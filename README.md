# prime-algorithms
This project is intended to be an exercise in code optimization and parallelism.  
The project will consist of algorithms for finding prime numbers that are recursively improved, 
starting from the most naive algorithm.  

Below are planned versions and the execution time of the ones I have implemented. All of the execution times are done with an input of 100 000 000, except for the naive. The naive version has an execution time of ~2h33m19s with an input of 10 000 000, it would run for over two weeks with the same input as the other versions. The execution times are an average over 5 tests. The C code is compiled with gcc -O3 and the ASM code with nasm -felf64.
  
|                                 | C | ASM | Multi-threaded (C + ASM) |  Multi-threaded  + AVX2 (intrinsics) | Multi-threaded + AXV2 (C + ASM) | CUDA |
|---------------------------------|---|-----|--------------------------|--------------------------------------|---------------------------------|------|
| Simple but somewhat optimized   | 2m10.419s  |     |                          |                                      |                                 |      |
| Sieve of eratosthenes           |   |     |                          |                                      |                                 |      |
| Segmented sieve of eratosthenes |   |     |                          |                                      |                                 |      |

&nbsp;  
Each column will be in it's own folder and the files will be called simple, sieve and segSieve.  
The most basic version is in C and is called naive.c. It is located in the main directory.
