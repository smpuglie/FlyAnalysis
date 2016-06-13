%% Exporting PiezoSineOsciRespVsFreq info on cells with X-functions
    
funchandle = @PF_PiezoSineSpikesVsFreq;
close all

clear transfer freqs dsplcmnts f hasPiezoSineName genotype
cnt = 0;
for c_ind = 1:length(analysis_cell)
    if ~isempty(analysis_cell(c_ind).PiezoSineTrial)
        trial = load(analysis_cell(c_ind).PiezoSineTrial);
        h = getShowFuncInputsFromTrial(trial);
        fprintf(1,'PF_PiezoSineSpikesVsFreq: %s\n',analysis_cell(c_ind).name);
        cnt = cnt+1;
        
        hasPiezoSineName{cnt} = analysis_cell(c_ind).name;
        genotype{cnt} = analysis_cell(c_ind).genotype;
        
        if exist('f','var') && ishandle(f), close(f),end
        
        [f,transfer{cnt},freqs{cnt},dsplcmnts{cnt}] = feval(funchandle,[],h,analysis_cell(c_ind).genotype);
        
        if isfield(h.trial.params,'trialBlock'), tb = num2str(h.trial.params.trialBlock);
        else tb = 'NaN';
        end
        
        fn = [id,analysis_cell(c_ind).name '_'...
            tb '_',... 
            'spikes_',...
            func2str(funchandle)];
        savePDF(f,savedir,[],fn)
    end
end

s.name = hasPiezoSineName;
s.transfer = transfer;
s.freqs = freqs;
s.dsplcmnts = dsplcmnts;
s.genotype = genotype;

save(fullfile(savedir,'spike_transfer_functions_data'),'-struct','s')

