function hFig = LEDArduinoFlash_conditionNormAvg(h, handles, savetag) 
% probe position for each trial is normalized to the baseline for that
% trial block
disp("plotting normalized average")
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

hFig = figure("Position",[440,440,350,330],"Color","w"); hold on

for i = 1:nTrials
    trialIdx = likeTrials(i);
    trial = load(sprintf(stem,trialIdx));
    trialData(i).LED = trial.arduino_output;
    normProbePosition = fixProbeArtifact(trial.probe_position,75) - getBlockBaseline(trial,T);
%     normProbePosition = trial.probe_position - getBlockBaseline(trial,T);
    trialData(i).NormProbePosition = normProbePosition;

    if mean(normProbePosition(1:25000) > -50)
        plot(tAxis,normProbePosition,"Color",[1 .7 .7]);
    else
        plot(tAxis,normProbePosition,"Color",[0 0 0]);
    end
end

probePositionMat = matFromStruct(trialData,"NormProbePosition");
plot(tAxis,mean(probePositionMat),"Color",[.7 0 0],'LineWidth',2)
% plot_mean_sem(tAxis',probePositionMat,[0 0 0])
% to be continued
hold off
ylabel("Probe position (µm)")
xlabel("Time from stimulus onset (s)")
ylim([-400 400])
xlim([tAxis(1) tAxis(end)])
% ylim([-200 200])
set(gca,"TickDir","out")

titleStr = strcat("LED amp = ",num2str(ledAmp));

title(titleStr,"FontSize",16)
end
