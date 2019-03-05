% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 27/02/2019
%
% Current version = v1.0
%
% This will take a single character array and present it on the Cogent
% window. To do this, it will first split the text into lines depending on
% a pre-defined wrap width. This wrap width is in number of characters
% rather than pixels. 
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% text  -   Text to draw.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% x                 -   X Position for text. (DEFAULT: 0)
% y                 -   Y Position for text. (DEFAULT: 0)
% font              -   Text font. (DEFAULT: 'Arial')
% fontSize          -   Text font size. (DEFAULT: 32)
% colour            -   Text colour. (DEFAULT: [1 1 1])
% wrapWidth         -   Wrap width for lines. (DEFAULT: 65)
% alignment         -   Text alignment/ (DEFAULT: {'c' 'c'})
% spaceBetweenLines -   Pixels between lines. (DEFAULT: fontSize/4)
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
% cog_InsertText('Line1 Line2 Line3','wrapWidth,5);
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

function cog_InsertText(text,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'x'), varInput.x = 0; end
if ~isfield(varInput, 'y'), varInput.y = 0; end
if ~isfield(varInput, 'font'), varInput.font = 'Arial'; end
if ~isfield(varInput, 'fontSize'), varInput.fontSize = 32; end
if ~isfield(varInput, 'colour'), varInput.colour = [1 1 1]; end
if ~isfield(varInput, 'wrapWidth'), varInput.wrapWidth = 65; end
if ~isfield(varInput, 'alignment'), varInput.alignment = {'c' 'c'}; end
if ~isfield(varInput, 'spaceBetweenLines'), varInput.spaceBetweenLines = varInput.fontSize/4; end

% ======================================================================= %
% Separate Text into Multiple Lines Based on Wrap Width.
% ======================================================================= %

finished = 0;
letterCount_Total = 0; letterCount_Reset = 0;
lineCount = 1;
lineList = {};
while ~finished
    
    letterCount_Total = letterCount_Total + 1;
    letterCount_Reset = letterCount_Reset + 1;
    currentLetter = text(letterCount_Total);
    lineList{lineCount}(letterCount_Reset) = currentLetter;
    
    if letterCount_Reset == varInput.wrapWidth
        
        nextLetter = text(letterCount_Total+1);
        
        if isspace(nextLetter)
            
            lineCount = lineCount + 1;
            letterCount_Reset = 0;
            
        else
            
            while ~isspace(currentLetter)
                lineList{lineCount}(letterCount_Reset) = [];
                letterCount_Reset = letterCount_Reset - 1;
                letterCount_Total = letterCount_Total - 1;
                currentLetter = lineList{lineCount}(letterCount_Reset);
            end
            
            % Remove spaces at end of lines.
            
            while isspace(lineList{lineCount}(letterCount_Reset))
                lineList{lineCount}(letterCount_Reset) = [];
                letterCount_Reset = letterCount_Reset - 1;
            end
            
            % Next line.
            
            lineCount = lineCount + 1;
            letterCount_Reset = 0;
            
        end
    end
    
    if letterCount_Total == length(text);
        finished = 1;
    end
    
end

% ======================================================================= %
% Display Each Line.
% ======================================================================= %

cgpencol(varInput.colour);
cgfont(varInput.font,varInput.fontSize);
cgalign(varInput.alignment{1},varInput.alignment{2});
newY = varInput.y;
for iLine = 1:length(lineList)
    cgtext(lineList{iLine},varInput.x,newY);
    newY = newY - ((varInput.fontSize/2) + varInput.spaceBetweenLines);
end

