% run PLS analysis
% ran with matlab/R2017b in interactive job on tardis

addpath(genpath('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/toolboxes/PLS_rank-master'));

cd('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats');

batch_plsgui('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/TaskPLS_samples_ranked_allCond_BfMRIanalysis.txt');