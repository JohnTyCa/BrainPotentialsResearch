REM Created in Corel PHOTO-PAINT Version 19.1.0.419
REM Created On Thursday, August, 02, 2018 by hljtyson

WITHOBJECT "CorelPHOTOPAINT.Automation.19"

	' %===========================================================================%'
	' If you want a border around your image, input the value here. This will 
	' produce a border of this many pixels on the edges so it is not cropped to the 
	' image border.
	' %===========================================================================%'

	MinimumOutsideBorder = 20
	
	' %===========================================================================%'
	' Main Loop.
	' %===========================================================================%'

	' %===========================================================================%'
	' Get the new document height and width.

	h = .GetDocumentHeight()
	w = .GetDocumentWidth()

	' %===========================================================================%'
	' If the image height is greater than or equal to the width, then it will set 
	' the height and the width of the final image to the height. Otherwise, it 
	' will set it to the width.

	IF h >= w THEN papersize = h + MinimumOutsideBorder*2
	IF h < w THEN papersize = w + MinimumOutsideBorder*2

	' %===========================================================================%'
	' Resizing the image paper size requires you to input the top left point of 
	' the image on the screen. To calculate this, the image height is 
	' subtracted from the final paper size and divided by 2 to centre the image 
	' on the screen.

	hcorrection = papersize - h
	wcorrection = papersize - w
	hcorrection = hcorrection / 2
	wcorrection = wcorrection / 2

	.ImagePapersize papersize, papersize, wcorrection, -hcorrection, 5, 255, 255, 255, 0

END WITHOBJECT
