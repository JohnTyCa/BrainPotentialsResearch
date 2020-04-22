% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 04/06/2019
%
% Current version = v1.0
%
% Convert all CSV file in a folder to XLSX and save it in folder of the 
% CSV files. 
% 
% Note that this script is for a very specific purpose, but easily adapted
% for more general uses.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% directory     -   Folder containing CSV files.
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
% directory = 'D:\Data\CSV_Files\';
% 
% ConvertCSVtoXLSX(directory);
%
% ======================================================================= %
% Dependencies.
% ======================================================================= %
%
% ======================================================================= %
% UPDATE HISTORY:
%
% 04/06/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function ConvertCSVtoXLSX(directory)
AllCSV = dir([directory '*.csv'])
for iCSV = 1:length(AllCSV)
    CurrentCSV = [AllCSV(iCSV).folder '\' AllCSV(iCSV).name];
    [dir,name,ex] = fileparts(CurrentCSV);
    [~,~,raw] = xlsread(CurrentCSV);
    xlswrite([dir '/' name '.xlsx'],raw);
end