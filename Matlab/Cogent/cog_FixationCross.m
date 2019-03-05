% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 27/02/2019
%
% Current version = v1.0
%
% Plot fixation cross on screen. This function may not require any
% parameters, as it will automatically detect the information required. It
% will use monitor size to automatically configure size, and default to the
% centre of the screen. If more than one monitor is detected, monintor
% parameter will need to be given.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
%
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% x         -   Origin of cross on x-axis. (DEFAULT: 0)
% y         -   Origin of cross on y-axis. (DEFAULT: 0)
% monitor   -   What monitor to display on. (DEFAULT: [])
% width     -   Width of cross. (DEFAULT: Monitor Width / 4)
% height    -   Height of cross. (DEFAULT: Monitor Width / 4)
% colour    -   Colour of cross (RGB). (DEFAULT: [1 1 1])
% lineWidth -   Width of line. (DEFAULT: 2)
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
% cog_FixationCross('monitor', 2)
%
% ======================================================================= %
% Dependencies.
% ======================================================================= %
%
% Cogent (Toolbox)
%
% ======================================================================= %
% UPDATE HISTORY:
%
% 27/02/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function cog_FixationCross(varargin)

screenRes = get(0,'MonitorPositions');

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'x'), varInput.x = 0; end
if ~isfield(varInput, 'y'), varInput.y = 0; end
if ~isfield(varInput, 'monitor'), varInput.monitor = []; end
if ~isfield(varInput, 'width')
    if isempty(varInput.monitor)
        if size(screenRes,1) > 1
            error('More than 1 monitor, cannot predict screen resolution for drawing fixation cross')
        else
            varInput.width = screenRes(1,4) / 4;
        end
    else
        if size(screenRes,1) < varInput.monitor
            error(['Desired Monitor (' num2str(varInput.monitor) ') Not Detected'])
        else
            varInput.width = screenRes(varInput.monitor,4) / 4;
        end
    end
end
if ~isfield(varInput, 'height')
    if isempty(varInput.monitor)
        if size(screenRes,1) > 1
            error('More than 1 monitor, cannot predict screen resolution for drawing fixation cross')
        else
            varInput.height = screenRes(1,4) / 4;
        end
    else
        if size(screenRes,1) < varInput.monitor
            error(['Desired Monitor (' num2str(varInput.monitor) ') Not Detected'])
        else
            varInput.height = screenRes(1,4) / 4;
        end
    end
end
if ~isfield(varInput, 'colour'), varInput.colour = [1 1 1]; end
if ~isfield(varInput, 'lineWidth'), varInput.lineWidth = 2; end

cgpencol(varInput.colour);
cgpenwid(varInput.lineWidth');
cgdraw(varInput.x-(varInput.width/2),varInput.y,varInput.x+(varInput.width/2),varInput.y);
cgdraw(varInput.x,varInput.y-(varInput.height/2),varInput.x,varInput.y+(varInput.height/2));



























