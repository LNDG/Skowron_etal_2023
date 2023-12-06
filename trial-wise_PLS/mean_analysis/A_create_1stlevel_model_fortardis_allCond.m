function A_create_1stlevel_model_fortardis_allCond
% This function creates a 1st level model specification mat file per subject and per condition 
% which is called in the mat file specifying the job to be used as input to VarTbx.

% ran on tardis with matlab/R2022b

SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};

RunID = {'1', '2', '3'};

%Nvol = 1020; % number of volumes per run

cond = {'s1' 's2' 's3' 's4' 's5' 'grid' 'dec'};

for sub = 1:length(SubjectID)
    
    %% --- specify model ---
    %-----------------------------------------------------------------------
    %matlabbatch{1}.spm.stats.fmri_spec.dir = {['/Users/skowron/Documents/Entscheidung2_dump/spm_check']}; % spm mat path
    matlabbatch{1}.spm.stats.fmri_spec.dir = {['/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/data/mean_niftis_allCond/' SubjectID{sub} '/']}; % spm mat path
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
            sprintf('%s_run%s_feat_detrended_highpassed_denoised_MNI.nii,%d', SubjectID{sub}, RunID{run}, vol));
        end
        
        for c = 1:length(cond)
            %%
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).name = cond{c};
            %% trial onset times (in sec)
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).onset = load(['/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/timings/' SubjectID{sub} '_run' RunID{run} '_' cond{c} '_onsets.txt']);
            %
            if (strcmp('s1',cond{c}) || strcmp('s2',cond{c}) || strcmp('s3',cond{c}) || strcmp('s4',cond{c}) || strcmp('s5',cond{c}))
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).duration = ones(length(matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).onset),1); % samples durations without ISIs!
            elseif (strcmp('grid',cond{c}) || strcmp('dec',cond{c}))
                matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).duration = load(['/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/timings/' SubjectID{sub} '_run' RunID{run} '_' cond{c} '_durations.txt']);
            end
            
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond(c).orth = 1;

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

    outdir = '/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/data/spm_spec_allCond';
    %outdir = '/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/';
    if ~ exist(outdir)
        mkdir (outdir)
    end

    %save(fullfile(outdir,[SubjectID{sub},'_allCond_model.mat']), 'matlabbatch');
    
    clear matlabbatch
    
    %% --- estimate model ---
    
    %matlabbatch{1}.spm.stats.fmri_est.spmmat = {['/Users/skowron/Documents/Entscheidung2_dump/spm_check/SPM.mat']};
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {['/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/data/mean_niftis_allCond/' SubjectID{sub} '/SPM.mat']};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0; % useful for variability analysis
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
    
    % --- save batch job ---

    %save(fullfile(outdir,[SubjectID{sub},'_allCond_estim_model.mat']), 'matlabbatch');
    
    clear matlabbatch
    
    %% --- specify contrast ---
    
    %matlabbatch{1}.spm.stats.con.spmmat = {['/Users/skowron/Documents/Entscheidung2_dump/spm_check/SPM.mat']};
    matlabbatch{1}.spm.stats.con.spmmat = {['/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/mean_analysis/data/mean_niftis_allCond/' SubjectID{sub} '/SPM.mat']};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 's1';
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 's2';
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 's3';
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 's4';
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.name = 's5';
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{5}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.name = 'grid';
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0];
    matlabbatch{1}.spm.stats.con.consess{6}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.name = 'dec';
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.weights = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0];
    matlabbatch{1}.spm.stats.con.consess{7}.tcon.sessrep = 'replsc';
    matlabbatch{1}.spm.stats.con.delete = 1;
    
    % --- save batch job ---

    save(fullfile(outdir,[SubjectID{sub},'_allCond_con_model.mat']), 'matlabbatch');
    
    clear matlabbatch

end