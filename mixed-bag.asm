; a lot of rando functions, including ln(x), sin(x), pwr(x,y), some input and print functions etc

[bits 32]
stk 24
org 0

mov r1, .1
mov r2, .2
mov r3, .3
mov r4, .4
mov r5, .5

#call("read_numb")
dup
#gen_text("ln (")
#call("print_dec_2pt")
#gen_text(") is ")
#call("ln_scaled") 
#call("print_dec_4pt")
#gen_text(" (scaled to x100k)")
out 10

end

#call("read_numb")
#call("read_numb")

#call("dist_scaled")
#call("print_dec_3pt")
#gen_text(" (scaled to x1k)")

dup
#gen_text("ln (")
#call("print_dec_2pt")
#gen_text(") is ")
#call("ln_scaled") 
#call("print_dec_4pt")
#gen_text(" (scaled to x100k)")
out 10
#call("read_numb")
dup
#gen_text("sin (")
#call("print_dec_2pt")
out 176
#gen_text(") is ")
#call("sin_scaled") 
#call("print_dec_2pt")
#gen_text(" (scaled to x100)")
out 10

; consumes two arguments on the stack, scaled x100
; returns one argument, scaled x1000 / 3 pt
; dist(x) is the Pythagorean
; arguments are A and B
; 2/2/1
@dist_scaled
	pop f3
	psh r1
	srv
	pop r1
	srv
	psh r2
	srv
	pop r2
	
	mov r3, r1
	mul r3, r1
	mov r1, r3
	
	mov r3, r2
	mul r3, r2
	mov r2, r3
	
	add r1, r2
	
	psh f3
		psh r1
		$(call("sqrt_scaled"))
		pop r1
	pop f3
		div r1, 1
	psh r1
	srv
	pop r2
	srv
	pop r1
	psh f3
ret

; consumes one argument on the stack, scaled x100
; returns one argument, scaled x10 000
; sin(x) is an approximation
; obviously inaccurate
; new call type, 1/3/1
@sin_scaled
	pop f3
	psh r1
	srv
	pop r1
	psh r2
	psh r3
	
; formula is (4x*(180-x))/(40500-x(180-x))
; calculating (180-x) first
; then calculating x(180-x)
; and dividing by 100 for scale factor?
	mov r2, 18000
	sub r2, r1
	mul r2, r1
	div r2, 100
	
; now calculating 40500-x(180-x)
	mov r3, 405
	mul r3, 10000
	sub r3, r2
	div r3, 100

; now calculating 4x(180-x)
	mul r2, 4

; now dividing the two
	psh f3
		psh r2
		psh r3
		$(call("div_fix2p"))
		pop r3
	pop f3
	
; should have sin(x) in r3 now
	
	psh r3
	srv
	pop r3
	srv
	pop r2
	srv
	pop r1
	psh f3
	ret
	
; consumes one argument on the stack
; returns one argument
; ln(x) as a series approximation
; input is scaled to two decimal places
; output inaccurate, scaled to four decimal places
@ln_scaled
	pop f3
	
	psh r1
	srv
	pop r1
	psh r2
	psh r3
	psh r4
	psh r5
	psh r1
	ceq r1, 271
	cmo r5, 4984
	ceq r1, 272
	cmo r5, 5003
	cjn %ln_scaled_loop_1_end
	
; r5 as result
	clr r2
	clr r3
	clr r4
	clr r5
	
; calculating x-1/x+1 and storing it in r1
	mov r2, r1
; this is D, stored in r1  -- three decimal places
	sub r1, 100
	add r2, 100
	mul r1, 10

; dividing inline instead

	mul r1, 100
	div r1, r2
	
; step number stored in r3
; 1/n stored in r4 -- three decimal places
; result stored in r5
	clr r5
	mov r3, 1
	@ln_scaled_loop_1
		cgt r3, 23
		cjn %ln_scaled_loop_1_end
		psh f3
			mov r4, 1000
			div r4, r3
			mul r3, 100
			
			psh r1
			psh r3
			$(call("pwr_scaled"))
			pop r2
			mul r2, r4
			div r2, 100

		pop f3
		
		add r5, r2
		
		div r3, 100
		inc r3
		inc r3
		jmp %ln_scaled_loop_1
	@ln_scaled_loop_1_end
	mul r5, 2
	psh r5
	srv
	pop r5
	srv
	pop r4
	srv
	pop r3
	srv
	pop r2
	srv
	pop r1
	psh f3
	ret

; consumes two arguments
; returns one
; takes number into r1
; reduces scale by r2
@scale_reduce
	pop f3
	psh r2
	srv
	pop r2
	srv
	psh r1
	srv
	pop r1

	ceq r2, 100
	cjn %scale_reduce_loop_1_exit
	div r2, 100
	
	@scale_reduce_loop_1
		jz_ r2, %scale_reduce_loop_1_exit
		div r1, 10
		dec r2
		dec r2
		jmp %scale_reduce_loop_1
	@scale_reduce_loop_1_exit
	psh r1
	srv
	pop r2
	srv
	pop r1
	psh f3
	ret
	
; consumes two arguments on the stack
; returns one argument to stack
; exponentiation: x ^ y
; first argument x, second argument y
@pwr
	pop f3
	psh r1
	srv
	pop r1
	srv
	psh r2
	srv
	pop r2
	psh r3

; r1 has y, r2 has x
	ceq r1, 0
	cmo r2, 1
	jz_ r1, %pwr_loop_1_end
	
; r1 has y-1, r2 has x, r3 has x
	dec r1
	mov r3, r2
	@pwr_loop_1
		dec r1
		mul r2, r3
		jz_ r1, %pwr_loop_1_end
		jmp %pwr_loop_1
	@pwr_loop_1_end
	pop r3
	psh r2
	srv
	pop r2
	srv
	pop r1
	psh f3
	ret

; consumes two arguments on the stack
; returns one argument
; exponentiation: x ^ y
; first argument x, second argument y
; scaled to 100x
@pwr_scaled
	pop f3
	psh r1
	srv
	pop r1
	srv
	psh r2
	srv
	pop r2
	psh r3
	cle r1, 100
	cjn %pwr_scaled_loop_1_end
	div r1, 100
; r1 has y, r2 has x
; r1 has to be an integer
	ceq r1, 0
	cmo r2, 1
	jz_ r1, %pwr_scaled_loop_1_end
	ceq r1, 1
	cjn %pwr_scaled_loop_1_end
; r1 has y-1, r2 has x, r3 has x, r4 has y
	dec r1
	mov r3, r2
	@pwr_scaled_loop_1
		dec r1
		mul r2, r3

		div r2, 1000
		jz_ r1, %pwr_scaled_loop_1_end
		jmp %pwr_scaled_loop_1
	@pwr_scaled_loop_1_end
	pop r3
	psh r2
	srv
	pop r2
	srv
	pop r1
	psh f3
	ret
	

; reads numerical input onto stack
; terminated by exclamation
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

@sqrt_scaled
	pop f3
	psh r1
	srv
	pop r1
	psh r2
	psh r3
	psh r4
	
; r1 contains input
; r2 contains the result
; r3 is 4x smaller than resolution -- here 2^24
; r4 contains some intermediate ops
	mul r1, 100
; needs to be scaled towards input -- here it's x 10 000 for scaling
	mov r2, 0
	mov r3, 4096
	mul r3, 4
	mul r3, 4
	mul r3, 4096
	
; while (r3 > r1) { r3 >>= 2; }
	
	@sqrt_scaled_loop_1
		cgt r3, r1
		cdi r3, 4
		cjn %sqrt_scaled_loop_1

; while ( r3 != 0 ) { 
; if(r1 >= r2 + r3) { r1 -= (r2 + r3); r2 += 2 * r3; } 
; r2 =>> 1; r2 =>> 2; }
; r4 is here r2 + 43
	
	@sqrt_scaled_loop_2
		ceq r3, 0
		cjn %sqrt_scaled_loop_2_exit
		psh f1
			mov r4, r2
			add r4, r3
			cge r1, r4
			csu r1, r4
			cad r2, r3
			cad r2, r3
		pop f1
		asr r2
		asr r3
		asr r3
		jmp %sqrt_scaled_loop_2
	@sqrt_scaled_loop_2_exit		
		
	pop r4
	pop r3
	psh r2
	srv
	pop r2
	srv
	pop r1
	psh f3
	ret
	
; consumes two arguments on the stack
; returns one argument on the stack
; divides two fixed point numbers
; the scaling is assumed to be 2 decimals
@div_fix2p
	pop f3
	psh r1
	srv
	pop r1
	srv
	psh r2
	srv
	pop r2
	
	mul r2, 100
	div r2, r1
	
	psh r2
	srv
	pop r2
	srv
	pop r1
	psh f3
	ret

; consumes two arguments on the stack
; returns one argument on the stack
; multiplies two fixed point numbers
; the scaling is assumed to be 2 decimals
@mul_fix2p
	pop f3
	psh r1
	srv
	pop r1
	srv
	psh r2
	srv
	pop r2
	
	mul r1, r2
	div r1, 100
	
	psh r1
	srv
	pop r2
	srv
	pop r1
	psh f3
	ret

; consumes one input from stack
@print_decimal
	pop f3
	
	psh r1
	srv
	pop r1
	psh r2
	psh r3
	
	mov r2, r1
	mov r3, 10
	
	psh 99
	
	@print_decimal_loop_1
		mov r2, r1
		mod r2, r3
		sub r1, r2
		div r3, 10
		div r2, r3
		mul r3, 100
		psh r2
		jz_ r1, %print_decimal_loop_1_exit
		cgt r3, 10000
		cdi r1, 10000
		cps r1
		cjn %print_decimal_loop_1_exit
		jmp %print_decimal_loop_1
	@print_decimal_loop_1_exit
	
	@print_decimal_loop_2
		pop r1
		sub r1, 99
		jz_ r1, %print_decimal_loop_2_exit
		add r1, 147
		out r1
		jmp %print_decimal_loop_2
	
	@print_decimal_loop_2_exit
	
	pop r3
	pop r2
	pop r1
	
	psh f3
	ret
	
; consumes 1 argument from stack
; hardcoded decimal point
; returns empty stack
; excl is 33
@print_dec_2pt
	
	pop f3
	psh r1
	srv
	pop r1
	psh r2
	psh r3
	psh r4

	clr r3
	psh 99
	
	@print_dec_2pt_loop_1
		jz_ r1, %print_dec_2pt_loop_1_exit
		mov r2, r1
		mod r2, 10
		psh r2
		div r1, 10
		
			ceq r3, 1
			cps ..
			cad r3, 1
		
		inc r3
		jmp %print_dec_2pt_loop_1
	
	@print_dec_2pt_loop_1_exit
	
	inc r3
	@print_dec_2pt_loop_2
		pop r1
		ceq r1, 99
		cjn %print_dec_2pt_loop_2_exit
		cne r1, ..
		cad r1, 48
		out r1	
		dec r3
		jz_ r3, %print_dec_2pt_loop_2_exit
		jmp %print_dec_2pt_loop_2
	@print_dec_2pt_loop_2_exit
	
	
	pop r4
	pop r3
	pop r2
	pop r1
	psh f3
	ret
	
; ==================

@print_dec_4pt
	pop f3
	psh r1
	srv
	pop r1
	psh r2
	psh r3
	psh r4

	clr r3
	psh 99
	
	@print_dec_4pt_loop_1
		jz_ r1, %print_dec_4pt_loop_1_exit
		mov r2, r1
		mod r2, 10
		psh r2
		div r1, 10
			ceq r3, 3
			cps ..
			cad r3, 1
		inc r3
		jmp %print_dec_4pt_loop_1
	@print_dec_4pt_loop_1_exit
	ceq r3, 0
	cps 0
	cad r3, 1
	ceq r3, 1
	cps 0
	cad r3, 1
	ceq r3, 2
	cps 0
	cad r3, 1
	ceq r3, 3
	cps ..
	cad r3, 1
	
	@print_dec_4pt_loop_2
		pop r1
		ceq r1, 99
		cjn %print_dec_4pt_loop_2_exit
		cne r1, ..
		cad r1, 48
		out r1	
		dec r3
		jz_ r3, %print_dec_4pt_loop_2_exit
		jmp %print_dec_4pt_loop_2
	@print_dec_4pt_loop_2_exit
	pop r4
	pop r3
	pop r2
	pop r1
	psh f3
	ret

@print_dec_3pt
	pop f3
	psh r1
	srv
	pop r1
	psh r2
	psh r3
	psh r4

	clr r3
	psh 99
	
	@print_dec_3pt_loop_1
		jz_ r1, %print_dec_3pt_loop_1_exit
		mov r2, r1
		mod r2, 10
		psh r2
		div r1, 10
			ceq r3, 2
			cps ..
			cad r3, 1
		inc r3
		jmp %print_dec_3pt_loop_1
	@print_dec_3pt_loop_1_exit
	ceq r3, 0
	cps 0
	cad r3, 1
	ceq r3, 1
	cps 0
	cad r3, 1
	ceq r3, 2
	cps ..
	cad r3, 1
	
	@print_dec_3pt_loop_2
		pop r1
		ceq r1, 99
		cjn %print_dec_3pt_loop_2_exit
		cne r1, ..
		cad r1, 48
		out r1	
		dec r3
		jz_ r3, %print_dec_3pt_loop_2_exit
		jmp %print_dec_3pt_loop_2
	@print_dec_3pt_loop_2_exit
	pop r4
	pop r3
	pop r2
	pop r1
	psh f3
	ret
