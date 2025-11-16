# 🚀 Instrucciones de Uso - Contador Serial

## 📋 **Resumen del Programa**
Este programa implementa un contador que se incrementa cada vez que se presiona un botón conectado al pin RB0 del PIC16F887. El valor actual del contador se muestra en tiempo real a través de comunicación UART a 9600 baudios.

## 🔧 **Configuración del Hardware**

### **Componentes Necesarios:**
- PIC16F887
- Cristal de 4MHz + 2 capacitores de 22pF
- Pulsador normalmente abierto
- Resistencia pull-up de 10kΩ
- Módulo COMPIM (Proteus) o MAX232 (hardware real)

### **Conexiones Principales:**
- **RB0 (Pin 33):** Botón con pull-up a +5V
- **RC6 (Pin 25):** TX de UART
- **RC7 (Pin 26):** RX de UART
- **Cristal:** OSC1 y OSC2 (Pines 13-14)

## 💻 **Configuración del Software**

### **En MPLAB X:**
1. Crear nuevo proyecto
2. Seleccionar PIC16F887
3. Configurar palabra de configuración:
   ```
   _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF
   ```

### **En Proteus ISIS:**
1. Montar circuito según diagrama
2. Configurar COMPIM:
   - Puerto: COM1 (o disponible)
   - Baud Rate: 9600
   - Data: 8 bits
   - Parity: None
   - Stop: 1 bit

## 🖥️ **Configuración del Terminal**

### **Opción 1 - Virtual Terminal (Proteus):**
1. Agregar componente "VIRTUAL TERMINAL"
2. Conectar a COMPIM
3. Configurar: 9600, 8N1

### **Opción 2 - Terminal PC (Putty/HyperTerminal):**
1. Abrir terminal serial
2. Seleccionar puerto COM configurado
3. Configurar: 9600, 8N1, sin control de flujo

## 🚀 **Ejecución**

### **Paso 1: Compilar el Código**
```bash
mpasmwin.exe serie.asm
```

### **Paso 2: Cargar en Proteus**
1. Editar propiedades del PIC16F887
2. Seleccionar archivo .hex generado
3. Aceptar y cerrar

### **Paso 3: Iniciar Simulación**
1. Presionar "Play" en Proteus
2. Abrir terminal (Virtual o PC)
3. Ver mensaje de bienvenida

### **Paso 4: Probar Funcionalidad**
1. Presionar el botón conectado a RB0
2. Observar el contador incrementarse
3. Cada presión genera nueva línea en terminal

## 📊 **Salida Esperada**

```
Sistema Contador Serial - PIC16F887
Presione el boton en RB0 para incrementar
----------------------------------------
Contador: 000
Contador: 001
Contador: 002
Contador: 003
...
```

## ⚙️ **Características del Programa**

### **Funcionalidades:**
- ✅ Contador de 0-255 con ciclo automático
- ✅ Detección de flanco de bajada en RB0
- ✅ Antirrebote por software (20ms)
- ✅ Transmisión UART a 9600 baudios
- ✅ Formato de salida legible
- ✅ Mensajes de bienvenida

### **Protección:**
- ✅ Manejo de contexto en interrupciones
- ✅ Antirrebote doble (al presionar y soltar)
- ✅ Verificación de estado del botón
- ✅ Ciclo automático del contador (255→0)

## 🐛 **Solución de Problemas**

### **No aparece texto en terminal:**
1. Verificar conexiones TX/RX (deben estar cruzadas)
2. Confirmar configuración 9600-8N1
3. Revisar que cristal de 4MHz esté conectado

### **Contador no se incrementa:**
1. Verificar conexión del botón en RB0
2. Confirmar resistencia pull-up de 10kΩ
3. Revisar que el botón funcione correctamente

### **Contador se incrementa solo:**
1. Revisar antirrebote (aumentar delay si es necesario)
2. Verificar que el botón no tenga falso contacto
3. Confirmar que RB0 esté como entrada digital

### **Caracteres extraños:**
1. Verificar baud rate en terminal
2. Confirmar configuración de bits de datos
3. Revisar conexión a tierra común

## 📝 **Modificaciones Posibles**

### **Cambiar Baud Rate:**
Modificar el valor en SPBRG:
- 2400 baud: SPBRG = 103
- 4800 baud: SPBRG = 51
- 19200 baud: SPBRG = 12

### **Cambiar Pin del Botón:**
- Modificar TRISB para habilitar pull-ups
- Cambiar de INT (RB0) a RBIF (RB4-RB7)
- Ajustar rutina de interrupción

### **Añadir Funcionalidades:**
- Botón para decrementar contador
- Envío periódico automático
- Comandos por terminal para reset/ajuste

## 📚 **Referencias**
- [Datasheet PIC16F887](https://ww1.microchip.com/downloads/en/DeviceDoc/41291D.pdf)
- [Manual UART PIC16F](https://ww1.microchip.com/downloads/en/AppNotes/00907B.pdf)
- [Documentación del Proyecto ED2](../README.md)

---

**Nota:** Este programa fue diseñado siguiendo los patrones de código del proyecto ED2 y mantiene coherencia con el estilo de programación utilizado en los módulos existentes.