function B3_create_1stlevel_model_fortardis_allCond
% This function creates a 1st level model specification mat file per subject and per condition 
% which is called in the mat file specifying the job to be used as input to VarTbx.

% ran on tardis with matlab/R2022b

SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};

RunID = {'1', '2', '3'};

%Nvol = 1020; % number of volumes per run

cond = {'s1' 's2' 's3' 's4' 's5' 'grid' 'dec'};

for sub = 1:length(SubjectID)
    
for cc = 1:length(cond)

    %-----------------------------------------------------------------------
    %matlabbatch{1}.spm.stats.fmri_spec.dir = {['/Users/skowron/Documents/Entscheidung2_dump/spm_check']}; % spm mat path
    matlabbatch{1}.spm.stats.fmri_spec.dir = {['/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/data/sd_niftis_allCond/' SubjectID{sub} '/' cond{cc} '/']}; % spm mat path
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

    outdir = '/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/data/spm_spec_allCond';
    %outdir = '/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/';
    if ~ exist(outdir)
        mkdir (outdir)
    end

    save(fullfile(outdir,[SubjectID{sub},'_allCond_' cond{cc} '_model.mat']), 'matlabbatch');
    
    clear matlabbatch

end

end