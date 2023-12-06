% plot beh to brain and model parameters
clear all

load('win_model_beh.mat')
load('beh_measures','p_experienced','p_responses','sj_vec')

% %load wide and narrow prior reference subjects
% load('/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/sim_beh/Bayes_prior2/sim_ENT3051.mat','mean_traj') % narrow prior
% pred_narrow=mean_traj(:,end);
% clear mean_traj
% load('/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/sim_beh/Bayes_prior2/sim_ENT3009.mat','mean_traj') % wide prior
% pred_wide=mean_traj(:,end);
% clear mean_traj

%% plot experienced vs estimated p

% median split prior par
narrow_prior_subs = find(var_mat_org(:,3)>=median(var_mat_org(:,3)));
wide_prior_subs = find(var_mat_org(:,3)<median(var_mat_org(:,3)));

save('PriorSplit','narrow_prior_subs','wide_prior_subs')

% get unique p_experienced
p_exp_sampled=unique(p_experienced);

% make mask of narrow prior subjects
narrow_prior_mask=zeros(1,length(sj_vec));
for s = 1:length(narrow_prior_subs)
    narrow_prior_mask(sj_vec==narrow_prior_subs(s)) = deal(1);
end
narrow_prior_mask=logical(narrow_prior_mask);

% % make mask of wide prior subjects
% wide_prior_mask=zeros(1,length(sj_vec));
% for s = 1:length(wide_prior_subs)
%     wide_prior_mask(sj_vec==wide_prior_subs(s)) = deal(1);
% end
% wide_prior_mask=logical(wide_prior_mask);

% % get means for each reference p_experienced
% med_narrow_ref=nan(1,length(p_exp_sampled));
% med_wide_ref=nan(1,length(p_exp_sampled));
% 
% for s = 1:length(p_exp_sampled)
%     
%     narrow_data = p_experienced(sj_vec==17);
%     wide_data = p_experienced(sj_vec==3);
%     
%     med_narrow_ref(s)=median(pred_narrow(narrow_data==p_exp_sampled(s)));
%     med_wide_ref(s)=median(pred_wide(wide_data==p_exp_sampled(s)));
%     
% end

% get means for each samples p_experienced
med_narrow_prior=nan(1,length(p_exp_sampled));
med_wide_prior=nan(1,length(p_exp_sampled));

for s = 1:length(p_exp_sampled)
   
    med_narrow_prior(s)=median(p_responses(narrow_prior_mask & (p_experienced==p_exp_sampled(s))'));
    med_wide_prior(s)=median(p_responses(~narrow_prior_mask & (p_experienced==p_exp_sampled(s))'));
    
end

% plot
figure
hold on

% % boxplot
% 
% boxplot(p_responses(narrow_prior_mask),p_experienced(narrow_prior_mask),'positions',p_experienced(narrow_prior_mask)+0.001,'Widths',0.015,'Colors','b','MedianStyle','line','Symbol','','Whisker',0)
% j = findobj(gca,'Tag','Median');
% set(j,'Visible','off');
% set(findobj(gca,'type','line'),'linew',2)
% h=findobj('LineStyle','--'); set(h, 'LineStyle','-');
% 
% boxplot(p_responses(~narrow_prior_mask),p_experienced(~narrow_prior_mask),'positions',p_experienced(~narrow_prior_mask)-0.001,'Widths',0.015,'Colors','r','MedianStyle','line','Symbol','','Whisker',0)
% j = findobj(gca,'Tag','Median');
% set(j,'Visible','off');
% set(findobj(gca,'type','line'),'linew',2)
% h=findobj('LineStyle','--'); set(h, 'LineStyle','-');

% data
% plot(p_experienced(narrow_prior_mask),p_responses(narrow_prior_mask),'b.','MarkerSize',20)
% plot(p_experienced(~narrow_prior_mask),p_responses(~narrow_prior_mask),'r.','MarkerSize',20)

scatter1 = scatter(p_experienced(narrow_prior_mask),p_responses(narrow_prior_mask),55,'MarkerFaceColor',[0 0.4470 0.7410],'MarkerEdgeColor','w'); 
scatter1.MarkerFaceAlpha = .3;
% scatter1.MarkerEdgeAlpha = .2;

scatter2 = scatter(p_experienced(~narrow_prior_mask),p_responses(~narrow_prior_mask),55,'MarkerFaceColor',[0.4660 0.6740 0.1880],'MarkerEdgeColor','w'); 
scatter2.MarkerFaceAlpha = .3;
% scatter2.MarkerEdgeAlpha = .2;

% identity line
hline=refline(1,0);
hline.Color=[.7 .7 .7];
hline.LineWidth=2;

% medians
mp(1)=plot(p_exp_sampled,med_narrow_prior,'.-','LineWidth',2,'MarkerSize',50,'Color',[0 0.4470 0.7410]);
mp(2)=plot(p_exp_sampled,med_wide_prior,'.-','LineWidth',2,'MarkerSize',50,'Color',[0.4660 0.6740 0.1880]);

set(gca,'FontSize',32);
xlabel('experienced proportion blue marbles')
ylabel('estimated proportion blue marbles')

legend([mp(1) mp(2)],'narrow prior','wide prior','location','southeast')

hold off

%set(gcf,'PaperSize',[100 10]);
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 15, 10], 'PaperUnits', 'Inches', 'PaperSize', [15, 10])
saveas(gcf,['figures/exp_estim_marble_prop.svg'])

%clf('reset')

%% plot bias slope (win) - estim error (win) correlation

[r,pval]=corr(var_mat(:,2),var_mat(:,1))

a=scatter(var_mat(:,2),var_mat(:,1),120,'filled')
a.MarkerEdgeColor = 'w';
a.MarkerFaceColor = [0.4660 0.6740 0.1880];
a.MarkerFaceAlpha = 0.6;
hline=refline;
hline.LineWidth=3;
%hline.Color=[0 0 0];
set(gca,'FontSize',32);

h = get(gca,'Children');
set(gca,'Children',[h(2) h(1)])

xlim([min(var_mat(:,2))-0.1 max(var_mat(:,2))+0.1])
ylim([0 0.2])
xticks([-0.2:0.2:0.8])
yticks([0:0.05:0.2])

xlabel('extreme jar bias')
ylabel('estimation error')
title(['r = ' num2str(round(r,3)), ', p = ' num2str(round(pval,4))]);

% txt=['r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc'),2))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-15,yl(1)+5,txt,'FontSize',30);

saveas(gcf,['figures/biasSlope_estimError_corr.svg'])

clf('reset')

clear r pval

%% plot prior par (win, residualized) - estim error (win) semi-part corrleation

% get prior par residuals
X = [ones(size(var_mat,1),1) var_mat(:,4)];
betas = X\var_mat(:,3);

prior_par_res = var_mat(:,3) - (betas(1) + betas(2) .* var_mat(:,4));

% % get estim error residuals
% X = [ones(size(var_mat,1),1) var_mat(:,4)];
% betas = X\var_mat(:,1);
% 
% estim_res = var_mat(:,1) - (betas(1) + betas(2) .* var_mat(:,4));

% plot
[r,pval]=corr(prior_par_res,var_mat(:,1))

a=scatter(prior_par_res,var_mat(:,1),120,'filled')
a.MarkerEdgeColor = 'w';
a.MarkerFaceColor = [0.4660 0.6740 0.1880];
a.MarkerFaceAlpha = 0.6;
hline=refline;
hline.LineWidth=3;
%hline.Color=[0 0 0];
set(gca,'FontSize',32);

h = get(gca,'Children');
set(gca,'Children',[h(2) h(1)])

xlim([min(prior_par_res)-1 max(prior_par_res)+1])
ylim([0 0.2])
xticks([-4:2:8])
yticks([0:0.05:0.2])

xlabel({'prior parameter' '(residualized)'})
ylabel('estimation error')
title(['r = ' num2str(round(r,3)), ', p = ' num2str(round(pval,4))]);

% txt=['r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc'),2))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-15,yl(1)+5,txt,'FontSize',30);

saveas(gcf,['figures/priorRes_estimError_corr.svg'])

clf('reset')

clear r pval

%% plot noise par (win, residualized) - estim error (win) semi-part corrleation

% get noise par residuals
X = [ones(size(var_mat,1),1) var_mat(:,3)];
betas = X\var_mat(:,4);

noise_par_res = var_mat(:,4) - (betas(1) + betas(2) .* var_mat(:,3));

% % get estim error residuals
% X = [ones(size(var_mat,1),1) var_mat(:,4)];
% betas = X\var_mat(:,1);
% 
% estim_res = var_mat(:,1) - (betas(1) + betas(2) .* var_mat(:,4));

% plot
[r,pval]=corr(noise_par_res,var_mat(:,1))

a=scatter(noise_par_res,var_mat(:,1),120,'filled')
a.MarkerEdgeColor = 'w';
a.MarkerFaceColor = [0.4660 0.6740 0.1880];
a.MarkerFaceAlpha = 0.6;
hline=refline;
hline.LineWidth=3;
%hline.Color=[0 0 0];
set(gca,'FontSize',32);

h = get(gca,'Children');
set(gca,'Children',[h(2) h(1)])

xlim([min(noise_par_res)-0.01 max(noise_par_res)+0.01])
ylim([0 0.2])
xticks([-0.1:0.05:0.1])
yticks([0:0.05:0.2])

xlabel({'noise parameter' '(residualized)'})
ylabel('estimation error')
title(['r = ' num2str(round(r,3)), ', p = ' num2str(round(pval,4))]);

% txt=['r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc'),2))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-15,yl(1)+5,txt,'FontSize',30);

saveas(gcf,['figures/noiseRes_estimError_corr.svg'])

clf('reset')

clear r pval

%% plot prior par (rank, residualized, N47) - latent BOLD SD correlation

% get rank brain scores
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/allCond_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat','result')
rank_usc = tiedrank(result.usc);

% get rank prior par for N = 47
prior_par_rank = var_mat_org(:,3);
prior_par_rank([11,25,29,49]) = []; % N = 47 subset, see SPSS file
prior_par_rank = tiedrank(prior_par_rank);

% get residuals
noise_par_rank = var_mat_org(:,4);
noise_par_rank([11,25,29,49]) = []; % N = 47
noise_par_rank = tiedrank(noise_par_rank);

X = [ones(length(prior_par_rank),1) noise_par_rank];
betas = X\prior_par_rank;

prior_par_rank_res = prior_par_rank - (betas(1) + betas(2) .* noise_par_rank);

prior_par_rank_res = tiedrank(prior_par_rank_res);

% plot
[r,pval]=corr(prior_par_rank_res,rank_usc)

a=scatter(prior_par_rank_res,rank_usc,120,'filled')
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

xlabel({'prior parameter' '(rank residualized)'})
ylabel({'Δ latent SD_B_O_L_D' '(rank)'})
title(['r = ' num2str(round(r,3)), ', p = ' num2str(round(pval,4))]);

% txt=['r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc'),2))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-15,yl(1)+5,txt,'FontSize',30);

saveas(gcf,['figures/priorResRank_latentSDBOLDchange_N47_corr.svg'])

clf('reset')

clear r pval

%% plot prior par (rank, N47) - latent pMod correlation

% get rank brain scores
load('/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats/pMod_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat','result')
rank_usc_pMod = tiedrank(result.usc);

% plot
[r,pval]=corr(prior_par_rank_res,rank_usc_pMod)

a=scatter(prior_par_rank_res,rank_usc_pMod,120,'filled')
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

xlabel({'prior parameter' '(rank residualized)'})
ylabel({'latent uncertainty'; 'modulation (rank)'})
title(['r = ' num2str(round(r,3)), ', p = ' num2str(round(pval,4))]);

% txt=['r = ' num2str(round(corr(result.stacked_behavdata(:,1),rerank_usc'),2))];
% yl=ylim;
% xl=xlim;
% text(xl(2)-15,yl(1)+5,txt,'FontSize',30);

saveas(gcf,['figures/priorResRank_latentPMOD_N47_corr.svg'])

clf('reset')

clear r pval

% rerank_usc=tiedrank(result.usc(:,1));

%% raincloud plots for fitted model parameters (raw) - TODO, would need subplot for each variable because of different scales

% % plot
% c_idx = 1:length(); % location of condition subplots
% 
% figure('color','w');
% hold on
% 
% % plot half-violins
% [f,xi] = deal({},{});
% for i = 1:size(brain_scores,2)
%     %[f{i},xi{i}] = ksdensity( brain_scores(:,i) );
%     [f{i},xi{i}] = ksdensity( brain_scores(:,i) , linspace(prctile(brain_scores(:,i),1),prctile(brain_scores(:,i),99), 100 ));
%     scale = 0.5/max(f{i});
%     %patch(0-[f{i},zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)],'b','parent',plts(i) )
%     po(i)=patch(c_idx(i)-[f{i}.*scale,zeros(1,numel(xi{i}),1),0],[xi{i},fliplr(xi{i}),xi{i}(1)]+c_idx(i),'b')
%     po(i).FaceAlpha = 0.2;
% end
% 
% % plot data
% s=scatter(lv_evt_list + 0.125 + rand(1,length(lv_evt_list))*0.25,reshape(brain_scores,[1,255]),70,[0 0 0],'filled')
% s.MarkerFaceAlpha=0.2;
% 
% % plot medians
% plot(c_idx + 0.25, median(brain_scores),'ko-','MarkerSize',10,'LineWidth',2)
% 
% if result.perm_result.sprob(1) < 0.001
%     title(['LV p < 0.001']);
% else
%     title(['LV p = ' num2str(round(result.perm_result.sprob(1),3))]);
% end
% 
% %ylim([min(-result.boot_result.usc2(:,1))-ref_val,max(-result.boot_result.usc2(:,1))-40])
% ylim([0,numel(brain_scores)])
% xlim([0,max(c_idx)+0.5])
% xticks(c_idx)
% xticklabels({'s1' 's2' 's3' 's4' 's5'})
% 
% set(gca,'FontSize',30)
% 
% xlabel('sample')
% ylabel('latent SD_B_O_L_D (rank)')
% 
% hold off