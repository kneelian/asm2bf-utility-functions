[bits 32]
stk 12
org 0

psh 3119
#call("print_binary16")
out 10

end

; consumes one argument on the stack
; prints out a 32 bit number as bits
; calls print_binary twice
; i haven't (re)checked this one haha

@print_binary32
	pop f3
	psh r1
	srv
	pop r1
	psh r2
	
	mov r2, r1
	shr r2, 16
	psh f3
    psh r2
    $(call("print_binary16"))
    mov r2, r1
    shl r2, 16
    psh r2
    $(call("print_binary16"))
	pop f3
  
	pop r2
	pop r1
	psh f3
	ret

; consumes one argument on the stack
; prints out a 16 bit number as bits
@print_binary16
	pop f3
	psh r1
	srv
	pop r1
	psh r2
	psh r3
	
	mov r3, 32768
	@print_binary16_loop_1
		mov r2, r1
	   band r2, r3
 		and r2, 1
		add r2, 48
		out r2
		div r3, 2
		jnz r3, %print_binary16_loop_1
	pop r3
	pop r2
	pop r1
	psh f3
	ret
