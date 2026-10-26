# Projeto Aastra

Projeto privado para criar uma experiência renovada de ArcheAge clássico:
narrativa de quests integralmente reescrita, novo equilíbrio de classes e
acesso igualitário aos sistemas e benefícios que, na experiência original,
dependiam de assinatura.

“Zero pay to win” é uma restrição de produto: pagamento não poderá conceder
vantagem de poder, progressão ou acesso exclusivo a sistemas de gameplay. O
modelo de sustentabilidade ou monetização, se houver, ainda não foi definido.

O baseline técnico escolhido é o AAEmu no cliente ArcheAge 1.2 r208022. O
primeiro marco é obter uma instância local reproduzível, persistente e
recuperável antes de alterar gameplay ou expor qualquer serviço publicamente.

## Fontes de verdade iniciais

- [Instruções da equipe](AGENTS.md)
- [Decisão de adoção do AAEmu](docs/decisions/001-adopt-aaemu.md)
- [Nome e visão de produto](docs/decisions/002-name-and-product-vision-aastra.md)
- [Integração provisória da fonte AAEmu](docs/decisions/003-aaemu-source-integration.md)
- [Baseline zero pay to win](docs/specs/002-zero-pay-to-win-access-baseline.md)
- [Runbook de bootstrap do AAEmu](docs/runbooks/001-aaemu-standalone-bootstrap.md)
- [Manifesto da fonte AAEmu](docs/manifests/aastra-upstream-sources.yaml)
- [Scripts operacionais](scripts/)
- [Modelo de trabalho dos agentes](.agents/README.md)
- [Registro dos agentes](.agents/registry.md)

## Estado atual

- Nome definido: `Projeto Aastra`.
- Repositório público: `joopmoreno-ai/projeto-aastra`; o remote local `origin`
  aponta para esse destino.
- Visão de produto registrada na ADR 002; nenhuma das mudanças de conteúdo,
  balanceamento ou acesso está implementada ainda.
- Upstream candidato: `AAEmu/AAEmu`, branch `develop`, fixado por commit no
  manifesto.
- A fonte permanece em clone externo ignorado até a revisão de licença e a
  necessidade de um patch próprio; a ADR 003 registra essa decisão.
- Cliente alvo declarado pelo upstream: ArcheAge 1.2 r208022.
- Host atual sem runtime OCI: o bootstrap começa pelo fluxo standalone com
  MySQL 8, sem misturar serviços locais e containers.
- A declaração de licença do upstream precisa de esclarecimento antes de
  distribuição: README e arquivos de licença não são consistentes entre si.
- Nenhum código ou asset proprietário deve ser versionado neste repositório.

O runbook `000`, a Spec `001` de F1/F2, o manifesto
`upstream-sources.yaml` e a conclusão F1 de 2026-10-23 são mantidos como
evidência histórica do estudo NexusForever/WildStar. Eles não descrevem o
baseline vigente. O inventário de arquitetura foi atualizado para AAEmu.
