% plot brain score - prior par correlation residualising for noise par
clear all

prior_rank_res=[19.55282 -23.46124 -8.76411 8.54579 -13.2148 -10.98945 -8.55985 -4.22183 -3.32747 0.89084 8.77114 -14.89787 9.87678 -1.03876 -12.10213 14.2148 9.98242 7.79223 8.65846 -13.77114 -10.89084 13.56688 -7.0951 -2.00352 8.98945 -12.65846 18.45421 2.11619 0.32747 -8.79223 4.43312 4.88381 2.22183 6.65143 -0.9049 -4.37678 -17.66549 16.67956 4.34857 22.44718 -4.33451 -19.67956 12.00352 6.55985 -5.98242 -3.23589]';

[~,rank_idx] = sort(prior_rank_res);
prior_rank_res_rank = 1:length(prior_rank_res);
prior_rank_res_rank(rank_idx) = prior_rank_res_rank;
prior_rank_res_rank=prior_rank_res_rank';

prior_rank=[45 12 5 39 5 5 18 19 16 23 37 15 42 10.5 5 43 46 21 38 5 14 29 5 24 40 5 35 22 28 25 36 32 26 41 34 10.5 5 31 17 44 20 13 33 27 5 30]';
brain_rank=[44 5 2 24 29 11 19 3 45 14 43 18 39 28 42 33 41 4 30 32 12 15 23 13 31 8 40 16 27 34 35 36 17 37 38 6 26 20 25 46 1 9 10 7 21 22]';
estim_error_rank = [43 2 15 39 17 1 8 22 19 6 36 14 40.500000 29 27 40.500000 46 10 37 16 18 31.500000 4.5000000 7 30 3 38 12 20 21 26 33 24 44 31.500000 12 9 25 34.500000 45 12 4.5000000 34.500000 23 42 28]';

% plot prior brain score corr
a=scatter(prior_rank_res_rank,brain_rank,80,'filled')
a.MarkerEdgeColor = 'w';
a.MarkerFaceColor = "#8E44AD";
hline=refline;
hline.LineWidth=2;
hline.Color=[0 0 0];
set(gca,'FontSize',32);

xticks([10:10:50])
yticks([10:10:50])
xlim([0 60])
ylim([0 60])
xlabel('prior width residualized (rank)')
ylabel('Δ latent SD_B_O_L_D (rank)')
%title(['p = 0.004']); % p-value of full GLM, see SPSS output

txt=['r = ' num2str(round(corr(prior_rank_res_rank,brain_rank),2),'%4.2f')];
yl=ylim;
xl=xlim;
text(xl(2)-15,yl(1)+6,txt,'FontSize',30);

saveas(gcf,'prior_brain_score2.jpg')

clf('reset')

% plot prior accuracy corr

a=scatter(prior_rank_res_rank,estim_error_rank,80,'filled')
a.MarkerEdgeColor = 'w';
a.MarkerFaceColor = "#8E44AD";
hline=refline;
hline.LineWidth=2;
hline.Color=[0 0 0];
set(gca,'FontSize',32);

xticks([10:10:50])
yticks([10:10:50])
xlim([0 60])
ylim([0 60])
xlabel('prior width residualized (rank)')
ylabel('estimation error (rank)')
%title(['p = 0.004']); % p-value of full GLM, see SPSS output

txt=['r = ' num2str(round(corr(prior_rank_res_rank,estim_error_rank),2),'%4.2f')];
yl=ylim;
xl=xlim;
text(xl(2)-15,yl(1)+6,txt,'FontSize',30);

saveas(gcf,'prior_estim_error.jpg')

clf('reset')