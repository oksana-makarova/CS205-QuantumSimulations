# CS205-QuantumSimulations
Final project for CS205 Spring 2021

Team members:
1. Michelle Chalupnik
2. Gregory Cunningham
3. Shelley Cheng
4. Oksana Makarova

## Academic Cluster Reproducibility 
To use the academic cluster to run the quantum simulator and generate CSVs containing polarization information 
for later processing, log into the academic cluster, then run on the terminal the following command:
```
$ sbatch parallel.sbatch
```
If necessary, you may need to first clean up files from previous run:
```
$ rm runtask.sh.*
$ rm runtask.log
$ rm slurm-*
```

The CSVs will be generated in a folder called testdir1. 