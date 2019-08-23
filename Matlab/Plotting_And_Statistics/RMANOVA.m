% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 15/08/2018
%
% Current version = v1.0
%
% This function will carry out a repeated measures ANOVA on a table of
% data.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% Data          -   Data must be a {nSubjects x nVariable} table.
%
% FactorNames   -   A cell containing the names of each of the factors. For
%                   example, factors of {'GENDER' 'AGE'}.
%
% FactorLevels  -   A cell, the same length as 'FactorNames', but containing
%                   the levels for each of the factors. For example,
%                   factors of 'GENDER' and 'AGE' would contain:
%
%                       {{'MALE'; 'FEMALE'} {'A18-24'; 'A25-30'; 'A30PLUS'}}
%
% LevelIndices  -   A cell, the same length as 'FactorNames', indicating the
%                   factor and level that each variable in 'Data' belongs
%                   to.
% 
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% SaveOutput    -   Name of file to save data to (.txt format). (DEFAULT: [])
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% ANOVATable    -   A table containing the main effects and interactions
%                   between all factors.

% ======================================================================= %
% Example
% ======================================================================= %
%
% Data = rand(25,6,1);
% Data = array2table(Data);
% 
% FactorNames = {'Age' 'Gender'}
% 
% FactorLevels = {{'Female'; 'Male'} {'A18_24'; 'A25_30'; 'A30Plus'}}
% 
% LevelIndices = {{1 2 3; 4 5 6} {1 4; 2 5; 3 6}} % Here, variables 1, 2
%                                                   and 3 in the table
%                                                   correspond to
%                                                   'Female', and
%                                                   variables 4, 5 and 6
%                                                   correspond to 'Male'.
%                                                   Secondly, variables 1
%                                                   and 4 correspond to
%                                                   'A18-24', variables 2
%                                                   and 5 correspond to
%                                                   'A25-30', and
%                                                   variables 3 and 6
%                                                   correspond to
%                                                   'A30Plus'.
% 
% ANOVATable = RMANOVA(Data,FactorNames,FactorLevels,LevelIndices);
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
% 15/08/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function ANOVATable = RMANOVA(Data,FactorNames,FactorLevels,LevelIndices,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'SaveOutput'), varInput.SaveOutput = []; end

TotalVarN = size(Data,2);
fieldNames = Data.Properties.VariableNames;

% Create a table reflecting the within subject factors and their levels.

withinTable = table();
for iFactor = 1:length(FactorNames)
    withinTable.(FactorNames{iFactor}) = cell(TotalVarN,1);
end

% if size(FactorNames,2) == 1
%     
%     count1 = 0;
%     for iLevel = 1:size(LevelIndices{iFactor},1)
%         for iVar = 1:size(LevelIndices{iFactor},2)
%             count1 = count1 + 1;
%             withinTable.(FactorNames{iFactor})(LevelIndices{iFactor}{iLevel,iVar},1) = FactorLevels{iFactor}(iLevel);
%         end
%     end
%     
% else
    
    for iFactor = 1:length(FactorNames)
        count1 = 0;
        for iLevel = 1:size(LevelIndices{iFactor},1)
            for iVar = 1:size(LevelIndices{iFactor},2)
                count1 = count1 + 1;
                withinTable.(FactorNames{iFactor})(LevelIndices{iFactor}{iLevel,iVar},1) = FactorLevels{iFactor}(iLevel);
            end
        end
    end
    
% end

% 1. Convert factors to categorical.
withinTable2 = withinTable;
for iFactor = 1:length(FactorNames)
    withinTable2.(FactorNames{iFactor}) = categorical(withinTable2.(FactorNames{iFactor}));
end

% 2. Create an interaction factor capturing each combination of levels.
% within2.([FactorNames{1} '_' FactorNames{2}]) = within2.(FactorNames{1}) .* within2.(FactorNames{2});

% 3. Call fitrm with the modified within design.

count1 = 0; count2 = 0; variableStart = {}; variableEnd = {};
for iFactor = 1:length(FactorNames)
    count1 = count1 + 1;
    variableStart{count1} = withinTable.(FactorNames{iFactor}){1};
    count1 = count1 + 1;
    if iFactor < length(FactorNames)
        variableStart{count1} = '_';
    end
    count2 = count2 + 1;
    variableEnd{count2} = withinTable.(FactorNames{iFactor}){end};
    count2 = count2 + 1;
    if iFactor < length(FactorNames)
        variableEnd{count2} = '_';
    end
end

variablesToInclude = [  cat(2,variableStart{:}) '-' ...
    cat(2,variableEnd{:})];

newVarNames = {};
for iVar = 1:size(withinTable,1)
    count1 = 0; tempStorage = {};
    for iFactor = 1:length(FactorNames)
        count1 = count1 + 1;
        tempStorage{count1} =  withinTable.(FactorNames{iFactor}){iVar};
        count1 = count1 + 1;
        if iFactor < length(FactorNames)
            tempStorage{count1} = '_';
        end
    end
    newVarNames{iVar} = cat(2,tempStorage{:});
end

newData = Data;
newData.Properties.VariableNames = newVarNames;

rm2 = fitrm(newData,[variablesToInclude '~1'],'WithinDesign',withinTable2);

count1 = 0; tempStorage = {};
for iFactor = 1:length(FactorNames)
    count1 = count1 + 1;
    tempStorage{count1} =  FactorNames{iFactor};
    count1 = count1 + 1;
    if iFactor < length(FactorNames)
        tempStorage{count1} = '*';
    end
end

interactionName = cat(2,tempStorage{:});

ANOVATable = ranova(rm2, 'WithinModel',interactionName);

% Encode Partial Eta Squared.

ANOVATable.np2 = nan(height(ANOVATable),1);
for iRow = 1:height(ANOVATable)
    if contains(ANOVATable.Properties.RowNames{iRow},'Intercept')
        ANOVATable.np2(iRow,1) = ANOVATable.SumSq(iRow,1) / (ANOVATable.SumSq(iRow,1) + ANOVATable.SumSq(iRow+1,1));
    end
end

% Save the output to file.

if ~isempty(varInput.SaveOutput)
    
    rows = ANOVATable.Row;
    columns = ANOVATable.Properties.VariableNames;
    
    ANOVATable2 = table2cell(ANOVATable);
    ANOVATable2 = [['row' columns]; rows ANOVATable2];
    
    for iRow = 1:size(ANOVATable2,1)
        currentRow = ANOVATable2{iRow,1};
        newRow = strrep(currentRow,'Error','E');
        newRow = strrep(newRow,'(Intercept)','(I)');
        
        for iFactor = 1:length(FactorNames)
            newRow = strrep(newRow,FactorNames{iFactor},['V' num2str(iFactor)]);
        end
        
        ANOVATable2{iRow,1} = newRow;
    end
    
    for iCol = 1:size(ANOVATable2,2)
        currentCol = ANOVATable2{1,iCol};
        newCol = strrep(currentCol,'SumSq','SSq');
        newCol = strrep(newCol,'MeanSq','MnSq');
        newCol = strrep(newCol,'pValue','p');
        
        ANOVATable2{1,iCol} = newCol;
    end
    
    fileID = fopen(varInput.SaveOutput,'w');
    
    [~,n,e] = fileparts(varInput.SaveOutput);
    fprintf(fileID,'%-30s\n\n',[n e]);
    
    for iRow = 1:size(ANOVATable2,1)
        for iColumn = 1:size(ANOVATable2,2)
            if isnumeric(ANOVATable2{iRow,iColumn})
                fprintf(fileID,'%-7.5s', num2str(round(ANOVATable2{iRow,iColumn},4)));
            else
                if iColumn == 1
                    fprintf(fileID,'%-15.20s', ANOVATable2{iRow,iColumn});
                else
                    fprintf(fileID,'%-7.20s', ANOVATable2{iRow,iColumn});
                end
            end
        end
        fprintf(fileID,'%-30.20s\n','');
    end
    
    fprintf(fileID,'%-30.20s\n','');
    for iFactor = 1:length(FactorNames)
        fprintf(fileID,'%-30.20s\n',['V' num2str(iFactor) ' is ' FactorNames{iFactor}]);
    end
    
    fprintf(fileID,'\n%-30.20s\n','I is Intercept');
    fprintf(fileID,'%-30.20s\n','E is Error');
    
    fclose(fileID);
    
end
