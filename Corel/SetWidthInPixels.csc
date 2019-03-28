REM Created On Friday, December, 09, 2016 by hljtyson

WITHOBJECT "CorelPHOTOPAINT.Automation.19"

	' %===========================================================================%'
	' Input the desired width in pixels and DPI.
	' %===========================================================================%'
	
	DPI = 300
	WidthInPixels = 450

	' %===========================================================================%'
	' Main Loop.
	' %===========================================================================%'
	
	' Calculate height/width ratio to keep aspect ratio.

	DocumentHeight = .GetDocumentHeight()
	DocumentWidth = .GetDocumentWidth()

	HeightWidthRatio = DocumentHeight / DocumentWidth 
	
	' Calculate final width, and using the height/width ratio, calculate the
	' final height.

	FinalWidth = WidthInPixels
	FinalHeight = WidthInPixels*HeightWidthRatio

	' Resample and resize image.

	.ImageResample FinalWidth, FinalHeight, DPI, DPI, TRUE

END WITHOBJECT
