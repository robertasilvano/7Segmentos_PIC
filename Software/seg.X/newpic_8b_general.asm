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
;cria constantes para o programa

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
#define	    btn_dec	PORTB,1		; Pino 34
#define	    btn_enter	PORTB,2		; Pino 34
#define	    btn_pulso	PORTB,3		; Pino 34


;********* vari?veis de Sa?da ***************
#define 	led	PORTC,5	            ; Pino 24
#define 	seg	PORTD	            ;

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
    
mostrar:
    swapf dezena, dezena_buffer ; troca os nibbles da dezena
    
    addwf unidade, W ; soma o valor da unidade com o valor que resultou do swap pra ter o valor completo
    
    movwf seg ; coloca no PORTD o resultado final
    
    return

incrementa:
    
    decfsz filtro, F
    
    movlw .2000
    call delays_ms
    
    movlw 0x10 ; coloca 10h no acumulador
    
    subwf unidade, W ; subtrai 10 da unidade. se der 0, unidade = 10
    btfss STATUS, 2 ; se der 0 na conta anterior, vai chamar a função da unidade, se não, só a da dezena. Precisa disso se não ele vai pular valores que tem unidade 0. Por exemplo: do 9 iria direto pro 11.
    call f_inc_unidade
    call f_inc_dezena
    
    call f_pulso
    
    call mostrar
    
    return
    
f_inc_unidade:
    movlw 0x09 ; coloca 9h no acumulador
    
    subwf unidade, W ; subtrai 9h da unidade, se der 0, unidade = 9
    btfsc STATUS, 2 ; se der 0 na conta anterior, vai chamar a função de limpar a unidade. Precisa disso pra zerar a unidade. Se não, continua o código.
    call clear_unidade
    
    ;movlw 0x09 ; coloca 9h no acumulador
    ;subwf unidade, W ; subtrai 9h da unidade, se der 0, unidade = 9. Se a unidade não for 9, vai chamar a função de incrementar.
    ;btfss STATUS, 2 ; se der 0 na conta anterior, vai chamar a função de incrementar
    call inc_unidade   
    return
    
inc_unidade:
    incf unidade, 1 ; incrementa 1 em unidade
    return
    
f_inc_dezena:
    movlw 0x0A ; coloca 10h no acumulador
    
    subwf dezena, W ; subtrai 10h da dezena, se der 0, dezena = 10. 
    btfsc STATUS, 2 ; se der 0 na conta anterior, vai chamar a função de limpar a dezena. Precisa disso pra zerar a dezena. Se não, continua o código.
    call clear_dezena
    
    movlw 0x0A ; coloca 10h no acumulador
    subwf dezena, W ; subtrai 10h da dezena, se der 0, dezena = 10. Se a dezena não for 10, vai chamar a função de incrementar.
    btfsc STATUS, 2 ; se der 0 na conta anterior, vai chamar a função de incrementar
    call inc_dezena  
    return
    
inc_dezena:
    incf dezena, 1
    return
    
clear_unidade:
    movlw 0x00
    movwf unidade
    
    call inc_dezena ; quando precisar zerar a unidade, significa que chegou em 9 e portanto tem que incrementar a dezena
    call mostrar
    goto loop
    
clear_dezena:
    movlw 0x00
    movwf dezena
    call mostrar
    goto loop

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
    
    movlw 0x00 ; coloca 00h no acumulador
    
    subwf unidade, W ; subtrai 00h da unidade. se der 0, unidade = 0
    btfsc STATUS, 2 ; se der 0 na conta anterior, vai chamar a função set unidade, se não, só a dec_unidade.
    call set_unidade
    call dec_unidade
    
    call mostrar
    
    return
    
set_unidade:
    movlw 0x09
    movwf unidade
    
    call f_dec_dezena ; quando precisar zerar a unidade, significa que chegou em 9 e portanto tem que incrementar a dezena
    call mostrar
    goto loop
    
dec_unidade:
    decf unidade, 1 ; incrementa 1 em unidade
    return

f_dec_dezena:
    movlw 0x00 ; coloca 00h no acumulador
    
    subwf dezena, W ; subtrai 00h da unidade. se der 0, unidade = 0
    btfsc STATUS, 2 ; se der 0 na conta anterior, vai chamar a função da unidade, se não, só a da dezena.
    call set_dezena
    call dec_dezena
    return

dec_dezena:
    decf dezena, 1 ; incrementa 1 em unidade
    return
    
set_dezena:
    movlw 0x09
    movwf dezena
    
    call mostrar
    goto loop
    
enter:
    decfsz filtro, F
    
    movlw .2000
    call delays_ms
    
    swapf dezena, dezena_buffer ; troca os nibbles da dezena
    
    addwf unidade, W ; soma o valor da unidade com o valor que resultou do swap pra ter o valor completo
    
    movwf valor_enter
    
    movlw 0x00
    movwf unidade
    movwf dezena
    movwf seg ; coloca no PORTD o resultado final
    
    return
    
f_pulso:
    swapf dezena, dezena_buffer ; troca os nibbles da dezena
    
    addwf unidade, W ; soma o valor da unidade com o valor que resultou do swap pra ter o valor completo
    
    subwf valor_enter, W
    
    btfsc STATUS, 2
    call f_led

    return
    
f_led:
    call mostrar
    
    bsf led
    
    movlw .250
    call delays_ms
    
    movlw 0x00
    movwf unidade
    movwf dezena    
    
    bcf led
    
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
    btfss btn_inc ; verifica se o botão foi apertado. se sim, executa a próxima linha
    call incrementa
    
    btfss btn_dec ; verifica se o botão foi apertado. se sim, executa a próxima linha
    call decrementa
    
    btfss btn_enter
    call enter
    
    btfss btn_pulso
    call incrementa
    
    movlw .250
    movwf filtro
    
    goto loop
    end			          ; Fim do Programa.    END    
    