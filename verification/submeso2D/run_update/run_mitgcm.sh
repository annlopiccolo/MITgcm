#!/bin/bash
# Example batch script for running mpi jobs on Oscar
#**********************
# SLURM JOB INFORMATION
#**********************
# Walltime requested for job (12 hrs)
#SBATCH -t 5:00:00

# Request use of 20 cores and 4GB of memory per core on 1 nodes
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G

# Define Oscar partition to use
#SBATCH -p batch
#SBATCH --account=epscor-condo

# Job Name
#SBATCH -J submeso

# SLURM output (*.out) and error (*.err) file names
# Use '%x' for Job Name,'%A' for array-job ID, '%j' for job ID and '%a' for task ID`
#SBATCH -e %x-%j.err
#SBATCH -o %x-%j.out

# Notify user if job fails or ends (uncomment and add your email address to use)
#SBATCH --mail-user=anna_lo_piccolo@brown.edu
#SBATCH --mail-type=FAIL,END

#********************
# COMMANDS TO EXECUTE
#********************
# load desired modules (change to suit your particular needs)
module purge
module load hpcx-mpi/4.1.5rc2s-yflad4v
module load netcdf-fortran-mpi/4.6.0-ciymq6f

# commands to be executed (change to suit your needs)
srun --mpi=pmix ./mitgcmuv 
