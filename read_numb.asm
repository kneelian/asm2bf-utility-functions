[bits 32]
stk 24
org 0

mov r1, .1
mov r2, .2
mov r3, .3
mov r4, .4

@main_loop
#call("read_numb")
pop r1
out r1

end

; reads numerical input onto stack
; terminated by exclamation mark / ascii code 33
; returns number to stack
@read_numb
	pop f3
	psh r1
	psh r2
	psh r3
	psh r4
	
	clr r2
	mov r3, 1
	mov r4, 1
	
	@read_numb_loop_1
		in_ r1
		ceq r1, .!
		cjn %read_numb_loop_1_end
		sub r1, 48
		cle r1, 9
		cad r3, 1
		cps r1
		jmp %read_numb_loop_1
	@read_numb_loop_1_end
	
	dec r3
	@read_numb_loop_2
		jz_ r3, %read_numb_loop_2_end
		dec r3
		pop r1
		mul r1, r4
		add r2, r1
		mul r4, 10
		jmp %read_numb_loop_2
	@read_numb_loop_2_end
	
	pop r4
	pop r3
	psh r2
	srv
	pop r2
	srv
	pop r1
	psh f3
	ret	
