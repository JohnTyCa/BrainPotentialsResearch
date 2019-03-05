% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 07/11/2017
%
% Current version = v1.1
%
% This will expand a polygon by a given factor whilst maintaining the
% centre point.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% X         -   X Coordinates for the polygon to be expanded.
% Y         -   Y Coordinates for the polygon to be expanded.
% factor    -   The factor by which to expand the polygon (where 1 = same
%               size).
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
% Xexp  -   Expanded X Coordinates.
% Yexp  -   Expanded Y Coordinates.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% [Xexp Yexp] = expandPolygon([-1 1 1 -1],[1 1 -1 -1],2)
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% polygeom
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 07/11/2017 (v1.0) -   V1.0 Created.
% 24/01/2018 (v1.1) -   When comparing the centre point of the original and new
%                       polygons, it first rounds them up to 1 d.p. This is 
%                       because the centre points differ slightly when 
%                       irregular polygons are expanded, but the difference 
%                       is only slight.
% 
% ======================================================================= %

function [Xexp Yexp] = expandPolygon(X,Y,factor)

if factor <= 0
    error('Factor for expanding polygon must be >0')
end

[GEOMorig,~,~] = polygeom(X,Y);

Xexp = factor*(X - GEOMorig(2)) + GEOMorig(2);
Yexp = factor*(Y - GEOMorig(3)) + GEOMorig(3);

[GEOMexp,~,~] = polygeom(Xexp,Yexp);

if any(round(GEOMorig(2:3),1) ~= round(GEOMexp(2:3),1)) == 1
    error('Centre Point Offset in expandPolygon') 
end

