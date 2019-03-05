% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 01/01/2019
%
% Current version = v1.0
%
% Plot a butterfly plot of EEG electrode data.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% data          -   Electrode x Time data.
% electrodeN    -   Number of electrodes. This is merely to ensure the
%                   correct dimensions are plotted.
% baseline      -   When baseline period starts, e.g. [-200].
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
% 
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% data1 = rand(64,800);
% data2 = -data1;
% data = vertcat(data1,data2);
% butterflyPlotFunction(data,128,-200)
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% hline
% vline
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 01/01/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function butterflyPlotFunction(data,electrodeN,baseline)

plotProp.lineColour = [0.3,0.3,0.3];
plotProp.lineWidth = 0.5;

if ndims(data) > 2
    disp(' ')
    disp('Too Many Dimensions on Data Variable')
    disp(' ')
    for iDim = 1:ndims(data)
        disp(['Dimension ' num2str(iDim) ': ' num2str(size(data,iDim))])
    end
    disp(' ')
    return
end

if size(data,1) ~= electrodeN
    data = data';
end

nDataPoints = size(data,2);
baseline = abs(baseline);

t = -baseline:nDataPoints-(baseline+1);

figure;

for iElectrode = 1:size(data,1)
    plot(t,data(iElectrode,:),'Color',plotProp.lineColour,'LineWidth',plotProp.lineWidth)
    hold on
end

box off

vLine = vline(0,'black');
vLine.LineWidth = 2;

hLine = hline(0,'black');
hLine.LineWidth = 2;

uistack(vLine,'top')
uistack(hLine,'top')

set(gca,'FontSize',16)

end