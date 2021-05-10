# "Serial" code implementation 

**Note 1**: the code described in this section is in our GitHub repo in code/serial directory. Description of the performed operation is described on the **paste** page. 

**Note 2**: for this project, we had to write write a script for evolution of a quantum system with a block-diagonal matrix from scratch (ED_evolve_block_diag_serial.m), while the other two functions (evolve_real_system_serial.m an dget_couplings.m) were inspired by code that was provided by Leigh Martin from Lukin group. Those two functions contain physical parameters of an actual quantum system and are used to make the new code compatible with the rest of the code base in the future.

This subpage describes **structure and testing of the base version of the code that doesn't contain any explicit parallelization or accelration**. However, the word serial in the title is taken in quotation marks because a lot of MATLAB built-in functions and operations are multithreaded by default and can run on multiple cores (but not nodes). Quoting MATLAB website:

>“Generally, if you want to make code run faster, first try to vectorize it. For details how to do this, see [Vectorization](https://www.mathworks.com/help/matlab/matlab_prog/vectorization.html). Vectorizing code allows you to benefit from the built-in parallelism provided by the multithreaded nature of many of the underlying MATLAB libraries. However, if you have vectorized code and you have access only to local workers, then parfor-loops may run slower than for-loops. Do not devectorize code to allow for parfor; in general, this solution does not work well.”

Since MATLAB tries to automatically take care of shared memory parallel processing, it expalins why **Parallelization Toolbox's main focus is Distributed-Memory parallel processing**. Even the default option for a pool of parallel workers is [Process-Based Environment](https://www.mathworks.com/help/parallel-computing/choose-between-thread-based-and-process-based-environments.html) instead of Thread-based environment where workers share a common data pool. Therefore, in order to capture MATLAB's default behavior, we tested base code execution with different numbers of cores (between 1 and 32). Unfortunately, MATLAB's *[maximum number of computational threads is equal to the number of physical cores on your machine](https://www.mathworks.com/help/matlab/ref/maxnumcompthreads.html),* so when we request an instance with 64 coreson the cluster, MATLAB sees it as an instance with 32 cores. 

All testing that is desriben on this page was performed on Harvard Cannon cluster on an instance with 64 logical cores (see parameters below):

```javascript
  $ salloc -c 64 --mem=32G -t 240
  $ lscpu    
  Architecture:          x86-64
    
  CPU op-mode(s):        32-bit, 64-bit

  Byte Order:            Little Endian

  CPU(s):                64

  On-line CPU(s) list:   0-63

  Thread(s) per core:    2

  Core(s) per socket:    8

  Socket(s):             4

  NUMA node(s):          8

Vendor ID:             AuthenticAMD

CPU family:            21

Model:                 2

Model name:            AMD Opteron(tm) Processor 6376

Stepping:              0

CPU MHz:               2300.022

BogoMIPS:              4600.04

Virtualization:        AMD-V

L1d cache:             16K

L1i cache:             64K

L2 cache:              2048K

L3 cache:              6144K
```

If you would like to replicate our results, copy the three scripts from GitHub repo *code/serial* directory to your cluster/machine.

Our cluster has pre-installed MATLAB, so in order to run our code in interactive mode, we used the following commands:

```javascript
$ module load matlab/R2021a-fasrc01
$ matlab -nodisplay -nojvm -nosplash
```

Once MATLAB interactive session loaded, we used the following command to run and edit the scripts:

```javascript
>> setenv('EDITOR', 'vim'); %allows you edit files in the interactive mode
>> evolve_real_system_serial
```

`evolve_real_system_serial.m` would call two other functions to evolve a quantum system of various sizes (for example, for 7, 8, 9, and 10 spins in the version on GitHub). It would output timings of the potential code bottlenecks. 



#### [Back to home page](https://oksana-makarova.github.io/CS205-QuantumSimulations/)
