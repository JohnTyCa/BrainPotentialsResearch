REM Created in Corel PHOTO-PAINT Version 19.1.0.419
REM Created On Thursday, August, 02, 2018 by hljtyson

WITHOBJECT "CorelPHOTOPAINT.Automation.19"

	' %===========================================================================%'
	' If you want a border around your image, input the value here. This will 
	' produce a border of this many pixels on the edges so it is not cropped to the 
	' image border. Note that this script crops from the top right pixel.
	' %===========================================================================%'

	MinimumOutsideBorder = 0

	' %===========================================================================%'
	' Main Loop.
	' %===========================================================================%'

	' %===========================================================================%'
	' Get the original document height and width.

	DocumentWidth = .GetDocumentWidth()
	DocumentHeight = .GetDocumentHeight()

	' %===========================================================================%'
	' Crop out all white space.

	.MaskMagicWand DocumentWidth-1, 1, 2, TRUE, TRUE, 0, 10, 10, 10, 10
	.ImageCropToMask 
	.MaskRemove

	' %===========================================================================%'
	' Get new width and height.

	DocumentWidthNew = .GetDocumentWidth()
	DocumentHeightNew = .GetDocumentHeight()

	' %===========================================================================%'
	' Add border to image.
	
	PapersizeWidth = DocumentWidthNew + MinimumOutsideBorder*2
	PapersizeHeight = DocumentHeightNew + MinimumOutsideBorder*2

	' %===========================================================================%'
	' Resizing the image paper size requires you to input the top left point of 
	' the image on the screen. To calculate this, the image height is 
	' subtracted from the final paper size and divided by 2 to centre the image 
	' on the screen.

	wcorrection = PapersizeWidth - DocumentWidthNew
	hcorrection = PapersizeHeight - DocumentHeightNew
	wcorrection = wcorrection / 2
	hcorrection = hcorrection / 2

	.ImagePapersize PapersizeWidth, PapersizeHeight, wcorrection, -hcorrection, 5, 255, 255, 255, 0

END WITHOBJECT
