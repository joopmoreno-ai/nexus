# Inventário do estado atual

Inventário factual do baseline vigente do Projeto Aastra, atualizado em
2026-10-25.
Ele descreve o que foi observado no commit fixado do AAEmu e no bootstrap
standalone local; não define comportamento desejado nem autoriza distribuição
de código ou assets.

## Fontes e versões

| Componente | Origem | Ref/versão observada | Estado |
|---|---|---|---|
| AAEmu | `AAEmu/AAEmu` | `develop` em `9549c76bd2c676fb6e3f6a2f2787e1113603cf6a` | clone local limpo e fixado pelo manifesto |
| Cliente ArcheAge | cópia local autorizada | 1.2 r208022 | presença validada; smoke interativo pendente |
| Compact do servidor | artefato separado indicado pelo upstream | schema com 679 tabelas | `PRAGMA quick_check` aprovado e carga completa pelo Game |
| MySQL | instalação local | 8.4.9 | loopback, dois schemas ativos e restauração isolada aprovada |

A classificação de licença do AAEmu continua como `NOASSERTION`: o README
declara LGPL-3.0-or-later, enquanto o repositório contém textos GPLv3 e MIT.
Distribuição de derivados aguarda esclarecimento. O manifesto vigente é
`docs/manifests/aastra-upstream-sources.yaml`.

## Processos e serviços

| Processo/recurso | Responsabilidade observada | Dependências | Estado comprovado |
|---|---|---|---|
| AAEmu.Login | login e registro do Game | `aaemu_login`, chave compartilhada e configuração local | iniciou em loopback nas portas 1234/1237 |
| AAEmu.Game | mundo e gameplay | `aaemu_game`, Compact do servidor e Login | iniciou em loopback nas portas 1239/1250/1280, registrou-se no Login e concluiu a carga |
| MySQL | estado mutável do Login e Game | diretório de dados local ignorado pelo Git | 8.4.9 em `127.0.0.1:3306` |
| Cliente/launcher | sessão interativa | cliente r208022, launcher e serviços locais | artefatos presentes; fluxo completo ainda não executado |

O AppHost Aspire existe no upstream, mas não integra o baseline standalone e
não foi executado. RabbitMQ, containers, serviços remotos e observabilidade não
fazem parte da topologia aprovada atual.

## Persistência e recuperação

| Recurso | Conteúdo observado | Consumidores | Recuperação comprovada |
|---|---|---|---|
| `aaemu_login` | 3 tabelas no backup vigente | AAEmu.Login | dump restaurado em schema descartável e verificado pelo `mysqlcheck` |
| `aaemu_game` | 35 tabelas no backup vigente | AAEmu.Game | dump restaurado em schema descartável e verificado pelo `mysqlcheck` |
| Compact do servidor | 679 tabelas de dados estáticos | AAEmu.Game | integridade SQLite e carga pelo Game aprovadas; não é substituto de backup MySQL |
| Compact do cliente | dados consumidos pelo cliente | cliente r208022 | presente; compatibilidade visual e funcional ainda depende do smoke interativo |

O ensaio de 2026-10-25 identificou que o dump inicial do Game, com 34 tabelas,
precedia a criação automática de `updates`. Um novo backup da baseline ativa
foi gerado e restaurado em destinos descartáveis: 3 tabelas de Login e 35 de
Game, todas aprovadas pelo `mysqlcheck`. Os destinos foram removidos e os
schemas originais não foram sobrescritos. Como os dumps precedem a criação de
um personagem, o ensaio prova restauração estrutural, não recuperação de
progresso de jogador.

O procedimento foi automatizado em
`scripts/Invoke-AaemuBackupRestoreTest.ps1` e repetido com comparação exata dos
nomes de tabela e das contagens de linhas entre origem e restauração.

## Rede

| Serviço | Porta observada | Binding observado | Exposição autorizada |
|---|---:|---|---|
| AAEmu.Login | 1234/1237 | loopback | somente host local |
| AAEmu.Game | 1239/1250/1280 | loopback | somente host local |
| MySQL | 3306 | `127.0.0.1` | somente host local |

Nenhuma dessas portas estava em escuta no início da revisão de 2026-10-25,
exceto o MySQL. Uma porta livre ou um processo iniciado uma vez não constitui
monitoramento contínuo.

## Diretórios e assets locais

| Alias | Finalidade | Política |
|---|---|---|
| `.data/sources/AAEmu` | clone e runtime local do AAEmu | ignorado; clone limpo no commit fixado |
| `.data/sources/AAEmu/.client_files` | cliente, launcher e downloads locais | ignorado; material proprietário não distribuível sem autorização |
| `.data/mysql` | dados do MySQL standalone | ignorado; não versionar |
| `.data/secrets` | credenciais protegidas do usuário local | ignorado; não exibir nem copiar para comandos/documentos |
| `.data/backups` | dumps locais do bootstrap | ignorado; restaurar somente em destino isolado durante ensaios |
| `AAEmu/` | pacotes locais de cliente recebidos | ignorado; não incorporar ao histórico Git |

## Fluxo Login → Game

### Fatos confirmados

1. Login e Game usam configurações locais ignoradas pelo Git e a mesma chave
   compartilhada, sem registrar seu valor.
2. Login iniciou antes do Game.
3. O Game registrou-se no Login e concluiu a carga do Compact.

### Hipótese ainda aberta

O fluxo `launcher → login → criação de personagem → entrada no mundo → logout
→ novo login` ainda não foi comprovado. Até esse smoke, não há evidência E2E de
persistência de personagem, inventário ou sessão.

## Estado de validação

- Build: zero erros; dois avisos `NU1902` do MessagePack 3.1.7 no AppHost não
  utilizado.
- Testes unitários: 1.150 aprovados, zero falhas e zero ignorados.
- Bootstrap dos serviços: aprovado em loopback.
- Backup e restauração estrutural da baseline ativa: aprovados em destino
  isolado.
- Smoke interativo e recuperação de dados criados pelo jogador: pendentes.

## Riscos e decisões pendentes

1. Executar o smoke interativo antes de qualquer mudança de gameplay.
2. Gerar um backup pós-smoke e provar a recuperação do personagem em schemas
   isolados; o ensaio atual contém apenas a baseline sem jogador.
3. A ADR 003 mantém o AAEmu como clone externo fixado por manifesto; mudanças
   feitas somente no clone ignorado continuam descartáveis até a revisão de
   licença e adoção de um fluxo de patches ou fork.
4. Esclarecer a licença antes de distribuir código derivado e nunca versionar
   cliente, `game_pak`, Compact ou outros assets proprietários.
5. Atualizar ou remover o MessagePack vulnerável antes de adotar o AppHost.

Os documentos do NexusLab/NexusForever permanecem apenas como evidência
histórica e não descrevem este baseline.
