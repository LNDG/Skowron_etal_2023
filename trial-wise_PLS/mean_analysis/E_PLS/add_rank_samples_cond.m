function add_rank_samples_cond
% add sample Size cond and linear trend across sample sizes

%toolboxes
addpath(genpath('/home/mpib/LNDG/toolboxes/NIfTI_20140122'));
addpath(genpath('/home/mpib/LNDG/toolboxes/preprocessing_tools'));

SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};
dataPath='/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/results/allCond/beta_datamats';

% create rank conditions
st_samples_cat = [];

for sj = 1:length(SubjectID)
    
    sub_conds=load(fullfile(dataPath,['beta_' SubjectID{sj} '_BfMRIsessiondata.mat']));
    
    st_samples_cat = [st_samples_cat; sub_conds.st_datamat(1:5,:)];
    
end

% create rank scores
st_samples_cat = tiedrank(st_samples_cat);

% create subject index for rank matrix
sj_idx = repmat(1:length(SubjectID),[5,1]);
sj_idx = reshape(sj_idx,[numel(sj_idx),1]);

for sj = 1:length(SubjectID)
    
    a=load(fullfile(dataPath,['beta_' SubjectID{sj} '_BfMRIsessiondata.mat']));
    
    %% add rank conditions
    
%     if size(a.st_datamat,1) >= 14
%        fprintf('rank samples conditions already added... skip\n') 
%     else

        % change SD_Datamat info
        a.num_subj_cond=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
        a.session_info.num_conditions=16;
        a.session_info.condition{12}='rank_s1';
        a.session_info.condition{13}='rank_s2';
        a.session_info.condition{14}='rank_s3';
        a.session_info.condition{15}='rank_s4';
        a.session_info.condition{16}='rank_s5';
        a.session_info.condition_baseline(12:16)=deal({[0,1]});
        a.session_info.num_conditions0=a.session_info.num_conditions;
        a.session_info.condition0=a.session_info.condition;
        a.session_info.condition_baseline0=a.session_info.condition_baseline;
        a.st_evt_list=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];
        
        % insert subject condition

        a.st_datamat(12:16,:) = st_samples_cat(sj_idx == sj,:);
        
        % save
        save(fullfile(dataPath,['beta_' SubjectID{sj} '_BfMRIsessiondata.mat']),'-struct','a')
    
        clear a
    
end

end