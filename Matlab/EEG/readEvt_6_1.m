% ======================================================================= %
%
% Created by Andrej Stancak.
%
% First Created 13/10/2018
%
% Current version = v1.0
%
% Read .evt file exported from BESA. This works with BESA 6.1, since this
% BESA version produces a 4th column (DIN).
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% Ename     -   Event file name.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% E     -   Matlab array of events.
%
% ======================================================================= %
% Example
% ======================================================================= %
%
% E = readEvt_6_1('D:/eventFile1.evt');
%
% ======================================================================= %
% Dependencies.
% ======================================================================= %
%
% ======================================================================= %
% UPDATE HISTORY:
%
% 13/10/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function E = readEvt_6_1(Ename)

E = [];

fid = fopen(Ename);
n=0;
tline = fgetl(fid);
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    %disp(tline);
    s=tline;
    n=n+1;
    [g b c d x1 x2 x3] = strread(deblank(s),'%f %d %d %s %s %s %s');
    E(n,1)=g(1,1);
    E(n,2)=b;
    E(n,3)=c;
    
    if ~isempty(x2)
        din = str2num(cell2mat(regexp(cell2mat(x2),'\d*','Match')));
    else
        din = NaN;
    end
    
    E(n,4) = din;
    
end
fclose(fid);

disp([num2str(n) ' various triggers and patterns read']);

return;


