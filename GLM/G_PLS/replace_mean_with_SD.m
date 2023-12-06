function replace_mean_with_SD
% This function loads mean_datamat files created with PLSgui (from sd_niftis 
% that were generated with VarTbx). The current content of the
% datamat files is not meaningful and they are only used for providing the
% correct structure input for later analysis with PLSgui. The actual data
% is taken from sd_nifti files output by VarTbx.

% ran as an interactive job with matlab/R2017b

pn.root = '/home/mpib/LNDG/Entscheidung2/analysis/GLM/PLS_results/pMod_var_norm/samples/';
pn.meanFiles = [pn.root, 'mean_datamats/'];
pn.sdFiles = [pn.root, 'sd_datamats/'];
pn.sdniftis = '/home/mpib/LNDG/Entscheidung2/analysis/GLM/results/pMod_var_norm/';

%toolboxes
addpath(genpath('/home/mpib/LNDG/toolboxes/NIfTI_20140122'));
addpath(genpath('/home/mpib/LNDG/toolboxes/preprocessing_tools'));

SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};
SessionID={'s1' 's2' 's3' 's4' 's5'}; % If no sessions, leave completely empty as a 0x0 cell

% Load common set of coordiants
load (['/home/mpib/LNDG/Entscheidung2/analysis/GLM/G_PLS/coords_EVAL.mat'], 'final_coords');

for indID = 1:numel(SubjectID)
    disp(['Processing subject ', SubjectID{indID}]);
    
    % load subject's sessiondata file
    a = load([pn.meanFiles, 'mean_', SubjectID{indID}, '_BfMRIsessiondata.mat']);
    
    a = rmfield(a,'st_datamat');
    a = rmfield(a,'st_coords');

    %replace fields with correct info.
    a.session_info.datamat_prefix   = (['SD_', SubjectID{indID}]); % SD PLS file name; _Bfmirsessiondata will be automatically appended!
    a.st_coords = final_coords;     % constrain analysis to shared non-zero GM voxels
    a.session_info.pls_data_path = pn.sdFiles;

    % load subject values for corresponding coordinates
    for indCond = 1:numel(SessionID)
        fname = dir([pn.sdniftis, SubjectID{indID} '/ResSD_' SessionID{indCond} '.nii' ]);
        fname = fname.name;
        
        img = double(S_load_nii_2d([pn.sdniftis, SubjectID{indID} '/' fname])); clear fname;
        img = img(final_coords,:); % restrict to final_coords
        
        a.st_datamat(indCond,:) = img;
        clear img;
    end
    
%     a.st_evt_list = a.st_evt_list(1:size(a.st_datamat,1));
%     a.num_subj_cond = a.num_subj_cond(1:size(a.st_datamat,1));
%     
%     a.session_info.num_conditions = size(a.st_datamat,1);
%     a.session_info.condition = a.session_info.condition(1:size(a.st_datamat,1));
%     a.session_info.condition_baseline = a.session_info.condition_baseline(1:size(a.st_datamat,1));
%     a.session_info.num_conditions0 = size(a.st_datamat,1);
%     a.session_info.condition0 = a.session_info.condition0(1:size(a.st_datamat,1));
%     a.session_info.condition_baseline0 = a.session_info.condition_baseline0(1:size(a.st_datamat,1));
%     a.session_info.run = 1:4;
    
    save([pn.sdFiles, a.session_info.datamat_prefix ,'_BfMRIsessiondata.mat'],'-struct','a','-mat');
    disp ([SubjectID{indID} ' done!'])
end