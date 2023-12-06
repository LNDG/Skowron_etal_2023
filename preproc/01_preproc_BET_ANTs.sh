#!/bin/bash

## Brain Extraction (BET) using ANTs. Create brain extracted images using desired parameters.

# 180516 | adapted from José's FSL BET script by JQK

source preproc_config.sh

FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11

# PBS Log Info
CurrentPreproc="BET/ANTs"
CurrentLog="${LogPath}/${CurrentPreproc}"

if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Loop over participants & sessions (if they exist)
for SUB in ${SubjectID} ; do
		
		# Path to the anatomical image folder.
		AnatPath="${DataPath}/${SUB}/anat"		# Path for anatomical image	
		# Name of anatomical image to be used.
		AnatImage="${SUB}_anat" 									# Original anatomical image, no extraction performed
		# Output path for ANTs procedure
		ANTsPath="${DataPath}/${SUB}/anat/ANTs"
		# ANTs output name
		ANTsName="${AnatImage}_ANTs_"
		# Start log
		StartLog="${ANTsPath}/${ANTsName}started.txt"
		# Error message if ANTs did not produce the expected output
		CrashLog="${ANTsPath}/${ANTsName}failed.txt"
		
		# If anat files have not been properly renamed.
		
		if [ ! -f ${AnatPath}/${AnatImage}.nii.gz ]; then   		# Verifies if the anatomical image exists. If it doesn't, the for loop stops here and continues with the next item. 
			echo "No mprage: ${SUB} cannot be processed"
			continue
		elif [ -f ${ANTsPath}/${SUB}_T1w_brain.nii.gz ]; then 	# Verify if ANTs output was already created
			continue
		elif [ ! -f ${ANTsPath}/${SUB}_T1w_brain.nii.gz ]; then
			if [ -f ${CrashLog} ]; then 							# Verify if crash log exists, if so, delete intermediary ANTs files and re-run ANTs.
				rm -rf ${ANTsPath}				
			elif [ -f ${StartLog} ]; then 							# Verify if ANTs job started. Could be problematic if job did not finish.
				continue
			fi
		fi
		
		# Create ANTS folder
		if [ ! -d ${ANTsPath} ]; then mkdir -p ${ANTsPath}; chmod 770 ${ANTsPath}; fi
		
		# ANTs settings
		KeepTemporaryFiles="0" # don't save temporary files
		ImageDimension="3" # 3d
		
		# ANTs-specific file paths
		##NKI template
		#TemplatePath="${SharedFilesPath_standards}/ANTS/NKI"
		#TemplateImage="${TemplatePath}/T_template.nii.gz" 								
		#ProbabilityImage="${TemplatePath}/T_template_BrainCerebellumProbabilityMask.nii.gz"
		#RegistrationMask="${TemplatePath}/T_template_BrainCerebellumExtractionMask.nii.gz" 
		
		#OASIS template
		TemplatePath="${SharedFilesPath_standards}/ANTS/MICCAI2012-Multi-Atlas-Challenge-Data" 					# Directory for ANTs template to be used (Oasis template)
		TemplateImage="${TemplatePath}/T_template0.nii.gz" 											# ANTs bet template image (e.g. averaged anatomical image) - mandatory
		ProbabilityImage="${TemplatePath}/T_template0_BrainCerebellumProbabilityMask.nii.gz" 		# ANTs bet brain probability image of the template image - mandatory
		RegistrationMask="${TemplatePath}/T_template0_BrainCerebellumRegistrationMask.nii.gz" 		# ANTs bet brain mask of the template image (i.e. rough binary mask of brain location) - optional (recommended)
		
		
		# Gridwise
		echo "#!/bin/bash" 	>> job # Interpreter 
		echo "#SBATCH --job-name ${CurrentPreproc}_${SUB}" 	>> job # Job name 
		echo "#SBATCH --time 12:00:00" 						>> job # Time until job is killed 
		echo "#SBATCH --mem 8GB" 								>> job # Books 10gb RAM for the job 
		echo "#SBATCH --mail-type NONE" 										>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#SBATCH --output ${CurrentLog}/slurm-%j.out" 							>> job # Write output log to group log folder
		echo "#SBATCH --workdir ${WorkingDirectory}" 							>> job # working directory
    	
		echo "sleep $(( RANDOM % 120 ))"						>> job # Sleep for a random period between 1-60 seconds, used to avoid interference when running antsBrainExtraction.sh
		
		echo "FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11"  >> job
		echo ". ${FSLDIR}/etc/fslconf/fsl.sh"                   >> job
		echo "PATH=${FSLDIR}/bin:${PATH}"                       >> job
		echo "export FSLDIR PATH"                               >> job
		
    	echo "module load ants/2.3.5-mpib0" 							>> job
		
		echo "cd ${ANTsPath}"		>> job
		echo "echo 'ANTs will start now' >> ${StartLog}"		>> job
		
		# Perform Brain Extraction
		
		echo "antsBrainExtraction.sh -d ${ImageDimension} -a ${AnatPath}/${AnatImage}.nii.gz -e ${TemplateImage} -m ${ProbabilityImage} -f ${RegistrationMask} -k ${KeepTemporaryFiles} -q 1 -o ${ANTsPath}/${ANTsName}" 	>> job
		
		# FIX: ${ScriptsPath}/antsBrainExtraction_cpgeom.sh

		# If the final ANTs output isn't created, write a text file to be used as a verification of the output outcome.
		echo "if [ ! -f ${ANTsPath}/${ANTsName}BrainExtractionBrain.nii.gz ]; then echo 'BrainExtractionBrain file was not produced.' >> ${CrashLog}; exit; fi" >> job
		
		echo "mv ${ANTsPath}/${ANTsName}BrainExtractionBrain.nii.gz ${ANTsPath}/${SUB}_anat_brain.nii.gz" >> job
		
		echo "rm ${StartLog}" >> job

		sbatch job
		rm job
done

