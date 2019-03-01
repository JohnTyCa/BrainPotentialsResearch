% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 15/10/2017
%
% Current version = v1.0
% 
% Will plot specified electrode numbers on a topographic map using the
% 'topoplot' function. 
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% electrodeNumbers  -   Numbers of the electrodes to plot on the scalp map.
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
% electrodeLocations    -   Electrode locations variable. Importing an
%                           electrode location file into EEGLab will give
%                           you the variable that you require. However, I
%                           put this as an optional input since the
%                           "rloc128.m" function produces the same variable
%                           for "egihydrocel_129" electrode locations file.
%                           (DEFAULT: rloc128)
% markerSize            -   Size of marker in the plot.
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
% plotElectrodes([1:10 55 56 78 125], ...
%   'electrodeLocations',EEG.chanlocs, ...
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
%
% ======================================================================= %

function plotElectrodes(electrodeNumbers,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'electrodeParam'), varInput.electrodeParam = {electrodeNumbers,'s','red',50}; end;
if ~isfield(varInput, 'electrodeLocations'), varInput.electrodeLocations = rloc128; end;
if ~isfield(varInput, 'markerSize'), varInput.markerSize = 10; end;

topoplot(zeros(129,1),varInput.electrodeLocations,'style','contour','emarker2',varInput.electrodeParam,'whitebk','on')

end