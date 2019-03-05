% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 27/02/2019
%
% Current version = v1.0
%
% Present image on Cogent window. You can give this function either:
%   
%   1) Image variable read into MATLAB, for example, using imread().
%   2) Character array indicating location of image file.
%   3) Cell array of charracter arrays indicating location of all image
%      files to be read in.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% sprite    -   Sprite ID(s) to draw images to.
% image     -   Image variable, character array for image file or cell
%               array of image file locations.
% 
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% resizeX   -   Width of image in pixels we wish to resize. (DEFAULT: [])
% resizeY   -   Height of image in pixels we wish to resize. (DEFAULT: [])
% xPos      -   X Position of image. (DEFAULT: 0)
% yPos      -   Y Position of image. (DEFAULT: 0)
% draw      -   Whether to flip screen. (DEFAULT: 0)
% loadBMP   -   Whether to use 'cgloadbmp' function instead of loading up
%               an array. (DEFAULT: 0)
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
% cog_ImageLoad(1,'D:\imageDir\image_001.bmp','resizeX',350,'xPos',200);
%
% ======================================================================= %
% Dependencies.
% ======================================================================= %
%
% Cogent (Toolbox)
%
% ======================================================================= %
% UPDATE HISTORY:
%
% 27/02/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function cog_ImageLoad(sprite,image,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'resizeX'), varInput.resizeX = []; end
if ~isfield(varInput, 'resizeY'), varInput.resizeY = []; end
if ~isfield(varInput, 'xPos'), varInput.xPos = 0; end
if ~isfield(varInput, 'yPos'), varInput.yPos = 0; end
if ~isfield(varInput, 'draw'), varInput.draw = 0; end
if ~isfield(varInput, 'loadBMP'), varInput.loadBMP = 0; end

% ======================================================================= %
% Script Error Checking.
% ======================================================================= %

if ~isempty(varInput.resizeX) & ~isempty(varInput.resizeY)
    error('Images can only be resized based on X or Y coordinate. Resizing both would distort the image')
end

if varInput.loadBMP & (~isempty(varInput.resizeX) | ~isempty(varInput.resizeY))
    warning('Using ''loadBMP'' and ''resizeX'' or ''resizeY'' results in pixelated images. You are best to use the ''cgloadarray'' command or resize the images outside of MATLAB. The ''cgloadarray'' command, which is the default for this script, is very computationally intensive if the width/height is too large (>400 pixels), so keep that in mind if you get delays.');
end

if iscell(image)
    if length(sprite) ~= length(image)
        error('Number of Sprites must correspond to number of images in cell array')
    end
end

% ======================================================================= %
% If Loading BMP, Check Image Input.
% ======================================================================= %

if varInput.loadBMP
    if ischar(image)
        [~,~,e] = fileparts(image);
        if ~strcmp(e,'.bmp')
            error('If using ''loadBMP'', image must be .bmp')
        end
    elseif iscell(image)
        fileError = 0;
        for iIm = 1:length(image)
            if ischar(image{iIm})
                [~,n,e] = fileparts(image{iIm});
                if ~strcmp(e,'.bmp')
                    fileError = 1;
                    disp(['If using ''loadBMP'', image must be .bmp: ' n])
                end
            else
                error('Cell array must contain character arrays')
            end
        end
        if fileError; return; end
    else
        error('If using ''loadBMP'', image must be cell array of file names or a character array.')
    end
end

% ======================================================================= %
% Load (and Resize) Images.
% ======================================================================= %

if isnumeric(image) | ischar(image)
    
    if ischar(image)
        imageRaw = imread(image);
    else
        imageRaw = image;
    end
    
    imageNew = imageRaw;
    
    imHeight = size(imageRaw,1);
    imWidth = size(imageRaw,2);
    
    % If using 'cgloadbmp' or 'cgloadarray'.
    
    if varInput.loadBMP
        
        if varInput.resizeX
            cgloadbmp(sprite,image,varInput.resizeX,0);
        elseif varInput.resizeX
            cgloadbmp(sprite,image,0,varInput.resizeY);
        else
            cgloadbmp(sprite,image);
        end
        
    else
        
        % Resize (if necessary).
        
        if ~isempty(varInput.resizeX)
            resizeRatio = varInput.resizeX / imWidth;
            imageNew = imresize(imageNew,resizeRatio);
        elseif ~isempty(varInput.resizeY)
            resizeRatio = varInput.resizeY / imHeight;
            imageNew = imresize(imageNew,resizeRatio);
        end
        
        imHeightNew = size(imageNew,1);
        imWidthNew = size(imageNew,2);
        
        % Convert image to long array.
        
        pixelCount = 0;
        for iH = 1:imHeightNew
            for iW = 1:imWidthNew
                pixelCount = pixelCount + 1;
                imageLong(pixelCount,:) = imageNew(iH,iW,:);
            end
        end
        imageLong = double(imageLong);
        
        % Convert colour mode from [255 255 255] to RGB.
        
        imageLong = imageLong / 255;
        
        % Load the image into sprite and draw it.
        
        cgloadarray(sprite,imWidthNew,imHeightNew,imageLong);
        
    end
    
    if varInput.draw
        cgdrawsprite(sprite,varInput.xPos,varInput.yPos);
    end
    
elseif iscell(image)
    
    for iIm = 1:length(image)
        
        if ischar(image{iIm})
            imageRaw = imread(image{iIm});
        else
            imageRaw = image{iIm};
        end
        
        imageNew = imageRaw;
        
        imHeight = size(imageRaw,1);
        imWidth = size(imageRaw,2);
        
        % If using 'cgloadbmp' or 'cgloadarray'.
        
        if varInput.loadBMP
            
            if varInput.resizeX
                cgloadbmp(sprite,image{iIm},varInput.resizeX,0);
            elseif varInput.resizeX
                cgloadbmp(sprite,image{iIm},0,varInput.resizeY);
            else
                cgloadbmp(sprite,image{iIm});
            end
            
        else
            
            % Resize (if necessary).
            
            if ~isempty(varInput.resizeX)
                resizeRatio = varInput.resizeX / imWidth;
                imageNew = imresize(imageNew,resizeRatio);
            elseif ~isempty(varInput.resizeY)
                resizeRatio = varInput.resizeY / imHeight;
                imageNew = imresize(imageNew,resizeRatio);
            end
            
            imHeightNew = size(imageNew,1);
            imWidthNew = size(imageNew,2);
            
            % Convert image to long array.
            
            pixelCount = 0;
            for iH = 1:imWidthNew
                for iW = 1:imHeightNew
                    pixelCount = pixelCount + 1;
                    imageLong(pixelCount,:) = imageNew(iH,iW,:);
                end
            end
            imageLong = double(imageLong);
            
            % Convert colour mode from [255 255 255] to RGB.
            
            imageLong = imageLong / 255;
            
            % Load the image into sprite and draw it.
            
            cgloadarray(sprite,imWidthNew,imHeightNew,imageLong);
            
        end
        
        if varInput.draw
            cgdrawsprite(sprite(iIm),varInput.xPos,varInput.yPos);
        end
        
    end
    
else
    error('Image input must be matlab image array, character array for image location, or cell array of characters for image locations')
end





















