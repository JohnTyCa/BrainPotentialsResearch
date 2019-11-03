function SA_GUI(PUPIL,VideoFile,StimulusFile,StimulusFolder,EvtFile,Output_FirstGazePos,Output_TriggerFrame,varargin)

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1}); %#ok<SFLD>
end
if ~isfield(varInput, 'LoadAllFrames'), varInput.LoadAllFrames = []; end
if ~isfield(varInput, 'SaveFile'), varInput.SaveFile = []; end
if ~isfield(varInput, 'ImageDownSize'), varInput.ImageDownSize = 0.2; end
if ~isfield(varInput, 'GazeCircle'), varInput.GazeCircle = varInput.ImageDownSize * 10; end
if ~isfield(varInput, 'ImagePerFile'), varInput.ImagePerFile = 100; end
if ~isfield(varInput, 'SaveImagesOnly'), varInput.SaveImagesOnly = 0; end
if ~isfield(varInput, 'TriggersToExtract'), varInput.TriggersToExtract = []; end
if ~isfield(varInput, 'GazeConfidenceThreshold'), varInput.GazeConfidenceThreshold = 0.8; end
if ~isfield(varInput, 'PlotGazePosition'), varInput.PlotGazePosition = 0; end

% if ~isfield(varInput, 'GazePosLimitX'), varInput.GazePosLimitX = 1; end
% if ~isfield(varInput, 'GazePosLimitY'), varInput.GazePosLimitY = 1; end

% ======================================================================= %
% Create Initial Variables
% ======================================================================= %

% Current Frame
currentFrameIndex = 0;
NextVideoFrameIndex = 0;

% Number of Frames That Have Been Extracted
nFramesExtracted = 0;

% The Absolute Start Time
TEMP = strsplit(PUPIL.ExportInfo.Absolute_Time_Range,'-');
StartTime = str2double(TEMP{1});
endTime = str2double(TEMP{2});

% The Total Number of Frames
TEMP = strsplit(PUPIL.ExportInfo.Frame_Index_Range,'-');
nVideoFrames = str2double(TEMP{2});

% Master Variable Where All Data Will Be Stored.

VIDEO.frames = table();
VIDEO.frames.index = [0:nVideoFrames]'; %#ok<NBRAK>
VIDEO.frames.matlabIndex = [1:nVideoFrames+1]'; %#ok<NBRAK>
VIDEO.frames.time = nan(nVideoFrames+1,1);
VIDEO.frames.image = cell(nVideoFrames+1,1);
VIDEO.frames.gazePos = cell(nVideoFrames+1,1);

% Load up necessary files.

STIM.Info = readtable(StimulusFile,'Delimiter',',');
STIM.Folder = StimulusFolder;

if exist(Output_FirstGazePos,'file')
    try
        GAZE = readtable(Output_FirstGazePos,'Delimiter',',');
        HeaderLines = GAZE{1,:};
        GAZE(1,:) = [];
        GAZE.Properties.VariableNames = HeaderLines;
        GAZE.Onset_Frame = str2double(GAZE.Onset_Frame);
        GAZE.Onset_Time = str2double(GAZE.Onset_Time);
        GAZE.Onset_Time_Gaze = str2double(GAZE.Onset_Time_Gaze);
        GAZE.Onset_Time_Frame = str2double(GAZE.Onset_Time_Frame);
        GAZE.Offset_Frame = str2double(GAZE.Offset_Frame);
        GAZE.Offset_Time = str2double(GAZE.Offset_Time);
        GAZE.Offset_Time_Gaze = str2double(GAZE.Offset_Time_Gaze);
        GAZE.Offset_Time_Frame = str2double(GAZE.Offset_Time_Frame);
        GAZE.Onset_Time_EEG = str2double(GAZE.Onset_Time_EEG);
        GAZE.Offset_Time_EEG = str2double(GAZE.Offset_Time_EEG);
    catch
        GAZE = readtable(Output_FirstGazePos,'Delimiter',',');
    end
    GAZE = table2struct(GAZE);
else
    GAZE = struct();
    GAZE.Item = [];
    GAZE.Surface = [];
    GAZE.Onset_Frame = [];
    GAZE.Onset_Time = [];
    GAZE.Onset_Time_Gaze = [];
    GAZE.Onset_Time_Frame = [];
    GAZE.Offset_Frame = [];
    GAZE.Offset_Time = [];
    GAZE.Offset_Time_Gaze = [];
    GAZE.Offset_Time_Frame = [];
    GAZE.Onset_Time_EEG = [];
    GAZE.Offset_Time_EEG = [];
    for iStim = 1:height(STIM.Info) %#ok<*FXUP>
        GAZE(iStim).Item = STIM.Info.ItemName{iStim};
        GAZE(iStim).Surface = STIM.Info.Surface{iStim};
        GAZE(iStim).Onset_Frame = NaN;
        GAZE(iStim).Onset_Time = NaN;
        GAZE(iStim).Onset_Time_Gaze = NaN;
        GAZE(iStim).Onset_Time_Frame = NaN;
        GAZE(iStim).Offset_Frame = NaN;
        GAZE(iStim).Offset_Time = NaN;
        GAZE(iStim).Offset_Time_Gaze = NaN;
        GAZE(iStim).Offset_Time_Frame = NaN;
        GAZE(iStim).Onset_Time_EEG = NaN;
        GAZE(iStim).Offset_Time_EEG = NaN;
    end
    saveFileFunc_FirstGazePos();
end

for iStim = 1:height(STIM.Info)
    STIM.Info.ListBoxName{iStim} = [STIM.Info.ItemName{iStim} ' (' STIM.Info.Surface{iStim} ') - ' num2str(GAZE(iStim).Onset_Frame) '/' num2str(GAZE(iStim).Offset_Frame)];
end

if exist(Output_TriggerFrame,'file')
    EVENTS = readtable(Output_TriggerFrame,'Delimiter',',');
    EVENTS = table2struct(EVENTS);
else
    EVENTS = struct();
    TEMP = [];
    TEMP = readEvt_7_0(EvtFile);
    for iEvent = 1:size(TEMP,1)
        EVENTS(iEvent).Index = iEvent;
        EVENTS(iEvent).Latency = TEMP(iEvent,1);
        EVENTS(iEvent).Name = [num2str(EVENTS(iEvent).Index) ' (' num2str(EVENTS(iEvent).Latency) ')'];
        EVENTS(iEvent).Trigger = TEMP(iEvent,3);
        EVENTS(iEvent).VideoFrame = NaN;
        EVENTS(iEvent).ET_Time = NaN;
    end
    if ~isempty(varInput.TriggersToExtract)
        EVENTS(~any([EVENTS.Trigger]' == varInput.TriggersToExtract,2)) = []
    end
    saveFileFunc_TriggerFrame();
end

SYNC = [];
SYNC.Latency_EEG = [];
SYNC.Frame = [];
SYNC.Latency_ET = [];

% ======================================================================= %
% Extract First Frame
% ======================================================================= %

[vidFrame,vidObj,gazePos,NextVideoFrameIndex] = frameExtract(PUPIL,VideoFile,StartTime,NextVideoFrameIndex);
nFramesExtracted = nFramesExtracted + 1;

if ~isempty(varInput.SaveFile)
    [d,n,~] = fileparts(varInput.SaveFile);
    masterFolder = [d '\' n '\'];
    masterSave = [masterFolder n '.mat'];
end

% VIDEO.frames.index(nFramesExtracted,1) = NextVideoFrameIndex-1;
% VIDEO.frames.matlabIndex(nFramesExtracted,1) = NextVideoFrameIndex;
vidFrame = imresize(vidFrame,varInput.ImageDownSize);
VIDEO.frames.image(nFramesExtracted,1) = {vidFrame};
VIDEO.frames.gazePos(nFramesExtracted,1) = {gazePos};
VIDEO.frames.time(nFramesExtracted,1) = vidObj.CurrentTime;
nFiles = 1;
nImageInFile = 1;
currentFileName = [n '_' nDigitString(nFiles,6) '.mat'];
VIDEO.frames.fileName(nFramesExtracted,1) = {currentFileName};

% ======================================================================= %
% Extract All Video Frames if Parameter is 1
% ======================================================================= %

recreate = 1;

if varInput.LoadAllFrames | varInput.SaveImagesOnly %#ok<OR2>
    
    if ~isempty(varInput.SaveFile)
        
        if exist(masterSave,'file')
            load(masterSave) %#ok<LOAD>
            fileList = VIDEO.frames.fileName;
            recreate = 0;
        end
        
        if ~exist(masterFolder,'file'); mkdir(masterFolder); end
        
        if recreate == 1
            
            currentFrameIndex = nVideoFrames;
            currentFrameIndexLocation = find(VIDEO.frames.index == currentFrameIndex);
            
            count = 0;
            while isempty(VIDEO.frames.image{currentFrameIndexLocation})
                tic;
                [vidFrame,vidObj,gazePos,NextVideoFrameIndex] = frameExtract(PUPIL,VideoFile,StartTime,NextVideoFrameIndex,'VideoObject',vidObj);
                nFramesExtracted = nFramesExtracted + 1;
                VIDEO.frames.index(nFramesExtracted,1) = NextVideoFrameIndex-1;
                VIDEO.frames.matlabIndex(nFramesExtracted,1) = NextVideoFrameIndex;
                VIDEO.frames.time(nFramesExtracted,1) = vidObj.CurrentTime;
                vidFrame = imresize(vidFrame,varInput.ImageDownSize);
                VIDEO.frames.image(nFramesExtracted,1) = {vidFrame};
                VIDEO.frames.gazePos(nFramesExtracted,1) = {gazePos};
                VIDEO.frames.luminance(nFramesExtracted,1) = ImageLuminance(VIDEO.frames.image{nFramesExtracted});
                count = count + 1;
                
                currentFileName = [n '_' nDigitString(nFiles,6) '.mat'];
                VIDEO.frames.fileName(nFramesExtracted,1) = {currentFileName};
                
                nImageInFile = nImageInFile + 1;
                
                fileJustSaved = 0;
                if nImageInFile >= varInput.ImagePerFile
                    save([masterFolder currentFileName],'VIDEO')
                    nFiles = nFiles + 1;
                    nImageInFile = 0;
                    VIDEO.frames.image = cell(size(VIDEO.frames,1),1);
                    VIDEO.frames.gazePos = cell(size(VIDEO.frames,1),1);
                    fileJustSaved = 1;
                end
                
                endTime(count) = toc;
                timeLeft = (nVideoFrames - (nFramesExtracted-1)) * mean(endTime);
                disp(['Extracting Frame ' num2str(nFramesExtracted-1) '/' num2str(nVideoFrames) '; Time Left = ' num2str(timeLeft/60) ' mins']);
                
            end
            
            if fileJustSaved == 0
                save([masterFolder currentFileName],'VIDEO')
                % % %                 nFiles = nFiles + 1;
                % % %                 nImageInFile = 0;
                VIDEO.frames.image = cell(size(VIDEO.frames,1),1);
                VIDEO.frames.gazePos = cell(size(VIDEO.frames,1),1);
                % % %                 fileJustSaved = 1;
            end
            
            save(masterSave,'VIDEO')
            
            %         extractedFramePosition = find(VIDEO.frames.index == currentFrameIndex);
            %         extractedFrame = cell2mat(VIDEO.frames.image(extractedFramePosition,1));
            
            %         image(extractedFrame, 'Parent', ha);
            %         ha.Visible = 'off';
            %         hCurrent.String = currentFrameIndex;
            
            currentFrameIndex = 0;
            
        end
        
    else
        disp('To load all frames, save file must be input')
        return
    end
    
end

if varInput.SaveImagesOnly == 1
    return
end

% ======================================================================= %
% Load up GUI
% ======================================================================= %

%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','on','Unit','normalized','Position',[0.25,0.25,0.5,0.5]);

clf

%  Construct the components.
hNextFrame = uicontrol('Style','pushbutton','String','Next Frame','Unit','normalized',...
    'Position',[0.25,0.95,0.05,0.05],...
    'Callback',@hNextFrame_Callback);

hNext10 = uicontrol('Style','pushbutton','String','Next Frame (10)','Unit','normalized',...
    'Position',[0.15,0.95,0.05,0.05],...
    'Callback',@hNextFrame_Callback);

hPrevFrame = uicontrol('Style','pushbutton','String','Prev Frame','Unit','normalized',...
    'Position',[0.2,0.95,0.05,0.05],...
    'Callback',@hPrevFrame_Callback);

hPrev10 = uicontrol('Style','pushbutton','String','Prev Frame (10)','Unit','normalized',...
    'Position',[0.1,0.95,0.05,0.05],...
    'Callback',@hPrevFrame_Callback);

hCurrentFrame = uicontrol('Style','edit','String',currentFrameIndex,'Unit','normalized',...
    'Position',[0.3,0.95,0.05,0.05],...
    'Callback',@hCurrentFrame_Callback);

hCurrentTime = uicontrol('Style','edit','String',['Time: ' num2str(VIDEO.frames.time(VIDEO.frames.index == currentFrameIndex))], ...
    'Unit','normalized',...
    'Position',[0.35,0.95,0.1,0.05],...
    'Callback',@hCurrentTime_Callback);

hStimList = uicontrol('Style','listbox','String',STIM.Info.ListBoxName,'Unit','normalized',...
    'Position',[0.5,0.1,0.2,0.3],...
    'Callback',@hStimList_Callback);

uicontrol('Style','text','String','First Product Gaze Frame','Unit','normalized',...
    'Position',[0.5,0.425,0.2,0.025], ...
    'FontSize',12);

hEncodeCurrentFrame_Onset = uicontrol('Style','pushbutton','String','Frame Onset','Unit','normalized',...
    'Position',[0.35,0.35,0.1,0.05],...
    'Callback',@hEncodeCurrentFrame_Onset_Callback);

hCurrentOnsetFrame = uicontrol('Style','edit','String',[],'Unit','normalized',...
    'Position',[0.35,0.3,0.1,0.05],...
    'Callback',@hCurrentOnsetFrame_Callback);

hCurrentOnsetTime = uicontrol('Style','text','String','Time: NaN','Unit','normalized',...
    'Position',[0.35,0.25,0.1,0.05]);

hEncodeCurrentFrame_Offset = uicontrol('Style','pushbutton','String','Frame Offset','Unit','normalized',...
    'Position',[0.35,0.2,0.1,0.05],...
    'Callback',@hEncodeCurrentFrame_Offset_Callback);

hCurrentOffsetFrame = uicontrol('Style','edit','String',[],'Unit','normalized',...
    'Position',[0.35,0.15,0.1,0.05],...
    'Callback',@hCurrentOffsetFrame_Callback);

hCurrentOffsetTime = uicontrol('Style','text','String','Time: NaN','Unit','normalized',...
    'Position',[0.35,0.1,0.1,0.05]);

hSyncFrame = uicontrol('Style','edit','String',[],'Unit','normalized',...
    'Position',[0.75,0.95,0.05,0.025],...
    'Callback',@hSyncFrame_Callback);

uicontrol('Style','text','String','Sync Frame','Unit','normalized',...
    'Position',[0.75,0.975,0.05,0.025]);

hSyncList = uicontrol('Style','popupmenu','String',{EVENTS.Name},'Unit','normalized',...
    'Position',[0.81,0.925,0.1,0.05]);

uicontrol('Style','text','String','Trigger for Sync','Unit','normalized',...
    'Position',[0.81,0.975,0.1,0.025]);

% ======================================================================= %
% Configure the boxes listing events.
% ======================================================================= %

BOXCONFIG = [];

BOXCONFIG.DistFromLeft = 0.75;
BOXCONFIG.DistFromRight = 0.05;
BOXCONFIG.DistFromTop = 0.1;
BOXCONFIG.DistFromBottom = 0.9;
BOXCONFIG.NBoxes = 4;

BOXCONFIG.DistBetweenBoxes = 0.005;

BOXCONFIG.NTriggers = length(EVENTS);

BOXCONFIG.BoxHeight = ((abs(BOXCONFIG.DistFromTop - BOXCONFIG.DistFromBottom)) - ((BOXCONFIG.NTriggers - 1)*BOXCONFIG.DistBetweenBoxes)) / BOXCONFIG.NTriggers;

BOXCONFIG.BoxWidth = ((1 - (BOXCONFIG.DistFromLeft + BOXCONFIG.DistFromRight)) - (BOXCONFIG.NBoxes*BOXCONFIG.DistBetweenBoxes)) / BOXCONFIG.NBoxes;

% ======================================================================= %
% Configure axes.
% ======================================================================= %

hVideoFrame = axes('Units','Pixels','Unit','normalized','Position',[0.1,0.5,0.4,0.4]);
hStimImage = axes('Units','Pixels','Unit','normalized','Position',[0.1,0.1,0.25,0.3]);
hLuminance = axes('Units','Pixels','Unit','normalized','Position',[0.55,0.7,0.15,0.2]);

[hCurrentEventLatency,hCurrentEventFrame,hPredictedEventLatency2] = ProduceTriggerBoxes();

% ======================================================================= %
% Encode the SyncFrame prediction if a trigger has already had its frame
% encoded.
% ======================================================================= %

if any(~isnan([EVENTS.VideoFrame]))
    
    TEMP = [];
    TEMP.IndexList = find(~isnan([EVENTS.VideoFrame]));
    
    TEMP.source = [];
    TEMP.source.String = num2str(EVENTS(TEMP.IndexList(1)).VideoFrame);
    
    hSyncFrame_Callback(TEMP.source,[]);
    
    %     TEMP = [];
    %     TEMP.IndexList = find(~isnan([EVENTS.VideoFrame]));
    %     hSyncFrame.String = EVENTS(TEMP.IndexList(1)).VideoFrame;
    %     hSyncList.Value = TEMP.IndexList(1);
end

% ======================================================================= %
% Initialize the GUI.
% ======================================================================= %

% Change units to normalized so components resize automatically.
f.Units = 'normalized';
hVideoFrame.Units = 'normalized';
hPrevFrame.Units = 'normalized';
hNextFrame.Units = 'normalized';
hSOI.Units = 'normalized';
hCurrentFrame.Units = 'normalized';

% Assign the GUI a name to appear in the window title.
f.Name = 'SupermarkET';

% Move the GUI to the center of the screen.
movegui(f,'center')

% ======================================================================= %
% Draw Initial Frame Into GUI
% ======================================================================= %

extractedFramePosition = find(VIDEO.frames.index == currentFrameIndex);
if varInput.LoadAllFrames == 1
    if isempty(VIDEO.frames.image{extractedFramePosition})
        VIDEO.frames.image = cell(size(VIDEO.frames,1),1);
        VIDEO.frames.gazePos = cell(size(VIDEO.frames,1),1);
        loadedData = load([masterFolder VIDEO.frames.fileName{extractedFramePosition}])
        VIDEO.frames.image = loadedData.VIDEO.frames.image;
        VIDEO.frames.gazePos = loadedData.VIDEO.frames.gazePos;
        VIDEO.frames.fileName = fileList;
    end
else
    currentFrameIndexLocation = find(VIDEO.frames.index == currentFrameIndex);
    while isempty(VIDEO.frames.image{currentFrameIndexLocation})
        [vidFrame,vidObj,gazePos,NextVideoFrameIndex] = frameExtract(PUPIL,VideoFile,StartTime,NextVideoFrameIndex,'VideoObject',vidObj);
        nFramesExtracted = nFramesExtracted + 1;
        VIDEO.frames.index(nFramesExtracted,1) = NextVideoFrameIndex-1;
        VIDEO.frames.matlabIndex(nFramesExtracted,1) = NextVideoFrameIndex;
        VIDEO.frames.time(nFramesExtracted,1) = vidObj.CurrentTime;
        vidFrame = imresize(vidFrame,varInput.ImageDownSize);
        VIDEO.frames.image(nFramesExtracted,1) = {vidFrame};
        VIDEO.frames.gazePos(nFramesExtracted,1) = {gazePos};
        disp(['Extracting Frame ' num2str(nFramesExtracted-1) '/' num2str(nVideoFrames)]);
    end
    extractedFramePosition = find(VIDEO.frames.index == currentFrameIndex);
end

extractedFrame = cell2mat(VIDEO.frames.image(extractedFramePosition,1));

% Plot Gaze Location
if varInput.PlotGazePosition
    extractedFrame = extractGazePos;
end

% Draw Frame
image(extractedFrame, 'Parent', hVideoFrame);
hVideoFrame.Visible = 'off';

% Make the GUI visible.
f.Visible = 'on';

% Plot luminance.
PlotLuminance();

% ======================================================================= %
% Callbacks.
%
% Callbacks for simple_gui. These callbacks automatically have access to 
% component handles and initialized data because they are nested at a lower 
% level.
% ======================================================================= %

    function hNextFrame_Callback(source,~)
        
        if strcmp(source.String,'Next Frame (10)')
            currentFrameIndex = currentFrameIndex + 10;
        else
            currentFrameIndex = currentFrameIndex + 1;
        end
        
        if currentFrameIndex > nVideoFrames
            currentFrameIndex = nVideoFrames;
        end
        
        if isempty(varInput.LoadAllFrames) | ~varInput.LoadAllFrames
            
            currentFrameIndexLocation = find(VIDEO.frames.index == currentFrameIndex);
            while isempty(VIDEO.frames.image{currentFrameIndexLocation})
                [vidFrame,vidObj,gazePos,NextVideoFrameIndex] = frameExtract(PUPIL,VideoFile,StartTime,NextVideoFrameIndex,'VideoObject',vidObj);
                nFramesExtracted = nFramesExtracted + 1;
                VIDEO.frames.index(nFramesExtracted,1) = NextVideoFrameIndex-1;
                VIDEO.frames.matlabIndex(nFramesExtracted,1) = NextVideoFrameIndex;
                VIDEO.frames.time(nFramesExtracted,1) = vidObj.CurrentTime;
                vidFrame = imresize(vidFrame,varInput.ImageDownSize);
                VIDEO.frames.image(nFramesExtracted,1) = {vidFrame};
                VIDEO.frames.gazePos(nFramesExtracted,1) = {gazePos};
                disp(['Extracting Frame ' num2str(nFramesExtracted-1) '/' num2str(nVideoFrames)]);
            end
            
            extractedFramePosition = find(VIDEO.frames.index == currentFrameIndex);
            extractedFrame = cell2mat(VIDEO.frames.image(extractedFramePosition,1));
            
        else
            
            extractedFramePosition = find(VIDEO.frames.index == currentFrameIndex);
            if isempty(VIDEO.frames.image{extractedFramePosition})
                VIDEO.frames.image = cell(size(VIDEO.frames,1),1);
                VIDEO.frames.gazePos = cell(size(VIDEO.frames,1),1);
                loadedData = load([masterFolder VIDEO.frames.fileName{extractedFramePosition}]);
                VIDEO.frames.image = loadedData.VIDEO.frames.image;
                VIDEO.frames.gazePos = loadedData.VIDEO.frames.gazePos;
                VIDEO.frames.fileName = fileList;
            end
            extractedFrame = cell2mat(VIDEO.frames.image(extractedFramePosition,1));
            
            % % %             encodeTimes
            
        end
        
        if varInput.PlotGazePosition
            extractedFrame = extractGazePos;
        end
        
        image(extractedFrame, 'Parent', hVideoFrame);
        hVideoFrame.Visible = 'off';
        hCurrentFrame.String = currentFrameIndex;
        hCurrentTime.String = ['Time: ' num2str(VIDEO.frames.time(VIDEO.frames.index == currentFrameIndex))];
        
        PlotLuminance();
        
    end

    function hPrevFrame_Callback(source,~)
        
        if strcmp(source.String,'Prev Frame (10)')
            currentFrameIndex = currentFrameIndex - 10;
        else
            currentFrameIndex = currentFrameIndex - 1;
        end
        
        if currentFrameIndex < 0
            currentFrameIndex = 0;
        end
        
        if isempty(varInput.LoadAllFrames) | ~varInput.LoadAllFrames
            extractedFramePosition = find(VIDEO.frames.index == currentFrameIndex);
            extractedFrame = cell2mat(VIDEO.frames.image(extractedFramePosition,1));
        else
            
            extractedFramePosition = find(VIDEO.frames.index == currentFrameIndex);
            if isempty(VIDEO.frames.image{extractedFramePosition})
                VIDEO.frames.image = cell(size(VIDEO.frames,1),1);
                VIDEO.frames.gazePos = cell(size(VIDEO.frames,1),1);
                loadedData = load([masterFolder VIDEO.frames.fileName{extractedFramePosition}]);
                VIDEO.frames.image = loadedData.VIDEO.frames.image;
                VIDEO.frames.gazePos = loadedData.VIDEO.frames.gazePos;
                VIDEO.frames.fileName = fileList;
            end
            extractedFrame = cell2mat(VIDEO.frames.image(extractedFramePosition,1));
            
        end
        
        if varInput.PlotGazePosition
            extractedFrame = extractGazePos;
        end
        
        image(extractedFrame, 'Parent', hVideoFrame);
        hVideoFrame.Visible = 'off';
        hCurrentFrame.String = currentFrameIndex;
        hCurrentTime.String = ['Time: ' num2str(VIDEO.frames.time(VIDEO.frames.index == currentFrameIndex))];
        
        PlotLuminance();
        
    end

    function hCurrentFrame_Callback(source,~)
        
        currentFrameIndex = str2double(source.String);
        
        if currentFrameIndex < 0
            currentFrameIndex = 0;
        elseif currentFrameIndex > nVideoFrames
            currentFrameIndex = nVideoFrames;
        end
        
        
        if isempty(varInput.LoadAllFrames) | ~varInput.LoadAllFrames
            
            currentFrameIndexLocation = find(VIDEO.frames.index == currentFrameIndex);
            while isempty(VIDEO.frames.image{currentFrameIndexLocation})
                [vidFrame,vidObj,gazePos,NextVideoFrameIndex] = frameExtract(PUPIL,VideoFile,StartTime,NextVideoFrameIndex,'VideoObject',vidObj);
                nFramesExtracted = nFramesExtracted + 1;
                VIDEO.frames.index(nFramesExtracted,1) = NextVideoFrameIndex-1;
                VIDEO.frames.matlabIndex(nFramesExtracted,1) = NextVideoFrameIndex;
                VIDEO.frames.time(nFramesExtracted,1) = vidObj.CurrentTime;
                vidFrame = imresize(vidFrame,varInput.ImageDownSize);
                VIDEO.frames.image(nFramesExtracted,1) = {vidFrame};
                VIDEO.frames.gazePos(nFramesExtracted,1) = {gazePos};
                disp(['Extracting Frame ' num2str(nFramesExtracted-1) '/' num2str(nVideoFrames)]);
            end
            
            extractedFramePosition = find(VIDEO.frames.index == currentFrameIndex);
            extractedFrame = cell2mat(VIDEO.frames.image(extractedFramePosition,1));
            
        else
            
            extractedFramePosition = find(VIDEO.frames.index == currentFrameIndex);
            if isempty(VIDEO.frames.image{extractedFramePosition})
                VIDEO.frames.image = cell(size(VIDEO.frames,1),1);
                VIDEO.frames.gazePos = cell(size(VIDEO.frames,1),1);
                loadedData = load([masterFolder VIDEO.frames.fileName{extractedFramePosition}]);
                VIDEO.frames.image = loadedData.VIDEO.frames.image;
                VIDEO.frames.gazePos = loadedData.VIDEO.frames.gazePos;
                VIDEO.frames.fileName = fileList;
            end
            extractedFrame = cell2mat(VIDEO.frames.image(extractedFramePosition,1));
            
        end
        
        if varInput.PlotGazePosition
            extractedFrame = extractGazePos;
        end
        
        image(extractedFrame, 'Parent', hVideoFrame);
        hVideoFrame.Visible = 'off';
        hCurrentFrame.String = currentFrameIndex;
        hCurrentTime.String = ['Time: ' num2str(VIDEO.frames.time(VIDEO.frames.index == currentFrameIndex))];
        
        PlotLuminance();
        
    end

    function hStimList_Callback(source,~)
        
        ImageToLoad = STIM.Info.ItemName{source.Value};
        StimImage = imread([STIM.Folder ImageToLoad]);
        
        image(StimImage, 'Parent', hStimImage);
        
        hCurrentOnsetFrame.String = GAZE(source.Value).Onset_Frame;
        hCurrentOnsetTime.String = GAZE(source.Value).Onset_Time;
        
        hCurrentOffsetFrame.String = GAZE(source.Value).Offset_Frame;
        hCurrentOffsetTime.String = GAZE(source.Value).Offset_Time;
        
        hStimImage.Visible = 'off';
        
    end

    function hEncodeCurrentFrame_Onset_Callback(~,~)
                
        FrameOnsetTime = VIDEO.frames.time(VIDEO.frames.index == currentFrameIndex);
        
        if isnan(FrameOnsetTime)
            warning(['Frame ' num2str(currentFrameIndex) ' has not yet been read by the video reader. Navigate to the frame before noting the frame.'])
            return
        end
        
        hCurrentOnsetTime.String = FrameOnsetTime;
        hCurrentOnsetFrame.String = currentFrameIndex;
        
        GAZE(hStimList.Value).Onset_Frame = currentFrameIndex;
        GAZE(hStimList.Value).Onset_Time = FrameOnsetTime;
        
        for iStim = 1:height(STIM.Info)
            STIM.Info.ListBoxName{iStim} = [STIM.Info.ItemName{iStim} ' (' STIM.Info.Surface{iStim} ') - ' num2str(GAZE(iStim).Onset_Frame) '/' num2str(GAZE(iStim).Offset_Frame)];
        end
        
        hStimList.String = STIM.Info.ListBoxName;
        
        try
            SystemTime_Gaze = median(VIDEO.frames.gazePos{VIDEO.frames.index == currentFrameIndex}.gaze_timestamp);
        catch
            warning('System timestamp could not be extracted using gaze positions, possibly due to no gaze positions for this frame.')
        end
        
        SystemTime_Frame = StartTime + FrameOnsetTime;
        
        GAZE(hStimList.Value).Onset_Time_Gaze = SystemTime_Gaze;
        GAZE(hStimList.Value).Onset_Time_Frame = SystemTime_Frame;
        
        saveFileFunc_FirstGazePos();
        
        SyncOnset();
        
    end

    function hEncodeCurrentFrame_Offset_Callback(~,~)
        
        FrameOffsetTime = VIDEO.frames.time(VIDEO.frames.index == currentFrameIndex);
        
        if isnan(FrameOffsetTime)
            warning(['Frame ' num2str(currentFrameIndex) ' has not yet been read by the video reader. Navigate to the frame before noting the frame.'])
            return
        end
        
        hCurrentOffsetTime.String = FrameOffsetTime;
        hCurrentOffsetFrame.String = currentFrameIndex;
        
        GAZE(hStimList.Value).Offset_Frame = currentFrameIndex;
        GAZE(hStimList.Value).Offset_Time = FrameOffsetTime;
        
        for iStim = 1:height(STIM.Info)
            STIM.Info.ListBoxName{iStim} = [STIM.Info.ItemName{iStim} ' (' STIM.Info.Surface{iStim} ') - ' num2str(GAZE(iStim).Onset_Frame) '/' num2str(GAZE(iStim).Offset_Frame)];
        end
        
        hStimList.String = STIM.Info.ListBoxName;
        
        try
            SystemTime_Gaze = median(VIDEO.frames.gazePos{VIDEO.frames.index == currentFrameIndex}.gaze_timestamp);
        catch
            warning('System timestamp could not be extracted using gaze positions, possibly due to no gaze positions for this frame.')
        end
        
        SystemTime_Frame = StartTime + FrameOffsetTime;
        
        GAZE(hStimList.Value).Offset_Time_Gaze = SystemTime_Gaze;
        GAZE(hStimList.Value).Offset_Time_Frame = SystemTime_Frame;
        
        saveFileFunc_FirstGazePos();
        
        SyncOnset();
        
    end

    function hSyncFrame_Callback(source,~)
        
        SyncFrame = str2double(source.String);
        ListIndex = hSyncList.Value;
        EEGLatency = EVENTS(ListIndex).Latency;
        
        OriginalFrame = hCurrentFrame.String;
        
        source = [];
        source.String = num2str(SyncFrame);
        
        hCurrentFrame_Callback(source,[]);
        
        try
            SystemTimestamp = median(VIDEO.frames.gazePos{VIDEO.frames.index == SyncFrame}.gaze_timestamp);
        catch
            warning on
            if isnan(VIDEO.frames.time(VIDEO.frames.index == SyncFrame))
                warning('No gaze position for this frame. Navigate to this frame first to extract gaze position.')
            else
                warning('No gaze position for this frame. Therefore, system timestamp cannot be extracted.')
            end
            return
        end
        
        SYNC.Latency_EEG = EEGLatency;
        SYNC.Frame = SyncFrame;
        SYNC.Latency_ET = SystemTimestamp;
        
        hSyncFrame.String = SyncFrame;
        
        [hCurrentEventLatency,hCurrentEventFrame,hPredictedEventLatency] = ProduceTriggerBoxes();
        
        source = [];
        source.String = OriginalFrame;
        
        hCurrentFrame_Callback(source,[]);
        
    end

    function extractedFrame2 = extractGazePos
        
        extractedFrame2 = extractedFrame;
        
        if ~isempty(VIDEO.frames.gazePos{extractedFramePosition})
            currentGazePos = [];
            
            % Based on mean of all values.
            
            % %             currentGazePos.xMean = mean(VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_x(VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_x >= -varInput.GazePosLimitX & VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_x <= varInput.GazePosLimitX));
            % %             currentGazePos.yMean = mean(VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_y(VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_y >= -varInput.GazePosLimitY & VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_y <= varInput.GazePosLimitY));
            
            % Based on max confidence.
            
            % %             currentGazePos.xMean = VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_x(nearest(VIDEO.frames.gazePos{extractedFramePosition,1}.confidence,max(VIDEO.frames.gazePos{extractedFramePosition,1}.confidence)));
            % %             currentGazePos.yMean = VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_y(nearest(VIDEO.frames.gazePos{extractedFramePosition,1}.confidence,max(VIDEO.frames.gazePos{extractedFramePosition,1}.confidence)));
            
            % Based on mean of all gaze positions exceding confidence threshold.
            
            currentGazePos.xMean = mean(VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_x(VIDEO.frames.gazePos{extractedFramePosition,1}.confidence >= varInput.GazeConfidenceThreshold));
            currentGazePos.yMean = mean(VIDEO.frames.gazePos{extractedFramePosition,1}.norm_pos_y(VIDEO.frames.gazePos{extractedFramePosition,1}.confidence >= varInput.GazeConfidenceThreshold));
            
            currentGazePos.yMean = abs(currentGazePos.yMean - 1);
            
            currentGazePos.xMean_MatlabCord = size(extractedFrame,2) * currentGazePos.xMean;
            currentGazePos.yMean_MatlabCord = size(extractedFrame,1) * currentGazePos.yMean;
            
            if ~isnan(currentGazePos.xMean)
                try
                    extractedFrame2 = insertShape(extractedFrame, ...
                        'circle',[currentGazePos.xMean_MatlabCord currentGazePos.yMean_MatlabCord varInput.GazeCircle], ...
                        'LineWidth',5);
                catch
                    extractedFrame2 = extractedFrame;
                end
            else
                extractedFrame2 = extractedFrame;
            end
        else
            disp('No Gaze Position Found')
            disp(['Frame ' num2str(VIDEO.frames.index(extractedFramePosition))])
        end
        
    end

% % %     function encodeTimes
% % %         for iGaze = 1:size(MASTER,1)
% % %             currentIndex = find(VIDEO.frames.index == MASTER.onset_frame(iGaze));
% % %             if ~isempty(currentIndex)
% % %                 MASTER.onset_time(iGaze) = VIDEO.frames.time(currentIndex);
% % %             else
% % %                 disp(['Timestamp not found for frame ' num2str( MASTER.onset_frame(iGaze))])
% % %             end
% % %         end
% % %     end

% % %     function encodeTotalGazeTime
% % %         for iGaze = 1:size(MASTER,1)
% % %             MASTER.gaze_time(iGaze) = MASTER.offset_time(iGaze) - MASTER.onset_time(iGaze);
% % %         end
% % %     end

    function saveFileFunc_FirstGazePos()
        [saveDir,~,~] = fileparts(Output_FirstGazePos);
        if ~exist(saveDir,'file')
            mkdir(saveDir);
        end
        SaveData = struct2table(GAZE);
        try
            writetable(SaveData,Output_FirstGazePos)
        catch
            disp('Invalid Save File')
            disp('Saving Temp File')
            count = 1;
            tempSave = ['TEMP_XLS_FILE_' nDigitString(count,3) '.xlsx'];
            while exist(tempSave,'file')
                count = count + 1;
                tempSave = ['TEMP_XLS_FILE_' nDigitString(count,3) '.xlsx'];
            end
            writetable(SaveData,Output_FirstGazePos)
        end
    end

    function saveFileFunc_TriggerFrame()
        [saveDir,~,~] = fileparts(Output_TriggerFrame);
        if ~exist(saveDir,'file')
            mkdir(saveDir);
        end
        SaveData = struct2table(EVENTS);
        try
            writetable(SaveData,Output_TriggerFrame)
        catch
            disp('Invalid Save File')
            disp('Saving Temp File')
            count = 1;
            tempSave = ['TEMP_XLS_FILE_' nDigitString(count,3) '.xlsx'];
            while exist(tempSave,'file')
                count = count + 1;
                tempSave = ['TEMP_XLS_FILE_' nDigitString(count,3) '.xlsx'];
            end
            writetable(SaveData,Output_TriggerFrame)
        end
    end

    function [hCurrentEventLatency2,hCurrentEventFrame2,hPredictedEventLatency2] = ProduceTriggerBoxes()
        
        hCurrentEventLatency2 = [];
        hCurrentEventFrame2 = [];
        hPredictedEventLatency2 = [];
        
        DL = BOXCONFIG.DistFromLeft;
        DB = (BOXCONFIG.DistFromBottom) - ((-2) * BOXCONFIG.DistBetweenBoxes);
        
        W = BOXCONFIG.BoxWidth;
        H = BOXCONFIG.BoxHeight;
        
        hCurrentEventLatencyTitle2 = [];
        hCurrentEventLatencyTitle2 = uicontrol('Style','text','String','Event # (Latency)','Unit','normalized',...
            'Position',[DL,DB,W,H]);
        
        DL = BOXCONFIG.DistFromLeft + (BOXCONFIG.BoxWidth + BOXCONFIG.DistBetweenBoxes);
        
        hCurrentEventFrameTitle2 = [];
        hCurrentEventFrameTitle2 = uicontrol('Style','text','String','Video Frame','Unit','normalized',...
            'Position',[DL,DB,W,H]);
        
        DL = BOXCONFIG.DistFromLeft + ((BOXCONFIG.BoxWidth + BOXCONFIG.DistBetweenBoxes) *2);
        
        hCurrentEventFrameTitle2 = [];
        hCurrentEventFrameTitle2 = uicontrol('Style','text','String','Delete','Unit','normalized',...
            'Position',[DL,DB,W,H]);
        
        if ~isempty(SYNC.Frame)
            
            DL = BOXCONFIG.DistFromLeft + ((BOXCONFIG.BoxWidth + BOXCONFIG.DistBetweenBoxes) *3);
            
            hPredictedEventLatencyTitle2 = [];
            hPredictedEventLatencyTitle2 = uicontrol('Style','text','String','Predicted Frame','Unit','normalized',...
                'Position',[DL,DB,W,H]);
            
        end
        
        for iEvent = 1:length(EVENTS)
            
            DL = BOXCONFIG.DistFromLeft;
            DB = (BOXCONFIG.DistFromBottom - (BOXCONFIG.BoxHeight * iEvent)) - ((iEvent-1) * BOXCONFIG.DistBetweenBoxes);
            
            W = BOXCONFIG.BoxWidth;
            H = BOXCONFIG.BoxHeight;
            
            hCurrentEventLatency2(iEvent) = uicontrol('Style','pushbutton','String',[num2str(EVENTS(iEvent).Index) ' (' num2str(EVENTS(iEvent).Latency) ')'],'Unit','normalized',...
                'Position',[DL,DB,W,H],...
                'UserData',EVENTS(iEvent));
            
            DL = BOXCONFIG.DistFromLeft + (BOXCONFIG.BoxWidth + BOXCONFIG.DistBetweenBoxes);
            
            hCurrentEventFrame2(iEvent) = uicontrol('Style','edit','String',EVENTS(iEvent).VideoFrame,'Unit','normalized',...
                'Position',[DL,DB,W,H],...
                'Callback',@hCurrentEventLatency_Callback, ...
                'UserData',EVENTS(iEvent));
            
            DL = BOXCONFIG.DistFromLeft + ((BOXCONFIG.BoxWidth + BOXCONFIG.DistBetweenBoxes) * 2);
            
            hDeleteEvent2(iEvent) = uicontrol('Style','pushbutton','String','DELETE','Unit','normalized',...
                'Position',[DL,DB,W,H],...
                'Callback',@hDeleteEvent2_Callback, ...
                'BackgroundColor',[1 0 0], ...
                'UserData',EVENTS(iEvent));
            
            if ~isempty(SYNC.Frame)
                
                PredictedETLatency = ((EVENTS(iEvent).Latency - SYNC.Latency_EEG) / 1000000) + SYNC.Latency_ET;
                PredictedFrame = PUPIL.GazePositions.world_index(nearest(PUPIL.GazePositions.gaze_timestamp,PredictedETLatency));
                
                DL = BOXCONFIG.DistFromLeft + ((BOXCONFIG.BoxWidth + BOXCONFIG.DistBetweenBoxes) *3);
                
                hPredictedEventLatency2 = [];
                hPredictedEventLatency2(iEvent) = uicontrol('Style','pushbutton','String',PredictedFrame,'Unit','normalized',...
                    'Position',[DL,DB,W,H],...
                    'Callback',@hPredictedEventLatency_Callback, ...
                    'UserData',struct('PredictedFrame',PredictedFrame));
                
            end
            
            
            
        end
    end

    function hDeleteEvent2_Callback(source,~)
        
        DeletionIndex = find([EVENTS.Index] == source.UserData.Index);
        
        answer = questdlg('Delete this event?', ...
            'Confirm Deletion', ...
            'Yes', 'No','No');
        
        switch answer
            case 'Yes'
                disp(['Deleting Event ' num2str(EVENTS(DeletionIndex).Index) '...'])
                EVENTS(DeletionIndex) = [];
                [hCurrentEventLatency,hCurrentEventFrame,hPredictedEventLatency] = ProduceTriggerBoxes();
                saveFileFunc_TriggerFrame()
            case 'No'
                return
        end
        
        SyncOnset();
        
    end

    function hCurrentEventLatency_Callback(source,~)
        
        TriggerFrame = source.String;
        
        TriggerIndex = source.UserData.Index;
        
        OriginalFrame = currentFrameIndex;
        
        EVENTS(TriggerIndex).VideoFrame = TriggerFrame;
        
        source2 = [];
        source2.String = TriggerFrame;
        hCurrentFrame_Callback(source2,[]);
        
        EVENTS(TriggerIndex).ET_Time = median(VIDEO.frames.gazePos{VIDEO.frames.index == str2double(TriggerFrame)}.gaze_timestamp);
        
        source2 = [];
        source2.String = num2str(OriginalFrame);
        hCurrentFrame_Callback(source2,[]);
        
        saveFileFunc_TriggerFrame()
        
        SyncOnset();
        
    end

    function hPredictedEventLatency_Callback(source,~)
        
        source2 = [];
        source2.String = num2str(source.UserData.PredictedFrame);
        
        hCurrentFrame_Callback(source2,[]);
        
    end

    function PlotLuminance()
        
        CurrentFrameRange = currentFrameIndex-50:currentFrameIndex+50;
        
        if varInput.LoadAllFrames
            Luminance = [];
            for iFrame = 1:length(CurrentFrameRange)
                TEMP = [];
                TEMP.CurrentFrame = CurrentFrameRange(iFrame);
                TEMP.FrameIndex = find(VIDEO.frames.index == TEMP.CurrentFrame);
                if ~isempty(TEMP.FrameIndex)
                    Luminance(iFrame) = VIDEO.frames.luminance(TEMP.FrameIndex);
                else
                    Luminance(iFrame) = 0;
                end
            end
        else
            disp('Cannot plot luminance with ''LoadAllFrames'' parameter of 0')
            return
        end
        
        delete(hLuminance);
        
        hLuminance = axes('Units','Pixels','Unit','normalized','Position',[0.55,0.7,0.15,0.2]);
        
        plot(CurrentFrameRange,Luminance,'black'); hold on;
        title('Luminace')
        xlabel('Frame')
        ylabel('Mean Luminance')
        
        axis([CurrentFrameRange(1) CurrentFrameRange(end) 0 1])
        
        vline(currentFrameIndex,'red');
        
    end






    function SyncOnset()
        
        if any(~isnan([EVENTS.VideoFrame]))
            
            Sync_All = EVENTS(~isnan([EVENTS.VideoFrame]));
            
            IgnoredEvents_Onset = zeros(size(GAZE,1),1);
            IgnoredEvents_Offset = zeros(size(GAZE,1),1);
            
            for iGaze = 1:size(GAZE,1)
                
                TEMP = [];
                
                TEMP.PotentialSyncEvents_Onset = Sync_All([Sync_All.ET_Time] <= GAZE(iGaze).Onset_Time_Gaze);
                
                if ~isempty(TEMP.PotentialSyncEvents_Onset)
                    TEMP.SyncEvent_Onset = TEMP.PotentialSyncEvents_Onset(nearest([TEMP.PotentialSyncEvents_Onset.ET_Time],GAZE(iGaze).Onset_Time_Gaze));
                    TEMP.Gaze_EEG_Time_Onset = ((GAZE(iGaze).Onset_Time_Gaze - TEMP.SyncEvent_Onset.ET_Time) + (TEMP.SyncEvent_Onset.Latency / 1000000)) * 1000000;
                    GAZE(iGaze).Onset_Time_EEG = TEMP.Gaze_EEG_Time_Onset;
                else
                    GAZE(iGaze).Onset_Time_EEG = NaN;
                    if ~isnan(GAZE(iGaze).Onset_Time_Gaze)
                        IgnoredEvents_Onset(iGaze) = 1;
                    end
                end
                
                TEMP.PotentialSyncEvents_Offset = Sync_All([Sync_All.ET_Time] <= GAZE(iGaze).Offset_Time_Gaze);
                
                if ~isempty(TEMP.PotentialSyncEvents_Offset)
                    TEMP.SyncEvent_Offset = TEMP.PotentialSyncEvents_Offset(nearest([TEMP.PotentialSyncEvents_Offset.ET_Time],GAZE(iGaze).Offset_Time_Gaze));
                    TEMP.Gaze_EEG_Time_Offset = ((GAZE(iGaze).Offset_Time_Gaze - TEMP.SyncEvent_Offset.ET_Time) + (TEMP.SyncEvent_Offset.Latency / 1000000)) * 1000000;
                    GAZE(iGaze).Offset_Time_EEG = TEMP.Gaze_EEG_Time_Offset;
                else
                    GAZE(iGaze).Offset_Time_EEG = NaN;
                    if ~isnan(GAZE(iGaze).Offset_Time_Gaze)
                        IgnoredEvents_Offset(iGaze) = 1;
                    end
                end
                
            end
            
            if any(IgnoredEvents_Onset)
                disp(['Onset encoded, but no event found to precede items [' strjoin(strrep(cellstr(num2str(find(IgnoredEvents_Onset))),' ',''),' ') ']'])
            end
            
            if any(IgnoredEvents_Offset)
                disp(['Offset encoded, but no event found to precede items [' strjoin(strrep(cellstr(num2str(find(IgnoredEvents_Onset))),' ',''),' ') ']'])
            end
            
        end
        
    end

    function hCurrentOnsetFrame_Callback(source,~)
        
        OriginalFrame = hCurrentFrame.String;
        
        source2 = [];
        source2.String = num2str(SyncFrame);
        hCurrentFrame_Callback(source2,[]);
        
        FrameOnsetTime = VIDEO.frames.time(VIDEO.frames.index == str2num(source.String));
        
        hCurrentOnsetTime.String = FrameOnsetTime;
        hCurrentOnsetFrame.String = str2num(source.String);
        
        GAZE(hStimList.Value).Onset_Frame = str2num(source.String);
        GAZE(hStimList.Value).Onset_Time = FrameOnsetTime;
        
        for iStim = 1:height(STIM.Info)
            STIM.Info.ListBoxName{iStim} = [STIM.Info.ItemName{iStim} ' (' STIM.Info.Surface{iStim} ') - ' num2str(GAZE(iStim).Onset_Frame) '/' num2str(GAZE(iStim).Offset_Frame)];
        end
        
        hStimList.String = STIM.Info.ListBoxName;
        
        try
            SystemTime_Gaze = median(VIDEO.frames.gazePos{VIDEO.frames.index == str2num(source.String)}.gaze_timestamp);
        catch
            SystemTime_Gaze = NaN;
            warning('System timestamp could not be extracted using gaze positions, possibly due to no gaze positions for this frame.')
        end
        
        SystemTime_Frame = StartTime + FrameOnsetTime;
        
        GAZE(hStimList.Value).Onset_Time_Gaze = SystemTime_Gaze;
        GAZE(hStimList.Value).Onset_Time_Frame = SystemTime_Frame;
        
        saveFileFunc_FirstGazePos();
        
        SyncOnset();
        
        source2 = [];
        source2.String = OriginalFrame;
        hCurrentFrame_Callback(source2,[]);
        
    end

    function hCurrentOffsetFrame_Callback(source,~)
        
        OriginalFrame = hCurrentFrame.String;
        
        source2 = [];
        source2.String = num2str(SyncFrame);
        hCurrentFrame_Callback(source2,[]);
        
        FrameOffsetTime = VIDEO.frames.time(VIDEO.frames.index == str2num(source.String));
        
        hCurrentOffsetTime.String = FrameOffsetTime;
        hCurrentOffsetFrame.String = str2num(source.String);
        
        GAZE(hStimList.Value).Offset_Frame = str2num(source.String);
        GAZE(hStimList.Value).Offset_Time = FrameOffsetTime;
        
        for iStim = 1:height(STIM.Info)
            STIM.Info.ListBoxName{iStim} = [STIM.Info.ItemName{iStim} ' (' STIM.Info.Surface{iStim} ') - ' num2str(GAZE(iStim).Onset_Frame) '/' num2str(GAZE(iStim).Offset_Frame)];
        end
        
        hStimList.String = STIM.Info.ListBoxName;
        
        try
            SystemTime_Gaze = median(VIDEO.frames.gazePos{VIDEO.frames.index == str2num(source.String)}.gaze_timestamp);
        catch
            SystemTime_Gaze = NaN;
            warning('System timestamp could not be extracted using gaze positions, possibly due to no gaze positions for this frame.')
        end
        
        SystemTime_Frame = StartTime + FrameOffsetTime;
        
        GAZE(hStimList.Value).Offset_Time_Gaze = SystemTime_Gaze;
        GAZE(hStimList.Value).Offset_Time_Frame = SystemTime_Frame;
        
        saveFileFunc_FirstGazePos();
        
        SyncOnset();
        
        source2 = [];
        source2.String = OriginalFrame;
        hCurrentFrame_Callback(source2,[]);
        
    end


end




