# Evidência sanitizada — bootstrap standalone — 2026-10-24

## Decisão

**Gate 1 e Gate 2 aprovados; Gate 3 parcial.** Todos os artefatos locais foram
validados, Login/Game iniciaram e se registraram em loopback, e os dumps
iniciais foram restaurados em destinos isolados. Resta o smoke interativo do
cliente e, depois dele, a prova de recuperação dos dados criados no teste.

## Evidências positivas

- O inventário oficial reconheceu o cliente `r208022`, o launcher e o Compact
  separado obtido pelo link indicado na documentação upstream.
- O Compact ativo passou no `PRAGMA quick_check`, continha 679 tabelas e incluía
  `item_socket_chances`.
- MySQL 8.4.9 respondeu somente em loopback; `aaemu_login` e `aaemu_game`
  continham, respectivamente, 3 e 34 tabelas antes do primeiro start do Game.
- Configurações locais de Login e Game usaram schemas distintos, portas
  internas coincidentes e a mesma chave, sem expor seus valores.
- A solução compilou com zero erros e dois avisos conhecidos do AppHost sobre
  `MessagePack` 3.1.7. O AppHost não foi executado.
- Os 1.150 testes unitários passaram, sem falhas ou testes ignorados.
- Dumps iniciais dos dois schemas foram gerados com `--no-tablespaces` e
  validados pelo marcador de conclusão.
- Em 2026-10-25, os dumps iniciais foram restaurados em schemas descartáveis
  distintos dos originais. A comparação revelou que o Game havia criado a
  tabela `updates` depois do primeiro backup. Um novo conjunto de backup da
  baseline ativa (`20261025T192335Z`) foi então gerado e restaurado: 3 tabelas
  de Login e 35 de Game, todas as 38 aprovadas pelo `mysqlcheck`. Os destinos
  de teste foram removidos ao final e os schemas originais não foram
  sobrescritos.
- O procedimento foi automatizado em
  `scripts/Invoke-AaemuBackupRestoreTest.ps1` e repetido com sucesso. Além do
  `mysqlcheck`, a automação comparou os nomes das tabelas e as contagens exatas
  de linhas entre os schemas ativos e restaurados.
- Login escutou em 1234/1237 e Game em 1239/1250/1280, somente em loopback.
  Game registrou com sucesso no Login e concluiu sua carga em aproximadamente
  53 segundos.

## Achado resolvido

O `compact.sqlite3` encontrado dentro do pacote do cliente passou na checagem
de tamanho, mas o Game encerrou durante a carga de `ItemManager` com erro
SQLite `no such table: item_socket_chances`. Não foi encontrado patch oficial
no commit fixado que crie essa tabela. A documentação upstream lista o Compact
como artefato separado.

A cópia incompatível foi retirada do caminho ativo e mantida apenas em
quarentena local ignorada pelo Git. O Compact separado substituto passou na
validação estrutural e permitiu a inicialização completa do Game.

## Próximo critério de saída

1. A pessoa operadora executa o launcher e cria uma conta/personagem de teste.
2. Login, entrada no mundo, inventário básico e logout persistente são
   verificados.
3. Um backup pós-smoke é restaurado em schemas descartáveis e comprova a
   recuperação do personagem criado, sem sobrescrever os schemas ativos.

O ensaio já realizado prova a recuperação estrutural da baseline ativa. Ele
não comprova recuperação de personagem, inventário ou progresso porque esses
dados ainda não existiam nos dumps.
