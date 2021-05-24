# Welcome to Harvard CS 205 Spring 2021 Quantum Simulations Project!

## Team 9 members:
- Gregory Cunningham
- Michelle Chalupnik
- Shelley Cheng
- Oksana Makarova

**Quantum computation** is a topic that gathered a lot of attention in the recent years. The main promise of quantum computing is the opportunity to **solve exponentially scaling problems in much shorter time and with much less memory**. It's possible due to the fundamental difference of "hardware" between classical and quantum computers. Instead of bits, quantum computers operate with **qubits (quantum bits)**, which are usually interacting two-level physical systems called spins. A computation is done by preparing all spins in a certain initial state, letting them interact(evolve) for some time, and then read out the final state of the system. There are a lot of various qubit realizations, such as cold atoms, ions, superconducting qubits, defects in solids and so on. One way to understand why quantum computers are so much better at solving exponentially scaling problems is that your simulator and your simulated system have the same underlying structure (imagine simulating a new material using interacting atoms instead of transistors!).

However, large-scale quantum computers are still unavaliable, so researchers need to rely on classical simulators in their current work. Also, we need capability to model quantum systems in order to design an actually useful machine. 

Simualting a quantum system on a classical machine is a **Big Compute problem because each extra particle doubles the problem size** [(see this page for more information on physics of our problem)](https://oksana-makarova.github.io/CS205-QuantumSimulations/Model_Description). Dynamics of interactions of quantum systems can be described with basic **matrix operations**, such as matrix multiplication and eigenvalue problem, making this problem tractable. Fortunately, **those operations are not only parallelizable between different cores and nodes, but also are perfect for being done using GPUs**, giving us hope to simulate large quantum systems in shorter times as compared to exponentially long serial computation.

Additional challenge is that the **output of the simulation is a wavefunction, which is a 2<sup>N</sup> large column vector** that needs to be post-processed. If one wants to expore time evolution of the system point-by-point, each of the time steps (~1000s of points) would have its own wavefunction. Also, some simulations require thousands of repetitions with different system parameters to emulate averaged behavior of an actual large system. Therefore, this problem might benefit from **Big Data** processing that would take care of **averaging thousands of column vectors before performing final operations to obtain the result**. For example, in our project we are interested in checking system polarization along different axes which requires final operation of multiplication of 2<sup>N</sup> x 2<sup>N</sup> matrix by the averaged row and column vectros. 

We decided to implement our project using **MATLAB** since it's excellent at handling matrix operations and allows us to capture physics of the problem. There are existing **Python libraries** for quantum simulations, such as [QuTiP](http://qutip.org/), and even cloud solutions that provide access to both classical and quantum simulators (check out amazing infrastructure that's provided by [IBM Q](https://www.ibm.com/quantum-computing/)). However, unlike Python, **MATLAB explicitly supports parallelization and accelerated computing with its own built-in librariesand hyperoptimized black-box functions**, so we think that MATLAB has more potential for fast computation of large systems. Additionally, [QuTiP relies on solving differential equations at different time points instead of solving eigenvalue problem](http://qutip.org/docs/3.1.0/guide/dynamics/dynamics-master.html), which makes it cubersome to simulate long-time system dyanmics, unlike in our solution where we can obtain system state at any time point with simple matrix multiplication.

Our quantum simulator falls under big compute and big data. The application is a GPU-type application, due to the prevalence of matrix operations. Our code produces hundreds or thousands of 2^N by M polarizations from quantum states which we sort by polarization, then average using PySpark on AWS. The types of parallelism we use are both many-core and multi-node, since we use GPU acceleration as well as a PySpark cluster. Our parallel execution model is single program multiple data, with a single program running on multiple nodes and multiple cores. We use task-level parallelism, where interrelated tasks within the application run in parallel, in order to run many simulations simultaneously, and then postprocess. We also use loop level parallelism, which parallelizes iterations within a loop, in order to speed up solving for eigenvalues as well as the matrix multiplication.

We use the MATLAB programming language, the academic cluster (with slurm job manager), and AWS for PySpark.



## Below is the list of the subpage links (some of which were mentioned in the text):

### [Physical Model Description](https://oksana-makarova.github.io/CS205-QuantumSimulations/Model_Description)
### [Benchmarking of the original code](https://oksana-makarova.github.io/CS205-QuantumSimulations/serial_code)
### [Benchmarking of the parallelized code](https://oksana-makarova.github.io/CS205-QuantumSimulations/Parallel_benchmarking)
### [Big Data processing with PySpark](https://oksana-makarova.github.io/CS205-QuantumSimulations/spark)
### [GPU-accelerated diagonalization](https://oksana-makarova.github.io/CS205-QuantumSimulations/Matrix_Load_Balancing)
### [Final presentation slides](https://github.com/oksana-makarova/CS205-QuantumSimulations/blob/19f8c64138725be9f18a5ed8678e434e2e1c14fe/docs/CS_205_Quantum_Simulations_final.pptx)


