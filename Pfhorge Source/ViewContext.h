// This object contains the current view context
// and a method for setting the current view to it 

#pragma once

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>


struct ViewContext {

	// Width and height of the view window
	GLfloat Width, Height;
	
	// Near and far distances
	GLfloat Near, Far;
	
	// Size of the field of view
	GLfloat FOV_Size;
	
	// Position
	GLfloat x, y, z;
	
	// Previous position
	GLfloat xprev, yprev, zprev;
	
	// Save/restore position:
	void Save() {xprev = x; yprev = y; zprev = z;}
	void Restore() {x = xprev; y = yprev; z = zprev;}
	
	// Horizontal-turning angle in degrees
	GLfloat YawAngle;
	
	// Vertical-look angle;
	// this doubles as the amount of panning to do
	// when panning the viewport
	GLfloat PitchAngle;
	
	// Room (map polygon) that the view is from
	short MemberOf;
	
	// Vertical-look modes
	enum {
		VertLookMarathon,	// Viewport panned
		VertLookThirdGen,	// View direction changed
		NUM_VERT_LOOK_MODES
	};
	
	// Current mode
	int VertLookMode;
		
	// Set the viewpoint using the view context's values
	void SetView();
	
	// Forward and rightward directions:
	GLfloat Forward_x, Forward_y;
	GLfloat Right_x, Right_y;
	
	// Find these directions
	void FindDirs();
	
	// Find position relative of screen point relative to viewpoint
        // The final flag indicates whether in world coords or screen-projection coords
	bool FindPosition(int Scrn_x, int Scrn_y, GLdouble *PosVec, bool InWorldCoords = true);
	
	// Start mouse drag
	bool StartDrag(int Scrn_x, int Scrn_y);
	
	// Drag to this spot
	bool DragTo(int Scrn_x, int Scrn_y);
		
	// Initial values
	ViewContext();

private:
	// This stuff is for doing mouse dragging:
	GLdouble SavedPosition[3];
};
