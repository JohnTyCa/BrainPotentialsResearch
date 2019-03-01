% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 15/10/2018
%
% Current version = v1.0
%
% Will import .evt file into EEG.event structure. BESA .evt files are in
% microseconds, whereas EEGLab takes milliseconds, so it will divide the
% timestamps by 1000. This function can also encode a value for each event
% that corresponds to that event. For example, if fixations are encoded,
% then the saccade amplitude can be encoded into a column in the EEG.event
% structure. This data needs to be an array in MATLAB and be the same size
% as the .evt file.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% EEG       -   EEG data structure from EEG Lab.
%
% evtFile   -   Event file containing events.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% Include       -   Trigger numbers to include.
%
% Exclude       -   Trigger numbers to exclude.
%
% TriggerInfo   -   Nested cells containing trigger number and the
%                   subsequent variable names for the EEG.event structure.
%                   (DEFAULT: []). Example:
%
%                   {{12,'type','fixation','TrialType','Small'} ...
%                   {22,'type','fixation','TrialType','Large'}};
%
% {RegressorName,RegressorData}    -    Any other regressors to input as separate column can be
%                                       input. To do so, name the column with the parameter and
%                                       the subsequent variable should be the same size as the
%                                       events file.
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% Outputs:
%
% EEG       -   EEG data structure from EEG Lab.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% EEG = importEventsToEEGLab(EEG,evtFile, ...
%           'Exclude', 999, ...
%           'TriggerInfo', {{40,'type','fixation','Condition','red'} ...
%                           {50,'type','stimulusOnset','Condition','red'}});
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% EEGLab (Toolbox)
% readEvt_6_1
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 15/10/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function EEG = importEventsToEEGLab(EEG,evtFile,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'Include'), varInput.Include = []; end;
if ~isfield(varInput, 'Exclude'), varInput.Exclude = []; end;
if ~isfield(varInput, 'TriggerInfo'), varInput.TriggerInfo = []; end;

E = readEvt_6_1(evtFile);
E_new = E;

fieldNames = fieldnames(varInput);

regressors = [];
for iVar = 1:length(fieldNames)
    if ~any(strcmp(fieldNames{iVar},{'Include' 'Exclude' 'TriggerInfo'}))
        regressors.(fieldNames{iVar}) = varInput.(fieldNames{iVar});
        if size(E_new,1) ~= size(regressors.(fieldNames{iVar}),1);
            disp('Size of Evt File ~= Regressor')
            disp(fieldNames{iVar})
            return
        end
    end
end

if ~isempty(varInput.Include)
    count = 0;
    for iInclude = varInput.Include
        count = count + 1;
        E_include{count} = E_new(E_new(:,3) == iInclude,:);
        E_include_index{count} = find(E_new(:,3) == iInclude);
    end
    E_include = cat(1,E_include{:});
    E_include_index = cat(1,E_include_index{:});
    E_new = sortrows(E_include,1);
    
    if ~isempty(regressors)
        fieldNames = fieldnames(regressors)
        for iVar = 1:length(fieldNames)
            regressors.(fieldNames{iVar}) = regressors.(fieldNames{iVar})(E_include_index,:);
        end
    end
    
end

if ~isempty(varInput.Exclude)
    
    count = 0;
    for iExclude = varInput.Exclude
        count = count + 1;
        E_exclude_index{count} = find(E_new(:,3) == iExclude);
    end
    E_exclude_index = cat(1,E_exclude_index{:});
    E_new(E_exclude_index,:) = [];
    
    if ~isempty(regressors)
        fieldNames = fieldnames(regressors);
        for iVar = 1:length(fieldNames)
            regressors.(fieldNames{iVar})(E_exclude_index,:) = [];
        end
    end
    
end

E_new(:,1) = E_new(:,1) / 1000;

if isempty(varInput.TriggerInfo)
    
    for iEvent = 1:size(E_new,1)
        EEG.event(iEvent).latency = E_new(iEvent,1);
        EEG.event(iEvent).intercept = 1;
        EEG.event(iEvent).type = E_new(iEvent,3);
    end
    
else
    
    allTriggerInfo = table();
    warning off
    for iTrigger = 1:length(varInput.TriggerInfo)
        triggerInfo = [];
        currentTriggerInfo = varInput.TriggerInfo{iTrigger};
        triggerInfo = setfield(triggerInfo, 'TriggerNumber', currentTriggerInfo{1});
        for iVar = 2:2:length(currentTriggerInfo)
            triggerInfo = setfield(triggerInfo, currentTriggerInfo{iVar}, currentTriggerInfo{iVar+1});
        end;
        
        fieldNames = fieldnames(triggerInfo);
        
        for iField = 1:length(fieldNames)
            allTriggerInfo.(fieldNames{iField}){iTrigger,1} = triggerInfo.(fieldNames{iField});
        end
        
    end
    warning on
    
    for iEvent = 1:size(E_new,1)
        
        currentEvent = E_new(iEvent,3);
        currentEventInfo = allTriggerInfo(cell2mat(allTriggerInfo.TriggerNumber) == currentEvent,:);
        
        EEG.event(iEvent).latency = E_new(iEvent,1);
        EEG.event(iEvent).intercept = 1;
        
        fieldNames = currentEventInfo.Properties.VariableNames;
        fieldNames(1) = [];
        
        for iFieldName = 1:length(fieldNames)
            EEG.event(iEvent).(fieldNames{iFieldName}) = cell2mat(currentEventInfo.(fieldNames{iFieldName}));
        end
        
    end
    
end

if ~isempty(regressors)
    fieldNames = fieldnames(regressors)
    for iVar = 1:length(fieldNames)
        for iEvent = 1:size(regressors.(fieldNames{iVar}),1)
            EEG.event(iEvent).(fieldNames{iVar}) = regressors.(fieldNames{iVar})(iEvent);
        end
    end
end

end