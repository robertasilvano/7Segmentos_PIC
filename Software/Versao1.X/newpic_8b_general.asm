;*******************************************************************************
; UFSC- Universidade Federal de Santa Catarina
; Projeto: 7 Segmentos
; Autor: Raul Brum e Roberta Silvano
; 7 Segmentos
;
;*******************************************************************************
 
    
    
    
    

#include <P16F877A.INC> 	; Arquivo de include do uC usado, no caso PIC16F877A

; Palavra de configura??o, desabilita e habilita algumas op??es internas
  __CONFIG  _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_OFF & _PWRTE_OFF & _WDT_OFF & _XT_OSC


;***** defini??o de Vari?veis  *****************************

  	cblock 0x20
	    dezena
	    unidade
	    dezena_buffer
	    valor_enter
	    tempo0
	    tempo1
	    filtro
	endc 
	
	
;********* vari?veis de Entrada ************
#define	    btn_inc	PORTB,0	; Pino 33
#define	    btn_dec	PORTB,1	; Pino 34
#define	    btn_enter	PORTB,2	; Pino 35
#define	    btn_pulso	PORTB,3	; Pino 36


;********* vari?veis de Sa?da ***************
#define 	led	PORTC,5	; Pino 24
#define 	seg	PORTD	           

;******** Vetor de Reset do uC**************
 org 0x00		                ; Vetor de reset do uC.
 goto inicio		            ; Desvia para o inicio do programa.


;*************** Rotinas e Sub-Rotinas *****************************************

delays_ms:
    movwf tempo1
    movlw .250
    movwf tempo0
    nop
    decfsz tempo0, F
    goto $-2
    
    decfsz tempo1, F
    goto $-6
    
    return
    
    
;********* MOSTRAR O RESULTADO NOS DISPLAYS **********

; calcula o resultado final e coloca o valor nos displays
mostrar:
    swapf dezena, dezena_buffer ; troca os nibbles da dezena, fazendo que o valor em si se torne o MSB
    
    addwf unidade, W ; soma o valor da unidade com o valor que resultou do swap pra ter o resultado final
    
    movwf seg ; coloca no PORTD o resultado final
    
    return

;********* INCREMENTA **********    
incrementa:
    
    decfsz filtro, F
    
    movlw .2000
    call delays_ms
    
    movlw 0x10 ; coloca o valor imediato 10h no acumulador
    
    subwf unidade, W ; subtrai 10h da unidade, se a conta der 0, unidade=10, z(STATUS, 2)=1
    btfss STATUS, 2 ; se z=0 na conta anterior, significa que a unidade ainda não chegou no 10, então vai incrementar a unidade. Precisa disso se não ele vai pular valores que tem unidade 0. Por exemplo: do 9 iria direto pro 11.
		    ; se z=1 na conta anterior, significa que a unidade chegou em 10 e não deve ser incrementada.
    call f_inc_unidade
    call f_inc_dezena
    
    call f_pulso ; função que verifica se temos algum valor salvo com o botão enter, e se o atingimos com o botão de pulso
    
    call mostrar ; função que calcula o resultado final e coloca nos displays
    
    return
    
f_inc_unidade:
    movlw 0x09 ; coloca o valor imediato 9h no acumulador
    
    subwf unidade, W ; subtrai 9h da unidade, se a conta der 0, unidade=9, z(STATUS, 2)=1
    btfsc STATUS, 2 ; se z=1 vai chamar a função de zerar a unidade, no caso que já atingiu seu máximo
		    ; se z=0 vai incrementar a unidade
    call clear_unidade
    
    call inc_unidade   
    return
    
inc_unidade:
    incf unidade, 1 ; incrementa 1 em unidade
    return
    
clear_unidade:
    movlw 0x00 ; coloca o valor imediato 0h no acumulador
    movwf unidade ; move o valor do acumulador para a unidade
    
    call inc_dezena ; quando precisar zerar a unidade, significa que chegou em 9 e portanto tem que incrementar a dezena
    call mostrar
    goto loop
    
f_inc_dezena:
    movlw 0x0A ; coloca o valor imediato 10h no acumulador
    
    subwf dezena, W ; subtrai 10h da dezena, se a conta der 0, dezena=10, z(STATUS, 2)=1
    btfsc STATUS, 2 ; se z=1, vai chamar a função de zerar a dezena
		    ; se z=0, vai incrementar a dezena
    call clear_dezena
    
    movlw 0x0A ; coloca o valor imediato 10h no acumulador
    subwf dezena, W ; subtrai 10h da dezena, se der 0, dezena = 10, z(STATUS, 2)=1
    btfsc STATUS, 2 ; se z=1, vai incrementar a dezena
    call inc_dezena  
    return
    
inc_dezena:
    incf dezena, 1 ; incrementa a dezena
    return
    
clear_dezena:
    movlw 0x00 ; coloca o valor imediato 0h no acumulador
    movwf dezena ; move o valor do acumulador para a unidade
    call mostrar
    goto loop
    
;********* DECREMENTA **********

;;;;;;;;;;;;
;    sempre decrementa a unidade
;    antes de decrementar, verifica se ela eh zero
;	se sim, tem que usar o set unidade
;	    verifica a dezena
;		se for zero, set dezena
;		se nao, so decrementa
;	se não, so decrementa a unidade
	
decrementa:
    
    decfsz filtro, F
    
    movlw .2000
    call delays_ms
    
    movlw 0x00 ; coloca o valor imediato 0h no acumulador
    
    subwf unidade, W ; subtrai 00h da unidade. se der 0, unidade = 0
    btfsc STATUS, 2 ; se der 0 na conta anterior, vai chamar a função set unidade, se não, só a dec_unidade.
    call set_unidade
    call dec_unidade
    
    call mostrar
    
    return
    
set_unidade:
    movlw 0x09 ; coloca o valor imediato 9h no acumulador
    movwf unidade
    
    call f_dec_dezena ; quando precisar zerar a unidade, significa que chegou em 9 e portanto tem que incrementar a dezena
    call mostrar
    goto loop
    
dec_unidade:
    decf unidade, 1 ; incrementa 1 em unidade
    return

f_dec_dezena:
    movlw 0x00 ; coloca o valor imediato 0h no acumulador
    
    subwf dezena, W 
    btfsc STATUS, 2
    call set_dezena
    call dec_dezena
    return

dec_dezena:
    decf dezena, 1 ; incrementa 1 em unidade
    return
    
set_dezena:
    movlw 0x09 ; coloca o valor imediato 9h no acumulador
    movwf dezena
    
    call mostrar
    goto loop

;********* SALVAR CONFIGURAÇÃO - ENTER **********
    
enter:
    decfsz filtro, F
    
    movlw .2000
    call delays_ms
    
    swapf dezena, dezena_buffer ; troca os nibbles da dezena
    
    addwf unidade, W ; soma o valor da unidade com o valor que resultou do swap pra ter o valor completo
    
    movwf valor_enter
    
    movlw 0x00 ; coloca o valor imediato 0h no acumulador
    movwf unidade
    movwf dezena
    movwf seg ; coloca no PORTD o resultado final
    
    return

;********* PULSO E LED **********
    
f_pulso:
    swapf dezena, dezena_buffer ; troca os nibbles da dezena
    
    addwf unidade, W ; soma o valor da unidade com o valor que resultou do swap pra ter o valor completo
    
    subwf valor_enter, W ; subtrai o valor do acumulador (resultado final) do valor_enter para saber se já atingiu o valor
    
    btfsc STATUS, 2 ; se tiver atingido o valor, chama a f_led
    call f_led

    return
    
f_led:
    call mostrar ; mostra o valor atual nos displays
    
    bsf led ; acende o led
    
    movlw .250
    call delays_ms
    
    movlw 0x00 ; coloca o valor imediato 0h no acumulador
    movwf unidade ; coloca o valor do acumulador na unidade para zerar
    movwf dezena ; coloca o valor do acumulador na dezena para zerar
    
    bcf led ; apaga o led
    
    return



;****************** Inicio do programa *****************************************

inicio:	
	
	clrf	PORTA		; Inicializa os Port's. Coloca todas pinos em 0.
	clrf	PORTB
	clrf	PORTC
	clrf	PORTD
	clrf	PORTE

	banksel	TRISA		; Seleciona banco de mem?ria 1
	movlw	0xFF
	movwf	TRISB		; Configura PortB como entrada.
	movlw	0x00
	movwf	TRISC		; Configura PortC como sa?da.
	movlw	0x00
	movwf	TRISD		; Configura PortD como sa?da.
	movlw	0x07
	movwf	TRISE		; Configura PortE como entrada e desliga Porta Paralela.

	movlw	0x00
	movwf	OPTION_REG	; Configura Op??es:
				; Pull-Up habilitados.
				; Interrup??o na borda de subida do sinal no pino B0.
				; Timer0 incrementado pelo oscilador interno.
				; Prescaler WDT 1:1.
				; Prescaler Timer0 1:2.

	movlw	0x90
	movwf	INTCON		; Desabilita todas as interrup??es.

	movlw	0x00
	movwf	PIE1		; Desabilita interrup??es perif?ricas.

	movlw	0x00
	movwf	PIE2		; Desabilita interrup??es perif?ricas.

	movlw	0x07
	movwf	ADCON0		; Desliga conversor A/D, PortA e PortE com I/O digital.

	movlw	0x07
	movwf	CMCON		; Desliga comparadores internos.

	movlw	0x00
	movwf	CVRCON		; Desliga m?dulo de ref?rencia interna de tens?o.

	banksel PORTA		; Seleciona banco de mem?ria 0.



;*********************** Loop principal ****************************************
loop:
    btfss btn_inc ; verifica se o botão incrementa foi apertado. se sim, executa a próxima linha
    call incrementa
    
    btfss btn_dec ; verifica se o botão decrementa foi apertado. se sim, executa a próxima linha
    call decrementa
    
    btfss btn_enter ; verifica se o botão enter foi apertado. se sim, executa a próxima linha
    call enter
    
    btfss btn_pulso ; verifica se o botão pulso foi apertado. se sim, executa a próxima linha
    call incrementa
    
    movlw .250
    movwf filtro
    
    goto loop
    end			          ; Fim do Programa.    END    
