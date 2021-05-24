Instructions for running spark test: 

First, follow the steps in the main readme to run ED_evolve_csv.m on the academic cluster for parameters NN=4, M=100, XXZCoeff=0, and mydir='testdir_spark', for 10 iterations. This may involve editing the files runtask.sh and parallel.batch as described in the main readme. 

After these simulations run, copy the testdir_spark directory into the code directory and run polz_avg_test_nospark.py or polarization_avg_spark.py as described in the main readme. 

polz_avg_test_nospark.py should produce two files, polarizations_pandas.csv and times_pandas.csv. The files produced for the parameters NN=4, M=100, XXZCoeff=0, and mydir='testdir_spark' are included in this test folder. 

polarization_avg_spark.py should produce a folder polarizations_spark.csv and a file times_spark.csv. The folder output contents can be viewed by typing "cat polarizations_pandas.csv/*" into the terminal. The files produced for the parameters NN=4, M=100, XXZCoeff=0, and mydir='testdir_spark' are included in this test folder.
