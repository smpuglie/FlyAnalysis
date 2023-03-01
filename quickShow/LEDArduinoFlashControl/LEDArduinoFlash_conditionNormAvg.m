function h = LEDArduinoFlash_conditionNormAvg(h, handles, savetag) 
% probe position for each trial is normalized to the baseline for that
% trial block

inTrial = handles.trial;

T = loadTableFromTrial(inTrial,"led");
tIdx = getTrialIdx(inTrial,T);

ledAmp = T.ledAmp(tIdx);
stimDur = T.stimDurInSec(tIdx);

likeTrials = find(T.ledAmp == ledAmp & T.stimDurInSec == stimDur & ~T.excluded);

nTrials = length(likeTrials);
stem = extractTrialStem(inTrial.name);
trialData = struct();
tAxis = makeTime(inTrial.params);

hFig = figure; hold on

for i = 1:nTrials
    trialIdx = likeTrials(i);
    trial = load(sprintf(stem,trialIdx));
    trialData(i).LED = trial.arduino_output;
    normProbePosition = trial.probe_position - getBlockBaseline(trial,T);
    trialData(i).NormProbePosition = normProbePosition;

    plot(tAxis,normProbePosition,"Color",[1 .7 .7]);
end

probePositionMat = matFromStruct(trialData,"NormProbePosition");
plot(tAxis,mean(probePositionMat),"Color",[.7 0 0],'LineWidth',2)
% to be continued
hold off
ylabel("Probe position (µm)")
xlabel("Time (s)")
ylim([-400 400])

titleStr = strcat("LED amp = ",num2str(ledAmp));

title(titleStr,"FontSize",16)
end
