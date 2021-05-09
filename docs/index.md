# Welcome to Harvard CS 205 Spring 2021 Quantum Simulations Project!

## Team 9 members:
- Gregory Cunningham
- Michelle Chalupnik
- Shelley Cheng
- Oksana Makarova
- 
**Quantum computation** is a topic that gathered a lot of attention in the recent years. The main promise of quantum computing is the opportunity to **solve exponentially scaling problems in much shorter time and with much less memory**. It's possible due to the fundamental difference of "hardware" between classical and quantum computers. Instead of bits, quantum computers operate with **qubits (quantum bits)**, which are usually interacting two-level physical systems called spins. A computation is done by preparing all spins in a certain initial state, letting them interact(evolve) for some time, and then read out the final state of the system. There are a lot of various qubit realizations, such as cold atoms, ions, superconducting qubits, defects in solids and so on. One way to understand why quantum computers are so much better at solving exponentially scaling problems is that your simulator and your simulated system have the same underlying structure (imagine simulating a new material using interacting atoms instead of transistors!).

However, large-scale quantum computers are still unavaliable, so researchers need to rely on classical simulators in their current work. Also, we need capability to model quantum systems in order to design an actually useful machine. 

Simualting a quantum system on a classical machine is a hard problem because **each extra particle doubles the problem size** [See this page for more information](https://oksana-makarova.github.io/CS205-QuantumSimulations/Model_Description). Dynamics of interactions of quantum systems can be described with basic **matrix operations**, such as matrix multiplication and eigenvalue problem, making this problem tractable. Fortunately, those operations are not only parallelizable between different cores and nodes, but also are perfect for being done using GPUs, giving us hope to be able to simulate large quantum systems in shorter times as compared to exponentially long serial computation.

Additional challenge is that the output of the simulation is a wavefunction, which is a 2<sup>N;</sup> large column vector that needs to be post-processed. If one wants to expore time evolution of the system point-by-point, each of the time steps (~1000s of points) would have its own wavefunction. Also, some simulations require thousands of repetitions with different system parameters to emulate averaged behavior of an actual large system. Therefore, this problem might benefit from Big Data processing that would take care of averaging thousands of column vectors before performing final operations to obtain the result. For example, in our project we are interested in checking system polarization along different axes which requires final operation of multiplication of 2<sup>N;</sup> x 2<sup>N;</sup> matrix by the averaged row and column vectros. 




## [Model Description](https://oksana-makarova.github.io/CS205-QuantumSimulations/Model_Description)

You can use the [editor on GitHub](https://github.com/oksana-makarova/CS205-QuantumSimulations/edit/om/docs/index.md) to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run [Jekyll](https://jekyllrb.com/) to rebuild the pages in your site, from the content in your Markdown files.

### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/oksana-makarova/CS205-QuantumSimulations/settings/pages). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://support.github.com/contact) and we’ll help you sort it out.
