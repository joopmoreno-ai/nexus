# ADR 001 — Adotar AAEmu como baseline do ArcheLab

**Status:** aceita pelo proprietário

**Data:** 2026-10-24

**Decisor:** proprietário do laboratório

**Nota posterior:** a decisão técnica permanece vigente, mas o nome
`ArcheLab` foi substituído por **Projeto Aastra** na ADR 002. As ocorrências do
nome anterior abaixo são preservadas como registro da decisão original.

## Contexto

O objetivo do laboratório passou a ser experimentar trabalho de LiveOps em um
MMO conhecido pelo proprietário: itens e sets, progressão horizontal e
vertical, balanceamento de classes e cenários de equilíbrio. O estudo anterior
de NexusForever/WildStar mostrou custo e incerteza incompatíveis com esse foco.

O AAEmu é um servidor open source de ArcheAge em .NET. A branch `develop`
declara suporte ao cliente ArcheAge 1.2 r208022 e separa Login, Game, código
comum, persistência MySQL e dados estáticos em `compact.sqlite3`.

## Decisão

1. O projeto passa a se chamar **ArcheLab**.
2. O candidato de baseline é `AAEmu/AAEmu`, branch `develop`, no commit
   `9549c76bd2c676fb6e3f6a2f2787e1113603cf6a`.
3. O alvo inicial é exclusivamente ArcheAge 1.2 r208022; outras versões exigem
   nova evidência de protocolo e dados.
4. Como o host não possui Docker/Podman, o bootstrap inicial seguirá o fluxo
   standalone do upstream: processos .NET no host e MySQL 8 no host. Não haverá
   topologia híbrida.
5. Cliente, `game_pak`, launcher e `compact.sqlite3` permanecem locais e
   ignorados pelo Git. A aquisição do cliente e do banco estático exige ação
   humana e verificação de proveniência.
6. Os documentos do estudo NexusForever/WildStar serão preservados como
   histórico; esta ADR os substitui como direção arquitetural vigente.

## Consequências

- O runtime principal passa de uma malha NexusForever com RabbitMQ para os
  serviços Login e Game do AAEmu e dois schemas MySQL (`aaemu_login` e
  `aaemu_game`). RabbitMQ não faz parte do baseline observado.
- Alterações de LiveOps deverão primeiro distinguir dados estáticos do cliente,
  `compact.sqlite3`, configuração de servidor e estado mutável no MySQL.
- Nenhuma alteração de item, classe ou economia será feita antes de existir uma
  baseline jogável e um procedimento de backup/restore.
- O clone de inspeção fica em `.data/sources/AAEmu` e não integra ainda o
  histórico Git do ArcheLab. A estratégia de fork/vendor será decidida depois.

## Evidências e incertezas

- Commit observado: `9549c76bd2c676fb6e3f6a2f2787e1113603cf6a`, datado de
  2026-10-21T17:02:01Z.
- O inventário oficial do setup confirmou ausência local de cliente,
  `compact.sqlite3` e launcher.
- O host possui SDK .NET 10.0.302, mas o `global.json` do commit fixa a versão
  inválida `10.0.0`; o desvio será documentado e encaminhado ao upstream antes
  de qualquer patch permanente.
- A solução compilou sem erros ao invocar o SDK a partir da raiz do ArcheLab;
  1.150 testes unitários passaram. O restore emitiu `NU1902` para a dependência
  `MessagePack` 3.1.7, associada ao advisory `GHSA-qhrr-8q5h-9q3h`. A
  dependência vulnerável foi encontrada apenas no AppHost Aspire, que não faz
  parte do fluxo standalone atual; ela deve ser atualizada antes de adotar
  Aspire ou expor o AppHost.
- A licença não está classificada: o README declara LGPL-3.0-or-later, enquanto
  o repositório contém um texto GPLv3 em `LICENSE.GPL` e uma licença MIT em
  `LICENSE.MIT`. Distribuição e publicação de derivados aguardam esclarecimento.

## Rollback

Antes de criar dados de jogador, o rollback consiste em remover o clone local
ignorado e reverter esta documentação. Cliente e dados locais não serão
apagados automaticamente. Uma mudança futura de baseline exige nova ADR.
