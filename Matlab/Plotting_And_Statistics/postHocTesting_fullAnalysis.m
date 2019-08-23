% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 19/02/2019
%
% Current version = v1.1
%
% Carries out statistics using the EEGLab statcond function. This function
% takes a cell array of data and carries out (permutation-based) ANOVAs and
% all possible post-hoc tests.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% statData  -   This is a cell array of data in the same format that is
%               required by the statCond function.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% Permutation           -   Whether to carry out permutation analysis, or
%                           just regular ANOVA / T-Tests. (DEFAULT: 1)
% nPerm                 -   Number of permutation for "Permutation".
%                           (DEFAULT: 5000)
% RowCondition          -   Name of conditions in each row. (DEFAULT: {'R01
%                           'R02' ... 'RXX'})
% ColCondition          -   Name of conditions in each column.
%                           (DEFAULT: {'C01 'C02' ... 'CXX'})
% IndividualLevels      -   Cell array of condition names corresponding to
%                           the size of statData. (DEFAULT: {'R01C01'
%                           'R01C02' ... 'RXXCXX'})
% ANOVATitle            -   Title of ANOVA. (DEFAULT: 'ANOVA Results')
% PrintToFile           -   File ID if printing to file. (DEFAULT: [])
% PlotData              -   Plot the data into bar graph. (DEFAULT: 1)
% PlotData_Effect       -   What effect to plot (1 = ROW; 2 = COL; 3 = INT).
%                           (DEFAULT: 3)
% PlotData_LineType     -   Whether to plot 'SE' or 'SD'. (DEFAULT: 'SE')
% CILineWidth           -   Width of confidence interval line. 
%                           (DEFAULT: 3).
% CIOneWay              -   Whether to plot confidence intervals in both
%                           directions, or just in the direction of the
%                           data. (DEFAULT: 1)
%
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% postHocStruct     -   Structure containing information regarding ANOVA
%                       and post-hoc T-Tests.
% figHandle         -   Handle for plotting of data.
%
% ======================================================================= %
% Example
% ======================================================================= %
%
% postHocTesting_fullAnalysis(statData, ...
%     'ColCondition',{'LowValue' 'HighValue'}, ...
%     'RowCondition',{'Congruent' 'Incongruent'}, ...
%     'ANOVATitle','ANOVA; Saccade Direction; Bundles', ...
%     'PrintToFile', FID, ...
%     'Permutation', 1);
%
% ======================================================================= %
% Dependencies.
% ======================================================================= %
%
% statCond (EEGLab Toolbox)
%
% ======================================================================= %
% UPDATE HISTORY:
%
% 19/02/2019 (v1.0) -   V1.0 Created.
% 25/02/2019 (v1.1) -   Implemented ability to plot data.

function [postHocStruct,figHandle] = postHocTesting_fullAnalysis(statData,varargin)

% ======================================================================= %
%
% ======================================================================= %

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'Permutation'), varInput.Permutation = 1; end
if ~isfield(varInput, 'nPerm'), varInput.nPerm = 5000; end
if ~isfield(varInput, 'RowCondition')
    for iRow = 1:size(statData,1)
        varInput.RowCondition{iRow} = ['R' nDigitString(iRow,2)];
    end
end
if ~isfield(varInput, 'ColCondition')
    for iCol = 1:size(statData,2)
        varInput.ColCondition{iCol} = ['C' nDigitString(iCol,2)];
    end
end
if ~isfield(varInput, 'IndividualLevels')
    for iRow = 1:size(statData,1)
        for iCol = 1:size(statData,2)
            varInput.IndividualLevels{iRow,iCol} = [varInput.RowCondition{iRow} varInput.ColCondition{iCol}];
        end
    end
end
if ~isfield(varInput, 'ANOVATitle'), varInput.ANOVATitle = 'ANOVA Results'; end
if ~isfield(varInput, 'PrintToFile'), varInput.PrintToFile = []; end
if ~isfield(varInput, 'PlotData'), varInput.PlotData = 1; end
if ~isfield(varInput, 'PlotData_Effect'), varInput.PlotData_Effect = 3; end
if ~isfield(varInput, 'PlotData_LineType'), varInput.PlotData_LineType = 'SE'; end
if ~isfield(varInput, 'CILineWidth'), varInput.CILineWidth = 3; end
if ~isfield(varInput, 'CIOneWay'), varInput.CIOneWay = 1; end

% ======================================================================= %
%
% ======================================================================= %

DATACONFIG = [];

DATACONFIG.statData = statData;

DATACONFIG.ANOVA = struct();
DATACONFIG.ANOVA.statData = DATACONFIG.statData;

postHocStruct = []; figHandle = [];

% ======================================================================= %
%
% ======================================================================= %

if varInput.Permutation
    [DATACONFIG.ANOVA.F,DATACONFIG.ANOVA.df,DATACONFIG.ANOVA.P,surrog] = statcond(DATACONFIG.ANOVA.statData,'method','perm','naccu',varInput.nPerm);
else
    [DATACONFIG.ANOVA.F,DATACONFIG.ANOVA.df,DATACONFIG.ANOVA.P,surrog] = statcond(DATACONFIG.ANOVA.statData);
end

% ======================================================================= %
%
% ======================================================================= %

if length(DATACONFIG.ANOVA.F) > 1
    
    for iRow = 1:size(DATACONFIG.ANOVA.statData,1)
        DATACONFIG.ANOVA.RowData.(varInput.RowCondition{iRow}) = mean(cat(1,DATACONFIG.ANOVA.statData{iRow,:}),1);
        DATACONFIG.ANOVA.RowMean.(varInput.RowCondition{iRow}) = mean(DATACONFIG.ANOVA.RowData.(varInput.RowCondition{iRow}));
        DATACONFIG.ANOVA.RowSTD.(varInput.RowCondition{iRow}) = std(DATACONFIG.ANOVA.RowData.(varInput.RowCondition{iRow}));
    end
    
    for iCol = 1:size(DATACONFIG.ANOVA.statData,2)
        DATACONFIG.ANOVA.ColData.(varInput.ColCondition{iCol}) = mean(cat(1,DATACONFIG.ANOVA.statData{:,iCol}),1);
        DATACONFIG.ANOVA.ColMean.(varInput.ColCondition{iCol}) = mean(DATACONFIG.ANOVA.ColData.(varInput.ColCondition{iCol}));
        DATACONFIG.ANOVA.ColSTD.(varInput.ColCondition{iCol}) = std(DATACONFIG.ANOVA.ColData.(varInput.ColCondition{iCol}));
    end
    
end

% ======================================================================= %
%
% ======================================================================= %

condCount = 0;
for iRow = 1:size(DATACONFIG.ANOVA.statData,1)
    for iCol = 1:size(DATACONFIG.ANOVA.statData,2)
        condCount = condCount + 1;
        DATACONFIG.ANOVA.AllData.(varInput.IndividualLevels{iRow,iCol}) = DATACONFIG.ANOVA.statData{iRow,iCol};
        DATACONFIG.ANOVA.AllMean.(varInput.IndividualLevels{iRow,iCol}) = mean(DATACONFIG.ANOVA.AllData.(varInput.IndividualLevels{iRow,iCol}));
        DATACONFIG.ANOVA.AllSTD.(varInput.IndividualLevels{iRow,iCol}) = std(DATACONFIG.ANOVA.AllData.(varInput.IndividualLevels{iRow,iCol}));
        DATACONFIG.ANOVA.AllConds{condCount} = varInput.IndividualLevels{iRow,iCol};
    end
end

% ======================================================================= %
%
% ======================================================================= %

if length(DATACONFIG.ANOVA.F) > 1
    
    % ======================================================================= %
    % Row Statistics.
    
    DATACONFIG.ANOVA.postHoc_Row = table();
    DATACONFIG.ANOVA.postHoc_Row.Combos = nchoosek(1:length(varInput.RowCondition),2);
    
    for iCombo = 1:size(DATACONFIG.ANOVA.postHoc_Row.Combos,1)
        TEMP = [];
        TEMP.combo = DATACONFIG.ANOVA.postHoc_Row.Combos(iCombo,:);
        DATACONFIG.ANOVA.postHoc_Row.StatData{iCombo,1} = DATACONFIG.ANOVA.RowData.(varInput.RowCondition{TEMP.combo(1)});
        DATACONFIG.ANOVA.postHoc_Row.StatData{iCombo,2} = DATACONFIG.ANOVA.RowData.(varInput.RowCondition{TEMP.combo(2)});
        
        if ~varInput.Permutation
            [   DATACONFIG.ANOVA.postHoc_Row.F(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Row.df(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Row.P(iCombo)] = statcond(DATACONFIG.ANOVA.postHoc_Row.StatData(iCombo,:));
        else
            
            [   DATACONFIG.ANOVA.postHoc_Row.F(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Row.df(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Row.P(iCombo)] = statcond(DATACONFIG.ANOVA.postHoc_Row.StatData(iCombo,:),'method','perm','naccu',varInput.nPerm);
        end
        
    end
    
    % ======================================================================= %
    % Calculate Cohen's D for each comparison.
    % ======================================================================= %
    
    for iRow = 1:size(DATACONFIG.ANOVA.postHoc_Row,1)
        DATACONFIG.ANOVA.postHoc_Row.CohensD(iRow,1) = CohensD(DATACONFIG.ANOVA.postHoc_Row.StatData{iRow,1},DATACONFIG.ANOVA.postHoc_Row.StatData{iRow,2});
    end

    % ======================================================================= %
    % Column Statistics.
    
    DATACONFIG.ANOVA.postHoc_Col = table();
    DATACONFIG.ANOVA.postHoc_Col.Combos = nchoosek(1:length(varInput.ColCondition),2);
    
    for iCombo = 1:size(DATACONFIG.ANOVA.postHoc_Col.Combos,1)
        TEMP = [];
        TEMP.combo = DATACONFIG.ANOVA.postHoc_Col.Combos(iCombo,:);
        DATACONFIG.ANOVA.postHoc_Col.StatData{iCombo,1} = DATACONFIG.ANOVA.ColData.(varInput.ColCondition{TEMP.combo(1)});
        DATACONFIG.ANOVA.postHoc_Col.StatData{iCombo,2} = DATACONFIG.ANOVA.ColData.(varInput.ColCondition{TEMP.combo(2)});
        
        if ~varInput.Permutation
            [   DATACONFIG.ANOVA.postHoc_Col.F(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Col.df(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Col.P(iCombo)] = statcond(DATACONFIG.ANOVA.postHoc_Col.StatData(iCombo,:));
        else
            [   DATACONFIG.ANOVA.postHoc_Col.F(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Col.df(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Col.P(iCombo)] = statcond(DATACONFIG.ANOVA.postHoc_Col.StatData(iCombo,:),'method','perm','naccu',varInput.nPerm);
        end
        
    end
    
    % ======================================================================= %
    % Calculate Cohen's D for each comparison.
    % ======================================================================= %
    
    for iRow = 1:size(DATACONFIG.ANOVA.postHoc_Col,1)
        DATACONFIG.ANOVA.postHoc_Col.CohensD(iRow,1) = CohensD(DATACONFIG.ANOVA.postHoc_Col.StatData{iRow,1},DATACONFIG.ANOVA.postHoc_Col.StatData{iRow,2});
    end
    
    % ======================================================================= %
    % Interaction Statistics.
    
    DATACONFIG.ANOVA.postHoc_Int = table();
    DATACONFIG.ANOVA.postHoc_Int.Combos = nchoosek(1:length(DATACONFIG.ANOVA.AllConds),2);
    
    for iCombo = 1:size(DATACONFIG.ANOVA.postHoc_Int.Combos,1)
        TEMP = [];
        TEMP.combo = DATACONFIG.ANOVA.postHoc_Int.Combos(iCombo,:);
        DATACONFIG.ANOVA.postHoc_Int.StatData{iCombo,1} = DATACONFIG.ANOVA.AllData.(DATACONFIG.ANOVA.AllConds{TEMP.combo(1)});
        DATACONFIG.ANOVA.postHoc_Int.StatData{iCombo,2} = DATACONFIG.ANOVA.AllData.(DATACONFIG.ANOVA.AllConds{TEMP.combo(2)});
        
        if ~varInput.Permutation
            [   DATACONFIG.ANOVA.postHoc_Int.F(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Int.df(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Int.P(iCombo)] = statcond(DATACONFIG.ANOVA.postHoc_Int.StatData(iCombo,:));
        else
            [   DATACONFIG.ANOVA.postHoc_Int.F(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Int.df(iCombo), ...
                DATACONFIG.ANOVA.postHoc_Int.P(iCombo)] = statcond(DATACONFIG.ANOVA.postHoc_Int.StatData(iCombo,:),'method','perm','naccu',varInput.nPerm);
        end
        
    end
    
    % ======================================================================= %
    % Calculate Cohen's D for each comparison.
    % ======================================================================= %
    
    for iRow = 1:size(DATACONFIG.ANOVA.postHoc_Int,1)
        DATACONFIG.ANOVA.postHoc_Int.CohensD(iRow,1) = CohensD(DATACONFIG.ANOVA.postHoc_Int.StatData{iRow,1},DATACONFIG.ANOVA.postHoc_Int.StatData{iRow,2});
    end
    
else
    
    % ======================================================================= %
    % Row/Column Statistics.
    
    DATACONFIG.ANOVA.postHoc = table();
    DATACONFIG.ANOVA.postHoc.Combos = nchoosek(1:length(DATACONFIG.ANOVA.AllConds),2);
    
    for iCombo = 1:size(DATACONFIG.ANOVA.postHoc.Combos,1)
        TEMP = [];
        TEMP.combo = DATACONFIG.ANOVA.postHoc.Combos(iCombo,:);
        DATACONFIG.ANOVA.postHoc.StatData{iCombo,1} = DATACONFIG.ANOVA.AllData.(DATACONFIG.ANOVA.AllConds{TEMP.combo(1)});
        DATACONFIG.ANOVA.postHoc.StatData{iCombo,2} = DATACONFIG.ANOVA.AllData.(DATACONFIG.ANOVA.AllConds{TEMP.combo(2)});
        
        if ~varInput.Permutation
            [   DATACONFIG.ANOVA.postHoc.F(iCombo), ...
                DATACONFIG.ANOVA.postHoc.df(iCombo), ...
                DATACONFIG.ANOVA.postHoc.P(iCombo)] = statcond(DATACONFIG.ANOVA.postHoc.StatData(iCombo,:));
        else
            [   DATACONFIG.ANOVA.postHoc.F(iCombo), ...
                DATACONFIG.ANOVA.postHoc.df(iCombo), ...
                DATACONFIG.ANOVA.postHoc.P(iCombo)] = statcond(DATACONFIG.ANOVA.postHoc.StatData(iCombo,:),'method','perm','naccu',varInput.nPerm);
        end
        
    end
    
    % ======================================================================= %
    % Calculate Cohen's D for each comparison.
    % ======================================================================= %
    
    for iRow = 1:size(DATACONFIG.ANOVA.postHoc,1)
        DATACONFIG.ANOVA.postHoc.CohensD(iRow,1) = CohensD(DATACONFIG.ANOVA.postHoc.StatData{iRow,1},DATACONFIG.ANOVA.postHoc.StatData{iRow,2});
    end

end



% ======================================================================= %
% Report Main Effects.
% ======================================================================= %

disp(' ')
disp('============================================')
if ~varInput.Permutation
    disp([varInput.ANOVATitle '; Regular ANOVAs / T-Tests (' num2str(varInput.nPerm) ')'])
else
    disp([varInput.ANOVATitle '; Permutation Based ANOVAs / T-Tests (' num2str(varInput.nPerm) ')'])
end
disp('============================================')
disp(' ')

if length(DATACONFIG.ANOVA.F) > 1
    
    % ======================================================================= %
    % Row Display.
    
    TEMP = [];
    TEMP.rowCat = strjoin(varInput.RowCondition,'_vs_');
    
    disp('============================================')
    disp(TEMP.rowCat)
    
    disp(' ')
    disp(['F(' num2str(DATACONFIG.ANOVA.df{1}(1)) ',' num2str(DATACONFIG.ANOVA.df{1}(2)) ') = ' num2str(round(DATACONFIG.ANOVA.F{1},3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P{1},3))])
    
    disp(' ')
    for iRow = 1:length(varInput.RowCondition)
        disp([varInput.RowCondition{iRow} ' (M = ' num2str(round(DATACONFIG.ANOVA.RowMean.(varInput.RowCondition{iRow}),3)) '; SD = ' num2str(round(DATACONFIG.ANOVA.RowSTD.(varInput.RowCondition{iRow}),3)) ')'])
    end
    
    disp(' ')
    for iCombo = 1:size(DATACONFIG.ANOVA.postHoc_Row.Combos,1)
        TEMP = [];
        TEMP.combo = DATACONFIG.ANOVA.postHoc_Row.Combos(iCombo,:);
        disp([strjoin(varInput.RowCondition(TEMP.combo),'_vs_') '; t(' num2str(DATACONFIG.ANOVA.postHoc_Row.df(iCombo,1)) ') = ' num2str(round(DATACONFIG.ANOVA.postHoc_Row.F(iCombo,1),3)) ', P = ' num2str(round(DATACONFIG.ANOVA.postHoc_Row.P(iCombo,1),4)) ...
            '; Cohens D = ' num2str(round(DATACONFIG.ANOVA.postHoc_Row.CohensD(iCombo,1),4)) ...
            ' (Abs Mean Difference = ' num2str(round(abs(mean(DATACONFIG.ANOVA.postHoc_Row.StatData{iCombo,1}) - mean(DATACONFIG.ANOVA.postHoc_Row.StatData{iCombo,2})),3)) ')'])
    end
    
    % ======================================================================= %
    % Column Display.
    
    TEMP = [];
    TEMP.colCat = strjoin(varInput.ColCondition,'_vs_');
    disp(' ')
    disp('============================================')
    disp(TEMP.colCat)
    
    disp(' ')
    disp(['F(' num2str(DATACONFIG.ANOVA.df{2}(1)) ',' num2str(DATACONFIG.ANOVA.df{2}(2)) ') = ' num2str(round(DATACONFIG.ANOVA.F{2},3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P{2},3))])
    
    disp(' ')
    for iCol = 1:length(varInput.ColCondition)
        disp([varInput.ColCondition{iCol} ' (M = ' num2str(round(DATACONFIG.ANOVA.ColMean.(varInput.ColCondition{iCol}),3)) '; SD = ' num2str(round(DATACONFIG.ANOVA.ColSTD.(varInput.ColCondition{iCol}),3)) ')'])
    end
    
    disp(' ')
    for iCombo = 1:size(DATACONFIG.ANOVA.postHoc_Col.Combos,1)
        TEMP = [];
        TEMP.combo = DATACONFIG.ANOVA.postHoc_Col.Combos(iCombo,:);
        disp([strjoin(varInput.ColCondition(TEMP.combo),'_vs_') '; t(' num2str(DATACONFIG.ANOVA.postHoc_Col.df(iCombo,1)) ') = ' num2str(round(DATACONFIG.ANOVA.postHoc_Col.F(iCombo,1),3)) ', P = ' num2str(round(DATACONFIG.ANOVA.postHoc_Col.P(iCombo,1),4)) ...
            '; Cohens D = ' num2str(round(DATACONFIG.ANOVA.postHoc_Col.CohensD(iCombo,1),4)) ...
            ' (Abs Mean Difference = ' num2str(round(abs(mean(DATACONFIG.ANOVA.postHoc_Col.StatData{iCombo,1}) - mean(DATACONFIG.ANOVA.postHoc_Col.StatData{iCombo,2})),3)) ')'])
    end
    
    % ======================================================================= %
    % Interaction Display.
    
    disp(' ')
    disp('============================================')
    disp('Interaction')
    
    disp(' ')
    disp(['F(' num2str(DATACONFIG.ANOVA.df{3}(1)) ',' num2str(DATACONFIG.ANOVA.df{3}(2)) ') = ' num2str(round(DATACONFIG.ANOVA.F{3},3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P{3},3))])
    
    disp(' ')
    for iInt = 1:length(DATACONFIG.ANOVA.AllConds)
        disp([DATACONFIG.ANOVA.AllConds{iInt} ' (M = ' num2str(round(DATACONFIG.ANOVA.AllMean.(DATACONFIG.ANOVA.AllConds{iInt}),3)) '; SD = ' num2str(round(DATACONFIG.ANOVA.AllSTD.(DATACONFIG.ANOVA.AllConds{iInt}),3)) ')'])
    end
    
    disp(' ')
    for iCombo = 1:size(DATACONFIG.ANOVA.postHoc_Int.Combos,1)
        TEMP = [];
        TEMP.combo = DATACONFIG.ANOVA.postHoc_Int.Combos(iCombo,:);
        disp([strjoin(DATACONFIG.ANOVA.AllConds(TEMP.combo),'_vs_') '; t(' num2str(DATACONFIG.ANOVA.postHoc_Int.df(iCombo,1)) ') = ' num2str(round(DATACONFIG.ANOVA.postHoc_Int.F(iCombo,1),3)) ', P = ' num2str(round(DATACONFIG.ANOVA.postHoc_Int.P(iCombo,1),4)) ...
            '; Cohens D = ' num2str(round(DATACONFIG.ANOVA.postHoc_Int.CohensD(iCombo,1),4)) ...
            ' (Abs Mean Difference = ' num2str(round(abs(mean(DATACONFIG.ANOVA.postHoc_Int.StatData{iCombo,1}) - mean(DATACONFIG.ANOVA.postHoc_Int.StatData{iCombo,2})),3)) ')'])
    end
    
    % ======================================================================= %
    % Print to File (If Appropriate).
    
    if ~isempty(varInput.PrintToFile)
        fprintf(varInput.PrintToFile,'\n============================================\n');
        if ~varInput.Permutation
            fprintf(varInput.PrintToFile,[varInput.ANOVATitle '; Regular ANOVAs / T-Tests\n']);
        else
            fprintf(varInput.PrintToFile,[varInput.ANOVATitle '; Permutation Based ANOVAs / T-Tests (' num2str(varInput.nPerm) ' Permutations)\n']);
        end
        fprintf(varInput.PrintToFile,'============================================\n\n');
        
        % ======================================================================= %
        % Row Display.
        
        TEMP = [];
        TEMP.rowCat = strjoin(varInput.RowCondition,'_vs_');
        
        fprintf(varInput.PrintToFile,'============================================\n');
        fprintf(varInput.PrintToFile,[TEMP.rowCat '\n\n']);
        
        fprintf(varInput.PrintToFile,['F(' num2str(DATACONFIG.ANOVA.df{1}(1)) ',' num2str(DATACONFIG.ANOVA.df{1}(2)) ') = ' num2str(round(DATACONFIG.ANOVA.F{1},3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P{1},3)) '\n\n']);
        
        for iRow = 1:length(varInput.RowCondition)
            fprintf(varInput.PrintToFile,[varInput.RowCondition{iRow} '(M = ' num2str(round(DATACONFIG.ANOVA.RowMean.(varInput.RowCondition{iRow}),3)) '; SD = ' num2str(round(DATACONFIG.ANOVA.RowSTD.(varInput.RowCondition{iRow}),3)) ')\n']);
        end
        
        fprintf(varInput.PrintToFile,'\n');
        for iCombo = 1:size(DATACONFIG.ANOVA.postHoc_Row.Combos,1)
            TEMP = [];
            TEMP.combo = DATACONFIG.ANOVA.postHoc_Row.Combos(iCombo,:);
            fprintf(varInput.PrintToFile,[strjoin(varInput.RowCondition(TEMP.combo),'_vs_') '; t(' num2str(DATACONFIG.ANOVA.postHoc_Row.df(iCombo,1)) ') = ' num2str(round(DATACONFIG.ANOVA.postHoc_Row.F(iCombo,1),3)) ', P = ' num2str(round(DATACONFIG.ANOVA.postHoc_Row.P(iCombo,1),4)) ...
                '; Cohens D = ' num2str(round(DATACONFIG.ANOVA.postHoc_Row.CohensD(iCombo,1),4)) ...
                ' (Abs Mean Difference = ' num2str(round(abs(mean(DATACONFIG.ANOVA.postHoc_Row.StatData{iCombo,1}) - mean(DATACONFIG.ANOVA.postHoc_Row.StatData{iCombo,2})),3)) ')' '\n']);
        end
        
        % ======================================================================= %
        % Column Display.
        
        TEMP = [];
        TEMP.colCat = strjoin(varInput.ColCondition,'_vs_');
        fprintf(varInput.PrintToFile,'\n');
        fprintf(varInput.PrintToFile,'============================================\n');
        fprintf(varInput.PrintToFile,[TEMP.colCat '\n\n']);
        
        fprintf(varInput.PrintToFile,['F(' num2str(DATACONFIG.ANOVA.df{2}(1)) ',' num2str(DATACONFIG.ANOVA.df{2}(2)) ') = ' num2str(round(DATACONFIG.ANOVA.F{2},3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P{2},3)) '\n\n']);
        
        for iCol = 1:length(varInput.ColCondition)
            fprintf(varInput.PrintToFile,[varInput.ColCondition{iCol} '(M = ' num2str(round(DATACONFIG.ANOVA.ColMean.(varInput.ColCondition{iCol}),3)) '; SD = ' num2str(round(DATACONFIG.ANOVA.ColSTD.(varInput.ColCondition{iCol}),3)) ')\n']);
        end
        
        fprintf(varInput.PrintToFile,'\n');
        for iCombo = 1:size(DATACONFIG.ANOVA.postHoc_Col.Combos,1)
            TEMP = [];
            TEMP.combo = DATACONFIG.ANOVA.postHoc_Col.Combos(iCombo,:);
            fprintf(varInput.PrintToFile,[strjoin(varInput.ColCondition(TEMP.combo),'_vs_') '; t(' num2str(DATACONFIG.ANOVA.postHoc_Col.df(iCombo,1)) ') = ' num2str(round(DATACONFIG.ANOVA.postHoc_Col.F(iCombo,1),3)) ', P = ' num2str(round(DATACONFIG.ANOVA.postHoc_Col.P(iCombo,1),4)) ...
                '; Cohens D = ' num2str(round(DATACONFIG.ANOVA.postHoc_Col.CohensD(iCombo,1),4)) ...
                ' (Abs Mean Difference = ' num2str(round(abs(mean(DATACONFIG.ANOVA.postHoc_Col.StatData{iCombo,1}) - mean(DATACONFIG.ANOVA.postHoc_Col.StatData{iCombo,2})),3)) ')' '\n']);
        end
        
        % ======================================================================= %
        % Interaction Display.
        
        fprintf(varInput.PrintToFile,'\n');
        fprintf(varInput.PrintToFile,'============================================\n');
        fprintf(varInput.PrintToFile,'Interaction\n\n');
        
        fprintf(varInput.PrintToFile,['F(' num2str(DATACONFIG.ANOVA.df{3}(1)) ',' num2str(DATACONFIG.ANOVA.df{3}(2)) ') = ' num2str(round(DATACONFIG.ANOVA.F{3},3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P{3},3)) '\n\n']);
        
        for iInt = 1:length(DATACONFIG.ANOVA.AllConds)
            fprintf(varInput.PrintToFile,[DATACONFIG.ANOVA.AllConds{iInt} '(M = ' num2str(round(DATACONFIG.ANOVA.AllMean.(DATACONFIG.ANOVA.AllConds{iInt}),3)) '; SD = ' num2str(round(DATACONFIG.ANOVA.AllSTD.(DATACONFIG.ANOVA.AllConds{iInt}),3)) ')\n']);
        end
        
        fprintf(varInput.PrintToFile,'\n');
        for iCombo = 1:size(DATACONFIG.ANOVA.postHoc_Int.Combos,1)
            TEMP = [];
            TEMP.combo = DATACONFIG.ANOVA.postHoc_Int.Combos(iCombo,:);
            fprintf(varInput.PrintToFile,[strjoin(DATACONFIG.ANOVA.AllConds(TEMP.combo),'_vs_') '; t(' num2str(DATACONFIG.ANOVA.postHoc_Int.df(iCombo,1)) ') = ' num2str(round(DATACONFIG.ANOVA.postHoc_Int.F(iCombo,1),3)) ', P = ' num2str(round(DATACONFIG.ANOVA.postHoc_Int.P(iCombo,1),4)) ...
                '; Cohens D = ' num2str(round(DATACONFIG.ANOVA.postHoc_Int.CohensD(iCombo,1),4)) ...
                ' (Abs Mean Difference = ' num2str(round(abs(mean(DATACONFIG.ANOVA.postHoc_Int.StatData{iCombo,1}) - mean(DATACONFIG.ANOVA.postHoc_Int.StatData{iCombo,2})),3)) ')' '\n']);
        end
        
    end
    
else
    
    % ======================================================================= %
    % Results Display.
    
    disp(' ')
    disp('============================================')
    if length(DATACONFIG.ANOVA.df) > 1
        disp('One-Way ANOVA Results')
        disp(' ')
        disp(['F(' num2str(DATACONFIG.ANOVA.df(1)) ',' num2str(DATACONFIG.ANOVA.df(2)) ') = ' num2str(round(DATACONFIG.ANOVA.F,3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P,3))])
    else
        disp('T-Test Results')
        disp(' ')
        disp(['t(' num2str(DATACONFIG.ANOVA.df(1)) ') = ' num2str(round(DATACONFIG.ANOVA.F,3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P,3))])
    end
    
    disp(' ')
    for iVar = 1:length(DATACONFIG.ANOVA.AllConds)
        disp([DATACONFIG.ANOVA.AllConds{iVar} ' (M = ' num2str(round(DATACONFIG.ANOVA.AllMean.(DATACONFIG.ANOVA.AllConds{iVar}),3)) '; SD = ' num2str(round(DATACONFIG.ANOVA.AllSTD.(DATACONFIG.ANOVA.AllConds{iVar}),3)) ')'])
    end
    
    disp(' ')
    for iCombo = 1:size(DATACONFIG.ANOVA.postHoc.Combos,1)
        TEMP = [];
        TEMP.combo = DATACONFIG.ANOVA.postHoc.Combos(iCombo,:);
        disp([strjoin(DATACONFIG.ANOVA.AllConds(TEMP.combo),'_vs_') '; t(' num2str(DATACONFIG.ANOVA.postHoc.df(iCombo,1)) ') = ' num2str(round(DATACONFIG.ANOVA.postHoc.F(iCombo,1),3)) ', P = ' num2str(round(DATACONFIG.ANOVA.postHoc.P(iCombo,1),4)) ...
            '; Cohens D = ' num2str(round(DATACONFIG.ANOVA.postHoc.CohensD(iCombo,1),4)) ...
            ' (Abs Mean Difference = ' num2str(round(abs(mean(DATACONFIG.ANOVA.postHoc.StatData{iCombo,1}) - mean(DATACONFIG.ANOVA.postHoc.StatData{iCombo,2})),3)) ')'])
    end
    
    if ~isempty(varInput.PrintToFile)
        
        fprintf(varInput.PrintToFile,'\n============================================\n');
        if ~varInput.Permutation
            fprintf(varInput.PrintToFile,[varInput.ANOVATitle '; Regular ANOVAs / T-Tests\n']);
        else
            fprintf(varInput.PrintToFile,[varInput.ANOVATitle '; Permutation Based ANOVAs / T-Tests (' num2str(varInput.nPerm) ' Permutations)\n']);
        end
        fprintf(varInput.PrintToFile,'============================================\n\n');
        
        % ======================================================================= %
        % Results Display.
        
        fprintf(varInput.PrintToFile,'============================================\n');
        
        if length(DATACONFIG.ANOVA.df) > 1
            fprintf(varInput.PrintToFile,'One-Way ANOVA Results\n');
            fprintf(varInput.PrintToFile,'\n');
            fprintf(varInput.PrintToFile,['F(' num2str(DATACONFIG.ANOVA.df(1)) ',' num2str(DATACONFIG.ANOVA.df(2)) ') = ' num2str(round(DATACONFIG.ANOVA.F,3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P,3)) '\n']);
        else
            fprintf(varInput.PrintToFile,'T-Test Results\n');
            fprintf(varInput.PrintToFile,'\n');
            fprintf(varInput.PrintToFile,['t(' num2str(DATACONFIG.ANOVA.df(1)) ') = ' num2str(round(DATACONFIG.ANOVA.F,3)) ', P = ' num2str(round(DATACONFIG.ANOVA.P,3)) '\n']);
        end
        
        fprintf(varInput.PrintToFile,'\n');
        for iVar = 1:length(DATACONFIG.ANOVA.AllConds)
            fprintf(varInput.PrintToFile,[DATACONFIG.ANOVA.AllConds{iVar} ' (M = ' num2str(round(DATACONFIG.ANOVA.AllMean.(DATACONFIG.ANOVA.AllConds{iVar}),3)) '; SD = ' num2str(round(DATACONFIG.ANOVA.AllSTD.(DATACONFIG.ANOVA.AllConds{iVar}),3)) ')\n']);
        end
        
        fprintf(varInput.PrintToFile,'\n');
        for iCombo = 1:size(DATACONFIG.ANOVA.postHoc.Combos,1)
            TEMP = [];
            TEMP.combo = DATACONFIG.ANOVA.postHoc.Combos(iCombo,:);
            fprintf(varInput.PrintToFile,[strjoin(DATACONFIG.ANOVA.AllConds(TEMP.combo),'_vs_') '; t(' num2str(DATACONFIG.ANOVA.postHoc.df(iCombo,1)) ') = ' num2str(round(DATACONFIG.ANOVA.postHoc.F(iCombo,1),3)) ', P = ' num2str(round(DATACONFIG.ANOVA.postHoc.P(iCombo,1),4)) ...
                '; Cohens D = ' num2str(round(DATACONFIG.ANOVA.postHoc.CohensD(iCombo,1),4)) ...
                ' (Abs Mean Difference = ' num2str(round(abs(mean(DATACONFIG.ANOVA.postHoc.StatData{iCombo,1}) - mean(DATACONFIG.ANOVA.postHoc.StatData{iCombo,2})),3)) ')' '\n']);
        end
        
    end
    
end

% Plot data.

if varInput.PlotData
    
    if varInput.PlotData_Effect == 1
        
        for iRow = 1:size(DATACONFIG.ANOVA.statData,1)
            DATACONFIG.ANOVA.statData2{iRow} = cat(1,DATACONFIG.ANOVA.statData{iRow,:});
            DATACONFIG.ANOVA.statData2{iRow} = nanmean(DATACONFIG.ANOVA.statData2{iRow},1);
            DATACONFIG.ANOVA.plotData{iRow} = nanmean(DATACONFIG.ANOVA.statData2{iRow});
            
        end
        DATACONFIG.ANOVA.plotData = cell2mat(DATACONFIG.ANOVA.plotData);
        
        figHandle = bar(DATACONFIG.ANOVA.plotData);
        
        CI = SE_WithinSubjects_Cell(DATACONFIG.ANOVA.statData2,figHandle, ...
            'LineType', varInput.PlotData_LineType, ...
            'CILineWidth', varInput.CILineWidth, ...
            'CIOneWay', varInput.CIOneWay);
        
        set(gca,'XTickLabels',varInput.RowCondition)
        set(gca,'FontSize',16)
        
    elseif varInput.PlotData_Effect == 2
        
        for iCol = 1:size(DATACONFIG.ANOVA.statData,2)
            DATACONFIG.ANOVA.statData2{iCol} = cat(1,DATACONFIG.ANOVA.statData{:,iCol});
            DATACONFIG.ANOVA.statData2{iCol} = nanmean(DATACONFIG.ANOVA.statData2{iCol},1);
            DATACONFIG.ANOVA.plotData{iCol} = nanmean(DATACONFIG.ANOVA.statData2{iCol});
        end
        DATACONFIG.ANOVA.plotData = cell2mat(DATACONFIG.ANOVA.plotData);
        
        figHandle = bar(DATACONFIG.ANOVA.plotData);
        
        CI = SE_WithinSubjects_Cell(DATACONFIG.ANOVA.statData2,figHandle, ...
            'LineType', varInput.PlotData_LineType, ...
            'CILineWidth', varInput.CILineWidth, ...
            'CIOneWay', varInput.CIOneWay);
        
        set(gca,'XTickLabels',varInput.ColCondition)
        set(gca,'FontSize',16)
        
    elseif varInput.PlotData_Effect == 3
        
        DATACONFIG.ANOVA.plotData = DATACONFIG.ANOVA.statData;
        for iRow = 1:size(DATACONFIG.ANOVA.plotData,1)
            for iCol = 1:size(DATACONFIG.ANOVA.plotData,2)
                DATACONFIG.ANOVA.plotData{iRow,iCol} = nanmean(DATACONFIG.ANOVA.plotData{iRow,iCol});
            end
        end
        DATACONFIG.ANOVA.plotData = cell2mat(DATACONFIG.ANOVA.plotData);
        
        figHandle = bar(DATACONFIG.ANOVA.plotData);
        
        CI = SE_WithinSubjects_Cell(DATACONFIG.ANOVA.statData,figHandle, ...
            'LineType', varInput.PlotData_LineType, ...
            'CILineWidth', varInput.CILineWidth, ...
            'CIOneWay', varInput.CIOneWay);
        
        if length(DATACONFIG.ANOVA.P) > 1
            legend(varInput.ColCondition,'Location','Best')
            set(gca,'XTickLabels',varInput.RowCondition)
        else
            set(gca,'XTickLabels',varInput.ColCondition)
        end
        
        set(gca,'FontSize',16)
        
%         sigstar({currentOffset},currentP,[],'lineWidth',2,'fontSize',16,'separation',0.15)

    end
end

postHocStruct = DATACONFIG.ANOVA;


















