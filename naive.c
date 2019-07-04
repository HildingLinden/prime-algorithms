#include <stdio.h>
#include <stdlib.h>

int sieve(unsigned int max) {
	unsigned int nrOfPrimes = 0;
    for (unsigned int i = 2; i < max; i++) {
        unsigned int j = 2;
        for (; j < i; j++) {
            if (i % j == 0) break;
        }
        if (j == i) nrOfPrimes++;
    }

    printf("%d\n", nrOfPrimes);
}

int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("Please specify the limit of the prime search\n");
		return 1;
	}
	sieve(strtoul(argv[1], NULL, 10));

	return 0;
}
