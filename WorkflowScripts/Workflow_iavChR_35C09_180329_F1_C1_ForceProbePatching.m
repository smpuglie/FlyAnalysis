%% ForceProbe patcing workflow 180329_F1_C1
trial = load('B:\Raw_Data\180329\180329_F1_C1\CurrentStep2T_Raw_180329_F1_C1_11.mat');
[protocol,dateID,flynum,cellnum,trialnum,D,trialStem,datastructfile] = extractRawIdentifiers(trial.name);

cd (D)
clear trials

%% Current step to get force
trial = load('B:\Raw_Data\180329\180329_F1_C1\CurrentStep2T_Raw_180329_F1_C1_11.mat');
[~,~,~,~,~,~,trialStem,~] = extractRawIdentifiers(trial.name);

clear trials
% trials{1} = 11:15; Not worth analysing
% trials{1} = (33:75); % the probe is not in focus
trials{1} = 34:75; % before this (33:75) the probe is not in focus
trials{2} = 76:91; % MLA, no spikes, except when current injected
trials{3} = 92:103; % MLA, longer current injection, no spikes during baseline

Nsets = length(trials);

% check the location
trial = load(sprintf(trialStem,35));
% showProbeImage(trial)

routine = {
    'probeTrackROI_IR' 
    'probeTrackROI_IR' 
    'probeTrackROI_IR' 
    };

%% epi flash random movements

trial = load('B:\Raw_Data\180329\180329_F1_C1\EpiFlash2T_Raw_180329_F1_C1_9.mat');
[~,~,~,~,~,~,trialStem,~] = extractRawIdentifiers(trial.name);

clear trials
trials{1} = 9:40; % Low
trials{2} = 41:69; % High
trials{3} = 70:101; % MLA, early, low intensity
trials{4} = 102:133; % MLA, late, high intensity
trials{5} = 134:165; % MLA washout no spikes
Nsets = length(trials);
    
trial = load(sprintf(trialStem,9));
showProbeImage(trial)

routine = {
    'probeTrackROI_IR' 
    'probeTrackROI_IR' 
    'probeTrackROI_IR' 
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
Script_FindTheMinimumCoM %% can run this any time, but probably best after all the probe positions have been calculated

% Extract spikes
Script_ExtractSpikesFromInterestingTrials

%% Interesting things for this fly
% include addition of MLA. Useful to compare forces on the bar with or
% without input to the motor neuron spiking. 

% MLA is an important manipulation
trialStem = 'CurrentStep2T_Raw_180329_F1_C1_%d.mat';
showProbeImage(load(sprintf(trialStem,75)))
showProbeImage(load(sprintf(trialStem,76)))

% Trials before and after MLA are in the same position, so it is possible
% to compare probe positions






