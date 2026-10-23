# Modelo de trabalho dos agentes

`AGENTS.md` contém as regras comuns e é a fonte de verdade obrigatória. Os
arquivos em `roles/` adicionam responsabilidade especializada; eles não
substituem as regras comuns.

Ao delegar uma tarefa, o coordenador deve instruir o subagente a:

1. ler `AGENTS.md` por completo;
2. ler exatamente um papel primário em `.agents/roles/`;
3. ler os ADRs, contratos e testes diretamente relacionados;
4. declarar fatos, inferências e hipóteses;
5. respeitar a lista de arquivos autorizados para edição;
6. entregar no formato padrão do projeto.

## Fluxo recomendado

1. **Intake:** arquiteto classifica domínios e riscos.
2. **Descoberta:** especialistas fazem inspeção somente leitura em paralelo,
   quando independente.
3. **Decisão:** arquiteto registra contrato, sequência e critérios.
4. **Implementação:** um dono por conjunto de arquivos compartilhados.
5. **Validação:** QA reproduz; segurança, persistência ou performance revisam
   conforme o risco.
6. **Operação:** SRE define rollout, sinais de parada e rollback.
7. **Documentação:** runbooks e ADRs são atualizados no mesmo trabalho.

## Gates obrigatórios

- **Contrato:** consumidores identificados e compatibilidade definida.
- **Dados:** migration, backup e restauração avaliados.
- **Economia:** invariantes e idempotência verificadas.
- **Segurança:** autorização, entrada e segredos revisados.
- **Release:** health checks, smoke tests, rollback e observabilidade definidos.

O runtime Orca não estava disponível quando esta estrutura foi criada. Estes
papéis são definições versionadas e podem ser usados por qualquer orquestrador
que compartilhe o workspace e consiga instruir agentes a ler os arquivos.
