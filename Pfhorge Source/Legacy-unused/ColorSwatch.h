// This does color swatches for color selection;
// however, redrawing of them must be done from outside
// (not sure how to do it on the inside)


#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>

#include <AGL/AGL.h>

#include <GLUT/glut.h>

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>


class ColorSwatch {
	
public:
	
	// ID number in the dialog box
	int ID;
	
	// Needs the dialog-box pointer and the UPP for the dialog box's swatch-finder
	void Setup(DialogPtr DPtr, UserItemUPP PaintSwatchUPP);
	
	// The above "paint swatch" routine should call this to paint this swatch
	void DoPaint(DialogPtr DPtr);
	
	// Was this object clicked on?
	bool Clicked(short ItemHit);
	
	// For the color picker
	Str31 Prompt;
	
	// Color values: current, previous, and default
	RGBColor Color, PrevColor, DfltColor;
	
	// Remember current value
	void Save() {PrevColor = Color;}
	
	// Revert to previous value
	void Restore() {Color = PrevColor;}
	
	// Revert to default value
	void Default() {Color = DfltColor;}
};
