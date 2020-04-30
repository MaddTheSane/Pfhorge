// Here are the methods of the color-swatch object

///#include <Quickdraw.h>
#include "ColorSwatch.h"

#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>

#warning re-write!

// Needs the dialog-box ID and the UPP for the dialog box's swatch-finder
void ColorSwatch::Setup(DialogPtr DPtr, UserItemUPP PaintSwatchUPP) {
#if 0
	Handle Hdl;
	short ItemType; // Might want to check for debugging purposes
	Rect ItemRect; // Don't want to keep these
	
	// Plug that UPP into the dialog-box item
	GetDialogItem(DPtr, ID, &ItemType,
		(Handle *)&Hdl, &ItemRect);	
	SetDialogItem(DPtr, ID, ItemType,
		Handle(PaintSwatchUPP), &ItemRect);
#endif
}


// Paints this swatch
void ColorSwatch::DoPaint(DialogPtr DPtr) {
#if 0
	// Get the swatch's current state in the dialog box
	Handle Hdl;
	short ItemType; // Might want to check for debugging purposes
	Rect ItemRect;

	GetDialogItem(DPtr, ID, &ItemType,
		(Handle *)&Hdl, &ItemRect);

	PenState OldPen;
	RGBColor OldBackColor, OldForeColor;

	// Save previous state		
	GetPenState(&OldPen);
	GetBackColor(&OldBackColor);
	GetForeColor(&OldForeColor);
	
	// Get ready to draw the swatch
	PenNormal();
	
	// Draw!
	RGBForeColor(&Color);
	PaintRect(&ItemRect);
	ForeColor(blackColor);
	FrameRect(&ItemRect);
	
	// Restore previous state
	SetPenState(&OldPen);
	RGBBackColor(&OldBackColor);
	RGBForeColor(&OldForeColor);
#endif
}

 
// Was this swatch clicked on?
bool ColorSwatch::Clicked(short ItemHit) {
	if (ID == ItemHit) {
		
		// Call the color-picker routine
		
		// Setup for GetColor()
		Point CPDialogLoc;
		CPDialogLoc.v = -1;
		CPDialogLoc.h = -1;
		RGBColor NewColor;
		
		// Pick!
		if (!GetColor(CPDialogLoc,Prompt,&Color,&NewColor)) return true;
		Color = NewColor;
		
		return true;
	} else return false;
}
