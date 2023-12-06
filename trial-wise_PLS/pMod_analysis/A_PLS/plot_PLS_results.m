%% Plot PLS results
clear all

pn.root = '/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/figures/';

addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/preprocessing_tools'))
addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/NIfTI_20140122'))

%% Beh PLS (reranked)

load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/pMod_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat');

rerank_usc=tiedrank(result.usc(:,1));
% [~,rank_idx] = sort(result.usc(:,1));
% rerank_usc = 1:length(result.usc(:,1));
% rerank_usc(rank_idx) = rerank_usc;

a=scatter(result.stacked_behavdata(:,1),rerank_usc,120,'filled')
a.MarkerEdgeColor = 'w';
a.MarkerFaceColor = 'r';
a.MarkerFaceAlpha = 0.6;
hline=refline;
hline.LineWidth=3;
%hline.Color=[0 0 0];
set(gca,'FontSize',32);

h = get(gca,'Children');
set(gca,'Children',[h(2) h(1)])

xticks([10:10:50])
yticks([10:10:50])
xlim([0 50])
ylim([0 50])
xlabel('estimation error (rank)')
ylabel({'latent uncertainty'; 'modulation (rank)'})
title(['LV p = ' num2str(round(result.perm_result.sprob(1),3)) ', r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc),2))]);

[r,p] = corr(result.stacked_behavdata(:,1),rerank_usc)

% txt=['r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc'),2))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-15,yl(1)+5,txt,'FontSize',30);

saveas(gcf,[pn.root,'pMod_BehPLS_rerank_errorOnlyRank_N47_LV1.svg'])

clf('reset')

%% Beh PLS (reranked) - N51

load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/pMod_ranked_errorOnlyRANK_BehPLS_BfMRIresult.mat');

rerank_usc=tiedrank(result.usc(:,1));
% [~,rank_idx] = sort(result.usc(:,1));
% rerank_usc = 1:length(result.usc(:,1));
% rerank_usc(rank_idx) = rerank_usc;

a=scatter(result.stacked_behavdata(:,1),rerank_usc,120,'filled')
a.MarkerEdgeColor = 'w';
a.MarkerFaceColor = 'r';
a.MarkerFaceAlpha = 0.6;
hline=refline;
hline.LineWidth=3;
%hline.Color=[0 0 0];
set(gca,'FontSize',32);

h = get(gca,'Children');
set(gca,'Children',[h(2) h(1)])

xticks([10:10:50])
yticks([10:10:50])
xlim([0 50])
ylim([0 50])
xlabel('estimation error (rank)')
ylabel({'latent uncertainty'; 'modulation (rank)'})
title(['LV p = ' num2str(round(result.perm_result.sprob(1),3)) ', r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc),2))]);

[r,p] = corr(result.stacked_behavdata(:,1),rerank_usc)

% txt=['r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc'),2))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-15,yl(1)+5,txt,'FontSize',30);

saveas(gcf,[pn.root,'N51/pMod_BehPLS_rerank_errorOnlyRank_N51_LV1.svg'])

clf('reset')

%% plot median BOLD SD in effect regions (BSR > and < 3 separately) for Beh PLS results (N=47)

load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/pMod_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat');

% ---get median SD---

% get voxels of behavioural PLS effect

PLS_result_path = '/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats';

fname = '/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/figures/pMod_ranked_errorOnlyRANK_N47_BehPLS_BfMRIbsr_lv1.nii.gz';

Beh_PLS_effect_mask = double(S_load_nii_2d( fname ));
clear fname

mask_coords_pos = find(Beh_PLS_effect_mask > 0);
mask_coords_neg = find(Beh_PLS_effect_mask < 0);

% load common coords
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/A_PLS/coords_EVAL.mat')

%find mask coords in common coords

[~,~,mask_coords_pos]=intersect(mask_coords_pos,final_coords);
[~,~,mask_coords_neg]=intersect(mask_coords_neg,final_coords);

% get subjects SD BOLD in pos effect voxels

pMod_pos_effect = nan(length(subj_name),length(mask_coords_pos));
pMod_neg_effect = nan(length(subj_name),length(mask_coords_neg));

for i = 1:length(subj_name)
   
    load([PLS_result_path '/' subj_name{i} '_BfMRIsessiondata.mat'], 'st_datamat');
    
    pMod_pos_effect(i,:) = st_datamat(1,mask_coords_pos);
    pMod_neg_effect(i,:) = st_datamat(1,mask_coords_neg);
    
end

median_pMod_pos_effect = median(pMod_pos_effect,2);
median_pMod_neg_effect = median(pMod_neg_effect,2);

% ---plot pos effect---

c_idx = unique(lv_evt_list); % location of condition subplots

figure('color','w');

hold on

% plot half-violins
[f,xi] = deal({},{});
for i = 1:size(median_pMod_pos_effect,2)
    [f{i},xi{i}] = ksdensity( median_pMod_pos_effect(:,i) );
    %[f{i},xi{i}] = ksdensity( median_SD_pos_effect(:,i) , linspace(prctile(median_SD_pos_effect(:,i),1),prctile(median_SD_pos_effect(:,i),99), 100 ));
    scale = 0.5/max(f{i});
    %patch(0-[f{i},zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)],'b','parent',plts(i) )
    po(i)=patch(c_idx(i)-[f{i}.*scale,zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)],'r')
    po(i).FaceAlpha = 0.4;
end

% plot data
s=scatter(lv_evt_list + 0.05 + rand(1,length(lv_evt_list))*0.1,median_pMod_pos_effect,120,[0 0 0],'filled')
s.MarkerEdgeColor = 'w';
s.MarkerFaceColor = 'k';
s.MarkerFaceAlpha = 0.6;

% plot medians
plot(c_idx, median(median_pMod_pos_effect),'diamondk','MarkerSize',20,'LineWidth',2)

%ylim([min(-result.boot_result.usc2(:,1))-ref_val,max(-result.boot_result.usc2(:,1))-40])
%ylim([0,numel(median_SD_pos_effect)])
xlim([0.4,max(c_idx)+0.2])
xticks(c_idx)
xticklabels({''})

set(gca,'FontSize',30)

ylabel('median unc. mod. in positive effect voxels (BSR > 3)')

hold off

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0 0 6 12]);

saveas(gcf,[pn.root,'rain_pos_pMod_BehPLS_rerank_errorOnlyRank_N47_LV1.svg'])

clf('reset')

% ---plot neg effect---

c_idx = unique(lv_evt_list); % location of condition subplots

figure('color','w');

hold on

% plot half-violins
[f,xi] = deal({},{});
for i = 1:size(median_pMod_neg_effect,2)
    [f{i},xi{i}] = ksdensity( median_pMod_neg_effect(:,i) );
    %[f{i},xi{i}] = ksdensity( median_SD_pos_effect(:,i) , linspace(prctile(median_SD_pos_effect(:,i),1),prctile(median_SD_pos_effect(:,i),99), 100 ));
    scale = 0.5/max(f{i});
    %patch(0-[f{i},zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)],'b','parent',plts(i) )
    po(i)=patch(c_idx(i)-[f{i}.*scale,zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)],'b')
    po(i).FaceAlpha = 0.4;
end

% plot data
s=scatter(lv_evt_list + 0.05 + rand(1,length(lv_evt_list))*0.1,median_pMod_neg_effect,120,[0 0 0],'filled')
s.MarkerEdgeColor = 'w';
s.MarkerFaceColor = 'k';
s.MarkerFaceAlpha = 0.6;

% plot medians
plot(c_idx, median(median_pMod_neg_effect),'diamondk','MarkerSize',20,'LineWidth',2)

%ylim([min(-result.boot_result.usc2(:,1))-ref_val,max(-result.boot_result.usc2(:,1))-40])
%ylim([0,numel(median_SD_pos_effect)])
xlim([0.4,max(c_idx)+0.2])
xticks(c_idx)
xticklabels({''})

set(gca,'FontSize',30)

ylabel('median unc. mod. in negative effect voxels (BSR < 3)')

hold off

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0 0 6 12]);

saveas(gcf,[pn.root,'rain_neg_pMod_BehPLS_rerank_errorOnlyRank_N47_LV1.svg'])

clf('reset')