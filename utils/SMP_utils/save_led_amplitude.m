% Created 2023-01-31

%{
Load in the summary table and a .tsv file detailing the LED amplitude for
each block and add this data to the summary table, resave.

- tableFilename = string specifying trial summary data (.mat Table saved
    to raw_raw_data
- ledFilename  = string specifying LED Amplitude data (.tsv exported from
    Google docs, loads as a double)

LED Amplitude data is formatted as an nBlocks x 2 matrix where column 1
specifies block # and column 2 specifies LED amplitude for that block.
%}

%TODO get this to work instead with loadTableFromTrial()
function T = save_led_amplitude(tableFilename, ledFilename)

load(tableFilename,"T"); % should load as variable T, error check below:
if ~exist("T","var")
    error("error loading trial summary data")
end

ledAmp = load(ledFilename);

for b = ledAmp(:,1)'
    blockTrials = T.trial(T.trialBlock == b);
    T.ledAmp(blockTrials) = ledAmp(b,2);
    if size(ledAmp,2) == 3
        T.excluded(blockTrials) = logical(ledAmp(b,3));
    end
end

save(strrep(tableFilename,".mat","_wLedAmp.mat"),"T");

end