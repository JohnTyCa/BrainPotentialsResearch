% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 08/05/2018
%
% Current version = v2.4
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% origin    -   Origin of centres of scale. e.g. [0 300; 0 -300]
% w         -   Width of scales in pixels. e.g. [500 300]
% h         -   Height of scales in pixels. e.g. [50 50];
% anchor    -   Anchors for scales. e.g. { {'0' '100'} {'None' 'All'} }
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% orientation           -   Orientation of the scale. ("horizontal" or
%                           "vertical"; DEFAULT: "horizontal")
%
% type                  -   Whether you can drag the scale or only single
%                           clicks are registered. ("single", "continuous"
%                           or "box"; DEFAULT: "single")
%
% scaleColour           -   Colour of the scale background.
%                           (DEFAULT: [1 1 1])
%
% fillColour            -   Colour of scale fill. (DEFAULT: [1 0 0])
%
% fontSize              -   Font size of anchors. (DEFAULT: 48)
%
% incrementLines        -   Number of increment lines per scale.
%                           (DEFAULT: [0; 0; 0; ...])
%
% incrementSize         -   Length of increment lines (DEFAULT: 25)
%
% incrementColour       -   Colour of increment lines (DEFAULT:
%                           [scaleColour]
%
% incrementWidth        -   Thickness of increment lines (DEFAULT: 1)
%
% textColour            -   Colour of anchors (DEFAULT: [1 1 1])
%
% clickRegister         -   Where to register clicking. ("box" or
%                           "increment"; DEFAULT: "box"). Current bug known
%                           for "increment" parameter wherein the scale
%                           will be highlighted beyond the scale box, but
%                           only if increment lock is off.
%
% drawOnly              -   Whether to draw scales only and present, or to
%                           draw scales and allow selection. (1 or 0;
%                           DEFAULT: 0)
%
% incrementLock         -   Whether to lock ratings to specific points. (0
%                           or 1; DEFAULT: 0)
%
% incrementLockPoints   -   How many points to allow rating to lock to.
%                           (DEFAULT: 10)
%
% forceChoice           -   Whether to allow continuing without making a
%                           rating. (1 or 0; DEFAULT: 1).
%
% contBoxOrigin         -   Origin of continue box. (DEFAULT: [550 -450])
%
% contBoxSize           -   Size of continue box. (DEFAULT: [50 50])
%
% contBoxColour         -   Colour of continue box.
%                           (DEFAULT: [0.5 0.5 0.5])
%
% scaleMaxTime          -   Max amount of time to present scale for.
%                           (DEFAULT: [])
%
% mouseTrack            -   Whether to track mouse during rating or not.
%                           Note that if you want to concatenate MOUSETRACK
%                           across several trials, MOUSETRACK will need to
%                           be initialized outside of this function, input
%                           into this variable as "MOUSETRACK", and output
%                           into the global workspace. This allows the same
%                           variable to be input into each instance of this
%                           function and each subsequent sample will be
%                           added to the bottom of the MOUSETRACK.xy
%                           structure. Otherwise, leave this parameter
%                           empty and a new MOUSETRACK structure will be
%                           produced for each instance of this function.
%                           (DEFAULT: []).
%
% mouseTrackHz          -   Sampling rate at which to take mouse samples.
%                           (DEFAULT: 256)
%
% cogentSXY             -   Sprite number to draw image onto screen each
%                           time scale is selected as well as X and Y
%                           location. Format should be Nx3 array with
%                           [SPRITE X Y] on each row for each image.
%                           (DEFAULT: [])
%
% cogentImageAlign      -   Position to which images should be aligned to.
%                           (DEFAULT: {'c' 'c'})
%
% fixMousePosition      -   Position as to which the mouse position should
%                           be fixed whilst the scale is being presented.
%                           (DEFAULT: [])
%
% fixMousePositionDuration  -   How long the mouse position should be fixed
%                               for. Note that this parameter must be input
%                               if the mouse movement is to be limited for
%                               a set duration. Otherwise, the mouse
%                               position will just be moved to the
%                               location. (DEFAULT: [])
%
% triggerForScale           -   Whether to input a trigger for the onset of
%                               the scale. Input must include the DIO
%                               object, the TRIGGER and the TIME to wait
%                               before resetting the port to zero, and must
%                               be in the format of {'DIO' TRIGGER TIME}.
%                               (DEFAULT: [])
%
% triggerForClick           -   Whether to input a trigger for the onset of
%                               each mouse click. Input must include the
%                               DIO object, the TRIGGER and the TIME to
%                               wait before resetting the port to zero, and
%                               must be in the format of
%                               {'DIO' TRIGGER TIME}. (DEFAULT: [])
%
%
% mouseAutoCont             -   This allows for the scale to continue
%                               automatically if an option has been
%                               selected and the mouse has not been moved
%                               in a set amount of time. This allows us to
%                               limit mouse movement (For example, if this
%                               parameter is set to 3, the scale will
%                               report its final rating if the mouse does
%                               not move for three seconds after making the
%                               last selection). (DEFAULT: [])
% 
% forceOption               -   If using a box scale, this will force a
%                               specific option to be selected. 
%                               (DEFAULT: [])
% 
% presentText               -   Draw text in specified location. Requires
%                               the text (char array), x-location
%                               (numeric), y-location (numeric), plus any
%                               number of optional inputs detailed in
%                               'cog_InsertText' function, such as
%                               fontSize, font, colour, etc. For example,
%                               {'TEXT_TO_INSERT',0,-150,'fontSize',64}.
%                               (DEFAULT: [])
%
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% ratings       -   The rating for each scale.
%
% MOUSETRACK    -   The mouse tracking structure containing data of mouse
%                   locations.
%
% flipTime      -   The time (using cogstd) at which the flip command was
%                   issued.
%
% boxSync       -   If scale type 'box' is used, this will report the
%                   anchor that is selected for each scale.
%
% ======================================================================= %
% Example
% ======================================================================= %
%
% % This is a randomly generated image that is loaded using the cogent
% % command. This will allow us to demonstrate how an image can be
% % presented during scale presentation.
%
% EXAMPLE.image = double((rand(90,3)>.5));
% cgloadarray(1,30,3,EXAMPLE.image,240,240)
%
% % Example Box Scale. This will present a series of discrete boxes, with
% % no limit on how long can be spent on the scale, but a choice must be
% % made, i.e. the continue box will not appear until an option is selected.
% % Mouse movements will also be tracked at 256 Hz.
%
% [rating,MOUSETRACK,flipTime,boxSync] = vasScale(   [0 -350], ...
%                                   [1200], ...
%                                   [50], ...
%                                   {{'£0' '£1' '£2' '£3' '£4' '£5' '£6' '£7' '£8' '£9' '£10' '£11' '£12' '£13' '£14' '£15' '£16'}}, ...
%                                   'orientation', 'horizontal', ...
%                                   'type', 'box', ...
%                                   'scaleColour', [1 1 1], ...
%                                   'fillColour',[1 0 0], ...
%                                   'fontSize', 24, ...
%                                   'incrementLines', [17], ...
%                                   'incrementSize', 50, ...
%                                   'incrementColour', [1 1 1], ...
%                                   'incrementWidth', 5, ...
%                                   'textColour', [1 1 1], ...
%                                   'clickRegister', 'increment', ...
%                                   'drawOnly',0, ...
%                                   'incrementLock', 1, ...
%                                   'incrementLockPoints', 101, ...
%                                   'forceChoice', 1, ...
%                                   'contBoxOrigin', [], ...
%                                   'contBoxSize', [50 50], ...
%                                   'contBoxColour', [0 0 1], ...
%                                   'scaleMaxTime', 10, ...
%                                   'mouseTrack', [], ...
%                                   'mouseTrackHz', 256, ...
%                                   'cogentSXY', [1 0 0], ...
%                                   'cogentImageAlign', {'c' 'c'}, ...
%                                   'fixMousePosition', [540 280], ...
%                                   'fixMousePositionDuration', 0);
%
% for iScale = 1:length(rating)
%     disp(['Scale ' num2str(iScale) ' Rating = ' num2str(rating(iScale))]);
%     disp(['Box Selected = ' boxSync{iScale}]);
%     disp(' ')
% end
%
% % Example VAS. This will present two visual analogue scales. Here, the
% % choice is not forced and they are free to continue at any point, even if
% % they have not made a selection. This will default to a rating of zero,
% % but a maximum of 10 seconds is allowed to be spent on the scale.
%
% [rating,MOUSETRACK,flipTime,boxSync] = vasScale(   [0 400; 0 -400], ...
%                                   [800 800], ...
%                                   [25 25], ...
%                                   {{'Unpleasant' 'Very Pleasant'} {'Undesirable' 'Very Desirable'}}, ...
%                                   'orientation', 'horizontal', ...
%                                   'type', 'continuous', ...
%                                   'scaleColour', [1 1 1], ...
%                                   'fillColour',[1 0 0], ...
%                                   'fontSize', 48, ...
%                                   'incrementLines', [10 4], ...
%                                   'incrementSize', 40, ...
%                                   'incrementColour', [1 1 1], ...
%                                   'incrementWidth', 5, ...
%                                   'textColour', [1 1 1], ...
%                                   'clickRegister', 'increment', ...
%                                   'drawOnly',0, ...
%                                   'incrementLock', 1, ...
%                                   'incrementLockPoints', 101, ...
%                                   'forceChoice', 0, ...
%                                   'contBoxOrigin', [500 -450], ...
%                                   'contBoxSize', [50 50], ...
%                                   'contBoxColour', [0 0 1], ...
%                                   'scaleMaxTime', 10, ...
%                                   'mouseTrack', [], ...
%                                   'mouseTrackHz', 0, ...
%                                   'cogentSXY', [1 0 0], ...
%                                   'cogentImageAlign', {'c' 'c'}, ...
%                                   'fixMousePosition', [540 280], ...
%                                   'fixMousePositionDuration', 0);
%
% for iScale = 1:length(rating)
%     disp(['Scale ' num2str(iScale) ' Rating = ' num2str(rating(iScale))]);
%     disp(' ')
% end
%
% ======================================================================= %
% Dependencies
% ======================================================================= %
% 
% cog_InsertText
% trackMouse
% fillScale (Nested)
% drawScales (Nested)
% drawLineScale (Nested)
% drawBoxScale (Nested)
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 09/05/2018 (v1.0) -   Input mouse tracking and maximum scale
%                       time capabilities.
%
% 25/06/2018 (v1.1) -   Now has capabilities to draw image to screen using
%                       COGENT using sprite that already has image assigned
%                       to it.
%
% 07/08/2018 (v1.2) -   Implemented ability to specify mouse location at
%                       scale presentation, and also whether to fix it in
%                       said location for a set duration.
%
% 24/08/2018 (v2.0) -   Implemented 'box' type scales wherein discrete
%                       boxes are presented, rather than a visual analogue
%                       scale.
%
%                   -   Fixed bug where, if several scales were presented
%                       at once and choices are forced, continuing was
%                       allowed after selecting only one of the scales.
%
%                   -   Fixed bug where mouse was not tracked when
%                       individuals are rating on the scale. Since during
%                       continuous scales the mouse is held down, this may
%                       result in a huge loss of data.
%
% 10/09/2018 (v2.1) -   Now allows for the input of trigger via parallel
%                       port for both the onset of the scale and the event
%                       of each mouse click.
%
% 18/09/2018 (v2.2) -   Automatic continue box allows continuing if option
%                       has been selected and mouse has not been moved in
%                       set amount of time.
% 
% 28/02/2019 (v2.3) -   Concatenated functions into single script.
%                       Organised script and made more notes.
%
% 28/03/2019 (v2.4) -   Ability to force specific choice.
% 
% 29/03/2019 (v2.5) -   Ability to present text on screen continuously.
% 
% ======================================================================= %

function [ratingValues, MOUSETRACK, flipTime, boxSync] = vasScale(origin,w,h,anchor,varargin)

%=====================================================================%
% Initial Variables.
%=====================================================================%

LOOPFUNC = [];

INPUT.origin = origin;
INPUT.w = w;
INPUT.h = h;
INPUT.anchor = anchor;

coordsFill = zeros(size(INPUT.origin,1),1);

OUTPUT = [];
finishedLoop = 0;
optionSelected = zeros(size(INPUT.origin,1),1);
contBoxSelected = 0;
scalesDrawn = 0;
flipTime = [];
boxSync = cell(size(INPUT.origin,1),1);

LOOPFUNC.startTime = cogstd('sGetTime',-1);

%=====================================================================%
% Variable Argument Input Definitions.
%=====================================================================%

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput, 'orientation'), varInput.orientation = 'horizontal'; end
if ~isfield(varInput, 'type'), varInput.type = 'single'; end
if ~isfield(varInput, 'scaleColour'), varInput.scaleColour = [1 1 1]; end
if ~isfield(varInput, 'fillColour'), varInput.fillColour = [1 0 0]; end
if ~isfield(varInput, 'fontSize'), varInput.fontSize = 48; end
if ~isfield(varInput, 'incrementLines'), varInput.incrementLines = zeros(length(coordsFill),1); end
if ~isfield(varInput, 'incrementSize'), varInput.incrementSize = 0; end%0; end;
if ~isfield(varInput, 'incrementColour'), varInput.incrementColour = varInput.scaleColour; end
if ~isfield(varInput, 'incrementWidth'), varInput.incrementWidth = 5; end%1; end;
if ~isfield(varInput, 'textColour'), varInput.textColour = [1 1 1]; end
if ~isfield(varInput, 'clickRegister'), varInput.clickRegister = 'increment'; end
if ~isfield(varInput, 'drawOnly'), varInput.drawOnly = 0; end
if ~isfield(varInput, 'incrementLock'), varInput.incrementLock = 0; end%0; end;
if ~isfield(varInput, 'incrementLockPoints'), varInput.incrementLockPoints = 10; end%10; end;
if ~isfield(varInput, 'forceChoice'), varInput.forceChoice = 1; end
if ~isfield(varInput, 'contBoxOrigin'), varInput.contBoxOrigin = [550 -450]; end
if ~isfield(varInput, 'contBoxSize'), varInput.contBoxSize = [50 50]; end
if ~isfield(varInput, 'contBoxColour'), varInput.contBoxColour = [0.5 0.5 0.5]; end
if ~isfield(varInput, 'scaleMaxTime'), varInput.scaleMaxTime = []; end
if ~isfield(varInput, 'mouseTrack'), varInput.mouseTrack = []; end
if ~isfield(varInput, 'mouseTrackHz'), varInput.mouseTrackHz = 0; end
if ~isfield(varInput, 'cogentSXY'), varInput.cogentSXY = []; end
if ~isfield(varInput, 'cogentImageAlign'), varInput.cogentImageAlign = {'c' 'c'}; end
if ~isfield(varInput, 'fixMousePosition'), varInput.fixMousePosition = []; end
if ~isfield(varInput, 'fixMousePositionDuration'), varInput.fixMousePositionDuration = []; end
if ~isfield(varInput, 'triggerForScale'), varInput.triggerForScale = []; end
if ~isfield(varInput, 'triggerForClick'), varInput.triggerForClick = []; end
if ~isfield(varInput, 'mouseAutoCont'), varInput.mouseAutoCont = []; end
if ~isfield(varInput, 'forceOption'), varInput.forceOption = 0; end
if ~isfield(varInput, 'presentText'), varInput.presentText = []; end

%=====================================================================%
% Logic Checks.
%=====================================================================%

% Change colour of text if it is same as box.
if strcmp(varInput.type,'box')
    if all(varInput.textColour == varInput.incrementColour)
        varInput.textColour = varInput.textColour / 2;
    end
    warning('Text Colour is Equal to Increment Colour. Autocorrecting, but Consider Changing')
end

% Recode scaleMaxTime to equal fixMousePositionDuration if time to fix
% mouse position extends beyond max scale time.

if ~isempty(varInput.scaleMaxTime) && ~isempty(varInput.fixMousePositionDuration)
    if varInput.scaleMaxTime < varInput.fixMousePositionDuration
        warning('scaleMaxTime < fixMousePositionDuration')
        warning('Fix Mouse Duration Should not Exceed Max Scale Time')
        warning('Setting scaleMaxTime as fixMousePositionDuration')
        varInput.scaleMaxTime = varInput.fixMousePositionDuration;
    end
end

% If an empty 'fixMousePositionDuration' parameter is given, it forces the
% mouse location indefinitely. Hence, we recode it to 0.01 here if empty.
% Also, if 0 is given as the duration, the mouse will not be moved.

if isempty(varInput.fixMousePositionDuration) || varInput.fixMousePositionDuration == 0
    varInput.fixMousePositionDuration = 0.01;
end

% To Auto-Continue, mouse tracking must be done. Hence, we force the mouse
% tracking sampling rate to 256 Hz if it is input as [] or 0.
if ~isempty(varInput.mouseAutoCont) && (isempty(varInput.mouseTrackHz) || varInput.mouseTrackHz == 0)
    disp('For Auto Continue, Mousetracking Sampling Rate Needs to be Greater')
    disp('Setting Mouse Tracking Sampling Rate to 256 Hz')
    varInput.mouseTrackHz = 256;
end

%=====================================================================%
% Mouse Tracking Initialisation.
%=====================================================================%

if ~isempty(varInput.mouseTrack)
    MOUSETRACK = varInput.mouseTrack;
    % elseif ~exist('MOUSETRACK') && varInput.mouseTrackHz > 0
elseif isempty(varInput.mouseTrack) && varInput.mouseTrackHz > 0
    MOUSETRACK = struct();
    MOUSETRACK = trackMouse(MOUSETRACK);
    MOUSETRACK.previousSampleTime = MOUSETRACK.xy.time(end);
end

%=====================================================================%
% Main Loop.
%=====================================================================%

while ~finishedLoop
    
    % Get start of bidding time.
    
    LOOPFUNC.currentTime = cogstd('sGetTime',-1);
    
    % Get initial mouse location.
    
    [MOUSE.x,MOUSE.y,MOUSE.bd,MOUSE.bp] = cgmouse;
    
    % Track Mouse during main loop. Will also set variable to continue
    % automatically if mouse position has not changed in a set amount of
    % time.
    
    if varInput.mouseTrackHz > 0
        
        MOUSETRACK.previousSampleTime = MOUSETRACK.xy.time(end);
        if (LOOPFUNC.currentTime - MOUSETRACK.previousSampleTime) >= 1/varInput.mouseTrackHz
            MOUSETRACK = trackMouse(MOUSETRACK);
        end
        
        if ~isempty(varInput.mouseAutoCont)
            
            AUTO_CONT.currentX = MOUSETRACK.xy.x(end,1);
            AUTO_CONT.currentY = MOUSETRACK.xy.y(end,1);
            AUTO_CONT.currentTime = MOUSETRACK.xy.time(end,1);
            AUTO_CONT.currentIndex = size(MOUSETRACK.xy,1);
            AUTO_CONT.continue = 0;
            AUTO_CONT.endLoop = 0;
            AUTO_CONT.prevX = MOUSETRACK.xy.x(AUTO_CONT.currentIndex,1);
            AUTO_CONT.prevY = MOUSETRACK.xy.y(AUTO_CONT.currentIndex,1);
            
            if AUTO_CONT.currentIndex > 1
                while AUTO_CONT.currentX == AUTO_CONT.prevX && AUTO_CONT.currentY == AUTO_CONT.prevY && AUTO_CONT.currentIndex > 1 && AUTO_CONT.endLoop == 0
                    AUTO_CONT.elapsedTime = AUTO_CONT.currentTime - MOUSETRACK.xy.time(AUTO_CONT.currentIndex);
                    if AUTO_CONT.elapsedTime >= varInput.mouseAutoCont
                        AUTO_CONT.continue = 1;
                        AUTO_CONT.endLoop = 1;
                    else
                        AUTO_CONT.currentIndex = AUTO_CONT.currentIndex - 1;
                        AUTO_CONT.prevX = MOUSETRACK.xy.x(AUTO_CONT.currentIndex,1);
                        AUTO_CONT.prevY = MOUSETRACK.xy.y(AUTO_CONT.currentIndex,1);
                    end
                end
            end
        end
        
    end
    
    % Draw scale, and input trigger if required.
    
    if ~scalesDrawn
        [OUTPUT, optionSelected, CONTBOX, scalesDrawn, flipTime] = drawScales(coordsFill,INPUT,varInput,optionSelected);
        if ~isempty(varInput.triggerForScale)
            inputTrigger(varInput.triggerForScale{1},varInput.triggerForScale{2},varInput.triggerForScale{3});
        end
    end
    
    if ~varInput.drawOnly
        
        if MOUSE.bp > 0
            
            % Track Mouse during single click loop.
            
            LOOPFUNC.currentTime = cogstd('sGetTime',-1);
            [MOUSE.x,MOUSE.y,MOUSE.bd,MOUSE.bp] = cgmouse;
            if  varInput.mouseTrackHz > 0
                MOUSETRACK.previousSampleTime = MOUSETRACK.xy.time(end);
                if (LOOPFUNC.currentTime - MOUSETRACK.previousSampleTime) >= 1/varInput.mouseTrackHz
                    MOUSETRACK = trackMouse(MOUSETRACK);
                end
            end
            
            %==============================================================%
            
            if ~isempty(varInput.contBoxOrigin) && isempty(varInput.mouseAutoCont)
                if inpolygon(MOUSE.x,MOUSE.y,CONTBOX.coordsCogent(:,1),CONTBOX.coordsCogent(:,2))
                    if (varInput.forceChoice == 1 && all(optionSelected)) || varInput.forceChoice == 0
                        contBoxSelected = 1;
                    end
                end
            end
            
            if strcmp(varInput.type,'single')
                %                 [coordsFill, optionSelected, contBoxSelected] = registerClick(coordsFill,INPUT,varInput,OUTPUT,CONTBOX,optionSelected,MOUSE);
                [coordsFill, optionSelected, ~]  = fillScale(coordsFill,INPUT,varInput,MOUSE,OUTPUT,optionSelected,CONTBOX,boxSync,'triggerForClick',varInput.triggerForClick);
                %             end
                
            elseif strcmp(varInput.type,'continuous')
                while MOUSE.bd == 1
                    
                    %======================================================%
                    % Track Mouse during continuous scale while loop.
                    LOOPFUNC.currentTime = cogstd('sGetTime',-1);
                    [MOUSE.x,MOUSE.y,MOUSE.bd,MOUSE.bp] = cgmouse;
                    if varInput.mouseTrackHz > 0 && ~isempty(varInput.mouseTrack)
                        MOUSETRACK.previousSampleTime = MOUSETRACK.xy.time(end);
                        if (LOOPFUNC.currentTime - MOUSETRACK.previousSampleTime) >= 1/varInput.mouseTrackHz
                            MOUSETRACK = trackMouse(MOUSETRACK);
                        end
                    end
                    %======================================================%
                    
                    %                 [coordsFill, optionSelected, contBoxSelected] = registerClick(coordsFill,INPUT,varInput,OUTPUT,CONTBOX,optionSelected,MOUSE);
                    [coordsFill, optionSelected, ~]  = fillScale(coordsFill,INPUT,varInput,MOUSE,OUTPUT,optionSelected,CONTBOX,boxSync,'triggerForClick',varInput.triggerForClick);
                end
            elseif strcmp(varInput.type,'box')
                
                [coordsFill, optionSelected, boxSync]  = fillScale(coordsFill,INPUT,varInput,MOUSE,OUTPUT,optionSelected,CONTBOX,boxSync,'triggerForClick',varInput.triggerForClick);
                
            end
        end
        
    elseif varInput.drawOnly
        finishedLoop = 1;
    end
    
    if contBoxSelected
        finishedLoop = 1;
    end
    
    if ~isempty(varInput.scaleMaxTime)
        if (LOOPFUNC.currentTime - LOOPFUNC.startTime) >= varInput.scaleMaxTime
            finishedLoop = 1;
        end
    end
    
    if exist('AUTO_CONT','var')
        if optionSelected && AUTO_CONT.continue
            finishedLoop = 1;
        end
    end
    
    if ~isempty(varInput.fixMousePosition)
        while (LOOPFUNC.currentTime - LOOPFUNC.startTime) < varInput.fixMousePositionDuration
            LOOPFUNC.currentTime = cogstd('sGetTime',-1);
            cgmouse(varInput.fixMousePosition(1),varInput.fixMousePosition(2))
        end
    end
    
end

ratingValues = coordsFill;

if ~exist('MOUSETRACK','var'); MOUSETRACK = []; end

end

%=====================================================================%
%=====================================================================%
%=====================================================================%

function [coordsFill, optionSelected, boxSync] = fillScale(coordsFill,INPUT,varInput,MOUSE,SCALE,optionSelected,~,boxSync,varargin)

varInput2 = [];
for iVar = 1:2:length(varargin)
    varInput2 = setfield(varInput2, varargin{iVar}, varargin{iVar+1});
end
if ~isfield(varInput2, 'triggerForClick'), varInput2.triggerForClick = []; end

for iScale = 1:size(INPUT.origin,1)
    
    LOOPFUNC = [];
    
    if strcmp(varInput.type,'box')
        
        LOOPFUNC.currentCoords = SCALE.coordsCogent{iScale};
        
        for iIncrement = 1:length(LOOPFUNC.currentCoords)
            if inpolygon(MOUSE.x,MOUSE.y,LOOPFUNC.currentCoords{iIncrement}(:,1), LOOPFUNC.currentCoords{iIncrement}(:,2))
                                
                if ~isempty(varInput2.triggerForClick)
                    inputTrigger(varInput2.triggerForClick{1},varInput2.triggerForClick{2},varInput2.triggerForClick{3});
                end
                
                % If forcing option, continue if wrong option selected, but
                % after inputting the trigger.
                
                if varInput.forceOption > 0
                    if iIncrement ~= varInput.forceOption
                        continue
                    end
                end 
                
                optionSelected(iScale) = 1;
                coordsFill(iScale) = iIncrement;
                boxSync{iScale} = INPUT.anchor{iScale}{iIncrement};
                
                [SCALE, optionSelected, ~] = drawScales(coordsFill,INPUT,varInput,optionSelected);
                
            end
        end
        
    else
        
        LOOPFUNC.currentCoords = SCALE.coordsCogent{iScale};
        LOOPFUNC.scaleMinMaxX = [min(LOOPFUNC.currentCoords(:,1)) max(LOOPFUNC.currentCoords(:,1))];
        LOOPFUNC.scaleMinMaxY = [min(LOOPFUNC.currentCoords(:,2)) max(LOOPFUNC.currentCoords(:,2))];
        
        if strcmp(varInput.clickRegister,'increment')
            
            LOOPFUNC.clickRegisterIncrease = varInput.incrementSize;
            LOOPFUNC.currentCoords([1 4],1) = LOOPFUNC.currentCoords([1 4],1) - LOOPFUNC.clickRegisterIncrease;
            LOOPFUNC.currentCoords([2 3],1) = LOOPFUNC.currentCoords([2 3],1) + LOOPFUNC.clickRegisterIncrease;
            LOOPFUNC.currentCoords([1 2],2) = LOOPFUNC.currentCoords([1 2],2) + LOOPFUNC.clickRegisterIncrease;
            LOOPFUNC.currentCoords([3 4],2) = LOOPFUNC.currentCoords([3 4],2) - LOOPFUNC.clickRegisterIncrease;
            
        end
        
        if strcmp(varInput.orientation,'horizontal')
            LOOPFUNC.startEndPixels = abs(LOOPFUNC.scaleMinMaxX(1) - LOOPFUNC.scaleMinMaxX(2));
            if inpolygon(MOUSE.x,MOUSE.y,LOOPFUNC.currentCoords(:,1), LOOPFUNC.currentCoords(:,2))
                
                if ~isempty(varInput2.triggerForClick)
                    inputTrigger(varInput2.triggerForClick{1},varInput2.triggerForClick{2},varInput2.triggerForClick{3});
                end
                
                coordsFill(iScale) = (MOUSE.x - LOOPFUNC.scaleMinMaxX(1)) / LOOPFUNC.startEndPixels;
                
                if varInput.incrementLock == 1
                    LOOPFUNC.percentageLockPoints = linspace(0,1,varInput.incrementLockPoints);
                    LOOPFUNC.percentageSync = LOOPFUNC.percentageLockPoints(nearest(LOOPFUNC.percentageLockPoints,coordsFill(iScale)));
                    coordsFill(iScale) = LOOPFUNC.percentageSync;
                end
                
                optionSelected(iScale) = 1;
                
                [SCALE, optionSelected, ~] = drawScales(coordsFill,INPUT,varInput,optionSelected);
                
            end
        end
        
        if strcmp(varInput.orientation,'vertical')
            LOOPFUNC.startEndPixels = abs(LOOPFUNC.scaleMinMaxY(1) - LOOPFUNC.scaleMinMaxY(2));
            if inpolygon(MOUSE.x,MOUSE.y,LOOPFUNC.currentCoords(:,1), LOOPFUNC.currentCoords(:,2))
                
                if ~isempty(varInput2.triggerForClick)
                    inputTrigger(varInput2.triggerForClick{1},varInput2.triggerForClick{2},varInput2.triggerForClick{3});
                end
                
                coordsFill(iScale) = (MOUSE.y - LOOPFUNC.scaleMinMaxY(1)) / LOOPFUNC.startEndPixels;
                
                if varInput.incrementLock == 1
                    LOOPFUNC.percentageLockPoints = linspace(0,1,varInput.incrementLockPoints);
                    LOOPFUNC.percentageSync = LOOPFUNC.percentageLockPoints(nearest(LOOPFUNC.percentageLockPoints,coordsFill(iScale)));
                    coordsFill(iScale) = LOOPFUNC.percentageSync;
                end
                
                optionSelected(iScale) = 1;
                
                [SCALE, optionSelected, ~] = drawScales(coordsFill,INPUT,varInput,optionSelected);
                
            end
        end
        
    end
    
end

end

%=====================================================================%
%=====================================================================%
%=====================================================================%

function [SCALE, optionSelected, CONTBOX, scalesDrawn, flipTime] = drawScales(coordsFill,INPUT,varInput,optionSelected)

% To stop repeated drawing, we will say here that the scale hasn't been
% drawn yet, as well as initialise the flipTime variable.

% Define Scale Coordinates.

if strcmp(varInput.type,'box')
    SCALE = drawBoxScale(varInput,INPUT,coordsFill);
else
    SCALE = drawLineScale(INPUT,varInput,coordsFill);
end

% Draw cont box (if applicable).

CONTBOX = [];

if ~isempty(varInput.contBoxOrigin) && isempty(varInput.mouseAutoCont)
    
    CONTBOX.contBoxOrigin = varInput.contBoxOrigin;
    CONTBOX.contBoxSize = varInput.contBoxSize;
    CONTBOX.contBoxColour = varInput.contBoxColour;
    
    CONTBOX.coords = createRectangleCoords(CONTBOX.contBoxOrigin,CONTBOX.contBoxSize(1),CONTBOX.contBoxSize(2));
    CONTBOX.coordsCogent = organiseCoordsForCogent(CONTBOX.coords(:,1),CONTBOX.coords(:,2));
    
    if (varInput.forceChoice == 1 && all(optionSelected)) || varInput.forceChoice == 0
        
        cgpencol(CONTBOX.contBoxColour);
        cgpolygon(CONTBOX.coordsCogent(:,1),CONTBOX.coordsCogent(:,2));
        
    end
    
end

% Draw cogent image (if applicable).

if ~isempty(varInput.cogentSXY)
    for iImage = 1:size(varInput.cogentSXY,1)
        cgalign(varInput.cogentImageAlign{1},varInput.cogentImageAlign{2})
        cgdrawsprite(varInput.cogentSXY(iImage,1),varInput.cogentSXY(iImage,2),varInput.cogentSXY(iImage,3))
    end
end

% Draw text (if applicable).

if ~isempty(varInput.presentText)
    cog_InsertText(varInput.presentText{1},'x',varInput.presentText{2},'y',varInput.presentText{3}, ...
        varInput.presentText{4:end});
end

% Present all drawings.

flipTime = cgflip(0,0,0);

scalesDrawn = 1;

end

%=====================================================================%
%=====================================================================%
%=====================================================================%

function SCALE = drawLineScale(INPUT,varInput,coordsFill)

% Initialise SCALE structure with information regarding scale coordinates.

SCALE = [];

for iScale = 1:size(coordsFill,1)
    
    % Scale Variables.
    
    LOOPFUNC2 = [];
    
    LOOPFUNC2.currentFill = coordsFill(iScale);
    LOOPFUNC2.currentOrigin = INPUT.origin(iScale,:);
    LOOPFUNC2.currentW = INPUT.w(iScale);
    LOOPFUNC2.currentH = INPUT.h(iScale);
    LOOPFUNC2.currentAnchors = INPUT.anchor{iScale};
    LOOPFUNC2.currentIncrementLines = varInput.incrementLines(iScale);
    
    SCALE.coords{iScale} = createRectangleCoords(LOOPFUNC2.currentOrigin,LOOPFUNC2.currentW,LOOPFUNC2.currentH);
    SCALE.coordsCogent{iScale} = organiseCoordsForCogent(SCALE.coords{iScale}(:,1),SCALE.coords{iScale}(:,2));
    %     OUTPUT.scaleCoords{iScale} = SCALE.coordsCogent;
    
    LOOPFUNC2.nAnchors = length(LOOPFUNC2.currentAnchors);
    LOOPFUNC2.scaleMinMaxX = [min(SCALE.coordsCogent{iScale}(:,1)) max(SCALE.coordsCogent{iScale}(:,1))];
    LOOPFUNC2.scaleMinMaxY = [min(SCALE.coordsCogent{iScale}(:,2)) max(SCALE.coordsCogent{iScale}(:,2))];
    
    % What scale to present.
    
    if strcmp(varInput.orientation,'horizontal')
        
        % If using horizontal scale.
        
        % Define coordinates for filling in scale.
        
        SCALE.coordsFill{iScale}(1,:) = SCALE.coordsCogent{iScale}(1,:);
        SCALE.coordsFill{iScale}(4,:) = SCALE.coordsCogent{iScale}(4,:);
        
        SCALE.fillPixels{iScale} = (abs(min(SCALE.coordsCogent{iScale}(:,1)) - max(SCALE.coordsCogent{iScale}(:,1)))) * LOOPFUNC2.currentFill;
        
        SCALE.coordsFill{iScale}(2,:) = [SCALE.coordsCogent{iScale}(1,1)+SCALE.fillPixels{iScale} SCALE.coordsCogent{iScale}(1,2)];
        SCALE.coordsFill{iScale}(3,:) = [SCALE.coordsCogent{iScale}(4,1)+SCALE.fillPixels{iScale} SCALE.coordsCogent{iScale}(4,2)];
        
        % Define increment size for lines.
        
        if isempty(varInput.incrementSize)
            LOOPFUNC2.currentIncrementSize = LOOPFUNC2.currentH;
        else
            LOOPFUNC2.currentIncrementSize = varInput.incrementSize;
        end
        
        % Draw increment lines if necessary.
        
        if LOOPFUNC2.currentIncrementLines > 1
            
            LOOPFUNC2.incrementLocations(:,1) = linspace(LOOPFUNC2.scaleMinMaxX(1),LOOPFUNC2.scaleMinMaxX(2),LOOPFUNC2.currentIncrementLines);
            LOOPFUNC2.incrementLocations(:,2) = LOOPFUNC2.currentOrigin(2);
            
            cgpenwid(varInput.incrementWidth)
            cgpencol(varInput.incrementColour)
            
            for iIncrementLine = 1:LOOPFUNC2.currentIncrementLines
                cgdraw(LOOPFUNC2.incrementLocations(iIncrementLine,1),LOOPFUNC2.incrementLocations(iIncrementLine,2)+LOOPFUNC2.currentIncrementSize,LOOPFUNC2.incrementLocations(iIncrementLine,1),LOOPFUNC2.incrementLocations(iIncrementLine,2) -  LOOPFUNC2.currentIncrementSize);
            end
            
        end
        
        % Define anchor locations.
        
        LOOPFUNC2.anchorLocations(:,1) = linspace(LOOPFUNC2.scaleMinMaxX(1),LOOPFUNC2.scaleMinMaxX(2),LOOPFUNC2.nAnchors);
        LOOPFUNC2.anchorLocations(:,2) = (LOOPFUNC2.currentOrigin(2)  - (varInput.fontSize * 1.1)) - (LOOPFUNC2.currentIncrementSize);
        
        % Draw anchors.
        
        cgpencol(varInput.textColour)
        cgfont('Arial',varInput.fontSize)
        cgalign('c','t')
        for iAnchor = 1:LOOPFUNC2.nAnchors
            cgtext(LOOPFUNC2.currentAnchors{iAnchor},LOOPFUNC2.anchorLocations(iAnchor,1),LOOPFUNC2.anchorLocations(iAnchor,2))
        end
        
    elseif strcmp(varInput.orientation,'vertical')
        
        % If using vertical scale.
        
        % Define coordinates for filling in scale.
        
        SCALE.coordsFill{iScale}(3,:) = SCALE.coordsCogent{iScale}(3,:);
        SCALE.coordsFill{iScale}(4,:) = SCALE.coordsCogent{iScale}(4,:);
        
        SCALE.fillPixels{iScale} = (abs(min(SCALE.coordsCogent{iScale}(:,2)) - max(SCALE.coordsCogent{iScale}(:,2)))) * LOOPFUNC2.currentFill;
        
        SCALE.coordsFill{iScale}(1,:) = [SCALE.coordsCogent{iScale}(1,1) SCALE.coordsCogent{iScale}(4,2)+SCALE.fillPixels{iScale}];
        SCALE.coordsFill{iScale}(2,:) = [SCALE.coordsCogent{iScale}(2,1) SCALE.coordsCogent{iScale}(3,2)+SCALE.fillPixels{iScale}];
        
        % Define increment size for lines.
        
        if isempty(varInput.incrementSize)
            LOOPFUNC2.currentIncrementSize = LOOPFUNC2.currentW;
        else
            LOOPFUNC2.currentIncrementSize = varInput.incrementSize;
        end
        
        % Draw increment lines if necessary.
        
        if LOOPFUNC2.currentIncrementLines > 1
            
            LOOPFUNC2.incrementLocations(:,2) = linspace(LOOPFUNC2.scaleMinMaxY(1),LOOPFUNC2.scaleMinMaxY(2),LOOPFUNC2.currentIncrementLines);
            LOOPFUNC2.incrementLocations(:,1) = LOOPFUNC2.currentOrigin(1);
            
            cgpenwid(varInput.incrementWidth)
            cgpencol(varInput.incrementColour)
            
            for iIncrementLine = 1:LOOPFUNC2.currentIncrementLines
                cgdraw(LOOPFUNC2.incrementLocations(iIncrementLine,1)-LOOPFUNC2.currentIncrementSize,LOOPFUNC2.incrementLocations(iIncrementLine,2),LOOPFUNC2.incrementLocations(iIncrementLine,1)+LOOPFUNC2.currentIncrementSize,LOOPFUNC2.incrementLocations(iIncrementLine,2));
            end
            
        end
        
        % Define anchor locations and draw them.
        
        if LOOPFUNC2.nAnchors > 2
            
            LOOPFUNC2.anchorLocations(:,2) = linspace(LOOPFUNC2.scaleMinMaxY(1),LOOPFUNC2.scaleMinMaxY(2),LOOPFUNC2.nAnchors);
            LOOPFUNC2.anchorLocations(:,1) = (LOOPFUNC2.scaleMinMaxX(2)  + 10)  + (LOOPFUNC2.currentIncrementSize); %Distance horizontally from scale
            
            cgpencol(varInput.textColour)
            cgfont('Arial',varInput.fontSize)
            cgalign('l','c')
            for iAnchor = 1:LOOPFUNC2.nAnchors
                cgtext(LOOPFUNC2.currentAnchors{iAnchor},LOOPFUNC2.anchorLocations(iAnchor,1),LOOPFUNC2.anchorLocations(iAnchor,2))
            end
            
        else
            
            LOOPFUNC2.anchorLocations(:,1) = [LOOPFUNC2.currentOrigin(1) LOOPFUNC2.currentOrigin(1)];
            LOOPFUNC2.anchorLocations(:,2) = linspace(LOOPFUNC2.scaleMinMaxY(1),LOOPFUNC2.scaleMinMaxY(2),LOOPFUNC2.nAnchors);
            
            cgpencol(varInput.textColour)
            cgfont('Arial',varInput.fontSize)
            cgalign('c','t')
            cgtext(LOOPFUNC2.currentAnchors{1},LOOPFUNC2.anchorLocations(1,1),LOOPFUNC2.anchorLocations(1,2))
            cgalign('c','b')
            cgtext(LOOPFUNC2.currentAnchors{2},LOOPFUNC2.anchorLocations(2,1),LOOPFUNC2.anchorLocations(2,2))
            
        end
        
    end
    
    % Draw Scale.
    
    cgpencol(varInput.scaleColour);
    cgpolygon(SCALE.coordsCogent{iScale}(:,1),SCALE.coordsCogent{iScale}(:,2));
    
    % Fill Scale.
    
    if varInput.incrementLock == 0
        
        cgpencol(varInput.fillColour);
        cgpolygon(SCALE.coordsFill{iScale}(:,1),SCALE.coordsFill{iScale}(:,2));
        
    elseif varInput.incrementLock == 1
        
        if strcmp(varInput.orientation,'horizontal')
            
            LOOPFUNC2.incrementLockSize = abs(LOOPFUNC2.scaleMinMaxX(1) - LOOPFUNC2.scaleMinMaxX(2)) / (varInput.incrementLockPoints - 1);
            LOOPFUNC2.incrementLockPoints = linspace(LOOPFUNC2.scaleMinMaxX(1),LOOPFUNC2.scaleMinMaxX(2),varInput.incrementLockPoints);
            LOOPFUNC2.incrementLockSync = LOOPFUNC2.currentFill * abs(LOOPFUNC2.scaleMinMaxX(1) - LOOPFUNC2.scaleMinMaxX(2));
            LOOPFUNC2.incrementLockSync = LOOPFUNC2.scaleMinMaxX(1) + LOOPFUNC2.incrementLockSync;
            LOOPFUNC2.incrementLockSync = LOOPFUNC2.incrementLockPoints(nearest(LOOPFUNC2.incrementLockPoints,LOOPFUNC2.incrementLockSync));
            
            SCALE.coordsFill{iScale}([2 3],1) = LOOPFUNC2.incrementLockSync;
            
        elseif strcmp(varInput.orientation,'vertical')
            
            LOOPFUNC2.incrementLockSize = abs(LOOPFUNC2.scaleMinMaxY(1) - LOOPFUNC2.scaleMinMaxY(2)) / (varInput.incrementLockPoints - 1);
            LOOPFUNC2.incrementLockPoints = linspace(LOOPFUNC2.scaleMinMaxY(1),LOOPFUNC2.scaleMinMaxY(2),varInput.incrementLockPoints);
            LOOPFUNC2.incrementLockSync = LOOPFUNC2.currentFill * abs(LOOPFUNC2.scaleMinMaxY(1) - LOOPFUNC2.scaleMinMaxY(2));
            LOOPFUNC2.incrementLockSync = LOOPFUNC2.scaleMinMaxY(1) + LOOPFUNC2.incrementLockSync;
            LOOPFUNC2.incrementLockSync = LOOPFUNC2.incrementLockPoints(nearest(LOOPFUNC2.incrementLockPoints,LOOPFUNC2.incrementLockSync));
            
            SCALE.coordsFill{iScale}([1 2],2) = LOOPFUNC2.incrementLockSync;
            
        end
        
        cgpencol(varInput.fillColour);
        cgpolygon(SCALE.coordsFill{iScale}(:,1),SCALE.coordsFill{iScale}(:,2));
        
    end
    
end

end

%=====================================================================%
%=====================================================================%
%=====================================================================%

function SCALE = drawBoxScale(varInput,INPUT,coordsFill)

% Initialise SCALE structure with information regarding scale coordinates.

SCALE = [];

for iScale = 1:size(coordsFill,1)
    
    LOOPFUNC2 = [];
    
    % What scale to present.
    
    if strcmp(varInput.orientation,'horizontal')
        
        % If using horizontal scale.
        
        % Location of boxes.
        
        LOOPFUNC2.outerBounds = [(INPUT.origin(iScale,1) - (INPUT.w(iScale)/2)) + (INPUT.h/2) (INPUT.origin(iScale,1) + (INPUT.w(iScale)/2)) - (INPUT.h/2)];
        LOOPFUNC2.boxCentreLocs = linspace(LOOPFUNC2.outerBounds(1),LOOPFUNC2.outerBounds(2),length(INPUT.anchor{iScale}));
        
        % Where to present boxes, as well as store coordinates for each
        % box.
        
        for iIncrement = 1:length(INPUT.anchor{iScale})
            
            SCALE.coords{iScale}{iIncrement,1} = createRectangleCoords([LOOPFUNC2.boxCentreLocs(iIncrement) INPUT.origin(iScale,2)],INPUT.h,INPUT.h);
            SCALE.coordsCogent{iScale}{iIncrement} = organiseCoordsForCogent(SCALE.coords{iScale}{iIncrement}(:,1),SCALE.coords{iScale}{iIncrement}(:,2));
            
            if coordsFill(iScale) == iIncrement
                cgpencol(0,1,0)
            else
                cgpencol(varInput.incrementColour)
            end
            
            cgpolygon(SCALE.coordsCogent{iScale}{iIncrement}(:,1),SCALE.coordsCogent{iScale}{iIncrement}(:,2))
            
            cgpencol(varInput.textColour)
            cgfont('Arial',varInput.fontSize)
            cgalign('c','c')
            cgtext(INPUT.anchor{iScale}{iIncrement},LOOPFUNC2.boxCentreLocs(iIncrement),INPUT.origin(iScale,2))
            
        end
        
    elseif strcmp(varInput.orientation,'vertical')
        
        % If using vertical scale.
        
        % Location of boxes.
        
        LOOPFUNC2.outerBounds = [(INPUT.origin(iScale,2) - (INPUT.h(iScale)/2)) + (INPUT.w/2) (INPUT.origin(iScale,2) + (INPUT.h(iScale)/2)) - (INPUT.w/2)];        
        LOOPFUNC2.boxCentreLocs = linspace(LOOPFUNC2.outerBounds(1),LOOPFUNC2.outerBounds(2),length(INPUT.anchor{iScale}));
        
        % Where to present boxes, as well as store coordinates for each
        % box.
        
        for iIncrement = 1:length(INPUT.anchor{iScale})
            
            SCALE.coords{iScale}{iIncrement,1} = createRectangleCoords([INPUT.origin(iScale,1) LOOPFUNC2.boxCentreLocs(iIncrement) ],INPUT.h,INPUT.h);
            SCALE.coordsCogent{iScale}{iIncrement} = organiseCoordsForCogent(SCALE.coords{iScale}{iIncrement}(:,1),SCALE.coords{iScale}{iIncrement}(:,2));
            
            if coordsFill(iScale) == iIncrement
                cgpencol(0,1,0)
            else
                cgpencol(varInput.incrementColour)
            end
            
            cgpolygon(SCALE.coordsCogent{iScale}{iIncrement}(:,1),SCALE.coordsCogent{iScale}{iIncrement}(:,2))
            
            cgpencol(varInput.varInput.textColour)
            cgfont('Arial',varInput.fontSize)
            cgalign('c','c')
            cgtext(INPUT.anchor{iScale}{iIncrement},INPUT.origin(iScale,1),LOOPFUNC2.boxCentreLocs(iIncrement))
            
        end
        
    end
    
end

end

%=====================================================================%
%=====================================================================%
%=====================================================================%

function MOUSETRACK = trackMouse(MOUSETRACK)

[MOUSE.x,MOUSE.y,MOUSE.bd,MOUSE.bp] = cgmouse;

if ~isfield(MOUSETRACK,'xy')
    MOUSETRACK.xy = table(0,0,0);
    MOUSETRACK.xy.Properties.VariableNames = {'x','y','time'};
    LOOPFUNC.currentSampleN = 0;
else
    LOOPFUNC.currentSampleN = size(MOUSETRACK.xy,1);
end

LOOPFUNC.currentSampleN = LOOPFUNC.currentSampleN + 1;

MOUSETRACK.xy(LOOPFUNC.currentSampleN,:) = {0 0 0};

MOUSETRACK.xy.x(LOOPFUNC.currentSampleN) = MOUSE.x;
MOUSETRACK.xy.y(LOOPFUNC.currentSampleN) = MOUSE.y;
MOUSETRACK.xy.time(LOOPFUNC.currentSampleN) = cogstd('sGetTime',-1);

end

