[bits 32]
stk 12
org 0

&rng_state
db 139451

mov r1, 0
mov r2, 0
mov r3, 0
mov r4, 0

rcl r1, *rng_state
in  r2
add r1, r2
ots r1, *rng_state

#call("rnd1")
#call("rnd2")

pop r2
out r2
pop r2
out r2

end

; assuming a 32 bit cell
; takes 0 inputs, returns 1 PRN on the stack
; 8 bit xorshift, truly the fastest and worst performing
; this is one half of the PRNG suite

@rnd1
  psh r1
  psh r2

; part one

  rcl r1, *rng_state

  mov r2, r1
  shr r2, 5
 bxor r1, r2

  mov r2, r1
  shl r2, 3
 bxor r1, r2

  mov r2, r1
  shr r2, 1
 bxor r1, r2
  
 band r1, 65535
  mov f3, r1
  out f3
  
  ots r1, *rng_state
  
  pop r2
  pop r1
  
  psh f3
  mov f3, 0
  srv
  
  ret

; this is the other half of the PRNG suite
; they're technically semi-dependent, but you can call
; either one or the other however you want it
; since they share the internal state / counter

@rnd2

  psh r1
  psh r2

; part two

  rcl r1, *rng_state

  mov r2, r1
  
  mov r2, r1
  shr r2, 7
 bxor r1, r2
 
  mov r2, r1
  shl r2, 3
 bxor r1, r2
 
  mov r2, r1
  shr r2, 1
 bxor r1, r2

 band r1, 65535
  mov f3, r1
  
  ots r1, *rng_state
  
  pop r3
  pop r1
  
  psh f3
  mov f3, 0
  srv
  
  ret
  
; assuming a 32 bit cell
; takes 2 inputs on stack, returns 1 on stack
; combines 2 PRNG outputs into one twice-wide RN
; make sure that you vary the called functions  

@rnd_combine

; first we pop the return address into f3
; for safekeeping

	pop f3
	
; then store the registers in use on the stack
; while taking inputs into those registers
	psh r1
	srv
	pop r1
	srv
	psh r2
	srv
	pop r2
	
; then OR the two numbers
; one bitshifted << 16
;	mul r1, 65536
    mul r1, r2
    
; restore the registers and push
; output to stack
    psh r1
    srv
    pop r2
    srv
    pop r1
    psh f3
    clr f3
    ret
