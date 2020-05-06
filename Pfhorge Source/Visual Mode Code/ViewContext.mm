// Here are the methods of the ViewContext object

#include <math.h>
#include "MiscUtils.h"
#include <GLKit/GLKit.h>

#include "ViewContext.h"

#include "SimpleVec.h"

const double PI = 4*atan(1.0);


ViewContext::ViewContext() {
	Width = Height = Near = Far = FOV_Size = 1;
	x = y = z = YawAngle = PitchAngle = 0;
	VertLookMode = VertLookMarathon;
	MemberOf = -1; // NONE
}


void ViewContext::SetView() {

	// Use the maximum dimension as a reference
	GLfloat MaxDim = max(Width,Height);
	GLfloat widc = (FOV_Size*Near)*(Width/MaxDim);
	GLfloat htc = (FOV_Size*Near)*(Height/MaxDim);
	
	// Do the view setting: this part belongs to the projection matrix
	glMatrixMode(GL_PROJECTION);
	
	// Start
	glLoadIdentity();
	
	// Find how much vertical panning (Marathon mode)
	GLfloat vertpan = 0;
	const GLfloat VertPanLimit = tan((PI/180)*30);
	if (VertLookMode == VertLookMarathon) {
		PitchAngle = min(PitchAngle,VertPanLimit);
		PitchAngle = max(PitchAngle,-VertPanLimit);
		vertpan = PitchAngle*Near;
	}
	
	// Projected, of course
	glFrustum(-widc,widc,vertpan-htc,vertpan+htc,Near,Far);
	
	// Do the view setting: this part belongs to the modelview matrix
	glMatrixMode(GL_MODELVIEW);
	
	// Start
	glLoadIdentity();
	
	// Do Marathon -> view coordinates
	const GLfloat MaraTMat[] = {0,0,-1,0, 1,0,0,0, 0,1,0,0, 0,0,0,1};
	glMultMatrixf(MaraTMat);
	
	// Rotate the viewpoint up-or-down (Quake mode -- true view direction change)
	if (VertLookMode == VertLookThirdGen) {
		PitchAngle = min(PitchAngle,GLfloat(90.0));
		PitchAngle = max(PitchAngle,GLfloat(-90.0));
		glRotatef(PitchAngle,0,1,0);
	}
	
	// Rotate the viewpoint horizontally
	int nrots = irint(YawAngle/360);
	YawAngle -= 360*nrots;
	glRotatef(-YawAngle,0,0,1);
	
	// Move the viewpoint
	glTranslatef(-x,-y,-z);
	
	// Return to "standard" matrix mode (modelview)
	glMatrixMode(GL_MODELVIEW);
}


// Find the (horizontal) directions corresponding to the yaw angle
void ViewContext::FindDirs() {
	// Degrees to randians
	double angrad = (PI/180)*YawAngle;
	double c = cos(angrad);
	double s = sin(angrad);
	
	Forward_x = c;
	Forward_y = s;
	Right_x = -s;
	Right_y = c;
}


// Find the view vector corresponding to the screen position
bool ViewContext::FindPosition(int Scrn_x, int Scrn_y, GLdouble *PosVec, bool InWorldCoords) {

	// Find the point position corresponding to the view vector
		
	// Get the other view stuff
	GLint ViewportDump[4];
	GLdouble ProjMatDump[16];
	GLdouble MVMatDump[16];
	glGetIntegerv(GL_VIEWPORT,ViewportDump);
	glGetDoublev(GL_PROJECTION_MATRIX,ProjMatDump);
        if (!InWorldCoords) {
            glMatrixMode(GL_MODELVIEW);
            glPushMatrix();
            glLoadIdentity();
        }
	glGetDoublev(GL_MODELVIEW_MATRIX,MVMatDump);
        if (!InWorldCoords) {
            glPopMatrix();
        }
	
	// Unproject!
	// Flip the screen-y coordinate, since it is measured from the top left
	// instead of OpenGL's bottom left: (Height-1) - double(Scrn_y)
        // No need to do that anymore, since the code now uses Cocoa's internal coordinate system,
        // which is just like OpenGL's
	if (gluUnProject(double(Scrn_x) , double(Scrn_y), 0,
					MVMatDump, ProjMatDump, ViewportDump,
					PosVec, PosVec+1, PosVec+2) == GL_FALSE) return false;
	if (InWorldCoords) {
            PosVec[0] -= x;
            PosVec[1] -= y;
            PosVec[2] -= z;
        }
	return true;
}

// Start mouse drag
bool ViewContext::StartDrag(int Scrn_x, int Scrn_y) {
	return FindPosition(Scrn_x, Scrn_y, SavedPosition, VertLookMode==VertLookMarathon);
}

// Drag to this spot
bool ViewContext::DragTo(int Scrn_x, int Scrn_y) {
	GLdouble CurrentPosition[3];
	if (!FindPosition(Scrn_x, Scrn_y, CurrentPosition, VertLookMode==VertLookMarathon)) return false;
	
	// Find what angle to drag by
	
	GLdouble CPx = CurrentPosition[0];
	GLdouble CPy = CurrentPosition[1];
	GLdouble CPz = CurrentPosition[2];
	GLdouble SPx = SavedPosition[0];
	GLdouble SPy = SavedPosition[1];
	GLdouble SPz = SavedPosition[2];
	
	switch(VertLookMode) {
  	case VertLookMarathon:
	{
		YawAngle -= (180/PI)*atan2(CPy*SPx - CPx*SPy, CPx*SPx + CPy*SPy);
                // Really the vertical shift
		PitchAngle -= (CPz - SPz)/Near;
	}
	break;
        
        
	case VertLookThirdGen:
	{
                YawAngle -= (180/PI)*atan2(CPz*SPx - CPx*SPz, CPx*SPx + CPz*SPz);
		PitchAngle -= (180/PI)*atan2(CPz*SPy - CPy*SPz, CPy*SPy + CPz*SPz);
                for (int c=0; c<3; c++)
                    SavedPosition[c] = CurrentPosition[c];
                
                /*
		// A crude approximate solution -- attempts to find the exact solution
		// resulted in some 4th-order polynomial equations.
		// This was derived with the help of some first-order approximations
		
		YawAngle -= (180/PI)*atan2(CPy*SPx - CPx*SPy, CPx*SPx + CPy*SPy + CPz*SPz);
		PitchAngle -= (180/PI)*atan2(CPz*SPx - CPx*SPz, CPx*SPx + CPy*SPy + CPz*SPz);
                */
	}
	break;
		
	}
	SetView();
	return true;
}
