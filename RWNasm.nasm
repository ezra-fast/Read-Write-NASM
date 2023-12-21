; Authors: Ezra Fast, Mitchell Nicholson
; Date: Sunday, March 5, 2023
; Description: This program is for ITSC204 Lab 3 Part 5. The program prompts the user for an address, R or W to that address, 
;		and then either what is located there or what to put there according to the users option selection.

section	.text

global _start        
      
_start:	                
	mov  rax, 1				; write system call
	mov  rdi, 1    
	mov  rsi, message	
	mov  rdx, len  
	syscall   
 
	mov rax, 0				; read system call
	mov rdi, 0	
	mov rsi, address	
	mov rdx, 12		
	syscall 

	mov rax, 1				; writing option prompt
	mov rdi, 1
	mov rsi, which
	mov rdx, whi_len
	syscall
	
	mov rax, 0				; reading in option selection 
	mov rdi, 0
	mov rsi, option
	mov rdx, 2
	syscall

	xor rsi, rsi				; cleaning rsi register so that it will hold address
	mov rsi, address 

	xor rax, rax				; cleaning rax

						; In the algorithm, rsi contains "address" variable; rcx (c register) contains the "current byte",
						; and RAX (a register) will ultimately contain the useable address at the end.

algorithm:					; THIS ALGORITHM IS BASED ON COMMON HEX CONVERSION ALGORITHM CONCEPT AND MODIFIED FOR THIS PROGRAM.
	cmp byte [rsi+1], 0			; checking for end of string --> for some unknown reason, +1 fixes the "a" problem
	je _continue
	shl rax, 4				; shifting left (multiplying by 16)
	movzx rcx, byte [rsi]			; move the current byte to rcx, zero fill the unused part of the buffer
	sub rcx, 0x30				; converting the ASCII digit to a number
	or al, cl				; combining the number with the lower 4 bits of rax register --> this is a logical OR operation
						; the OR line works because the RAX register is empty, and OR drops bits into place if EITHER
						; al or cl has 1 at a given place. So, it essentially loads the bits into al
						; this can be repeated for all characters because rax is shifted left every loop
	inc rsi					; point to the next digit in the input string
	jmp algorithm				; unconditional loop until line 36 breaks out

_continue:					; AS OF THIS POINT RAX CONTAINS THE ADDRESS ENTERED BY THE USER
	;mov byte[rax], 0x55			; This is successful --> values can be written to user-specified memory locations
	
	mov r14, rax				; at this point rax contains the address entered by the user
	push r14				; pushing r14 onto the stack so that it is preserved. Both the streams of execution pop r14 immediately
	
	cmp byte[option], 0x52			; if "R"
	JE _Read
	Jmp _Write				; unconditional jump to "W" if not "R"
	
_Read:
	
	pop r14					; popping r14 off the stack  
	
	mov rax, 1				; write system call
	mov rdi, 1
	mov rsi, contents
	mov rdx, con_len
	syscall
	
	mov r15, [r14]				; at this line the r15 register contains the little endian format input word
						; r14 holds address of message, r15 holds message, message placed into "stored" 
	mov [stored], r15

	mov rax, 1				; system call to print the message at specified address
	mov rdi, 1
	mov rsi, stored
	mov rdx, 100
	syscall

;	mov r12, newline			; newline print sequence commented out 

;	mov rax, 1
;	mov rdi, 1
;	mov rsi, r12
;	mov rdx, 1
;	syscall

	jmp _start				; unconditional jump to the start so that the user can repeat operations

_Write:						; at this point in execution, the address is in R14 and option contains the option
	
	pop r14					; popping r14 off the stack
	
	mov rax, 1
	mov rdi, 1
	mov rsi, write_into
	mov rdx, write_len
	syscall
	
	mov rax, 0
	mov rdi, 0
	mov rsi, written_message		; this buffer will contain the message that the user enters
	mov rdx, 100
	syscall
						; at this point in execution "written_message" contains the message to write to the address (R14)

	mov rax, qword [written_message]	; load the value of "variable" into the rax register
	mov qword [r14], rax			; store the value of rax at the memory address in r14
	
						; At this point, the address in R14 (user address) will contain the message entered by the user
						; written_message contains the message, r14 contains the address, the address contains the message
	
	jmp _start				; unconditional jump to start so the user can repeat operations
	
exit:		
	mov rax, 60				; exit system call	
	mov rdi, 0		
	syscall			

section	.data					; data section (initialized variables)
	message db "Enter an address: ", 0x00			  
	len equ $- message			
			
	newline db 0xa
			
	which db "R or W: ", 0x00			
	whi_len equ $- which
	
	contents db "Contents: ", 0x00	
	con_len equ $- contents
	
	write_into db "Write This: ", 0x00
	write_len equ $- write_into
	
section .bss					; bss section (uninitialized data)
	space resb 0xFFFF
	address resb 12				
	temp resb 12		
	option resb 1			
	count resb 2
	written_message resb 100
	stored resb 100

