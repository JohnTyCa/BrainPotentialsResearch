% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 01/01/2019
%
% Current version = v1.0
%
% Given an origin and size of the vertices of the cube, this will compute
% coordinates across the surface of the cube.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% centre            -   Cube origin.
% size              -   Cube vertices size.
% distBetweenPoints -   Distance between each point on surface.
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
% coordsSurface     -   Coordinates of points across cube surface.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% coordsSurface = createSurfaceCube([0 0],50,0.1);
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% boundingBox3d
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 01/01/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function coordsSurface = createSurfaceCube(centre,size,distBetweenPoints)

[x y z] = meshgrid(centre(1)-(size/2):distBetweenPoints:centre(1)+(size/2), ...
    centre(2)-(size/2):distBetweenPoints:centre(2)+(size/2), ...
    centre(3)-(size/2):distBetweenPoints:centre(3)+(size/2));

coordsOriginal = [x(:) y(:) z(:)];
coordsBoundary = boundingBox3d(coordsOriginal);

coordsSurface = coordsOriginal(   any(coordsOriginal(:,1) == coordsBoundary([1 2]),2) | ...
    any(coordsOriginal(:,2) == coordsBoundary([3 4]),2) | ...
    any(coordsOriginal(:,3) == coordsBoundary([5 6]),2),:);

end