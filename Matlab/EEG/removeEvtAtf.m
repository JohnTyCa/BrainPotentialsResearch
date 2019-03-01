% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 05/12/2017
%
% Current version = v1.0
%
% Takes an .evt file containing a list of events and recodes event
% triggers as "999" if it overlaps with the latency of any of the artefacts
% given in a second event file. This overlap is dependent on the epoch
% which is given in the format [-100 399], i.e. milliseconds.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% evt       -   Event file containing events to be recoded.
% 
% evtAtf    -   Event file containing artefact latencies. Artefact onset and
%               offset must have codes of [21 22] respectively.
%
% epoch     -   The epoch of the event. If the artefact occurs within the epoch
%               of an event, it is excluded.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% saveLoc   -   Save location. If not given, the new .evt file will be put into
%               same location as "evt". 
%
% artiMult  -   Whether to multiply the original trigger by artiMult, or
%               whether to simply recode as 999. (DEFAULT: [])
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% finalSaveLoc  -   Final save location of event file.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% finalSaveLoc = removeEvtAtf('D:/eventFile1.evt','D:/eventFile1-export.evt',[-200 600])
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
% 01/01/2019 (v1.0) -   V1.0 Created.
% 13/02/2019 (v1.0) -   artiMult capability implemented.
%
% ======================================================================= %

function finalSaveLoc = removeEvtAtf(evt,evtAtf,epoch,varargin)

finalSaveLoc = [];

[d, n, e] = fileparts(evt);

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'saveLoc'), varInput.saveLoc = [d '\' n '_atfRemoved' e]; end;
if ~isfield(varInput, 'artiMult'), varInput.artiMult = []; end;

if exist(d) == 0; mkdir(d); end;

if ~isempty(varInput.artiMult) && ~isnumeric(varInput.artiMult)
    error('artiMult must be a number')
end

E = readEvt_6_1(evt);
EAtf = readEvt_6_1(evtAtf);

if length(E) == 0
    disp('No Events Read for Event File')
    return
end

if length(EAtf) == 0
    disp('No Events Read for Artifacts Event File')
    return
end

if abs(epoch(1)) < 1 || abs(epoch(end)) < 1, disp('Epoch Must be in ms'), return, end;

%Round artefact latencies up to milliseconds.
try
    EAtf(:,1) = round(EAtf(:,1),-3);
catch
    f = 10.^-3;
    EAtf(:,1) = round(f*EAtf(:,1))/f;
end

E(:,1) = E(:,1)/1000;
EAtf(:,1) = EAtf(:,1)/1000;

indexStart = EAtf(:,2) == 21;
indexEnd = EAtf(:,2) == 22;

artefactLatencies(:,1) = EAtf(indexStart,1);
artefactLatencies(:,2) = EAtf(indexEnd,1);

trashCount = 0; evtRemoval = []; ENew = E;
for iEvent = 1:size(E,1)
    
    evtLatency = [];
    evtLatency = epoch(1)+E(iEvent,1):epoch(end)+E(iEvent,1);
    
    for iArtefact = 1:size(artefactLatencies,1)
        
        atfLatency = [];
        atfLatency = artefactLatencies(iArtefact,1):artefactLatencies(iArtefact,2);
        
        overlap = intersect(evtLatency,atfLatency);
        
        if ~isempty(overlap)
            trashCount = trashCount+1;
            evtRemoval(trashCount) = iEvent;
        end
        
    end
    
end

if isempty(varInput.artiMult)
    ENew(evtRemoval,3) = 999;
else
    ENew(evtRemoval,3) = ENew(evtRemoval,3) * varInput.artiMult;
end

ENew(:,1) = ENew(:,1) * 1000;

disp(['Fixations Removed = ' num2str(trashCount)]);

saveEvt(ENew,varInput.saveLoc);

finalSaveLoc = varInput.saveLoc;

end