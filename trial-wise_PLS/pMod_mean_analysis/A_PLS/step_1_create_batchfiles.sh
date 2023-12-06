#!/bin/bash

## Make PLS text batch files

source pls_config.sh

for SID in $SubjectID; do
    # Make individual batch files       	
	cp ${ScriptsPath}/A_PLS/make_batch_template.txt ${MeanPLS}/${SID}_meanbold_batch.txt
	
	# Modify file using sed command to edit the subject ID and file location/path within the batch text file.
	
	#TODO: Note that the rest of this script will have to me modified for however many sessions/runs/conditions must be specified for the project.
	
	dummy_ID="dummyID"
	new_ID="${SID}"
	
	dummy_pMod="dummy_pMod"
	pMod_dir="/home/mpib/LNDG/Entscheidung2/analysis/GLM/results/pMod_mean/${SID}/con_0001.nii"
	
	# The '' is neccessary when performing on a local machine, but not on the grid 
	sed -i "s|${dummy_ID}|${new_ID}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	sed -i "s|${dummy_pMod}|${pMod_dir}|g" ${MeanPLS}/${SID}_meanbold_batch.txt
	
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