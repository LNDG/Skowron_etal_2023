%% correlate pMod effects with BOLD SD effects
clear all

%% Beh PLS
% BOLD SD
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/allCond_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat','result');
usc_SD = result.usc(:,1);
usc_SD = tiedrank(usc_SD); % rerank
estim_error = result.stacked_behavdata(:,1);
clear result

% pMod
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/pMod_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat','result')
usc_pMod = result.usc(:,1);
usc_pMod = tiedrank(usc_pMod); % rerank
clear result

a=scatter(usc_SD,usc_pMod,120,estim_error,'filled')
a.MarkerEdgeColor = 'w';
%a.MarkerFaceColor = "#4DBEEE";
hline=refline;
hline.LineWidth=3;
%hline.Color=[0 0 0];

h = get(gca,'Children');
set(gca,'Children',[h(2) h(1)])

set(gca,'FontSize',32);

xticks([10:10:50])
yticks([10:10:50])
xlim([0 50])
ylim([0 50])
xlabel('Δ latent SD_B_O_L_D (rank)')
ylabel({'latent uncertainty' 'modulation (rank)'})

[r,pval]=corr(usc_SD,usc_pMod)
title(['r = ' num2str(round(corr(usc_SD,usc_pMod),3)) ', p = ' num2str(round(pval,4))])

% txt=['r = ' num2str(round(corr(usc_SD,usc_pMod),3))];
% yl=ylim;
% xl=xlim;
% text(xl(1)+500,yl(1)+500,txt,'FontSize',24);

colorbar

saveas(gcf,'figures/pMod_SD_corr.svg')

clf('reset')