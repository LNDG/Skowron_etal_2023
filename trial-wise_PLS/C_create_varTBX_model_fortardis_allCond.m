function C3_create_varTBX_model_fortardis_allCond
% This function creates an spm job specification mat file that is used as input to VarTbx.

% ran with matlab/R2017b on tardis as interactive job
     
SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};

cond = {'s1' 's2' 's3' 's4' 's5' 'grid' 'dec'};

% directory where mat file is saved
job_dir = ['/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/data/spm_spec_allCond'];
% job_dir = ['/Users/skowron/Documents/Entscheidung2_dump/spm_check'];

for sub = 1:length(SubjectID)
    for c = 1:length(cond)
        
        % specify matlabbatch
        matlabbatch{1}.spm.tools.variability.modeltype = 'lss';
        matlabbatch{1}.spm.tools.variability.modelmat = {fullfile(job_dir,[SubjectID{sub},'_allCond_' cond{c} '_model.mat'])}; % directory of 1st-level model
        matlabbatch{1}.spm.tools.variability.metric = 'sd';
        matlabbatch{1}.spm.tools.variability.resultprefix = [SubjectID{sub},'_allCond_sd'];
        matlabbatch{1}.spm.tools.variability.resultdir = {['/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/data/sd_niftis_allCond/' SubjectID{sub} '/' cond{c} '/']}; % output directory for nifti file
        %matlabbatch{1}.spm.tools.variability.resultdir = {['/Users/skowron/Documents/Entscheidung2_dump/spm_check/']}; % output directory for nifti file
        %matlabbatch{1}.spm.tools.variability.savebeta = false; % toggle saving beta timeseries
        
        %save(fullfile('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/',[SubjectID{sub},'_samples_sdmodel.mat']), 'matlabbatch');
        save(fullfile(job_dir,[SubjectID{sub},'_allCond_' cond{c} '_sdmodel.mat']), 'matlabbatch');
        
    end
end