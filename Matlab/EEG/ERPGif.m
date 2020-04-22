% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 29/05/2019
%
% Current version = v1.0
%
% Will generate a GIF of an ERP across the scalp.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% data      -   nElec x TimeCourse EEG data.
% nElec     -   Number of electrodes, purely for orientation.
% saveName  -   Name of GIF to save.
% Eloc      -   Electrode locations variable.

% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% Intervals     -   Intervals to plot the scalp maps at. (DEFAULT: 1)
% FPS           -   Frames per second for GIF. (DEFAULT: 10)
% Baseline      -   Baseline in ms, e.g. -300. (DEFAULT: 0)
% Title         -   Title to place over GIF. (DEFAULT: 'Electrode Data')
% PlotRange     -   Range to plot data. (DEFAULT: [] i.e. all data)
% GridScale     -   Grid scale for the sclap map. (DEFAULT: 64)
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% data = rand(129,1000);
% nElec = 129;
% saveName = 'GIF1.gif';
% 
% ERPGif(data,nElec,saveName,ELoc,'FPS',30,'PlotRange',-200:500,'GridScale',128);
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% EEGLab.
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 29/05/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function ERPGif(data,nElec,saveName,ELoc,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'Intervals'), varInput.Intervals = 1; end
if ~isfield(varInput, 'FPS'), varInput.FPS = 10; end
if ~isfield(varInput, 'Baseline'), varInput.Baseline = 0; end
if ~isfield(varInput, 'Title'), varInput.Title = 'Electrode Data'; end
if ~isfield(varInput, 'PlotRange'), varInput.PlotRange = []; end
if ~isfield(varInput, 'Gridscale'), varInput.Gridscale = 64; end
if ~isfield(varInput, 'Times'), varInput.Times = []; end
if ~isfield(varInput, 'TimeRound'), varInput.TimeRound = 0; end
if ~isfield(varInput, 'FixScale'), varInput.FixScale = []; end

if ndims(data) > 2; error('Data must be Two-Dimensional'); end

if size(data,2) == nElec
    data = data';
elseif size(data,1) ~= nElec
    error('Data does not have dimension with size of ''nElec''')
end

if isempty(varInput.Times)
    varInput.Times = 1:size(data,2);
end

if isempty(varInput.PlotRange)
    varInput.PlotRange = 1:size(varInput.Times,2);
end

DATA = [];

DATA.PlotRangeSync = [varInput.Times(nearest(varInput.Times,varInput.PlotRange(1))) varInput.Times(nearest(varInput.Times,varInput.PlotRange(end)))];
DATA.PlotRange = [nearest(varInput.Times,DATA.PlotRangeSync(1)) nearest(varInput.Times,DATA.PlotRangeSync(end))];

DATA.PlotRangeSync_Intervals = DATA.PlotRangeSync(1):varInput.Intervals:DATA.PlotRangeSync(end);
for iTime = 1:length(DATA.PlotRangeSync_Intervals)
    DATA.PlotRangeSync_Intervals(iTime) = varInput.Times(nearest(varInput.Times,DATA.PlotRangeSync_Intervals(iTime)));
    DATA.PlotRange_Intervals(iTime) = nearest(varInput.Times,DATA.PlotRangeSync_Intervals(iTime));
end

[saveDir,saveFile,saveEx] = fileparts(saveName);
if ~exist(saveDir); mkdir(saveDir); end

firstPointComplete = 0;
figure;
for iTime = DATA.PlotRange_Intervals
    
    currentPlot = data(:,iTime);
    currentTime = varInput.Times(iTime);
    
    figHandle = topoplot(currentPlot,ELoc,'gridscale', varInput.Gridscale, 'maplimits',[-varInput.FixScale varInput.FixScale]);
    titleHandle = title([varInput.Title '; T' num2str(round(currentTime,varInput.TimeRound))])
    
    set(gcf,'color','w');

    frame = getframe(gcf); 
    im = frame2im(frame);
      
    [imind,cm] = rgb2ind(im,256); 
    
    if firstPointComplete
        imwrite(imind,cm,saveName,'gif','WriteMode','append','DelayTime',1/varInput.FPS);
    else
        imwrite(imind,cm,saveName,'gif', 'Loopcount',inf,'DelayTime',1/varInput.FPS);
        firstPointComplete = 1;
    end
    
    clf
    
end