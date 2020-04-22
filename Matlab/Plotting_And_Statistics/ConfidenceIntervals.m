% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 15/04/2020
%
% Current version = v1.0
%
% Produces confidence intervals and SEM for NxM matrix, whereby N is the
% number of observations and M the number of conditions.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% Data  -   Matrix of data.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% CI    -   Confidence intervals to extract. (DEFAULT: 0.95)
% Force -   In the scenario whereby there are more subjects 
%
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% yCI   -   Confidence intervals.
% SEM   -   Standard mean error.
%
% ======================================================================= %
% Example
% ======================================================================= %
%
% Data = rand(24,6);
% CI = 0.95;
% [yCI,SEM] = ConfidenceIntervals(Data,CI);
%
% ======================================================================= %
% Dependencies.
% ======================================================================= %
%
% ======================================================================= %
% UPDATE HISTORY:
%
% 15/04/2020 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function [yCI,SEM] = ConfidenceIntervals(Data,CI,Force)

if nargin < 2
    CI = 0.95;
end

if nargin < 3
    Force = 0;
end

if CI > 1
    CI = CI/100;
end

if size(Data,2) > size(Data,1)
    
    if size(Data,1) == 1
        Data = Data';
    elseif ~Force
        warning(['Detected more conditions than observations - if this is correct, input "Force" parameter of 1. If incorrect, transpose so observations are rows.'])
        return
    end
end

CI_Int = [(1-CI)/2 1-((1-CI)/2)];

SEM = [std(Data)/sqrt(size(Data,1))]';
yCI = bsxfun(@times, SEM,tinv(CI_Int, size(Data,1)-1));

end

























