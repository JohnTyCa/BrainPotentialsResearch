REM Created in Corel PHOTO-PAINT Version 19.1.0.419
REM Created On Monday, June, 25, 2018 by hljtyson

WITHOBJECT "CorelPHOTOPAINT.Automation.19"

	' %===========================================================================%'
	' This will scale the image down by a percentage and fill the image out with 
	' white space. Also, requires the final DPI and whether you want to square the 
	' image or not.
	' %===========================================================================%'

	scalePercentage = 80
	finalDPI = 500
	squareImage = 0

	' %===========================================================================%'
	' Main Loop.
	' %===========================================================================%'

	' %===========================================================================%'
	' Get the original document height and width.

	origh& = .GetDocumentHeight()
	origw& = .GetDocumentWidth()

	' %===========================================================================%'
	' Get final width and height.

	finalh = origh * (scalePercentage / 100)
	finalw = origw * (scalePercentage / 100)

	' %===========================================================================%'
	' If the image height is greater than or equal to the width, then it will set 
	' the height and the width of the final image to the height. Otherwise, it 
	' will set it to the width.

	IF squareImage = 1 THEN
	
		IF finalh >= finalw THEN 
			PapersizeWidth = origh
			PapersizeHeight = origh
		ELSE
			PapersizeWidth = origw
			PapersizeHeight = origw
		ENDIF
	
	ELSE
	
		PapersizeWidth = origw
		PapersizeHeight = origh
	
	ENDIF
	
	' %===========================================================================%'
	' Resizing the image paper size requires you to input the top left point of 
	' the image on the screen. To calculate this, the image height is 
	' subtracted from the final paper size and divided by 2 to centre the image 
	' on the screen.

	hcorrection = PapersizeHeight - finalh
	wcorrection = PapersizeWidth - finalw
	hcorrection = hcorrection / 2
	wcorrection = wcorrection / 2
 
	.ImageResample finalw, finalh, finalDPI, finalDPI, TRUE
	.ImagePapersize PapersizeWidth, PapersizeHeight, wcorrection, -hcorrection, 5, 255, 255, 255, 0

END WITHOBJECT
