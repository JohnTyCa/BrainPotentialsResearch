REM Created On Friday, December, 09, 2016 by hljtyson

WITHOBJECT "CorelPHOTOPAINT.Automation.19"

	' %===========================================================================%'
	' Input the desired height in pixels and DPI.
	' %===========================================================================%'
	
	DPI = 300
	HeightInPixels = 400

	' %===========================================================================%'
	' Main Loop.
	' %===========================================================================%'
	
	' Calculate height/width ratio to keep aspect ratio.

	DocumentHeight = .GetDocumentHeight()
	DocumentWidth = .GetDocumentWidth()
	WidthHeightRatio = DocumentWidth / DocumentHeight
	
	' Calculate final width, and using the height/width ratio, calculate the
	' final height.

	FinalHeight = HeightInPixels
	FinalWidth = HeightInPixels*WidthHeightRatio

	' Resample and resize image.

	.ImageResample FinalWidth, FinalHeight, DPI, DPI, TRUE

END WITHOBJECT
