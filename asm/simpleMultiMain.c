#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

// Assembly function that returns number of primes between start and end inclusive
int nrOfPrimes(int start, int end);

// Convenience function that calls the assembly code from each thread
void *threadFunc(void *ptr);

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
	struct thread_data_t data[8];

	if (argc < 2) {
		printf("Please specify the limit of the prime search\n");
		return 1;
	}

	max = strtoul(argv[1], NULL, 10);
	workload = (max-5) / 8; // integer division

	for (int i = 0; i < 8; i++) {
		data[i].start = i*workload+5;
		data[i].end = i*workload+workload+4;

		pthread_create(&threads[i], NULL, threadFunc, &data[i]);
	}

	sum = 2;
 	sum += nrOfPrimes(8*workload+5, max);

	for (int i = 0; i < 8; i++) {
		pthread_join(threads[i], NULL);
	}
	for (int i = 0; i < 8; i++) {
		sum += data[i].result;
	}

	printf("Number of primes under and including %u is: %d\n", max, sum);	

	return 0;
}

void *threadFunc(void *arguments) {
	struct thread_data_t *a = arguments;
	a->result = nrOfPrimes(a->start, a->end);
}
