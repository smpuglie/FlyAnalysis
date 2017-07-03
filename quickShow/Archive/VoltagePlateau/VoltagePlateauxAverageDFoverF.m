function h = VoltagePlateauxAverageDFoverF(h,handles,savetag,varargin)
p = inputParser;
p.addParameter('BGCorrectImages',false,@islogical);
parse(p,varargin{:});

trials = findLikeTrials('name',handles.trial.name,'datastruct',handles.prtclData);
goodtrials = excludeTrials('trials',trials,'name',handles.trial.name);

if isempty(h) || ~ishghandle(h)
    h = figure(100+trials(1)); clf
else
end

set(h,'tag',mfilename);
trial = load(fullfile(handles.dir,sprintf(handles.trialStem,trials(1))));
x = makeTime(trial.params);

if sum(strcmp({'IClamp','IClamp_fast'},trial.params.mode))
    y_name = 'voltage';
    y_units = 'mV';
    outname = 'current';
    outunits = 'pA';
elseif sum(strcmp('VClamp',trial.params.mode))
    y_name = 'current';
    y_units = 'pA';
    outname = 'voltage';
    outunits = 'mV';
end

%min_exposures = Inf;
exp_t_i = -Inf;
exp_t_f = Inf;
hasDFoverF = 0;
y = zeros(length(x),length(trials));
for t = 1:length(trials)
    trial = load(fullfile(handles.dir,sprintf(handles.trialStem,trials(t))));
    y(:,t) = trial.(y_name)(1:length(x));
    if isfield(trial,'dFoverF') || isfield(trial,'roiFluoTrace')
        exp_t_i = max(exp_t_i, trial.exposure_time(1));
        exp_t_f = min(exp_t_f, trial.exposure_time(end));
        %min_exposures = min(min_exposures,length(trial.dFoverF));
        hasDFoverF = hasDFoverF+1;
    end
end
while isempty(trial.exposure_time)
    t = t-1;
    trial = load(fullfile(handles.dir,sprintf(handles.trialStem,trials(t))));
end

ax = subplot(3,1,1,'parent',h);
cla(ax,'reset')
plot(ax,x,y,'color',[1, .7 .7],'tag',savetag); hold on
plot(ax,x,mean(y,2),'color',[.7 0 0],'tag',savetag);

[~,dateID,flynum,cellnum] = extractRawIdentifiers(trial.name);

title(ax,[dateID '.' flynum '.' cellnum ' ' mfilename sprintf('.%d',trials)]);
ylabel(ax,y_units);
axis(ax,'tight')
xlim([-.5 trial.params.stimDurInSec+ min(.5,trial.params.postDurInSec)])
box(ax,'off');
set(ax,'TickDir','out');

ax = subplot(3,1,2,'parent',h);
cla(ax,'reset')
min_exposures = sum(trial.exposure_time >= exp_t_i & trial.exposure_time <= exp_t_f);
dFoverF = zeros(hasDFoverF,min_exposures);
exposure_times = zeros(hasDFoverF,min_exposures);
hasDFoverF = 0;
for t = 1:length(trials)
    trial = load(fullfile(handles.dir,sprintf(handles.trialStem,trials(t))));
    if sum(goodtrials == trials(t)) && (isfield(trial,'dFoverF') || isfield(trial,'roiFluoTrace'))
        hasDFoverF = hasDFoverF+1;
        
        % Flag whether to use the background correction or not
        if p.Results.BGCorrectImages
            dFoverF_fulltrace = dFoverF_bgcorr_trace(trial);
            dFoverF(hasDFoverF,:) = dFoverF_fulltrace(trial.exposure_time >= exp_t_i & trial.exposure_time <= exp_t_f);
        else
            dFoverF_fulltrace = dFoverF_withbg_trace(trial);
            dFoverF(hasDFoverF,:) = dFoverF_fulltrace(trial.exposure_time >= exp_t_i & trial.exposure_time <= exp_t_f);
        end
        
        exposure_times(hasDFoverF,:) = trial.exposure_time(trial.exposure_time >= exp_t_i & trial.exposure_time <= exp_t_f);
        plot(ax,trial.exposure_time(trial.exposure_time >= exp_t_i & trial.exposure_time <= exp_t_f),dFoverF(hasDFoverF,:),'color',[.7, 1 .7],'tag',savetag); hold on
    elseif ~sum(goodtrials == trials(t)) && (isfield(trial,'dFoverF') || isfield(trial,'roiFluoTrace'))
        
        if p.Results.BGCorrectImages
            dFoverF_fulltrace = dFoverF_bgcorr_trace(trial);
        else
            dFoverF_fulltrace = dFoverF_withbg_trace(trial);
        end
        
        plot(ax,trial.exposure_time(trial.exposure_time >= exp_t_i & trial.exposure_time <= exp_t_f),...
            dFoverF_fulltrace(trial.exposure_time >= exp_t_i & trial.exposure_time <= exp_t_f),'color',[1, .7 1],'tag',savetag); hold on
    end
end

plot(ax,exposure_times(1,:),mean(dFoverF,1),'color',[0 .7 0],'tag',savetag);
ylabel(ax,'%\DeltaF / F');
axis(ax,'tight')
xlims = [-.5 trial.params.stimDurInSec+ min(.5,trial.params.postDurInSec)];
xlim(ax,xlims)
xwind = exposure_times(1,:)>= min(xlims) & exposure_times(1,:)<max(xlims);
ys = dFoverF(:,xwind);
ylims = [min(ys(:)) max(ys(:))];
ylim(ax,ylims)

box(ax,'off');
set(ax,'TickDir','out');
textbp(sprintf('BG corrected: %d',p.Results.BGCorrectImages));

ax = subplot(3,1,3,'parent',h);
cla(ax,'reset')
if sum(strcmp({'IClamp','IClamp_fast'},trial.params.mode))
    y_name = 'voltage';
    y_units = 'mV';
    outname = 'current';
    outunits = 'pA';
elseif sum(strcmp('VClamp',trial.params.mode))
    y_name = 'current';
    y_units = 'pA';
    outname = 'voltage';
    outunits = 'mV';
end
plot(ax,x,trial.(outname)(1:length(x)),'color',[0 0 1],'tag',savetag); hold on;
ylabel(ax,outunits);
xlabel(ax,'Time (s)');
axis(ax,'tight')
xlim([-.5 trial.params.stimDurInSec+ min(.5,trial.params.postDurInSec)])

ylims = get(ax,'ylim');
xlims = get(ax,'xlim');
% plot(ax,x,trial.exposure*diff(ylims)+ylims(1),'color',[1 1 1]*.9,'tag',savetag); hold on;
% set(ax,'children',flipud(get(ax,'children')));
text(xlims(1)+.01*diff(xlims),max(ylims)-.1*diff(ylims),[num2str(trial.params.plateaux(1)) ' ' outunits],'fontsize',7,'parent',ax,'tag',savetag)

box(ax,'off');
set(ax,'TickDir','out');

linkaxes(findobj(h,'type','axes'),'x')

% set(ax,'TickDir','out','XColor',[1 1 1],'XTick',[],'XTickLabel','');
% set(ax,'TickDir','out','YColor',[1 1 1],'YTick',[],'YTickLabel','');

