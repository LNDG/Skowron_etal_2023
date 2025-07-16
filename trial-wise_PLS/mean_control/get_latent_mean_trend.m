% create latent variable reflecting mean effect size in BOLD SD change (beh pls) effect areas
% use s5-s1 to relax linearity assumption
clear all

% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/NIfTI_20140122'));
% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/preprocessing_tools'));

addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/NIfTI_20140122'));
addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/preprocessing_tools'));

PLS_result_path='/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats';
pn.sdniftis = '/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/data/mean_niftis_allCond/';

SessionID={'1' '2' '3' '4' '5'};
% s1 s2 s3 s4 s5

%% beh PLS

% get brain salience for delta SDbold effect

load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/allCond_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat','result','subj_name')
SD_brain_scores = result.usc(:,1);
SD_brain_scores_rank = tiedrank(SD_brain_scores);
estim_error_rank = result.stacked_behavdata;
brain_sal = result.u;
clear result

subj_name = cellfun(@(x) x(4:end), subj_name, 'UniformOutput', false);

% load common coords
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/E_PLS/coords_samples/coords_EVAL.mat')

%% get meanBold trends

mean_lin_trend_mat=nan(length(subj_name),length(final_coords));
mean_quad_trend_mat=nan(length(subj_name),length(final_coords));
mean_cubic_trend_mat=nan(length(subj_name),length(final_coords));

for i = 1:length(subj_name)
    
    fprintf(['Getting MEAN BOLD trend for ' subj_name{i} '\n'])
    
    % load subject values for corresponding coordinates
    st_datamat_sub = nan(length(SessionID),length(final_coords));
    
    for indCond = 1:length(SessionID)
        fname = dir([pn.sdniftis, subj_name{i} '/con_000' SessionID{indCond} '.nii' ]);
        fname = fname.name;
        
        img = double(S_load_nii_2d([pn.sdniftis, subj_name{i} '/' fname])); clear fname;
        img = img(final_coords,:); % restrict to final_coords
        
        st_datamat_sub(indCond,:) = img;
        clear img
    end
    
    % compute mean trends
    
    % linear

    X = [ones(length(SessionID),1) [-2 -1 0 1 2]']; % linear contrast

    for vox = 1:size(st_datamat_sub,2)

        % compute and add linear trend across samples for each voxel
        betas = X\st_datamat_sub(1:length(SessionID),vox);
        mean_lin_trend_mat(i,vox) = betas(2);

    end

    clear X betas
    
    % quadratic
    
    X = [ones(length(SessionID),1) [2 -1 -2 -1 2]']; % quadratic contrast

    for vox = 1:size(st_datamat_sub,2)

        % compute and add linear trend across samples for each voxel
        betas = X\st_datamat_sub(1:length(SessionID),vox);
        mean_quad_trend_mat(i,vox) = betas(2);

    end

    clear X betas
    
    
    % cubic
    
    X = [ones(length(SessionID),1) [-1 2 0 -2 1]']; % cubic contrast

    for vox = 1:size(st_datamat_sub,2)

        % compute and add linear trend across samples for each voxel
        betas = X\st_datamat_sub(1:length(SessionID),vox);
        mean_cubic_trend_mat(i,vox) = betas(2);

    end

    clear X betas
    
    
    clear st_datamat_sub
    
end


% compute rank scores

%linear
for v = 1:size(mean_lin_trend_mat,2)

    mean_lin_trend_mat(:,v) = tiedrank(mean_lin_trend_mat(:,v));
    
end

%quadratic
for v = 1:size(mean_quad_trend_mat,2)

    mean_quad_trend_mat(:,v) = tiedrank(mean_quad_trend_mat(:,v));
    
end

%cubic
for v = 1:size(mean_cubic_trend_mat,2)

    mean_cubic_trend_mat(:,v) = tiedrank(mean_cubic_trend_mat(:,v));
    
end

% compute new latent variable reflecting mean trend effects in delta BOLD SD change (beh
% pls) effect regions

%linear
mean_lin_trend_brain_scores=nan(length(subj_name),1);

for i = 1:length(subj_name)

    mean_lin_trend_brain_scores(i) = brain_sal' * mean_lin_trend_mat(i,:)';

end

mean_lin_trend_brain_scores_rank = tiedrank(mean_lin_trend_brain_scores);

%quadratic
mean_quad_trend_brain_scores=nan(length(subj_name),1);

for i = 1:length(subj_name)

    mean_quad_trend_brain_scores(i) = brain_sal' * mean_quad_trend_mat(i,:)';

end

mean_quad_trend_brain_scores_rank = tiedrank(mean_quad_trend_brain_scores);

%cubic
mean_cubic_trend_brain_scores=nan(length(subj_name),1);

for i = 1:length(subj_name)

    mean_cubic_trend_brain_scores(i) = brain_sal' * mean_cubic_trend_mat(i,:)';

end

mean_cubic_trend_brain_scores_rank = tiedrank(mean_cubic_trend_brain_scores);

%% save stuff

save('mean_trend_control_var.mat','estim_error_rank','SD_brain_scores','SD_brain_scores_rank','mean_lin_trend_brain_scores','mean_lin_trend_brain_scores_rank','mean_quad_trend_brain_scores','mean_quad_trend_brain_scores_rank','mean_cubic_trend_brain_scores','mean_cubic_trend_brain_scores_rank');