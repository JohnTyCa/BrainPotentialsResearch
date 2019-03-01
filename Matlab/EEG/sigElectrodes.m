% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 13/10/2018
%
% Current version = v1.0
%
% Given an array of P-Values corresponding to electrodes, this will plot
% the significant P-Values and increase the size of the marker based on the
% sigSizes input. 
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% E         -   Electrode locations file. If empty, this defaults to
%               rloc128.
% plotData  -   An Nx1 array (N = number of electrodes) of P values showing
%               significance at specific electrodes.
% sigSizes  -   P-Values indicating what P-Values will have different size
%               markers, e.g. [0.05 0.01 0.001].
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
% 
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% sigElectrodes(E,plotData,[0.05 0.01 0.001])
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
% 13/10/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function sigElectrodes(E,plotData,sigSizes)

if isempty(E)
    E = rloc128;
end

sigSizes = sort(sigSizes);

for iSig = 1:length(sigSizes)
    markerSize = abs(iSig - (length(sigSizes)+1));
    index{iSig} = find(plotData <= sigSizes(iSig));
    plotData(plotData <= sigSizes(iSig)) = markerSize;
end

index = cat(1,index{:});
allElectrode = 1:length(plotData);

allElectrode(find(ismember(allElectrode,index))) = [];

plotData(allElectrode) = 0;
topoplot(plotData,E,'style','blank','electrodes','on');

end
