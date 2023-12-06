function make_meanbold_datamat
%% 2nd pre-step for PLS.
% Create meanbold PLS files from text batch files.
	% ran with matlab/R2017b as an interactive job

% For compilation, use:
% /opt/matlab/R2017b/bin/mcc -m make_meanbold_datamat -a /home/mpib/skowron/UCL_Chowdhury_RL/data/mri/analysis/task/PLS/toolboxes/PLS_LNDG2018/Pls

%% Subject List
SubjectID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};
%% Paths if not running compiled

%addpath(genpath('/home/mpib/skowron/UCL_Chowdhury_RL/data/mri/analysis/task/PLS/blocked/toolboxes/PLS_LNDG2018')); % check if latest version
addpath(genpath('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/toolboxes/pls-LNDG2018_TXTandMAT'))
%addpath(genpath('/home/mpib/LNDG/toolboxes/PLS/Full_toolbox_complete_modifications/Pls')); % check if latest version

BASEPATH=('/home/mpib/LNDG/Entscheidung2');
MEANPATH=([BASEPATH '/analysis/trial-wise_PLS/pMod_analysis/results/mean_datamats']);

%% Create mean-BOLD PLS files
for i=1:length(SubjectID)
    TextBatch=([SubjectID{i} '_meanbold_batch.txt']); % Text batch filename
    cd (MEANPATH) % The toolbox outputs our mean-BOLD PLS files in the current directory
    fprintf('Creating mean-BOLD PLS datamat for subject %s \n', SubjectID{i});
    batch_plsgui([ MEANPATH '/' TextBatch ]);
    fprintf('Finished creating PLS meanbold_datamat \n');   
end
