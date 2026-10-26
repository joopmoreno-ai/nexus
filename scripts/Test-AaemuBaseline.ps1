[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$sourceRoot = Join-Path $repoRoot '.data\sources\AAEmu'
$expectedCommit = '9549c76bd2c676fb6e3f6a2f2787e1113603cf6a'

$checks = @(
    [pscustomobject]@{
        Name = 'cliente r208022'
        Path = Join-Path $sourceRoot '.client_files\ArcheAge 1.2 (r208022) for AAEmu\bin32\archeage.exe'
    },
    [pscustomobject]@{
        Name = 'game_pak'
        Path = Join-Path $sourceRoot '.client_files\ArcheAge 1.2 (r208022) for AAEmu\game_pak'
    },
    [pscustomobject]@{
        Name = 'launcher'
        Path = Join-Path $sourceRoot '.client_files\launcher\AAEmu.Launcher\AAEmu.Launcher.exe'
    },
    [pscustomobject]@{
        Name = 'Compact do servidor'
        Path = Join-Path $sourceRoot 'AAEmu.Game\Data\compact.sqlite3'
    },
    [pscustomobject]@{
        Name = 'configuracao local do Login'
        Path = Join-Path $sourceRoot 'AAEmu.Login\Config.Local.json'
    },
    [pscustomobject]@{
        Name = 'configuracao local do Game'
        Path = Join-Path $sourceRoot 'AAEmu.Game\Config.Local.json'
    }
)

$failures = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw 'Clone local do AAEmu ausente no alias esperado.'
}

$actualCommit = (& git -C $sourceRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $actualCommit -ne $expectedCommit) {
    $failures.Add('O clone nao esta no commit fixado pelo manifesto.')
}
else {
    Write-Output '[PASS] commit fixado do AAEmu'
}

$sourceStatus = @(& git -C $sourceRoot status --short)
if ($LASTEXITCODE -ne 0 -or $sourceStatus.Count -ne 0) {
    $failures.Add('O clone local do AAEmu possui alteracoes rastreadas ou nao ignoradas.')
}
else {
    Write-Output '[PASS] clone local limpo'
}

foreach ($check in $checks) {
    $item = Get-Item -LiteralPath $check.Path -ErrorAction SilentlyContinue
    if ($null -eq $item -or ($item -is [System.IO.FileInfo] -and $item.Length -le 0)) {
        $failures.Add("Artefato ausente ou vazio: $($check.Name).")
        continue
    }

    Write-Output "[PASS] $($check.Name)"
}

$mysqlConfig = Join-Path $repoRoot '.data\mysql\my.ini'
if (-not (Test-Path -LiteralPath $mysqlConfig -PathType Leaf)) {
    $failures.Add('Configuracao local do MySQL ausente.')
}
else {
    $bindLine = Get-Content -LiteralPath $mysqlConfig |
        Where-Object { $_ -match '^\s*bind-address\s*=' } |
        Select-Object -First 1

    if ($bindLine -notmatch '^\s*bind-address\s*=\s*127\.0\.0\.1\s*$') {
        $failures.Add('O MySQL nao esta explicitamente limitado a 127.0.0.1.')
    }
    else {
        Write-Output '[PASS] MySQL limitado a loopback IPv4'
    }
}

if ($failures.Count -gt 0) {
    foreach ($failure in $failures) {
        Write-Error $failure -ErrorAction Continue
    }

    throw "Preflight reprovado com $($failures.Count) problema(s)."
}

Write-Output '[PASS] preflight da baseline concluido'
