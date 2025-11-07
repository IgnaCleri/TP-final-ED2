;*** Directivas de Inclusi?n ***    
LIST P=16F887                
#include "p16f887.inc"

;**** Configuraci?n General ****    
__CONFIG _CONFIG1, _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF    
    
;**** Definici?n de Variables ****
CBLOCK 0x20
    W_TEMP         
    STATUS_TEMP     
    DELAY1_2ms
    DELAY2_2ms
    DELAY1_20ms
    DELAY2_20ms
    CONT
    UNI
    DECS
    CEN
    NTECL
    NTECL_CONT
ENDC  

;*** Vectores de Reset e Interrupci?n ***
ORG 0x00
GOTO INICIO
ORG 0x04
GOTO ISR_INICIO
ORG 0x05

;==============================================================
; PROGRAMA PRINCIPAL
;==============================================================
INICIO    
    BANKSEL ANSELH
    CLRF    ANSELH	         ; PORTB digital
    BCF	    ANSEL,5
    BCF	    ANSEL,6
    BCF	    ANSEL,7
    BANKSEL TRISB
    MOVLW b'11000000'         ; RB7-RB6 = entradas (filas), RB5-RB3 = salidas (columnas) ;RB2-0 QUEDAN PENDIENTES DE ASIGNAR
    MOVWF   TRISB
    MOVLW B'00000000'
    MOVWF TRISA ; SALIDAS DE MULTIPLEXACION PUERTO A, RA0-RA2
    CLRF    TRISD
    
    BANKSEL OPTION_REG
    BCF OPTION_REG,7	         ; Habilita pull-ups en PORTB (RBPU=0)
   
    BANKSEL IOCB
    MOVLW b'11000000'          ; Habilita cambio en RB7-RB6
    MOVWF IOCB
    
    ; Inicializa las filas en alto (sin presionar tecla)
    BANKSEL PORTB
    MOVLW   b'00000000'      ; 
    MOVWF PORTB
    CLRF  PORTD
    CLRF NTECL
    CLRF CONT
    CLRF UNI
    CLRF DECS
    CLRF CEN
    CLRF NTECL_CONT          
   
    ; Habilita interrupciones por cambio en PORTB
    BANKSEL INTCON
    BCF INTCON, RBIF      ; Limpia bandera anterior
    MOVF PORTB, W         ; Lectura obligatoria para armar el latch
    BSF INTCON, RBIE       ; Habilita interrupci?n en cambio de RB
    BSF INTCON, GIE        ; Habilita interrupciones globales

MAIN_LOOP
LOOP_MUESTREO
    CALL MUESTREO             ; Actualiza displays a salida
    INCF    CONT,F
    MOVLW   .7
    SUBWF   CONT,W
    BTFSS   STATUS,Z
    GOTO    LOOP_MUESTREO
    GOTO    MAIN_LOOP ;;; que hacen estas lineas??
 
    
;==============================================================
; RUTINA DE INTERRUPCI?N
;==============================================================
ISR_INICIO    
    MOVWF   W_TEMP
    MOVFW   STATUS
    MOVWF   STATUS_TEMP ; guadado de contexto 

    BTFSS   INTCON,RBIF ; verifica si fue una int por teclado
    GOTO    ISR_FIN
    
    ; *** ANTIRREBOTE INICIAL *** (ver que hace????)
    CALL    DELAY_20ms
    
    CLRF    NTECL              
    MOVLW   b'10000000'        ; Activa primera fila
    MOVWF   PORTB
    CALL    DELAY_20ms          ; *** DELAY PARA ESTABILIZAR ***
    GOTO    TEST_TECLADO

;--------------------------------------------------------------
; Detecta columna activa
;--------------------------------------------------------------
TEST_TECLADO    
   CLRF NTECL
   MOVLW B'00011000'
   MOVWF PORTB
   INCF NTECL
   BTFSC PORTB,RB7
   GOTO TDELAY1
   MOVLW B'00101000'
   MOVWF PORTB
   INCF NTECL
   BTFSC PORTB,RB7
   GOTO 
   MOVLW B'00110000'
   MOVWF PORTB
   INCF NTECL
   BTFSC PORTB,RB7
   GOTO 


   MOVLW B'00011000'
   MOVWF PORTB
   INCF NTECL
   BTFSC PORTB,RB6
   GOTO 
   MOVLW B'00101000'
   MOVWF PORTB
   INCF NTECL
   BTFSC PORTB,RB6
   GOTO 
   MOVLW B'00110000'
   MOVWF PORTB
   INCF NTECL
   BTFSC PORTB,RB6
   GOTO 
   GOTO ISR_FIN ; NTECL =7 : NO ENCONTRO BOTON, SALGO



;--------------------------------------------------------------
; Guarda valor seg?n la tecla y fila detectada
;--------------------------------------------------------------
TECL_LOAD
    INCF    NTECL_CONT,F
    
    MOVLW   0x04
    SUBWF   NTECL_CONT,0
    BTFSC   STATUS,Z
    GOTO    TECL_RES

    MOVLW   0x03
    SUBWF   NTECL_CONT,0
    BTFSC   STATUS,Z
    GOTO    TECL_LOAD3

    MOVLW   0x02
    SUBWF   NTECL_CONT,0
    BTFSC   STATUS,Z
    GOTO    TECL_LOAD2

    GOTO    TECL_LOAD1

TECL_LOAD3
    MOVF    NTECL,W        
    MOVWF   UNI
    BCF     INTCON,RBIE         
    BCF     INTCON,GIE          
    GOTO    TECL_RES
    
TECL_LOAD2
    MOVF    NTECL,W
    MOVWF   DECS
    GOTO    TECL_RES
    
TECL_LOAD1
    MOVF    NTECL,W
    MOVWF   CEN
    GOTO    TECL_RES


;--------------------------------------------------------------
; Restaura registros y sale de interrupci?n
;--------------------------------------------------------------
ISR_FIN
    MOVFW   STATUS_TEMP
    MOVWF   STATUS
    MOVFW   W_TEMP
    RETFIE

;==============================================================
; RUTINA MUESTREO (actualiza displays o salidas)
;==============================================================
MUESTREO
    BSF	    PORTA,0
    BCF	    PORTA,1
    BCF	    PORTA,2
    MOVF    UNI,W
    CALL    TABLA_TECL
    MOVWF   PORTD
    CALL    DELAY_2ms

    BCF	    PORTA,0
    BSF	    PORTA,1
    BCF	    PORTA,2
    MOVF    DECS,W
    CALL    TABLA_TECL
    MOVWF   PORTD
    CALL    DELAY_2ms

    BCF	    PORTA,0
    BCF	    PORTA,1
    BSF	    PORTA,2
    MOVF    CEN,W
    CALL    TABLA_TECL
    MOVWF   PORTD
    CALL    DELAY_2ms
    RETURN

;==============================================================
; TABLA DE CONVERSI?N PARA DISPLAY 7 SEGMENTOS
;==============================================================
TABLA_TECL
	    ADDWF   PCL, F
	    RETLW   0x3F	; 0
	    NOP
	    NOP
	    NOP
	    NOP
	    nop
	    RETLW   0x7D	; 6 ---
	    RETLW   0x4F	; 3----
	    NOP
	    NOP
	    RETLW   0x6D	; 5----
	    RETLW   0x5B	; 2 ----
	    NOP
	    NOP
	    RETLW   0x66	; 4 ---
	    RETLW   0x06        ; 1 ---

;==============================================================
; DELAYS
;==============================================================
DELAY_2ms
    MOVLW   D'80'         
    MOVWF   DELAY1_2ms
LOOP1_2ms
    MOVLW   D'8'          
    MOVWF   DELAY2_2ms
LOOP2_2ms
    NOP
    DECFSZ  DELAY2_2ms, F
    GOTO    LOOP2_2ms
    DECFSZ  DELAY1_2ms, F
    GOTO    LOOP1_2ms
    RETURN

DELAY_20ms
    MOVLW   D'80'          
    MOVWF   DELAY1_20ms
LOOP1_20ms
    MOVLW   D'80'          
    MOVWF   DELAY2_20ms
LOOP2_20ms
    NOP
    DECFSZ  DELAY2_20ms, F
    GOTO    LOOP2_20ms
    DECFSZ  DELAY1_20ms, F
    GOTO    LOOP1_20ms
    RETURN

END