% check positive and negative BSR regions to interpret effect. (note: this model excludes variance outliers)
clear all

% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/NIfTI_20140122'));
% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/preprocessing_tools'));

addpath(genpath('/Users/skowron/Volumes/tardis/LNDG/toolboxes/NIfTI_20140122'));
addpath(genpath('/Users/skowron/Volumes/tardis/LNDG/toolboxes/preprocessing_tools'));

% get info
load('/Users/skowron/Volumes/tardis/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/pMod_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat','result','subj_name')
estim_error_rank = result.stacked_behavdata;


PLS_result_path='/Users/skowron/Volumes/tardis/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats';

%% --- correlation between BOLD SD trend and pMod beta for each voxel ---
%% beh PLS

% get voxels of behavioural PLS effect

fname = '/Users/skowron/Volumes/tardis/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/figures/pMod_ranked_errorOnlyRANK_N47_BehPLS_BfMRIbsr_lv1.nii.gz';

Beh_PLS_effect_mask = double(S_load_nii_2d( fname ));
clear fname

mask_coords_pos = find(Beh_PLS_effect_mask > 0);
mask_coords_neg = find(Beh_PLS_effect_mask < 0);

% load common coords
load('/Users/skowron/Volumes/tardis/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/A_PLS/coords_EVAL.mat')

%find mask coords in common coords

[~,~,mask_coords_pos]=intersect(mask_coords_pos,final_coords);
[~,~,mask_coords_neg]=intersect(mask_coords_neg,final_coords);

% get subjects pMod in pos effect voxels

pMod_pos_effect = nan(length(subj_name),length(mask_coords_pos));
pMod_neg_effect = nan(length(subj_name),length(mask_coords_neg));

for i = 1:length(subj_name)
   
    load([PLS_result_path '/' subj_name{i} '_BfMRIsessiondata.mat'], 'st_datamat');
    
    pMod_pos_effect(i,:) = st_datamat(1,mask_coords_pos);
    pMod_neg_effect(i,:) = st_datamat(1,mask_coords_neg);
    
end

% plot median pMod effect against estimation error
plot(estim_error_rank,median(pMod_pos_effect,2),'bo')
title('pMod effect in BSR > 3 regions')
ylabel('median pMod effect')
xlabel('estimation error (rank)')
lsline

pause

% get subjects pMod in neg effect voxels

% plot median pMod effect against estimation error
plot(estim_error_rank,median(pMod_neg_effect,2),'bo')
title('pMod effect in BSR < 3 regions')
ylabel('median pMod effect')
xlabel('estimation error (rank)')
lsline

pause

% correlation between pMod effects

plot(median(pMod_pos_effect,2),median(pMod_neg_effect,2),'bo')
ylabel('median pMod effect in neg BSRs')
xlabel('median pMod effect in pos BSRs')
lsline
