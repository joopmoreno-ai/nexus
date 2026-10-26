[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string] $MySqlBinDirectory = 'C:\Program Files\MySQL\MySQL Server 8.4\bin',
    [string] $CredentialPath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$backupRoot = Join-Path $repoRoot '.data\backups'

if ([string]::IsNullOrWhiteSpace($CredentialPath)) {
    $CredentialPath = Join-Path $repoRoot '.data\secrets\mysql-root.credential.clixml'
}

$mysql = Join-Path $MySqlBinDirectory 'mysql.exe'
$mysqlDump = Join-Path $MySqlBinDirectory 'mysqldump.exe'
$mysqlCheck = Join-Path $MySqlBinDirectory 'mysqlcheck.exe'

foreach ($requiredTool in @($mysql, $mysqlDump, $mysqlCheck)) {
    if (-not (Test-Path -LiteralPath $requiredTool -PathType Leaf)) {
        throw "Ferramenta MySQL ausente: $([System.IO.Path]::GetFileName($requiredTool))."
    }
}

if (-not (Test-Path -LiteralPath $CredentialPath -PathType Leaf)) {
    throw 'Credencial administrativa local do MySQL ausente.'
}

if (-not (Test-Path -LiteralPath $backupRoot -PathType Container)) {
    throw 'Diretorio local de backups ausente.'
}

$credential = Import-Clixml -LiteralPath $CredentialPath
if ($credential -isnot [System.Management.Automation.PSCredential]) {
    throw 'O arquivo de credencial nao contem um PSCredential valido.'
}

$stamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssfffZ')
$runId = "${stamp}_$PID"
$backupDirectory = Join-Path $backupRoot $stamp
$loginRestore = "aastra_restore_login_$runId"
$gameRestore = "aastra_restore_game_$runId"
$restorePattern = '^aastra_restore_(login|game)_\d{8}T\d{9}Z_\d+$'
$createdRestoreSchemas = New-Object System.Collections.Generic.List[string]

foreach ($schema in @($loginRestore, $gameRestore)) {
    if ($schema -notmatch $restorePattern) {
        throw 'A protecao de nome recusou um schema descartavel invalido.'
    }
}

if (-not $PSCmdlet.ShouldProcess(
        'aaemu_login e aaemu_game',
        'Gerar backup, restaurar em schemas descartaveis e validar conteudo')) {
    return
}

$runtimePorts = @(1234, 1237, 1239, 1250, 1280)
$activeRuntimeListeners = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -in $runtimePorts })
if ($activeRuntimeListeners.Count -gt 0) {
    throw 'Pare Login e Game antes do backup para obter uma baseline consistente.'
}

$previousPassword = [Environment]::GetEnvironmentVariable('MYSQL_PWD', 'Process')
$env:MYSQL_PWD = $credential.GetNetworkCredential().Password
$databaseUser = $credential.UserName
$createdBackup = $false

function Invoke-MySqlCommand {
    param([Parameter(Mandatory = $true)][string] $Sql)

    $output = & $mysql `
        --host=127.0.0.1 `
        --port=3306 `
        --user=$databaseUser `
        --protocol=TCP `
        --batch `
        --skip-column-names `
        --execute=$Sql

    if ($LASTEXITCODE -ne 0) {
        throw "Comando MySQL falhou com codigo $LASTEXITCODE."
    }

    return @($output)
}

function Start-RedirectedProcess {
    param(
        [Parameter(Mandatory = $true)][string] $FilePath,
        [Parameter(Mandatory = $true)][string[]] $ArgumentList,
        [string] $StandardInput,
        [string] $StandardOutput
    )

    $parameters = @{
        FilePath = $FilePath
        ArgumentList = $ArgumentList
        WindowStyle = 'Hidden'
        Wait = $true
        PassThru = $true
    }

    if ($StandardInput) {
        $parameters.RedirectStandardInput = $StandardInput
    }
    if ($StandardOutput) {
        $parameters.RedirectStandardOutput = $StandardOutput
    }

    $process = Start-Process @parameters
    if ($process.ExitCode -ne 0) {
        throw "$([System.IO.Path]::GetFileName($FilePath)) falhou com codigo $($process.ExitCode)."
    }
}

try {
    $staleRestoreSchemas = @(Invoke-MySqlCommand -Sql "SELECT schema_name FROM information_schema.schemata WHERE schema_name LIKE 'aastra_restore_%';")
    if ($staleRestoreSchemas.Count -gt 0) {
        throw "Existem $($staleRestoreSchemas.Count) schema(s) descartavel(is) de execucao anterior; revise-os antes de continuar."
    }

    New-Item -ItemType Directory -Path $backupDirectory | Out-Null
    $createdBackup = $true

    $databasePairs = @(
        [pscustomobject]@{
            Source = 'aaemu_login'
            Restore = $loginRestore
            Dump = Join-Path $backupDirectory 'aaemu_login.sql'
        },
        [pscustomobject]@{
            Source = 'aaemu_game'
            Restore = $gameRestore
            Dump = Join-Path $backupDirectory 'aaemu_game.sql'
        }
    )

    foreach ($pair in $databasePairs) {
        $dumpArguments = @(
            '--host=127.0.0.1',
            '--port=3306',
            "--user=$databaseUser",
            '--protocol=TCP',
            '--single-transaction',
            '--no-tablespaces',
            '--routines',
            '--events',
            '--triggers',
            '--set-gtid-purged=OFF',
            $pair.Source
        )

        Start-RedirectedProcess `
            -FilePath $mysqlDump `
            -ArgumentList $dumpArguments `
            -StandardOutput $pair.Dump

        if (-not ((Get-Content -LiteralPath $pair.Dump -Tail 3) -match 'Dump completed')) {
            throw "O dump de $($pair.Source) nao possui marcador de conclusao."
        }
    }

    foreach ($schema in @($loginRestore, $gameRestore)) {
        $existingSchema = @(Invoke-MySqlCommand -Sql "SELECT schema_name FROM information_schema.schemata WHERE schema_name='$schema';")
        if ($existingSchema.Count -ne 0) {
            throw "O schema descartavel ja existe e nao sera reutilizado: $schema."
        }

        Invoke-MySqlCommand -Sql "CREATE DATABASE $schema CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;" | Out-Null
        $createdRestoreSchemas.Add($schema)
    }

    foreach ($pair in $databasePairs) {
        $restoreArguments = @(
            '--host=127.0.0.1',
            '--port=3306',
            "--user=$databaseUser",
            '--protocol=TCP',
            $pair.Restore
        )

        Start-RedirectedProcess `
            -FilePath $mysql `
            -ArgumentList $restoreArguments `
            -StandardInput $pair.Dump
    }

    $checkOutput = & $mysqlCheck `
        --host=127.0.0.1 `
        --port=3306 `
        --user=$databaseUser `
        --protocol=TCP `
        --check `
        --databases `
        $loginRestore `
        $gameRestore 2>&1

    if ($LASTEXITCODE -ne 0 -or ($checkOutput -match '(?i)error')) {
        throw 'O mysqlcheck reprovou um dos schemas restaurados.'
    }
    Write-Output '[PASS] mysqlcheck aprovou os schemas restaurados'

    foreach ($pair in $databasePairs) {
        $sourceTables = @(Invoke-MySqlCommand -Sql "SELECT table_name FROM information_schema.tables WHERE table_schema='$($pair.Source)' ORDER BY table_name;")
        $restoredTables = @(Invoke-MySqlCommand -Sql "SELECT table_name FROM information_schema.tables WHERE table_schema='$($pair.Restore)' ORDER BY table_name;")

        if (($sourceTables -join "`n") -ne ($restoredTables -join "`n")) {
            throw "As tabelas restauradas de $($pair.Source) divergem da origem."
        }

        foreach ($table in $sourceTables) {
            if ($table -notmatch '^[A-Za-z0-9_]+$') {
                throw "Nome de tabela nao suportado na validacao: $table."
            }

            $counts = @(Invoke-MySqlCommand -Sql "SELECT (SELECT COUNT(*) FROM $($pair.Source).``$table``), (SELECT COUNT(*) FROM $($pair.Restore).``$table``);")
            if ($counts.Count -ne 1) {
                throw "Nao foi possivel validar a contagem de $($pair.Source).$table."
            }

            $parts = $counts[0] -split "`t"
            if ($parts.Count -ne 2 -or $parts[0] -ne $parts[1]) {
                throw "A contagem restaurada diverge em $($pair.Source).$table."
            }
        }

        Write-Output "[PASS] $($pair.Source): $($sourceTables.Count) tabelas com contagens identicas"
    }

    Write-Output "[PASS] backup restaurado e validado: .data/backups/$stamp"
}
catch {
    if ($createdBackup) {
        Write-Warning "Backup incompleto ou nao validado preservado em .data/backups/$stamp para diagnostico."
    }
    throw
}
finally {
    foreach ($schema in $createdRestoreSchemas) {
        if ($schema -match $restorePattern) {
            try {
                Invoke-MySqlCommand -Sql "DROP DATABASE IF EXISTS $schema;" | Out-Null
            }
            catch {
                Write-Warning "Nao foi possivel remover o schema descartavel $schema."
            }
        }
    }

    if ($null -eq $previousPassword) {
        Remove-Item Env:MYSQL_PWD -ErrorAction SilentlyContinue
    }
    else {
        $env:MYSQL_PWD = $previousPassword
    }

    $credential = $null
}
