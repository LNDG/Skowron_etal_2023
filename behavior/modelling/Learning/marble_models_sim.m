% Model simulations for marble task
clear all

%load subject data
load('../PGT2016_data_MRIpost_04-Mar-2018.mat')

pp=1; % toggle updating plots
ps=0:0.01:1; % probability ratios (for plotting)

Nsub=size(data,2);

choice_rule = 2; % 1 = sampling models, 2 = error models

%% Bayes normative updating model with fitted prior and exponential evidence weight

if choice_rule == 1
    load('Bayes_prior_expo_par_fit.mat')
elseif choice_rule == 2
    load('Bayes_prior2_expo_par_fit.mat')
end

avg_sd_traj = nan(Nsub,2);
avg_sd_diff = nan(Nsub,1);

mean_pred_error = nan(Nsub,1);

% N_sel = find(theta(:,1) < 1.01);

for i = 1:Nsub %length(N_sel)
    
%     i=N_sel(j);
%     
%     LL(i)
%     theta(i,2)
    
    %prepare subject data
    nBlue_mat = [];
    N_mat = [];
    p_response = [];
    
    if choice_rule == 2
        prior_par = theta(i,1);
        expo_par = theta(i,2);
        choice_sd = theta(i,3);
    else
        prior_par = theta(i,1);
        expo_par = theta(i,2);
    end
    
    for tr = 1:length(data(i).trial)
        
        nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
        N_tr = data(i).trial(tr).sequence_type;
        p_response_tr = data(i).trial(tr).p_response./100;
        
        if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
            nBlue_mat = [nBlue_mat; nBlue_tr];
            N_mat = [N_mat; N_tr];
            p_response = [p_response; p_response_tr];
        end
        
        clear nBlue_tr N_tr p_response_tr
        
    end
    
    % collect predicted behaviour
    p_response_pred = [];
    sd_response_pred = [];
    sim_response=[];
    
    %collect update trajectories
    mean_traj = nan(length(p_response),size(nBlue_mat,2));
    sd_traj = nan(length(p_response),size(nBlue_mat,2));
    
    for t = 1:length(p_response)
        
        nBlue = nBlue_mat(t,:);
        N = N_mat(t,:);
        
        % initial values of the beta distribution
        alpha = prior_par;
        beta = prior_par;

        for b = 1:length(nBlue)

            prior = betapdf(ps,alpha,beta);
            like = betapdf(ps,nBlue(b)+1,N(b)-nBlue(b)+1); % correct?

            %update beta parameters
            alpha = alpha + nBlue(b).^expo_par;
            beta = beta + (N(b)-nBlue(b)).^expo_par;

            posterior = betapdf(ps,alpha,beta);
            
            % collect update trajectories
            mean_traj(t,b) = alpha/(alpha+beta);
            sd_traj(t,b) = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));

%             %plot
%             if pp == 1
%                 belief_pl(1)=plot(ps,prior,'LineWidth',3);
%                 hold on
%                 belief_pl(2)=plot(ps,like,'LineWidth',3);
%                 belief_pl(3)=plot(ps,posterior,'LineWidth',3);
%                 hold off
% 
%                 title('Bayes normative model')
%                 xlabel('probability ratios')
%                 ylabel('density')
%                 legend(belief_pl,{'prior' 'likelihood' 'posterior'})
% 
%                 pause
%             end

        end
        
        mean_tr_posterior = alpha/(alpha+beta);
        sd_tr_posterior = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));
        
        p_response_pred = [p_response_pred mean_tr_posterior];
        sd_response_pred = [sd_response_pred sd_tr_posterior];
        
        if choice_rule == 1
            sim_response = [sim_response betarnd(alpha, beta)];
        elseif choice_rule == 2
            trunc_norm = makedist('Normal', mean_tr_posterior, choice_sd);
            trunc_norm = truncate(trunc_norm,0,1); % truncated normal distribution
            sim_response = [sim_response random(trunc_norm)];
        end
        
        clear alpha beta prior like posterior mean_tr_posterior sd_tr_posterior

    end
    
    % compute mean update trajectories for subject
    X = [ones(size(sd_traj,2),1) (1:size(sd_traj,2))'];
    avg_sd_traj(i,:) = X\(median(sd_traj,1))'; % linear fit
    
    avg_sd_diff(i,:) = median(sd_traj(:,5)) - median(sd_traj(:,1)); % s5 - s1 diff
    
%     plot(p_response_pred,p_response,'bo','MarkerSize',5)
%     refline(1,0)
%     
%     title([data(i).sub_id ', prior=' num2str(prior_par)])
%     xlabel('predicted probability ratio')
%     ylabel('response probability ratio')
%     
%     xlim([0,1])
%     ylim([0,1])
%     
%     pause
    
    %compute mean squared prediction error
    mean_pred_error(i) = mean((p_response - p_response_pred').^2);

%      if pp == 1
%         plot(mean_traj')
%         xlabel('sample')
%         ylabel('posterior mean')
%         pause
%      end
    
%     if pp == 1
% 
%        plot(sd_traj','b-')
%        hold on
%        
%        y_pred = avg_sd_traj(i,1) + avg_sd_traj(i,2) .* (1:5)';
%        plot((1:5),y_pred,'r-','LineWidth',5)
%        hold off
%        
%         xlabel('sample')
%         ylabel('prior SD')
%        
%        pause
%     end
    
    % save simulated behaviour
    if choice_rule == 1
        save(['sim_beh/Bayes_prior_expo/sim_' data(i).sub_id], 'sim_response', 'mean_traj', 'sd_traj')
    elseif choice_rule == 2
       save(['sim_beh/Bayes_prior2_expo/sim_' data(i).sub_id], 'sim_response', 'mean_traj', 'sd_traj')
       %save(['sim_beh/Bayes_prior2/sim_' data(i).sub_id], 'sim_response', 'sd_traj','-append') 
    end
    
end

% % save simulated behaviour
% if choice_rule == 1
%     save(['sim_beh/Bayes_prior/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff', 'mean_pred_error')
% elseif choice_rule == 2
%    save(['sim_beh/Bayes_prior2/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff', 'mean_pred_error') 
% end

% if pp == 1
%     histogram(avg_sd_traj(:,2),10)
%     xlabel('uncertainty slopes')
% end
% 
% pause
% 
% if pp == 1
%     histogram(mean_pred_error,20)
%     xlabel('mean prediction error')
% end
% 
% pause

clear theta choice_sd

%% Bayes normative updating model
for i = 1:Nsub
    
    %prepare subject data
    nBlue_mat = [];
    N_mat = [];
    p_response = [];
    
    avg_mean_traj = nan(Nsub,2);
    avg_sd_traj = nan(Nsub,2);
    avg_sd_diff = nan(Nsub,1);
    
    for tr = 1:length(data(i).trial)
        
        nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
        N_tr = data(i).trial(tr).sequence_type;
        p_response_tr = data(i).trial(tr).p_response./100;
        
        if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
            nBlue_mat = [nBlue_mat; nBlue_tr];
            N_mat = [N_mat; N_tr];
            p_response = [p_response; p_response_tr];
        end
        
        clear nBlue_tr N_tr p_response_tr
        
    end
    
    % collect predicted behaviour
    p_response_pred = [];
    
    %collect update trajectories
    mean_traj = nan(length(p_response),size(nBlue_mat,2));
    sd_traj = nan(length(p_response),size(nBlue_mat,2));
    
    for t = 1:length(p_response)
        
        nBlue = nBlue_mat(t,:);
        N = N_mat(t,:);
        
        % initial values of the beta distribution
        alpha = 1;
        beta = 1;

        for b = 1:length(nBlue)

            prior = betapdf(ps,alpha,beta);
            like = betapdf(ps,nBlue(b)+1,N(b)-nBlue(b)+1); % correct?

            %update beta parameters
            alpha = alpha + nBlue(b);
            beta = beta + (N(b)-nBlue(b));

            posterior = betapdf(ps,alpha,beta);
            
            % collect update trajectories
            mean_traj(t,b) = alpha/(alpha+beta);
            sd_traj(t,b) = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));

%             %plot
%             if pp == 1
%                 belief_pl(1)=plot(ps,prior,'LineWidth',3);
%                 hold on
%                 belief_pl(2)=plot(ps,like,'LineWidth',3);
%                 belief_pl(3)=plot(ps,posterior,'LineWidth',3);
%                 hold off
% 
%                 title('Bayes normative model')
%                 xlabel('probability ratios')
%                 ylabel('density')
%                 legend(belief_pl,{'prior' 'likelihood' 'posterior'})
% 
%                 pause
%             end

        end
        
        mean_tr_posterior = alpha/(alpha+beta);
        p_response_pred = [p_response_pred mean_tr_posterior];
        
        clear alpha beta prior like posterior mean_tr_posterior

    end
    
%     plot(p_response_pred,p_response,'bo','MarkerSize',5)
%     refline(1,0)
%     
%     title(data(i).sub_id)
%     xlabel('predicted probability ratio')
%     ylabel('response probability ratio')
%     
%     pause

    % compute mean update trajectories for subject
    X = [ones(size(sd_traj,2),1) (1:size(sd_traj,2))'];
    avg_sd_traj(i,:) = X\(median(sd_traj,1))'; % linear fit
    
    % compute mean update trajectories for subject
    X = [ones(size(mean_traj,2),1) (1:size(mean_traj,2))'];
    avg_mean_traj(i,:) = X\(median(mean_traj,1))'; % linear fit
    
    if pp == 1
        
%        plot(mean_traj','k--','LineWidth',2)
%        hold on
%        
%        y_pred = avg_mean_traj(i,1) + avg_mean_traj(i,2) .* (1:5)';
%        plot((1:5),y_pred,'g-','LineWidth',5)
%        hold off
%         
%        set(gca,'FontSize',20);
%        xticks([1:5])
%        
%        title('Bayesian ideal observer')
%        xlabel('sample')
%        ylabel('posterior mean')
%        
%        pause

       plot(sd_traj','k--','LineWidth',2)
       hold on
       
       y_pred = avg_sd_traj(i,1) + avg_sd_traj(i,2) .* (1:5)';
       plot((1:5),y_pred,'g-','LineWidth',5)
       hold off
        
       set(gca,'FontSize',20);
       xticks([1:5])
       
       title('Bayesian ideal observer')
       xlabel('sample')
       ylabel('posterior variance')
       
       pause
    end
    
    % save simulated behaviour
    %save(['sim_beh/Bayes_norm/sim_' data(i).sub_id], 'mean_traj', 'sd_traj')
    
end

%% Bayes normative updating model with exponential evidence weight

if choice_rule == 1
    load('Bayes_expo_par_fit.mat')
elseif choice_rule == 2
    load('Bayes_expo2_par_fit.mat')
end

avg_sd_traj = nan(Nsub,2);
avg_sd_diff = nan(Nsub,1);

mean_pred_error = nan(Nsub,1);

for i = 1:Nsub
    
    %prepare subject data
    nBlue_mat = [];
    N_mat = [];
    p_response = [];
    
    if choice_rule == 2
        expo = theta(i,1);
        choice_sd = theta(i,2);
    else
        expo = theta(i);
    end
    
    for tr = 1:length(data(i).trial)
        
        nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
        N_tr = data(i).trial(tr).sequence_type;
        p_response_tr = data(i).trial(tr).p_response./100;
        
        if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
            nBlue_mat = [nBlue_mat; nBlue_tr];
            N_mat = [N_mat; N_tr];
            p_response = [p_response; p_response_tr];
        end
        
        clear nBlue_tr N_tr p_response_tr
        
    end
    
    % collect predicted behaviour
    p_response_pred = [];
    sd_response_pred = [];
    sim_response = [];
    
    %collect update trajectories
    mean_traj = nan(length(p_response),size(nBlue_mat,2));
    sd_traj = nan(length(p_response),size(nBlue_mat,2));
    
    for t = 1:length(p_response)
        
        nBlue = nBlue_mat(t,:);
        N = N_mat(t,:);
        
        % initial values of the beta distribution
        alpha = 1;
        beta = 1;

        for b = 1:length(nBlue)

            prior = betapdf(ps,alpha,beta);
            like = betapdf(ps,nBlue(b)+1,N(b)-nBlue(b)+1); % correct?

            %update beta parameters
            alpha = alpha + nBlue(b).^expo;
            beta = beta + (N(b)-nBlue(b)).^expo;

            posterior = betapdf(ps,alpha,beta);
            
            mean_traj(t,b) = alpha/(alpha+beta);
            sd_traj(t,b) = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));

%             %plot
%             if pp == 1
%                 belief_pl(1)=plot(ps,prior,'LineWidth',3);
%                 hold on
%                 belief_pl(2)=plot(ps,like,'LineWidth',3);
%                 belief_pl(3)=plot(ps,posterior,'LineWidth',3);
%                 hold off
% 
%                 title('Bayes normative model')
%                 xlabel('probability ratios')
%                 ylabel('density')
%                 legend(belief_pl,{'prior' 'likelihood' 'posterior'})
% 
%                 pause
%             end

        end
        
        mean_tr_posterior = alpha/(alpha+beta);
        sd_tr_posterior = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));
        
        p_response_pred = [p_response_pred mean_tr_posterior];
        sd_response_pred = [sd_response_pred sd_tr_posterior];
        
        
        if choice_rule == 1
            sim_response = [sim_response betarnd(alpha, beta)];
        elseif choice_rule == 2
            trunc_norm = makedist('Normal', mean_tr_posterior, choice_sd);
            trunc_norm = truncate(trunc_norm,0,1); % truncated normal distribution
            sim_response = [sim_response random(trunc_norm)];
        end
        
        clear alpha beta prior like posterior mean_tr_posterior sd_tr_posterior

    end
    
%     plot(p_response_pred,p_response,'bo','MarkerSize',5)
%     refline(1,0)
%     
%     title([data(i).sub_id ', expo=' num2str(expo)])
%     xlabel('predicted probability ratio')
%     ylabel('response probability ratio')
%     xlim([0,1])
%     ylim([0,1])
%     
%     pause
    
    % compute mean update trajectories for subject
    X = [ones(size(sd_traj,2),1) (1:size(sd_traj,2))'];
    avg_sd_traj(i,:) = X\(median(sd_traj,1))'; % linear fit
    
    avg_sd_diff(i,:) = median(sd_traj(:,5)) - median(sd_traj(:,1)); % s5 - s1 diff
    
    
    %compute mean squared prediction error
    mean_pred_error(i) = mean((p_response - p_response_pred').^2);
    
%     if pp == 1
%         
% %        plot(mean_traj')
% %        pause
% 
%        plot(sd_traj','b-')
%        hold on
%        
%        y_pred = avg_sd_traj(i,1) + avg_sd_traj(i,2) .* (1:5)';
%        plot((1:5),y_pred,'r-','LineWidth',5)
%        hold off
%        
%         xlabel('sample')
%         ylabel('prior SD')
%        
%        pause
%        
%     end
    
    % save simulated behaviour
    if choice_rule == 1
        save(['sim_beh/Bayes_expo/sim_' data(i).sub_id], 'sim_response','mean_traj')
    elseif choice_rule == 2
       save(['sim_beh/Bayes_expo2/sim_' data(i).sub_id], 'sim_response','mean_traj') 
    end
    
%     pause
    
end


% save simulated behaviour
if choice_rule == 1
    save(['sim_beh/Bayes_expo/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff', 'mean_pred_error')
elseif choice_rule == 2
   save(['sim_beh/Bayes_expo2/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff', 'mean_pred_error') 
end

% if pp == 1
%     histogram(avg_sd_traj(:,2),10)
%     xlabel('uncertainty slopes')
% end

% pause

clear theta choice_sd

%% Bayes normative updating model with fitted prior

if choice_rule == 1
    load('Bayes_prior_par_fit.mat')
elseif choice_rule == 2
    load('Bayes_prior2_par_fit.mat')
end

avg_sd_traj = nan(Nsub,2);
avg_sd_diff = nan(Nsub,1);

mean_pred_error = nan(Nsub,1);

% N_sel = find(theta(:,1) < 1.01);

for i = 1:Nsub %length(N_sel)
    
%     i=N_sel(j);
%     
%     LL(i)
%     theta(i,2)
    
    %prepare subject data
    nBlue_mat = [];
    N_mat = [];
    p_response = [];
    
    if choice_rule == 2
        prior_par = theta(i,1);
        choice_sd = theta(i,2);
    else
        prior_par = theta(i);
    end
    
    for tr = 1:length(data(i).trial)
        
        nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
        N_tr = data(i).trial(tr).sequence_type;
        p_response_tr = data(i).trial(tr).p_response./100;
        
        if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
            nBlue_mat = [nBlue_mat; nBlue_tr];
            N_mat = [N_mat; N_tr];
            p_response = [p_response; p_response_tr];
        end
        
        clear nBlue_tr N_tr p_response_tr
        
    end
    
    % collect predicted behaviour
    p_response_pred = [];
    sd_response_pred = [];
    sim_response=[];
    
    %collect update trajectories
    mean_traj = nan(length(p_response),size(nBlue_mat,2));
    sd_traj = nan(length(p_response),size(nBlue_mat,2));
    
    for t = 1:length(p_response)
        
        nBlue = nBlue_mat(t,:);
        N = N_mat(t,:);
        
        % initial values of the beta distribution
        alpha = prior_par;
        beta = prior_par;

        for b = 1:length(nBlue)

            prior = betapdf(ps,alpha,beta);
            like = betapdf(ps,nBlue(b)+1,N(b)-nBlue(b)+1); % correct?

            %update beta parameters
            alpha = alpha + nBlue(b);
            beta = beta + (N(b)-nBlue(b));

            posterior = betapdf(ps,alpha,beta);
            
            % collect update trajectories
            mean_traj(t,b) = alpha/(alpha+beta);
            sd_traj(t,b) = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));

%             %plot
%             if pp == 1
%                 belief_pl(1)=plot(ps,prior,'LineWidth',3);
%                 hold on
%                 belief_pl(2)=plot(ps,like,'LineWidth',3);
%                 belief_pl(3)=plot(ps,posterior,'LineWidth',3);
%                 hold off
% 
%                 title('Bayes normative model')
%                 xlabel('probability ratios')
%                 ylabel('density')
%                 legend(belief_pl,{'prior' 'likelihood' 'posterior'})
% 
%                 pause
%             end

        end
        
        mean_tr_posterior = alpha/(alpha+beta);
        sd_tr_posterior = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));
        
        p_response_pred = [p_response_pred mean_tr_posterior];
        sd_response_pred = [sd_response_pred sd_tr_posterior];
        
        if choice_rule == 1
            sim_response = [sim_response betarnd(alpha, beta)];
        elseif choice_rule == 2
            trunc_norm = makedist('Normal', mean_tr_posterior, choice_sd);
            trunc_norm = truncate(trunc_norm,0,1); % truncated normal distribution
            sim_response = [sim_response random(trunc_norm)];
        end
        
        clear alpha beta prior like posterior mean_tr_posterior sd_tr_posterior

    end
    
    % compute mean update trajectories for subject
    X = [ones(size(sd_traj,2),1) (1:size(sd_traj,2))'];
    avg_sd_traj(i,:) = X\(median(sd_traj,1))'; % linear fit
    
    avg_sd_diff(i,:) = median(sd_traj(:,5)) - median(sd_traj(:,1)); % s5 - s1 diff
    
%     plot(p_response_pred,p_response,'bo','MarkerSize',5)
%     refline(1,0)
%     
%     title([data(i).sub_id ', prior=' num2str(prior_par)])
%     xlabel('predicted probability ratio')
%     ylabel('response probability ratio')
%     
%     xlim([0,1])
%     ylim([0,1])
%     
%     pause
    
    %compute mean squared prediction error
    mean_pred_error(i) = mean((p_response - p_response_pred').^2);

%      if pp == 1
%         plot(mean_traj')
%         xlabel('sample')
%         ylabel('posterior mean')
%         pause
%      end
    
%     if pp == 1
% 
%        plot(sd_traj','b-')
%        hold on
%        
%        y_pred = avg_sd_traj(i,1) + avg_sd_traj(i,2) .* (1:5)';
%        plot((1:5),y_pred,'r-','LineWidth',5)
%        hold off
%        
%         xlabel('sample')
%         ylabel('prior SD')
%        
%        pause
%     end
    
    % save simulated behaviour
    if choice_rule == 1
        save(['sim_beh/Bayes_prior/sim_' data(i).sub_id], 'sim_response', 'mean_traj', 'sd_traj')
    elseif choice_rule == 2
       save(['sim_beh/Bayes_prior2/sim_' data(i).sub_id], 'sim_response', 'mean_traj', 'sd_traj')
       %save(['sim_beh/Bayes_prior2/sim_' data(i).sub_id], 'sim_response', 'sd_traj','-append') 
    end
    
end

% % save simulated behaviour
% if choice_rule == 1
%     save(['sim_beh/Bayes_prior/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff', 'mean_pred_error')
% elseif choice_rule == 2
%    save(['sim_beh/Bayes_prior2/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff', 'mean_pred_error') 
% end

% if pp == 1
%     histogram(avg_sd_traj(:,2),10)
%     xlabel('uncertainty slopes')
% end
% 
% pause
% 
% if pp == 1
%     histogram(mean_pred_error,20)
%     xlabel('mean prediction error')
% end
% 
% pause

clear theta choice_sd

%% RW model

load('RW_par_fit.mat')

for i = 1:Nsub
    
    %prepare subject data
    nBlue_mat = [];
    N_mat = [];
    p_response = [];
    
    % model pars
    alpha = theta(i,1);
    sigma = theta(i,2);
    
    for tr = 1:length(data(i).trial)
        
        nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
        N_tr = data(i).trial(tr).sequence_type;
        p_response_tr = data(i).trial(tr).p_response./100;
        
        if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
            nBlue_mat = [nBlue_mat; nBlue_tr];
            N_mat = [N_mat; N_tr];
            p_response = [p_response; p_response_tr];
        end
        
        clear nBlue_tr N_tr p_response_tr
        
    end
    
    % collect predicted behaviour
    sim_response=[];
    
    %collect update trajectories
    mean_traj = nan(length(p_response),size(nBlue_mat,2));
    
    for t = 1:length(p_response)
        
        nBlue = nBlue_mat(t,:);
        N = N_mat(t,:);
        
        pBlue = 0.5; % intialise estimate

            for b = 1:length(nBlue)

                %update marble ratio estimate
                er = pBlue - (nBlue(b)/N(b));

                pBlue = pBlue - alpha * er;

                % collect update trajectories
                mean_traj(t,b) = pBlue;

            end
        
        trunc_norm = makedist('Normal', pBlue, sigma);
        trunc_norm = truncate(trunc_norm,0,1); % truncated normal distribution
        sim_response = [sim_response random(trunc_norm)];
        
        clear pBlue er trunc_norm
        
    end
    
    % save simulated behaviour
   save(['sim_beh/RW/sim_' data(i).sub_id], 'sim_response', 'mean_traj')
    
end

clear theta alpha sigma

%% Bayes normative updating model with fixed evidence weight

if choice_rule == 1
    load('Bayes_rate_par_fit.mat')
elseif choice_rule == 2
    load('Bayes_rate2_par_fit.mat')
end


for i = 1:Nsub
    
    %prepare subject data
    nBlue_mat = [];
    N_mat = [];
    p_response = [];
    
    if choice_rule == 2
        rate = theta(i,1);
        choice_sd = theta(i,2);
    else
        rate = theta(i);
    end
    
    for tr = 1:length(data(i).trial)
        
        nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
        N_tr = data(i).trial(tr).sequence_type;
        p_response_tr = data(i).trial(tr).p_response./100;
        
        if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
            nBlue_mat = [nBlue_mat; nBlue_tr];
            N_mat = [N_mat; N_tr];
            p_response = [p_response; p_response_tr];
        end
        
        clear nBlue_tr N_tr p_response_tr
        
    end
    
    % collect predicted behaviour
    p_response_pred = [];
    sd_response_pred = [];
    sim_response=[];
    
    for t = 1:length(p_response)
        
        nBlue = nBlue_mat(t,:);
        N = N_mat(t,:);
        
        % perceived ratios
        nBlue_perc = rate.*(nBlue./N);
        N_perc = repmat(rate,[1,length(nBlue_perc)]);
        
        % initial values of the beta distribution
        alpha = 1;
        beta = 1;

        for b = 1:length(nBlue)

            prior = betapdf(ps,alpha,beta);
            like = betapdf(ps,nBlue(b)+1,N(b)-nBlue(b)+1); % correct?

            %update beta parameters
            alpha = alpha + nBlue_perc(b);
            beta = beta + (N_perc(b)-nBlue_perc(b));

            posterior = betapdf(ps,alpha,beta);

            %plot
            if pp == 1
                belief_pl(1)=plot(ps,prior,'LineWidth',3);
                hold on
                belief_pl(2)=plot(ps,like,'LineWidth',3);
                belief_pl(3)=plot(ps,posterior,'LineWidth',3);
                hold off

                title('Bayes normative model')
                xlabel('probability ratios')
                ylabel('density')
                legend(belief_pl,{'prior' 'likelihood' 'posterior'})

                pause
            end

        end
        
        mean_tr_posterior = alpha/(alpha+beta);
        sd_tr_posterior = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));
        
        p_response_pred = [p_response_pred mean_tr_posterior];
        sd_response_pred = [sd_response_pred sd_tr_posterior];
        
        if choice_rule == 1
            sim_response = [sim_response betarnd(alpha, beta)];
        elseif choice_rule == 2
            trunc_norm = makedist('Normal', mean_tr_posterior, choice_sd);
            trunc_norm = truncate(trunc_norm,0,1); % truncated normal distribution
            sim_response = [sim_response random(trunc_norm)]; 
        end
        
        clear alpha beta prior like posterior mean_tr_posterior sd_tr_posterior

    end
    
    plot(p_response_pred,p_response,'bo','MarkerSize',5)
    refline(1,0)
    
    title([data(i).sub_id ', rate=' num2str(rate)])
    xlabel('predicted probability ratio')
    ylabel('response probability ratio')
    
    xlim([0,1])
    ylim([0,1])
    
    % save simulated behaviour
    if choice_rule == 1
        save(['sim_beh/Bayes_rate/sim_' data(i).sub_id], 'sim_response')
    elseif choice_rule == 2
       save(['sim_beh/Bayes_rate2/sim_' data(i).sub_id], 'sim_response') 
    end
    
    pause
end

clear theta choice_sd

%% Bayes normative updating model with exponential evidence weight and learning rate

load('Bayes_expo_LR_par_fit.mat')

avg_sd_traj = nan(Nsub,2);
avg_sd_diff = nan(Nsub,1);

for i = 1:Nsub
    
    %prepare subject data
    nBlue_mat = [];
    N_mat = [];
    p_response = [];
    
    expo = theta(i,1);
    LR = theta(i,2);
    
    for tr = 1:length(data(i).trial)
        
        nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
        N_tr = data(i).trial(tr).sequence_type;
        p_response_tr = data(i).trial(tr).p_response./100;
        
        if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
            nBlue_mat = [nBlue_mat; nBlue_tr];
            N_mat = [N_mat; N_tr];
            p_response = [p_response; p_response_tr];
        end
        
        clear nBlue_tr N_tr p_response_tr
        
    end
    
    % collect predicted behaviour
    p_response_pred = [];
    sd_response_pred = [];
    sim_response = [];
    
    %collect update trajectories
    mean_traj = nan(length(p_response),size(nBlue_mat,2));
    sd_traj = nan(length(p_response),size(nBlue_mat,2));
    
    for t = 1:length(p_response)
        
        nBlue = nBlue_mat(t,:);
        N = N_mat(t,:);
        
        % initial values of the beta distribution
        alpha = 1;
        beta = 1;

        for b = 1:length(nBlue)

            prior = betapdf(ps,alpha,beta);
            like = betapdf(ps,nBlue(b)+1,N(b)-nBlue(b)+1); % correct?

            %update beta parameters
            alpha = alpha + LR*(nBlue(b).^expo);
            beta = beta + LR*((N(b)-nBlue(b)).^expo);

            posterior = betapdf(ps,alpha,beta);
            
            mean_traj(t,b) = alpha/(alpha+beta);
            sd_traj(t,b) = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));

%             %plot
%             if pp == 1
%                 belief_pl(1)=plot(ps,prior,'LineWidth',3);
%                 hold on
%                 belief_pl(2)=plot(ps,like,'LineWidth',3);
%                 belief_pl(3)=plot(ps,posterior,'LineWidth',3);
%                 hold off
% 
%                 title('Bayes normative model')
%                 xlabel('probability ratios')
%                 ylabel('density')
%                 legend(belief_pl,{'prior' 'likelihood' 'posterior'})
% 
%                 pause
%             end

        end
        
        mean_tr_posterior = alpha/(alpha+beta);
        sd_tr_posterior = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));
        
        p_response_pred = [p_response_pred mean_tr_posterior];
        sd_response_pred = [sd_response_pred sd_tr_posterior];
        
        
        sim_response = [sim_response betarnd(alpha, beta)];
        
        clear alpha beta prior like posterior mean_tr_posterior sd_tr_posterior

    end
    
%     plot(p_response_pred,p_response,'bo','MarkerSize',5)
%     refline(1,0)
%     
%     title([data(i).sub_id ', expo=' num2str(expo) ', LR=' num2str(LR)])
%     xlabel('predicted probability ratio')
%     ylabel('response probability ratio')
%     xlim([0,1])
%     ylim([0,1])
%     
%     pause
    
    % compute mean update trajectories for subject
    X = [ones(size(sd_traj,2),1) (1:size(sd_traj,2))'];
    avg_sd_traj(i,:) = X\(median(sd_traj,1))'; % linear fit
    
    avg_sd_diff(i,:) = median(sd_traj(:,5)) - median(sd_traj(:,1)); % s5 - s1 diff
    
%     if pp == 1
%         
% %        plot(mean_traj')
% %        pause
% 
%        plot(sd_traj','b-')
%        hold on
%        
%        y_pred = avg_sd_traj(i,1) + avg_sd_traj(i,2) .* (1:5)';
%        plot((1:5),y_pred,'r-','LineWidth',5)
%        hold off
%        
%         xlabel('sample')
%         ylabel('prior SD')
%        
%        pause
%        
%     end
    
    % save simulated behaviour
    save(['sim_beh/Bayes_expo_LR/sim_' data(i).sub_id], 'sim_response')
    
%     pause
    
end


% save simulated behaviour
save(['sim_beh/Bayes_expo_LR/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff')

% if pp == 1
%     histogram(avg_sd_traj(:,2),10)
%     xlabel('uncertainty slopes')
% end
% 
% pause

clear theta choice_sd

%% Bayes normative updating model with fitted prior and learning rate

load('Bayes_prior_LR_par_fit.mat')

avg_sd_traj = nan(Nsub,2);
avg_sd_diff = nan(Nsub,1);

mean_pred_error = nan(Nsub,1);

% N_sel = find(theta(:,1) < 1.01);

for i = 1:Nsub %length(N_sel)
    
%     i=N_sel(j);
%     
%     LL(i)
%     theta(i,2)
    
    %prepare subject data
    nBlue_mat = [];
    N_mat = [];
    p_response = [];
    
    prior_par = theta(i,1);
    LR = theta(i,2);
     
    for tr = 1:length(data(i).trial)
        
        nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
        N_tr = data(i).trial(tr).sequence_type;
        p_response_tr = data(i).trial(tr).p_response./100;
        
        if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
            nBlue_mat = [nBlue_mat; nBlue_tr];
            N_mat = [N_mat; N_tr];
            p_response = [p_response; p_response_tr];
        end
        
        clear nBlue_tr N_tr p_response_tr
        
    end
    
    % collect predicted behaviour
    p_response_pred = [];
    sd_response_pred = [];
    sim_response=[];
    
    %collect update trajectories
    mean_traj = nan(length(p_response),size(nBlue_mat,2));
    sd_traj = nan(length(p_response),size(nBlue_mat,2));
    
    for t = 1:length(p_response)
        
        nBlue = nBlue_mat(t,:);
        N = N_mat(t,:);
        
        % initial values of the beta distribution
        alpha = prior_par;
        beta = prior_par;

        for b = 1:length(nBlue)

            prior = betapdf(ps,alpha,beta);
            like = betapdf(ps,nBlue(b)+1,N(b)-nBlue(b)+1); % correct?

            %update beta parameters
            alpha = alpha + LR*nBlue(b);
            beta = beta + LR*((N(b)-nBlue(b)));

            posterior = betapdf(ps,alpha,beta);
            
            % collect update trajectories
            mean_traj(t,b) = alpha/(alpha+beta);
            sd_traj(t,b) = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));

%             %plot
%             if pp == 1
%                 belief_pl(1)=plot(ps,prior,'LineWidth',3);
%                 hold on
%                 belief_pl(2)=plot(ps,like,'LineWidth',3);
%                 belief_pl(3)=plot(ps,posterior,'LineWidth',3);
%                 hold off
% 
%                 title('Bayes normative model')
%                 xlabel('probability ratios')
%                 ylabel('density')
%                 legend(belief_pl,{'prior' 'likelihood' 'posterior'})
% 
%                 pause
%             end

        end
        
        mean_tr_posterior = alpha/(alpha+beta);
        sd_tr_posterior = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));
        
        p_response_pred = [p_response_pred mean_tr_posterior];
        sd_response_pred = [sd_response_pred sd_tr_posterior];
        
        sim_response = [sim_response betarnd(alpha, beta)];
        
        clear alpha beta prior like posterior mean_tr_posterior sd_tr_posterior

    end
    
    % compute mean update trajectories for subject
    X = [ones(size(sd_traj,2),1) (1:size(sd_traj,2))'];
    avg_sd_traj(i,:) = X\(median(sd_traj,1))'; % linear fit
    
    avg_sd_diff(i,:) = median(sd_traj(:,5)) - median(sd_traj(:,1)); % s5 - s1 diff
    
    plot(p_response_pred,p_response,'bo','MarkerSize',5)
    refline(1,0)
    
    title([data(i).sub_id ', prior=' num2str(prior_par) ', LR=' num2str(LR)])
    xlabel('predicted probability ratio')
    ylabel('response probability ratio')
    
    xlim([0,1])
    ylim([0,1])
    
    % compute mean squared prediction error
    mean_pred_error(i) = mean((p_response - p_response_pred').^2);
    
    pause
    
    if pp == 1
        
%        plot(mean_traj')
%        pause

       plot(sd_traj','b-')
       hold on
       
       y_pred = avg_sd_traj(i,1) + avg_sd_traj(i,2) .* (1:5)';
       plot((1:5),y_pred,'r-','LineWidth',5)
       hold off
       
        xlabel('sample')
        ylabel('prior SD')
        
        ylim([0 0.05])
       
       pause
    end
    
    % save simulated behaviour
    save(['sim_beh/Bayes_prior_LR/sim_' data(i).sub_id], 'sim_response')
    
end

% save simulated behaviour
save(['sim_beh/Bayes_prior_LR/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff', 'mean_pred_error')

if pp == 1
    histogram(avg_sd_traj(:,2),10)
    xlabel('uncertainty slopes')
end

pause

if pp == 1
    histogram(mean_pred_error,20)
    xlabel('mean prediction error')
end

pause

clear theta choice_sd

%% Bayes normative updating model with fitted prior

if choice_rule == 1
    load('Bayes_prior_rec_par_fit.mat')
elseif choice_rule == 2
    load('Bayes_prior_rec2_par_fit.mat')
end

avg_sd_traj = nan(Nsub,2);
avg_sd_diff = nan(Nsub,1);

mean_pred_error = nan(Nsub,1);

% N_sel = find(theta(:,1) < 1.01);

for i = 1:Nsub %length(N_sel)
    
%     i=N_sel(j);
%     
%     LL(i)
%     theta(i,2)
    
    %prepare subject data
    nBlue_mat = [];
    N_mat = [];
    p_response = [];
    
    if choice_rule == 2
        prior_par = theta(i,1);
        rec = theta(i,2);
        choice_sd = theta(i,3);
    else
        prior_par = theta(i);
        rec = theta(i,2);
    end
    
    for tr = 1:length(data(i).trial)
        
        nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
        N_tr = data(i).trial(tr).sequence_type;
        p_response_tr = data(i).trial(tr).p_response./100;
        
        if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
            nBlue_mat = [nBlue_mat; nBlue_tr];
            N_mat = [N_mat; N_tr];
            p_response = [p_response; p_response_tr];
        end
        
        clear nBlue_tr N_tr p_response_tr
        
    end
    
    % collect predicted behaviour
    p_response_pred = [];
    sd_response_pred = [];
    sim_response=[];
    
    %collect update trajectories
    mean_traj = nan(length(p_response),size(nBlue_mat,2));
    sd_traj = nan(length(p_response),size(nBlue_mat,2));
    
    for t = 1:length(p_response)
        
        nBlue = nBlue_mat(t,:);
        N = N_mat(t,:);
        
        % initial values of the beta distribution
        alpha = prior_par;
        beta = prior_par;

        for b = 1:length(nBlue)

            prior = betapdf(ps,alpha,beta);
            like = betapdf(ps,nBlue(b)+1,N(b)-nBlue(b)+1); % correct?

            %update beta parameters
            alpha = alpha + nBlue(b) + (b*rec);
            beta = beta + (N(b)-nBlue(b)) + (b*rec);

            posterior = betapdf(ps,alpha,beta);
            
            % collect update trajectories
            mean_traj(t,b) = alpha/(alpha+beta);
            sd_traj(t,b) = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));

%             %plot
%             if pp == 1
%                 belief_pl(1)=plot(ps,prior,'LineWidth',3);
%                 hold on
%                 belief_pl(2)=plot(ps,like,'LineWidth',3);
%                 belief_pl(3)=plot(ps,posterior,'LineWidth',3);
%                 hold off
% 
%                 title('Bayes normative model')
%                 xlabel('probability ratios')
%                 ylabel('density')
%                 legend(belief_pl,{'prior' 'likelihood' 'posterior'})
% 
%                 pause
%             end

        end
        
        mean_tr_posterior = alpha/(alpha+beta);
        sd_tr_posterior = (alpha*beta)/((alpha+beta)^2*(alpha+beta+1));
        
        p_response_pred = [p_response_pred mean_tr_posterior];
        sd_response_pred = [sd_response_pred sd_tr_posterior];
        
        if choice_rule == 1
            sim_response = [sim_response betarnd(alpha, beta)];
        elseif choice_rule == 2
            trunc_norm = makedist('Normal', mean_tr_posterior, choice_sd);
            trunc_norm = truncate(trunc_norm,0,1); % truncated normal distribution
            sim_response = [sim_response random(trunc_norm)];
        end
        
        clear alpha beta prior like posterior mean_tr_posterior sd_tr_posterior

    end
    
    % compute mean update trajectories for subject
    X = [ones(size(sd_traj,2),1) (1:size(sd_traj,2))'];
    avg_sd_traj(i,:) = X\(median(sd_traj,1))'; % linear fit
    
    avg_sd_diff(i,:) = median(sd_traj(:,5)) - median(sd_traj(:,1)); % s5 - s1 diff
    
%     plot(p_response_pred,p_response,'bo','MarkerSize',5)
%     refline(1,0)
%     
%     title([data(i).sub_id ', prior=' num2str(prior_par)])
%     xlabel('predicted probability ratio')
%     ylabel('response probability ratio')
%     
%     xlim([0,1])
%     ylim([0,1])
    
    % compute mean squared prediction error
    mean_pred_error(i) = mean((p_response - p_response_pred').^2);
%     
%     pause
    
%     if pp == 1
%         
% %        plot(mean_traj')
% %        pause
% 
%        plot(sd_traj','b-')
%        hold on
%        
%        y_pred = avg_sd_traj(i,1) + avg_sd_traj(i,2) .* (1:5)';
%        plot((1:5),y_pred,'r-','LineWidth',5)
%        hold off
%        
%         xlabel('sample')
%         ylabel('prior SD')
%        
%        pause
%     end
    
    % save simulated behaviour
    if choice_rule == 1
        save(['sim_beh/Bayes_prior_rec/sim_' data(i).sub_id], 'sim_response')
    elseif choice_rule == 2
       save(['sim_beh/Bayes_prior_rec2/sim_' data(i).sub_id], 'sim_response') 
    end
    
end

% save simulated behaviour
if choice_rule == 1
    save(['sim_beh/Bayes_prior_rec/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff', 'mean_pred_error')
elseif choice_rule == 2
   save(['sim_beh/Bayes_prior_rec2/sim_avg_sd_traj'], 'avg_sd_traj', 'avg_sd_diff', 'mean_pred_error') 
end

if pp == 1
    histogram(avg_sd_traj(:,2),10)
    xlabel('uncertainty slopes')
end

pause

if pp == 1
    histogram(mean_pred_error,20)
    xlabel('mean prediction error')
end

pause

clear theta choice_sd