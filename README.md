# 🎯 TP Final Integrador - ED2
## Monitor de Ruido y Luminancia Ambiental con PIC16F887

[![Assembly](https://img.shields.io/badge/Assembly-MPASM-blue.svg)](https://microchip.com)
[![PIC](https://img.shields.io/badge/PIC16F887-Microcontroller-green.svg)](https://microchip.com)
[![Status](https://img.shields.io/badge/Status-Development-yellow.svg)](#estado-de-implementación)
[![License](https://img.shields.io/badge/License-Educational-blue.svg)](#licencia)

Sistema embebido completo para monitoreo ambiental que detecta niveles de ruido y luz ambiental, ajustando automáticamente los umbrales de ruido según sea día o noche. Implementado en **PIC16F887** con programación **Assembly MPASM**.

## 📋 Tabla de Contenidos

- [🎯 Visión del Proyecto](#️-visión-del-proyecto)
- [🏗️ Arquitectura del Sistema](#️-arquitectura-del-sistema)
- [⚙️ Especificaciones Técnicas](#️-especificaciones-técnicas)
- [🚀 Estado de Implementación](#-estado-de-implementación)
- [🔧 Requisitos de Hardware](#️-requisitos-de-hardware)
- [💻 Software y Herramientas](#️-software-y-herramientas)
- [📖 Uso del Sistema](#️-uso-del-sistema)
- [🧪 Probar el Sistema](#️-probar-el-sistema)
- [🔍 Estructura del Código](#️-estructura-del-código)
- [🛣️ Roadmap de Desarrollo](#️-roadmap-de-desarrollo)
- [📚 Documentación Adicional](#️-documentación-adicional)
- [📄 Licencia](#️-licencia)

---

## 🎯 **Visión del Proyecto**

### **Objetivo Principal**
Implementar un **"Monitor de Ruido y Luminancia Ambiental"** capaz de:

1. **Medir niveles de ruido ambiental** en decibelios (dB)
2. **Detectar condiciones de luz** para determinar día/noche
3. **Ajustar automáticamente umbrales de ruido** según el momento del día
4. **Mostrar información en displays** de 7 segmentos
5. **Controlar alarma** visual y sonora cuando se exceden límites
6. **Comunicarse con PC** vía UART para configuración y monitoreo

### **Contexto Académico**
- **Asignatura:** Sistemas Embebidos - Diseño II (ED2)
- **Proyecto:** Trabajo Final Integrador
- **Tecnología:** Microcontroladores PIC16F887
- **Metodología:** Desarrollo incremental con documentación técnica

---

## 🏗️ **Arquitectura del Sistema**

### **Diagrama de Bloques Principal**

```
┌─────────────────────────────────────────────────────────────────┐
│                    SISTEMA MONITOR AMBIENTAL                  │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐    │
│  │   SENSOR    │    │   SENSOR    │    │   SISTEMA DE    │    │
│  │   RUIDO     │    │     LUZ     │    │   CONTROL       │    │
│  │  (MAX9814)  │    │    (LDR)     │    │  (PIC16F887)    │    │
│  └─────┬───────┘    └─────┬───────┘    └─────────┬───────┘    │
│        │ ADC              │ ADC                 │          │    │
│        ▼                 ▼                    ▼          │    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                 PIC16F887 - MICROCONTROLADOR           │  │
│  │                                                         │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │  │
│  │  │   ADC       │  │   TIMER0    │  │   INTERRUPTES   │   │  │
│  │  │  (2 canales)│  │ (Muestreo)   │  │  (Teclado/DI)   │   │  │
│  │  └─────┬───────┘  └─────┬───────┘  └─────┬─────────┘   │  │
│  │        │                 │                  │          │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │                 LÓGICA DE CONTROL                │  │  │
│  │  │                                                         │  │  │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │  │  │
│  │  │  │    LÓGICA    │  │  UMBRALES    │  │    ALARMA    │ │  │  │
│  │  │  │   DÍA/NOCHE │  │  CONFIGURABLES│  │  (LED+BUZZER)│ │  │  │
│  │  │  └─────┬───────┘  └─────┬───────┘  └─────┬───────┘ │  │  │
│  │  │        │                    │                 │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │                         │                                 │        │  │
│  │  ┌─────────────────┐  ┌─────────────────┐             │  │
│  │  │   INTERFAZ     │  │   VISUALIZACIÓN  │             │  │
│  │  │    USUARIO     │  │    DISPLAYS     │             │  │
│  │  │  (Teclado 3x2) │  │ (4×7-Segmentos)  │             │  │
│  │  └─────────────────┘  └─────────────────┘             │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                           │                                 │          │
│                 ┌─────────┴─────────┐                   │          │
│                 │   COMUNICACIÓN    │                   │          │
│                 │   UART (PC)       │                   │          │
│                 └───────────────────┘                   │          │
└─────────────────────────────────────────────────────────────────┘
```

### **Flujo de Datos Principal**

```
Sensores → ADC → Procesamiento → Lógica Día/Noche → Umbrales → Control → Displays
    │           │           │                │         │         │
    │           ▼           ▼                ▼         ▼         ▼
  Ruido     0-1023     Crudo    Día/Noche    Activo    Alarma   7-Seg
  Luz      0-1023    → 0-99   →  Umbrales  →  Límite  → ON/OFF  → Nivel
```

---

## ⚙️ **Especificaciones Técnicas**

### **Hardware Principal**
- **Microcontrolador:** PIC16F887 (8KB Flash, 368B RAM, 256B EEPROM)
- **Clock:** Cristal externo de 4MHz (XT_OSC)
- **Voltaje:** 5V DC ±10%
- **Temperatura:** -40°C a +85°C

### **Periféricos Utilizados**
- **ADC:** 2 canales de 10 bits (AN0: Luz, AN1: Ruido)
- **Timer0:** Muestreo periódico (200ms)
- **PORTB:** Interrupciones por cambio (teclado)
- **PORTA:** Control de displays y alarmas
- **PORTD:** Salida de datos a displays 7-segmentos

### **Software**
- **Lenguaje:** Assembly MPASM
- **IDE:** MPLAB X + NetBeans
- **Simulador:** Proteus ISIS
- **Debugger:** Pickit 3/4

### **Timing Específico**
- **Ciclo de instrucción:** 1μs @ 4MHz
- **Muestreo ADC:** Cada 200ms
- **Multiplexación displays:** 200Hz total (5ms por display)
- **Antirrebote teclado:** 20ms
- **Refresh pantalla:** 60Hz perceptible

---

## 🚀 **Estado de Implementación**

### ✅ **Completado (100%)**
- **Sistema de Displays:** Multiplexación 4 displays 7-segmentos con buffer circular
- **Teclado Matricial:** 3×2 con detección por interrupciones y antirrebote
- **Control de Flujo:** Sistema de buffer para múltiples caracteres (A-F)
- **Documentación:** Guías técnicas completas y diagramas de flujo

### 🔄 **En Desarrollo (60%)**
- **Sistema ADC:** Configuración básica completada
- **Sensor de Luz:** Implementación LDR con divisor de tensión
- **Lógica Día/Noche:** Detección basada en umbral de luz
- **Comunicación UART:** Configuración básica establecida

### 📋 **Planificado (0%)**
- **Sensor de Ruido:** Implementación MAX9814 con rectificador
- **Sistema de Alarma:** LED + Buzzer controlado por umbrales
- **Interface PC:** Protocolo de configuración vía UART
- **Optimizaciones:** Mejoras de rendimiento y consumo

### 📊 **Progreso General**
```
███░░░░░░░░░░░░░░░░░░░░ 30% Completado
```

---

## 🔧 **Requisitos de Hardware**

### **Componentes Esenciales**
```
Microcontrolador:
├── PIC16F887 (DIP-40)
└── Cristal 4MHz + Capacitores 22pF

Sistema de Visualización:
├── 4× Displays 7-segmentos (ánodo común)
├── 4× Transistores PNP (2N3906 o similar)
├── 7× Resistencias 330Ω (segmentos)
└── 4× Resistencias 1kΩ (bases de transistores)

Sistema de Entrada:
├── Teclado matricial 3×2
├── 6× Push buttons
└── 6× Resistencias 10kΩ (pull-ups)

Sistema de Sensado:
├── Sensor LDR (fotorresistencia)
├── Resistencia 10kΩ (divisor tensión)
├── Módulo MAX9814 (micrófono + amplificador)
└── Circuito rectificador (etapa externa)

Alarma y Comunicación:
├── LED rojo 5mm
├── Buzzer pasivo 5V
├── Resistencia LED 330Ω
├── Capacitor desacopleo 100nF
└── Conector USB-UART (para PC)

Fuente de Alimentación:
├── Regulador 7805 (5V/1A)
├── Capacitores 100μF (entrada/salida)
└── Conector DC barrel jack 2.1mm
```

### **Conexiones PIC16F887**
```
PORTA (Control):
├── RA0: Entrada ADC - Sensor Luz (AN0)
├── RA1: Entrada ADC - Sensor Ruido (AN1)
├── RA2: Salida - LED Alarma
├── RA3: Salida - Display 1 (Selección)
├── RA4: Salida - Display 2 (Selección)
├── RA5: Salida - Display 3 (Selección)
└── RA6: Salida - Display 4 (Selección)

PORTB (Teclado):
├── RB0: Entrada - Teclado (configurable)
├── RB1: Entrada - Teclado (configurable)
├── RB2: Entrada - Teclado (configurable)
├── RB3: Entrada - Teclado Fila 1
├── RB4: Entrada - Teclado Fila 2
├── RB5: Entrada - Teclado Fila 3
├── RB6: Salida - Teclado Columna 1
└── RB7: Salida - Teclado Columna 2

PORTC (Comunicación):
├── RC0: Entrada/Salida - Configurable
├── RC1: Entrada/Salida - Configurable
├── RC2: Entrada/Salida - Configurable
├── RC3: Entrada/Salida - Configurable
├── RC4: Entrada/Salida - Configurable
├── RC5: Entrada/Salida - Configurable
├── RC6: Salida - UART TX
└── RC7: Entrada - UART RX

PORTD (Displays):
├── RD0: Salida - Segmento A
├── RD1: Salida - Segmento B
├── RD2: Salida - Segmento C
├── RD3: Salida - Segmento D
├── RD4: Salida - Segmento E
├── RD5: Salida - Segmento F
├── RD6: Salida - Segmento G
└── RD7: Salida - Configurable

PORTE (Control General):
├── RE0: Entrada/Salida - Configurable
├── RE1: Entrada/Salida - Configurable
├── RE2: Entrada/Salida - Configurable
└── RE3: Entrada - MCLR (Reset)
```

---

## 💻 **Software y Herramientas**

### **Software Requerido**
- **MPLAB X IDE v5.40+** - Entorno de desarrollo
- **MPASMWIN** - Ensamblador (incluido en MPLAB)
- **Proteus 8 Professional** - Simulación de circuitos
- **Pickit 3/4** - Programador y debugger

### **Plugins y Herramientas**
- **NetBeans Project Support** - Integración con MPLAB
- **Git** - Control de versiones
- **VS Code** - Editor de código (opcional)
- **RealTerm** - Terminal serial para UART

### **Estructura del Proyecto**
```
TP-final-ED2/
├── nbproject/                 # Configuración NetBeans
│   ├── project.xml          # Configuración del proyecto
│   ├── Makefile-*.mk        # Scripts de compilación
│   └── private/             # Configuración local (no en git)
├── displays + teclado/        # Archivos principales
│   ├── displays + teclado.asm  # Código fuente principal
│   ├── displays + teclado.pdsprj  # Esquema Proteus
│   └── diagrama de flujo.md    # Documentación de flujo
├── Project Backups/           # Backups automáticos (excluir de git)
└── TP5 V2.pdsprj            # Esquema Proteus principal
```

---

## 📖 **Uso del Sistema**

### **Modos de Operación**

#### **Modo 1: Standby**
- **Estado:** Sistema en reposo, consumo mínimo
- **Displays:** Apagados
- **Sensado:** Desactivado
- **Activación:** Tecla Power/Enable

#### **Modo 2: Día/Noche (Automático)**
- **Lógica:** Detección automática de día/noche basada en luz
- **Umbral ruido:** Seleccionado automáticamente
- **Configuración:** Vía UART (PC) o teclado

#### **Modo 3: Manual**
- **Lógica:** Umbrales manuales independientes
- **Configuración:** Totalmente customizable
- **Control:** Teclado dedicado

### **Funciones del Teclado (3×2)**
```
Teclado Matricial 3×2:
┌─────┬─────┬─────┐
│  B1 │  B2 │  B3 │  ← Fila 1
├─────┼─────┼─────┤
│  B4 │  B5 │  B6 │  ← Fila 2
└─────┴─────┴─────┘

Funciones:
B1: Power/Enable          → Inicia/pausa medición
B2: Mute                  → Silencia alarma sonora
B3: UP                    → Incrementa umbral
B4: DOWN                  → Decrementa umbral
B5: Focus                 → Cambia foco (ruido/luz)
B6: View                  → Cambia vista (medidos/umbrales)
```

### **Flujo de Operación Típico**
1. **Power On:** Sistema inicia en modo Standby
2. **Press B1:** Activa modo medición automático
3. **Detección:** Sistema mide luz y ruido continuamente
4. **Decisión:** Determina día/noche automáticamente
5. **Monitoreo:** Compara niveles con umbrales activos
6. **Alarma:** Activa LED/buzzer si se exceden límites
7. **Display:** Muestra valores actuales y umbrales
8. **Control:** Usuario puede ajustar parámetros via teclado

---

## 🧪 **Probar el Sistema**

### **Prueba en Simulador (Proteus)**

1. **Abrir Esquema:**
   ```
   Proteus ISIS → File → Open Project → "TP5 V2.pdsprj"
   ```

2. **Configurar Simulación:**
   ```
   System → Set Animation Options → 1ms/step
   ```

3. **Compilar y Cargar:**
   ```
   MPLAB X → Build → "Build Main Project"
   Proteus → Debug → Run Simulation
   ```

4. **Verificar Funciones:**
   - Presionar teclas virtuales
   - Observar displays 7-segmentos
   - Verificar tiempos de multiplexación
   - Testear interrupciones

### **Prueba en Hardware Real**

1. **Programar PIC:**
   ```
   Pickit 3 → MPLAB X → "Make and Program Device"
   ```

2. **Conexiones:**
   ```
   1. Verificar alimentación 5V
   2. Conectar cristal 4MHz
   3. Conectar teclado y displays
   4. Conectar LEDs de prueba
   ```

3. **Testing Básico:**
   ```
   1. Power ON → LED indicador debe encenderse
   2. Presionar B1 → Sistema debe activarse
   3. Presionar teclas → Mostrar A-F en displays
   4. Verificar multiplexación → Sin parpadeo visible
   ```

4. **Debugging:**
   ```
   - Usar osciloscopio para señales PORTA/D
   - Verificar timing con Pickit debugger
   - Medir consumo con multímetro
   ```

### **Troubleshooting Rápido**
| Síntoma | Posible Causa | Solución |
|---------|---------------|----------|
| Nada funciona | Alimentación incorrecta | Verificar 5V en VDD |
| Displays parpadean | Timing incorrecto | Ajustar delay multiplexación |
| Teclado no responde | Pull-ups no habilitados | Configurar OPTION_REG |
| ADC siempre 0 | Canal no analógico | Configurar ANSEL register |
| Se reinicia solo | Watchdog activo | Desactivar WDT en __CONFIG |

---

## 🔍 **Estructura del Código**

### **Archivo Principal: `displays + teclado.asm`**

#### **Secciones Principales**
```assembly
;====================================================================
; 1. DEFINICIONES Y CONFIGURACIÓN
;====================================================================
LIST P=16F887
#include p16f887.inc
__CONFIG _CONFIG1, _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF

;====================================================================
; 2. VARIABLES EN RAM
;====================================================================
CBLOCK 0x20
    W_TEMP           ; Contexto de interrupción
    STATUS_TEMP
    DISPLAY_BUFFER_1  ; Buffer display 1
    DISPLAY_BUFFER_2  ; Buffer display 2
    DISPLAY_BUFFER_3  ; Buffer display 3
    DISPLAY_BUFFER_4  ; Buffer display 4
    BUFFER_INDEX     ; Índice circular
    CURRENT_DIGIT    ; Display actual
    DIGIT_COUNTER    ; Contador para delays
ENDC

;====================================================================
; 3. VECTORES DE INTERRUPCIÓN
;====================================================================
ORG 0x0000
goto INICIO
ORG 0x0004
goto ISR_INICIO

;====================================================================
; 4. INICIALIZACIÓN
;====================================================================
INICIO:
    CALL CONFIG_PUERTOS
    CALL INICIALIZAR_VARIABLES
    GOTO MAIN_LOOP

;====================================================================
; 5. BUCLE PRINCIPAL
;====================================================================
MAIN_LOOP:
    CALL MULTIPLEX_DISPLAYS
    GOTO MAIN_LOOP

;====================================================================
; 6. RUTINAS DE INTERRUPCIÓN
;====================================================================
ISR_INICIO:
    ; Guardar contexto
    MOVWF W_TEMP
    SWAPF STATUS,W
    MOVWF STATUS_TEMP

    CALL PROCESAR_TECLADO

    ; Restaurar contexto
    SWAPF STATUS_TEMP,W
    MOVWF STATUS
    SWAPF W_TEMP,F
    SWAPF W_TEMP,W
    RETFIE
```

#### **Rutinas Clave**

**Multiplexación de Displays:**
```assembly
MULTIPLEX_DISPLAYS:
    ; Apagar todos los displays
    BANKSEL PORTA
    MOVLW B'11110000'
    MOVWF PORTA

    ; Seleccionar display actual
    MOVF CURRENT_DIGIT,W
    ANDLW 0x03
    BRW
    goto SHOW_1
    goto SHOW_2
    goto SHOW_3
    goto SHOW_4
```

**Detección de Teclado:**
```assembly
PROCESAR_TECLADO:
    ; Escanear teclado matricial
    CALL ESCANEAR_TECLADO
    CALL ANTIRREBOTE
    CALL MAPEAR_TECLA_A_LETRA
    CALL AGREGAR_A_BUFFER
    RETURN
```

**Tabla de 7 Segmentos (Ánodo Común):**
```assembly
TABLA_7SEG:
    ADDWF PCL
    RETLW 0xC0  ; 0
    RETLW 0xF9  ; 1
    RETLW 0xA4  ; 2
    RETLW 0xB0  ; 3
    RETLW 0x99  ; 4
    RETLW 0x92  ; 5
    RETLW 0x82  ; 6
    RETLW 0xF8  ; 7
    RETLW 0x80  ; 8
    RETLW 0x90  ; 9
    RETLW 0x88  ; A
    RETLW 0x83  ; b
    RETLW 0xC6  ; C
    RETLW 0xA1  ; d
    RETLW 0x86  ; E
    RETLW 0x8E  ; F
```

---

## 🛣️ **Roadmap de Desarrollo**

### **Fase 1: Core System** ✅ **COMPLETADO**
- [x] Displays 7-segmentos multiplexados
- [x] Teclado matricial 3×2 con interrupciones
- [x] Sistema de buffer circular para teclas
- [x] Mapeo de botones a letras A-F
- [x] Sistema de antirrebote implementado

### **Fase 2: Sensores ADC** 🔄 **EN PROGRESO**
- [x] Configuración básica ADC
- [x] Divisor de tensión para LDR
- [ ] Implementación lectura sensor luz
- [ ] Integración sensor ruido MAX9814
- [ ] Filtrado digital de lecturas
- [ ] Escalado de valores 0-99

### **Fase 3: Inteligencia de Control** 📋 **PENDIENTE**
- [ ] Lógica día/noche automática
- [ ] Umbrales configurables
- [ ] Sistema de alarma (LED + Buzzer)
- [ ] Modos de operación (automático/manual)
- [ ] Validación de límites
- [ ] Indicadores de estado

### **Fase 4: Comunicación y Configuración** 📋 **PENDIENTE**
- [ ] Interface UART con PC
- [ ] Protocolo de comandos
- [ ] Configuración remota de umbrales
- [ ] Logging de datos
- [ ] Actualización firmware vía serial
- [ ] Interface gráfica (opcional)

### **Fase 5: Optimización y Testing** 📋 **PENDIENTE**
- [ ] Optimización de consumo
- [ ] Mejoras de rendimiento
- [ ] Suite de pruebas automatizadas
- [ ] Documentación completa
- [ ] Manual de usuario
- [ ] Presentación final

### **Timeline Estimada**
```
Semana 1-2:    Completar sensores ADC
Semana 3-4:    Implementar inteligencia de control
Semana 5-6:    Desarrollar comunicación PC
Semana 7-8:    Optimización y testing final
```

---

## 📚 **Documentación Adicional**

### **Archivos de Referencia**
- **`displays + teclado.asm`** - Código fuente principal
- **`displays + teclado.pdsprj`** - Esquema Proteus completo
- **`diagrama de flujo.md`** - Diagrama de flujo del sistema
- **`TP5 V2.pdsprj`** - Esquema Proteus principal

### **Recursos Técnicos**
- **[PIC16F887 Datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/41291D.pdf)** - Hoja de datos oficial
- **[MPASM User Guide](https://ww1.microchip.com/downloads/en/DeviceDoc/33014J.pdf)** - Guía de programación
- **[Proteus User Manual](https://www.labcenter.com/)** - Simulador de circuitos

### **Skills de Claude Code**
- **`.claude/skills/pic16f887-experto/`** - Skill especializada en PIC16F887
- Guías educativas y plantillas de código
- Tutoriales paso a paso
- Debugging avanzado y troubleshooting

### **Gestión del Proyecto**
- **Linear Project:** [ED2 TPI](https://linear.app/bilby-trial-space/project/ed2-tpi-00d8eae9bd73) - Gestión de tareas
- **Git Repository:** Control de versiones del código
- **Documentation:** README.md y wikis técnicas

---

## 📄 **Licencia**

Este proyecto está desarrollado con fines educativos y académicos para la asignatura **Sistemas Embebidos - Diseño II (ED2)**.

### **Permisos:**
- ✅ Uso educativo y académico
- ✅ Modificación y aprendizaje
- ✅ Referencia y citación con crédito
- ✅ Distribución en contexto educativo

### **Restricciones:**
- ❌ Uso comercial sin autorización
- ❌ Distribución sin atribución
- ❌ Venta directa del código

### **Atribución:**
```
Proyecto ED2 TPI - Monitor Ambiental
Desarrollado por: [Tu Nombre]
Institución: [Universidad/Facultad]
Curso: Sistemas Embebidos - Diseño II
Año: 2025
```

---

## 🤝 **Contribuciones**

Este es un proyecto educativo en desarrollo. Las contribuciones son bienvenidas en formato de:

- **Bug reports** y **soluciones** implementadas
- **Mejoras de código** optimizadas
- **Documentación adicional** técnica o educativa
- **Testing** y **validación** de funcionalidades

Para contribuir, por favor crea un **issue** o **pull request** describiendo claramente:

1. **Problema** o **mejora** propuesta
2. **Solución** implementada
3. **Testing** realizado
4. **Documentación** actualizada

---

## 👥 **Contacto y Soporte**

Para consultas sobre este proyecto:

- **Issues de GitHub:** Reportar bugs o solicitar funciones
- **Claude Code:** Usar la skill `pic16f887-experto` para asistencia técnica
- **Académico:** Contactar al profesor de la cátedra ED2

---

*Última actualización: Noviembre 2025*
*Versión: 1.0.0*
*Estado: Development*