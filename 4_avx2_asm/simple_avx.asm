		GLOBAL 			main
		EXTERN			printf
		EXTERN			strtoul

		section			.text
main:
		sub 			rsp, 8			; align stack to 16-byte boundary

		cmp				rdi, 2			; check that we have 1 argument + program name
		jne				error

		mov 			rdi, [rsi+8]	; get the argument
		mov				rsi, 0
		mov				rdx, 10
		call			strtoul			; atoi(argv[1])

		cmp				rax, 1			; print error if number is below 1
		jl				error2

		cmp				rax, 7			; all numbers under 7 will be hardcoded in special
		jl				special

		vcvtsi2sd		xmm1, rax		; convert max prime to float
		vbroadcastsd	ymm1, xmm1		; and fill the whole vector register with it

		; use rbx temporarily to populate the vector register with the first prime candidate
		mov	 			rcx, 7			; first candidate is 7
		vcvtsi2sd		xmm0, rcx		; convert the prime candidate to scalar double-precision float
		vbroadcastsd	ymm0, xmm0		; fill ymm0 with prime candidate

		mov				rcx, 3			; initialize number of primes to 3 as there are 3 primes under 7

		; rax  max prime candidate as integer
		; rcx number of primes
		; ymm0 candidate
		; ymm1 max prime candidate
		; ymm2 divisors
		; ymm3 max divisors (sqrt)
		; ymm4 quotients
		; ymm5 rounded down quotients
		; ymm6 compare result
		; ymm7 vector to increment all divisors by 4
		; ymm8 vector with all bits set to one to be able to flip the bits of another vector with xor
		; ymm9 vector to increment all candidates by 2
		; ymm10 original divisors (to avoid memory load)

		; loading all constants from memory
		vmovupd			ymm2, [divisors]
		vmovupd			ymm7, [divisorsInc]
		vmovupd			ymm8, [allOnes]
		vmovupd			ymm9, [twos]
		vmovupd			ymm10, [divisors]

maxDivisor:
		vsqrtpd			ymm3, ymm0			; get packed double-precision square root of the prime candidate
		vroundpd		ymm3, ymm3, 2 		; round up
		vmovupd			ymm2, ymm10			; reset divisors

loop:
		vdivpd			ymm4, ymm0, ymm2 	; divide packed double-precision prime candidate by divisors
		vroundpd		ymm5, ymm4, 1		; round down
		vcmppd			ymm6, ymm4, ymm5, 0	; quotient and rounded down quotient are equal if evenly divisible

		vtestpd			ymm6, ymm6			; jump if any division is even (not prime)
		jnz				incCandidate

		vcmppd			ymm6, ymm2, ymm3, 2	; all divisors must be less than or equal to max divisors
		vxorpd			ymm6, ymm6, ymm8	; flip all bits
		vtestpd			ymm6, ymm6			; the candidate is a prime if we have looped through all divisors up to max divisor
		jnz				incPrimes

		vaddpd			ymm2, ymm2, ymm7 	; increment divisors with divisorsInc (4.0,4.0,4.0,4.0)

		jmp 			loop

debug:
		vpermpd			ymm0, ymm13, 00000000b	; move the first double of the vector register to ymm0, the second to ymm1 and so on to be able to display %lf %lf %lf %lf
		vpermpd			ymm1, ymm13, 00000001b
		vpermpd			ymm2, ymm13, 00000010b
		vpermpd			ymm3, ymm13, 00000011b
		mov				rdi, debugfmt
		mov				rax, 4					; use four vector registers
		call			printf
		jmp				exit

incPrimes:
		inc				rcx					; increment number of primes

incCandidate:
		vaddpd			ymm0, ymm0, ymm9	; increment the current prime candidate to the next odd by adding 2.0

		vcmppd			ymm6, ymm0, ymm1, 14; check if we have looped through all prime candidates to max prime candidate
		vptest			ymm6, ymm6
		jz				maxDivisor

print:
		mov				rsi, rax			; print number of primes less than or equal to max prime candidate
		mov				rdx, rcx
		mov				rdi, fmt
		xor				rax, rax
		call			printf

		jmp 			exit

special:
		cmp				rax, 2
		mov				rcx, 0				; 0 primes equal to or under 1
		jl 				print

		mov 			rcx, 1				; 1 prime equal to or under 2
		je				print

		mov 			rcx, 2				; 2 primes equal to or under 4
		cmp				rax, 4
		jle				print

		mov				rcx, 3				; 3 primes equal to or under 6
		jmp				print

error:
		mov				rdi, errmsg
		xor				rax, rax
		call			printf

		jmp				exit

error2:
		mov				rdi, errmsg2
		xor				rax, rax
		call 			printf

exit:
		add				rsp, 8				; realign stack

		xor				rax, rax			; return 0
		ret

		section			.data
fmt:
		db				"The number of primes less than or equal to %d is: %d", 10, 0 		; 10 is "\n" and 0 is NULL TERMINATOR
errmsg:
		db				"You should give 1 parameter", 10, 0
errmsg2:
		db				"The number has to be above 0", 10, 0
divisors:
		dq				3.0, 4.0, 5.0, 6.0
divisorsInc:
		dq				4.0, 4.0, 4.0, 4.0
allOnes:
		dq				0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
twos:
		dq				2.0, 2.0, 2.0, 2.0
debugfmt:
		db				"%lf %lf %lf %lf", 10, 0