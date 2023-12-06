% run PLS analysis
% ran with matlab/R2017b in interactive job on tardis

addpath(genpath('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/toolboxes/PLS_rank-master'));

cd('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats');

batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/BehPLS_errorOnlyRANK_ranked_N47_pMod_BfMRIanalysis.txt');
batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/BehPLS_errorOnlyRANK_ranked_pMod_BfMRIanalysis.txt');
% batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/BehPLS_errorOnly_ranked_abs_pMod_BfMRIanalysis.txt');
% batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/BehPLS_errorOnly_pMod_BfMRIanalysis.txt');
% batch_plsgui('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/BehPLS_errorOnly_ranked_pMod_BfMRIanalysis.txt');