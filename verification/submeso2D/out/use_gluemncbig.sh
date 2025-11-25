#!/bin/bash
# Example batch script for running gluemncbig on Oscar
#**********************
# SLURM JOB INFORMATION
#**********************
# Walltime requested for job (4 days)
#SBATCH -t 1:00:00

# Request use of 25 cores and 4GB of memory per core on 16 nodes
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G

# Define Oscar partition to use
#SBATCH -p batch

# Job Name
#SBATCH -J glue_submeso

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

# commands to be executed (change to suit your needs)

source ~/./python_venv.venv/bin/activate
./../gluemncbig -2 -o state.nc mnc_*/state.*.t*.nc
./../gluemncbig -2 -o diag_ocean.nc mnc_*/diag_ocean.*.t*.nc
./../gluemncbig -2 -o diag_tracers.nc mnc_*/ptracers.*.t*.nc
./../gluemncbig -2 -o diag_GM.nc mnc_*/diag_GM.*.t*.nc
./../gluemncbig -2 -o diag_GMlevel1.nc mnc_*/diag_GMlevel1.*.t*.nc
deactivate
