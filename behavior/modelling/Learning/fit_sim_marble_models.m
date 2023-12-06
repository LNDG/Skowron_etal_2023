% fit simulated behaviour for marble task models
clear all

% load data
load('../PGT2016_data_MRIpost_04-Mar-2018.mat')

true_model_names = {'Bayes_expo' 'Bayes_expo2' 'Bayes_prior' 'Bayes_prior2' 'RW'}; % ground truth model for simulated behaviour (see folder names in sim_beh)
% {'Bayes_expo' 'Bayes_expo2' 'Bayes_prior' 'Bayes_prior2' 'Bayes_rate' 'Bayes_expo_LR' 'Bayes_prior_LR' 'Bayes_prior_rec' 'Bayes_prior_rec2'}; % ground truth model for simulated behaviour (see folder names in sim_beh)

iter=10; % number of fitting iterations

for t = 1:(length(true_model_names)-1) %1:length(true_model_names)

    true_model = true_model_names{t};
    
    %% fit RW model
    for i = 1:size(data,2)
    
        %prepare subject data
        nBlue_mat = [];
        N_mat = [];
        p_response = [];

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
        
        % replace actual behaviour with simulated behaviour
        load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
        
        p_response = sim_response;
        clear sim_response

        for it = 1:iter

            theta_start = [rand 0.5*rand]; % starting value for optimisation
            theta_lb = [0 0];
            theta_ub = [1 Inf];

            [theta_fit LL_fit]=fmincon(@(x) RW_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);

            if it > 1

                if  LL_fit < LL(i)
                    theta(i,:)=theta_fit;
                    LL(i,:)=LL_fit;
                end

            else
                theta(i,:)=theta_fit;
                LL(i,:)=LL_fit;
            end

        end
    end

    % save results
    save(['sim_beh/' true_model '/RW_par_fit.mat'],'theta','LL')

    clear theta LL

    
%     %% fit Bayesian updating model with exponential evidence weight
%     for i = 1:size(data,2)
% 
%             %prepare subject data
%             nBlue_mat = [];
%             N_mat = [];
%             p_response = [];
% 
%             for tr = 1:length(data(i).trial)
% 
%                 nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
%                 N_tr = data(i).trial(tr).sequence_type;
%                 p_response_tr = data(i).trial(tr).p_response./100;
% 
%                 if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
%                     nBlue_mat = [nBlue_mat; nBlue_tr];
%                     N_mat = [N_mat; N_tr];
%                     p_response = [p_response; p_response_tr];
%                 end
% 
%                 clear nBlue_tr N_tr p_response_tr
% 
%             end
% 
%             % replace actual behaviour with simulated behaviour
%             load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
% 
%             p_response = sim_response;
%             clear sim_response
% 
%             for it = 1:iter
% 
%                 theta_start = 5*rand; % starting value for optimisation
%                 theta_lb = 0;
%                 theta_ub = Inf;
% 
%                 [theta_fit LL_fit]=fmincon(@(x) Bayes_expo_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
% 
%                 if it > 1
% 
%                     if  LL_fit < LL(i)
%                         theta(i)=theta_fit;
%                         LL(i)=LL_fit;
%                     end
% 
%                 else
%                     theta(i)=theta_fit;
%                     LL(i)=LL_fit;
%                 end
% 
%             end
% 
%         end
% 
%         % save results
%         save(['sim_beh/' true_model '/Bayes_expo_par_fit.mat'],'theta','LL')
% 
%         clear theta LL
% 
%         %% fit Bayesian updating model with free prior
%         for i = 1:size(data,2)
% 
%             %prepare subject data
%             nBlue_mat = [];
%             N_mat = [];
%             p_response = [];
% 
%             for tr = 1:length(data(i).trial)
% 
%                 nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
%                 N_tr = data(i).trial(tr).sequence_type;
%                 p_response_tr = data(i).trial(tr).p_response./100;
% 
%                 if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
%                     nBlue_mat = [nBlue_mat; nBlue_tr];
%                     N_mat = [N_mat; N_tr];
%                     p_response = [p_response; p_response_tr];
%                 end
% 
%                 clear nBlue_tr N_tr p_response_tr
% 
%             end
% 
%             % replace actual behaviour with simulated behaviour
%             load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
% 
%             p_response = sim_response;
%             clear sim_response
% 
% 
%             for it = 1:iter
% 
%                 theta_start = 20*rand+1; % starting value for optimisation
%                 theta_lb = 1;
%                 theta_ub = Inf;
% 
%                 [theta_fit LL_fit]=fmincon(@(x) Bayes_prior_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
% 
%                 if it > 1
% 
%                     if  LL_fit < LL(i)
%                         theta(i)=theta_fit;
%                         LL(i)=LL_fit;
%                     end
% 
%                 else
%                     theta(i)=theta_fit;
%                     LL(i)=LL_fit;
%                 end
% 
%             end
%         end
% 
%         % save results
%         save(['sim_beh/' true_model '/Bayes_prior_par_fit.mat'],'theta','LL')
% 
%         clear theta LL
% 
% %         %% fit Bayesian updating model with fixed rate
% %         for i = 1:size(data,2)
% % 
% %             %prepare subject data
% %             nBlue_mat = [];
% %             N_mat = [];
% %             p_response = [];
% % 
% %             for tr = 1:length(data(i).trial)
% % 
% %                 nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
% %                 N_tr = data(i).trial(tr).sequence_type;
% %                 p_response_tr = data(i).trial(tr).p_response./100;
% % 
% %                 if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
% %                     nBlue_mat = [nBlue_mat; nBlue_tr];
% %                     N_mat = [N_mat; N_tr];
% %                     p_response = [p_response; p_response_tr];
% %                 end
% % 
% %                 clear nBlue_tr N_tr p_response_tr
% % 
% %             end
% % 
% %             % replace actual behaviour with simulated behaviour
% %             load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
% % 
% %             p_response = sim_response;
% %             clear sim_response
% % 
% %             for it = 1:iter
% % 
% %                 theta_start = 5*rand; % starting value for optimisation
% %                 theta_lb = 0;
% %                 theta_ub = Inf;
% % 
% %                 [theta_fit LL_fit]=fmincon(@(x) Bayes_rate_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
% % 
% %                 if it > 1
% % 
% %                     if  LL_fit < LL(i)
% %                         theta(i)=theta_fit;
% %                         LL(i)=LL_fit;
% %                     end
% % 
% %                 else
% %                     theta(i)=theta_fit;
% %                     LL(i)=LL_fit;
% %                 end
% % 
% %             end
% % 
% %         end
% % 
% %         % save results
% %         save(['sim_beh/' true_model '/Bayes_rate_par_fit.mat'],'theta','LL')
% % 
% %         clear theta LL
% 
%         %% fit Bayesian updating model with exponential evidence weight (noisy choice)
% 
%         for i = 1:size(data,2)
% 
%             %prepare subject data
%             nBlue_mat = [];
%             N_mat = [];
%             p_response = [];
% 
%             for tr = 1:length(data(i).trial)
% 
%                 nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
%                 N_tr = data(i).trial(tr).sequence_type;
%                 p_response_tr = data(i).trial(tr).p_response./100;
% 
%                 if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
%                     nBlue_mat = [nBlue_mat; nBlue_tr];
%                     N_mat = [N_mat; N_tr];
%                     p_response = [p_response; p_response_tr];
%                 end
% 
%                 clear nBlue_tr N_tr p_response_tr
% 
%             end
% 
%             % replace actual behaviour with simulated behaviour
%             load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
% 
%             p_response = sim_response;
%             clear sim_response
% 
%             for it = 1:iter
% 
%                 theta_start = [5*rand 0.5*rand]; % starting value for optimisation
%                 theta_lb = [0 0];
%                 theta_ub = [Inf Inf];
% 
%                 [theta_fit LL_fit]=fmincon(@(x) Bayes_expo2_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
% 
%                 if it > 1
% 
%                     if  LL_fit < LL(i)
%                         theta(i,:)=theta_fit;
%                         LL(i,:)=LL_fit;
%                     end
% 
%                 else
%                     theta(i,:)=theta_fit;
%                     LL(i,:)=LL_fit;
%                 end
% 
%             end
% 
%         end
% 
%         % save results
%         save(['sim_beh/' true_model '/Bayes_expo2_par_fit.mat'],'theta','LL')
% 
%         clear theta LL
% 
%         %% fit Bayesian updating model with free prior (noisy choice)
%         for i = 1:size(data,2)
% 
%             %prepare subject data
%             nBlue_mat = [];
%             N_mat = [];
%             p_response = [];
% 
%             for tr = 1:length(data(i).trial)
% 
%                 nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
%                 N_tr = data(i).trial(tr).sequence_type;
%                 p_response_tr = data(i).trial(tr).p_response./100;
% 
%                 if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
%                     nBlue_mat = [nBlue_mat; nBlue_tr];
%                     N_mat = [N_mat; N_tr];
%                     p_response = [p_response; p_response_tr];
%                 end
% 
%                 clear nBlue_tr N_tr p_response_tr
% 
%             end
% 
%             % replace actual behaviour with simulated behaviour
%             load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
% 
%             p_response = sim_response;
%             clear sim_response
% 
%             for it = 1:iter
% 
%                 theta_start = [20*rand+1 0.5*rand]; % starting value for optimisation
%                 theta_lb = [1 0];
%                 theta_ub = [Inf Inf];
% 
%                 [theta_fit LL_fit]=fmincon(@(x) Bayes_prior2_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
% 
%                 if it > 1
% 
%                     if  LL_fit < LL(i)
%                         theta(i,:)=theta_fit;
%                         LL(i,:)=LL_fit;
%                     end
% 
%                 else
%                     theta(i,:)=theta_fit;
%                     LL(i,:)=LL_fit;
%                 end
% 
%             end
%         end
% 
%         % save results
%         save(['sim_beh/' true_model '/Bayes_prior2_par_fit.mat'],'theta','LL')
% 
%         clear theta LL
% 
%         % %% fit Bayesian updating model with fixed rate (noisy choice)
%         % for i = 1:size(data,2)
%         %     
%         %     %prepare subject data
%         %     nBlue_mat = [];
%         %     N_mat = [];
%         %     p_response = [];
%         %     
%         %     for tr = 1:length(data(i).trial)
%         %         
%         %         nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
%         %         N_tr = data(i).trial(tr).sequence_type;
%         %         p_response_tr = data(i).trial(tr).p_response./100;
%         %         
%         %         if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
%         %             nBlue_mat = [nBlue_mat; nBlue_tr];
%         %             N_mat = [N_mat; N_tr];
%         %             p_response = [p_response; p_response_tr];
%         %         end
%         %         
%         %         clear nBlue_tr N_tr p_response_tr
%         %         
%         %     end
%         %     
%         %     % replace actual behaviour with simulated behaviour
%         %     load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
%         %     
%         %     p_response = sim_response;
%         %     clear sim_response
%         %     
%         %     for it = 1:iter
%         %         
%         %         theta_start = [5*rand 0.5*rand]; % starting value for optimisation
%         %         theta_lb = [0 0];
%         %         theta_ub = [Inf Inf];
%         % 
%         %         [theta_fit LL_fit]=fmincon(@(x) Bayes_rate2_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
%         % 
%         %         if it > 1
%         % 
%         %             if  LL_fit < LL(i)
%         %                 theta(i,:)=theta_fit;
%         %                 LL(i,:)=LL_fit;
%         %             end
%         % 
%         %         else
%         %             theta(i,:)=theta_fit;
%         %             LL(i,:)=LL_fit;
%         %         end
%         %     
%         %     end
%         %     
%         % end
%         % 
%         % % save results
%         % save(['sim_beh/' true_model '/Bayes_rate2_par_fit.mat'],'theta','LL')
%         % 
%         % clear theta LL
%         
% %         %% fit Bayesian updating model with exponential evidence weight and learning rate
% % 
% %     for i = 1:size(data,2)
% % 
% %         %prepare subject data
% %         nBlue_mat = [];
% %         N_mat = [];
% %         p_response = [];
% % 
% %         for tr = 1:length(data(i).trial)
% % 
% %             nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
% %             N_tr = data(i).trial(tr).sequence_type;
% %             p_response_tr = data(i).trial(tr).p_response./100;
% % 
% %             if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
% %                 nBlue_mat = [nBlue_mat; nBlue_tr];
% %                 N_mat = [N_mat; N_tr];
% %                 p_response = [p_response; p_response_tr];
% %             end
% % 
% %             clear nBlue_tr N_tr p_response_tr
% % 
% %         end
% %         
% %         % replace actual behaviour with simulated behaviour
% %         load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
% % 
% %         p_response = sim_response;
% %         clear sim_response
% % 
% %         for it = 1:iter
% % 
% %             theta_start = [5*rand 2*rand]; % starting value for optimisation
% %             theta_lb = [0 0];
% %             theta_ub = [Inf Inf];
% % 
% %             [theta_fit LL_fit]=fmincon(@(x) Bayes_expo_LR_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
% % 
% %             if it > 1
% % 
% %                 if  LL_fit < LL(i)
% %                     theta(i,:)=theta_fit;
% %                     LL(i,:)=LL_fit;
% %                 end
% % 
% %             else
% %                 theta(i,:)=theta_fit;
% %                 LL(i,:)=LL_fit;
% %             end
% % 
% %         end
% % 
% %     end
% % 
% %     % save results
% %     save(['sim_beh/' true_model '/Bayes_expo_LR_par_fit.mat'],'theta','LL')
% % 
% %     clear theta LL
% % 
% %     %% fit Bayesian updating model with free prior
% %     for i = 1:size(data,2)
% % 
% %         %prepare subject data
% %         nBlue_mat = [];
% %         N_mat = [];
% %         p_response = [];
% % 
% %         for tr = 1:length(data(i).trial)
% % 
% %             nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
% %             N_tr = data(i).trial(tr).sequence_type;
% %             p_response_tr = data(i).trial(tr).p_response./100;
% % 
% %             if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
% %                 nBlue_mat = [nBlue_mat; nBlue_tr];
% %                 N_mat = [N_mat; N_tr];
% %                 p_response = [p_response; p_response_tr];
% %             end
% % 
% %             clear nBlue_tr N_tr p_response_tr
% % 
% %         end
% %         
% %         % replace actual behaviour with simulated behaviour
% %         load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
% % 
% %         p_response = sim_response;
% %         clear sim_response
% % 
% % 
% %         for it = 1:iter
% % 
% %             theta_start = [20*rand+1 rand*2]; % starting value for optimisation
% %             theta_lb = [1 0];
% %             theta_ub = [Inf Inf] ;
% % 
% %             [theta_fit LL_fit]=fmincon(@(x) Bayes_prior_LR_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
% % 
% %             if it > 1
% % 
% %                 if  LL_fit < LL(i,:)
% %                     theta(i,:)=theta_fit;
% %                     LL(i,:)=LL_fit;
% %                 end
% % 
% %             else
% %                 theta(i,:)=theta_fit;
% %                 LL(i,:)=LL_fit;
% %             end
% % 
% %         end
% %     end
% % 
% %     % save results
% %     save(['sim_beh/' true_model '/Bayes_prior_LR_par_fit.mat'],'theta','LL')
% % 
% %     clear theta LL
% % 
% % % fit Bayesian updating model with free prior and recency par
% % for i = 1:size(data,2)
% %     
% %     prepare subject data
% %     nBlue_mat = [];
% %     N_mat = [];
% %     p_response = [];
% %     
% %     for tr = 1:length(data(i).trial)
% %         
% %         nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
% %         N_tr = data(i).trial(tr).sequence_type;
% %         p_response_tr = data(i).trial(tr).p_response./100;
% %         
% %         if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
% %             nBlue_mat = [nBlue_mat; nBlue_tr];
% %             N_mat = [N_mat; N_tr];
% %             p_response = [p_response; p_response_tr];
% %         end
% %         
% %         clear nBlue_tr N_tr p_response_tr
% %         
% %     end
% %     
% %     replace actual behaviour with simulated behaviour
% %     load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
% %     
% %     p_response = sim_response;
% %     clear sim_response
% %     
% %     
% %     for it = 1:iter
% %         
% %         theta_start = [20*rand+1 4*rand]; % starting value for optimisation
% %         theta_lb = [1 0];
% %         theta_ub = [Inf Inf];
% % 
% %         [theta_fit LL_fit]=fmincon(@(x) Bayes_prior_rec_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
% % 
% %         if it > 1
% % 
% %             if  LL_fit < LL(i)
% %                 theta(i,:)=theta_fit;
% %                 LL(i,:)=LL_fit;
% %             end
% % 
% %         else
% %             theta(i,:)=theta_fit;
% %             LL(i,:)=LL_fit;
% %         end
% %     
% %     end
% % end
% % 
% % save results
% % save(['sim_beh/' true_model '/Bayes_prior_rec_par_fit.mat'],'theta','LL')
% % 
% % clear theta LL
% % 
% % %% fit Bayesian updating model with free prior (noisy choice) and recency par
% % for i = 1:size(data,2)
% %     
% %     %prepare subject data
% %     nBlue_mat = [];
% %     N_mat = [];
% %     p_response = [];
% %     
% %     for tr = 1:length(data(i).trial)
% %         
% %         nBlue_tr = data(i).trial(tr).sequence_marbles_color1;
% %         N_tr = data(i).trial(tr).sequence_type;
% %         p_response_tr = data(i).trial(tr).p_response./100;
% %         
% %         if ~any([isnan(nBlue_tr) isnan(N_tr) isnan(p_response_tr)])
% %             nBlue_mat = [nBlue_mat; nBlue_tr];
% %             N_mat = [N_mat; N_tr];
% %             p_response = [p_response; p_response_tr];
% %         end
% %         
% %         clear nBlue_tr N_tr p_response_tr
% %         
% %     end
% %     
% %     % replace actual behaviour with simulated behaviour
% %     load(['sim_beh/' true_model '/sim_' data(i).sub_id '.mat'])
% %     
% %     p_response = sim_response;
% %     clear sim_response
% %     
% %     
% %     for it = 1:iter
% %         
% %         theta_start = [20*rand+1 4*rand 0.5*rand]; % starting value for optimisation
% %         theta_lb = [1 0 0];
% %         theta_ub = [Inf Inf Inf];
% % 
% %         [theta_fit LL_fit]=fmincon(@(x) Bayes_prior_rec2_model(x, nBlue_mat, N_mat, p_response),theta_start,[],[],[],[],theta_lb,theta_ub);
% % 
% %         if it > 1
% % 
% %             if  LL_fit < LL(i)
% %                 theta(i,:)=theta_fit;
% %                 LL(i,:)=LL_fit;
% %             end
% % 
% %         else
% %             theta(i,:)=theta_fit;
% %             LL(i,:)=LL_fit;
% %         end
% %     
% %     end
% % end
% % 
% % % save results
% % save(['sim_beh/' true_model '/Bayes_prior_rec2_par_fit.mat'],'theta','LL')
% % 
% % clear theta LL

end