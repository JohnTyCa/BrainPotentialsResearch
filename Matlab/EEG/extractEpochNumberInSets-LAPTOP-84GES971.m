
varargin = {'TrialNumColumn' 'Trial_Number' ...
    'Conditions' {'LowValue' 'HighValue' 'CongBundle_LowVal' 'CongBundle_HighVal' 'IncongBundle_LowVal' 'IncongBundle_HighVal'}, ...
    'TrialAverage' {'Bundle_Benefit' 'Bundle_Similarity' 'Bid_Value'} ...
    'TrialAverage_ConditionAverage' {{{[3] [4] [5] [6]} {[3 4] [5 6]}} {{[3] [4] [5] [6]} {[3 4] [5 6]}} {{[1] [2] [3] [4] [5] [6]} {[1] [2] [3 4] [5 6]}}} ...
    'AllEventAverage' {'Fixation_Duration' 'Saccade_Duration' 'Saccade_Amplitude' 'Saccade_Direction'} ...
    'AllEventAverage_ConditionAverage' {{{[1] [2]} {[3] [4] [5] [6]}} {{[1] [2]} {[3] [4] [5] [6]}} {{[1] [2]} {[3] [4] [5] [6]}} {{[1] [2]} {[3] [4] [5] [6]}}}};

function [epochN,trialN,trialAverage,eventAverage] = extractEpochNumberInSets(folder,varargin)

epochN = []; trialN = []; trialAverage = []; eventAverage = [];

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

subCount = 0;
for iFolder = 3:size(FUNCLOOP.folders,1)
    
    subCount = subCount + 1;
    
    FUNCFORLOOP = [];
    
    FUNCFORLOOP.currentFolder = [folder FUNCLOOP.folders(iFolder,:) '\'];
    FUNCFORLOOP.currentFiles = ls([FUNCFORLOOP.currentFolder '*.set']);
    
    FUNCFORLOOP.currentFilesNew = FUNCFORLOOP.currentFiles;
    
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
    
    for iSet = 1:size(FUNCFORLOOP.currentFiles,1)
        
        FUNCFORLOOP2 = [];
        
        FUNCFORLOOP2.currentSet = FUNCFORLOOP.currentFiles{iSet};
        
        FUNCFORLOOP2.currentSetName = FUNCFORLOOP.currentFilesNew{iSet};
        FUNCFORLOOP2.currentSetName = strrep(FUNCFORLOOP2.currentSetName,'.set','');
        
        EEG = pop_loadset('filename',FUNCFORLOOP2.currentSet,'filepath',FUNCFORLOOP.currentFolder);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        
        FUNCLOOP.EpochCount.(FUNCFORLOOP2.currentSetName)(subCount,1) = size(EEG.epoch,2);
        
        % Extract Epoch Events.
        
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
        
        STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
        
    end
    
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


epochN = FUNCLOOP.EpochCount;
trialN = FUNCLOOP.nTrials;

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
                    FUNCFORLOOP2.averagedData.(FUNCFORLOOP3.currentConds_Joined)(iSub,1) = mean(FUNCFORLOOP4.currentData);
                end
                
                FUNCFORLOOP2.newConditions{iAverage} = strrep(FUNCFORLOOP3.currentConds_Joined,'_',' ');
                
            end
            
            FUNCFORLOOP.averagedData.(FUNCFORLOOP.currentVar).(['PLOT_' nDigitString(iPlot,2)]) = FUNCFORLOOP2.averagedData;
            
            FUNCFORLOOP2.plotData = table2array(FUNCFORLOOP2.averagedData);
            FUNCFORLOOP2.plotData = permute(FUNCFORLOOP2.plotData,[2 1]);
            
            FUNCFORLOOP2.postHocStruct = postHocTesting(FUNCFORLOOP2.plotData);
            postHocTesting_plotData(FUNCFORLOOP2.plotData,FUNCFORLOOP2.postHocStruct);
            
            set(gca,'XTickLabels',FUNCFORLOOP2.newConditions);
            xtickangle(45);
            title(strrep(FUNCFORLOOP.currentVar,'_',' '));
            
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
        xtickangle(90);
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
                    FUNCFORLOOP2.averagedData.(FUNCFORLOOP3.currentConds_Joined)(iSub,1) = mean(FUNCFORLOOP4.currentData);
                end
                
                FUNCFORLOOP2.newConditions{iAverage} = strrep(FUNCFORLOOP3.currentConds_Joined,'_',' ');
                
            end
            
            FUNCFORLOOP.averagedData.(FUNCFORLOOP.currentVar).(['PLOT_' nDigitString(iPlot,2)]) = FUNCFORLOOP2.averagedData;
            
            FUNCFORLOOP2.plotData = table2array(FUNCFORLOOP2.averagedData);
            FUNCFORLOOP2.plotData = permute(FUNCFORLOOP2.plotData,[2 1]);
            
            FUNCFORLOOP2.postHocStruct = postHocTesting(FUNCFORLOOP2.plotData);
            postHocTesting_plotData(FUNCFORLOOP2.plotData,FUNCFORLOOP2.postHocStruct);
            
            set(gca,'XTickLabels',FUNCFORLOOP2.newConditions);
            xtickangle(45);
            title(strrep(FUNCFORLOOP.currentVar,'_',' '));
            
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
        xtickangle(90);
        title(FUNCFORLOOP.currentVar)
    end
    
end

figure;
bar(mean(table2array(epochN,1)));
set(gca,'XTickLabels',(epochN.Properties.VariableNames));
xtickangle(90);
title('Epoch Number')

figure;
bar(mean(table2array(trialN,1)));
set(gca,'XTickLabels',(trialN.Properties.VariableNames));
xtickangle(90);
title('Trial Number')






