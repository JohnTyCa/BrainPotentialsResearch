% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 27/10/2018
%
% Current version = v1.0
%
% Create a variable with the same format of .evt file.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% timeStamps    -   Time of events.
% code          -   Code column (usually 1).
% triggers      -   Triggers corresponding to events.
% multiply      -   Whether to multiply the timestamps by 1,000,000 to
%                   return the values from seconds to microseconds that
%                   BESA produces.
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
% E     -   Event variable.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% E = createEvtFormat([1.523 1.525 1.823 1.825],1,[10 11 20 21],1);
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
% 27/10/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function E = createEvtFormat(timeStamps,code,triggers,multiply)

if length(timeStamps) ~= length(triggers)
    disp(' ')
    disp('Unequal Number of Events across Inputs')
    return
end

if length(timeStamps) ~= length(code) | length(triggers) ~= length(code) && length(code) > 1
    disp(' ')
    disp('Length of Code Must == Length of timeStamp & trigger (OR == 1)')
    return
end

if multiply == 1
    timeStamps = timeStamps * 1000000;
end

try
timeStamps = round(timeStamps,-3);
catch
f = 10.^-3;
timeStamps = round(f*timeStamps)/f;
end

E = zeros(length(timeStamps),3);

E(:,1) = timeStamps;
E(:,2) = code;
E(:,3) = triggers;

end