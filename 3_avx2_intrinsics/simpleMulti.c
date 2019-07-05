#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <math.h>
#include <immintrin.h>

void *numberOfPrimes(void *ptr);

// Struct for giving the parameters to the thread function and getting the result back
struct thread_data_t {
	int start;
	int end;
	int result;
};

int main(int argc, char *argv[]) {
	unsigned int max;
	int workload, sum;
	pthread_t threads[8];
	struct thread_data_t data[9];

	if (argc < 2) {
		printf("Please specify the limit of the prime search\n");
		return 1;
	}

	max = strtoul(argv[1], NULL, 10);
	workload = (max-5) / 8; // integer division

	for (int i = 0; i < 8; i++) {
		data[i].start = i*workload+5;
		data[i].end = i*workload+workload+4;

		pthread_create(&threads[i], NULL, numberOfPrimes, &data[i]);
	}

	sum = 4;

	data[8].start = 8*workload+5;
	data[8].end = max;
	numberOfPrimes(&data[8]);
 	sum += data[8].result;

	for (int i = 0; i < 8; i++) {
		pthread_join(threads[i], NULL);
	}
	for (int i = 0; i < 8; i++) {
		sum += data[i].result;
	}

	printf("Number of primes under and including %u is: %d\n", max, sum);	

	return 0;
}

void *numberOfPrimes(void *arguments) {
	struct thread_data_t *a = arguments;

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

	int nrOfPrimes = 0;

	int candidateInt, undivisable, divisorsLeft;
	char isPrime;

	for (int i = a->start; i <= a->end; i+=2) {

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

		if (isPrime) nrOfPrimes++;
	}

	a->result = nrOfPrimes;
}
