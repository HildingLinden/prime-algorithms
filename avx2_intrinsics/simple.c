#include <immintrin.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("Please specify the limit of the prime search\n");
		return 1;
	}

	int primes[168] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997};

	// Constant vectors
	const double testIncFloat = 4.0;
	const double zeroesFloat = 1.2e-06;
	const double onesFloat = 1.0;
	__m256d divisorsInc = _mm256_broadcast_sd(&testIncFloat);			// vector for incrementing the divisors
	__m256d	zeroes		= _mm256_broadcast_sd(&zeroesFloat);			// vector with the machine epsilon * 2
	__m256d	ones		= _mm256_broadcast_sd(&onesFloat);				// vector with all ones

	double divisorsArr[4] = {3.0,4.0,5.0,6.0};
	__m256d	candidate, divisors, floats, diffs, result;
	__m128i ints;

	int nrOfPrimes = 4;
	int max = atoi(argv[1]);

	int candidateInt, undivisable, divisorsLeft;
	char isPrime;

	for (int i = 11; i <= max; i+=2) {

		candidateInt = i;
		isPrime = 1;													// candidate is prime until proven otherwise

		int limit = sqrt(candidateInt)+0.5f;							// get the limit of divisors

		if (limit <= 10) {												// if limit is lower than 10 we do the check non-vectorized since the vector divisors are 3-10
			for (int i = 3; i <= limit; i++) {
				if (candidateInt % i == 0) {
					isPrime = 0;
					break;
				}
			}
		} else {
			divisors		= _mm256_loadu_pd(&divisorsArr[0]);				// initial divisors

			const double candidateFloat	= (double)candidateInt;				// converting the candidate to a constant float to be able to broadcast it to the vector
			candidate	 	= _mm256_broadcast_sd(&candidateFloat);			// vector with the prime candidate in all elements

			for (int divisorIndex = 6; divisorIndex <= limit; divisorIndex+=4) {	// 10 is the last divisor we start with and the stride is 8 beacause of 8 floats in AVX2
				floats		= _mm256_div_pd(candidate, divisors);					// division result as floats
				ints		= _mm256_cvttpd_epi32(floats);							// convert them to integers
				diffs 		= _mm256_sub_pd(floats, _mm256_cvtepi32_pd(ints));		// convert back, and subtract from original, which should leave us with the fractional part
				result		= _mm256_cmp_pd(diffs, zeroes, 2);						// if ((float - truncated float) <= 0) = 1 in result
				undivisable = _mm256_testz_pd(result, result);						// undivisable = 1 (true) if all result are 0. A result is 0 if the division returned a number with fraction

				// if (i == 119) {
				// 	double debug[4], debug2[4], debug3[4];
				// 	_mm256_storeu_pd(&debug[0], diffs);
				// 	_mm256_storeu_pd(&debug2[0], floats);
				// 	_mm256_storeu_pd(&debug3[0], divisors);
				// 	//printf("%d\n",divisorIndex)
				// 	for (int j = 0; j < 4; j++) {
				// 		printf("%d / %f = %f with %f remainder\n", i, debug3[j], debug2[j], debug[j]);
				// 	}
				// }
				if (!undivisable) {
					isPrime = 0;
					break;
				}

				divisors		= _mm256_add_pd(divisors, divisorsInc);				// increment each divisor by 8
			}

			divisorsLeft = (limit-10) % 4;
			for (int i = limit-divisorsLeft+1; i <= limit; i++) {					// do non-vectorize checking for the remainding divisors
				if (candidateInt % i == 0) {
					isPrime = 0;
					break;
				}
			}
		}

		if (isPrime) {
			// char found = 0;
			// for (int j = 0; j < 168; j++) {
			// 	if (primes[j] == i) found = 1;
			// }
			// if (!found) printf("%d was erronously found as prime\n", i);
			nrOfPrimes++;
		}
	}

	printf("Number of primes under or equal to %d is: %d\n", max, nrOfPrimes);
	return 0;
}