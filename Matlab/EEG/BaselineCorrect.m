% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 26/06/2019
%
% Current version = v1.0
%
% Baseline correct EEG data.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% Data          -   EEG epoch to be baseline corrected.
% nChan         -   Number of EEG channels, purely to orientate the data.
% TimeCourse    -   The timecourse of the epoch, e.g. -300:999.
% Baseline      -   Baseline period, e.g. -300:-200.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% NewData   -   Baseline corrected data.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% Data = rand(1000,129);
% nChan = 129;
% TimeCourse = -300:999;
% Baseline = -300:0;
% 
% NewData = BaselineCorrect(Data,nChan,TimeCourse,Baseline);
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 26/06/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function NewData = BaselineCorrect(Data,nChan,TimeCourse,Baseline)

if size(Data,1) ~= nChan
    Data = Data';
end

NewData = [];
for iChan = 1:nChan
    NewData(:,iChan) = permute(Data(iChan,:,1),[2 3 1]);
    DataToCorrect = NewData(:,iChan);
    DataToCorrect = bsxfun(@minus,DataToCorrect,mean(DataToCorrect((TimeCourse>=Baseline(1))& (TimeCourse<Baseline(end)),:),1));
    NewData(:,iChan) = DataToCorrect;
end

NewData = NewData';

end