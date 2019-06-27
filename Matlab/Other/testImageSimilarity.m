% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 23/10/2018
%
% Current version = v1.0
%
% Given a directory of images, this will scan through all possible pairs of
% images and test for a high level of similarity. This comes in handy if
% you are gathering stimuli from multiple sources and images become mixed
% up.
%
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% directory     -   Directory containing images.
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
% testImageSimilarity('D:\myImageDir\')
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
% 23/10/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function testImageSimilarity(directory)

similarityThreshold = 30;

files = dir(directory);
files(1:2) = [];

nFiles = size(files,1);

try
    combos = combntns(1:nFiles,2);
catch
    combos = nchoosek(1:nFiles,2);
end

elapsedTime = []; similarity = [];
for iFile = 1:size(combos,1)
    
    tic
    
    referenceImage = imread([files(combos(iFile,1)).folder '\' files(combos(iFile,1)).name]);
    compImage = imread([files(combos(iFile,2)).folder '\' files(combos(iFile,2)).name]);
    
    %     similarity(iFile,1) = ssim(compImage,referenceImage);
    %     similarity(iFile,1) = immse(compImage,referenceImage);
    similarity(iFile,1) = psnr(compImage,referenceImage);
    
    
    elapsedTime(iFile) = toc;
    timeRemaining = (size(combos,1) - iFile) * mean(elapsedTime);
    
    disp(['Comparison ' num2str(iFile) '/' num2str(size(combos,1)) '; ' num2str(timeRemaining) ' secs remaining'])
    
end

% Find perfect matches.

infIndex = similarity == Inf;
infCombos = combos(infIndex,:);

for iMatch = 1:size(infCombos,1)
    
    match1 = files(infCombos(iMatch,1)).name;
    match2 = files(infCombos(iMatch,2)).name;
    
    disp(['Identical Match Between ' match1 ' & ' match2])
    
    figure;
    
    match1im = imread([files(infCombos(iMatch,1)).folder '\' files(infCombos(iMatch,1)).name]);
    match2im = imread([files(infCombos(iMatch,2)).folder '\' files(infCombos(iMatch,2)).name]);
    
    match1RegExpRep = regexprep(match1,'_',' ');
    match2RegExpRep = regexprep(match2,'_',' ');
    
    subplot(2,1,1)
    imshow(match1im);
    title(['Identical Match; ' match1RegExpRep]);
    
    subplot(2,1,2)
    imshow(match2im);
    title(['Identical Match; ' match2RegExpRep]);
    
end

% Find highly similar (>20 psnr).

highSim = find(similarity > similarityThreshold & similarity ~= Inf);
highSimCombos = combos(highSim,:);

for iMatch = 1:size(highSimCombos,1)
    
    match1 = files(highSimCombos(iMatch,1)).name;
    match2 = files(highSimCombos(iMatch,2)).name;
    
    disp(['High Match Between ' match1 ' & ' match2])
    
    figure;
    
    match1im = imread([files(highSimCombos(iMatch,1)).folder '\' files(highSimCombos(iMatch,1)).name]);
    match2im = imread([files(highSimCombos(iMatch,2)).folder '\' files(highSimCombos(iMatch,2)).name]);
    
    match1RegExpRep = regexprep(match1,'_',' ');
    match2RegExpRep = regexprep(match2,'_',' ');
    
    subplot(2,1,1)
    imshow(match1im);
    title(['Highly Similar; ' match1RegExpRep '; ' num2str(similarity(highSim(iMatch)))]);
    
    subplot(2,1,2)
    imshow(match2im);
    title(['Highly Similar; ' match2RegExpRep '; ' num2str(similarity(highSim(iMatch)))]);
    
end

end