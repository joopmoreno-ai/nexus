# Runbook 000 — Baseline reproduzível do NexusLab

## Objetivo

Obter uma baseline local do NexusForever que possa ser construída, iniciada,
observada, desligada, reiniciada, copiada e restaurada de forma reproduzível.

Este runbook descreve o trabalho das próximas iterações; comandos concretos só
serão adicionados depois de verificarmos o upstream, o host e os pré-requisitos.

## Escopo

Inclui:

- inventário seguro da máquina de desenvolvimento;
- forks e commits fixados;
- build da branch `game_rework`;
- MariaDB/MySQL e RabbitMQ locais;
- assets extraídos de uma cópia local autorizada do cliente `16042`;
- criação de conta de desenvolvimento;
- login, seleção de personagem e entrada no mundo;
- persistência após reinício;
- logs, traces e métricas locais;
- backup e restauração comprovados.

Não inclui:

- servidor público;
- distribuição do cliente ou assets;
- gameplay novo;
- painel administrativo;
- plataforma LiveOps;
- otimização ou teste de escala.

## Papéis e aprovações

| Papel | Responsabilidade neste marco |
|---|---|
| Arquiteto | Fixar topologia, fronteiras, versões e critérios |
| SRE | Ambiente, scripts, containers, telemetria e backup |
| Backend | Validar fluxo de conexão e serviços necessários |
| Persistência | Migrations, world data, backup e restore |
| QA | Smoke tests e evidências reproduzíveis |
| Segurança | Segredos, bind de portas e superfície local |
| Jurídico | Proveniência e exclusão de material proprietário |
| Documentação | Atualizar este runbook com comandos verificados |
| GM Ops | Fora do escopo até existir uma operação administrativa autorizada |

| Mudança | Autor | Revisores antes de executar |
|---|---|---|
| Conexão, login ou autenticação | Backend | QA + Segurança |
| Migration ou restauração | Persistência | QA + SRE |
| Configuração de listeners/containers | SRE | Segurança + QA |
| Extração ou uso de assets locais | Ferramentas | Jurídico + Segurança |

## Pré-condições bloqueantes

- [ ] Sistema operacional, CPU, RAM, armazenamento e virtualização do host.
- [ ] Disponibilidade de Git, .NET SDK exigido, Docker e ferramenta de build.
- [ ] Cópia local autorizada do cliente WildStar build `16042`.
- [ ] Espaço separado e ignorado pelo Git para cliente e assets extraídos.
- [ ] Licenças dos repositórios registradas.
- [ ] Local seguro para segredos locais definido e testado.
- [ ] Allowlist de listeners, bancos, schemas e volumes descartáveis definida.

Decisões adiáveis: nome definitivo, conta GitHub, visibilidade dos forks e
provedor remoto. `NexusLab` permanece como nome de trabalho.

## Controles comuns a todos os gates

Cada gate deve registrar em `evidence/local/` um documento sanitizado contendo:

- timestamp UTC, executor e papéis revisores;
- host, sistema e versões das ferramentas relevantes;
- `candidate_ref`, versões de dados e comandos executados sem segredos;
- precondições, resultado esperado, observado e exit code;
- artefatos/checksums permitidos, risco residual e decisão `pass` ou `fail`.

`evidence/local/` nunca é versionado. Somente modelos e conclusões sanitizadas
podem ir para o Git.

Antes de qualquer ação mutável:

1. Resolver e exibir host, porta, banco/schema, container e volume alvo.
2. Exigir marcador inequívoco de ambiente `Development` e allowlist exata.
3. Abortar se o alvo não for local, isolado, autorizado e descartável.
4. Mostrar preview; nunca operar sobre a única cópia de dados.
5. Verificar listeners IPv4 e IPv6; DB, broker e administração devem estar
   apenas em loopback ou rede interna sem publicação de portas.
6. Usar credenciais geradas, sem defaults, armazenadas com ACL apropriada;
   nunca passá-las em argumentos, logs ou Compose versionado.
7. Interromper se qualquer teste existente falhar ou se a evidência não puder
   ser sanitizada sem perder sua utilidade.

## Fase 1 — Inventário sem mutação

1. Registrar versões do sistema, Git, .NET, Docker e PowerShell.
2. Confirmar virtualização e disponibilidade de containers Linux.
3. Levantar portas locais ocupadas sem encerrar processos.
4. Medir armazenamento livre sem enumerar ou copiar arquivos pessoais.
5. Localizar o cliente apenas com autorização; registrar somente caminho
   local e checksum, nunca seu conteúdo no Git.
6. Comparar `game_rework`, forks candidatos e PRs necessários.
7. Produzir matriz factual de processos, serviços, schemas, filas, portas,
   diretórios e fluxo login→mundo, separando fatos, inferências e hipóteses.
8. Verificar o índice Git e regras de ignore antes de lidar com assets.

**Gate F1:** Arquiteto como owner; SRE, Segurança e Jurídico revisam. Aprova
somente com relatório de compatibilidade, matriz de portas/alvos, inventário
arquitetural e prova de que nenhum segredo ou dado proprietário foi versionado.

## Fase 2 — Fixação das fontes

1. Criar fork do NexusForever e configurar `upstream` somente leitura.
2. Criar fork do WorldDatabase.
3. Selecionar um `candidate_ref` exato; não depender do topo móvel da branch.
4. Registrar licenças, origem, commit e data em um manifesto.
5. Documentar política de sincronização e conflitos.

**Gate F2:** Arquiteto como owner; Jurídico e SRE revisam. Um clone limpo em
diretório temporário deve resolver refs, licenças, fontes e hashes do manifesto.

## Fase 3 — Build local

1. Ler integralmente as instruções do upstream e projetos do AppHost.
2. Restaurar dependências com fontes conhecidas e locked mode quando o
   upstream já o suportar; ausência de lockfile vira risco registrado.
3. Compilar sem alterar o código para estabelecer baseline.
4. Registrar warnings e testes existentes; não corrigir incidentalmente.
5. Produzir relatório de componentes e executáveis gerados.

**Gate F3:** SRE como owner; QA revisa. Dois builds em condições declaradas
(incluindo cache limpo em ao menos um deles) devem ter os mesmos exit codes,
grafo de dependências, testes, executáveis esperados e conjunto explicado de
warnings. Hash binário só é exigido se o build provar ser determinístico.

## Fase 4 — Dependências e dados

1. Subir MariaDB/MySQL e RabbitMQ somente em loopback/rede privada, com imagens
   fixadas por versão/digest e volumes classificados como persistentes ou
   descartáveis.
2. Gerar credenciais locais fora do Git.
3. Inventariar consumidores e migrations; resolver o alvo e provar que o banco
   está limpo e descartável antes de executar migrations oficiais.
4. Aplicar world data por processo documentado e repetível.
5. Extrair game tables e mapas para diretório ignorado.
6. Validar checksums, permissões e referências sem publicar assets.
7. Verificar history de migrations, schemas, constraints, índices, referências
   e sentinelas de world data após a execução.
8. Reexecutar somente processos declaradamente idempotentes; caso contrário,
   confirmar que a segunda execução falha da maneira prevista.

**Gate F4:** Persistência como owner; QA, SRE e Segurança revisam. Dependências
devem estar fixadas, bindings reais dentro da allowlist e migrations/dados
validados. Um reset com preview deve reconstruir apenas alvos descartáveis e
provar que recursos persistentes fora do escopo permaneceram intactos.

## Fase 4B — Observabilidade e redaction mínimas

1. Habilitar o plumbing de logs/traces já existente sem alterar contratos.
2. Definir campos mínimos: serviço, versão, ambiente, correlation ID e erro
   normalizado, evitando identificadores pessoais como labels.
3. Inserir valores-canário falsos e provar redaction em logs, traces, métricas,
   argumentos, configuração renderizada e inspeção de containers.
4. Registrar capacidades ausentes como dívida, sem instrumentação oportunista.

**Gate F4B:** Segurança como owner; QA e SRE revisam. Nenhuma credencial real é
usada antes de a varredura do valor-canário resultar em zero vazamentos.

## Fase 5 — Primeiro fluxo jogável

1. Iniciar todos os recursos pelo AppHost.
2. Confirmar readiness por serviço com dependências, timeout e tentativas;
   processo vivo ou porta aberta, isoladamente, não comprovam prontidão.
3. Criar conta de desenvolvimento sem credenciais fixas em scripts.
4. Conectar pelo mecanismo suportado pelo upstream.
5. Criar personagem e entrar no mundo sem executar operação administrativa.
6. Executar testes negativos: credencial errada, conta inexistente e uma
   dependência indisponível, esperando falha fechada, sem mutação parcial.
7. Encerrar entradas, drenar sessões/writes, parar de forma coordenada,
   reiniciar e confirmar persistência.

**Gate F5:** Backend como owner; QA e Segurança revisam. Readiness deve ser
comprovada, smoke tests positivos e negativos passam, shutdown drena dentro do
timeout e invariantes persistem depois do reinício.

## Fase 6 — Observabilidade

1. Capturar logs estruturados por serviço e correlation ID.
2. Confirmar traces do login atravessando os serviços disponíveis.
3. Registrar métricas de sessão, erros e dependências.
4. Verificar que credenciais, tokens, e-mail e payload sensível não aparecem.
5. Criar uma visão mínima no Aspire Dashboard.

**Gate F6:** SRE como owner; QA e Segurança revisam. Uma falha sintética de
login deve ser diagnosticada por correlation ID sem debugger; varredura de
segredos e dados pessoais deve resultar em zero achados não autorizados.

## Fase 7 — Backup e recuperação

1. Criar fixture sentinela com vínculo conta-personagem, inventário, quantidades,
   moedas exatas e progresso conhecido.
2. Definir objetivos provisórios de RPO/RTO e inventariar todos os schemas.
3. Drenar writes ou parar serviços na ordem documentada; gerar backup com
   ferramenta/versionamento conhecidos, ACL restrita, tamanho e SHA-256.
4. Restaurar em bancos novos, nunca sobre fonte ou única cópia existente.
5. Confirmar que a aplicação aponta apenas para o destino restaurado.
6. Validar versions de schema/migrations, constraints e a fixture sentinela.
7. Provar falha fechada para arquivo truncado ou credencial errada.
8. Registrar RPO, RTO e limitações observados.

**Gate F7:** Persistência como owner; QA e SRE revisam. Backup com checksum deve
ser restaurado em destino novo; schema, constraints, conta, personagem,
inventário, moeda e progresso devem corresponder exatamente à sentinela.

## Promoção da baseline

Somente após F1–F7 aprovados, o `candidate_ref` recebe uma tag imutável
`baseline_ref`. O manifesto registra a promoção e as evidências sanitizadas.

## Critérios de conclusão

- [ ] Bootstrap documentado a partir de host compatível.
- [ ] Versões e commits fixados.
- [ ] Build e testes repetíveis.
- [ ] Dependências privadas e persistentes.
- [ ] Cliente entra no mundo.
- [ ] Personagem persiste depois de restart.
- [ ] Falha de login pode ser rastreada.
- [ ] Nenhum segredo ou asset proprietário no Git.
- [ ] Backup restaurado com sucesso em banco limpo.
- [ ] `candidate_ref` promovido a `baseline_ref` imutável.
- [ ] Riscos e dívidas encontrados registrados, sem correção oportunista.

## Sinais para interromper o trabalho

- Instrução exige copiar ou publicar material proprietário.
- Versão do cliente não pode ser comprovada.
- Migration tenta remover dados ou schema sem backup restaurável.
- Serviço administrativo ou banco fica exposto fora de loopback/rede privada.
- Build depende de binário ou pacote sem origem verificável.
- O upstream muda durante a execução e invalida o commit fixado.
- Alvo de reset/restore não é inequivocamente local, isolado e autorizado.
- Binding real difere da allowlist ou credencial default é detectada.
- Migration inesperada, incompatível ou pendente aparece no startup.
- Checksum, provenance, constraint ou invariante restaurada diverge.
- Segredo ou dado pessoal aparece em log, trace, argumento ou artefato.
- Serviço não fica ready ou não drena no timeout definido.
- Espaço livre não comporta simultaneamente backup, destino novo e logs.

## Próximo runbook

Após esta baseline: `001-ptr-single-host.md`, cobrindo imagens imutáveis,
Docker Compose, VPN administrativa, telemetria durável, deploy, rollback e PTR.
