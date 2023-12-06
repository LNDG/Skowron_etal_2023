#!/bin/bash

source ../preproc_config.sh

# Training Set
SubjectID="${TestSetID}"

for SUB in ${SubjectID} ; do
	for RUN in ${RunID}; do
		
		# Name of functional image to be used.
		FuncImage="${SUB}_run${RUN}"												# Run specific functional image
		# Path to the functional image folder.
		FuncPath="${DataPath}/${SUB}/func/run${RUN}"	# Path for run specific functional image
		
		HLN_File="${FuncPath}/FEAT.feat/hand_labels_noise.txt"
		
		if [ ! -f ${HLN_File} ];then
			echo "HLN file missing for ${SUB} ${RUN}"
		fi
		
		if [ -f ${HLN_File} ] && [ $(cat -e ${HLN_File} | tail -c 2) != "$" ]; then
			rm ${HLN_File}
			#echo "adding new line to ${FuncImage}"
			#echo "" >> ${HLN_File}
		fi
		
		
	done
done