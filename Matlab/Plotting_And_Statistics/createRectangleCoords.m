% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 18/10/2018
%
% Current version = v1.0
%
% Given an origin, width and height, this will produce the coordinates for
% the resulting rectangle. 
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% origin    -   Rectangle origin.
% w         -   Rectangle width.
% h         -   Rectangle height.
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
% coords    -   Four points for rectangle corners.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% coords = createRectangleCoords([0 0],200,50);
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% selfintersect
% poly2cw
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 18/10/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function coords = createRectangleCoords(origin,w,h)

coords = [];
coordsOrig = [];

w = w/2;
h = h/2;

coordsOrig(1,:) = [origin(1)-w origin(2)+h];
coordsOrig(2,:) = [origin(1)+w origin(2)+h];
coordsOrig(3,:) = [origin(1)+w origin(2)-h];
coordsOrig(4,:) = [origin(1)-w origin(2)-h];

[coordsOrig(:,1) coordsOrig(:,2)] = poly2cw(coordsOrig(:,1),coordsOrig(:,2));

intersect = selfintersect(coordsOrig(:,1),coordsOrig(:,2));

if ~isempty(intersect); disp('Self Intersection Found'); return; end;

coords = coordsOrig;

end