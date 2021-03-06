// Here are the methods of the ViewContext object

#include <math.h>
#include "MiscUtils.h"
#import <GLKit/GLKit.h>
#include <cmath>

#include "ViewContext.h"

#include "SimpleVec.h"

using std::atan2;
using std::sin;
using std::cos;
using std::tan;


ViewContext::ViewContext() {
	Width = Height = Near = Far = FOV_Size = 1;
	pos = simd_make_float3(0, 0, 0);
	YawAngle = PitchAngle = 0;
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
	const GLfloat VertPanLimit = tan(((GLfloat)M_PI/180)*30);
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
	glTranslatef(-pos.x,-pos.y,-pos.z);
	
	// Return to "standard" matrix mode (modelview)
	glMatrixMode(GL_MODELVIEW);
}


// Find the (horizontal) directions corresponding to the yaw angle
void ViewContext::FindDirs() {
	// Degrees to randians
	GLfloat angrad = (M_PI/180)*YawAngle;
	GLfloat c = cos(angrad);
	GLfloat s = sin(angrad);
	
	Forward_x = c;
	Forward_y = s;
	Right_x = -s;
	Right_y = c;
}


bool ViewContext::FindPosition(int Scrn_x, int Scrn_y, simd::float3 &PosVec, bool InWorldCoords)
{
	// Find the point position corresponding to the view vector
		
	// Get the other view stuff
	GLint ViewportDump[4];
	GLKMatrix4 ProjMatDump;
	GLKMatrix4 MVMatDump;
	glGetIntegerv(GL_VIEWPORT,ViewportDump);
	glGetFloatv(GL_PROJECTION_MATRIX,ProjMatDump.m);
	if (!InWorldCoords) {
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		glLoadIdentity();
	}
	glGetFloatv(GL_MODELVIEW_MATRIX,MVMatDump.m);
	if (!InWorldCoords) {
		glPopMatrix();
	}
	
	// Unproject!
	// Flip the screen-y coordinate, since it is measured from the top left
	// instead of OpenGL's bottom left: (Height-1) - double(Scrn_y)
	// No need to do that anymore, since the code now uses Cocoa's internal coordinate system,
	// which is just like OpenGL's
	bool success;
	GLKVector3 outVar = GLKMathUnproject(GLKVector3Make(Scrn_x, Scrn_y, 0), MVMatDump, ProjMatDump, ViewportDump, &success);
	PosVec.x = outVar.x;
	PosVec.y = outVar.y;
	PosVec.z = outVar.z;
	if (!success) {
		return false;
	}
	if (InWorldCoords) {
		PosVec -= pos;
	}
	return true;
}

// Start mouse drag
bool ViewContext::StartDrag(int Scrn_x, int Scrn_y) {
	return FindPosition(Scrn_x, Scrn_y, SavedPosition, VertLookMode==VertLookMarathon);
}

// Drag to this spot
bool ViewContext::DragTo(int Scrn_x, int Scrn_y) {
	simd::float3 CurrentPosition;
	if (!FindPosition(Scrn_x, Scrn_y, CurrentPosition, VertLookMode==VertLookMarathon)) return false;
	
	// Find what angle to drag by
	
	GLfloat CPx = CurrentPosition.x;
	GLfloat CPy = CurrentPosition.y;
	GLfloat CPz = CurrentPosition.z;
	GLfloat SPx = SavedPosition.x;
	GLfloat SPy = SavedPosition.y;
	GLfloat SPz = SavedPosition.z;
	
	switch(VertLookMode) {
		case VertLookMarathon:
		{
			YawAngle -= (180/M_PI)*atan2(CPy*SPx - CPx*SPy, CPx*SPx + CPy*SPy);
			// Really the vertical shift
			PitchAngle -= (CPz - SPz)/Near;
		}
			break;
			
			
		case VertLookThirdGen:
		{
			YawAngle -= (180/M_PI)*atan2(CPz*SPx - CPx*SPz, CPx*SPx + CPz*SPz);
			PitchAngle -= (180/M_PI)*atan2(CPz*SPy - CPy*SPz, CPy*SPy + CPz*SPz);
			SavedPosition = CurrentPosition;
			
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
