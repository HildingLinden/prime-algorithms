# prime-algorithms
This project is intended to be an exercise in code optimization and parallelism.  
The project will consist of algorithms for finding prime numbers that are recursively improved, 
starting from the most naive algorithm.  

Below are planned versions and timings of the ones I have implemented.
  
|                                 | C | ASM | Multi-threaded |  Multi-threaded + AVX2 | CUDA |
|---------------------------------|---|-----|----------------|------------------------|------|
| Simple but somewhat optimized   |   |     |                |                        |      |
| Sieve of eratosthenes           |   |     |                |                        |      |
| Segmented sieve of eratosthenes |   |     |                |                        |       

&nbsp;  
Each column will be in it's own folder and the files will be called simple, sieve and segSieve.
