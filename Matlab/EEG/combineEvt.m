% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 24/10/2019
%
% Current version = v1.0
%
% Will combine at least two event files into a single .evt file. Event
% files must be .evt format exported from BESA, or at least in the same
% format.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% saveLoc   -   Save file for combined event file.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% Will take any number of input arguments listing filenames of event files
% that you wish to combine.
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
% combineEvt('combinedEvt.evt','evt1.evt','evt2.evt')
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% readEvt_6_1
% saveEvt_6_1
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 24/10/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function combineEvt(saveLoc,varargin)

if length(varargin) < 2
    disp('At least 2 event files required')
    return
end

for iEvt = 1:length(varargin)
    evt{iEvt} = readEvt_6_1(varargin{iEvt});
end

evtNew = cat(1,evt{:});

evtNew = sortrows(evtNew,1);

saveEvt_6_1(evtNew,saveLoc)

end