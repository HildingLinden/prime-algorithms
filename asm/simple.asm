		GLOBAL 		main
		EXTERN		printf
		EXTERN		strtoul

		section		.text
main:
		push		rbx			; To be used for holding the number of primes
		push 		r12			; To be used for holding max prime candidate
		push		r13			; To be used for current prime candidate
		push		r14			; To be used for holding current divisor
		push		r15			; Max divisor that we have to check

		cmp			rdi, 2		; check that we have 1 parameter + program name
		jne			error

		mov 		rdi, [rsi+8]	; atoi(argv[1])
		mov			rsi, 0
		mov			rdx, 10
		call		strtoul

		mov			r12, rax	; store max prime candidate
		mov			r13, 2		; initialize prime candidate to 2

		cmp			r12, 1
		jl			error2		; print error if number is below 1
		mov			rbx, 0		; set nr of primes to 0 and print if number is 1
		je			print

		cmp			r12, 3		; check if number is 2 or 3 since those are special cases
		mov			rbx, 1	
		jl			print		; set nr of primes to 1 and print if number is 2
		mov			rbx, 2
		je			print		; set nr of primes to 2 and print if number is 3

		cmp			r12, 4		; same as above but with 4
		je			print

		mov	 		r13, 5		; next prime candidate is 5, we skip 4 since that is even
		mov			r14, 2		; initialize divisor

		; maxDivisor, loop and incCandidate uses 32-bit register too speed up the computation

maxDivisor:
		cvtsi2ss	xmm0, r13d	; convert the prime candidate to single-precision float
		sqrtss		xmm0, xmm0	; get single-precision square root
		cvttss2si	r15d, xmm0	; convert the result back to integer with truncation and add 1 to get the ceil
		inc			r15d


loop:
		mov			eax, r13d	; move current prime candidate to eax
		xor			edx, edx	; reset edx (used for remainder)
		div			r14d		; unsigned integer division

		test		edx, edx	; if prime candidate is evenly divisible it's not a prime and we go to the next candidate
								; "test r, r" is slighty faster than "cmp r, 0"
		je			incCandidate

		inc			r14d
		cmp			r14d,r15d	; compare current divisor and max divisor
		jng			loop

		inc			ebx

incCandidate:
		add			r13d, 2		; increment the current prime candidate to the next odd
		mov			r14d, 2		; reset divisor to 2
		cmp			r13d, r12d	; check if we have looped through all prime candidates
		jng			maxDivisor

print: 
		mov			rdx, rbx
		mov			rsi, r12
		mov			rdi, fmt
		xor			rax, rax
		call		printf

		jmp 		exit

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
		pop			rbx
		pop			r15
		pop 		r14
		pop			r13
		pop			r12

		xor			rax, rax
		ret

		section		.data
fmt:	db		"The number of primes less than or equal to %d is: %d", 10, 0 		; 10 is "\n" and 0 is NULL TERMINATOR
errmsg:	db		"You should give 1 parameter", 10, 0
errmsg2:db		"The number has to be above 0", 10, 0