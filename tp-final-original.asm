; ============================================================
; PROGRAMA DE PRUEBA: TECLADO 3x2 + 4 DISPLAYS 7SEG AC
; ============================================================
; Teclado 6 teclas (3 filas x 2 columnas) por PUERTO B
;     - 3 FILAS F1 a F3 (RB7-RB5) como OUT
;     - 2 COLUMNAS C1 a C2 (RB4-RB3) como IN
; Muestra en 4 Displays por PUERTO D
; Control de displays por PUERTO A (RA0-RA3)
    
;*** Directivas de Inclusi n ***
LIST P=16F887
#include "p16f887.inc"
#include "multiplicacion.asm"    ; Tabla de conversi n ADC→Lux

;**** Configuraci n General ****    
__CONFIG _CONFIG1, _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF    
    
;==============================================================
; DEFINICI N DE VARIABLES
;==============================================================

;--- Variables para Rutina de Interrupci n (Banco 0x20) ---
	    CBLOCK 0x20
		W_TEMP          ; Temporal para salvar registro W en interrupciones
		STATUS_TEMP     ; Temporal para salvar registro STATUS en interrupciones
		DELAY1_2ms      ; Temporal para rutina de retardo de 2ms
		DELAY2_2ms      ; Temporal para rutina de retardo de 2ms
		DELAY1_20ms     ; Temporal para rutina de retardo de 20ms
		DELAY2_20ms     ; Temporal para rutina de retardo de 20ms
	    ENDC

;--- Variables de Display y Teclado (Banco 0x30) ---
	    CBLOCK 0x30
		UNIDAD          ; D gito de unidades para display 7 segmentos
		DECENA          ; D gito de decenas para display 7 segmentos
		CENTENA         ; D gito de centenas para display 7 segmentos
		MILLAR          ; D gito de millares para display 7 segmentos
		NTECL           ; N mero de tecla presionada (0-5)
		NTECL_CONT      ; Contador/auxiliar para teclado
	    ENDC

;--- Variables del Sistema y Datos de 16 bits (Banco 0x40) ---
	    CBLOCK 0x40
		MODO_DISPLAY		; 0 = Ver Medici n, 1 = Ver Umbral

		; Variables para Umbral de Luz (16 bits)
		UMBRAL_LUZ_H		; Byte alto del Umbral (0-9999 lux)
		UMBRAL_LUZ_L		; Byte bajo del Umbral

		; Variables para Medici n de Luz (16 bits)
		MED_LUZ_H		; Byte alto de Medici n (simulada sin ADC)
		MED_LUZ_L		; Byte bajo de Medici n

		; Variables Temporales para Aritm tica de 16 bits
		TEMP_H			; Temporal alto para c lculos de 16 bits
		TEMP_L			; Temporal bajo para c lculos de 16 bits
	    ENDC

;==============================================================
; MACROS DE CONFIGURACI N DEL SISTEMA
;==============================================================
;--- Macro: Configurar Displays de 7 Segmentos ---
CFG_DSPL    MACRO
	    ; Configurar ANSEL para puertos digitales
	    BANKSEL ANSEL
	    CLRF    ANSEL

	    ; Configurar PORTA: RA0-RA3 como salidas (control de displays)
	    BANKSEL TRISA
	    BCF     TRISA, RA0        ; Display 1 (unidades)
	    BCF     TRISA, RA1        ; Display 2 (decenas)
	    BCF     TRISA, RA2        ; Display 3 (centenas)
	    BCF     TRISA, RA3        ; Display 4 (millares)

	    ; Configurar PORTD: RD0-RD7 como salidas (datos 7 segmentos)
	    CLRF    TRISD

	    ; Inicializar puertos en 0
	    BANKSEL PORTD
	    CLRF    PORTD
	    CLRF    PORTA
	    ENDM
    
    
;--- Macro: Configurar Teclado Matricial 3x2 ---
CFG_TECL    MACRO
	    ; Configurar PORTB como digital
	    BANKSEL ANSELH
	    CLRF    ANSELH

	    ; Configurar direcciones: Filas(RB7-RB5)=OUT, Columnas(RB4-RB3)=IN
	    MOVLW   B'00011000'     ; RB7-RB5=0 (salidas), RB4-RB3=1 (entradas)
	    MOVWF   TRISB

	    ; Habilitar pull-ups internos para columnas (RB4-RB3)
	    BANKSEL WPUB
	    MOVLW   B'00011000'
	    MOVWF   WPUB

	    ; Habilitar interrupciones por cambio en columnas
	    BANKSEL IOCB
	    MOVLW   B'00011000'
	    MOVWF   IOCB

	    ; Habilitar pull-ups globales
	    BANKSEL OPTION_REG
	    BCF     OPTION_REG, 7    ; RBPU = 0 (pull-ups habilitados)
	    ENDM        

    
;--- Macro: Inicializar Registros y Variables ---
CFG_INIT_REG MACRO
	    BANKSEL PORTB
	    CLRF    PORTB            ; Limpiar puertos
	    CLRF    PORTD
	    CLRF    PORTA

	    ; Inicializar variables de display y teclado
	    CLRF    NTECL
	    CLRF    UNIDAD
	    CLRF    DECENA
	    CLRF    CENTENA
	    CLRF    MILLAR
	    CLRF    NTECL_CONT

	    ; Configurar modo de display: 0=Medici n, 1=Umbral
	    MOVLW   .0
	    MOVWF   MODO_DISPLAY

	    ; Valores iniciales de prueba (demostraci n 16 bits > 255)
	    MOVLW   0x20            ; Umbral: 800 lux (0x0320)
	    MOVWF   UMBRAL_LUZ_L
	    MOVLW   0x03
	    MOVWF   UMBRAL_LUZ_H

	    ; Inicializar medici n simulada mediante ADC
	    CALL    SIMULAR_LECTURA_ADC     ; Obtener valor ADC simulado
	    CALL    CONVERTIR_ADC_A_LUX     ; Convertir a lux
	    MOVWF   MED_LUZ_L                ; Guardar parte baja
	    MOVF    LUX_RESULT_H, W         ; Obtener parte alta
	    MOVWF   MED_LUZ_H                ; Guardar parte alta
	    ENDM        
    
    
;--- Macro: Configurar Interrupciones ---
CFG_INT     MACRO
	    BANKSEL INTCON
	    BCF     INTCON, RBIF     ; Limpiar bandera de interrupci n por B
	    MOVF    PORTB, W        ; Lectura para armar latch
	    BSF     INTCON, RBIE     ; Habilitar interrupciones por cambio B
	    BSF     INTCON, GIE      ; Habilitar interrupciones globales
	    ENDM                
                
    
;==============================================================
; VECTORES DE INTERRUPCI N Y INICIALIZACI N
;==============================================================
	    ORG     0x00            ; Vector de Reset
	    GOTO    INICIO
	    ORG     0x04            ; Vector de Interrupci n
	    GOTO    ISR_INICIO
	    ORG     0x05            ; Inicio del programa principal

;==============================================================
; PROGRAMA PRINCIPAL
;==============================================================
INICIO
	    CFG_DSPL               ; Configurar displays de 7 segmentos
	    CFG_TECL               ; Configurar teclado matricial
	    CFG_INIT_REG           ; Inicializar variables y registros
	    CFG_INT                ; Configurar interrupciones

;--- Bucle Principal de Operaci n ---
LOOP

;==============================================================
; L GICA DE SELECCI N DE MODO DE VISUALIZACI N
;==============================================================
SEL_MODO_LUZ
	    ; Verificar qu mostrar: Medici n (0) o Umbral (1)
	    BTFSS   MODO_DISPLAY, 0     ; ¿Modo Umbral activado?
	    GOTO    CARGAR_MED_LUZ       ; No: mostrar medici n
	    GOTO    CARGAR_UMB_LUZ       ; S : mostrar umbral

;--- Cargar y Descomponer Medici n de Luz (16 bits) ---
CARGAR_MED_LUZ
	    CALL    DESCOMPONER_MED_LUZ_16
	    GOTO    MOSTRAR

;--- Cargar y Descomponer Umbral de Luz (16 bits) ---
CARGAR_UMB_LUZ
	    CALL    DESCOMPONER_UMB_LUZ_16
	    GOTO    MOSTRAR

;==============================================================
; RUTINAS DE SOPORTE PARA ARITM TICA DE 16 BITS
;==============================================================

;==============================================================
; COMPARA SI VALOR_H:VALOR_L >= 1000 (0x03E8)
; Entrada: VALOR_H:VALOR_L = valor a comparar (0-9999)
; Salida: Carry = 1 si valor >= 1000, Carry = 0 si valor < 1000
;==============================================================
COMPARAR_1000
    ; Comparar byte alto primero
    MOVF    VALOR_H, W
    SUBLW   0x03          ; Comparar con 0x03
    BTFSS   STATUS, Z     ; Si parte alta != 0x03, resultado definido
    GOTO    FIN_COMP_1000
    BTFSS   STATUS, C     ; Si C=0, VALOR_H > 0x03 (imposible para 9999)
    GOTO    VALOR_MAYOR_1000

    ; Si parte alta = 0x03, comparar parte baja
    MOVF    VALOR_L, W
    SUBLW   0xE8          ; Comparar con 0xE8 (232)
    BTFSS   STATUS, C     ; Si C=1, valor < 1000
    GOTO    VALOR_MENOR_1000

VALOR_MAYOR_1000
    ; valor >= 1000, establecer Carry = 1
    BSF     STATUS, C
    RETURN

VALOR_MENOR_1000
    ; valor < 1000, establecer Carry = 0
    BCF     STATUS, C
    RETURN

FIN_COMP_1000
    ; Si parte alta > 0x03, definitivamente >= 1000
    BTFSC   STATUS, C     ; Si C=0, VALOR_H > 0x03
    GOTO    VALOR_MAYOR_1000
    GOTO    VALOR_MENOR_1000

;==============================================================
; RESTA 1000 (0x03E8) DEL VALOR ACTUAL EN VALOR_H:VALOR_L
; Entrada: VALOR_H:VALOR_L = valor inicial (>= 1000)
; Salida: VALOR_H:VALOR_L = valor - 1000
; Nota: Se asume que el valor inicial es >= 1000
;==============================================================
RESTAR_1000
    ; Preparar valor 1000 en temporales
    MOVLW   0x03
    MOVWF   TEMP_H
    MOVLW   0xE8
    MOVWF   TEMP_L

    ; Restar parte baja (VALOR_L - 232)
    MOVF    TEMP_L, W
    SUBWF   VALOR_L, F

    ; Restar parte alta con manejo de pr stamo
    MOVF    TEMP_H, W
    BTFSS   STATUS, C      ; Si no hay pr stamo, resta normal
    GOTO    RESTA_ALTA_NORMAL

    ; Si hay pr stamo (C=0), restar 1 extra de la parte alta
    ADDLW   0xFF           ; W = W - 1 (equivalente a decrementar)

RESTA_ALTA_NORMAL
    SUBWF   VALOR_H, F
    RETURN

;==============================================================
; INCREMENTA UMBRAL_LUZ_H:UMBRAL_LUZ_L EN 1
; Entrada: UMBRAL_LUZ_H:UMBRAL_LUZ_L = valor actual
; Salida: UMBRAL_LUZ_H:UMBRAL_LUZ_L = valor + 1 (con l mite 9999)
;==============================================================
INCREMENTAR_UMBRAL
    ; Incrementar parte baja
    INCF    UMBRAL_LUZ_L, F
    BTFSS   STATUS, Z          ; Si no hay desbordamiento, terminar
    GOTO    FIN_INC_UMBRAL

    ; Hay desbordamiento en parte baja, incrementar parte alta
    INCF    UMBRAL_LUZ_H, F
    ; Verificar si excede 9999 (0x270F)
    MOVLW   0x27
    SUBWF   UMBRAL_LUZ_H, W
    BTFSS   STATUS, Z
    GOTO    FIN_INC_UMBRAL
    MOVLW   0x0F
    SUBWF   UMBRAL_LUZ_L, W
    BTFSS   STATUS, Z
    GOTO    FIN_INC_UMBRAL

    ; Excedi 9999, limitar a 9999
    MOVLW   0x27
    MOVWF   UMBRAL_LUZ_H
    MOVLW   0x0F
    MOVWF   UMBRAL_LUZ_L

FIN_INC_UMBRAL
    RETURN

;==============================================================
; DECREMENTA UMBRAL_LUZ_H:UMBRAL_LUZ_L EN 1
; Entrada: UMBRAL_LUZ_H:UMBRAL_LUZ_L = valor actual
; Salida: UMBRAL_LUZ_H:UMBRAL_LUZ_L = valor - 1 (sin pasar de 0)
;==============================================================
DECREMENTAR_UMBRAL
    ; Verificar si ya es 0
    MOVF    UMBRAL_LUZ_H, W
    BTFSS   STATUS, Z
    GOTO    DEC_NORMAL
    MOVF    UMBRAL_LUZ_L, W
    BTFSS   STATUS, Z
    GOTO    DEC_NORMAL

    ; Ya es 0, no decrementar m s
    RETURN

DEC_NORMAL
    ; Decrementar parte baja
    DECF    UMBRAL_LUZ_L, F
    BTFSC   STATUS, Z          ; Si hay desbordamiento, ajustar parte alta
    GOTO    AJUSTE_ALTO

    ; No hay desbordamiento, terminar
    RETURN

AJUSTE_ALTO
    ; Hay desbordamiento (parte baja pas de 0 a 255)
    DECF    UMBRAL_LUZ_H, F
    RETURN

;==============================================================
; DESCOMPONE VALOR DE MEDICI N DE 16 BITS (0-9999) EN 4 D GITOS
; Entrada: MED_LUZ_H:MED_LUZ_L = valor a descomponer (0-9999)
; Salida: MILLAR, CENTENA, DECENA, UNIDAD
;==============================================================
DESCOMPONER_MED_LUZ_16
	    ; Inicializar todos los d gitos
	    CLRF    MILLAR
	    CLRF    CENTENA
	    CLRF    DECENA
	    CLRF    UNIDAD

	    ; Copiar MED_LUZ a TEMP para no modificar originales
	    MOVF    MED_LUZ_L, W
	    MOVWF   TEMP_L
	    MOVF    MED_LUZ_H, W
	    MOVWF   TEMP_H

	    ; Extraer millares (division sustractiva por 1000)
EXTRAER_MILLARES_MED
	    ; Comparar si TEMP_H:TEMP_L >= 1000
	    MOVLW   0x03
	    SUBWF   TEMP_H, W
	    BTFSS   STATUS, Z          ; Si parte alta > 3, es >= 1000
	    GOTO    RESTAR_1000_MED
	    BTFSC   STATUS, C          ; Si parte alta < 3, es < 1000
	    GOTO    EXTRAER_CENTENAS_MED

	    ; Parte alta = 3, comparar parte baja
	    MOVF    TEMP_L, W
	    SUBLW   0xE8               ; Comparar con 232
	    BTFSS   STATUS, C          ; Si C=0, es >= 1000
	    GOTO    EXTRAER_CENTENAS_MED

RESTAR_1000_MED
	    ; Restar 1000 (0x03E8)
	    MOVLW   0xE8
	    SUBWF   TEMP_L, F
	    BTFSS   STATUS, C          ; Si hay pr stamo
	    GOTO    SIN_PRESTAMO_MED
	    DECF    TEMP_H, F          ; Ajustar parte alta

SIN_PRESTAMO_MED
	    MOVLW   0x03
	    SUBWF   TEMP_H, F
	    INCF    MILLAR, F
	    GOTO    EXTRAER_MILLARES_MED

EXTRAER_CENTENAS_MED
	    ; Ahora TEMP_H:TEMP_L < 1000, extraer centenas del valor restante
	    MOVF    TEMP_H, W
	    BTFSS   STATUS, Z          ; Deber a ser 0
	    GOTO    ERROR_DESCOMP_MED

	    MOVF    TEMP_L, W
	    MOVWF   UNIDAD             ; Usar UNIDAD como temporal

LOOP_CENTENAS_MED
	    MOVLW   d'100'
	    SUBWF   UNIDAD, W
	    BTFSS   STATUS, C
	    GOTO    EXTRAER_DECENAS_MED
	    MOVWF   UNIDAD
	    INCF    CENTENA, F
	    GOTO    LOOP_CENTENAS_MED

EXTRAER_DECENAS_MED
	    MOVLW   d'10'
	    SUBWF   UNIDAD, W
	    BTFSS   STATUS, C
	    GOTO    FIN_DESCOMP_MED
	    MOVWF   UNIDAD
	    INCF    DECENA, F
	    GOTO    EXTRAER_DECENAS_MED

FIN_DESCOMP_MED
	    RETURN

ERROR_DESCOMP_MED
	    ; Error, limitar a 9999
	    MOVLW   0x0F
	    MOVWF   MILLAR
	    MOVLW   0x09
	    MOVWF   CENTENA
	    MOVLW   0x09
	    MOVWF   DECENA
	    MOVLW   0x09
	    MOVWF   UNIDAD
	    RETURN

;==============================================================
; DESCOMPONE UMBRAL DE 16 BITS (0-9999) EN 4 D GITOS
; Entrada: UMBRAL_LUZ_H:UMBRAL_LUZ_L = valor a descomponer (0-9999)
; Salida: MILLAR, CENTENA, DECENA, UNIDAD
;==============================================================
DESCOMPONER_UMB_LUZ_16
	    ; Inicializar todos los d gitos
	    CLRF    MILLAR
	    CLRF    CENTENA
	    CLRF    DECENA
	    CLRF    UNIDAD

	    ; Copiar UMBRAL_LUZ a TEMP para no modificar originales
	    MOVF    UMBRAL_LUZ_L, W
	    MOVWF   TEMP_L
	    MOVF    UMBRAL_LUZ_H, W
	    MOVWF   TEMP_H

	    ; Extraer millares (division sustractiva por 1000)
EXTRAER_MILLARES_UMB
	    ; Comparar si TEMP_H:TEMP_L >= 1000
	    MOVLW   0x03
	    SUBWF   TEMP_H, W
	    BTFSS   STATUS, Z          ; Si parte alta > 3, es >= 1000
	    GOTO    RESTAR_1000_UMB
	    BTFSC   STATUS, C          ; Si parte alta < 3, es < 1000
	    GOTO    EXTRAER_CENTENAS_UMB

	    ; Parte alta = 3, comparar parte baja
	    MOVF    TEMP_L, W
	    SUBLW   0xE8               ; Comparar con 232
	    BTFSS   STATUS, C          ; Si C=0, es >= 1000
	    GOTO    EXTRAER_CENTENAS_UMB

RESTAR_1000_UMB
	    ; Restar 1000 (0x03E8)
	    MOVLW   0xE8
	    SUBWF   TEMP_L, F
	    BTFSS   STATUS, C          ; Si hay pr stamo
	    GOTO    SIN_PRESTAMO_UMB
	    DECF    TEMP_H, F          ; Ajustar parte alta

SIN_PRESTAMO_UMB
	    MOVLW   0x03
	    SUBWF   TEMP_H, F
	    INCF    MILLAR, F
	    GOTO    EXTRAER_MILLARES_UMB

EXTRAER_CENTENAS_UMB
	    ; Ahora TEMP_H:TEMP_L < 1000, extraer centenas del valor restante
	    MOVF    TEMP_H, W
	    BTFSS   STATUS, Z          ; Deber a ser 0
	    GOTO    ERROR_DESCOMP_UMB

	    MOVF    TEMP_L, W
	    MOVWF   UNIDAD             ; Usar UNIDAD como temporal

LOOP_CENTENAS_UMB
	    MOVLW   d'100'
	    SUBWF   UNIDAD, W
	    BTFSS   STATUS, C
	    GOTO    EXTRAER_DECENAS_UMB
	    MOVWF   UNIDAD
	    INCF    CENTENA, F
	    GOTO    LOOP_CENTENAS_UMB

EXTRAER_DECENAS_UMB
	    MOVLW   d'10'
	    SUBWF   UNIDAD, W
	    BTFSS   STATUS, C
	    GOTO    FIN_DESCOMP_UMB
	    MOVWF   UNIDAD
	    INCF    DECENA, F
	    GOTO    EXTRAER_DECENAS_UMB

FIN_DESCOMP_UMB
	    RETURN

ERROR_DESCOMP_UMB
	    ; Error, limitar a 9999
	    MOVLW   0x0F
	    MOVWF   MILLAR
	    MOVLW   0x09
	    MOVWF   CENTENA
	    MOVLW   0x09
	    MOVWF   DECENA
	    MOVLW   0x09
	    MOVWF   UNIDAD
	    RETURN

;==============================================================
; RUTINA DE SIMULACI N DE LECTURA ADC
; Propósito: Simular diferentes valores ADC para probar la conversión
; Salida: W = valor ADC simulado (0-255)
;==============================================================
SIMULAR_LECTURA_ADC
	    ; Para pruebas, podemos devolver valores fijos o variarlos
	    ; Aquí algunos ejemplos de prueba:

	    ;MOVLW   0x00        ; ADC=0   →   7 lux (mínimo)
	    ;MOVLW   0x33        ; ADC=51  → 889 lux (bajo)
	    ;MOVLW   0x66        ; ADC=102 → 3208 lux (medio)
	    ;MOVLW   0x99        ; ADC=153 → 7230 lux (alto)
	    MOVLW   0xFF        ; ADC=255 → 9999 lux (saturado)

	    RETURN


;==============================================================
; ACTUALIZACI N DE DISPLAYS Y CONTROL DEL BUCLE
;==============================================================
MOSTRAR
	    CALL    REFRESH_DSPL      ; Actualizar displays con multiplexado
	    GOTO    LOOP              ; Continuar bucle principal     
    
;==============================================================
; RUTINA DE REFRESCO DE DISPLAYS (MULTIPLEXADO)
;==============================================================
; Despliega los 4 d gitos en los displays de 7 segmentos mediante multiplexado
; Entrada: UNIDAD, DECENA, CENTENA, MILLAR (valores 0-9)
; Salida: Muestra valores en displays 7 segmentos

REFRESH_DSPL
	    ; Apagar todos los displays para evitar ghosting
	    BSF     PORTA, RA0       ; Display 1 OFF
	    BSF     PORTA, RA1       ; Display 2 OFF
	    BSF     PORTA, RA2       ; Display 3 OFF
	    BSF     PORTA, RA3       ; Display 4 OFF

	    ; --- Display 1: Unidades (RA0) ---
	    MOVF    UNIDAD, W
	    CALL    TABLE_DSPL_AC    ; Convertir a 7 segmentos
	    MOVWF   PORTD           ; Enviar datos al display
	    BCF     PORTA, RA0       ; Encender Display 1
	    CALL    DELAY_2ms       ; Mantener encendido 2ms

	    ; Apagar todos los displays
	    BSF     PORTA, RA0
	    BSF     PORTA, RA1
	    BSF     PORTA, RA2
	    BSF     PORTA, RA3

	    ; --- Display 2: Decenas (RA1) ---
	    MOVF    DECENA, W
	    CALL    TABLE_DSPL_AC    ; Convertir a 7 segmentos
	    MOVWF   PORTD           ; Enviar datos al display
	    BCF     PORTA, RA1       ; Encender Display 2
	    CALL    DELAY_2ms       ; Mantener encendido 2ms

	    ; Apagar todos los displays
	    BSF     PORTA, RA0
	    BSF     PORTA, RA1
	    BSF     PORTA, RA2
	    BSF     PORTA, RA3

	    ; --- Display 3: Centenas (RA2) ---
	    MOVF    CENTENA, W
	    CALL    TABLE_DSPL_AC    ; Convertir a 7 segmentos
	    MOVWF   PORTD           ; Enviar datos al display
	    BCF     PORTA, RA2       ; Encender Display 3
	    CALL    DELAY_2ms       ; Mantener encendido 2ms

	    ; Apagar todos los displays
	    BSF     PORTA, RA0
	    BSF     PORTA, RA1
	    BSF     PORTA, RA2
	    BSF     PORTA, RA3

	    ; --- Display 4: Millares (RA3) ---
	    MOVF    MILLAR, W
	    CALL    TABLE_DSPL_AC    ; Convertir a 7 segmentos
	    MOVWF   PORTD           ; Enviar datos al display
	    BCF     PORTA, RA3       ; Encender Display 4
	    CALL    DELAY_2ms       ; Mantener encendido 2ms

	    RETURN

;==============================================================
; TABLA DE CONVERSI N PARA DISPLAY 7 SEGMENTOS ( NODO COM N)
;==============================================================
TABLE_DSPL_AC
	    ADDWF   PCL, F
	    RETLW   b'10100000'	; 0
	    RETLW   b'11111001'	; 1
	    RETLW   b'11000100'	; 2
	    RETLW   b'11010000'	; 3
	    RETLW   b'10011001'	; 4
	    RETLW   b'10010010'	; 5
	    RETLW   b'10000010'	; 6
	    RETLW   b'11111000'	; 7
	    RETLW   b'10000000'	; 8
	    RETLW   b'10011000'	; 9

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
    
;==============================================================
; RUTINAS DE TECLADO
;==============================================================

;--- Rutina Unificada para Toggle entre Modo Umbral y Medición ---
TOGGLE_MODO_DISPLAY
	    ; Invierte el bit 0 de MODO_DISPLAY (0=Medición, 1=Umbral)
	    MOVLW   .1
	    XORWF   MODO_DISPLAY, F
	    RETURN

;==============================================================
; RUTINA DE INTERRUPCI N
;==============================================================
ISR_INICIO    
	    ; Guardo contexto:
	    MOVWF   W_TEMP
	    SWAPF   STATUS, W
	    MOVWF   STATUS_TEMP

	    BTFSC   INTCON, RBIF	; Si RBIF=1 -> Voy a la rutina de ISR_TECL
	    GOTO    ISR_TECL
	    GOTO    ISR_FIN
    

ISR_TECL    
	    CLRF    NTECL              
	    MOVLW   b'01100000'		; Activa 1era fila
	    MOVWF   PORTB
	    CALL    DELAY_20ms
	    GOTO    TEST_COL

    
TEST_COL    ; Detecta columna activa
	    ; TEST_COL1:
	    BTFSS   PORTB, RB4            
	    GOTO    TECL_DELAYC1
	    INCF    NTECL,F            
    
	    ; TEST_COL2:
	    BTFSS   PORTB, RB3            
	    GOTO    TECL_DELAYC2
	    INCF    NTECL,F                      
              
	    GOTO    TEST_FIL


TEST_FIL    ; Cambia fila activa para seguir buscando tecla
	    BTFSS   PORTB, RB5            
	    GOTO    TECL_RES           
    
	    BSF     STATUS, C
	    RRF     PORTB, F            
	    CALL    DELAY_20ms		; *** DELAY DESPU S DE CAMBIAR FILA ***
	    GOTO    TEST_COL

;--------------------------------------------------------------
; Detecta qu  columna se activ  y verifica tecla
;--------------------------------------------------------------
TECL_DELAYC1
	    CALL    DELAY_20ms
	    BTFSS   PORTB, RB4             
	    GOTO    TECL_LOAD
	    GOTO    TECL_RES

TECL_DELAYC2
	    CALL    DELAY_20ms
	    BTFSS   PORTB, RB3
	    GOTO    TECL_LOAD
	    GOTO    TECL_RES
    

;--------------------------------------------------------------
; COMANDO SEG N TECLA PRESIONADA (NTECL)
;--------------------------------------------------------------
TECL_LOAD
	    ; 6 teclas: NTECL con el ID de la tecla (0 a 5)
	    MOVF    NTECL, W
	    CALL    TABLE_COMANDOS	; tabla de comandos
	    GOTO    TECL_RES		
    
;==============================================================
; TABLA DE COMANDOS DE TECLADO (JUMP TABLE)
;==============================================================
TABLE_COMANDOS
	    ADDWF   PCL, F
	    GOTO    TECLA_1_SUBIR		; NTECL = 0 (Fila 1, Col 1) - Incrementa umbral
	    GOTO    TECLA_2_BAJAR		; NTECL = 1 (Fila 1, Col 2) - Decrementa umbral
	    GOTO    TECLA_3_MODO_SLEEP		; NTECL = 2 (Fila 2, Col 1) - Sin implementar
	    GOTO    TECLA_4_TOGGLE_MODO	; NTECL = 3 (Fila 2, Col 2) - Toggle umbral/medición
	    GOTO    TECLA_5_SIN_IMPLEMENTAR	; NTECL = 4 (Fila 3, Col 1) - Sin implementar
	    GOTO    TECLA_6_SILENCIO		; NTECL = 5 (Fila 3, Col 2) - Sin implementar
    
; --- Definici n de las 6 Funciones de Tecla ---       
TECLA_1_SUBIR
SUBIR_LUZ
	    CALL    INCREMENTAR_UMBRAL
	    GOTO    TECL_RES

    
TECLA_2_BAJAR
	    ; Pregunta qu  modo est  activo
BAJAR_LUZ
	    CALL    DECREMENTAR_UMBRAL
	    GOTO    TECL_RES    
    
    
;----       
TECLA_3_MODO_SLEEP
	    ; (IMPLEMENTAR) (deja de medir)

    
;--- Tecla 4: Toggle entre Modo Umbral y Medición ---
TECLA_4_TOGGLE_MODO
	    CALL    TOGGLE_MODO_DISPLAY
	    GOTO    TECL_RES    

    
;--- Tecla 5: Sin Implementar (reservado para uso futuro) ---
TECLA_5_SIN_IMPLEMENTAR
	    ; (ESPERANDO IMPLEMENTACI N FUTURA)
	    GOTO    TECL_RES        
    
    
TECLA_6_SILENCIO
	    ; L gica para apagar el buzzer
	    ; BCF     PORT_BUZZER, PIN_BUZZER
	    GOTO    TECL_RES		; Termina y espera que se suelte la tecla
    

;--------------------------------------------------------------
; Limpieza final de interrupci n
;--------------------------------------------------------------
TECL_RES
	    ; *** ACTIVAR TODAS LAS FILAS PARA DETECTAR LIBERACI N ***
	    MOVLW   b'11100000'         ; Activa todas las filas (RB7-RB5)
	    MOVWF   PORTB
	    NOP
	    NOP
    
WAIT_RELEASE
	    MOVLW   b'00011000'
	    ANDWF   PORTB, W
	    SUBLW   b'00011000'        
	    BTFSS   STATUS, Z
	    GOTO    WAIT_RELEASE         ;(revisar)
    
	    ; --- Limpieza de flags y salida ---
	    CLRF    NTECL        
	    MOVLW   b'00000000'         ; Desactiva todas las filas
	    MOVWF   PORTB
	    NOP
	    NOP
	    MOVF    PORTB, W            ; Lectura para limpiar mismatch
	    BCF     INTCON, RBIF
	    GOTO    ISR_FIN


;--------------------------------------------------------------
; Restaura registros y sale de interrupci n
;--------------------------------------------------------------
ISR_FIN
	    SWAPF   STATUS_TEMP, W
	    MOVWF   STATUS
	    SWAPF   W_TEMP, F
	    SWAPF   W_TEMP, W
    
	    RETFIE

	    END