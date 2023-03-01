function quickShow_TriggerPiezoRampControl(plotcanvas,obj,savetag)

if strcmp(plotcanvas.UserData,mfilename) % the plotcanvas is already set up for this protocol
    axPiezo = findobj(plotcanvas,'type','axes','tag','quickshow_inax');
    axProbe = findobj(plotcanvas,'type','axes','tag','quickshow_inax2');
    delete(axPiezo.Children)
    delete(axProbe.Children)
else
    % setupStimulus
    delete(get(plotcanvas,'children'));
    panl = panel(plotcanvas);
    panl.fontname = 'Arial';
        
    panl.pack('v',{1/4 3/4})  % response panel, stimulus panel
    panl(1).marginbottom = 16;
            
    axProbe = panl(2).select(); %axProbe.XTick = {}; axProbe.XColor = [1 1 1];            
    ylabel(axProbe,'Probe (um)'); %xlim([0 max(t)]);
    box(axProbe,'off'); set(axProbe,'TickDir','out','tag','quickshow_inax2');
    xlabel(axProbe,'Time (s)'); %xlim([0 max(t)]);
            
    axPiezo = panl(1).select(); axPiezo.XTick = {}; axPiezo.XColor = [1 1 1];
    box(axPiezo,'off'); set(axPiezo,'TickDir','out','tag','quickshow_inax');
    
    panl.marginleft = 18;
    panl.margintop = 10;
    
    obj.plotcanvas.UserData = mfilename;

end
[prot,d,fly,cell,trial] = extractRawIdentifiers(obj.trial.name);
title(axPiezo,sprintf('%s', [prot '.' d '.' fly '.' cell '.' trial]));
%%

% setupStimulus
x = makeInTime(obj.trial.params);

if ~isfield(obj.trial,'arduino_output')
    fprintf('Need to run continuous data extraction routine\n')
    return
end
% displayTrial
line(x,obj.trial.sgsmonitor,'parent',axPiezo,'color',[.2 .2 .2],'tag',savetag);

ylabel(axPiezo,'Piezo signal'); %xlim([0 max(t)]);
axis(axPiezo,'tight');

patch('XData',[x(1) x(end) x(end) x(1)], 'YData',obj.trial.target_location(1)*[1 1 1 1] + obj.trial.target_location(2)*[0 0 1 1],'FaceColor',[.8 .8 .8],'EdgeColor',[.8 .8 .8],'parent',axProbe)
line(x,obj.trial.probe_position,'parent',axProbe,'color',[1 .2 .2],'tag',savetag);
axis(axProbe,'tight');
axPiezo.YLim = [0 10];
axProbe.YLim = [100 900];


