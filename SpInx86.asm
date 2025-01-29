bits 64
default rel


; Here comes the defines
	sys_read: equ 0	
	sys_write:	equ 1
	sys_nanosleep:	equ 35
	sys_nanosleep2:	equ 200
	sys_time:	equ 201
	sys_fcntl:	equ 72

	char_equal: equ 61 
	char_aster: equ 42
	char_may: equ 62 
	char_men: equ 60 
	char_dosp: equ 58
	char_comillas: equ 34
	char_comilla: equ 39 
	char_space: equ 32 
	char_O: equ 79
	char_U: equ 85
	char_T: equ 84
	char_X: equ 88
	left_direction: equ -1
	right_direction: equ 1
	enemy_y_pos1: equ 5
	enemy_y_pos2: equ 8
	enemy_speed1: equ 50
	enemy_speed2: equ 40
	enemy_speed3: equ 35
	enemy_speed30: equ 20
	enemy_speed59: equ 10


STDIN_FILENO: equ 0			;Se utiliza en llamadas al sistema que requieren un descriptor de archivo, por ejemplo, al leer de la entrada estándar

F_SETFL:	equ 0x0004		;Se pasa como segundo argumento a la llamada al sistema fcntl para indicar que queremos cambiar los flags del descriptor de archivo.
O_NONBLOCK: equ 0x0004		;Se utiliza como tercer argumento en la llamada al sistema fcntl para indicar que el descriptor de archivo debe operar en modo no bloqueante.

;screen clean definition
	row_cells:	equ 24	;Numero de filas que caben en la pantalla
	column_cells: 	equ 110 ; set to any (reasonable) value you wish
	array_length:	equ row_cells * column_cells + row_cells ;(+ 32 caracteres de nueva línea)

	;enemigos
		row_cells2:	equ 3	;Numero de filas que caben en la pantalla
		column_cells2: 	equ 8 ; set to any (reasonable) value you wish
		array_length2:	equ row_cells2 * column_cells2 + row_cells2 ;(+ 6 caracteres de nueva línea)

;This is regarding the sleep time
timespec:
    tv_sec  dq 0
    tv_nsec dq 20000000		;0.02 s

timespec2:
    tv_sec2  dq 0
    tv_nsec2 dq 2000000000000		;0.02 s


;This is for cleaning up the screen
clear:		db 27, "[2J", 27, "[H"	;2J: Esta es una secuencia de escape ANSI que indica Clear screen
clear_length:	equ $-clear			;H: Indica reposicionamiento del cursor.
	
	

; Start Message
	
	msg13: db "               ", 0xA, 0xD
	msg1: db "     					   TECNOLOGICO DE COSTA RICA        ", 0xA, 0xD
	msg14: db "               ", 0xA, 0xD
	msg2: db "     						  SAUL RAMIREZ       ", 0xA, 0xD
	msg5: db "     						 JUSTIN JIMENEZ      ", 0xA, 0xD
	msg15: db "               ", 0xA, 0xD
	msg6: db "               ", 0xA, 0xD
	msg7: db "               ", 0xA, 0xD
	msg8: db "               ", 0xA, 0xD
	msg9: db "               ", 0xA, 0xD
	msg16: db "               ", 0xA, 0xD 
	msg3: db "     			   	          S P A C E    I N V A D E R S        ", 0xA, 0xD
	msg17: db "               ", 0xA, 0xD
	msg18: db "               ", 0xA, 0xD
	msg19: db "               ", 0xA, 0xD
	msg20: db "               ", 0xA, 0xD
	msg21: db "               ", 0xA, 0xD
	msg22: db "               ", 0xA, 0xD
	msg23: db "               ", 0xA, 0xD 
	msg24: db "               ", 0xA, 0xD
	msg25: db "               ", 0xA, 0xD
	msg26: db "               ", 0xA, 0xD 
	msg4: db "      					   PRESIONE ENTER PARA INICIAR        ", 0xA, 0xD
	msg1_length:	equ $-msg1
	msg2_length:	equ $-msg2
	msg3_length:	equ $-msg3
	msg4_length:	equ $-msg4
	msg5_length:	equ $-msg5
	msg13_length:	equ $-msg13
	msg14_length:	equ $-msg14
	msg15_length:	equ $-msg15
	msg16_length:	equ $-msg16
	msg17_length:	equ $-msg17 
	msg6_length:	equ $-msg6 
	msg7_length:	equ $-msg7 
	msg8_length:	equ $-msg8 
	msg9_length:	equ $-msg9 
	msg18_length:	equ $-msg18
	msg19_length:	equ $-msg19
	msg20_length:	equ $-msg20
	msg21_length:	equ $-msg21
	msg22_length:	equ $-msg22
	msg23_length:	equ $-msg23
	msg24_length:	equ $-msg24
	msg25_length:	equ $-msg25
	msg26_length:	equ $-msg26
	

; Usefull macros (Como funciones reutilizables)
 
	%macro setnonblocking 0		;Configura la entrada estándar para que funcione en modo no bloqueante
		mov rax, sys_fcntl
		mov rdi, STDIN_FILENO
		mov rsi, F_SETFL
		mov rdx, O_NONBLOCK
		syscall
	%endmacro

	%macro unsetnonblocking 0	;Restablece la entrada estándar al modo bloqueante
		mov rax, sys_fcntl
		mov rdi, STDIN_FILENO
		mov rsi, F_SETFL
		mov rdx, 0
		syscall
	%endmacro

	%macro full_line 0			;Crea una línea completa de 'X' seguida de una nueva línea
		times column_cells db "X"
		db 0x0a, 0xD
	%endmacro

	%macro marcadores 0			;Crea una línea completa de 'O' seguida de una nueva línea
		db "X"
		times 8 db " "
		db "S"
		db "C"
		db "O"
		db "R"
		db "E"
		db ":"
		times 75 db " "
		db "L"
		db "E"
		db "V"
		db "E"
		db "L"
		db ":"
		times 13  db " "
		db "X"
		db 0x0a, 0xD
	%endmacro

	%macro hi_score 0			;Crea una línea completa de 'O' seguida de una nueva línea
		db "X"
		times 89 db " "
		db "H"
		db "I"
		db "-"
		db "S"
		db "C"
		db "O"
		db "R"
		db "E"
		db ":"
		times 10 db " " 
		db "X"
		db 0x0a, 0xD
	%endmacro

	%macro next_level 0			;Crea una línea completa de 'O' seguida de una nueva línea
		db "X"
		times 49 db " " 
		db "N"
		db "E"
		db "X"
		db "T"
		db " " 
		db "L"
		db "E"
		db "V"
		db "E"
		db "L" 
		times 49  db " "
		db "X"
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X"
		db 0x0a, 0xD 
		db "X"
		times 108  db " "
		db "X"
		db 0x0a, 0xD
		db "X"
		times 51 db " "  
		db "S" 
		db "C"
		db "O"
		db "R"
		db "E"  
		db " " 
		db " " 
		db " "  
		times 49 db " " 
		db "X"
		db 0x0a, 0xD
		db "X"
		times 50 db " " 
		db "H"
		db "I"
		db "-"
		db "S" 
		db "C"
		db "O"
		db "R"
		db "E" 
		times 50  db " " 
		db "X"
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X"
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X" 
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X" 
		db 0x0a, 0xD
		db "X"
		times 43 db " " 
		db "P"
		db "R"
		db "E"
		db "S"
		db "S"
		db " "
		db "E"
		db "N"
		db "T"
		db "E"
		db "R"
		db " "
		db "T"
		db "O"
		db " "
		db "C"
		db "O"
		db "N"
		db "T"
		db "I"
		db "N"
		db "U"
		db "E" 
		times 42 db " "
		db "X"
		db 0x0a, 0xD
		
	%endmacro
  
  	%macro game_ov 0			;Crea una línea completa de 'O' seguida de una nueva línea	
		db "X"
		times 49 db " " 
		db "G"
		db "A"
		db "M"
		db "E" 
		db " "
		db "O"
		db "V"
		db "E"
		db "R" 
		db "!" 
		times 49  db " "
		db "X"
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X"
		db 0x0a, 0xD 
		db "X"
		times 51 db " "  
		db "S" 
		db "C"
		db "O"
		db "R"
		db "E"  
		db " " 
		db " " 
		db " "  
		times 49 db " " 
		db "X"
		db 0x0a, 0xD
		db "X"
		times 50 db " " 
		db "H"
		db "I"
		db "-"
		db "S" 
		db "C"
		db "O"
		db "R"
		db "E" 
		times 50  db " " 
		db "X"
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X"
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X" 
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X"
		db 0x0a, 0xD
		db "X" 
		times 43 db " " 
		db "P"
		db "R"
		db "E"
		db "S"
		db "S"
		db " "
		db "E"	 
		db "N"
		db "T"
		db "E"
		db "R"
		db " "
		db "T"
		db "O"
		db " " 
		db "C"
		db "O"
		db "N"
		db "T"
		db "I"
		db "N"
		db "U"
		db "E" 
		times 42  db " "
		db "X"
		db 0x0a, 0xD
		
	%endmacro

	%macro winner 0			;Crea una línea completa de 'O' seguida de una nueva línea	
		db "X"
		times 48 db " " 
		db "W"
		db " "
		db "I"
		db " " 
		db "N"
		db " "
		db "N"
		db " "
		db "E" 
		db " " 
		db "R"
		db " " 
		db "!" 
		times 47  db " ";,"X"
		db "X"
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X"
		db 0x0a, 0xD 
		db "X"
		times 51 db " "  
		db "S" 
		db "C"
		db "O"
		db "R"
		db "E"  
		db " " 
		db " " 
		db " "  
		times 49 db " " 
		db "X"
		db 0x0a, 0xD
		db "X"
		times 50 db " " 
		db "H"
		db "I"
		db "-"
		db "S" 
		db "C"
		db "O"
		db "R"
		db "E" 
		times 50  db " " 
		db "X"
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X"
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X" 
		db 0x0a, 0xD
		db "X"
		times 108  db " "
		db "X"
		db 0x0a, 0xD
		db "X" 
		times 43 db " " 
		db "P"
		db "R"
		db "E"
		db "S"
		db "S"
		db " "
		db "E"	 
		db "N"
		db "T"
		db "E"
		db "R"
		db " "
		db "T"
		db "O"
		db " " 
		db "C"
		db "O"
		db "N"
		db "T"
		db "I"
		db "N"
		db "U"
		db "E" 
		times 42  db " "
		db "X"
		db 0x0a, 0xD
		
	%endmacro

	%macro hollow_line 0		;Crea una línea con 'X' en los extremos y espacios en el medio, seguida de una nueva línea
		db "X"
		times column_cells-2 db char_space	;A 80 le resta las 2 X de los extremos e imprime 78 espacios
		db "X", 0x0a, 0xD
	%endmacro


	%macro print 2				;Imprime una cadena especificada en la salida estándar
		mov eax, sys_write
		mov edi, 1 	; stdout
		mov rsi, %1				;Parametro 1 que se pasa en donde se llama al macro
		mov edx, %2				;Parametro 2
		syscall
	%endmacro

	%macro getchar 0			;Lee un solo carácter de la entrada estándar y lo almacena en input_char
		mov     rax, sys_read
		mov     rdi, STDIN_FILENO
		mov     rsi, input_char
		mov     rdx, 1 ; number of bytes
		syscall         ;read text input from keyboard
	%endmacro

	%macro sleeptime 0			;Suspende la ejecución del programa durante el tiempo especificado
		mov eax, sys_nanosleep
		mov rdi, timespec
		xor esi, esi		; ignore remaining time in case of call interruption
		syscall			; sleep for tv_sec seconds + tv_nsec nanoseconds
	%endmacro




global _start

section .bss

	buffer resb 5  ; Buffer para almacenar los dígitos convertidos

	input_char: resq 1 	

	bullet_x_pos resq 1
	bullet_y_pos resq 1

	bulletenemy_x_pos: resq 1
	bulletenemy_y_pos: resq 1

	bulletenemy_x_pos2: resq 1
	bulletenemy_y_pos2: resq 1
 
	;Enemigos
		enemy1_x_pos: resq 1
		enemy1_y_pos: resq 1 
		enemy2_x_pos: resq 1
		enemy2_y_pos: resq 1 
		enemy3_x_pos: resq 1
		enemy3_y_pos: resq 1
		enemy4_x_pos: resq 1
		enemy4_y_pos: resq 1
		enemy5_x_pos: resq 1
		enemy5_y_pos: resq 1
		enemy6_x_pos: resq 1
		enemy6_y_pos: resq 1
		enemy7_x_pos: resq 1
		enemy7_y_pos: resq 1
		enemy8_x_pos: resq 1
		enemy8_y_pos: resq 1
		enemy9_x_pos: resq 1
		enemy9_y_pos: resq 1
		enemy10_x_pos: resq 1
		enemy10_y_pos: resq 1 
		enemy11_x_pos: resq 1
		enemy11_y_pos: resq 1 
		enemy12_x_pos: resq 1
		enemy12_y_pos: resq 1 
		enemy13_x_pos: resq 1
		enemy13_y_pos: resq 1
		enemy14_x_pos: resq 1
		enemy14_y_pos: resq 1
		enemy15_x_pos: resq 1
		enemy15_y_pos: resq 1
		enemy16_x_pos: resq 1
		enemy16_y_pos: resq 1
		enemy17_x_pos: resq 1
		enemy17_y_pos: resq 1
		enemy18_x_pos: resq 1
		enemy18_y_pos: resq 1
		enemy19_x_pos: resq 1
		enemy19_y_pos: resq 1
		enemy20_x_pos: resq 1
		enemy20_y_pos: resq 1 
		enemy21_x_pos: resq 1
		enemy21_y_pos: resq 1 
		enemy22_x_pos: resq 1
		enemy22_y_pos: resq 1 
		enemy23_x_pos: resq 1
		enemy23_y_pos: resq 1
		enemy24_x_pos: resq 1
		enemy24_y_pos: resq 1
		enemy25_x_pos: resq 1
		enemy25_y_pos: resq 1
		enemy26_x_pos: resq 1
		enemy26_y_pos: resq 1
		enemy27_x_pos: resq 1
		enemy27_y_pos: resq 1
		enemy28_x_pos: resq 1
		enemy28_y_pos: resq 1
		enemy29_x_pos: resq 1
		enemy29_y_pos: resq 1
		enemy30_x_pos: resq 1
		enemy30_y_pos: resq 1 
		enemy31_x_pos: resq 1
		enemy31_y_pos: resq 1 
		enemy32_x_pos: resq 1
		enemy32_y_pos: resq 1 
		enemy33_x_pos: resq 1
		enemy33_y_pos: resq 1
		enemy34_x_pos: resq 1
		enemy34_y_pos: resq 1
		enemy35_x_pos: resq 1
		enemy35_y_pos: resq 1
		enemy36_x_pos: resq 1
		enemy36_y_pos: resq 1
		enemy37_x_pos: resq 1
		enemy37_y_pos: resq 1
		enemy38_x_pos: resq 1
		enemy38_y_pos: resq 1
		enemy39_x_pos: resq 1
		enemy39_y_pos: resq 1
		enemy40_x_pos: resq 1
		enemy40_y_pos: resq 1
		enemy41_x_pos: resq 1
		enemy41_y_pos: resq 1 
		enemy42_x_pos: resq 1
		enemy42_y_pos: resq 1 
		enemy43_x_pos: resq 1
		enemy43_y_pos: resq 1
		enemy44_x_pos: resq 1
		enemy44_y_pos: resq 1
		enemy45_x_pos: resq 1
		enemy45_y_pos: resq 1
		enemy46_x_pos: resq 1
		enemy46_y_pos: resq 1
		enemy47_x_pos: resq 1
		enemy47_y_pos: resq 1
		enemy48_x_pos: resq 1
		enemy48_y_pos: resq 1
		enemy49_x_pos: resq 1
		enemy49_y_pos: resq 1
		enemy50_x_pos: resq 1
		enemy50_y_pos: resq 1
		enemy51_x_pos: resq 1
		enemy51_y_pos: resq 1 
		enemy52_x_pos: resq 1
		enemy52_y_pos: resq 1 
		enemy53_x_pos: resq 1
		enemy53_y_pos: resq 1
		enemy54_x_pos: resq 1
		enemy54_y_pos: resq 1
		enemy55_x_pos: resq 1
		enemy55_y_pos: resq 1
		enemy56_x_pos: resq 1
		enemy56_y_pos: resq 1
		enemy57_x_pos: resq 1
		enemy57_y_pos: resq 1
		enemy58_x_pos: resq 1
		enemy58_y_pos: resq 1
		enemy59_x_pos: resq 1
		enemy59_y_pos: resq 1
		enemy60_x_pos: resq 1
		enemy60_y_pos: resq 1   
 
	
	
	temp_char resb 1
	random resb 1 ;Numero random obtenido
	random2 resb 1

section .data 

	urandom db '/dev/urandom', 0
	newline db 10, 0 

	kills dq 0
	score dq 0
	hi_mscore dq 0
	score_position dq board + 19 + 10* (column_cells + 2)   
	hi_score_position dq board + 103 + 11* (column_cells + 2) 
	level dq 1
	level_position dq board + 97 + 10* (column_cells + 2) 
	  
	shot dq 0
	shot_enemy dq 0
	shot_enemy2 dq 0
	ver_coll dq 0
	ball_speed dq 2
	enemy_speed dq 50 
	ball_coll dq 1
	ball_coll_enemy dq 1
	ball_coll_enemy2 dq 1
	limpiar dq 0

	counter_enemy_atack: dq 5
	counter_enemy_atack2: dq 7
	counter_enemy: dq 10
	counter_enemy2: dq 10

	board:
		full_line
        %rep 9  ; 3 = linea superior+linea inferior+linea de comandos 
        hollow_line
        %endrep 
		marcadores 
		hi_score
		%rep 9  ; 3 = linea superior+linea inferior+linea de comandos 
        hollow_line
        %endrep
        full_line
	board_size:   equ   $ - board 

	boardw:
		full_line
        %rep 5  ; 3 = linea superior+linea inferior+linea de comandos 
        hollow_line
        %endrep
		winner
		%rep 7  ; 3 = linea superior+linea inferior+linea de comandos 
        hollow_line
        %endrep
        full_line
	boardw_size:   equ   $ - boardw 

	boardg:
		full_line
        %rep 5  ; 3 = linea superior+linea inferior+linea de comandos 
        hollow_line
        %endrep
		game_ov
		%rep 7  ; 3 = linea superior+linea inferior+linea de comandos 
        hollow_line
        %endrep
        full_line
	boardg_size:   equ   $ - boardg 

	boardl:
		full_line
        %rep 4  ; 3 = linea superior+linea inferior+linea de comandos 
        hollow_line
        %endrep
		next_level
		%rep 7  ; 3 = linea superior+linea inferior+linea de comandos 
        hollow_line
        %endrep
        full_line
	boardl_size:   equ   $ - boardl
	

	; Added for the terminal issue	
		termios:        times 36 db 0	;Define una estructura de 36 bytes inicializados a 0. Esta estructura es utilizada para almacenar las configuraciones del terminal
		stdin:          equ 0			;Define el descriptor de archivo para la entrada estándar (stdin), que es 0
		ICANON:         equ 1<<1		;Canonico la entrada no se envía al programa hasta que el usuario presiona Enter
		ECHO:           equ 1<<3		;Bandera que habilita o deshabilita este modo
		VTIME: 			equ 5
		VMIN:			equ 6
		CC_C:			equ 18

	;board: Es la dirección de inicio del tablero
	;40: Es el desplazamiento horizontal inicial desde el borde izquierdo del tablero.
	;29 * (column_cells + 2): Es el desplazamiento vertical. 20 indica la fila en la que se coloca la paleta, y column_cells + 2 es el número de caracteres por fila, incluyendo los caracteres de nueva línea 
	pallet_position dq board + 35 + 20 * (column_cells +2)
	pallet_size dq 3 

	vidas_position dq board + 17 + 20 * (column_cells +2)
	vidas dq 0
  
	enemy_position dq board +  36 + 3 * (column_cells +2)
	enemy_size dq 1

	enemy_nave_position dq board +  32 + 2 * (column_cells +2)
	start_enemy_nave_position dq board +  32 + 2 * (column_cells +2)
	enemy_nave_size dq 7
	enemy_nave_counter dq 1000
	enemy_nave_speed dq 8
	col_nave dq 0

	pared1_x_pos: dq 30 ;0-59
	pared1_y_pos: dq 1
	pared2_x_pos: dq 80 ;0-59
	pared2_y_pos: dq 1
		colen: dq 21
		colj: dq 0
		cole: dq 0
		pared: dq 21
		colplayer: dq 0 

	ball_x_pos: dq 36
	ball_y_pos: dq 19 

	enemy_x_pos: dq 40
	enemy_y_pos: dq 3
	  

	;Colisiones
		cole1: dq 0 
		cole2: dq 0 
		cole3: dq 0
		cole4: dq 0 
		cole5: dq 0 
		cole6: dq 0
		cole7: dq 0
		cole8: dq 0
		cole9: dq 0 
		cole10: dq 0
		cole11: dq 0 
		cole12: dq 0 
		cole13: dq 0
		cole14: dq 0 
		cole15: dq 0 
		cole16: dq 0
		cole17: dq 0
		cole18: dq 0
		cole19: dq 0 
		cole20: dq 0
		cole21: dq 0 
		cole22: dq 0 
		cole23: dq 0
		cole24: dq 0 
		cole25: dq 0 
		cole26: dq 0
		cole27: dq 0
		cole28: dq 0
		cole29: dq 0 
		cole30: dq 0
		cole31: dq 0 
		cole32: dq 0 
		cole33: dq 0
		cole34: dq 0 
		cole35: dq 0 
		cole36: dq 0
		cole37: dq 0
		cole38: dq 0
		cole39: dq 0 
		cole40: dq 0
		cole41: dq 0 
		cole42: dq 0 
		cole43: dq 0
		cole44: dq 0 
		cole45: dq 0 
		cole46: dq 0
		cole47: dq 0
		cole48: dq 0
		cole49: dq 0 
		cole50: dq 0
		cole51: dq 0 
		cole52: dq 0 
		cole53: dq 0
		cole54: dq 0 
		cole55: dq 0 
		cole56: dq 0
		cole57: dq 0
		cole58: dq 0
		cole59: dq 0 
		cole60: dq 0

	enemy_numx: dq 4
	enemy_numy: dq 4
	enemy_dir: dq 0
	;	left: db -1
	;	right: db 1

		game_over dq 0 
		win dq 0 
		levl dq 0


section .text
;;;;;;;;;;;;;;;;;;;;for the working of the terminal;;;;;;;;;;;;;;;;;
canonical_off:										;La entrada se procese carácter por carácter sin esperar a que se presione Enter.
        call read_stdin_termios						;Guarda los atributos actuales del terminal en la variable termios

        ; clear canonical bit in local mode flags	
        push rax						
        mov eax, ICANON								;Carga el valor de la constante ICANON (que representa el bit del modo canónico) en eax
        not eax										;Niega todos los bits en eax
        and [termios+12], eax						;Limpia el bit canónico en las banderas de modo local
		mov byte[termios+CC_C+VTIME], 0				;Establecen VTIME y VMIN en 0 para que el terminal no espere caracteres adicionales
		mov byte[termios+CC_C+VMIN], 0
        pop rax

        call write_stdin_termios					;Escribe los atributos modificados de termios de vuelta al terminal
        ret

echo_off:											;No se muestran los caracteres introducidos
        call read_stdin_termios

        ; clear echo bit in local mode flags
        push rax
        mov eax, ECHO
        not eax
        and [termios+12], eax
        pop rax

        call write_stdin_termios
        ret

canonical_on:										;La entrada se procesa en líneas completas. Espera hasta que el usuario presione Enter
        call read_stdin_termios

        ; set canonical bit in local mode flags
        or dword [termios+12], ICANON
		mov byte[termios+CC_C+VTIME], 0			;Tiempo en decisegundos que el terminal espera para la entrada.
		mov byte[termios+CC_C+VMIN], 1			;El número mínimo de caracteres que se deben leer
        call write_stdin_termios
        ret

echo_on:											;Se muestran los caracteres introducidos
        call read_stdin_termios

        ; set echo bit in local mode flags
        or dword [termios+12], ECHO

        call write_stdin_termios
        ret

read_stdin_termios:									;Lee los atributos del terminal y los guarda en la variable termios
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5401h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

write_stdin_termios:								;Escribe los atributos del terminal utilizando la llamada al sistema 
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5402h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

;;;;;;;;;;;;;;;;;;;;end for the working of the terminal;;;;;;;;;;;;


rand_num:

	push rax
	push rcx
	push rdx
	push rdi
	push rsi

	  ; Open /dev/urandom
    mov rax, 2                ; syscall: open
    lea rdi, [rel urandom]    ; filename: /dev/urandom
    xor rsi, rsi              ; flags: O_RDONLY
    xor rdx, rdx              ; mode: 0
    syscall
    mov rdi, rax              ; Save file descriptor

    ; Read 1 byte from /dev/urandom
    mov rax, 0                ; syscall: read
    mov rsi, input_char       ; buffer: input_char
    mov rdx, 1                ; count: 1 byte
    syscall

    ; Close /dev/urandom
    mov rax, 3                ; syscall: close
    syscall

    ; Adjust the random number to be within 0-9
    movzx eax, byte [input_char] ; Load random byte into eax and zero-extend
    mov ecx, 30                ; Upper range
    xor edx, edx               ; Clear edx for division
    div ecx                    ; eax = eax / ecx, edx = eax % ecx (remainder)

	mov byte [random], dl   

    ;add dl, '0'                ; Convert remainder to ASCII

    ; Store the character in temp_char
   ; mov [temp_char], dl

    ; Print the character
   ; mov rax, 1                ; syscall: write
   ; mov rdi, 1                ; file descriptor: stdout
   ; lea rsi, [rel temp_char]  ; Pointer to the character
   ; mov rdx, 1                ; Length of 1 byte
   ; syscall

    ; Print newline
    ;mov rax, 1                ; syscall: write
    ;mov rdi, 1                ; file descriptor: stdout
    ;lea rsi, [newline]        ; Pointer to newline
    ;mov rdx, 1                ; Length of 1 byte
    ;syscall

	pop rax
	pop rcx
	pop rdx
	pop rdi
	pop rsi

ret 

rand_num2:

	push rax
	push rcx
	push rdx
	push rdi
	push rsi

	  ; Open /dev/urandom
    mov rax, 2                ; syscall: open
    lea rdi, [rel urandom]    ; filename: /dev/urandom
    xor rsi, rsi              ; flags: O_RDONLY
    xor rdx, rdx              ; mode: 0
    syscall
    mov rdi, rax              ; Save file descriptor

    ; Read 1 byte from /dev/urandom
    mov rax, 0                ; syscall: read
    mov rsi, input_char       ; buffer: input_char
    mov rdx, 1                ; count: 1 byte
    syscall

    ; Close /dev/urandom
    mov rax, 3                ; syscall: close
    syscall

    ; Adjust the random number to be within 0-9
    movzx eax, byte [input_char] ; Load random byte into eax and zero-extend
    mov ecx, 30                ; Upper range
    xor edx, edx               ; Clear edx for division
    div ecx                    ; eax = eax / ecx, edx = eax % ecx (remainder)

	mov byte [random], dl   

    ;add dl, '0'                ; Convert remainder to ASCII

    ; Store the character in temp_char
   ; mov [temp_char], dl

    ; Print the character
   ; mov rax, 1                ; syscall: write
   ; mov rdi, 1                ; file descriptor: stdout
   ; lea rsi, [rel temp_char]  ; Pointer to the character
   ; mov rdx, 1                ; Length of 1 byte
   ; syscall

    ; Print newline
    ;mov rax, 1                ; syscall: write
    ;mov rdi, 1                ; file descriptor: stdout
    ;lea rsi, [newline]        ; Pointer to newline
    ;mov rdx, 1                ; Length of 1 byte
    ;syscall

	pop rax
	pop rcx
	pop rdx
	pop rdi
	pop rsi

ret 


paredes:

	push rax
	push rcx 

	mov r12, [pared]

	mov r8, [pared1_x_pos]
	mov r9, [pared1_y_pos]  
	mov r11, r8
	;izquierda
		.repeat_l:
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx

			add r8, rax
				mov byte [r8], char_X 
	
				inc r9
				dec r12
				cmp r12, 0
				je .pared_r

				mov r8, r11
				jmp .repeat_l
 

	;derecha
		.pared_r:
		mov r12, [pared]

		mov r8, [pared2_x_pos]
		mov r9, [pared2_y_pos]  
		mov r11, r8

		.repeat_r:
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx

			add r8, rax
				mov byte [r8], char_X 
	
				inc r9
				dec r12
				cmp r12, 0
				je .no_col

				mov r8, r11
				jmp .repeat_r
		.no_col:

	pop rax
	pop rcx 
	ret

col_paredes_enemy:

	push rax
	push rcx 

	mov r12, 20

	mov r8, [pared1_x_pos] 
	mov r9, [pared1_y_pos]  
	 
	;izquierda

		inc r8
		mov r11, r8
		.repeat_l:
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx

			add r8, rax
 
			mov al,[r8] 
			cmp al, ' '
			jne .si_col

				inc r9
				dec r12
				cmp r12, 0
				je .col_r

				mov r8, r11
				jmp .repeat_l

		.si_col:
			cmp al, 'O'
				je .cl_en 
					cmp al, 'U'
						je .cl_en 	
						cmp al, 'T' 
							je .cl_en
							jmp .col_r
								
			.cl_en:
				mov qword [cole], 1 
				mov qword [enemy_dir], 1  
				    
	;derecha
		.col_r:
		mov r12, 20

		mov r8, [pared2_x_pos]
		mov r9, [pared2_y_pos]  

		dec r8
		mov r11, r8 

		.repeat_r:
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx

			add r8, rax
 
			mov al,[r8] 
			cmp al, ' '
				jne .si_colr
	
				inc r9
				dec r12
				cmp r12, 0
				je .no_col1
				mov r8, r11
				jmp .repeat_r

		.si_colr:
			cmp al, 'O'
				je .cl_en1        
					cmp al, 'U'
					je .cl_en1	
						cmp al, 'T' 
							je .cl_en1 
							jmp .no_col1
			.cl_en1:
				mov qword [cole], 1 
				mov qword [enemy_dir], 0  
	.no_col1:

	pop rax
	pop rcx
ret

col_paredes_player:

	push rax
	push rcx 
  
	mov r8, [pared1_x_pos]  
	 
	;izquierda

		inc r8
		mov r9, 20
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx

			add r8, rax

			mov r9, [pallet_position]
			cmp r8, r9
			je .col_jl
			jmp .col_rj
			
			.col_jl: 
				mov qword [colj], 1 

	.col_rj:
	mov r8, [pared2_x_pos]   

	;Derecha 
		dec r8
		mov r9, 20
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx

			add r8, rax
			
			mov r9, [pallet_position]
			add r9, 2
			cmp r8, r9
			je .col_jr
			jmp .no_C
			
			.col_jr: 
				mov qword [colj], 2 

	.no_C:
	pop rax
	pop rcx 
	ret


limite_aprox_enemy:

	;limite 
		mov r8, 31
		mov r9, 19
		mov r12, r8

		mov r10, 0 

		 
		.linea:
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
			mov al,[r8] 
			cmp al, ' '
			je .no_colis
				cmp al, '='
				je .no_colis
					cmp al, '*'
					je .no_colis
						cmp al, '<'
						je .no_colis
							cmp al, '"'
							je .no_colis
								cmp al, '>'
								je .no_colis
					
					mov qword [game_over], 1
					jmp .donelim

			.no_colis:

			inc r10
			cmp r10, 48
			je .donelim
			inc r12
			mov r8, r12
			jmp .linea
		.donelim:

	ret

; Function: print_ball
; This function displays the position of the ball
; Arguments: none
;
; Return:
;	Void
print_ball:											;Trabaja la ventana como un arreglo en memoria

	push rax
	push rcx 

	mov r8, [ball_coll]
	cmp r8, 1
	jne .esperar

	mov r8, [ball_x_pos]
	mov r9, [ball_y_pos]

	mov qword[bullet_x_pos], r8
	mov qword[bullet_y_pos], r9

	add r8, board

	mov rcx, r9
	mov rax, column_cells + 2
	imul rcx
	
	add r8, rax
	mov byte [r8], char_comilla

	mov qword[ball_coll], 0
	.esperar:

	pop rax
	pop rcx 
	ret
 
move_ball:

	push rax
	push rcx
	 
	mov r8, [shot]
	cmp r8, 1 
	jne .end 
	
	call print_ball
		mov r8, [ball_speed] 
		dec r8
		mov qword [ball_speed], r8
		cmp r8, 0
		jne .end
			;Limpiar
				
				mov r8, [bullet_x_pos]
				mov r9, [bullet_y_pos]
				add r8, board

				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax
				mov byte [r8], char_space

			;Colision
				
				call collision_ball

			;Mover
				mov r8, [ball_coll]
				cmp r8, 0
				jne .preend1

				;mov r9, [bullet_y_pos]
				;dec r9	
				;mov qword [bullet_y_pos], r9						 

				mov r8, [bullet_x_pos]
				mov r9, [bullet_y_pos]
				add r8, board

				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax
				mov byte [r8], char_comilla
		.preend1:
			mov qword[ball_speed], 2

	.end:

	pop rax
	pop rcx 
	ret

collision_ball:
  
	push rax
	push rcx
	 
	mov r8, [bullet_x_pos]
	mov r9, [bullet_y_pos]
	dec r9
	mov qword [bullet_y_pos], r9
	add r8, board

	mov rcx, r9
	mov rax, column_cells + 2
	imul rcx

	add r8, rax

	mov al,[r8] 
	cmp al, ' '
		je .no_colision

			mov qword[ball_coll], 1 
			mov qword[shot], 0 

			cmp r9, 2
			jne .no_col_nave
				mov r8, [score]
				add r8, 100
				mov qword [score], r8

				mov qword [enemy_nave_speed], 0
				call move_enemy_nave
				mov qword [enemy_nave_speed], 8
				mov qword [enemy_nave_counter], 500
				mov qword [col_nave], 0
				mov qword [enemy_nave_position], board +  32 + 2 * (column_cells +2) 
				jmp .no_colision

			.no_col_nave:
			cmp al, '='
			jne .no_colision1
				mov r8, [bullet_x_pos]
				mov r9, [bullet_y_pos] 
				add r8, board

				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx

				add r8, rax

				mov byte [r8], ' '
				jmp .no_colision

			.no_colision1:

			cmp al, 'O'
			jne .no_colisionO

				mov r8, [score]
				add r8, 30
				mov qword [score], r8

				mov r8, [kills]
				inc r8 
				mov qword [kills], r8

				mov r8, [bullet_x_pos]
				mov r9, [enemy1_x_pos]
				cmp r8, r9
				jne .sig
				mov r8, [bullet_y_pos]
				mov r9, [enemy1_y_pos]
				cmp r8, r9
				jne .sig 
					mov qword [cole1], 1
					jmp .no_colision
				.sig:
				mov r8, [bullet_x_pos]
				mov r9, [enemy2_x_pos]
				cmp r8, r9
				jne .sig1
				mov r8, [bullet_y_pos]
				mov r9, [enemy2_y_pos] 
				cmp r8, r9
				jne .sig1 
					mov qword [cole2], 1
					jmp .no_colision
				.sig1:
				mov r8, [bullet_x_pos]
				mov r9, [enemy3_x_pos]
				cmp r8, r9
				jne .sig2 
				mov r8, [bullet_y_pos]
				mov r9, [enemy3_y_pos] 
				cmp r8, r9
				jne .sig2 
					mov qword [cole3], 1
					jmp .no_colision
				.sig2: 
				mov r8, [bullet_x_pos]
				mov r9, [enemy4_x_pos]
				cmp r8, r9
				jne .sig3 
				mov r8, [bullet_y_pos]
				mov r9, [enemy4_y_pos] 
				cmp r8, r9
				jne .sig3 
					mov qword [cole4], 1
					jmp .no_colision
				.sig3:
				mov r8, [bullet_x_pos]
				mov r9, [enemy5_x_pos]
				cmp r8, r9
				jne .sig4 
				mov r8, [bullet_y_pos]
				mov r9, [enemy5_y_pos] 
				cmp r8, r9
				jne .sig4 
					mov qword [cole5], 1
					jmp .no_colision
				.sig4:
				mov r8, [bullet_x_pos]
				mov r9, [enemy6_x_pos]
				cmp r8, r9
				jne .sig5 
				mov r8, [bullet_y_pos]
				mov r9, [enemy6_y_pos] 
				cmp r8, r9
				jne .sig5
					mov qword [cole6], 1
					jmp .no_colision
				.sig5:
				mov r8, [bullet_x_pos]
				mov r9, [enemy7_x_pos]
				cmp r8, r9
				jne .sig6
				mov r8, [bullet_y_pos]
				mov r9, [enemy7_y_pos] 
				cmp r8, r9
				jne .sig6 
					mov qword [cole7], 1
					jmp .no_colision
				.sig6:
				mov r8, [bullet_x_pos]
				mov r9, [enemy8_x_pos]
				cmp r8, r9
				jne .sig7
				mov r8, [bullet_y_pos]
				mov r9, [enemy8_y_pos] 
				cmp r8, r9
				jne .sig7 
					mov qword [cole8], 1
					jmp .no_colision
				.sig7:
				mov r8, [bullet_x_pos]
				mov r9, [enemy9_x_pos]
				cmp r8, r9
				jne .sig8
				mov r8, [bullet_y_pos]
				mov r9, [enemy9_y_pos] 
				cmp r8, r9
				jne .sig8 
					mov qword [cole9], 1
					jmp .no_colision
				.sig8:
				mov r8, [bullet_x_pos]
				mov r9, [enemy10_x_pos]
				cmp r8, r9
				jne .sig9
				mov r8, [bullet_y_pos]
				mov r9, [enemy10_y_pos] 
				cmp r8, r9
				jne .sig9 
					mov qword [cole10], 1
					jmp .no_colision
				
				.sig9:
				mov r8, [bullet_x_pos]
				mov r9, [enemy11_x_pos]
				cmp r8, r9
				jne .sig10
				mov r8, [bullet_y_pos]
				mov r9, [enemy11_y_pos] 
				cmp r8, r9
				jne .sig10
					mov qword [cole11], 1
					jmp .no_colision

				.sig10:
				mov r8, [bullet_x_pos]
				mov r9, [enemy12_x_pos]
				cmp r8, r9
				jne .sig11
				mov r8, [bullet_y_pos]
				mov r9, [enemy12_y_pos] 
				cmp r8, r9
				jne .sig11 
					mov qword [cole12], 1
					jmp .no_colision
				.sig11:
				mov r8, [bullet_x_pos]
				mov r9, [enemy13_x_pos]
				cmp r8, r9
				jne .sig12 
				mov r8, [bullet_y_pos]
				mov r9, [enemy13_y_pos] 
				cmp r8, r9
				jne .sig12 
					mov qword [cole13], 1
					jmp .no_colision
				.sig12: 
				mov r8, [bullet_x_pos]
				mov r9, [enemy14_x_pos]
				cmp r8, r9
				jne .sig13 
				mov r8, [bullet_y_pos]
				mov r9, [enemy14_y_pos] 
				cmp r8, r9
				jne .sig13 
					mov qword [cole14], 1
					jmp .no_colision
				.sig13:
				mov r8, [bullet_x_pos]
				mov r9, [enemy15_x_pos]
				cmp r8, r9
				jne .sig14 
				mov r8, [bullet_y_pos]
				mov r9, [enemy15_y_pos] 
				cmp r8, r9
				jne .sig14 
					mov qword [cole15], 1
					jmp .no_colision
				.sig14:
				mov r8, [bullet_x_pos]
				mov r9, [enemy16_x_pos]
				cmp r8, r9
				jne .sig15 
				mov r8, [bullet_y_pos]
				mov r9, [enemy16_y_pos] 
				cmp r8, r9
				jne .sig15
					mov qword [cole16], 1
					jmp .no_colision
				.sig15:
				mov r8, [bullet_x_pos]
				mov r9, [enemy17_x_pos]
				cmp r8, r9
				jne .sig16
				mov r8, [bullet_y_pos]
				mov r9, [enemy17_y_pos] 
				cmp r8, r9
				jne .sig16 
					mov qword [cole17], 1
					jmp .no_colision
				.sig16:
				mov r8, [bullet_x_pos]
				mov r9, [enemy18_x_pos]
				cmp r8, r9
				jne .sig17
				mov r8, [bullet_y_pos]
				mov r9, [enemy18_y_pos] 
				cmp r8, r9
				jne .sig17 
					mov qword [cole18], 1
					jmp .no_colision
				.sig17:
				mov r8, [bullet_x_pos]
				mov r9, [enemy19_x_pos]
				cmp r8, r9
				jne .sig18
				mov r8, [bullet_y_pos]
				mov r9, [enemy19_y_pos] 
				cmp r8, r9
				jne .sig18 
					mov qword [cole19], 1
					jmp .no_colision
				 
				.sig18: 
				mov r8, [bullet_x_pos]
				mov r9, [enemy20_x_pos]
				cmp r8, r9
				jne .sig19
				mov r8, [bullet_y_pos]
				mov r9, [enemy20_y_pos] 
				cmp r8, r9
				jne .sig19 
					mov qword [cole20], 1
					jmp .no_colision 
			.no_colisionO:
			;Enemigos U	
				.sig19: 
			cmp al, 'U'
			jne .no_colisionU
				mov r8, [score]
				add r8, 20
				mov qword [score], r8

				mov r8, [kills]
				inc r8 
				mov qword [kills], r8

				mov r8, [bullet_x_pos]
				mov r9, [enemy21_x_pos]
				cmp r8, r9
				jne .sig20
				mov r8, [bullet_y_pos]
				mov r9, [enemy21_y_pos] 
				cmp r8, r9
				jne .sig20
					mov qword [cole21], 1
					jmp .no_colision

				.sig20:
				mov r8, [bullet_x_pos]
				mov r9, [enemy22_x_pos]
				cmp r8, r9
				jne .sig21
				mov r8, [bullet_y_pos]
				mov r9, [enemy22_y_pos] 
				cmp r8, r9
				jne .sig21 
					mov qword [cole22], 1
					jmp .no_colision
				.sig21:
				mov r8, [bullet_x_pos]
				mov r9, [enemy23_x_pos]
				cmp r8, r9
				jne .sig22 
				mov r8, [bullet_y_pos]
				mov r9, [enemy23_y_pos] 
				cmp r8, r9
				jne .sig22 
					mov qword [cole23], 1
					jmp .no_colision
				.sig22: 
				mov r8, [bullet_x_pos]
				mov r9, [enemy24_x_pos]
				cmp r8, r9
				jne .sig23 
				mov r8, [bullet_y_pos]
				mov r9, [enemy24_y_pos] 
				cmp r8, r9
				jne .sig23 
					mov qword [cole24], 1
					jmp .no_colision
				.sig23:
				mov r8, [bullet_x_pos]
				mov r9, [enemy25_x_pos]
				cmp r8, r9
				jne .sig24 
				mov r8, [bullet_y_pos]
				mov r9, [enemy25_y_pos] 
				cmp r8, r9
				jne .sig24 
					mov qword [cole25], 1
					jmp .no_colision
				.sig24:
				mov r8, [bullet_x_pos]
				mov r9, [enemy26_x_pos]
				cmp r8, r9
				jne .sig25 
				mov r8, [bullet_y_pos]
				mov r9, [enemy26_y_pos] 
				cmp r8, r9
				jne .sig25
					mov qword [cole26], 1
					jmp .no_colision
				.sig25:
				mov r8, [bullet_x_pos]
				mov r9, [enemy27_x_pos]
				cmp r8, r9
				jne .sig26
				mov r8, [bullet_y_pos]
				mov r9, [enemy27_y_pos] 
				cmp r8, r9
				jne .sig26 
					mov qword [cole27], 1
					jmp .no_colision
				.sig26:
				mov r8, [bullet_x_pos]
				mov r9, [enemy28_x_pos]
				cmp r8, r9
				jne .sig27
				mov r8, [bullet_y_pos]
				mov r9, [enemy28_y_pos] 
				cmp r8, r9
				jne .sig27 
					mov qword [cole28], 1
					jmp .no_colision
				.sig27:
				mov r8, [bullet_x_pos]
				mov r9, [enemy29_x_pos]
				cmp r8, r9
				jne .sig28
				mov r8, [bullet_y_pos]
				mov r9, [enemy29_y_pos] 
				cmp r8, r9
				jne .sig28 
					mov qword [cole29], 1
					jmp .no_colision
				.sig28:
				mov r8, [bullet_x_pos]
				mov r9, [enemy30_x_pos]
				cmp r8, r9
				jne .sig29
				mov r8, [bullet_y_pos]
				mov r9, [enemy30_y_pos] 
				cmp r8, r9
				jne .sig29 
					mov qword [cole30], 1
					jmp .no_colision
				
				.sig29:
				mov r8, [bullet_x_pos]
				mov r9, [enemy31_x_pos]
				cmp r8, r9
				jne .sig30
				mov r8, [bullet_y_pos]
				mov r9, [enemy31_y_pos] 
				cmp r8, r9
				jne .sig30
					mov qword [cole31], 1
					jmp .no_colision

				.sig30:
				mov r8, [bullet_x_pos]
				mov r9, [enemy32_x_pos]
				cmp r8, r9
				jne .sig31
				mov r8, [bullet_y_pos]
				mov r9, [enemy32_y_pos] 
				cmp r8, r9
				jne .sig31 
					mov qword [cole32], 1
					jmp .no_colision
				.sig31:
				mov r8, [bullet_x_pos]
				mov r9, [enemy33_x_pos]
				cmp r8, r9
				jne .sig32 
				mov r8, [bullet_y_pos]
				mov r9, [enemy33_y_pos] 
				cmp r8, r9
				jne .sig32 
					mov qword [cole33], 1
					jmp .no_colision
				.sig32: 
				mov r8, [bullet_x_pos]
				mov r9, [enemy34_x_pos]
				cmp r8, r9
				jne .sig33 
				mov r8, [bullet_y_pos]
				mov r9, [enemy34_y_pos] 
				cmp r8, r9
				jne .sig33 
					mov qword [cole34], 1
					jmp .no_colision
				.sig33:
				mov r8, [bullet_x_pos]
				mov r9, [enemy35_x_pos]
				cmp r8, r9
				jne .sig34 
				mov r8, [bullet_y_pos]
				mov r9, [enemy35_y_pos] 
				cmp r8, r9
				jne .sig34 
					mov qword [cole35], 1
					jmp .no_colision
				.sig34:
				mov r8, [bullet_x_pos]
				mov r9, [enemy36_x_pos]
				cmp r8, r9
				jne .sig35 
				mov r8, [bullet_y_pos]
				mov r9, [enemy36_y_pos] 
				cmp r8, r9
				jne .sig35
					mov qword [cole36], 1
					jmp .no_colision
				.sig35:
				mov r8, [bullet_x_pos]
				mov r9, [enemy37_x_pos]
				cmp r8, r9
				jne .sig36
				mov r8, [bullet_y_pos]
				mov r9, [enemy37_y_pos] 
				cmp r8, r9
				jne .sig36 
					mov qword [cole37], 1
					jmp .no_colision
				.sig36:
				mov r8, [bullet_x_pos]
				mov r9, [enemy38_x_pos]
				cmp r8, r9
				jne .sig37
				mov r8, [bullet_y_pos]
				mov r9, [enemy38_y_pos] 
				cmp r8, r9
				jne .sig37 
					mov qword [cole38], 1
					jmp .no_colision
				.sig37:
				mov r8, [bullet_x_pos]
				mov r9, [enemy39_x_pos]
				cmp r8, r9
				jne .sig38
				mov r8, [bullet_y_pos]
				mov r9, [enemy39_y_pos] 
				cmp r8, r9
				jne .sig38 
					mov qword [cole39], 1
					jmp .no_colision
				.sig38:
				mov r8, [bullet_x_pos]
				mov r9, [enemy40_x_pos]
				cmp r8, r9
				jne .sig39
				mov r8, [bullet_y_pos]
				mov r9, [enemy40_y_pos] 
				cmp r8, r9
				jne .sig39 
					mov qword [cole40], 1
					jmp .no_colision
			.no_colisionU:
			;Enemigos T	
				.sig39:
			cmp al, 'T'
			jne .no_colision

				mov r8, [score]
				add r8, 10
				mov qword [score], r8

				mov r8, [kills]
				inc r8 
				mov qword [kills], r8

				mov r8, [bullet_x_pos]
				mov r9, [enemy41_x_pos]
				cmp r8, r9
				jne .sig40
				mov r8, [bullet_y_pos]
				mov r9, [enemy41_y_pos] 
				cmp r8, r9
				jne .sig40
					mov qword [cole41], 1
					jmp .no_colision	 
				.sig40: 
				mov r8, [bullet_x_pos]
				mov r9, [enemy42_x_pos]
				cmp r8, r9
				jne .sig41
				mov r8, [bullet_y_pos]
				mov r9, [enemy42_y_pos] 
				cmp r8, r9
				jne .sig41 
					mov qword [cole42], 1
					jmp .no_colision
				.sig41:
				mov r8, [bullet_x_pos]
				mov r9, [enemy43_x_pos]
				cmp r8, r9
				jne .sig42 
				mov r8, [bullet_y_pos]
				mov r9, [enemy43_y_pos] 
				cmp r8, r9
				jne .sig42 
					mov qword [cole43], 1
					jmp .no_colision
				.sig42: 
				mov r8, [bullet_x_pos]
				mov r9, [enemy44_x_pos]
				cmp r8, r9
				jne .sig43 
				mov r8, [bullet_y_pos]
				mov r9, [enemy44_y_pos] 
				cmp r8, r9
				jne .sig43 
					mov qword [cole44], 1
					jmp .no_colision
				.sig43:
				mov r8, [bullet_x_pos]
				mov r9, [enemy45_x_pos]
				cmp r8, r9
				jne .sig44 
				mov r8, [bullet_y_pos]
				mov r9, [enemy45_y_pos] 
				cmp r8, r9
				jne .sig44 
					mov qword [cole45], 1
					jmp .no_colision
				.sig44:
				mov r8, [bullet_x_pos]
				mov r9, [enemy46_x_pos]
				cmp r8, r9
				jne .sig45 
				mov r8, [bullet_y_pos]
				mov r9, [enemy46_y_pos] 
				cmp r8, r9
				jne .sig45
					mov qword [cole46], 1
					jmp .no_colision
				.sig45:
				mov r8, [bullet_x_pos]
				mov r9, [enemy47_x_pos]
				cmp r8, r9
				jne .sig46
				mov r8, [bullet_y_pos]
				mov r9, [enemy47_y_pos] 
				cmp r8, r9
				jne .sig46 
					mov qword [cole47], 1
					jmp .no_colision
				.sig46:
				mov r8, [bullet_x_pos]
				mov r9, [enemy48_x_pos]
				cmp r8, r9
				jne .sig47
				mov r8, [bullet_y_pos]
				mov r9, [enemy48_y_pos] 
				cmp r8, r9
				jne .sig47 
					mov qword [cole48], 1
					jmp .no_colision
				.sig47:
				mov r8, [bullet_x_pos]
				mov r9, [enemy49_x_pos]
				cmp r8, r9
				jne .sig48
				mov r8, [bullet_y_pos]
				mov r9, [enemy49_y_pos] 
				cmp r8, r9
				jne .sig48 
					mov qword [cole49], 1
					jmp .no_colision
				.sig48:
				mov r8, [bullet_x_pos]
				mov r9, [enemy50_x_pos]
				cmp r8, r9
				jne .sig49
				mov r8, [bullet_y_pos]
				mov r9, [enemy50_y_pos] 
				cmp r8, r9
				jne .sig49 
					mov qword [cole50], 1
					jmp .no_colision
				
				.sig49:
				mov r8, [bullet_x_pos]
				mov r9, [enemy51_x_pos]
				cmp r8, r9
				jne .sig50
				mov r8, [bullet_y_pos]
				mov r9, [enemy51_y_pos] 
				cmp r8, r9
				jne .sig50
					mov qword [cole51], 1
					jmp .no_colision

				.sig50:
				mov r8, [bullet_x_pos]
				mov r9, [enemy52_x_pos]
				cmp r8, r9
				jne .sig51
				mov r8, [bullet_y_pos]
				mov r9, [enemy52_y_pos] 
				cmp r8, r9
				jne .sig51 
					mov qword [cole52], 1
					jmp .no_colision
				.sig51:
				mov r8, [bullet_x_pos]
				mov r9, [enemy53_x_pos]
				cmp r8, r9
				jne .sig52 
				mov r8, [bullet_y_pos]
				mov r9, [enemy53_y_pos] 
				cmp r8, r9
				jne .sig52 
					mov qword [cole53], 1
					jmp .no_colision
				.sig52: 
				mov r8, [bullet_x_pos]
				mov r9, [enemy54_x_pos]
				cmp r8, r9
				jne .sig53 
				mov r8, [bullet_y_pos]
				mov r9, [enemy54_y_pos] 
				cmp r8, r9
				jne .sig53 
					mov qword [cole54], 1
					jmp .no_colision
				.sig53:
				mov r8, [bullet_x_pos]
				mov r9, [enemy55_x_pos]
				cmp r8, r9
				jne .sig54 
				mov r8, [bullet_y_pos]
				mov r9, [enemy55_y_pos] 
				cmp r8, r9
				jne .sig54 
					mov qword [cole55], 1
					jmp .no_colision
				.sig54:
				mov r8, [bullet_x_pos]
				mov r9, [enemy56_x_pos]
				cmp r8, r9
				jne .sig55 
				mov r8, [bullet_y_pos]
				mov r9, [enemy56_y_pos] 
				cmp r8, r9
				jne .sig55
					mov qword [cole56], 1
					jmp .no_colision
				.sig55:
				mov r8, [bullet_x_pos]
				mov r9, [enemy57_x_pos]
				cmp r8, r9
				jne .sig56
				mov r8, [bullet_y_pos]
				mov r9, [enemy57_y_pos] 
				cmp r8, r9
				jne .sig56 
					mov qword [cole57], 1
					jmp .no_colision
				.sig56:
				mov r8, [bullet_x_pos]
				mov r9, [enemy58_x_pos]
				cmp r8, r9
				jne .sig57
				mov r8, [bullet_y_pos]
				mov r9, [enemy58_y_pos] 
				cmp r8, r9
				jne .sig57 
					mov qword [cole58], 1
					jmp .no_colision
				.sig57:
				mov r8, [bullet_x_pos]
				mov r9, [enemy59_x_pos]
				cmp r8, r9
				jne .sig58
				mov r8, [bullet_y_pos]
				mov r9, [enemy59_y_pos] 
				cmp r8, r9
				jne .sig58 
					mov qword [cole59], 1
					jmp .no_colision
				.sig58:
				mov r8, [bullet_x_pos]
				mov r9, [enemy60_x_pos]
				cmp r8, r9
				jne .sig59
				mov r8, [bullet_y_pos]
				mov r9, [enemy60_y_pos] 
				cmp r8, r9
				jne .sig59 
					mov qword [cole60], 1
					jmp .no_colision
				.sig59:
		.no_colision:

	pop rax
	pop rcx 
	ret

; Function: print_pallet
; This function moves the pallet in the game
; Arguments: none
;
; Return;
;	void
print_pallet:
  
	mov r8, [pallet_position] 
	.write_pallet:
		mov byte [r8], char_men						; Escribir el carácter = en la posición actual
		inc r8										; Avanzar a la siguiente posición en el tablero
		mov byte [r8], char_comillas
		inc r8										 
		mov byte [r8], char_may
	 
	ret

print_enemy_nave:

	mov r8, [enemy_nave_counter] 
	cmp r8, 0
	jne .no_nave

	call move_enemy_nave

	mov r8, [col_nave]
	cmp r8, 1
	je .mov_nave_done
  
	mov r8, [enemy_nave_position]  					 
		mov byte [r8], '~' 
		inc r8										 
		mov byte [r8], '~'
		inc r8										 
		mov byte [r8], '('
		inc r8										 
		mov byte [r8], '*'
		inc r8										 
		mov byte [r8], '0'
		inc r8										 
		mov byte [r8], '*'
		inc r8
		mov byte [r8], ')'	 
		inc r8										 
		mov byte [r8], '~'
		inc r8										 
		mov byte [r8], '~'
		jmp .mov_nave_done

	.no_nave:
		mov r8, [enemy_nave_counter]
		dec r8
		mov qword [enemy_nave_counter], r8
	 	mov qword [col_nave], 0
	.mov_nave_done:
	ret

move_enemy_nave:

	mov r8, [enemy_nave_speed]
	cmp r8, 0
	jne .no_move_nave

		;Limpiar
			mov r8, [enemy_nave_position]  					 
			mov byte [r8], ' ' 
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8
			mov byte [r8], ' '	 
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '

		mov r8, [enemy_nave_position]
		mov r9, r8
		add r8, 9
		mov al, [r8]
		cmp al, ' '
		je .move_nave
			mov qword [col_nave], 1
			mov r8, [start_enemy_nave_position]
			mov qword [enemy_nave_position], r8
			mov qword [enemy_nave_counter], 500
			mov qword [enemy_nave_speed], 8
			jmp .move_nave_done

		.move_nave:
			inc r9
			mov qword [enemy_nave_position], r9
			mov qword [enemy_nave_speed], 8
			mov qword [col_nave], 0
			jmp .move_nave_done

	.no_move_nave:
		mov r8, [enemy_nave_speed]
		dec r8
		mov qword [enemy_nave_speed], r8
		mov qword [col_nave], 1
	.move_nave_done:
	ret

; Function: move_pallet
; This function is in charge of moving the pallet in a given direction
; Arguments:
;	rdi: left direction or right direction
;
; Return:
;	void
move_pallet:

	push rax
	push rcx
	  
	cmp rdi, left_direction					; Comparar el valor de rdi (dirección) con left_direction
	jne .move_right							; Si no es igual a left_direction, saltar a .move_right
	.move_left:

		mov r13, [colj]
		cmp r13, 1
		je .endp

		mov r8, [pallet_position]
		mov r9, [pallet_size]
		mov byte [r8 + r9 - 1], char_space	; Limpiar el último carácter del palet
		dec r8								; Mover la posición del palet una unidad a la izquierda
		mov [pallet_position], r8			; Actualizar la posición del palet en la memoria
 
		;Limpiar 
				mov r8, [ball_x_pos]
				mov r9, [ball_y_pos]
				add r8, board

				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax
				mov byte [r8], char_space 
		;Muevo a la izquierda
			mov r8, [ball_x_pos]
			dec r8	
			mov qword [ball_x_pos], r8

		jmp .endp	
							 
	.move_right:

		mov r13, [colj]
		cmp r13, 2
		je .endp

		mov r8, [pallet_position]
		mov byte [r8], char_space
		inc r8
		mov [pallet_position], r8
 
		;Limpiar  
				mov r8, [ball_x_pos]
				mov r9, [ball_y_pos]
				add r8, board

				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax
				mov byte [r8], char_space 
		;Muevo a la derecha
			mov r8, [ball_x_pos]
			inc r8	
			mov qword [ball_x_pos], r8

	.endp:
		mov qword [colj], 0

	pop rax
	pop rcx
	 
	ret

calc_dir_enemy:

	push rax
	push rcx  

	mov r8, [enemy_x_pos]
	mov r9, [enemy_y_pos]

	mov r12, [levl]
	cmp r12, 1
	jne .position_done
	mov r12, [level]

	cmp r12, 1
	je .position_done
	cmp r12, 2
	je .position_done
		cmp r12, 3
		je .p1
		cmp r12, 4
		je .p1
			mov r9, enemy_y_pos2
			mov qword [enemy_y_pos], r9
			jmp .position_done
		.p1: 
		mov r9, enemy_y_pos1
		mov qword [enemy_y_pos], r9 

	.position_done:
	
	mov qword [levl], 0 

	;Enemigos
		.ene1:
			mov r10, [cole1]
			cmp r10, 1 
			je .ene2 
			mov qword [enemy1_x_pos], r8
			mov qword [enemy1_y_pos], r9

		.ene2:
			add r8, 3 

			mov r10, [cole2]
			cmp r10, 1 
			je .ene3 
			mov qword [enemy2_x_pos], r8
			mov qword [enemy2_y_pos], r9

		.ene3:
			add r8, 3 

			mov r10, [cole3]
			cmp r10, 1 
			je .ene4 
			mov qword [enemy3_x_pos], r8
			mov qword [enemy3_y_pos], r9

		.ene4:
			add r8, 3

			mov r10, [cole4]
			cmp r10, 1 
			je .ene5 
			mov qword [enemy4_x_pos], r8
			mov qword [enemy4_y_pos], r9

		.ene5:
			add r8, 3

			mov r10, [cole5]
			cmp r10, 1 
			je .ene6 
			mov qword [enemy5_x_pos], r8
			mov qword [enemy5_y_pos], r9

		.ene6:
			add r8, 3

			mov r10, [cole6]
			cmp r10, 1 
			je .ene7 
			mov qword [enemy6_x_pos], r8
			mov qword [enemy6_y_pos], r9

		.ene7:
			add r8, 3
			
			mov r10, [cole7]
			cmp r10, 1 
			je .ene8 
			mov qword [enemy7_x_pos], r8
			mov qword [enemy7_y_pos], r9

		.ene8:
			add r8, 3

			mov r10, [cole8]
			cmp r10, 1 
			je .ene9 
			mov qword [enemy8_x_pos], r8
			mov qword [enemy8_y_pos], r9

		.ene9:
			add r8, 3

			mov r10, [cole9]
			cmp r10, 1 
			je .ene10 
			mov qword [enemy9_x_pos], r8
			mov qword [enemy9_y_pos], r9

		.ene10:
			add r8, 3

			mov r10, [cole10]
			cmp r10, 1 
			je .ene11 
			mov qword [enemy10_x_pos], r8
			mov qword [enemy10_y_pos], r9

		.ene11:
			mov r8, [enemy_x_pos]
			inc r9

			mov r10, [cole11]
			cmp r10, 1 
			je .ene12 
			mov qword [enemy11_x_pos], r8
			mov qword [enemy11_y_pos], r9

		.ene12:
			add r8, 3 

			mov r10, [cole12]
			cmp r10, 1 
			je .ene13 
			mov qword [enemy12_x_pos], r8
			mov qword [enemy12_y_pos], r9

		.ene13:
			add r8, 3 

			mov r10, [cole13]
			cmp r10, 1 
			je .ene14 
			mov qword [enemy13_x_pos], r8
			mov qword [enemy13_y_pos], r9

		.ene14:
			add r8, 3

			mov r10, [cole14]
			cmp r10, 1 
			je .ene15 
			mov qword [enemy14_x_pos], r8
			mov qword [enemy14_y_pos], r9

		.ene15:
			add r8, 3

			mov r10, [cole15]
			cmp r10, 1 
			je .ene16 
			mov qword [enemy15_x_pos], r8
			mov qword [enemy15_y_pos], r9

		.ene16:
			add r8, 3

			mov r10, [cole16]
			cmp r10, 1 
			je .ene17 
			mov qword [enemy16_x_pos], r8
			mov qword [enemy16_y_pos], r9

		.ene17:
			add r8, 3
			
			mov r10, [cole17]
			cmp r10, 1 
			je .ene18 
			mov qword [enemy17_x_pos], r8
			mov qword [enemy17_y_pos], r9

		.ene18:
			add r8, 3

			mov r10, [cole18]
			cmp r10, 1 
			je .ene19 
			mov qword [enemy18_x_pos], r8
			mov qword [enemy18_y_pos], r9

		.ene19:
			add r8, 3

			mov r10, [cole19]
			cmp r10, 1 
			je .ene20 
			mov qword [enemy19_x_pos], r8
			mov qword [enemy19_y_pos], r9

		.ene20:
			add r8, 3

			mov r10, [cole20]
			cmp r10, 1 
			je .ene21 
			mov qword [enemy20_x_pos], r8
			mov qword [enemy20_y_pos], r9

		.ene21:
			mov r8, [enemy_x_pos]
			inc r9

			mov r10, [cole21]
			cmp r10, 1 
			je .ene22 
			mov qword [enemy21_x_pos], r8
			mov qword [enemy21_y_pos], r9

		.ene22:
			add r8, 3 

			mov r10, [cole22]
			cmp r10, 1 
			je .ene23 
			mov qword [enemy22_x_pos], r8
			mov qword [enemy22_y_pos], r9

		.ene23:
			add r8, 3 

			mov r10, [cole23]
			cmp r10, 1 
			je .ene24 
			mov qword [enemy23_x_pos], r8
			mov qword [enemy23_y_pos], r9

		.ene24:
			add r8, 3

			mov r10, [cole24]
			cmp r10, 1 
			je .ene25 
			mov qword [enemy24_x_pos], r8
			mov qword [enemy24_y_pos], r9

		.ene25:
			add r8, 3

			mov r10, [cole25]
			cmp r10, 1 
			je .ene26 
			mov qword [enemy25_x_pos], r8
			mov qword [enemy25_y_pos], r9

		.ene26:
			add r8, 3

			mov r10, [cole26]
			cmp r10, 1 
			je .ene27 
			mov qword [enemy26_x_pos], r8
			mov qword [enemy26_y_pos], r9

		.ene27:
			add r8, 3
			
			mov r10, [cole27]
			cmp r10, 1 
			je .ene28 
			mov qword [enemy27_x_pos], r8
			mov qword [enemy27_y_pos], r9

		.ene28:
			add r8, 3

			mov r10, [cole28]
			cmp r10, 1 
			je .ene29 
			mov qword [enemy28_x_pos], r8
			mov qword [enemy28_y_pos], r9

		.ene29:
			add r8, 3

			mov r10, [cole9]
			cmp r10, 1 
			je .ene30 
			mov qword [enemy29_x_pos], r8
			mov qword [enemy29_y_pos], r9

		.ene30:
			add r8, 3

			mov r10, [cole30]
			cmp r10, 1 
			je .ene31 
			mov qword [enemy30_x_pos], r8
			mov qword [enemy30_y_pos], r9
		
		.ene31:
			mov r8, [enemy_x_pos]
			inc r9

			mov r10, [cole31]
			cmp r10, 1 
			je .ene32 
			mov qword [enemy31_x_pos], r8
			mov qword [enemy31_y_pos], r9

		.ene32:
			add r8, 3 

			mov r10, [cole32]
			cmp r10, 1 
			je .ene33 
			mov qword [enemy32_x_pos], r8
			mov qword [enemy32_y_pos], r9

		.ene33:
			add r8, 3
			mov r10, [cole33]
			cmp r10, 1 
			je .ene34 
			mov qword [enemy33_x_pos], r8
			mov qword [enemy33_y_pos], r9

		.ene34:
			add r8, 3

			mov r10, [cole34]
			cmp r10, 1 
			je .ene35 
			mov qword [enemy34_x_pos], r8
			mov qword [enemy34_y_pos], r9

		.ene35:
			add r8, 3

			mov r10, [cole35]
			cmp r10, 1 
			je .ene36 
			mov qword [enemy35_x_pos], r8
			mov qword [enemy35_y_pos], r9

		.ene36:
			add r8, 3

			mov r10, [cole36]
			cmp r10, 1 
			je .ene37 
			mov qword [enemy36_x_pos], r8
			mov qword [enemy36_y_pos], r9

		.ene37:
			add r8, 3
			
			mov r10, [cole37]
			cmp r10, 1 
			je .ene38 
			mov qword [enemy37_x_pos], r8
			mov qword [enemy37_y_pos], r9

		.ene38:
			add r8, 3

			mov r10, [cole38]
			cmp r10, 1 
			je .ene39 
			mov qword [enemy38_x_pos], r8
			mov qword [enemy38_y_pos], r9

		.ene39:
			add r8, 3

			mov r10, [cole9]
			cmp r10, 1 
			je .ene40 
			mov qword [enemy39_x_pos], r8
			mov qword [enemy39_y_pos], r9

		.ene40:
			add r8, 3

			mov r10, [cole40]
			cmp r10, 1 
			je .ene41 
			mov qword [enemy40_x_pos], r8
			mov qword [enemy40_y_pos], r9

		.ene41:
			mov r8, [enemy_x_pos]
			inc r9

			mov r10, [cole41]
			cmp r10, 1 
			je .ene42 
			mov qword [enemy41_x_pos], r8
			mov qword [enemy41_y_pos], r9

		.ene42:
			add r8, 3 

			mov r10, [cole42]
			cmp r10, 1 
			je .ene43 
			mov qword [enemy42_x_pos], r8
			mov qword [enemy42_y_pos], r9

		.ene43:
			add r8, 3 

			mov r10, [cole3]
			cmp r10, 1 
			je .ene44 
			mov qword [enemy43_x_pos], r8
			mov qword [enemy43_y_pos], r9

		.ene44:
			add r8, 3

			mov r10, [cole44]
			cmp r10, 1 
			je .ene45 
			mov qword [enemy44_x_pos], r8
			mov qword [enemy44_y_pos], r9

		.ene45:
			add r8, 3

			mov r10, [cole45]
			cmp r10, 1 
			je .ene46 
			mov qword [enemy45_x_pos], r8
			mov qword [enemy45_y_pos], r9

		.ene46:
			add r8, 3

			mov r10, [cole46]
			cmp r10, 1 
			je .ene47 
			mov qword [enemy46_x_pos], r8
			mov qword [enemy46_y_pos], r9

		.ene47:
			add r8, 3
			
			mov r10, [cole47]
			cmp r10, 1 
			je .ene48 
			mov qword [enemy47_x_pos], r8
			mov qword [enemy47_y_pos], r9

		.ene48:
			add r8, 3

			mov r10, [cole48]
			cmp r10, 1 
			je .ene49 
			mov qword [enemy48_x_pos], r8
			mov qword [enemy48_y_pos], r9

		.ene49:
			add r8,3

			mov r10, [cole49]
			cmp r10, 1 
			je .ene50 
			mov qword [enemy49_x_pos], r8
			mov qword [enemy49_y_pos], r9

		.ene50:
			add r8, 3

			mov r10, [cole50]
			cmp r10, 1 
			je .ene51 
			mov qword [enemy50_x_pos], r8
			mov qword [enemy50_y_pos], r9

		.ene51:
			mov r8, [enemy_x_pos]
			inc r9

			mov r10, [cole51]
			cmp r10, 1 
			je .ene52 
			mov qword [enemy51_x_pos], r8
			mov qword [enemy51_y_pos], r9

		.ene52:
			add r8, 3 

			mov r10, [cole52]
			cmp r10, 1 
			je .ene53 
			mov qword [enemy52_x_pos], r8
			mov qword [enemy52_y_pos], r9

		.ene53:
			add r8, 3

			mov r10, [cole53]
			cmp r10, 1 
			je .ene54 
			mov qword [enemy53_x_pos], r8
			mov qword [enemy53_y_pos], r9

		.ene54:
			add r8, 3

			mov r10, [cole54]
			cmp r10, 1 
			je .ene55 
			mov qword [enemy54_x_pos], r8
			mov qword [enemy54_y_pos], r9

		.ene55:
			add r8, 3

			mov r10, [cole55]
			cmp r10, 1 
			je .ene56 
			mov qword [enemy55_x_pos], r8
			mov qword [enemy55_y_pos], r9

		.ene56:
			add r8, 3

			mov r10, [cole56]
			cmp r10, 1 
			je .ene57 
			mov qword [enemy56_x_pos], r8
			mov qword [enemy56_y_pos], r9

		.ene57:
			add r8, 3
			
			mov r10, [cole57]
			cmp r10, 1 
			je .ene58 
			mov qword [enemy57_x_pos], r8
			mov qword [enemy57_y_pos], r9

		.ene58:
			add r8, 3

			mov r10, [cole58]
			cmp r10, 1 
			je .ene59 
			mov qword [enemy58_x_pos], r8
			mov qword [enemy58_y_pos], r9

		.ene59:
			add r8, 3

			mov r10, [cole59]
			cmp r10, 1 
			je .ene60 
			mov qword [enemy59_x_pos], r8
			mov qword [enemy59_y_pos], r9

		.ene60:
			add r8,3

			mov r10, [cole60]
			cmp r10, 1 
			je .ene61 
			mov qword [enemy60_x_pos], r8
			mov qword [enemy60_y_pos], r9
			
		.ene61:

	pop rax
	pop rcx 
	ret



print_enemy:

	push rax
	push rcx 

	mov r11, [limpiar]
	cmp r11, 1
	je .limpiar
	call calc_dir_enemy 
	.limpiar:

	;Enemigos
		;Enemigo1
			mov r8, [enemy1_x_pos]
			mov r9, [enemy1_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole1]
			cmp r10, 2
			je .eliminado1
			mov r10, [cole1]
			cmp r10, 0
			jne .killed 
				cmp r11, 0
				jne .killedl
			mov byte [r8], char_O 
			jmp .en2
			.killed: 
				mov byte [r8], char_space
				mov qword [enemy1_x_pos], 2
				mov qword [enemy1_y_pos], 2 
				mov qword [cole1], 2
			.killedl:
				mov byte [r8], char_space
			.eliminado1:

		;Enemigo2
			.en2:
			mov r8, [enemy2_x_pos]
			mov r9, [enemy2_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole2]
			cmp r10, 2
			je .eliminado2
			mov r10, [cole2]
			cmp r10, 0
			jne .killed2
				cmp r11, 0
				jne .killed2l
			mov byte [r8], char_O 
			jmp .en3
			.killed2: 
				mov byte [r8], char_space
				mov qword [enemy2_x_pos], 2
				mov qword [enemy2_y_pos], 2 
				mov qword [cole2], 2
			.killed2l:
				mov byte [r8], char_space
			.eliminado2:
	
		;Enemigo3
			.en3:
			mov r8, [enemy3_x_pos]
			mov r9, [enemy3_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole3]
			cmp r10, 2
			je .eliminado3
			mov r10, [cole3]
			cmp r10, 0
			jne .killed3 
				cmp r11, 0
				jne .killed3l
			mov byte [r8], char_O 
			jmp .en4
			.killed3: 
				mov byte [r8], char_space
				mov qword [enemy3_x_pos], 2
				mov qword [enemy3_y_pos], 2 
				mov qword [cole3], 2
			.killed3l:
				mov byte [r8], char_space
			.eliminado3:

		;Enemigo4
			.en4:
			mov r8, [enemy4_x_pos]
			mov r9, [enemy4_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole4]
			cmp r10, 2
			je .eliminado4
			mov r10, [cole4]
			cmp r10, 0
			jne .killed4 
				cmp r11, 0
				jne .killed4l
			mov byte [r8], char_O 
			jmp .en5
			.killed4: 
				mov byte [r8], char_space
				mov qword [enemy4_x_pos], 2
				mov qword [enemy4_y_pos], 2 
				mov qword [cole4], 2
			.killed4l:
				mov byte [r8], char_space
			.eliminado4:

		;Enemigo5
			.en5:
			mov r8, [enemy5_x_pos]
			mov r9, [enemy5_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole5]
			cmp r10, 2
			je .eliminado5
			mov r10, [cole5]
			cmp r10, 0
			jne .killed5
				cmp r11, 0
				jne .killed5l
			mov byte [r8], char_O 
			jmp .en6
			.killed5: 
				mov byte [r8], char_space
				mov qword [enemy5_x_pos], 2
				mov qword [enemy5_y_pos], 2 
				mov qword [cole5], 2
			.killed5l:
				mov byte [r8], char_space
			.eliminado5:

		;Enemigo6
			.en6:
			mov r8, [enemy6_x_pos]
			mov r9, [enemy6_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole6]
			cmp r10, 2
			je .eliminado6
			mov r10, [cole6]
			cmp r10, 0
			jne .killed6 
				cmp r11, 0
				jne .killed6l
			mov byte [r8], char_O 
			jmp .en7
			.killed6: 
				mov byte [r8], char_space
				mov qword [enemy6_x_pos], 2
				mov qword [enemy6_y_pos], 2 
				mov qword [cole6], 2
			.killed6l:
				mov byte [r8], char_space
			.eliminado6:

		;Enemigo7
			.en7:
			mov r8, [enemy7_x_pos]
			mov r9, [enemy7_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole7]
			cmp r10, 2
			je .eliminado7
			mov r10, [cole7]
			cmp r10, 0
			jne .killed7
				cmp r11, 0
				jne .killed7l
			mov byte [r8], char_O 
			jmp .en8
			.killed7: 
				mov byte [r8], char_space
				mov qword [enemy7_x_pos], 2
				mov qword [enemy7_y_pos], 2 
				mov qword [cole7], 2
			.killed7l:
				mov byte [r8], char_space
			.eliminado7:

		;Enemigo8
			.en8:
			mov r8, [enemy8_x_pos]
			mov r9, [enemy8_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole8]
			cmp r10, 2
			je .eliminado8
			mov r10, [cole8]
			cmp r10, 0
			jne .killed8 
				cmp r11, 0
				jne .killed8l
			mov byte [r8], char_O 
			jmp .en9
			.killed8: 
				mov byte [r8], char_space
				mov qword [enemy8_x_pos], 2
				mov qword [enemy8_y_pos], 2 
				mov qword [cole8], 2
			.killed8l:
				mov byte [r8], char_space
			.eliminado8:

		;Enemigo9
			.en9:
			mov r8, [enemy9_x_pos]
			mov r9, [enemy9_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole9]
			cmp r10, 2
			je .eliminado9
			mov r10, [cole9]
			cmp r10, 0
			jne .killed9 
				cmp r11, 0
				jne .killed9l
			mov byte [r8], char_O 
			jmp .en10
			.killed9:
				mov byte [r8], char_space
				mov qword [enemy9_x_pos], 2
				mov qword [enemy9_y_pos], 2 
				mov qword [cole9], 2
			.killed9l:
				mov byte [r8], char_space	
				.eliminado9: 

		;Enemigo10
			.en10:
			mov r8, [enemy10_x_pos]
			mov r9, [enemy10_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole10]
			cmp r10, 2
			je .eliminado10
			mov r10, [cole10]
			cmp r10, 0
			jne .killed10 
				cmp r11, 0
				jne .killed10l
			mov byte [r8], char_O 
			jmp .en11
			.killed10:
				mov byte [r8], char_space
				mov qword [enemy10_x_pos], 2
				mov qword [enemy10_y_pos], 2 
				mov qword [cole10], 2
			.killed10l:
				mov byte [r8], char_space	
				.eliminado10: 

		;Enemigo11
			.en11:
			mov r8, [enemy11_x_pos]
			mov r9, [enemy11_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole11]
			cmp r10, 2
			je .eliminado11
			mov r10, [cole11]
			cmp r10, 0
			jne .killed11 
				cmp r11, 0
				jne .killed11l
			mov byte [r8], char_O 
			jmp .en12
			.killed11:
				mov byte [r8], char_space
				mov qword [enemy11_x_pos], 2
				mov qword [enemy11_y_pos], 2 
				mov qword [cole11], 2
			.killed11l:
				mov byte [r8], char_space	
				.eliminado11: 

		;Enemigo12
			.en12:
			mov r8, [enemy12_x_pos]
			mov r9, [enemy12_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole12]
			cmp r10, 2
			je .eliminado12
			mov r10, [cole12]
			cmp r10, 0
			jne .killed12 
				cmp r11, 0
				jne .killed12l
			mov byte [r8], char_O 
			jmp .en13
			.killed12:
				mov byte [r8], char_space
				mov qword [enemy12_x_pos], 2
				mov qword [enemy12_y_pos], 2 
				mov qword [cole12], 2
			.killed12l:
				mov byte [r8], char_space	
				.eliminado12: 
	
		;Enemigo13
			.en13:
			mov r8, [enemy13_x_pos]
			mov r9, [enemy13_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole13]
			cmp r10, 2
			je .eliminado13
			mov r10, [cole13]
			cmp r10, 0
			jne .killed13 
				cmp r11, 0
				jne .killed13l
			mov byte [r8], char_O 
			jmp .en14
			.killed13:
				mov byte [r8], char_space
				mov qword [enemy13_x_pos], 2
				mov qword [enemy13_y_pos], 2 
				mov qword [cole13], 2
			.killed13l:
				mov byte [r8], char_space	
				.eliminado13: 

		;Enemigo14
			.en14:
			mov r8, [enemy14_x_pos]
			mov r9, [enemy14_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole14]
			cmp r10, 2
			je .eliminado14
			mov r10, [cole14]
			cmp r10, 0
			jne .killed14
				cmp r11, 0
				jne .killed14l
			mov byte [r8], char_O 
			jmp .en15
			.killed14:
				mov byte [r8], char_space
				mov qword [enemy14_x_pos], 2
				mov qword [enemy14_y_pos], 2 
				mov qword [cole14], 2
			.killed14l:
				mov byte [r8], char_space	
				.eliminado14: 

		;Enemigo15
			.en15:
			mov r8, [enemy15_x_pos]
			mov r9, [enemy15_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			
			mov r10, [cole15]
			cmp r10, 2
			je .eliminado15
			mov r10, [cole15]
			cmp r10, 0
			jne .killed15
				cmp r11, 0
				jne .killed15l
			mov byte [r8], char_O 
			jmp .en16
			.killed15:
				mov byte [r8], char_space
				mov qword [enemy15_x_pos], 2
				mov qword [enemy15_y_pos], 2 
				mov qword [cole15], 2
			.killed15l:
				mov byte [r8], char_space	
				.eliminado15: 

		;Enemigo16
			.en16:
			mov r8, [enemy16_x_pos]
			mov r9, [enemy16_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole16]
			cmp r10, 2
			je .eliminado16
			mov r10, [cole16]
			cmp r10, 0
			jne .killed16
				cmp r11, 0
				jne .killed16l
			mov byte [r8], char_O 
			jmp .en17
			.killed16:
				mov byte [r8], char_space
				mov qword [enemy16_x_pos], 2
				mov qword [enemy16_y_pos], 2 
				mov qword [cole16], 2
			.killed16l:
				mov byte [r8], char_space	
				.eliminado16: 

		;Enemigo17
			.en17:
			mov r8, [enemy17_x_pos]
			mov r9, [enemy17_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole17]
			cmp r10, 2
			je .eliminado17
			mov r10, [cole17]
			cmp r10, 0
			jne .killed17
				cmp r11, 0
				jne .killed17l
			mov byte [r8], char_O 
			jmp .en18
			.killed17:
				mov byte [r8], char_space
				mov qword [enemy17_x_pos], 2
				mov qword [enemy17_y_pos], 2 
				mov qword [cole17], 2
			.killed17l:
				mov byte [r8], char_space	
				.eliminado17: 

		;Enemigo18
			.en18:
			mov r8, [enemy18_x_pos]
			mov r9, [enemy18_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
				mov r10, [cole18]
			cmp r10, 2
			je .eliminado18
			mov r10, [cole18]
			cmp r10, 0
			jne .killed18
				cmp r11, 0
				jne .killed18l
			mov byte [r8], char_O 
			jmp .en19
			.killed18:
				mov byte [r8], char_space
				mov qword [enemy18_x_pos], 2
				mov qword [enemy18_y_pos], 2 
				mov qword [cole18], 2
			.killed18l:
				mov byte [r8], char_space	
				.eliminado18: 

		;Enemigo19
			.en19:
			mov r8, [enemy19_x_pos]
			mov r9, [enemy19_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole19]
			cmp r10, 2
			je .eliminado19
			mov r10, [cole19]
			cmp r10, 0
			jne .killed19
				cmp r11, 0
				jne .killed19l
			mov byte [r8], char_O 
			jmp .en20
			.killed19:
				mov byte [r8], char_space
				mov qword [enemy19_x_pos], 2
				mov qword [enemy19_y_pos], 2 
				mov qword [cole19], 2
			.killed19l:
				mov byte [r8], char_space	
				.eliminado19: 

		;Enemigo20
			.en20:
			mov r8, [enemy20_x_pos]
			mov r9, [enemy20_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole20]
			cmp r10, 2
			je .eliminado20
			mov r10, [cole20]
			cmp r10, 0
			jne .killed20
				cmp r11, 0
				jne .killed20l
			mov byte [r8], char_O 
			jmp .en21
			.killed20:
				mov byte [r8], char_space
				mov qword [enemy20_x_pos], 2
				mov qword [enemy20_y_pos], 2 
				mov qword [cole20], 2
			.killed20l:
				mov byte [r8], char_space	
				.eliminado20: 

		;Enemigo21
			.en21:
			mov r8, [enemy21_x_pos]
			mov r9, [enemy21_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole21]
			cmp r10, 2
			je .eliminado21
			mov r10, [cole21]
			cmp r10, 0
			jne .killed21
				cmp r11, 0
				jne .killed21l
			mov byte [r8], char_U 
			jmp .en22
			.killed21:
				mov byte [r8], char_space
				mov qword [enemy21_x_pos], 2
				mov qword [enemy21_y_pos], 2 
				mov qword [cole21], 2
			.killed21l:
				mov byte [r8], char_space	
				.eliminado21: 
	
		;Enemigo22
			.en22:
			mov r8, [enemy22_x_pos]
			mov r9, [enemy22_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole22]
			cmp r10, 2
			je .eliminado22
			mov r10, [cole22]
			cmp r10, 0
			jne .killed22
				cmp r11, 0
				jne .killed22l
			mov byte [r8], char_U 
			jmp .en23
			.killed22:
				mov byte [r8], char_space
				mov qword [enemy22_x_pos], 2
				mov qword [enemy22_y_pos], 2 
				mov qword [cole22], 2
			.killed22l:
				mov byte [r8], char_space	
				.eliminado22: 
	
		;Enemigo23
			.en23:
			mov r8, [enemy23_x_pos]
			mov r9, [enemy23_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole23]
			cmp r10, 2
			je .eliminado23
			mov r10, [cole23]
			cmp r10, 0
			jne .killed23
				cmp r11, 0
				jne .killed23l
			mov byte [r8], char_U 
			jmp .en24
			.killed23:
				mov byte [r8], char_space
				mov qword [enemy23_x_pos], 2
				mov qword [enemy23_y_pos], 2 
				mov qword [cole23], 2
			.killed23l:
				mov byte [r8], char_space	
				.eliminado23: 

		;Enemigo24
			.en24:
			mov r8, [enemy24_x_pos]
			mov r9, [enemy24_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole24]
			cmp r10, 2
			je .eliminado24
			mov r10, [cole24]
			cmp r10, 0
			jne .killed24
				cmp r11, 0
				jne .killed24l
			mov byte [r8], char_U 
			jmp .en25
			.killed24:
				mov byte [r8], char_space
				mov qword [enemy24_x_pos], 2
				mov qword [enemy24_y_pos], 2 
				mov qword [cole24], 2
			.killed24l:
				mov byte [r8], char_space	
				.eliminado24: 

		;Enemigo25
			.en25:
			mov r8, [enemy25_x_pos]
			mov r9, [enemy25_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole25]
			cmp r10, 2
			je .eliminado25
			mov r10, [cole25]
			cmp r10, 0
			jne .killed25
				cmp r11, 0
				jne .killed25l
			mov byte [r8], char_U
			jmp .en26
			.killed25:
				mov byte [r8], char_space
				mov qword [enemy25_x_pos], 2
				mov qword [enemy25_y_pos], 2 
				mov qword [cole25], 2
			.killed25l:
				mov byte [r8], char_space	
				.eliminado25: 

		;Enemigo26
			.en26:
			mov r8, [enemy26_x_pos]
			mov r9, [enemy26_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole26]
			cmp r10, 2
			je .eliminado26
			mov r10, [cole26]
			cmp r10, 0
			jne .killed26
				cmp r11, 0
				jne .killed26l
			mov byte [r8], char_U 
			jmp .en27
			.killed26:
				mov byte [r8], char_space
				mov qword [enemy26_x_pos], 2
				mov qword [enemy26_y_pos], 2 
				mov qword [cole26], 2
			.killed26l:
				mov byte [r8], char_space	
				.eliminado26: 

		;Enemigo27
			.en27:
			mov r8, [enemy27_x_pos]
			mov r9, [enemy27_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole27]
			cmp r10, 2
			je .eliminado27
			mov r10, [cole27]
			cmp r10, 0
			jne .killed27
				cmp r11, 0
				jne .killed27l
			mov byte [r8], char_U 
			jmp .en28
			.killed27:
				mov byte [r8], char_space
				mov qword [enemy27_x_pos], 2
				mov qword [enemy27_y_pos], 2 
				mov qword [cole27], 2
			.killed27l:
				mov byte [r8], char_space	
				.eliminado27: 

		;Enemigo28
			.en28:
			mov r8, [enemy28_x_pos]
			mov r9, [enemy28_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole28]
			cmp r10, 2
			je .eliminado28
			mov r10, [cole28]
			cmp r10, 0
			jne .killed28
				cmp r11, 0
				jne .killed28l
			mov byte [r8], char_U
			jmp .en29
			.killed28:
				mov byte [r8], char_space
				mov qword [enemy28_x_pos], 2
				mov qword [enemy28_y_pos], 2 
				mov qword [cole28], 2
			.killed28l:
				mov byte [r8], char_space	
				.eliminado28: 	

		;Enemigo29
			.en29:
			mov r8, [enemy29_x_pos]
			mov r9, [enemy29_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole29]
			cmp r10, 2
			je .eliminado29
			mov r10, [cole29]
			cmp r10, 0
			jne .killed29
				cmp r11, 0
				jne .killed29l
			mov byte [r8], char_U
			jmp .en30
			.killed29:
				mov byte [r8], char_space
				mov qword [enemy29_x_pos], 2
				mov qword [enemy29_y_pos], 2 
				mov qword [cole29], 2
			.killed29l:
				mov byte [r8], char_space	
				.eliminado29: 

		;Enemigo30
			.en30:
			mov r8, [enemy30_x_pos]
			mov r9, [enemy30_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole30]
			cmp r10, 2
			je .eliminado30
			mov r10, [cole30]
			cmp r10, 0
			jne .killed30
				cmp r11, 0
				jne .killed30l
			mov byte [r8], char_U 
			jmp .en31
			.killed30:
				mov byte [r8], char_space
				mov qword [enemy30_x_pos], 2
				mov qword [enemy30_y_pos], 2 
				mov qword [cole30], 2
			.killed30l:
				mov byte [r8], char_space	
				.eliminado30: 

		;Enemigo31
			.en31:
			mov r8, [enemy31_x_pos]
			mov r9, [enemy31_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole31]
			cmp r10, 2
			je .eliminado31
			mov r10, [cole31]
			cmp r10, 0
			jne .killed31
				cmp r11, 0
				jne .killed31l
			mov byte [r8], char_U 
			jmp .en32
			.killed31:
				mov byte [r8], char_space
				mov qword [enemy31_x_pos], 2
				mov qword [enemy31_y_pos], 2 
				mov qword [cole31], 2
			.killed31l:
				mov byte [r8], char_space	
				.eliminado31: 

		;Enemigo32
			.en32:
			mov r8, [enemy32_x_pos]
			mov r9, [enemy32_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole32]
			cmp r10, 2
			je .eliminado32
			mov r10, [cole32]
			cmp r10, 0
			jne .killed32
				cmp r11, 0
				jne .killed32l
			mov byte [r8], char_U 
			jmp .en33
			.killed32:
				mov byte [r8], char_space
				mov qword [enemy32_x_pos], 2
				mov qword [enemy32_y_pos], 2 
				mov qword [cole32], 2
			.killed32l:
				mov byte [r8], char_space	
				.eliminado32: 
	
		;Enemigo33
			.en33:
			mov r8, [enemy33_x_pos]
			mov r9, [enemy33_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole33]
			cmp r10, 2
			je .eliminado33
			mov r10, [cole33]
			cmp r10, 0
			jne .killed33
				cmp r11, 0
				jne .killed33l
			mov byte [r8], char_U 
			jmp .en34
			.killed33:
				mov byte [r8], char_space
				mov qword [enemy33_x_pos], 2
				mov qword [enemy33_y_pos], 2 
				mov qword [cole33], 2
			.killed33l:
				mov byte [r8], char_space	
				.eliminado33:

		;Enemigo34
			.en34:
			mov r8, [enemy34_x_pos]
			mov r9, [enemy34_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole34]
			cmp r10, 2
			je .eliminado34
			mov r10, [cole34]
			cmp r10, 0
			jne .killed34
				cmp r11, 0
				jne .killed34l
			mov byte [r8], char_U 
			jmp .en35
			.killed34:
				mov byte [r8], char_space
				mov qword [enemy34_x_pos], 2
				mov qword [enemy34_y_pos], 2 
				mov qword [cole34], 2
			.killed34l:
				mov byte [r8], char_space	
				.eliminado34:

		;Enemigo35
			.en35:
			mov r8, [enemy35_x_pos]
			mov r9, [enemy35_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole35]
			cmp r10, 2
			je .eliminado35
			mov r10, [cole35]
			cmp r10, 0
			jne .killed35
				cmp r11, 0
				jne .killed35l
			mov byte [r8], char_U 
			jmp .en36
			.killed35:
				mov byte [r8], char_space
				mov qword [enemy35_x_pos], 2
				mov qword [enemy35_y_pos], 2 
				mov qword [cole35], 2
			.killed35l:
				mov byte [r8], char_space	
				.eliminado35:

		;Enemigo36
			.en36:
			mov r8, [enemy36_x_pos]
			mov r9, [enemy36_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole36]
			cmp r10, 2
			je .eliminado36
			mov r10, [cole36]
			cmp r10, 0
			jne .killed36
				cmp r11, 0
				jne .killed36l
			mov byte [r8], char_U 
			jmp .en37
			.killed36:
				mov byte [r8], char_space
				mov qword [enemy36_x_pos], 2
				mov qword [enemy36_y_pos], 2 
				mov qword [cole36], 2
			.killed36l:
				mov byte [r8], char_space	
				.eliminado36:

		;Enemigo37
			.en37:
			mov r8, [enemy37_x_pos]
			mov r9, [enemy37_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole37]
			cmp r10, 2
			je .eliminado37
			mov r10, [cole37]
			cmp r10, 0
			jne .killed37
				cmp r11, 0
				jne .killed37l
			mov byte [r8], char_U
			jmp .en38
			.killed37:
				mov byte [r8], char_space
				mov qword [enemy37_x_pos], 2
				mov qword [enemy37_y_pos], 2 
				mov qword [cole37], 2
			.killed37l:
				mov byte [r8], char_space	
				.eliminado37:

		;Enemigo38
			.en38:
			mov r8, [enemy38_x_pos]
			mov r9, [enemy38_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole38]
			cmp r10, 2
			je .eliminado38
			mov r10, [cole38]
			cmp r10, 0
			jne .killed38
				cmp r11, 0
				jne .killed38l
			mov byte [r8], char_U 
			jmp .en39
			.killed38:
				mov byte [r8], char_space
				mov qword [enemy38_x_pos], 2
				mov qword [enemy38_y_pos], 2 
				mov qword [cole38], 2
			.killed38l:
				mov byte [r8], char_space	
				.eliminado38:	

		;Enemigo39
			.en39:
			mov r8, [enemy39_x_pos]
			mov r9, [enemy39_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole39]
			cmp r10, 2
			je .eliminado39
			mov r10, [cole39]
			cmp r10, 0
			jne .killed39
				cmp r11, 0
				jne .killed39l
			mov byte [r8], char_U 
			jmp .en40
			.killed39:
				mov byte [r8], char_space
				mov qword [enemy39_x_pos], 2
				mov qword [enemy39_y_pos], 2 
				mov qword [cole39], 2
			.killed39l:
				mov byte [r8], char_space	
				.eliminado39:

		;Enemigo40
			.en40:
			mov r8, [enemy40_x_pos]
			mov r9, [enemy40_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole40]
			cmp r10, 2
			je .eliminado40
			mov r10, [cole40]
			cmp r10, 0
			jne .killed40
				cmp r11, 0
				jne .killed40l
			mov byte [r8], char_U
			jmp .en41
			.killed40:
				mov byte [r8], char_space
				mov qword [enemy40_x_pos], 2
				mov qword [enemy40_y_pos], 2 
				mov qword [cole40], 2
			.killed40l:
				mov byte [r8], char_space	
				.eliminado40:

		;Enemigo41
			.en41:
			mov r8, [enemy41_x_pos]
			mov r9, [enemy41_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole41]
			cmp r10, 2
			je .eliminado41
			mov r10, [cole41]
			cmp r10, 0
			jne .killed41
				cmp r11, 0
				jne .killed41l
			mov byte [r8], char_T 
			jmp .en42
			.killed41:
				mov byte [r8], char_space
				mov qword [enemy41_x_pos], 2
				mov qword [enemy41_y_pos], 2 
				mov qword [cole41], 2
			.killed41l:
				mov byte [r8], char_space	
				.eliminado41:
		
		;Enemigo42
			.en42:
			mov r8, [enemy42_x_pos]
			mov r9, [enemy42_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole42]
			cmp r10, 2
			je .eliminado42
			mov r10, [cole42]
			cmp r10, 0
			jne .killed42
				cmp r11, 0
				jne .killed42l
			mov byte [r8], char_T
			jmp .en43
			.killed42:
				mov byte [r8], char_space
				mov qword [enemy42_x_pos], 2
				mov qword [enemy42_y_pos], 2 
				mov qword [cole42], 2
			.killed42l:
				mov byte [r8], char_space	
				.eliminado42:
	
		;Enemigo43
			.en43:
			mov r8, [enemy43_x_pos]
			mov r9, [enemy43_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole43]
			cmp r10, 2
			je .eliminado43
			mov r10, [cole43]
			cmp r10, 0
			jne .killed43
				cmp r11, 0
				jne .killed43l
			mov byte [r8], char_T 
			jmp .en44
			.killed43:
				mov byte [r8], char_space
				mov qword [enemy43_x_pos], 2
				mov qword [enemy43_y_pos], 2 
				mov qword [cole43], 2
			.killed43l:
				mov byte [r8], char_space	
				.eliminado43:

		;Enemigo44
			.en44:
			mov r8, [enemy44_x_pos]
			mov r9, [enemy44_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole44]
			cmp r10, 2
			je .eliminado44
			mov r10, [cole44]
			cmp r10, 0
			jne .killed44
				cmp r11, 0
				jne .killed44l
			mov byte [r8], char_T 
			jmp .en45
			.killed44:
				mov byte [r8], char_space
				mov qword [enemy44_x_pos], 2
				mov qword [enemy44_y_pos], 2 
				mov qword [cole44], 2
			.killed44l:
				mov byte [r8], char_space	
				.eliminado44:

		;Enemigo45
			.en45:
			mov r8, [enemy45_x_pos]
			mov r9, [enemy45_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole45]
			cmp r10, 2
			je .eliminado45
			mov r10, [cole45]
			cmp r10, 0
			jne .killed45
				cmp r11, 0
				jne .killed45l
			mov byte [r8], char_T 
			jmp .en46
			.killed45:
				mov byte [r8], char_space
				mov qword [enemy45_x_pos], 2
				mov qword [enemy45_y_pos], 2 
				mov qword [cole45], 2
			.killed45l:
				mov byte [r8], char_space	
				.eliminado45:

		;Enemigo46
			.en46:
			mov r8, [enemy46_x_pos]
			mov r9, [enemy46_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole46]
			cmp r10, 2
			je .eliminado46
			mov r10, [cole46]
			cmp r10, 0
			jne .killed46
				cmp r11, 0
				jne .killed46l
			mov byte [r8], char_T 
			jmp .en47
			.killed46:
				mov byte [r8], char_space
				mov qword [enemy46_x_pos], 2
				mov qword [enemy46_y_pos], 2 
				mov qword [cole46], 2
			.killed46l:
				mov byte [r8], char_space	
				.eliminado46:

		;Enemigo47
			.en47:
			mov r8, [enemy47_x_pos]
			mov r9, [enemy47_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole47]
			cmp r10, 2
			je .eliminado47
			mov r10, [cole47]
			cmp r10, 0
			jne .killed47
				cmp r11, 0
				jne .killed47l
			mov byte [r8], char_T 
			jmp .en48
			.killed47:
				mov byte [r8], char_space
				mov qword [enemy47_x_pos], 2
				mov qword [enemy47_y_pos], 2 
				mov qword [cole47], 2
			.killed47l:
				mov byte [r8], char_space	
				.eliminado47:

		;Enemigo48
			.en48:
			mov r8, [enemy48_x_pos]
			mov r9, [enemy48_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole48]
			cmp r10, 2
			je .eliminado48
			mov r10, [cole48]
			cmp r10, 0
			jne .killed48
				cmp r11, 0
				jne .killed48l
			mov byte [r8], char_T 
			jmp .en49
			.killed48:
				mov byte [r8], char_space
				mov qword [enemy48_x_pos], 2
				mov qword [enemy48_y_pos], 2 
				mov qword [cole48], 2
			.killed48l:
				mov byte [r8], char_space	
				.eliminado48:	

		;Enemigo49
			.en49:
			mov r8, [enemy49_x_pos]
			mov r9, [enemy49_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole49]
			cmp r10, 2
			je .eliminado49
			mov r10, [cole49]
			cmp r10, 0
			jne .killed49
				cmp r11, 0
				jne .killed49l
			mov byte [r8], char_T 
			jmp .en50
			.killed49:
				mov byte [r8], char_space
				mov qword [enemy49_x_pos], 2
				mov qword [enemy49_y_pos], 2 
				mov qword [cole49], 2
			.killed49l:
				mov byte [r8], char_space	
				.eliminado49:	

		;Enemigo50
			.en50:
			mov r8, [enemy50_x_pos]
			mov r9, [enemy50_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole50]
			cmp r10, 2
			je .eliminado50
			mov r10, [cole50]
			cmp r10, 0
			jne .killed50
				cmp r11, 0
				jne .killed50l
			mov byte [r8], char_T 
			jmp .en51
			.killed50:
				mov byte [r8], char_space
				mov qword [enemy50_x_pos], 2
				mov qword [enemy50_y_pos], 2 
				mov qword [cole50], 2
			.killed50l:
				mov byte [r8], char_space	
				.eliminado50:

		;Enemigo51
			.en51:
			mov r8, [enemy51_x_pos]
			mov r9, [enemy51_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole51]
			cmp r10, 2
			je .eliminado51
			mov r10, [cole51]
			cmp r10, 0
			jne .killed51
				cmp r11, 0
				jne .killed51l
			mov byte [r8], char_T 
			jmp .en52
			.killed51:
				mov byte [r8], char_space
				mov qword [enemy51_x_pos], 2
				mov qword [enemy51_y_pos], 2 
				mov qword [cole51], 2
			.killed51l:
				mov byte [r8], char_space	
				.eliminado51:

		;Enemigo52
			.en52:
			mov r8, [enemy52_x_pos]
			mov r9, [enemy52_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole52]
			cmp r10, 2
			je .eliminado52
			mov r10, [cole52]
			cmp r10, 0
			jne .killed52
				cmp r11, 0
				jne .killed52l
			mov byte [r8], char_T 
			jmp .en53
			.killed52:
				mov byte [r8], char_space
				mov qword [enemy52_x_pos], 2
				mov qword [enemy52_y_pos], 2 
				mov qword [cole52], 2
			.killed52l:
				mov byte [r8], char_space	
				.eliminado52:
	
		;Enemigo53
			.en53:
			mov r8, [enemy53_x_pos]
			mov r9, [enemy53_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole53]
			cmp r10, 2
			je .eliminado53
			mov r10, [cole53]
			cmp r10, 0
			jne .killed53
				cmp r11, 0
				jne .killed53l
			mov byte [r8], char_T 
			jmp .en54
			.killed53:
				mov byte [r8], char_space
				mov qword [enemy53_x_pos], 2
				mov qword [enemy53_y_pos], 2 
				mov qword [cole53], 2
			.killed53l:
				mov byte [r8], char_space	
				.eliminado53:

		;Enemigo54
			.en54:
			mov r8, [enemy54_x_pos]
			mov r9, [enemy54_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole54]
			cmp r10, 2
			je .eliminado54
			mov r10, [cole54]
			cmp r10, 0
			jne .killed54
				cmp r11, 0
				jne .killed54l
			mov byte [r8], char_T 
			jmp .en55
			.killed54:
				mov byte [r8], char_space
				mov qword [enemy54_x_pos], 2
				mov qword [enemy54_y_pos], 2 
				mov qword [cole54], 2
			.killed54l:
				mov byte [r8], char_space	
				.eliminado54:

		;Enemigo55
			.en55:
			mov r8, [enemy55_x_pos]
			mov r9, [enemy55_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole55]
			cmp r10, 2
			je .eliminado55
			mov r10, [cole55]
			cmp r10, 0
			jne .killed55
				cmp r11, 0
				jne .killed55l
			mov byte [r8], char_T 
			jmp .en56
			.killed55:
				mov byte [r8], char_space
				mov qword [enemy55_x_pos], 2
				mov qword [enemy55_y_pos], 2 
				mov qword [cole55], 2
			.killed55l:
				mov byte [r8], char_space	
				.eliminado55:

		;Enemigo56
			.en56:
			mov r8, [enemy56_x_pos]
			mov r9, [enemy56_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole56]
			cmp r10, 2
			je .eliminado56
			mov r10, [cole56]
			cmp r10, 0
			jne .killed56
				cmp r11, 0
				jne .killed56l
			mov byte [r8], char_T
			jmp .en57
			.killed56:
				mov byte [r8], char_space
				mov qword [enemy56_x_pos], 2
				mov qword [enemy56_y_pos], 2 
				mov qword [cole56], 2
			.killed56l:
				mov byte [r8], char_space	
				.eliminado56:

		;Enemigo57
			.en57:
			mov r8, [enemy57_x_pos]
			mov r9, [enemy57_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole57]
			cmp r10, 2
			je .eliminado57
			mov r10, [cole57]
			cmp r10, 0
			jne .killed57
				cmp r11, 0
				jne .killed57l
			mov byte [r8], char_T 
			jmp .en58
			.killed57:
				mov byte [r8], char_space
				mov qword [enemy57_x_pos], 2
				mov qword [enemy57_y_pos], 2 
				mov qword [cole57], 2
			.killed57l:
				mov byte [r8], char_space	
				.eliminado57:

		;Enemigo58
			.en58:
			mov r8, [enemy58_x_pos]
			mov r9, [enemy58_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole58]
			cmp r10, 2
			je .eliminado58
			mov r10, [cole58]
			cmp r10, 0
			jne .killed58
				cmp r11, 0
				jne .killed58l
			mov byte [r8], char_T 
			jmp .en59
			.killed58:
				mov byte [r8], char_space
				mov qword [enemy58_x_pos], 2
				mov qword [enemy58_y_pos], 2 
				mov qword [cole58], 2
			.killed58l:
				mov byte [r8], char_space	
				.eliminado58:

		;Enemigo59
			.en59:
			mov r8, [enemy59_x_pos]
			mov r9, [enemy59_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole59]
			cmp r10, 2
			je .eliminado59
			mov r10, [cole59]
			cmp r10, 0
			jne .killed59
				cmp r11, 0
				jne .killed59l
			mov byte [r8], char_T 
			jmp .en60
			.killed59:
				mov byte [r8], char_space
				mov qword [enemy59_x_pos], 2
				mov qword [enemy59_y_pos], 2 
				mov qword [cole59], 2
			.killed59l:
				mov byte [r8], char_space	
				.eliminado59:	

		;Enemigo60
			.en60:
			mov r8, [enemy60_x_pos]
			mov r9, [enemy60_y_pos] 
	
			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
		
			mov r10, [cole60]
			cmp r10, 2
			je .eliminado60
			mov r10, [cole60]
			cmp r10, 0
			jne .killed60
				cmp r11, 0
				jne .killed60l
			mov byte [r8], char_T
			jmp .en61
			.killed60:
				mov byte [r8], char_space
				mov qword [enemy60_x_pos], 2
				mov qword [enemy60_y_pos], 2 
				mov qword [cole60], 2
			.killed60l:
				mov byte [r8], char_space	
				.eliminado60:

			.en61:

	pop rax
	pop rcx 
	ret

move_enemy:

	push rax
	push rcx 
 
	call print_enemy

	mov r8, [enemy_speed]
	dec r8
	mov qword [enemy_speed], r8	
	cmp r8, 0 						 
	jne .endme

		;Bajar los enemigos al colisionar con pared
		mov r8, [cole]
		cmp r8, 1
		jne .no_baja 
		mov r13, [enemy_y_pos]
		inc r13
		mov qword [enemy_y_pos], r13
		mov qword [cole], 0

		call limite_aprox_enemy
		.no_baja:

		mov r8, [enemy_dir]
		cmp r8, 0								 
		jne .move_right							 
		.move_left:

			;Limpiar
				
				mov qword [limpiar], 1
				call print_enemy
				mov qword [limpiar], 0

			;mover
				mov r8, [enemy_x_pos]
				dec r8	
				mov qword [enemy_x_pos], r8

			jmp .preendme							; Saltar al final de la función


		.move_right:
			;Limpiar
				mov qword [limpiar], 1
				call print_enemy
				mov qword [limpiar], 0		 
	
			;mover
				mov r8, [enemy_x_pos]
				inc r8	
				mov qword [enemy_x_pos], r8
		.preendme:
 
		mov r13, [kills] 
		cmp r13, 50
		jle .no_kills
			cmp r13, 58
			jle .kills30
				mov qword [enemy_speed], enemy_speed59 
				jmp .endme
			.kills30:
				mov qword [enemy_speed], enemy_speed30 
				jmp .endme
		.no_kills:
		mov r12, [level] 
		cmp r12, 1
		je .speed_done
			cmp r12, 2
			je .speed_done
			cmp r12, 3
			je .speed_done 
				mov qword [enemy_speed], enemy_speed3
				jmp .endme 
			mov qword [enemy_speed], enemy_speed2 
			jmp .endme

	.speed_done:
		mov qword [enemy_speed], enemy_speed1
	.endme:

	pop rax
	pop rcx 
	ret

collision_enemy_ball:

	push rax
	push rcx 

	mov r8, [bulletenemy_x_pos]
	mov r9, [bulletenemy_y_pos]
	inc r9
	add r8, board

	mov rcx, r9
	mov rax, column_cells + 2
	imul rcx

	add r8, rax

	mov al,[r8] 
	cmp al, ' '
		je .no_colision1 

		cmp al, '<'
			je .no_colision2
			cmp al, '>'
				je .no_colision2
					cmp al, '"'
						je .no_colision2	
							jmp .no_colision3
			.no_colision2: 

					mov r8, [vidas]
					inc r8
					mov qword [vidas], r8 

					mov r8, [pallet_position]   
					mov byte [r8], ' '					 
					inc r8										 
					mov byte [r8], ' '
					inc r8										 
					mov byte [r8], ' '
					mov qword [pallet_position], board + 35 + 20 * (column_cells +2)

					mov qword [ball_x_pos], 36  
					mov qword [ball_y_pos], 19 

					jmp .limpiar

			.no_colision3:
				cmp al, '='
					jne .no_colision4  

						mov byte [r8], char_space 

					jmp .limpiar

			.no_colision4:  
					;colision con el piso 	

			.limpiar: 
					mov qword [shot_enemy], 0
					mov qword [ball_coll_enemy], 1
					mov qword [counter_enemy_atack], 5
					mov qword [counter_enemy], 5
		
					mov r8, [bulletenemy_x_pos]
					mov r9, [bulletenemy_y_pos]
					add r8, board

					mov rcx, r9
					mov rax, column_cells + 2
					imul rcx
					
					add r8, rax
					mov byte [r8], char_space

		.no_colision1:

	pop rax
	pop rcx 

	ret

collision_enemy_ball2:

	push rax
	push rcx 

	mov r8, [bulletenemy_x_pos2]
	mov r9, [bulletenemy_y_pos2]
	inc r9
	add r8, board

	mov rcx, r9
	mov rax, column_cells + 2
	imul rcx

	add r8, rax

	mov al,[r8] 
	cmp al, ' '
		je .no_colision12 

		cmp al, '<'
			je .no_colision22
			cmp al, '>'
				je .no_colision22
					cmp al, '"'
						je .no_colision22	
							jmp .no_colision32
			.no_colision22: 

					mov r8, [vidas]
					inc r8
					mov qword [vidas], r8 

					mov r8, [pallet_position]   
					mov byte [r8], ' '					 
					inc r8										 
					mov byte [r8], ' '
					inc r8										 
					mov byte [r8], ' '
					mov qword [pallet_position], board + 35 + 20 * (column_cells +2)

					mov qword [ball_x_pos], 36  
					mov qword [ball_y_pos], 19 

					jmp .limpiar2

			.no_colision32:
				cmp al, '='
					jne .no_colision42  

						mov byte [r8], char_space 

					jmp .limpiar2

			.no_colision42:  
					;colision con el piso 	

			.limpiar2: 
					mov qword [shot_enemy2], 0
					mov qword [ball_coll_enemy2], 1
					mov qword [counter_enemy_atack2], 3
					mov qword [counter_enemy2], 5
		
					mov r8, [bulletenemy_x_pos2]
					mov r9, [bulletenemy_y_pos2]
					add r8, board

					mov rcx, r9
					mov rax, column_cells + 2
					imul rcx
					
					add r8, rax
					mov byte [r8], char_space

		.no_colision12:

	pop rax
	pop rcx 

	ret

print_enemy_bullet: 

	push rax
	push rcx 
	 
	mov r8, [counter_enemy] 
	dec r8
	mov qword [counter_enemy], r8
	cmp r8, 0
	jne .ende
	mov qword[counter_enemy], 10
		;Colision
			
			call collision_enemy_ball

		 
		;Mover
			mov r8, [ball_coll_enemy]
			cmp r8, 0
			jne .ende 

			;Limpiar 
				mov r8, [bulletenemy_x_pos]
				mov r9, [bulletenemy_y_pos]
				add r8, board

				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax
				mov byte [r8], char_space

			;Mover
				mov r9, [bulletenemy_y_pos]
				inc r9	
				mov qword [bulletenemy_y_pos], r9						 

				mov r8, [bulletenemy_x_pos]
				mov r9, [bulletenemy_y_pos]
				add r8, board

				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax
				mov byte [r8], char_aster 

	.ende:

	pop rax
	pop rcx 
	ret

print_enemy_bullet2: 

	push rax
	push rcx 
	 
	mov r8, [counter_enemy2] 
	dec r8
	mov qword [counter_enemy2], r8
	cmp r8, 0
	jne .ende2
	mov qword[counter_enemy2], 10 
		;Colision
			
			call collision_enemy_ball2

		 
		;Mover
			mov r8, [ball_coll_enemy2]
			cmp r8, 0
			jne .ende2 

			;Limpiar 
				mov r8, [bulletenemy_x_pos2]
				mov r9, [bulletenemy_y_pos2]
				add r8, board

				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax
				mov byte [r8], char_space

			;Mover
				mov r9, [bulletenemy_y_pos2]
				inc r9	
				mov qword [bulletenemy_y_pos2], r9						 

				mov r8, [bulletenemy_x_pos2]
				mov r9, [bulletenemy_y_pos2]
				add r8, board

				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax
				mov byte [r8], char_aster 

	.ende2:

	pop rax
	pop rcx 
	ret


atack_enemy:

	push rax
	push rcx 
 
	mov r8, [shot_enemy]
	cmp r8, 0
	jne .on

	mov r8, [counter_enemy_atack]
	dec r8
	mov qword [counter_enemy_atack], r8
	cmp r8, 0
	jne .fin

	mov qword [counter_enemy_atack], 5

	mov r8, [ball_coll_enemy]
	cmp r8, 1
	jne .on
	;crear bala
		call rand_num
		mov r10, [random] 

		mov r8, [enemy_x_pos]
		add r8, r10
		mov r9, [enemy_y_pos] 

		mov r11, r8
		mov r12, r9

		add r8, board
		mov rcx, r9
		mov rax, column_cells + 2
		imul rcx
		
		add r8, rax 

		mov al, [r8]
		cmp al, ' '
		je .fin						
		cmp al, 'X'								;Evita que la comparacion se vaya por una pared
			je .fin  

			mov qword [shot_enemy], 1
			mov qword [ball_coll_enemy], 0
			.bajar:
				inc r9

				mov r8, r11

				add r8, board
				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax 

				mov al, [r8]
				cmp al, '='
				jne .bien
					mov qword [shot_enemy], 1
					mov qword [ball_coll_enemy], 0
					jmp .fin
				.bien:
				cmp al, ' '
				jne .bajar

				mov qword [bulletenemy_x_pos], r11
				mov qword [bulletenemy_y_pos], r9 

	;Bala existente
		.on:
			call print_enemy_bullet 
			
	.fin:

	pop rax
	pop rcx 
 ret

atack_enemy2:

	push rax
	push rcx 
 
	mov r8, [level]
	cmp r8, 1
	jle .fin2

	mov r8, [shot_enemy2]
	cmp r8, 0
	jne .on2

	mov r8, [counter_enemy_atack2]
	dec r8
	mov qword [counter_enemy_atack2], r8
	cmp r8, 0
	jne .fin2

	mov qword [counter_enemy_atack2], 7

	mov r8, [ball_coll_enemy2]
	cmp r8, 1
	jne .on2
	;crear bala
		call rand_num 
		mov r10, [random ] 

		mov r8, [enemy_x_pos]
		add r8, r10
		mov r9, [enemy_y_pos] 

		mov r11, r8
		mov r12, r9

		add r8, board
		mov rcx, r9
		mov rax, column_cells + 2
		imul rcx
		
		add r8, rax 

		mov al, [r8]
		cmp al, ' '
		je .fin2						
		cmp al, 'X'								;Evita que la comparacion se vaya por una pared
			je .fin2  

			mov qword [shot_enemy2], 1
			mov qword [ball_coll_enemy2], 0
			.bajar2:
				inc r9

				mov r8, r11

				add r8, board
				mov rcx, r9
				mov rax, column_cells + 2
				imul rcx
				
				add r8, rax 

				mov al, [r8]

				cmp al, '='
				jne .bien2
					mov qword [shot_enemy2], 1
					mov qword [ball_coll_enemy2], 0
					jmp .fin2
				.bien2:

				cmp al, ' '
				jne .bajar2

				mov qword [bulletenemy_x_pos2], r11
				mov qword [bulletenemy_y_pos2], r9 

	;Bala existente
		.on2:
			call print_enemy_bullet2 
			
	.fin2:

	pop rax
	pop rcx 
 ret
 
print_muros:

	push rax
	push rcx 

	;Muro 1
		mov r8, 35
		mov r9, 18 
		mov r12, r8

		mov r10, 0
		mov r11, 0 

		.y:
			mov r8, 35 
			mov r12, r8
			dec r9
			inc r11
			mov r10, 0

			cmp r11, 4
			je .done1
		.x:
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
			mov byte [r8], char_equal

			inc r10
			cmp r10, 6
			je .y
			inc r12
			mov r8, r12
			jmp .x
		.done1:
	;Muro 2
		mov r8, 46
		mov r9, 18 
		mov r12, r8

		mov r10, 0
		mov r11, 0 

		.y2:
			mov r8, 46 
			mov r12, r8
			dec r9
			inc r11
			mov r10, 0

			cmp r11, 4
			je .done2
		.x2:
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
			mov byte [r8], char_equal

			inc r10
			cmp r10, 6
			je .y2
			inc r12
			mov r8, r12
			jmp .x2

		.done2:

	;Muro 3
		mov r8, 58
		mov r9, 18 
		mov r12, r8

		mov r10, 0
		mov r11, 0 

		.y3:
			mov r8, 58 
			mov r12, r8
			dec r9
			inc r11
			mov r10, 0

			cmp r11, 4
			je .done3
		.x3:
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
			mov byte [r8], char_equal

			inc r10
			cmp r10, 6
			je .y3
			inc r12
			mov r8, r12
			jmp .x3

		.done3:

	;Muro 4
		mov r8, 70
		mov r9, 18 
		mov r12, r8

		mov r10, 0
		mov r11, 0 

		.y4:
			mov r8, 70 
			mov r12, r8
			dec r9
			inc r11
			mov r10, 0

			cmp r11, 4
			je .done4
		.x4:
			add r8, board

			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
			mov byte [r8], char_equal

			inc r10
			cmp r10, 6
			je .y4
			inc r12
			mov r8, r12
			jmp .x4

		.done4:

	pop rax
	pop rcx 
	

	ret

scoref_print: 

	push rax
	push rcx
	push rdx
	push rdi	
	push rsi
    
		mov r12, [score_position] 
		mov rax, [score]
	    mov rcx, 10 ; divider to extract digits 

	.convert_loop:
	    xor rdx, rdx ; clean rdx for division
	    div rcx       ; divide rax by 10, the quotient remains in rax, the remainder in rdx
	    add dl, '0'    ; convert remainder to ASCII
	    mov [r12], dl  ; store the converted digit
	    dec r12        ; move pointer back

	    test rax, rax ; check if there are digits left to convert
	jnz .convert_loop

	mov r12, [hi_score_position] 
		mov rax, [hi_mscore]
		mov rcx, 10 ; divider to extract digits 

	.convert_loop2:
		xor rdx, rdx ; clean rdx for division
		div rcx       ; divide rax by 10, the quotient remains in rax, the remainder in rdx
		add dl, '0'    ; convert remainder to ASCII
		mov [r12], dl  ; store the converted digit
		dec r12        ; move pointer back

		test rax, rax ; check if there are digits left to convert
	jnz .convert_loop2	

	mov r12, [level_position] 
		mov rax, [level]  

		add al, '0'    ; convert remainder to ASCII
		mov [r12], al  ; store the converted digit  
	

	pop rax
	pop rcx
	pop rdx
	pop rdi
	pop rsi

	ret
 
print_vidas:

	mov r8, [vidas_position] 
	mov r10, 2
	.loop_vidas:  
		mov byte [r8], char_men						 
		inc r8										 
		mov byte [r8], char_comillas
		inc r8										 
		mov byte [r8], char_may

		cmp r10, 0
		je .loop_done
			dec r10
			add r8, 2
			jmp .loop_vidas
		.loop_done:
	  

	ret

borrar_vidas:

	mov r10, [vidas]
	cmp r10, 4
	jne .vivo
		mov qword [game_over], 1 
	.vivo:
	mov r8, [vidas_position]  
	cmp r10, 0
	je .no_borrar
	.loop_vidas:  
		mov byte [r8], ' '					 
		inc r8										 
		mov byte [r8], ' '
		inc r8										 
		mov byte [r8], ' '

		dec r10
		cmp r10, 0
		je .loop_done
			add r8, 2
			jmp .loop_vidas
		.loop_done:
	.no_borrar:

	ret

restart_game_over:
 
	mov qword [vidas], 0  
	mov qword [kills], 0  
	;limpiar score 
		;limpiar en pantalla de game over
			mov r8, [score_position] 
			mov byte [r8  ], char_space
			mov byte [r8 - 1], char_space
			mov byte [r8 - 2], char_space
			mov byte [r8 - 3], char_space
			mov byte [r8 - 4], char_space
			mov byte [r8 - 5], char_space
		;limpiar en pantalla del juego
			mov qword [score_position], board + 19 + 10* (column_cells + 2) 
			mov r8, [score_position] 
			mov byte [r8  ], char_space
			mov byte [r8 - 1], char_space
			mov byte [r8 - 2], char_space
			mov byte [r8 - 3], char_space
			mov byte [r8 - 4], char_space
			mov byte [r8 - 5], char_space
		mov qword [score], 0   
		mov qword [score_position],  board + 19 + 10* (column_cells + 2)   
		mov qword [hi_score_position], board + 103 + 11* (column_cells + 2) 
	mov qword [level], 1 
	mov qword [levl], 0 
	mov qword [shot], 0 
	mov qword [shot_enemy], 0 
	mov qword [shot_enemy2], 0 
	mov qword [ver_coll], 0 
	mov qword [ball_speed], 2 
	mov qword [enemy_speed], 50 
	mov qword [ball_coll], 1 
	mov qword [ball_coll_enemy], 1  
	mov qword [ball_coll_enemy2], 1 
 
	mov qword [counter_enemy_atack], 5 
	mov qword [counter_enemy_atack2], 7
	mov qword [counter_enemy], 10
	mov qword [counter_enemy2], 10
	;Limpiar enemigos
		mov qword [limpiar], 1
		call print_enemy
	;limpiar jugador
		mov r8, [pallet_position]
		mov r9, [pallet_size]
		mov byte [r8 + r9 - 1], char_space
		mov byte [r8 + r9 - 2], char_space
		mov byte [r8 + r9 - 3], char_space
		mov qword [pallet_position], board + 35 + 20 * (column_cells +2)

	;limpiar balas
		;jugador
			mov r8, [bullet_x_pos]
			mov r9, [bullet_y_pos]  
			mov r12, r9

			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax

			cmp r9, 0
			jne .espacio
			mov byte [r8], 'X'
			jmp .equis
			.espacio:
			mov byte [r8], char_space
			.equis:
		
		;enemigo
			mov r8, [bulletenemy_x_pos]
			mov r9, [bulletenemy_y_pos] 
			mov r12, r9

			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
			
			cmp r9, 22
			jne .espacioe
			mov byte [r8], 'X'
			jmp .equise
			.espacioe:
			mov byte [r8], char_space
			.equise:

			mov r8, [bulletenemy_x_pos2]
			mov r9, [bulletenemy_y_pos2] 
			mov r12, r9

			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
			
			cmp r9, 22
			jne .espacioe2
			mov byte [r8], 'X'
			jmp .equise2
			.espacioe2:
			mov byte [r8], char_space
			.equise2:

	  
	mov qword [colj], 0  
	mov qword [cole], 0  
	mov qword [colplayer], 0 
	mov qword [limpiar], 0
 
	mov qword [ball_x_pos], 36  
	mov qword [ball_y_pos], 19 
 
	mov qword [enemy_x_pos], 40  
	mov qword [enemy_y_pos], 3 

	;Colisiones 
		mov qword [cole1], 0
		mov qword [cole2], 0
		mov qword [cole3], 0
		mov qword [cole4], 0
		mov qword [cole5], 0
		mov qword [cole6], 0
		mov qword [cole7], 0
		mov qword [cole8], 0
		mov qword [cole9], 0
		mov qword [cole10], 0
		mov qword [cole11], 0
		mov qword [cole12], 0
		mov qword [cole13], 0
		mov qword [cole14], 0
		mov qword [cole15], 0
		mov qword [cole16], 0
		mov qword [cole17], 0
		mov qword [cole18], 0
		mov qword [cole19], 0
		mov qword [cole20], 0
		mov qword [cole21], 0
		mov qword [cole22], 0
		mov qword [cole23], 0
		mov qword [cole24], 0
		mov qword [cole25], 0
		mov qword [cole26], 0
		mov qword [cole27], 0
		mov qword [cole28], 0
		mov qword [cole29], 0
		mov qword [cole30], 0
		mov qword [cole31], 0
		mov qword [cole32], 0
		mov qword [cole33], 0
		mov qword [cole34], 0
		mov qword [cole35], 0
		mov qword [cole36], 0
		mov qword [cole37], 0
		mov qword [cole38], 0
		mov qword [cole39], 0
		mov qword [cole40], 0
		mov qword [cole41], 0
		mov qword [cole42], 0
		mov qword [cole43], 0
		mov qword [cole44], 0
		mov qword [cole45], 0
		mov qword [cole46], 0
		mov qword [cole47], 0
		mov qword [cole48], 0
		mov qword [cole49], 0
		mov qword [cole50], 0
		mov qword [cole51], 0
		mov qword [cole52], 0
		mov qword [cole53], 0
		mov qword [cole54], 0
		mov qword [cole55], 0
		mov qword [cole56], 0
		mov qword [cole57], 0
		mov qword [cole58], 0
		mov qword [cole59], 0
		mov qword [cole60], 0
 
	mov qword [enemy_numx], 4 
	mov qword [enemy_numy], 4 
	mov qword [enemy_dir], 0 

	;Limpiar nave
			mov r8, [enemy_nave_position]  					 
			mov byte [r8], ' ' 
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8
			mov byte [r8], ' '	 
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
	mov qword [enemy_nave_position], board +  32 + 2 * (column_cells +2)  
	mov qword [enemy_nave_counter], 500 
	mov qword [enemy_nave_speed], 8  
	mov qword [col_nave], 0  
 
	mov qword [game_over], 0
	mov qword [win], 0
	ret

restart_next_level:
  
	mov qword [vidas], 0  
	mov qword [kills], 0  
	;mov qword [score], 0  
	mov qword [score_position], board + 19 + 10* (column_cells + 2) 
	mov qword [hi_score_position], board + 103 + 11* (column_cells + 2)
	;mov qword [level], 1 
	;mov qword [levl], 0
	mov qword [shot], 0 
	mov qword [shot_enemy], 0 
	mov qword [shot_enemy2], 0 
	mov qword [ver_coll], 0 
	;mov qword [ball_speed], 2 
	;mov qword [enemy_speed], 50 
	mov qword [ball_coll], 1 
	mov qword [ball_coll_enemy], 1 
	mov qword [ball_coll_enemy2], 1 
 
	mov qword [counter_enemy_atack], 5 
	mov qword [counter_enemy_atack2], 7
	mov qword [counter_enemy], 10
	mov qword [counter_enemy2], 10
  
  	;Limpiar enemigos
		mov qword [limpiar], 1
		call print_enemy
	;limpiar jugador
		mov r8, [pallet_position]
		mov r9, [pallet_size]
		mov byte [r8 + r9 - 1], char_space
		mov byte [r8 + r9 - 2], char_space
		mov byte [r8 + r9 - 3], char_space
		mov qword [pallet_position], board + 35 + 20 * (column_cells +2)

	;limpiar balas
		;jugador
			mov r8, [bullet_x_pos]
			mov r9, [bullet_y_pos]  
			mov r12, r9

			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax

			cmp r9, 0
			jne .espacio2
			mov byte [r8], 'X'
			jmp .equis2
			.espacio2:
			mov byte [r8], char_space
			.equis2:
		
		;enemigo
			mov r8, [bulletenemy_x_pos]
			mov r9, [bulletenemy_y_pos] 
			mov r12, r9

			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
			
			cmp r9, 22
			jne .espacioe2
			mov byte [r8], 'X'
			jmp .equise2
			.espacioe2:
			mov byte [r8], char_space
			.equise2:

			mov r8, [bulletenemy_x_pos2]
			mov r9, [bulletenemy_y_pos2] 
			mov r12, r9

			add r8, board
			mov rcx, r9
			mov rax, column_cells + 2
			imul rcx
			
			add r8, rax
			
			cmp r9, 22
			jne .espacioe22
			mov byte [r8], 'X'
			jmp .equise22
			.espacioe22:
			mov byte [r8], char_space
			.equise22:

	  
	mov qword [colj], 0  
	mov qword [cole], 0  
	mov qword [colplayer], 0 
	mov qword [limpiar], 0
 
	mov qword [ball_x_pos], 36  
	mov qword [ball_y_pos], 19 
 
	mov qword [enemy_x_pos], 35  
	mov qword [enemy_y_pos], 3 

	;Colisiones 
		mov qword [cole1], 0
		mov qword [cole2], 0
		mov qword [cole3], 0
		mov qword [cole4], 0
		mov qword [cole5], 0
		mov qword [cole6], 0
		mov qword [cole7], 0
		mov qword [cole8], 0
		mov qword [cole9], 0
		mov qword [cole10], 0
		mov qword [cole11], 0
		mov qword [cole12], 0
		mov qword [cole13], 0
		mov qword [cole14], 0
		mov qword [cole15], 0
		mov qword [cole16], 0
		mov qword [cole17], 0
		mov qword [cole18], 0
		mov qword [cole19], 0
		mov qword [cole20], 0
		mov qword [cole21], 0
		mov qword [cole22], 0
		mov qword [cole23], 0
		mov qword [cole24], 0
		mov qword [cole25], 0
		mov qword [cole26], 0
		mov qword [cole27], 0
		mov qword [cole28], 0
		mov qword [cole29], 0
		mov qword [cole30], 0
		mov qword [cole31], 0
		mov qword [cole32], 0
		mov qword [cole33], 0
		mov qword [cole34], 0
		mov qword [cole35], 0
		mov qword [cole36], 0
		mov qword [cole37], 0
		mov qword [cole38], 0
		mov qword [cole39], 0
		mov qword [cole40], 0
		mov qword [cole41], 0
		mov qword [cole42], 0
		mov qword [cole43], 0
		mov qword [cole44], 0
		mov qword [cole45], 0
		mov qword [cole46], 0
		mov qword [cole47], 0
		mov qword [cole48], 0
		mov qword [cole49], 0
		mov qword [cole50], 0
		mov qword [cole51], 0
		mov qword [cole52], 0
		mov qword [cole53], 0
		mov qword [cole54], 0
		mov qword [cole55], 0
		mov qword [cole56], 0
		mov qword [cole57], 0
		mov qword [cole58], 0
		mov qword [cole59], 0
		mov qword [cole60], 0
 
	mov qword [enemy_numx], 4 
	mov qword [enemy_numy], 4 
	mov qword [enemy_dir], 0 

	;Limpiar nave
			mov r8, [enemy_nave_position]  					 
			mov byte [r8], ' ' 
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
			inc r8
			mov byte [r8], ' '	 
			inc r8										 
			mov byte [r8], ' '
			inc r8										 
			mov byte [r8], ' '
	mov qword [enemy_nave_position], board +  32 + 2 * (column_cells +2)  
	mov qword [enemy_nave_counter], 500 
	mov qword [enemy_nave_speed], 8  
	mov qword [col_nave], 0  

	mov qword [game_over], 0
	mov qword [win], 0
 
	ret


_start: 
	print clear, clear_length
	call start_screen
	level_up:
	call canonical_off
	call print_enemy 
	call paredes
	call print_muros 
	call print_vidas
 
	.main_loop:
		
		call level_screen
		call scoref_print  
		call borrar_vidas
		call paredes
		call col_paredes_player
		;call rand_num
		call col_paredes_enemy
		call print_pallet 
		call print_enemy_nave
		call move_ball
		call move_enemy
		call atack_enemy
		call atack_enemy2 
			 
		call game_over_screen 
		call win_screen
		print board, board_size	  
	
		
		;setnonblocking	
	.read_more:	
		getchar						;Llama a la macro getchar para leer un carácter de la entrada de teclado 
		
		cmp rax, 1
    	jne .done
		
		mov al,[input_char]

		.minn:
			cmp al, 'p'
			jne .loser 
			mov qword [win], 1
			jmp .done

		.loser:
			cmp al, 'l'
			jne .leveling  
			mov qword [game_over], 1
			jmp .done

		.leveling:
			cmp al, 'n'
			jne .left_in 
			mov qword [kills], 60
			jmp .done

		.left_in:
			cmp al, 'a'
			jne .right_in
			mov rdi, left_direction
			call move_pallet
			jmp .done
		
		.right_in:
		 	cmp al, 'd'
	    	jne .shot_in
			mov rdi, right_direction
	    	call move_pallet
    		jmp .done	

		.shot_in:
		 	cmp al, char_space
	    	jne .go_out
			mov qword [shot], 1
    		jmp .done	

		.go_out:

    		cmp al, 'q'
    		je exit

			jmp .read_more
		
		.done:	
			;unsetnonblocking		
			sleeptime	
			print clear, clear_length
    		jmp .main_loop 

		print clear, clear_length
		
		jmp exit


start_screen: 

	push rax
	push rcx
	push rdx
	push rdi
	push rsi
	
	print msg1, msg1_length	
	getchar
	print clear, clear_length

	pop rax
	pop rcx
	pop rdx
	pop rdi
	pop rsi
	ret

game_over_screen: 

	push rax
	push rcx
	push rdx
	push rdi
	push rsi

	mov r8, [game_over]
	cmp r8, 0
	je .no_game_ov 

		print clear, clear_length 
	    
		call canonical_on   

		mov r8, [score]
		mov r9, [hi_mscore]
		cmp r9, r8
		jg .hi
			mov qword [hi_mscore], r8
		.hi:
		mov qword [score_position], boardg + 65 + 8* (column_cells + 2)  
		mov qword [hi_score_position], boardg + 65 + 9* (column_cells + 2) 
		call scoref_print 
		;call paredes

			mov r8, [pared1_x_pos]
			mov r9, [pared1_y_pos]  
			mov r11, r8
			mov r12, [pared]
			;izquierda
				.repeat_lg:
					add r8, boardg

					mov rcx, r9
					mov rax, column_cells + 2
					imul rcx

					add r8, rax
						mov byte [r8], char_X 
			
						inc r9
						dec r12
						cmp r12, 0
						je .pared_rg

						mov r8, r11
						jmp .repeat_lg
		

			;derecha
				.pared_rg:
				mov r12, [pared]

				mov r8, [pared2_x_pos]
				mov r9, [pared2_y_pos]  
				mov r11, r8

				.repeat_rg:
					add r8, boardg

					mov rcx, r9
					mov rax, column_cells + 2
					imul rcx

					add r8, rax
						mov byte [r8], char_X 
			
						inc r9
						dec r12
						cmp r12, 0
						je .no_colg

						mov r8, r11
						jmp .repeat_rg
			.no_colg:


		print boardg, boardg_size

		call restart_game_over 

		sleeptime
		getchar
			
		print clear, clear_length 
		 

		jmp _start

	.no_game_ov:

	pop rax
	pop rcx
	pop rdx
	pop rdi
	pop rsi
	ret

win_screen: 

	push rax
	push rcx
	push rdx
	push rdi
	push rsi

	mov r8, [win]
	cmp r8, 0
	je .no_win 

		print clear, clear_length 
	    
		call canonical_on   

		mov r8, [score]
		mov r9, [hi_mscore]
		cmp r9, r8
		jg .hiw
			mov qword [hi_mscore], r8
		.hiw:
		mov qword [score_position], boardw + 65 + 8* (column_cells + 2)  
		mov qword [hi_score_position], boardw + 65 + 9* (column_cells + 2) 
		call scoref_print 
		


		print boardw, boardw_size

		call restart_game_over 

		sleeptime
		getchar
			
		print clear, clear_length 
		 

		jmp _start

	.no_win:

	pop rax
	pop rcx
	pop rdx
	pop rdi
	pop rsi
	ret

level_screen: 

	push rax
	push rcx
	push rdx
	push rdi
	push rsi

	mov r8, [kills]
	cmp r8, 60
	jne .no_lev 

		mov qword [levl], 1 

		mov r8, [level]
		inc r8
		cmp r8, 6
		jne .lv
			mov qword [level], 1
			jmp .rlv
		.lv:
		mov qword [level], r8
		.rlv:

		print clear, clear_length 
	    
		call canonical_on   

		mov r8, [score]
		mov r9, [hi_mscore]
		cmp r9, r8
		jg .hiw
			mov qword [hi_mscore], r8
		.hiw:
		mov qword [score_position], boardl + 65 + 8* (column_cells + 2)  
		mov qword [hi_score_position], boardl + 65 + 9* (column_cells + 2) 
		call scoref_print 
		 

			mov r8, [pared1_x_pos]
			mov r9, [pared1_y_pos]  
			mov r11, r8
			mov r12, [pared]
			;izquierda
				.repeat_ll:
					add r8, boardl

					mov rcx, r9
					mov rax, column_cells + 2
					imul rcx

					add r8, rax
						mov byte [r8], char_X 
			
						inc r9
						dec r12
						cmp r12, 0
						je .pared_rl

						mov r8, r11
						jmp .repeat_ll
		

			;derecha
				.pared_rl:
				mov r12, [pared]

				mov r8, [pared2_x_pos]
				mov r9, [pared2_y_pos]  
				mov r11, r8

				.repeat_rl:
					add r8, boardl

					mov rcx, r9
					mov rax, column_cells + 2
					imul rcx

					add r8, rax
						mov byte [r8], char_X 
			
						inc r9
						dec r12
						cmp r12, 0
						je .no_coll

						mov r8, r11
						jmp .repeat_rl
			.no_coll:


		print boardl, boardl_size 

		call restart_next_level

		sleeptime
		getchar
			
		print clear, clear_length  

		jmp level_up

	.no_lev:

	pop rax
	pop rcx
	pop rdx
	pop rdi
	pop rsi
	ret

next_level_screen: 

	push rax
	push rcx
	push rdx
	push rdi
	push rsi
	
	

	pop rax
	pop rcx
	pop rdx
	pop rdi
	pop rsi
	ret


exit: 
	call canonical_on
	mov    rax, 60
    mov    rdi, 0
    syscall

