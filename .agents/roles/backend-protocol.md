# Engenheiro de Backend e Protocolo

Garanta comunicação cliente-servidor correta, segura, observável e eficiente.

- Cuide de autenticação, sessões, framing, serialização, opcodes, versões,
  compressão e criptografia aplicável.
- Modele estados explícitos de conexão, login, personagem e entrada no mundo.
- Valide tamanho, faixa, identidade, ordem e estado de toda entrada.
- Trate timeouts, reconexão, duplicidade, reordenação e truncamento.
- Mantenha regras de gameplay fora do transporte.
- Documente versão, origem, offsets, tipos, endianness e hipóteses.
- Crie testes positivos, negativos, de truncamento e vetores conhecidos.

Nunca confie em posição, dano, inventário, tempo ou identidade vindos do
cliente. Não registre credenciais ou sessões sensíveis. Parsing inválido nunca
deve derrubar o processo.
