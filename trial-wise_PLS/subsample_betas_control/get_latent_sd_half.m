clear all

% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/NIfTI_20140122'));
% addpath(genpath('/Users/skowron/Volumes/tardis2/toolboxes/preprocessing_tools'));

addpath(genpath('/home/mpib/LNDG/toolboxes/NIfTI_20140122'));
addpath(genpath('/home/mpib/LNDG/toolboxes/preprocessing_tools'));

PLS_result_path='/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats';
pn.sdniftis = '/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/data/sd_niftis_allCond/';

SessionID={'1' '2' '3' '4' '5'};
% s1 s2 s3 s4 s5

%% beh PLS

% get subj names for N=47
load('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/results/allCond/sd_datamats/allCond_ranked_errorOnlyRANK_N47_BehPLS_BfMRIresult.mat','subj_name')
clear result

subj_name = cellfun(@(x) x(4:end), subj_name, 'UniformOutput', false);

% load common coords
load('/home/mpib/LNDG/Entscheidung2/analysis/trial-wise_PLS/E_PLS/coords_samples/coords_EVAL.mat')

%% get sdBold for each condition of first and second half of trials

st_datamat1=[];
st_datamat2=[];

for i = 1:length(subj_name)
    
    fprintf(['Getting SD BOLD for ' subj_name{i} '\n'])
    
    % load subject values for corresponding coordinates
    st_datamat1_sub = nan(length(SessionID),length(final_coords));
    st_datamat2_sub = nan(length(SessionID),length(final_coords));
    
    for indCond = 1:length(SessionID)
        
        fname = fullfile(pn.sdniftis, subj_name{i}, ['s' SessionID{indCond}], 'beta_series',[subj_name{i} '_allCond_sd_s' SessionID{indCond} '_beta_series.nii']);
        
        img = double(S_load_nii_2d(fname)); clear fname;
        img = img(final_coords,:); % restrict to final_coords
        
        % compute first and second half sd
        st_datamat1_sub(indCond,:) = std(img(:,1:27)');
        st_datamat2_sub(indCond,:) = std(img(:,28:54)');
        clear img
        
    end
    
    % concatenate subjects
    st_datamat1 = [st_datamat1, st_datamat1_sub];
    st_datamat2 = [st_datamat2, st_datamat2_sub];

    clear st_datamat1_sub st_datamat2_sub
    
end

%% save stuff

save('sd_half_control.mat','st_datamat1','st_datamat2');