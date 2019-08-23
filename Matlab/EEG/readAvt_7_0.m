% ======================================================================= %
%
% Created by Andrej Stancak.
%
% First Created 27/03/2019
%
% Current version = v1.0
%
% Read .evt file exported from BESA. This works with BESA 7.0, since this
% BESA version produces a 4th column, but in contrast to 6.1, this column 
% includes sporadic comments.
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
% E = readAvt_6_1('D:/eventFile1.evt');
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
% 27/03/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function E = readEvt_7_0(Ename)

E = [];

fid = fopen(Ename);
n=0;
tline = fgetl(fid);
while 1
    
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    %disp(tline);
    eventLine=tline;
    eventLine_Deblank = regexprep(regexprep(regexprep(deblank(eventLine),' +',' '),'\t',' '),'  ',' ');
    n=n+1;
    
    eventLine_Split = strsplit(eventLine_Deblank,' ');
    
    E(n,1) = str2num(eventLine_Split{1});
    E(n,2) = str2num(eventLine_Split{2});
    E(n,3) = str2num(eventLine_Split{3});;
    
% % %     for iSection = 1:length(eventLine_Split)
% % %         eventLine_Split{iSection} = deblank(eventLine_Split{iSection});
% % %     end

    endLine = strjoin(eventLine_Split(4:end),' ');
    
    if contains(endLine,'DI')
        endLine = str2num(cell2mat(regexp(endLine,'\d*','Match')));
    else
        endLine = NaN;
    end
    
    E(n,4) = endLine;
    
end
fclose(fid);

disp([num2str(n) ' various triggers and patterns read']);

return;


