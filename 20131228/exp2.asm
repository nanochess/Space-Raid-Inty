        ;
        ; Space Raid para Intellivision
        ;
        ; por Oscar Toledo Gutiérrez
        ;
        ; (c) Copyright 2013 Oscar Toledo Gutiérrez
        ;
        ; Creación: 22-nov-2013.
        ; Revisión: 27-nov-2013. Se agrega la nave y su sombra.
        ; Revisión: 28-nov-2013. La nave ya se mueve usando el controlador izq.
        ; Revisión: 29-nov-2013. La nave ya puede disparar.
        ; Revisión: 14-dic-2013. Se implementa código para mover bala enemigos.
        ; Revisión: 16-dic-2013. Se agrega código para crear enemigos del
        ;                        espacio y los dibujos de los sprites.
        ; Revisión: 19-dic-2013. Se integra código para visualizar aviones en
        ;                        el espacio, generar movimiento de ataque y
        ;                        disparar.
        ; Revisión: 20-dic-2013. El jugador explota cuando toca un enemigo o
        ;                        una bala. Los enemigos explotan cuando los
        ;                        toca una bala. Se asignan colores a los
        ;                        sprites. Se pone indicador de puntuación,
        ;                        vidas y combustible. Ya gasta combustible. Se
        ;                        integran los datos para todos los niveles.
	; Revisión: 21-dic-2013. Ya salen los elementos de las fortalezas y
	;                        cohetes funcionales, y pueden ser destruidos.
	;                        Ya funcionan los campos eléctricos. Las
	;                        antenas ya están animadas.
	; Revisión: 23-dic-2013. Se agregan efectos de sonido y de fondo.
	; Revisión: 24-dic-2013. Primer experimento de fondo para la fortaleza.
	; Revisión: 25-dic-2013. Ajuste en mensaje de presentación.
	; Revisión: 26-dic-2013. Se integran los gráficos para los abismos y
	;                        las paredes. Se pone una raya en la fortaleza,
	;                        y se prepara la pantalla del espacio donde
	;                        se pondran estrellas.
	; Revisión: 27-dic-2013. Ya visualiza correctamente el robotote. Fondo
	;                        de estrellas que se desplazan suavemente en
	;                        el espacio. Los planetoides se desplazan más
	;                        despacio. Se agrega sonido para la mirilla.
	; Revisión: 28-dic-2013. Se incorpora mensaje de Game Over. Se elimina
	;                        basura al perder juego en espacio. Se agrega
	;                        pantalla de presentación.
        ;

        ; Próxima etiqueta: @@152
        
        ; Por hacer:
	; o Música de Game Over.
	; o Abismos de entrada y salida.
	; o Paredes
	;
	; Mejoras posibles:
	; o Fondo de color en fortalezas.
	; o Columnas en fortalezas.
	; o Mejorar el dibujo del robotote.
	; o Indicador de altitud a la izquierda.
	; o Elementos desapareciendo suavemente a la izquierda
	; o Bug: a veces sprites extraños en esquina sup. izq.
        
        ROMW    16              ; ROM de 16 bits

SCRATCH:        ORG     $100, $100, "-RWBN"
ISRVEC:     RMB     2               ; Always at $100 / $101
WFLAG:      RMB     1               ; ISR wait flag: ISR clears, fg task sets.
cuadro:         RMB 1           ; Contador de cuadros visualizados
x_jugador:      RMB 1           ; Coordenada X 3D del jugador
y_jugador:      RMB 1           ; Coordenada Y 3D del jugador
sprite_nave:    RMB 1           ; Sprite de la nave
ajuste_nave:    RMB 1           ; Ajuste de nave para animación :)
x_bala:         RMB 1           ; Coordenada X de bala
y_bala:         RMB 1           ; Coordenada Y de bala
bala_x3d:       RMB 1           ; Coordenada X 3D de bala al ser disparada
bala_y3d:       RMB 1           ; Coordenada Y 3D de bala al ser disparada
xj3d:           RMB 1           ; Temporal
yj3d:           RMB 1           ; Coordenada Y del jugador
x_bala2:        RMB 1           ; Coordenada X de bala enemigo
y_bala2:        RMB 1           ; Coordenada Y de bala enemigo
nivel_bala2:    RMB 1           ; Nivel de bala enemigo
bala_der:       RMB 1           ; Indica si bala enemigo va a la derecha
inicia_sprites: RMB 1           ; Indica si inicia sprites
gasolina:       RMB 1           ; Gasolina restante
x_enemigo1:     RMB 1           ; Posición X 3D de enemigo 1
x_enemigo2:     RMB 1           ; Posición X 3D de enemigo 2
x_enemigo3:     RMB 1           ; Posición X 3D de enemigo 3
y_enemigo1:     RMB 1           ; Posición Y 3D de enemigo 1
y_enemigo2:     RMB 1           ; Posición Y 3D de enemigo 2
y_enemigo3:     RMB 1           ; Posición Y 3D de enemigo 3
xe3d0:          RMB 1
xe3d1:          RMB 1
xe3d2:          RMB 1
xe3d3:          RMB 1
ye3d0:          RMB 1
ye3d1:          RMB 1
ye3d2:          RMB 1
ye3d3:          RMB 1
ye3d4:          RMB 1
offset9:        RMB 1
offset0:        RMB 1
offset1:        RMB 1
offset2:        RMB 1
offset3:        RMB 1
offset1temp:	RMB 1
offset2temp:	RMB 1
offset3temp: 	RMB 1
dificultad:     RMB 1           ; Dificultad actual
nivel:          RMB 1           ; Nivel actual
tiempo:         RMB 1           ; Tiempo para que aparezca otro enemigo
electrico:	 RMB 1		  ; Indica si hay campo eléctrico o cuenta impactos
lector:         RMB 2           ; Offset a nivel
byte:           RMB 1           ; Byte en lectura
ola:            RMB 1           ; Ola de ataque actual
secuencia:      RMB 1           ; Secuencia de ataque actual
proximo:        RMB 1           ; Próximo avión que disparará
explosion:      RMB 1           ; Indica si el jugador está explotando
avance:         RMB 1           ; Avance (aviones en espacio)
vidas:          RMB 1           ; Total de vidas
rand:           RMB 1           ; Número seudoaleatorio
puntos:         RMB 2           ; Puntos
colision0:	 RMB 1		  ; Colisión de nave con demás
colision2:	 RMB 1		  ; Colisión de bala con demás
colision6:	 RMB 1		  ; Colisión de bala enemigo con demás
pixel:		RMB 1		; Pixel para estrellas en el espacio
sonido_base0:	RMB 1		; Base de sonido 0
sonido_ap0:	RMB 1		; Apuntador a sonido 0
sonido_d0:	RMB 1		; Duración de sonido 0
sonido_base1:	RMB 1		; Base de sonido 1
sonido_ap1:	RMB 1		; Apuntador a sonido 1
sonido_d1:	RMB 1		; Duración de sonido 1
psg_copia:	RMB 14		; Copia del PSG antes de vaciado

_SCRATCH    EQU     $               ; end of scratch area

SYSTEM: ORG     $2F0, $2F0, "-RWBN"
STACK:  RMB     32              ; Reserva 32 palabras para la pila

_SYSTEM:        EQU     $       ; Fin del área del sistema


        ORG     $5000           ; Mapa de memoria por defecto

        INCLUDE "gimini.asm"

        ;
        ; Encabezado de la ROM
        ;
ROMHDR: BIDECLE ZERO            ; MOB picture base   (ap. a lista nula)
        BIDECLE ZERO            ; Tabla de procesos  (ap. a lista nula)
        BIDECLE MAIN            ; Inicio del programa
        BIDECLE ZERO            ; Base imagen fondo  (ap. a lista nula)
        BIDECLE ONES            ; Imagenes GRAM      (ap. a lista nula)
        BIDECLE TITLE           ; Título del cartucho y fecha
        DECLE   $03C0           ; Sin título ECS, inicia código después título,
                                ; ... sin clicks
                                
ZERO:   DECLE   $0000           ; Control de borde de a pantalla
        DECLE   $0000           ; 0 = color stack, 1 = f/b mode
        
ONES:   DECLE   C_BLU, C_BLU    ; Initial color stack 0 and 1: Blue
        DECLE   C_BLU, C_BLU    ; Initial color stack 2 and 3: Blue
        DECLE   C_BLU           ; Initial border color: Blue

        ;
        ; Título, modifica para eliminar info de Mattel
        ;
TITLE:  PROC
        BYTE    113, 'Space Raid', 0
        BEGIN

        ; Patch the title string to say '=JRMZ=' instead of Mattel.
        CALL    PRINT.FLS       ; Write string (ptr in R5)
        DECLE   C_WHT, $23D     ; White, Point to 'Mattel' in top-left
        STRING  ' *** na'    ; Guess who?  :-)
        STRING  'nochess ***'
        BYTE    0

        CALL    PRINT.FLS       ; Write string (ptr in R1)
        DECLE   C_WHT, $2C9     ; White, Point to 'Mattel' in lower-right
        STRING  '(C) Copyright 2013 '   ; Guess who?  :-)
        BYTE    0

        ; Done.
        RETURN                  ; Return to EXEC for title screen display
        ENDP

        ;
        ; Programa principal
        ;
MAIN:   PROC
        BEGIN

        DIS
        MVII    #STACK, R6

@@0:    
	MVII #$0fe,R1           ; 240 palabras + 14 de sonido
        MVII #$100,R4           ; 8-bit scratch RAM
        CALL FILLZERO
	
        CALL    CLRSCR          ; Limpia la pantalla

        MVII    #vector_int,R0  ; Apunta a la rutina de interrupción
        MVO     R0,     ISRVEC
        SWAP    R0
        MVO     R0,     ISRVEC+1

        EIS
	MVII #$031,R0
	MVO R0,psg_copia+8	; Configura ruido en canal A
reinicio:
	MVII #$50,R0
	MVO R0,gasolina
	;
	; Pantalla de título
	;
	MVII #$0206,R5
	MVII #$e5,R1
	MVII #0,R2
@@146:	MVO@ R2,R5
	DECR R1
	BNE @@146
	MVII #pantalla_titulo,R4
	MVII #$0219,R5
	MVII #10,R2
@@147:	MVII #10,R3
@@148:	MVI@ R4,R0
	MVO@ R0,R5
	DECR R3
	BNE @@148
	ADDI #10,R5
	DECR R2
	BNE @@147
	MVII #60,R2
@@149:	CALL espera_int
	DECR R2
	BNE @@149
@@150:	CALL espera_int
	MVI $01FF,R1
        COMR R1
        ANDI #$E0,R1    ; Disparo (botón izq o der, pero no superior)
        BEQ @@150
        MVII #$0F,R0
        MVO R0,dificultad
        MVII #15,R0
        MVO R0,x_jugador
        MVII #4,R0
        MVO R0,vidas
        MVII #0,R0
        MVO R0,puntos
        MVO R0,puntos+1
	MVII #0,R0	; !!!
	MVO R0,nivel
        CALl sel_nivel2
        ; En la jerga del Intellivision, se le llama card a cada caracter
        ; La GROM del Intellivision contiene caracteres predefinidos en el
        ; rango 0-215, para accederlos en el modo más común, se utiliza su
        ; número multiplicado por 8 (los 3 bits bajos son el color)
        ; Los caracteres ASCII 32-127 están reflejados en el rango 0-95.
;       MVII #(65-32)*8+C_YEL,R0
;@@0:   MVII #$0F0,R1
;       MVII #$200,R4
;       CALL FILLMEM
;       MVII #$10,R1
;@@1:   MVII #$10,R2
;@@2:   DECR R2
;       BNEQ @@2
;       DECR R1
;       BNEQ @@1

;       CALL    CLRSCR          ; Clear the screen

;       CALL    PRINT.FLS       ; Display our message.
;       DECLE   C_YEL           ; Yellow
;       DECLE   $200 + 5*20 + 4 ; Row #5, colukmn #4 on screen
;       STRING  'Hello World!'
;       BYTE    0

	MVII #$FF,R0
	MVO R0,pixel
        MVII #3,R0
        MVO R0,inicia_sprites
	CALL graficos_nivel

bucle:
        CALL espera_int
	MVI explosion,R0
	TSTR R0			; ¿Jugador explotando?
	BEQ @@55
	MVI xe3d1,R0
	INCR R0
	MVO R0,xe3d1
	MVI xe3d3,R0
	INCR R0
	MVO R0,xe3d3
	MVI ye3d1,R0
	TSTR R0
	BEQ @@56
	INCR R0
	CMPI #96,R0
	BNE @@57
	MVII #0,R0
@@57:	MVO R0,ye3d1
@@56:	MVI ye3d3,R0
	TSTR R0
	BEQ @@58
	DECR R0
	MVO R0,ye3d3
@@58:	MVI ye3d2,R0
	TSTR R0
	BEQ @@59
	MVI xe3d2,R1
	INCR R1		; Explosión intermedia
	INCR R1
	MVO R1,xe3d2
	CMPI #120,R1
	BNC @@59
	MVII #0,R0
	MVO R0,ye3d2
@@59:	MVI explosion,R0
	DECR R0		; ¿Finalizó explosión?
	MVO R0,explosion
	BNE @@60	; No, salta
	MVI vidas,R0
	DECR R0		; ¿Aún tiene vidas?
	MVO R0,vidas
	BPL @@61	; Sí, salta
	; Mensaje de Game Over
	MVII #0,R0
	MVO R0,vidas
	MVO R0,ye3d0
	MVO R0,ye3d1
	MVO R0,ye3d2
	MVO R0,ye3d3
	MVO R0,y_bala
	MVO R0,y_bala2
	MVO R0,psg_copia+11
	MVO R0,psg_copia+12
	MVO R0,psg_copia+13
	MVII #$FF,R0
	MVO R0,offset9
	MVII #mensaje_1,R4
	MVII #$0268,R5
	MVII #11,R1
@@145:	MVI@ R4,R0
	MVO@ R0,R5
	DECR R1
	BNE @@145
	MVII #60,R2
@@143:	CALL espera_int
	DECR R2
	BNE @@143
@@144:	CALL espera_int
	MVI $01FF,R1
        COMR R1
        ANDI #$E0,R1    ; Disparo (botón izq o der, pero no superior)
        BEQ @@144
	B reinicio

mensaje_1:	DECLE $07+$00*8,$07+$27*8
	DECLE $07+$21*8,$07+$2D*8
	DECLE $07+$25*8,$07+$00*8
	DECLE $07+$2F*8,$07+$36*8
	DECLE $07+$25*8,$07+$32*8
	DECLE $07+$00*8

@@61:	MVI lector,R3
	CALL sel_nivel2	; Reinicia el nivel
	SUB lector,R3	; Verifica avance
	CMPI #12,R3	; ¿Más de la mitad del nivel?
	BNC @@60	; No, salta.
	MVII #24,R1	; Sí, inicia a medio nivel
@@62:	CALL adelanta_lector
	DECR R1
	BNE @@62
	B @@60

@@55: 	
        ;
        ; Agrega enemigos según el nivel
        ;
        MVI nivel,R0
        ANDI #$01,R0
        BEQ @@15
        ;
        ; Fortaleza: enemigos fijos
        ;
        MVI tiempo,R0
	CMPI #25,R0	; ¿Agrega un adorno?
	BNE @@84	; No, salta.
	MVI offset1,R0
	CMPI #$60,R0
	BEQ @@84
	CMPI #$88,R0	; ¿Es $88,$98,$a0,$b8,$c0,$c8,$d0,$d8 o $e0?
	BC @@84		; Sí, evita poner adorno
	MVI ye3d0,R0
	TSTR R0
	BNE @@84
	MVII #150,R0
	MVO R0,xe3d0
	MVII #96,R0
	MVO R0,ye3d0
	MVII #$E0,R0
	MVI rand,R1
	ANDI #$80,R1
	BEQ @@85
	MVII #$B0,R0
@@85:	MVO R0,offset0
@@84:	MVI tiempo,R0	; ¿Tiempo de poner otro enemigo?
	DECR R0
	MVO R0,tiempo
        BNE @@86
	CALL lee_byte
	ANDI #$FF,R0
	BEQ @@87
	ANDI #$F8,R0
	CMPI #$E8,R0	; ¿Adorno de nivel?
	BEQ @@89
	CMPI #$90,R0	; ¿Alienígena, misil, robotote $a0 o electricidad $b8?
			; ¿Pared $c0,$c8,$d0,$d8 o $e0?
	BNC @@89	; No, salta.
@@87:	MVI ye3d1,R0
	TSTR R0
	BNE @@88
	MVI ye3d2,R0
	TSTR R0
	BNE @@88
	MVI ye3d3,R0
	TSTR R0
	BNE @@88
	MVII #8,R1
	CALL lee_byte
	ANDI #$FF,R0
	BNE @@90
	CALL adelanta_nivel
	B @@16

@@90:	ANDI #$F8,R0
	CMPI #$C0,R0
	BNC @@91
	CMPI #$E8,R0
	BNC @@92
@@91:	CMPI #$B8,R0	; ¿Electricidad?
	BEQ @@93
	CMPI #$A0,R0	; ¿Robotote?
	; !!! Código de tamaño
	B @@93

@@92:	; !!! Muro
	B @@93

@@89:	MVI ye3d1,R0
	TSTR R0
	BEQ @@93
	MVI offset1,R0
	CMPI #$88,R0	; ¿Hay un misil vertical activo?
	BEQ @@88
	CMPI #$60,R0	; ¿Hay un agujero de misil?
	BNE @@94
	MVI electrico,R0
	TSTR R0
	BNE @@93
	;
	; Para reducir vacíos del área de juego en ciertas ocasiones
	; dispara al llegar al centro.
	;
	MVI rand,R0
	ANDI #$40,R0
	MVII #80,R0	; Centro de la pantalla
	BNE @@95
	;
	; Pequeña ecuación para atinarle al jugador si pasa por encima :>
	; 
	MVI yj3d,R0
	SUB ye3d1,R0
	BC @@96
	MVII #0,R0
@@96:	SLL R0,1
	ADD x_jugador,R0
@@95:	CMP xe3d1,R0
	BNC @@88	; Sí, salta a esperar
	CALL insercion
	ADDI #7,R0
	MVO R0,ye3d1
	; Efecto de sonido: lanzamiento
	MVII #sonido_4-base_sonido,R0
	CALL efecto_sonido_prioridad
	MVII #$88,R0	; Misil vertical
	MVO R0,offset1
	MVII #$80,R0	; Agujero disparando
	MVO R0,offset2
	B @@88
	
@@94:	CMPI #$E8,R0	; ¿Adorno de piso?
	BEQ @@93
	CMPI #$98,R0	; ¿Hay misil teledirigido, robotote $a0 o campo $b8?
	BC @@88		; Sí, salta a esperar

@@93:	CALL lee_byte
	ANDI #$07,R0
	ADDI #offset_y,R0
	MOVR R0,R4
	MVI@ R4,R0
	B @@97		; Salto innecesario
	
@@88:	MVI tiempo,R0	; Espera un poco más
	INCR R0
	MVO R0,tiempo
	B @@86

@@97:	CALL insercion
	MVII #0,R2
	MVO R2,electrico
	CALL lee_byte
	ANDI #$F8,R0
	MVO R0,offset1
	MVII #150,R1
	CMPI #$A0,R0	; ¿Robotote?
	BNE @@98
	MVII #140,R1
@@98:	MVO R1,xe3d1
	MVO R1,avance	; Para calcular pared "cercana"
	MVII #5,R1
	CMPI #$E8,R0	; ¿Adorno de piso?
	BEQ @@99
	MVI rand,R1
	ANDI #4,R1
	ADDI #40,R1
@@99:	MVO R1,tiempo
	CALL lee_byte
	ANDI #$07,R0
	ADDI #offset_y,R0
	MOVR R0,R4
	MVI@ R4,R0
	MVO R0,ola	; Para referencia campo eléctrico
	MVO R0,ye3d1
	CALL adelanta_lector

	;
	; Desplaza los elementos de la fortaleza para efecto de scrolling
	;
@@86:	MVII #0,R1
	MVO R1,xj3d
	MVII #-4,R1	; Ajuste Y de bala para alienígena
	MVII #32,R2	; Nivel con respecto al piso para posible bala
	MVI offset1,R0
	CMPI #$90,R0	; ¿Alienígena?
	BEQ @@100
	MVI xj3d,R3
	INCR R3		; Ajuste Y del misil teledirigido
	INCR R3
	MVO R3,xj3d
	CMPI #$98,R0	; ¿Misil teledirigido?
	BEQ @@101
	MVII #-13,R1	; Ajuste Y de bala para robotote
	MVI y_jugador,R2	; Nivel idéntico al del jugador para posible bala
	CMPI #$A0,R0	; ¿Robotote?
	BNE @@102
@@100:	MVI xe3d1,R0
	CMPI #140,R0	; ¿Recién salido?
	BC @@103	; Sí, salta, debe centrarlo
	MVI x_bala2,R0	; ¿Bala activa?
	TSTR R0
	BNE @@103	; Sí, salta
	MVO R0,bala_der
	MVI rand,R0
	CMP dificultad,R0	; ¿Tiempo de disparar?
	BC @@103	; No, salta.
	ADD ye3d1,R1
	MVO R1,y_bala2
	MVO R2,nivel_bala2
	MVI xe3d1,R0
	MVO R0,x_bala2
	; Efecto de sonido: disparo enemigo
	MVII #sonido_2-base_sonido,R0
	CALL efecto_sonido
@@103:	MVI offset1,R0
	CMPI #$90,R0
	BEQ @@101
	MVI cuadro,R0
	ANDI #1,R0	; El robotote sólo se mueve cada dos cuadros
	BEQ @@16
	MVII #8,R1
	MVO R1,xj3d
	;
	; Robotote y misil teledirigido siguen al jugador
	;
@@101:	MVI xe3d1,R0
	CMPI #16,R0	; ¿Llegó al borde de la pantalla?
	BNE @@104
	MVII #0,R0	; Desaparece
	MVO R0,ye3d1
	B @@16

@@104:	DECR R0
	MVO R0,xe3d1
	INCR R0
	SUB x_jugador,R0
	BPL @@105
	MVII #0,R0
@@105:	SLR R0,2
	ADD yj3d,R0
	ADD xj3d,R0	; Corrección robotote
	MVI offset1,R1
	CMPI #$90,R1	; ¿Alienígena?
	BNE @@106
	MVII #32,R1	; Sí, lleva al piso
	SUB y_jugador,R1
	ADDR R1,R0
@@106:	CMPI #96,R0	; Limita a la pantalla visible
	BNC @@107
	MVII #96,R0
@@107:	MVO R0,ye3d1
	MVI xj3d,R0
	CMPI #8,R0
	BNE @@16
	; Robotote, agrega sprite extra.
	MVI xe3d1,R0
	ADDI #16,R0
	MVO R0,xe3d2
	MVI ye3d1,R0
	MVO R0,ye3d2
	MVII #$20,R0
	MVO R0,offset2
	B @@16

	;
	; Desplaza los elementos fijos por el piso
	;
@@102:	
	MVI avance,R0
	DECR R0
	MVO R0,avance
	MVII #xe3d0,R2
	MVII #ye3d0,R3
@@108:	MVI@ R2,R0	; ¿Elemento activo?
	TSTR R0
	BEQ @@109
	DECR R0
	MVO@ R0,R2
	CMPI #16,R0
	BC @@110
	MVII #16,R0
	MVO@ R0,R2
	MVII #0,R0
	MVO@ R0,R3
@@110:	ANDI #3,R0
	CMPI #3,R0
	BNE @@111
	MVI@ R3,R0
	DECR R0
	MVO@ R0,R3
@@111:	MVI x_bala2,R0	; ¿Bala activa?
	TSTR R0
	BNE @@109	; Sí, salta.
	MVO R0,bala_der
	MVI rand,R0
	CMP dificultad,R0	; ¿Tiempo de disparar?
	BC @@109	; No, salta.
	ADDI #offset0-xe3d0,R2
	MVI@ R2,R0
	SUBI #offset0-xe3d0,R2
	CMPI #$40,R0	; ¿Avión chico?
	BEQ @@112
	CMPI #$68,R0	; ¿Cañón mirando a jugador?
	BEQ @@112
	CMPI #$50,R0	; ¿Cañón mirando a derecha?
	BNE @@109	; No, salta.
	MVI rand,R0
	ANDI #1,R0
	BNE @@113
	MVII #1,R0	; Dispara una bala a la derecha
	MVO R0,bala_der
	B @@112

@@113:	MVII #$68,R0	; Gira cañón
	ADDI #offset0-xe3d0,R2
	MVO@ R0,R2
	SUBI #offset0-xe3d0,R2
@@112:	MVI@ R3,R0
	SUBI #7,R0
	BMI @@109	; Evita crear bala en coordenada negativa o cero
	BEQ @@109
	MVO R0,y_bala2
	ADDI #offset0-xe3d0,R2
	MVI@ R2,R0
	SUBI #offset0-xe3d0,R2
	SUBI #$50,R0
	BEQ @@114
	MVII #-8,R0	
@@114:	MVI@ R2,R1
	ADDR R1,R0
	ADDI #8,R0
	MVO R0,x_bala2
	MVII #32,R0
	MVO R0,nivel_bala2
	; Efecto de sonido: disparo enemigo
	MVII #sonido_2-base_sonido,R0
	CALL efecto_sonido
@@109:	INCR R2
	INCR R3
	CMPI #ye3d4,R3
	BNE @@108

	MVI offset1,R0
	CMPI #$88,R0	; ¿Misil vertical?
	BNE @@115
	MVI cuadro,R0
	ANDI #1,R0	; Se alza un pixel cada dos cuadros?
	BNE @@115
	MVI ye3d1,R0
	TSTR R0
	BEQ @@116	; ¿Salió de la pantalla?
	INCR R0
	MVO R0,ye3d1
	SUB ye3d2,R0
	CMPI #24,R0
	BNC @@117
	MVII #$60,R0	; Fin de fuego en agujero de misil
	MVO R0,offset2
@@117:	MVI ye3d1,R0
	CMPI #97,R0
	BNE @@115
@@116:	MVII #1,R0
	MVO R0,electrico	; Ya disparó
	MVI ye3d2,R0
	MVO R0,ye3d1
	MVI xe3d2,R0
	MVO R0,xe3d1
	MVI offset2,R0
	MVO R0,offset1
	MVI ye3d3,R0
	MVO R0,ye3d2
	MVI xe3d3,R0
	MVO R0,xe3d2
	MVI offset3,R0
	MVO R0,offset2
@@115:

	B @@16



        ;
        ; Espacio exterior
        ;
@@15:   MVI tiempo,R0
        DECR R0
        MVO R0,tiempo
        BNE @@17
        MVI y_enemigo1,R0
        TSTR R0
        BNE @@18
        MVI y_enemigo2,R0
        TSTR R0
        BNE @@18
        MVI y_enemigo3,R0
        TSTR R0
        BNE @@18
        CALL lee_byte
        ANDI #$FF,R0
        BNE @@19
        CALL adelanta_nivel
        B @@16
        
@@18:   MVII #1,R0
        MVO R0,tiempo
        B @@17

@@19:   MVO R0,ola
        CALL adelanta_lector
        MVII #0,R1
        MVO R1,secuencia
        MVO R1,proximo
        CMPI #$E8,R0    ; Planetoide
        BGE @@20
        CMPI #$C0,R0    ; ¿Satélite?
        BEQ @@23
        MVII #35,R1     ; Enemigo solitario por el centro
        CMPI #$3A,R0
        BLT @@25
        BEQ @@27
        CMPI #$3C,R0
        BEQ @@27
        MVII #15,R1     ; Enemigo solitario por la izquierda
        CMPI #$3D,R0
        BNE @@27
        MVII #55,R1     ; Enemigo solitario por la derecha
@@27:   MVO R1,x_enemigo1
        CALL lee_byte
        CALL adelanta_lector
        MOVR R0,R2
        MVII #$40,R1
        MVII #96,R0
        B @@24

@@20:   MVII #15,R1     ; Planetoide 1
        MVO R1,x_enemigo1
        MVII #35,R1     ; Planetoide 2
        MVO R1,x_enemigo2
        ANDI #1,R0
        MVII #50,R2
        MVII #12,R1
        BNE @@21        ; Alternativa de posición
        MVII #72,R2
        MVII #32,R1
@@21:   MVO R1,y_enemigo2
        MVII #96,R0
        MVII #$F8,R1
        MVO R1,offset2
        MVII #$F0,R1
        B @@22

@@23:   MOVR R0,R1      ; Satélite
        MVII #105,R0
        MVO R0,x_enemigo1
        MVII #72,R2
;        MVII #16,R0     ; Más largo que los otros sprites
;        MVO R0,largo_sprite    ; !!!
        MVII #48,R0
        B @@24

@@25:   MVII #15,R0     ; Tres enemigos
        MVO R0,x_enemigo1
        MVO R1,x_enemigo2
        MVII #55,R0
        MVO R0,x_enemigo3
        MVII #72,R2
        MVI ola,R0
        CMPI #$38,R0
        BEQ @@26
        MVII #32,R2
@@26:   MVO R2,y_enemigo2
        MVO R2,y_enemigo3
        MVII #$40,R1
        MVII #125,R0
@@24:   MVO R1,offset2
@@22:   MVO R1,offset1
        MVO R1,offset3
        MVO R2,y_enemigo1
        MVO R0,avance
        MVII #50,R0
        MVO R0,tiempo
        ;
        ; Posiciona los enemigos
        ;
@@17:   MVII #0,R0
        MVO R0,ye3d0
        MVI avance,R0
	CMPI #$80,R0
	BNC @@81 
	XORI #$FF00,R0
@@81:   SAR R0,2
        MVO R0,xj3d
        MVII #x_enemigo1,R2
        MVII #y_enemigo1,R3
        MVII #xe3d1,R4
        MVII #ye3d1,R5
@@28:
        MVI@ R2,R0
        SLR R0,1
        MVI@ R3,R1
        CMPI #0,R1
        BEQ @@29
        ADDI #8,R1
        SUBR R0,R1
        ADD xj3d,R1
        BEQ @@29
        CMPI #97,R1     ; ¿Invisible?
        BC @@29
        MVI@ R2,R0
        ADD avance,R0
	ANDI #$FF,R0
        CMPI #150,R0    ; ¿Invisible?
        BNC @@31
@@29:   MVII #0,R0
        MVO@ R0,R4
        MVO@ R0,R5
        B @@30

@@31:   MVO@ R0,R4
        MVO@ R1,R5
        ;
        ; Verifica si pone "mira"
        ;
        ADDI #offset1-x_enemigo1,R2
        MVI@ R2,R0
        SUBI #offset1-x_enemigo1,R2
        CMPI #$C0,R0    ; ¿Satélite?
        BEQ @@32
        CMPI #$48,R0
        BGE @@30        ; Si no es avión, obvia disparo
        MVI avance,R0
        CMPI #160,R0
        BGE @@33
        CMPI #50,R0
        BLT @@33
@@32:   MVI@ R3,R1
        SUB y_jugador,R1
        ADDI #2,R1
        CMPI #5,R1
        BC @@33
        MVI@ R2,R0
        SUB x_jugador,R0
        ADDI #3,R0
        CMPI #7,R0
        BC @@33
        MVII #$D0,R0
        MVO R0,offset0
        MVI x_jugador,R0
        ADDI #32,R0
        MVO R0,xe3d0
        MVI yj3d,R0
        ADDI #8,R0
        MVO R0,ye3d0
        ;
        ; Cambia sprite de los aviones según la altitud
        ;
@@33:   ADDI #offset1-x_enemigo1,R2
        MVI@ R2,R0
        SUBI #offset1-x_enemigo1,R2
        CMPI #$48,R0
        BC @@30         ; Si no es avión, obvia disparo
        MVI@ R3,R1
        CMPI #48,R1
        MVII #$40,R0
        BNC @@35
        CMPI #64,R1
        MVII #$38,R0
        BNC @@35
        MVII #$30,R0
@@35:   ADDI #offset1-x_enemigo1,R2
        MVO@ R0,R2
        SUBI #offset1-x_enemigo1,R2
@@34:   MVI x_bala2,R0
        TSTR R0         ; ¿Bala activa?
        BNE @@30
        MVO R0,bala_der
        MVI rand,R0
        CMP dificultad,R0       ; ¿Tiempo de disparar?
        BC @@30
        MOVR R2,R0
        SUBI #x_enemigo1,R0
        CMP proximo,R0  ; ¿Es el avión que debe disparar?
        BNE @@30
        MOVR R5,R1
        DECR R1
        MVI@ R1,R0
        SUBI #7,R0
        MVO R0,y_bala2
        MVI@ R3,R0
        MVO R0,nivel_bala2
        MOVR R4,R1
        DECR R1
        MVI@ R1,R0
        MVO R0,x_bala2
	; Efecto de sonido: disparo enemigo
	MVII #sonido_2-base_sonido,R0
	CALL efecto_sonido
        MVI ola,R0
        CMPI #$3B,R0    ; ¿Aviones después de bajar/subir?
        BEQ @@36
        CMPI #$3A,R0    ; ¿Ola de avión simple?
        BC @@30       ; Sí, salta.
@@36:   MVI proximo,R0
        INCR R0
        CMPI #3,R0
        BNE @@37
        MVII #0,R0
@@37:   MVO R0,proximo
@@30:   INCR R2
        INCR R3
        CMPI #x_enemigo3+1,R2
        BNE @@28
@@16:
	;
	; Evita código de enemigos si está explotando
	;
@@60:
        MVI explosion,R0
        TSTR R0
        BEQ @@53
        MVI offset9,R0
        TSTR R0
        BNE @@63
        MVII #$48,R0
        MVO R0,offset9
        B @@63
        
@@53:   MVII #0,R0
        MVO R0,offset9
        ; Parpadeo de explosiones
@@63:   MVI cuadro,R0
        ANDI #3,R0      ; Cada cuatro cuadros
        BNE @@49
        MVII #offset9,R2
        MVII #5,R1
@@52:   MVI@ R2,R0
        CMPI #$48,R0    ; Intercambia entre $48 y $58
        BEQ @@50
        CMPI #$58,R0
        BNE @@51
@@50:   XORI #$10,R0    ; Con esto basta
        MVO@ R0,R2
@@51:   INCR R2
        DECR R1
        BNE @@52
@@49:
        ;
        ; A 30 cuadros por segundo
        ;
        MVI cuadro,R0
        ANDI #$01,R0
        BEQ @@11
	MVI explosion,R0
	TSTR R0
	BNE @@54
        ;
        ; Desplazamiento de la nave del jugador
        ;
        MVII #0,R0
        MVO R0,ajuste_nave
        MVI x_jugador,R2
        MVI y_jugador,R3
        MVI $01FF,R0
        MOVR R0,R1
        ANDI #$01,R1    ; Abajo
        BNE @@1
        CMPI #72,R3
        BEQ @@1
        INCR R3
@@1:    MOVR R0,R1
        ANDI #$02,R1    ; Derecha
        BNE @@2
        MVII #$18,R1
        MVO R1,ajuste_nave
        CMPI #55,R2
        BEQ @@2
        INCR R2
@@2:    MOVR R0,R1
        ANDI #$04,R1    ; Arriba
        BNE @@3
        CMPI #32,R3
        BEQ @@3
        DECR R3
@@3:    MOVR R0,R1
        ANDI #$08,R1    ; Izquierda
        BNE @@4
        MVII #$0c,R1
        MVO R1,ajuste_nave
        CMPI #15,R2
        BEQ @@4
        DECR R2
@@4:    MVO R2,x_jugador
        MVO R3,y_jugador
        
        MOVR R0,R1
        COMR R1
        ANDI #$E0,R1    ; Disparo (botón izq o der, pero no superior)
        BEQ @@6
        MVI x_bala,R0
        TSTR R0         ; ¿Bala activa?
        BNE @@6         ; Sí, salta
        MVI y_jugador,R0
        MVO R0,bala_y3d
        MVI x_jugador,R0
        MVO R0,bala_x3d
        ADDI #12,r0
        MVO R0,x_bala
        MVII #1,R1
;        MVI sprite_nave,R0
;        CMPI #4,R0
;        BEQ @@7
;        INCR R1
;        BC @@7
;        MVII #1,R1
@@7:    MVI yj3d,R0
        SUBR R1,R0
        MVO R0,y_bala
	; Efecto de sonido: disparo del jugador
	MVII #sonido_1-base_sonido,R0
	CALL efecto_sonido

        ;
        ; Mueve bala del enemigo
        ;
@@6:    MVI x_bala2,R0
        TSTR R0         ; ¿Bala activa?
        BEQ @@11
        MVI y_bala2,R1
        MVI bala_der,R2
        TSTR R2
        BEQ @@12
        INCR R0
        DECR R1
        B @@13

@@12:   SUBI #4,R0
        CMPI #15,R0
        BLT @@14
@@13:   DECR R1
        MVO R0,x_bala2
        MVO R1,y_bala2
        BEQ @@14
        BMI @@14
        MVI nivel_bala2,R0
        SUB y_jugador,R0
        ADDI #2,R0
        CMPI #5,R0
        BC @@11
	MVI colision0,R0	; Colisión nave
	ANDI #$80,R0		; ¿Chocó con bala enemigo?
	BEQ @@11
	CALL inicia_explosion
@@14:   MVII #0,R0
        MVO R0,y_bala2
        MVO R0,x_bala2
@@11:

        ;
        ; Corriendo a 60 cuadros por segundo
        ;
        
        ; Mueve bala del jugador
	MVII #1,R3
        MVI x_bala,R0
        TSTR R0         ; ¿Bala activa?
        BEQ @@8         ; No, salta
        INCR R3
	MVI y_bala,R1
        INCR R1
        CMPI #96,R1
        BEQ @@10
        ADDI #4,R0
        CMPI #150,R0
        BNC @@9
@@10:   MVII #0,R0
        MOVR R0,R1
	DECR R3
@@9:    MVO R1,y_bala
        MVO R0,x_bala
@@8:	MVII #0,R2
	;
	; Comprueba si el jugador (r2=0) o la bala (r2=1) chocan 
	; con algún elemento
	;
@@64:	MVII #2,R1
@@65:	MVI nivel,R0
	ANDI #1,R0
	BEQ @@66
	; Fortaleza
	MVII #ye3d1,R4
	ADDR R1,R4
	MVI@ R4,R5
	TSTR R5
	BEQ @@67
	MVII #offset1,R4
	ADDR R1,R4
	MVI@ R4,R5
	SUBI #$C0,R5	; ¿Pared?
	BNC @@118
	CMPI #$18,R5
	BC @@67		; Ignora lo demás
	CMPI #0,R2
	BNE @@125
	; Jugador contra pared
	MVI avance,R0
	CMPI #21,R0	; ¿Llegó al punto de choque?
	BC @@67		; No, salta.
	MVI y_jugador,R0
	CMPI #72,R0	; ¿La nave está hasta arriba?
	BNE @@124	; No, explota.
	CMPI #$00,R5
	MVI x_jugador,R0
	BNE @@126
	SUBI #31,R0
	CMPI #8,R0
	BNC @@67
	B @@124

@@126:	CMPI #$08,R5
	BNE @@127
	SUBI #46,R0
	CMPI #8,R0
	BNC @@67
	B @@124

@@127:	SUBI #31,R0
	CMPI #23,R0
	BNC @@67
	B @@124

	; Bala contra pared
@@125:	MVI x_bala,R0
	SUB bala_x3d,R0
	ADDI #4,R0
	CMP avance,R0
	BNC @@67
	MVI bala_y3d,R0
	CMPI #72,R0
	BNE @@124
	CMPI #0,R5
	MVI bala_x3d,R0
	BNE @@128
	SUBI #31,R0
	CMPI #8,R0
	BNC @@67
	B @@124

@@128:	CMPI #8,R5
	BNE @@129
	SUBI #46,R0
	CMPI #8,R0
	BNC @@67
	B @@124

@@129:	SUBI #31,R0
	CMPI #23,R0
	BNC @@67
	B @@124

@@118:	MVII #offset1,R4
	ADDR R1,R4
	MVI@ R4,R0
	CMPI #$B8,R0	; ¿Electricidad?
	BEQ @@119
	CMPI #$98,R0	; ¿Misil teledirigido o robotote $a0?
	BC @@120	; Sí, salta, siempre al nivel
	CMPI #$88,R0	; ¿Misil vertical?
	BNE @@121
	MVI ye3d1,R5	; Saca nivel en referencia a su agujero
	SUB ye3d2,R5	
	ADDI #32,R5
	B @@131

@@121:	MVII #32,R5	; En el piso
	B @@131

@@119:	MVI ola,R0
	CMPI #105,R0
	MVI y_jugador,R0
	BNC @@130
	CMPI #48,R0	; Arriba de la zona: pasa a choque
	BC @@120
	B @@122

@@130:	CMPI #56,R0
	BC @@122

	; Simplifica detección de impacto robotote
@@120:	CMPI #0,R2
	MVI colision2,R0	; Choque entre bala y otros
	BNE @@123
	MVI colision0,R0	; Choque entre nave y otros
@@123:	ANDI #$78,R0
	BEQ @@67
	B @@124

	; Espacio
@@66:	MVII #y_enemigo1,R4
	ADDR R1,R4
	MVI@ R4,R5
	TSTR R5
	BEQ @@67
@@131:	TSTR R2
	BEQ @@70
	SUB bala_y3d,R5
	B @@71

@@70:	SUB y_jugador,R5
@@71:	ADDI #2,R5
	CMPI #5,R5
	BC @@67
	MVII #xe3d1,R4
	ADDR R1,R4
	MVI@ R4,R5
	TSTR R2
	BEQ @@72
	SUB x_bala,R5
	ADDI #8,R5
	CMPI #10,R5
	MVI y_bala,R5
	B @@73

@@72:	SUB x_jugador,R5
	ADDI #4,R5
	CMPI #13,R5
	MVI yj3d,R5
@@73:	BC @@67
	MVII #ye3d1,R4
	ADDR R1,R4
	SUB@ R4,R5
	TSTR R2
	BEQ @@68
	ADDI #7,R5
	CMPI #8,R5
	B @@69

@@68:	ADDI #4,R5
	CMPI #9,R5
@@69:	BC @@67
	; El jugador/bala tocó un enemigo
@@124:	MVII #offset1,R4
	ADDR R1,R4
	MVI@ R4,R0
	CMPI #$D8,R0	; ¿Adorno o planetoides?
	BC @@67		; Sí, no afecta
	CMPI #$48,R0	; ¿Explosión 1?
	BEQ @@67	; Sí, no afecta
	CMPI #$58,R0	; ¿Explosión 2?
	BEQ @@67	; Sí, no afecta
	CMPI #$60,R0	; ¿Agujero de misil?
	BEQ @@67	; Sí, no afecta
	TSTR R2
	BNE @@74
	CALL gana_puntos
	CALL inicia_explosion
	B @@75

@@74:	MVI nivel,R4
	ANDI #1,R4
	BEQ @@78
	CMPI #$B8,R0	; ¿Electricidad, pared 1/2/3, abismos?
	BC @@77		; Sí, detiene bala
	CMPI #$80,R0	; ¿Agujero de misil disparado?
	BEQ @@77	; Sí, detiene bala
	CMPI #$70,R0	; ¿Gasolina?
	BNE @@78	; No, salta.
	MVI gasolina,R4
	ADDI #$0F,R4	; Más gasolina
	ANDI #$F8,R4
	CMPI #$50,R4	; Limita a diez unidades
	BNC @@79
	MVII #$50,R4
@@79:	MVO R4,gasolina
@@78:	CMPI #$98,R0	; ¿Misil teledirigido?
	BNE @@80
	MVI electrico,R4
	INCR R4
	MVO R4,electrico
	CMPI #5,R4	; ¿Cinco impactos?
	BNE @@77	; No, salta.
@@80:	CMPI #$A0,R0	; ¿Robotote?
	BNE @@76
	MVI electrico,R4
	INCR R4
	MVO R4,electrico
	CMPI #10,R4	; ¿Diez impactos?
	BNE @@77	; No, salta.
	MVII #$58,R4
	MVO R4,offset2
@@76:	CALL gana_puntos
	MVII #$48,R0
	MVII #offset1,R4
	ADDR R1,R4
	MVO@ R0,R4
	; Efecto de sonido: explosión
	MVII #sonido_3-base_sonido,R0
	CALL efecto_sonido_prioridad

@@77:	MVII #0,R1	; Desaparece la bala y evita checar otro enemigo
	MVO R1,y_bala
	MVO R1,x_bala
@@67:	DECR R1
	BPL @@65
@@122:	INCR R2
	DECR R3
	BNE @@64
@@75:

        ;
        ; Cambia el sprite de la nave según la altitud
        ;
        MVI y_jugador,R0
        MVII #8,R1
        CMPI #48,R0
        BLT @@5
        MVII #4,R1
        CMPI #64,R0
        BLT @@5
        MVII #0,R1
@@5:    MVO R1,sprite_nave
        ;
	; Sonido de fondo
	;
	MVII #72,R0
	SUB y_jugador,R0
	SLR R0,1
	ADDI #10,R0
	MVO R0,psg_copia+9	; Periodo de ruido
	MVII #10,R0
	MVO R0,psg_copia+11	; Volumen canal A
	MVI nivel,R0
	ANDI #1,R0		; ¿En el espacio?
	MVI offset1,R1
	BNE @@138
	MVII #sonido_5-base_sonido,R0
	CMPI #$C0,R1		; ¿Satélite?
	BEQ @@139
@@138:	MVII #sonido_6-base_sonido,R0
	CMPI #$98,R1		; ¿Misil teledirigido?
	BEQ @@139
	MVII #sonido_7-base_sonido,R0
	CMPI #$B8,R1		; ¿Electricidad?
	BEQ @@139
	MVII #sonido_8-base_sonido,R0
	CMPI #$A0,R1		; ¿Robotote?
	BEQ @@139
	MVII #0,R0
@@139:	CMP sonido_base0,R0
	BEQ @@140
	MVO R0,sonido_base0
	MVO R0,sonido_ap0
	TSTR R0
	BEQ @@141
	MOVR R0,R4
	ADDI #base_sonido,R4
	MVI@ R4,R0
	ANDI #$1F,R0
@@141:	MVO R0,sonido_d0
@@140:
        ;
        ; Procesa ola de ataque
        ;
        MVI nivel,R0
        ANDI #1,R0      ; ¿En espacio?
        BNE @@38        ; No, salta.
        MVI secuencia,R0
        INCR R0
        MVO R0,secuencia
        MVI y_enemigo1,R1
        MVI ola,R2
        CMPI #$38,R2
        BNE @@39
        CMPI #32,R0
        BNC @@40
        DECR R1
        CMPI #32,R1
@@41:   BNE @@42
        MVII #$3B,R2
        MVO R2,ola
        B @@42

@@39:   CMPI #$39,R2
        BNE @@43
        CMPI #32,R0
        BNC @@40
        INCR R1
        CMPI #72,R1
        B @@41

@@43:   CMPI #$C0,R2    ; Satélite
        BNE @@44
        MVI x_enemigo1,R2
        DECR R2
        MVO R2,x_enemigo1
        CMPI #10,R2
        BEQ @@45
        B @@38

@@44:   CMPI #$3A,R2
        BNE @@40
        MVI offset1,R2
        CMPI #$48,R2
        BC @@40
        CMP y_jugador,R1
        BEQ @@46
        MVII #$FF,R2
        BC @@47
        MVII #$01,R2
@@47:   ADD y_enemigo1,R2
        MVO R2,y_enemigo1
@@46:   MVI x_enemigo1,R2
        CMP x_jugador,R2
        BEQ @@40
        MVII #$FF,R2
        BC @@48
        MVII #$01,R2
@@48:   ADD x_enemigo1,R2
        MVO R2,x_enemigo1
@@40:   MVI offset1,R0
	CMPI #$F0,R0	; ¿Planetoides?
	BNE @@142
	MVI cuadro,R0
	ANDI #1,R0	; Desplazar más lento
	BNE @@38
@@142:	MVI avance,R2
        DECR R2
        MVO R2,avance
        ADD x_enemigo1,R2
	ANDI #$FF,R2
        CMPI #15,R2
        BNE @@38
@@45:   MVII #0,R1
@@42:   MVO R1,y_enemigo1
        MVO R1,y_enemigo2
        MVO R1,y_enemigo3
@@38:
	;
	; Mueve el campo eléctrico
	;
	MVI ye3d1,R0
	TSTR R0
	BEQ @@132
	MVI electrico,R1
	MVI offset1,R0
	CMPI #$B8,R0	; ¿Electricidad?
	BNE @@132
	CMPI #5,R1	; ¿Alcanzó el ancho horizontal?
	BNE @@133
@@134:	MVI ye3d1,R0
	ADDI #4,R0
	MVO R0,ye3d1
	MVI xe3d1,R0
	SUBI #8,R0
	MVO R0,xe3d1
	DECR R1
	BNE @@134
	B @@135
	
@@133:	INCR R1
	MVI ye3d1,R0
	SUBI #4,R0
	MVO R0,ye3d1
	MVI xe3d1,R0
	ADDI #8,R0
	MVO R0,xe3d1
	CMPI #160,R0	; ¿Se sale de la pantalla?
	BC @@134
@@135:	MVO R1,electrico
	MVI ye3d1,R0
	SUBI #8,R0
	MVO R0,ye3d2
	SUBI #8,R0
	MVO R0,ye3d3
	MVI xe3d1,R0
	MVO R0,xe3d2
	MVO R0,xe3d3
	MVI offset1,R0
	MVO R0,offset2
	MVO R0,offset3
@@132:

	MVI cuadro,R0
	TSTR R0		; ¿256 cuadros? (4 segundos)
	BNE @@54
	MVI nivel,R0
	ANDI #1,R0	; ¿Espacio?
	BEQ @@54	; Sí, no gasta gasolina
	MVI nivel,R0
	CMPI #6,R0
	MVII #-2,R1	; -2
	BNC @@82
	DECR R1		; -3
	CMPI #12,R0
	BNC @@82
	DECR R1		; -4
@@82:	ADD gasolina,R1	; Resta gasolina
	MVO R1,gasolina
	BEQ @@83	; ¿Se acabó?
	BPL @@54
	MVII #0,R1 
	MVO R1,gasolina
@@83:	CALL inicia_explosion

        ;
        ; Llega aquí si el jugador está explotando
        ;
@@54:   
	;
	; Animación de antenas de satélite
	;
	MVII #offset1,R2
	MVII #3,R3
	MVII #offset1temp,R5
@@136:	MVI@ R2,R0
	CMPI #$78,R0	; Antena
	BNE @@137
	MVI cuadro,R1
	SLR R1,2
	SLR R1,2
	ANDI #7,R1
	ADDI #antena,R1
	MVI@ R1,R0
@@137:	MVO@ R0,R5
	INCR R2
	DECR R3
	BNE @@136
        
        ;
        ; Generador de números bien aleatorios :P
        ;
MACRO ROR
	RRC R0,1
	MOVR R0,R1
	SLR R1,2
	SLR R1,2
	ANDI #$0800,R1
	SLR R1,2
	SLR R1,2
	ANDI #$007F,R0
	XORR R1,R0
ENDM
        MVI rand,R0
	SETC
	ROR
        XOR cuadro,R0
	ROR
	XOR rand,R0
	ROR
        XORI #9,R0
        MVO R0,rand
	CALL reproduce_sonido
	MVI ye3d0,R0
	TSTR R0
	BEQ bucle
	MVI offset0,R0
	CMPI #$D0,R0
	BNE bucle
	MVI cuadro,R0
	ANDI #1,R0
	BNE bucle
	MVII #48,R0
	MVO R0,psg_copia+2
	MVII #0,R0
	MVO R0,psg_copia+6
	MVII #15,R0
	MVO R0,psg_copia+13
        B bucle
        
;       RETURN                  ; Return to the EXEC and sit doing nothing.
        ENDP

;       INCLUDE "../library/print.asm"       ; PRINT.xxx routines


        ; FILLZERO - Rellena memoria con ceros
        ; FILLMEM - Rellena memoria con una constante (r0)
        ;
        ; R1 - Número de palabras
        ; R4 - Ap. a memoria para rellenar
        ;
CLRSCR: PROC
        MVII #$0F0,R1
        MVII #$200,R4
FILLZERO:
        CLRR R0         ; Pone R0 a cero
FILLMEM:
        MVO@ R0,R4      ; Guarda R0 en R4, incrementa R4
        DECR R1         ; Decrementa contador
        BNEQ FILLMEM    ; Salta si no cero
        JR R5           ; Retorna
        ENDP

	;
	; Reproduce efectos de sonido
	;
reproduce_sonido:
	MVII #0,R0
	MVO R0,psg_copia+12	; Volumen canal B
	MVI psg_copia+8,R0
	ANDI #$ED,R0
	XORI #$12,R0
	MVO R0,psg_copia+8
	MVI sonido_d1,R0
	TSTR R0
	BEQ @@1
	MVI sonido_ap1,R4
	ADDI #base_sonido,R4
	MVI@ R4,R2
	MVI@ R4,R3
	MOVR R2,R1
	ANDI #$E0,R2
	SLR R2,1
	XORI #$80,R2
	SLR R2,2
	SLR R2,2
	MVO R2,psg_copia+12	; Volumen canal B
	TSTR R3
	BEQ @@4
	MVO R3,psg_copia+1	; Periodo canal B
	SWAP R3
	MVO R3,psg_copia+5	; Periodo canal B
	MVI psg_copia+8,R1
	ANDI #$FD,R1
	MVO R1,psg_copia+8
@@4:	SWAP R1
	ANDI #$1F,R1
	BEQ @@3
	MVO R1,psg_copia+9	; Periodo ruido
	MVI psg_copia+8,R1
	ANDI #$EF,R1
	MVO R1,psg_copia+8
@@3:	DECR R0
	BNE @@2
	SUBI #base_sonido,R4
	MVO R4,sonido_ap1
	ADDI #base_sonido,R4
	MVI@ R4,R0
	ANDI #$1F,R0
@@2:	MVO R0,sonido_d1
	TSTR R0
	BNE @@1
	MVO R0,sonido_base1
@@1:	
	MVII #0,R0	
	MVO R0,psg_copia+13	; Volumen canal C
	MVI sonido_d0,R0
	TSTR R0
	BEQ @@5
	MVI sonido_ap0,R4
	ADDI #base_sonido,R4
	MVI@ R4,R2
	MVI@ R4,R3
	SWAP R2
	MVO R2,psg_copia+13	; Volumen canal C
	MVO R3,psg_copia+2	; Periodo canal C
	SWAP R3
	MVO R3,psg_copia+6	; Periodo canal C
	DECR R0
	BNE @@6
	SUBI #base_sonido,R4
	MVO R4,sonido_ap0
	ADDI #base_sonido,R4
	MVI@ R4,R0
	ANDI #$1F,R0
	BNE @@6
	MVI sonido_base0,R0
	MVO R0,sonido_ap0
	MOVR R0,R4
	ADDI #base_sonido,R4
	MVI@ R4,R0
	ANDI #$1F,R0
@@6:	MVO R0,sonido_d0
@@5:
	JR R5

	;
	; Genera un efecto de sonido
	;
efecto_sonido:	PROC
	PSHR R0
	MVI sonido_base1,R0
	CMPI #sonido_3-base_sonido,R0
	BEQ @@1
	CMPI #sonido_4-base_sonido,R0
@@1:	BNE @@2
	PULR R0
	JR R5

@@2:	PULR R0
	ENDP

efecto_sonido_prioridad:	PROC
	PSHR R4
	MVO R0,sonido_ap1
	MVO R0,sonido_base1
	MOVR R0,R4
	ADDI #base_sonido,R4
	MVI@ R4,R0
	ANDI #$1F,R0
	MVO R0,sonido_d1
	PULR R4
	JR R5
	ENDP

	;
	; Inserción de enemigo en lista visible
	;
insercion:	PROC
	MVI offset2,R0
	MVO R0,offset3
	MVI xe3d2,R0
	MVO R0,xe3d3
	MVI ye3d2,R0
	MVO R0,ye3d3
	MVI offset1,R0
	MVO R0,offset2
	MVI xe3d1,R0
	MVO R0,xe3d2
	MVI ye3d1,R0
	MVO R0,ye3d2
	JR R5
	ENDP

gana_puntos:	PROC
	MVI nivel,R4
	ANDI #1,R4
	BEQ @@1
	CMPI #$C0,R0	; ¿Pared?
	BC @@2
@@1:	SUBI #64,R0
	BC @@3
	MVII #0,R0
@@3:	SLR R0,2
	SLR R0,1
	MVII #tabla_puntos,R4
	ADDR R0,R4
	MVI@ R4,R0
	ADD puntos,R0
	MVO R0,puntos
	BNC @@2
	MVI puntos+1,R0
	ADCR R0
	MVO R0,puntos+1
	; 256 puntos cumplidos
	MVI vidas,R0
	CMPI #9,R0
	BEQ @@2
	INCR R0
	MVO R0,vidas
@@2:	JR R5

	ENDP

tabla_puntos:	PROC
	DECLE $02
	DECLE $00
	DECLE $02
	DECLE $00
	DECLE $00
	DECLE $02
	DECLE $01
	DECLE $02
	DECLE $00
	DECLE $01	; Misil vertical
	DECLE $03
	DECLE $05
	DECLE $25
	DECLE $00
	DECLE $00
	DECLE $00
	DECLE $10	; Satélite
	ENDP

adelanta_nivel: PROC
        MVI dificultad,R0
        ADDI #4,R0
        CMPI #$7F,R0
        BLE @@1
        MVII #$7F,R0
@@1:    MVO R0,dificultad
        MVI nivel,R0
        INCR R0
        MVO R0,nivel
	ENDP

graficos_nivel:	PROC
	PSHR R5
	MVI nivel,R0
	ANDI #1,R0
	BEQ @@s6

	;
	; Cambia estructuras gráficas
	;
	call espera_int
	MVII #borde_fortaleza,R4
	MVII #$0200,R5
@@s1:	MVI@ R4,R0
	TSTR R0
	BEQ @@s2
	BPL @@s3
	NEGR R0
	ADDR R0,R5
	B @@s1

@@s3:	MVI@ R4,R1
	MVO@ R1,R5
	DECR R0
	BNE @@s3
	B @@s1

@@s2:	MVI@ R4,R0
	TSTR R0
	BEQ @@s4
	MVI@ R4,R1
@@s5:	MVO@ R1,R5
	DECR R0
	BNE @@s5
	B @@s1
@@s4:

	B @@s12

@@s6:
	call espera_int
	MVI inicia_sprites,R0
	TSTR R0
	BNE @@s6
	MVII #$80,R0
	MVO R0,inicia_sprites
	call espera_int
	MVII #$00,R0
	MVO R0,pixel
	MVII #tabla_estrellas,R2
	MVII #$0228,R3
	MVII #12,R1
@@s7:	MVI@ R2,R0
	MVII #20,R5
@@s10:	CMPI #$0200,R3
	BNC @@s8
	CMPI #$02F0,R3
	BC @@s8
	MVO@ R0,R3
@@s8:	INCR R3
	MOVR R3,R4
	ANDI #$03,R4
	BNE @@s9
	SUBI #20,R3
@@s9:	SUBI #8,R0
	CMPI #($124-1)*8+COLOR_ESTRELLA,R0
	BNE @@s11
	MVII #($124+19)*8+COLOR_ESTRELLA,R0
@@s11:	DECR R5
	BNE @@s10
	ADDI #100,R3
	INCR R2
	DECR R1
	BNE @@s7
@@s12:
        PULR R5
	B sel_nivel
        ENDP
        
sel_nivel2:     PROC
        MVII #$50,R0
        MVO R0,gasolina
        MVII #72,R0
        MVO R0,y_jugador
        ENDP
        
sel_nivel:      PROC
        MVI nivel,R0
        ANDI #7,R0
        ADDI #niveles,R0
	MOVR R0,R4
	MVI@ R4,R0
        MVO R0,lector
        SWAP R0
        MVO R0,lector+1
        MVII #0,R0
        MVO R0,byte
        MVO R0,ola
        MVO R0,secuencia
        MVO R0,explosion
        MVO R0,ye3d0
        MVO R0,ye3d1
        MVO R0,ye3d2
        MVO R0,ye3d3
        MVO R0,y_enemigo1
        MVO R0,y_enemigo2
        MVO R0,y_enemigo3
        MVII #10,R0
        MVO R0,tiempo
        JR R5
        ENDP

lee_byte:       PROC
        MVI lector,R0
        MVI lector+1,R1
        SWAP R1
        XORR R1,R0
        MOVR R0,R4
        MVI@ R4,R0
        MVI byte,R2
        XORI #1,R2
        BNE @@1
        SWAP R0
@@1:    JR R5
        ENDP
        
adelanta_lector:        PROC
        MVI byte,R2
        XORI #1,R2
        MVO R2,byte
        BNE @@2
        MVI lector,R2
        MVI lector+1,R3
        INCR R2
        BNE @@1
        INCR R3
@@1:    MVO R2,lector
        MVO R3,lector+1
@@2:    JR R5
        ENDP

inicia_explosion:	PROC
	MVI x_jugador,R0
	MVO R0,xe3d1
	MVO R0,xe3d2
	MVO R0,xe3d3
	MVII #$48,R0
	MVO R0,offset1
	MVO R0,offset2
	MVO R0,offset3
	MVII #0,R0
	MVO R0,x_bala
	MVO R0,y_bala
	MVO R0,x_bala2
	MVO R0,y_bala2
	MVO R0,ye3d0
	MVI yj3d,R0
	MVO R0,ye3d2
	ADDI #8,R0
	MVO R0,ye3d1
	SUBI #16,R0
	MVO R0,ye3d3
	MVII #60,R0	; Duración de la explosión en cuadros
	MVO R0,explosion
	; Efecto de sonido: explosión
	MVII #sonido_3-base_sonido,R0
	B efecto_sonido_prioridad
	;JR R5
	ENDP
        
        ;
        ; Espera a que ocurra una interrupción
        ;
espera_int: PROC
        CLRR    R0
        MVO     R0,     WFLAG   ; Borra la bandera de espera
@@1     CMP     WFLAG,  R0      ; Espera a que cambie
        BEQ     @@1
	;
	; Actualiza el sonido	
	;
	MVII #psg_copia,R4
	MVII #$01F0,R3
	MVII #14,R1
@@2:	MVI@ R4,R0
	MVO@ R0,R3
	INCR R3
	DECR R1
	BNE @@2
        JR      R5              ; Retorna
        ENDP


        ;
        ; Rutina de interrupción
        ;
vector_int:     PROC
        BEGIN

        MVO     R0,     $20     ; Activa el display
        MVI     $21,    R0      ; Activa modo de 64 definiciones de sprites
        MVII    #1,     R0
        MVO     R0,     WFLAG   ; Indica que sucedió interrupción
        MVII    #0,     R0
        MVO     R0,     $28     ; Color stack 0
        MVO     R0,     $2A     ; Color stack 2
        MVO     R0,     $2C     ; Color del borde
        MVI nivel,R1
	ANDI #$01,R1
	BEQ @@0
	MVII #1,R0
@@0:	MVO     R0,     $29     ; Color stack 1
        MVO     R0,     $2B     ; Color stack 3
        ; Verifica si inicia sprites por defecto
        MVI inicia_sprites,R0
	CMPI #$80,R0
	BNE @@vi20
	MVII #0,R0
	MVO R0,inicia_sprites
	MVII #dibujo_estrellas,R4
	MVII #$3920,R5
	MVII #20,R0
	B @@vi3

@@vi20:	TSTR R0
        BEQ @@vi0
        DECR R0
        MVO R0,inicia_sprites
        MVII #tabla_sprites,R4
        MVII #$3810,R5
        SLL R0,2
        SLL R0,2
        SLL R0,2
        ADDR R0,R4
        SLL R0,1
        ADDR R0,R5
        MVII #16,R0
@@vi3:
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        DECR R0
        BNE @@vi3

	MVII	#0,R0
	MVO 	R0,$18
	MVO 	R0,$19
	MVO 	R0,$1E
	MVO	R0,colision0
	MVO	R0,colision2
	MVO	R0,colision6        
	MVO	R0,$00
	MVO	R0,$01
	MVO 	R0,$02
	MVO 	R0,$03
	MVO	R0,$04
	MVO 	R0,$05
	MVO 	R0,$06
	MVO 	R0,$07
        B @@vi2
        
@@vi0:
	MVI  	$18,	R0	; Colisión 0
	MVO	R0,colision0
	MVI	$1A,	R0	; Colisión 2
	MVO 	R0,colision2
	MVI	$1E,	R0	; Colisión 6
	MVO 	R0,colision6
	MVII	#0,R0
	MVO 	R0,$18
	MVO 	R0,$1A
	MVO 	R0,$1E  

	; Scroll suave de las estrellas
	MVI nivel,R0
	ANDI #1,R0
	BNE @@vi21
	MVI cuadro,R0
	ANDI #1,R0
	BNE @@vi21
	MVI pixel,R0
	CMPI #$FF,R0
	BEQ @@vi21
	MOVR R0,R5
	SLR R0,2
	ANDI #7,R0
	ANDI #$F8,R5
	ADDR R0,R5
	ADDI #$3920,R5
	MVII #0,R1
	MVO@ R1,R5
	MVI pixel,R0
	INCR R0
	CMPI #160,R0
	BNE @@vi22
	MVII #0,R0
@@vi22:	MVO R0,pixel
	ANDI #7,R0
	MVII #$01,R1
	BEQ @@vi23
@@vi24:	SLL R1,1
	DECR R0
	BNE @@vi24
@@vi23:	MVI pixel,R0
	MOVR R0,R5
	SLR R0,2
	ANDI #7,R0
	ANDI #$F8,R5
	ADDR R0,R5
	ADDI #$3920,R5
	MVO@ R1,R5
@@vi21:      

        ; Define el sprite de la nave
        MVI sprite_nave,R0
        MVI ajuste_nave,R1
        ADDR R1,R0
        ADDI #sprites_nave,R0
        MOVR R0,R4
        MVII #$3800,R5

        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5

        ; Define la sombra de la nave
        MVI sprite_nave,R0
        CMPI #$0c,R0
        BLT @@vi1
        SUBI #$0c,R0
        CMPI #$0c,R0
        BLT @@vi1
        SUBI #$0c,R0
@@vi1:  ADDI #$24,R0
        ADDI #sprites_nave,R0
        MOVR R0,R4

        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        MVI@    R4,     R1
        MVO@    R1,     R5
        SWAP    R1
        MVO@    R1,     R5
        
        ; Dibuja los sprites correspondientes
        MVII #$0,R5     ; Coordenadas X
        MVI offset9,R0
	CMPI #$FF,R0
	MVII #$100,R0
	BEQ @@vi25
	MVI x_jugador,R0
        MOVR R0,R1
        SLR R1,1
        MVI y_jugador,R2
        ADDI #8,R2
        SUBR R1,R2
        MVO R2,yj3d
        NEGR R2
        ADDI #104,R2
        XORI #$0100,R2
        MVII #38,R3
        SUBR R1,R3
        NEGR R3
        ADDI #104,R3
        XORI #$0100,R3
        ADDI #$0700,R0
@@vi25: MVO@ R0,R5      ; Nave
	MVI nivel,R1
	ANDI #1,R1
	BEQ @@vi12
        MVI offset9,R1
        TSTR R1
        BEQ @@vi10
@@vi12: MVII #0,R0      ; Desactiva
@@vi10: MVO@ R0,R5      ; Sombra
        MVI x_bala,R1
        ADDI #$0700,R1
        MVO@ R1,R5      ; Bala jugador
        MVI xe3d0,R1
        ADDI #$0700,R1
        MVO@ R1,R5      ; Enemigo 0
        MVI xe3d1,R1
        ADDI #$0700,R1
        MVO@ R1,R5      ; Enemigo 1
        MVI xe3d2,R1
        ADDI #$0700,R1
        MVO@ R1,R5      ; Enemigo 2
        MVI xe3d3,R1
        ADDI #$0700,R1
        MVO@ R1,R5      ; Enemigo 3
        MVI x_bala2,R1
        ADDI #$0700,R1
        MVO@ R1,R5      ; Bala enemigos

        MVII #$8,R5     ; Coordenadas Y
        MVO@ R2,R5      ; Nave
        MVO@ R3,R5      ; Sombra
        MVI y_bala,R0
        TSTR R0
        BEQ @@vi9
        NEGR R0
        ADDI #104,R0
@@vi9:  XORI #$0100,R0
        MVO@ R0,R5      ; Bala jugador
        MVI ye3d0,R0
        TSTR R0
        BEQ @@vi4
        NEGR R0
        ADDI #104,R0
@@vi4:  XORI #$0100,R0
        MVO@ R0,R5      ; Enemigo 0
        MVI ye3d1,R0
        TSTR R0
        BEQ @@vi5
        NEGR R0
        ADDI #104,R0
@@vi5:  XORI #$0100,R0
	MVI offset1,R1
	CMPI #$A0,R1
	BEQ @@vi18
	CMPI #$C0,R1
	BNE @@vi17
@@vi18:	XORI #$0080,R0
@@vi17: MVO@ R0,R5      ; Enemigo 1
        MVI ye3d2,R0
        TSTR R0
        BEQ @@vi6
        NEGR R0
        ADDI #104,R0
@@vi6:  XORI #$0100,R0
        MVI offset2,R1
	CMPI #$20,R1
	BNE @@vi19
	XORI #$0080,R0
@@vi19:	MVO@ R0,R5      ; Enemigo 2
        MVI ye3d3,R0
        TSTR R0
        BEQ @@vi7
        NEGR R0
        ADDI #104,R0
@@vi7:  XORI #$0100,R0
        MVO@ R0,R5      ; Enemigo 3
        MVI y_bala2,R0
        TSTR R0
        BEQ @@vi8
        NEGR R0
        ADDI #104,R0
@@vi8:  XORI #$0100,R0
        MVO@ R0,R5      ; Bala enemigos

MACRO COLOR_SPRITE
	MVII #color_sprites+3,R4
	MOVR R0,R3
	SLR R3,2
	SLR R3,1
	ADDR R3,R4
	MVI@ R4,R3
	ADDR R3,R0
ENDM

        MVII #$10,R5    ; Colores y figuras
        MVI offset9,R0
        TSTR R0
        BEQ @@vi14
	COLOR_SPRITE
        ADDI #$0820,R0
	B @@vi11

@@vi14:	MVII #$0807,R0
@@vi11: MVO@ R0,R5      ; Nave
        MVII #$0808,R0
        MVO@ R0,R5      ; Sombra
        MVII #$0817,R0
        MVO@ R0,R5      ; Bala jugador
        MVI offset0,R0
	COLOR_SPRITE
        ADDI #$0820,R0
        MVO@ R0,R5      ; Enemigo 0
        MVI offset1temp,R0
	COLOR_SPRITE
        ADDI #$0820,R0
        MVO@ R0,R5      ; Enemigo 1
        MVI offset2temp,R0
	COLOR_SPRITE
        ADDI #$0820,R0
        MVO@ R0,R5      ; Enemigo 2
        MVI offset3temp,R0
	COLOR_SPRITE
        ADDI #$0820,R0
        MVO@ R0,R5      ; Enemigo 3
        MVII #$0816,R0
        MVO@ R0,R5      ; Bala enemigos

	;
	; El GRAM es accesible por más tiempo en el VBLANK
	; Así que aquí se actualiza la pantalla
	;
MACRO DIGITO
	ADDI #8,R2
	SUBR R1,R0
	BC $-3
	ADDR R1,R0
	MVO@ R2,R5
ENDM
	;
	; Ilustra la puntuación
	;
	MVI puntos,R0
	MVI puntos+1,R1
	SWAP R1
	XORR R1,R0
	MVII #$200,R5
	MVII #$33*8+$0005,R2
	MVO@ R2,R5
	INCR R5
	MVII #1000,R1
	MVII #$0F*8+$0006,R2
	DIGITO
	MVII #100,R1
	MVII #$0F*8+$0006,R2
	DIGITO
	MVII #10,R1
	MVII #$0F*8+$0006,R2
	DIGITO
	MVII #1,R1
	MVII #$0F*8+$0006,R2
	DIGITO
	;
	; Dibuja el total de vidas
	;
	MVI vidas,R0
	MVII #1,R1
	MVII #$2D9,R5
	MVII #$0103*8+$0005,R2
	MVO@ R2,R5
	INCR R5
	MVII #$0F*8+$0006,R2
	DIGITO
	;
	; Dibuja la barra de combustible
	;
	MVII #$02E9,R5
	MVII #$26*8+$0005,R2
	MVO@ R2,R5
	INCR R5
	MVI gasolina,R0
	ADDI #$07,R0
	SLR R0,2
	SLR R0,1
	MVII #5,R1
@@vi15:	MVII #$00*8+$0003,R2
	TSTR R0
	BEQ @@vi16
	MVII #$A5*8+$0003,R2
	DECR R0
	BEQ @@vi16
	MVII #$5F*8+$0003,R2
	DECR R0
@@vi16:	MVO@ R2,R5
	DECR R1
	BNE @@vi15

@@vi2:
        ; Incrementa el número de cuadro
        MVI cuadro,R0
        INCR R0
        MVO R0,cuadro

        RETURN
        ENDP

sprites_nave:   PROC
        ; Nave grande ($00)
        DECLE $6d46
        DECLE $feef
        DECLE $78fc
        DECLE $1c38
        ; Nave media ($08)
        DECLE $6c40
        DECLE $fe6a
        DECLE $70fc
        DECLE $0030
        ; Nave chica ($10)
        DECLE $3420
        DECLE $7c7a
        DECLE $1030
        DECLE $0000
        ; Nave grande yendo a izq. ($18)
        DECLE $cb86
        DECLE $fe6f
        DECLE $78fc
        DECLE $001c
        ; Nave media yendo a izq. ($20)
        DECLE $cc80
        DECLE $fe56
        DECLE $70fc
        DECLE $0000
        ; Nave chica yendo a izq. ($28)
        DECLE $6440
        DECLE $3c7a
        DECLE $0030
        DECLE $0000
        ; Nave grande yendo a der. ($30)
        DECLE $6f26
        DECLE $feed
        DECLE $387C
        DECLE $0818
        ; Nave media yendo a der. ($38)
        DECLE $6c20
        DECLE $faee
        DECLE $707c
        DECLE $1030
        ; Nave chica yendo a der. ($40)
        DECLE $7410
        DECLE $3c7a
        DECLE $1038
        DECLE $0010
        ; Sombra chica ($48)
        DECLE $7c48
        DECLE $3078
        DECLE $0020
        DECLE $0000
        ; Sombra media ($50)
        DECLE $6c40
        DECLE $7c7e
        DECLE $1030
        DECLE $0000
        ; Sombra grande ($58)
        DECLE $7e6c
        DECLE $7c7e
        DECLE $3070
        DECLE $0000
        
        ENDP
        
        ; Sin uso ($28)
;        DECLE $7E3C
;        DECLE $FFDB
;        DECLE $C3FF
;        DECLE $3C66

tabla_sprites:  PROC
        ; Disparo ($10)
        DECLE $00F0
        DECLE $0000
        DECLE $0000
        DECLE $0000
        ; Nave media (carácter $103)
        DECLE $6c40
        DECLE $fe6a
        DECLE $70fc
        DECLE $0030
        ; Antena 2 ($00)
        DECLE $381C
        DECLE $3837
        DECLE $1C3E
        DECLE $3818
        ; Antena 3 ($08)
        DECLE $1C38
        DECLE $1CEC
        DECLE $387C
        DECLE $1C18
        ; Antena 4 ($10)
        DECLE $2E5C
        DECLE $2E16
        DECLE $0C3E
        DECLE $1C18
        ; Antena 5 ($18)
        DECLE $3E5E
        DECLE $3E3E
        DECLE $0C1E
        DECLE $1C18
        ; Robotote ($20) (mitad der.)
        DECLE $3000
        DECLE $FF0C
        DECLE $0F0F
        DECLE $FFCC
        DECLE $FFCC
        DECLE $FFCC
        DECLE $FFCC
        DECLE $3CCC
        ; Avión grande ($30)
        DECLE $4202
        DECLE $3E66
        DECLE $F85C
        DECLE $04CC
        ; Avión medio ($38)
        DECLE $4200
        DECLE $3E66
        DECLE $785C
        DECLE $040C
        ; Avión chico ($40)
        DECLE $4400
        DECLE $3C6C
        DECLE $7058
        DECLE $0818
        ; Explosión 1 ($48)
        DECLE $6600
        DECLE $1238
        DECLE $566C
        DECLE $0008
        ; Cañón mirando a la der. ($50)
        DECLE $3C00
        DECLE $3A7E
        DECLE $7E44
        DECLE $397B
        ; Explosión 2 ($58)
        DECLE $A649
        DECLE $1358
        DECLE $6644
        DECLE $2299
        ; Agujero ($60)
        DECLE $3800
        DECLE $C36E
        DECLE $76C3
        DECLE $183E
        ; Cañón mirando a la izq. ($68)
        DECLE $3C00
        DECLE $5C7E
        DECLE $7E22
        DECLE $9CDE
        ; Combustible ($70)
        DECLE $7E3C
        DECLE $5A3C
        DECLE $7E66
        DECLE $3C7E
        ; Antena ($78)
        DECLE $743A
        DECLE $7468
        DECLE $307C
        DECLE $3818
        ; Agujero disparando ($80)
        DECLE $5C28
        DECLE $DF3A
        DECLE $7FEB
        DECLE $5FBE
        ; Misil vertical ($88)
        DECLE $3810
        DECLE $3838
        DECLE $7C38
        DECLE $3838
        ; Alienígena ($90)
        DECLE $7C38
        DECLE $BA7C
        DECLE $44BA
        DECLE $387C
        ; Misil teledirigido ($98)
        DECLE $0A02
        DECLE $1C0E
        DECLE $F07E
        DECLE $00C0
        ; Robotote ($a0)
        DECLE $C030
        DECLE $C3FC
        DECLE $CFC3
        DECLE $CFFF
        DECLE $CCFF
        DECLE $CFFC
        DECLE $3FFF
        DECLE $0003
        ; Adorno en pared de fortaleza ($b0)
        DECLE $DCB8
        DECLE $F3EE
        DECLE $FCFF
        DECLE $C0F0
        ; Electricidad ($b8)
	DECLE $5948
	DECLE $852B
	DECLE $5948
	DECLE $052B
        ; Satélite ($c0)
        DECLE $7C30
        DECLE $7A7E
        DECLE $3A7A
        DECLE $205E
        DECLE $183E
        DECLE $3050
        DECLE $1418
        DECLE $1038
        ; Mira ($d0)
        DECLE $4400
        DECLE $0028
        DECLE $4428
        DECLE $0000
        ; Antena 6 ($D8)
        DECLE $3E1C
        DECLE $3E3E
        DECLE $1C3E
        DECLE $3818
        ; Adorno 2 ($e0)
        DECLE $F0C0
        DECLE $FFFC
        DECLE $FCFF
        DECLE $C0F0
        ; Adorno de piso ($e8)
        DECLE $3C08
        DECLE $CFF2
        DECLE $7F3F
        DECLE $307C
        ; Planetoide ($f0)
        DECLE $3D1B
        DECLE $7A7D
        DECLE $8E76
        DECLE $D8BC
        ; Planetoide ($f8)
        DECLE $3800
        DECLE $7C7C
        DECLE $7C7C
        DECLE $0038
	ENDP

dibujo_estrellas:	PROC
	; $00
	DECLE $0000,$0000,$0000,$0000
	; $01
	DECLE $0000,$0000,$0000,$0000
	; $02
	DECLE $0000,$0000,$0000,$0000
	; $03
	DECLE $0000,$0000,$0000,$0000
	; $04
	DECLE $0000,$0000,$0000,$0000
	; $05
	DECLE $0000,$0000,$0000,$0000
	; $06
	DECLE $0000,$0000,$0000,$0000
	; $07
	DECLE $0000,$0000,$0000,$0000
	; $08
	DECLE $0000,$0000,$0000,$0000
	; $09
	DECLE $0000,$0000,$0000,$0000
	; $0a
	DECLE $0000,$0000,$0000,$0000
	; $0b
	DECLE $0000,$0000,$0000,$0000
	; $0c
	DECLE $0000,$0000,$0000,$0000
	; $0d
	DECLE $0000,$0000,$0000,$0000
	; $0e
	DECLE $0000,$0000,$0000,$0000
	; $0f
	DECLE $0000,$0000,$0000,$0000
	; $10
	DECLE $0000,$0000,$0000,$0000
	; $11
	DECLE $0000,$0000,$0000,$0000
	; $12
	DECLE $0000,$0000,$0000,$0000
	; $13
	DECLE $0000,$0000,$0000,$0000

	ENDP

dibujo_abismos:	PROC
	DECLE $0000,$E080,$F0F8,$7060	; $124 - Abismo entrada 1
	DECLE $7F7F,$1F3F,$030F,$0001	; $125 - Abismo entrada 2
	DECLE $C080,$C0E0,$C080,$FFF8	; $126 - Abismo entrada 3
	DECLE $7F7F,$0F3F,$0003,$0000	; $127 - Abismo entrada 4
	DECLE $C080,$C080,$FCF0,$FCF8	; $128 - Abismo entrada 5
	DECLE $0F1F,$0307,$0001,$0000	; $129 - Abismo entrada 6
	DECLE $C000,$C080,$E0F0,$FEF0	; $12A - Abismo entrada 7
	DECLE $1FFF,$0000,$0000,$0000	; $12B - Abismo entrada 8
	DECLE $0000,$0000,$0000,$0000
	DECLE $8000,$6018,$040C,$1C0F	; $12D - Abismo salida 1
	DECLE $0000,$0000,$0000,$0000
	DECLE $20C0,$3010,$3870,$0106	; $12F - Abismo salida 2
	DECLE $0000,$0000,$0000,$0000
	DECLE $30C0,$3870,$0204,$0306	; $131 - Abismo salida 3
	DECLE $0000,$0000,$0000,$0000
	DECLE $20C0,$3860,$1808,$010F	; $133 - Abismo salida 4
	ENDP

dibujo_muros:	PROC
	; $124 - $00+$01
	DECLE $0000,$0000,$2000,$F870	; 1 - Tope izq.
	DECLE $BE7C,$EFDF,$BB77,$EEDD	; 2 - Intermedio 1
	; $126 - $02+$02
	DECLE $AA66,$EECC,$BB77,$EEDD	; 3 - Intermedio 2
	DECLE $AA66,$EECC,$BB77,$EEDD	; 3 - Intermedio 2
	; $128 - $03+nada
	DECLE $2A66,$0E0C,$0307,$0001	; 4 - Intermedio 3
	DECLE $0000,$0000,$0000,$0000
	; $12A - $04+$05
	DECLE $0000,$8000,$80C0,$C040	; 5 - Hueco 1
	DECLE $A0C0,$F870,$BE7C,$EEDF	; 6 - Hueco 2
	; $12C - $06+$07
	DECLE $0000,$8000,$A0C0,$F870	; 7 - Tope der.
	DECLE $B87C,$ECD4,$A86C,$ECC4	; 8 - Lado der 1.
	; $12E - $08+$08
	DECLE $A86C,$ECC4,$A86C,$ECC4	; 9 - Lado der 2.
	DECLE $A86C,$ECC4,$A86C,$ECC4	; 9 - Lado der 2.
	; $130 - $09+nada
	DECLE $286C,$0000,$0000,$0000	; 10 - Inf. der.
	DECLE $0000,$0000,$0000,$0000
	; $132 - $06+$01
	DECLE $0000,$8000,$A0C0,$F870	; 7 - Tope der.
	DECLE $BE7C,$EFDF,$BB77,$EEDD	; 2 - Intermedio 1
	; $134 - $00+$07
	DECLE $0000,$0000,$2000,$F870	; 1 - Tope izq.
	DECLE $B87C,$ECD4,$A86C,$ECC4	; 8 - Lado der 1.
	; $136 - $04+$0a
	DECLE $0000,$8000,$80C0,$C040	; 5 - Hueco 1
	DECLE $A0C0,$F870,$BE7C,$EFDF	; 11 - Hueco 3
	; $138 - $0b+$02
	DECLE $AB67,$EECD,$BB77,$EEDD	; 12 - Hueco 4
	DECLE $AA66,$EECC,$BB77,$EEDD	; 3 - Intermedio 2
	; $13A - $0C+$05
	DECLE $0000,$0000,$0000,$8000	; 13 - Hueco 5
	DECLE $A0C0,$F870,$BE7C,$EEDF	; 6 - Hueco 2
	; $13C - $00+$07
	DECLE $0000,$0000,$2000,$F870	; 1 - Tope izq.
	DECLE $B87C,$ECD4,$A86C,$ECC4	; 8 - Lado der 1.

        ENDP

color_sprites:	proc
	decle $0007
	decle $0000
	decle $000f
	decle $0007	; Antena 2
	decle $0007	; Antena 3
	decle $0007	; Antena 4
	decle $0007	; Antena 5
	decle $0007	; Antena 6
	decle $0007
	decle $1001	; Avión grande
	decle $1001	; Avión medio
	decle $1001	; Avión chico
	decle $0002	; Explosión 1
	decle $0005	; Cañón mirando a la der.
	decle $1002	; Explosión 2
	decle $0003	; Agujero
	decle $0005	; Cañón mirando a la izq.
	decle $1001	; Combustible
	decle $0007	; Antena
	decle $0002	; Agujero disparando
	decle $1006	; Misil vertical
	decle $0002	; Alienígena
	decle $1002	; Misil teledirigido
	decle $0007	; Robotote
	decle $0007	; Robotote
	decle $1003	; Adorno en pared de fortaleza
	decle $0007
	decle $1000	; Satélite
	decle $1000
	decle $1002	; Mira
	decle $0007
	decle $0006	; Adorno 2
	decle $1000	; Adorno de piso
	decle $0004	; Planetoide
	decle $0001	; Planetoide
	endp

	; Tabla de niveles
niveles:	PROC
	DECLE espacio_1
	DECLE fortaleza_1
	DECLE espacio_2
	DECLE fortaleza_2
	DECLE espacio_3
	DECLE fortaleza_3
	DECLE espacio_4
	DECLE fortaleza_4
	ENDP

        ; Espacio 1
espacio_1:      PROC
        DECLE $38F0
        DECLE $3A39
        DECLE $3B34
        DECLE $3C48
        DECLE $3D34
        DECLE $C020
        DECLE $3B39
        DECLE $3C20
        DECLE $3D34
        DECLE $3848
        DECLE $343A
        DECLE $0000
        ENDP

	; Fortaleza 1
fortaleza_1:	PROC
	DECLE $D6DF
	DECLE $7170
	DECLE $E96B
	DECLE $E862
	DECLE $7963
	DECLE $5368
	DECLE $61E8
	DECLE $62E8
	DECLE $6A70
	DECLE $63EA
	DECLE $6079
	DECLE $63EA
	DECLE $7252
	DECLE $6A61
	DECLE $BC78
	DECLE $709B
	DECLE $7373
	DECLE $9379
	DECLE $516A
	DECLE $716B
	DECLE $6260
	DECLE $6278
	DECLE $E6C6
	DECLE $0000	; Fin del nivel
	ENDP

        ; Espacio 2
espacio_2:	PROC
	DECLE $3AF1
	DECLE $C020
	DECLE $343B
	DECLE $343C
	DECLE $343D
	DECLE $3A38
	DECLE $3948
	DECLE $483B
	DECLE $343C
	DECLE $483D
	DECLE $39C0
	DECLE $343A
	DECLE $0000	; Fin del nivel
	ENDP

	; Fortaleza 2
fortaleza_2:	PROC
	DECLE $CEDF
	DECLE $4342
	DECLE $7171
	DECLE $EA60
	DECLE $E863
	DECLE $7A61
	DECLE $5168
	DECLE $6B6A
	DECLE $7279
	DECLE $BC9B
	DECLE $61E8
	DECLE $6093
	DECLE $BD68
	DECLE $7273
	DECLE $7B78
	DECLE $73BC
	DECLE $7972
	DECLE $BD9B
	DECLE $7040
	DECLE $9393
	DECLE $4393
	DECLE $717A
	DECLE $A37B
	DECLE $E6CE
	DECLE $0000	; Fin de nivel
	ENDP

        ; Espacio 3
espacio_3:	PROC
	DECLE $483B
	DECLE $343C
	DECLE $203D
	DECLE $38C0
	DECLE $3A39
	DECLE $3934
	DECLE $203B
	DECLE $343C
	DECLE $483D
	DECLE $0038	; Fin de nivel
	ENDP

        ; Fortaleza 3 (46 bytes + 1 final)
fortaleza_3:	PROC
	DECLE $CEDF
	DECLE $6A70
	DECLE $63EA
	DECLE $6079
	DECLE $63EA
	DECLE $7252
	DECLE $6A61
	DECLE $BC78
	DECLE $709B
	DECLE $7373
	DECLE $9379
	DECLE $516A
	DECLE $716B
	DECLE $6260
	DECLE $6278
	DECLE $7170
	DECLE $E96B
	DECLE $E862
	DECLE $7963
	DECLE $5368
	DECLE $61E8
	DECLE $62E8
	DECLE $E6C6
	DECLE $0000	; Fin de nivel
	ENDP

        ; Espacio 4
espacio_4:	PROC
	DECLE $483B
	DECLE $343C
	DECLE $483D
	DECLE $39C0
	DECLE $343A
	DECLE $203A
	DECLE $483A
	DECLE $3BC0
	DECLE $3C34
	DECLE $3D34
	DECLE $3834
	DECLE $0039
	ENDP

        ; Fortaleza 4 (48 bytes + 1 final)
fortaleza_4:	PROC
	DECLE $C6DF
	DECLE $BC9B
	DECLE $61E8
	DECLE $6093
	DECLE $BD68
	DECLE $7273
	DECLE $7B78
	DECLE $73BC
	DECLE $7972
	DECLE $4342
	DECLE $7171
	DECLE $EA60
	DECLE $E863
	DECLE $7A61
	DECLE $9368
	DECLE $6A51
	DECLE $796B
	DECLE $9B72
	DECLE $40BD
	DECLE $9370
	DECLE $4393
	DECLE $717A
	DECLE $A37B
	DECLE $E6C6
	DECLE $0000	; Fin de nivel
	ENDP

base_sonido:
	DECLE $0000

	; Disparo del jugador
sonido_1:
	DECLE $0481,$0000
	DECLE $0682,$0000
	DECLE $0983,$0000
	DECLE $0943,$0000
	DECLE $0903,$0000
	DECLE $0000

	; Disparo enemigo
sonido_2:
	DECLE $00E1,$0040
	DECLE $00C1,$0010
	DECLE $00A1,$0020
	DECLE $0081,$0010
	DECLE $0061,$0060
	DECLE $0000

	; Explosión
sonido_3:
	DECLE $0882,$0000
	DECLE $09E3,$0000
	DECLE $0AE3,$0000
	DECLE $0BA2,$0000
	DECLE $0C62,$0000
	DECLE $1062,$0000
	DECLE $1462,$0000
	DECLE $1C65,$0000
	DECLE $1F05,$0000
	DECLE $1F05,$0000
	DECLE $0000

	; Lanzamiento
sonido_4:
	DECLE $1F8A,$0000
	DECLE $10EA,$0000
	DECLE $0EF4,$0000
	DECLE $0000

	; Los siguientes cuatro son sonidos de fondo continuos

	; Satélite
sonido_5:
	DECLE $0A07,$0040
	DECLE $0A03,$0100
	DECLE $0C07,$0040
	DECLE $0C03,$0100
	DECLE $0000

	; Misil teledirigido
sonido_6:
	DECLE $0F01,$0018
	DECLE $0F02,$0060
	DECLE $0F03,$0090
	DECLE $0000

	; Electricidad
sonido_7:
	DECLE $0802,$0030
	DECLE $0F01,$0018
	DECLE $0C02,$0060
	DECLE $0000

	; Robotote
sonido_8:
	DECLE $0C05,$0080
	DECLE $0C05,$0040
	DECLE $0C05,$0060
	DECLE $0C05,$0100
	DECLE $0C05,$0080
	DECLE $0C05,$00C0
	DECLE $0000

	; Música de Game Over
sonido_9:
	; !!!
	DECLE $0000

	; Offset Y de elementos en fortaleza
offset_y:	PROC
	DECLE 35
	DECLE 45
	DECLE 55
	DECLE 65
	DECLE 81
	DECLE 105
	DECLE 113
	DECLE 107
	ENDP

	; Estructura de bordes para la fortaleza
borde_fortaleza:
;	DECLE -16
;	DECLE 4,148*8+1,150*8+1,152*8+1,154*8+1
;	DECLE -12
;	DECLE 4,148*8+1,150*8+1,152*8+1,154*8+1
;	DECLE 0,4,95*8+1
	DECLE -8
	DECLE 4,148*8+1,150*8+1,152*8+1,154*8+1
	DECLE 0,8,95*8+1
	DECLE -4
	DECLE 4,148*8+1,150*8+1,152*8+1,154*8+1
	DECLE 0,12,95*8+1
	DECLE 4,148*8+1,150*8+1,152*8+1,154*8+1
	DECLE 0,16,95*8+1

COLOR_RAYA:	EQU $0004

	DECLE 1,$2000
	DECLE 0,17,0*8+0
	DECLE 2,166*8+COLOR_RAYA,168*8+COLOR_RAYA
	DECLE 0,14,0*8+0
	DECLE 4,166*8+COLOR_RAYA,168*8+COLOR_RAYA,170*8+COLOR_RAYA,172*8+COLOR_RAYA
	DECLE 0,2,0*8+0
	DECLE 0,10,0*8+0
	DECLE 4,166*8+COLOR_RAYA,168*8+COLOR_RAYA,170*8+COLOR_RAYA,172*8+COLOR_RAYA
	DECLE 0,6,0*8+0
	DECLE 0,6,0*8+0
	DECLE 4,166*8+COLOR_RAYA,168*8+COLOR_RAYA,170*8+COLOR_RAYA,172*8+COLOR_RAYA
	DECLE 0,10,0*8+0
	DECLE 0,2,0*8+0
	DECLE 4,166*8+COLOR_RAYA,168*8+COLOR_RAYA,170*8+COLOR_RAYA,172*8+COLOR_RAYA
	DECLE 0,14,0*8+0
	DECLE 2,170*8+COLOR_RAYA,172*8+COLOR_RAYA
	DECLE 0,18,0*8+0

	DECLE 1,$2000+95*8+1
	DECLE 0,15,95*8+1
	DECLE 4,$2000+148*8+0,150*8+0,152*8+0,154*8+0
	DECLE 0,1,$2000+95*8+1
	DECLE 0,11,95*8+1
	DECLE 4,$2000+148*8+0,150*8+0,152*8+0,154*8+0
	DECLE 0,1,$2000
	DECLE 0,3,0
	DECLE 0,8,95*8+1
	DECLE 4,$2000+148*8+0,150*8+0,152*8+0,154*8+0
	DECLE 0,1,$2000
	DECLE 0,7,0
;	DECLE 0,4,95*8+1
;	DECLE 4,$2000+148*8+0,150*8+0,152*8+0,154*8+0
;	DECLE 0,1,$2000
;	DECLE 0,11,0
;	DECLE 4,$2000+148*8+0,150*8+0,152*8+0,154*8+0
;	DECLE 0,1,$2000
;	DECLE 0,15,0
	DECLE 0,0

	; Cuadros para antena animada
antena:	PROC
	DECLE $78,$00,$08,$10,$18,$D8,$D8,$78
	ENDP

	; Gráficos para pared
graficos_pared:
	DECLE $0000,$0000,$2000,$F870	; 1 - Tope izq.
	DECLE $BE7C,$EFDF,$BB77,$EEDD	; 2 - Intermedio 1
	DECLE $AA66,$EECC,$BB77,$EEDD	; 3 - Intermedio 2
	DECLE $2A66,$0E0C,$0307,$0001	; 4 - Intermedio 3
	DECLE $0000,$8000,$80C0,$C040	; 5 - Hueco 1
	DECLE $A0C0,$F870,$BE7C,$EEDF	; 6 - Hueco 2
	DECLE $0000,$8000,$A0C0,$F870	; 7 - Tope der.
	DECLE $B87C,$ECD4,$A86C,$ECC4	; 8 - Lado der 1.
	DECLE $A86C,$ECC4,$A86C,$ECC4	; 9 - Lado der 2.
	DECLE $286C,$0000,$0000,$0000	; 10 - Inf. der.
	DECLE $A0C0,$F870,$BE7C,$EFDF	; 11 - Hueco 3
	DECLE $AB67,$EECD,$BB77,$EEDD	; 12 - Hueco 4
	DECLE $0000,$0000,$0000,$8000	; 13 - Hueco 5

	DECLE $0000,$E080,$F0F8,$7060	; 14 - Abismo entrada 1
	DECLE $7F7F,$1F3F,$030F,$0001	; 15 - Abismo entrada 2
	DECLE $C080,$C0E0,$C080,$FFF8	; 16 - Abismo entrada 3
	DECLE $7F7F,$0F3F,$0003,$0000	; 17 - Abismo entrada 4
	DECLE $C080,$C080,$FCF0,$FCF8	; 18 - Abismo entrada 5
	DECLE $0F1F,$0307,$0001,$0000	; 19 - Abismo entrada 6
	DECLE $C000,$C080,$E0F0,$FEF0	; 20 - Abismo entrada 7
	DECLE $1FFF,$0000,$0000,$0000	; 21 - Abismo entrada 8

	DECLE $8000,$6018,$040C,$1C0F	; 22 - Abismo salida 1
	DECLE $20C0,$3010,$3870,$0106	; 23 - Abismo salida 2
	DECLE $30C0,$3870,$0204,$0306	; 24 - Abismo salida 3
	DECLE $20C0,$3860,$1808,$010F	; 25 - Abismo salida 4

	DECLE $0000,$0000,$0000,$0000	; 26 - Vacío

	; Pared con hueco a izq.
	DECLE $00,$01,$02,$02,$02,$02,$03
	DECLE     $04,$05,$02,$02,$02,$02,$03
	DECLE         $00,$01,$02,$02,$02,$02,$03
	DECLE             $06,$07,$08,$08,$08,$08,$09

	; Pared con hueco a der.
	DECLE $00,$01,$02,$02,$02,$02,$03
	DECLE     $06,$01,$02,$02,$02,$02,$03
	DECLE         $04,$05,$02,$02,$02,$02,$03
	DECLE             $00,$07,$08,$08,$08,$08,$09

	; Pared con hueco amplio
	DECLE $00,$01,$02,$02,$02,$02,$03
	DECLE     $04,$0A,$0B,$02,$02,$02,$03
	DECLE         $0c,$05,$02,$02,$02,$02,$03
	DECLE             $00,$07,$08,$08,$08,$08,$09

	; Abismo de entrada
	DECLE $19,$19,$19,$19,$19,$0D,$0E
	DECLE     $19,$19,$19,$19,$19,$0F,$10
	DECLE         $19,$19,$19,$19,$19,$11,$12
	DECLE             $19,$19,$19,$19,$19,$13,$14

	; Abismo de salida
	DECLE $19,$19,$19,$19,$19,$19,$15
	DECLE     $19,$19,$19,$19,$19,$19,$16
	DECLE         $19,$19,$19,$19,$19,$19,$17
	DECLE             $19,$19,$19,$19,$19,$19,$18

COLOR_ESTRELLA:	EQU $07

	; Tabla de estrellas
tabla_estrellas:	PROC
	DECLE $137*8+COLOR_ESTRELLA
	DECLE $12F*8+COLOR_ESTRELLA
	DECLE $127*8+COLOR_ESTRELLA
	DECLE $133*8+COLOR_ESTRELLA

	DECLE $12F*8+COLOR_ESTRELLA
	DECLE $12B*8+COLOR_ESTRELLA
	DECLE $127*8+COLOR_ESTRELLA
	DECLE $137*8+COLOR_ESTRELLA

	DECLE $12F*8+COLOR_ESTRELLA
	DECLE $12B*8+COLOR_ESTRELLA
	DECLE $137*8+COLOR_ESTRELLA
	DECLE $12F*8+COLOR_ESTRELLA
	ENDP

	; Pantalla de título
pantalla_titulo:	PROC
OO:	EQU $00*8+$07
OX:	EQU $A4*8+$07
XO:	EQU $A5*8+$07
XX:	EQU $5F*8+$07

	DECLE XX,XO,XX,XO,XX,XO,XX,XO,XX,XO
	DECLE XO,OO,XO,XO,XO,XO,XO,OO,XO,OO
	DECLE XX,XO,XX,XO,XX,XO,XO,OO,XX,XO
	DECLE OO,XO,XO,OO,XO,XO,XO,OO,XO,OO
	DECLE XX,XO,XO,OO,XO,XO,XX,XO,XX,XO
	DECLE OO,OO,OO,OO,OO,OO,OO,OO,OO,OO
	DECLE OO,XX,XO,XX,XO,XX,XO,XX,OO,OO
	DECLE OO,XO,XO,XO,XO,OX,OO,XO,XO,OO
	DECLE OO,XX,OO,XX,XO,OX,OO,XO,XO,OO
	DECLE OO,XO,XO,XO,XO,XX,XO,XX,OO,OO
	ENDP

        INCLUDE "print.asm"     ; Rutinas PRINT.xxx
