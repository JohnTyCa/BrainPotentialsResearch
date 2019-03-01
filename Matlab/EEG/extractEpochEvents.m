% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 26/01/2019
%
% Current version = v1.0
%
% When working with epoched data, the EEG.event structure contains multiple
% repeats of events, since it repeats events that occur repeatedly across
% multiple epochs.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% EEG   -   EEG data structure from EEGLab (Must be epoched).
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
% events    -   Indices of events that correspond to each epoch.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% events = extractEpochEvents(EEG)
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% EEGLab (Toolbox)
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 26/01/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function events = extractEpochEvents(EEG)

events = [];

for iEpoch = 1:size(EEG.epoch,2)
    
    FORLOOP = [];
    FORLOOP.currentLat = EEG.epoch(iEpoch).eventlatency;
    FORLOOP.currentEvents = EEG.epoch(iEpoch).event;
    
    FORLOOP.currentZeroEventIndex = find(cell2mat(FORLOOP.currentLat) == 0);
    FORLOOP.currentZeroEvent = FORLOOP.currentEvents(FORLOOP.currentZeroEventIndex);
    
    FUNCLOOP.events{iEpoch} = FORLOOP.currentZeroEvent;
    
end

events = cat(1,FUNCLOOP.events{:});

end