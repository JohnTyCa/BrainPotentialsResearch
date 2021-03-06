% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 23/02/2019
%
% Current version = v1.0
%
% Fix mouse position for set set amount of time.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% duration  -   Seconds to fix mouse for.
% x         -   X coordinate to fix.
% Y         -   Y coordinate to fix.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% fixMousePos(5,0,0)
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% cogent (Toolbox)
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 23/02/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function fixMousePos(duration,xPos,yPos)

startTime = cogstd('sGetTime',-1);
currentTime = cogstd('sGetTime',-1);
while currentTime < startTime + duration
    currentTime = cogstd('sGetTime',-1);
    cgmouse(xPos,yPos)
end

end