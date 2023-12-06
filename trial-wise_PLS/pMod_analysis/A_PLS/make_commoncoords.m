function make_commoncoords
%% 3rd pre-step for PLS analysis
% Input: 1)SubjectID
% Create GM masked common coordiantes for all subject/conditions/runs

% ran as an interactive job with matlab/R2017b

%% Settings

% MNI Size
MNI=3;

% ID Lists
SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};

%% Initiate paths
BASEPATH=(['/home/mpib/LNDG/Entscheidung2/']);
DATAPATH=([BASEPATH 'analysis/GLM/results/pMod_var_norm']);
SAVEPATH=([BASEPATH, 'analysis/trial-wise_PLS/pMod_analysis/A_PLS/coords_EVAL.mat']);
GRAYPATH=['/home/mpib/LNDG/Standards/binary_masks/avg152_T1_gray_mask_90_' num2str(MNI) 'mm_binary.nii']; % Binary Gray matter mask

% Comment out if running compiled
addpath(genpath('/home/mpib/LNDG/toolboxes/NIfTI_20140122'));
addpath(genpath('/home/mpib/LNDG/toolboxes/preprocessing_tools'));

%% Initiate coordinate size for NIfTI files
if MNI >= 1
    nii_coords= 1:floor(182/MNI)*floor(218/MNI)*floor(182/MNI) ; % 1MM = 182*218*182
elseif MNI == 0.5
    nii_coords= 1:364*436*364;
end

%% Find common coordiantes for all subjects/runs
for i = 1:numel(SubjectID)
            
            %% Set image name/path
            NIIPATH=([DATAPATH '/' SubjectID{i} '/']);
            NIINAME=dir([NIIPATH '/con_0007.nii']);
            
            NIINAME=NIINAME.name;
            
            %% Find common coords
            fname=([ NIIPATH NIINAME ]);

            [ coords ] = double(S_load_nii_2d( fname ));
            %coords=load_nii([ NIIPATH NIINAME '.nii']);
            %coords=reshape(coords.img,[],coords.hdr.dime.dim(5));
            coords(isnan(coords))=0; % Necessary to avoid NaNs, which cause problems for PLS analysis
            coords = find(coords(:,1));
            
            % Add to common coordinates
            nii_coords=intersect(nii_coords,coords);
            
            clear coords
%     end
    disp (['Finished with subject ' SubjectID{i}])
end

%% Gray Matter Mask
% Find coordiantes of gray matter mask
GM_coords = load_nii(GRAYPATH);
GM_coords = reshape(GM_coords.img, [],1);
GM_coords = find(GM_coords);

% Perform gray matter masking of common coordinates
final_coords = intersect(nii_coords, GM_coords);

%% Export coordinates
save (SAVEPATH ,'nii_coords', 'final_coords', 'GM_coords');

end
