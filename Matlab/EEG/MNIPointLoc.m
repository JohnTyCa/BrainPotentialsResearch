% ======================================================================= %
%
% Created by John Tyson-Carr
%
% First Created 11/02/2019
%
% Current version = v1.0
%
% This will take an MNI coordinate (XYZ) and return the region that it most
% likely bekongs to. This uses an online database and function 
% 'cuixuFindStructure' produced Xu Cui (2007). This function can return the
% nearest Brodmann area, or nearest GrayMatter, or all regions within a
% specified cube of NxNxN mm.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% MNI   -   MNI coordinate to identify (XYZ).
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% DBFile                -   The path the the 'TDdatabase.mat' file.
%                           Will default to the current dir (DEFAULT: [])
% CubeSpace             -   Whether to extract a cube of regions. 
%                           (DEFAULT: 0)
% CubeSpaceSize         -   Size of cube (mm). (DEFAULT: 5)
% CubeSpaceDist         -   Distance between points. (DEFAULT: 0.2)
% NearestGrayMatter     -   Whether to extract nearest gray matter. 
%                           (DEFAULT: 0)
% NearestBrodmann       -   Whether to extract nearest Brodmann area. 
%                           (DEFAULT: 0)
% Search_SizeIteration  -   When searching through regions for either the
%                           nearest Brodmann or Gray Matter, this defines
%                           how much to extend the search area by on each
%                           iteration. Note that, in order to save
%                           computing time, a cube will be created of
%                           coordinates and only the surface coordinates
%                           will be localised. Each iteration, the cube
%                           will increase in size. (DEFAULT: 1)
% Search_Dist           -   Distance between coordinates when searching.
%                           (DEFAULT: 0.2)
% Search_StopThreshold  -   Size of cube when we should stop searching.
%                           (DEFAULT: 20)
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% COORDSPACE    -   Structure with information on source localisation.
% sourceError   -   Whether an error was found during search.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% [COORDSPACE,sourceError] = MNIPointLoc(MNI, ...
%           'DBFile', 'D:\DBDirectory\', ...
%           'NearestBrodmann', 1);
% 
% ======================================================================= %
% Dependencies.
% ======================================================================= %
% 
% cuixuFindStructure
% nearest
% uniqueRowsCA
% createSurfaceCube
% 
% ======================================================================= %
% UPDATE HISTORY:
%
% 11/02/2019 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function [COORDSPACE,sourceError] = MNIPointLoc(MNI,varargin)

% ======================================================================= %
% Variable Argument Input Definitions.
% ======================================================================= %

varInput = [];
for iVar = 1:2:length(varargin)
    varInput = setfield(varInput, varargin{iVar}, varargin{iVar+1});
end;
if ~isfield(varInput, 'DBFile'), varInput.DBFile = 'TDdatabase.mat'; end
if ~isfield(varInput, 'CubeSpace'), varInput.CubeSpace = 0; end
if ~isfield(varInput, 'CubeSpaceSize'), varInput.CubeSpaceSize = 5; end
if ~isfield(varInput, 'CubeSpaceDist'), varInput.CubeSpaceDist = 0.2; end
if ~isfield(varInput, 'NearestGrayMatter'), varInput.NearestGrayMatter = 0; end
if ~isfield(varInput, 'NearestBrodmann'), varInput.NearestBrodmann = 0; end
if ~isfield(varInput, 'Search_SizeIteration'), varInput.Search_SizeIteration = 1; end
if ~isfield(varInput, 'Search_Dist'), varInput.Search_Dist = 0.2; end
if ~isfield(varInput, 'Search_StopThreshold'), varInput.Search_StopThreshold = 20; end

% ======================================================================= %
% Pre-Machine Logic Checks.
% ======================================================================= %

if ~mod(varInput.CubeSpaceSize / varInput.CubeSpaceDist,1) == 0
    error('CubeSpaceSize / CubeSpaceDist Must be an Integer')
else
    FUNCLOOP = [];
    FUNCLOOP.nPoints = varInput.CubeSpaceSize/varInput.CubeSpaceDist;
    FUNCLOOP.nPoints_GrayMatter = varInput.Search_SizeIteration/varInput.Search_Dist;
    if ~mod(FUNCLOOP.nPoints_GrayMatter/2,1)
        FUNCLOOP.nPoints_GrayMatter = FUNCLOOP.nPoints_GrayMatter +1;
    end
    sourceError = 0;
end

if sum([varInput.CubeSpace varInput.NearestGrayMatter varInput.NearestBrodmann]) > 1
    error('Only One Can be Used: "CubeSpace" / "NearestGrayMatter" / "NearestBrodmann"')
end

% ======================================================================= %
% Load DB.
% ======================================================================= %

COORDSPACE = [];
COORDSPACE.centre = MNI;
COORDSPACE.DB_All = load(varInput.DBFile);
COORDSPACE.DB = COORDSPACE.DB_All.DB;

% ======================================================================= %
% Loop Depending on how we Localise the Region.
% ======================================================================= %

if varInput.CubeSpace
    
    % ======================================================================= %
    % Loop for Cube Centred on Coordinate.
    % ======================================================================= %
    
    % Define coordinates for cube.
    
    COORDSPACE.coordCount = 0;
    for iX = 1:FUNCLOOP.nPoints
        FUNCFORLOOP = [];
        FUNCFORLOOP.X = (COORDSPACE.centre(1)-2.5)+(iX*(varInput.CubeSpaceSize / FUNCLOOP.nPoints));
        for iY = 1:FUNCLOOP.nPoints
            FUNCFORLOOP2 = [];
            FUNCFORLOOP2.Y = (COORDSPACE.centre(2)-2.5)+(iY*(varInput.CubeSpaceSize / FUNCLOOP.nPoints));
            for iZ = 1:FUNCLOOP.nPoints
                FUNCFORLOOP3 = [];
                FUNCFORLOOP3.Z = (COORDSPACE.centre(3)-2.5)+(iZ*(varInput.CubeSpaceSize / FUNCLOOP.nPoints));
                COORDSPACE.coordCount = COORDSPACE.coordCount + 1;
                COORDSPACE.coords_3D{iX,iY,iZ} = [FUNCFORLOOP.X FUNCFORLOOP2.Y FUNCFORLOOP3.Z];
                COORDSPACE.coords_3D_Matrix(COORDSPACE.coordCount,:) = [FUNCFORLOOP.X FUNCFORLOOP2.Y FUNCFORLOOP3.Z];
            end
        end
    end
    
    %     scatter3(COORDSPACE.coords_3D_Matrix(:,1),COORDSPACE.coords_3D_Matrix(:,2),COORDSPACE.coords_3D_Matrix(:,3),'bluex'); hold on;
    %     scatter3(COORDSPACE.centre(1),COORDSPACE.centre(2),COORDSPACE.centre(3),'redo')
    
    % ======================================================================= %
    % Search all Coordinates and Note the Region & Distance from Centre.
    % ======================================================================= %
    
    sourceError = 0;
    for iPoint = 1:size(COORDSPACE.coords_3D_Matrix,1)
        try
            [~, COORDSPACE.pointRegions(iPoint,:)] = cuixuFindStructure(COORDSPACE.coords_3D_Matrix(iPoint,:), COORDSPACE.DB);
            COORDSPACE.distFromCentre(iPoint,1) = pdist([COORDSPACE.coords_3D_Matrix(iPoint,:); COORDSPACE.centre],'Euclidean');
            disp([num2str(iPoint) '/' num2str(size(COORDSPACE.coords_3D_Matrix,1)) ' Points Localised']);
        catch
            sourceError = 1;
            COORDSPACE.pointRegions(iPoint,:) = nan(1,6);
            COORDSPACE.distFromCentre(iPoint,1) = NaN;
            disp('Cannot Localise Points - MNI Coordinates Return Undefined Location')
            disp('Coordinates are Likely Outside of Head')
            return
        end
    end
    
    % ====================================================================    %
    % Here, we now have the brain regions in a cubic range around the
    % centroid of the mean cluster dipole. We also have the distance from
    % the centre for each region.
    
    % Therefore, we will count the number of samples demonstrating each
    % region and the nearest brodmann / gray matter region.
    % ======================================================================= %
    
    COORDSPACE.cerebrum = unique(COORDSPACE.pointRegions(:,1));
    COORDSPACE.lobe = unique(COORDSPACE.pointRegions(:,2));
    COORDSPACE.region = unique(COORDSPACE.pointRegions(:,3));
    COORDSPACE.matter = unique(COORDSPACE.pointRegions(:,4));
    COORDSPACE.brodmann = unique(COORDSPACE.pointRegions(:,5));
    
    [COORDSPACE.uniqueRows,~,COORDSPACE.pointRegionCount] = uniqueRowsCA(COORDSPACE.pointRegions);
    
    for iUnique = 1:size(COORDSPACE.uniqueRows,1)
        COORDSPACE.pointRowCount(iUnique,1) = sum(COORDSPACE.pointRegionCount == iUnique);
        COORDSPACE.pointDistance{iUnique,1} = COORDSPACE.distFromCentre(find(COORDSPACE.pointRegionCount == iUnique));
        COORDSPACE.pointDistance_Mean(iUnique,1) = mean(COORDSPACE.pointDistance{iUnique,1});
        COORDSPACE.pointDistance_SD(iUnique,1) = std(COORDSPACE.pointDistance{iUnique,1});
    end
    
elseif varInput.NearestGrayMatter | varInput.NearestBrodmann
    
    % ======================================================================= %
    % If we want to Find the Nearest Gray Matter or Brodmann Area.
    % ======================================================================= %
    
    MATTERSEARCH = [];
    MATTERSEARCH.matterFound = 0;
    MATTERSEARCH.cubeSize = varInput.Search_SizeIteration;
    MATTERSEARCH.cubeDist = varInput.Search_Dist;
    MATTERSEARCH.searchIteration = 1;
    
    % ======================================================================= %
    % Calculate Coordinates & Localise Region in each Coordinate.
    % ======================================================================= %
    
    % To save computing power, this function creates an initial cube
    % centered on the centre coordinate. These coordinates are converted to
    % "surface coordinates" wherein only points on the surface of the cube
    % are localised. This saves us localising an excessive number of points
    % within the cube.
    
    % This cube is then iteratively expanded until the necessary matter is
    % found. The surface coordinates mean we do not re-localise already
    % localised points.
    
    while ~MATTERSEARCH.matterFound
        
        COORDSPACE.coordsSurface = [];
        COORDSPACE.pointRegions = {};
        COORDSPACE.distFromCentre = [];
        
        COORDSPACE.coordsSurface = createSurfaceCube(COORDSPACE.centre,MATTERSEARCH.cubeSize,MATTERSEARCH.cubeDist);
        
        sourceError = 0;
        for iPoint = 1:size(COORDSPACE.coordsSurface,1)
            try
                [~, COORDSPACE.pointRegions(iPoint,:)] = cuixuFindStructure(COORDSPACE.coordsSurface(iPoint,:), COORDSPACE.DB);
                COORDSPACE.distFromCentre(iPoint,1) = pdist([COORDSPACE.coordsSurface(iPoint,:); COORDSPACE.centre],'Euclidean');
                disp(['Localising... ' num2str(iPoint) '/' num2str(size(COORDSPACE.coordsSurface,1)) '; Iteration ' num2str(MATTERSEARCH.searchIteration) '; Current Cube = ' num2str(MATTERSEARCH.cubeSize) ' mm']);
            catch
                sourceError = 1;
                COORDSPACE.pointRegions(iPoint,:) = nan(1,6);
                COORDSPACE.distFromCentre(iPoint,1) = NaN;
                disp('Cannot Localise Points - MNI Coordinates Return Undefined Location')
                disp('Coordinates are Likely Outside of Head')
                return
            end
        end
        
        TEMP = [];
        
        if varInput.NearestGrayMatter
            TEMP.matterIndices = find(strcmp(COORDSPACE.pointRegions(:,4),'Gray Matter'));
        elseif varInput.NearestBrodmann
            TEMP.matterIndices = find(contains(COORDSPACE.pointRegions(:,5),'brodmann'));
        end
        
        if isempty(TEMP.matterIndices)
            MATTERSEARCH.cubeSize = MATTERSEARCH.cubeSize + varInput.Search_SizeIteration;
            MATTERSEARCH.searchIteration = MATTERSEARCH.searchIteration + 1;
            if MATTERSEARCH.cubeSize > varInput.Search_StopThreshold
                disp(['Matter not Found Within ' num2str(varInput.Search_StopThreshold) ' mm'])
                sourceError = 1;
                return
            end
        else
            MATTERSEARCH.matterFound = 1;
        end
        
    end
    
    if varInput.NearestGrayMatter
        MATTERSEARCH.matterIndex = find(strcmp(COORDSPACE.pointRegions(:,4),'Gray Matter'));
    elseif varInput.NearestBrodmann
        MATTERSEARCH.matterIndex = find(contains(COORDSPACE.pointRegions(:,5),'brodmann'));
    end
    MATTERSEARCH.matterRegions = COORDSPACE.pointRegions(MATTERSEARCH.matterIndex,:);
    MATTERSEARCH.matterDistances = COORDSPACE.distFromCentre(MATTERSEARCH.matterIndex);
    MATTERSEARCH.minDist = min(MATTERSEARCH.matterDistances);
    MATTERSEARCH.minDistIndex = nearest(MATTERSEARCH.matterDistances,MATTERSEARCH.minDist);
    MATTERSEARCH.nearestPoint = MATTERSEARCH.matterRegions(MATTERSEARCH.minDistIndex,:);
    
    COORDSPACE.cerebrum = unique(MATTERSEARCH.nearestPoint(:,1));
    COORDSPACE.lobe = unique(MATTERSEARCH.nearestPoint(:,2));
    COORDSPACE.region = unique(MATTERSEARCH.nearestPoint(:,3));
    COORDSPACE.matter = unique(MATTERSEARCH.nearestPoint(:,4));
    COORDSPACE.brodmann = unique(MATTERSEARCH.nearestPoint(:,5));
    
    [COORDSPACE.uniqueRows,~,COORDSPACE.pointRegionCount] = uniqueRowsCA(MATTERSEARCH.nearestPoint);
    
    for iUnique = 1:size(COORDSPACE.uniqueRows,1)
        COORDSPACE.pointRowCount(iUnique,1) = sum(COORDSPACE.pointRegionCount == iUnique);
        COORDSPACE.pointDistance{iUnique,1} = MATTERSEARCH.minDist(find(COORDSPACE.pointRegionCount == iUnique));
        COORDSPACE.pointDistance_Mean(iUnique,1) = mean(COORDSPACE.pointDistance{iUnique,1});
        COORDSPACE.pointDistance_SD(iUnique,1) = std(COORDSPACE.pointDistance{iUnique,1});
    end
    
else
    
    % ======================================================================= %
    % Localise a Single Point.
    % ======================================================================= %
    
    try
        [~, COORDSPACE.pointRegions(1,:)] = cuixuFindStructure(COORDSPACE.centre, COORDSPACE.DB);
        COORDSPACE.distFromCentre = 0;
    catch
        sourceError = 1;
        COORDSPACE.pointRegions(1,:) = nan(1,6);
        COORDSPACE.distFromCentre = NaN;
        disp('Cannot Localise Points - MNI Coordinates Return Undefined Location')
        disp('Coordinates are Likely Outside of Head')
        return
    end
    
end

