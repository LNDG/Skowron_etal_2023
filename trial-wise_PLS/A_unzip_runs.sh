#!/bin/bash
# unzip preprocessed niftis of different runs for VarToolbox

SubjectID="ENT3003 ENT3006 ENT3009 ENT3012 ENT3015 ENT3018 ENT3021 ENT3024 ENT3027 ENT3030 ENT3033 ENT3036 ENT3039 ENT3042 ENT3045 ENT3048 ENT3051 ENT3004 ENT3007 ENT3010 ENT3013 ENT3016 ENT3019 ENT3022 ENT3025 ENT3028 ENT3031 ENT3034 ENT3037 ENT3040 ENT3043 ENT3046 ENT3049 ENT3052 ENT3005 ENT3008 ENT3011 ENT3014 ENT3017 ENT3020 ENT3023 ENT3026 ENT3029 ENT3032 ENT3035 ENT3038 ENT3041 ENT3044 ENT3047 ENT3050 ENT3053"
RunID="1 2 3"

DataPath="/home/mpib/LNDG/Entscheidung2/data"

for SUB in ${SubjectID} ; do			
		for RUN in ${RunID}; do
		
		FuncPath="${DataPath}/${SUB}/func/run${RUN}"
		FuncImg="${SUB}_run${RUN}_feat_detrended_highpassed_denoised_MNI.nii.gz"
		
		# Gridwise
		echo "#!/bin/bash" 	>> job # Interpreter
		echo "#SBATCH --job-name uzip_${SUB}_run${RUN}" 	>> job # Job name 
		echo "#SBATCH --time 1:00:00" 						>> job # Time until job is killed 
		echo "#SBATCH --mem 6GB" 								>> job # Books 10gb RAM for the job 
		echo "#SBATCH --mail-type NONE" 										>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#SBATCH --output /home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/log/slurm-%j.out" 							>> job # Write output log to group log folder
		echo "#SBATCH --workdir /home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/data" 							>> job # working directory
		
		echo "cd ${FuncPath}" 	>> job
		echo "gunzip ${FuncPath}/${FuncImg}" 	>> job
		
		sbatch job
		rm job
		
		done
		
done

