LIST p =16F887
INCLUDE <P16F887.inc>
#include "multiplicacion.asm"    ; Tabla de conversión ADC→Lux

 ORG 0x00
    GOTO MAIN
 ORG 0x04
    GOTO ISR_INICIO
;-------------------------------------------------------------------------------
;Declaracion de Variables:
;-------------------------------------------------------------------------------
CBLOCK 0X20
    STATUS_TEMP
    W_TEMP
    ADRESL_temp
    ADRESH_temp
    UNIDAD
    DECENA
    CENTENA
    CONT_TMR0
    ; Variables para conversión ADC→Lux
    MED_LUZ_H            ; Byte alto de medición en lux (0-9999)
    MED_LUZ_L            ; Byte bajo de medición en lux (0-9999)
ENDC
;-------------------------------------------------------------------------------
    
;-------------------------------------------------------------------------------
;Declaracion de MACROS:
;-------------------------------------------------------------------------------
CFG_ADC MACRO
    BSF STATUS, RP0
    BCF STATUS, RP1 ; Banco 1
 
    BCF ADCON1, VCFG0 ; Valor de referencia positivo y negativo de 5V y 0V
    BCF ADCON1, VCFG1 ; respectivamente.(Cambiar a los valores que usemos)
 
    BCF ADCON1, ADFM  ; Left justified
 
    BCF STATUS,RP0; Banco 0
 
    BSF ADCON0, ADCS0
    BCF ADCON0, ADCS1 ; Fosc/8 para 4MHz --> 2uS
 
    BCF ADCON0, CHS3
    BCF ADCON0, CHS2
    BCF ADCON0, CHS1
    BCF ADCON0, CHS0  ; CHANEL 0
 
    BSF ADCON0, ADON  ; ADC --> ON
 ENDM
;-------------------------------------------------------------------------------
 CFG_INT_ADC MACRO
 
    BCF STATUS, RP0
    BCF STATUS, RP1 ; Banco 0
 
    BSF INTCON, GIE  ; Habilito interrupcion
    BSF INTCON, PEIE ; Interrupcion por puerto activada.
 
    BSF STATUS, RP0
    BCF STATUS, RP1 ; Banco 1
 
    BSF PIE1, ADIE  ; Interrupcion por ADC
 ENDM
;-------------------------------------------------------------------------------
 CFG_TMR0 MACRO
    
    BSF STATUS, RP0
    BCF STATUS, RP1 ; BANCO 1
    
    BCF OPTION_REG, T0CS ; Modo Temporizador
    BCF OPTION_REG, T0SE ; por Flanco Ascendente
    BCF OPTION_REG, PSA  ; Prescaler al TMR0
    
    BCF OPTION_REG, PS0
    BCF OPTION_REG, PS1
    BCF OPTION_REG, PS2 ; Prescaler 1/2
    
    BCF STATUS, RP0 ; BANCO 0
    
    MOVLW .252
    MOVWF TMR0
ENDM
;-------------------------------------------------------------------------------
 CFG_INT_TMR0 MACRO
    
    BCF STATUS, RP0
    BCF STATUS, RP1 ; BANCO 0
    
    BSF INTCON, T0IE
ENDM
;-------------------------------------------------------------------------------
    
;-------------------------------------------------------------------------------
; CONNFIGURACION DE PUERTOS:
;-------------------------------------------------------------------------------
 CFG_PRS MACRO

    BSF STATUS, RP0
    BCF STATUS, RP1  ; Banco 1
    
    BSF TRISE, RE0
    BSF TRISE, RE1   ; RE0 y RE1 como entradas 
    
    BSF ANSEL, ANS5   
    BSF ANSEL, ANS6   ; RE0 y RE1 como analogicas
    
    BCF STATUS, RP0
    
ENDM
    
;-------------------------------------------------------------------------------
; INTERRUPCIONES:
;-------------------------------------------------------------------------------
ISR_INICIO
    MOVWF W_TEMP        ; Guarda W original
    SWAPF W_TEMP, F 
    SWAPF STATUS,W  
    MOVWF STATUS_TEMP

    BCF STATUS, RP0
    BCF STATUS, RP1 ; BANCO 0

    BTFSC PIR1, ADIF
    GOTO ISR_ADC
    BTFSC INTCON, T0IF
    GOTO ISR_TMR0
;-------------------------------------------------------------------------------
ISR_ADC
    BCF STATUS, RP0
    BCF STATUS, RP1 ; BANCO 0
 
 LOOP
    BTFSC ADCON0, GO
    GOTO LOOP
 
    BSF STATUS, RP0 ; BANCO 1
 
    MOVF ADRESL, W
    MOVWF ADRESL_temp
 
    BCF STATUS, RP0 ; BANCO 0
    MOVF ADRESH, W
    MOVWF ADRESH_temp
 
    CALL ADQ_CONV_LUX
 
    BCF PIR1, ADIF
 
    GOTO ISR_FIN
;-------------------------------------------------------------------------------
ISR_FIN 
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, W
    RETFIE
;-------------------------------------------------------------------------------
ISR_TMR0
    
    BCF STATUS, RP0
    BCF STATUS, RP1
    
    INCF CONT_TMR0
    MOVLW .2 
    
    SUBWF CONT_TMR0
    BTFSS STATUS, Z
    GOTO RELOAD_TMR
    CLRF CONT_TMR0
    BTFSC ADCON0, 1
    GOTO RELOAD_TMR
    BSF ADCON0, 1
    GOTO RELOAD_TMR	
;-------------------------------------------------------------------------------
    
    
;-------------------------------------------------------------------------------
; PROGRAMA PRINCIPAL:
;-------------------------------------------------------------------------------
MAIN
    CFG_PRS
    CFG_ADC                 ; Configuro ADC
    CFG_INT_ADC             ; Configuro interrupciones
    CFG_TMR0
    CFG_INT_TMR0
    BCF STATUS, RP0         ; Banco 0
    
MAIN_LOOP
    BSF ADCON0, GO          ; Inicio conversion
    GOTO MAIN_LOOP
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; CONVERSIÓN ADC → LUX
;-------------------------------------------------------------------------------
ADQ_CONV_LUX
    ; Convertir valor ADC a lux usando tabla pre-calculada
    ; Entrada: ADRESH_temp = valor ADC (0-255, formato left-justified)
    ; Salida: MED_LUZ_H:MED_LUZ_L = valor en lux (0-9999)

    MOVF    ADRESH_temp, W        ; Cargar valor ADC
    CALL    CONVERTIR_ADC_A_LUX   ; Convertir usando tabla pre-calculada
    MOVWF   MED_LUZ_L            ; Guardar parte baja del resultado

    MOVF    LUX_RESULT_H, W       ; Obtener parte alta del resultado
    MOVWF   MED_LUZ_H            ; Guardar parte alta

    RETURN

RELOAD_TMR
    BCF STATUS, RP0
    BCF STATUS, RP1
    
    MOVLW .252
    MOVWF TMR0
    
    BCF INTCON, T0IF
    
    GOTO ISR_FIN	
 
 END
;-------------------------------------------------------------------------------