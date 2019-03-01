% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 25/01/2019
%
% Current version = v1.0
%
% This will take a directory with N folders in it. Each of these folders
% should correspond to a subject, with each subject folder containing a set
% file for each condition. This will iterate through each folder and merge
% the set files into new set files depending on the input. This is good if
% you want to create set files that are merged across conditions.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% folder            -   Folder containing subject folders.
% fileAppendice     -   Cell array containing a cell array for each new
%                       condition, containing the names of the set files
%                       that we wish to merge.
% fileAppendiceNew  -   Cell array of conditions corresponding to the
%                       length of filleAppendice, indicating the names of
%                       the new conditions.
% saveDir           -   Directory in which new set files will be saved. A
%                       new folder for each subject will be made. If this
%                       is the same as the folder input, it will save them
%                       in the same folder.
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
% 
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% mergeDatasetsInFolders(   'D:/dataDir/', ...
%                           {{'C1' 'C2'} {'C3' 'C4'}}, ...
%                           {'C1C2' 'C3C4'}, ...
%                           ,'D:/dataDirNew/')
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% EEGLab (Toolbox)
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 25/01/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function mergeDatasetsInFolders(folder,fileAppendice,fileAppendiceNew,saveDir)

foldersInDir = ls(folder);

STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

for iFolder = 3:size(foldersInDir,1)
    
    currentFolder = [folder foldersInDir(iFolder,:) '\'];
    currentSaveDir = [saveDir foldersInDir(iFolder,:) '\'];
    currentFiles = cellstr(ls([currentFolder '*.set']));
    
    if ~exist(currentSaveDir); mkdir(currentSaveDir); end
    
    for iCombo = 1:length(fileAppendice)
        for iFile = 1:length(fileAppendice{iCombo})
            comboIndices{iCombo}(iFile) = find(not(cellfun('isempty',strfind(currentFiles,fileAppendice{iCombo}{iFile}))));
            comboPrefixes{iCombo}{iFile} = strrep(currentFiles(comboIndices{iCombo}(iFile)),fileAppendice{iCombo}{iFile},'');
        end
    end
    
    for iCombo = 1:length(fileAppendice)
        
        currentFilesToLoad = currentFiles(comboIndices{iCombo})';
        EEG = pop_loadset('filename',currentFilesToLoad,'filepath',currentFolder);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'study',0);
        EEG = pop_mergeset( ALLEEG, 1:length(currentFilesToLoad), 1);
        
        newSetName = [cell2mat(comboPrefixes{iCombo}{1}) cell2mat(fileAppendiceNew{iCombo})];
        newSetName = strrep(newSetName,'.set','');
        
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off','setname',newSetName);
        
        EEG = pop_saveset( EEG, 'filename',[newSetName '.set'],'filepath',currentSaveDir);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
        STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

    end
    
    
end