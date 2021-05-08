#!/bin/bash
#
#SBATCH -J test
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gcunningham@g.harvard.edu
#SBATCH -o output.out
#SBATCH -e output.err
#SBATCH -p gpu 
#SBATCH -n 1 
#SBATCH --gres=gpu:4
#SBATCH --mem 120G 
#SBATCH -t 0-0:10

module load matlab/R2021a-fasrc01

matlab -nodisplay -nosplash < test4.m get_couplings.m ED_evolve_block_diag_gpu_parfeval_lb.m eig_load_balanced.m