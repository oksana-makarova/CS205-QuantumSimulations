#!/bin/sh

#grab current working directory name
MYDIR=$PWD
echo $MYDIR

salloc -p academic -n 8 --mem-per-cpu=1G -t 0-06:00 -N 1
#To move off the login node

# this script outputs some useful information so we can see what parallel
# and srun are doing.

#To avoid overloading the scheduler, need to pause 0.5 to 1 seconds between 
#each sbatch submit
sleepsecs=$[ ( $RANDOM % 10 ) + 10 ]s

# $1 is arg1:{1} from GNU parallel.
#
# $PARALLEL_SEQ is a special variable from GNU parallel. It gives the
# number of the job in the sequence.
#
# Here we print the sleep time, host name, and the date and time.
echo task $1 seq:$PARALLEL_SEQ sleep:$sleepsecs host:$(hostname) date:$(date)

fullFileName="test_ED_evolve.m"
# launch X virtual framebuffer to handle matlab graphics creation                                                                                
#xvfb-run matlab -nodisplay -nosplash < "${fullFileName}"
#matlab -nosplash -nodisplay -r "test_ED_evolve"
matlab -nosplash -nodisplay -r "ED_evolve_csv(4, 1000, 0, $PARALLEL_SEQ, '$MYDIR/testdir1')"

# Sleep a random amount of time.
sleep $sleepsecs
