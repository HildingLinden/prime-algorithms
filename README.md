# prime-algorithms
This project is intended to be an exercise in code optimization and parallelism.  
The project will consist of algorithms for finding prime numbers that are recursively improved, 
starting from the most naive algorithm.  

Below are planned versions and the execution time of the ones I have implemented.
  
|                                 | C | ASM | Multi-threaded (C + ASM) |  Multi-threaded  + AVX2 (intrinsics) | Multi-threaded + AXV2 (C + ASM) | CUDA |
|---------------------------------|---|-----|--------------------------|--------------------------------------|---------------------------------|------|
| Simple but somewhat optimized   |   |     |                          |                                      |                                 |      |
| Sieve of eratosthenes           |   |     |                          |                                      |                                 |      |
| Segmented sieve of eratosthenes |   |     |                          |                                      |                                 |      |

&nbsp;  
Each column will be in it's own folder and the files will be called simple, sieve and segSieve.  
The most basic version is in C and is called naive.c. It is located in the main directory.
