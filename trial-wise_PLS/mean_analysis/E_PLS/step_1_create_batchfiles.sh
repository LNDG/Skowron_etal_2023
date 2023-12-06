#!/bin/bash

## Make PLS text batch files

source pls_config.sh

for SID in $SubjectID; do
    # Make individual batch files       	
	cp ${ScriptsPath}/E_PLS/make_batch_template.txt ${MeanPLS}/${SID}_meanbold_batch.txt
	
	# Modify file using sed command to edit the subject ID and file location/path within the batch text file.
	
	#TODO: Note that the rest of this script will have to me modified for however many sessions/runs/conditions must be specified for the project.
	
	dummy_ID="dummyID"
	new_ID="${SID}"
	
	dummy_s1="dummy_s1"
	s1_dir="${ScriptsPath}/data/mean_niftis_allCond/${SID}/con_0001.nii"
	
	dummy_s2="dummy_s2"
	s2_dir="${ScriptsPath}/data/mean_niftis_allCond/${SID}/con_0002.nii"
	
	dummy_s3="dummy_s3"
	s3_dir="${ScriptsPath}/data/mean_niftis_allCond/${SID}/con_0003.nii"
	
	dummy_s4="dummy_s4"
	s4_dir="${ScriptsPath}/data/mean_niftis_allCond/${SID}/con_0004.nii"
	
	dummy_s5="dummy_s5"
	s5_dir="${ScriptsPath}/data/mean_niftis_allCond/${SID}/con_0005.nii"
	
	dummy_grid="dummy_grid"
	grid_dir="${ScriptsPath}/data/mean_niftis_allCond/${SID}/con_0006.nii"
	
	dummy_dec="dummy_dec"
	dec_dir="${ScriptsPath}/data/mean_niftis_allCond/${SID}/con_0007.nii"
	
	# The '' is neccessary when performing on a local machine, but not on the grid 
	sed -i "s|${dummy_ID}|${new_ID}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	sed -i "s|${dummy_s1}|${s1_dir}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	sed -i "s|${dummy_s2}|${s2_dir}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	sed -i "s|${dummy_s3}|${s3_dir}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	sed -i "s|${dummy_s4}|${s4_dir}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	sed -i "s|${dummy_s5}|${s5_dir}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	sed -i "s|${dummy_grid}|${grid_dir}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	sed -i "s|${dummy_dec}|${dec_dir}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	
	## The '' is neccessary when performing on a local machine, but not on the grid 
	#sed -i "s|${old_1}|${new_1}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	#sed -i "s|${old_2}|${new_2}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	#sed -i "s|${old_3}|${new_3}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	#sed -i "s|${old_4}|${new_4}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	#sed -i "s|${old_5}|${new_5}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	#sed -i "s|${old_6}|${new_6}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	
	# Unzip all NIfTI files
	# gunzip ${new_2}.gz
				
done