# Challenging Aspects
- The success of the code depends on whether there is enough memory to hold the largest matrix (this is non-negotiable, since diagonalization of a single block can’t be further blocked or split up; it’s a serial task within the largest block)
  - Maximum memory per gpu on cluster limits problem size to N=14
- Load balancing aims to reduce communication overhead (between cpu and gpu memory), again limited by size of largest block and memory per gpu 
  - Custom/manual load balancing involves indexing that works differently for odd or even N
- Blocking here is unique and different from what was discussed in class, since we effectively remove large sections of the big initial matrix
  - Taking advantage of the math/physics of the problem, not deeply discussed in class
