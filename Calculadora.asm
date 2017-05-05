;Calculadora
%include "io.mac"
%include "macros.asm"


    ; ;;;; ; ; ; COMIENZA CODIGO ; ; ; ; ; ; ; ;; 




.DATA

	bienvenido	db '¡Bienvenido a la calculadora más crack del TEC!',10,13,0
	hex			db 'ABCDEF',0
	sim			db 10,13,10,13,'$',0
	ayudaMsg	db 'En breve estara disponible esta opcion',0
	error		db 'No existe ese comando',0
	var			db 'Lista de variables:',10,13,0
	proced		db 'Mostrar procedimientos: ',0
	msAyuda		db '#ayuda',0
	msVar		db '#var',0
	error_variableMsg	db 'El espacio maximo para el tamaño de variables es de 14 caracteres',0
	error_variable_NF	db 'No se ha encontrado la variable',0
	error_variable_NS	db 'No hay más espacio para variables',10,13,'Puede redefinir alguna con el comando "=":  var= 123',0
	ms			db 'Se ha guardado la variable',0
	error_variableMsg2 	db 'Error de syntaxis, reescriba la operacion.',0
	h			db 	'0000000F',0
	error_aux	db  '00000000',0
	
	
.UDATA
	
	input resb 	100 
	v1 	  resb  100 ;;Variables para manejo de expresiones
	v2 	  resb  100
	v3 	  resb  100 ;;16 bytes para el nombre de variable y 44 para la expresion
	v4 	  resb  100 
	v5 	  resb  100
	v6 	  resb  100 
	v7 	  resb  100 
	v8 	  resb  100
	v9 	  resb  100 
	v10   resb  100 
	v11   resb  100
	v12   resb  100 
	aux	  resb  100
	fin	  resb  1
	
	
	
.CODE	
	.STARTUP
		
		PutStr bienvenido
		
		
		PutStr sim
		HexToInt h, 8
		PutCh '>'
		
		PutStr sim
		OctToInt octal, 8
		PutCh '>'
		
		PutStr sim
		BinToInt b, 8
		PutCh '>'
		
		
	while:
		
		nwln
		PutStr sim
		GetStr  input
		mov ecx, 0
		
		mov bl, [input]
		;PutCh bl
		cmp bl,0
		je while
		cmp bl,'#'
		je comandos
		
		
		mov eax, v1-100		;Comienzo la busqueda en el primer campo de las variables
		
		
		jmp revisar_expresion
		
	revisar_expresion:
		
		call incremento
		cmp edx, 15
		je error_variable
		cmp bl, ':'
		je declarar ;Proceso para declarar variables
		cmp bl, '='
		je buscar_coincidencia ;Redefinir las variables
		cmp bl, 20H
		je revisar_expresion ;Va por el contenido de la variable y hace el calculo de ser una expresion y retorna el resultado
		cmp bl,0
		je buscar_coincidencia
		jmp revisar_expresion
		
		
	
	buscar_coincidencia:
	
		add eax,100
		mov edx,-1
		mov bh, [eax]
		cmp bh,0			;Si encuentro que la variable actual
		je error_variable2	;está vacia significa que las demas tambien, por lo tanto, no se encontro
		
	busqueda_en_actual:
		inc edx
		mov bh, [eax+edx] ;Comparo byte por byte a ver si es igual
		cmp bh,0
		je determinar		
		cmp bh, [input+edx]     ;Si es igual, sigue al siguiente byte
		je busqueda_en_actual
		
		jmp buscar_coincidencia	; No es igual, busca en el siguiente campo
	
	determinar:
		mov bh, [input+edx]	
		inc edx
		cmp bh, "="					; Si puso "=" se redefine
		je guardar_var_value		
		cmp bh, 20H					; Si hay " ", solo salta
		je determinar				
		cmp bh,0					; Si es blanco, se le da el valor
		je dar_valor				
		jmp buscar_coincidencia		; No es igual, busca siquiente campo
			
	error_variable:
		PutStr error_variableMsg
		jmp while
		
	error_variable2:
		PutStr error_variable_NF
		jmp while
		
	error_variable3:
		PutStr error_variable_NS
		jmp while
		
	declarar:
		

		mov edx, fin        ; FIN del espacio para variables
		mov eax, v1
		jmp buscar_var_libre
		
	buscar_var_libre:		;Busca un espacio no asignado todavia y devuelve la posicion
	
		;;PutStr eax
		
		cmp eax, edx		;Si  indice = fin(etiqueta)  =>  llegamos al fin del campo para variables  :. No se encontró.
		je error_variable3
		mov bh, [eax]		
		cmp bh,0			;Si  el espacio esta disponible => Guardo en esta posicion
		je guardar_va
		add eax, 100			; Incremento 50 para ir al siguiente espacio para variable
		jmp buscar_var_libre
		
	guardar_va:
		mov edx,0
	
	guardar_var:			;Guarda el string de la variable desde la posicion 0 de el espacio en memoria
	
		
		mov bh, [input+edx] ;;Recorro byte por byte el valor dado a la variable
		inc edx
		cmp bh, 20H			;salto si encuentro espacios
		je guardar_var
		
		
		cmp edx, ecx		;;Salto cuando encuentro los : de variable
		je guardar_var_value
		
		
		mov [eax+edx-1],bh  ;
		jmp guardar_var
		
	guardar_var_value:		;Guarda el valor de la variable desde la posicion 16 de el espacio en memoria
		
		mov edx, 16
					
	for_guardar:
		
		call incremento
		cmp bl,20h
		je for_guardar
		
		cmp bl, "D" ;
		je dec
		
		cmp bl, "H"
		je hexa
		
		cmp bl, "O"
		je oct
		
		cmp bl, "B"
		je bin
		
		cmp bl, 0
		je guardada
		
		mov [eax+edx], bl
		
		inc edx
		
		jmp for_guardar
		
	dec:
		
		
		jmp while
		
	hexa:
		push ecx
		mov ecx, 0
		
	hloop:
		mov bl, [eax+ecx]
		inc ecx   
		cmp bl, 0
		jne hloop
		
		
		dec ecx
		HexToInt eax,ecx
		pop ecx
		
		jmp while
		
	oct:
	
		jmp while
	bin:
	
		jmp while
		
	guardada:
	
		mov edx ,0
		PutStr ms	;Mensaje ayuda
		jmp while
	for_guardada:
	
		mov bh, [eax+edx]
		;PutCh bh
		inc edx
		cmp bh,0
		jne for_guardada
	
	dar_valor:
	
		mov edx, 16 ;Como el espacio de la variable es despues de los 16 bytes, se comienza a leer desde aca; el valor.
		
	valor:
	
		mov bh, [eax+edx] ; En el espacio del variable: incremento con edx, y leo el valor
		PutCh bh
		inc edx
		cmp bh, 0
		jne valor
		
		jmp while
	

		
	comandos:
	
	
		call incremento
		cmp bl, 'a'
		je a
		cmp bl, 'v'
		je v
		cmp bl, 's'
		je s
		cmp bl, 'b'
		je pre
		cmp bl, 'p'
		je pro
		jmp err
		
		
	a:
		call incremento
		cmp bl, 'y'
		jne err
		call incremento
		cmp bl, 'u'
		jne err
		call incremento
		cmp bl, 'd'
		jne err
		call incremento
		cmp bl, 'a'
		jne err
		call incremento
		cmp bl, 0
		jne err
		
		PutStr ayudaMsg
		
		jmp while
	v:
		call incremento
		cmp bl, 'a'
		jne err
		call incremento
		cmp bl, 'r'
		jne err
		call incremento
		cmp bl, 0
		jne err
		
		PutStr var
		
		jmp while
	s:
		call incremento
		cmp bl, 'a'
		jne err
		call incremento
		cmp bl, 'l'
		jne err
		call incremento
		cmp bl, 'i'
		jne err
		call incremento
		cmp bl, 'r'
		jne err
		call incremento
		cmp bl, 0
		jne err
		
		PutStr ayudaMsg
		jmp imprimir_binario
		
		;jmp while
	pre:
		call incremento
		cmp bl, 'i'
		jne err
		call incremento
		cmp bl, 't'
		jne err
		call incremento
		cmp bl, 's'
		jne err
		jmp while
		
	pro:
		call incremento
		cmp bl, 'r'
		jne err
		call incremento
		cmp bl, 'o'
		jne err
		call incremento
		cmp bl, 'c'
		jne err
		call incremento
		cmp bl, 'e'
		jne err
		call incremento
		cmp bl, 'd'
		jne err
		call incremento
		cmp bl, 'i'
		jne err
		call incremento
		cmp bl, 'm'
		jne err
		call incremento
		cmp bl, 'i'
		jne err
		call incremento
		cmp bl, 'e'
		jne err
		call incremento
		cmp bl, 'n'
		jne err
		call incremento
		cmp bl, 't'
		jne err
		call incremento
		cmp bl, 'o'
		jne err
		
		
		PutStr proced
		jmp while
	err:
	
		PutStr error
		jmp while
	
	exit:
		jmp while
	
	imprimir_binario:	
		
	.EXIT

ayuda:
	PutStr ayudaMsg
	ret

incremento:
		mov bl, [input+ecx]
		inc ecx
		ret
		
		
		
