%% Plot PLS results
clear all

pn.root = '/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/figures/';

addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/preprocessing_tools'))
addpath(genpath('/Users/skowron/Volumes/tardis1/toolboxes/NIfTI_20140122'))

%% samples SD

% task PLS
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/results/allCond/beta_datamats/TaskPLS_samples_ranked_allCond_BfMRIresult.mat');

cond_means_org = result.boot_result.orig_usc(:,1);
cond_means_CIhigh_org = result.boot_result.ulusc(:,1) - cond_means_org;
cond_means_CIlow_org = result.boot_result.llusc(:,1) - cond_means_org;

% transform variables for easier plotting and interpretation
% 1. flip brain salience for more intuitive interpretation
cond_means = -cond_means_org;
cond_means_CIhigh = -cond_means_CIlow_org;
cond_means_CIlow = -cond_means_CIhigh_org;

% % 2. change reference value (arbitrary value; just to make bars more visible)
ref_val = -5000;

cond_means = cond_means - ref_val;

b=bar(1:length(cond_name),cond_means)
b.FaceColor="#B5DBBF";
b.EdgeColor = "#B5DBBF";
hold on

errorbar(1:length(cond_name),cond_means,cond_means_CIlow,cond_means_CIhigh,'k','LineStyle','none','LineWidth',2)

% scatter(lv_evt_list,-(result.usc(:,1)-mean(result.usc(:,1))),45,[0 0 0],'filled') % flip sign of USC to plot flipped salience for more intuitive interpretation

set(gca,'FontSize',32);

xticks(1:5)
xticklabels({'s1' 's2' 's3' 's4' 's5'})
ylabel('latent MEAN_B_O_L_D (rank)')
xlabel('sample')

if result.perm_result.sprob(1) < 0.001
    title(['LV p < 0.001']);
else
    title(['LV p = ' num2str(round(result.perm_result.sprob(1),3))]);
end

hold off

saveas(gcf,[pn.root,'meanBOLD_TaskPLS_ranked.svg'])

clf('reset')