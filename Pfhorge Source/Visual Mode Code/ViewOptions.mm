// This does the work of the View Options dialog box

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

#include "ViewOptions.h"
#include "MiscUtils.h"

#include "SimpleVec.h"

#include "LEExtras.h"

static void NS_To_RGB(RGBColor& C, NSColor *NSC)
{
    C.red = (unsigned short)(65535 * ([NSC redComponent]));
    C.green = (unsigned short)(65535 * ([NSC greenComponent]));
    C.blue = (unsigned short)(65535 * ([NSC blueComponent]));
}

void ViewOptions::Init() {
    
	NSColor *theCeilingColor = getArchColor(VMCeilingColor);
	NSColor *theWallColor = getArchColor(VMWallColor);
	NSColor *theFloorColor = getArchColor(VMFloorColor);
	NSColor *theLiquidColor = getArchColor(VMLiquidColor);
	NSColor *theTransparentColor = getArchColor(VMTransparentColor);
	NSColor *theLandscapeColor = getArchColor(VMLandscapeColor);
	NSColor *theInvalidSurfaceColor = getArchColor(VMInvalidSurfaceColor);
	NSColor *theWireColor = getArchColor(VMWireFrameLineColor);
	NSColor *theBackgroundColor = getArchColor(VMBackGroundColor);
	
	NS_To_RGB(BkgdSwatch,theBackgroundColor);
	NS_To_RGB(FloorSwatch,theFloorColor);
	NS_To_RGB(CeilSwatch,theCeilingColor);
	NS_To_RGB(WallSwatch,theWallColor);
	NS_To_RGB(LiquidSwatch,theLiquidColor);
	NS_To_RGB(TransSwatch,theTransparentColor);
	NS_To_RGB(LdscpSwatch,theLandscapeColor);
	NS_To_RGB(InvldSwatch,theInvalidSurfaceColor);
	NS_To_RGB(WireSwatch,theWireColor);
	
	SelectRenderMode = Render_Textured;
	SelectPlatformState = Platform_Contracted;
	SelectVisibleSides = SideBoth;
	SelectVerticalLook = VertLookMarathon;
	SelectFieldOfView = FOV_Normal;
	SelectCloseupRender = CloseupRndr_Nearest;
	SelectDistantRender = DistantRndr_Nearest;
	SelectLightType = Light_Initial;
	SelectNearDistance = NearDist_1_8;
	SelectFarDistance = FarDist_256;
      
	ShowTrans = true;
	ShowLdscp = true;
	ShowInvld = true;
	ShowObjects = false;
	UseLights = true;
	ShowLiquids = true;
	LiquidsTransparent = true;
	OffsetWires = true;
	UseFog = true;
	
	FogDepth = 16;
}


// Set OpenGL stuff that can be set immediately
void ViewOptions::SetImmediate() {
	
	// Set the background and fog colors
	RGBColor &Color = BkgdSwatch;
	GLfloat FColor[4];
	FColor[0] = Color.red/float(65535);
	FColor[1] = Color.green/float(65535);
	FColor[2] = Color.blue/float(65535);
	FColor[3] = 1;
	glClearColor(FColor[0],FColor[1],FColor[2],FColor[3]);
	glFogfv(GL_FOG_COLOR,FColor);
	
	// Set the sidedness
	// The sidedness is always inward unless explicitly outward
	// One-based to zero-based indexing
	switch(SelectVisibleSides)	{
		case SideBoth:
			glDisable(GL_CULL_FACE);
			glFrontFace(GL_CW);
			break;
			
		case SideInward:
			glEnable(GL_CULL_FACE);
			glFrontFace(GL_CW);
			break;
			
		case SideOutward:
			glEnable(GL_CULL_FACE);
			glFrontFace(GL_CCW);
			break;
			
		case SideShow5D:
			glEnable(GL_CULL_FACE);
			glFrontFace(GL_CW);
			break;
	}
}


// Get OpenGL render-mode constants;
// One-based to zero-based indexing
GLint ViewOptions::GetCloseupRenderMode() {
	switch(SelectCloseupRender) {
		case CloseupRndr_Nearest: return GL_NEAREST;
		case CloseupRndr_Linear: return GL_LINEAR;
	}
	return GL_NEAREST;
}
GLint ViewOptions::GetDistantRenderMode() {
	switch(SelectDistantRender) {
		case DistantRndr_Nearest: return GL_NEAREST;
		case DistantRndr_Linear: return GL_LINEAR;
		case DistantRndr_Nearest_Mipmap_Nearest: return GL_NEAREST_MIPMAP_NEAREST;
		case DistantRndr_Linear_Mipmap_Nearest: return GL_LINEAR_MIPMAP_NEAREST;
		case DistantRndr_Nearest_Mipmap_Linear: return GL_NEAREST_MIPMAP_LINEAR;
		case DistantRndr_Linear_Mipmap_Linear: return GL_LINEAR_MIPMAP_LINEAR;
	}
	return GL_NEAREST;
}

