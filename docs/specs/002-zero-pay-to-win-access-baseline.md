# Spec 002 — Baseline de acesso universal e zero pay to win

**Status:** inventário inicial; não autoriza mudança de economia

**Data:** 2026-10-25

**Baseline:** AAEmu `9549c76bd2c676fb6e3f6a2f2787e1113603cf6a`, cliente 1.2 r208022

## Objetivo

Transformar a visão da ADR 002 em fatos verificáveis sobre o baseline atual.
Este documento identifica o que o servidor chama de premium, seus efeitos
diretos conhecidos e as lacunas que precisam de evidência antes de declarar
que todos os antigos benefícios de assinatura estão disponíveis.

## Definição operacional proposta

Para o Projeto Aastra, zero pay to win significa que nenhum pagamento pode:

1. aumentar poder de combate ou capacidade econômica;
2. acelerar progressão, regeneração, obtenção de recursos ou recompensas;
3. remover limites de gameplay impostos a quem não paga;
4. conceder acesso exclusivo a conteúdo, mercado, moradia ou conveniências com
   efeito competitivo.

Todos os jogadores devem receber a mesma regra funcional. Isso não implica
distribuir moeda premium continuamente nem tornar gratuitos, sem análise,
itens originalmente vendidos: cada fonte e sumidouro precisa preservar a
economia.

## Fatos confirmados no servidor

### Estado premium da conta

- Cada `GameConnection` cria um `AccountPayment` novo.
- `AccountPayment.Method` inicia como `Premium`.
- O período padrão vai de `DateTime.MinValue` até 1º de janeiro de 2030.
- Não foi encontrada carga desse entitlement a partir do MySQL.
- Na data desta inspeção, toda conexão é tratada como premium pelo Game.

Consequência: a igualdade de entitlement já existe por hardcode, mas possui
data de expiração e não é uma política explícita ou durável do produto.

### Labor, credits e loyalty

Configuração observada em `CharacterSettings.json`:

| Recurso | Conta não premium | Conta premium atual | Frequência |
|---|---:|---:|---:|
| limite de labor | 2.000 | 5.000 | limite fixo no código |
| labor online | 5 | 10 | a cada 5 minutos |
| labor offline | 0 | 5 | a cada 5 minutos offline |
| credits | 0 | 100 | a cada 5 minutos online |
| loyalty periódico | 0 | 0 | a cada 5 minutos |
| loyalty no login diário | 5 | 5 | uma vez pelo fluxo diário |

Como todas as conexões estão premium, um jogador online recebe atualmente a
regra da coluna premium. A geração de 100 credits a cada cinco minutos equivale
a 1.200 credits por hora online, antes de considerar falhas, arredondamento ou
limites ainda não identificados.

Esse comportamento é um risco econômico alto. Credits são aceitos pelo fluxo
de cash shop; portanto, a gratuidade precisa ser desenhada junto com catálogo,
preços, fontes, sumidouros, auditoria e limites. Não se deve apenas manter a
taxa atual por ser igual para todos.

### Cliente e feature flags

- O bit `Feature.premium` está habilitado no `FeatureSet` enviado ao client.
- Os bits de botão de leilão, postagem em leilão e pré-pagamento de imposto da
  casa também estão habilitados no conjunto observado.
- O Game envia ao client o método e o período premium da conexão.
- O Login escreve `isPremium = false` no pacote de fila e comprimentos de fila
  iguais a zero. Não há evidência de priorização premium funcional na fila.

Os feature flags indicam disponibilidade de UI, não provam sozinhos que todas
as operações correspondentes estão completas ou autorizadas no servidor.

### Loja e compra de premium

- A listagem de serviço premium devolve uma oferta fixa de 30 dias com texto
  em russo e preço fixo.
- O pacote de compra apenas registra o identificador recebido; não concede nem
  persiste entitlement.
- O fluxo de mensagem premium é um stub.
- O servidor envia um pacote fixo de atualização de pontos premium durante a
  entrada no mundo.

Conclusão: o código contém superfície de protocolo e UI para premium, mas não
um sistema de assinatura funcional e persistente.

### Leilão e moradia

Não foi encontrada verificação de `PremiumState` nos handlers de leilão,
construção, compra, venda, decoração ou impostos de moradia inspecionados. Isso
sustenta apenas que o servidor não aplica uma barreira premium direta nesses
caminhos; o comportamento completo do client ainda depende do smoke.

## Inferências sustentadas

1. O baseline tenta oferecer uma experiência universalmente premium, mas por
   defaults temporários e incompletos, não por uma política explícita.
2. Labor offline e o limite maior de labor já são universalizados enquanto a
   data hardcoded permanecer válida.
3. A geração automática de credits pode converter a antiga monetização em uma
   torneira econômica sem controle, com impacto em itens e progressão.
4. Remover apenas a UI de assinatura não basta; pacotes, feature flags, ticks,
   loja e mensagens precisam de decisão coordenada.

## Hipóteses abertas

- Quais benefícios pertenciam exatamente à assinatura na build 1.2 r208022.
- Quais restrições eram impostas pelo client, pelo servidor oficial ou por
  serviços externos não reproduzidos no AAEmu.
- Se leilão, moradia, impostos, comércio e regeneração funcionam de ponta a
  ponta no client local.
- Quais itens do cash shop afetam poder, economia ou progressão.
- Se credits e loyalty devem existir no Projeto Aastra e, caso existam, quais
  fontes e usos são aceitáveis.

## Regras antes de implementar

1. Não alterar `AccountPayment`, ticks ou saldos antes do smoke da baseline.
2. Não conceder itens ou moedas em massa como substituto de assinatura.
3. Catalogar SKUs e classificar impacto em cosmético, conveniência,
   progressão, poder e economia.
4. Tornar entitlement universal uma regra explícita sem data de expiração,
   coberta por teste, em vez de depender de 2030.
5. Separar acesso universal de taxas de geração de recursos.
6. Testar reconexão, tempo offline, mudança de relógio, limites e idempotência
   antes de modificar labor ou recompensas periódicas.

## Critérios de conclusão do catálogo

- Cada benefício alegado possui evidência na build alvo.
- O componente responsável está identificado: client, protocolo, servidor,
  Compact, configuração ou MySQL.
- A regra universal desejada, o impacto econômico e o rollback estão escritos.
- Há testes para premium expirado, reconexão, tick repetido e saldo no limite.
- Nenhuma capacidade competitiva depende de pagamento.

## Evidência principal no clone local

- `AAEmu.Game/Models/AccountPayment.cs`;
- `AAEmu.Game/Core/Network/Connections/GameConnection.cs`;
- `AAEmu.Game/Core/Managers/TimedRewardsManager.cs`;
- `AAEmu.Game/Configurations/CharacterSettings.json`;
- `AAEmu.Game/Models/Game/Features/FeatureSet.cs`;
- `AAEmu.Game/Core/Packets/C2G/CSPremiumService*Packet.cs`;
- `AAEmu.Login/Core/Packets/L2C/ACWorldQueuePacket.cs`.

Esses caminhos são evidência de implementação do AAEmu, não comprovação do
comportamento histórico do serviço oficial.
