;String a imprimir

%include "io.mac"

.DATA

	ms	db 'Input string: ',0
	hex db 'ABCDEF',0
	mfinal db 'Total entries: ',0
.UDATA

	string resb 40
	
.CODE
	
	.STARTUP
		
		PutStr ms
		GetStr string, 40
		
		mov eax, string
		mov cx,0
	contar:
		mov bl, [eax]
		inc eax
		inc cx
		cmp bl, 0
		je afor
		
		jmp contar
		
		
		
	afor:
		mov eax, string
		PutStr mfinal
		dec cx
		PutInt cx
		inc cx
		nwln
	for:
		
		dec cx
		cmp cx, 0
		je salir
		mov bl, [eax]
		inc eax
		cmp bl, 30h
		jl no_number
		cmp bl, 39h
		jg no_number
		
		
		sub bl, 30h ;Resta 30 para llegar al valor numerico explicito
		PutCh '('
		PutInt bx
		PutCh ')'
		PutCh ' '
		
		jmp for
		
	no_number:
		
		mov edx, 0
		PutCh '('
		mov edx, ebx
		shr bl, 4
		cmp bx, 9
		jg a_hex
		PutInt bx
		
	seguir1:
		shl edx,4
		mov dh,0
		mov ebx, edx
		shr bl, 4
		cmp bx, 9
		jg a_hex2
		PutInt bx
	seguir2:
		PutCh 'h'
		PutCh ')'
		PutCh ' '
		jmp for
		
	a_hex:
		
		sub bx, 10
		PutCh [hex+ebx]
		jmp seguir1
	a_hex2:
		
		sub bx, 10
		PutCh [hex+ebx]
		jmp seguir2
	
	salir:
	.EXIT
		
		
		
