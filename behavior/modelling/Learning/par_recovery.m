%check parameter recovery
% Bayes_rate2 model is not identifiable (rate parameter only affects SD but not mean of beta distribution)

cd('/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning')
clear all

model_name = {'RW' 'Bayes_expo' 'Bayes_expo2' 'Bayes_prior' 'Bayes_prior2' 'Bayes_prior_expo' 'Bayes_prior2_expo'};
%{'Bayes_expo' 'Bayes_expo2' 'Bayes_prior' 'Bayes_prior2' 'Bayes_rate' 'Bayes_prior_rec' 'Bayes_prior_rec2'};

%N=51
load('/Users/skowron/Documents/Entscheidung2_dump/behaviour/beh_measures.mat','sids')
sub_ls = sids;
clear sids

for m = 6:length(model_name)
    
    %load simulation parameters (i.e. subject fitted parameters)
    load([model_name{m} '_par_fit.mat'],'theta')
    
    if size(theta,2) > size(theta,1) % check that rows are subjects and columns are parameters
       theta=theta'; 
    end
    
    theta_sim = theta;
    theta_sim = theta_sim(sub_ls,:); % N=51
    clear theta

    load(['sim_beh/' model_name{m} '/' model_name{m} '_par_fit.mat'],'theta')
        
    if size(theta,2) > size(theta,1) % check that rows are subjects and columns are parameters
       theta=theta'; 
    end
    
    theta_rec = theta;
    theta_rec = theta_rec(sub_ls,:); % N=51
    clear theta
    
    for t = 1:size(theta_sim,2)
        
        % remove simulated parameters far away from distribution mass for
        % plotting
        
        %show_idx = ~(theta_sim(:,t) > prctile(theta_sim(:,t),95));
        show_idx = 1:length(theta_sim(:,t));
        
        a=scatter(theta_sim(show_idx,t),theta_rec(show_idx,t),120,'filled')
        
        a.MarkerEdgeColor = 'w';
        a.MarkerFaceColor = '#fb3dfa';
        a.MarkerFaceAlpha = 0.6;
        hline=refline(1,0);
        hline.LineWidth=3;
        hline.Color=[0.7 0.7 0.7];
        set(gca,'FontSize',26);

        h = get(gca,'Children');
        set(gca,'Children',[h(2) h(1)])
%         
%         a.MarkerEdgeColor = "w";
%         a.MarkerFaceColor = "#bf4283";
%         hline=refline(1,0);
%         hline.LineWidth=2;
%         hline.Color=[0 0 0];
%         set(gca,'FontSize',20);
        
        % adjust plotting range to reflect possible parameter range
        if contains(model_name{m}, 'Bayes_prior') && t == 1
           x_val = xlim;
           xlim([1 x_val(2)]);
           
           y_val = ylim;
           ylim([1 y_val(2)]);
           
           clear x_val y_val
%         else
%            x_val = xlim;
%            xlim([0 x_val(2)]);
%            
%            y_val = ylim;
%            ylim([0 y_val(2)]);
%            
%            clear x_val y_val
        end
        
        title({[model_name{m} ', theta ' num2str(t)] ['r = ' num2str(round(corr(theta_sim(:,t),theta_rec(:,t)),3))]})
        xlabel('simulated parameter')
        ylabel('recovered parameter')
        
        pause
        
        saveas(gcf,['/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/figures/' model_name{m} '_theta' num2str(t) '_par_rec.jpg'])
    
        clf('reset')
        
    end
    

end