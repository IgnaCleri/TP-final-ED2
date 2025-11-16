;==============================================================
; TABLA DE CONVERSI N ADC ’ LUX
; Fórmula: Lux = (24.662 * V³) + (104.742 * V²) + (156.987 * V) + 7.158
; Voltaje = ADC * 5.0 / 255.0
;==============================================================

;==============================================================
; RUTINA DE CONVERSI N ADC ’ LUX
; Entrada: W = valor ADC (0-255)
; Salida: LUX_RESULT_H:LUX_RESULT_L = valor en lux (0-9999)
;==============================================================

CONVERTIR_ADC_A_LUX
    ; Guardar valor ADC para usar en ambas tablas
    MOVWF   ADC_TEMP

    ; Obtener parte alta del valor de lux
    MOVF    ADC_TEMP, W
    CALL    LUX_TABLE_H       ; Salto indexado a tabla alta
    MOVWF   LUX_RESULT_H      ; Guardar parte alta

    ; Obtener parte baja del valor de lux
    MOVF    ADC_TEMP, W
    CALL    LUX_TABLE_L       ; Salto indexado a tabla baja
    MOVWF   LUX_RESULT_L      ; Guardar parte baja

    RETURN

;==============================================================
; VARIABLES PARA CONVERSI N
;==============================================================
ADC_TEMP        EQU     0x70    ; Temporal para valor ADC
LUX_RESULT_H    EQU     0x71    ; Resultado parte alta
LUX_RESULT_L    EQU     0x72    ; Resultado parte baja

;==============================================================
; TABLA PARTE ALTA - LUX_TABLE_H
; Cada entrada es la parte alta del valor 0-9999
;==============================================================
LUX_TABLE_H
    RETLW   0x00    ; ADC=0  ’   7 lux
    RETLW   0x00    ; ADC=1  ’  12 lux
    RETLW   0x00    ; ADC=2  ’  18 lux
    RETLW   0x00    ; ADC=3  ’  24 lux
    RETLW   0x00    ; ADC=4  ’  31 lux
    RETLW   0x00    ; ADC=5  ’  38 lux
    RETLW   0x00    ; ADC=6  ’  46 lux
    RETLW   0x00    ; ADC=7  ’  54 lux
    RETLW   0x00    ; ADC=8  ’  62 lux
    RETLW   0x00    ; ADC=9  ’  71 lux
    RETLW   0x00    ; ADC=10 ’  80 lux
    RETLW   0x00    ; ADC=11 ’  90 lux
    RETLW   0x00    ; ADC=12 ’ 100 lux
    RETLW   0x00    ; ADC=13 ’ 111 lux
    RETLW   0x00    ; ADC=14 ’ 122 lux
    RETLW   0x00    ; ADC=15 ’ 134 lux

    ; 16-31
    RETLW   0x00    ; ADC=16 ’ 146 lux
    RETLW   0x00    ; ADC=17 ’ 159 lux
    RETLW   0x00    ; ADC=18 ’ 172 lux
    RETLW   0x00    ; ADC=19 ’ 186 lux
    RETLW   0x00    ; ADC=20 ’ 200 lux
    RETLW   0x00    ; ADC=21 ’ 215 lux
    RETLW   0x00    ; ADC=22 ’ 230 lux
    RETLW   0x00    ; ADC=23 ’ 246 lux
    RETLW   0x00    ; ADC=24 ’ 262 lux
    RETLW   0x01    ; ADC=25 ’ 279 lux
    RETLW   0x01    ; ADC=26 ’ 296 lux
    RETLW   0x01    ; ADC=27 ’ 314 lux
    RETLW   0x01    ; ADC=28 ’ 332 lux
    RETLW   0x01    ; ADC=29 ’ 351 lux
    RETLW   0x01    ; ADC=30 ’ 370 lux
    RETLW   0x01    ; ADC=31 ’ 390 lux

    ; 32-47
    RETLW   0x01    ; ADC=32 ’ 410 lux
    RETLW   0x01    ; ADC=33 ’ 431 lux
    RETLW   0x01    ; ADC=34 ’ 452 lux
    RETLW   0x01    ; ADC=35 ’ 474 lux
    RETLW   0x01    ; ADC=36 ’ 496 lux
    RETLW   0x02    ; ADC=37 ’ 519 lux
    RETLW   0x02    ; ADC=38 ’ 542 lux
    RETLW   0x02    ; ADC=39 ’ 566 lux
    RETLW   0x02    ; ADC=40 ’ 590 lux
    RETLW   0x02    ; ADC=41 ’ 615 lux
    RETLW   0x02    ; ADC=42 ’ 640 lux
    RETLW   0x02    ; ADC=43 ’ 666 lux
    RETLW   0x02    ; ADC=44 ’ 692 lux
    RETLW   0x02    ; ADC=45 ’ 719 lux
    RETLW   0x02    ; ADC=46 ’ 746 lux
    RETLW   0x03    ; ADC=47 ’ 774 lux

    ; 48-63
    RETLW   0x03    ; ADC=48 ’ 802 lux
    RETLW   0x03    ; ADC=49 ’ 831 lux
    RETLW   0x03    ; ADC=50 ’ 860 lux
    RETLW   0x03    ; ADC=51 ’ 889 lux
    RETLW   0x03    ; ADC=52 ’ 919 lux
    RETLW   0x03    ; ADC=53 ’ 950 lux
    RETLW   0x03    ; ADC=54 ’ 981 lux
    RETLW   0x03    ; ADC=55 ’ 1013 lux
    RETLW   0x04    ; ADC=56 ’ 1045 lux
    RETLW   0x04    ; ADC=57 ’ 1078 lux
    RETLW   0x04    ; ADC=58 ’ 1111 lux
    RETLW   0x04    ; ADC=59 ’ 1145 lux
    RETLW   0x04    ; ADC=60 ’ 1179 lux
    RETLW   0x04    ; ADC=61 ’ 1214 lux
    RETLW   0x04    ; ADC=62 ’ 1250 lux
    RETLW   0x05    ; ADC=63 ’ 1286 lux

    ; 64-79
    RETLW   0x05    ; ADC=64 ’ 1323 lux
    RETLW   0x05    ; ADC=65 ’ 1360 lux
    RETLW   0x05    ; ADC=66 ’ 1398 lux
    RETLW   0x05    ; ADC=67 ’ 1437 lux
    RETLW   0x05    ; ADC=68 ’ 1476 lux
    RETLW   0x05    ; ADC=69 ’ 1516 lux
    RETLW   0x06    ; ADC=70 ’ 1557 lux
    RETLW   0x06    ; ADC=71 ’ 1598 lux
    RETLW   0x06    ; ADC=72 ’ 1640 lux
    RETLW   0x06    ; ADC=73 ’ 1683 lux
    RETLW   0x06    ; ADC=74 ’ 1726 lux
    RETLW   0x06    ; ADC=75 ’ 1770 lux
    RETLW   0x07    ; ADC=76 ’ 1815 lux
    RETLW   0x07    ; ADC=77 ’ 1860 lux
    RETLW   0x07    ; ADC=78 ’ 1906 lux
    RETLW   0x07    ; ADC=79 ’ 1953 lux

    ; 80-95
    RETLW   0x07    ; ADC=80 ’ 2000 lux
    RETLW   0x07    ; ADC=81 ’ 2048 lux
    RETLW   0x08    ; ADC=82 ’ 2096 lux
    RETLW   0x08    ; ADC=83 ’ 2145 lux
    RETLW   0x08    ; ADC=84 ’ 2195 lux
    RETLW   0x08    ; ADC=85 ’ 2245 lux
    RETLW   0x08    ; ADC=86 ’ 2296 lux
    RETLW   0x09    ; ADC=87 ’ 2348 lux
    RETLW   0x09    ; ADC=88 ’ 2401 lux
    RETLW   0x09    ; ADC=89 ’ 2454 lux
    RETLW   0x09    ; ADC=90 ’ 2508 lux
    RETLW   0x09    ; ADC=91 ’ 2563 lux
    RETLW   0x0A    ; ADC=92 ’ 2618 lux
    RETLW   0x0A    ; ADC=93 ’ 2674 lux
    RETLW   0x0A    ; ADC=94 ’ 2731 lux
    RETLW   0x0A    ; ADC=95 ’ 2788 lux

    ; 96-111
    RETLW   0x0A    ; ADC=96 ’ 2846 lux
    RETLW   0x0B    ; ADC=97 ’ 2905 lux
    RETLW   0x0B    ; ADC=98 ’ 2964 lux
    RETLW   0x0B    ; ADC=99 ’ 3024 lux
    RETLW   0x0B    ; ADC=100 ’ 3085 lux
    RETLW   0x0C    ; ADC=101 ’ 3146 lux
    RETLW   0x0C    ; ADC=102 ’ 3208 lux
    RETLW   0x0C    ; ADC=103 ’ 3271 lux
    RETLW   0x0C    ; ADC=104 ’ 3334 lux
    RETLW   0x0D    ; ADC=105 ’ 3398 lux
    RETLW   0x0D    ; ADC=106 ’ 3463 lux
    RETLW   0x0D    ; ADC=107 ’ 3528 lux
    RETLW   0x0D    ; ADC=108 ’ 3594 lux
    RETLW   0x0E    ; ADC=109 ’ 3661 lux
    RETLW   0x0E    ; ADC=110 ’ 3728 lux
    RETLW   0x0E    ; ADC=111 ’ 3796 lux

    ; 112-127
    RETLW   0x0E    ; ADC=112 ’ 3865 lux
    RETLW   0x0F    ; ADC=113 ’ 3934 lux
    RETLW   0x0F    ; ADC=114 ’ 4004 lux
    RETLW   0x0F    ; ADC=115 ’ 4075 lux
    RETLW   0x10    ; ADC=116 ’ 4146 lux
    RETLW   0x10    ; ADC=117 ’ 4218 lux
    RETLW   0x10    ; ADC=118 ’ 4291 lux
    RETLW   0x11    ; ADC=119 ’ 4364 lux
    RETLW   0x11    ; ADC=120 ’ 4438 lux
    RETLW   0x11    ; ADC=121 ’ 4513 lux
    RETLW   0x11    ; ADC=122 ’ 4588 lux
    RETLW   0x11    ; ADC=123 ’ 4664 lux
    RETLW   0x12    ; ADC=124 ’ 4740 lux
    RETLW   0x12    ; ADC=125 ’ 4817 lux
    RETLW   0x12    ; ADC=126 ’ 4895 lux
    RETLW   0x13    ; ADC=127 ’ 4973 lux

    ; 128-143
    RETLW   0x13    ; ADC=128 ’ 5052 lux
    RETLW   0x13    ; ADC=129 ’ 5131 lux
    RETLW   0x14    ; ADC=130 ’ 5211 lux
    RETLW   0x14    ; ADC=131 ’ 5292 lux
    RETLW   0x14    ; ADC=132 ’ 5373 lux
    RETLW   0x14    ; ADC=133 ’ 5455 lux
    RETLW   0x15    ; ADC=134 ’ 5538 lux
    RETLW   0x15    ; ADC=135 ’ 5621 lux
    RETLW   0x15    ; ADC=136 ’ 5705 lux
    RETLW   0x16    ; ADC=137 ’ 5790 lux
    RETLW   0x16    ; ADC=138 ’ 5875 lux
    RETLW   0x16    ; ADC=139 ’ 5961 lux
    RETLW   0x17    ; ADC=140 ’ 6047 lux
    RETLW   0x17    ; ADC=141 ’ 6134 lux
    RETLW   0x18    ; ADC=142 ’ 6222 lux
    RETLW   0x18    ; ADC=143 ’ 6310 lux

    ; 144-159
    RETLW   0x18    ; ADC=144 ’ 6399 lux
    RETLW   0x19    ; ADC=145 ’ 6489 lux
    RETLW   0x19    ; ADC=146 ’ 6579 lux
    RETLW   0x19    ; ADC=147 ’ 6670 lux
    RETLW   0x1A    ; ADC=148 ’ 6762 lux
    RETLW   0x1A    ; ADC=149 ’ 6854 lux
    RETLW   0x1A    ; ADC=150 ’ 6947 lux
    RETLW   0x1B    ; ADC=151 ’ 7041 lux
    RETLW   0x1B    ; ADC=152 ’ 7135 lux
    RETLW   0x1C    ; ADC=153 ’ 7230 lux
    RETLW   0x1C    ; ADC=154 ’ 7326 lux
    RETLW   0x1C    ; ADC=155 ’ 7422 lux
    RETLW   0x1D    ; ADC=156 ’ 7519 lux
    RETLW   0x1D    ; ADC=157 ’ 7617 lux
    RETLW   0x1D    ; ADC=158 ’ 7715 lux
    RETLW   0x1E    ; ADC=159 ’ 7814 lux

    ; 160-175
    RETLW   0x1E    ; ADC=160 ’ 7914 lux
    RETLW   0x1F    ; ADC=161 ’ 8014 lux
    RETLW   0x1F    ; ADC=162 ’ 8115 lux
    RETLW   0x20    ; ADC=163 ’ 8217 lux
    RETLW   0x20    ; ADC=164 ’ 8319 lux
    RETLW   0x20    ; ADC=165 ’ 8422 lux
    RETLW   0x21    ; ADC=166 ’ 8526 lux
    RETLW   0x21    ; ADC=167 ’ 8630 lux
    RETLW   0x22    ; ADC=168 ’ 8735 lux
    RETLW   0x22    ; ADC=169 ’ 8841 lux
    RETLW   0x23    ; ADC=170 ’ 8947 lux
    RETLW   0x23    ; ADC=171 ’ 9054 lux
    RETLW   0x23    ; ADC=172 ’ 9162 lux
    RETLW   0x24    ; ADC=173 ’ 9270 lux
    RETLW   0x24    ; ADC=174 ’ 9379 lux
    RETLW   0x25    ; ADC=175 ’ 9489 lux

    ; 176-191
    RETLW   0x25    ; ADC=176 ’ 9599 lux
    RETLW   0x26    ; ADC=177 ’ 9710 lux
    RETLW   0x26    ; ADC=178 ’ 9822 lux
    RETLW   0x26    ; ADC=179 ’ 9934 lux
    RETLW   0x27    ; ADC=180 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=181 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=182 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=183 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=184 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=185 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=186 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=187 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=188 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=189 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=190 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=191 ’ 9999 lux (Saturado)

    ; 192-207
    RETLW   0x27    ; ADC=192 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=193 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=194 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=195 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=196 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=197 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=198 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=199 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=200 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=201 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=202 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=203 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=204 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=205 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=206 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=207 ’ 9999 lux (Saturado)

    ; 208-223
    RETLW   0x27    ; ADC=208 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=209 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=210 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=211 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=212 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=213 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=214 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=215 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=216 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=217 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=218 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=219 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=220 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=221 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=222 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=223 ’ 9999 lux (Saturado)

    ; 224-239
    RETLW   0x27    ; ADC=224 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=225 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=226 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=227 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=228 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=229 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=230 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=231 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=232 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=233 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=234 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=235 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=236 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=237 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=238 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=239 ’ 9999 lux (Saturado)

    ; 240-255
    RETLW   0x27    ; ADC=240 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=241 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=242 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=243 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=244 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=245 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=246 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=247 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=248 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=249 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=250 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=251 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=252 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=253 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=254 ’ 9999 lux (Saturado)
    RETLW   0x27    ; ADC=255 ’ 9999 lux (Saturado)

;==============================================================
; TABLA PARTE BAJA - LUX_TABLE_L
; Cada entrada es la parte baja del valor 0-9999
;==============================================================
LUX_TABLE_L
    RETLW   0x07    ; ADC=0  ’   7 lux
    RETLW   0x0C    ; ADC=1  ’  12 lux
    RETLW   0x12    ; ADC=2  ’  18 lux
    RETLW   0x18    ; ADC=3  ’  24 lux
    RETLW   0x1F    ; ADC=4  ’  31 lux
    RETLW   0x26    ; ADC=5  ’  38 lux
    RETLW   0x2E    ; ADC=6  ’  46 lux
    RETLW   0x36    ; ADC=7  ’  54 lux
    RETLW   0x3E    ; ADC=8  ’  62 lux
    RETLW   0x47    ; ADC=9  ’  71 lux
    RETLW   0x50    ; ADC=10 ’  80 lux
    RETLW   0x5A    ; ADC=11 ’  90 lux
    RETLW   0x64    ; ADC=12 ’ 100 lux
    RETLW   0x6F    ; ADC=13 ’ 111 lux
    RETLW   0x7A    ; ADC=14 ’ 122 lux
    RETLW   0x86    ; ADC=15 ’ 134 lux

    ; 16-31
    RETLW   0x92    ; ADC=16 ’ 146 lux
    RETLW   0x9F    ; ADC=17 ’ 159 lux
    RETLW   0xAC    ; ADC=18 ’ 172 lux
    RETLW   0xBA    ; ADC=19 ’ 186 lux
    RETLW   0xC8    ; ADC=20 ’ 200 lux
    RETLW   0xD7    ; ADC=21 ’ 215 lux
    RETLW   0xE6    ; ADC=22 ’ 230 lux
    RETLW   0xF6    ; ADC=23 ’ 246 lux
    RETLW   0x06    ; ADC=24 ’ 262 lux
    RETLW   0x17    ; ADC=25 ’ 279 lux
    RETLW   0x28    ; ADC=26 ’ 296 lux
    RETLW   0x3A    ; ADC=27 ’ 314 lux
    RETLW   0x4C    ; ADC=28 ’ 332 lux
    RETLW   0x5F    ; ADC=29 ’ 351 lux
    RETLW   0x72    ; ADC=30 ’ 370 lux
    RETLW   0x86    ; ADC=31 ’ 390 lux

    ; 32-47
    RETLW   0x9A    ; ADC=32 ’ 410 lux
    RETLW   0xAF    ; ADC=33 ’ 431 lux
    RETLW   0xC4    ; ADC=34 ’ 452 lux
    RETLW   0xDA    ; ADC=35 ’ 474 lux
    RETLW   0xF0    ; ADC=36 ’ 496 lux
    RETLW   0x07    ; ADC=37 ’ 519 lux
    RETLW   0x1E    ; ADC=38 ’ 542 lux
    RETLW   0x36    ; ADC=39 ’ 566 lux
    RETLW   0x4E    ; ADC=40 ’ 590 lux
    RETLW   0x67    ; ADC=41 ’ 615 lux
    RETLW   0x80    ; ADC=42 ’ 640 lux
    RETLW   0x9A    ; ADC=43 ’ 666 lux
    RETLW   0xB4    ; ADC=44 ’ 692 lux
    RETLW   0xCF    ; ADC=45 ’ 719 lux
    RETLW   0xEA    ; ADC=46 ’ 746 lux
    RETLW   0x06    ; ADC=47 ’ 774 lux

    ; 48-63
    RETLW   0x22    ; ADC=48 ’ 802 lux
    RETLW   0x3F    ; ADC=49 ’ 831 lux
    RETLW   0x5C    ; ADC=50 ’ 860 lux
    RETLW   0x79    ; ADC=51 ’ 889 lux
    RETLW   0x97    ; ADC=52 ’ 919 lux
    RETLW   0xB6    ; ADC=53 ’ 950 lux
    RETLW   0xD5    ; ADC=54 ’ 981 lux
    RETLW   0xF5    ; ADC=55 ’ 1013 lux
    RETLW   0x15    ; ADC=56 ’ 1045 lux
    RETLW   0x36    ; ADC=57 ’ 1078 lux
    RETLW   0x57    ; ADC=58 ’ 1111 lux
    RETLW   0x79    ; ADC=59 ’ 1145 lux
    RETLW   0x9B    ; ADC=60 ’ 1179 lux
    RETLW   0xBE    ; ADC=61 ’ 1214 lux
    RETLW   0xE2    ; ADC=62 ’ 1250 lux
    RETLW   0x06    ; ADC=63 ’ 1286 lux

    ; 64-79
    RETLW   0x2B    ; ADC=64 ’ 1323 lux
    RETLW   0x50    ; ADC=65 ’ 1360 lux
    RETLW   0x76    ; ADC=66 ’ 1398 lux
    RETLW   0x9D    ; ADC=67 ’ 1437 lux
    RETLW   0xC4    ; ADC=68 ’ 1476 lux
    RETLW   0xEC    ; ADC=69 ’ 1516 lux
    RETLW   0x15    ; ADC=70 ’ 1557 lux
    RETLW   0x3E    ; ADC=71 ’ 1598 lux
    RETLW   0x68    ; ADC=72 ’ 1640 lux
    RETLW   0x93    ; ADC=73 ’ 1683 lux
    RETLW   0xBE    ; ADC=74 ’ 1726 lux
    RETLW   0xEA    ; ADC=75 ’ 1770 lux
    RETLW   0x17    ; ADC=76 ’ 1815 lux
    RETLW   0x44    ; ADC=77 ’ 1860 lux
    RETLW   0x72    ; ADC=78 ’ 1906 lux
    RETLW   0xA1    ; ADC=79 ’ 1953 lux

    ; 80-95
    RETLW   0xD0    ; ADC=80 ’ 2000 lux
    RETLW   0x00    ; ADC=81 ’ 2048 lux
    RETLW   0x30    ; ADC=82 ’ 2096 lux
    RETLW   0x61    ; ADC=83 ’ 2145 lux
    RETLW   0x93    ; ADC=84 ’ 2195 lux
    RETLW   0xC5    ; ADC=85 ’ 2245 lux
    RETLW   0xF8    ; ADC=86 ’ 2296 lux
    RETLW   0x2C    ; ADC=87 ’ 2348 lux
    RETLW   0x61    ; ADC=88 ’ 2401 lux
    RETLW   0x96    ; ADC=89 ’ 2454 lux
    RETLW   0xCC    ; ADC=90 ’ 2508 lux
    RETLW   0x03    ; ADC=91 ’ 2563 lux
    RETLW   0x3A    ; ADC=92 ’ 2618 lux
    RETLW   0x72    ; ADC=93 ’ 2674 lux
    RETLW   0xAB    ; ADC=94 ’ 2731 lux
    RETLW   0xE4    ; ADC=95 ’ 2788 lux

    ; 96-111
    RETLW   0x1E    ; ADC=96 ’ 2846 lux
    RETLW   0x59    ; ADC=97 ’ 2905 lux
    RETLW   0x94    ; ADC=98 ’ 2964 lux
    RETLW   0xD0    ; ADC=99 ’ 3024 lux
    RETLW   0x0D    ; ADC=100 ’ 3085 lux
    RETLW   0x4A    ; ADC=101 ’ 3146 lux
    RETLW   0x88    ; ADC=102 ’ 3208 lux
    RETLW   0xC7    ; ADC=103 ’ 3271 lux
    RETLW   0x06    ; ADC=104 ’ 3334 lux
    RETLW   0x46    ; ADC=105 ’ 3398 lux
    RETLW   0x87    ; ADC=106 ’ 3463 lux
    RETLW   0xC8    ; ADC=107 ’ 3528 lux
    RETLW   0x0A    ; ADC=108 ’ 3594 lux
    RETLW   0x4D    ; ADC=109 ’ 3661 lux
    RETLW   0x90    ; ADC=110 ’ 3728 lux
    RETLW   0xD4    ; ADC=111 ’ 3796 lux

    ; 112-127
    RETLW   0x19    ; ADC=112 ’ 3865 lux
    RETLW   0x5E    ; ADC=113 ’ 3934 lux
    RETLW   0xA4    ; ADC=114 ’ 4004 lux
    RETLW   0xEB    ; ADC=115 ’ 4075 lux
    RETLW   0x32    ; ADC=116 ’ 4146 lux
    RETLW   0x7A    ; ADC=117 ’ 4218 lux
    RETLW   0xC3    ; ADC=118 ’ 4291 lux
    RETLW   0x0C    ; ADC=119 ’ 4364 lux
    RETLW   0x56    ; ADC=120 ’ 4438 lux
    RETLW   0xA1    ; ADC=121 ’ 4513 lux
    RETLW   0xEC    ; ADC=122 ’ 4588 lux
    RETLW   0x38    ; ADC=123 ’ 4664 lux
    RETLW   0x84    ; ADC=124 ’ 4740 lux
    RETLW   0xD1    ; ADC=125 ’ 4817 lux
    RETLW   0x1F    ; ADC=126 ’ 4895 lux
    RETLW   0x6D    ; ADC=127 ’ 4973 lux

    ; 128-143
    RETLW   0xBC    ; ADC=128 ’ 5052 lux
    RETLW   0x0B    ; ADC=129 ’ 5131 lux
    RETLW   0x5B    ; ADC=130 ’ 5211 lux
    RETLW   0xAC    ; ADC=131 ’ 5292 lux
    RETLW   0xFE    ; ADC=132 ’ 5373 lux
    RETLW   0x50    ; ADC=133 ’ 5455 lux
    RETLW   0xA3    ; ADC=134 ’ 5538 lux
    RETLW   0xF7    ; ADC=135 ’ 5621 lux
    RETLW   0x4C    ; ADC=136 ’ 5705 lux
    RETLW   0xA1    ; ADC=137 ’ 5790 lux
    RETLW   0xF7    ; ADC=138 ’ 5875 lux
    RETLW   0x4E    ; ADC=139 ’ 5961 lux
    RETLW   0xA6    ; ADC=140 ’ 6047 lux
    RETLW   0xFF    ; ADC=141 ’ 6134 lux
    RETLW   0x59    ; ADC=142 ’ 6222 lux
    RETLW   0xB4    ; ADC=143 ’ 6310 lux

    ; 144-159
    RETLW   0x0F    ; ADC=144 ’ 6399 lux
    RETLW   0x6B    ; ADC=145 ’ 6489 lux
    RETLW   0xC8    ; ADC=146 ’ 6579 lux
    RETLW   0x26    ; ADC=147 ’ 6670 lux
    RETLW   0x85    ; ADC=148 ’ 6762 lux
    RETLW   0xE5    ; ADC=149 ’ 6854 lux
    RETLW   0x46    ; ADC=150 ’ 6947 lux
    RETLW   0xA8    ; ADC=151 ’ 7041 lux
    RETLW   0x0B    ; ADC=152 ’ 7135 lux
    RETLW   0x6E    ; ADC=153 ’ 7230 lux
    RETLW   0xD2    ; ADC=154 ’ 7326 lux
    RETLW   0x37    ; ADC=155 ’ 7422 lux
    RETLW   0x9D    ; ADC=156 ’ 7519 lux
    RETLW   0x04    ; ADC=157 ’ 7617 lux
    RETLW   0x6C    ; ADC=158 ’ 7715 lux
    RETLW   0xD5    ; ADC=159 ’ 7814 lux

    ; 160-175
    RETLW   0x3F    ; ADC=160 ’ 7914 lux
    RETLW   0xAA    ; ADC=161 ’ 8014 lux
    RETLW   0x16    ; ADC=162 ’ 8115 lux
    RETLW   0x83    ; ADC=163 ’ 8217 lux
    RETLW   0xF1    ; ADC=164 ’ 8319 lux
    RETLW   0x60    ; ADC=165 ’ 8422 lux
    RETLW   0xD0    ; ADC=166 ’ 8526 lux
    RETLW   0x41    ; ADC=167 ’ 8630 lux
    RETLW   0xB3    ; ADC=168 ’ 8735 lux
    RETLW   0x26    ; ADC=169 ’ 8841 lux
    RETLW   0x9A    ; ADC=170 ’ 8947 lux
    RETLW   0x0F    ; ADC=171 ’ 9054 lux
    RETLW   0x85    ; ADC=172 ’ 9162 lux
    RETLW   0x02    ; ADC=173 ’ 9270 lux
    RETLW   0x80    ; ADC=174 ’ 9379 lux
    RETLW   0xFF    ; ADC=175 ’ 9489 lux

    ; 176-191
    RETLW   0x7F    ; ADC=176 ’ 9599 lux
    RETLW   0x00    ; ADC=177 ’ 9710 lux
    RETLW   0x82    ; ADC=178 ’ 9822 lux
    RETLW   0x04    ; ADC=179 ’ 9934 lux
    RETLW   0x09    ; ADC=180 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=181 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=182 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=183 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=184 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=185 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=186 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=187 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=188 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=189 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=190 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=191 ’ 9999 lux (Saturado)

    ; 192-207 (Todos saturados en 9999)
    RETLW   0x09    ; ADC=192 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=193 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=194 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=195 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=196 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=197 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=198 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=199 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=200 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=201 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=202 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=203 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=204 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=205 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=206 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=207 ’ 9999 lux (Saturado)

    ; 208-223 (Todos saturados en 9999)
    RETLW   0x09    ; ADC=208 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=209 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=210 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=211 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=212 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=213 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=214 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=215 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=216 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=217 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=218 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=219 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=220 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=221 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=222 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=223 ’ 9999 lux (Saturado)

    ; 224-239 (Todos saturados en 9999)
    RETLW   0x09    ; ADC=224 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=225 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=226 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=227 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=228 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=229 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=230 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=231 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=232 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=233 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=234 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=235 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=236 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=237 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=238 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=239 ’ 9999 lux (Saturado)

    ; 240-255 (Todos saturados en 9999)
    RETLW   0x09    ; ADC=240 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=241 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=242 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=243 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=244 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=245 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=246 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=247 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=248 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=249 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=250 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=251 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=252 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=253 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=254 ’ 9999 lux (Saturado)
    RETLW   0x09    ; ADC=255 ’ 9999 lux (Saturado)

    END