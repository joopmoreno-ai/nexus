# Registro e roteamento de agentes

| ID | Papel | Arquivo | Acione quando |
|---|---|---|---|
| `architect` | Arquiteto e coordenador | `roles/architect.md` | Mudança multidomínio, contrato, ADR ou decomposição |
| `backend-protocol` | Backend e protocolo | `roles/backend-protocol.md` | Sessões, opcodes, parsing, framing ou rede |
| `gameplay` | Gameplay | `roles/gameplay.md` | Regras, combate, quests, itens, NPCs ou instâncias |
| `persistence` | Banco e persistência | `roles/persistence.md` | Schema, query, transação, migration ou backup |
| `sre` | DevOps e SRE | `roles/sre.md` | Build, deploy, observabilidade, capacidade de recuperação |
| `qa` | QA e testes | `roles/qa.md` | Estratégia, reprodução, regressão ou evidência de aceitação |
| `security` | Segurança defensiva | `roles/security.md` | AuthN/AuthZ, abuso, segredos, painel ou exposição externa |
| `integrity` | Anti-cheat e economia | `roles/integrity.md` | Dupes, fraude, movimento, recompensa ou investigação |
| `performance` | Performance e capacidade | `roles/performance.md` | Profiling, carga, tick, alocação ou gargalo |
| `content-tools` | Ferramentas de conteúdo | `roles/content-tools.md` | Schemas, validação, importadores e publicação |
| `gm-ops` | Painel e operações de GM | `roles/gm-ops.md` | Suporte, compensação, punição e auditoria |
| `docs` | Documentação | `roles/docs.md` | Setup, referência, ADR, guia ou runbook |
| `liveops` | Comunidade e LiveOps | `roles/liveops.md` | Evento, comunicação, feedback, retenção ou incidente |
| `legal` | Risco jurídico | `roles/legal.md` | Licença, asset, marca, privacidade ou termos |

## Matriz mínima de revisão

| Tipo de mudança | Autor primário | Revisores obrigatórios |
|---|---|---|
| Protocolo ou autenticação | Backend | QA + Segurança |
| Item, moeda ou recompensa | Gameplay | Persistência + Integridade + QA |
| Migration | Persistência | QA + SRE |
| Deploy | SRE | QA; Segurança se houver exposição |
| Evento LiveOps | LiveOps + Gameplay | Conteúdo + QA + Integridade |
| Ação administrativa | GM Ops | Segurança + Persistência + QA |
| Asset, cliente ou distribuição | Ferramentas | Jurídico + Segurança |
