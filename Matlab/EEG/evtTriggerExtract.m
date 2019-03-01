% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 04/12/2017
%
% Current version = v1.0
%
% This will extract a single trigger from a .EVT file. It will read
% the event file and extract all triggers defined by 'trigger', and then
% extract the trigger(s) from that list defined by 'index'.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% evtFile   -   BESA Event File (.evt) from which to extract event(s).
%
% trigger   -   List of doubles indicating ID number of trigger to extract 
%               from event file.
%
% index     -   When multiple events with same trigger ID are present, index
%               refers to what trigger should be extracted, e.g. 1 = first
%               trigger N, 'end' = last event in list of events, 'all' will
%               return all events matching the triggers.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% ExtractDin    -   Whether to extract the DIN line, rather than the
%                   exported trigger. Likely to cause a crash with BESA
%                   versions prior to 6.1. (DEFAULT:0)
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% TS    -   A list of timestamps for the events that match 'trigger' and
%           'index'.
%
% CODE  -   A list of codes for the events that match 'trigger' and
%           'index'.
%
% ID    -   A list of trigger IDs for the events that match 'trigger' and
%           'index'.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% [TS CODE ID] = evtTriggerExtract('event1.evt',10,1, 'ExtractDIN', 1);
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% readEvt_6_1
% read_longevt
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 04/12/2017 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function [TS CODE ID] = evtTriggerExtract(evtFile,trigger,index,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'ExtractDIN'), varInput.ExtractDIN = 0; end

try
    E = readEvt_6_1(evtFile);
catch
    E = read_longevt(evtFile);
end

evtIndex = [];
if varInput.ExtractDIN == 1
    for iTrigger = 1:length(trigger)
        evtIndex{iTrigger} = find(E(:,4) == trigger(iTrigger));
    end
else
    for iTrigger = 1:length(trigger)
        evtIndex{iTrigger} = find(E(:,3) == trigger(iTrigger));
    end
end

evtIndex = cat(1,evtIndex{:});
E_TOI = E(evtIndex,:);
E_TOI = sortrows(E_TOI,1);

if strcmp(index,'all')
    TS = E_TOI(:,1);
    CODE = E_TOI(:,2);
    if varInput.ExtractDIN == 1
        ID = E_TOI(:,4);
    else
        ID = E_TOI(:,3);
    end
else
    if strcmp(index,'end')
        TS = E_TOI(end,1);
        CODE = E_TOI(end,2);
        if varInput.ExtractDIN == 1
            ID = E_TOI(end,4);
        else
            ID = E_TOI(end,3);
        end
    else
        TS = E_TOI(index,1);
        CODE = E_TOI(index,2);
        if varInput.ExtractDIN == 1
            ID = E_TOI(index,4);
        else
            ID = E_TOI(index,3);
        end
    end
end

end