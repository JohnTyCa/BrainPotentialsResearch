% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 15/08/2018
%
% Current version = v2.1
%
% This function will carry out a repeated measures ANOVA on an array of
% data.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% Data          -   Data must be a NxM array with any number of dimensions.
%                   Ensure that the last dimension is the number of
%                   subjects.
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
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% SaveOutput    -   Name of file to save data to (.txt format). (DEFAULT: [])
%
% nPerm         -   Number of permutations for permutation testing.
%                   (DEFAULT: 5000)
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
% Data = rand(2,3,25);
%
% FactorNames = {'Age' 'Gender'}
%
% FactorLevels = {{'Female'; 'Male'} {'A18_24'; 'A25_30'; 'A30Plus'}}
%
% ANOVATable = RMANOVA(Data,FactorNames,FactorLevels);
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
% 12/08/2018 (v1.1) -   Implementation of Partial Eta Squared effect size.
% 24/02/2020 (v2.0) -   Full posthoc testing.
% 27/02/2020 (v2.1) -   Now only requires a single multi-dimensional array
%                       input to do all ANOVAs and posthoc tests.
%
% ======================================================================= %

function ANOVATable = RMANOVA(Data,FactorNames,FactorLevels,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'SaveOutput'), varInput.SaveOutput = []; end
if ~isfield(varInput, 'nPerm'), varInput.nPerm = 5000; end

% Create the data table from the array.

DataSizes = size(Data);
NSub = DataSizes(end);
DataSizes(end) = [];

if length(DataSizes) > 1
    LinearIndices = reshape(1:numel(mean(Data,length(DataSizes)+1)), DataSizes);
else
    LinearIndices = 1:numel(mean(Data,length(DataSizes)+1));
end

LevelIndices = cell(1,length(FactorLevels));
for iFactor = 1:length(FactorLevels)
    for iLevel = 1:length(FactorLevels{iFactor})
        IndexLabel = repmat(':,',1,length(FactorLevels));
        IndexLabel((2*iFactor)-1) = num2str(iLevel);
        IndexLabel(end) = [];
        LevelIndices{iFactor}(iLevel,:) = eval(['reshape(LinearIndices(' IndexLabel '),1,[])']);
    end
    LevelIndices{iFactor} = num2cell(LevelIndices{iFactor});
end

Data_Table = array2table(reshape(Data,prod(DataSizes),NSub)');

TotalVarN = size(Data_Table,2);

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

newData = Data_Table;
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

[ANOVATable,~,CovarMatrix] = ranova(rm2, 'WithinModel',interactionName);

% Mauchly's Tests

MAUCHLY = [];
MAUCHLY = mauchly(rm2,CovarMatrix);
EPSILON = [];
EPSILON = epsilon(rm2,CovarMatrix);

% Encode Partial Eta Squared & adjusted df.

ANOVATable.np2 = nan(height(ANOVATable),1);
ANOVATable.DF_GG = nan(height(ANOVATable),1);
ANOVATable.DF_HF = nan(height(ANOVATable),1);
ANOVATable.DF_LB = nan(height(ANOVATable),1);
for iRow = 1:height(ANOVATable)
    if contains(ANOVATable.Properties.RowNames{iRow},'Intercept')
        ANOVATable.np2(iRow,1) = ANOVATable.SumSq(iRow,1) / (ANOVATable.SumSq(iRow,1) + ANOVATable.SumSq(iRow+1,1));
    end
    EpsilonIndex = ceil(iRow/2);
    ANOVATable.DF_GG(iRow,1) = ANOVATable.DF(iRow,1) * EPSILON.GreenhouseGeisser(EpsilonIndex,1);
    ANOVATable.DF_HF(iRow,1) = ANOVATable.DF(iRow,1) * EPSILON.HuynhFeldt(EpsilonIndex,1);
    ANOVATable.DF_LB(iRow,1) = ANOVATable.DF(iRow,1) * EPSILON.LowerBound(EpsilonIndex,1);
end

%% Post-hoc testing.

% ======================================================================= %
% Determine number of interactions.
% ======================================================================= %

POSTHOC = [];

if length(DataSizes) > 1
    
    ComboSize = 1; LevelCount = 0; Finished = 0;
    
    while ~Finished
        LevelCount = LevelCount + 1;
        POSTHOC.(['INT' num2str(LevelCount)]) = nchoosek(1:length(FactorNames),ComboSize);
        ComboSize = ComboSize + 1;
        if isempty(POSTHOC.(['INT' num2str(LevelCount)]))
            POSTHOC = rmfield(POSTHOC,['INT' num2str(LevelCount)]);
            Finished = 1;
        end
    end
    POSTHOC.NLevels = length(fieldnames(POSTHOC));
    POSTHOC.NFactors = 1:length(FactorNames);
        
else
    
    POSTHOC.INT1 = 1;
    POSTHOC.NLevels = 1;
    POSTHOC.NFactors = 1;
        
end

% ======================================================================= %
%
% ======================================================================= %

POSTHOC.Analysis = struct();

POSTHOC.AnalysisCount = 0;
for iLevel = 1:POSTHOC.NLevels
    
    for iAnalysis = 1:size(POSTHOC.(['INT' num2str(iLevel)]),1)
        
        POSTHOC.AnalysisCount = POSTHOC.AnalysisCount + 1;
        
        POSTHOC.Analysis(POSTHOC.AnalysisCount).Factor = POSTHOC.(['INT' num2str(iLevel)])(iAnalysis,:);
        POSTHOC.Analysis(POSTHOC.AnalysisCount).FactorNames = FactorNames(POSTHOC.(['INT' num2str(iLevel)])(iAnalysis,:))
        
        POSTHOC.Analysis(POSTHOC.AnalysisCount).DimToAv = flipud(find(~ismember(POSTHOC.NFactors,POSTHOC.Analysis(POSTHOC.AnalysisCount).Factor))');
        
        POSTHOC.Analysis(POSTHOC.AnalysisCount).Data = Data;
        for iAv = 1:length(POSTHOC.Analysis(POSTHOC.AnalysisCount).DimToAv)
            POSTHOC.Analysis(POSTHOC.AnalysisCount).Data = squeeze(mean(POSTHOC.Analysis(POSTHOC.AnalysisCount).Data,POSTHOC.Analysis(POSTHOC.AnalysisCount).DimToAv(iAv)));
        end
        
        TEMP = [];
        TEMP.AnalysisSize = size(POSTHOC.Analysis(POSTHOC.AnalysisCount).Data);
        TEMP.AnalysisSize(end) = [];
        TEMP.NLevels = prod(TEMP.AnalysisSize);
        
        TEMP.Indices = ones(1,length(POSTHOC.Analysis(POSTHOC.AnalysisCount).Factor));
        
        for iCond = 1:TEMP.NLevels
            for iFactor = 1:length(TEMP.Indices)-1
                if TEMP.Indices(iFactor) > length(FactorLevels{POSTHOC.Analysis(POSTHOC.AnalysisCount).Factor(iFactor)})
                    TEMP.Indices(iFactor) = 1;
                    TEMP.Indices(iFactor+1) = TEMP.Indices(iFactor+1) + 1;
                end
            end
            if iLevel == 1
                TEMP.CondName{iCond,1} = FactorLevels{POSTHOC.Analysis(POSTHOC.AnalysisCount).Factor(1)}{TEMP.Indices(1)};
                TEMP.CondName2 = TEMP.CondName;
            else
                for iFactor = 1:length(TEMP.Indices)-1
                    TEMP.CondName{iCond,iFactor} = FactorLevels{POSTHOC.Analysis(POSTHOC.AnalysisCount).Factor(iFactor)}{TEMP.Indices(iFactor)};
                    TEMP.CondName{iCond,iFactor+1} = FactorLevels{POSTHOC.Analysis(POSTHOC.AnalysisCount).Factor(iFactor+1)}{TEMP.Indices(iFactor+1)};
                end
                TEMP.CondName2{iCond,1} = strjoin(TEMP.CondName(iCond,:),'_');
            end
            TEMP.Indices(1) = TEMP.Indices(1) + 1;
        end
        
        POSTHOC.Analysis(POSTHOC.AnalysisCount).Data_Resize = reshape(POSTHOC.Analysis(POSTHOC.AnalysisCount).Data,TEMP.NLevels,size(POSTHOC.Analysis(POSTHOC.AnalysisCount).Data,ndims(POSTHOC.Analysis(POSTHOC.AnalysisCount).Data)))
        
        POSTHOC.Analysis(POSTHOC.AnalysisCount).Conditions = TEMP.CondName2;
        
        TEMP.Combos = nchoosek(1:TEMP.NLevels,2);
        
        POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc = struct();
        for iCombo = 1:size(TEMP.Combos,1)
            POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Pair = TEMP.Combos(iCombo,:);
            POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Levels = TEMP.CondName2(TEMP.Combos(iCombo,:));
            POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data = POSTHOC.Analysis(POSTHOC.AnalysisCount).Data_Resize(TEMP.Combos(iCombo,:),:);
            POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data_Cell{1} = POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data(1,:);
            POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data_Cell{2} = POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data(2,:);
            POSTHOC.Analysis(POSTHOC.AnalysisCount).FDRData(:,iCombo) = POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data_Cell{1} - POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data_Cell{2};
            [   POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).F, ...
                POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).df, ...
                POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).P] = statcond(POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data_Cell);
            POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).CohensD = CohensD(POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data_Cell{1},POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data_Cell{2});
            [   ~, ...
                ~, ...
                POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).P_Perm] = statcond(POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).Data_Cell,'method','perm','naccu',varInput.nPerm);
        end
        
        FDR = [];
        [FDR.pval,~,~,~,~]=mult_comp_perm_t1(POSTHOC.Analysis(POSTHOC.AnalysisCount).FDRData,varInput.nPerm);
        for iCombo = 1:size(POSTHOC.Analysis(POSTHOC.AnalysisCount).FDRData,2)
            POSTHOC.Analysis(POSTHOC.AnalysisCount).PostHoc(iCombo).P_FDR = FDR.pval(iCombo);
        end
        
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
    
    % =================================================================== %
    % Print out the regular ANOVA.
    
    fprintf(fileID,'\n========================================================\n');
    fprintf(fileID,'Regular ANOVA');
    fprintf(fileID,'\n========================================================\n\n');
    for iRow = 1:size(ANOVATable2,1)
        for iColumn = [1 2 3 4 5 6 10]
            if isnumeric(ANOVATable2{iRow,iColumn})
                fprintf(fileID,'%-12.10s', num2str(round(ANOVATable2{iRow,iColumn},4)));
            else
                if iColumn == 1
                    fprintf(fileID,'%-15.20s', ANOVATable2{iRow,iColumn});
                else
                    fprintf(fileID,'%-12.20s', ANOVATable2{iRow,iColumn});
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
    
    % =================================================================== %
    % Print out the GG ANOVA.
    
    fprintf(fileID,'\n========================================================\n');
    fprintf(fileID,'GreenhouseGeisser ANOVA')
    fprintf(fileID,'\n========================================================\n\n');
    for iRow = 1:size(ANOVATable2,1)
        for iColumn = [1 2 11 4 5 7 10]
            if isnumeric(ANOVATable2{iRow,iColumn})
                fprintf(fileID,'%-12.10s', num2str(round(ANOVATable2{iRow,iColumn},4)));
            else
                if iColumn == 1
                    fprintf(fileID,'%-15.20s', ANOVATable2{iRow,iColumn});
                else
                    fprintf(fileID,'%-12.20s', ANOVATable2{iRow,iColumn});
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
    
    % =================================================================== %
    % Print out the HF ANOVA.
    
    fprintf(fileID,'\n========================================================\n');
    fprintf(fileID,'HuynhFeldt ANOVA');
    fprintf(fileID,'\n========================================================\n\n');
    for iRow = 1:size(ANOVATable2,1)
        for iColumn = [1 2 12 4 5 8 10]
            if isnumeric(ANOVATable2{iRow,iColumn})
                fprintf(fileID,'%-12.10s', num2str(round(ANOVATable2{iRow,iColumn},4)));
            else
                if iColumn == 1
                    fprintf(fileID,'%-15.20s', ANOVATable2{iRow,iColumn});
                else
                    fprintf(fileID,'%-12.20s', ANOVATable2{iRow,iColumn});
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
    
    % =================================================================== %
    % Print out the HF ANOVA.
    
    fprintf(fileID,'\n========================================================\n');
    fprintf(fileID,'LowerBound ANOVA');
    fprintf(fileID,'\n========================================================\n\n');
    for iRow = 1:size(ANOVATable2,1)
        for iColumn = [1 2 13 4 5 9 10]
            if isnumeric(ANOVATable2{iRow,iColumn})
                fprintf(fileID,'%-12.10s', num2str(round(ANOVATable2{iRow,iColumn},4)));
            else
                if iColumn == 1
                    fprintf(fileID,'%-15.20s', ANOVATable2{iRow,iColumn});
                else
                    fprintf(fileID,'%-12.20s', ANOVATable2{iRow,iColumn});
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
    
    % =================================================================== %
    % Print Mauchly's and Epsilon.
    % =================================================================== %
    
    fprintf(fileID,'\n========================================================\n');
    fprintf(fileID,'Mauchly''s Test');
    fprintf(fileID,'\n========================================================\n\n');
    
    for iLevel = 1:(height(ANOVATable))/2
        RowName = ANOVATable.Properties.RowNames{(iLevel*2)-1};
        fprintf(fileID,[RowName '; W(' num2str(MAUCHLY.DF(iLevel,1)) ') = ' num2str(MAUCHLY.W(iLevel,1)) ', P = ' num2str(MAUCHLY.pValue(iLevel,1)) ', Chi = ' num2str(MAUCHLY.ChiStat(iLevel,1)) '\n']);
    end
    
    fprintf(fileID,'\n========================================================\n');
    fprintf(fileID,'Epsilon Values')
    fprintf(fileID,'\n========================================================\n\n');
    
    for iLevel = 1:(height(ANOVATable))/2
        RowName = ANOVATable.Properties.RowNames{(iLevel*2)-1};
        fprintf(fileID,[RowName '; Uncorr = ' num2str(EPSILON.Uncorrected(iLevel,1)) '; GG = ' num2str(EPSILON.GreenhouseGeisser(iLevel,1)) '; HF = ' num2str(EPSILON.HuynhFeldt(iLevel,1)) '; LB = ' num2str(EPSILON.LowerBound(iLevel,1)) '\n']);
    end
    
    % Print PostHoc.
    
    for iAnalysis = 1:length(POSTHOC.Analysis)
        fprintf(fileID,'\n\n========================================================\n');
        fprintf(fileID,['Effect = ' strjoin(POSTHOC.Analysis(iAnalysis).FactorNames,' + ')]);
        fprintf(fileID,['\n\nMauchly''s Test; W(' num2str(MAUCHLY.DF(iAnalysis+1,1)) ') = ' num2str(MAUCHLY.W(iAnalysis+1,1)) ', P = ' num2str(MAUCHLY.pValue(iAnalysis+1,1)) ', Chi = ' num2str(MAUCHLY.ChiStat(iAnalysis+1,1)) '\n']);
        
        if MAUCHLY.W(iAnalysis+1,1) == 1
            fprintf(fileID,'Ignore Sphericity; use regular ANOVA\n');
        elseif MAUCHLY.pValue(iAnalysis+1,1) < 0.05
            fprintf(fileID,'SPHERICITY VIOLATED (P < .05); USE GG/HF/LB\n');
        else
            fprintf(fileID,'Sphericity Okay (P >= .05); use Regular\n');
        end
        
        fprintf(fileID,['\nRegular - F(' num2str(ANOVATable.DF(iAnalysis*2+1)) ',' num2str(ANOVATable.DF(iAnalysis*2+2)) ') = ' num2str(round(ANOVATable.F(iAnalysis*2+1),3)) ', P = ' num2str(round(ANOVATable.pValue(iAnalysis*2+1),3)) ', np2 = ' num2str(round(ANOVATable.np2(iAnalysis*2+1),3))]);
        fprintf(fileID,['\nGreenhouseGeisser - F(' num2str(ANOVATable.DF_GG(iAnalysis*2+1)) ',' num2str(ANOVATable.DF_GG(iAnalysis*2+2)) ') = ' num2str(round(ANOVATable.F(iAnalysis*2+1),3)) ', P = ' num2str(round(ANOVATable.pValueGG(iAnalysis*2+1),3)) ', np2 = ' num2str(round(ANOVATable.np2(iAnalysis*2+1),3))]);
        fprintf(fileID,['\nHuynhFeldt - F(' num2str(ANOVATable.DF_HF(iAnalysis*2+1)) ',' num2str(ANOVATable.DF_HF(iAnalysis*2+2)) ') = ' num2str(round(ANOVATable.F(iAnalysis*2+1),3)) ', P = ' num2str(round(ANOVATable.pValueHF(iAnalysis*2+1),3)) ', np2 = ' num2str(round(ANOVATable.np2(iAnalysis*2+1),3))]);
        fprintf(fileID,['\nLowerBound - F(' num2str(ANOVATable.DF_LB(iAnalysis*2+1)) ',' num2str(ANOVATable.DF_LB(iAnalysis*2+2)) ') = ' num2str(round(ANOVATable.F(iAnalysis*2+1),3)) ', P = ' num2str(round(ANOVATable.pValueLB(iAnalysis*2+1),3)) ', np2 = ' num2str(round(ANOVATable.np2(iAnalysis*2+1),3))]);
        fprintf(fileID,'\n========================================================\n\n');
        for iCond = 1:length(POSTHOC.Analysis(iAnalysis).Conditions)
            fprintf(fileID,[POSTHOC.Analysis(iAnalysis).Conditions{iCond} '; M = ' num2str(round(mean(POSTHOC.Analysis(iAnalysis).Data_Resize(iCond,:)),3)) ' (SD = ' num2str(round(std(POSTHOC.Analysis(iAnalysis).Data_Resize(iCond,:)),3)) ')\n']);
        end
        fprintf(fileID,'\n');
        for iLevel = 1:length(POSTHOC.Analysis(iAnalysis).PostHoc)
            fprintf(fileID,[strjoin(POSTHOC.Analysis(iAnalysis).PostHoc(iLevel).Levels,' vs ') '; ']);
            fprintf(fileID,['t(' num2str(POSTHOC.Analysis(iAnalysis).PostHoc(iLevel).df) ') = '  num2str(round(POSTHOC.Analysis(iAnalysis).PostHoc(iLevel).F,3)) ', P = ' num2str(round(POSTHOC.Analysis(iAnalysis).PostHoc(iLevel).P_Perm,3)) ' (Corrected = ' num2str(round(POSTHOC.Analysis(iAnalysis).PostHoc(iLevel).P_FDR,3)) '), d = ' num2str(round(POSTHOC.Analysis(iAnalysis).PostHoc(iLevel).CohensD,3)) '\n']);
        end
    end
    
    fclose(fileID);
    
end
