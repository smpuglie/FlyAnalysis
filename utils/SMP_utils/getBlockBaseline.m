function blockBaseline = getBlockBaseline(inTrial,T)

block = getBlockFromTrial(inTrial,T);

blockTrials = find(T.trialBlock==block);
nTrials = length(blockTrials);
stem = extractTrialStem(inTrial.name);
trialBaselines = zeros(nTrials,1);

for i = 1:nTrials
    trialIdx = blockTrials(i);
    trial = load(sprintf(stem,trialIdx));
    if strcmp(trial.params.protocol, "LEDArduinoFlashControl")
        baselineIdxs = 1:find(diff(trial.arduino_output)>0);
    else
         baselineIdxs = 1:(trial.params.preDurInSec * trial.params.sampratein);
    end
    trialBaselines(i) = mean(trial.probe_position(baselineIdxs));
end

blockBaseline = mean(trialBaselines);

return