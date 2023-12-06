#!/bin/bash

## Noise Component Rejection

# This will remove the components which have been selected manually for rejection.

source preproc_config.sh

FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11

OutputStage="denoised"

# Number of subjects in test set
Nsubjects=`echo ${TestSetID} | wc -w`

# PBS Log Info
CurrentPreproc="Denoise"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error Log
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${Error_Log}

## Create string with all FEAT directories
# Loop over participants, sessions (if they exist) & runs
for SUB in ${SubjectID} ; do
		for RUN in ${RunID}; do

			FuncImage="${SUB}_run${RUN}_feat_detrended_highpassed"
			
			# functional image path
			FuncPath="${DataPath}/${SUB}/func/run${RUN}"
			FuncName="${SUB}_run${RUN}"
			
			if [ ! -f ${FuncPath}/${FuncImage}.nii.gz ]; then
				echo "${FuncImage} not found"
				continue
			elif [ -f ${FuncPath}/${FuncImage}_${OutputStage}.nii.gz ]; then
				continue
			fi
			
			## Training set does not have to be explicitly indicated if verifying for the rejcomps file
			#cd ${ScriptsPath}/rejcomps
			#if [ ! -f ${FuncName}_rejcomps.txt ]; then
			#	echo "${FuncName}_rejcomps.txt does not exist" >> ${Error_Log}
			#	continue
			#fi
			#
			## Create hand_labels_noise.txt file
			#if [ -f ${FuncName}_rejcomps.txt ]; then
			#	echo  "${SUB} ${SESS} ${RUN}: creating hand_labels_noise.txt"
			#	cp ${FuncName}_rejcomps.txt ${FuncPath}/FEAT.feat/hand_labels_noise.txt
			#fi
			#
			#chmod -R 770 ${FuncPath}/FEAT.feat/hand_labels_noise.txt
			
			## Remove rejected components
			cd ${FuncPath}/FEAT.feat
			
			Training="hand_labels_noise.txt" # use manual labels if available
			if [ ! -f ${FuncPath}/FEAT.feat/${Training} ]; then
				Training="fix4melview_Training_${ProjectName}_N${Nsubjects}_thr${FixThreshold}.txt"
			fi
			
			Rejected=`cat ${Training} | tail -1`
			
			# Gridwise
			echo "#!/bin/bash" 	>> job # Interpreter
			echo "#SBATCH --job-name ${CurrentPreproc}_${SUB}_run${RUN}" 	>> job # Job name 
			echo "#SBATCH --time 1:00:00" 						>> job # Time until job is killed 
			echo "#SBATCH --mem 10GB" 								>> job # Books 10gb RAM for the job 
			echo "#SBATCH --mail-type NONE" 										>> job # Email notification on abort/end, use 'n' for no notification 
			echo "#SBATCH --output ${CurrentLog}/slurm-%j.out" 							>> job # Write output log to group log folder
			echo "#SBATCH --workdir ${WorkingDirectory}" 							>> job # working directory

			# Initialize FSL	
			echo "FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11"  >> job
			echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
			echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
			echo "export FSLDIR PATH"                               >> job
			
			echo "tmpnam /home/mpib/LNDG/fsl_temp/fsl" 						>> job # change fsl temp folder	
					
			# Variables for denoising
	
			Preproc="${FuncPath}/${FuncImage}.nii.gz"									# Preprocessed data image
			Denoised="${FuncPath}/${FuncImage}_${OutputStage}.nii.gz"								# Denoised image
			Melodic="${FuncPath}/FEAT.feat/filtered_func_data.ica/melodic_mix"						# Location of ICA generated Melodic Mix
			
																	# List of components to be removed
			
			# Run fsl_regfilt command
			echo "fsl_regfilt -i ${Preproc} -o ${Denoised} -d ${Melodic} -f \"${Rejected}\""  		>> job
			
			# Change permissions
			echo "chmod 770 ${Denoised}"  															>> job
			
			# Error Log
			echo "Difference=\`cmp ${Preproc} ${Denoised}\`" >> job
			echo "if [ -z \${Difference} ]; then echo 'Denoising did not change the preprocessing image: ${FuncImage}' >> ${Error_Log}; fi" >> job
			
			sbatch job
			rm job
			
		done
done
