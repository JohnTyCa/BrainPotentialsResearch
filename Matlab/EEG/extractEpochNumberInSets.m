% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 23/02/2019
%
% Current version = v1.0
%
% This function will take a directory that has a list of folders, each
% corresponding to a subject. Each folder should contain a number of set
% files corresponding to a several conditions. It will load up the set
% files, and extract the number of epochs each set file contains and return
% a table.
% 
% If you also have other variables encoded for each event within the
% EEG.event structure, you can extract the mean of these variables for each
% set file.
% 
% If you have several events for each trial, and want to extract the mean of a
% across trials and not just across all epochs, this function can also
% extract a single value for each trial if the column indicating trial
% number is given.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% folder    -   Folder containing several directories corresponding to
%               subjects.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% TrialNumColumn                    -   Name of column that indicates trial
%                                       number. (DEFAULT: [])
% Conditions                        -   Name of conditions in set files.
%                                       (DEFAULT: [])
% TrialAverage                      -   Name of columns that we want to
%                                       obtain a trial average of.
%                                       (DEFAULT: [])
% TrialAverage_ConditionAverage     -   Cell array, corresponding to the 
%                                       number of variables in the
%                                       "TrialAverage", with each cell
%                                       array containing a cell array
%                                       indicating what condition indices
%                                       to average over. For example, 
%                                       {{[1 2] [3] [4]} {[1] [2] [3] [4]}}.
%                                       (DEFAULT: []).
% AllEventAverage                   -   Name of columns that we want to
%                                       obtain an epoch average of.
%                                       (DEFAULT: [])
% AllEventAverage_ConditionAverage  -   Cell array, corresponding to the 
%                                       number of variables in the
%                                       "AllEventAverage", with each cell
%                                       array containing a cell array
%                                       indicating what condition indices
%                                       to average over. For example, 
%                                       {{[1 2] [3] [4]} {[1] [2] [3] [4]}}.
%                                       (DEFAULT: []).
% SaveAndClose                      -   Whether we want to save the plots
%                                       to a folder and then close them, or
%                                       just keep them open. Must be a
%                                       directory.  (DEFAULT: [])
% PlotERP                           -   Whether we want to plot the ERP for
%                                       each condition. (DEFAULT: 1)
% PlotEpoch                         -   Epoch to plot. 
%                                       (DEFAULT: 1:size(EEG.data,2))
% PlotConditions                    -   Whether to plot conditions for ERPs
%                                       or just the grand average.
%                                       (DEFAULT: 0).
% ERPDataSave                       -   Where we want to save ERP data.
%                                       (DEFAULT: [])
% EpochInformationSave              -   Where we want to save Epoch Info.
%                                       (DEFAULT: [])
% ERPOnly                           -   Plot ERP Only. (DEFAULT: 0)
% PlotElectrodes                    -   Plot specific electrodes. 
%                                       (DEFAULT: [])
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% epochN        -   Table indicating number of epochs in each condition.
% trialN        -   Table indicating number of trials in each condition.
% trialAverage  -   Trial average means.
% eventAverage  -   Event average means.
% ERPData       -   ERP Data.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% [epochN,trialN,trialAverage,eventAverage,ERPData] = extractEpochNumberInSets(folder, ...
%       'TrialNumColumn' 'Trial_Number' ...
%       'Conditions' {'C1' 'C2' 'C3' 'C4' 'C5' 'C6'}, ...
%       'TrialAverage' {'Value' 'Similarity' 'Amplitude'} ...
%       'TrialAverage_ConditionAverage' {{{[3] [4] [5] [6]} {[3 4] [5 6]}} {{[3] [4] [5] [6]} {[3 4] [5 6]}} {{[1] [2] [3] [4] [5] [6]} {[1] [2] [3 4] [5 6]}}} ...
%       'AllEventAverage' {'Fixation_Duration' 'Saccade_Duration' 'Saccade_Amplitude' 'Saccade_Direction'} ...
%       'AllEventAverage_ConditionAverage' {{{[1] [2]} {[3] [4] [5] [6]}} {{[1] [2]} {[3] [4] [5] [6]}} {{[1] [2]} {[3] [4] [5] [6]}} {{[1] [2]} {[3] [4] [5] [6]}}}, ...
%       'SaveAndClose', 'd:\DATA\SaveFolder\'};
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% EEGLab (Toolbox)
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 23/02/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function [epochN,trialN,trialAverage,eventAverage,ERPData] = extractEpochNumberInSets(folder,varargin)

epochN = []; trialN = []; trialAverage = []; eventAverage = []; ERPData = [];

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'TrialNumColumn'), varInput.TrialNumColumn = []; end
if ~isfield(varInput, 'Conditions'), varInput.Conditions = []; end
if ~isfield(varInput, 'TrialAverage'), varInput.TrialAverage = []; end
if ~isfield(varInput, 'TrialAverage_ConditionAverage'), varInput.TrialAverage_ConditionAverage = []; end
if ~isfield(varInput, 'AllEventAverage'), varInput.AllEventAverage = []; end
if ~isfield(varInput, 'AllEventAverage_ConditionAverage'), varInput.AllEventAverage_ConditionAverage = []; end
if ~isfield(varInput, 'SaveAndClose'), varInput.SaveAndClose = []; end
if ~isfield(varInput, 'PlotERP'), varInput.PlotERP = 1; end
if ~isfield(varInput, 'PlotEpoch'), varInput.PlotEpoch = []; end
if ~isfield(varInput, 'PlotConditions'), varInput.PlotConditions = 0; end
if ~isfield(varInput, 'ERPDataSave'), varInput.ERPDataSave = []; end
if ~isfield(varInput, 'EpochInformationSave'), varInput.EpochInformationSave = []; end
if ~isfield(varInput, 'ERPOnly'), varInput.ERPOnly = 0; end
if ~isfield(varInput, 'PlotElectrodes'), varInput.PlotElectrodes = []; end

FUNCLOOP = [];

FUNCLOOP.folders = ls(folder);

FUNCLOOP.EpochCount = table();

for iVarargin = 1:length(varInput.TrialAverage)
    FUNCFORLOOP = [];
    FUNCFORLOOP.currentVar = varInput.TrialAverage{iVarargin};
    FUNCLOOP.TrialAverage.(FUNCFORLOOP.currentVar) = table();
end

for iVarargin = 1:length(varInput.AllEventAverage)
    FUNCFORLOOP = [];
    FUNCFORLOOP.currentVar = varInput.AllEventAverage{iVarargin};
    FUNCLOOP.AllEventAverage.(FUNCFORLOOP.currentVar) = table();
end

FUNCLOOP.nTrials = table();
FUNCLOOP.ERPData = table();

if varInput.PlotERP
    FUNCLOOP.FigH1 = figure('Position', get(0, 'Screensize'));
end

if varInput.PlotElectrodes
    for iElectrode = 1:length(varInput.PlotElectrodes)
        FUNCLOOP.(['FigH' num2str(1+iElectrode)]) = figure('Position', get(0, 'Screensize'));
    end
end

subCount = 0;
for iFolder = 3:size(FUNCLOOP.folders,1)
    
    subCount = subCount + 1;
    
    FUNCFORLOOP = [];
    
    FUNCFORLOOP.currentFolder = [folder FUNCLOOP.folders(iFolder,:) '\'];
    FUNCFORLOOP.currentFiles = ls([FUNCFORLOOP.currentFolder '*.set']);
    
    FUNCFORLOOP.currentFilesNew = FUNCFORLOOP.currentFiles;
    
    FUNCFORLOOP.currentSubFolder = fileparts(FUNCFORLOOP.currentFolder);
    FUNCFORLOOP.currentSubFolder = strsplit(FUNCFORLOOP.currentSubFolder,'\');
    FUNCFORLOOP.currentSubFolder = FUNCFORLOOP.currentSubFolder{end};
    
    while all(strcmp(FUNCFORLOOP.currentFilesNew(1,1),cellstr(FUNCFORLOOP.currentFilesNew(:,1))))
        FUNCFORLOOP.currentFilesNew(:,1) = [];
    end
    
    % We will do a quick check of the condition names, but only if the
    % average parameter is given.
    
    for iCond = 1:size(FUNCFORLOOP.currentFilesNew,1)
        FUNCFORLOOP.conditions{iCond} = cell2mat(cellstr(strrep(FUNCFORLOOP.currentFilesNew(iCond,:),'.set','')));
    end
    
    if ~isempty(varInput.TrialAverage_ConditionAverage) | ~isempty(varInput.AllEventAverage_ConditionAverage)
        
        if isempty(varInput.Conditions)
            error('If Averaging Across Conditions for Plots (''TrialAverage_ConditionAverage'' or ''AllEventAverage_ConditionAverage''), Condition Names (''Conditions'') must be Reported')
        else
            if length(varInput.Conditions) ~= length(FUNCFORLOOP.conditions)
                error('Reported Conditions Does not Match Size of Conditions Obtained from Set File Names')
            else
                for iCond = 1:length(varInput.Conditions)
                    if ~any(strcmp(varInput.Conditions{iCond},FUNCFORLOOP.conditions))
                        error(['Reported Condition not Found in Set Files; ' varInput.Conditions{iCond}])
                    end
                end
            end
        end
        
        if ~isempty(varInput.TrialAverage_ConditionAverage)
            if length(varInput.TrialAverage) ~= length(varInput.TrialAverage_ConditionAverage)
                error('Number of Averages (''TrialAverage_ConditionAverage'') ~= Number of Event Types (''TrialAverage'')')
            end
        end
        
        if ~isempty(varInput.AllEventAverage_ConditionAverage)
            if length(varInput.AllEventAverage) ~= length(varInput.AllEventAverage_ConditionAverage)
                error('Number of Averages (''AllEventAverage_ConditionAverage'') ~= Number of Event Types (''AllEventAverage'')')
            end
        end
        
        TEMPSTORAGE = [];
        TEMPSTORAGE.trialAverage = cat(1,varInput.TrialAverage_ConditionAverage{:});
        TEMPSTORAGE.trialAverage = reshape(TEMPSTORAGE.trialAverage,size(TEMPSTORAGE.trialAverage,1)*size(TEMPSTORAGE.trialAverage,2),1);
        TEMPSTORAGE.trialAverage = cat(2,TEMPSTORAGE.trialAverage{:});
        TEMPSTORAGE.trialAverage = cat(2,TEMPSTORAGE.trialAverage{:});
        TEMPSTORAGE.trialAverage = unique(TEMPSTORAGE.trialAverage);
        
        if length(TEMPSTORAGE.trialAverage) == length(varInput.Conditions)
            if ~all(TEMPSTORAGE.trialAverage == 1:length(varInput.Conditions))
                error('Indices of Conditions for Averaging (''TrialAverage_ConditionAverage'') Extend Beyond Number of Condition')
            end
        else
            error('Number Indices of Conditions for Averaging (''TrialAverage_ConditionAverage'') Does not Equal Number of Conditions')
        end
        
        TEMPSTORAGE = [];
        TEMPSTORAGE.allEventAverage = cat(1,varInput.AllEventAverage_ConditionAverage{:});
        TEMPSTORAGE.allEventAverage = reshape(TEMPSTORAGE.allEventAverage,size(TEMPSTORAGE.allEventAverage,1)*size(TEMPSTORAGE.allEventAverage,2),1);
        TEMPSTORAGE.allEventAverage = cat(2,TEMPSTORAGE.allEventAverage{:});
        TEMPSTORAGE.allEventAverage = cat(2,TEMPSTORAGE.allEventAverage{:});
        TEMPSTORAGE.allEventAverage = unique(TEMPSTORAGE.allEventAverage);
        
        if length(TEMPSTORAGE.allEventAverage) == length(varInput.Conditions)
            if ~all(TEMPSTORAGE.allEventAverage == 1:length(varInput.Conditions))
                error('Indices of Conditions for Averaging (''AllEventAverage_ConditionAverage'') Extend Beyond Number of Condition')
            end
        else
            error('Number Indices of Conditions for Averaging (''AllEventAverage_ConditionAverage'') Does not Equal Number of Conditions')
        end
        
    end
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
    FUNCFORLOOP.currentFiles = cellstr(FUNCFORLOOP.currentFiles);
    FUNCFORLOOP.currentFilesNew = cellstr(FUNCFORLOOP.currentFilesNew);
    
    for iVarargin = 1:length(varInput.TrialAverage)
        FUNCFORLOOP2 = [];
        FUNCFORLOOP2.currentVar = varInput.TrialAverage{iVarargin};
        FUNCFORLOOP.TrialAverage.(FUNCFORLOOP2.currentVar) = table();
    end
    
    for iVarargin = 1:length(varInput.AllEventAverage)
        FUNCFORLOOP2 = [];
        FUNCFORLOOP2.currentVar = varInput.AllEventAverage{iVarargin};
        FUNCFORLOOP.AllEventAverage.(FUNCFORLOOP2.currentVar) = table();
    end
    
    FUNCFORLOOP.ERPData = table();
    
    fileExist_Erp = 0;
    if ~isempty(varInput.ERPDataSave)
        if exist([varInput.ERPDataSave FUNCFORLOOP.currentSubFolder '.mat'])
            fileExist_Erp = 1;
            saveData = [];
            load([varInput.ERPDataSave FUNCFORLOOP.currentSubFolder '.mat'],'saveData');
            disp(['Subject ERP Data Found; Loading - ' FUNCFORLOOP.currentSubFolder])
            FUNCFORLOOP.ERPData = saveData;
        end
    end
    
    fileExist_EpochInfo = 0;
    if ~isempty(varInput.EpochInformationSave) & exist([varInput.EpochInformationSave FUNCFORLOOP.currentSubFolder '.mat'])
        fileExist_EpochInfo = 1;
        saveData = [];
        load([varInput.EpochInformationSave FUNCFORLOOP.currentSubFolder '.mat'],'saveData');
        disp(['Subject Epoch Info Found; Loading - ' FUNCFORLOOP.currentSubFolder])
        FUNCFORLOOP.currentInfo_Event = saveData.event;
        FUNCFORLOOP.currentInfo_Epoch = saveData.epoch;
    else
        FUNCFORLOOP.currentInfo_Epoch = table();
        FUNCFORLOOP.currentInfo_Event = table();
    end
    
    for iSet = 1:size(FUNCFORLOOP.currentFiles,1)
        
        FUNCFORLOOP2 = [];
        
        FUNCFORLOOP2.currentSet = FUNCFORLOOP.currentFiles{iSet};
        
        FUNCFORLOOP2.currentSetName = FUNCFORLOOP.currentFilesNew{iSet};
        FUNCFORLOOP2.currentSetName = strrep(FUNCFORLOOP2.currentSetName,'.set','');
        
        try
            if varInput.ERPOnly
                EEG.data = FUNCFORLOOP.ERPData.(FUNCFORLOOP2.currentSetName){1};
            else
                EEG.data = FUNCFORLOOP.ERPData.(FUNCFORLOOP2.currentSetName){1};
                EEG.event = FUNCFORLOOP.currentInfo_Event.(FUNCFORLOOP2.currentSetName);
                EEG.epoch = FUNCFORLOOP.currentInfo_Epoch.(FUNCFORLOOP2.currentSetName);
            end
        catch
            EEG = pop_loadset('filename',FUNCFORLOOP2.currentSet,'filepath',FUNCFORLOOP.currentFolder);
            [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
            FUNCFORLOOP.currentInfo_Epoch.(FUNCFORLOOP2.currentSetName) = EEG.epoch;
            FUNCFORLOOP.currentInfo_Event.(FUNCFORLOOP2.currentSetName) = EEG.event;
        end
        
        % Extract Epoch Events.
        
        if varInput.ERPOnly
            
        else
            
            FUNCLOOP.EpochCount.(FUNCFORLOOP2.currentSetName)(subCount,1) = size(EEG.epoch,2);
            
            FUNCFORLOOP2.events = extractEpochEvents(EEG);
            for iVarargin = 1:length(varInput.AllEventAverage)
                FUNCFORLOOP3 = [];
                FUNCFORLOOP3.currentVar = varInput.AllEventAverage{iVarargin};
                if isfield(EEG.event,FUNCFORLOOP3.currentVar)
                    FUNCFORLOOP3.currentVarVals = [EEG.event(FUNCFORLOOP2.events).(FUNCFORLOOP3.currentVar)];
                    FUNCFORLOOP.AllEventAverage.(FUNCFORLOOP3.currentVar).(FUNCFORLOOP2.currentSetName) = {FUNCFORLOOP3.currentVarVals};
                    % FUNCFORLOOP3.currentVarValsMean = nanmean(FUNCFORLOOP3.currentVarVals);
                    % FUNCFORLOOP.AllEventAverage.(FUNCFORLOOP3.currentVar).(FUNCFORLOOP2.currentSetName) = FUNCFORLOOP3.currentVarValsMean;
                else
                    error(['"' FUNCFORLOOP3.currentVar '" is not in Event Structure; ' FUNCFORLOOP2.currentSet])
                end
            end
            
            for iVarargin = 1:length(varInput.TrialAverage)
                FUNCFORLOOP3 = [];
                FUNCFORLOOP3.currentVar = varInput.TrialAverage{iVarargin};
                if isfield(EEG.event,FUNCFORLOOP3.currentVar)
                    FUNCFORLOOP3.currentVarEvents = EEG.event(FUNCFORLOOP2.events);
                    FUNCFORLOOP3.uniqueTrials = unique([FUNCFORLOOP3.currentVarEvents.(varInput.TrialNumColumn)]);
                    for iUnique = 1:length(FUNCFORLOOP3.uniqueTrials)
                        FUNCFORLOOP4 = [];
                        FUNCFORLOOP4.currentTrialTypeIndex = find([FUNCFORLOOP3.currentVarEvents.(varInput.TrialNumColumn)] == FUNCFORLOOP3.uniqueTrials(iUnique));
                        FUNCFORLOOP3.singleEventIndices(iUnique) = FUNCFORLOOP4.currentTrialTypeIndex(1);
                    end
                    FUNCFORLOOP3.currentVarVals = [FUNCFORLOOP3.currentVarEvents(FUNCFORLOOP3.singleEventIndices).(FUNCFORLOOP3.currentVar)];
                    FUNCFORLOOP.TrialAverage.(FUNCFORLOOP3.currentVar).(FUNCFORLOOP2.currentSetName) = {FUNCFORLOOP3.currentVarVals};
                    % FUNCFORLOOP3.currentVarValsMean = nanmean(FUNCFORLOOP3.currentVarVals);
                    % FUNCFORLOOP.TrialAverage.(FUNCFORLOOP3.currentVar).(FUNCFORLOOP2.currentSetName) = FUNCFORLOOP3.currentVarValsMean;
                else
                    error(['"' FUNCFORLOOP3.currentVar '" is not in Event Structure; ' FUNCFORLOOP2.currentSet])
                end
            end
            
            warning off
            FUNCFORLOOP2.currentVarEvents = EEG.event(FUNCFORLOOP2.events);
            FUNCFORLOOP2.uniqueTrials = unique([FUNCFORLOOP2.currentVarEvents.(varInput.TrialNumColumn)]);
            FUNCLOOP.nTrials.(FUNCFORLOOP2.currentSetName)(subCount,1) = length(FUNCFORLOOP3.uniqueTrials);
            warning on
            
        end
        
        FUNCFORLOOP.ERPData.(FUNCFORLOOP2.currentSetName) = {EEG.data};
        
        STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
        
    end
    
    if ~isempty(varInput.ERPDataSave) && ~fileExist_Erp
        saveData = [];
        saveData = FUNCFORLOOP.ERPData;
        save([varInput.ERPDataSave FUNCFORLOOP.currentSubFolder '.mat'],'saveData')
    end
    
    if ~isempty(varInput.EpochInformationSave) && ~fileExist_EpochInfo
        saveData = [];
        saveData.event = FUNCFORLOOP.currentInfo_Event;
        saveData.epoch = FUNCFORLOOP.currentInfo_Epoch;
        save([varInput.EpochInformationSave FUNCFORLOOP.currentSubFolder '.mat'],'saveData')
    end
    
    if varInput.PlotERP
        figure(FUNCLOOP.FigH1)
        nPlot = numSubplots(size(FUNCLOOP.folders,1)-1);
        FUNCFORLOOP.allSubjectData = table2array(FUNCFORLOOP.ERPData);
        FUNCFORLOOP.allSubjectData_averaged = {};
        for iCond = 1:length(FUNCFORLOOP.allSubjectData)
            FUNCFORLOOP.allSubjectData_averaged{iCond} = mean(FUNCFORLOOP.allSubjectData{iCond},3);
        end
        subplot(nPlot(1),nPlot(2),subCount); hold on;
        if isempty(varInput.PlotEpoch)
            varInput.PlotEpoch = 0:length(FUNCFORLOOP.allSubjectData_GFP-1);
        end
        if varInput.PlotConditions
            for iCond = 1:length(FUNCFORLOOP.allSubjectData_averaged)
                FUNCFORLOOP2 = [];
                FUNCFORLOOP2.currentGFP = eeg_gfp(FUNCFORLOOP.allSubjectData_averaged{iCond}');
                plot(varInput.PlotEpoch,FUNCFORLOOP2.currentGFP);
            end
        else
            FUNCFORLOOP.allSubjectData = mean(cat(3,FUNCFORLOOP.allSubjectData_averaged{:}),3);
            FUNCFORLOOP.allSubjectData_GFP = eeg_gfp(FUNCFORLOOP.allSubjectData');
            plot(varInput.PlotEpoch,FUNCFORLOOP.allSubjectData_GFP);
        end
        title([strrep(FUNCFORLOOP.currentSubFolder,'_',' ') ' (GFP)'])
    end
    
    if ~isempty(varInput.PlotElectrodes)
        nPlot = numSubplots(size(FUNCLOOP.folders,1)-1);
        FUNCFORLOOP.allSubjectData = table2array(FUNCFORLOOP.ERPData);
        FUNCFORLOOP.allSubjectData_averaged = {};
        for iCond = 1:length(FUNCFORLOOP.allSubjectData)
            FUNCFORLOOP.allSubjectData_averaged{iCond} = mean(FUNCFORLOOP.allSubjectData{iCond},3);
        end
        if isempty(varInput.PlotEpoch)
            varInput.PlotEpoch = 0:length(FUNCFORLOOP.allSubjectData_GFP-1);
        end
        electrodeCount = 0;
        for iElectrode = varInput.PlotElectrodes
            electrodeCount = electrodeCount + 1;
            figure(FUNCLOOP.(['FigH' num2str(1+electrodeCount)]));
            subplot(nPlot(1),nPlot(2),subCount); hold on;
            if varInput.PlotConditions
                for iCond = 1:length(FUNCFORLOOP.allSubjectData_averaged)
                    FUNCFORLOOP2 = [];
                    FUNCFORLOOP2.currentData = FUNCFORLOOP.allSubjectData_averaged{iCond}(iElectrode,:);
                    plot(varInput.PlotEpoch,FUNCFORLOOP2.currentData);
                end
            else
                FUNCFORLOOP.allSubjectData = mean(cat(3,FUNCFORLOOP.allSubjectData_averaged{:}),3);
                FUNCFORLOOP.allSubjectData_Electrode{electrodeCount} = FUNCFORLOOP.allSubjectData(iElectrode,:);
                plot(varInput.PlotEpoch,FUNCFORLOOP.allSubjectData_Electrode{electrodeCount});
            end
            title([strrep(FUNCFORLOOP.currentSubFolder,'_',' ') ' (E' num2str(iElectrode) ')'])
        end
    end
    
    if ~varInput.ERPOnly
        
        for iVarargin = 1:length(varInput.AllEventAverage)
            FUNCFORLOOP2 = [];
            FUNCFORLOOP2.currentVar = varInput.AllEventAverage{iVarargin};
            FUNCLOOP.AllEventAverage.(FUNCFORLOOP2.currentVar)(subCount,:) = FUNCFORLOOP.AllEventAverage.(FUNCFORLOOP2.currentVar);
        end
        
        for iVarargin = 1:length(varInput.TrialAverage)
            FUNCFORLOOP2 = [];
            FUNCFORLOOP2.currentVar = varInput.TrialAverage{iVarargin};
            FUNCLOOP.TrialAverage.(FUNCFORLOOP2.currentVar)(subCount,:) = FUNCFORLOOP.TrialAverage.(FUNCFORLOOP2.currentVar);
        end
        
    end
    
    FUNCLOOP.ERPData(subCount,:) = FUNCFORLOOP.ERPData;
    
end

if varInput.PlotERP && ~isempty(varInput.SaveAndClose)
    FUNCLOOP.F1    = getframe(FUNCLOOP.FigH1);
    if varInput.PlotConditions
        imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'ERP_Subjects (Conditions).bmp'], 'bmp')
    else
        imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'ERP_Subjects.bmp'], 'bmp')
    end
    close(FUNCLOOP.FigH1)
end

if ~isempty(varInput.PlotElectrodes) && ~isempty(varInput.SaveAndClose)
    for iElectrode = 1:length(varInput.PlotElectrodes)
        FUNCLOOP.(['F' num2str(1+iElectrode)]) = getframe(FUNCLOOP.(['FigH' num2str(1+iElectrode)]));
        if varInput.PlotConditions
            imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'ERP_Subjects (E' num2str(varInput.PlotElectrodes(iElectrode)) '; Conditions).bmp'], 'bmp')
        else
            imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'ERP_Subjects (E' num2str(varInput.PlotElectrodes(iElectrode)) ').bmp'], 'bmp')
        end
        close(FUNCLOOP.(['FigH' num2str(1+iElectrode)]))
    end
end

FUNCLOOP.ERPData_averaged = FUNCLOOP.ERPData;
for iSub = 1:size(FUNCLOOP.ERPData_averaged,1)
    for iCond = 1:size(FUNCLOOP.ERPData_averaged,2)
        FUNCLOOP.ERPData_averaged(iSub,iCond) = {mean(FUNCLOOP.ERPData_averaged{iSub,iCond}{1},3)};
    end
end

for iSub = 1:size(FUNCLOOP.ERPData,1)
    FUNCSUBLOOP = [];
    FUNCSUBLOOP.currentData = table2array(FUNCLOOP.ERPData_averaged(iSub,:));
    FUNCLOOP.allData(:,:,:,iSub) = cat(3,FUNCSUBLOOP.currentData{:});
    FUNCSUBLOOP.currentData = mean(cat(3,FUNCSUBLOOP.currentData{:}),3);
    FUNCLOOP.grandAverage(:,:,iSub) = FUNCSUBLOOP.currentData;
end
FUNCLOOP.averageData = mean(FUNCLOOP.allData,4);

FUNCLOOP.superGrandAverage = mean(FUNCLOOP.grandAverage,3);
FUNCLOOP.superGrandAverage_GFP = eeg_gfp(FUNCLOOP.superGrandAverage');

if varInput.PlotERP
    FUNCLOOP.FigH1 = figure('Position', get(0, 'Screensize'));
    if varInput.PlotConditions
        hold on;
        FUNCLOOP.condNames = FUNCLOOP.ERPData.Properties.VariableNames;
        for iCond = 1:size(FUNCLOOP.averageData,3)
            FUNCFORLOOP = [];
            FUNCFORLOOP.currentGFP = eeg_gfp(FUNCLOOP.averageData(:,:,iCond)');
            plot(varInput.PlotEpoch,FUNCFORLOOP.currentGFP);
            FUNCLOOP.condNames_Legend{iCond} = strrep(FUNCLOOP.condNames{iCond},'_',' ');
        end
        legend(FUNCLOOP.condNames_Legend);
    else
        plot(varInput.PlotEpoch,FUNCLOOP.superGrandAverage_GFP);
    end
    vline(0,'black');
    title('Super Grand Average (GFP)')
    set(gca,'FontSize',16)
    ylabel('GFP')
    xlabel('Time (ms)')
    if ~isempty(varInput.SaveAndClose)
        FUNCLOOP.F1    = getframe(FUNCLOOP.FigH1);
        if varInput.PlotConditions
            imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'ERP_Super_Grand_Average (Conditions).bmp'], 'bmp');
        else
            imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'ERP_Super_Grand_Average.bmp'], 'bmp');
        end
        close
    end
end

if varInput.PlotElectrodes
    for iElectrode = 1:length(varInput.PlotElectrodes)
        FUNCLOOP.(['FigH' num2str(1+iElectrode)]) = figure('Position', get(0, 'Screensize'));
        if varInput.PlotConditions
            hold on;
            FUNCLOOP.condNames = FUNCLOOP.ERPData.Properties.VariableNames;
            for iCond = 1:size(FUNCLOOP.averageData,3)
                FUNCFORLOOP = [];
                FUNCFORLOOP.currentData = FUNCLOOP.averageData(varInput.PlotElectrodes(iElectrode),:,iCond);
                plot(varInput.PlotEpoch,FUNCFORLOOP.currentData);
                FUNCLOOP.condNames_Legend{iCond} = strrep(FUNCLOOP.condNames{iCond},'_',' ');
            end
            legend(FUNCLOOP.condNames_Legend);
        else
            plot(varInput.PlotEpoch,FUNCLOOP.superGrandAverage(varInput.PlotElectrodes(iElectrode),:));
        end
        vline(0,'black');
        title(['Super Grand Average (E' num2str(varInput.PlotElectrodes(iElectrode)) ')'])
        set(gca,'FontSize',16)
        ylabel('GFP')
        xlabel('Time (ms)')
        if ~isempty(varInput.SaveAndClose)
            FUNCLOOP.F1    = getframe(FUNCLOOP.(['FigH' num2str(1+iElectrode)]));
            if varInput.PlotConditions
                imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'ERP_Super_Grand_Average (E' num2str(varInput.PlotElectrodes(iElectrode)) '); Conditions).bmp'], 'bmp');
            else
                imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'ERP_Super_Grand_Average (E' num2str(varInput.PlotElectrodes(iElectrode)) ').bmp'], 'bmp');
            end
            close
        end
    end
end

if ~varInput.ERPOnly
    
    epochN = FUNCLOOP.EpochCount;
    trialN = FUNCLOOP.nTrials;
    
    FUNCLOOP.FigH1 = figure('Position', get(0, 'Screensize'));
    if ~isempty(varInput.TrialAverage_ConditionAverage)
        
        for iVarargin = 1:length(varInput.TrialAverage)
            
            FUNCFORLOOP = [];
            
            FUNCFORLOOP.currentAverage = varInput.TrialAverage_ConditionAverage{iVarargin};
            FUNCFORLOOP.currentVar = varInput.TrialAverage{iVarargin};
            
            for iPlot = 1:length(FUNCFORLOOP.currentAverage)
                
                FUNCFORLOOP2 = [];
                FUNCFORLOOP2.currentPlot = FUNCFORLOOP.currentAverage{iPlot};
                FUNCFORLOOP2.averagedData = table();
                FUNCFORLOOP.averagedData.(FUNCFORLOOP.currentVar).(['PLOT_' nDigitString(iPlot,2)]) = table();
                
                for iAverage = 1:length(FUNCFORLOOP2.currentPlot)
                    FUNCFORLOOP3 = [];
                    FUNCFORLOOP3.currentAv = FUNCFORLOOP2.currentPlot{iAverage};
                    FUNCFORLOOP3.currentConds = varInput.Conditions(FUNCFORLOOP3.currentAv);
                    FUNCFORLOOP3.currentConds_Joined = strjoin(FUNCFORLOOP3.currentConds,'_');
                    FUNCFORLOOP3.currentData = table();
                    for iVar = 1:length(FUNCFORLOOP3.currentConds)
                        FUNCFORLOOP4 = [];
                        FUNCFORLOOP4.currentCond = FUNCFORLOOP3.currentConds{iVar};
                        FUNCFORLOOP4.currentData = FUNCLOOP.TrialAverage.(FUNCFORLOOP.currentVar).(FUNCFORLOOP4.currentCond);
                        FUNCFORLOOP3.currentData.(FUNCFORLOOP4.currentCond) = FUNCFORLOOP4.currentData;
                    end
                    
                    for iSub = 1:size(FUNCFORLOOP3.currentData,1)
                        FUNCFORLOOP4 = [];
                        FUNCFORLOOP4.currentData = FUNCFORLOOP3.currentData(iSub,:);
                        FUNCFORLOOP4.currentData = table2cell(FUNCFORLOOP4.currentData);
                        FUNCFORLOOP4.currentData = cat(2,FUNCFORLOOP4.currentData{:});
                        FUNCFORLOOP2.averagedData.(FUNCFORLOOP3.currentConds_Joined)(iSub,1) = nanmean(FUNCFORLOOP4.currentData);
                    end
                    
                    FUNCFORLOOP2.newConditions{iAverage} = strrep(FUNCFORLOOP3.currentConds_Joined,'_',' ');
                    
                end
                
                FUNCFORLOOP.averagedData.(FUNCFORLOOP.currentVar).(['PLOT_' nDigitString(iPlot,2)]) = FUNCFORLOOP2.averagedData;
                
                FUNCFORLOOP2.plotData = table2array(FUNCFORLOOP2.averagedData);
                FUNCFORLOOP2.plotData = permute(FUNCFORLOOP2.plotData,[2 1]);
                
                FUNCFORLOOP2.postHocStruct = postHocTesting(FUNCFORLOOP2.plotData);
                postHocTesting_plotData(FUNCFORLOOP2.plotData,FUNCFORLOOP2.postHocStruct,'newFig',0);
                
                set(gca,'XTickLabels',FUNCFORLOOP2.newConditions);
                xtickangle(45);
                title(strrep(FUNCFORLOOP.currentVar,'_',' '));
                
                if ~isempty(varInput.SaveAndClose)
                    FUNCFORLOOP2.currentSaveName = ['TrialAverage_' FUNCFORLOOP.currentVar '_' 'PLOT_' nDigitString(iPlot,2)];
                    FUNCLOOP.F1    = getframe(FUNCLOOP.FigH1);
                    imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose FUNCFORLOOP2.currentSaveName '.bmp'], 'bmp')
                    clf
                end
                
            end
            
            FUNCLOOP.TrialAverage_averagedData.(FUNCFORLOOP.currentVar) = FUNCFORLOOP.averagedData.(FUNCFORLOOP.currentVar);
            
        end
        
        trialAverage = FUNCLOOP.TrialAverage_averagedData;
        
    else
        
        for iVarargin = 1:length(varInput.TrialAverage)
            FUNCFORLOOP = [];
            FUNCFORLOOP.currentVar = varInput.TrialAverage{iVarargin};
            trialAverage.(FUNCFORLOOP.currentVar) = FUNCLOOP.TrialAverage.(FUNCFORLOOP.currentVar);
        end
        
        numPlot = numSubplots(length(varInput.TrialAverage));
        figure;
        for iVarargin = 1:length(varInput.TrialAverage)
            FUNCFORLOOP = [];
            FUNCFORLOOP.currentVar = varInput.TrialAverage{iVarargin};
            subplot(numPlot(1),numPlot(2),iVarargin);
            bar(mean(table2array(eventInfo.(FUNCFORLOOP.currentVar)),1));
            set(gca,'XTickLabels',(TrialAverage.(FUNCFORLOOP.currentVar).Properties.VariableNames));
            xtickangle(45);
            title(FUNCFORLOOP.currentVar)
        end
        
    end
    
    
    if ~isempty(varInput.AllEventAverage_ConditionAverage)
        
        for iVarargin = 1:length(varInput.AllEventAverage)
            
            FUNCFORLOOP = [];
            
            FUNCFORLOOP.currentAverage = varInput.AllEventAverage_ConditionAverage{iVarargin};
            FUNCFORLOOP.currentVar = varInput.AllEventAverage{iVarargin};
            
            for iPlot = 1:length(FUNCFORLOOP.currentAverage)
                
                FUNCFORLOOP2 = [];
                FUNCFORLOOP2.currentPlot = FUNCFORLOOP.currentAverage{iPlot};
                FUNCFORLOOP2.averagedData = table();
                FUNCFORLOOP.averagedData.(FUNCFORLOOP.currentVar).(['PLOT_' nDigitString(iPlot,2)]) = table();
                
                for iAverage = 1:length(FUNCFORLOOP2.currentPlot)
                    FUNCFORLOOP3 = [];
                    FUNCFORLOOP3.currentAv = FUNCFORLOOP2.currentPlot{iAverage};
                    FUNCFORLOOP3.currentConds = varInput.Conditions(FUNCFORLOOP3.currentAv);
                    FUNCFORLOOP3.currentConds_Joined = strjoin(FUNCFORLOOP3.currentConds,'_');
                    FUNCFORLOOP3.currentData = table();
                    for iVar = 1:length(FUNCFORLOOP3.currentConds)
                        FUNCFORLOOP4 = [];
                        FUNCFORLOOP4.currentCond = FUNCFORLOOP3.currentConds{iVar};
                        FUNCFORLOOP4.currentData = FUNCLOOP.AllEventAverage.(FUNCFORLOOP.currentVar).(FUNCFORLOOP4.currentCond);
                        FUNCFORLOOP3.currentData.(FUNCFORLOOP4.currentCond) = FUNCFORLOOP4.currentData;
                    end
                    
                    for iSub = 1:size(FUNCFORLOOP3.currentData,1)
                        FUNCFORLOOP4 = [];
                        FUNCFORLOOP4.currentData = FUNCFORLOOP3.currentData(iSub,:);
                        FUNCFORLOOP4.currentData = table2cell(FUNCFORLOOP4.currentData);
                        FUNCFORLOOP4.currentData = cat(2,FUNCFORLOOP4.currentData{:});
                        FUNCFORLOOP2.averagedData.(FUNCFORLOOP3.currentConds_Joined)(iSub,1) = nanmean(FUNCFORLOOP4.currentData);
                    end
                    
                    FUNCFORLOOP2.newConditions{iAverage} = strrep(FUNCFORLOOP3.currentConds_Joined,'_',' ');
                    
                end
                
                FUNCFORLOOP.averagedData.(FUNCFORLOOP.currentVar).(['PLOT_' nDigitString(iPlot,2)]) = FUNCFORLOOP2.averagedData;
                
                FUNCFORLOOP2.plotData = table2array(FUNCFORLOOP2.averagedData);
                FUNCFORLOOP2.plotData = permute(FUNCFORLOOP2.plotData,[2 1]);
                
                FUNCFORLOOP2.postHocStruct = postHocTesting(FUNCFORLOOP2.plotData);
                postHocTesting_plotData(FUNCFORLOOP2.plotData,FUNCFORLOOP2.postHocStruct,'newFig',0);
                
                set(gca,'XTickLabels',FUNCFORLOOP2.newConditions);
                xtickangle(45);
                title(strrep(FUNCFORLOOP.currentVar,'_',' '));
                
                if ~isempty(varInput.SaveAndClose)
                    FUNCFORLOOP2.currentSaveName = ['AllEventAverage_' FUNCFORLOOP.currentVar '_' 'PLOT_' nDigitString(iPlot,2)];
                    FUNCLOOP.F1    = getframe(FUNCLOOP.FigH1);
                    imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose FUNCFORLOOP2.currentSaveName '.bmp'], 'bmp')
                    clf
                end
                
            end
            
            FUNCLOOP.AllAverage_averagedData.(FUNCFORLOOP.currentVar) = FUNCFORLOOP.averagedData.(FUNCFORLOOP.currentVar);
            
        end
        
        eventAverage = FUNCLOOP.AllAverage_averagedData;
        
    else
        
        for iVarargin = 1:length(varInput.AllEventAverage)
            FUNCFORLOOP = [];
            FUNCFORLOOP.currentVar = varInput.AllEventAverage{iVarargin};
            eventAverage.(FUNCFORLOOP.currentVar) = FUNCLOOP.AllEventAverage.(FUNCFORLOOP.currentVar);
        end
        
        numPlot = numSubplots(length(varInput.AllEventAverage));
        figure;
        for iVarargin = 1:length(varInput.AllEventAverage)
            FUNCFORLOOP = [];
            FUNCFORLOOP.currentVar = varInput.AllEventAverage{iVarargin};
            subplot(numPlot(1),numPlot(2),iVarargin);
            bar(mean(table2array(eventInfo.(FUNCFORLOOP.currentVar)),1));
            set(gca,'XTickLabels',(AllEventAverage.(FUNCFORLOOP.currentVar).Properties.VariableNames));
            xtickangle(45);
            title(FUNCFORLOOP.currentVar)
        end
        
    end
    
    plot_Epoch = bar(mean(table2array(epochN,1)));
    set(gca,'XTickLabels',(epochN.Properties.VariableNames));
    xtickangle(45);
    title('Epoch Number')
    
    for iCond = 1:size(epochN,2)
        FORLOOP = [];
        FORLOOP.currentData = table2array(epochN(:,iCond));
        FORLOOP.currentMean = mean(FORLOOP.currentData);
        FORLOOP.currentSD = std(FORLOOP.currentData);
        FORLOOP.currentText = [num2str(round(FORLOOP.currentMean,2)) ' (SD = ' num2str(round(FORLOOP.currentSD,2)) ')'];
        FORLOOP.currentXLoc = plot_Epoch.XData(iCond);
        FORLOOP.currentYLoc = FORLOOP.currentMean / 2;
        text(FORLOOP.currentXLoc,FORLOOP.currentYLoc,FORLOOP.currentText,'HorizontalAlignment','center');
    end
    
    if ~isempty(varInput.SaveAndClose)
        FUNCLOOP.F1    = getframe(FUNCLOOP.FigH1);
        imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'EpochNumber.bmp'], 'bmp')
        clf
    end
    
    plot_Epoch = bar(mean(table2array(trialN,1)));
    set(gca,'XTickLabels',(trialN.Properties.VariableNames));
    xtickangle(45);
    title('Trial Number')
    
    for iCond = 1:size(trialN,2)
        FORLOOP = [];
        FORLOOP.currentData = table2array(trialN(:,iCond));
        FORLOOP.currentMean = mean(FORLOOP.currentData);
        FORLOOP.currentSD = std(FORLOOP.currentData);
        FORLOOP.currentText = [num2str(round(FORLOOP.currentMean,2)) ' (SD = ' num2str(round(FORLOOP.currentSD,2)) ')'];
        FORLOOP.currentXLoc = plot_Epoch.XData(iCond);
        FORLOOP.currentYLoc = FORLOOP.currentMean / 2;
        text(FORLOOP.currentXLoc,FORLOOP.currentYLoc,FORLOOP.currentText,'HorizontalAlignment','center');
    end
    
    if ~isempty(varInput.SaveAndClose)
        FUNCLOOP.F1    = getframe(FUNCLOOP.FigH1);
        imwrite(FUNCLOOP.F1.cdata, [varInput.SaveAndClose 'TrialNumber.bmp'], 'bmp')
        clf
    end
    
    if ~isempty(varInput.SaveAndClose)
        close
    end
    
end

ERPData = FUNCLOOP.ERPData;





