% create latent variable reflecting pMod effect size in BOLD SD change (beh pls) effect areas
clear all

% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/NIfTI_20140122'));
% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/preprocessing_tools'));

addpath(genpath('/Users/skowron/Volumes/tardis/LNDG/toolboxes/NIfTI_20140122'));
addpath(genpath('/Users/skowron/Volumes/tardis/LNDG/toolboxes/preprocessing_tools'));

PLS_result_path='/Users/skowron/Volumes/tardis/LNDG/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats';
GLM_result_path='/Users/skowron/Volumes/tardis/LNDG/Entscheidung2/analysis/GLM/results/pMod_var_norm';

%% beh PLS

% get brain salience for change effect

load('/Users/skowron/Volumes/tardis/LNDG/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/allCond_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat','result','subj_name')
SD_brain_scores = result.usc(:,1);
SD_brain_scores_rank = tiedrank(SD_brain_scores);
estim_error_rank = result.stacked_behavdata;
brain_sal = result.u;
clear result

subj_name = cellfun(@(x) x(4:end), subj_name, 'UniformOutput', false);

% load common coords
load('/Users/skowron/Volumes/tardis/LNDG/Entscheidung2/analysis/trial-wise_PLS/E_PLS/coords_samples/coords_EVAL.mat')

% get parametric modulation effect (use normative observer model so that beta reflects the scaling of a common regressor. In this case higher beta straight-forwardly reflects more predicted decline)

pMod_beta_mat=nan(length(subj_name),length(final_coords));

for i = 1:length(subj_name)
   
    pMod_img=double(S_load_nii_2d([GLM_result_path '/' subj_name{i} '/con_0007.nii']));
    
    pMod_beta_mat(i,:) = pMod_img(final_coords);
    
end

% % take absolute effect size because the direction of the
% % effect does not matter for the predicted variance
% pMod_beta_mat = abs(pMod_beta_mat);


% compute rank scores
for v = 1:size(pMod_beta_mat,2)

    pMod_beta_mat(:,v) = tiedrank(pMod_beta_mat(:,v));
    
end

% compute new latent variable reflecting pMod effect in BOLD SD change (beh
% pls) effect regions

pMod_brain_scores=nan(length(subj_name),1);

for i = 1:length(subj_name)

    pMod_brain_scores(i) = brain_sal' * pMod_beta_mat(i,:)';

end

pMod_brain_scores_rank = tiedrank(pMod_brain_scores);

save('pMod_control_var.mat','SD_brain_scores','SD_brain_scores_rank','estim_error_rank','pMod_brain_scores','pMod_brain_scores_rank');