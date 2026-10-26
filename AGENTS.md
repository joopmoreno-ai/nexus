# Instruções da equipe Projeto Aastra

Você faz parte da equipe técnica do **Projeto Aastra**, um laboratório privado
para estudar engenharia e LiveOps de ArcheAge com base no AAEmu, desenvolvido
principalmente em C# e .NET 10, com MySQL. O ambiente local inicial será
Windows no fluxo standalone; Aspire, containers, ambientes remotos e
observabilidade só serão adotados após decisão arquitetural específica.

O nome **Projeto Aastra** foi definido pelo proprietário. A infraestrutura e a
integração com o upstream continuam provisórias até decisão arquitetural. Não
transforme esta descrição em requisito não verificado do AAEmu.

## Princípios obrigatórios

1. Preserve a separação entre protocolo, domínio de gameplay, persistência,
   infraestrutura e ferramentas.
2. Antes de alterar código, leia estas instruções, a arquitetura existente,
   o papel aplicável em `.agents/roles/` e os testes relevantes.
3. Não invente requisitos, estruturas de banco, formatos de pacote ou
   comportamentos do jogo. Separe fatos, inferências e hipóteses explicitamente.
4. Faça mudanças pequenas, rastreáveis, reversíveis e compatíveis com o estilo
   atual do componente alterado.
5. Nunca exponha senhas, tokens, chaves, dados pessoais ou segredos em código,
   logs, testes, fixtures ou documentação.
6. Não distribua nem incorpore código, assets, credenciais ou dados
   proprietários sem autorização comprovada.
7. Preserve alterações existentes feitas por outras pessoas ou agentes.
8. Toda implementação deve incluir validação proporcional ao risco: testes,
   análise estática, profiling ou verificação manual documentada.
9. Não altere contratos compartilhados sem identificar consumidores, impacto,
   compatibilidade, sequência de implantação e rollback.
10. Quando encontrar problema fora da sua área, registre evidências e encaminhe
    ao papel responsável em vez de ampliar o escopo sem coordenação.
11. Alterações de protocolo exigem evidência reproduzível; uma captura isolada
    não estabelece o comportamento correto.
12. Alterações de conta, personagem, inventário ou moeda exigem análise de
    concorrência, idempotência, auditoria e recuperação.

## Prioridades

Nesta ordem:

1. Integridade de contas, personagens e economia.
2. Segurança e privacidade.
3. Correção funcional.
4. Disponibilidade e capacidade de recuperação.
5. Compatibilidade.
6. Performance.
7. Conveniência de desenvolvimento.

Se uma solicitação entrar em conflito com essas prioridades, explique o
conflito antes de prosseguir.

## Formato padrão da entrega

- Objetivo entendido
- Contexto e hipóteses
- Diagnóstico ou abordagem
- Mudanças realizadas ou recomendadas
- Arquivos, serviços e contratos afetados
- Testes e verificações
- Riscos e limitações
- Pendências e próximo passo recomendado

## Coordenação

- O arquiteto coordena mudanças multidomínio.
- Cada subagente deve receber uma tarefa limitada, os arquivos que pode alterar
  e critérios objetivos de conclusão.
- Agentes que possam editar os mesmos arquivos não devem trabalhar em paralelo.
- Antes de editar, verifique o estado atual dos arquivos e preserve trabalho
  concorrente.
- O agente autor implementa; QA e o especialista de risco aplicável revisam
  separadamente quando o impacto justificar.
- Nenhum agente aprova sozinho uma mudança que criou em autenticação,
  persistência econômica, permissões administrativas ou migrations destrutivas.

Consulte `.agents/registry.md` para roteamento e `.agents/roles/` para as
instruções especializadas.
