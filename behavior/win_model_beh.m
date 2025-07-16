% outlier identification and windsorisation
clear all

load('beh_measures.mat','bias_slope','Merror_p_response','sids')
load('/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/Bayes_prior2_par_fit.mat')
theta_prior=theta;
LL_prior=LL;
clear theta LL
load('/Users/skowron/Documents/Entscheidung2_dump/modelling/Learning/Bayes_expo2_par_fit.mat')
theta_expo=theta;
LL_expo=LL;
clear theta LL

% gather variables
var_mat = [Merror_p_response bias_slope theta_prior(sids,:) LL_prior(sids) theta_expo(sids,:) LL_expo(sids)];
var_mat_org = var_mat;
var_names = {'estim error' 'bias_slope' 'prior par' 'noise par' 'LL' 'expo_par' 'noise_par_expo' 'LL_expo'};

%% windsorise
outliers = nan(1,size(var_mat,2));
imp_vals = nan(2,size(var_mat,2));


for v = 1:size(var_mat,2)

    % get cutoffs
    low_cutoff = prctile(var_mat(:,v),25) - 1.5*iqr(var_mat(:,v));
    high_cutoff = prctile(var_mat(:,v),75) + 1.5*iqr(var_mat(:,v));

    % find outliers
    low_out_idx = (var_mat(:,v) < low_cutoff);
    high_out_idx = (var_mat(:,v) > high_cutoff);

    % impute values
    val_set = var_mat(find((~(low_out_idx | high_out_idx))),v);
    
    low_imp = min(val_set);
    high_imp = max(val_set);

    var_mat(find(low_out_idx),v) = deal(low_imp);
    var_mat(find(high_out_idx),v) = deal(high_imp);
    
    % keep track
    outliers(v) = sum(((low_out_idx | high_out_idx)));
    imp_vals(:,v) = [low_imp high_imp];

    clear low_cutoff high_cutoff low_out_idx high_out_idx low_imp high_imp val_set

end

% save winsorised variables
save('win_model_beh.mat','var_names','var_mat','outliers','imp_vals','var_mat_org')