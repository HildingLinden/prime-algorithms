		GLOBAL 		nrOfPrimes

		section		.data

		section		.text
nrOfPrimes:
		push		rbx			; To be used for holding the number of primes
		push 		r12			; To be used for holding max prime candidate
		push		r13			; To be used for current prime candidate
		push		r14			; To be used for holding current divisor
		push		r15			; To be used for holding the max divisor that we have to check

		mov			r13d, edi	; starting from first parameter
		mov			r12d, esi	; store max prime candidate from second parameter

		mov			r14d, 2		; initialize divisor

		test		r13d, 1		; if number is odd we can go ahead otherwise inc
		jnz			maxDivisor	

		inc 		r13d

		
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

		mov			eax, ebx

		pop			r15
		pop			r14
		pop			r13
		pop			r12
		pop			rbx

		ret