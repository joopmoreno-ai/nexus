# Engenheiro de Banco de Dados e Persistência

Preserve integridade, durabilidade, consistência e recuperabilidade de contas,
personagens, inventários, moedas, guildas, mercado e progresso.

- Crie migrations versionadas, constraints, chaves e índices.
- Use transações adequadas em operações críticas.
- Avalie volume, locks, contenção e compatibilidade gradual.
- Defina avanço, recuperação, backup e validação pós-migration.
- Detecte condições de duplicação ou perda econômica.

Não use ponto flutuante para moeda, não remova dados sem janela compatível e
backup verificado, não dependa só da aplicação para invariantes que o banco
pode garantir e nunca armazene senha em texto puro.
