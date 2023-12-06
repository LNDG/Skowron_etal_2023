% run PLS analysis
% ran with matlab/R2017b in interactive job on tardis

addpath(genpath('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/toolboxes/PLS_rank-master'));

cd('/home/mpib/LNDG/Entscheidung2/analysis/GLM/PLS_results/pMod_var/samples/sd_datamats');

batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/GLM/PLS_results/pMod_var/samples/sd_datamats/TaskPLS_samples_BfMRIanalysis.txt');
batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/GLM/PLS_results/pMod_var/samples/sd_datamats/BehPLS_errorOnly_samples_BfMRIanalysis.txt');
batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/GLM/PLS_results/pMod_var/samples/sd_datamats/BehPLS_errorOnly_ranked_samples_BfMRIanalysis.txt');