# Runbook 001 — Bootstrap standalone do Projeto Aastra

## Objetivo

Obter uma baseline local e reproduzível do AAEmu para ArcheAge 1.2 r208022,
sem expor serviços, versionar segredos ou misturar processos do host com
containers.

## Escopo e pré-condições

- Fonte fixada pelo manifesto em `.data/sources/AAEmu`.
- Windows e SDK .NET 10 no host.
- Fluxo standalone enquanto não houver runtime OCI aprovado.
- MySQL 8 no host; MariaDB não é assumido compatível.
- Cliente, launcher e `compact.sqlite3` obtidos manualmente de fonte autorizada.
- Nenhuma conta, personagem ou economia de valor será migrada neste marco.

## Gate 0 — Fonte e toolchain

1. Confirmar que `git -C .data/sources/AAEmu status --short` está vazio.
2. Confirmar o commit com `git -C .data/sources/AAEmu rev-parse HEAD`.
3. Executar `dotnet --version`.
4. Registrar a falha conhecida do `global.json` antes de aplicar qualquer
   workaround. Não alterar o upstream sem issue/patch rastreável.
5. Compilar a solução e executar testes unitários sem iniciar serviços.

No commit atualmente fixado, a validação foi feita a partir da raiz do Projeto
Aastra para que o SDK não interpretasse o `global.json` inválido:

```powershell
dotnet build .data\sources\AAEmu\AAEmu.slnx --configuration Debug
.\.data\sources\AAEmu\AAEmu.UnitTests\bin\Debug\net10.0\AAEmu.UnitTests.exe `
  --no-ansi --no-progress --minimum-expected-tests 1
```

Critério de saída: build e testes com resultado registrado, ou bloqueio
reproduzível atribuído a uma dependência específica.

## Gate 1 — Artefatos locais com ação humana

Na raiz do Projeto Aastra, executar:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File scripts\Test-AaemuBaseline.ps1
```

O comando valida o commit fixado, a limpeza do clone, presença dos artefatos e
configurações locais e o bind do MySQL em loopback. Ele não prova proveniência
ou compatibilidade. Registre separadamente a origem autorizada; no Compact do
servidor, execute `PRAGMA quick_check`, confirme a tabela
`item_socket_chances` e exija que o Game conclua a carga.

A pessoa operadora deve fornecer e validar:

- cliente ArcheAge 1.2 r208022, com `game_pak` e `bin32/archeage.exe`;
- `AAEmu.Game/Data/compact.sqlite3`;
- AAEmu Launcher compatível.

Reexecutar o inventário até os três itens aparecerem como presentes. Não
copiar esses artefatos para caminhos versionados nem publicar seus hashes como
prova de licença.

## Gate 2 — MySQL e configuração local

1. Instalar MySQL 8 por um mecanismo aprovado e manter o bind em loopback.
2. Criar um usuário local dedicado, com segredo fora do Git.
3. Criar os schemas `aaemu_login` e `aaemu_game`.
4. Importar `SQL/aaemu_login.sql` e `SQL/aaemu_game.sql` conforme o upstream.
5. Criar `AAEmu.Login/Config.Local.json` e
   `AAEmu.Game/Config.Local.json`; ambos já são ignorados pelo upstream.
6. Usar o mesmo `SecretKey` nos dois serviços e configurar `GameServers` no
   Login. Não inserir manualmente linhas de servidor no banco.

Critério de saída: schemas restauráveis, configurações locais sem segredo no
Git e nenhuma porta publicada fora de loopback sem decisão específica.

## Gate 3 — Smoke test jogável

1. Fazer backup inicial dos dois schemas.
2. Iniciar Login antes de Game.
3. Verificar logs sem expor credenciais.
4. Conectar pelo launcher, criar uma conta de teste e um personagem descartável.
5. Validar login, entrada no mundo, inventário básico e logout persistente.
6. Parar os processos e restaurar o backup em schemas novos e descartáveis,
   nunca sobre `aaemu_login` ou `aaemu_game`.
7. Executar `mysqlcheck` nos destinos restaurados, comparar a quantidade de
   tabelas com a origem e remover somente os schemas descartáveis após a
   coleta da evidência.

Com Login e Game parados, os passos 6 e 7 são automatizados por:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File scripts\Invoke-AaemuBackupRestoreTest.ps1
```

O script gera um novo backup, restaura em schemas com prefixo
`aastra_restore_`, compara nomes de tabelas e contagens exatas de linhas,
executa `mysqlcheck` e remove somente os schemas descartáveis criados pela
própria execução. A credencial fica no processo e nunca é passada em argumento.

## Gate 4 — Baseline de LiveOps

Antes da primeira mudança de gameplay:

1. catalogar onde o dado alvo vive: cliente, `compact.sqlite3`, configuração,
   script ou MySQL;
2. definir hipótese, métrica, coorte de teste e rollback;
3. capturar baseline reproduzível;
4. alterar um eixo por vez;
5. validar integridade de conta, personagem, inventário e moeda.

## Limitações atuais

- A classificação de licença do AAEmu está pendente por inconsistência entre
  README e arquivos de licença.
- O AppHost Aspire referencia `MessagePack` 3.1.7, afetado por
  `GHSA-qhrr-8q5h-9q3h`; o componente não deve ser usado antes de atualização e
  validação. Login, Game e os projetos de teste não foram sinalizados pelo
  inventário NuGet atual.
- O host possui MySQL 8.4.9 em loopback. Em 2026-10-25, os dumps iniciais foram
  restaurados em schemas descartáveis. Como o primeiro dump do Game ainda não
  continha a tabela `updates`, foi gerado um novo backup da baseline ativa: 3
  tabelas de Login e 35 de Game passaram no `mysqlcheck`; os destinos de teste
  foram removidos.
- Cliente, launcher e o Compact separado passaram no inventário local. O
  `compact.sqlite3` distribuído dentro do pacote do cliente recebido não era
  compatível e foi mantido apenas em quarentena local.
- Login e Game iniciam em loopback e o Game registra no Login. O login pelo
  launcher e a persistência do personagem ainda precisam de validação
  interativa. Depois do smoke, um novo backup deve provar também recuperação
  de dados criados pelo jogador.
- O `global.json` do commit selecionado contém uma versão de SDK inválida.
