# ADR 003 — Integração provisória da fonte AAEmu

**Status:** aceita provisoriamente

**Data:** 2026-10-25

**Decisor:** equipe técnica, sujeita à revisão do proprietário

## Contexto

O Projeto Aastra precisa fixar e validar a fonte usada no baseline, mas a
declaração de licença do AAEmu ainda é inconsistente entre o README e os
arquivos de licença observados. O projeto também ainda não possui uma mudança
própria no código do servidor que justifique manter um fork público.

O clone local atual está em `.data/sources/AAEmu`, fora do histórico deste
repositório. O manifesto registra a origem, a branch observada e o commit
exato, e o preflight reprova um clone divergente ou com alterações locais.

## Decisão

1. Manter o AAEmu como fonte externa, adquirida separadamente em
   `.data/sources/AAEmu` e fixada pelo manifesto
   `docs/manifests/aastra-upstream-sources.yaml`.
2. Não incorporar o código como vendor, subtree ou submodule neste momento.
3. Não criar nem publicar um fork derivado antes de esclarecer a licença e
   existir uma primeira alteração de servidor aprovada.
4. Tratar qualquer modificação feita somente no clone ignorado como
   descartável. Mudanças de produto deverão nascer como patch rastreável ou em
   um fork privado autorizado, depois da revisão de licença.
5. Continuar validando o commit e a limpeza do clone por
   `scripts/Test-AaemuBaseline.ps1` antes de build, teste ou execução.

## Justificativa

- O manifesto e o commit fornecem reprodutibilidade sem copiar código de
  procedência ainda não esclarecida para o repositório do produto.
- Um submodule registraria a dependência, mas não resolveria licença nem o
  fluxo futuro de manutenção de alterações próprias.
- Um fork público agora ampliaria a superfície de distribuição sem benefício
  técnico imediato.

## Consequências

- O checkout deste repositório, sozinho, não contém o servidor executável; o
  bootstrap deve obter a fonte canônica e fazer checkout do commit fixado.
- Nenhuma alteração local no clone do AAEmu conta como implementação entregue.
- A automação de bootstrap ainda poderá ser melhorada, mas não deve baixar
  cliente, Compact ou outros artefatos proprietários.
- Quando a primeira mudança de servidor for aprovada, esta decisão deverá ser
  revisada com estratégia de upstream, atualização, autoria, licença e
  rollback.

## Critérios para revisão

Reabrir esta ADR quando ocorrer o primeiro dos seguintes eventos:

- esclarecimento verificável da licença aplicável ao código que será alterado;
- necessidade aprovada de manter patches próprios do servidor;
- mudança do repositório, branch ou commit-base;
- necessidade de build reproduzível em CI ou por outro colaborador.

## Rollback

Como nenhuma fonte é incorporada por esta decisão, o rollback documental é
substituí-la por nova ADR. A remoção do clone local não deve apagar cliente,
Compact, configurações, backups ou segredos adjacentes.
