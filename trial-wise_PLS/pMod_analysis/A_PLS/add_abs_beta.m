function add_abs_beta
% compute linear trend in SD across samples conditions and add to
% SD_datamat

SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};
dataPath='/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/pMod_analysis/results/beta_datamats';

for sj = 1:length(SubjectID)
    
    a=load(fullfile(dataPath,['beta_' SubjectID{sj} '_BfMRIsessiondata.mat']));
    
    %% add absolute beta (effect size) condition
    
    if size(a.st_datamat,1) >= 2
       fprintf('abs condition already added... skip\n') 
    else

        % change SD_Datamat info
        a.num_subj_cond=[1 1];
        a.session_info.num_conditions=2;
        a.session_info.condition{2}='pMod_abs';
        a.session_info.condition_baseline{2}=[0,1];
        a.session_info.num_conditions0=a.session_info.num_conditions;
        a.session_info.condition0=a.session_info.condition;
        a.session_info.condition_baseline0=a.session_info.condition_baseline;
        a.st_evt_list=[1 2];

        % add absolute effects size condition
        a.st_datamat(2,:) = abs(a.st_datamat(1,:));
    
    end
    
    save(fullfile(dataPath,['beta_' SubjectID{sj} '_BfMRIsessiondata.mat']),'-struct','a')
    
end

end