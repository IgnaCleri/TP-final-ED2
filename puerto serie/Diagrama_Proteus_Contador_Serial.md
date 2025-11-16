# 📋 Diagrama de Conexiones Proteus - Contador Serial con Botón

## 🎯 **Descripción del Circuito**
Circuito para demostrar un contador que se incrementa por cada presión de un botón conectado a RB0 y muestra el valor por terminal serie (UART).

---

## 🔧 **Componentes Necesarios**

### **Componentes Principales**
1. **PIC16F887** - Microcontrolador principal
2. **Crystal Oscillator** - 4MHz
3. **Capacitores** - 22pF (2 unidades)
4. **Push Button** - Pulsador para RB0
5. **Resistor Pull-up** - 10kΩ para RB0
6. **COMPIM** - Módulo de comunicación serie virtual
7. **VIRTUAL TERMINAL** - Terminal para visualización

### **Componentes Opcionales (si se requiere conversión de nivel)**
8. **MAX232** - Convertidor de nivel TTL a RS232
9. **Capacitores** - 1µF o 10µF (4-5 unidades para MAX232)

---

## 🔌 **Conexiones del PIC16F887**

### **Alimentación y Clock**
```
PIC16F887                    Componentes
─────────────────────────────────────────────────────────────
VDD (Pin 11, 32) ──────────── +5V
VSS (Pin 12, 31) ──────────── GND
OSC1 (Pin 13) ───────────────┬── Crystal 4MHz ───┐
OSC2 (Pin 14) ───────────────┘                ├── 22pF ── GND
                                         │
                                         └── 22pF ── GND
```

### **Botón en RB0**
```
PIC16F887                    Componentes
─────────────────────────────────────────────────────────────
RB0/INT (Pin 33) ────────────┬── Push Button ─── GND
                              │
                              └── 10kΩ ── +5V
```

### **Conexiones UART**
```
PIC16F887                    Componentes
─────────────────────────────────────────────────────────────
RC6/TX (Pin 25) ─────────────┬── RXD de COMPIM
RC7/RX (Pin 26) ─────────────┘── TXD de COMPIM

Si usa MAX232:
RC6/TX (Pin 25) ───────────── T1IN de MAX232
RC7/RX (Pin 26) ───────────── R1OUT de MAX232

MAX232 ── RS232 ── COMPIM
```

### **COMPIM (Virtual Serial Port)**
```
COMPIM                       Conexiones
─────────────────────────────────────────────────────────────
RXD  ─────────────────────── RC6/TX del PIC
TXD  ─────────────────────── RC7/RX del PIC
CTS  ─────────────────────── RTS (puente si es necesario)
RTS  ─────────────────────── CTS (puente si es necesario)
GND  ─────────────────────── GND común
```

---

## 🖥️ **Configuración en Proteus**

### **1. Configurar el PIC16F887**
- **Processor Clock:** 4MHz
- **Configuration Word:**
  ```
  _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF
  ```

### **2. Configurar COMPIM**
- **Physical Port:** COM1 (o el que prefieras)
- **Baud Rate:** 9600
- **Data Bits:** 8
- **Parity:** None
- **Stop Bits:** 1

### **3. Configurar Virtual Terminal**
- **Baud Rate:** 9600
- **Data Bits:** 8
- **Parity:** None
- **Stop Bits:** 1

---

## 📊 **Diagrama Completo (Representación ASCII)**

```
                    +5V
                     │
         ┌───────────┴───────────┐
         │                       │
        10kΩ                  +5V
         │                       │
RB0 ─────┴───────┐         ┌────┴────┐
(Pin 33)          │         │  VDD    │
                  │         │ (Pin 11)│
         ┌────────┴─┐       │         │
         │   PUSH    │       │         │
         │  BUTTON   │       │         │
         └────┬──────┘       │   PIC   │
              │            │  16F887 │
             GND           │         │
                           │         │
RC6 ───────────────────────│         │
(TX) (Pin 25)              │         │
                           │         │
RC7 ───────────────────────│         │
(RX) (Pin 26)              │         │
                           │         │
          Crystal 4MHz     │         │
     OSC1 ────┬───────┐    │         │
     (Pin 13) │       │    │         │
               │       │    │         │
     OSC2 ────┴───────┘    │         │
     (Pin 14)              │         │
                           │         │
          22pF   22pF      │         │
            │      │       │         │
           GND    GND      │         │
                           └────┬────┘
                                │
                               GND
                               (Pin 12)

UART Interface:
RC6 (TX) ──────────────┐
                      │
                     ┌┴┐
                     │ │  COMPIM
                     └┬┘
                      │
RC7 (RX) ──────────────┘

Virtual Terminal:
RXD ──────────────────── TXD de COMPIM
GND ──────────────────── GND común
```

---

## 🖥️ **Configuración del Terminal en PC**

### **Opción 1: Virtual Terminal de Proteus**
1. Agregar "VIRTUAL TERMINAL" al diseño
2. Conectar:
   - RXD del Terminal ←→ TXD de COMPIM
   - GND del Terminal ←→ GND común

### **Opción 2: Terminal Real (HyperTerminal, Putty, etc.)**
1. Configurar el puerto COM seleccionado en COMPIM
2. **Configuración:**
   - Baud Rate: 9600
   - Data Bits: 8
   - Parity: None
   - Stop Bits: 1
   - Flow Control: None

---

## 🚀 **Simulación y Prueba**

### **Pasos para Simular:**
1. **Montar el circuito** en Proteus ISIS
2. **Cargar el programa** serie.asm en el PIC16F887
3. **Iniciar la simulación**
4. **Abrir el terminal** (Virtual Terminal o terminal PC)
5. **Presionar el botón** conectado a RB0
6. **Observar el contador** incrementándose en el terminal

### **Salida Esperada:**
```
Sistema Contador Serial - PIC16F887
Presione el boton en RB0 para incrementar
----------------------------------------
Contador: 000
Contador: 001
Contador: 002
...
```

---

## 🔧 **Troubleshooting**

### **Problemas Comunes:**

1. **No se muestra nada en el terminal:**
   - Verificar conexiones TX/RX (deben estar cruzadas)
   - Confirmar configuración de baud rate (9600)
   - Verificar que el cristal de 4MHz esté conectado

2. **Caracteres extraños en el terminal:**
   - Revisar configuración de baud rate
   - Verificar configuración de bits de datos/paridad/stop

3. **El contador no se incrementa:**
   - Verificar conexión del botón en RB0
   - Confirmar resistor pull-up de 10kΩ
   - Revisar configuración de interrupciones

4. **El contador se incrementa solo:**
   - Aumentar el tiempo de antirrebote (DELAY_20ms)
   - Verificar que el botón no tenga falso contacto

---

## 📁 **Archivos Relacionados**
- **Código fuente:** `serie.asm`
- **Proyecto Proteus:** Crear nuevo archivo .pdsprj
- **Documentación:** Este archivo markdown

---

**Nota:** Para una mejor experiencia, se recomienda usar el Virtual Terminal de Proteus para depuración, ya que es más fácil de configurar y no requiere configuración de puertos COM del sistema.