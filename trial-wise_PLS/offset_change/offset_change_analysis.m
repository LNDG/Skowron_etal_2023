%check if prior width parameter explains BOLD SD offset in change effect
%regions

clear all

% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/NIfTI_20140122'));
% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/preprocessing_tools'));

addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/NIfTI_20140122'));
addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/preprocessing_tools'));

SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};
% PLS_result_path='/Users/skowron/Volumes/tardis2/Entscheidung2/analysis/trial-wise_PLS/results/samples/sd_datamats';
% GLM_result_path='/Users/skowron/Volumes/tardis2/Entscheidung2/analysis/GLM/results/pMod_var_norm';

PLS_result_path='/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats';

% get brain salience for change effect

load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/allCond_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat','result','subj_name')
SD_change_brain_scores = result.usc;
brain_sal = result.u;
clear result

% compute latent BOLD SD offset reflecting BOLD SD offset in change effect
% regions

SD_s1_brainScore = [];

for i = 1:length(subj_name)
   
    load([PLS_result_path '/' subj_name{i} '_BfMRIsessiondata.mat'], 'st_datamat');
    
    SD_s1_brainScore = [SD_s1_brainScore; (brain_sal' * (st_datamat(1,:))')];
    
end

% rank brain scores
SD_brainScore_rank=tiedrank(SD_change_brain_scores);
% [~,rank_idx] = sort(SD_Brain_scores);
% SD_brainScore_rank = 1:length(SD_Brain_scores);
% SD_brainScore_rank(rank_idx) = SD_brainScore_rank;
% SD_brainScore_rank=SD_brainScore_rank';

% rank s1 brain scores
SD_s1_brainScore_rank=tiedrank(SD_s1_brainScore);
% [~,rank_idx] = sort(SD_s1_brainScore);
% SD_s1_brainScore_rank = 1:length(SD_s1_brainScore);
% SD_s1_brainScore_rank(rank_idx) = SD_s1_brainScore_rank;
% SD_s1_brainScore_rank=SD_s1_brainScore_rank';

% get prior par residuals
load('/Users/skowron/Documents/Entscheidung2_dump/behaviour/win_model_beh.mat')

% get N=47 subset
subj_subset=cellfun(@(x) x(4:end), subj_name,'UniformOutput',false);
map_idx=nan(1,length(subj_subset));
for sub = 1:length(subj_subset)
   map_idx(sub)=find(cell2mat(cellfun(@(x) strcmp(x,subj_subset{sub}), SubjectID, 'UniformOutput', false))); 
end

% get rank prior par for N = 47
prior_par_rank = var_mat_org(:,3);
prior_par_rank = prior_par_rank(map_idx); % N = 47
prior_par_rank = tiedrank(prior_par_rank);

% get residuals
noise_par_rank = var_mat_org(:,4);
noise_par_rank = noise_par_rank(map_idx); % N = 47
noise_par_rank = tiedrank(noise_par_rank);

X = [ones(length(prior_par_rank),1) noise_par_rank];
betas = X\prior_par_rank;

prior_par_rank_res = prior_par_rank - (betas(1) + betas(2) .* noise_par_rank);

prior_par_rank_res = tiedrank(prior_par_rank_res);

% get estim error

estim_error_rank=tiedrank(var_mat_org(map_idx,1));


%% save variables
save('offset_change_control_var.mat','SD_brainScore_rank','SD_s1_brainScore_rank','prior_par_rank_res','estim_error_rank')

%% plot offset-change corr
a=scatter(SD_brainScore_rank,SD_s1_brainScore_rank,80,'filled')
a.MarkerEdgeColor = 'w';
%a.MarkerFaceColor = "#8E44AD";
hline=refline;
hline.LineWidth=2;
hline.Color=[0 0 0];
set(gca,'FontSize',26);

xticks([10:10:50])
yticks([10:10:50])
xlim([0 60])
ylim([0 60])
xlabel('latent ΔSD_B_O_L_D (rank)')
ylabel('latent SD_B_O_L_D at s1 (rank)')
%title(['p = 0.004']); % p-value of full GLM, see SPSS output

[~,p]=corr(SD_brainScore_rank,SD_s1_brainScore_rank);
p=round(p,2);
title(['p = ' num2str(p)])
txt=['r = ' num2str(round(corr(SD_brainScore_rank,SD_s1_brainScore_rank),2),'%4.2f')];
yl=ylim;
xl=xlim;
text(xl(2)-15,yl(1)+6,txt,'FontSize',30);

saveas(gcf,'s1_change_BS.jpg')

clf('reset')

%% plot prior brain score offset corr
a=scatter(prior_par_rank_res,SD_s1_brainScore_rank,80,'filled')
a.MarkerEdgeColor = 'w';
%a.MarkerFaceColor = "#8E44AD";
hline=refline;
hline.LineWidth=2;
hline.Color=[0 0 0];
set(gca,'FontSize',26);

xticks([10:10:50])
yticks([10:10:50])
xlim([0 60])
ylim([0 60])
xlabel('prior width residualized (rank)')
ylabel('latent SD_B_O_L_D at s1 (rank)')
%title(['p = 0.004']); % p-value of full GLM, see SPSS output

[~,p]=corr(prior_par_rank_res,SD_s1_brainScore_rank);
p=round(p,2);
title(['p = ' num2str(p)])
txt=['r = ' num2str(round(corr(prior_par_rank_res,SD_s1_brainScore_rank),2),'%4.2f')];
yl=ylim;
xl=xlim;
text(xl(2)-15,yl(1)+6,txt,'FontSize',30);

saveas(gcf,'s1_prior_BS.jpg')

clf('reset')

%% plot estim error brain score offset corr
a=scatter(estim_error_rank,SD_s1_brainScore_rank,80,'filled')
a.MarkerEdgeColor = 'w';
%a.MarkerFaceColor = "#8E44AD";
hline=refline;
hline.LineWidth=2;
hline.Color=[0 0 0];
set(gca,'FontSize',26);

xticks([10:10:50])
yticks([10:10:50])
xlim([0 60])
ylim([0 60])
xlabel('estimation error (rank)')
ylabel('latent SD_B_O_L_D at s1 (rank)')
%title(['p = 0.004']); % p-value of full GLM, see SPSS output

[~,p]=corr(estim_error_rank,SD_s1_brainScore_rank);
p=round(p,2);
title(['p = ' num2str(p)])
txt=['r = ' num2str(round(corr(estim_error_rank,SD_s1_brainScore_rank),2),'%4.2f')];
yl=ylim;
xl=xlim;
text(xl(2)-15,yl(1)+6,txt,'FontSize',30);

saveas(gcf,'s1_estim_error_BS.jpg')

clf('reset')