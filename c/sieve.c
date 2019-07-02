#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void sieve(unsigned int max) {
    unsigned int nrOfPrimes = 0;
    char *numbers = calloc(max, sizeof(char));

    unsigned int p = 2;

    while (p < max) {    
    
        unsigned int i = 2;

        // Fill in all multiples
        while (i*p < max) {
            numbers[p*i++] = 1;
        };

        // Find next 
        while (p < max) {
            if (numbers[++p] == 0) {
                nrOfPrimes++;
                break;
            }
        }
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

