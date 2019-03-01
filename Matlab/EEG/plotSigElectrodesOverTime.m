% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 28/01/2019
%
% Current version = v1.0
%
% This will take a [nCond x nSub x nElectrodes x nTimePoints] array and
% plot significant differences between conditions over time. You can either
% investigate all differences over the time course, or can specify a
% latency to investigate differences. You can also average across a
% specified latency, and save the plots to file.
% 
% At the moment, this will likely not work if:
% 
%   1) Data not sampled at 1000 Hz.
%   2) Any of the parameters nElec, nTime, nSub, nCond are equal.
%   3) Electrode locations are different to that of the EGI_HYDROCEL_129.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% data              -   Data to plot.
% nElec             -   How many electrodes.
% nTime             -   How many timepoints.
% nSub              -   How many subjects.
% nCond             -   How many conditions.
% startLat          -   When the baseline interval begins.
% latencyAverage    -   How many time points do we include in a single time
%                       bin.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% topoPerFig            -   How many topographic maps to include in each
%                           figure. (DEFAULT: 20)
% startPlotLatency      -   Start point to begin plotting. (DEFAULT: [])
% endPlotLatency        -   End point to begin plotting. (DEFAULT: [])
% savePlots             -   Directory to save plots in. (DEFAULT: [])
% sigPVals              -   When plotting significant differences across
%                           the scalp, markers will increase in size for
%                           increasingly significant differences. This
%                           parameter defines the three P-Values that
%                           indicate marker size. 
%                           (DEFAULT: [0.05 0.01 0.001])
% oneMap                -   Whether to plot single map over specified
%                           latency. (DEFAULT: [])
% oneMap_Conds          -   If plotting oneMap, then the conditions will
%                           need to be named, corresponding to the order
%                           within the data input. (DEFAULT: [])
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% 
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% plotSigElectrodesOverTime(data,129,800,25,4,50,5, ...
%       'topoPerFig, 10, ...
%       'savePlots','D:/plotSaveDir/');
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% numSubplots
% sigElectrodes
% rloc128
% postHocTesting
% postHocTesting_plotData
% SE_WithinSubjects
% sigstar
% EEGLab (Toolbox)
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 28/01/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function plotSigElectrodesOverTime(data,nElec,nTime,nSub,nCond,startLat,latencyAverage,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'topoPerFig'), varInput.topoPerFig = 20; end;
if ~isfield(varInput, 'startPlotLatency'), varInput.startPlotLatency = []; end;
if ~isfield(varInput, 'endPlotLatency'), varInput.endPlotLatency = []; end;
if ~isfield(varInput, 'savePlots'), varInput.savePlots = []; end;
if ~isfield(varInput, 'sigPVals'), varInput.sigPVals = [0.05 0.01 0.001]; end;
if ~isfield(varInput, 'oneMap'), varInput.oneMap = 0; end;
if ~isfield(varInput, 'oneMap_Conds'), varInput.oneMap_Conds = []; end;

FUNCLOOP = [];

FUNCLOOP.E = rloc128;

FUNCLOOP.dataSize = size(data);

FUNCLOOP.dataLoc_Elec = find(FUNCLOOP.dataSize == nElec);
FUNCLOOP.dataLoc_Time = find(FUNCLOOP.dataSize == nTime);
FUNCLOOP.dataLoc_Sub = find(FUNCLOOP.dataSize == nSub);
FUNCLOOP.dataLoc_Cond = find(FUNCLOOP.dataSize == nCond);

if isempty(FUNCLOOP.dataLoc_Elec)
    error('Data Does not Contain Expected Size (nElec)')
elseif isempty(FUNCLOOP.dataLoc_Time)
    error('Data Does not Contain Expected Size (nTime)')
elseif isempty(FUNCLOOP.dataLoc_Sub)
    error('Data Does not Contain Expected Size (nSub)')
elseif isempty(FUNCLOOP.dataLoc_Cond)
    error('Data Does not Contain Expected Size (nCond)')
end

if varInput.oneMap
    if isempty(varInput.startPlotLatency) | isempty(varInput.endPlotLatency)
        error('If Plotting One Map, startPlotLatency & endPlotLatency is Required')
    end 
    if isempty(varInput.oneMap_Conds)
        error('If Plotting One Map, oneMap_Conds is Required')
    elseif length(varInput.oneMap_Conds) ~= nCond
        error('nCond ~= Conditions in oneMap_Conds')
    else
        for iCond = 1:nCond
            FUNCLOOP.condString{iCond} = strrep(varInput.oneMap_Conds{iCond},'_',' ');
        end
    end
end
    

FUNCLOOP.data = permute(data,[FUNCLOOP.dataLoc_Elec FUNCLOOP.dataLoc_Time FUNCLOOP.dataLoc_Sub FUNCLOOP.dataLoc_Cond]);

FUNCLOOP.latencies = startLat:(nTime-abs(startLat))-1;

FUNCLOOP.nTimeBins = length(FUNCLOOP.latencies) / latencyAverage;

FUNCLOOP.currentBins(:,1) = linspace(1,length(FUNCLOOP.latencies)-(latencyAverage-1),FUNCLOOP.nTimeBins);
FUNCLOOP.currentBins(:,2) = linspace(latencyAverage,length(FUNCLOOP.latencies),FUNCLOOP.nTimeBins);

for iTB = 1:FUNCLOOP.nTimeBins
    if ~floor(FUNCLOOP.currentBins(iTB,1)) == FUNCLOOP.currentBins(iTB,1) | ~floor(FUNCLOOP.currentBins(iTB,2)) == FUNCLOOP.currentBins(iTB,2)
        error([num2str(FUNCLOOP.latencies(1)) ':' num2str(FUNCLOOP.latencies(end)) ' Latency Range is not Equally Divisible by ' num2str(latencyAverage)]);
    end
    for iRange = 1:2
        FUNCLOOP.currentBins_Synced(iTB,iRange) = FUNCLOOP.latencies(FUNCLOOP.currentBins(iTB,iRange));
    end
end

FUNCLOOP.FigH1 = figure('Position', get(0, 'Screensize')); hold on;

if isempty(varInput.startPlotLatency)
    FUNCLOOP.startBinIndex = 1;
else
    FUNCLOOP.startBinIndex = nearest(FUNCLOOP.currentBins_Synced(:,1),varInput.startPlotLatency);
end

if isempty(varInput.endPlotLatency)
    FUNCLOOP.endBinIndex = FUNCLOOP.nTimeBins;
else
    FUNCLOOP.endBinIndex = nearest(FUNCLOOP.currentBins_Synced(:,2),varInput.endPlotLatency);
end

if varInput.oneMap
    
    FUNCFORLOOP = [];
    FUNCFORLOOP.currentStart = nearest(FUNCLOOP.latencies,varInput.startPlotLatency);
    FUNCFORLOOP.currentEnd = nearest(FUNCLOOP.latencies,varInput.endPlotLatency);
    
    FUNCFORLOOP.currentData = squeeze(mean(FUNCLOOP.data(:,FUNCFORLOOP.currentStart:FUNCFORLOOP.currentEnd,:,:),2));
    
    FUNCFORLOOP.plotData = squeeze(mean(FUNCFORLOOP.currentData,2));
    
    nSubPlots = numSubplots(size(FUNCFORLOOP.currentData,3)+1);
    
    for iCond = 1:size(FUNCFORLOOP.currentData,3)
        FUNCFORLOOP.statData{iCond} = squeeze(FUNCFORLOOP.currentData(:,:,iCond));
    end
    
    [~,~,FUNCFORLOOP.P] = statcond(FUNCFORLOOP.statData,'method','perm','naccu',5000);
    
    subplot(nSubPlots(1),nSubPlots(2),1);
    
    title([num2str(varInput.startPlotLatency) ':' num2str(varInput.endPlotLatency) ' ms']);
    sigElectrodes([],FUNCFORLOOP.P,varInput.sigPVals);
    
    for iCond = 1:size(FUNCFORLOOP.currentData,3)
        subplot(nSubPlots(1),nSubPlots(2),iCond+1);
        topoplot(FUNCFORLOOP.plotData(:,iCond),FUNCLOOP.E);
        title(FUNCLOOP.condString{iCond});
    end
    
    if ~isempty(varInput.savePlots)
        [d,n,e] = fileparts(varInput.savePlots);
        FUNCLOOP.F1    = getframe(gcf);
        imwrite(FUNCLOOP.F1.cdata, [d '\' n '_' nDigitString(varInput.startPlotLatency,3) '_' nDigitString(varInput.endPlotLatency,3) '_ms_ScalpMaps.bmp'], 'bmp')
    end
    
    clf
    
    FUNCFORLOOP.sigElectrodes = find(FUNCFORLOOP.P <= max(varInput.sigPVals));
    FUNCFORLOOP.sigElectrodesData = squeeze(mean(FUNCFORLOOP.currentData(FUNCFORLOOP.sigElectrodes,:,:),1));
    FUNCFORLOOP.sigElectrodesData = permute(FUNCFORLOOP.sigElectrodesData,[2 1]);
    
    postHocStruct = postHocTesting(FUNCFORLOOP.sigElectrodesData);
    postHocTesting_plotData(FUNCFORLOOP.sigElectrodesData,postHocStruct,'newFig',0);
    
    set(gca,'XTickLabels',FUNCLOOP.condString);
    title([num2str(varInput.startPlotLatency) ':' num2str(varInput.endPlotLatency) ' ms']);
    set(gca,'FontSize',16);
    xtickangle(45);
    box off;
    
    if ~isempty(varInput.savePlots)
        [d,n,e] = fileparts(varInput.savePlots);
        FUNCLOOP.F1    = getframe(gcf);
        imwrite(FUNCLOOP.F1.cdata, [d '\' n '_' nDigitString(varInput.startPlotLatency,3) '_' nDigitString(varInput.endPlotLatency,3) '_ms_PostHoc.bmp'], 'bmp')
    end
    
    close all
        
else
    
    nSubPlots = numSubplots(varInput.topoPerFig); subPlotCount = 0;

    plotSaveCounter = 0;
    for iTB = FUNCLOOP.startBinIndex:FUNCLOOP.endBinIndex
        
        FUNCFORLOOP = [];
        
        FUNCFORLOOP.currentData = squeeze(FUNCLOOP.data(:,FUNCLOOP.currentBins(iTB,1):FUNCLOOP.currentBins(iTB,1),:,:));
        
        for iCond = 1:size(FUNCFORLOOP.currentData,3)
            FUNCFORLOOP.statData{iCond} = squeeze(FUNCFORLOOP.currentData(:,:,iCond));
        end
        
        [~,~,FUNCFORLOOP.P] = statcond(FUNCFORLOOP.statData,'method','perm','naccu',5000);
        
        subPlotCount = subPlotCount + 1;
        
        justSaved = 0;
        if subPlotCount > varInput.topoPerFig
            
            if ~isempty(varInput.savePlots)
                [d,n,e] = fileparts(varInput.savePlots);
                plotSaveCounter = plotSaveCounter + 1;
                FUNCLOOP.F1    = getframe(gcf);
                imwrite(FUNCLOOP.F1.cdata, [d '\' n '_' nDigitString(plotSaveCounter,3) '.bmp'], 'bmp')
                justSaved = 1;
            end
            
            FUNCLOOP.FigH1 = figure('Position', get(0, 'Screensize')); hold on;
            subPlotCount = 1;
        end
        
        subplot(nSubPlots(1),nSubPlots(2),subPlotCount)
        
        sigElectrodes([],FUNCFORLOOP.P,varInput.sigPVals);
        
        title([num2str(FUNCLOOP.currentBins_Synced(iTB,1)) ':' num2str(FUNCLOOP.currentBins_Synced(iTB,2)) ' ms']);
        
    end
    
    if ~isempty(varInput.savePlots)
        if ~justSaved
            [d,n,e] = fileparts(varInput.savePlots);
            plotSaveCounter = plotSaveCounter + 1;
            FUNCLOOP.F1    = getframe(gcf);
            imwrite(FUNCLOOP.F1.cdata, [d '\' n '_' nDigitString(plotSaveCounter,3) '.bmp'], 'bmp')
        end
    end
    
    close all
    
end








