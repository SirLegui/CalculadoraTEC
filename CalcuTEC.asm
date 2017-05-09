%include 'io.mac'
%include 'macros.asm'

.DATA
	bienvenido	db	'¡Bienvenido a la calculadora más crack del TEC!',10,13,0
	sim			db	10,13,'$ ',0
	msg_error	db	'Expresion Invalida!',0
	operacion	db	'(6+2)*3/2+2-8',0;'B1010',0

.UDATA
	;operacion	resb	16
	posfijo		resb	32
	boolean		resb	1	;variable booleana
	aux			resd	2	;auxiliar del ptro del posfijo
	aux2		resd	1	;auxiliar al contador de la pila
	var			resb	16	;numero en diferente base
	base		resb	16
	resultado	resd	16
	auxB		resb	16
	basura		resd	3

.CODE
	.STARTUP
		call limpiarRegistros		;limpio los registros
		PutStr bienvenido			;imprimo msg de bienvenida
		nwln				
		PutStr sim					;imprimo simbolo de $
		;GetStr operacion			;espero el inout del usuario y lo guardo en operacion 
		
		call verificarSintaxis
		cmp byte[boolean], 1
		je error
		
		generarPosfijo:
			mov bl, [operacion+edx];muevo al ebx el 1er caracter de operacion
			cmp bl, 0				;comparo si se termino el string
			je terminar
			inc edx					;incremento contador para leer prox caracter de operacion
			cmp bl, '('
			je meterPila
			cmp bl, ')'
			je vaciarPila
			call verificarOperacion	;verifico si es una operacion valida
			cmp byte[boolean], 1
			je verificarPila
			call verificarNumero	;verifico si es un numero
			cmp byte[boolean], 1
			je meterPosfijo
			call verificarLetra		;verifico si es una letra
			cmp byte[boolean], 1
			je meterPosfijo
			jmp verificarBase		;verifico si esta en otra base
;-----------------------------------------------------------------------		
		verificarPila:
			cmp ecx, 0
			je meterPila
			mov [aux], eax	
			Pop eax
			Push eax
			cmp bl, '+'
			je verificarSumaResta
			cmp bl, '-'
			je verificarSumaResta
			cmp bl, '*'
			je verificarMultDiv
			cmp bl, '/'
			je verificarMultDiv
		
		verificarSumaResta: 
			cmp al, '('
			je meterPila
			cmp al, '+'
			je cambiarTope
			cmp al, '-'
			je cambiarTope
			cmp al, '*'
			je cambiarTope
			cmp al, '/'
			je cambiarTope
		
		verificarMultDiv:
			cmp al, '('
			je meterPila
			cmp al, '+'
			je meterPila
			cmp al, '-'
			je meterPila
			cmp al, '*'
			je cambiarTope
			cmp al, '/'
			je cambiarTope
;-----------------------------------------------------------------------		
		meterPila:
			;PutCh 'M'
			Push ebx
			inc ecx
			mov eax, [aux]
			jmp generarPosfijo
			
		cambiarTope:
			Pop eax
			Push ebx
			mov ebx, [aux]
			mov [posfijo+ebx], al
			inc ebx
			mov eax, ebx
			jmp generarPosfijo
			
		
		meterPosfijo:
			;PutCh 'P'
			mov [posfijo+eax], bl
			inc eax
			mov [aux], eax
			jmp generarPosfijo
			
		vaciarPila:
			cmp ecx, 0
			jne ciclo
			jmp generarPosfijo
			ciclo:
				Pop ebx
				cmp bl, '('
				je disminuir
				mov [posfijo+eax], bl
				inc eax
				mov [aux], eax
				loop ciclo
				jmp generarPosfijo
			disminuir:
				dec ecx
				jmp generarPosfijo
;-----------------------------------------------------------------------		
		verificarBase:
			cmp bl, 'B'
			je binario
			cmp bl, 'O'
			je octal
			cmp bl, 'H'
			je hexadecimal
			jmp error
		
		binario:
			mov [aux2], ecx
			xor ecx, ecx
			call contarCaracteres
			;PutCh 'c';B1010
			PutInt cx
			;nwln
			
			mov eax, 0
			
			
			a_auxB:
				dec ecx
				cmp ecx, 0
				jl fi
				mov bl, [var+ecx]
				mov [auxB+ecx-1],bl
				inc eax
				jmp a_auxB
			
			fi:
			BinToInt auxB,eax
			;PutCh 'i'
			PutLInt [aux]
			mov ecx, [aux2]
			mov bl, [var]
			mov [posfijo+edx], bl
			jmp generarPosfijo
			
		octal:
		 
		hexadecimal:
		 
;-----------------------------------------------------------------------	
		error:
			nwln
			PutStr msg_error
			.EXIT
			
		terminar:
			nwln
			cmp ecx, 0
			jne vaciarPila
			PutStr posfijo
			mov edx, eax
			dec edx
			jmp llenarPila
			
		llenarPila:
			mov bl, [posfijo+edx]
			cmp bl, 0
			je resolver
			dec edx
			call verificarNumero
			cmp byte[boolean], 1
			je implicito
			Push ebx
			inc ecx
			jmp llenarPila
			implicito:
				sub ebx, 30h
				Push ebx
				jmp llenarPila
		
		resolver:
			cmp ecx, 0
			je mostrarResultado
			Pop eax
			Pop ebx
			Pop edx
			cmp dl, '+'
			je sumar
			cmp dl, '-'
			je restar
			cmp dl, '/'
			je dividir
			cmp dl, '*'
			je multiplicar
			
		sumar:
			;PutCh 'S'
			;nwln
			add eax, ebx
			Push eax
			;PutInt ax
			dec ecx
			jmp resolver
		
		restar:
			;PutCh 'R'
			;nwln
			sub eax, ebx
			Push eax
			;PutInt ax
			dec ecx
			jmp resolver
			
		dividir:
			;PutCh 'D'
			;nwln
			div bl				;-------------------- nop hacer diviciones cn tamanio mas q bl
			Push eax
			;PutInt ax
			dec ecx
			jmp resolver
			
		multiplicar:
			;PutCh 'M'
			;nwln
			mul ebx
			Push eax
			;PutInt ax
			dec ecx
			jmp resolver
	
		mostrarResultado: 
			;nwln
			Pop eax
			;mov [var], eax
			PutCh '='
			PutInt ax
			adios:
			.EXIT
					
;=======================================================================
;=======================================================================
limpiarRegistros:
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx

verificarOperacion: 
	cmp bl, 30h
	jge noOperacion
	cmp bl, '+'
	je suma
	cmp bl, '-'
	je resta
	cmp bl, '/'
	je esOperacion
	cmp bl, '*'
	je esOperacion
	noOperacion:
		mov byte[boolean], 0
		ret
	esOperacion:
		mov byte[boolean], 1
		;PutCh 'O'
		;nwln
		ret
	suma:
		mov bl, [operacion+edx]
		inc edx
		cmp bl, '+'
		je suma
		cmp bl, '-'
		je resta
		dec edx
		mov bl, '+'
		jmp esOperacion
	resta:
		mov bl, [operacion+edx]
		inc edx
		cmp bl, '+'
		je suma
		cmp bl, '-'
		je suma
		dec edx
		mov bl, '-'
		jmp esOperacion
	
verificarNumero:
	cmp bl, 2Fh
	jle noNumero
	cmp bl, 3Ah
	jge noNumero
	esNumero:
		mov byte[boolean], 1
		;PutCh 'N'
		;nwln
		ret
	noNumero:
		mov byte[boolean], 0
		ret
	
verificarLetra:
	cmp bl, 60h
	jle noLetra
	cmp bl, 7Bh
	jge noLetra
	esLetra:
		mov byte[boolean], 1
		;PutCh 'L'
		;nwln
		ret
	noLetra:
		mov byte[boolean], 0
		ret

contarCaracteres:
	mov bl, [operacion+edx]
	call verificarOperacion
	cmp byte[boolean], 1
	je salir
	cmp bl, '('
	je salir
	cmp bl, ')'
	je salir
	cmp bl, 0
	je salir
	mov [var+ecx], bl
	PutCh bl
	inc ecx
	inc edx
	jmp contarCaracteres
	salir:
		ret
	
verificarSintaxis:
	
;HexToInt var,32
	;mov eax,var
	;PutStr eax
