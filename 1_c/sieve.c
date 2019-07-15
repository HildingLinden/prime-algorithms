#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void printBits(int a);

int main(int argc, char *argv[]) {
	if (argc < 2) {
        printf("Please specify the limit of the prime search\n");
        return 1;
    }

	int max = strtol(argv[1], NULL, 10);
	int numberOfPrimes = 1;

	char * arr;
	arr = calloc(max/8, sizeof(char));

	int prime = 2;

	do {
		// Fill in multiples of prime
		for (int i = prime; i < max; i += prime) {
			int byte = (i-1) / 8;
			int bit = (i-1) % 8;

			arr[byte] |= (128 >> bit);
		}

		// Find next prime
		for (prime++; prime < sqrt(max); prime++) {
			int byte = (prime-1) / 8;
			int bit = (prime-1) % 8; 
			if (!(arr[byte] & (128 >> bit))) {
				numberOfPrimes++;
				break;
			}
		}

	} while (prime < sqrt(max));

	// Look through rest of the array from sqrt(max) to max to find remaining primes
	for (prime; prime < max; prime++) {
		int byte = (prime-1) / 8;
		int bit = (prime-1) % 8; 
		if (!(arr[byte] & (128 >> bit))) {
			numberOfPrimes++;
		}
	}

	printf("Number of primes less than or equal to %d is: %d\n", max, numberOfPrimes);
}

void printBits(int a) {
	printf("Bits: ");
	for (int j = 7; 0 <= j; j--) {
		printf("%c", (a & (1 << j)) ? '1' : '0');
	}
	printf("\n\n");
}