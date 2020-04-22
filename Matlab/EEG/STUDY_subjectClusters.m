% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 15/10/2018
%
% Current version = v1.0
%
% This will extract the subjects that belong to each cluster in a STUDY
% design. Data must have been clustered.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% STUDY     -   EEGLab STUDY data structure.
% clusters  -   Cluster(s) that you want to extract the subjects.
% 
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% subjectCluster    -   Subjects that belong to each cluster.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% subjectCluster = STUDY_subjectClusters(STUDY,[1 3 5 7 9]);
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
% 15/10/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function subjectCluster = STUDY_subjectClusters(STUDY,clusters)

parentSet = STUDY.cluster.sets;
uniqueSet = unique(parentSet(1,:));

clusterCount = 0;
for iCluster = clusters
    
    clusterCount = clusterCount  + 1;
    
    clusterSet = [];
    clusterSet = STUDY.cluster(iCluster).sets;
    
    uniqueClusterSet = unique(clusterSet(1,:));
    
    uniqueClusterSet = uniqueClusterSet / size(parentSet,1);
    
    subjectCluster{clusterCount} = uniqueClusterSet;
    
end

end