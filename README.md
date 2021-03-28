# SeteSegmentos_PIC
Hardware e software de um contador em um display 7 Segmentos.

Trabalho realizado para a disciplina de Microprocessadores e Microcontroladores, em dupla com um colega, Raul Brum.
O hardware possui um PIC16F877A, 4 botões, led, decodificador 7447, e 2 displays de 7 segmentos.
O software foi implementado em assembly.

O contador inicia em zero, mostrando este valor nos displays.
Ao clicar no botão 'incrementa', os displays devem ir incrementando 1 unidade.
Ao clicar no botão 'decrementa', os displays devem ir decrementando 1 unidade.
Ao clicar no botão 'enter', será salvo na memória do PIC o valor atual dos displays, e após irá zerar os displays.
Ao clicar no botão 'pulso', os displays devem ir incrementando 1 unidade, mas ao atingir o valor salvo pelo botão de enter, o LED irá acender por alguns segundos, e após irá zerar os displays.

O contador tem como limite os valores 0 e 99. Ao atingir o valor máximo, reinicia.
