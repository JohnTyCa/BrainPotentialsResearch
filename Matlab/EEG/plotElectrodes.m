% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 15/10/2017
%
% Current version = v1.1
% 
% Will plot specified electrode numbers on a topographic map using the
% 'topoplot' function. 
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% electrodeNumbers  -   Numbers of the electrodes to plot on the scalp map.
% chanLocs          -   Channel locations variable.
% 
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% electrodeParam        -   Parameters that define the appearance of the
%                           electrode markers. This paramater takes the
%                           numbers of the electrodes (electrodeNumbers),
%                           the shape (e.g., s = square), the colour of the
%                           markers and the size.
%                           (DEFAULT: {electrodeNumbers,'s','red',50}).
% markerSize            -   Size of marker in the plot. (DEFAULT: 10)
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% plotElectrodes([1:10 55 56 78 125], ...
%   'electrodeParam',{[1:10 55 56 78 125],'s','blue',25})
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% EEGLab (Toolbox)
% rloc128
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 15/10/2017 (v1.0) -   V1.0 Created.
% 22/04/2020 (v1.1) -   Removed rloc128 functionality.
% 
% ======================================================================= %

function plotElectrodes(electrodeNumbers,chanLoc,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'electrodeParam'), varInput.electrodeParam = {electrodeNumbers,'s','red',50}; end
if ~isfield(varInput, 'markerSize'), varInput.markerSize = 10; end

topoplot(zeros(129,1),chanLoc,'style','contour','emarker2',varInput.electrodeParam,'whitebk','on')

end