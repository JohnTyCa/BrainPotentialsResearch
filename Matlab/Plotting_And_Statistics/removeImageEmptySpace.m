% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 16/01/2019
%
% Current version = v1.0
%
% Takes a MATLAB variable containing an image in RGB form and removes empty
% space surrounding the image. This is quite computationally demanding, but
% it helps quite a lot when visualising images in figures.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% imageVar  -   RGB image (see 'imread').
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
% imageVarNew   -   RGB image with no empty space around edges.
% 
% ======================================================================= %
% Example
% ======================================================================= %
% 
% imageVar = imread('myImage.bmp');
% imageVarNew = removeImageEmptySpace(imageVar);
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
% 16/01/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function imageVarNew = removeImageEmptySpace(imageVar)

disp('Removing Image White Space...')

tempRem = zeros(size(imageVar,1),size(imageVar,2));
tempRemCriteria = imageVar(1,1,:);

for iVer = 1:size(imageVar,1)
    for iHor = 1:size(imageVar,2)
        TEMPLOOP = [];
        TEMPLOOP.currentRGB = imageVar(iVer,iHor,:);
        if all(TEMPLOOP.currentRGB == tempRemCriteria)
            tempRem(iVer,iHor) = 1;
        end
    end
end

imageVarNew = imageVar;

rowRem = zeros(size(imageVarNew,1),1);
colRem = zeros(size(imageVarNew,2),1);

% Top to bottom

finished = 0;
while finished == 0
    cancel = 0;
    for iTop = 1:size(imageVarNew,1)
        if cancel
            continue
        end
        if all(tempRem(iTop,:)) && cancel == 0
            rowRem(iTop,1) = 1;
        else
            finished = 1; cancel = 1;
        end
    end
end

% Bottom to top

finished = 0;
while finished == 0
    cancel = 0;
    for iBot = size(imageVarNew,1):-1:1
        if cancel
            continue
        end 
        if all(tempRem(iBot,:)) && cancel == 0
            rowRem(iBot,1) = 1;
        else
            finished = 1; cancel = 1;
        end
    end
end

% Left to right

finished = 0;
while finished == 0
    cancel = 0;
    for iLeft = 1:size(imageVarNew,2)
        if cancel
            continue
        end 
        if all(tempRem(:,iLeft)) && cancel == 0
            colRem(iLeft,1) = 1;
        else
            finished = 1; cancel = 1;
        end
    end
end

% Right to left

finished = 0;
while finished == 0
    cancel = 0;
    for iRight = size(imageVarNew,2):-1:1
        if cancel
            continue
        end 
        if all(tempRem(:,iRight)) && cancel == 0
            colRem(iRight,1) = 1;
        else
            finished = 1; cancel = 1;
        end
    end
end

% Remove rows

imageVarNew(find(rowRem),:,:) = [];

% Remove columns

imageVarNew(:,find(colRem),:) = [];

disp('... Done!')

end





