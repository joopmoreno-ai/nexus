# Handoff técnico — capacidades de conteúdo do Projeto Aastra — 2026-10-25

## Objetivo entendido

Registrar o estado deixado para o próximo agente após o bootstrap standalone e
a inspeção inicial das capacidades de quests, cinematics, habilidades, combate
e instâncias do AAEmu com o cliente ArcheAge 1.2 r208022.

Este documento é um inventário técnico, não uma autorização para distribuir o
cliente, o `game_pak`, o Compact ou outros assets proprietários.

## Contexto e fontes inspecionadas

- Baseline: `AAEmu/AAEmu`, branch observada `develop`, commit
  `9549c76bd2c676fb6e3f6a2f2787e1113603cf6a`.
- Cliente alvo: ArcheAge 1.2 r208022.
- Clone local ignorado pelo Git: `.data/sources/AAEmu`.
- Compact usado pelo servidor:
  `.data/sources/AAEmu/AAEmu.Game/Data/compact.sqlite3`.
- Compact presente no cliente local:
  `.data/sources/AAEmu/.client_files/ArcheAge 1.2 (r208022) for AAEmu/game/db/compact.sqlite3`.
- Resultado do bootstrap: Login e Game inicializaram em loopback e se
  registraram entre si. A evidência detalhada está em
  `docs/evidence/bootstrap-standalone-2026-10-24.md`.

Os dois Compacts têm papéis distintos. Não se deve presumir que editar apenas
um deles seja suficiente. Dados consumidos pelo servidor devem permanecer
compatíveis com IDs e referências usados pelo client.

## Estado do ambiente confirmado

- O Compact ativo do servidor passou no `PRAGMA quick_check`, contém 679
  tabelas e inclui `item_socket_chances`.
- A solução compilou com zero erros; houve dois avisos conhecidos relacionados
  a `MessagePack` 3.1.7 no AppHost, que não integra o fluxo standalone atual.
- Os 1.150 testes unitários passaram, sem falhas ou testes ignorados.
- Login e Game iniciaram em loopback e o Game concluiu a carga.
- Permanece pendente o smoke interativo completo do client. Um backup da
  baseline ativa dos bancos MySQL foi restaurado e verificado em schemas
  descartáveis;
  após o smoke, ainda será necessário provar a recuperação do personagem
  criado a partir de um novo backup.

## Quests e reescrita narrativa

### Fatos confirmados

- Existem 4.876 registros em `quest_contexts`.
- Os principais textos estão em estruturas do Compact como:
  - `quest_names`;
  - `quest_context_texts`;
  - `quest_component_texts`;
  - `quest_chat_bubbles`;
  - `quest_mails`;
  - `localized_texts`.
- Objetivos, condições, recompensas, IDs de NPCs e encadeamento são dados
  separados do texto narrativo.

### Conclusão

É viável reescrever somente a narrativa das quests, preservando sua lógica.
Uma alteração segura deve manter IDs, tipos de componente, condições,
objetivos, recompensas e ligações entre quests, modificando apenas os campos de
texto e localização pretendidos.

### Risco principal

Textos novos podem contradizer falas gravadas, cinematics, animações ou a
identidade visual do NPC. Como a decisão atual aceita retirar a dublagem, a
estratégia recomendada é remover referências de voz apenas nas quests
reescritas e preservar efeitos sonoros de gameplay.

Não editar o Compact manualmente como processo definitivo. Criar uma fonte de
conteúdo versionada e uma ferramenta que valide IDs/referências, produza diff e
aplique o patch deterministicamente aos artefatos locais.

## Dublagem, câmeras e cinematics

### Inventário confirmado no Compact do client

| Estrutura | Quantidade/achado |
|---|---:|
| `cinemas` | 149 |
| `cinema_captions` | 97 |
| `cinema_subtitles` | 71 |
| `quest_cameras` | 51 |
| componentes de quest com `cinema_id` não nulo/zero | 111 |
| componentes com `summary_voice_id` não nulo/zero | 203 |
| componentes com `sound_id` não nulo/zero | 17 |
| `quest_chat_bubbles` | 13.268 |
| balões com `sound_id` não nulo/zero | 35 |
| balões com `camera_id` não nulo/zero | 109 |
| `quest_act_obj_cinemas` | 12 |

Dos 4.876 contextos de quest, 4.869 possuem `use_quest_camera = true`. Isso
indica uso amplo da câmera de diálogo; não significa que existam 4.869
cutscenes completas.

### Capacidades e limites

- É possível trocar legendas em `cinema_subtitles` e textos associados em
  `cinema_captions` sem mudar a coreografia.
- É possível retirar referências de voz, desde que `summary_voice_id` e sons de
  diálogo sejam diferenciados de efeitos sonoros usados pelo gameplay.
- O banco associa IDs, nomes, legendas e câmeras, mas não contém sozinho toda a
  coreografia da cinematic.
- A execução da cena é predominantemente responsabilidade do client.
- `QuestActObjCinema` acompanha início e fim da cena e contém o comentário de
  que presume que o client iniciará a cinematic.
- `CinemalEffect.Apply` existe, mas atualmente apenas registra trace; não
  dispara uma cena no servidor.

### Inferência sustentada

Editar câmera, duração, atores, movimentos e animações de uma cinematic exige
extrair e reconstruir os assets correspondentes no client. O formato e o
toolchain corretos ainda não foram comprovados nesta build. A única evidência
desempacotada encontrada fora do `game_pak` foi um arquivo pequeno em
`game/worlds/login2/cinemas/en_us/09_ci.xml`, composto apenas por espaços e sem
coreografia utilizável.

### Prova de conceito recomendada

Escolher uma cinematic curta existente e validar, nesta ordem:

1. troca de legenda;
2. remoção da voz sem remover efeitos de gameplay;
3. sincronização temporal e quebra de linhas;
4. empacotamento e carregamento pelo client;
5. início, término e avanço correto da quest no servidor.

Somente depois avaliar edição completa da coreografia.

## Habilidades, árvores e NPCs

### Fatos confirmados

- O Compact do client contém 15.126 skills, 19.285 vínculos em
  `skill_effects`, 23.697 efeitos e 9.816 buffs.
- O Compact do servidor contém 7.845 atribuições em `np_skills`, cobrindo
  3.265 owners e 3.194 skills distintas.
- Existem 805 atribuições em `np_passive_buffs`, cobrindo 759 owners e 41 buffs
  passivos distintos.
- As skills de NPC são vinculadas por `owner_id`, `skill_id`, condição de uso e
  dois parâmetros de condição. A IA decide quando usá-las.
- `AbilityType` é uma enumeração fixa no servidor com as árvores conhecidas
  desta versão.

### Conclusão

- Criar ou recombinar habilidades é tecnicamente possível, reaproveitando
  efeitos, buffs, animações, projéteis e regras já suportadas.
- Criar um skillset/árvore realmente novo é uma mudança maior: envolve client,
  UI, localização, enumerações e regras do servidor, progressão/persistência e
  possivelmente contratos de protocolo.
- Uma “classe” no modelo do ArcheAge deriva da combinação de árvores. Novos
  nomes ou combinações devem ser tratados separadamente de uma nova árvore de
  habilidades.

Antes de criar habilidade nova, validar se todos os seus tipos de efeito estão
implementados. A existência de uma linha no Compact não prova suporte funcional
no AAEmu.

## Tipos e fórmula de dano

### Tipos implementados

`DamageType` possui:

- `Melee`;
- `Magic`;
- `Siege`;
- `Ranged`;
- `Heal` — tecnicamente na enumeração, mas representa cura.

Corpo a corpo e distância usam armadura; magia usa resistência mágica. Cerco
possui trechos marcados como incompletos.

### Perfurante, cortante e contundente

O Compact possui fatores de perfuração, corte e impacto em `holdables` e
`wearable_kinds`. A matriz observada em `wearable_kinds` é:

| Tipo de armadura | Perfurante | Cortante | Contundente |
|---|---:|---:|---:|
| Tecido | 15 | 15 | 0 |
| Couro | 0 | 15 | 0 |
| Metal | 0 | 0 | 15 |

Esses dados são carregados pelo `ItemManager`, mas não foram encontrados no
cálculo efetivo de `DamageEffect`. NPCs calculam armadura e resistência mágica
genéricas por fórmula, nível, template, tipo e graduação; não foi encontrado
campo de resistência individual a perfuração, corte ou impacto.

Portanto, no AAEmu atual, esses três subtipos são metadados sem efeito de dano
confirmado. Implementá-los em monstros seria uma decisão nova de design do
Projeto Aastra, não uma correção comprovada do comportamento original.

### Fórmula efetivamente observada

Em termos simplificados:

```text
dano variável =
    (DPS de arma × coeficiente + poder adicional × coeficiente adicional)
    × modificador de tempo de conjuração

dano final =
    sorteio(mínimo, máximo)
    × bônus de combo
    × redução de PvP
    × multiplicador crítico
    × multiplicador de dano recebido
    × mitigação
```

Mitigação física:

```text
defesa efetiva = max(0, armadura - penetração física)
multiplicador = 5300 / (5300 + defesa efetiva)
```

Mitigação mágica:

```text
defesa efetiva = max(0, resistência mágica - penetração mágica)
multiplicador = 5300 / (5300 + defesa efetiva)
```

Redução de PvP, quando ambos são personagens:

```text
multiplicador PvP = 8000 / (8000 + BattleResist)
```

Chance crítica efetiva:

```text
chance crítica - Flexibility / 1000 × 3
```

Multiplicador crítico:

```text
1 + (bônus crítico - Flexibility / 100) / 100
```

### Aleatoriedade do dano-base

O servidor usa distribuição uniforme de ponto flutuante no intervalo
`[mínimo, máximo)`. Não há curva normal nem preferência pela média.

Para armas, `damage_scale` define uma faixa simétrica. Exemplo com dano 1.000 e
escala 10:

```text
900 <= sorteio < 1100
```

Escalas observadas variam de 1 a 30. Muitas armas comuns usam 10; lanças de uma
mão usam 15, machados usam 20 e lança de duas mãos usa 25.

Dos 1.056 efeitos marcados como dano fixo, 246 têm mínimo igual ao máximo e 810
ainda sorteiam entre dois valores diferentes.

### Limitações confirmadas do cálculo

- perfurante/cortante/contundente não são aplicados;
- dano de cerco possui `TODO`;
- campos de dano percentual, altura, vida atual do alvo e outros são carregados
  em `DamageEffect`, mas não usados;
- o escalonamento por nível contém uma divisão inteira suspeita;
- há comentários reconhecendo aproximações no uso do DPS da arma.

Arquivos centrais:

- `AAEmu.Game/Models/Game/Skills/Effects/DamageEffect.cs`;
- `AAEmu.Game/Models/Game/Skills/Skill.cs`;
- `AAEmu.Game/Models/Game/Skills/DamageType.cs`.

## Dungeons, raids e possibilidade de nova instância

### Inventário confirmado

`indun_zones` possui 20 registros:

- 15 instâncias de combate;
- 13 com capacidade de até cinco jogadores;
- duas com capacidade de dez jogadores:
  - `instance_nachashgar` — Serpentis;
  - `instance_immortal_isle` — Sea of Drowned Love.

Os outros cinco registros são Ilha da Miragem, o prólogo solo e três grandes
pisos sistêmicos da Biblioteca. As 15 instâncias de combate incluem versões
alternativas como Greater Howling Abyss, Unstable Serpentis e a versão de fim
de semana de Sea of Drowned Love. Agrupando variantes, há aproximadamente 12
conteúdos distintos.

Os diretórios de mundo e spawns correspondentes estão presentes em
`AAEmu.Game/Data/Worlds`. Isso não comprova que todas as portas, eventos,
chefes, recompensas e condições de conclusão funcionem de ponta a ponta.

Não foi feita uma contagem de chefes de raid de mundo aberto.

### Nova raid em uma ilha

É tecnicamente plausível reutilizar um mapa de ilha e transformá-lo em
instância, porque o servidor já possui criação de mundos instanciados,
`indun_zones`, entradas, limites de jogadores, spawns, salas, eventos e ações.
Ainda seriam necessários:

1. definir o mundo/zona instanciável e sua entrada;
2. criar spawns, salas, eventos, progressão e reset;
3. implementar mecânicas dos chefes e condições de falha/conclusão;
4. definir loot com análise de economia, idempotência e auditoria;
5. validar grupo/raid, desconexão, reconexão e limite de jogadores;
6. confirmar que o client possui e carrega todos os assets do mapa;
7. executar testes E2E com múltiplos jogadores.

O código de times ainda contém observação pendente sobre raids dentro de
dungeons. Uma raid instanciada não deve ser considerada pronta apenas porque a
zona pode ser criada.

## Mudanças realizadas nesta investigação

- Nenhum código do AAEmu foi alterado.
- Nenhum Compact, asset ou arquivo do client foi modificado.
- Nenhuma migration ou dado MySQL foi alterado.
- Este documento é a única mudança criada nesta etapa de handoff.
- Alterações preexistentes no worktree foram preservadas.

## Riscos e limitações

1. **Client ainda sem smoke completo:** presença de dados não prova reprodução
   visual ou comportamento correto.
2. **Compact duplo:** servidor e client podem precisar de alterações
   coordenadas; divergência pode causar texto incorreto, referência ausente ou
   falha de gameplay.
3. **Clone ignorado:** mudanças dentro de `.data/sources/AAEmu` não são uma
   estratégia versionada e podem ser perdidas.
4. **Assets proprietários:** não versionar nem distribuir client, `game_pak`,
   áudio, mapas ou dados sem autorização comprovada.
5. **Licença do upstream:** permanece pendente de esclarecimento antes de
   distribuição de derivados.
6. **Servidor incompleto:** vários campos e efeitos existem no banco, mas não
   possuem implementação funcional correspondente.
7. **Economia:** qualquer recompensa de raid exige revisão de gameplay,
   persistência, integridade e QA antes de ativação.

## Próximo passo recomendado

Prioridade imediata:

1. concluir o smoke interativo do client e gerar um backup pós-smoke;
2. restaurar esse backup em schemas isolados e comprovar a recuperação do
   personagem criado;
3. decidir como o AAEmu será integrado ao Git do Projeto Aastra, sem editar
   permanentemente o clone ignorado;
4. criar uma ferramenta de patch de conteúdo versionada e determinística;
5. realizar uma prova de conceito pequena: uma quest, texto novo, voz removida
   e legenda de uma cinematic alterada;
6. validar essa quest de ponta a ponta antes de reescrever conteúdo em massa;
7. somente depois escolher uma dungeon curta para auditoria funcional ou
   iniciar o desenho da raid da ilha.

## Critério de conclusão sugerido para o próximo agente

Uma primeira prova de conteúdo estará concluída quando:

- a fonte do patch estiver versionada fora dos assets proprietários;
- o patch validar previamente todos os IDs e referências;
- houver diff legível e rollback;
- client e servidor iniciarem com os Compacts resultantes;
- a quest puder ser aceita, executada e entregue;
- a cinematic exibir a nova legenda sem voz antiga;
- nenhuma recompensa, objetivo ou efeito sonoro de gameplay for alterado sem
  intenção documentada.
