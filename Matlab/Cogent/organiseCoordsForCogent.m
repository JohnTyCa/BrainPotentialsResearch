% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 23/02/2019
%
% Current version = v1.0
%
% Organise coordinates for rectangle comprised of 4 points into clockwise
% order, with first row being top left point.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% x     -   X coordinates. Must only contain 4 coordinates.
% y     -   Y coordinates. Must only contain 4 coordinates.
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
% coordsNew     -   Contains 4x2 array of coordinates, but in the clockwise
%                   order that is needed for drawing in MATLAB. The first
%                   row corresponds to the top left of the rectangle.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% coordsNew = organiseCoordsForCogent([12 -12 12 -12],[5 -5 -5 5])
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% selfintersect
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 23/02/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function coordsNew = organiseCoordsForCogent(x,y)

returnFunc = 0;

if size(x,1) == 1
    x = x';
elseif size(x,2) > 1
    disp('X Coordinates must be 4x1')
    returnFunc = 1;
end

if size(y,1) == 1
    x = y';
elseif size(y,2) > 1
    disp('Y Coordinates must be 4x1')
    returnFunc = 1;
end

if returnFunc
    return
end

DISTANCES.TL = sqrt(sum(bsxfun(@minus, [x y], [min(x) max(y)]).^2,2));
DISTANCES.TL = find(DISTANCES.TL == min(DISTANCES.TL));

DISTANCES.TR = sqrt(sum(bsxfun(@minus, [x y], [max(x) max(y)]).^2,2));
DISTANCES.TR = find(DISTANCES.TR == min(DISTANCES.TR));

DISTANCES.BR = sqrt(sum(bsxfun(@minus, [x y], [max(x) min(y)]).^2,2));
DISTANCES.BR = find(DISTANCES.BR == min(DISTANCES.BR));

DISTANCES.BL = sqrt(sum(bsxfun(@minus, [x y], [min(x) min(y)]).^2,2));
DISTANCES.BL = find(DISTANCES.BL == min(DISTANCES.BL));

coordsNew(1,:) = [x(DISTANCES.TL) y(DISTANCES.TL)];
coordsNew(2,:) = [x(DISTANCES.TR) y(DISTANCES.TR)];
coordsNew(3,:) = [x(DISTANCES.BR) y(DISTANCES.BR)];
coordsNew(4,:) = [x(DISTANCES.BL) y(DISTANCES.BL)];

if ~isempty(selfintersect(coordsNew(:,1),coordsNew(:,2)))
    disp('Self Intersect Found')
    return
end

end