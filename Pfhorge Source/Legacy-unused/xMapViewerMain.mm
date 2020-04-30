// Here is my Map Viewer:

// For now, I'll try to test basic OpenGL rendering and viewing -- and navigation.

#include <math.h>
#include "MapManager.h"
#include "KeyControls.h"


// Control parameters:
// These probably belong in a separate file

// Motion
// const GLfloat HorizStep = 256;
// const GLfloat VertStep = 256;
const GLfloat YawStep = 10;
const GLfloat PitchStep = 10;

// Vertical Panning
const double PI = 4*atan(1.0);
const GLfloat VertPanLimit = tan((PI/180)*30);
const GLfloat PanStep = VertPanLimit/3;


// Map-manager object
MapManager M;

// Key-controls object
KeyControls K;

GLfloat rtri;
GLfloat rquad;

#define kWindowWidth	512
#define kWindowHeight	256

const short TextDefaultsID = 650;

bool ShowText, ShowFramerate;
RGBColor TextColor, TextShadowColor;


// For finding framerates
int PrevTick = 0;
float AvgTickIntvl = -1; // A value of -1 means "reset"
bool TakingAverage = false;


static bool SetBool(short ID, int Indx) {
	Str255 StringBuffer;
	GetIndString(StringBuffer,ID,Indx);
	Pas2C(StringBuffer,StringBuffer);
	int val = atoi((char *)StringBuffer);
	return (val != 0);
}

static unsigned short SetColor(short ID, int Indx) {
	Str255 StringBuffer;
	GetIndString(StringBuffer,ID,Indx);
	Pas2C(StringBuffer,StringBuffer);
	double fval = atof((char *)StringBuffer);
	fval = min(max(fval,0.0),1.0);
	return (unsigned short)irint(65535*fval);
}

void InitText() {
	int li = 1;
	ShowText = SetBool(TextDefaultsID,li++);
	ShowFramerate = SetBool(TextDefaultsID,li++);
	TextColor.red = SetColor(TextDefaultsID,li++);
	TextColor.green = SetColor(TextDefaultsID,li++);
	TextColor.blue = SetColor(TextDefaultsID,li++);
	TextShadowColor.red = SetColor(TextDefaultsID,li++);
	TextShadowColor.green = SetColor(TextDefaultsID,li++);
	TextShadowColor.blue = SetColor(TextDefaultsID,li++);
}


// Turns some characters into a line of text
void DisplayText(int h, int v, char *Text) {
	glRasterPos2f(h,v);
	for (int ic=0; ic<strlen(Text); ic++)
		glutBitmapCharacter(GLUT_BITMAP_8_BY_13, Text[ic]);
}

// Displays some text in a styled fashion;
// the styling here is a simple drop shadow,
// and the coordinates are assumed to start from the top left of the screen
void DisplayStyledText(int h, int v, char *Text) {
	
	// The display order assumes acceptance of the newest pixel
	
	// The text shadow
	glColor3usv((unsigned short *)&TextShadowColor);
	DisplayText(h+1,v+1,Text);
	
	// The text itself
	glColor3usv((unsigned short *)&TextColor);
	DisplayText(h,v,Text);
}


GLvoid DisplayFunc(GLvoid) {
	
        M.VO.PopupList[ViewOptions::SelectRenderMode].SetState(MapManager::Render_Wireframe);
        
        // Need to clear both color and depth
	glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
        
        /*glLoadIdentity();					// Reset The View

	glTranslatef(-1.5f,0.0f,-6.0f);				// Move Into The Screen And Left
	glRotatef(rtri,0.0f,1.0f,0.0f);				// Rotate The Triangle On The Y axis ( NEW )
	glBegin(GL_POLYGON);						// Start Drawing A Polygon
		glColor3f(1.0f,0.0f,0.0f);				// Set Top Point Of Polygon To Red
		glVertex3f( 0.0f, 1.0f, 0.0f);			// First Point Of The Polygon (Triangle)
		glColor3f(0.0f,1.0f,0.0f);				// Set Left Point Of Polygon To Green
		glVertex3f(-1.0f,-1.0f, 0.0f);			// Second Point Of The Polygon
		glColor3f(0.0f,0.0f,1.0f);				// Set Right Point Of Polygon To Blue
		glVertex3f( 1.0f,-1.0f, 0.0f);			// Third Point Of The Polygon
	glEnd();
	
	glLoadIdentity();
	
	glTranslatef(1.5f,0.0f,-6.0f);				// Move Right 1.5 Units
	glRotatef(rquad,1.0f,0.0f,0.0f);			// Rotate The Quad On The X axis ( NEW )
	glColor3f(0.5f,0.5f,1.0f);					// Set The Color To A Nice Blue Shade
	glBegin(GL_QUADS);							// Start Drawing A Quad
		glVertex3f(-1.0f, 1.0f, 0.0f);			// Top Left Of The Quad
		glVertex3f( 1.0f, 1.0f, 0.0f);			// Top Right Of The Quad
		glVertex3f( 1.0f,-1.0f, 0.0f);			// Bottom Right Of The Quad
		glVertex3f(-1.0f,-1.0f, 0.0f);			// Bottom Left Of The Quad
	glEnd();							
	
	rtri += 0.2;
	rquad -= 0.15;*/
        
        //glutSwapBuffers();
        //glutPostRedisplay();
        

        // Update view context and do visibility
	//M.UpdateViewCtxtDoVis();

	
	// Set the fog
	// One-based to zero-based indexing
	/*
        switch(M.VO.PopupList[ViewOptions::SelectFog].State-1) {
	case ViewOptions::Fog_None:
		glDisable(GL_FOG);
		break;
		
	case ViewOptions::Fog_64:
		glEnable(GL_FOG);
		glFogf(GL_FOG_DENSITY,1./(64*1024));
		break;
		
	case ViewOptions::Fog_16:
		glEnable(GL_FOG);
		glFogf(GL_FOG_DENSITY,1./(16*1024));
		break;
		
	case ViewOptions::Fog_4:
		glEnable(GL_FOG);
		glFogf(GL_FOG_DENSITY,1./(4*1024));
		break;
		
	case ViewOptions::Fog_1:
		glEnable(GL_FOG);
		glFogf(GL_FOG_DENSITY,1./(1024));
		break;
	}
	
	// Use the background color for the fog color (reasonable)
	GLfloat FogColor[4];
	GLushort *Color = (GLushort *)&M.VO.SwatchList[ViewOptions::BkgdSwatch].Color;
	FogColor[0] = Color[0]/65535.;
	FogColor[1] = Color[1]/65535.;
	FogColor[2] = Color[2]/65535.;
	FogColor[3] = 1.0;
	glFogfv(GL_FOG_COLOR,FogColor);
	
	// Get the rendering mode
	// One-based to zero-based indexing
	int RenderMode =  MapManager::Render_Colored; //M.VO.PopupList[ViewOptions::SelectRenderMode].State-1;
	*/
	bool UseZBuffer = true; //M.MP.ZBufferCB.Checked;
	/*
	if (!UseZBuffer) glDisable(GL_DEPTH_TEST);
	
	// Fallback in case of absent textures
	switch(RenderMode) {
	case MapManager::Render_Textured:
	case MapManager::Render_Averaged:
		if (!M.WallTxtrPresent()) {
			glDisable(GL_TEXTURE_2D);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			RenderMode = MapManager::Render_Colored;
		} else if (RenderMode == MapManager::Render_Textured) {
			glEnable(GL_TEXTURE_2D);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		} else {
			glDisable(GL_TEXTURE_2D);
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		}
	break;
	default:
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	// Move surfaces behind the lines
	bool OffsetWires = M.VO.CheckBoxList[ViewOptions::OffsetWires].Checked;
	if (OffsetWires) {
		switch(RenderMode) {
		case MapManager::Render_Colored:
		case MapManager::Render_Averaged:
			glPolygonOffset(1,1);
			glEnable(GL_POLYGON_OFFSET_FILL);
		}
	}
	
	// Do colored rendering on the outward sides if trying to detect 5D space:
	// One-based to zero-based indexing
	int SideVisMode = M.VO.PopupList[ViewOptions::SelectVisibleSides].State-1;
	if (SideVisMode == ViewOptions::SideShow5D)
		if (RenderMode != MapManager::Render_Wireframe) {
			// Not surprising
			GLboolean NormallyDoTextures = glIsEnabled(GL_TEXTURE_2D);
			if (NormallyDoTextures) {
				glDisable(GL_TEXTURE_2D);
				glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			}
			
			// Go!
			glFrontFace(GL_CCW);
			M.DoRender(MapManager::Render_Colored,false);
			glFrontFace(GL_CW);
			
			// Set back for textured sides
			if (NormallyDoTextures) {
				glEnable(GL_TEXTURE_2D);
				glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			}
		}
	
	// Do the specified rendering
	M.DoRender(RenderMode);
	
	// Pop previous move
	if (OffsetWires) {
		switch(RenderMode) {
		case MapManager::Render_Colored:
		case MapManager::Render_Averaged:
			glDisable(GL_POLYGON_OFFSET_FILL);
		}
	}
	
	// Wireframe is good for colored mode,
	// because it sets up perceptual hints.
	// Do it here only when doing Z-buffering
	if (UseZBuffer) {
		switch(RenderMode) {
		case MapManager::Render_Colored:
		case MapManager::Render_Averaged:
			M.DoRender(MapManager::Render_Wireframe);
		}
	}

	if (!UseZBuffer) glEnable(GL_DEPTH_TEST);
        
	ShowText = true;
	if (ShowText) {
		// Display status as text
		
		// Push the transformation matrices and put in appropriate ones
		// Assume starting out in modelview mode
		// And switch off z-buffering for the occasion
		glPushMatrix();
		glLoadIdentity();
		
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		
		glLoadIdentity();
		glOrtho(0,M.VC.Width,M.VC.Height,0,-1,1);
		glDisable(GL_DEPTH_TEST);
		
		// Go!
		char Buffer[256];
		int HPos = 8, VPos = 16;
		
		// Line up X, Y, Z format
		
		sprintf(Buffer,"X = %8.3f",M.VC.x/float(WORLD_ONE));
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 16;
		
		sprintf(Buffer,"Y = %8.3f",M.VC.y/float(WORLD_ONE));
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 16;
		
		sprintf(Buffer,"Z = %8.3f",M.VC.z/float(WORLD_ONE));
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 24;
		
		// Line up view-angle format
		
		sprintf(Buffer,"Yaw   = %7.2f",M.VC.YawAngle);
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 16;

		switch(M.VC.VertLookMode) {
		case ViewContext::VertLookMarathon:
			sprintf(Buffer,"VtPan = %7.2f",M.VC.PitchAngle);
			break;
		case ViewContext::VertLookThirdGen:
			sprintf(Buffer,"Pitch = %7.2f",M.VC.PitchAngle);
			break;
		}
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 24;

		sprintf(Buffer,"Polygon = %4d",M.VC.MemberOf);
		DisplayStyledText(HPos,VPos,Buffer);
		
		// Pop back; return to modelview mode and z-buffering
		glEnable(GL_DEPTH_TEST);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
	}
        ShowFramerate = true;
	if (ShowFramerate) {
		// Display the current framerate
		
		// Push the transformation matrices and put in appropriate ones
		// Assume starting out in modelview mode
		// And switch off z-buffering for the occasion
		glPushMatrix();
		glLoadIdentity();
		
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		
		glLoadIdentity();
		glOrtho(0,M.VC.Width,M.VC.Height,0,-1,1);
		glDisable(GL_DEPTH_TEST);
		
		// Go!
		char Buffer[256];
		int HPos = 8, VPos = M.VC.Height-8;
		
		int CurrTick = TickCount();
		int TickIntvl = CurrTick - PrevTick;
		PrevTick = CurrTick;
		
		if (TakingAverage) {
			if (AvgTickIntvl > 0) {
				// Continuing with average-taking;
				// Use an interval of something like 1 second or 1 tick, whichever is greater
				AvgTickIntvl = AvgTickIntvl + (TickIntvl - AvgTickIntvl)/max(60.0/max(TickIntvl,1),1.0);
				float Framerate = 60/max(AvgTickIntvl,float(0.001));
				sprintf(Buffer,"Frames/s = %.2f",Framerate);
				DisplayStyledText(HPos,VPos,Buffer);
			} else {
				// Starting the average-taking
				AvgTickIntvl = TickIntvl;
			}
		} else {
			// Signal start of average-taking
			AvgTickIntvl = -1;
			TakingAverage = true;
		}
				
		// Pop back; return to modelview mode and z-buffering
		glEnable(GL_DEPTH_TEST);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
	} else TakingAverage = false;
        
	//NSLog(@"...");
        //DisplayText(50, 50, "TESTING");						
	
    glutSwapBuffers();
    
    //glFinish();
    
    if (ShowFramerate) glutPostRedisplay();
    */
    
    M.UpdateViewCtxtDoVis();
    glDisable(GL_FOG);
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_DEPTH_TEST);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
    glEnable(GL_DEPTH_TEST);
    M.DoRender(MapManager::Render_Colored);
    //M.DoRender(MapManager::Render_Wireframe);
    //M.DoRender(MapManager::Render_Textured);
    
    
	ShowText = true;
	if (ShowText) {
		// Display status as text
		
		// Push the transformation matrices and put in appropriate ones
		// Assume starting out in modelview mode
		// And switch off z-buffering for the occasion
		glPushMatrix();
		glLoadIdentity();
		
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		
		glLoadIdentity();
		glOrtho(0,M.VC.Width,M.VC.Height,0,-1,1);
		glDisable(GL_DEPTH_TEST);
		
		// Go!
		char Buffer[256];
		int HPos = 8, VPos = 16;
		
		// Line up X, Y, Z format
		
		sprintf(Buffer,"X = %8.3f",M.VC.x/float(WORLD_ONE));
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 16;
		
		sprintf(Buffer,"Y = %8.3f",M.VC.y/float(WORLD_ONE));
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 16;
		
		sprintf(Buffer,"Z = %8.3f",M.VC.z/float(WORLD_ONE));
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 24;
		
		// Line up view-angle format
		
		sprintf(Buffer,"Yaw   = %7.2f",M.VC.YawAngle);
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 16;

		switch(M.VC.VertLookMode) {
		case ViewContext::VertLookMarathon:
			sprintf(Buffer,"VtPan = %7.2f",M.VC.PitchAngle);
			break;
		case ViewContext::VertLookThirdGen:
			sprintf(Buffer,"Pitch = %7.2f",M.VC.PitchAngle);
			break;
		}
		DisplayStyledText(HPos,VPos,Buffer);
		
		VPos += 24;

		sprintf(Buffer,"Polygon = %4d",M.VC.MemberOf);
		DisplayStyledText(HPos,VPos,Buffer);
		
		// Pop back; return to modelview mode and z-buffering
		glEnable(GL_DEPTH_TEST);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
	}
        ShowFramerate = true;
	if (ShowFramerate) {
		// Display the current framerate
		
		// Push the transformation matrices and put in appropriate ones
		// Assume starting out in modelview mode
		// And switch off z-buffering for the occasion
		glPushMatrix();
		glLoadIdentity();
		
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		
		glLoadIdentity();
		glOrtho(0,M.VC.Width,M.VC.Height,0,-1,1);
		glDisable(GL_DEPTH_TEST);
		
		// Go!
		char Buffer[256];
		int HPos = 8, VPos = M.VC.Height-8;
		
		int CurrTick = TickCount();
		int TickIntvl = CurrTick - PrevTick;
		PrevTick = CurrTick;
		
		if (TakingAverage) {
			if (AvgTickIntvl > 0) {
				// Continuing with average-taking;
				// Use an interval of something like 1 second or 1 tick, whichever is greater
				AvgTickIntvl = AvgTickIntvl + (TickIntvl - AvgTickIntvl)/max(60.0/max(TickIntvl,1),1.0);
				float Framerate = 60/max(AvgTickIntvl,float(0.001));
				sprintf(Buffer,"Frames/s = %.2f",Framerate);
				DisplayStyledText(HPos,VPos,Buffer);
			} else {
				// Starting the average-taking
				AvgTickIntvl = TickIntvl;
			}
		} else {
			// Signal start of average-taking
			AvgTickIntvl = -1;
			TakingAverage = true;
		}
				
		// Pop back; return to modelview mode and z-buffering
		glEnable(GL_DEPTH_TEST);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
	} else TakingAverage = false;
        
	//NSLog(@"...");
        //DisplayText(50, 50, "TESTING");						
	
    glutSwapBuffers();
    if (ShowFramerate) glutPostRedisplay();
}


GLvoid ReshapeFunc(int Width, int Height) {
    /*
    glViewport (0, 0, (GLsizei) Width, (GLsizei) Height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    gluPerspective(45.0, (GLfloat) Width / (GLfloat) Height, 0.1, 100.0);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    return;
    */
    glViewport(0, 0, Width, Height);
    
    M.VC.Width = Width;
    M.VC.Height = Height;
    M.VC.SetView();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}


const unsigned char ESCAPE = 0x1b;

GLvoid KeyboardFunc(unsigned char Key, int x, int y) {

	int KeyUpper = toupper(int(Key));
	
	KeyControlChar *C = K.ControlList;
	
	float HorizStep, VertStep;
	HorizStep = VertStep = M.MP.GetMotionSpeed();

	if (KeyUpper == ESCAPE) {
		// Get the map dialog
		if (!M.DoDialog()) exit(0);
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::MoveForward].KCChar) {
		// Move forward
		M.VC.Save();
		M.VC.FindDirs();
		M.VC.x += HorizStep*M.VC.Forward_x;
		M.VC.y += HorizStep*M.VC.Forward_y;
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::MoveBackward].KCChar) {
		// Move backward
		M.VC.Save();
		M.VC.FindDirs();
		M.VC.x -= HorizStep*M.VC.Forward_x;
		M.VC.y -= HorizStep*M.VC.Forward_y;
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::TurnLeftward].KCChar) {
		// Turn leftward
		M.VC.YawAngle -= YawStep;
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::TurnRightward].KCChar) {
		// Turn rightward
		M.VC.YawAngle += YawStep;
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::MoveLeftward].KCChar) {
		// Move leftward
		M.VC.Save();
		M.VC.FindDirs();
		M.VC.x -= HorizStep*M.VC.Right_x;
		M.VC.y -= HorizStep*M.VC.Right_y;
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::MoveRightward].KCChar) {
		// Move rightward
		M.VC.Save();
		M.VC.FindDirs();
		M.VC.x += HorizStep*M.VC.Right_x;
		M.VC.y += HorizStep*M.VC.Right_y;
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::MoveUpward].KCChar) {
		// Move upward
		M.VC.Save();
		M.VC.z += VertStep;
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::MoveDownward].KCChar) {
		// Move downward
		M.VC.Save();
		M.VC.z -= VertStep;
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::LookUpward].KCChar) {
		// Look upward
		switch(M.VC.VertLookMode) {
		case ViewContext::VertLookMarathon:
			M.VC.PitchAngle += PanStep;
			break;
		case ViewContext::VertLookThirdGen:
			M.VC.PitchAngle += PitchStep;
			break;
		}
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::LookCenter].KCChar) {
		// Look center
		M.VC.PitchAngle = 0;
		M.VC.SetView();
		
		glutPostRedisplay();
	} else if (KeyUpper == C[KeyControls::LookDownward].KCChar) {
		// Look downward
		switch(M.VC.VertLookMode) {
		case ViewContext::VertLookMarathon:
			M.VC.PitchAngle -= PanStep;
			break;
		case ViewContext::VertLookThirdGen:
			M.VC.PitchAngle -= PitchStep;
			break;
		}
		M.VC.SetView();
		
		glutPostRedisplay();
	}		
}


// Toggles a checkbox
void Toggle(CheckBox &CB) {
	/*CB.Checked = !CB.Checked;
	CB.Update();*/
}

// Cycles through a dialog-box control;
// state ID's start from 1 here
void CycleThrough(DBControl &Ctrl, int NumStates) {
	/*int NewState;
	if (Ctrl.State >= NumStates)
		NewState = 1;
	else
		NewState = Ctrl.State + 1;
	Ctrl.SetState(NewState);*/
}


GLvoid SpecialKeyFunc(int Key, int x, int y) {

	float HorizStep, VertStep;
	HorizStep = VertStep = M.MP.GetMotionSpeed();

	switch(Key) {
	case GLUT_KEY_LEFT:
		// Turn leftward
		M.VC.YawAngle -= YawStep;
		M.VC.SetView();
		
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_RIGHT:
		// Turn rightward
		M.VC.YawAngle += YawStep;
		M.VC.SetView();
		
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_UP:
		// Look upward
		switch(M.VC.VertLookMode) {
		case ViewContext::VertLookMarathon:
			M.VC.PitchAngle += PanStep;
			break;
		case ViewContext::VertLookThirdGen:
			M.VC.PitchAngle += PitchStep;
			break;
		}
		M.VC.SetView();
		
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_DOWN:
		// Look downward
		switch(M.VC.VertLookMode) {
		case ViewContext::VertLookMarathon:
			M.VC.PitchAngle -= PanStep;
			break;
		case ViewContext::VertLookThirdGen:
			M.VC.PitchAngle -= PitchStep;
			break;
		}
		M.VC.SetView();
		
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_PAGE_UP:
		// Move upward
		M.VC.Save();
		M.VC.z += VertStep;
		M.VC.SetView();
		
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_PAGE_DOWN:
		// Move downward
		M.VC.Save();
		M.VC.z -= VertStep;
		M.VC.SetView();
		
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_INSERT:
		// Move leftward
		M.VC.Save();
		M.VC.FindDirs();
		M.VC.x -= HorizStep*M.VC.Right_x;
		M.VC.y -= HorizStep*M.VC.Right_y;
		M.VC.SetView();
		
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_HOME:
		// Move rightward
		M.VC.Save();
		M.VC.FindDirs();
		M.VC.x += HorizStep*M.VC.Right_x;
		M.VC.y += HorizStep*M.VC.Right_y;
		M.VC.SetView();
		
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_END:
		// Turn around 180 degrees (as in Tomb Raider)
		M.VC.YawAngle += 180;
		M.VC.SetView();
		
		glutPostRedisplay();
		break;
	
	case GLUT_KEY_F1:
		CycleThrough(M.VO.PopupList[ViewOptions::SelectRenderMode], ViewOptions::NUM_RENDER_MODES);
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_F2:
		Toggle(M.VO.CheckBoxList[ViewOptions::ShowTrans]);
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_F3:
		Toggle(M.VO.CheckBoxList[ViewOptions::ShowLdscp]);
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_F4:
		CycleThrough(M.VO.PopupList[ViewOptions::SelectVisibleSides], ViewOptions::NUM_SIDE_VISIBILITIES);
		M.VO.SetImmediate();
		glutPostRedisplay();
		break;
	
	case GLUT_KEY_F5:
		CycleThrough(M.VO.PopupList[ViewOptions::SelectFieldOfView], ViewOptions::NUM_FOV_VALUES);
		M.UpdateViewOptions();
		glutPostRedisplay();
		break;
	
	case GLUT_KEY_F6:
		Toggle(M.VO.CheckBoxList[ViewOptions::UseLights]);
		glutPostRedisplay();
		break;
	
	case GLUT_KEY_F7:
		CycleThrough(M.VO.PopupList[ViewOptions::SelectLightType], ViewOptions::NUM_LIGHT_VALUES);
		M.UpdateViewOptions();
		glutPostRedisplay();
		break;
		
	case GLUT_KEY_F8:
		Toggle(M.VO.CheckBoxList[ViewOptions::ShowLiquids]);
		glutPostRedisplay();
		break;
	
	case GLUT_KEY_F9:
		CycleThrough(M.VO.PopupList[ViewOptions::SelectPlatAutoHeight], ViewOptions::NUM_PLAT_AUTOHEIGHTS);
		M.UpdateViewOptions();
		glutPostRedisplay();
		break;
			
	case GLUT_KEY_F10:
		CycleThrough(M.VO.PopupList[ViewOptions::SelectParseSides], ViewOptions::NUM_PARSE_SIDES);
		M.UpdateViewOptions();
		glutPostRedisplay();
		break;
			
	case GLUT_KEY_F11:
		Toggle(M.VO.CheckBoxList[ViewOptions::OffsetWires]);
		glutPostRedisplay();
		break;
			
	case GLUT_KEY_F12:
		CycleThrough(M.VO.PopupList[ViewOptions::SelectFog], ViewOptions::NUM_FOG_TYPES);
		glutPostRedisplay();
		break;
	}
}


GLvoid MouseClickFunc(int Button, int State, int x, int y) {

	if (Button == GLUT_LEFT_BUTTON) {
		if (State == GLUT_DOWN) {
			M.VC.StartDrag(x,y);
		}
	}
}

GLvoid MouseMotionFunc(int x, int y) {

	M.VC.DragTo(x,y);
	glutPostRedisplay();
}


enum {
	MM_None,				// Do nothing (as for separators)
	MM_FileLevel,			// File and level dialog box
	MM_ControlKeys,			// Control-key dialog box
	MM_ViewOptions,			// View-options dialog box
	MM_MotPortOptions,		// Motion/portal dialog box
	MM_StatusDisplay,		// Toggle status display
	MM_FramerateDisplay,	// Toggle framerate display
	MM_NextPolygon,			// Go to next polygon at the current location
	MM_PrevPolygon			// Go to previous polygon at the current location
};


void MainMenuFunc(int MenuItem) {

	switch(MenuItem) {
	case MM_FileLevel:
		// Get the map dialog
		//if (!M.DoDialog()) exit(0);
		
		glutPostRedisplay();
		break;
	
	case MM_ControlKeys:
		// Get the control-keys dialog
		K.Do();
		break;
	
	case MM_ViewOptions:
		// Get the view-options dialog
		if (!M.VO.Do()) break;
		
		glutPostRedisplay();
		break;

	case MM_MotPortOptions:
		// Get the motion/portal dialog
		// Be sure to handle the position
		if (!M.DoMotPort()) break;
		
		glutPostRedisplay();
		break;
	
	case MM_StatusDisplay:
		// Toggle the status display
		ShowText = !ShowText;
		
		glutPostRedisplay();
		break;
	
	case MM_FramerateDisplay:
		// Toggle the framerate
		ShowFramerate = !ShowFramerate;
		
		glutPostRedisplay();
		break;
	
	case MM_NextPolygon:
		// Go to next polygon at the current location
		M.FindOtherPolygon(1);
		
		glutPostRedisplay();
		break;
		
	case MM_PrevPolygon:
		// Go to previous polygon at the current location
		M.FindOtherPolygon(-1);
		
		glutPostRedisplay();
		break;
	}
}


void RenderModeMenuFunc(int RenderMode) {
	
	// Set this dialog-box control here
	// Zero-based to one-based indexing
	M.VO.PopupList[ViewOptions::SelectRenderMode].SetState(RenderMode+1);
	
	glutPostRedisplay();
}


void VisModeMenuFunc(int VisMode) {
	
	// Set this dialog-box control here
	// Zero-based to one-based indexing
	M.MP.VisModePopup.SetState(VisMode+1);
	
	glutPostRedisplay();
}


enum {
	RM_Terminal,	// Marathon terminal size (300*240)
	RM_Mara,		// Standard Marathon size (640*320)
	RM_Square,		// Square (512*512)
	RM_FullScreen		// Full Screen
};

void ResizeMenuFunc(int Resizing) {

	switch(Resizing) {
	case RM_Terminal:
		// Terminal size
		glutReshapeWindow(300,240);
		
		glutPostRedisplay();
		break;
	
	case RM_Mara:
		// Marathon size
		glutReshapeWindow(640,320);
		
		glutPostRedisplay();
		break;
	
	case RM_Square:
		// Square
		glutReshapeWindow(512,512);
		
		glutPostRedisplay();
		break;
		
	case RM_FullScreen:
		// Full screen
		glutFullScreen();
		
		glutPostRedisplay();
		break;
	}
}


void ViewDirMenuFunc(int Angle) {
	M.VC.YawAngle = Angle;
	M.VC.SetView();
	glutPostRedisplay();
}


int main(int argc, char **argv) {
	
	// Initialize the view context:
	// Units are Marathon's internal units
	// Width and Height are Marathon's standard values
	M.VC.Width = 640;
	M.VC.Height = 320;
        
        rtri = 0.0;
	rquad = 0.0;
        
	// Initialize GLUT
	glutInit(&argc, argv);
        // Initialize the window
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	
	// Create the window
	glutInitWindowSize(kWindowWidth, kWindowHeight);
        glutInitWindowPosition (100, 100);
	glutCreateWindow("Visual Viewer Window");
        
        
	glClearColor(0.0f, 1.0f, 1.0f, 0.0f);		// This Will Clear The Background Color To Black
	glClearDepth(1.0);							// Enables Clearing Of The Depth Buffer
	glDepthFunc(GL_LESS);						// The Type Of Depth Test To Do
	glEnable(GL_DEPTH | GL_DOUBLE | GLUT_RGB);	// Enables Depth Testing
	glShadeModel(GL_SMOOTH);					// Enables Smooth Color Shading

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();							// Reset The Projection Matrix

	gluPerspective(45.0f,(GLfloat)kWindowWidth/(GLfloat)kWindowHeight,0.1f,100.0f);

	glMatrixMode(GL_MODELVIEW);
        
        
	//M.VO.SetImmediate();
        
        NSLog(@"InitText();");
	// Initialize the text defaults
	InitText();
	
        NSLog(@"M.InitDialog");
	// Initialize the map manager:
	// Needs to be after glutInit() because
	// glutInit() does Toolbox initialization
	M.InitDialog();
        
	NSLog(@"K.Init");
	// Initialize the key-controls dialog
	K.Init();
	
        NSLog(@"glutInitDisplayMode ");
	
        
	// Set up the callbacks
	glutDisplayFunc(DisplayFunc);
	glutReshapeFunc(ReshapeFunc);
	glutSpecialFunc(SpecialKeyFunc);
	glutKeyboardFunc(KeyboardFunc);
	glutMouseFunc(MouseClickFunc);
	glutMotionFunc(MouseMotionFunc);
        
	
	// Create render-mode menu:
	int RenderModeMenu = glutCreateMenu(RenderModeMenuFunc);
	glutAddMenuEntry("Wireframe/1",MapManager::Render_Wireframe);
	glutAddMenuEntry("Flat Color/2",MapManager::Render_Colored);
	glutAddMenuEntry("Avg Color/3",MapManager::Render_Averaged);
	glutAddMenuEntry("Textured/4",MapManager::Render_Textured);

	// Create visibility-mode menu:
	int VisModeMenu = glutCreateMenu(VisModeMenuFunc);
	glutAddMenuEntry("All/8",MotPort::VisMode_All);
	glutAddMenuEntry("Portal/9",MotPort::VisMode_Portal);
	glutAddMenuEntry("One/0",MotPort::VisMode_One);
	
	// Create resize menu
	int ResizeMenu = glutCreateMenu(ResizeMenuFunc);
	glutAddMenuEntry("Terminal: 300*240",RM_Terminal);
	glutAddMenuEntry("Marathon: 640*320",RM_Mara);
	glutAddMenuEntry("Square: 512*512",RM_Square);
	glutAddMenuEntry("Full Screen",RM_FullScreen);
	
	// Create view-direction menu
	int ViewDirMenu = glutCreateMenu(ViewDirMenuFunc);
	glutAddMenuEntry("North",-90);
	glutAddMenuEntry("East",0);
	glutAddMenuEntry("South",90);
	glutAddMenuEntry("West",180);
	
	// Create main menu
	int MainMenu = glutCreateMenu(MainMenuFunc);
	glutAddMenuEntry("Select File, Level, Start.../F",MM_FileLevel);
	glutAddMenuEntry("Select Control Keys.../K",MM_ControlKeys);
	glutAddMenuEntry("Select View Options.../T",MM_ViewOptions);
	glutAddMenuEntry("Select Motion&Visibility Options.../M",MM_MotPortOptions);
	glutAddMenuEntry("---",MM_None);
	glutAddSubMenu("Render Mode", RenderModeMenu);
	glutAddSubMenu("Visibility Mode", VisModeMenu);
	glutAddSubMenu("Resize to", ResizeMenu);
	glutAddSubMenu("View Direction", ViewDirMenu);
	glutAddMenuEntry("Toggle Status Display/D",MM_StatusDisplay);
	glutAddMenuEntry("Toggle Framerate Display/R",MM_FramerateDisplay);
	glutAddMenuEntry("---",MM_None);
	glutAddMenuEntry("Next Polygon/N",MM_NextPolygon);
	glutAddMenuEntry("Previous Polygon/P",MM_PrevPolygon);
	glutAttachMenu(GLUT_RIGHT_BUTTON);
	
	// Set up z-buffering;
	// use newest pixel at same position
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	
	// Do transparent surfaces correctly
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER,0.5);
	
	// Do perspective correction
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	
	// Will be using arrays of vertices
	glEnableClientState(GL_VERTEX_ARRAY);
	
	// Select a map file
	if (!M.DoDialog()) exit(0);
	
	// Run!
        
	glutMainLoop();
        
        return 1;
}
