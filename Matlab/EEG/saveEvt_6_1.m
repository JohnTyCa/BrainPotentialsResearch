% ======================================================================= %
%
% Created by Andrej Stancak.
%
% First Created 05/12/2017
%
% Current version = v1.0
%
% Will save a matrix of values to a .evt file. Matrix must be in .evt
% format already.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% events    -   Contains a matrix matching the .evt format to be saved.
% saveLoc   -   The location where new event file is to be saved.
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
% saveEvt_6_1([123456000 1 22],'D:/saveDir/events1_new.evt');
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
% 05/12/2017 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function saveEvt_6_1(events,saveLoc)

[d n e] = fileparts(saveLoc);

if exist(d) == 0; mkdir(d); end;

if isempty(e)
    saveLoc = [d '\' n '.evt'];
end

fid  = fopen(saveLoc,'wt');
s = ['Tmu         	Code	TriNo	Comnt'];
s = sprintf('%s\n',s);
fprintf(fid,s);
for i=1:size(events,1)
    if events(i,4) >= 100
    s = [num2str((events(i,1)))     '\t1\t'  num2str(round(events(i,3))) '\tTrigger - D' nDigitString(events(i,4),3)];
    else
    s = [num2str((events(i,1)))     '\t1\t'  num2str(round(events(i,3))) '\tTrigger - DI' nDigitString(events(i,4),2)];
    end
    s = sprintf('%s\n',s);
    fprintf(fid,s);
end;

fclose(fid);

end