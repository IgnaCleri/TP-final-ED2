    ;**********************************************************************
    ;* Programa: Contador Serial con Bot�n en RB0                        *
    ;* Microcontrolador: PIC16F887                                       *
    ;* Autor: Sistema ED2                                                *
    ;* Descripci�n: Incrementa un contador cada vez que se presiona un   *
    ;*              bot�n en RB0 y muestra el valor por terminal serie   *
    ;**********************************************************************

    ;*** Directivas de Inclusi�n ***
    LIST P=16F887
    #include "p16f887.inc"

    ;**** Configuraci�n General ****
    __CONFIG _CONFIG1, _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF

    ;**** Definici�n de Variables ****
    CBLOCK 0x20
        W_TEMP          ; Temporal para W durante interrupci�n
        STATUS_TEMP     ; Temporal para STATUS durante interrupci�n
        PCLATH_TEMP     ; Temporal para PCLATH durante interrupci�n
        CONTADOR        ; Contador principal (0-255)
        CONTADOR_CENT   ; Centenas del contador
        CONTADOR_DEC    ; Decenas del contador
        CONTADOR_UNI    ; Unidades del contador
        DELAY1_20ms     ; Variable para delay 20ms
        DELAY2_20ms     ; Variable para delay 20ms
        CARACTER_TX     ; Car�cter a transmitir por UART
        FLAG_NUEVO_DATO ; Bandera para indicar nuevo dato que enviar
        TEMP_W          ; Temporal adicional para W
    ENDC

    ;*** Vectores de Reset e Interrupci�n ***
    ORG 0x00
    GOTO INICIO
    ORG 0x04
    GOTO INTERRUPCION
    ORG 0x05

    ;**********************************************************************
    ; PROGRAMA PRINCIPAL
    ;**********************************************************************
    INICIO
        ;--- Configuraci�n de Puertos ---
        BANKSEL ANSEL
        CLRF    ANSEL          ; PORTA digital
        BANKSEL ANSELH
        CLRF    ANSELH         ; PORTB digital

        BANKSEL TRISA
        CLRF    TRISA          ; PORTA como salidas

        BANKSEL TRISB
        MOVLW   b'00000001'    ; RB0 = entrada (bot�n), resto salidas
        MOVWF   TRISB

        BANKSEL TRISC
        MOVLW   b'10000000'    ; RC7 = RX (entrada), RC6 = TX (salida)
        MOVWF   TRISC

        ;--- Inicializaci�n de Variables ---
        BANKSEL PORTA
        CLRF    PORTA
        CLRF    PORTB
        CLRF    PORTC

        ; Inicializar variables (están en banco 0)
        BANKSEL CONTADOR
        CLRF    CONTADOR       ; Inicia contador en 0
        CLRF    CONTADOR_CENT
        CLRF    CONTADOR_DEC
        CLRF    CONTADOR_UNI
        CLRF    FLAG_NUEVO_DATO

        ;--- Configuraci�n de Pull-ups en PORTB ---
        BANKSEL OPTION_REG
        BCF     OPTION_REG,7   ; Habilita pull-ups en PORTB (RBPU=0)

        ;--- Configuraci�n de Interrupci�n Externa (RB0/INT) ---
        BANKSEL INTCON
        BCF     INTCON,INTF    ; Limpia bandera de interrupci�n externa
        BSF     INTCON,INTE    ; Habilita interrupci�n externa RB0/INT
        BSF     INTCON,GIE     ; Habilita interrupciones globales

        ;--- Configuraci�n de UART (9600 baud @ 4MHz) ---
        CALL    INICIALIZAR_UART

        ;--- Mensaje de Bienvenida ---
        CALL    ENVIAR_MENSAJE_BIENVENIDA

        ;--- Bucle Principal ---
    BUCLE_PRINCIPAL
        ; Espera hasta que haya un nuevo dato para enviar
        BTFSC   FLAG_NUEVO_DATO,0
        CALL    PROCESAR_DATO_NUEVO

        GOTO    BUCLE_PRINCIPAL

    ;**********************************************************************
    ; INICIALIZACION DE UART (9600 baud @ 4MHz)
    ;**********************************************************************
    INICIALIZAR_UART
        BANKSEL TXSTA
        MOVLW   0x24           ; 8-bit, TX enabled, async mode, BRGH=1
        MOVWF   TXSTA

        BANKSEL SPBRG
        MOVLW   D'25'          ; SPBRG = 25 para 9600 baud @ 4MHz
        MOVWF   SPBRG

        BANKSEL RCSTA
        MOVLW   0x90           ; Serial port enabled, continuous receive
        MOVWF   RCSTA

        RETURN

    ;**********************************************************************
    ; PROCESAR NUEVO DATO (Convertir y Transmitir)
    ;**********************************************************************
    PROCESAR_DATO_NUEVO
        ; Convierte el contador a centenas, decenas y unidades
        CALL    CONVERTIR_DECIMAL

        ; Env�a el mensaje "Contador: XXX\n"
        CALL    ENVIAR_TEXTO_CONTADOR

        ; Env�a las centenas
        MOVF    CONTADOR_CENT,W
        CALL    CONVERTIR_ASCII
        CALL    ENVIAR_CARACTER_UART

        ; Env�a las decenas
        MOVF    CONTADOR_DEC,W
        CALL    CONVERTIR_ASCII
        CALL    ENVIAR_CARACTER_UART

        ; Env�a las unidades
        MOVF    CONTADOR_UNI,W
        CALL    CONVERTIR_ASCII
        CALL    ENVIAR_CARACTER_UART

        ; Env�a salto de l�nea
        MOVLW   0x0A           ; NL (New Line)
        CALL    ENVIAR_CARACTER_UART
        MOVLW   0x0D           ; CR (Carriage Return)
        CALL    ENVIAR_CARACTER_UART

        ; Limpia la bandera
        BANKSEL FLAG_NUEVO_DATO
        BCF     FLAG_NUEVO_DATO,0

        RETURN

    ;**********************************************************************
    ; CONVERSI�N DE N�MERO (0-255) A DECIMAL
    ;**********************************************************************
    CONVERTIR_DECIMAL
        BANKSEL CONTADOR
        ; Guarda el valor original del contador
        MOVF    CONTADOR,W
        MOVWF   CONTADOR_UNI    ; Usamos CONTADOR_UNI como temporal

        ; Calcula centenas
        CLRF    CONTADOR_CENT
    CENTENAS_LOOP
        MOVLW   D'100'
        SUBWF   CONTADOR_UNI,W
        BTFSS   STATUS,C
        GOTO    FIN_CENTENAS
        INCF    CONTADOR_CENT,F
        MOVLW   D'100'
        SUBWF   CONTADOR_UNI,F
        GOTO    CENTENAS_LOOP
    FIN_CENTENAS

        ; Calcula decenas
        CLRF    CONTADOR_DEC
    DECENAS_LOOP
        MOVLW   D'10'
        SUBWF   CONTADOR_UNI,W
        BTFSS   STATUS,C
        GOTO    FIN_DECENAS
        INCF    CONTADOR_DEC,F
        MOVLW   D'10'
        SUBWF   CONTADOR_UNI,F
        GOTO    DECENAS_LOOP
    FIN_DECENAS

        ; Lo que queda son las unidades
        MOVF    CONTADOR_UNI,W
        MOVWF   CONTADOR_UNI

        RETURN

    ;**********************************************************************
    ; CONVERSI�N DE D�GITO (0-9) A ASCII
    ;**********************************************************************
    CONVERTIR_ASCII
        ADDLW   '0'            ; Suma 48 (ASCII '0')
        RETURN

    ;**********************************************************************
    ; ENVIAR UN CARACTER POR UART
    ;**********************************************************************
    ENVIAR_CARACTER
        MOVWF   CARACTER_TX    ; Guarda el car�cter a enviar

    ESPERAR_TXREG
        BANKSEL TXSTA
        BTFSS   TXSTA,TRMT     ; Espera a que TXREG est� vac�o (TRMT=1)
        GOTO    ESPERAR_TXREG

        BANKSEL TXREG
        MOVF    CARACTER_TX,W
        MOVWF   TXREG          ; Env�a el car�cter

        RETURN

    ;**********************************************************************
    ; ENVIAR MENSAJE DE BIENVENIDA
    ;**********************************************************************
    ENVIAR_MENSAJE_BIENVENIDA
        ; "Sistema Contador Serial - PIC16F887\n\r"
        MOVLW   'S'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'i'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   's'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   't'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'e'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'm'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'a'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'C'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'o'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'n'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   't'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'a'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'd'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'o'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'r'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'S'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'e'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'r'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'i'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'a'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'l'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   '-'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'P'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'I'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'C'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   '1'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   '6'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'F'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   '8'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   '8'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   '7'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   0x0A           ; New Line
        CALL    ENVIAR_CARACTER_UART
        MOVLW   0x0D           ; Carriage Return
        CALL    ENVIAR_CARACTER_UART

        ; "Presione el boton en RB0 para incrementar\n\r"
        MOVLW   'P'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'r'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'e'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   's'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'i'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'o'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'n'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'e'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'e'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'l'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'b'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'o'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   't'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'o'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'n'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'e'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'n'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'R'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'B'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   '0'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'p'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'a'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'r'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'a'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'i'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'n'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'c'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'r'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'e'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'm'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'e'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'n'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   't'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'a'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'r'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   0x0A           ; New Line
        CALL    ENVIAR_CARACTER_UART
        MOVLW   0x0D           ; Carriage Return
        CALL    ENVIAR_CARACTER_UART

        RETURN

    ;**********************************************************************
    ; ENVIAR TEXTO "Contador: "
    ;**********************************************************************
    ENVIAR_TEXTO_CONTADOR
        MOVLW   'C'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'o'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'n'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   't'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'a'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'd'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'o'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   'r'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ':'
        CALL    ENVIAR_CARACTER_UART
        MOVLW   ' '
        CALL    ENVIAR_CARACTER_UART
        RETURN

    ;**********************************************************************
    ; ENVIAR CARACTER POR UART (versión simple)
    ;**********************************************************************
    ENVIAR_CARACTER_UART
        MOVWF   CARACTER_TX
    ESPERAR_TX
        BANKSEL TXSTA
        BTFSS   TXSTA,TRMT     ; Espera que TX esté libre
        GOTO    ESPERAR_TX
        BANKSEL TXREG
        MOVF    CARACTER_TX,W
        MOVWF   TXREG
        RETURN

    ;**********************************************************************
    ; RUTINA DE INTERRUPCI�N
    ;**********************************************************************
    INTERRUPCION
        ; Guarda contexto
        MOVWF   W_TEMP
        MOVF    STATUS,W
        MOVWF   STATUS_TEMP
        MOVF    PCLATH,W
        MOVWF   PCLATH_TEMP

        ; Verifica si fue interrupci�n externa (RB0/INT)
        BTFSS   INTCON,INTF
        GOTO    FIN_INTERRUPCION

        ; --- Procesamiento de la interrupci�n por bot�n ---

        ; Antirrebote
        CALL    DELAY_20ms

        ; Verifica si el bot�n sigue presionado (confirmaci�n)
        BANKSEL PORTB
        BTFSC   PORTB,RB0      ; Si RB0=1 (no presionado), ignora
        GOTO    FIN_INTERRUPCION

        ; Espera a que se suelte el bot�n
    ESPERA_SOLTAR
        BTFSS   PORTB,RB0
        GOTO    ESPERA_SOLTAR

        ; Segundo antirrebote
        CALL    DELAY_20ms

        ; Incrementa el contador
        BANKSEL CONTADOR
        INCF    CONTADOR,F
        BTFSC   STATUS,Z
        CLRF    CONTADOR       ; Si pasa de 255, vuelve a 0

        ; Establece bandera para enviar dato
        BANKSEL FLAG_NUEVO_DATO
        BSF     FLAG_NUEVO_DATO,0

        ; Limpia bandera de interrupci�n
        BANKSEL INTCON
        BCF     INTCON,INTF

    FIN_INTERRUPCION
        ; Restaura contexto
        MOVF    PCLATH_TEMP,W
        MOVWF   PCLATH
        MOVF    STATUS_TEMP,W
        MOVWF   STATUS
        MOVF    W_TEMP,W
        RETFIE

    ;**********************************************************************
    ; DELAY DE 20ms (Para antirrebote)
    ;**********************************************************************
    DELAY_20ms
        MOVLW   D'250'
        MOVWF   DELAY1_20ms
    LOOP1_20MS
        MOVLW   D'80'
        MOVWF   DELAY2_20ms
    LOOP2_20MS
        NOP
        DECFSZ  DELAY2_20ms,F
        GOTO    LOOP2_20MS
        DECFSZ  DELAY1_20ms,F
        GOTO    LOOP1_20MS
        RETURN

    ;**********************************************************************
    ; TABLA DE MENSAJES (Ya no se usa - mensajes enviados caracter por caracter)
    ;**********************************************************************
    ; ORG 0x200
    ; MENSAJE_BIENVENIDA
    ;     DT  "Sistema Contador Serial - PIC16F887", 0x0A, 0x0D
    ;     DT  "Presione el boton en RB0 para incrementar", 0x0A, 0x0D
    ;     DT  "----------------------------------------", 0x0A, 0x0D, 0x00
    ; MENSAJE_CONTADOR
    ;     DT  "Contador: ", 0x00

    ;**********************************************************************
    ; FIN DEL PROGRAMA
    ;**********************************************************************
        END