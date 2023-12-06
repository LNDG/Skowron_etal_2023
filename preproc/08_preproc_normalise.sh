#!/bin/bash

# Register to MNI

source preproc_config.sh

# load FSL
FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh    
PATH=${FSLDIR}/bin:${PATH}       
export FSLDIR PATH

tmpnam /home/mpib/LNDG/fsl_temp/fsl

# PBS Log Info
CurrentPreproc="normalise"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error Log
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${Error_Log}

# Loop over participants, sessions (if they exist) & runs/conditions/tasks/etc
for SUB in ${SubjectID} ; do
	#echo "starting ${SUB}"			
		for RUN in ${RunID}; do
			
			FuncPath="${DataPath}/${SUB}/func/run${RUN}"
			FuncImage="${SUB}_run${RUN}_feat_detrended_highpassed_denoised.nii.gz"
			
			Func2MNI="${SUB}_run${RUN}_feat_detrended_highpassed_denoised_MNI.nii.gz"
			
			if [ -f ${FuncPath}/${Func2MNI} ]; then
				echo "${Func2MNI} already produced"
				continue
			elif [ -f ${FuncPath}/${FuncImage} ]; then
				
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
				
				echo "flirt -in ${FuncPath}/${FuncImage} -ref ${MNIImage} -applyxfm -init ${FuncPath}/FEAT.feat/reg/example_func2standard.mat -out ${FuncPath}/${Func2MNI}"			>> job # change fsl temp folder
				
				echo "if [ ! -f  ${FuncPath}/${Func2MNI} ]; then echo 'Normalisation failed: ${FuncImage}' >> ${Error_Log}; fi" >> job
				
				sbatch job
				rm job
				
			else
				echo "${FuncImage} not found"
				continue
			fi
			
		done
done