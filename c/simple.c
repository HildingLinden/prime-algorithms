#include <stdio.h>
#include <stdlib.h>

int sieve(unsigned int max) {
    unsigned int nrOfPrimes = 4;    

    for (unsigned int i = 11; i < max; i = i + 2) {
        char isPrime = 1;
        unsigned int j = 3;
        int limit = sqrt(i)+0.5;

        for (; j <= limit; j++) {
            if (i % j == 0) {
                isPrime = 0;
                break;
            }
        }
        if (isPrime) nrOfPrimes++;
    }

    printf("Nr of primes: %u\n", nrOfPrimes);
}

int main(int argc, char *argv[]) {
        if (argc < 2) {
                printf("Please specify the limit of the prime search\n");
                return 1;
        }
        sieve(strtotul(argv[1], NULL, 10));

        return 0;
}

