% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 14/11/2018
%
% Current version = v1.0
%
% Will input a single event into a .evt file. The event must be in
% microseconds, for example, 1 second = 1,000,000. This is since .evt files
% default to microseconds.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% evtFile   -   Event file to input event.
% latency   -   Latency of event.
% condition -   Trigger number for event.
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
% inputMissingEvent(evtFile,32568000,12)
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% readEvt_6_1
% saeEvt_6_1
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 14/11/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function inputMissingEvent(evtFile,latency,condition)

E = readEvt_6_1(evtFile);

E_new = E;

E_new(end+1,:) = NaN;

E_new(end,1) = latency;
E_new(end,2) = 1;

if size(E_new,2) == 3
    E_new(end,3) = condition;
else
    DIN_Trigger = E_new(find(E_new(:,4) == condition),3);
    DIN_Trigger(isnan(DIN_Trigger),:) = [];
    DIN_Trigger = unique(DIN_Trigger);
    E_new(end,3) = DIN_Trigger
    E_new(end,4) = condition;
end

E_new = sortrows(E_new,1);

saveEvt_6_1(E_new,evtFile);

end