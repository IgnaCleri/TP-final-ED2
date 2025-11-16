# 🔧 Guía de Solución de Problemas - Baud Rate UART

## 📊 **Tabla de Configuraciones para 4MHz**

| Baud Rate | SPBRG | BRGH | Error | Error % |
|-----------|-------|------|-------|---------|
| 2400      | 103   | 1    | 2399   | 0.04%   |
| 4800      | 51    | 1    | 4808   | 0.16%   |
| 9600      | 25    | 1    | 9615   | 0.16%   |
| 19200     | 12    | 1    | 19231  | 0.16%   |

## 🎯 **Pasos para Solucionar Problemas de Baud Rate**

### **Paso 1: Verificar la Configuración Actual**
El código viene configurado por defecto para **9600 baud** con:
- **SPBRG = 25**
- **BRGH = 1** (High Speed)

### **Paso 2: Configurar la Terminal Correctamente**

#### **En Proteus Virtual Terminal:**
1. **Baud Rate:** 9600
2. **Data Bits:** 8
3. **Parity:** None
4. **Stop Bits:** 1

#### **En Terminal Real (Putty/HyperTerminal):**
1. **Speed:** 9600
2. **Data bits:** 8
3. **Parity:** None
4. **Stop bits:** 1
5. **Flow control:** None

### **Paso 3: Si 9600 no funciona, prueba estas opciones:**

#### **Opción A: Cambiar a 4800 baud**
1. **Modifica el código:** comenta la línea 117 y descomenta 122
2. **Configura terminal:** 4800 baud
3. **Ventaja:** Más tolerante a errores de sincronización

#### **Opción B: Cambiar a 19200 baud**
1. **Modifica el código:** comenta la línea 117 y descomenta 127
2. **Configura terminal:** 19200 baud
3. **Ventaja:** Transmisión más rápida

#### **Opción C: Cambiar a 2400 baud**
1. **Modifica el código:** comenta la línea 117 y descomenta 132
2. **Configura terminal:** 2400 baud
3. **Ventaja:** Muy estable, casi sin errores

## 🔍 **Síntomas de Problemas de Baud Rate**

### **Caracteres Extraños:**
- **Causa:** Baud rate incorrecto
- **Solución:** Ajustar terminal o cambiar SPBRG

### **Caracteres Incompletos:**
- **Causa:** Baud rate muy diferente
- **Solución:** Verificar configuración exacta

### **Sin caracteres:**
- **Causa:** Baud rate muy alejado del correcto
- **Solución:** Probar todas las velocidades

## 🛠️ **Cómo Cambiar el Baud Rate en el Código**

### **Para 9600 baud (actual):**
```assembly
; OPCI�N 1: 9600 baud (RECOMENDADO)
BANKSEL SPBRG
MOVLW   D'25'          ; SPBRG = 25
MOVWF   SPBRG
```

### **Para 4800 baud:**
```assembly
; OPCI�N 2: 4800 baud
BANKSEL SPBRG
MOVLW   D'51'          ; SPBRG = 51
MOVWF   SPBRG
```

### **Para 19200 baud:**
```assembly
; OPCI�N 3: 19200 baud
BANKSEL SPBRG
MOVLW   D'12'          ; SPBRG = 12
MOVWF   SPBRG
```

### **Para 2400 baud:**
```assembly
; OPCI�N 4: 2400 baud
BANKSEL SPBRG
MOVLW   D'103'         ; SPBRG = 103
MOVWF   SPBRG
```

## ⚡ **Recomendación de Prueba**

### **Orden Sugerido:**
1. **9600 baud** - Más estándar y recomendado
2. **4800 baud** - Si 9600 da problemas
3. **19200 baud** - Para mayor velocidad
4. **2400 baud** - Como última opción

### **Verificación:**
Después de cada cambio:
1. **Compila el código**
2. **Carga en Proteus**
3. **Configura la terminal**
4. **Presiona el botón**
5. **Observa la salida**

## 📋 **Configuración en Proteus**

### **COMPIM:**
- **Physical Port:** COM1 (o el que uses)
- **Baud Rate:** Debe coincidir con el código
- **Data Bits:** 8
- **Parity:** None
- **Stop Bits:** 1

### **VIRTUAL TERMINAL:**
- **Baud Rate:** Debe coincidir con COMPIM
- **Data Bits:** 8
- **Parity:** None
- **Stop Bits:** 1

## 🐛 **Problemas Comunes Adicionales**

### **Clock Incorrecto:**
- **Verificar:** Cristal de 4MHz conectado correctamente
- **Síntomas:** Todos los baud rates aparecen incorrectos

### **Conexiones TX/RX:**
- **Verificar:** TX del PIC → RX del COMPIM
- **Verificar:** RX del PIC → TX del COMPIM
- **Síntomas:** Sin comunicación o caracteres invertidos

### **Tierra Común:**
- **Verificar:** GND del PIC conectado a GND del COMPIM
- **Síntomas:** Comunicación errática o nula

---

**Nota:** La configuración de 9600 baud con SPBRG=25 y BRGH=1 es la más estándar y debería funcionar en el 99% de los casos si el resto del hardware está conectado correctamente.