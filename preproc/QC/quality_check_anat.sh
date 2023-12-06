#!/bin/bash
# 21.11.18 Creating quality check reports by Alex

source ../preproc_config.sh

#Output path must be an empty folder!
OutPath_anat="${DataPath}/QC/ANTs_BET"

if [ ! -d ${OutPath_anat} ]; then mkdir -p ${OutPath_anat}; chmod 770 ${OutPath_anat}; fi

# load FSL

FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh      
PATH=${FSLDIR}/bin:${PATH}         
export FSLDIR PATH

cd ${ScriptsPath}

#------------- QC step anat + fmap BET -------------------
# T1
cd ${OutPath_anat}
	
#cycle over subjects
for SUB in ${SubjectID}; do
	
 if [ ! -d ${OutPath_anat}/temp ]; then mkdir -p ${OutPath_anat}/temp; chmod 770 ${OutPath_anat}/temp; fi
	
 # Path to the anatomical image folder.
 AnatPath="${DataPath}/${SUB}/anat"		# Path for anatomical image	
 # Name of anatomical image to be used.
 AnatImage="${SUB}_anat" 									# Original anatomical image, no extraction performed
	
 cd ${OutPath_anat}/temp
 
 fslsplit ${AnatPath}/${AnatImage} ${AnatImage}-acq

# raw T1
 T1=${OutPath_anat}/temp/${AnatImage}-acq0000.nii.gz

# Brain extracted T1 (FSL bet output)
 T1_bet=${DataPath}/${SUB}/anat/ANTs/${SUB}_anat_brain.nii.gz	 
 
 cd ${OutPath_anat}

#overlay of brain extraction
 overlay 1 1 ${T1} -a ${T1_bet} 1 10 ${OutPath_anat}/${SUB}_anat_bet_overlay.nii.gz 
 
 rm -r ${OutPath_anat}/temp
 
done

overlays=`ls *_anat_bet_overlay.nii.gz`	 

#create report
slicesdir ${overlays}

#delete intermediate niftis
rm ${overlays}	
 
#clean up
cd ${OutPath_anat}/slicesdir

overlays_png=`ls *_anat_bet_overlay.png`
mv ${overlays_png} ${OutPath_anat}

cd ${OutPath_anat}

mv ${OutPath_anat}/slicesdir/index.html ${OutPath_anat}/index.html
rm -r ${OutPath_anat}/slicesdir