; comments, explaination and errors defined at the end of the functions

%include "asm_io.inc"


SECTION .data

err1: db "Incorrect number of command line arguments",0
err2: db "Incorrect command line argument",0

pegs: dd 0,0,0,0,0,0,0,0,0
no: dd 0 ;to hold argument number

breaks: db " ", 0 ; i noticed if i use break
disk: db "o", 0
rod: db "|", 0
baseX: db "           XXXXXXXXXXXXXXXXXXXXXXX", 0
start: db "            initial configuration",0
end: db "           final configuration",0


SECTION .bss

tmp: resd 1

SECTION .text
	global asm_main



asm_main:
	enter 0,0
	pusha
	mov eax, dword [ebp+8] 	; counting number of arguement

	cmp eax, dword 2
	jne Error1

	mov ebx, dword [ebp+12]
	mov ecx, dword [ebx+4]

	mov bl, byte [ecx+1] 	;this is for second byte!
    cmp bl, byte 0
    jne Error2

	mov al, byte [ecx]
	sub al, '0'     ;converting to integer

	L1:
	cmp al, 2
	jl Error2
	jmp L2

	L2:
	cmp al, 9
	jg Error2
	jmp byte_ok

	byte_ok:
	movzx ax, al
	movzx eax, ax		;found this `movzx` online `16bit -> 32bit`

	mov [no], eax
	mov ecx, pegs
	push eax
	push ecx
	call rconf

	add esp, 8

	call print_nl

	add eax, 1


	mov eax, start
	call print_string
	call print_nl
	call print_nl


	mov eax, [no]
	mov ecx, pegs
	push eax
	push ecx
	call showp
	add esp, 8

	mov eax, [no]

	mov ecx, pegs
	push eax
	push ecx
	call sorthem
	add esp, 8

	mov eax, end
	call print_string
	call print_nl
	call print_nl

	mov ecx, [pegs]
	mov eax, [no]
	push eax
	push ecx
	call showp
	add esp, 8

	jmp asm_main_end

showp:
	enter 0,0
	pusha

	mov ecx, [no]
	imul ecx, 4

	mov ebx, [ebp+12]
	mov eax, ebx

	sub ecx, 4
	jmp initial
		.continue:
			add esp, 4
			mov eax, baseX
			call print_string
			call print_nl
			call print_nl
			call read_char
			jmp asm_main_end

initial:
	mov edx, [pegs+ecx]
	push edx
	call add_space
	add esp, 4
	push edx
	call add_disks
	add esp, 4
	mov eax, rod
	call print_string
	push edx
	call add_disks
	add esp, 4
	call print_nl
	sub ecx, 4
	cmp ecx, 0
	jge initial
	jmp showp.continue


add_space:
	enter 0,0
	pushad
	mov ebx, [ebp+8]
	mov ecx, dword 22
	sub ecx, ebx 		; for different of pegs, we need different number of spaces, inspired from major la
	lp_0:
		mov eax, breaks
		call print_string
		sub ecx, 1
		cmp ecx, 0
		jne lp_0
	popa
	leave
	ret



add_disks:
	enter 0,0
	pushad
	mov ebx, [ebp+8]
	lp_2:
		mov eax, disk
		call print_string
		sub ebx, 1
		cmp ebx, 0
		jne lp_2
	popa
	leave
	ret

sorthem:
	enter 0,0
	pushad

	mov ebx, [ebp+12]
	dec ebx
	cmp ebx, 1
	je asm_main_end

 	; idk why second arguemt is taken itried with
	add ecx, 4
	push ebx
	push ecx
	call sorthem

	add esp, 8 ; free top two stacks
	sub ecx, 4
	mov edx, 0
	jmp swap
swap:

	cmp edx, ebx
	je sorthem_end

	mov eax, [ecx]
	cmp eax, [ecx+4]
	jg sorthem_end

	; the following is a typical swap function _ inspired from C & Our 2GA3 book

	mov [tmp], eax
	mov eax, [ecx+4]
	mov [ecx], eax
	mov eax, [tmp]
	mov [ecx+4], eax

	add ecx, 4
	inc edx
	jmp swap

sorthem_end:
	push pegs
	push dword [no]
	call showp
	add esp, 8
	jmp asm_main_end


Error1:
	call print_nl

	mov eax, err1
	call print_string
	call print_nl

	jmp asm_main_end

Error2:
	call print_nl
	mov eax, err2
	call print_string
	call print_nl
	jmp asm_main_end

asm_main_end:
	popa
	leave
	ret

; asm main is inspired from major lab 4 and 5
; showp inspired from tower of hanoi, as provided by Intructor
; sorthem consists of two parts : sorthem and swap
; as the instructor suggested sorthem recursivly calls itself - since i missed the lecture, i learned from the book
; swap changes number 1 with a temp and back with number 2 - inspired from common C swap function


; known bugs:
	;	if the peg is greater at the start, it tends to either stay there or come in between two.
		; calling sorthem again in asm_main just makes the output bigger
		; and doesnt help if the peg is the top
		; if i find a solution before deadline i will upload
		; example given  below
;		final configuration
;
;		  o|o
;		 oo|oo
; ooooooooo|ooooooooo
;		ooo|ooo
;	   oooo|oooo
;	  ooooo|ooooo
;	 oooooo|oooooo
;	ooooooo|ooooooo
;  oooooooo|oooooooo
;XXXXXXXXXXXXXXXXXXXXXXX
