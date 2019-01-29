function spikeThresholdUpdateGUI(disttreshfig,norm_detectedSpikeCandidates,spikeWaveforms)
global squiggles
global spikes
clear GLOBAL goodspikeamp

squiggles = norm_detectedSpikeCandidates;
spikes = spikeWaveforms;

ax_main = findobj(disttreshfig,'Tag','main');
ax_hist = findobj(disttreshfig,'Tag','hist');
ax_detect = findobj(disttreshfig,'Tag','detect');

distthresh_l = findobj(ax_hist,'tag','dist_threshold');
ampthresh_l = findobj(ax_hist,'tag','amp_threshold');
distthresh_l.Color = [0 1 1];

ax_hist.ButtonDownFcn = @updateSpikeThreshold;
ax_detect.ButtonDownFcn = @runDetectionWithNewTemplate;

% title(ax_main,'When done, hit a button')

title(ax_hist,'Click to change distance threshold (X-axis)');
updateSpikeThreshold(ax_hist,[])

while ~waitforbuttonpress;end

distthresh_l.Color = [1 0 0];
ampthresh_l.Color = [0 1 1];

ax_hist.ButtonDownFcn = @updateAmpThreshold;
ax_detect.ButtonDownFcn = [];

title(ax_hist,'Click to change amplitude threshold (Y-axis)');
title(ax_detect,'');

updateAmpThreshold(ax_hist,[])
while ~waitforbuttonpress;end

end

function updateSpikeThreshold(hObject,eventdata)
global vars 

if ~isempty(eventdata) && hObject==eventdata.Source
    vars.Distance_threshold = hObject.CurrentPoint(1);
end

updatePanels(hObject,[])
end

function updateAmpThreshold(hObject,eventdata)
global vars 
% global goodspikeamp
% if isempty(goodspikeamp)
%     error('No goodspikeamp');
% end

if ~isempty(eventdata) && hObject==eventdata.Source
    vars.Amplitude_threshold = hObject.CurrentPoint(1,2); % /goodspikeamp;
end

updatePanels(hObject,[])
end


function updatePanels(hObject,~)

global vars 
global squiggles
global spikes

disttreshfig = get(hObject,'parent');

ax_main = findobj(disttreshfig,'Tag','main');
ax_hist = findobj(disttreshfig,'Tag','hist');
ax_detect = findobj(disttreshfig,'Tag','detect');
ax_detect_patch = findobj(disttreshfig,'Tag','detect_patch');

ax_fltrd_suspect = findobj(disttreshfig,'Tag','fltrd_suspect');
ax_unfltrd_suspect = findobj(disttreshfig,'Tag' ,'unfltrd_suspect');
ax_fltrd_notsuspect = findobj(disttreshfig,'Tag','fltrd_notsuspect');
ax_unfltrd_notsuspect = findobj(disttreshfig,'Tag','unfltrd_notsuspect');

distthresh_l = findobj(ax_hist,'tag','dist_threshold');
distthresh_l.XData = vars.Distance_threshold*[1 1];
ampthresh_l = findobj(ax_hist,'tag','amp_threshold');
ampthresh_l.YData = vars.Amplitude_threshold*[1 1]; % *goodspikeamp

selectcriteria = ax_hist.UserData; %threshidx = threshidx(:)';

%%
suspect = selectcriteria(:,1)<vars.Distance_threshold & selectcriteria(:,2) > vars.Amplitude_threshold; %*goodspikeamp;
targetSpikeDist = selectcriteria(:,1);
spikeAmplitude = selectcriteria(:,2);

[good,weird,weirdbad,bad] = thegoodthebadandtheweird(targetSpikeDist,spikeAmplitude,vars.Distance_threshold,vars.Amplitude_threshold);

%% Redraw the criteria based on new thresholds

hist_dots_out = findobj(hObject,'tag','distance_hist_out');
hist_dots_in = findobj(hObject,'tag','distance_hist');

% selectcriteria = hist_dots_in.UserData;
sDs = selectcriteria(:,1);
amps = selectcriteria(:,2);

delete(hist_dots_out);
delete(hist_dots_in);

hist_dots_out = plot(ax_hist,sDs(~suspect),amps(~suspect),...
    '.','color',[0.9290 0.6940 0.1250],'markersize',10,'tag','distance_hist_out'); 
hold(ax_hist,'on');
hist_dots_in = plot(ax_hist,sDs(suspect),amps(suspect),...
    '.','color',[.0 .45 .74],'markersize',10,'tag','distance_hist'); 
% hist_dots_in.UserData = selectcriteria;
uistack([hist_dots_out hist_dots_in],'bottom')

xlims = ampthresh_l.XData+[-1 1]*.1*diff(ampthresh_l.XData);
xlims = [xlims(1) max([xlims(2) distthresh_l.XData(2)*1.1])];
ylims = distthresh_l.YData+[-1 1]*.1*diff(distthresh_l.YData);
ylims = [min([ylims(1), ampthresh_l.YData(1)-0.1*diff([ampthresh_l.YData(1) max(distthresh_l.YData)])]) ylims(2)];
xlim(ax_hist,xlims);
ylim(ax_hist,ylims);

%%

suspect_ticks = findobj(ax_main,'Tag','ticks'); suspect_ticks = flipud(suspect_ticks);

set(suspect_ticks(suspect),'color',[0 0 0],'linewidth',1)
set(suspect_ticks(~suspect),'color',[1 0 0],'linewidth',.5)

goodsquiggles = findobj(ax_detect,'Tag','squiggles');  delete(goodsquiggles);
weirdsquiggles = findobj(ax_detect,'Tag','weirdsquiggles'); delete(weirdsquiggles);

goodspikes = findobj(ax_detect_patch,'Tag','spikes'); delete(goodspikes);
weirdspikes = findobj(ax_detect_patch,'Tag','weirdspikes'); delete(weirdspikes);

window = ax_detect.UserData.window;
spikewindow = ax_detect.UserData.spikewindow;

cla(ax_fltrd_suspect)
cla(ax_unfltrd_suspect)

if any(good) && any(weird)
    goodsquiggles = plot(ax_detect,window,squiggles(:,good),'tag','squiggles','Color',[.8 .8 .8]);
    weirdSuspectSquiggles = plot(ax_detect,window,squiggles(:,weird),'tag','weirdsquiggles','Color',[0 0 0]);
    uistack(weirdSuspectSquiggles,'bottom')
    uistack(goodsquiggles,'bottom')
    
    goodspikes = plot(ax_detect_patch,spikewindow,spikes(:,good),'color',[.8 .8 .8],'tag','spikes');
    weirdspikes = plot(ax_detect_patch,spikewindow,spikes(:,weird),'color',[0 0 0],'tag','weirdspikes');
    uistack(weirdspikes,'bottom')
    uistack(goodspikes,'bottom')
        
    plot(ax_fltrd_suspect,window,squiggles(:,good),'tag','squiggles_suspect','color',[0.8 0.8 0.8]);
    plot(ax_fltrd_suspect,window,squiggles(:,weird),'tag','squiggles_suspect','color',[0 0 0]);
    % ax_fltrd_suspect.YLim = ax_detect.YLim;
    % hold(ax_fltrd_suspect,'on');
    text(ax_fltrd_suspect,...
        ax_fltrd_suspect.XLim(1)+0.05*diff(ax_fltrd_suspect.XLim),...
        ax_fltrd_suspect.YLim(2)-0.05*diff(ax_fltrd_suspect.YLim),...
        sprintf('%d Spikes',sum(suspect)),'color',[.1 .4 .8]);
    %hold(ax_fltrd_suspect,'off');


    plot(ax_unfltrd_suspect,spikewindow,spikes(:,good),'tag','spikes_suspect','color',[0.8 0.8 0.8]);
    plot(ax_unfltrd_suspect,spikewindow,spikes(:,weird),'tag','spikes_suspect','color',[0 0 0]);
    ax_unfltrd_suspect.YLim = ax_detect_patch.YLim;

    meanspike = findobj(ax_detect_patch,'tag','goodspike');
    if isempty(meanspike)
        meanspike = plot(ax_detect_patch,spikewindow,mean(spikes(:,suspect),2),'color',[0 .3 1],'linewidth',2,'tag','goodspike');
        spikeWaveform = smooth(mean(spikes(:,suspect),2),vars.fs/2000);
        spikeWaveform_ = smoothAndDifferentiate(spikeWaveform,vars.fs/2000);
        smthwnd = (vars.fs/2000+1:length(meanspike.YData)-vars.fs/2000);
        spikediffdiff = plot(ax_detect_patch,spikewindow(smthwnd(2:end-1)),spikeWaveform_(smthwnd(2:end-1))/max(spikeWaveform_(smthwnd(2:end-1)))*max(spikeWaveform),'color',[0 .8 .4],'linewidth',2,'tag','spike_ddt');           
    else
        meanspike.YData = smooth(mean(spikes(:,suspect),2));        
    end

    spikeWaveform_ = smooth(diff(spikewindow),vars.fs/2000);
    spikeWaveform_ = smooth(diff(spikeWaveform_),vars.fs/2000);
    spikediffdiff = findobj(ax_detect_patch,'color',[0 .8 .4]);
    smthwnd = (vars.fs/2000+1:length(meanspike.YData)-vars.fs/2000);
    spikediffdiff.YData = spikeWaveform_(smthwnd(2:end-1))/max(spikeWaveform_(smthwnd(2:end-1)))*max(meanspike.YData);
end

cla(ax_fltrd_notsuspect)
if any(bad)
    plot(ax_fltrd_notsuspect,window,squiggles(:,bad),'tag','squiggles_notsuspect','color',[1 .7 .7]);
end
if any(weirdbad)
    plot(ax_fltrd_notsuspect,window,squiggles(:,weirdbad),'tag','squiggles_notsuspect','color',[.7 0 0]);
end
ax_fltrd_notsuspect.YLim = ax_detect.YLim;

cla(ax_unfltrd_notsuspect)
if any(bad)
    plot(ax_unfltrd_notsuspect,spikewindow,spikes(:,bad),'tag','spikes_notsuspect','color',[1 .7 .7]);
end
if any(weirdbad)
    plot(ax_unfltrd_notsuspect,spikewindow,spikes(:,weirdbad),'tag','spikes_notsuspect','color',[.7 0 0]);
    if any(good)
        ax_unfltrd_notsuspect.YLim = ax_detect_patch.YLim;
    end
end

meansquiggle = findobj(ax_detect,'tag','potential_template');
if any(good) && ~isempty(meansquiggle)
    meansquiggle.YData = mean(squiggles(:,good),2);
elseif any(good)
    meansquiggle = plot(ax_detect,window,mean(squiggles(:,good),2),'color',[0 .3 1],'linewidth',2,'tag','potential_template');
elseif ~isempty(meansquiggle)
    meansquiggle.YData = mean(squiggles,2);
end

end

function runDetectionWithNewTemplate(hObject,eventdata)
global vars 

disttreshfig = get(hObject,'parent');

ax_main = findobj(disttreshfig,'Tag','main');
ax_filtered = findobj(disttreshfig,'Tag','filtered');
ax_hist = findobj(disttreshfig,'Tag','hist');
ax_detect = findobj(disttreshfig,'Tag','detect');
ax_detect_patch = findobj(disttreshfig,'Tag','detect_patch');

suspect_ls = findobj(ax_detect,'Tag','squiggles'); suspect_ls = flipud(suspect_ls);
suspect_ticks = findobj(ax_main,'Tag','ticks'); suspect_ticks = flipud(suspect_ticks);
suspectUF_ls = findobj(ax_detect_patch,'Tag','spikes'); suspectUF_ls = flipud(suspectUF_ls);
%all_filtered_data = findobj(ax_filtered,'Tag','filtered_data'); all_filtered_data = all_filtered_data.YData;

goodsquiggle = findobj(ax_detect,'tag','potential_template');
initsquiggle = findobj(ax_detect,'tag','initial_template');
spikeTemplate = goodsquiggle.YData;
initsquiggle.YData = spikeTemplate;

selectcriteria = ax_hist.UserData; %threshidx = threshidx(:)';

[detectedUFSpikeCandidates,...
    detectedSpikeCandidates,...
    norm_detectedSpikeCandidates,...
    targetSpikeDist,...
    spikeAmplitude,...
    window,...
    spikewindow] = ...
    getSquiggleDistanceFromTemplate(selectcriteria(:,3),spikeTemplate,vars.filtered_data,vars.unfiltered_data,vars.spikeTemplateWidth,vars.fs);

ax_hist.UserData = [targetSpikeDist(:) spikeAmplitude(:) selectcriteria(:,3)];
vars.spikeTemplate = spikeTemplate;

updateSpikeThreshold(ax_hist,eventdata)
end
