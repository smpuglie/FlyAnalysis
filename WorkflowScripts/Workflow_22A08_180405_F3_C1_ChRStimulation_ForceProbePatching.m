%% ForceProbe patcing workflow 180405_F3_C1
trial = load('B:\Raw_Data\180405\180405_F3_C1\EpiFlash2T_Raw_180405_F3_C1_43.mat');
[protocol,dateID,flynum,cellnum,trialnum,D,trialStem,datastructfile] = extractRawIdentifiers(trial.name);

cd (D)
clear trials

%% epi flash Twitch movements

trial = load('B:\Raw_Data\180405\180405_F3_C1\EpiFlash2T_Raw_180405_F3_C1_43.mat');
[~,~,~,~,~,D,trialStem,~] = extractRawIdentifiers(trial.name); cd (D)

clear trials 
trials{1} = 42:85; % Low
trials{2} = 86:125; % High 

% dists = [0 0 75 150 -75 -150 0 0];

% trials{2} = 10:19; % these trials have no probe. No sense in doing
% running this now
Nsets = length(trials);
    
trial = load(sprintf(trialStem,43));
% showProbeImage(trial)

routine = {
    'probeTrackROI_IR' 
    'probeTrackROI_IR' 
    };


%% Run scripts one at a time

% Set probe line 
Script_SetProbeLine 

% double check some trials
trial = load(sprintf(trialStem,66));
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

trialnumlist_specific = 42:125;
ZeroForce = 782.8;
Script_SetTheMinimumCoM_byHand


% Extract spikes
Script_ExtractSpikesFromInterestingTrials

%%
Script_PlotTwitchesColoredBySpikeNumber

