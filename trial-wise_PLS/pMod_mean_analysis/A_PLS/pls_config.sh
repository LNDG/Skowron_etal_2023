#!/bin/bash

## Configuration file
# This file will set environments and variables which will be used throughout the preprocessing procedures.

#TODO: Change study parameters for your study
## Study parameters

# Project name. This should be the name of the folder in which the study data is saved.
	# EX: ProjectName="Mock_Study"
ProjectName="Entscheidung2"									# No default, must be set by user

# Name of the specific pipeline which is used as input.
	# EX: "new_preproc"
# Set subject ID list. Use an explicit list. No commas between subjects.
	# EX:  SubjectID="Subject001 SubjectID002 Suject003"
SubjectID="ENT3003 ENT3006 ENT3009 ENT3012 ENT3015 ENT3018 ENT3021 ENT3024 ENT3027 ENT3030 ENT3033 ENT3036 ENT3039 ENT3042 ENT3045 ENT3048 ENT3051 ENT3004 ENT3007 ENT3010 ENT3013 ENT3016 ENT3019 ENT3022 ENT3025 ENT3028 ENT3031 ENT3034 ENT3037 ENT3040 ENT3043 ENT3046 ENT3049 ENT3052 ENT3005 ENT3008 ENT3011 ENT3014 ENT3017 ENT3020 ENT3023 ENT3026 ENT3029 ENT3032 ENT3035 ENT3038 ENT3041 ENT3044 ENT3047 ENT3050 ENT3053"
 									# No default, must be set by user

# Set session ID list. Leave as an empty string if no sessions in data path. No commas if containing any session information.
	# EX: SessionID="ses1 ses2"
SessionID=""									# Default is empty string

# Name of experimental conditions, runs or task data to be analyzed. No commas between runs/conditions.
	# EX: RunID="task1_run1 task1_run2 task2 restingstate"

#TODO: These next values do not need modifying
## Set directories

# Base directory.
BaseDirectory="/home/mpib/LNDG"

## Project directories
WorkingDirectory="${BaseDirectory}/${ProjectName}"  	# Base project directory
ScriptsPath="${WorkingDirectory}/analysis/trial-wise_PLS/pMod_mean_analysis" 	# Pipe specific scripts
PLSDirectory="${ScriptsPath}/results"					# PLS directory
#LogPath="${WorkingDirectory}/data/mri/analysis/task/PLS/logs"					# Common log paths for PLS processing
MeanPLS="${PLSDirectory}/mean_datamats" 				# Location of Mean PLS files &  batch text files
SDPLS="${PLSDirectory}/beta_datamats" 					# Location of SD PLS files