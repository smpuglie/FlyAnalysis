%% Muscle Imaging Leg Tracking and ForceProbe Workflow 

%% EpiFlash2CB2T Bar detection
trial = load('F:\Acquisition\181017\181017_F1_C1\EpiFlash2CB2T_Raw_181017_F1_C1_1.mat');
[~,~,~,~,~,D,trialStem] = extractRawIdentifiers(trial.name);
cd(D);

clear trials

% if the position of the prep changes, make a new set
trials{1} = 61:105;

routine = {
    'probeTrackROI_IR' 
    };

Nsets = length(trials);

%% Run scripts one at a time

% Set probe line 
Script_SetProbeLine 

% double check some trials
trial = load(sprintf(trialStem,215));
showProbeLocation(trial)

% trial = probeLineROI(trial);

% Find an area to smooth out the pixels
Script_FindAreaToSmoothOutPixels

% Track the bar
Script_TrackTheBarAcrossTrialsInSet

% Find the trials with Red LED transients and mark them down
% Script_FindTheTrialsWithRedLEDTransients % Using UV Led

% Fix the trials with Red LED transients and mark them down
% Script_FixTheTrialsWithRedLEDTransients % Using UV Led

% Find the minimum CoM, plot a few examples from each trial block and check.
% Script_FindTheMinimumCoM %% can run this any time, but probably best after all the probe positions have been calculated
Script_LookAtTrialsWithMinimumCoM %% can run this any time, but probably best after all the probe positions have been calculated

ZeroForce = 700-(setpoint-700);
Script_SetTheMinimumCoM_byHand

%% EpiFlash2T Calcium clusters calculation with bar
trial = load('F:\Acquisition\181011\181011_F2_C1\EpiFlash2CB2T_Raw_181011_F2_C1_1.mat');
[~,~,~,~,~,D,trialStem] = extractRawIdentifiers(trial.name);
cd(D);

clear trials

% 50 Hz, kmeans clustering
trials{1} = 1:15;

Nsets = length(trials);

for setidx = 1:Nsets
    trialnumlist = trials{setidx};
    fprintf('\t- Threshold\n');
    batch_avikmeansThreshold 
    trialnumlist = trials{setidx};
    fprintf('\t- Cluster\n');
    batch_avikmeansCalculation_v2
end

%% The previous routine set the clusters for the 50 Hz data. Now add cluster intensit to 100 Hz data
trial = load('F:\Acquisition\181011\181011_F3_C1\EpiFlash2CB2T_Raw_181011_F3_C1_1.mat');
setacqpref('quickshowPrefs','clmask',trial.clmask);

clear trials
trials{1} = 1:15;
trials{2} = 16:75;
Nsets = length(trials);

%% Save the clusters found for the 50Hz trials to all the other trials
for setidx = 1:Nsets
    trialnumlist = trials{setidx};
    for tr_idx = trialnumlist %1:length(data)
        
        trial = load(sprintf(trialStem,tr_idx));
        fprintf('%s: ',trial.name);
        if ~isfield(trial,'clmask')
            fprintf('No mask',trial.name);
        end
        trial.clmask = getacqpref('quickshowPrefs','clmask');
        save(trial.name, '-struct', 'trial')
        fprintf('\n');
    end
end

%% Now calculate all the cluster intensities

for setidx = 1:Nsets
    trialnumlist = trials{setidx};
    fprintf('\t- Intensity\n');
    batch_avikmeansClusterIntensity_nobar
end

