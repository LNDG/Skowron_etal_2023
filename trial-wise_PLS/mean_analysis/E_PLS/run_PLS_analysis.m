% run PLS analysis
% ran with matlab/R2017b in interactive job on tardis

addpath(genpath('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/toolboxes/PLS_rank-master'));

cd('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/results/allCond/beta_datamats');

batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/results/allCond/beta_datamats/TaskPLS_samples_allCond_BfMRIanalysis.txt');
batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/results/allCond/beta_datamats/BehPLS_errorOnlyRANK_ranked_meanChange_BfMRIanalysis.txt');
batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/results/allCond/beta_datamats/BehPLS_errorOnlyRANK_ranked_N47_meanChange_BfMRIanalysis.txt');
