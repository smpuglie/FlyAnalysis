function h = LEDArduinoFlash_Average(h,handles,savetag)

% setupStimulus
delete(get(h,'children'));
panl = panel(h);
panl.pack('v',{1/3 1/3 1/3})  % response panel, stimulus panel
panl.margin = [18 16 2 10];
panl.fontname = 'Arial';
panl(1).marginbottom = 2;
panl(2).marginbottom = 2;

trials = findLikeTrials('name',handles.trial.name,'datastruct',handles.prtclData);
if isempty(h) || ~ishghandle(h)
    h = figure(100+trials(1)); clf
else
end

set(h,'tag',mfilename);
trial = load(fullfile(handles.dir,sprintf(handles.trialStem,trials(1))));
x = makeTime(trial.params);

if sum(strcmp({'IClamp','IClamp_fast'},trial.params.mode_1))
    y_name = 'voltage_1';
    y_units = 'mV';
elseif sum(strcmp('VClamp',trial.params.mode_1))
    y_name = 'current_1';
    y_units = 'pA';
end

if sum(strcmp({'IClamp','IClamp_fast'},trial.params.mode_2))
    y_name_2 = 'voltage_2';
    y_units_2 = 'mV';
elseif sum(strcmp('VClamp',trial.params.mode_2))
    y_name_2 = 'current_2';
    y_units_2 = 'pA';
end

y = zeros(length(x),length(trials));
y_2 = zeros(length(x),length(trials));
ax = panl(1).select();
for t = 1:length(trials)
    trial = load(fullfile(handles.dir,sprintf(handles.trialStem,trials(t))));
    y(:,t) = trial.(y_name);
    y_2(:,t) = trial.(y_name_2);
    plot(ax,x,y(:,t),'color',[1, .7 .7],'tag',num2str(trials(t))); hold on
end

plot(ax,x,mean(y,2),'color',[.7 0 0],'tag',savetag);
% xlim([-.1 trial.params.stimDurInSec+ min(.15,trial.params.postDurInSec)])
xlim([-trial.params.preDurInSec  trial.params.stimDurInSec+trial.params.postDurInSec])
text(-.09,mean(mean(y(x<0),2),1),...
    [num2str(trial.params.displacement *3) ' \mum'],...
    'fontsize',7,'parent',ax,'tag',savetag)
box(ax,'off');
set(ax,'TickDir','out');
ylabel(ax,y_units);
set(ax,'tag','response_ax');

ax = panl(2).select();
plot(ax,x,y_2,'color',[1, .7 .7],'tag',savetag); hold on
plot(ax,x,mean(y_2,2),'color',[.7 0 0],'tag',savetag);
xlim([-trial.params.preDurInSec  trial.params.stimDurInSec+trial.params.postDurInSec])
set(ax,'tag','response_ax_2');

ax = panl(3).select();
plot(ax,x,trial.sgsmonitor,'color',[0 0 1],'tag',savetag); hold on;
box(ax,'off');
set(ax,'TickDir','out');
xlim([-trial.params.preDurInSec  trial.params.stimDurInSec+trial.params.postDurInSec])
set(ax,'tag','stimulus_ax');
