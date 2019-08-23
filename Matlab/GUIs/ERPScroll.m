% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 21/03/2019
%
% Current version = v1.0
%
% Plots EEG data and allows navigation.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% data      -   EEG data.
% chanLocs  -   Channel locations variable.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% baseline  -   Baseline period, e.g. -300. (DEFAULT: [])
% title     -   Title for GUI. (DEFAULT: 'ERP Data')
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% x = -pi:0.01:pi;
% y = sin(x);
% 
% for iElectrode = 1:129
%   data(iElectrode,:) = y .* (1/iElectrode);
% end
% 
% ERPScroll(data,chanLocs)
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% EEGLab
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 21/03/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function ERPScroll(data,chanLocs,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'baseline'), varInput.baseline = []; end
if ~isfield(varInput, 'title'), varInput.title = 'ERP Data'; end

% ======================================================================= %
% Create Initial Variables
% ======================================================================= %

% Define plot epoch.

if isempty(varInput.baseline)
    plotEpoch = 1:size(data,2);
else
    plotEpoch = varInput.baseline:(size(data,2)-(abs(varInput.baseline)+1));
end

% Extract Peak GFP.

dataGFP = eeg_gfp(data');
dataPeakPlot = nearest(dataGFP,max(dataGFP));
dataPeakPlotSync = plotEpoch(dataPeakPlot);

% ======================================================================= %
% Load up GUI
% ======================================================================= %

%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','off','Unit','normalized','Position',[0.25,0.25,0.5,0.5]);

clf

%  Construct the components.
hNext = uicontrol('Style','pushbutton','String','Next','Unit','normalized',...
    'Position',[0,0.95,0.05,0.05],...
    'Callback',@hnext_Callback);

hNext10 = uicontrol('Style','pushbutton','String','Next (10)','Unit','normalized',...
    'Position',[0.05,0.95,0.05,0.05],...
    'Callback',@hnext10_Callback);

hPrev = uicontrol('Style','pushbutton','String','Prev','Unit','normalized',...
    'Position',[0.1,0.95,0.05,0.05],...
    'Callback',@hprev_Callback);

hPrev10 = uicontrol('Style','pushbutton','String','Prev (10)','Unit','normalized',...
    'Position',[0.15,0.95,0.05,0.05],...
    'Callback',@hprev10_Callback);

hCurrent = uicontrol('Style','edit','String',dataPeakPlotSync,'Unit','normalized',...
    'Position',[0.2,0.95,0.05,0.05],...
    'Callback',@hcurrent_Callback);

axisERP = axes('Units','Pixels','Unit','normalized','Position',[0.1,0.1,0.8,0.4]); hold on;
axisTopo = axes('Units','Pixels','Unit','normalized','Position',[0.3,0.55,0.4,0.4]);

% Initialize the GUI.
% Change units to normalized so components resize
% automatically.
f.Units = 'normalized';
axisERP.Units = 'normalized';
axisTopo.Units = 'normalized';
hPrev.Units = 'normalized';
hNext.Units = 'normalized';
hCurrent.Units = 'normalized';

% Assign the GUI a name to appear in the window title.
f.Name = 'ERP Data';
% Move the GUI to the center of the screen.
% movegui(f,'center')

% ======================================================================= %
% Draw Initial Time Point Into GUI
% ======================================================================= %

% Draw ERP.

axes(axisERP);
for iElec = 1:size(data,1)
    plot(axisERP,plotEpoch,data(iElec,:));
end
hline(0,'black')
peakVLine = vline(dataPeakPlotSync,'red');
peakVLine.LineWidth = 3;
vline(0,'black');

% axisERP.Visible = 'off';

% Draw scalp map.

axes(axisTopo);
topoPlotHandle = topoplot(data(:,dataPeakPlot),chanLocs);
topoTitle = title([varInput.title '; ' num2str(dataPeakPlotSync) ' ms'])

% Make the GUI visible.
f.Visible = 'on';

% ======================================================================= %
% Callbacks.
% ======================================================================= %

%  Callbacks for the GUI. These callbacks automatically
%  have access to component handles and initialized data
%  because they are nested at a lower level.

    function hnext_Callback(source,eventdata)
        
        % Increase point to plot.
        
        dataPeakPlot = dataPeakPlot + 1;
        
        if dataPeakPlot < size(data,2)
            
            dataPeakPlotSync = plotEpoch(dataPeakPlot);
            
            % Select ERP Axis.
            
            axes(axisERP);
            
            % Delete previous vline & title.
            
            delete(peakVLine);
            delete(topoTitle);
            
            % Draw new vline.
            
            peakVLine = vline(dataPeakPlotSync,'red');
            peakVLine.LineWidth = 3;
            
            % Change current label.
            
            hCurrent.String = dataPeakPlotSync;
            
            % Re-create topo plot.
            
            axisTopo = axes('Units','Pixels','Unit','normalized','Position',[0.3,0.55,0.4,0.4]);
            axisTopo.Units = 'normalized';
            topoplot(data(:,dataPeakPlot),chanLocs);
            topoTitle = title([varInput.title '; ' num2str(dataPeakPlotSync) ' ms'])
            
        else
            
            dataPeakPlot = dataPeakPlot - 1;
            
        end
        
    end

    function hnext10_Callback(source,eventdata)
        
        % Increase point to plot.
        
        dataPeakPlot = dataPeakPlot + 10;
        
        if dataPeakPlot < size(data,2)
            
            dataPeakPlotSync = plotEpoch(dataPeakPlot);
            
            % Select ERP Axis.
            
            axes(axisERP);
            
            % Delete previous vline & title.
            
            delete(peakVLine);
            delete(topoTitle);
            
            % Draw new vline.
            
            peakVLine = vline(dataPeakPlotSync,'red');
            peakVLine.LineWidth = 3;
            
            % Change current label.
            
            hCurrent.String = dataPeakPlotSync;
            
            % Re-create topo plot.
            
            axisTopo = axes('Units','Pixels','Unit','normalized','Position',[0.3,0.55,0.4,0.4]);
            axisTopo.Units = 'normalized';
            topoplot(data(:,dataPeakPlot),chanLocs);
            topoTitle = title([varInput.title '; ' num2str(dataPeakPlotSync) ' ms'])
            
        else
            
            dataPeakPlot = size(data,2);
            
        end
        
    end

    function hprev_Callback(source,eventdata)
        
        % Increase point to plot.
        
        dataPeakPlot = dataPeakPlot - 1;
        
        if dataPeakPlot > 0
            
            dataPeakPlotSync = plotEpoch(dataPeakPlot);
            
            % Select ERP Axis.
            
            axes(axisERP);
            
            % Delete previous vline & title.
            
            delete(peakVLine);
            delete(topoTitle);
            
            % Draw new vline.
            
            peakVLine = vline(dataPeakPlotSync,'red');
            peakVLine.LineWidth = 3;
            
            % Change current label.
            
            hCurrent.String = dataPeakPlotSync;
            
            % Re-create topo plot.
            
            axisTopo = axes('Units','Pixels','Unit','normalized','Position',[0.3,0.55,0.4,0.4]);
            axisTopo.Units = 'normalized';
            topoplot(data(:,dataPeakPlot),chanLocs);
            topoTitle = title([varInput.title '; ' num2str(dataPeakPlotSync) ' ms'])
            
        else
            
            dataPeakPlot = dataPeakPlot + 1;
            
        end
        
    end

    function hprev10_Callback(source,eventdata)
        
        % Increase point to plot.
        
        dataPeakPlot = dataPeakPlot - 10;
        
        if dataPeakPlot > 0
            
            dataPeakPlotSync = plotEpoch(dataPeakPlot);
            
            % Select ERP Axis.
            
            axes(axisERP);
            
            % Delete previous vline & title.
            
            delete(peakVLine);
            delete(topoTitle);
            
            % Draw new vline.
            
            peakVLine = vline(dataPeakPlotSync,'red');
            peakVLine.LineWidth = 3;
            
            % Change current label.
            
            hCurrent.String = dataPeakPlotSync;
            
            % Re-create topo plot.
            
            axisTopo = axes('Units','Pixels','Unit','normalized','Position',[0.3,0.55,0.4,0.4]);
            axisTopo.Units = 'normalized';
            topoplot(data(:,dataPeakPlot),chanLocs);
            topoTitle = title([varInput.title '; ' num2str(dataPeakPlotSync) ' ms'])
            
        else
            
            dataPeakPlot = 1;
            
        end
        
    end

    function hcurrent_Callback(source,eventdata)
        
        dataPeakPlotSync = str2num(source.String);
        dataPeakPlot = nearest(plotEpoch,dataPeakPlotSync);
        
        % Logic for if greater than max or less than baseline.
        
        if dataPeakPlot < 0
            dataPeakPlot = 1;
            dataPeakPlotSync = plotEpoch(1);
        elseif dataPeakPlot > size(data,2)
            dataPeakPlot = size(data,2);
            dataPeakPlotSync = plotEpoch(end);
        end
        
        % Select ERP Axis.
        
        axes(axisERP);
        
        % Delete previous vline & title.
        
        delete(peakVLine);
        delete(topoTitle);
        
        % Draw new vline.
        
        peakVLine = vline(dataPeakPlotSync,'red');
        peakVLine.LineWidth = 3;
        
        % Change current label.
        
        hCurrent.String = dataPeakPlotSync;
        
        % Re-create topo plot.
        
        axisTopo = axes('Units','Pixels','Unit','normalized','Position',[0.3,0.55,0.4,0.4]);
        axisTopo.Units = 'normalized';
        topoplot(data(:,dataPeakPlot),chanLocs);
        topoTitle = title([varInput.title '; ' num2str(dataPeakPlotSync) ' ms'])
        
    end



end












