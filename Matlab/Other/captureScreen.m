% ======================================================================= %
%
% Created by Unknown.
%
% First Created 15/10/2018
%
% Current version = v1.0
%
% Take screenshot of all screens and store in variable.
% 
% ======================================================================= %
% Required Inputs:
% ======================================================================= %
%
% 
%
% ======================================================================= %
% Optional Inputs:
% ======================================================================= %
%
% view  -   Whether to view screenshot in figure. If you want to view it,
%           input view. If not, leave function input parameters empty.
% 
% ======================================================================= %
% Outputs:
% ======================================================================= %
%
% IM    -   Cell array, with length corresponding to number of screens.
%           Each array corresponds to a screenshot of each screen in RGB,
%           with the size corresponding to the resolution of the screen.
% 
% ======================================================================= %
% Example
% ======================================================================= %
%
% IM = captureScreen ();
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
% 15/10/2018 (v1.0) -   V1.0 Created.
%
% ======================================================================= %

function IM = captureScreen (view)
    if nargin ==0
        view = false;
    end
    ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment();
    gd = ge.getScreenDevices;
    
    robot = java.awt.Robot;
    
    for i = 1:numel(gd)
        bounds = gd(i).getDefaultConfiguration.getBounds;
    
        width  = bounds.getWidth();
        height = bounds.getHeight();
        left   = bounds.getX;
        top    = bounds.getY;
    
        im = zeros(height,width,3,'uint8');
        bimg = robot.createScreenCapture(java.awt.Rectangle(left, top, width, height));
        RGBA = bimg.getRGB(0,0,width,height,[],0,width);
        RGBA = typecast(RGBA, 'uint8');

        im(:,:,1) = reshape(RGBA(3:4:end),width,height).';
        im(:,:,2) = reshape(RGBA(2:4:end),width,height).';
        im(:,:,3) = reshape(RGBA(1:4:end),width,height).';    
        
        IM{i} = im; 
    end
    
    if view
        figure;
        N = numel(IM);
        for i = 1:N
            subplot(N,1,i);
            image(IM{i});
            axis equal tight
        end
    end
end