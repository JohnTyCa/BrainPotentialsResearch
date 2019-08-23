% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 21/03/2019
%
% Current version = v1.0
%
% Extract the independent components that belong to each cluster.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% STUDY     -   EEGLab STUDY structure.
% clusters  -   Cluster(s) to extract independent components.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% CLS_DATA_IC   -   Clusters ICs.
%
% ======================================================================= %
% Example
% ======================================================================= %
%
% CLS_DATA_IC = STUDY_ExtractClusterICs(STUDY,[2 4 7]);
%
% ======================================================================= %
% Dependencies.
% ======================================================================= %
%
% EEGLab (Toolbox)
% nDigitString
%
% ======================================================================= %
% UPDATE HISTORY:
%
% 21/03/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function CLS_DATA_IC = STUDY_ExtractClusterICs(STUDY,clusters)

CLS_DATA_IC = struct();

for iCluster = clusters
    
    currentCluster = ['Cls ' num2str(iCluster)];
    currentClusterIndex = find(strcmp({STUDY.cluster.name},currentCluster));
    currentClusterData = STUDY.cluster(currentClusterIndex);
    
    clusterData = table();
    setCount = 0;
    warning off
    for iCond = 1:size(currentClusterData.sets,1)
        for iIC = 1:size(currentClusterData.sets,2)
            
            setCount = setCount + 1;
            
            currentSetIndex = currentClusterData.sets(iCond,iIC);
            currentSetIndex_Index = find([STUDY.datasetinfo.index] == currentSetIndex);
            currentSetSubject = STUDY.datasetinfo(currentSetIndex_Index).subject;
            currentComponent = currentClusterData.comps(iIC);
            currentSetFile = [STUDY.datasetinfo(currentSetIndex_Index).filepath '\' STUDY.datasetinfo(currentSetIndex_Index).filename];
            currentSetCond = STUDY.datasetinfo(currentSetIndex_Index).condition;
            
            clusterData.setFileIndex(setCount,1) = currentSetIndex;
            clusterData.subject{setCount,1} = currentSetSubject;
            clusterData.component(setCount,1) = currentComponent;
            clusterData.condition{setCount,1} = currentSetCond;
            clusterData.setFile{setCount,1} = currentSetFile;
            
        end
    end
    warning on
    
    CLS_DATA_IC.(['C' nDigitString(iCluster,2)]) = clusterData;
    
end
















