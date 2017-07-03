function transfer = CurrentSineTransFuncSingleTrode(fig,handles,savetag,varargin)
% see also CurrentSineTransFunc
p = inputParser;
p.PartialMatching = 0;
p.addParameter('closefig',1,@isnumeric);
p.addParameter('trode','',@ischar);
parse(p,varargin{:});

trials = findLikeTrials('name',handles.trial.name,'datastruct',handles.prtclData);
if isempty(fig) && p.Results.closefig 
    fig = figure(101); clf
elseif isempty(fig) || ~ishghandle(fig) 
    fig = figure(100+trials(1)); clf
else
end

set(fig,'tag',mfilename);
if strcmp(get(fig,'type'),'figure'), set(fig,'name',mfilename);end
trial = load(fullfile(handles.dir,sprintf(handles.trialStem,trials(1))));
x = makeTime(trial.params);

if isfield(trial.params,'mode_1')
    trodenum = ['_' p.Results.trode];
else trodenum = ''; 
end

if sum(strcmp({'IClamp','IClamp_fast'},trial.params.(['mode' trodenum])))
    y_name = 'voltage';
    y_units = 'mV';
    outname = 'current';
    outunits = 'pA';
elseif sum(strcmp('VClamp',trial.params.(['mode' trodenum])))
    y_name = 'current';
    y_units = 'pA';
    outname = 'voltage';
    outunits = 'mV';
end

y = zeros(length(x),length(trials));
u = zeros(length(x),length(trials));
for t = 1:length(trials)
    trial = load(fullfile(handles.dir,sprintf(handles.trialStem,trials(t))));
    y(:,t) = trial.([y_name trodenum])(1:length(x));
    u(:,t) = trial.([outname trodenum])(1:length(x));
end

yc = mean(y,2);
base = mean(yc(x<0));
yc = yc-base;
uc = mean(u,2);
offset = mean(uc(x<0));
uc = uc-offset;


fin = trial.params.stimDurInSec;
if isfield(trial.params,'ramptime');
    fin = trial.params.stimDurInSec - trial.params.ramptime;
end
yc = yc(x>=fin-trial.params.stimDurInSec/2 & x< fin);
uc = uc(x>=fin-trial.params.stimDurInSec/2 & x< fin);
t = x(x>=fin-trial.params.stimDurInSec/2 & x< fin);

f = trial.params.sampratein/length(t)*[0:length(t)/2]; f = [f, fliplr(f(2:end-1))];
YC = fft(yc(1:length(f)));
UC = fft(uc(1:length(f)));
f_ind = find(abs(f-trial.params.freq)==min(abs(f-trial.params.freq)));

transfer = YC(f_ind(1))/UC(f_ind(1));

u_ideal = trial.params.amp*exp(1i * (2*pi*trial.params.freq * x - pi/2));

ax = subplot(6,1,1,'parent',fig);
delete(ax),ax = subplot(6,1,1,'parent',fig);
semilogx(ax,f,real(YC.*conj(YC)),'color',[.7 0 0],'tag',savetag); hold on
semilogx(ax,f,real(max(YC.*conj(YC)))/real(max(UC.*conj(UC)))* real(UC.*conj(UC)),'color',[0 0 .7],'tag',savetag); hold on

axis(ax,'tight');
ylims = get(ax,'ylim');
ylims = [ylims(1)-.05*(ylims(2)-ylims(1)) ylims(2)+.05*(ylims(2)-ylims(1)) ];
ylim(ax,ylims);
title([handles.currentPrtcl ' - ' num2str(handles.trial.params.freq) ' Hz, ' num2str(handles.trial.params.amp) ' pA'])
box(ax,'off');
set(ax,'TickDir','out');

ax = subplot(6,1,[2 3 4],'parent',fig);
cla(ax)
plot(ax,x,y,'color',[1, .7 .7],'tag',savetag); hold on
plot(ax,x,real(transfer * u_ideal) + base,'color',[.7 .7 1],'tag',savetag); hold on;
plot(ax,x, mean(y,2),'color',[.7 0 0],'tag',savetag);
axis(ax,'tight')
xlim([-.1 trial.params.stimDurInSec+ min(.15,trial.params.postDurInSec)])

title([])
box(ax,'off');
set(ax,'TickDir','out');
ylabel(ax,y_units);

ax = subplot(6,1,[5 6],'parent',fig);
cla(ax)
plot(ax,x,real(transfer/abs(transfer) * u_ideal)+offset,'color',[.7 .7 1],'tag',savetag); hold on;
plot(ax,x,mean(u,2),'color',[0 0 .7],'tag',savetag); hold on;

box(ax,'off');
set(ax,'TickDir','out');

xlim(ax,[-.1 trial.params.stimDurInSec+ min(.15,trial.params.postDurInSec)])
linkaxes(findobj(fig,'xscale','linear'),'x');
drawnow