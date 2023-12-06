#!/bin/bash

# 180124 JQK: added check for availability of hand_labels_noise.txt

## FIX: Training Data creation
# Create Training.Rdata from Training Set (subjects must already have hand_labels_noise.txt in their FEAT directories)

source ../preproc_config.sh

# Preprocessing suffix. This denotes the preprocessing stage of the data, that is to say, the preprocessing steps which have already been undertaken before generating ICA.ica folder.
InputStage="feat_detrended_highpassed"

# Training Set
SubjectID="${TestSetID}"

# String with all FEAT folders
TrainingSet=""

# Error Log
CurrentPreproc="Create_Training_Data"
CurrentLog="${LogPath}/06_FIX"; if [ ! -d ${CurrentLog} ]; then mkdir ${CurrentLog}; chmod 770 ${CurrentLog}; fi
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${Error_Log}

## Create string with all FEAT directories
# Loop over participants, sessions (if they exist) & runs
for SUB in ${SubjectID} ; do
	for RUN in ${RunID}; do
		
		# Name of functional image to be used.
		FuncImage="${SUB}_run${RUN}"												# Run specific functional image
		# Path to the functional image folder.
		FuncPath="${DataPath}/${SUB}/func/run${RUN}"	# Path for run specific functional image
		
		if [ ! -f ${FuncPath}/${FuncImage}_${InputStage}.nii.gz ]; then
			echo "${FuncImage}_${InputStage}.nii.gz does not exist. Process will fail when attempting to create Rdata." >> ${Error_Log}
			continue
		fi
		
		if [ ! -f ${FuncPath}/FEAT.feat/hand_labels_noise.txt ]; then
			echo "hand_labels_noise.txt does not exist. Skipping this run/subject. Please CHECK!" >> ${Error_Log}
			continue
		fi
		
		FeatPath="${FuncPath}/FEAT.feat"
		
		TrainingSet="${TrainingSet}${FeatPath} "
		#TrainingSet="${FeatPath}"
		
	done
done

## Initialize FIX
#source /etc/fsl/5.0/fsl.sh
#module load fsl_fix
#
## Location where Training.Rdata file will be saved
#cd ${ScriptsPath}/05_FIX
#
## Create Training file
#echo "Creating Training_${ProjectName}_N${Nsubjects}"
#fix -t Training_${ProjectName}_N${Nsubjects} -l ${TrainingSet}

#####echo "#PBS -N ${CurrentPreproc}_TrainingSet" 						>> job # job name 
#####echo "#PBS -l walltime=1:00:00" 									>> job # time until job is killed 
#####echo "#PBS -l mem=8gb" 												>> job # books 4gb RAM for the job 
######echo "#PBS -m ae" 													>> job # email notification on abort/end   -n no notification 
#####echo "#PBS -o ${CurrentLog}" 										>> job # write (error) log to group log folder 
#####echo "#PBS -e ${CurrentLog}" 										>> job 
#####
#####
###### Initialize FSL
######echo ". /etc/fsl/5.0/fsl.sh"								>> job # Set fsl environment 	
#####
#####FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
#####echo "FSLDIR=${FSLDIR}"  								>> job
#####echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
#####echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
#####echo "export FSLDIR PATH"                               >> job
#####
#####echo "module load fsl_fix" 											>> job
###### Run Training Set
#####echo "cd ${ScriptsPath}/05_FIX" 									>> job
#####echo "fix -t Training_${ProjectName}_N${Nsubjects} ${TrainingSet}" 								>> job 
#####
###### Change group permissions for all documents created using this script
######echo "chgrp -R lip-lndg ."  										>> job
#####echo "chmod -R 770 ."  												>> job
#####
#####qsub job  
#####rm job

# Number of subjects
Nsubjects=`echo $SubjectID | wc -w`

# Initialize FSL
#echo ". /etc/fsl/5.0/fsl.sh"								>> job # Set fsl environment 	

FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH

#module load R/4.2.0
module load fsl_fix

# Run Training Set
cd ${ScriptsPath}/06_FIX
echo "${TrainingSet}"
fix -t Training_${ProjectName}_N${Nsubjects} ${TrainingSet}

# Change group permissions for all documents created using this script
#echo "chgrp -R lip-lndg ."  										>> job
chmod -R 770 .
