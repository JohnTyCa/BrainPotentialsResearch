% ======================================================================= %
%
% Created by Andrej Stancak.
%
% First Created 23/10/2018
%
% Current version = v1.0
%
% Will load up the .sfp and .elp for egi_hydrocel_129 sensor net and
% produce a channel locations variable.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% 
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% elpFile   -   Location of .elp file.
% sfpFile   -   Location of .sfp file.
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% elpFile   -   Electrode locations variable.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% elpFile  = rloc128(   'elpFile','D:/egi_hydrocel_129.elp', ...
%                       'sfpFile','D:/egi_hydrocel_129.sfp');
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
% 23/10/2018 (v1.0) -   V1.0 Created.
% 23/10/2018 (v1.0) -   Optional input of .sfp and .elp file 
%                       (Modified by John Tyson-Carr).
%
% ======================================================================= %

function elpFile  = rloc128(varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'elpFile'), varInput.elpFile = 'c:\Users\nhojt\OneDrive - The University of Liverpool\DOCUMENTS\BESA\egi_newhydrocel_129.elp'; end
if ~isfield(varInput, 'sfpFile'), varInput.sfpFile = 'c:\Users\nhojt\OneDrive - The University of Liverpool\DOCUMENTS\BESA\egi_newhydrocel_129.sfp'; end

cfg = [];
cfg.NEL = 129;
elpFile = readlocs(varInput.elpFile);

SFP = {};
FID = fopen(varInput.sfpFile);
for iLine = 1:132
    tline = fgets(FID);
    splitStr = strsplit(deblank(tline),' ');
    if iLine >= 4
        SFP(iLine-3,:) = splitStr(2:end);
    end
end
fclose(FID)

for i=1:cfg.NEL
    elpFile(i).X=str2num(SFP{i,2});
    elpFile(i).Y=str2num(SFP{i,1});
    elpFile(i).Z=str2num(SFP{i,3});
    % eloc(i).sph_theta=ELP(i,1);
    % eloc(i).sph_phi=ELP(i,2);
end







