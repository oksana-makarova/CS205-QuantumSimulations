#!/bin/sh

#grab current working directory name
MYDIR=$PWD
echo $MYDIR

salloc -p academic -n 16 --mem-per-cpu=1G -t 0-08:00 -N 1
#To move off the login node
#(Not sure if this should go here or in parallel.sbatch?)

# this script outputs some useful information so we can see what parallel
# and srun are doing.

# $1 is arg1:{1} from GNU parallel.
#
# $PARALLEL_SEQ is a special variable from GNU parallel. It gives the
# number of the job in the sequence.
#
# Here we print the host name, and the date and time.
echo task $1 seq:$PARALLEL_SEQ host:$(hostname) date:$(date)

# launch X virtual framebuffer to handle matlab graphics creation                                                                                #xvfb-run matlab -nodisplay -nosplash < "${fullFileName}"
#matlab -nosplash -nodisplay -r "test_ED_evolve"
matlab -nosplash -nodisplay -r "ED_evolve_csv(4, 1000, 0, $PARALLEL_SEQ, '$MYDIR/testdir_spark')"