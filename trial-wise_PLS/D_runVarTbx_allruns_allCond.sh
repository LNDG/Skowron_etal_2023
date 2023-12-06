#!/bin/bash

Outdir="/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/data/sd_niftis_allCond"
DataPath="/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/data"

SubjectID="ENT3003 ENT3006 ENT3009 ENT3012 ENT3015 ENT3018 ENT3021 ENT3024 ENT3027 ENT3030 ENT3033 ENT3036 ENT3039 ENT3042 ENT3045 ENT3048 ENT3051 ENT3004 ENT3007 ENT3010 ENT3013 ENT3016 ENT3019 ENT3022 ENT3025 ENT3028 ENT3031 ENT3034 ENT3037 ENT3040 ENT3043 ENT3046 ENT3049 ENT3052 ENT3005 ENT3008 ENT3011 ENT3014 ENT3017 ENT3020 ENT3023 ENT3026 ENT3029 ENT3032 ENT3035 ENT3038 ENT3041 ENT3044 ENT3047 ENT3050 ENT3053"

condID="s1 s2 s3 s4 s5 grid dec"

for sub in ${SubjectID}; do
		
		for cond in ${condID}; do
			
				if [ ! -d ${Outdir}/${sub}/${cond} ]; then	
					mkdir -p ${Outdir}/${sub}/${cond}
					chmod 770 ${Outdir}/${sub}/${cond}
				fi
			
				
				if [ ! -f ${Outdir}/${sub}/${cond}/${sub}_allCond_sd_${cond}_sd.nii ]; then
					
					# Gridwise
					echo "#!/bin/bash" 	>> job # Interpreter
					echo "#SBATCH --job-name VarTbx_${sub}_${cond}" 	>> job # Job name 
					#echo "#SBATCH --partition long" 						>> job
					echo "#SBATCH --cpus-per-task 9" 						>> job # Time until job is killed 
					echo "#SBATCH --time 24:00:00" 						>> job # Time until job is killed 
					echo "#SBATCH --mem 80GB" 								>> job # Books 10gb RAM for the job 
					echo "#SBATCH --mail-type NONE" 										>> job # Email notification on abort/end, use 'n' for no notification 
					echo "#SBATCH --output /home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/log/slurm-%j.out" 							>> job # Write output log to group log folder
					echo "#SBATCH --workdir ${Outdir}/${sub}/${cond}" 							>> job # working directory
					
				
					spm_file=${DataPath}/spm_spec_allCond/${sub}_allCond_${cond}_sdmodel.mat
					
					#echo "/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/toolboxes/spm_parallel/standalone/run_spm12.sh /opt/matlab/R2022b run ${spm_file}" >> job
					echo "/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/toolboxes/spm12_sepCond/standalone/run_spm12.sh /opt/matlab/R2022b run ${spm_file}" >> job
					#echo "/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/toolboxes/standalone/run_spm12.sh /opt/matlab/R2022b run ${spm_file}" >> job
					
					sbatch job
					rm job
					
				fi
		
		done
	
done
