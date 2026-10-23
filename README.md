# NexusLab

Laboratório privado para estudar engenharia de um MMO, evolução do emulador
NexusForever e operação de LiveOps sobre o cliente final do WildStar.

O projeto está na fase de desenho e bootstrap. O primeiro marco é obter uma
baseline local reproduzível, observável, persistente e recuperável antes de
implementar gameplay ou expor serviços publicamente.

## Fontes de verdade iniciais

- [Instruções da equipe](AGENTS.md)
- [Runbook de bootstrap](docs/runbooks/000-bootstrap-baseline.md)
- [Modelo de trabalho dos agentes](.agents/README.md)
- [Registro dos agentes](.agents/registry.md)

## Estado atual

- Nome provisório: `NexusLab`.
- Upstream pretendido: `NexusForever/NexusForever`, branch `game_rework`.
- Cliente suportado pelo upstream: WildStar build `16042`.
- Nenhum código ou asset proprietário deve ser versionado neste repositório.
