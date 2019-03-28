REM Created On Friday, December, 09, 2016 by hljtyson

WITHOBJECT "CorelPHOTOPAINT.Automation.19"

	' %===========================================================================%'
	' Input the desired width in cm and DPI.
	' %===========================================================================%'
	
	DPI = 300
	WidthInCM = 12

	' %===========================================================================%'
	' Main Loop.
	' %===========================================================================%'
	
	' Calculate the size in pixels from DPI and width in cm. Also, calculate
	' height/width ratio to keep aspect ratio.

	PixelsForOneCM = DPI / 2.54
	NewWidth = PixelsForOneCM * WidthInCM
	DocumentHeight = .GetDocumentHeight()
	DocumentWidth = .GetDocumentWidth()
	HeightWidthRatio = DocumentHeight / DocumentWidth 
	
	' Calculate final width, and using the height/width ratio, calculate the
	' final height.

	FinalWidth = NewWidth
	FinalHeight = NewWidth*HeightWidthRatio

	' Resample and resize image.

	.ImageResample FinalWidth, FinalHeight, DPI, DPI, TRUE

END WITHOBJECT
