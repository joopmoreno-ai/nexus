# ADR 002 — Nome e visão de produto do Projeto Aastra

**Status:** aceita pelo proprietário

**Data:** 2026-10-25

**Decisor:** proprietário do projeto

## Contexto

O baseline AAEmu já permite estudar o cliente ArcheAge 1.2 r208022, conteúdo,
progressão e balanceamento. Faltava registrar a identidade do projeto e os
limites de produto que devem orientar as futuras decisões de conteúdo,
economia e operação.

## Decisão

1. O projeto passa a se chamar **Projeto Aastra**. O nome `ArcheLab` fica
   restrito ao histórico anterior a esta decisão.
2. A direção do produto é oferecer uma experiência de ArcheAge clássico
   renovada, usando a versão 1.2 r208022 como baseline técnico inicial.
3. A narrativa e os textos das quests serão integralmente reescritos. IDs,
   objetivos, condições, recompensas e encadeamentos existentes não serão
   alterados implicitamente por essa diretriz; mudanças de mecânica exigem
   especificação e validação próprias.
4. As classes receberão um novo equilíbrio. Nenhuma fórmula, coeficiente ou
   meta específico é definido por esta ADR; alterações devem partir de uma
   baseline mensurável e mudar um eixo por vez.
5. O produto terá **zero pay to win**: pagamento não poderá conceder vantagem
   de poder, velocidade de progressão, moeda, equipamento ou acesso exclusivo
   a sistemas de gameplay.
6. Sistemas e benefícios que dependiam de assinatura na experiência original
   deverão estar disponíveis a todos os jogadores por regras normais de jogo.
   A lista exata desses sistemas ainda precisa ser inventariada para a build
   alvo; memória ou comportamento de outras versões não constitui evidência.
7. Esta decisão não define preços, loja, doações, cosméticos ou outro modelo de
   sustentabilidade. Qualquer proposta futura deverá preservar o item 5 e
   passar por análise de economia, integridade e risco jurídico.

## Consequências

- Conteúdo narrativo precisa de fonte versionada, validação de referências,
  diff legível e aplicação determinística aos artefatos locais.
- Balanceamento requer métricas, cenários reproduzíveis, rollback e testes de
  impacto PvE/PvP antes de publicação.
- A remoção de barreiras de assinatura afeta configuração, client, servidor e
  possivelmente persistência; cada capacidade deverá ter origem e consumidores
  identificados antes de ser alterada.
- Recompensas, progressão e economia continuam sujeitas às revisões de
  Gameplay, Persistência, Integridade e QA.
- Cliente, áudio, mapas, `game_pak` e Compact permanecem proprietários e não
  serão incorporados ao Git nem distribuídos sem autorização comprovada.

## Critérios iniciais de aceitação

- O smoke jogável da baseline é concluído antes de alterações de conteúdo.
- Existe um catálogo evidenciado dos benefícios de assinatura na build alvo.
- A primeira quest reescrita mantém objetivos e recompensas deliberadamente e
  passa de ponta a ponta no client e servidor.
- A primeira alteração de balanceamento possui hipótese, métrica, comparação e
  rollback documentados.
- Nenhum caminho de pagamento concede vantagem funcional ou acesso exclusivo
  a gameplay.

## Pendências explícitas

1. Inventariar os benefícios de assinatura da build 1.2 r208022.
2. Definir princípios mensuráveis de balanceamento de classes.
3. Revisar a integração Git provisória definida na ADR 003 quando houver
   licença esclarecida ou a primeira mudança própria no servidor.
4. Definir, somente se necessário, um modelo de sustentabilidade compatível
   com zero pay to win.

## Registro de execução

Em 2026-10-25, o repositório GitHub existente foi renomeado de
`joopmoreno-ai/nexus` para `joopmoreno-ai/projeto-aastra`, preservando histórico
e visibilidade pública. O remote local `origin` foi atualizado e sua leitura
foi validada após a mudança.

## Rollback

O nome pode ser substituído por nova ADR. Reverter a visão de acesso ou
economia depois da existência de jogadores exigirá análise de compatibilidade,
comunicação e impacto; não é um rollback puramente documental.
