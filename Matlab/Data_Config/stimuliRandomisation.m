% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 27/02/2019
%
% Current version = v1.0
%
% Will randomise stimuli. Can take a table, character or numeric array as
% input. You can also define a seed number if you want to control the
% random number generator to produce predictable random sequences, or
% shuffle the random number generator to get different sequences each time.
% 
% Some versions of MATLAB do not contain the "randperm" function that this
% script depends on, so it will only work on newer versions.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% stimList  -   An array (table, numeric, character).
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% seed  -   What seed to use for the random number generator. If you need
%           predictable sequences each time this script is used, then input
%           the same seed number. If different sequences are needed, use
%           the "shuffle" parameter. (DEFAULT: 'shuffle')
%
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% stimListRand  -   The randomised stimList.
% originalIndex -   The randomly generated array used for randomisation.
%
% ======================================================================= %
% Example
% ======================================================================= %
%
% [stimListRand,originalIndex] = stimuliRandomisation(1:100,'seed', 25)
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
% 27/02/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function [stimListRand,originalIndex] = stimuliRandomisation(stimList,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'seed'), varInput.seed = 'shuffle'; end;

if strcmp(varInput.seed,'shuffle')
    rng('shuffle')
    disp('Shuffling Random Number Generator...')
else
    if isnumeric(varInput.seed)
        rng(varInput.seed);
        warning(['Using Seed ' num2str(varInput.seed) ' for Random Number Generator... Using the same seed will produce predictable sequences; Use ''shuffle'' if you need different sequences'])
    else
        error('seed paramater must be ''shuffle'' or a non-negative integer')
    end
end

if istable(stimList)
    randVar = randperm(height(stimList));
    stimListRand = stimList(randVar,:);
elseif isnumeric(stimList) || iscell(stimList)
    randVar = randperm(length(stimList));
    stimListRand = stimList(randVar); 
else
    randVar = randperm(length(stimList));
    stimListRand = stimList(randVar,:); 
end

originalIndex = randVar;




















