% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 05/06/2018
%
% Current version = v1.0
%
% Will find peaks within a given array of Nx1 / 1xN. NOTE THAT NO
% LOGIC IS GIVEN FOR WHAT SHOULD HAPPEN WHEN A PEAK IS EQUAL FOR TWO
% CONSECUTIVE TIME POINTSs.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% data      -   Nx1 or 1xN array of data.
% overlap   -   The script will find peaks and if multiple peaks are found
%               within the latency (Peak Latency +/- overlap), it will find
%               the largest peak and remove the others.
% threshold -   This will only find peaks that occur above a certain
%               percentage of maximum power. If data is normalised, then
%               value is between 0 and 1.
% norm      -   Whether to normalise data first between 0 and 1.
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% peakLatencies     -   The latencies at which the data peaks given a
%                       certain overlap and threshold.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% peakLatencies = findPeaks([0 2 4 6 8 6 4 2 0],10,6,0)
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 05/06/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function peakLatencies = findPeaks(data,overlap,threshold,norm)

if ndims(data) > 2
    error('Data has too many dimensions ( > 2 )')
end

if size(data,2) > 1
    if size(data,1) > 1
        error('One dimension must be singular')
    end
    data = data';
end

if norm == 1
    dataNorm = normaliseData(data,0,1);
else
    dataNorm = data;
end

peakCount = 0; peakLatencies = [];
for iLat = 1:length(dataNorm)-1
    
    if iLat == 1
        if dataNorm(iLat,1) > dataNorm(iLat+1,1) && dataNorm(iLat,1) > threshold
            peakCount = peakCount + 1;
            peakLatencies(peakCount,1) = iLat;
        end
    else
        if dataNorm(iLat,1) > dataNorm(iLat+1,1) && dataNorm(iLat,1) > dataNorm(iLat-1,1) && dataNorm(iLat,1) > threshold
            peakCount = peakCount + 1;
            peakLatencies(peakCount,1) = iLat;
        end
    end
    
end

finished = 0; peakIndex = 1;
while finished == 0
    
    LOOP = [];
    
    LOOP.currentPeak = peakLatencies(peakIndex);
    
    LOOP.currentSpan = LOOP.currentPeak-overlap:LOOP.currentPeak+overlap;
    
    LOOP.currentOverlapIndex = find(ismember(peakLatencies,LOOP.currentSpan));
    
    if peakIndex >= length(peakLatencies)
        finished = 1;
    end
    
    if length(LOOP.currentOverlapIndex) == 1
        peakIndex = peakIndex + 1;
        continue
    else
        
        LOOP.currentOverlap = peakLatencies(LOOP.currentOverlapIndex);
        
        LOOP.allPeakMax = dataNorm(LOOP.currentOverlap,1);
        
        LOOP.totalPeakMax = nearest(LOOP.allPeakMax,max(LOOP.allPeakMax));
        
        LOOP.peakToKeepIndex = LOOP.currentOverlapIndex(LOOP.totalPeakMax);
        LOOP.peakToRemoveIndex = LOOP.currentOverlapIndex(LOOP.currentOverlapIndex ~= LOOP.peakToKeepIndex);
        
        peakLatencies(LOOP.peakToRemoveIndex) = [];
        
    end
    
end
