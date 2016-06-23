#!/bin/bash
#
# This script does stuff
# 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                                                             #
#   AUTHOR: REMI MONTROTY                                   Jun 17   2016     #
#                                                                             #
#   VERSION :	
#	* v1.0.1: 20160623						      # 
#		-	Add: INDS0250, INDS0100 & all correct BBOXes				      #
#	* v1.0.0: 20160617						      # 
#		-	Init: empty skeleton with the following modes:
#           FRMAX_MODE
#           RUN_MODE
#           INT_MODE
#       - RAF: manage BBOX & actual SLURM tasks						      #
#									      #
#   TODO / IMPROVE:						  	      #
#                                                                             #
#                                                                             #
#   Example:                                                                  #
#                                                                             #
#  script.sh $arg1 $arg2                                        	      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


SLURMDIR=$PWD/SLURM


function get_jobid() {

	logfile=$1
	ID=`cat $logfile |grep job|awk '{print $4}'`
	echo $ID

}


function set_model_options() {

    let model_counter=model_counter+1
	
	MODELGRID=$1
    idx=$2
	
	MODEL=`echo $MODELGRID | cut -d "-" -f 1`
	GRID=`echo $MODELGRID | cut -d "-" -f 2`
	
	case $GRID in
		JAVA0030)	 
			BBOX="-9.3 105.2 -4.56 117.2"
			RESOLUTION="0.03"
			FRMAX="72"
			FRINT="1"
			FRLIST_FULL=`seq 0 $FRINT $FRMAX`
		;;
		SEA0300)	 
			BBOX="-25.0 70.0 25.0 170.0"
			RESOLUTION="0.3"
			FRMAX="120"
			FRINT="3"
			FRLIST_FULL=`seq 0 $FRINT $FRMAX`
		;;
		INDX0100)	 
			BBOX="-16.2 90.0 15.5 150.0"
			RESOLUTION="0.1"
			FRMAX="120"
			FRINT="1"
			FRLIST_FULL=`seq 0 $FRINT $FRMAX`
		;;
 		INDS0250)	 
            # LAT_S LON_W LAT_N LAT_E
			BBOX="-15.0 95.0 15.0 150.0"
			RESOLUTION="0.25"
			FRMAX="72"
			FRINT="3"
			FRLIST_FULL=`seq 0 $FRINT $FRMAX`
		;;        
 		INDS0100)	 
            # LAT_S LON_W LAT_N LAT_E
			BBOX="-15.0 95.0 15.0 150.0"
			RESOLUTION="0.1"
			FRMAX="72"
			FRINT="3"
			FRLIST_FULL=`seq 0 $FRINT $FRMAX`
		;;          
 		INDX0110)	 
			BBOX="-30.0 80.0 17.0 160.0"
			RESOLUTION="0.11"
			FRMAX="144"
			FRINT="3"
			FRLIST_FULL=`seq 0 $FRINT $FRMAX`
		;;       
		SEA0125)	 
			#BBOX="-10.0 105.0 -4.0 120.0"
			BBOX="-25.0 70.0 -40.0 170.0"      
			RESOLUTION="0.125"
			FRMAX="192"
			FRINT="3"
			FRLIST_FULL=`seq 0 $FRINT $FRMAX`
		;;
 		SEA0500)	 
            # LAT_S LON_W LAT_N LAT_E
			BBOX="-25.0 70.0 40.0 170.0"
			RESOLUTION="0.5"
			FRMAX="72"
			FRINT="3"
			FRLIST_FULL=`seq 0 $FRINT $FRMAX`
		;;     
 		GLOB0500)	 
			BBOX="-90.0 -180.0 90.0 180.0"
			#BBOX="-90.0 0.0 90.0 360.0"
            RESOLUTION="0.5"
			FRMAX="192"
			FRINT="3"
			FRLIST_FULL=`seq 0 $FRINT $FRMAX`
		;;           
		*)
			echo "GRID $GRID undefined! Abort"
			exit 1
		;;        
	esac
	
	case $DOMAIN_MODE in
		SAME)
			echo "Using the same specified domain $DOMAIN_SPECIFIED"
            
		;;
		OWN)
			echo "Model${model_counter} $MODEL is using his own domain/grid $GRID"
		;;
		INTERSECT)
			echo "Model${model_counter} $MODEL is using the common intersection of both domains"
            OPT_BBOX[$idx]=$BBOX
		;;
		*)
			echo "Missing a DOMAIN_MODE variable. Abort"
			exit 1
		;;
	esac
	
	case $FRMAX_MODE in
		OWN)
			echo "Model${model_counter} $MODEL is using his FRMAX $FRMAX"
            OPT_FRMAX[$idx]=$FRMAX
           
		;;
		LOWEST_FRMAX)
			echo "Model${model_counter} $MODEL is using the lowest FRMAX"
            ## fill the OPT array first, since we need to run min after
            OPT_FRMAX[$idx]=$FRMAX
		;;
        *)
			echo "Missing a FRMAX_MODE variable. Abort"
			exit 1
		;;
	esac
    
	case $INT_MODE in
		SAME_INTERVAL)
			echo "Using the common FR interval= $COMMON_INTERVAL"
            OPT_INT[$idx]=$COMMON_INTERVAL
            ;;
		OWN)
			echo "Model${model_counter} $MODEL is using its own INTERVAL"
            OPT_INT[$idx]=$FRINT
		;;
		COMMON_HIGHEST)
			echo "Model${model_counter} $MODEL is using the max(INT1,INT2)"
            OPT_INT[$idx]=$FRINT
		;;
        *)
			echo "Missing a INT_MODE variable. Abort"
			exit 1
		;;        
	esac
		
	
	
	case ${MODEL} in
		PWRFDY|PECMWF|PGFSUS)
            OPT_RUNS[$idx]="00 12"
        	echo "Model${model_counter} $MODEL is using its own RUNS ${OPT_RUNS[$idx]}"     
            ;;
		PARPEGE|PWRFDA|PACCESSR)
            OPT_RUNS[$idx]="00 06 12 18"        
        	echo "Model${model_counter} $MODEL is using its own RUNS ${OPT_RUNS[$idx]}"     
            
		;;
        *)
			echo "Missing MODEL variable. Abort"
			exit 1
		;;              
	esac

	
}
min_number() {
    printf "%s\n" "$@" | sort -g | head -n1
}
max_number() {
    printf "%s\n" "$@" | sort -g | tail -n1
}

function select_final_frlist() {


    case $FRMAX_MODE in 
        LOWEST_FRMAX)
            FRMAX1=`min_number ${OPT_FRMAX[*]}`
            FRMAX2=`min_number ${OPT_FRMAX[*]}`
            ;;
        OWN)
            FRMAX1=`echo ${OPT_FRMAX[$idx1]}`
            FRMAX2=`echo ${OPT_FRMAX[$idx2]}`
           ;;       
        *)
			echo "Missing a FRMAX_MODE variable. Abort"
			exit 1
		;;           
    esac
    
    case $INT_MODE in 
        COMMON_HIGHEST)
            INT1=`max_number ${OPT_INT[*]}`
            INT2=`max_number ${OPT_INT[*]}`
            ;;
        OWN)
            INT1=`echo ${OPT_INT[$idx1]}`
            INT2=`echo ${OPT_INT[$idx2]}`
           ;;       
        SAME_INTERVAL)
            INT1=$COMMON_INTERVAL
            INT2=$COMMON_INTERVAL
           ;;   
        *)
			echo "Missing a INT_MODE variable. Abort"
			exit 1
		;;                   
    esac


    FRLIST1=`seq 0 $INT1 $FRMAX1`
    FRLIST2=`seq 0 $INT2 $FRMAX2`

    if [ "$FORCE_COMMON_FRLIST" == "YES" ]; then
    
      
        ## Put double quotes to preserve the line returns when dropping to file
        #  keep "| sort" so that comm -12 finds them in 'correct' order
        echo "$FRLIST1" |sort  > frlist1
        echo "$FRLIST2" |sort  > frlist2
        ## Find the intersection 
        FRLIST_INTERSECT=`comm -12 frlist1 frlist2 |sort -g`
        rm -f frlist1 frlist2
        
        echo "- Settings : Due to FORCE_COMMON_FRLIST=YES, override to the intersection of both"
        
        
        FRLIST1=$FRLIST_INTERSECT
        FRLIST2=$FRLIST_INTERSECT
    fi
    echo "FRLIST1="$FRLIST1
    echo "FRLIST2="$FRLIST2

}

function print_choices() {

    CHOICES_LEN=${#MODELGRID_LIST[*]}

    echo "Available Models to compare:"
    echo " "
    let CLEN=CHOICES_LEN-1
    for i in  `seq 0 $CLEN`; do 
        echo "$i - ${MODELGRID_LIST[$i]}"; 
    done

}

function select_runs() {


    case $RUN_MODE in 
        ALL_RUNS)
            RUNS1=${OPT_RUNS[$idx1]}
            RUNS2=${OPT_RUNS[$idx2]}
            if [ "$RUNS1" == "00 06 12 18" ] && [ "$RUNS2" == "00 06 12 18" ]; then 
                RUNS_INTERVAL="06"
            else   
                RUNS_INTERVAL="12"
            
            fi
            ;;
        COMMON_RUNS)
            echo "- Settings : Due to RUN_MODE=$RUN_MODE, Models are using the common runs "
            #RUNS1="00 12"
            #RUNS2="00 12"
            
            RUNS1=${OPT_RUNS[$idx1]}
            RUNS2=${OPT_RUNS[$idx2]}
            if [ "$RUNS1" == "$RUNS2" ]; then 
                echo "Using same runs for both models : $RUNS1"
                if [ "$RUNS1" == "00 06 12 18" ] ; then 
                    RUNS_INTERVAL="06"
                else   
                    RUNS_INTERVAL="12"
                fi
                            
                
            else   
                echo "Discrepancies exist between RUNS1 & RUNS2. Forcing to 00 12"
                RUNS1="00 12"
                RUNS_INTERVAL="12"
                
            
            fi
            
           ;;       
        *)
			echo "Missing a RUN_MODE variable. Abort"
			exit 1
		;;           
    esac
    
    echo "Preparing to extract for the following runs:"
    echo ""
    echo "Model1 : runs $RUNS1"
    echo "Model2 : runs $RUNS2"
    
    
 }
 
 function set_datelist() {
 
    set +x
    MAX_FORECAST_RANGE=$1
 
    if [ -z "$DMT_DATE_PIVOT" ];then    
        DMT_DATE_PIVOT=`date -u +"%Y%m%d"`
    fi
    START=$DMT_DATE_PIVOT
    YYYYMMDD=${START:0:8}
    #ONEMONTH=`/bin/date -d "$YYYYMMDD 30 day ago" +%Y%m%d`
    #/common/bin/gen_datelist.bash $ONEMONTH $YYYYMMDD 12 hours

    OLDEST_DAY=`/bin/date -d "$YYYYMMDD $MAX_FORECAST_RANGE hours ago" +%Y%m%d`
    
    ## RUNS_INTERVAL comes from select_runs while MAX_FORECAST_RANGE comes from select_final_frlist
    if [ -z "$RUNS_INTERVAL" ]; then    
        echo "RUNS_INTERVAL not set... aborting"
        exit 10
    fi
    
    EXTRACTION_DATELIST=`/common/bin/gen_datelist.bash $OLDEST_DAY $YYYYMMDD $RUNS_INTERVAL hours`
    
    echo ""
    echo "Extracting until $MAX_FORECAST_RANGE hours ago, on those dates:"
    echo $EXTRACTION_DATELIST
 }
 
######################################################################
#				MAIN



##################################
## General definitions
COMMON_INTERVAL="3"
INT_MODE="OWN"
INT_MODE="COMMON_HIGHEST"
INT_MODE="SAME_INTERVAL"

FRMAX_MODE="SAME_FRMAX"
FRMAX_MODE="LOWEST_FRMAX"
FRMAX_MODE="OWN"

RUN_MODE="ALL_RUNS"
RUN_MODE="COMMON_RUNS"


## Independently of separate choices, you may
#  over-ride the final FR list via this variable:
FORCE_COMMON_FRLIST="NO"
FORCE_COMMON_FRLIST="YES"

DOMAIN_MODE="OWN"

declare -a MODELGRID_LIST=(PACCESSR-INDX0110 PWRFDY-JAVA0030 PWRFDY-INDX0100 \
PWRFDY-SEA0300 PWRFDA-JAVA0030 PWRFDA-INDX0100 PWRFDA-SEA0300 PECMWF-SEA0125 \
PGFSUS-GLOB0500 PARPEGE-SEA0500 )



model_counter=0

# end of definitions
########################################"


###################### Start the code:

#~~
print_choices

echo "Choose Model1 from 0 to $CLEN:"
read idx1
echo "Choose Model2 from 0 to $CLEN:"
read idx2


MODELGRID1=`eval echo ${MODELGRID_LIST[$idx1]}`
MODELGRID2=`eval echo ${MODELGRID_LIST[$idx2]}`


set -x
set +x



#~~
set_model_options $MODELGRID1 $idx1
set_model_options $MODELGRID2 $idx2

#~~ 
select_final_frlist

#~~
select_runs

#~~ 
if [ $FRMAX1 -ne $FRMAX2 ]; then    
    FRMAX=`min_number $FRMAX1 $FRMAX2`
else
    FRMAX=$FRMAX1
fi
set_datelist $FRMAX



exit 0

## Start with OBS
sbatch $SLURMDIR/model1_extract.slurm > obs.slurmjobid
OBS_JOBID=`get_jobid obs.slurmjobid `



### Loop over domains
sbatch --dependency=after:$OBS_EXTRACT $SLURMDIR/model1_extract.slurm > m1ext.slurmjobid
M1EXT_JOBID=`get_jobid m1ext.slurmjobid`




sbatch --dependency=after:$OBS_EXTRACT $SLURMDIR/model2_extract.slurm > m2ext.slurmjobid
M2EXT_JOBID=`get_jobid m2ext.slurmjobid`






sbatch --dependency=after:$WRF_JOBID wrf_watcher.slurm > wrf_watcher.slurmjobid
