;*** Directivas de Inclusión ***
LIST P=16F887                
#include "p16f887.inc"

;**** Configuración General ****    
__CONFIG _CONFIG1, _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF    

;**** Definición de Variables ****
CBLOCK 0x20
   W_TEMP
   STATUS_TEMP
   COUNTER_TMR0
   COUNTER
ENDC  

;*** Vectores ***
ORG 0x00
GOTO INICIO
ORG 0x04
GOTO ISR_INICIO
ORG 0x05

;==============================================================
; MACROS
;==============================================================

CFG_SERIAL MACRO
   BANKSEL TRISC
   BCF  TRISC, 6      ; TX como salida
   BSF  TRISC, 7      ; RX como entrada (aunque no se use)

   BANKSEL TXSTA
   BSF TXSTA, TXEN     ; Habilita TX
   BCF TXSTA, SYNC     ; Modo asíncrono
   BSF TXSTA, BRGH     ; Alta velocidad

   BANKSEL RCSTA
   BSF RCSTA, SPEN     ; Habilita TX (y RX si se quisiera)

   BANKSEL BAUDCTL
   BCF BAUDCTL, BRG16  ; Baudrate de 8 bits

   BANKSEL SPBRG 
   MOVLW .25           ; 9600 baud @ 4MHz (BRGH=1)
   MOVWF SPBRG
ENDM
   

CFG_TMR0 MACRO
   BANKSEL INTCON
   BSF INTCON, T0IE     ; Habilita interrupciones por TMR0
   BCF INTCON, T0IF     ; Borra flag

   BANKSEL OPTION_REG
   MOVLW B'10000111'    ; PSA=1 (prescaler asignado a TMR0), PS=111 (1:256)
   MOVWF OPTION_REG

   BANKSEL TMR0
   MOVLW .61            ; Preload para 50 ms
   MOVWF TMR0

   BANKSEL COUNTER_TMR0
   CLRF COUNTER_TMR0
ENDM

;==============================================================
; PROGRAMA PRINCIPAL
;==============================================================
INICIO    
   CFG_TMR0
   CFG_SERIAL

   BANKSEL INTCON
   BSF INTCON, GIE      ; Habilita interrupciones globales

   GOTO $               ; Loop infinito

;==============================================================
; RUTINA DE INTERRUPCIÓN
;==============================================================
ISR_INICIO
   MOVWF W_TEMP
   SWAPF STATUS, W
   MOVWF STATUS_TEMP

   ; Verificar fuente TMR0
   BTFSS INTCON, T0IF
   GOTO ISR_FIN

   ;--------------------------------------
   ; ISR TMR0
   ;--------------------------------------
   INCF COUNTER_TMR0, F

   ; ¿Llegó a 20 interrupciones? (˜1s)
   MOVF COUNTER_TMR0, W
   SUBWF COUNTER_TMR0, W   ; W = COUNTER_TMR0 - COUNTER_TMR0 (NO! corregimos abajo)

   ; CORRECTO:
   MOVF COUNTER_TMR0, W
   SUBLW .20               ; W = 20 - COUNTER_TMR0
   BTFSS STATUS, Z
   GOTO RELOAD_TMR0

   ; Si llegó a 20 ? reiniciar contador
   CLRF COUNTER_TMR0

   ;---------------------------------------------------------
   ; Aumentar contador principal (0–9)
   ;---------------------------------------------------------
ADD_COUNTER:
   INCF COUNTER, F
   MOVF COUNTER, W
   SUBLW .10               ; W = 10 - COUNTER
   BTFSS STATUS, Z
   GOTO SERIAL_OUT
   CLRF COUNTER

;---------------------------------------------------------
; Envío serial
;---------------------------------------------------------
SERIAL_OUT
   MOVF COUNTER, W         ; W = COUNTER (0–9)
   CALL TABLE_OUT_SERIAL   ; -> ASCII en W
   CALL UART_TX

   MOVLW .10               ; salto de línea (LF)
   CALL UART_TX

   ;-------------------------------------------------------
   ; Recargar TMR0 y limpiar flag
   ;-------------------------------------------------------
RELOAD_TMR0
   BANKSEL TMR0
   MOVLW .61
   MOVWF TMR0

   BANKSEL INTCON
   BCF INTCON, T0IF
   GOTO ISR_FIN

;---------------------------------------------------------
; Tabla de conversión a ASCII
;---------------------------------------------------------
TABLE_OUT_SERIAL
   ADDWF PCL, F
   RETLW '0'
   RETLW '1'
   RETLW '2'
   RETLW '3'
   RETLW '4'
   RETLW '5'
   RETLW '6'
   RETLW '7'
   RETLW '8'
   RETLW '9'

;---------------------------------------------------------
; TX UART routine
;---------------------------------------------------------
UART_TX
   BANKSEL TXSTA
WAIT_TX
   BTFSS TXSTA, TRMT
   GOTO WAIT_TX
   BANKSEL TXREG
   MOVWF TXREG
   RETURN

;---------------------------------------------------------
; Restauración de contexto
;---------------------------------------------------------
ISR_FIN
   SWAPF STATUS_TEMP, W
   MOVWF STATUS
   SWAPF W_TEMP, F
   SWAPF W_TEMP, W
   RETFIE

END