graph TD
    subgraph "Flujo Principal (General)"
        Z1[Directivas de Inclusión] --> Z2[Configuración General]
        Z2 --> Z3[Definición de Variables]
        Z3 --> Z4[Declaración de Macros para Configuración de Registros]
        Z4 --> Z5[Inicialización de Registros]
        Z5 --> Z6(Programa Principal)
        Z6 --> Z7(( ))
        Z7 --> Z8[REFRESH_DSPL]
        Z8 --> Z7
    end

    subgraph "ISR (Rutina de Interrupción)"
        A(ISR_INICIO) --> B[Guardado Contexto: STATUS, W]
        B --> C{RBIF = 1?}
        C -->|SI| D[ISR_TECL]
        C -->|NO| E[ISR_FIN]
        
        E --> F[Restauración Contexto: STATUS, W]
        F --> G(RETFIE)
        
        D --> H[TECL_PRESS]
    end

    subgraph "Manejo de Tecla Presionada"
        H[TECL_PRESS] --> J[NTECL = 0]
        J --> K[PORTB = 01111000]
        K --> L[Estabilización Señal NOP]
        L --> M[TEST_COL]
    end

    subgraph "Testeo de Columnas (TEST_COL)"
        direction LR
        M[TEST_COL] --> M1(TEST_COL1)
        M1 --> M2[NTECL++]
        M2 --> M3{RB3 = 1?}
        M3 -->|NO| TD[TECL_DELAY]
        M3 -->|SI| M4(TEST_COL2)
        M4 --> M5[NTECL++]
        M5 --> M6{RB2 = 1?}
        M6 -->|NO| TD
        M6 -->|SI| M7(TEST_COL3)
        
        M7 --> M8[NTECL++]
        M8 --> M9{RB1 = 1?}
        M9 -->|NO| TD
        M9 -->|SI| M10(TEST_COL4)
        M10 --> M11[NTECL++]
        M11 --> M12{RB0 = 1?}
        M12 -->|NO| TD
        M12 -->|SI| TF[TEST_FIL]
    end

    subgraph "Testeo de Fila (TEST_FIL)"
        TF[TEST_FIL] --> TF1{RB4 = 0?}
        TF1 -->|SI| TR[TECL_RST]
        TF1 -->|NO| TF2[C = 1]
        TF2 --> TF3[RRF PORTB]
        TF3 --> M
    end

    subgraph "Reset de Tecla (TECL_RST)"
        TR[TECL_RST] --> TR1[NTECL = 0]
        TR1 --> TR2[RBIF = 0]
        TR2 --> TR3[PORTB = 0]
        TR3 --> TR4[RETURN]
    end

    subgraph "Delay de Tecla (TECL_DELAY)"
        TD[TECL_DELAY] --> TD1(( ))
        TD1 --> TD2{RB3 = 1?}
        TD2 -->|NO| TD1
        TD2 -->|SI| TD3(( ))
        TD3 --> TD4{RB2 = 1?}
        TD4 -->|NO| TD3
        TD4 -->|SI| TD5(( ))
        
        TD5 --> TD6{RB1 = 1?}
        TD6 -->|NO| TD5
        TD6 -->|SI| TD7(( ))
        TD7 --> TD8{RB0 = 1?}
        TD8 -->|NO| TD7
        TD8 -->|SI| TD9[RBIF = 0]
        TD9 --> TD10[PORTB = 0]
        TD10 --> TD11[RETURN]
    end

    subgraph "Carga de Tecla (TECL_LOAD)"
        TL[TECL_LOAD] --> TL1[W = 3]
        TL1 --> TL2[CONT_NTECL - W]
        TL2 --> TL3{Z = 1?}
        TL3 -->|SI| LDT3[LOAD_TECL3]
        TL3 -->|NO| TL4[W = 2]
        TL4 --> TL5[CONT_NTECL - W]
        TL5 --> TL6{Z = 1?}
        TL6 -->|SI| LDT2[LOAD_TECL2]
        TL6 -->|NO| LDT1[LOAD_TECL1]
        
        LDT1 --> TL7[NTECL -> W]
        TL7 --> TL8[W -> NTECL1]
        TL8 --> TL9[RETURN]
    end

    subgraph "Flujo Adicional (Derecha, Img 3)"
        X1[W = 1] --> X2[CONT_NTECL - W]
        X2 --> X3{Z = 1?}
        X3 -->|SI| LDT1
        X3 -->|NO| X4[CONT_NTECL -]
        X4 --> X5{CONT_NTECL - W = 0?}
        X5 -->|SI| X6[CONT_NTECL = 3]
        X5 -->|NO| E
    end