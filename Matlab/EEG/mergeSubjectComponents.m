% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 10/01/2019
%
% Current version = v1.0
%
% Clustered data can contain multiple components from the same subject.
% However, in order to do statistics, we need to merge the components from
% the same subject in a cluster. In line with the EEGLab manual, all
% components from the same subject will be summated to produce a single
% component for each cluster, although this technically isn't an IC
% anymore.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% STUDY     -   EEGLab STUDY data structure with clustered data.
% ALLEEG    -   EEGLab ALLEEG data structure.
% cluster   -   Cluster for which we want to merge components.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% data      -   Merged data for desired cluster.
% STUDY     -   EEGlab STUDY data structure.
% ALLEEG    -   EEGLab ALLEEG data structure.
%
% ======================================================================= %
% Example
% ======================================================================= %
%
% [data,STUDY,ALLEEG] = mergeSubjectComponents(STUDY,ALLEEG,3)
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
% 10/01/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function [ERPData,SpecData,STUDY,ALLEEG] = mergeSubjectComponents(STUDY,ALLEEG,cluster)

% ERP Merging.

plotERP = 0;
if isfield(STUDY.cluster,'erpdata')
    if isempty(STUDY.cluster(cluster).erpdata)
        plotERP = 1;
    end
else
    plotERP = 1;
end

if plotERP
    STUDY = std_erpplot(STUDY,ALLEEG,'clusters',cluster,'noplot','on');
end

erpData  = STUDY.cluster(cluster).erpdata;
erpTimes = STUDY.cluster(cluster).erptimes;
setInds  = STUDY.cluster(cluster).setinds;

for iCell = 1:length(setInds(:))
    uniqueSubj = unique(setInds{iCell});
    for iSubj = 1:length(uniqueSubj)
        subjInd    = setInds{iCell} == uniqueSubj(iSubj);
        erpData2{iCell}(:,iSubj) = sum( erpData{iCell}(:,subjInd), 2);
    end
end

ERPData = erpData2;

% Spec Merging.

plotSpec = 0;
if isfield(STUDY.cluster,'spec')
    if isempty(STUDY.cluster(cluster).erpdata)
        plotSpec = 1;
    end
else
    plotSpec = 1;
end

if plotSpec
    STUDY = std_specplot(STUDY,ALLEEG,'clusters',cluster,'noplot','on');
end

specData  = STUDY.cluster(cluster).specdata;
setInds  = STUDY.cluster(cluster).setinds;

for iCell = 1:length(setInds(:))
    uniqueSubj = unique(setInds{iCell});
    for iSubj = 1:length(uniqueSubj)
        subjInd = setInds{iCell} == uniqueSubj(iSubj);
        specData2{iCell}(:,iSubj) = sum(specData{iCell}(:,subjInd), 2);
    end
end

SpecData = specData2;

end