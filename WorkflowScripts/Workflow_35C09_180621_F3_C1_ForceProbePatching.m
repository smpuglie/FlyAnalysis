%% ForceProbe patcing workflow 180621_F1_C1
trial = load('B:\Raw_Data\180621\180621_F3_C1\CurrentStep2T_Raw_180621_F3_C1_175.mat');
[protocol,dateID,flynum,cellnum,trialnum,D,trialStem,datastructfile] = extractRawIdentifiers(trial.name);

cd (D)
clear trials

%% Current step to get force
trial = load('B:\Raw_Data\180621\180621_F3_C1\CurrentStep2T_Raw_180621_F3_C1_175.mat');
[~,~,~,~,~,~,trialStem,~] = extractRawIdentifiers(trial.name);

clear trials
trials{1} = 41:52;
trials{2} = 114:185;

Nsets = length(trials);

% check the location
trial = load(sprintf(trialStem,52));
% showProbeImage(trial)

routine = {
    'probeTrackROI_IR' 
    'probeTrackROI_IR' 
    'probeTrackROI_IR' 
    };

%% epi flash random movements

trial = load('B:\Raw_Data\180621\180621_F3_C1\EpiFlash2T_Raw_180621_F3_C1_8.mat');
[~,~,~,~,~,~,trialStem,~] = extractRawIdentifiers(trial.name);

clear trials
trials{1} = 1:4;
Nsets = length(trials);
    
trial = load(sprintf(trialStem,3));
showProbeImage(trial)

routine = {
    'probeTrackROI_IR' 
    };

%% ramps cause spikes for this neuron
% just spikes

trial = load('B:\Raw_Data\180621\180621_F3_C1\PiezoRamp2T_Raw_180621_F3_C1_1.mat');
[~,~,~,~,~,~,trialStem,~] = extractRawIdentifiers(trial.name);

clear trials
trials{1} = 1:60;
Nsets = length(trials);
    
% showProbeImage(trial)

routine = {
    };


%% Set probe line 

close all
% Go through all the sets of trials
for set = 1:Nsets
    fprintf('\n\t***** Batch %d of %d\n',set,Nsets);
    trialnumlist = trials{set};
    
    br = waitbar(0,sprintf('Batch %d of %d',set,Nsets));
    br.Position =  [1050    251    270    56];
    
    % set probeline for a few test movies
    for tr_idx = trialnumlist(1:4) 
        trial = load(sprintf(trialStem,tr_idx));
        
        waitbar((tr_idx-trialnumlist(1)+1)/6,br,regexprep(trial.name,{regexprep(D,'\\','\\\'),'_'},{'','\\_'}));
        
        fprintf('%s\n',trial.name);
        if isfield(trial,'excluded') && trial.excluded
            fprintf(' * Bad movie: %s\n',trial.name)
            continue
        end
        trial = probeLineROI(trial);
    end
    
    % just set the line for the rest of the trials
    temp.forceProbe_line = getacqpref('quickshowPrefs','forceProbeLine');
    temp.forceProbe_tangent = getacqpref('quickshowPrefs','forceProbeTangent');

    for tr_idx = trialnumlist(5:end)
        trial = load(sprintf(trialStem,tr_idx));
        if ~isfield(trial,'forceProbe_line')
            trial.forceProbe_line = temp.forceProbe_line;
            trial.forceProbe_tangent = temp.forceProbe_tangent;
            fprintf('Saving bar and tangent in trial %s\n',num2str(tr_idx))
            save(trial.name,'-struct','trial')
        else
            fprintf('Bar and tangent already in trial %s\n',num2str(tr_idx))
        end

    end
    
    delete(br);
end

%% double check some trials
trial = load(sprintf(trialStem,6));
showProbeLocation(trial)

% trial = probeLineROI(trial);

%% Find an area to smooth out the pixels
for set = 1:Nsets
    trialnumlist = trials{set};
    
    for tr_idx = trialnumlist(1:3)
        trial = load(sprintf(trialStem,tr_idx));
        
        if (~isfield(trial,'excluded') || ~trial.excluded) 
            tic
            fprintf('%s\n',trial.name);
            trial = smoothOutBrightPixels(trial);
            
            toc
        else
            fprintf('\t* Bad movie: No line or tangent: %s\n',trial.name);
            continue
        end
    end
    
    % just set the line for the rest of the trials
    temp.ROI = getpref('quickshowPrefs','brightSpots2Smooth');

    for tr_idx = trialnumlist(4:end)
        trial = load(sprintf(trialStem,tr_idx));
        trial.brightSpots2Smooth = temp.ROI;
        fprintf('Saving bright spots to smooth in trial %s\n',num2str(tr_idx))
        save(trial.name,'-struct','trial')
    end
end

%% Track the bar

for set = 1:Nsets
    fprintf('\n\t***** Batch %d of %d\n',set,Nsets);
    trialnumlist = trials{set};
    
    close all
    
    br = waitbar(0,'Batch');
    br.Position =  [1050    251    270    56];
    
    for tr_idx = trialnumlist
        trial = load(sprintf(trialStem,tr_idx));
        
        waitbar((tr_idx-trialnumlist(1))/length(trialnumlist),br,regexprep(trial.name,{regexprep(D,'\\','\\\'),'_'},{'','\\_'}));
        
        if isfield(trial ,'forceProbe_line') && isfield(trial,'forceProbe_tangent') && (~isfield(trial,'excluded') || ~trial.excluded) && ~isfield(trial,'forceProbeStuff')
            fprintf('%s\n',trial.name);
            eval(routine{set}); %probeTrackROI_IR;
        elseif isfield(trial,'forceProbeStuff')
            fprintf('%s\n',trial.name);
            fprintf('\t*Has profile: passing over trial for now\n')
            
            %OR...
            %fprintf('\t*Has profile: redoing\n')
            %eval(routine{set}); %probeTrackROI_IR;

            %OR...
            if isfield(trial.forceProbeStuff,'keimograph')
                fprintf('\t*Moving keimograph to alt file: redoing\n')
                keimograph = trial.forceProbeStuff.keimograph;
                save(regexprep(trial.name,'_Raw_','_keimograph_'),'keimograph');
                trial.forceProbeStuff = rmfield(trial.forceProbeStuff,'keimograph');
                save(trial.name,'-struct','trial')
            end
            if exist(regexprep(trial.name,'.mat','_barkeimograph.mat'),'file')
                fprintf('\t*Moving keimograph to alt file: movefile\n')
                movefile(regexprep(trial.name,'.mat','_barkeimograph.mat'),regexprep(trial.name,'_Raw_','_keimograph_'));
            end
        else
            fprintf('\t* Bad movie: No line or tangent: %s\n',trial.name);
            continue
        end
    end
    
    delete(br);
    
end

%% Epi flash trials

%% Extract spikes

% for now, use trials in the sets
close all
% Go through all the sets of trials
for set = 1:Nsets
    fprintf('\n\t***** Batch %d of %d\n',set,Nsets);
    trialnumlist = trials{set};
        
    % Do a little investigation of filter properties on a couple of trials
    % first
    spikevars_cell = cell(3,1); cnt = 0;
    for tr_idx = trialnumlist(1:5) 
        trial = load(sprintf(trialStem,tr_idx)); 
                
        fprintf('%s\n',trial.name);
        if isfield(trial,'excluded') && trial.excluded
            fprintf(' * Bad movie: %s\n',trial.name)
            continue
        end
        cnt = cnt+1;
        fstag = ['fs' num2str(trial.params.sampratein)];
        if ~isfield(trial,'spikeDetectionParams')
            spikevars = getacqpref('FlyAnalysis',['Spike_params_' fstag]);
            
            switch trial.params.mode_1; case 'VClamp', invec1 = 'current_1'; case 'IClamp', invec1 = 'voltage_1'; otherwise; invec1 = 'voltage_1'; end
            [h.trial,spikevars_cell{cnt}] = spikeDetection(trial,invec1,spikevars);
        else
            fprintf('Got some spike vars already\n');
            spikevars_cell{cnt} = trial.spikeDetectionParams;
            spikevars = trial.spikeDetectionParams;
            switch trial.params.mode_1; case 'VClamp', invec1 = 'current_1'; case 'IClamp', invec1 = 'voltage_1'; otherwise; invec1 = 'voltage_1'; end
        end
        
        if cnt>=3
            break
        end
    end
    
    thresh = 0;
    peak = Inf;
    spikeTemplate = zeros(size(spikevars.spikeTemplate));
    for cnt = 1:length(spikevars_cell)
        thresh = max([thresh,spikevars_cell{cnt}.Distance_threshold]);
        peak = min([peak,spikevars_cell{cnt}.peak_threshold]);
        spikeTemplate = spikeTemplate + spikevars_cell{cnt}.spikeTemplate;
    end
    spikevars.spikeTemplate = spikeTemplate/cnt;
    spikevars.Distance_threshold = thresh;
    spikevars.peak_threshold = peak;
    
    [distancestructure] = spikeDetectionBatch(trialStem,trialnumlist,invec1,spikevars);
    close all; spikeSpotCheckBatch(trialStem,trialnumlist,invec1,'spikes',distancestructure);
    
end

