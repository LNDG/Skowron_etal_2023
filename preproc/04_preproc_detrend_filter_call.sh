#!/bin/bash

## Compiled Matlab matlab_master_do

source preproc_config.sh

# load FSL

FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh      
PATH=${FSLDIR}/bin:${PATH}         
export FSLDIR PATH

# Preprocessing suffix. Denotes the preprocessing stage of the data.
InputStage="feat" 		# Before doing steps on matlab
OutputStage="feat_detrended_highpassed" 		# After running Detrend & Filtering

# PBS Log Info
CurrentPreproc="Detrend_Filt"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error log
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${CurrentLog}

# Loop over participants, sessions (if they exist) & runs/conditions/tasks/etc
for SUB in ${SubjectID} ; do			
		for RUN in ${RunID}; do
			
			# Name of functional image.
			FuncImage="${SUB}_run${RUN}"
			
			# Path to the pipeline specific folder.
			FuncPath="${DataPath}/${SUB}/func/run${RUN}"
			
			if [ ! -f ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz ]; then
				echo "no filtered_func_data file found for ${FuncImage}"
				continue
			elif [ -f ${FuncPath}/${FuncImage}_${OutputStage}.nii.gz ] && [ ! -f ${FuncPath}/${FuncImage}_${InputStage}_detrended.nii.gz ] ; then
					continue
			fi
			
			# Gridwise
			echo "#!/bin/bash" 	>> job # Interpreter
			echo "#SBATCH --job-name ${CurrentPreproc}_${SUB}_run${RUN}" 	>> job # Job name 
			echo "#SBATCH --time 4:00:00" 						>> job # Time until job is killed 
			echo "#SBATCH --mem 6GB" 								>> job # Books 10gb RAM for the job 
			echo "#SBATCH --mail-type NONE" 										>> job # Email notification on abort/end, use 'n' for no notification 
			echo "#SBATCH --output ${CurrentLog}/slurm-%j.out" 							>> job # Write output log to group log folder
			echo "#SBATCH --workdir ${WorkingDirectory}" 							>> job # working directory
            
			echo "cd ${ScriptsPath}"	 							>> job
			
			# Inputs must be given in the correct order: 
				# FuncPath, FuncImage, PolyOrder, TR, HighpassFilterLowCutoff, LowpassFilterHighCutoff, FilterOrder
			echo -n "./run_preproc_detrend_filter_excecute.sh /opt/matlab/R2017b/ " 															>> job 
			echo "${FuncPath} ${FuncImage}_${InputStage} ${PolyOrder} ${TR} ${HighpassFilterLowCutoff} ${LowpassFilterHighCutoff} ${FilterOrder}" 	>> job  
			
			# Cleanup
			echo "if [ -f ${FuncPath}/${FuncImage}_${OutputStage}.nii.gz ];" 					>> job
			echo "then rm -rf ${FuncPath}/${FuncImage}_${InputStage}_detrended.nii.gz; fi" 		>> job
			
			# Error Log
			echo "if [ ! -f ${FuncPath}/${FuncImage}_${OutputStage}.nii.gz ];" 					>> job
			echo "then echo 'Error in ${FuncImage}' >> ${Error_Log}; fi"						>> job 
			
			sbatch job
			rm job
			
			sleep 3
			
		done
done