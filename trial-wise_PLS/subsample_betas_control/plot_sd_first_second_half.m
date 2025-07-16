% plot
%load('sd_half_control.mat')

figure
set(gcf,'units','pixel','position',[0 0 700 700])

for i = 1:size(st_datamat1,1)
    %plt=subplot(1,5,i)
%     plot(st_datamat1(i,:),st_datamat2(i,:),'bo')
%     h=lsline
%     set(h(1),'color','r')
%     set(h(1),'LineWidth',2)
    
    a=scatter(st_datamat1(i,:),st_datamat2(i,:),60,'filled')
    %a.MarkerEdgeColor = 'w';
    a.MarkerFaceColor = '#fb3dfa';
    a.MarkerFaceAlpha = 0.6;
    hline=refline(1,0);
    hline.LineWidth=3;
    hline.Color=[0.7 0.7 0.7];
    set(gca,'FontSize',32);
    
%     h = get(gca,'Children');
%     set(gca,'Children',[h(2) h(1)])
    
    % correlations
    r = corr(st_datamat1(i,:)',st_datamat2(i,:)');
    rho = corr(st_datamat1(i,:)',st_datamat2(i,:)','Type','Spearman');
    
    upper=70; max([max(st_datamat1(i,:)),max(st_datamat2(i,:))]);
    
    xlim([0,upper])
    ylim([0,upper])
    
    xticks(0:20:upper)
    yticks(0:20:upper)

    saveas(gcf,['/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/subsample_betas_control/sd_s' num2str(i) '_half_noLabel.svg'])
    
    title({['s' num2str(i)],['r=' num2str(round(r,3)), ' / rho=' num2str(round(rho,3))]})
    xlabel('first half SD_B_O_L_D')
    ylabel('second half SD_B_O_L_D')
    
    saveas(gcf,['/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/subsample_betas_control/sd_s' num2str(i) '_half.svg'])
    clf

end

% set(gcf, 'Units', 'Inches', 'Position', [0, 0, 15, 10], 'PaperUnits', 'Inches', 'PaperSize', [25, 5])
% saveas(gcf,'/Users/skowron/Volumes/tardis1/Entscheidung2/analysis/trial-wise_PLS/subsample_betas_control/sd_half_noLabel.pdf')
