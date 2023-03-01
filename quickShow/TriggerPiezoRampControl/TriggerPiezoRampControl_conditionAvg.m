function h = TriggerPiezoRampControl_conditionAvg(h, handles, savetag) 

inTrial = handles.trial;

T = loadTableFromTrial(inTrial);
tIdx = getTrialIdx(inTrial,T);

displacement = T.displacement(tIdx);

likeTrials = find(T.displacement == displacement & ~T.excluded);

nTrials = length(likeTrials);
stem = extractTrialStem(inTrial.name);
trialData = struct();
tAxis = makeTime(inTrial.params);

hFig = figure; hold on

for i = 1:nTrials
    trialIdx = likeTrials(i);
    trial = load(sprintf(stem,trialIdx));
    trialData(i).Piezo = trial.sgsmonitor;
    trialData(i).ProbePosition = trial.probe_position;

    plot(tAxis,trial.probe_position,"Color",[.7 .7 .7]);
end

probePositionMat = matFromStruct(trialData,"ProbePosition");
plot(tAxis,mean(probePositionMat),"Color",[.2 .2 .2],'LineWidth',2)
% to be continued
hold off
ylabel("Probe position (µm)")
xlabel("Time (s)")
ylim([100 900])

titleStr = strcat("Displacement = ",num2str(displacement));

title(titleStr,"FontSize",16)
end
