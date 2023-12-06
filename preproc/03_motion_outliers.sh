source preproc_config.sh

FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11

# PBS Log Info
CurrentPreproc="mo_out"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error log
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${CurrentLog}

# Loop over participants, sessions (if they exist) & runs/conditions/tasks/etc
for SUB in ${SubjectID} ; do			
		for RUN in ${RunID}; do
			
			# Name of functional image to be used.
			FuncImage="${SUB}_run${RUN}"
			
			# Path to the original functional image folder.
			OriginalPath="${DataPath}/${SUB}/func/run${RUN}"
			
			# Path to the pipeline specific folder.
			FuncPath="${DataPath}/${SUB}/func/run${RUN}"
				
			if [ ! -f ${OriginalPath}/${FuncImage}.nii.gz ]; then
				continue
			elif [ -f ${FuncPath}/motionout/${SUB}_motionout.txt ]; then
				continue
			fi
			
			# Create output path for motion outlier detection
			if [ ! -d ${FuncPath}/motionout ]; then mkdir -p ${FuncPath}/motionout; fi
			
			# Gridwise
			echo "#!/bin/bash" 	>> job # Interpreter
			echo "#SBATCH --job-name ${CurrentPreproc}_${SUB}_run${RUN}" 	>> job # Job name 
			echo "#SBATCH --time 12:00:00" 						>> job # Time until job is killed 
			echo "#SBATCH --mem 8GB" 								>> job # Books 10gb RAM for the job 
			echo "#SBATCH --mail-type NONE" 										>> job # Email notification on abort/end, use 'n' for no notification 
			echo "#SBATCH --output ${CurrentLog}/slurm-%j.out" 							>> job # Write output log to group log folder
			echo "#SBATCH --workdir ${WorkingDirectory}" 							>> job # working directory 

			#echo ". /etc/fsl/5.0/fsl.sh"										>> job # Set fsl environment 	
			echo "FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11"  >> job
			echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
			echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
			echo "export FSLDIR PATH"                               >> job
			
			echo "tmpnam /home/mpib/LNDG/fsl_temp/fsl" 						>> job # change fsl temp folder
			
			echo "cd ${FuncPath}"           												>> job

			# Run motion outlier detection
			echo "fsl_motion_outliers -i ${OriginalPath}/${FuncImage} -o ${FuncPath}/motionout/${SUB}_motionout.txt -s ${FuncPath}/motionout/${SUB}_${MoutMetric}.txt -p ${FuncPath}/motionout/${SUB}_${MoutMetric}_plot.png --${MoutMetric} --dummy=${DeleteVolumes} -v >> ${FuncPath}/motionout/report.txt" >> job
			
			# Error log
			echo "if [ ! -f ${FuncPath}/motionout/${SUB}_motionout.txt ];"  		>> job
			echo "then echo 'Error in ${FuncImage}' >> ${Error_Log}; fi"				>> job
			
			sbatch job
			rm job
			
			sleep 3
			
		done
done