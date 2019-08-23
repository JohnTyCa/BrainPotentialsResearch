% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 21/03/2019
%
% Current version = v1.0
%
% Back projectes IC clusters onto the scalp. There are two ways to do this,
% depending on how the data has been analysed will depend on what you are
% able to do:
%
%   1)  Automatic Back Projection - If you do not exclude dipoles based on
%   residual variance, then the resulting clusters will comprise all ICs
%   across all subjects. Hence, you can use the STUDY 'Remove Artifactual
%   Clusters' protocol to remove all the clusters, including the outlier
%   cluster, besides the cluster you are interested in from the channel ERP
%   data. This will leave you with scalp level data for the cluster.
%
%   2)  Manual Back Projection - If dipoles were removed due to residual
%   variance exclusion, then the resulting clusters will only be comprised
%   of the ICs that passed the residual variance threshold. Hence, even if
%   you removed all ICs from the scalp level data that comprised the
%   clusters, then you would still have scalp level data that included IC
%   data from the dipoles that did not pass the residual variance
%   threshold. Therefore, this script will make a note of the components
%   that are included in each cluster and load up the original set file,
%   make a copy, and remove all components that were not contributing to
%   each cluster. This will only do this for the subjects that contributed
%   ICs, since not all subjects contribute ICs to a cluster.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% STUDY     -   EEGLab STUDY structure.
% ALLEEG    -   EEGLab ALLEEG structure.
% clusters  -   Clusters to back-project.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% ResaveStudy                   -   Whether to resave STUDY in event of
%                                   AutomaticBackProjection. (DEFAULT: 1)
%
% ManualBackProjection          -   Whether to force ManualBackProjection.
%                                   (DEFAULT: 0)
%
% ManualBackProjection_Folder   -   Folder to save data regarding
%                                   ManualBackProjection. (DEFAULT: [])
%
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% STUDY                 -   EEGLab STUDY structure.
% 
% currentPlotDataSGA    -   Super grand average electrode data.
% 
% currentPlotDataGFP    -   Super grand average GFP.
% 
% CLS_DATA_ERP          -   All data for all conditions, subjects & 
%                           clusters.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% STUDY_BackProject(STUDY,ALLEEG,5,'ManualBackProjection_Folder','D:\BackProjection\');
%
% ======================================================================= %
% Dependencies.
% ======================================================================= %
%
% EEGLab (Toolbox)
% nDigitString
% STUDY_ExtractClusterICs
% vline
% numSubplots
% ERPScroll (GUI)
% eeg_gfp
% butterflyPlotFunction
%
% ======================================================================= %
% UPDATE HISTORY:
%
% 21/03/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function [STUDY,currentPlotDataSGA,currentPlotDataGFP,CLS_DATA_ERP] = STUDY_BackProject(STUDY,ALLEEG,clusters,varargin)

currentPlotDataSGA = [];
currentPlotDataGFP = [];
CLS_DATA_ERP = [];

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'ResaveStudy'), varInput.ResaveStudy = 1; end
if ~isfield(varInput, 'ManualBackProjection'), varInput.ManualBackProjection = 0; end
if ~isfield(varInput, 'ManualBackProjection_Folder'), varInput.ManualBackProjection_Folder = []; end

% ======================================================================= %
% Logic Checks.
% ======================================================================= %

% Check as to whether components were removed due to residual variance. If
% so, manual back projection is required.

nComponentsTotal = length(ALLEEG(1).icaweights) * length(STUDY.subject);
nComponentsClustered = length(STUDY.cluster(1).comps);

if nComponentsTotal ~= nComponentsClustered
    varInput.ManualBackProjection = 1;
else
    varInput.ManualBackProjection = 0;
end

% If manual back projection, location to save set files is required.

if varInput.ManualBackProjection & isempty(varInput.ManualBackProjection_Folder)
    error('Manual back projection required folder to save new set files.')
end

% ======================================================================= %
% Main Loop.
% ======================================================================= %

if ~varInput.ManualBackProjection
    
    error('Fix logic before running automatic back projection. DO NOT RUN THIS SECTION IN CASE THINGS GET OVERWRITTEN!!');
    % ======================================================================= %
    % If no RV Removal.
    % ======================================================================= %
    
    clusterCount = 0;
    for iCluster = clusters
        
        clusterCount = clusterCount + 1;
        currentClusterStr = ['C' nDigitString(iCluster,2)];
        currentDesignName = [currentClusterStr '_BP'];
        
        studyDesigns = {STUDY.design.name};
        studyDesignsIndex = find(strcmp(studyDesigns,currentDesignName));
        
        if isempty(studyDesignsIndex)
            
            STUDY = std_makedesign(STUDY, ALLEEG, size(STUDY.design,2)+1, 'variable1','condition','variable2','','name',currentDesignName,'pairing1','on','pairing2','on','delfiles','off','defaultdesign','off','values1',STUDY.condition,'values2',{''},'subjselect',STUDY.subject);
            if varInput.ResaveStudy
                [STUDY EEG] = pop_savestudy( STUDY, ALLEEG, 'savemode','resave');
            end
            
            studyDesignsIndex = size(STUDY.design,2)+1;
        else
            
            STUDY = std_selectdesign(STUDY, ALLEEG, studyDesignsIndex);
            if varInput.ResaveStudy
                [STUDY EEG] = pop_savestudy( STUDY, ALLEEG, 'savemode','resave');
            end
            
        end
        
        eeglab redraw
        
        % ======================================================================= %
        % Check if ERP Files Exist.
        % ======================================================================= %
        
        existError = 0;
        for iFile = 1:size(STUDY.datasetinfo,2)
            
            currentFolder = STUDY.datasetinfo(iFile).filepath;
            currentFile = [STUDY.datasetinfo(iFile).subject '_' STUDY.datasetinfo(iFile).condition];
            
            currentERPFile = [currentFolder '\design' num2str(studyDesignsIndex) '_' currentFile '.daterp'];
            
            if ~exist(currentERPFile)
                existError = 1;
            end
            
        end
        
        % ======================================================================= %
        % If Files not Found, Recreate Them.
        % ======================================================================= %
        
        error('Unfinished logic')
        
    end
    
else
    
    % ======================================================================= %
    % If Manually Back Projecting.
    % ======================================================================= %
    
    % Make backup of STUDY & ALLEEG before removing them, since we need to
    % load up set files.
    
    STUDY_BACKUP = STUDY;
    ALLEEG_BACKUP = ALLEEG;
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    
    % Main loop for each cluster.
    
    clusterCount = 0;
    for iCluster = clusters
        
        clusterCount = clusterCount + 1;
        
        % Cluster variables.
        
        currentClusterStr = ['C' nDigitString(iCluster,2)];
        currentClusterICs = STUDY_ExtractClusterICs(STUDY_BACKUP,iCluster);
        currentClusterSubjects = unique(currentClusterICs.(currentClusterStr).subject);
        
        % Save location for set files and matlab data.
        
        saveLoc_SetFiles = [varInput.ManualBackProjection_Folder '\' currentClusterStr '\SetFiles\'];
        saveLoc_BackProjectionData = [varInput.ManualBackProjection_Folder '\' currentClusterStr '\MatlabData\BackProjections\'];
        saveLoc_ICData = [varInput.ManualBackProjection_Folder '\' currentClusterStr '\MatlabData\ICData\'];
        
        if ~exist(saveLoc_SetFiles); mkdir(saveLoc_SetFiles); end
        if ~exist(saveLoc_BackProjectionData); mkdir(saveLoc_BackProjectionData); end
        if ~exist(saveLoc_ICData); mkdir(saveLoc_ICData); end
        
        % Loop through subjects and load up each set file.
        
        CLS_DATA_ERP.(currentClusterStr) = table();
        
        subCount = 0;
        for iSub = 1:length(currentClusterSubjects)
            
            subCount = subCount + 1;
            
            % Subject variables.
            
            currentSubject = currentClusterSubjects{iSub};
            currentSubjectComponents = currentClusterICs.(currentClusterStr)(find(strcmp(currentClusterICs.(currentClusterStr).subject,currentSubject)),:);
            currentSubjectSets = unique(currentSubjectComponents.setFileIndex);
            
            % Save folder for new set file.
            
            currentSubjectFolder = [saveLoc_SetFiles '\' currentSubject];
            if ~exist(currentSubjectFolder); mkdir(currentSubjectFolder); end
            
            % Loop through each set file.
            
            for iSet = currentSubjectSets'
                
                % Set file variables.
                
                currentSetFiles = currentSubjectComponents(find(currentSubjectComponents.setFileIndex == iSet),:);
                currentSetComponents = currentSetFiles.component;
                currentSetCondition = currentSetFiles.condition{1};
                currentSetFileToLoad = currentSetFiles.setFile{1};
                [currentSetDir,currentSetFile,currentSetEx] = fileparts(currentSetFileToLoad);
                
                currentSetSaveFile = [currentSetFile '_BP.set'];
                
                % If back projected set file already exists, load it
                % instead of creating it.
                
                if exist([currentSubjectFolder '\' currentSetSaveFile])
                    
                    EEG = pop_loadset('filename',currentSetSaveFile,'filepath',currentSubjectFolder);
                    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
                    
                else
                    
                    % Load up original set file.
                    
                    EEG = pop_loadset('filename',[currentSetFile currentSetEx],'filepath',currentSetDir);
                    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
                    
                    % Note which components to remove.
                    
                    componentsToRemove = 1:length(EEG.icaweights);
                    componentsToRemove(find(ismember(componentsToRemove,currentSetComponents))) = [];
                    
                    % Save copy of set file under different name.
                    
                    EEG = pop_saveset( EEG, 'filename',currentSetSaveFile,'filepath',currentSubjectFolder);
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                    
                    % Subtract components.
                    
                    EEG = pop_subcomp( EEG, componentsToRemove, 0);
                    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',currentSetSaveFile,'overwrite','on','gui','off');
                    
                    % Save the set file with subtracted components.
                    
                    EEG = pop_saveset( EEG, 'filename',currentSetSaveFile,'filepath',currentSubjectFolder);
                    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                    
                end
                
                % Store data.
                
                CLS_DATA_ERP.(currentClusterStr).(currentSetCondition){subCount,1} = mean(EEG.data,3);
                
                % Clear EEGLab.
                
                STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
                
            end
            
        end
        
        % Define row names.
        
        CLS_DATA_ERP.(currentClusterStr).Properties.RowNames = currentClusterSubjects;
        
        % Plot ERP for each subject (GFP).
        
        figure;
        nPlots = numSubplots(length(currentClusterSubjects));
        peakGFP = [];
        for iPlot = 1:size(CLS_DATA_ERP.(currentClusterStr),1)
            subplot(nPlots(1),nPlots(2),iPlot);
            currentPlotData = table2cell(CLS_DATA_ERP.(currentClusterStr)(iPlot,:));
            currentPlotData = cat(3,currentPlotData{:});
            currentPlotData = mean(currentPlotData,3);
            currentGFP = eeg_gfp(currentPlotData');
            plot(ALLEEG_BACKUP(1).times,currentGFP);
            vline(0,'black');
            title([currentClusterStr '; ' CLS_DATA_ERP.(currentClusterStr).Properties.RowNames{iPlot}]);
            ylabel('GFP')
            
            peakGFP(iPlot) = nearest(currentGFP,max(currentGFP));
            
        end
        
        % Plot ERP for each subject (Butterfly Plot).
        
        figure;
        nPlots = numSubplots(length(currentClusterSubjects));
        for iPlot = 1:size(CLS_DATA_ERP.(currentClusterStr),1)
            subplot(nPlots(1),nPlots(2),iPlot);
            currentPlotData = table2cell(CLS_DATA_ERP.(currentClusterStr)(iPlot,:));
            currentPlotData = cat(3,currentPlotData{:});
            currentPlotData = mean(currentPlotData,3);
            
            butterflyPlotFunction(currentPlotData,size(currentPlotData),min(ALLEEG_BACKUP(1).times)),
            
            vline(0,'black');
            title([currentClusterStr '; ' CLS_DATA_ERP.(currentClusterStr).Properties.RowNames{iPlot}]);
            ylabel('GFP')
        end
        
        % Plot Scalp Map for each subject at peak GFP.
        
        figure;
        nPlots = numSubplots(length(currentClusterSubjects));
        for iPlot = 1:size(CLS_DATA_ERP.(currentClusterStr),1)
            subplot(nPlots(1),nPlots(2),iPlot);
            currentPlotData = table2cell(CLS_DATA_ERP.(currentClusterStr)(iPlot,:));
            currentPlotData = cat(3,currentPlotData{:});
            currentPlotData = mean(currentPlotData,3);
            topoplot(currentPlotData(:,peakGFP(iPlot)),ALLEEG_BACKUP(1).chanlocs);
            title([currentClusterStr '; ' CLS_DATA_ERP.(currentClusterStr).Properties.RowNames{iPlot} '; ' num2str(ALLEEG_BACKUP(1).times(peakGFP(iPlot))) ' ms']);
        end
        
        % Plot super grand average scalp map at peak GFP.
        
        figure;
        
        for iPlot = 1:size(CLS_DATA_ERP.(currentClusterStr),1)
            currentPlotData = table2cell(CLS_DATA_ERP.(currentClusterStr)(iPlot,:));
            currentPlotData = cat(3,currentPlotData{:});
            currentPlotData = mean(currentPlotData,3);
            currentPlotDataSGA(:,:,iPlot) = currentPlotData;
        end
        currentPlotDataSGA = mean(currentPlotDataSGA,3);
        currentPlotDataGFP = eeg_gfp(currentPlotDataSGA');
        peakGFP = nearest(currentPlotDataGFP,max(currentPlotDataGFP));
        
        topoplot(currentPlotDataSGA(:,peakGFP),ALLEEG_BACKUP(1).chanlocs);
        title([currentClusterStr '; Super Grand Average; ' num2str(ALLEEG_BACKUP(1).times(peakGFP)) ' ms']);
        
        % GUI for scrolling through ERP.
        
        ERPScroll(currentPlotDataSGA,ALLEEG_BACKUP(1).chanlocs,'baseline', ALLEEG_BACKUP(1).times, 'title', [currentClusterStr ' BP']);
        
        % Save cluster data as .mat file.
        
        saveData = CLS_DATA_ERP.(currentClusterStr);
        save([saveLoc_BackProjectionData currentClusterStr '.mat'],'saveData');
        
    end
    
end





















