function h = LEDArduinoFlash_blockAvg(h, handles, savetag) 
% TODO - savetag?
inTrial = handles.trial;

T = loadTableFromTrial(inTrial);
block = getBlockFromTrial(inTrial,T);

blockTrials = find(T.trialBlock==block);
nTrials = length(blockTrials);
stem = extractTrialStem(inTrial.name);
trialData = struct();
tAxis = makeTime(inTrial.params);

hFig = figure; hold on

for i = 1:nTrials
    trialIdx = blockTrials(i);
    trial = load(sprintf(stem,trialIdx));
    trialData(i).LED = trial.arduino_output;
    trialData(i).ProbePosition = trial.probe_position;

    plot(tAxis,trial.probe_position,"Color",[1 .7 .7]);
end

probePositionMat = matFromStruct(trialData,"ProbePosition");
plot(tAxis,mean(probePositionMat),"Color",[.7 0 0],'LineWidth',2)
% to be continued
hold off
ylabel("Probe position (µm)")
xlabel("Time (s)")
ylim([100 900])

end