function get_timings_noInterest
% This function saves onset and duration vectors for each experimental condition for VarToolbox.

% ran on tardis with matlab/R2022b

cd('/home/mpib/LNDG/Entscheidung2/analysis/GLM')

ID = {'ENT3003', 'ENT3006', 'ENT3009', 'ENT3012', 'ENT3015', 'ENT3018', 'ENT3021', 'ENT3024', 'ENT3027', 'ENT3030', 'ENT3033', 'ENT3036', 'ENT3039', 'ENT3042', 'ENT3045', 'ENT3048', 'ENT3051', 'ENT3004', 'ENT3007', 'ENT3010', 'ENT3013', 'ENT3016', 'ENT3019', 'ENT3022', 'ENT3025', 'ENT3028', 'ENT3031', 'ENT3034', 'ENT3037', 'ENT3040', 'ENT3043', 'ENT3046', 'ENT3049', 'ENT3052', 'ENT3005', 'ENT3008', 'ENT3011', 'ENT3014', 'ENT3017', 'ENT3020', 'ENT3023', 'ENT3026', 'ENT3029', 'ENT3032', 'ENT3035', 'ENT3038', 'ENT3041', 'ENT3044', 'ENT3047', 'ENT3050', 'ENT3053'};
RunID = {'1', '2', '3'};

cond = {'grid','dec'}; %note: order needs to comply to temporal order in trial! Also naming convention needs to be according to the data structure.

load('/home/mpib/LNDG/Entscheidung2/analysis/PGT2016_data_MRIpost_04-Mar-2018.mat')

for c = 1:length(cond)
    for sj = 1:length(ID)
        for run = 1:length(RunID)


           % no initial discarded volumes, otherwise timing needs to be adjusted

          sid = find(cellfun(@(x) strcmp(x,ID(sj)),{data.sub_id})); % look up subject id in data structure

          onsets = nan(1,54); % 54 trials in MR
          durations = nan(1,54); % 54 trials in MR

          for i = 1:length(onsets) 
            onsets(i) = data(sid).trial(i).timing.(['time_' cond{c}]); % MR trials start from till 54; afterwards outside scanner
            
            if (strcmp('grid',cond{c}))
                durations(i) = data(sid).trial(i).rt_p/1000; % assuming rt is in ms
            elseif (strcmp('dec',cond{c}))
                durations(i) = data(sid).trial(i).rt_dec/1000; % assuming rt is in ms
            end
            
          end
          
          % get run specific timings
          if strcmp(RunID(run),'1')
              onsets = onsets(1:18);
              durations = durations(1:18);
          elseif strcmp(RunID(run),'2')
              onsets = onsets(19:36);
              durations = durations(19:36);
          elseif strcmp(RunID(run),'3')
              onsets = onsets(37:54);
              durations = durations(37:54);
          end
              

        % save trial_onsets text file for VarToolbox
        OutDir='/home/mpib/LNDG/Entscheidung2/analysis/GLM/timings/';

        if ~exist(OutDir, 'dir')
            mkdir(OutDir);
        end

        % save onsets onsets and durations
        dlmwrite([OutDir ID{sj} '_run' RunID{run} '_' cond{c} '_onsets.txt'], onsets');
        dlmwrite([OutDir ID{sj} '_run' RunID{run} '_' cond{c} '_durations.txt'], durations');

        clear onsets durations
        end
    end
end