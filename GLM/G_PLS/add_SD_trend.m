function add_SD_trend
% compute linear trend in SD across samples conditions and add to
% SD_datamat

SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};
dataPath='/home/mpib/LNDG/Entscheidung2/analysis/GLM/PLS_results/pMod_var_norm/samples/sd_datamats';

for sj = 1:length(SubjectID)
    
    a=load(fullfile(dataPath,['SD_' SubjectID{sj} '_BfMRIsessiondata.mat']));
    
    %% add linear trend across samples condition
    
    if size(a.st_datamat,1) >= 6
       fprintf('trend condition already added... skip\n') 
    else

        % change SD_Datamat info
        a.num_subj_cond=[1 1 1 1 1 1];
        a.session_info.num_conditions=6;
        a.session_info.condition{6}='lin_trend';
        a.session_info.condition_baseline{6}=[0,1];
        a.session_info.num_conditions0=a.session_info.num_conditions;
        a.session_info.condition0=a.session_info.condition;
        a.session_info.condition_baseline0=a.session_info.condition_baseline;
        a.st_evt_list=[1 2 3 4 5 6];

        % run linear regression

        %design matrix for linear regression
        Nsamples = 5;

        X = [ones(Nsamples,1) (1:Nsamples)'];

        for vox = 1:size(a.st_datamat,2)

            % compute and add linear trend across samples for each voxel
            betas = X\a.st_datamat(1:Nsamples,vox);
            a.st_datamat(6,vox) = betas(2);

        end

        clear Nsamples X betas
    
    end
    
    %% add s1-s5 change condition
    
    if size(a.st_datamat,1) >= 7
       fprintf('diff condition already added... skip\n') 
    else
    
        % change SD_Datamat info
        a.num_subj_cond=[1 1 1 1 1 1 1];
        a.session_info.num_conditions=7;
        a.session_info.condition{7}='s5-s1_diff';
        a.session_info.condition_baseline{7}=[0,1];
        a.session_info.num_conditions0=a.session_info.num_conditions;
        a.session_info.condition0=a.session_info.condition;
        a.session_info.condition_baseline0=a.session_info.condition_baseline;
        a.st_evt_list=[1 2 3 4 5 6 7];

        a.st_datamat(7,:) = a.st_datamat(5,:) - a.st_datamat(1,:);
        
    end
    
    save(fullfile(dataPath,['SD_' SubjectID{sj} '_BfMRIsessiondata.mat']),'-struct','a')
    
    clear a
    
end

end