
;;ESPACIO DE MACROS

%macro aBase 1

;;; IN:  "H000B"
;;; OUT: 0000 0000 0000 1011 (11)

	push eax
	push ebx
	push ecx
	push edx

	xor eax,eax
	xor ebx, ebx
	xor ecx, ecx
	
	mov ebx, %1
	mov ecx, 1
	mov al, [ebx]
	sub al, 30H
	
	cmp al, 0
	jl %%no
	
	cmp al, 10
	jl %%si
	
%%ite:
	mov al, [ebx+ecx]
	sub al, 30H
	
	cmp al, 0
	jl %%seguir
	
	cmp al, 9
	jg %%hex 
	
	inc ecx
	jmp ite

%%hex:
	sub al, 17
	
	cmp al, 5
	jg %%seguir
	jmp ite

%%seguir:

	mov al, [ebx]
	cmp al, 'B'
	je %%b
%%b:

	BinToInt ebx, ecx
	jmp %%no
%%o:

	OctToInt ebx, ecx
	jmp %%no
%%d:

	DecToInt ebx, ecx
	jmp %no
%%h:

	HexToInt ebx, ecx
	jmp %no	
	

%%si:
	mov ecx, 0
	jmp ite
%%no:

	
	pop edx
	pop ecx
	pop ebx
	pop eax
	
%endmacro

;;;MACRO DE HEXADECIMAL A EXPLICITO (BINARIO)

%macro HexToInt 2 

;;; IN:  "H000B"
;;; OUT: 0000 0000 0000 1011 (11)

	push eax
	push ebx
	push ecx
	push edx

	xor eax,eax
	xor ebx, ebx
	xor ecx, ecx
	
	
	mov eax, %1
	mov ecx, %2
	
%%ite:

	mov ch, [eax] 
	
	sub ch, 30H
	cmp ch, 9
	jg %%no_number
	
	
	cmp ch, 0
	jl %%no_valid
	
	add bl, ch
	
	dec cl
	
	cmp cl, 0
	je %%salir
	
	
	rol ebx, 4
	
	
	inc eax
	
	jmp %%ite
	


%%no_number:

	sub ch, 17
	cmp	ch, 5
	jg %%no_valid
	add ch, 10
	
	add bl, ch
	
	dec cl
	cmp cl, 0
	je %%salir
		
		
	rol ebx, 4
	
	inc eax
	 
	jmp %%ite
	
%%no_valid:
	PutStr error_variableMsg2
	xor ebx, ebx
	
%%salir: 
	PutCh '('
	PutLInt ebx
	PutCh ')'
	
	mov [aux], ebx 
	
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	
%endmacro

;;;MACRO DE DECIMAL A EXPLICITO (BINARIO)


%macro DecToInt 2

;;; IN:  "00000017"
;;; OUT: 0000 0000 0000 1111 (7)
;;;      _--- ___- --__ _---
;;;     (s)(0) (0)(0) (1) (7)

	;PutLInt eax
	;PutCh '<'
	PutCh '-'
	push eax
	push ebx
	push ecx
	push edx

	xor eax,eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	
	
	mov edx, %1
	;PutStr edx
	mov ecx, %2
	
%%ite:

	mov ch, [edx] 
	
	PutCh '('
	PutCh ch
	PutCh ')'
	
	sub ch, 30H
	cmp ch, 9
	jg %%no_valid
	
	cmp ch, 0
	jl %%no_valid
	
	add al, ch
	
	dec cl
	cmp cl, 0
	je %%salir

	mov ch, 10
	
	mul ch
	;PutLInt eax
	
	inc edx
	jmp %%ite

%%no_valid:
	PutStr error_variableMsg2
	xor ebx, ebx

%%salir:
	
	PutCh '('
	PutLInt eax
	PutCh ')'
	
	mov [aux], eax 
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	
%endmacro


;;;MACRO DE OCTAL A EXPLICITO (BINARIO)


%macro OctToInt 2

;;; IN:  "00000017"
;;; OUT: 0000 0000 0000 1111 (7)
;;;      _--- ___- --__ _---
;;;     (s)(0) (0)(0) (1) (7)

	;PutLInt eax
	PutCh '<'
	PutCh '-'
	push eax
	push ebx
	push ecx
	push edx

	xor eax,eax
	xor ebx, ebx
	xor ecx, ecx
	
	
	mov eax, %1
	PutStr eax
	mov ecx, %2
	
%%ite:

	mov ch, [eax] 
	sub ch, 30H
	cmp ch, 7
	jg %%no_valid
	
	cmp ch, 0
	jl %%no_valid
	
	add bl, ch
	
	dec cl
	cmp cl, 0
	je %%salir
	
	rol ebx, 3
	
	inc eax
	jmp %%ite

%%no_valid:
	PutStr error_variableMsg2
	xor ebx, ebx

%%salir:
	
	PutCh '('
	PutLInt ebx
	PutCh ')'
	
	mov [aux], ebx 
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	
%endmacro


;;;MACRO DE BINARIO A EXPLICITO (BINARIO)


%macro BinToInt 2 

;;; IN:  "000101"
;;; OUT: 0000 0000 0000 0101 (5)


	push eax
	push ebx
	push ecx
	push edx

	xor eax,eax
	xor ebx, ebx
	xor ecx, ecx
	
	mov eax, %1
	mov ecx, %2
	
%%ite:

	mov ch, [eax] 
	PutStr eax
	sub ch, 30H
	cmp ch, 1
	jg %%no_valid
	cmp ch, 0
	jl %%no_valid
	
	
	add bl, ch
	
	dec cl
	cmp cl, 0
	je %%salir
	
	rol ebx,1
	
	inc eax
	jmp %%ite

%%no_valid:
	PutStr error_variableMsg2
	xor ebx, ebx

%%salir:
	
	PutCh '('
	PutLInt ebx
	PutCh ')'
	
	mov [aux], ebx 
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	
%endmacro



