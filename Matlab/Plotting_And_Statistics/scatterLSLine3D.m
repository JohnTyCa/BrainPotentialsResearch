% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 11/02/2019
%
% Current version = v1.0
%
% Plot scatter plot in 3D with least-squares line.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% XYZ   -   [X Y Z] data to plot.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% Colour        -   Line and marker colour. (DEFAULT: [])
% MarkerSize    -   Marker size. (DEFAULT: 60)
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% figHandle     -   Figure handle.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% XYZ = rand(20,3,1);
% figHandle = scatterLSLine3D(XYZ,'MarkerSize',10);
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
% 11/02/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function figHandle = scatterLSLine3D(XYZ,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'Colour'), varInput.Colour = []; end
if ~isfield(varInput, 'MarkerSize'), varInput.MarkerSize = 60; end

figHandle = scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3),'SizeData',varInput.MarkerSize,'LineWidth',2.5);

hold all

[x0, a] = ls3dline(XYZ);

quiverLine1 = quiver3(x0(1),x0(2),x0(3),-a(1),-a(2),-a(3),3);
quiverLine2 = quiver3(x0(1),x0(2),x0(3),a(1),a(2),a(3),3);

quiverLine1.LineWidth = 3;
quiverLine2.LineWidth = 3;

if isempty(varInput.Colour)
    quiverLine1.Color = figHandle.CData;
    quiverLine2.Color = figHandle.CData;
else
    quiverLine1.Color = varInput.Colour;
    quiverLine2.Color = varInput.Colour;
end
