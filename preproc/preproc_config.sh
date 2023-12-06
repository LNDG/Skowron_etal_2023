#!/bin/bash

# Configuration file

# This file will set environments and variables which will be used throughout the preprocessing procedures.

#################################################################
#################################################################
#TODO: REMEMBER TO VERIFY IF THE IMAGES HAVE TO BE RESLICED!!!!!#
#################################################################
#################################################################

## Study variables

# Project name. This should be the name of the folder in which the study data is saved.
ProjectName="Entscheidung2"

## Set the base directory. This will be the place where we can access common files which are not particular to this project, for example, MNI images, gray matter masks and any shared toolboxes.

BaseDirectory="/home/mpib/LNDG"
LNDGdirectory="/home/mpib/LNDG"

## Set the working directory for the current project & it's script/data paths

WorkingDirectory="${BaseDirectory}/${ProjectName}"  		# Common project directory
DataPath="${WorkingDirectory}/data"	 						# Root Data
ScriptsPath="${WorkingDirectory}/scripts" 	# Pipe specific scripts
LogPath="${WorkingDirectory}/logs"			# Common log paths
SharedFilesPath_standards="${LNDGdirectory}/Standards" 				# Toolboxes, Standards, etc
SharedFilesPath_toolboxes="${LNDGdirectory}/toolboxes" 
# MasksFilesPath="${WorkingDirectory}/data/mri/preproc/task/masks"

if [ ! -d ${LogPath} ]; then
	mkdir -p ${LogPath}
	chmod 770 ${LogPath}
fi

# Set subject ID list. Use an explicit list. No commas.

SubjectID="ENT3003 ENT3006 ENT3009 ENT3012 ENT3015 ENT3018 ENT3021 ENT3024 ENT3027 ENT3030 ENT3033 ENT3036 ENT3039 ENT3042 ENT3045 ENT3048 ENT3051 ENT3004 ENT3007 ENT3010 ENT3013 ENT3016 ENT3019 ENT3022 ENT3025 ENT3028 ENT3031 ENT3034 ENT3037 ENT3040 ENT3043 ENT3046 ENT3049 ENT3052 ENT3005 ENT3008 ENT3011 ENT3014 ENT3017 ENT3020 ENT3023 ENT3026 ENT3029 ENT3032 ENT3035 ENT3038 ENT3041 ENT3044 ENT3047 ENT3050 ENT3053"

# Name of experimental conditions, runs or task data to be analyzed. No commas.
RunID="2"
#"1 2 3"

# Voxel sizes & TR:
VoxelSize="3"
TR="0.645" # Volume acquisition time

# FEAT standard variables
ToggleMCFLIRT="1"								# 0=No, 1=Yes: Default is 1
BETFunc="1" 									# 0=No, 1=Yes: Default is 1
#TotalVolumes=""	# take directly from nifti
DeleteVolumes="0"
HighpassFEAT="0"			# 0=No, 1=Yes
SmoothingKernel="5"
RegisterStructDOF="BBR" 						# Default is BBR, other DOF options: 12, 9, 7, 6, 3
MNIImage="${SharedFilesPath_standards}/MNI152_T1_3mm_brain"

# Secondary FEAT variables (normally unused)
NonLinearReg="0"								# 0=No, 1=Yes: Default is 0
NonLinearWarp="10"								# Default is 10, applied only if NonLinearReg=1
IntensityNormalization="0" 						# 0=No, 1=Yes: Default is 0
SliceTimingCorrection="0"						# Default is 0; 0:None,1:Regular up,2:Regular down,3:Use slice order file,4:Use slice timings file,5:Interleaved

# Other FIELDmap variables
Unwarping="0"
UnwarpDir="y-"
EpiSpacing="0.7"
EpiTE="35" # in ms
SignalLossThresh="10"

# Motion outlier detection metric
MoutMetric="dvars"

# Detrend variables
PolyOrder="3" 									# Default is 3

# Filter variables
HighpassFilterLowCutoff="0.01"					# Default is 0.01, can be set to "off"" if not perforing Highpass
LowpassFilterHighCutoff="off" 					# Default is 0.1, can be set to "off" if not performing Lowpass
FilterOrder="8" 								# Default is 8

# ICA variables
dimestVALUE="mdl" 								# Default is mdl
bgthresholdVALUE="3" 							# Default is 3
mmthreshVALUE="0.5" 							# Default is 0.5
dimensionalityVALUE="0" 						# Default is 0
AdditionalParameters="-v --Ostats" 				# Default are '-v --Ostats', verbose and, output thresholded maps and probability maps

# FIX
# Test Set for FIX
## Need to double check number of younger and old subjects
TestSetID="ENT3003 ENT3004 ENT3005 ENT3006 ENT3007 ENT3008 ENT3009 ENT3010 ENT3011 ENT3012 ENT3013 ENT3014 ENT3015 ENT3016 ENT3017 ENT3018 ENT3019 ENT3020 ENT3021"

## Accepted FIX Threshold
FixThreshold="20"

# Additional parameters
#StandardsAndMasks="${ProjectName}_Standards" #For template
#MeanValue="10000" #For re-adding mean