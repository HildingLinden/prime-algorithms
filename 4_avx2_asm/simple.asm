		GLOBAL 		main
		EXTERN		printf
		EXTERN		strtoul

		section		.text
main:
		push		rbx			; To be used for holding the number of primes
		push 		r12			; To be used for holding max prime candidate
		push		r13			; To be used for current prime candidate

		cmp			rdi, 2		; check that we have 1 parameter + program name
		jne			error

		mov 		rdi, [rsi+8]	; atoi(argv[1])
		mov			rsi, 0
		mov			rdx, 10
		call		strtoul

		mov			r12, rax	; store max prime candidate
		;mov			r13, 2		; initialize prime candidate to 2

		;cmp			r12, 1
		;jl			error2		; print error if number is below 1
		
		;cmp			r12, 11		; all numbers under 11 will be hardcoded in special
		;jl			special

		;mov	 		r13, 11		; first candidate is 11
		;mov			rbx, 4		; 4 primes under 11

		; ymm0 candidate
		; ymm1 maxDivisor
		; ymm2 divisors
		; ymm3 quotients 
		; ymm4 int quotients -> float fraction quotients
		; ymm5 divisorsInc
		; ymm6 zeroes
		; ymm7 ones
		; ymm8 allOnes
		; ymm9 divisor compare result
		; ymm10 twos
		; ymm11 max prime candidate
		; ymm12 original divisors (to avoid memory load)

		vmovupd			ymm2, [divisors]
		vmovupd			ymm5, [divisorsInc]
		vmovupd			ymm6, [zeroes]
		vmovupd			ymm7, [ones]
		vmovupd			ymm8, [allOnes]
		vmovupd			ymm10, [twos]
		vmovupd			ymm12, [divisors]

maxDivisor:
		; non-vex sqrt (sqrtsd) about 25% faster but might be penalized later
		vcvtsi2sd		xmm0, r12d			; convert the prime candidate to scalar double-precision float
		vbroadcastsd	ymm0, xmm0			; fill ymm0 with prime candidate 

		vsqrtpd			ymm1, ymm0			; get packed double-precision square root
		vroundpd		ymm1, ymm1, 2 		; round up

loop:
		vdivpd			ymm3, ymm0, ymm2 	; divide packed double-precision
		vroundpd		ymm4, ymm3, 1		; round down
		vcmppd			ymm4, ymm3, ymm4, 0	; they are equal if evenly divisible

		;vtestpd			ymm4, ymm4			; jump if any division is even
		;jnz				incCandidate

		vcmppd			ymm13, ymm2, ymm1, 2	; all divisors must be less than or equal
		vxorpd			ymm13, ymm13, ymm8		; flip all bits
		vtestpd			ymm4, ymm4			; loop if above is not true
		jnz				exit

		vfmadd132pd		ymm2, ymm5, ymm7 	; increment divisors with divisorsInc
		
		jmp 			error

		;vmovapd			ymm0, ymm4

		inc				ebx					; increment number of primes

incCandidate:
		jmp				exit
		vfmadd132pd		ymm0, ymm10, ymm7	; increment the current prime candidate to the next odd
		vmovupd			ymm2, ymm12			; reset divisors

		;vcmpsd			ymm0, ymm11, ymm0, 14; check if we have looped through all prime candidates
		;vptest			ymm0, ymm0
		;jz				maxDivisor

print: 
		mov			rdx, rbx
		mov			rsi, r12
		mov			rdi, fmt
		xor			rax, rax
		call		printf

		jmp 		exit

special:
		cmp			r12, 2		
		mov			rbx, 0		; 0 primes equal to or under 1
		jl 			print		

		mov 		rbx, 1		; 1 prime equal to or under 2
		je			print

		mov 		rbx, 2		; 2 primes equal to or under 4
		cmp			r12, 4
		jle			print

		mov			rbx, 3		; 3 primes equal to or under 6
		cmp			r12, 6
		jle			print

		mov			rbx, 4		; 4 primes equal to or under 10
		jmp 		print

error:
		mov			rdi, errmsg
		xor			rax, rax
		call		printf

		jmp			exit

error2:		
		mov			rdi, errmsg2
		xor			rax, rax
		call 		printf

exit:
		pop			r13
		pop			r12
		pop			rbx

		xor			rax, rax
		ret

		section		.data
fmt:	db		"The number of primes less than or equal to %d is: %d", 10, 0 		; 10 is "\n" and 0 is NULL TERMINATOR
errmsg:	db		"You should give 1 parameter", 10, 0
errmsg2:db		"The number has to be above 0", 10, 0
zeroes: dq		0.0000012, 0.0000012, 0.0000012, 0.0000012
divisors:
		dq		3.0, 4.0, 5.0, 6.0
divisorsInc:
		dq		4.0, 4.0, 4.0, 4.0
ones:	dq		1.0, 1.0, 1.0, 1.0
fmtf:	db		"%lf", 10, 0
allOnes:
		dq		0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
twos:	dq		2.0, 2.0, 2.0, 2.0