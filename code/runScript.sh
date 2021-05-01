#! /bin/bash                                                                                                                                     
#SBATCH -n 64  #Number of cores                                                                                                                  
#SBATCH -t 400    #Runtime in minutes -t D-HH:MM                                                                                                 
#SBATCH --mem 64000 #Memory per cpu in MB (see also --mem-per-cpu for memory per cpu in MB)                                                      
#SBATCH -o 64core64000MB400min.out    # Standard out goes to this file                                                                           
#SBATCH -e 64core64000MB400min.err    # Standard err goes to this file                                                                           
                                                         
# load new modules system                                                                                                                        
source new-modules.sh
module load matlab
PWDD=$(pwd)
codeDir=""
fullFileName="test_ED_evolve.m"
# launch X virtual framebuffer to handle matlab graphics creation                                                                                
xvfb-run matlab -nodisplay -nosplash < "${fullFileName}"
exit