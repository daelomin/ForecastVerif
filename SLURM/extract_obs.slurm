#!/bin/bash
#SBATCH -n __NCORES__
##SBATCH --ntasks-per-node __NMPIPROCESS_PER_NODE__
##SBATCH -c __NOMP_PER_MPIPROCESS__
#SBATCH -p __QUEUE__
#SBATCH -J __JOBNAME__ 
#SBATCH -s


##  This SLURM job prepares the OBSERVATIONS extractions for 
#   the task of daily forecast verification

PYTHON_PATH=$PYTHON_PATH:$PWD/extract

DATELIST=__DATELIST__

OBSTYPE=__OBSTYPE__

case $OBSTYPE in 
    SYNOP)

        SCRIPT="extract_${OBSTYPE}.py"
        
    
    ;;
    TEMP)
    
        SCRIPT="extract_${OBSTYPE}.py"

    ;;
    *)
        echo "OBSTYPE is not defined. Cannot proceed. Aborting"
        exit 1
    ;;
esac


echo "using $SCRIPT to process datelist= $DATELIST"

sleep 2