function get_beh
% compute additional behavioural variables

load('./PGT2016_data_MRIpost_04-Mar-2018.mat')

ID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};

Merror_p_response = nan(length(ID),1);
error_p_response = [];
p_dist = []; % actual proabbility distance from 0.5
sample_size = []; % control variable trial sample size
p_experienced = [];
p_responses = [];
p_true = [];
bias_slope = nan(length(ID),1);
bias_int = nan(length(ID),1);
sj_vec=[]; % subject vector for spss
sids=[];
Ntr_sub = nan(length(ID),1);

Ntr = 54; % MR trials only

for sj = 1:length(ID)

    sid = find(cellfun(@(x) strcmp(x,ID(sj)),{data.sub_id})); % look up subject id in data structure
    sids = [sids; sid];
    
    p_response = [];
    mean_act = [];
    mean_obj = [];
    samples = [];
    
    %Ntr=length([data(sj).trial]); % all trials
    
    % get estimation response and actual trial estimate
    for tr = 1:Ntr % tr trials only
    
            p_response = [p_response; data(sid).trial(tr).p_response./100]; 
            mean_act = [mean_act; data(sid).trial(tr).mean_act];  
            mean_obj = [mean_obj; data(sid).trial(tr).mean_obj]; 
            samples = [samples; data(sid).trial(tr).samplesize];
    
    end
    
    % exclude trials with missing responses
    nan_idx = unique([find(isnan(p_response)); find(isnan(mean_act)); find(isnan(samples))]);
    
    p_response(nan_idx) = [];
    mean_act(nan_idx) = [];
    samples(nan_idx) = [];
    
    miss = length(nan_idx);
    
    % collect data across subjects
    Ntr_sub(sj) = Ntr-miss;
    
    sj_vec=[sj_vec; repmat(sj,[Ntr-miss,1])];
    
    sample_size = [sample_size; samples];
    p_responses = [p_responses; p_response];
    p_experienced = [p_experienced; mean_act];
    p_true = [p_true; mean_obj];
    
    pd =  abs(mean_act - 0.5);
    p_dist = [p_dist; pd];
    
    ep = abs(mean_act - p_response);
    error_p_response = [error_p_response; ep];
    
%     if sum(isnan(ep)) > 0
%        fprintf('error. nans in some of the variables.')
%        pause
%     end
    
    % estimation accuracy (median absolute error)
    Merror_p_response(sj) = median(abs(mean_act - p_response)); 
    
    % get subjects' regression slopes for the effect of mean distance on
    % estimation error
    X = [ones(Ntr-miss,1) pd];
    
    betas = X\ep;
    bias_int(sj) = betas(1);
    bias_slope(sj) = betas(2);
    
    clear betas mean_act p_response pd ep nan_idx miss

end

% plot estimation errors
histogram(Merror_p_response,10)
xticks(0:0.05:0.2)
xlabel('estimation error')
ylabel('frequency')
set(gca,'FontSize',32);

saveas(gcf,'estimation_error.jpg')

pause

clf('reset')

% plot bias slopes
histogram(bias_slope,10)
%xticks(0:0.2:1.2)
xlabel('bias slope')
ylabel('frequency')
set(gca,'FontSize',32);

saveas(gcf,'bias_slopes.jpg')

pause

clf('reset')

% plot correlation between median estimation error and bias slopes
[r,p]=corr(bias_slope,Merror_p_response)
plot(bias_slope,Merror_p_response,'bo')
title(['r = ' num2str(round(r,2)) ', p = ' num2str(round(p,3))])
xlabel('bias slope')
ylabel('estimation error')
lsline

saveas(gcf,'bias_error_corr.jpg')

pause

clf('reset')

save('beh_measures.mat','Merror_p_response','error_p_response','sample_size','p_dist','bias_slope','sids','sj_vec','Ntr_sub','p_responses','p_experienced','bias_int','p_true')

end
