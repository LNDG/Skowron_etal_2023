#PBS -N QC 	  # Job name 
#PBS -l walltime=12:00:00 						  # Time until job is killed 
#PBS -l mem=4gb 								  # Books 10gb RAM for the job 
#PBS -m n										  # Email notification on abort/end, use 'n' for no notification 
#PBS -o /home/mpib/LNDG/EyeMem/study_information/B_logs/BET_QC 							  # Write (output) log to group log folder 
#PBS -e /home/mpib/LNDG/EyeMem/study_information/B_logs/BET_QC 							  # Write (error) log to group log folder 

#!/bin/bash
# 21.11.18 Creating quality check reports by Alex

source ../preproc_config.sh

if [ ! -d ${CurrentLog} ]; then mkdir -p ${CurrentLog}; chmod 770 ${CurrentLog}; fi

#Output path must be an empty folder!
OutPath_task="${WorkingDirectory}/data/QC"

if [ ! -d ${OutPath_task} ]; then mkdir -p ${OutPath_task}; chmod 770 ${OutPath_task}; fi

# load FSL
FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh      
PATH=${FSLDIR}/bin:${PATH}         
export FSLDIR PATH

##---------------------------- QC step mean raw func -----------------------------
## create overview of mean raw func images
#
#meanRaw_Outpath="${OutPath_task}/mean_raw"
#
#if [ ! -d ${meanRaw_Outpath} ]; then mkdir -p ${meanRaw_Outpath}; chmod 770 ${meanRaw_Outpath}; fi
#	
#cd ${meanRaw_Outpath}
#
#for SUB in ${SubjectID}; do
#		for RUN in ${RunID}; do
#			
#			raw_img="${DataPath}/${SUB}/${SUB}_run${RUN}"
#			
#			if [ ! -f ${raw_img}.nii.gz ] || [ -f ${meanRaw_Outpath}/${SUB}_task-${TASK}_rawMean.nii.gz ]; then
#				continue
#			fi
#			
#			fslmaths ${raw_img} -Tmean ${meanRaw_Outpath}/${SUB}_task-${TaskID}_run${RUN}_rawMean
#			
#		done
#done
#
#mean_raw_images=`ls sub-*_task-*_*_run-*_rawMean.nii.gz`
#
#slicesdir ${mean_raw_images}
#
#cd ${meanRaw_Outpath}/slicesdir
#
#mv index.html ${meanRaw_Outpath}
#
#mean_raw_png=`ls sub-*_task-*_*_run-*_rawMean.png`
#
#mv ${mean_raw_png} ${meanRaw_Outpath}
#
#cd ${meanRaw_Outpath}
#
#rm -r ${meanRaw_Outpath}/slicesdir
#
#rm mean_raw_images=`ls sub-*_task-*_*_run-*_rawMean.nii.gz`

#---------------------------- QC step epi2MNI ---------------------------
# creates a gif of the MNI template and mean filtered func image registered to MNI space 

epi2MNI_Outpath="${OutPath_task}/epi2MNI"

if [ ! -d ${epi2MNI_Outpath} ]; then mkdir -p ${epi2MNI_Outpath}; chmod 770 ${epi2MNI_Outpath}; fi
	
cd ${epi2MNI_Outpath}

# prepare report index

echo "<HTML><TITLE>epi2MNI</TITLE><BODY BGCOLOR=\"#aaaaff\">" >> epi2standard_report.html

# create MNI template overlay

cp ${MNIImage}.nii.gz ${epi2MNI_Outpath}/MNI_template.nii.gz

slicesdir -p ${epi2MNI_Outpath}/MNI_template ${epi2MNI_Outpath}/MNI_template

cd slicesdir

pngappend grota.png + grotb.png + grotc.png + grotd.png + grote.png + grotf.png + grotg.png + groth.png + groti.png movie_MNI_template.gif

cp movie_MNI_template.gif ../movie_MNI_template.gif

cd ${epi2MNI_Outpath}

rm -r slicesdir

for SUB in ${SubjectID}; do
		for RUN in ${RunID}; do
			
			preproc_dir="${WorkingDirectory}/data/${SUB}/func/run${RUN}/FEAT.feat"
			
			mean_func="${SUB}_run${RUN}_mean_func"
			
			# check if file exists
			if [ ! -f ${preproc_dir}/mean_func.nii.gz ]; then
				continue
			fi
			
			# prepare epi overlay
			cp ${preproc_dir}/mean_func.nii.gz ${epi2MNI_Outpath}/${mean_func}.nii.gz
    	
			flirt -in ${mean_func} -ref ${MNIImage} -applyxfm -init ${preproc_dir}/reg/example_func2standard.mat -out ${mean_func}2standard
			
			rm ${mean_func}.nii.gz
			
			slicesdir -p ${epi2MNI_Outpath}/MNI_template ${mean_func}2standard
			
			cd slicesdir
			
			pngappend grota.png + grotb.png + grotc.png + grotd.png + grote.png + grotf.png + grotg.png + groth.png + groti.png movie_${SUB}_run${RUN}.gif
			
			cp movie_${SUB}_run${RUN}.gif ../movie_${SUB}_run${RUN}.gif
			
			cd ${epi2MNI_Outpath}
			
			rm -r slicesdir
			rm ${mean_func}2standard.nii.gz
			
			whirlgif -o epi2standard_${SUB}_run${RUN}.gif -time 50 -loop 0 movie_${SUB}_run${RUN}.gif movie_MNI_template.gif 2>&1
			
			rm movie_${SUB}_run${RUN}.gif
			
			# add gif to report
			
			echo "<a href=\"epi2standard_${SUB}_run${RUN}.gif\"><img src=\"epi2standard_${SUB}_run${RUN}.gif\" WIDTH=1000 > ${SUB}_run${RUN}</a><br>" >> epi2standard_report.html
    	
		done
done

# finalise
echo "</BODY></HTML>" >> epi2standard_report.html

rm MNI_template.nii.gz
rm movie_MNI_template.gif

##--------------------------- QC step run2run -----------------------------------
## creates gif of mean filtered func images registered to MNI space cycling through runs
#
#run2run_Outpath="${OutPath_task}/run2run"
#
#if [ ! -d ${run2run_Outpath} ]; then mkdir -p ${run2run_Outpath}; chmod 770 ${run2run_Outpath}; fi
#	
#cd ${run2run_Outpath}
#
## prepare report index
#
#echo "<HTML><TITLE>run2run</TITLE><BODY BGCOLOR=\"#aaaaff\">" >> run2run_report.html
#
#for SUB in ${SubjectID}; do
#	for SESS in ${SessionID}; do
#		for RUN in ${RunID}; do
#			
#			preproc_dir="${WorkingDirectory}/data/mri/preproc/task/data/${SUB}/${SESS}/run${RUN}/FEAT.feat"
#			
#			mean_func="${SUB}_run${RUN}_mean_func"
#			
#			# check if file exists
#			if [ ! -f ${preproc_dir}/mean_func.nii.gz ]; then
#				continue
#			fi
#			
#			# prepare epi overlay
#			cp ${preproc_dir}/mean_func.nii.gz ${run2run_Outpath}/${mean_func}.nii.gz
#			
#			flirt -in ${mean_func} -ref ${MNIImage} -applyxfm -init ${preproc_dir}/reg/example_func2standard.mat -out ${mean_func}2standard
#			
#			rm ${mean_func}.nii.gz
#			
#			slicesdir ${mean_func}2standard
#			
#			cd slicesdir
#			
#			pngappend grota.png + grotb.png + grotc.png + grotd.png + grote.png + grotf.png + grotg.png + groth.png + groti.png movie_${SUB}_run${RUN}.gif
#			
#			cp movie_${SUB}_run${RUN}.gif ../movie_${SUB}_run${RUN}.gif
#			
#			cd ${run2run_Outpath}
#			
#			rm -r slicesdir
#			rm ${mean_func}2standard.nii.gz
#			
#		done
#	
#		# create gif concatenating all run images
#		if [ -f movie_${SUB}_run-01.gif ] && [ -f movie_${SUB}_run-02.gif ]; then
#			whirlgif -o run2run_${SUB}.gif -time 50 -loop 0 movie_${SUB}_run-01.gif movie_${SUB}_run-02.gif 2>&1
#		elif [ -f movie_${SUB}_run-01.gif ]; then rm movie_${SUB}_run-01.gif; continue; fi
#		
#		gifs=`ls movie_*.gif`
#		rm ${gifs}
#		
#		# add gif to report
#		
#		echo "<a href=\"run2run_${SUB}.gif\"><img src=\"run2run_${SUB}.gif\" WIDTH=1000 > ${SUB}</a><br>" >> run2run_report.html
#	
#	done
#done
#
## finalise
#echo "</BODY></HTML>" >> run2run_report.html

#------------------------ QC step func2anat -------------------------------------------


epi2anat_Outpath="${OutPath_task}/epi2anat"

if [ ! -d ${epi2anat_Outpath} ]; then mkdir -p ${epi2anat_Outpath}; chmod 770 ${epi2anat_Outpath}; fi

cd ${epi2anat_Outpath}

# prepare report index
echo "<HTML><TITLE>epi2anat</TITLE><BODY BGCOLOR=\"#aaaaff\">" >> epi2anat_report.html

for SUB in ${SubjectID}; do
		for RUN in ${RunID}; do

			org_file="${WorkingDirectory}/data/${SUB}/func/run${RUN}/FEAT.feat/reg/example_func2highres.png"
			
			if [ ! -f ${org_file} ]; then
				continue
			fi
			
			cp ${org_file} ${epi2anat_Outpath}/${SUB}_run${RUN}_epi2anat.png
			
			# add png to report
			echo "<a href=\"${SUB}_run${RUN}_epi2anat.png\"><img src=\"${SUB}_run${RUN}_epi2anat.png\" WIDTH=1000 > ${SUB}_run${RUN}</a><br>" >> epi2anat_report.html
			
		done
done

# finalise
echo "</BODY></HTML>" >> epi2anat_report.html

##-------------------------- QC step func BET -------------------------------------------
#
#funcBET_Outpath="${OutPath_task}/funcBET"
#
#if [ ! -d ${funcBET_Outpath} ]; then mkdir -p ${funcBET_Outpath}; chmod 770 ${funcBET_Outpath}; fi
#	
#cd ${funcBET_Outpath}
#
#for SUB in ${SubjectID}; do
#	for SESS in ${SessionID}; do
#		for RUN in ${RunID}; do
#			
#			preproc_dir="${WorkingDirectory}/data/mri/preproc/task/data/${SUB}/${SESS}/run${RUN}/FEAT.feat"
#			
#			# check if file exists
#			if [ ! -f ${preproc_dir}/mask.nii.gz ]; then
#				continue
#			fi
#			
#			cp ${preproc_dir}/mask.nii.gz ${funcBET_Outpath}/${SUB}_run${RUN}_mask.nii.gz
#			
#			org_func="${DataPath}/${SUB}/ses-${SESS}/func/${SUB}_task-${TaskID}_run${RUN}_bold"
#			
#			if [ ! -f ${org_func}.nii.gz ]; then
#				continue
#			fi
#			
#			fslmaths ${org_func} -Tmean ${funcBET_Outpath}/${SUB}_run${RUN}_raw_mean.nii.gz
#			
#			overlay 1 1 ${funcBET_Outpath}/${SUB}_run${RUN}_raw_mean.nii.gz -a ${funcBET_Outpath}/${SUB}_run${RUN}_mask.nii.gz 1 1 ${funcBET_Outpath}/${SUB}_run${RUN}_funcBET.nii.gz
#			
#			# clean up
#			rm ${funcBET_Outpath}/${SUB}_run${RUN}_mask.nii.gz
#			rm ${funcBET_Outpath}/${SUB}_run${RUN}_raw_mean.nii.gz	
#			
#		done
#	done
#done
#
#cd ${funcBET_Outpath}
#
#overlays=`ls *_funcBET.nii.gz`
#
##create report
#slicesdir ${overlays}	
#
##delete intermediate niftis
#rm ${overlays}
#
##clean up
#cd ${funcBET_Outpath}/slicesdir
#
#overlays_png=`ls *_funcBET.png`
#mv ${overlays_png} ${funcBET_Outpath}
#
#cd ${funcBET_Outpath}	
#
#mv ${funcBET_Outpath}/slicesdir/index.html ${funcBET_Outpath}/funcBET_report.html
#rm -r ${funcBET_Outpath}/slicesdir

##------------------------------- QC step common activation mask ---------------------------------------
#
#common_Outpath="${OutPath_task}/common_coords"
#
#if [ ! -d ${common_Outpath} ]; then mkdir -p ${common_Outpath}; chmod 770 ${common_Outpath}; fi
#	
#cd ${common_Outpath}
#
## create common coordinates per subject
#for SUB in ${SubjectID}; do
#	for SESS in ${SessionID}; do
#		for RUN in ${RunID}; do
#			
#			preproc_dir="${WorkingDirectory}/data/mri/preproc/task/data/${SUB}/${SESS}/run${RUN}/FEAT.feat"
#			
#			mean_func="${SUB}_run${RUN}_mean_func"
#			
#			# check if file exists
#			if [ ! -f ${preproc_dir}/mean_func.nii.gz ]; then
#				continue
#			fi
#			
#			cp ${preproc_dir}/mean_func.nii.gz ${common_Outpath}/${mean_func}.nii.gz
#			
#			# register mean func to MNI
#			flirt -in ${mean_func} -ref ${MNIImage} -applyxfm -init ${preproc_dir}/reg/example_func2standard.mat -out ${mean_func}2standard
#			
#			rm ${mean_func}.nii.gz
#			
#			# create mean func mask
#			fslmaths ${mean_func}2standard -bin ${mean_func}2standard_mask
#			
#			rm ${mean_func}2standard.nii.gz
#			
#			if [ ! -f ${SUB}_common_coords.nii.gz ]; then
#				cp ${mean_func}2standard_mask.nii.gz ${SUB}_common_coords.nii.gz
#			fi
#			
#			# add image to common coords mask
#			fslmaths ${SUB}_common_coords -mas ${mean_func}2standard_mask ${SUB}_common_coords
#			
#			rm ${mean_func}2standard_mask.nii.gz
#			
#			#create visual
#			if [ -f ${common_Outpath}/${SUB}_common_coords.nii.gz ]; then
#				overlay 1 1 ${MNIImage} -a ${common_Outpath}/${SUB}_common_coords 1 1 ${common_Outpath}/${SUB}_common_coords_overlay
#			fi
#			
#		done
#	done
#done
#
## create common coordinates across subjects with voxel density
#
#cd ${common_Outpath}
#
## across sessions
#for SUB in ${SubjectID}; do
#	for SESS in ${SessionID}; do
#		if [ ! -f ${SUB}_common_coords.nii.gz ]; then
#			continue
#		elif [ ! -f common_coords.nii.gz ]; then
#			cp ${SUB}_common_coords.nii.gz common_coords.nii.gz
#		else
#			fslmaths common_coords.nii.gz -add ${SUB}_common_coords.nii.gz common_coords.nii.gz
#		fi
#	done
#done
#
## for each session
#
#for SUB in ${SubjectID}; do
#	for SESS in ${SessionID}; do
#		if [ ! -f ${SUB}_common_coords.nii.gz ]; then
#			continue
#		elif [ ! -f ${SESS}_common_coords.nii.gz ]; then
#			cp ${SUB}_common_coords.nii.gz ${SESS}_common_coords.nii.gz
#		else
#			fslmaths ${SESS}_common_coords.nii.gz -add ${SUB}_common_coords.nii.gz ${SESS}_common_coords.nii.gz
#		fi
#	done
#done