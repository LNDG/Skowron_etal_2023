#!/bin/bash

# FEAT: Smoothing and Motion Correction

# NOTE1: This uses a template file which already has 'dummyCode' specified for the variables which will be replaced with the appropriate study/subject/session/run information.

# NOTE 2: The template specifies the anatomical image (which should already be Brain Extracted) for registration. This will not perform the registration, only create registration matrices which are necesarry for the Automated Denoising procedure (FIX).

# NOTE 3: The Nifti Toolbox might require you to reslice images, thus altering their dimensions. The files that FIX requires must be of the same size as the registration matrices produced by FEAT. For this reason, one must VERIFY beforehand if the files will require reslicing in order to perform it before FEAT. Currently (19.06.17), all processes that require the Nifti toolbox operare with load_untouch_nii and save_untouch_nii, thus rendering this point moot, but this might change in the future.

source preproc_config.sh

# load FSL

#module load fsl/5.0

FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh    
PATH=${FSLDIR}/bin:${PATH}       
export FSLDIR PATH
                  
# PBS Log Info
CurrentPreproc="FEAT"
CurrentLog="${LogPath}/${CurrentPreproc}"
if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error log
Error_Log="${CurrentLog}/${CurrentPreproc}_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${CurrentLog}

# Loop over participants, sessions (if they exist) & runs/conditions/tasks/etc
for SUB in ${SubjectID} ; do			
		for RUN in ${RunID}; do
			
			# Path to the original functional image folder.
			OriginalPath="${DataPath}/${SUB}/func/run${RUN}"
			
			# Name of functional image to be used.
			FuncImage="${SUB}_run${RUN}"
			
			# Path to the anatomical image
			AnatPath="${DataPath}/${SUB}/anat/ANTs" # bet
			
			# Name of brain extracted anatomical and functional image to be used.
			#AnatImage="${SUB}_T1w" # non-bet
			AnatImage="${SUB}_anat_brain" # bet
			
			# Path to the pipeline specific folder.
			FuncPath="${DataPath}/${SUB}/func/run${RUN}"
			
			if [ ! -f ${OriginalPath}/${FuncImage}.nii.gz ]; then
				echo "No functional image found for ${SUB} run-${RUN}"
				continue
			elif [ ! -f ${AnatPath}/${AnatImage}.nii.gz ]; then
				echo "Anatomical image for ${SUB} not found: ${AnatPath}/${AnatImage}.nii.gz does not exist, FEAT was halted" >> ${Error_Log}
				continue
			elif [ -d ${FuncPath}/FEAT.feat ]; then
				if [ -d ${FuncPath}/FEAT+.feat ]; then
					rm -rf ${FuncPath}/FEAT+.feat
				fi
				if [ -f ${FuncPath}/FEAT.feat/prefiltered_func_data.nii.gz ]; then
					rm -rf ${FuncPath}/FEAT.feat
				elif [ ! -f ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz ]; then
					rm -rf ${FuncPath}/FEAT.feat
				elif [ -f ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz ]; then
					continue
				fi
			fi
			
			# Create run specific directory for preprocessing images and files
			if [ ! -d ${FuncPath} ]; then mkdir -p ${FuncPath}; fi
			
			# Roundabout way for getting Volumes & Effective echo spacing
			TotalVolumes=`fslinfo ${OriginalPath}/${FuncImage}.nii.gz | grep -w dim4`; TotalVolumes=${TotalVolumes:15}

			#EpiSpacing=`cat ${OriginalPath}/${FuncImage}.json | grep -w EffectiveEchoSpacing`; EpiSpacing=${EpiSpacing:25:13}
			#EpiSpacing=`echo "${EpiSpacing}*1000" | bc` # Epi spacing in ms
			
			
			# Gridwise
			echo "#!/bin/bash" 	>> job # Interpreter
			echo "#SBATCH --job-name ${CurrentPreproc}_${SUB}_run${RUN}" 	>> job # Job name 
			echo "#SBATCH --time 12:00:00" 						>> job # Time until job is killed 
			echo "#SBATCH --mem 9GB" 								>> job # Books 10gb RAM for the job 
			echo "#SBATCH --mail-type NONE" 										>> job # Email notification on abort/end, use 'n' for no notification 
			echo "#SBATCH --output ${CurrentLog}/slurm-%j.out" 							>> job # Write output log to group log folder
			echo "#SBATCH --workdir ${WorkingDirectory}" 							>> job # working directory  

			#echo "module load fsl/5.0" >> job
			echo "FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11"  >> job
			echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
			echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
			echo "export FSLDIR PATH"                               >> job
			
			echo "tmpnam /home/mpib/LNDG/fsl_temp/fsl" 						>> job # change fsl temp folder

			# Create a designfile from the common template file, which should be saved in the scripts folder. 
			echo "cp ${ScriptsPath}/feat_template.fsf  ${FuncPath}/${FuncImage}.fsf"     	>> job

			# Adjust paths to the location of the fsf file
			echo "cd ${FuncPath}"           												>> job

			## This will replace the dummy code with the appropriate image, study, subject, session & run specific information.
				# The 'g' option will replace all instances of the dummy code with the required variable.
				# As a side note, we're using the '|' character so as to avoid issues when replacing strings which include slashes.
			
			# Primary Directories	
			echo "sed  -i 's|dummyFEAT|'${FuncPath}/FEAT.feat'|g'  				${FuncImage}.fsf"          	>> job	
			echo "sed  -i 's|dummyOriginal|'${OriginalPath}/${FuncImage}'|g'  	${FuncImage}.fsf"      		>> job
			echo "sed  -i 's|dummyAnatomical|'${AnatPath}/${AnatImage}'|g'  	${FuncImage}.fsf"     		>> job
			echo "sed  -i 's|dummyStandard|'${MNIImage}'|g'						${FuncImage}.fsf"          	>> job
			# Primary Parameters
			echo "sed  -i 's|dummyToggleMCFLIRT|'${ToggleMCFLIRT}'|g'  			${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyBETFunc|'${BETFunc}'|g'  						${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyTR|'${TR}'|g'  								${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyTotalVolumes|'${TotalVolumes}'|g'  			${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyDeleteVolumes|'${DeleteVolumes}'|g'  			${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyHighpassFEAT|'${HighpassFEAT}'|g'  			${FuncImage}.fsf" 			>> job
            echo "sed  -i 's|dummySmoothingKernel|'${SmoothingKernel}'|g'  		${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummyRegisterStructDOF|'${RegisterStructDOF}'|g'  	${FuncImage}.fsf" 			>> job
			# Secondary Parameters. Not usually used in our analysis.
				# Nonlinear Registration
			echo "sed  -i 's|dummyNonLinearReg|'${NonLinearReg}'|g'  			${FuncImage}.fsf" 			>> job
            echo "sed  -i 's|dummyNonLinearWarp|'${NonLinearWarp}'|g'  			${FuncImage}.fsf" 			>> job
				# B0 unwarping
			if [ "${Unwarping}" == "1" ]; then
				FieldRad="${WorkingDirectory}/data/mri/preproc/fmap/data/${SUB}/${SESS}/${SUB}_fmap_rads"
				FieldMapBrain="${WorkingDirectory}/data/mri/preproc/fmap/data/${SUB}/${SESS}/${SUB}_fmap_MeanMagnitude_brain"
			else FieldRad="Unused"; FieldMapBrain="Unused"; fi 
			echo "sed  -i 's|dummyUnwarping|'${Unwarping}'|g'  														  		${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummyFieldRad|'${FieldRad}'|g'  														  		${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummyFieldMapBrain|'${FieldMapBrain}'|g'  												  		${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummyEpiSpacing|'${EpiSpacing}'|g'  													  		${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyEpiTE|'${EpiTE}'|g'  																  		${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummyUnwarpDir|'${UnwarpDir}'|g'  														  		${FuncImage}.fsf"           >> job
			echo "sed  -i 's|dummySignalLossThresh|'${SignalLossThresh}'|g'  										  		${FuncImage}.fsf"           >> job
				# Other Parameters
	        echo "sed  -i 's|dummyIntensityNormalization|'${IntensityNormalization}'|g'										${FuncImage}.fsf" 			>> job
			echo "sed  -i 's|dummySliceTimingCorrection|'${SliceTimingCorrection}'|g' 										${FuncImage}.fsf" 			>> job
			
			# Run feat command.                                                                    
			echo "feat ${FuncImage}.fsf"           										>> job
			
			# Error log
			echo "if [ ! -f ${FuncPath}/FEAT.feat/filtered_func_data.nii.gz ];"  		>> job
			echo "then echo 'Error in ${FuncImage}' >> ${Error_Log}; fi"				>> job
			
			sbatch job
			rm job
			
		done
done
