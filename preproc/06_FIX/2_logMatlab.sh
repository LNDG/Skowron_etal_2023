#!/bin/bash

## FIX: Feature Extraction

source ../preproc_config.sh

# Preprocessing suffix. This denotes the preprocessing stage of the data, that is to say, the preprocessing steps which have already been undertaken before generating ICA.ica folder.
InputStage="feat_detrended_highpassed"

# Test
#SubjectID="EYEMEMtest"

# Error Log
CurrentPreproc="Log_Matlab"
CurrentLog="${LogPath}/06_FIX"; if [ ! -d ${CurrentLog} ]; then mkdir ${CurrentLog}; chmod 770 ${CurrentLog}; fi
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${Error_Log}

# Loop over participants, sessions (if they exist) & runs
for SUB in ${SubjectID} ; do
	for RUN in ${RunID}; do
		
		# Name of functional image to be used.
		FuncImage="${SUB}_run${RUN}"																# Run specific functional image
		# Path to the functional image folder.
		FuncPath="${DataPath}/${SUB}/func/run${RUN}"					# Path for run specific functional image
		
		if [ ! -f ${FuncPath}/${FuncImage}_${InputStage}.nii.gz ]; then
			continue
		fi
		
		# Verify Matlab log file
		
		cd ${FuncPath}/FEAT.feat/fix
		Log=`grep "End of Matlab Script" logMatlab.txt | tail -1` # Get line containing our desired text output
		
		if [ ! -d ${FuncPath}/FEAT.feat/fix ]; then
			echo "${SUB} ${RUN}: missing fix folder" >> ${Error_Log}
			continue
		elif [ ! "$Log" == "End of Matlab Script" ]; then
			echo "${SUB} ${RUN}: fix did not terminate properly" >> ${Error_Log}
		fi

	done
done