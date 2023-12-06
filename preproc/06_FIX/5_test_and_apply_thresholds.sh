#!/bin/bash

## FIX: Test & Apply Thresholding Values
# Apply cleanup with certain threshold on your Test Set; can be run locally (doesn't need much time)
# Threshold: the higher, the more components will be rejected; recommended: 20; we have used 50-60 

source ../preproc_config.sh

# IDs for testing
# SubjectID="ENT3022 ENT3023 ENT3024"

# Preprocessing suffix. This denotes the preprocessing stage of the data, that is to say, the preprocessing steps which have already been undertaken before generating ICA.ica folder.
InputStage="feat_detrended_highpassed"

# Set to N when threshold has laready been set in the configuration file 
Evaluation="N"

# Test
#SubjectID="EYEMEMtest"

# Evaluation Subjects
	# EX: SubjectID="SUB001 SUB002"
#SubjectID="1219 1265 1131"; Evaluation="Y"

# Number of subjects in test set
Nsubjects=`echo ${TestSetID} | wc -w`

# PBS Log Info
CurrentPreproc="Apply_Threshold"
CurrentLog="${LogPath}/06_FIX/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error Log
Error_Log="${LogPath}/06_FIX/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${Error_Log}

## Create string with all FEAT directories
# Loop over participants, sessions (if they exist) & runs
for SUB in ${SubjectID} ; do
	
	# Gridwise
	echo "#!/bin/bash" 	>> job # Interpreter
	echo "#SBATCH --job-name ${CurrentPreproc}_${SUB}_run${RUN}" 	>> job # Job name 
	echo "#SBATCH --time 1:00:00" 						>> job # Time until job is killed 
	echo "#SBATCH --mem 2GB" 								>> job # Books 10gb RAM for the job 
	echo "#SBATCH --mail-type NONE" 										>> job # Email notification on abort/end, use 'n' for no notification 
	echo "#SBATCH --output ${CurrentLog}/slurm-%j.out" 							>> job # Write output log to group log folder
	echo "#SBATCH --workdir ${WorkingDirectory}" 							>> job # working directory
	
	
	#echo "source /etc/fsl/5.0/fsl.sh" 						>> job
	echo "module load fsl_fix" 								>> job
	
	# Initialize FIX
	FSLDIR="/home/mpib/LNDG/FSL/fsl-5.0.11"
	echo "FSLDIR=${FSLDIR}" 								>> job
	echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
	echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
	echo "export FSLDIR PATH"                               >> job
	
	echo "tmpnam /home/mpib/LNDG/fsl_temp/fsl" 						>> job # change fsl temp folder

	for RUN in ${RunID}; do
		
		# Name of functional image to be used.
		FuncImage="${SUB}_run${RUN}"												# Run specific functional image
		# Path to the functional image folder.
		FuncPath="${DataPath}/${SUB}/func/run${RUN}"	# Path for run specific functional image
		
		if [ ! -f ${FuncPath}/${FuncImage}_${InputStage}.nii.gz ]; then
			continue
		fi

		# Test Thresholds
		Training_Object="${ScriptsPath}/06_FIX/Training_${ProjectName}_N${Nsubjects}.RData"
		Training_File="fix4melview_Training_${ProjectName}_N${Nsubjects}_thr${FixThreshold}.txt"
		if [ ${Evaluation} = "Y" ]; then 
			
			# Output: txt-file (fix4melview_Training_thr##.txt) with names of noise components
			# TODO: Once a satisfactory threshold has been determined, set the FixThreshold variable in the configuration file.
			# TODO: Make sure to comment out the Evaluation Subjects when applying threhold.
			
			echo "fix -c ${FuncPath}/FEAT.feat ${Training_Object} 20" >> job
			echo "fix -c ${FuncPath}/FEAT.feat ${Training_Object} 30" >> job
			echo "fix -c ${FuncPath}/FEAT.feat ${Training_Object} 40" >> job
			echo "fix -c ${FuncPath}/FEAT.feat ${Training_Object} 50" >> job
			echo "fix -c ${FuncPath}/FEAT.feat ${Training_Object} 60" >> job
			echo "fix -c ${FuncPath}/FEAT.feat ${Training_Object} 70" >> job
			
		# Apply Threshold
		else 
			echo "fix -c ${FuncPath}/FEAT.feat ${Training_Object} ${FixThreshold}" 					>> job
			# Error Log
			echo "if [ ! -f ${FuncPath}/FEAT.feat/${Training_File} ];" 								>> job
			echo "then echo '${FuncImage}: ${Training_File} does not exist' >> ${Error_Log}; fi " 	>> job

		fi
		
	done
	
	sbatch job
	rm job
	
done
