 #!/bin/bash

## FIX: hand_labels_file.txt creation
# FIX expects the ICA folders to be called 'filtered_func_data.ica', so either do this to rename all your folders appropriately or change all the scripts in FIX...

#TODO: User must first manually create the <subjID>_<run/condition>_rejcomps.txt files for all subjects in the Test Set. These text files must be locatedf in the ${ScriptsPath}/05_FIX/rejcomps directory.

source ../preproc_config.sh

# Training Set
SubjectID="${TestSetID}"

# Preprocessing suffix. This denotes the preprocessing stage of the data, that is to say, the preprocessing steps which have already been undertaken before generating ICA.ica folder.
InputStage="feat_detrended_highpassed"

# Error Log
CurrentPreproc="Create_Hand_Labels_Noise"
CurrentLog="${LogPath}/06_FIX"; if [ ! -d ${CurrentLog} ]; then mkdir ${CurrentLog}; chmod 770 ${CurrentLog}; fi
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${Error_Log}

# Loop over participants, sessions (if they exist) & runs
for SUB in ${SubjectID} ; do
	for RUN in ${RunID}; do
		
		# Name of functional image to be used.
		FuncImage="${SUB}_run${RUN}"													# Run specific functional image
		# Path to the functional image folder.
		FuncPath="${DataPath}/${SUB}/func/run${RUN}"		# Path for run specific functional image
									
		if [ ! -f ${FuncPath}/${FuncImage}_${InputStage}.nii.gz ]; then
			continue
		fi
		
		#if [ -f ${FuncPath}/FEAT.feat/hand_labels_noise.txt ]; then
		#	continue
		#fi
					
		if [ ! -f ${ScriptsPath}/06_FIX/rejcomps/${FuncImage}_rejcomps.txt ]; then
			echo "${ScriptsPath}/06_FIX/rejcomps/${FuncImage}_rejcomps.txt does not exist" >> ${Error_Log}
			continue
		fi
					
		# Create hand_labels_noise.txt file
		echo  "${SUB} ${RUN}: creating hand_labels_noise.txt"
		cd ${ScriptsPath}/06_FIX/rejcomps
		cp ${FuncImage}_rejcomps.txt ${FuncPath}/FEAT.feat/filtered_func_data.ica/hand_labels_noise.txt
					
		# Error Log
		if [ ! -f ${FuncPath}/FEAT.feat/filtered_func_data.ica/hand_labels_noise.txt ]; then
			echo "${FuncPath}/FEAT.feat/filtered_func_data.ica/hand_labels_noise.txt was not created" >> ${Error_Log}
		fi
		
		# Its much more straightforward to add brackets when creating the rejcompx text files...
		#cd ${FuncPath}/FEAT.feat
		#sed -i  '1s/^/[\n/' hand_labels_noise.txt
		#sed -i  's/n//g' hand_labels_noise.txt
	
		#chgrp -R lip-lndg ${FuncPath}/FEAT.feat/hand_labels_noise.txt
		chmod -R 770 ${FuncPath}/FEAT.feat/filtered_func_data.ica/hand_labels_noise.txt
		
	done
done