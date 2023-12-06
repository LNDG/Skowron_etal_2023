#!/bin/bash

## FIX: Feature Extraction

source ../preproc_config.sh

# Preprocessing suffix. This denotes the preprocessing stage of the data, that is to say, the preprocessing steps which have already been undertaken before generating ICA.ica folder.
InputStage="feat_detrended_highpassed"

# PBS Log Info
CurrentPreproc="Extract_Features"
CurrentLog="${LogPath}/06_FIX/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error Log
Error_Log="${LogPath}/06_FIX/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${Error_Log}

# Loop over participants, sessions (if they exist) & runs
for SUB in ${SubjectID} ; do
	for RUN in ${RunID}; do
		
		# Name of functional image to be used.
		FuncImage="${SUB}_run${RUN}"													# Run specific functional image
		# Path to the functional image folder.
		FuncPath="${DataPath}/${SUB}/func/run${RUN}"		# Path for run specific functional image
		
		if [ ! -f ${FuncPath}/${FuncImage}_${InputStage}.nii.gz ]; then
			continue
		elif [ -d ${FuncPath}/FEAT.feat/fix ]; then
			cd ${FuncPath}/FEAT.feat/fix
			Log=`grep "End of Matlab Script" logMatlab.txt | tail -1` # Get line containing our desired text output
			if [ ! "$Log" == "End of Matlab Script" ]; then
				echo "${SUB} ${RUN}: fix was incomplete, deleting and re-running"
				rm -rf ${FuncPath}/FEAT.feat/fix
			else
				continue
			fi
		fi
       
		cd ${FuncPath}/FEAT.feat
		if [ ! -f filtered_func_data.nii.gz ]; then
			echo "${SUB} ${RUN}: filtered_func_data.nii.gz missing" >> ${Error_Log}
			continue
		elif [ ! -d filtered_func_data.ica ]; then
			echo "${SUB} ${RUN}: filtered_func_data.ica missing" >> ${Error_Log}
			continue	
		elif [ ! -f mc/prefiltered_func_data_mcf.par ]; then
			echo "${SUB} ${RUN}: filtered_func_data.ica missing" >> ${Error_Log}
			continue
		elif [ ! -f mask.nii.gz ]; then
			echo "${SUB} ${RUN}: mask.nii.gz missing" >> ${Error_Log}
			continue
		elif [ ! -f mean_func.nii.gz ]; then
			echo "${SUB} ${RUN}: mean_func.nii.gz missing" >> ${Error_Log}
			continue
		elif [ ! -f reg/example_func.nii.gz ]; then
			echo "${SUB} ${RUN}: reg/example_func.nii.gz missing" >> ${Error_Log}
			continue
		elif [ ! -f reg/highres.nii.gz ]; then
			echo "${SUB} ${RUN}: reg/highres.nii.gz missing" >> ${Error_Log}
			continue
		elif [ ! -f reg/highres2example_func.mat ]; then
			echo "${SUB} ${RUN}: reg/highres2example_func.mat missing" >> ${Error_Log}
			continue
		elif [ ! -f design.fsf ]; then
			echo "${SUB} ${RUN}: design.fsf missing" >> ${Error_Log}
			continue																								
		fi
		
		# Gridwise
		echo "#!/bin/bash" 	>> job # Interpreter
		echo "#SBATCH --job-name ${CurrentPreproc}_${SUB}_run${RUN}" 	>> job # Job name 
		echo "#SBATCH --time 24:00:00" 						>> job # Time until job is killed 
		echo "#SBATCH --mem 4GB" 								>> job # Books 10gb RAM for the job 
		echo "#SBATCH --mail-type NONE" 										>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#SBATCH --output ${CurrentLog}/slurm-%j.out" 							>> job # Write output log to group log folder
		echo "#SBATCH --workdir ${WorkingDirectory}" 							>> job # working directory
		
		#echo "source /etc/fsl/5.0/fsl.sh"									>> job 	 # set fsl environment
		#echo "which fix"													>> job
		echo "module load fsl_fix" 											>> job
		
		# Initialize FSL 	
		echo "FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11"  >> job
		echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
		echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
		echo "export FSLDIR PATH"                               >> job
		
		echo "tmpnam /home/mpib/LNDG/fsl_temp/fsl" 						>> job # change fsl temp folder
		
		# Extract features for FIX; FEAT directories with all required files and folders have to be provided
		echo "cd ${FuncPath}"												>> job
		echo "fix -f ${FuncPath}/FEAT.feat" 								>> job 
       
		# Change group permissions for all documents created using this script
		echo "cd ${FuncPath}/FEAT.feat/" 									>> job
		#echo "chgrp -R lip-lndg ."  										>> job
		echo "chmod -R 770 ."  												>> job
       
		sbatch job 
		rm job
		
	done
done