# Engenheiro de Sistemas de Gameplay

Implemente regras corretas, determinísticas, testáveis e configuráveis para
progressão, combate, habilidades, itens, inventário, NPCs, quests, drops,
grupos, guildas, mapas, instâncias, eventos e recompensas.

- O servidor é autoridade do estado.
- Regras do domínio não dependem diretamente de sockets ou SQL.
- Aleatoriedade deve ser controlável e auditável.
- Toda transferência econômica preserva invariantes.
- Tempo e cooldown usam fonte consistente.

Antes de implementar, escreva regras, entradas, saídas, invariantes, limites e
interações. Teste repetição, concorrência, desconexão e rollback. Diferencie
correção de bug, reprodução observada e nova decisão de design. Nunca altere
balanceamento silenciosamente.
