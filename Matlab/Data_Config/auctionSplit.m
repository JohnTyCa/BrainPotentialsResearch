% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 15/10/2018
%
% Current version = v2.0
%
% This will take an Nx2 array with the first column containing indices of
% values, and the second column indicating values we want to organise into
% different categories. This function will organise the values into
% separate categories, with or without overlap, and of equal or unequal
% size.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% values    -   Values that we want to split.
% nSplit    -   Number of split categories.
% nStim     -   Number of values in 'values'. This is merely confirmatory
%               and not strictly necessary for the script.
% overlap   -   Whether overlap is permitted between categories.
% equalSize -   Whether category sizes should be equalised.
% 
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% saveFile              -   File name that data should be saved under. If
%                           this file already exists, it will load up the
%                           values instead. (DEFAULT: [])
% secondOrderParameter  -   Since overlap with many categories and no
%                           overlap can reduce the number of values
%                           massively, you can introduce a second parameter
%                           to order variables on to increase number of
%                           values extracted. (DEFAULT: [])
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% splitValues   -   Values, but split into the appropriate number of
%                   categories.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% values = [[1:100]' randi(10,100,1)];
% splitValues = auctionSplit(values,4,100,0,0);
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% 
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 01/01/2019 (v1.0) -   V1.0 Created.
% 01/03/2019 (v2.0) -   Fixed issue wherein overlap remained with equal
%                       stimuli on each side of the split.
% ======================================================================= %

function splitValues = auctionSplit(values,nSplit,nStim,overlap,equalSize,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'secondOrderParameter'), varInput.secondOrderParameter = []; end
if ~isfield(varInput, 'saveFile'), varInput.saveFile = []; end

splitValues = {};

if isempty(varInput.saveFile) | ~exist(varInput.saveFile)
    
    if size(values,1) > 2 && size(values,2) > 2
        disp('Two many columns/rows')
        disp('nStim x 2 array is required')
        return
    end
    
    if size(values,1) == 2
        values = values';
    end
    
    if size(values,1) ~= nStim
        disp('Mismatch between expected and actual number of stimuli')
        return
    end
    
    newVals = values;
    
    newVals = sortrows(newVals,2);
    
    initialSplit = nStim / nSplit;
    
    if mod(initialSplit,1) ~= 0
        disp('Split size is not whole number')
        return
    end
    
    % Here we encode the second order parameter into the fourth column of the
    % newVals, if the parameter is given.
    
    if ~isempty(varInput.secondOrderParameter)
        
        uniqueValues = unique(newVals(:,2));
        tempStorage = {};
        
        for iVal = 1:length(uniqueValues)
            
            tempStorage{iVal} = newVals(newVals(:,2) == uniqueValues(iVal),:);
            
            for iStim = 1:size(tempStorage{iVal},1)
                
                currentStimuli = tempStorage{iVal}(iStim,1);
                currentStimuliParamIndex = find(varInput.secondOrderParameter(:,1) == currentStimuli);
                
                if ~isempty(currentStimuliParamIndex)
                    tempStorage{iVal}(iStim,4) = varInput.secondOrderParameter(currentStimuliParamIndex,2);
                else
                    tempStorage{iVal}(iStim,4) = NaN;
                end
                
            end
            
            if any(isnan(tempStorage{iVal}(:,4)))
                error('Second order parameter not found for stimuli');
            end
            
            tempStorage{iVal} = sortrows(tempStorage{iVal},4);
            
        end
        
        tempStorage = cat(1,tempStorage{:});
        newVals = tempStorage;
        
    end
    
    for iSplit = 1:nSplit
        
        index = ((initialSplit * (iSplit - 1)) + 1) : (iSplit * initialSplit);
        splitValues{iSplit} = newVals(index,:);
        splitValues{iSplit}(:,3) = iSplit;
        
    end
    
    % Here we remove stimuli at random of the overlapping value to remove all
    % overlap between splits. We must also take into account the presence of a
    % second order parameter. This parameter will will allow us to further
    % order the stimuli as to minimise stimuli exclusion if overlap is not
    % allowed.
    
    if ~overlap
        
        for iSplit = 1:nSplit-1
            
            splitOneEnd = splitValues{iSplit}(end,2);
            splitTwoStart = splitValues{iSplit+1}(1,2);
            
            if splitOneEnd == splitTwoStart
                
                splitOneVal = sum(splitValues{iSplit}(:,2) == splitOneEnd);
                splitTwoVal = sum(splitValues{iSplit+1}(:,2) == splitTwoStart);
                
                splitOneIndex = find(splitValues{iSplit}(:,2) == splitOneEnd);
                splitTwoIndex = find(splitValues{iSplit+1}(:,2) == splitTwoStart);
                
                valuesToRemove = min([splitOneVal splitTwoVal]);
                
                if valuesToRemove > 0
                    
                    if ~isempty(varInput.secondOrderParameter)
                        splitOneParam = splitValues{iSplit}(end,4);
                        splitTwoParam = splitValues{iSplit+1}(1,4);
                        while splitOneParam == splitTwoParam
                            splitValues{iSplit}(end,:) = [];
                            splitValues{iSplit+1}(1,:) = [];
                            splitOneParam = splitValues{iSplit}(end,4);
                            splitTwoParam = splitValues{iSplit+1}(1,4);
                        end
                        
                    elseif splitOneVal > splitTwoVal
                        
                        splitValues{iSplit+1}(splitTwoIndex,:) = [];
                        
                        randRemoval = randperm(splitOneVal,valuesToRemove);
                        
                        removalIndex = splitOneIndex(randRemoval);
                        
                        splitValues{iSplit}(removalIndex,:) = [];
                        
                    elseif splitOneVal < splitTwoVal
                        
                        splitValues{iSplit}(splitOneIndex,:) = [];
                        
                        randRemoval = randperm(splitTwoVal,valuesToRemove);
                        splitValues{iSplit+1}(randRemoval,:) = [];
                        
                    else
                        splitValues{iSplit}(splitOneIndex,:) = [];
                        splitValues{iSplit+1}(splitTwoIndex,:) = [];
                    end
                    
                end
                
            end
            
        end
        
    end
    
    if equalSize
        
        count = 0;
        for iSplit = 1:size(splitValues,2)
            
            count = count + 1;
            splitSizes(count) = size(splitValues{iSplit},1);
            
        end
        
        minSize = min(splitSizes);
        removalFromSplit = splitSizes - minSize;
        
        for iSplit = 1:size(splitValues,2)
            randRemoval = randperm(splitSizes(iSplit),removalFromSplit(iSplit));
            splitValues{iSplit}(randRemoval,:) = [];
        end
        
    end
    
    if ~isempty(varInput.saveFile)
        save(varInput.saveFile,'splitValues');
        disp('Split Values Saved')
    end
    
else
    
    load(varInput.saveFile);
    disp('Split Values Loaded')
    
end

end



