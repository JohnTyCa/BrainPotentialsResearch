% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 10/10/2018
%
% Current version = v1.1
%
% Given the start and end point of two gaze positions, this function
% calculates the degrees of visual angle between the two points, and the
% direction in terms of angle.
% 
% Optionally, you can input the size of the monitor and the resolution.
% This will mean you can accurately calculate the size of a single pixel.
% This will be assumed to be 0.0264583333 if these values are not given.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% start             -   Start point of gaze [x y]. Can be a list of points.
% finish            -   End point of gaze [x y]. Can be a list of points.
% viewingDistance   -   Distance from monitor.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% Plot          -   Plot the start and end point. (DEFAULT: 0)
% Resolution    -   Screen resolution. (DEFAULT: [])
% MonitorSize   -   Screen size. (DEFAULT: [])
%
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% amplitude     -   Visual degrees between two points.
% direction     -   Direction between two points.
%
% ======================================================================= %
% Example
% ======================================================================= %
%
% [amplitude, direction] = Pix2VisualAngle([0 0; 100 100],[50 50; 0 0],60,'Resolution',[1280 1024],'MonitorSize',[60 40]);
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
% 10/10/2018 (v1.0) -   V1.0 Created.
% 05/03/2019 (v1.1) -   Allowed monitor size and resolution to used to
%                       calculate pixel size.
% 
% ======================================================================= %

function [amplitude, direction] = Pix2VisualAngle(start,finish,viewingDistance,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'Plot'), varInput.plot = 0; end
if ~isfield(varInput, 'Resolution'), varInput.Resolution = []; end
if ~isfield(varInput, 'MonitorSize'), varInput.MonitorSize = []; end

if any(size(start) ~= size(finish))
    error('size(point1) must equal size(point2)')
end

LOOPFUNC = [];

if isempty(varInput.Resolution) | isempty(varInput.MonitorSize)
    disp('Assuming Pixel Size... Input MonitorSize & Resolution for More Accurate Calculation')
    LOOPFUNC.pixelSize = 0.0264583333;
else
    LOOPFUNC.pixelSize = varInput.MonitorSize(1) / varInput.Resolution(1);
    disp(['Calculating Pixel Size > Resolution Width = ' num2str(varInput.Resolution(1)) '; Monitor Width = ' num2str(varInput.MonitorSize(1))])
end

% Calculate amplitudes, in visual angle, between start and finish.

for iPoint = 1:size(start,1)
    LOOPFUNC.currentDistancePix(iPoint) = pdist([start(iPoint,:); finish(iPoint,:)],'euclidean');
    disp(['Detecting Distance Between Points ' num2str(iPoint) '/' num2str(size(start,1))]);
end

LOOPFUNC.currentDistanceCM = LOOPFUNC.currentDistancePix * LOOPFUNC.pixelSize;
LOOPFUNC.currentAmplitude = rad2deg(2 * (atan((LOOPFUNC.currentDistanceCM / 2) / viewingDistance)));

% Calculate direction between start and finish.

for iPoint = 1:size(start,1)
    
    LOOPFUNC2 = [];
    
    LOOPFUNC2.startOrigin = start(iPoint,:);
    LOOPFUNC2.startOrigin(1) = LOOPFUNC2.startOrigin(1) + abs(LOOPFUNC2.startOrigin(1)*0.1);
    
    LOOPFUNC2.v1=start(iPoint,:)-LOOPFUNC2.startOrigin;
    LOOPFUNC2.v2=start(iPoint,:)-finish(iPoint,:);
    
    LOOPFUNC2.radians = mod( atan2( det([LOOPFUNC2.v1;LOOPFUNC2.v2]) , dot(LOOPFUNC2.v1,LOOPFUNC2.v2) ) , 2*pi );
    
    LOOPFUNC2.currentAngle = rad2deg(LOOPFUNC2.radians);
    
    LOOPFUNC.currentAngle(iPoint) = LOOPFUNC2.currentAngle;
end

% Plot Data.
if varInput.plot == 1
    figure; hold on;
    for iPoint = 1:size(start,1)
        plot([start(iPoint,1),finish(iPoint,1)],[start(iPoint,2) finish(iPoint,2)],'-ored');
%         plot([start(iPoint,1),LOOPFUNC.startOrigin(1)],[start(iPoint,2) LOOPFUNC.startOrigin(2)],'-oblack');
    text(start(iPoint,:),start(iPoint,:),num2str(iPoint))
    end
end

amplitude = LOOPFUNC.currentAmplitude;
direction = LOOPFUNC.currentAngle;