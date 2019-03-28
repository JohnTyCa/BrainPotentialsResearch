% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 13/02/2019
%
% Current version = v1.4
%
% Carries out regression analysis over a specified time interval for
% clustered independent components. Since multiple components can be
% contributed by a single subject, components from the same subject are
% first merged (via summation). This function accepts multiple predictors
% and utilises the fitlm() function. 
% 
% The function outputs the data into a variable, as well as plots the data
% across the latency interval with corresponding Adjusted R^2 Values and
% P-Values. Note that these values are taken from the highest order of
% predictors. For example, inputting 3 predictors will produce the
% following formula:
% 
% y ~ x1 + x2 + x3 + x1:x2 + x1:x3 + x2:x3 + x1:x2:x3
% 
% In this scenario, we will plot data in relation to "x1:x2:x3".
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% STUDY             -   EEGLab STUDY structure containing clustered data.
% ALLEEG            -   EEGLab ALLEEG structure.
% behaviouralData   -   Behavioural data. This must be in the format of a
%                       {1 x nPredictor} cell array of tables, each table 
%                       being a {nSub x nCond} array. The titles of the
%                       tables must correspond to variables within the
%                       STUDY.condition variable.
% clusters          -   Clusters for which to investigate as responses in
%                       regression.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% Latency               -   Latency over which to carry out regression.
%                           (DEFAULT: [])
% AverageConditions     -   Names of conditions in which you may want to
%                           average across. This should be a {1 x nAverage}
%                           cell array, with each column containing its own
%                           cell array of variable names. These variable
%                           names must correspond to names in the
%                           behaviouralData and the STUDY.condition
%                           variable. (DEFAULT: [])
% Regression            -   Whether to carry out regression or correlation.
%                           (DEFAULT: 1)
% AverageOverLatency    -   Whether you want to average over the latency
%                           input. (DEFAULT: 0)
% FDR                   -   False-discovery rate correction (BHFDR).
%                           (DEFAULT: 0)
% PredictorNames        -   Name of predictor variables. (DEFAULT: {})
% ResponseName          -   Name of response variable. (DEFAULT: {})
% ForceStudyCond        -   Force the STUDY.condition variable to be
%                           identical to the behaviouralData condition
%                           names as indicated by the behaviouralData table
%                           VariableNames. USE THIS WITH CAUTION, THIS
%                           ASSUMES THAT THE ORDER OF THE VARIABLES IN THE
%                           BEHAVIOURAL DATA TABLE CORRESPOND PERFECTLY TO
%                           THE STUDY CONDITIONS IN TERMS OF ORDERING.
%                           (DEFAULT: 0)
% PValYAxis             -   The range of P-Values to visualize when
%                           plotting P-Values over latencies. 
%                           (DEFAULT: 0.05)
% PlotSave              -   Directory to save each plot to. (DEFAULT: [])
% StanardizeData        -   Standardize data to z-scores. (DEFAULT: 0)
% ExtractCovariateData  -   Whether to extract the covariate data only for
%                           analysis elsewhere. This will organise the data
%                           into columns representing either the covariate
%                           or the dependent variable for each level of the
%                           independent variable. (DEFAULT: 0)
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% OUTPUT   -    Data extracted from each of the regression analyses taken
%               place, along with the corresponding predictor and response
%               data. The full linear model for each analysis is included.
%
% ======================================================================= %
% Example
% ======================================================================= %
%
% OUTPUT = clusterCovar(STUDY,ALLEEG,behaviouralData,5, ...
%                           'Latency', 100:150, ...
%                           'AverageConditions', {{'C1' 'C2'} {'C3'}, ...
%                           'AverageOverLatency', 1, ...
%                           'PredictorNames', {'Age' 'Height'}, ...
%                           'Response Name', 'Cluster Activation);
% 
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% nearest
% mergeSubjectComponents
% STUDY_subjectClusters
% scatterLSLine3D
% ls3dline
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 13/02/2019 (v1.0) -   V1.0 Created.
% 04/03/2019 (V1.1) -   If averaging over latency, will print out output.
% 08/03/2019 (V1.2) -   Now prints full ANOVA results.
% 13/03/2019 (V1.3) -   Ability to save plots.
%                       Ability to standardize data (z-score).
% 22/03/2019 (V1.4) -   Will save plots to individual file.
%                   -   Will extract the covariate data into a variable, or
%                       save it to a .txt and .csv file.
% 
% ======================================================================= %

function OUTPUT = clusterCovar(STUDY,ALLEEG,behaviouralData,clusters,varargin)

OUTPUT = [];

% ======================================================================= %
% Variable Argument Input Definitions.
% ======================================================================= %

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'Latency'), varInput.Latency = []; end
if ~isfield(varInput, 'AverageConditions'), varInput.AverageConditions = []; end
if ~isfield(varInput, 'Regression'), varInput.Regression = 1; end
if ~isfield(varInput, 'AverageOverLatency'), varInput.AverageOverLatency = 0; end
if ~isfield(varInput, 'FDR'), varInput.FDR = 0; end
if ~isfield(varInput, 'PredictorNames'), varInput.PredictorNames = {}; end
if ~isfield(varInput, 'ResponseName'), varInput.ResponseName = {}; end
if ~isfield(varInput, 'ForceStudyCond'), varInput.ForceStudyCond = 0; end
if ~isfield(varInput, 'PValYAxis'), varInput.PValYAxis = 0.05; end
if ~isfield(varInput, 'PlotSave'), varInput.PlotSave = []; end
if ~isfield(varInput, 'StandardizeData'), varInput.StandardizeData = 0; end
if ~isfield(varInput, 'ExtractCovariateData'), varInput.ExtractCovariateData = 0; end
if ~isfield(varInput, 'ExtractCovariateData_Save'), varInput.ExtractCovariateData_Save = []; end

% ======================================================================= %
% If ForceStudyCond, Rename STUDY.condition Variables to Behavioural Data
% Table Variable Names.
% ======================================================================= %

if varInput.ForceStudyCond
    disp('Forcing study conditions to behavioural data column names...')
    disp('Make sure the conditons correspond')
    for iPredictor = 1:length(behaviouralData)
        if length(STUDY.condition) ~= size(behaviouralData{iPredictor},2)
            disp(['Number of conditions in STUDY.condition ~= number in Predictor ' num2str(iPredictor)])
            return
        end
        for iCond = 1:length(STUDY.condition)
            disp(['STUDY.condition [' STUDY.condition{iCond} ']; behaviouralData{' num2str(iPredictor) '} [' behaviouralData{iPredictor}.Properties.VariableNames{iCond} ']'])
        end
        disp('Is this correct?')
        pause
    end
    
    for iCond = 1:length(STUDY.condition)
        STUDY.condition{iCond} =  behaviouralData{1}.Properties.VariableNames{iCond};
    end
    
end

% ======================================================================= %
% Some Logic Checks to Make Sure Input Data is Correctly Configured.
% ======================================================================= %

FUNCLOOP = [];

for iPredictor = 1:length(behaviouralData)
    if istable(behaviouralData{iPredictor})
        FUNCLOOP.fieldNames{iPredictor} = behaviouralData{iPredictor}.Properties.VariableNames;
    else
        error('behaviouralData must be a table (Subjects x Cond)')
    end
end

for iPredictor = 1:length(behaviouralData)
    for iCond = 1:length(FUNCLOOP.fieldNames{iPredictor})
        if ~any(strcmp(FUNCLOOP.fieldNames{iPredictor}{iCond},STUDY.condition))
            error(['behaviouralData column not found in STUDY.condition; ' FUNCLOOP.fieldNames{iPredictor}{iCond}]);
        else
            FUNCLOOP.conditionIndices{iPredictor}(iCond) = find(strcmp(FUNCLOOP.fieldNames{iPredictor}{iCond},STUDY.condition));
        end
    end
end

if ~isempty(varInput.AverageConditions)
    TEMP = [];
    TEMP.allCond = cat(2,varInput.AverageConditions{:});
    for iCond = 1:length(TEMP.allCond)
        if ~any(strcmp(TEMP.allCond{iCond},STUDY.condition))
            error(['AverageConditions variable not found in STUDY.condition; ' TEMP.allCond{iCond}]);
        end
    end
end

if length(behaviouralData) > 1
    TEMP = [];
    TEMP.combos = nchoosek(1:length(behaviouralData),2);
    TEMP.error = 0;
    for iCombo = 1:size(TEMP.combos,1)
        if size(behaviouralData{TEMP.combos(iCombo,1)},2) ~= size(behaviouralData{TEMP.combos(iCombo,2)},2)
            disp(['Length of Predictor ' num2str(TEMP.combos(iCombo,1)) ' ~= Length of Predictor ' num2str(TEMP.combos(iCombo,2))])
            TEMP.error = 1;
        end
        for iCond = 1:length(FUNCLOOP.fieldNames{TEMP.combos(iCombo,1)})
            if ~any(strcmp(FUNCLOOP.fieldNames{TEMP.combos(iCombo,1)}{iCond},FUNCLOOP.fieldNames{TEMP.combos(iCombo,2)}))
                disp(['Condition in Predictor ' num2str(TEMP.combos(iCombo,1)) ' Not Found in Predictor ' num2str(TEMP.combos(iCombo,2)) '; ' FUNCLOOP.fieldNames{TEMP.combos(iCombo,1)}{iCond}])
                TEMP.error = 1;
            end
        end
        if FUNCLOOP.conditionIndices{TEMP.combos(iCombo,1)} ~= FUNCLOOP.conditionIndices{TEMP.combos(iCombo,2)}
            disp(['Conditions Order in Predictor ' num2str(TEMP.combos(iCombo,1)) ' Does not Match Predictor ' num2str(TEMP.combos(iCombo,2))])
            disp('Please Reorder!')
            TEMP.error = 1;
        end
    end
    if TEMP.error
        return
    end
end
FUNCLOOP.fieldNames_Master = FUNCLOOP.fieldNames{1};
FUNCLOOP.conditionIndices_Master = FUNCLOOP.conditionIndices{1};

% ======================================================================= %
% Standardize the data (if applicable).
% ======================================================================= %

if varInput.StandardizeData
    for iPredictor = 1:length(behaviouralData)
        TEMP = [];
        TEMP.currentData = behaviouralData{iPredictor};
        TEMP.originalSize = size(TEMP.currentData);
        TEMP.newData = reshape(table2array(TEMP.currentData),TEMP.originalSize(1)*TEMP.originalSize(2),1);
        TEMP.zScore = zscore(TEMP.newData);
        TEMP.newData2 = reshape(TEMP.zScore,TEMP.originalSize(1),TEMP.originalSize(2));
        TEMP.newData2 = array2table(TEMP.newData2);
        TEMP.newData2.Properties.VariableNames = TEMP.currentData.Properties.VariableNames;
        behaviouralData{iPredictor} = TEMP.newData2;
    end
else
    if length(behaviouralData) > 1
        warning('Multiple regression detected and stanardization not requested. Either stanardize data beforehand, input StandardizeData parameter, or take caution with interpreting interaction terms!')
    end
end

% ======================================================================= %
% We Run a Loop for All Clusters Input.
% ======================================================================= %

clusterCount = 0; FUNCLOOP.clusterData = table();
for iCluster = clusters
    
    % ======================================================================= %
    % Loop Counters.
    % ======================================================================= %
    
    FUNCFORLOOP = [];
    
    clusterCount = clusterCount + 1;
    
    % ======================================================================= %
    % Main Variables for Loop.
    % ======================================================================= %
    
    % Merge components belonging to same subject.
    
    [FUNCFORLOOP.currentData,STUDY,ALLEEG] = mergeSubjectComponents(STUDY,ALLEEG,iCluster);
    
    % Full latency times.
    
    FUNCFORLOOP.erpTimesSync = STUDY.cluster(iCluster).erptimes;
    FUNCFORLOOP.erpTimes = 1:length(FUNCFORLOOP.erpTimesSync);
    
    % Create times to plot, both synced and not synced.
    
    if isempty(varInput.Latency)
        FUNCFORLOOP.erpTimes_ToPlotSync = FUNCFORLOOP.erpTimes;
    else
        FUNCFORLOOP.erpTimes_ToPlotSync = varInput.Latency;
    end
    
    % Extract nearest times to SYNC times for plotting.
    
    for iTime = 1:length(FUNCFORLOOP.erpTimes_ToPlotSync)
        FUNCFORLOOP.erpTimes_ToPlot(iTime) = nearest(FUNCFORLOOP.erpTimesSync,FUNCFORLOOP.erpTimes_ToPlotSync(iTime));
    end
    
    % ======================================================================= %
    % Extract Cluster Data.
    % ======================================================================= %
    
    % Extract subjects present for current cluster.

    FUNCLOOP.clusterData.cluster{clusterCount,1} = ['Cls ' num2str(iCluster)];
    FUNCLOOP.clusterData.clusterSubjects(clusterCount,1) = STUDY_subjectClusters(STUDY,iCluster);
    
    % Create variable with data for each cluster and condition.
    
    FUNCFORLOOP.allConditionsData = table();
    for iCond = 1:length(FUNCLOOP.fieldNames_Master)
        FUNCFORLOOP.allConditionsData.(FUNCLOOP.fieldNames_Master{iCond}) = {FUNCFORLOOP.currentData{FUNCLOOP.conditionIndices_Master(iCond)}};
    end
    
    % ======================================================================= %
    % Average Across Variables if Required.
    % ======================================================================= %
    
    if isempty(varInput.AverageConditions)
        
        % Only extract the data for data for which we have behavioural data.
        
        FUNCLOOP.clusterData.behaviouralData{clusterCount,1} = {};
        for iPredictor = 1:length(behaviouralData)
            FUNCLOOP.clusterData.behaviouralData{clusterCount,1}{iPredictor} = behaviouralData{iPredictor}(FUNCLOOP.clusterData.clusterSubjects{clusterCount,1},:);
            FUNCLOOP.clusterData.behaviouralData{clusterCount,1}{iPredictor} = table2array(FUNCLOOP.clusterData.behaviouralData{clusterCount,1}{iPredictor});
        end
        FUNCLOOP.clusterData.behaviouralData{clusterCount,1} = cat(3,FUNCLOOP.clusterData.behaviouralData{clusterCount,1}{:});
        
        for iCond = 1:length(FUNCLOOP.fieldNames_Master)
            FUNCLOOP.clusterData.(FUNCLOOP.fieldNames_Master{iCond}){clusterCount,1} = FUNCFORLOOP.allConditionsData.(FUNCLOOP.fieldNames_Master{iCond}){1};
        end
        
        FUNCFORLOOP.conditionsToAnalyse = FUNCLOOP.fieldNames_Master;
        
    else
                
        FUNCLOOP.clusterData.behaviouralData{clusterCount,1} = [];
        
        for iAverage = 1:length(varInput.AverageConditions)
            
            FUNCFORLOOP2 = [];
            FUNCFORLOOP2.currentConds = varInput.AverageConditions{iAverage};
            FUNCFORLOOP2.newCondName = strjoin(FUNCFORLOOP2.currentConds,'_x_');
            for iCond = 1:length(FUNCFORLOOP2.currentConds)
                FUNCFORLOOP2.currentData_IC(:,:,iCond) = FUNCFORLOOP.allConditionsData.(FUNCFORLOOP2.currentConds{iCond}){1};
                for iPredictor = 1:length(behaviouralData)
                    FUNCFORLOOP2.currentData_Behav(:,iPredictor,iCond) = behaviouralData{iPredictor}.(FUNCFORLOOP2.currentConds{iCond})(FUNCLOOP.clusterData.clusterSubjects{clusterCount,1},:);
                end
            end
            
            FUNCFORLOOP2.currentData_IC = mean(FUNCFORLOOP2.currentData_IC,3);
            FUNCFORLOOP2.currentData_Behav = mean(FUNCFORLOOP2.currentData_Behav,3);
            
            for iPredictor = 1:length(behaviouralData)
                FUNCLOOP.clusterData.behaviouralData{clusterCount,1}(:,iAverage,iPredictor) = FUNCFORLOOP2.currentData_Behav(:,iPredictor);
            end
            
            try
                FUNCLOOP.clusterData.(FUNCFORLOOP2.newCondName){clusterCount,1} = FUNCFORLOOP2.currentData_IC;
            catch
                warning(['Invalid variable name (' FUNCFORLOOP2.newCondName ') - likely too long, using default name.']);
                FUNCFORLOOP2.newCondName = ['AveragedCondition_' nDigitString(iAverage,2)];
                FUNCLOOP.clusterData.(FUNCFORLOOP2.newCondName){clusterCount,1} = FUNCFORLOOP2.currentData_IC;
            end
            
            FUNCFORLOOP.conditionsToAnalyse{iAverage} = FUNCFORLOOP2.newCondName;
            
        end
        
    end
    
    % ======================================================================= %
    % Produce Linear Model (fitlm) Either for Averaged Latency, or for Each
    % Time Point.
    % ======================================================================= %
    
    FUNCFORLOOP.clusterR2 = table();
    
    if varInput.AverageOverLatency | varInput.ExtractCovariateData
        
        % Secondly, if we do want to average over the latency and produce
        % a single linear model.
        
        % Current time point to plot.
        
        FUNCFORLOOP.clusterR2.latency = {FUNCFORLOOP.erpTimes_ToPlot};
        FUNCFORLOOP.clusterR2.latencySync = {FUNCFORLOOP.erpTimes_ToPlotSync};
        
        % Extract the behavioural data and cluster activation for the
        % corresponding time point.
        
        FUNCFORLOOP.clusterR2.ICData = {table()};
        FUNCFORLOOP.clusterR2.BehavData = {table()};
        for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
            FUNCFORLOOP.averagePlot.currentData_IC(:,iCond) = squeeze(mean(FUNCLOOP.clusterData.(FUNCFORLOOP.conditionsToAnalyse{iCond}){clusterCount}(FUNCFORLOOP.clusterR2.latency{1},:),1));
            FUNCFORLOOP.averagePlot.currentData_Behav(:,iCond,:) = FUNCLOOP.clusterData.behaviouralData{clusterCount,1}(:,iCond,:);
            FUNCFORLOOP.clusterR2.ICData{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = FUNCFORLOOP.averagePlot.currentData_IC(:,iCond);
            FUNCFORLOOP.clusterR2.BehavData{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = squeeze(FUNCFORLOOP.averagePlot.currentData_Behav(:,iCond,:));
        end
        
        % Regression or correlation, depending on varargin input.
        
        if ~varInput.ExtractCovariateData
            
            if varInput.Regression
                FUNCFORLOOP.clusterR2.lm = {table()};
                FUNCFORLOOP.clusterR2.RSqAdj = {table()};
                FUNCFORLOOP.clusterR2.PVal = {table()};
                for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
                    
                    % Produce table that contains the predictors and response
                    % variables, aswell as the formula we will use for the
                    % model.
                    
                    STATS = [];
                    
                    STATS.statTable = table();
                    
                    if isempty(varInput.ResponseName)
                        STATS.formula = 'y~';
                    else
                        STATS.formula = [varInput.ResponseName '~'];
                    end
                    
                    if isempty(varInput.PredictorNames)
                        for iPredictor = 1:size(FUNCFORLOOP.averagePlot.currentData_Behav,3)
                            STATS.statTable.(['x' num2str(iPredictor)]) = squeeze(FUNCFORLOOP.averagePlot.currentData_Behav(:,iCond,iPredictor));
                            STATS.formula = [STATS.formula 'x' num2str(iPredictor) '+'];
                        end
                    else
                        for iPredictor = 1:size(FUNCFORLOOP.averagePlot.currentData_Behav,3)
                            STATS.statTable.(varInput.PredictorNames{iPredictor}) = squeeze(FUNCFORLOOP.averagePlot.currentData_Behav(:,iCond,iPredictor));
                            STATS.formula = [STATS.formula varInput.PredictorNames{iPredictor} '+'];
                        end
                    end
                    
                    STATS.formula(end) = [];
                    if size(FUNCFORLOOP.averagePlot.currentData_Behav,3) > 1
                        for iMulti = 2:size(FUNCFORLOOP.averagePlot.currentData_Behav,3)
                            STATS.combos = nchoosek(1:size(FUNCFORLOOP.averagePlot.currentData_Behav,3),iMulti);
                            for iCombo = 1:size(STATS.combos,1)
                                TEMP = {};
                                TEMP.count = 0;
                                for iIV = STATS.combos(iCombo,:)
                                    TEMP.count = TEMP.count + 1;
                                    if isempty(varInput.PredictorNames)
                                        TEMP.varsToJoin{TEMP.count} = ['x' num2str(iIV)];
                                    else
                                        TEMP.varsToJoin{TEMP.count} = varInput.PredictorNames{iIV};
                                    end
                                end
                                TEMP.varsToJoin = strjoin(TEMP.varsToJoin,':');
                                STATS.formula = [STATS.formula '+' TEMP.varsToJoin];
                            end
                        end
                    end
                    
                    if isempty(varInput.ResponseName)
                        STATS.statTable.y = FUNCFORLOOP.averagePlot.currentData_IC(:,iCond);
                    else
                        STATS.statTable.(varInput.ResponseName) = FUNCFORLOOP.averagePlot.currentData_IC(:,iCond);
                    end
                    
                    % Fit the model.
                    
                    STATS.lm = fitlm(STATS.statTable,STATS.formula);
                    
                    FUNCFORLOOP.clusterR2.lm{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = STATS.lm;
                    FUNCFORLOOP.clusterR2.RSqAdj{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = STATS.lm.Rsquared.Ordinary;
                    FUNCFORLOOP.clusterR2.PVal{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = STATS.lm.Coefficients.pValue(end);
                    
                    %                 [~,FUNCFORLOOP.clusterR2.(FUNCFORLOOP.conditionsToAnalyse{iCond})] = linearRegression(FUNCFORLOOP.averagePlot.currentData_IC(iCond,:),FUNCFORLOOP.averagePlot.currentData_Behav(iCond,:));
                end
                
                FUNCFORLOOP.clusterR2.formula = STATS.formula;
                
            else
                for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
                    FUNCFORLOOP2 = [];
                    FUNCFORLOOP2.corr = corrcoef(FUNCFORLOOP.averagePlot.currentData_Behav(iCond,:),FUNCFORLOOP.averagePlot.currentData_IC(iCond,:));
                    FUNCFORLOOP.clusterR2.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = FUNCFORLOOP2.corr(1,2);
                end
            end
            
        end
        
    else
        
        % First, if we do not want to average over the latency and produce
        % multple linear models.
        
        timeCount = 0;
        warning off
        
        % Loop for each time point.
        
        for iTime = 1:length(FUNCFORLOOP.erpTimes_ToPlot)
            
            
            timeCount = timeCount + 1;
            
            FUNCFORLOOP2 = [];
            
            % Current time point to plot.
            
            FUNCFORLOOP2.currentTime = FUNCFORLOOP.erpTimes_ToPlot(iTime);
            FUNCFORLOOP2.currentTimeSync = FUNCFORLOOP.erpTimes_ToPlotSync(iTime);
            
            FUNCFORLOOP.clusterR2.latency(timeCount,1) = FUNCFORLOOP2.currentTime;
            FUNCFORLOOP.clusterR2.latencySync(timeCount,1) = FUNCFORLOOP2.currentTimeSync;
            
            % Extract the behavioural data and cluster activation for the
            % corresponding time point.
            
            FUNCFORLOOP.clusterR2.ICData{timeCount,1} = table();
            FUNCFORLOOP.clusterR2.BehavData{timeCount,1} = table();
            for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
                FUNCFORLOOP2.currentData_IC(:,iCond) = FUNCLOOP.clusterData.(FUNCFORLOOP.conditionsToAnalyse{iCond}){clusterCount}(FUNCFORLOOP2.currentTime,:);
                FUNCFORLOOP2.currentData_Behav(:,iCond,:) = squeeze(FUNCLOOP.clusterData.behaviouralData{clusterCount,1}(:,iCond,:));
                FUNCFORLOOP.clusterR2.ICData{timeCount,1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = FUNCFORLOOP2.currentData_IC(:,iCond);
                FUNCFORLOOP.clusterR2.BehavData{timeCount,1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = squeeze(FUNCFORLOOP2.currentData_Behav(:,iCond,:));
            end
            
            % Regression or correlation, depending on varargin input.
            
            if varInput.Regression
                FUNCFORLOOP.clusterR2.lm(timeCount,1) = {table()};
                FUNCFORLOOP.clusterR2.RSqAdj(timeCount,1) = {table()};
                FUNCFORLOOP.clusterR2.PVal(timeCount,1) = {table()};
                for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
                    
                    % Produce table that contains the predictors and response
                    % variables, aswell as the formula we will use for the
                    % model.
                    
                    STATS = [];
                    
                    STATS.statTable = table();
                    
                    if isempty(varInput.ResponseName)
                        STATS.formula = 'y~';
                    else
                        STATS.formula = [varInput.ResponseName '~'];
                    end
                    
                    if isempty(varInput.PredictorNames)
                        for iPredictor = 1:size(FUNCFORLOOP2.currentData_Behav,3)
                            STATS.statTable.(['x' num2str(iPredictor)]) = squeeze(FUNCFORLOOP2.currentData_Behav(:,iCond,iPredictor));
                            STATS.formula = [STATS.formula 'x' num2str(iPredictor) '+'];
                        end
                    else
                        for iPredictor = 1:size(FUNCFORLOOP2.currentData_Behav,3)
                            STATS.statTable.(varInput.PredictorNames{iPredictor}) = squeeze(FUNCFORLOOP2.currentData_Behav(:,iCond,iPredictor));
                            STATS.formula = [STATS.formula varInput.PredictorNames{iPredictor} '+'];
                        end
                    end
                    
                    STATS.formula(end) = [];
                    if size(FUNCFORLOOP2.currentData_Behav,3) > 1
                        for iMulti = 2:size(FUNCFORLOOP2.currentData_Behav,3)
                            STATS.combos = nchoosek(1:size(FUNCFORLOOP2.currentData_Behav,3),iMulti);
                            for iCombo = 1:size(STATS.combos,1)
                                TEMP = {};
                                TEMP.count = 0;
                                for iIV = STATS.combos(iCombo,:)
                                    TEMP.count = TEMP.count + 1;
                                    if isempty(varInput.PredictorNames)
                                        TEMP.varsToJoin{TEMP.count} = ['x' num2str(iIV)];
                                    else
                                        TEMP.varsToJoin{TEMP.count} = varInput.PredictorNames{iIV};
                                    end
                                end
                                TEMP.varsToJoin = strjoin(TEMP.varsToJoin,':');
                                STATS.formula = [STATS.formula '+' TEMP.varsToJoin];
                            end
                        end
                    end
                    
                    if isempty(varInput.ResponseName)
                        STATS.statTable.y = FUNCFORLOOP2.currentData_IC(:,iCond);
                    else
                        STATS.statTable.(varInput.ResponseName) = FUNCFORLOOP2.currentData_IC(:,iCond);
                    end
                    
                    % Fit the model.
                    
                    STATS.lm = fitlm(STATS.statTable,STATS.formula);
                    
                    FUNCFORLOOP.clusterR2.lm{timeCount,1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = STATS.lm;
                    FUNCFORLOOP.clusterR2.RSqAdj{timeCount,1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = STATS.lm.Rsquared.Ordinary;
                    FUNCFORLOOP.clusterR2.PVal{timeCount,1}.(FUNCFORLOOP.conditionsToAnalyse{iCond}) = STATS.lm.Coefficients.pValue(end);
                    
                    %                     FUNCFORLOOP.clusterR2.([FUNCFORLOOP.conditionsToAnalyse{iCond} '_RSq_Adj'])(timeCount,1) = STATS.lm.Rsquared.Adjusted;
                    %                     FUNCFORLOOP.clusterR2.([FUNCFORLOOP.conditionsToAnalyse{iCond} '_PVal'])(timeCount,1) = STATS.lm.Coefficients.pValue(end);
                    
                end
                
                FUNCFORLOOP.clusterR2.formula{timeCount,1} = STATS.formula;
                
            else
                for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
                    FUNCFORLOOP3 = [];
                    FUNCFORLOOP3.corr = corrcoef(FUNCFORLOOP2.currentData_Behav(iCond,:),FUNCFORLOOP2.currentData_IC(iCond,:));
                    FUNCFORLOOP.clusterR2.(FUNCFORLOOP.conditionsToAnalyse{iCond})(timeCount,1) = FUNCFORLOOP3.corr(1,2);
                end
            end
            
            disp(['Regressing Time Point ' num2str(iTime) '/' num2str(length(FUNCFORLOOP.erpTimes_ToPlot))])
            
        end
        warning on
        
    end
    
    % ======================================================================= %
    % If Only Returning Covariate Data, We Can Actually Just do a Little
    % More Configuration and Return the Script.
    % ======================================================================= %
    
    if varInput.ExtractCovariateData
        
        covarData = table();
        icFieldNames = FUNCFORLOOP.clusterR2.ICData{1}.Properties.VariableNames;
        behavFieldNames = FUNCFORLOOP.clusterR2.BehavData{1}.Properties.VariableNames;
        
        for iField = 1:length(icFieldNames)
            covarData.([icFieldNames{iField} '_IC']) = FUNCFORLOOP.clusterR2.ICData{1}.(icFieldNames{iField});
            covarData.([behavFieldNames{iField} '_' varInput.PredictorNames{1}]) = FUNCFORLOOP.clusterR2.BehavData{1}.(behavFieldNames{iField});
            covarData.([icFieldNames{iField} '_IC']) = round(covarData.([icFieldNames{iField} '_IC']),3);
            covarData.([behavFieldNames{iField} '_' varInput.PredictorNames{1}]) = round(covarData.([behavFieldNames{iField} '_' varInput.PredictorNames{1}]),3);
        end
                
        if ~isempty(varInput.ExtractCovariateData_Save)
            
            if isempty(varInput.PredictorNames)
                saveDir = varInput.ExtractCovariateData_Save;
                saveFile = ['C' nDigitString(iCluster,2) '_' num2str(varInput.Latency(1)) '_' num2str(varInput.Latency(end)) '.dat'];
            else
                saveDir = [varInput.ExtractCovariateData_Save varInput.PredictorNames{1} '\'];
                saveFile = ['C' nDigitString(iCluster,2) '_' varInput.PredictorNames{1} '_' num2str(varInput.Latency(1)) '_' num2str(varInput.Latency(end))];
            end
            
            if ~exist(saveDir); mkdir(saveDir); end
            
            dlmwrite([saveDir saveFile '.txt'],table2array(covarData),'delimiter','\t');
            writetable(covarData,[saveDir saveFile ' (TABLE).csv']);
            
            OUTPUT = covarData;
            
            return
            
        end
    
    end
    
    % ======================================================================= %
    %
    % ======================================================================= %
    
    FigH1 = figure('Position', get(0, 'Screensize')); hold on;
    
    if varInput.AverageOverLatency
        
        subplot(2,1,1); hold on;
        
        PLOT = [];
        for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
            PLOT.plotData(iCond) = FUNCFORLOOP.clusterR2.RSqAdj{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond});
            FUNCFORLOOP.legendNames{iCond} = strrep(FUNCFORLOOP.conditionsToAnalyse{iCond},'_',' ');
            FUNCFORLOOP.legendNames{iCond} = strrep(FUNCFORLOOP.legendNames{iCond},' x ',' x  \newline');
        end
        bar(PLOT.plotData);
        set(gca,'XTick',1:length(FUNCFORLOOP.conditionsToAnalyse))
        set(gca,'XTickLabels', FUNCFORLOOP.legendNames);
        xtickangle(45)
        if varInput.Regression
            ylabel('R^2')
            title(['R^2; ' FUNCLOOP.clusterData.cluster{clusterCount,1} '; ' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(1)) '-' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(end)) ' ms; ' strrep(strrep(strrep(FUNCFORLOOP.clusterR2.formula,'_',' '),'~',' ~ '),'+',' + ')])
        else
            ylabel('Correlation Coeficient')
            title(['Correlation Coeficient; ' FUNCLOOP.clusterData.cluster{clusterCount,1} '; ' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(1)) '-' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(end)) ' ms'])
        end
        set(gca,'FontSize',12)
        box off
        
        subplot(2,1,2); hold on;
        
        STATS = [];
        for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
            
            STATS.pVals(iCond) = FUNCFORLOOP.clusterR2.PVal{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond});
            if varInput.FDR
                disp('Cannot FDR when averaging over latency... Continuing without FDR.')
            end
            FUNCLOOP.legendNames{iCond} = strrep(FUNCFORLOOP.conditionsToAnalyse{iCond},'_',' ');
            
            STATS.sigPlot = bar(iCond,STATS.pVals(iCond));
            
            if STATS.pVals(iCond) <= 0.05
                STATS.sigPlot.FaceColor = [0 1 0];
            else
                STATS.sigPlot.FaceColor = [1 0 0];
            end
            
        end
        
        STATS.legend(1) = plot(NaN,NaN,'red');
        STATS.legend(2) = plot(NaN,NaN,'green');
        legend(STATS.legend,{'Non-Sig (P > 0.05)' 'Sig (P <= 0.05)'})
        
        set(gca,'XTick',1:length(FUNCFORLOOP.conditionsToAnalyse))
        set(gca,'XTickLabels', FUNCFORLOOP.legendNames);
        xtickangle(45)
        ylabel('P-Value')
        title(['P-Value; ' FUNCLOOP.clusterData.cluster{clusterCount,1} '; ' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(1)) '-' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(end)) ' ms'])
        set(gca,'FontSize',12)
        box off
        
        % ======================================================================= %
        % Save Loop.
        % ======================================================================= %
        
        saveInfo = {};
        if varInput.PlotSave
            for iPredictor = 1:length(behaviouralData)
                if isempty(varInput.PredictorNames)
                    saveInfo{iPredictor} = ['x' num2str(iPredictor)];
                else
                    saveInfo{iPredictor} = varInput.PredictorNames{iPredictor};
                end
            end
            saveInfo = strjoin(saveInfo,'-');
            saveInfo = [saveInfo ' (' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(1)) '-' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(end)) ')'];
            if varInput.AverageOverLatency
                saveInfo = [saveInfo '; Averaged Lat'];
            end
            if ~isempty(varInput.AverageConditions)
                saveInfo = [saveInfo '; Averaged Cond'];
            end
            if varInput.FDR
                saveInfo = [saveInfo '; FDR'];
            end
            newSaveDir = [varInput.PlotSave 'C' num2str(iCluster) '\'];
            if ~exist(newSaveDir); mkdir(newSaveDir); end
            saveas(gcf,[newSaveDir saveInfo '; PVals.bmp']);
        end
        
        % ======================================================================= %
        
        FigH1 = figure('Position', get(0, 'Screensize')); hold on;
        
        if size(FUNCLOOP.clusterData.behaviouralData{1},3) == 1
            
            FIGHANDLES = []; hold on;
            for iCond = 1:size(FUNCLOOP.clusterData.behaviouralData{1},2)
                PLOT = [];
                PLOT.X = FUNCFORLOOP.clusterR2.BehavData{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond});
                PLOT.Y = FUNCFORLOOP.clusterR2.ICData{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond});
                PLOT.Z = zeros(length(PLOT.Y),1);
                FIGHANDLES.scatterPlot(iCond) = scatterLSLine3D([PLOT.X PLOT.Y PLOT.Z]);
                FIGHANDLES.legend(iCond) = plot(NaN,NaN,'o');
                FIGHANDLES.legend(iCond).Color = FIGHANDLES.scatterPlot(iCond).CData;
                FIGHANDLES.legendNames{iCond} = strrep(FUNCFORLOOP.conditionsToAnalyse{iCond},'_',' ');
            end

            view(2);
            
            legend(FIGHANDLES.legend,FIGHANDLES.legendNames);
            
            title(['Least Squares Line; ' strrep(strrep(strrep(FUNCFORLOOP.clusterR2.formula,'_',' '),'~',' ~ '),'+',' + ')])
            
            if isempty(varInput.PredictorNames)
                xlabel('x1')
            else
                xlabel(strrep(varInput.PredictorNames{1},'_',' '))
            end
            
            if isempty(varInput.ResponseName)
                ylabel('y')
            else
                ylabel(strrep(varInput.ResponseName,'_',' '))
            end
            
            set(gca,'FontSize',12)
            
        elseif size(FUNCLOOP.clusterData.behaviouralData{1},3) == 2
            
            for iCond = 1:size(FUNCLOOP.clusterData.behaviouralData{1},2)
                PLOT = [];
                PLOT.X = FUNCFORLOOP.clusterR2.BehavData{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond})(:,1);
                PLOT.Y = FUNCFORLOOP.clusterR2.BehavData{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond})(:,2);
                PLOT.Z = FUNCFORLOOP.clusterR2.ICData{1}.(FUNCFORLOOP.conditionsToAnalyse{iCond});
                FIGHANDLES.scatterPlot(iCond) = scatterLSLine3D([PLOT.X PLOT.Y PLOT.Z]);
                FIGHANDLES.legend(iCond) = plot(NaN,NaN,'o');
                FIGHANDLES.legend(iCond).Color = FIGHANDLES.scatterPlot(iCond).CData;
                FIGHANDLES.legendNames{iCond} = strrep(FUNCFORLOOP.conditionsToAnalyse{iCond},'_',' ');
            end
            
            legend(FIGHANDLES.legend,FIGHANDLES.legendNames);
            
            title(['Least Squares Line; ' strrep(strrep(strrep(FUNCFORLOOP.clusterR2.formula,'_',' '),'~',' ~ '),'+',' + ')])
            
            if isempty(varInput.PredictorNames)
                xlabel('x1')
                ylabel('x2')
            else
                xlabel(strrep(varInput.PredictorNames{1},'_',' '))
                ylabel(strrep(varInput.PredictorNames{2},'_',' '))
            end
            
            if isempty(varInput.ResponseName)
                zlabel('y')
            else
                zlabel(strrep(varInput.ResponseName,'_',' '))
            end
            
            set(gca,'FontSize',12)
            
        else
            disp('Cannot Plot More than 3 Vars; Skipping')
        end
        
        % ======================================================================= %
        % Save Loop.
        % ======================================================================= %
        
        saveInfo = {};
        if varInput.PlotSave
            for iPredictor = 1:length(behaviouralData)
                if isempty(varInput.PredictorNames)
                    saveInfo{iPredictor} = ['x' num2str(iPredictor)];
                else
                    saveInfo{iPredictor} = varInput.PredictorNames{iPredictor};
                end
            end
            saveInfo = strjoin(saveInfo,'-');
            saveInfo = [saveInfo ' (' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(1)) '-' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(end)) ')'];
            if varInput.AverageOverLatency
                saveInfo = [saveInfo '; Averaged Lat'];
            end
            if ~isempty(varInput.AverageConditions)
                saveInfo = [saveInfo '; Averaged Cond'];
            end
            if varInput.FDR
                saveInfo = [saveInfo '; FDR'];
            end
            newSaveDir = [varInput.PlotSave 'C' num2str(iCluster) '\'];
            if ~exist(newSaveDir); mkdir(newSaveDir); end
            saveas(gcf,[newSaveDir saveInfo '; Relationship.bmp']);
        end
        
        % ======================================================================= %
        
        % We will want to extract the regression output and print it to the
        % command window.
        
        disp(' ')
        disp('==============================================')
        disp('Regression Output')
        disp(['Cluster = ' num2str(iCluster) '; ' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(1)) '-' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(end)) ' ms'])
        disp('==============================================')
        disp(' ')
        for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
            MODEL = [];
            MODEL.currentCond = FUNCFORLOOP.conditionsToAnalyse{iCond};
            MODEL.lm = FUNCFORLOOP.clusterR2.lm{1}.(MODEL.currentCond);
            MODEL.RSq = MODEL.lm.Rsquared.Ordinary;
            MODEL.RSqAdj = MODEL.lm.Rsquared.Adjusted;
            MODEL.Beta = MODEL.lm.Coefficients.Estimate(end);
            MODEL.PVal = MODEL.lm.Coefficients.pValue(end);
            MODEL.anova.summary = anova(MODEL.lm,'summary');
            MODEL.anova.DF = MODEL.anova.summary({'Model' 'Total'},:).DF';
            MODEL.anova.F = MODEL.anova.summary('Model',:).F;
            MODEL.anova.P = MODEL.anova.summary('Model',:).pValue;
            MODEL.t = MODEL.lm.Coefficients.tStat(end);
            MODEL.PVal_tStat = MODEL.lm.Coefficients.pValue(end);
            disp(MODEL.currentCond)
            disp(['Beta = ' num2str(round(MODEL.Beta,4)) '; R^2 = ' num2str(round(MODEL.RSq,2)) ' (Adj = ' num2str(round(MODEL.RSqAdj,2)) ') P = ' num2str(round(MODEL.PVal,3))])
            disp(['ANOVA; F(' num2str(MODEL.anova.DF(1)) ',' num2str(MODEL.anova.DF(2)) ') = ' num2str(round(MODEL.anova.F,4)) ', P = ' num2str(round(MODEL.anova.P,4))])
            disp(['T-Test; t(' num2str(MODEL.anova.DF(2)) ') = ' num2str(round(MODEL.t,4)) ', P = ' num2str(round(MODEL.PVal_tStat,4))]);
            disp(' ')
        end
        
        % ======================================================================= %
        % Write Regression Output to File.
        % ======================================================================= %

        if varInput.PlotSave
            
            FID = fopen([newSaveDir saveInfo '; Regression Output.txt'],'w');
            
            fprintf(FID,'==============================================\n');
            fprintf(FID,'Regression Output\n');
            fprintf(FID,['Cluster = ' num2str(iCluster) '; ' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(1)) '-' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(end)) ' ms\n']);
            fprintf(FID,'==============================================\n\n');
            for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
                MODEL = [];
                MODEL.currentCond = FUNCFORLOOP.conditionsToAnalyse{iCond};
                MODEL.lm = FUNCFORLOOP.clusterR2.lm{1}.(MODEL.currentCond);
                MODEL.RSq = MODEL.lm.Rsquared.Ordinary;
                MODEL.RSqAdj = MODEL.lm.Rsquared.Adjusted;
                MODEL.Beta = MODEL.lm.Coefficients.Estimate(end);
                MODEL.PVal = MODEL.lm.Coefficients.pValue(end);
                MODEL.anova.summary = anova(MODEL.lm,'summary');
                MODEL.anova.DF = MODEL.anova.summary({'Model' 'Total'},:).DF';
                MODEL.anova.F = MODEL.anova.summary('Model',:).F;
                MODEL.anova.P = MODEL.anova.summary('Model',:).pValue;
                MODEL.t = MODEL.lm.Coefficients.tStat(end);
                MODEL.PVal_tStat = MODEL.lm.Coefficients.pValue(end);
                fprintf(FID,[MODEL.currentCond '\n']);
                fprintf(FID,['Beta = ' num2str(round(MODEL.Beta,4)) '; R^2 = ' num2str(round(MODEL.RSq,2)) ' (Adj = ' num2str(round(MODEL.RSqAdj,2)) ') P = ' num2str(round(MODEL.PVal,3)) '\n']);
                fprintf(FID,['ANOVA; F(' num2str(MODEL.anova.DF(1)) ',' num2str(MODEL.anova.DF(2)) ') = ' num2str(round(MODEL.anova.F,4)) ', P = ' num2str(round(MODEL.anova.P,4)) '\n']);
                fprintf(FID,['T-Test; t(' num2str(MODEL.anova.DF(2)) ') = ' num2str(round(MODEL.t,4)) ', P = ' num2str(round(MODEL.PVal_tStat,4)) '\n']);
                fprintf(FID,'\n');
            end
            
            fclose(FID);
            
        end
        
    else
        
        % Plot RSquare Adjusted.
        
        subplot(2,1,1); hold on;
        for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
            PLOT = [];
            PLOT.plotData = cat(1,FUNCFORLOOP.clusterR2.RSqAdj{:});
            PLOT.plotData = PLOT.plotData.(FUNCFORLOOP.conditionsToAnalyse{iCond});
            plot(FUNCFORLOOP.clusterR2.latencySync,PLOT.plotData,'LineWidth',2)
            FUNCLOOP.legendNames{iCond} = strrep(FUNCFORLOOP.conditionsToAnalyse{iCond},'_',' ');
        end
        legend(FUNCLOOP.legendNames)
        axis([FUNCFORLOOP.clusterR2.latencySync(1) FUNCFORLOOP.clusterR2.latencySync(end) ylim])
        xlabel('ms')
        if varInput.Regression
            ylabel('R^2')
            title(['R^2; ' FUNCLOOP.clusterData.cluster{clusterCount,1} '; ' strrep(strrep(strrep(FUNCFORLOOP.clusterR2.formula{1},'_',' '),'~',' ~ '),'+',' + ')])
        else
            ylabel('Correlation Coeficient')
            title(['Correlation Over Cluster Time Course; ' FUNCLOOP.clusterData.cluster{clusterCount,1}])
        end
        set(gca,'FontSize',12)
        box off
        
        % Carry out FDR correction, if required.
        
        STATS = [];
        STATS.pVals = cat(1,FUNCFORLOOP.clusterR2.PVal{:});
        STATS.pVals_Array = table2array(STATS.pVals);
        STATS.pVals_New = reshape(STATS.pVals_Array,size(STATS.pVals_Array,1)*size(STATS.pVals_Array,2),1);
        if varInput.FDR
            STATS.pVals_New = mafdr(STATS.pVals_New,'LAMBDA',0.15);
            %             STATS.pVals_New = mafdr(STATS.pVals_New,'BHFDR','true');
            %             STATS.pVals_New = bonf_holm(STATS.pVals_New);
            %             [~,~,~,STATS.pVals_New] = fdr_bh(STATS.pVals_Array);
            %             STATS.pVals_New = fdr0(STATS.pVals_New,0.05);
        end
        STATS.pVals_Corrected = reshape(STATS.pVals_New,size(STATS.pVals_Array,1),size(STATS.pVals_Array,2));
        STATS.pVals_Corrected = array2table(STATS.pVals_Corrected);
        STATS.pVals_Corrected.Properties.VariableNames = STATS.pVals.Properties.VariableNames;
        
        % Plot P-Values.
        
        subplot(2,1,2); hold on;
        for iCond = 1:length(FUNCFORLOOP.conditionsToAnalyse)
            plot(FUNCFORLOOP.clusterR2.latencySync,STATS.pVals_Corrected.(FUNCFORLOOP.conditionsToAnalyse{iCond}),'LineWidth',2)
            FUNCLOOP.legendNames{iCond} = strrep(FUNCFORLOOP.conditionsToAnalyse{iCond},'_',' ');
        end
        legend(FUNCLOOP.legendNames)
        axis([FUNCFORLOOP.clusterR2.latencySync(1) FUNCFORLOOP.clusterR2.latencySync(end) 0 varInput.PValYAxis])
        xlabel('ms')
        ylabel('P-Value')
        title(['P-Value Over Cluster Time Course; ' FUNCLOOP.clusterData.cluster{clusterCount,1}])
        set(gca,'FontSize',12)
        box off
        
        % ======================================================================= %
        % Save Loop.
        % ======================================================================= %
        
        saveInfo = {};
        if varInput.PlotSave
            for iPredictor = 1:length(behaviouralData)
                if isempty(varInput.PredictorNames)
                    saveInfo{iPredictor} = ['x' num2str(iPredictor)];
                else
                    saveInfo{iPredictor} = varInput.PredictorNames{iPredictor};
                end
            end
            saveInfo = strjoin(saveInfo,'-');
            saveInfo = [saveInfo ' (' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(1)) '-' num2str(FUNCFORLOOP.erpTimes_ToPlotSync(end)) ')'];
            if varInput.AverageOverLatency
                saveInfo = [saveInfo '; Averaged Lat'];
            end
            if ~isempty(varInput.AverageConditions)
                saveInfo = [saveInfo '; Averaged Cond'];
            end
            if varInput.FDR
                saveInfo = [saveInfo '; FDR'];
            end
            newSaveDir = [varInput.PlotSave 'C' num2str(iCluster) '\'];
            if ~exist(newSaveDir); mkdir(newSaveDir); end
            saveas(gcf,[newSaveDir saveInfo '; Prediction Over Time.bmp']);
            saveas(gcf,[newSaveDir saveInfo '; Prediction Over Time.fig']);
        end
        
        % ======================================================================= %
        
    end
    
    FUNCLOOP.clusterData.OutputParams{clusterCount,1} = FUNCFORLOOP.clusterR2;
    
end

OUTPUT = FUNCLOOP.clusterData;








