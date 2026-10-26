# Spec 001 — Fronteiras do bootstrap F1/F2 (histórico NexusLab)

**Status:** substituída em 2026-10-24 pela ADR 001

**Baseline descrito:** NexusLab/NexusForever, não vigente

**Uso atual:** evidência histórica; não executar como runbook

> Este documento foi preservado para rastreabilidade. A decisão vigente adotou
> AAEmu e o fluxo standalone descrito em
> `docs/runbooks/001-aaemu-standalone-bootstrap.md`. Nenhum item abaixo autoriza
> fork, instalação, exposição de rede ou uso de assets.

## Objetivo

Permitir a fixação das fontes e a preparação posterior do host sem expor
serviços, versionar segredos/assets ou criar uma topologia difícil de reverter.
Esta spec não autoriza instalação, migration, extração de assets nem execução
do servidor.

## Decisões propostas

### 1. Fontes e forks

- Usar somente `NexusForever/NexusForever` e
  `NexusForever/NexusForever.WorldDatabase` como upstreams oficiais iniciais.
- Fixar os candidatos pelos SHAs do manifesto, nunca pelo topo móvel da branch.
- Criar forks públicos sob `joopmoreno-ai` somente após aprovação desta spec.
  O GitHub não oferece fork privado comum de repositório público; se isolamento
  for obrigatório, usar mirrors privados separados após revisão jurídica.
- Configurar o remote `upstream` apenas para fetch e com push URL inválida ou
  desabilitada. `origin` aponta para o fork e nenhum force-push é permitido na
  branch de baseline.
- Não incorporar o PR #570 enquanto Backend, Persistência, Segurança e QA não
  revisarem seu download de world data, criação de conta, migrations, segredos
  e extração de assets. O PR está aberto, sem review no GitHub, embora os checks
  de seu head tenham passado.

### 2. Rede local

- Ambiente obrigatório: `Development`.
- STS `6600/tcp`, Auth `23115/tcp` e World `24000/tcp`: publicar apenas em
  `127.0.0.1` e `::1`.
- APIs `4000/4001`, console `5000` e dashboard: loopback; consumidores internos
  preferem rede do Aspire.
- MySQL `3306`, RabbitMQ `5672` e interfaces administrativas: rede interna sem
  publicação; se diagnóstico exigir publicação, ela será temporária, em
  loopback, registrada em evidência e removida ao final.
- Falhar o gate se o binding real incluir `0.0.0.0`, `::` ou endereço LAN.

Essa política é mais restrita que o AppHost observado, que usa
`IPAddress.Any`. A implementação deve ser pequena, configurável e revisada;
esta spec não define ainda se será um patch local ou contribuição upstream.

### 3. Segredos e material proprietário

- Segredos de desenvolvimento ficam em .NET User Secrets ou store equivalente
  com ACL do usuário; nunca em argumentos, arquivos versionados ou exemplos com
  valor funcional.
- Credenciais default presentes nos `*.example.json` do upstream não podem ser
  reutilizadas.
- Cliente e assets só podem existir em `client/`, `assets/local/` ou outro alias
  explicitamente ignorado. O manifesto versionado registra alias, build e hash
  permitido, nunca caminho pessoal ou conteúdo.
- Nenhuma busca fora do projeto por cliente/assets ocorrerá sem autorização
  explícita do proprietário sobre o caminho raiz.

### 4. Evidência e proveniência

- O manifesto mínimo registra URL canônica, ref observada, commit, data,
  verificação de assinatura, licença/SPDX, hash da licença e estado dos checks.
- Usar SLSA Source 1.2 como referência de proveniência de revisão e SPDX 3.0.1
  como vocabulário de licença/SBOM, sem alegar conformidade ainda.
- Cada gate mantém evidência detalhada em `evidence/local/`; somente conclusão
  sanitizada pode ser versionada.

## Critérios de aprovação

- [ ] Conta/organização e natureza pública dos dois forks aprovadas.
- [ ] SHAs candidatos e exclusão temporária do PR #570 aprovados.
- [ ] Allowlist e política de loopback aprovadas.
- [ ] Store local de segredos aprovado.
- [ ] Alias autorizado da cópia do cliente build 16042 informado.
- [ ] Capacidade mínima de disco decidida após medir build, imagens e dumps.

## Referências normativas e técnicas

- [SLSA Source Requirements 1.2](https://slsa.dev/spec/v1.2/source-requirements)
- [SPDX 3.0 / ISO/IEC 5962](https://spdx.dev/use/specifications/)
- [Docker — port publishing](https://docs.docker.com/engine/network/port-publishing/)
- [Microsoft — configuração e segredos ASP.NET Core](https://learn.microsoft.com/aspnet/core/fundamentals/configuration/)
- [GitHub — visibilidade de forks](https://docs.github.com/en/pull-requests/reference/forks)
- [GitHub — remote upstream de um fork](https://docs.github.com/en/pull-requests/how-tos/work-with-forks/configuring-a-remote-repository-for-a-fork)
- [README do NexusForever](https://github.com/NexusForever/NexusForever/blob/game_rework/README.md)
- [PR NexusForever #570](https://github.com/NexusForever/NexusForever/pull/570)

## Rollback

Antes de qualquer fork, esta spec é apenas documental. Depois da aprovação, o
rollback consiste em arquivar/remover os forks sem tocar upstream e apagar os
clones locais ignorados. Nenhum dado de conta, personagem ou economia participa
desta decisão.
