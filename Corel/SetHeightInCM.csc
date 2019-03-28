REM Created On Friday, December, 09, 2016 by hljtyson

WITHOBJECT "CorelPHOTOPAINT.Automation.19"

	' %===========================================================================%'
	' Input the desired height in cm and DPI.
	' %===========================================================================%'
	
	DPI = 300
	HeightInCM = 16

	' %===========================================================================%'
	' Main Loop.
	' %===========================================================================%'
	
	' Calculate the size in pixels from DPI and width in cm. Also, calculate
	' height/width ratio to keep aspect ratio.

	PixelsForOneCM = DPI / 2.54
	NewHeight = PixelsForOneCM * HeightInCM
	DocumentHeight = .GetDocumentHeight()
	DocumentWidth = .GetDocumentWidth()
	WidthHeightRatio = DocumentWidth / DocumentHeight
	
	' Calculate final width, and using the height/width ratio, calculate the
	' final height.

	FinalHeight = NewHeight
	FinalWidth = NewHeight*WidthHeightRatio

	' Resample and resize image.

	.ImageResample FinalWidth, FinalHeight, DPI, DPI, TRUE

END WITHOBJECT
