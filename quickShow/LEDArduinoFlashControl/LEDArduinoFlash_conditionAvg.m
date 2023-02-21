function h = LEDArduinoFlash_conditionAvg(h, handles, savetag) 

inTrial = handles.trial;

T = loadTableFromTrial(inTrial,"led");
tIdx = getTrialIdx(inTrial,T);

ledAmp = T.ledAmp(tIdx);
stimDur = T.stimDurInSec(tIdx);

likeTrials = find(T.ledAmp == ledAmp & T.stimDurInSec == stimDur & ~T.excluded);

% if any(strcmp("analyze",T.Properties.VariableNames))
%     likeTrials = find(T.ledAmp == ledAmp & T.stimDurInSec == stimDur & T.analyze);
% else
%     likeTrials = find(T.ledAmp == ledAmp & T.stimDurInSec == stimDur);
% end

nTrials = length(likeTrials);
stem = extractTrialStem(inTrial.name);
trialData = struct();
tAxis = makeTime(inTrial.params);

hFig = figure; hold on

for i = 1:nTrials
    trialIdx = likeTrials(i);
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

titleStr = strcat("LED amp = ",num2str(ledAmp));

title(titleStr,"FontSize",16)
end
