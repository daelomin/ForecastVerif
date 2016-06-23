#!/bin/bash
#SBATCH -n __NCORES__
##SBATCH --ntasks-per-node __NMPIPROCESS_PER_NODE__
##SBATCH -c __NOMP_PER_MPIPROCESS__
#SBATCH -p __QUEUE__
#SBATCH -J __JOBNAME__ 
#SBATCH -s


##  This SLURM job prepares the MODEL extractions for 
#   the task of daily forecast verification
 
PYTHON_PATH=$PYTHON_PATH:$PWD/extract 

DATELIST=__DATELIST__

MODEL=__MODEL__
GRID=__GRID__


echo "Extracting $MODEL over grid $GRID to process datelist= $DATELIST"

sleep 2