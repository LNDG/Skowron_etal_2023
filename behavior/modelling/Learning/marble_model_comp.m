%model comparison
clear all

% model fit output folder
cd('/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning') % real behaviour

model_name = {'RW' 'Bayes_expo' 'Bayes_prior' 'Bayes_expo2' 'Bayes_prior2'};

load('/Users/skowron/Documents/Entscheidung2_dump/modelling/PGT2016_data_MRIpost_04-Mar-2018.mat')

% N=51
load('/Users/skowron/Documents/Entscheidung2_dump/behaviour/beh_measures.mat','sids')
sub_ls = sids';
clear sids
Nsub=length(sub_ls);

LL_mat = nan(Nsub,length(model_name));

for m = 1:length(model_name)
    load([model_name{m} '_par_fit.mat'],'LL')
    LL_mat(:,m) = LL(sub_ls);
    clear LL
end

%% count datapoints per subject
% for some reason missing information post scanner (trials 54+) - not
% fitted here but should check. every subject now 54 datapoints

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

%% overall BIC
LL_sum = sum(LL_mat,1); % sum of negative log likelihoods

BIC_total = nan(1,length(LL_sum));

for m = 1:length(model_name)

    if contains(model_name{m},'2')|| contains(model_name{m},'RW')
        BIC_total(m) = (2*Nsub)*log(sum(Ndata)) + 2.*LL_sum(m); % error models
    else
        BIC_total(m) = Nsub*log(sum(Ndata)) + 2.*LL_sum(m); % sampling models
    end

end

[~, best_model_all] = min(BIC_total)

% % without outlier
% LL_mat_filt = LL_mat([1:49 51:end],:);
% LL_sum_filt = sum(LL_mat_filt,1);
% 
% BIC_total_filt([1,3,5]) = sub_ls*log(sum(Ndata)) + 2.*LL_sum_filt([1,3,5]); % sampling models
% BIC_total_filt([2,4,6]) = (2*sub_ls)*log(sum(Ndata)) + 2.*LL_sum_filt([2,4,6]); % error models
% 
% [~, best_model_filt_all] = min(BIC_total_filt)

%% subject-wise BIC

BIC_sub = nan(size(LL_mat));

for m = 1:length(model_name)
    for i = 1:Nsub
        
        if contains(model_name{m},'2') || contains(model_name{m},'RW')
            BIC_sub(i,m) = 2*log(Ndata(i)) + 2.*LL_mat(i,m); % error models
        else
            BIC_sub(i,m) = log(Ndata(i)) + 2.*LL_mat(i,m); % sampling models
        end
        
    end
end

[~,best_model_sub]=min(BIC_sub,[],2);

% plotting
best_categ = categorical(best_model_sub,1:length(model_name),{'RW' 'expo' 'prior' 'expo+noise' 'prior+noise'});
histogram(best_categ,'BarWidth',0.9,'FaceColor',"#0096d1",'EdgeColor','none')
% xticks(1:length(model_name))
% xticklabels({'expo' 'prior' 'expo+noise' 'prior+noise'});
y_val = ylim;
ylim([y_val(1) y_val(2)+2])
xlabel('model')
ylabel('number of subjects')
set(gca,'FontSize',26);

saveas(gcf,'/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/figures/model_comp.jpg')

clf('reset')

plot(BIC_sub')
xlabel('model')
ylabel('BIC')
