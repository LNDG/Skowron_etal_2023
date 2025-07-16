%model comparison
clear all

model_name = {'RW' 'Bayes_expo' 'Bayes_prior' 'Bayes_expo2' 'Bayes_prior2' 'Bayes_prior2_expo'};
Npar = [2 1 1 2 2 3]; % number of free model parameters

% matrix containing proportions of best simulated subjects' fitting model for each ground truth
% model (ground truth model x recovered model)

model_rec_mat = nan(length(model_name));

%% count datapoints per subject
% for some reason missing information post scanner (trials 54+) - not
% fitted here but should check

load('/Users/skowron/Documents/Entscheidung2_dump/modelling/PGT2016_data_MRIpost_04-Mar-2018.mat')

% get N subjects and N datapoints per subject
% Nsub = size(data,2);
% Ndata = nan(size(data,2),1); % is just 54 for everyone (all MR trials)

%N=51
load('/Users/skowron/Documents/Entscheidung2_dump/behaviour/beh_measures.mat','sids')
sub_ls = sids;
clear sids

Nsub = length(sub_ls);
Ndata = nan(Nsub,1);

for i = 1:size(data,2)
    
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
    
    Ndata(i)=length(p_response);
end

Ndata = Ndata(sub_ls);

% model recovery
for m = 1:length(model_name)
    
% model simulation folder
cd(['/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/sim_beh/' model_name{m}]) % simulated behaviour

LL_mat = nan(Nsub,length(model_name));

for m_rec = 1:length(model_name)
    load([model_name{m_rec} '_par_fit.mat'],'LL')
    LL_mat(:,m_rec) = LL(sub_ls);
    clear LL
end

%% overall BIC
LL_sum = sum(LL_mat,1); % sum of negative log likelihoods

BIC_total = nan(1,length(LL_sum));

for m_rec = 1:length(model_name)

    BIC_total(m_rec) = (Npar(m_rec)*Nsub)*log(sum(Ndata)) + 2.*LL_sum(m_rec);
        
    % if contains(model_name{m_rec},'2') || contains(model_name{m_rec},'RW')
    %     BIC_total(m_rec) = (2*Nsub)*log(sum(Ndata)) + 2.*LL_sum(m_rec); % error models / RW models
    % else
    %     BIC_total(m_rec) = Nsub*log(sum(Ndata)) + 2.*LL_sum(m_rec); % sampling models
    % end
    
end

plot(1:length(BIC_total),BIC_total,'r.','MarkerSize',50)
title(['true model' model_name{m}])
xticks(1:length(BIC_total))
xticklabels(model_name)
pause

BIC_total_mat(m,:)=BIC_total;

%% subject-wise BIC

BIC_sub = nan(size(LL_mat));

for m_rec = 1:length(model_name)
    for i = 1:Nsub

        BIC_sub(i,m_rec) = Npar(m_rec)*log(Ndata(i)) + 2.*LL_mat(i,m_rec); % error models
        
        % if contains(model_name{m_rec},'2') || contains(model_name{m_rec},'RW')
        %     BIC_sub(i,m_rec) = 2*log(Ndata(i)) + 2.*LL_mat(i,m_rec); % error models
        % else
        %     BIC_sub(i,m_rec) = log(Ndata(i)) + 2.*LL_mat(i,m_rec); % sampling models
        % end
        
    end
end

[~,best_model_sub]=min(BIC_sub,[],2);

% save in model recovery mat
for m_rec = 1:length(model_name)
    model_rec_mat(m,m_rec) = sum(best_model_sub == m_rec)/Nsub;
end

clear best_model_sub

% histogram(best_model_sub)
% xlabel('model')
% ylabel('#subjects')
% pause
% plot(BIC_sub')
% xlabel('model')
% ylabel('BIC')

end

%plot

% % custom colormap
% load('/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/util/hot_c.mat');

h=heatmap(round(model_rec_mat,2),'XLabel','recovered model','YLabel','simulated model')
labels = ["RW","expo","prior","expo+noise","prior+noise", "prior+expo+noise"];
h.XDisplayLabels = labels;
h.YDisplayLabels = labels;
set(gca,'FontSize',20);
pause

saveas(gcf,'/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/figures/model_rec2.jpg')

clf('reset')

save('/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/model_rec_comp2.mat','BIC_total_mat')