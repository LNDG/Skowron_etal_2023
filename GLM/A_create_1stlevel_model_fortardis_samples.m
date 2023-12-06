function A_create_1stlevel_model_fortardis_samples
% This function creates a 1st level model specification mat file per subject and per condition 
% which is called in the mat file specifying the job to be used as input to VarTbx.

%addpath(genpath('/home/mpib/LNDG/toolboxes/spm_LP/SPM/'))

% ran on tardis with matlab/R2022b

SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};

RunID = {'1', '2', '3'};

cond_names = {'samples' 'grid' 'dec'};

%Nvol = 1020; % number of volumes per run

% create output directory
outdir = '/home/mpib/LNDG/Entscheidung2/analysis/GLM/results/pMod_var_norm/spm_spec_samples';
%outdir = '/home/mpib/LNDG/Entscheidung2/analysis/GLM/';
if ~ exist(outdir)
    mkdir (outdir)
end

for sub = 1:length(SubjectID)

    %% --- specify model ---
    %matlabbatch{1}.spm.stats.fmri_spec.dir = {['/Users/skowron/Documents/Entscheidung2_dump/spm_check']}; % spm mat path
    matlabbatch{1}.spm.stats.fmri_spec.dir = {['/home/mpib/LNDG/Entscheidung2/analysis/GLM/results/pMod_var_norm/' SubjectID{sub} '/']}; % spm mat path
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 0.645; % TR
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16; % microtime resolution (default)
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8; % microtime onset (default)
    %%
        
    for run = 1:length(RunID)
        
        Nvol = niftiinfo(fullfile('/home/mpib/LNDG/Entscheidung2/data', SubjectID{sub}, ['func/run' RunID{run}], [SubjectID{sub} '_run' RunID{run} '_feat_detrended_highpassed_denoised_MNI.nii']));
        Nvol = Nvol.ImageSize(4);
        
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = {};
        for vol = 1:Nvol
%             matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans{vol,1} = fullfile('/Users/skowron/Documents/Entscheidung2_dump/spm_check', SubjectID{sub}, ['func/run' RunID{run}], ...
%             sprintf('%s_run%s_feat_detrended_highpassed_denoised_MNI.nii,%d', SubjectID{sub}, RunID{run}, vol)); % demean images necessary??
%         
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans{vol,1} = fullfile('/home/mpib/LNDG/Entscheidung2/data', SubjectID{sub}, ['func/run' RunID{run}], ...
            sprintf('%s_run%s_feat_detrended_highpassed_denoised_MNI.nii,%d', SubjectID{sub}, RunID{run}, vol)); % demean images necessary??
        end
        
        for c = 1:length(cond_names)
        
            %%
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).name = cond_names{c};
            %% trial onset times (in sec)
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).onset = load(['/home/mpib/LNDG/Entscheidung2/analysis/GLM/timings/' SubjectID{sub} '_run' RunID{run} '_' cond_names{c} '_onsets.txt']);
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).duration = load(['/home/mpib/LNDG/Entscheidung2/analysis/GLM/timings/' SubjectID{sub} '_run' RunID{run} '_' cond_names{c} '_durations.txt']);
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).tmod = 0;
            
            %parametric modulation
            if strcmp(cond_names{c},'samples')
                
                load(['./beh_modelling/Bayes_norm/sim_' SubjectID{sub} '.mat'],'sd_traj')
                %load(['./beh_modelling/Bayes_prior2/sim_' SubjectID{sub} '.mat'],'sd_traj')

                M_traj = mean(reshape(sd_traj,[size(sd_traj,1)*size(sd_traj,2),1]));
                C_traj = sd_traj - M_traj; % demean parameter to orthogonalise it to the ME regressor

                % get run specific trials
                if strcmp(RunID(run),'1')
                      C_traj = C_traj(1 : 18,:);
                elseif strcmp(RunID(run),'2')
                      C_traj = C_traj(19 : 36,:);
                elseif strcmp(RunID(run),'3')
                      C_traj = C_traj(37 : 54,:);
                end

                C_traj = reshape(C_traj',[size(C_traj,1)*size(C_traj,2), 1]);

                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).pmod.name = 'posterior var';
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).pmod.param = C_traj;
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).pmod.poly = 1;
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).orth = 0;
                
            else
                
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).pmod = struct('name', {}, 'param', {}, 'poly', {});
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).orth = 1;
            
            end
            
        end

        matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress = struct('name', {}, 'val', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf = 128;
    
    end
    
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'FAST'; % AR(1) - default
    
    % --- save batch job ---
    
    %save(fullfile(outdir,[SubjectID{sub},'_samples_spec_model.mat']), 'matlabbatch');
    
    clear matlabbatch
    
    %% --- estimate model ---
    
    %matlabbatch{1}.spm.stats.fmri_est.spmmat = {['/Users/skowron/Documents/Entscheidung2_dump/spm_check/SPM.mat']};
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {['/home/mpib/LNDG/Entscheidung2/analysis/GLM/results/pMod_var_norm/' SubjectID{sub} '/SPM.mat']};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 1; % useful for variability analysis
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
    
    % --- save batch job ---

    %save(fullfile(outdir,[SubjectID{sub},'_samples_estim_model.mat']), 'matlabbatch');
    
    clear matlabbatch
    
    %% --- specify contrast ---
    
    %matlabbatch{1}.spm.stats.con.spmmat = {['/Users/skowron/Documents/Entscheidung2_dump/spm_check/SPM.mat']};
    matlabbatch{1}.spm.stats.con.spmmat = {['/home/mpib/LNDG/Entscheidung2/analysis/GLM/results/pMod_var_norm/' SubjectID{sub} '/SPM.mat']};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'posterior var PM bf';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [0 0 0 1 1 1 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'posterior var PM';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 1 0 0 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.delete = 0;
    
    % --- save batch job ---

    save(fullfile(outdir,[SubjectID{sub},'_samples_con_model.mat']), 'matlabbatch');
    
    clear matlabbatch
    
end