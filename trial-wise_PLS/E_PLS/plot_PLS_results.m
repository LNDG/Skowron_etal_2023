%% Plot PLS results
clear all

pn.root = '/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/figures/';

addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/preprocessing_tools'))
addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/NIfTI_20140122'))

%% samples SD with prior median split groups

% load prior split groups
load('PriorSplit.mat')

% task PLS
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/TaskPLS_samples_ranked_allCond_BfMRIresult.mat');

% reshape transformed usc mat for group mean computation
usc2_mat = reshape(result.boot_result.usc2(:,1),[result.num_subj_lst,length(cond_name)]);

cond_means_org = result.boot_result.orig_usc(:,1);
cond_means_narrow_prior = mean(usc2_mat(narrow_prior_subs,:));
cond_means_wide_prior = mean(usc2_mat(wide_prior_subs,:));
cond_means_CIhigh_org = result.boot_result.ulusc(:,1) - cond_means_org;
cond_means_CIlow_org = result.boot_result.llusc(:,1) - cond_means_org;

% transform variables for easier plotting and interpretation
% 1. flip brain salience for more intuitive interpretation
cond_means = -cond_means_org;
cond_means_narrow_prior = -cond_means_narrow_prior;
cond_means_wide_prior = -cond_means_wide_prior;
cond_means_CIhigh = -cond_means_CIlow_org;
cond_means_CIlow = -cond_means_CIhigh_org;

% % 2. change reference value (arbitrary value; just to make bars more visible)
ref_val = -3100;

cond_means = cond_means - ref_val;
cond_means_narrow_prior = cond_means_narrow_prior - ref_val;
cond_means_wide_prior = cond_means_wide_prior - ref_val;


% b=bar(1:length(cond_name),cond_means)
% b.FaceColor="#4DBEEE";
% b.EdgeColor = "#4DBEEE";

figure
hold on

mp(1)=plot(1:length(cond_name),cond_means_narrow_prior,'o--','LineWidth',2,'MarkerSize',20,'Color',[0 0.4470 0.7410]); % narrow prior
mp(2)=plot(1:length(cond_name),cond_means_wide_prior,'o--','LineWidth',2,'MarkerSize',20,'Color',[0.4660 0.6740 0.1880]); % wide prior
mp(3)=plot(1:length(cond_name),cond_means,'.-','LineWidth',2,'MarkerSize',70,'Color','k'); % overall

legend([mp(1) mp(2) mp(3)],'narrow prior','wide prior','overall','location','southwest')

mp(4)=errorbar(1:length(cond_name),cond_means,cond_means_CIlow,cond_means_CIhigh,'k','LineStyle','none','LineWidth',2);

% scatter(lv_evt_list,-(result.usc(:,1)-mean(result.usc(:,1))),45,[0 0 0],'filled') % flip sign of USC to plot flipped salience for more intuitive interpretation

set(gca,'FontSize',32);

xticks(1:5)
xticklabels({'s1' 's2' 's3' 's4' 's5'})
xlim([0.75,5.25])
ylabel('latent SD_B_O_L_D (rank)')
xlabel('sample')

legend([mp(1) mp(2) mp(3)],'narrow prior','wide prior','overall','location','southwest')

if result.perm_result.sprob(1) < 0.001
    title(['LV p < 0.001']);
else
    title(['LV p = ' num2str(round(result.perm_result.sprob(1),3))]);
end

hold off

set(gcf, 'Units', 'Inches', 'Position', [0, 0, 15, 10], 'PaperUnits', 'Inches', 'PaperSize', [15, 10])
saveas(gcf,[pn.root,'TaskPLS_PriorSplit_ranked.svg'])

clf('reset')

%% samples SD

% task PLS
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/TaskPLS_samples_ranked_allCond_BfMRIresult.mat');

cond_means_org = result.boot_result.orig_usc(:,1);
cond_means_CIhigh_org = result.boot_result.ulusc(:,1) - cond_means_org;
cond_means_CIlow_org = result.boot_result.llusc(:,1) - cond_means_org;

% transform variables for easier plotting and interpretation
% 1. flip brain salience for more intuitive interpretation
cond_means = -cond_means_org;
cond_means_CIhigh = -cond_means_CIlow_org;
cond_means_CIlow = -cond_means_CIhigh_org;

% % 2. change reference value (arbitrary value; just to make bars more visible)
ref_val = -2100;

cond_means = cond_means - ref_val;

b=bar(1:length(cond_name),cond_means)
b.FaceColor="#4DBEEE";
b.EdgeColor = "#4DBEEE";
hold on

errorbar(1:length(cond_name),cond_means,cond_means_CIlow,cond_means_CIhigh,'k','LineStyle','none','LineWidth',2)

% scatter(lv_evt_list,-(result.usc(:,1)-mean(result.usc(:,1))),45,[0 0 0],'filled') % flip sign of USC to plot flipped salience for more intuitive interpretation

set(gca,'FontSize',32);

xticks(1:5)
xticklabels({'s1' 's2' 's3' 's4' 's5'})
ylabel('latent SD_B_O_L_D (rank)')
xlabel('sample')

if result.perm_result.sprob(1) < 0.001
    title(['LV p < 0.001']);
else
    title(['LV p = ' num2str(round(result.perm_result.sprob(1),3))]);
end

hold off

saveas(gcf,[pn.root,'TaskPLS_ranked.svg'])

clf('reset')

% %% samples SD - orig brainscores
% 
% % task PLS
% load('/Users/skowron/Volumes/tardis/LNDG/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/TaskPLS_samples_ranked_allCond_BfMRIresult.mat');
% 
% cond_means_org = result.boot_result.orig_usc(:,1);
% cond_means_CIhigh_org = result.boot_result.ulusc(:,1) - cond_means_org;
% cond_means_CIlow_org = result.boot_result.llusc(:,1) - cond_means_org;
% 
% brain_scores = reshape(result.boot_result.usc2(:,1),[51,5]);
% 
% % transform variables for easier plotting and interpretation
% % 1. flip brain salience for more intuitive interpretation
% cond_means = -cond_means_org;
% cond_means_CIhigh = -cond_means_CIlow_org;
% cond_means_CIlow = -cond_means_CIhigh_org;
% 
% brain_scores=-brain_scores;
% 
% % % 2. change reference value (arbitrary value; just to make bars more visible)
% ref_val = -40;
% 
% cond_means = cond_means - ref_val;
% brain_scores = brain_scores - ref_val;
% 
% % plot
% 
% c_idx = unique(lv_evt_list).*2; % location of condition subplots
% 
% figure('color','w');
% hold on
% 
% % plot half-violins
% [f,xi] = deal({},{});
% for i = 1:size(brain_scores,2)
%     %[f{i},xi{i}] = ksdensity( brain_scores(:,i) );
%     [f{i},xi{i}] = ksdensity( brain_scores(:,i) , linspace(prctile(brain_scores(:,i),1),prctile(brain_scores(:,i),99), 100 ));
%     scale = 1/max(f{i});
%     %patch(0-[f{i},zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)],'b','parent',plts(i) )
%     po(i)=patch(c_idx(i)-[f{i}.*scale,zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)]+c_idx(i),'b')
%     po(i).FaceAlpha = 0.2;
% end
% 
% % plot data
% s=scatter(lv_evt_list.*2 + 0.25 + rand(1,length(lv_evt_list))*0.5,reshape(brain_scores,[1,255]),70,[0 0 0],'filled')
% s.MarkerFaceAlpha=0.2;
% 
% % plot BS means and CIs
% b=plot(c_idx+0.5,cond_means,'ko-','MarkerSize',15,'LineWidth',2);
% 
% errorbar(c_idx+0.5,cond_means,cond_means_CIlow,cond_means_CIhigh,'k','LineStyle','none','LineWidth',2)
% 
% if result.perm_result.sprob(1) < 0.001
%     title(['LV p < 0.001']);
% else
%     title(['LV p = ' num2str(round(result.perm_result.sprob(1),3))]);
% end
% 
% xlim([0.5,max(c_idx)+1])
% xticks(c_idx)
% xticklabels({'s1' 's2' 's3' 's4' 's5'})
% 
% set(gca,'FontSize',30)
% 
% xlabel('sample')
% ylabel('latent SD_B_O_L_D (rank)')
% 
% hold off
% 
% %saveas(gcf,[pn.root,'samples_rain_TaskPLS_LV1.jpg'])
% % 
% % clf('reset')
% 

% %% Beh PLS
% 
% load('/Users/skowron/Volumes/tardis6/Entscheidung2/analysis/trial-wise_PLS/results/samples/sd_datamats/samples_ranked_errorOnly_exOut_BehPLS_BfMRIresult.mat');
% 
% a=scatter(result.stacked_behavdata(:,1),result.usc(:,1),80,'filled')
% a.MarkerEdgeColor = 'w';
% a.MarkerFaceColor = "#4DBEEE";
% hline=refline;
% hline.LineWidth=2;
% hline.Color=[0 0 0];
% set(gca,'FontSize',24);
% 
% xlabel('estimation error (rank)')
% ylabel('Δ latent BOLD SD (rank)')
% title(['LV p = ' num2str(round(result.perm_result.sprob(1),3))]);
% 
% txt=['r = ' num2str(round(result.lvcorrs,3))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-10,yl(1)+500,txt,'FontSize',24);
% 
% saveas(gcf,[pn.root,'samples_BehPLS_errorOnly_exOut_LV1.jpg'])
% 
% clf('reset')

%% Beh PLS (reranked)

load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/allCond_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat');

rerank_usc=tiedrank(result.usc(:,1));
% [~,rank_idx] = sort(result.usc(:,1));
% rerank_usc = 1:length(result.usc(:,1));
% rerank_usc(rank_idx) = rerank_usc;

a=scatter(result.stacked_behavdata(:,1),rerank_usc,120,'filled')
a.MarkerEdgeColor = 'w';
a.MarkerFaceColor = 'b';
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
ylabel('Δ latent SD_B_O_L_D (rank)')
title(['LV p = ' num2str(round(result.perm_result.sprob(1),3)) ', r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc),2))]);

[r,p]=corr(result.stacked_behavdata(:,1),rerank_usc)


% txt=['r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc'),2))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-15,yl(1)+5,txt,'FontSize',30);

saveas(gcf,[pn.root,'allCond_BehPLS_rerank_errorOnly_N47_LV1.svg'])

clf('reset')

%% Beh PLS (reranked) - N51

load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/allCond_ranked_errorOnlyRANK_BehPLS_BfMRIresult.mat');

rerank_usc=tiedrank(result.usc(:,1));
% [~,rank_idx] = sort(result.usc(:,1));
% rerank_usc = 1:length(result.usc(:,1));
% rerank_usc(rank_idx) = rerank_usc;

a=scatter(result.stacked_behavdata(:,1),rerank_usc,120,'filled')
a.MarkerEdgeColor = 'w';
a.MarkerFaceColor = 'b';
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
ylabel('Δ latent SD_B_O_L_D (rank)')
title(['LV p = ' num2str(round(result.perm_result.sprob(1),3)) ', r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc),2))]);

[r,p]=corr(result.stacked_behavdata(:,1),rerank_usc)

% txt=['r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc'),2))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-15,yl(1)+5,txt,'FontSize',30);

saveas(gcf,[pn.root,'N51/allCond_BehPLS_rerank_errorOnly_N51_LV1.svg'])

clf('reset')

%% plot median BOLD SD in effect regions (BSR > 3) for Beh PLS results (N=47)

load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/allCond_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat');

% ---get median SD---

% get voxels of behavioural PLS effect

PLS_result_path = '/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats';

fname = '/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/figures/allCond_ranked_errorOnlyRANK_N47_BehPLS_BfMRIbsr_lv1.nii.gz';

Beh_PLS_effect_mask = double(S_load_nii_2d( fname ));
clear fname

mask_coords_pos = find(Beh_PLS_effect_mask > 0);

% load common coords
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/E_PLS/coords_EVAL.mat')

%find mask coords in common coords

[~,~,mask_coords_pos]=intersect(mask_coords_pos,final_coords);

% get subjects SD BOLD in pos effect voxels

SD_pos_effect = nan(length(subj_name),length(mask_coords_pos));

for i = 1:length(subj_name)
   
    load([PLS_result_path '/' subj_name{i} '_BfMRIsessiondata.mat'], 'st_datamat');
    
    SD_pos_effect(i,:) = st_datamat(8,mask_coords_pos);
    
end

median_SD_pos_effect = median(SD_pos_effect,2);

% ---plot---

c_idx = unique(lv_evt_list); % location of condition subplots

figure('color','w');

hold on

% plot half-violins
[f,xi] = deal({},{});
for i = 1:size(median_SD_pos_effect,2)
    [f{i},xi{i}] = ksdensity( median_SD_pos_effect(:,i) );
    %[f{i},xi{i}] = ksdensity( median_SD_pos_effect(:,i) , linspace(prctile(median_SD_pos_effect(:,i),1),prctile(median_SD_pos_effect(:,i),99), 100 ));
    scale = 0.5/max(f{i});
    %patch(0-[f{i},zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)],'b','parent',plts(i) )
    po(i)=patch(c_idx(i)-[f{i}.*scale,zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)],'r')
    po(i).FaceAlpha = 0.4;
end

% plot data
s=scatter(lv_evt_list + 0.05 + rand(1,length(lv_evt_list))*0.1,median_SD_pos_effect,120,[0 0 0],'filled')
s.MarkerEdgeColor = 'w';
s.MarkerFaceColor = 'k';
s.MarkerFaceAlpha = 0.6;

% plot medians
plot(c_idx, median(median_SD_pos_effect),'diamondk','MarkerSize',20,'LineWidth',2)

%ylim([min(-result.boot_result.usc2(:,1))-ref_val,max(-result.boot_result.usc2(:,1))-40])
%ylim([0,numel(median_SD_pos_effect)])
xlim([0.4,max(c_idx)+0.2])
xticks(c_idx)
xticklabels({''})

set(gca,'FontSize',30)

ylabel('median Δ SD_B_O_L_D in positive effect voxels (BSR > 3)')

hold off

set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPosition', [0 0 6 12]);

saveas(gcf,[pn.root,'rain_allCond_BehPLS_rerank_errorOnly_N47_LV1.svg'])

clf('reset')