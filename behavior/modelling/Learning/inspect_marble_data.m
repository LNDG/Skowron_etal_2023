%inspect data
clear all

% load data
load('../PGT2016_data_MRIpost_04-Mar-2018.mat')

%% inspect data

%% experienced vs estimated probability ratio
for i = 1:size(data,2)
    a=scatter([data(i).trial.mean_act],[data(i).trial.p_response]./100,100,'filled')
    a.MarkerEdgeColor = "w";
    a.MarkerFaceColor = "#4DBEEE";
    hline=refline(1,0);
    hline.LineWidth=2;
    hline.Color=[0 0 0];
    set(gca,'FontSize',20);
    
    title(data(i).sub_id)
    xlabel('probability experienced')
    ylabel('probability estimated')

    pause
    
    if (i == 4 || i == 6 || i == 45 || i == 50)
        saveas(gcf,['/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/figures/' data(i).sub_id '_beh.jpg'])
    end
    
    clf('reset')

end

%% autocorrelation of ratio estimations
for i = 1:size(data,2)
    
    % no evidence for autocorrelation between trials?
    % load simulated data
    load(['sim_beh/Bayes_prior/sim_' data(i).sub_id '.mat'])
    resp_sim_t = sim_response(1:end-1);
    resp_sim_t1 = sim_response(2:end);
    clear sim_response
    
    resp = [data(i).trial.p_response]./100;
    resp_t = resp(1:end-1);
    resp_t1 = resp(2:end);
    
    auto_pl(1)=plot(resp_t,resp_t1,'o')
    refline
    hold on
    
    auto_pl(2)=plot(resp_sim_t,resp_sim_t1,'o')
    refline
    
    hold off
    
    legend(auto_pl,{'behaviour','simulation (Bayes prior model)'})

    xlabel('probability estimated t')
    ylabel('probability estimated t+1')

    pause
    
end

%% autocorrelation of ratio estimations
for i = 1:size(data,2)
    
%     % no evidence for autocorrelation between trials?
%     % load simulated data
%     load(['sim_beh/Bayes_prior/sim_' data(i).sub_id '.mat'])
%     resp_sim_t = sim_response(1:end-1);
%     resp_sim_t1 = sim_response(2:end);
%     clear sim_response
    
    resp = [data(i).trial.mean_act];
    resp_t = resp(1:end-1);
    resp_t1 = resp(2:end);
    
    auto_pl(1)=plot(resp_t,resp_t1,'o')
    refline
    hold on
%     
%     auto_pl(2)=plot(resp_sim_t,resp_sim_t1,'o')
%     refline
%     
    hold off
    
%     legend(auto_pl,{'behaviour','simulation (Bayes prior model)'})

    xlabel('probability experienced t')
    ylabel('probability experienced t+1')

    pause
    
end