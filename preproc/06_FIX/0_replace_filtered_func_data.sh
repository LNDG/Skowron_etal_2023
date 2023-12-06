#!/bin/bash

## FIX: File Preparation

# Rename the original filtered_func_data.nii.gz image and replace it with the preprocessed data. Will also attempt to take reg folder from FEAT+.feat if the default reg folder doesn't contain a highres image (necessary input for FIX).
source ../preproc_config.sh

# Preprocessing suffix. This denotes the preprocessing stage of the data, that is to say, the preprocessing steps which have already been undertaken before generating ICA.ica folder.
InputStage="feat_detrended_highpassed"

# Error Log
CurrentPreproc="Replace_Data"
CurrentLog="${LogPath}/06_FIX"; if [ ! -d ${CurrentLog} ]; then mkdir ${CurrentLog}; chmod 770 ${CurrentLog}; fi
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${Error_Log}

# Loop over participants, sessions (if they exist) & runs
for SUB in ${SubjectID} ; do
	for RUN in ${RunID}; do
		
		# Name of functional image to be used.
		FuncImage="${SUB}_run${RUN}"											# Run specific functional image
		# Path to the functional image folder.
		FuncPath="${DataPath}/${SUB}/func/run${RUN}"	# Path for run specific functional image
		
		if [ ! -f ${FuncPath}/${FuncImage}_${InputStage}.nii.gz ]; then
			continue
		fi

		# Copy and rename files
		if [ ! -f ${FuncPath}/FEAT.feat/ORIGINAL_filtered_func_data.nii.gz ]; then
			mv ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz ${FuncPath}/FEAT.feat/ORIGINAL_filtered_func_data.nii.gz
		fi
		if [ ! -f ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz ]; then
			cp ${FuncPath}/${FuncImage}_${InputStage}.nii.gz ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz
		fi
		if [ ! -f ${FuncPath}/FEAT.feat/reg/highres.nii.gz ]; then
			mv ${FuncPath}/FEAT.feat/reg ${FuncPath}/FEAT.feat/ORIGINAL_reg 
		fi
		if [ ! -d ${FuncPath}/FEAT.feat/reg ]; then
			cp -r ${FuncPath}/FEAT+.feat/reg ${FuncPath}/FEAT.feat/reg 
		fi
		
		# Error Log
		if [ ! -d ${FuncPath}/FEAT.feat/reg ]; then
			echo "${FuncImage} reg is missing" >> ${Error_Log}
		fi
		if [ ! -f ${FuncPath}/FEAT.feat/ORIGINAL_filtered_func_data.nii.gz ]; then
			echo "${FuncImage} ORIGINAL_filtered_func_data file is missing." >> ${Error_Log}
		elif [ ! -f ${FuncPath}/FEAT.feat/ORIGINAL_filtered_func_data.nii.gz ]; then
			echo "${FuncImage} filtered_func_data file is missing." >> ${Error_Log}
		fi
		
		#chgrp -R lip-lndg ${FuncPath}/FEAT.feat/	
		#chmod -R 770 ${FuncPath}/FEAT.feat/	
		
	done
done