% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 10/01/2019
%
% Current version = v1.0
%
% Will take an array of N length and will extract clusters of values that
% overlap by a pre-defined amount.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% data      -   Data array.
% overlap   -   Allowed overlap to be included in cluster.
% minSize   -   Minimum number of data points in cluster.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% 
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% clusters  -   Clusters of data.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% data = reshape(magic(10),100,1) / 100
% clusters = findArrayClusters(data,0.1,1);
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
% 10/01/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function clusters = findArrayClusters(data,overlap,minSize)

clusterCount = 1;
latCount = 1;
clusters = [];
for iTime = 1:length(data)-1
    
    clusters{clusterCount}(latCount) = data(iTime);
    
    if data(iTime+1) <= data(iTime) + overlap
        latCount = latCount + 1;
    else
        latCount = 1;
        clusterCount = clusterCount + 1;
    end
    
end


if ~isempty(clusters)
    for iCluster = length(clusters):-1:1
        if length(clusters{iCluster}) < minSize
            clusters(iCluster) = [];
        end
    end
end

end