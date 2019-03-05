% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 01/01/2019
%
% Current version = v1.0
%
% This will return an index of overlapping polygons. For example,
% given a list of coordinates (CELL), will sequentially compare coordinates
% with one another and return all overlapping polygons. Requires Mapping
% Toolbox.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% X     -   Cell containing list of X coordinates.
% Y     -   Cell containing list of Y coordinates.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% drawPlot  -   Draw the polygons. (DEFAULT: [])
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% Overlap   -   Indices indicating the location of any two overlapping
%               polygons.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% overlap = polygonOverlapList({,Y,varargin)
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% polybool (Mapping Toolbox)
% polygeom
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 07/11/2017 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function overlap = polygonOverlapList(X,Y,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'drawPlot'), varInput.drawPlot = 0; end;

if ~iscell(X), error('polygonOverlapList; Input Must be Cell'), return, end;

overlap = [];

errorCount = 0;
for iPoly1 = 1:length(X)
    for iPoly2 = 1:length(X)
        if iPoly1 == iPoly2
            continue
        end
        if ~isempty(polybool('intersection', X(iPoly1), ...
                Y(iPoly1), ...
                X(iPoly2), ...
                Y(iPoly2)))
            errorCount = errorCount+1;
            overlap(errorCount,1) = iPoly1;
            overlap(errorCount,2) = iPoly2;
        end
    end
end

overlap = sort(overlap,2);
overlap = unique(overlap,'rows','first');

if  varInput.drawPlot == 1
    if errorCount>0
        figure
        for iPoly3 = 1:length(X)
            hold on
            [GEOM,~,~] = polygeom(X{iPoly3},Y{iPoly3});
            fill(X{iPoly3},Y{iPoly3},'green')
            text(GEOM(2),GEOM(3),num2str(iPoly3),'HorizontalAlignment','center')
        end
    end
end

end