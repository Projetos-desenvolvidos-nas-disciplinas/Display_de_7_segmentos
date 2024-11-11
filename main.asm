; Lista de valores de 8 bits
lista_valores:
    .DB     74, 85, 99, 123, 45, 67, 89, 234, 176, 38

; Inicialização da lista de 10 valores
LDI     ZH, HIGH(lista_valores)   ; Carregar o endereço alto da lista em Z
LDI     ZL, LOW(lista_valores)    ; Carregar o endereço baixo da lista em Z

LDI     R23, 10                ; Número de valores na lista (10)
LDI     R17, 0x00			   ; R17 para a centena
LDI     R18, 0x00              ; R18 para a dezena
LDI     R19, 0x00              ; R19 para a unidade

LDI     R24, 0x00              ; R24 para a ZERO
LDI     R28, 0x00              ; R28 para a ZERO
LDI     R29, 0x00              ; R29 para a ZERO

SBI     DDRC, 1
SBI     DDRC, 2
SBI     DDRC, 3

loop_lista:
	LPM     R16, Z                 ; Carregar o próximo valor da lista em R16
    RCALL   separa_digitos         ; Separar R16 em centenas, dezenas e unidades
    RCALL   converte_display       ; Converter os dígitos para códigos dos displays de sete segmentos
	
	; Exibir os valores convertidos no PORTD com delay entre cada exibição
	CBI     PORTC, 1
	SBI     PORTC, 2
    SBI     PORTC, 3
    OUT     PORTD, R17             ; Exibir a centena convertida no PORTD
	OUT     PORTB, R24             ; Exibir a centena convertida no PORTD
    RCALL   delay                  ; Chamar a rotina de delay

    SBI     PORTC, 1
	CBI     PORTC, 2
    SBI     PORTC, 3
    OUT     PORTD, R18             ; Exibir a centena convertida no PORTD
	OUT     PORTB, R28             ; Exibir a centena convertida no PORTD
    RCALL   delay                  ; Chamar a rotina de delay

	SBI     PORTC, 1
	SBI     PORTC, 2
    CBI     PORTC, 3
    OUT     PORTD, R19             ; Exibir a centena convertida no PORTD
	OUT     PORTB, R29             ; Exibir a centena convertida no PORTD
    RCALL   delay                  ; Chamar a rotina de delay

    ; Incrementar o ponteiro e verificar se o final da lista foi alcançado
    ADIW    ZL, 1                  ; Incrementar o endereço de Z para o próximo valor
    DEC     R23                    ; Decrementar o contador de valores
    BRNE    loop_lista             ; Se R20 não for zero, continuar o loop

    ; Reiniciar o loop
    LDI     ZH, HIGH(lista_valores)   ; Reiniciar o endereço alto da lista em Z
    LDI     ZL, LOW(lista_valores)    ; Reiniciar o endereço baixo da lista em Z
    LDI     R23, 10                   ; Reiniciar o contador de valores
    RJMP    loop_lista

; Separar o valor em centenas, dezenas e unidades
separa_digitos:
; Calcular centenas (R16/100)
	MOV     R20, R16       ; Copiar o valor original para R20
	LDI     R21, 100       ; Carregar 100 em R21 (divisor)
	CLR     R22            ; R22 será o contador de centenas (inicializado com zero)

centenas:
	CP      R20, R21       ; Comparar R20 com 100
	BRLO    fim_centenas   ; Se R20 < 100, terminar o cálculo
	SUB     R20, R21       ; Subtrair 100 de R20
	INC     R22            ; Incrementar o contador de centenas
	RJMP    centenas       ; Continuar subtraindo 100 de R20

fim_centenas:
	MOV     R17, R22       ; Armazenar o número de centenas em R17 (neste caso, R17 = 1)

; Calcular dezenas (R20/10)
	LDI     R21, 10        ; Carregar 10 em R21 (divisor)
	CLR     R22            ; R22 será o contador de dezenas

dezenas:
	CP      R20, R21       ; Comparar R20 com 10
	BRLO    fim_dezenas    ; Se R20 < 10, terminar o cálculo
	SUB     R20, R21       ; Subtrair 10 de R20
	INC     R22            ; Incrementar o contador de dezenas
	RJMP    dezenas        ; Continuar subtraindo 10 de R20

fim_dezenas:
	MOV     R18, R22       ; Armazenar o número de dezenas em R18 (neste caso, R18 = 7)

	; O valor restante em R20 é a unidade
	MOV     R19, R20       ; Armazenar o número de unidades em R19 (neste caso, R19 = 4)
    RET


; Rotina de conversão para display de sete segmentos
; Converte os valores de R17 (centena), R18 (dezena) e R19 (unidade) para os códigos de sete segmentos
converte_display:
    ; Converter R17 (centena)
    SBI     PORTC, 1
	SBI     PORTC, 2
	SBI     PORTC, 3

check_one17:
    CPI     R17, 1
    BRNE    check_two17
    LDI     R17, 0x60    ; Código para "one" no display de sete segmentos
	LDI     R24, 0x00    ; Código para "one" no display de sete segmentos
    RJMP    continua18

check_two17:
    CPI     R17, 2
    BRNE    check_three17
    LDI     R17, 0xB0    ; Código para "two" no display de sete segmentos
	LDI     R24, 0xA0    ; Código para "one" no display de sete segmentos
    RJMP    continua18

check_three17:
    CPI     R17, 3
    BRNE    check_four17
    LDI     R17, 0xF0    ; Código para "three" no display de sete segmentos
	LDI     R24, 0x80    ; Código para "one" no display de sete segmentos
    RJMP    continua18

check_four17:
    CPI     R17, 4
    BRNE    check_five17
    LDI     R17, 0x60    ; Código para "four" no display de sete segmentos
	LDI     R24, 0xC0    ; Código para "one" no display de sete segmentos
    RJMP    continua18

check_five17:
    CPI     R17, 5
    BRNE    check_six17
    LDI     R17, 0xD0    ; Código para "five" no display de sete segmentos
	LDI     R24, 0xC0    ; Código para "one" no display de sete segmentos
    RJMP    continua18

check_six17:
    CPI     R17, 6
    BRNE    check_seven17
    LDI     R17, 0xD0    ; Código para "six" no display de sete segmentos
	LDI     R24, 0xE0    ; Código para "one" no display de sete segmentos
    RJMP    continua18

check_seven17:
    CPI     R17, 7
    BRNE    check_eight17
    LDI     R17, 0x70    ; Código para "seven" no display de sete segmentos
	LDI     R24, 0x00    ; Código para "one" no display de sete segmentos
    RJMP    continua18

check_eight17:
    CPI     R17, 8
    BRNE    check_nine17
    LDI     R17, 0xF0    ; Código para "eight" no display de sete segmentos
	LDI     R24, 0xE0    ; Código para "one" no display de sete segmentos
    RJMP    continua18

check_nine17:
    CPI     R17, 9
    BRNE    continua18
    LDI     R17, 0xF0    ; Código para "nine" no display de sete segmentos
	LDI     R24, 0xC0    ; Código para "one" no display de sete segmentos

continua18:
    ; Repetir o mesmo processo para R18 (dezena) e R19 (unidade)
    CPI     R18, 0
    BRNE    check_one18
    LDI     R18, 0xF0
	LDI     R28, 0x60    ; Código para "one" no display de sete segmentos
    RJMP    continua19

check_one18:
    CPI     R18, 1
    BRNE    check_two18
    LDI     R18, 0x60    ; Código para "one" no display de sete segmentos
	LDI     R28, 0x00    ; Código para "one" no display de sete segmentos
    RJMP    continua19

check_two18:
    CPI     R18, 2
    BRNE    check_three18
    LDI     R18, 0xB0    ; Código para "two" no display de sete segmentos
	LDI     R28, 0xA0    ; Código para "one" no display de sete segmentos
    RJMP    continua19

check_three18:
    CPI     R18, 3
    BRNE    check_four18
    LDI     R18, 0xF0    ; Código para "three" no display de sete segmentos
	LDI     R28, 0x80    ; Código para "one" no display de sete segmentos
    RJMP    continua19

check_four18:
    CPI     R18, 4
    BRNE    check_five18
    LDI     R18, 0x60    ; Código para "four" no display de sete segmentos
	LDI     R28, 0xC0    ; Código para "one" no display de sete segmentos
    RJMP    continua19

check_five18:
    CPI     R18, 5
    BRNE    check_six18
    LDI     R18, 0xD0    ; Código para "five" no display de sete segmentos
	LDI     R28, 0xC0    ; Código para "one" no display de sete segmentos
    RJMP    continua19

check_six18:
    CPI     R18, 6
    BRNE    check_seven18
    LDI     R18, 0xD0    ; Código para "six" no display de sete segmentos
	LDI     R28, 0xE0    ; Código para "one" no display de sete segmentos
    RJMP    continua19

check_seven18:
    CPI     R18, 7
    BRNE    check_eight18
    LDI     R18, 0x70    ; Código para "seven" no display de sete segmentos
	LDI     R28, 0x00    ; Código para "one" no display de sete segmentos
    RJMP    continua19

check_eight18:
    CPI     R18, 8
    BRNE    check_nine18
    LDI     R18, 0xF0    ; Código para "eight" no display de sete segmentos
	LDI     R28, 0xE0    ; Código para "one" no display de sete segmentos
    RJMP    continua19

check_nine18:
    CPI     R18, 9
    BRNE    continua19
    LDI     R18, 0xF0    ; Código para "nine" no display de sete segmentos
	LDI     R28, 0xC0    ; Código para "one" no display de sete segmentos

continua19:
    ; Converter R19 (unidade)
    CPI     R19, 0
    BRNE    check_one19
    LDI     R19, 0xF0
	LDI     R29, 0x60    ; Código para "one" no display de sete segmentos
    RET

check_one19:
    CPI     R19, 1
    BRNE    check_two19
    LDI     R19, 0x60
	LDI     R29, 0x00    ; Código para "one" no display de sete segmentos
    RET

check_two19:
    CPI     R19, 2
    BRNE    check_three19
    LDI     R19, 0xB0
	LDI     R29, 0xA0    ; Código para "one" no display de sete segmentos
    RET

check_three19:
    CPI     R19, 3
    BRNE    check_four19
    LDI     R19, 0xF0
	LDI     R29, 0x80    ; Código para "one" no display de sete segmentos
    RET

check_four19:
    CPI     R19, 4
    BRNE    check_five19
    LDI     R19, 0x60
	LDI     R29, 0xC0    ; Código para "one" no display de sete segmentos
    RET

check_five19:
    CPI     R19, 5
    BRNE    check_six19
    LDI     R19, 0xD0
	LDI     R29, 0xC0    ; Código para "one" no display de sete segmentos
    RET

check_six19:
    CPI     R19, 6
    BRNE    check_seven19
    LDI     R19, 0xD0
	LDI     R29, 0xE0    ; Código para "one" no display de sete segmentos
    RET

check_seven19:
    CPI     R19, 7
    BRNE    check_eight19
    LDI     R19, 0x70
	LDI     R29, 0x00    ; Código para "one" no display de sete segmentos
    RET

check_eight19:
    CPI     R19, 8
    BRNE    check_nine19
    LDI     R19, 0xF0
	LDI     R29, 0xE0    ; Código para "one" no display de sete segmentos
    RET

check_nine19:
    CPI     R19, 9
    BRNE    fim_conversao
    LDI     R19, 0xF0
	LDI     R29, 0xC0    ; Código para "one" no display de sete segmentos

fim_conversao:
    RET

; Rotina de Delay
delay:
    LDI     R26, 26      ; Configurar o número de loops externos
delay1:
    LDI     R27, 26      ; Configurar o número de loops do meio
delay2:
    LDI     R25, 26      ; Configurar o número de loops internos
delay3:
    DEC     R25           ; Decrementar o loop interno
    NOP                   ; No Operation (para ajuste de tempo)
    BRNE    delay3        ; Repetir se R25 não for zero
    DEC     R27           ; Decrementar o loop do meio
    BRNE    delay2        ; Repetir se R24 não for zero
    DEC     R26           ; Decrementar o loop externo
    BRNE    delay1        ; Repetir se R30 não for zero
    RET                    ; Retornar ao programa principal