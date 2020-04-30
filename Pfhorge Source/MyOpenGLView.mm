/*

 This code was created by Jeff Molofee '99

 If you've found this code useful, please let me know.

 Visit me at www.demonews.com/hosted/nehe

_______________________________________________________________________________
                                                                    26/07/2001
  This code was ported to Mac OS X's Cocoa API by Pierre d'Herbemont
  Note that this code was also ported to MacOS X's Carbon API by Raal Goff.
                                                            (unreality@mac.com)
  Hope you enjoy this code. If you have any suggestion let me know...
  
  steg  (steg@mac.com)								*/
                                                    
#import "MyOpenGLView.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <Foundation/Foundation.h>
#import "LEExtras.h"
#include "MapManager.h"
#include "KeyControls.h"

// Here is my Map Viewer:

// For now, I'll try to test basic OpenGL rendering and viewing -- and navigation.

#include <math.h>
//#include "MapManager.h"
//#include "KeyControls.h"

#import <ApplicationServices/ApplicationServices.h>

//#import "InputHelpers.h"


#import <AppKit/AppKit.h>
//#import "InputHelpers.h"

#if 1
#import <drivers/event_status_driver.h>
#else
// TJW - The definition of NXMouseScaling is not present in the public headers right now.
//       Copied in from Darwin.   Also, event_status_driver.h imports two headers that
//       don't exist in public builds (one of which contains this typedef).

#define NX_MAXMOUSESCALINGS 20

typedef struct evsioMouseScaling        /* Match old struct names in kernel */
{
    int numScaleLevels;
    short scaleThresholds[NX_MAXMOUSESCALINGS];
    short scaleFactors[NX_MAXMOUSESCALINGS];
} NXMouseScaling;

typedef mach_port_t NXEventHandle;

extern NXEventHandle NXOpenEventStatus(void);
extern void NXCloseEventStatus(NXEventHandle handle);

extern void NXSetMouseScaling(NXEventHandle handle, NXMouseScaling *scaling);
extern void NXGetMouseScaling(NXEventHandle handle, NXMouseScaling *scaling);

extern double NXKeyRepeatInterval(NXEventHandle handle);
extern double NXKeyRepeatThreshold(NXEventHandle handle);
extern void NXSetKeyRepeatInterval(NXEventHandle handle, double seconds);
extern void NXSetKeyRepeatThreshold(NXEventHandle handle, double threshold);

#endif



static BOOL mouseScalingEnabled = YES;
static NXMouseScaling originalMouseScaling;

void SetMouseScalingEnabled(BOOL enabled)
{
    NXEventHandle eventStatus;
    NXMouseScaling newScaling;

    if (mouseScalingEnabled == enabled)
        return;
        
    if (!(eventStatus = NXOpenEventStatus()))
        return;
    
    // Set or restore the scaling
    if (enabled) {
        NXSetMouseScaling(eventStatus, &originalMouseScaling);
    } else {
        // Save the old scaling value
        NXGetMouseScaling(eventStatus, &originalMouseScaling);

        // Setting a scaling curve with one factor of -1 turns off the OS scaling.  Setting it to 1 will NOT turn off the scaling.  This will make it linear, but the OS will still throw away bits of mouse movement precision
        newScaling.numScaleLevels = 1;
        newScaling.scaleThresholds[0] = 1;
        newScaling.scaleFactors[0] = -1;
        NXSetMouseScaling(eventStatus, &newScaling);
    }
		
    NXCloseEventStatus(eventStatus);
    mouseScalingEnabled = enabled;
}

static BOOL           keyboardRepeatEnabled = YES;
static double         originalKeyboardRepeatInterval;
static double         originalKeyboardRepeatThreshold;

void SetKeyboardRepeatEnabled(BOOL enabled)
{
    NXEventHandle eventStatus;
    
    if (keyboardRepeatEnabled == enabled)
        return;

    if (!(eventStatus = NXOpenEventStatus()))
        return;

    // Set or restore the configuration
    if (enabled) {
        NXSetKeyRepeatInterval(eventStatus, originalKeyboardRepeatInterval);
        NXSetKeyRepeatThreshold(eventStatus, originalKeyboardRepeatThreshold);
    } else {
        // Save the old configuration if we are about to disable repeats
        originalKeyboardRepeatInterval = NXKeyRepeatInterval(eventStatus);
        originalKeyboardRepeatThreshold = NXKeyRepeatThreshold(eventStatus);

        // No repeat events for 40 days and 40 nights
        NXSetKeyRepeatInterval(eventStatus, 3456000.0f);
        NXSetKeyRepeatThreshold(eventStatus, 3456000.0f);
    }

    NXCloseEventStatus(eventStatus);
    keyboardRepeatEnabled = enabled;
}

static NSDate *distantPast;

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

#define kWindowWidth	512
#define kWindowHeight	256

const short TextDefaultsID = 650;

bool ShowText, ShowFramerate;
RGBColor TextColor, TextShadowColor;
// int theRenderMode;

// For finding framerates
int PrevTick = 0;
float AvgTickIntvl = -1; // A value of -1 means "reset"
bool TakingAverage = false;

// Range of fog depths:
const float MIN_FOG = 1;
const float MAX_FOG = 64;

// Fog translation: slider position (0 to 1) to actual depth
static float FogSliderToActualDepth(float Position)
    {return MIN_FOG*pow((MAX_FOG/MIN_FOG),Position);}


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
	for (unsigned int ic=0; ic<strlen(Text); ic++)
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


GLvoid DisplayFunc(bool CanBeTextured) {

	// Need to clear both color and depth
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        bool UseFog = M.VO.UseFog;
         if (UseFog) {
            glEnable(GL_FOG);
            glFogf(GL_FOG_DENSITY,1/(1024*M.VO.FogDepth));
        }
	
	// Update view context and do visibility
	M.UpdateViewCtxtDoVis();
                
	// Get the rendering mode
	// One-based to zero-based indexing
	int RenderMode = M.VO.SelectRenderMode;
 	
	bool UseZBuffer = M.MP.ZBufferCB;
	
	if (!UseZBuffer) glDisable(GL_DEPTH_TEST);
	
	// Fallback in case of absent textures
	switch(RenderMode) {
	case MapManager::Render_Textured:
	case MapManager::Render_Averaged:
		if (!CanBeTextured) {
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
	bool OffsetWires = M.VO.OffsetWires;
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
	int SideVisMode = M.VO.SelectVisibleSides;
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
        
        if (UseFog) glDisable(GL_FOG);
    
	ShowText = false;
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
        ShowFramerate = false;
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
		int HPos = 8, VPos = (int)M.VC.Height-8;
		
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
	
    //glutSwapBuffers();
    if (ShowFramerate) glutPostRedisplay();
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


GLvoid InitGL(LELevelData *theLevel, NSString *thePathToShapesFile) {
	
	// Initialize the view context:
	// Units are Marathon's internal units
	// Width and Height are Marathon's standard values
	M.VC.Width = 640;
	M.VC.Height = 320;
                
	glClearColor(0.0f, 1.0f, 1.0f, 0.0f);		// This Will Clear The Background Color To Black
	glClearDepth(1.0);							// Enables Clearing Of The Depth Buffer
	glDepthFunc(GL_LESS);						// The Type Of Depth Test To Do
	glEnable(GL_DEPTH | GL_DOUBLE | GLUT_RGB);	// Enables Depth Testing
	glShadeModel(GL_SMOOTH);					// Enables Smooth Color Shading

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();							// Reset The Projection Matrix

	gluPerspective(45.0f,(GLfloat)kWindowWidth/(GLfloat)kWindowHeight,0.1f,100.0f);

	glMatrixMode(GL_MODELVIEW);
        
	InitText();
	K.Init();
        M.VO.SetImmediate();
 
	// Set up z-buffering;
	// use newest pixel at same position
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	
	// Do transparent surfaces correctly
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER,0.5);
	
	// Do perspective correction
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
        
	glEnableClientState(GL_VERTEX_ARRAY);
        
        M.DoDialog(theLevel,thePathToShapesFile);
        
}

@implementation MyOpenGLView

-(id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    return self;
}

+ (void) initialize;
{
    distantPast = [[NSDate distantPast] retain];
}

- (void)doMapRenderingLoopWithMapData:(LELevelData *)theLevel shapesLocation:(NSString *)theShapesLocation
{
    BOOL done = NO, downKey = NO, leftKey = NO, rightKey = NO, upKey = NO;
    BOOL forwardKey = NO, backwardKey = NO, slideLeftKey = NO, slideRightKey = NO;
    
    BOOL MouseButtonPressed = NO;
    
    BOOL  invertMouse 		= [preferences boolForKey:VMInvertMouse];
    float mouseSpeedMultiplier 	= [preferences floatForKey:VMMouseSpeed];
    int   keySpeed		= [preferences integerForKey:VMKeySpeed];
    
    NSEvent *event;
    ///NSAutoreleasePool *pool;
    CGMouseDelta deltaX, deltaY;
    unsigned int previousFlags = 0, newFlags, changed, down;
    unsigned int previousMouseButtons = 0, newMouseButtons;
    	float HorizStep, VertStep;
	HorizStep = VertStep = M.MP.GetMotionSpeed();
    
    unichar upKeyUnichar = [preferences integerForKey:VMUpKey];
    unichar downKeyUnichar = [preferences integerForKey:VMDownKey];
    unichar leftKeyUnichar = [preferences integerForKey:VMLeftKey];
    unichar rightKeyUnichar = [preferences integerForKey:VMRightKey];
    
    unichar forwardKeyUnichar = [preferences integerForKey:VMForwardKey];
    unichar backwardKeyUnichar = [preferences integerForKey:VMBackwardKey];
    unichar slideLeftKeyUnichar = [preferences integerForKey:VMSlideLeftKey];
    unichar slideRightKeyUnichar = [preferences integerForKey:VMSlideRightKey];
    
    // Up here because it sets a lot of defaults
    M.InitDialog();
    
    M.VO.SelectRenderMode = [preferences integerForKey:VMRenderMode];
    
    M.VO.ShowLiquids = [preferences boolForKey:VMShowLiquids];
    M.VO.ShowTrans = [preferences boolForKey:VMShowTransparent];
    M.VO.ShowLdscp = [preferences boolForKey:VMShowLandscapes];
    M.VO.ShowInvld = [preferences boolForKey:VMShowInvalid];
    M.VO.ShowObjects = [preferences boolForKey:VMShowObjects];
        
    M.VO.SelectPlatformState = [preferences boolForKey:VMPlatformState];
    M.VO.SelectVisibleSides = [preferences integerForKey:VMVisibleSide];
    M.VO.SelectVerticalLook = [preferences integerForKey:VMVerticalLook];
    M.VO.SelectFieldOfView = [preferences integerForKey:VMFieldOfView];
     
    if ([preferences boolForKey:VMSmoothRendering])
    {
        M.VO.SelectCloseupRender = ViewOptions::CloseupRndr_Linear;
        M.VO.SelectDistantRender = ViewOptions::DistantRndr_Linear_Mipmap_Linear;
    }
    else
    {
        M.VO.SelectCloseupRender = ViewOptions::CloseupRndr_Nearest;
        M.VO.SelectDistantRender = ViewOptions::DistantRndr_Nearest;
    }
    
    M.VO.LiquidsTransparent = [preferences boolForKey:VMLiquidsTransparent];
    M.VO.UseLights = [preferences boolForKey:VMUseLighting];
    M.VO.SelectLightType = [preferences integerForKey:VMWhatLighting];
    
    M.VO.UseFog = [preferences boolForKey:VMUseFog];
    M.VO.FogDepth = FogSliderToActualDepth([preferences floatForKey:VMFogDepth]);
    
    M.MP.VisModePopup = [preferences integerForKey:VMVisibilityMode];
    
    M.UpdateViewOptions();
    
    /*
	CheckBoxList[OffsetWires].DfltChecked =
		SetValue(ControlStringsID,CSIndx++,0,1);
	PopupList[SelectNearDistance].DfltState =
		SetValue(ControlStringsID,CSIndx++,1,NUM_NEAR_DISTANCES);
	PopupList[SelectFarDistance].DfltState =
		SetValue(ControlStringsID,CSIndx++,1,NUM_FAR_DISTANCES);
                */
    
    theLevelData = theLevel;
    
    if (theLevelData == nil)
        return;
    
    thePathToShapesFile = [theShapesLocation copy];
    
    // LP: will handle all the various options inside of here
     
    if ([thePathToShapesFile length] > 1)
    {
        InitGL(theLevel, thePathToShapesFile);
    }
    else
    {
        thePathToShapesFile = nil;
        InitGL(theLevel, nil);
    }
    
  /*  
    timer = [NSTimer scheduledTimerWithTimeInterval:1/60
                target:self 
                selector:@selector(timerDraw:) 
                userInfo:nil 
                repeats:YES];*/
    
    // Turn off key repeat and input scaling to get something more like 'raw' input
    SetMouseScalingEnabled(NO);
    SetKeyboardRepeatEnabled(NO);
    
    [OGLwindow setAcceptsMouseMovedEvents: YES];
    
    // Process events
    while (!done) {
        NSEventType type;
        NSPoint MouseLoc;
                
        if (forwardKey == YES)
        {
           // M.VC.YawAngle += 1;
            // Move forward
            
                M.VC.Save();
		M.VC.FindDirs();
		M.VC.x += keySpeed*M.VC.Forward_x;//HorizStep*M.VC.Forward_x;
		M.VC.y += keySpeed*M.VC.Forward_y;//HorizStep*M.VC.Forward_y;
		M.VC.SetView();
        }
        
        if (backwardKey == YES)
        {
        		// Move backward
		M.VC.Save();
		M.VC.FindDirs();
		M.VC.x -= keySpeed*M.VC.Forward_x;//HorizStep*M.VC.Forward_x;
		M.VC.y -= keySpeed*M.VC.Forward_y;//HorizStep*M.VC.Forward_y;
		M.VC.SetView();
        }
        
        if (upKey == YES)
        {
        		// Move upward
		M.VC.Save();
		M.VC.z += keySpeed;//VertStep;
		M.VC.SetView();
        }
        
        if (downKey == YES)
        {
        		// Move downward
		M.VC.Save();
		M.VC.z -= keySpeed;//VertStep;
		M.VC.SetView();
        }
        
        
        if (leftKey == YES)
        {
           // M.VC.YawAngle += 1;
            // Move forward
                M.VC.Save();
		M.VC.FindDirs();
		///M.VC.x += 66*M.VC.Forward_x;//HorizStep*M.VC.Forward_x;
		///M.VC.y += 66*M.VC.Forward_y;//HorizStep*M.VC.Forward_y;
                
                M.VC.YawAngle -= (keySpeed * 0.1);
                
		M.VC.SetView();
        }
        if (rightKey == YES)
        {
           // M.VC.YawAngle += 1;
            // Move forward
                M.VC.Save();
		M.VC.FindDirs();
		///M.VC.x += 66*M.VC.Forward_x;//HorizStep*M.VC.Forward_x;
		///M.VC.y += 66*M.VC.Forward_y;//HorizStep*M.VC.Forward_y;
                
                M.VC.YawAngle += (keySpeed * 0.1);
                
		M.VC.SetView();
        }
        if (slideLeftKey == YES)
        {
		// Move leftward
		M.VC.Save();
		M.VC.FindDirs();
		M.VC.x -= keySpeed * M.VC.Right_x;
		M.VC.y -= keySpeed * M.VC.Right_y;
		M.VC.SetView();
        }
        if (slideRightKey == YES)
        {
		// Move rightward
		M.VC.Save();
		M.VC.FindDirs();
		M.VC.x += keySpeed * M.VC.Right_x;
		M.VC.y += keySpeed * M.VC.Right_y;
		M.VC.SetView();
        }
        
        
        // This polls for an event.  If there isn't an event read immediately, it will return nil.  In a real game, we would loop until we had processed all pending events and would then go about our normal game processing
        event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:distantPast inMode:NSDefaultRunLoopMode dequeue:YES];
        if (event == nil) {
            //[pool release];
            DisplayFunc([thePathToShapesFile length] > 1);
            
            glFinish();
            // We'd break out of this loop instead of continuing in a real game (as mentioned above).
            continue; // <-- continue;
        }
        
        // Handle the event we got
        type = [event type];
        switch (type) {
            // Mouse up/down
            case NSLeftMouseDown:
            case NSRightMouseDown:
            case 25: // New undocumented 'other' mouse down
                MouseLoc = [event locationInWindow];
                M.VC.StartDrag(MouseLoc.x,MouseLoc.y);
                MouseButtonPressed = YES;
                break;
            case NSLeftMouseUp:
            case NSRightMouseUp:
            case 26: // New undocumented 'other' mouse up
                MouseButtonPressed = NO;
                break;
            case NSSystemDefined:
                if ([event subtype] == 7) {
                    unsigned int buttonIndex;
                    
                    newMouseButtons = [event data2];
                    changed = previousMouseButtons ^ newMouseButtons;
                    
                    for (buttonIndex = 0; buttonIndex < 32; buttonIndex++) {
                        if (changed & (1<<buttonIndex)) {
                            down = newMouseButtons & (1<<buttonIndex);
                            //[self _logString: [NSString stringWithFormat: @"MOUSE %d %@\n", buttonIndex, down ? @"DOWN" : @"UP"]];
                        }
                    }
                    
                    previousMouseButtons = newMouseButtons;
                }
                break;
            case NSMouseMoved:
            case NSLeftMouseDragged:
            case NSRightMouseDragged:
            case 27: // New undocumented 'other' mouse dragged
                // Ignore the contents of these events -- just use them as a trigger to call CoreGraphics
                //CGGetLastMouseDelta(&deltaX, &deltaY);
                //[dxField setIntValue: deltaX];
                //[dyField setIntValue: deltaY];
               // NSLog(@"deltaX: %g   deltaY: %g", deltaX, deltaY);
                //M.VC.YawAngle += (deltaX * mouseSpeedMultiplier);
                //if (!invertMouse)
                //    M.VC.PitchAngle -= ((deltaY*.01) * mouseSpeedMultiplier);
                //else
                //    M.VC.PitchAngle += ((deltaY*.01) * mouseSpeedMultiplier);
                
                if (MouseButtonPressed)
                {
                    MouseLoc = [event locationInWindow];
                    M.VC.DragTo(MouseLoc.x,MouseLoc.y);
                    M.VC.SetView();
                }
                break;
            case NSScrollWheel:
                //[self _logString: [NSString stringWithFormat: @"SCROLL WHEEL dx=%f dy=%f dz=%f\n", [event deltaX], [event deltaY], [event deltaZ]]];
                break;
            case NSKeyDown:
            case NSKeyUp:
                {
                    NSString *characters;
                    unichar c;
                    unsigned int characterIndex, characterCount;
                    
                    // There could be multiple characters in the event.  Additionally, if shift is down, these characters will be upper case.
                    characters = [event charactersIgnoringModifiers];
                    characterCount = [characters length];
                    for (characterIndex = 0; characterIndex < characterCount; characterIndex++) {
                        c = [characters characterAtIndex: characterIndex];
                        //[self _logString: [NSString stringWithFormat: @"KEY %@:  unichar=0x%02x\n", (type == NSKeyDown) ? @"DOWN" : @"UP", c]];
                        
                        // These keys are all to change overall settings, and are thus not auto-repeat keys
                        if (type == NSKeyDown)
                        {
                        BOOL IsChecked;
                        int PopupIndex;
                        float SliderLocation;
                        switch(c)
                        {
                        case NSF1FunctionKey:
                            PopupIndex = ([preferences integerForKey:VMRenderMode] + 1) % ViewOptions::NUM_RENDER_MODES;
                            [preferences setInteger:PopupIndex forKey:VMRenderMode];
                            M.VO.SelectRenderMode = PopupIndex;
                            M.VO.SetImmediate();
                            break;
		
                        case NSF2FunctionKey:
                            IsChecked = !([preferences boolForKey:VMShowTransparent]);
                            [preferences setBool:IsChecked forKey:VMShowTransparent];
                            M.VO.ShowTrans = IsChecked;
                            break;
		
                        case NSF3FunctionKey:
                            IsChecked = !([preferences boolForKey:VMShowLandscapes]);
                            [preferences setBool:IsChecked forKey:VMShowLandscapes];
                            M.VO.ShowLdscp = IsChecked;
                            break;
		
                        case NSF4FunctionKey:
                            IsChecked = !([preferences boolForKey:VMShowLiquids]);
                            [preferences setBool:IsChecked forKey:VMShowLiquids];
                            M.VO.ShowLiquids = IsChecked;
                            break;
                        
                        case NSF5FunctionKey:
                            IsChecked = !([preferences boolForKey:VMShowInvalid]);
                            [preferences setBool:IsChecked forKey:VMShowInvalid];
                            M.VO.ShowInvld = IsChecked;
                                 
                        case NSF6FunctionKey:
                            PopupIndex = ([preferences integerForKey:VMVisibleSide] + 1) % ViewOptions::NUM_SIDE_VISIBILITIES;
                            [preferences setInteger:PopupIndex forKey:VMVisibleSide];
                            M.VO.SelectVisibleSides = PopupIndex;
                            M.VO.SetImmediate();
                            break;
	
                        case NSF7FunctionKey:
                            PopupIndex = ([preferences integerForKey:VMFieldOfView] + 1) % ViewOptions::NUM_FOV_VALUES;
                            [preferences setInteger:PopupIndex forKey:VMFieldOfView];
                            M.VO.SelectFieldOfView = PopupIndex;
                            M.UpdateViewOptions();
                            break;
	
                        case NSF8FunctionKey:
                            IsChecked = !([preferences boolForKey:VMUseLighting]);
                            [preferences setBool:IsChecked forKey:VMUseLighting];
                            M.VO.UseLights = IsChecked;
                            break;
	
                        case NSF9FunctionKey:
                            PopupIndex = ([preferences integerForKey:VMWhatLighting] + 1) % ViewOptions::NUM_LIGHT_VALUES;
                            [preferences setInteger:PopupIndex forKey:VMWhatLighting];
                            M.VO.SelectLightType = PopupIndex;
                            M.UpdateViewOptions();
                            break;
                            
                        case NSF10FunctionKey:
                            IsChecked = !([preferences boolForKey:VMUseFog]);
                            [preferences setBool:IsChecked forKey:VMUseFog];
                            M.VO.UseFog = IsChecked;
                            break;
                          
                        case NSF11FunctionKey:
                            SliderLocation = [preferences floatForKey:VMFogDepth];
                            SliderLocation -= 0.05;
                            if (SliderLocation < 0) SliderLocation = 1;
                            [preferences setFloat:SliderLocation forKey:VMFogDepth];
                            M.VO.FogDepth = FogSliderToActualDepth(SliderLocation);
                            break;
                        
                        case NSF12FunctionKey:
                            PopupIndex = ([preferences integerForKey:VMVisibilityMode] + 1) % MotPort::NUM_VISIBILITY_MODES;
                            [preferences setInteger:PopupIndex forKey:VMVisibilityMode];
                            M.MP.VisModePopup = PopupIndex;
                            M.UpdateViewOptions();
                            break;
	
                        case NSF13FunctionKey:
                            IsChecked = !([preferences boolForKey:VMLiquidsTransparent]);
                            [preferences setBool:IsChecked forKey:VMLiquidsTransparent];
                            M.VO.LiquidsTransparent = IsChecked;
                            break;
	
                        case NSF14FunctionKey:
                            IsChecked = !([preferences boolForKey:VMShowObjects]);
                            [preferences setBool:IsChecked forKey:VMShowObjects];
                            M.VO.ShowObjects = IsChecked;
                            break;
                        
                        case NSF15FunctionKey:
                            PopupIndex = ([preferences integerForKey:VMPlatformState] + 1) % ViewOptions::NUM_PLATFORM_STATES;
                            [preferences setInteger:PopupIndex forKey:VMPlatformState];
                            M.VO.SelectPlatformState = PopupIndex;
                            M.UpdateViewOptions();
                            break;
                        
                        // Since we take over the event loop, 'cmd-q' will not quit the app.
                        // Quit is the "escape" key
                        case 0x1b:
                            done = YES;
                            break;
                        }
                        }
 
                        if (c == upKeyUnichar && (type == NSKeyDown))
                            upKey = YES;
                        if (c == downKeyUnichar && (type == NSKeyDown))
                            downKey = YES;
                        if (c == leftKeyUnichar && (type == NSKeyDown))
                            leftKey = YES;
                        if (c == rightKeyUnichar && (type == NSKeyDown))
                            rightKey = YES;
                        if (c == upKeyUnichar && (type == NSKeyUp))
                            upKey = NO;
                        if (c == downKeyUnichar && (type == NSKeyUp))
                            downKey = NO;
                        if (c == leftKeyUnichar && (type == NSKeyUp))
                            leftKey = NO;
                        if (c == rightKeyUnichar && (type == NSKeyUp))
                            rightKey = NO;

                        if (c == forwardKeyUnichar && (type == NSKeyDown))
                            forwardKey = YES;
                        if (c == backwardKeyUnichar && (type == NSKeyDown))
                            backwardKey = YES;
                        if (c == slideLeftKeyUnichar && (type == NSKeyDown))
                            slideLeftKey = YES;
                        if (c == slideRightKeyUnichar && (type == NSKeyDown))
                            slideRightKey = YES;
                        if (c == forwardKeyUnichar && (type == NSKeyUp))
                            forwardKey = NO;
                        if (c == backwardKeyUnichar && (type == NSKeyUp))
                            backwardKey = NO;
                        if (c == slideLeftKeyUnichar && (type == NSKeyUp))
                            slideLeftKey = NO;
                        if (c == slideRightKeyUnichar && (type == NSKeyUp))
                            slideRightKey = NO;
                    }
                }
                break;
            case NSFlagsChanged:
                newFlags = [event modifierFlags];
                changed = newFlags ^ previousFlags;
                
                if (changed & NSAlphaShiftKeyMask) {
                    down = newFlags & NSAlphaShiftKeyMask;
                    //[self _logString: down ? @"CAPS LOCK DOWN\n" : @"CAPS LOCK UP\n"];
                }
                
                if (changed & NSShiftKeyMask) {
                    down = newFlags & NSShiftKeyMask;
                    //[self _logString: down ? @"SHIFT DOWN\n" : @"SHIFT UP\n"];
                }
                
                if (changed & NSControlKeyMask) {
                    down = newFlags & NSControlKeyMask;
                    //[self _logString: down ? @"CONTROL DOWN\n" : @"CONTROL UP\n"];
                }
                
                if (changed & NSAlternateKeyMask) {
                    down = newFlags & NSAlternateKeyMask;
                    //[self _logString: down ? @"ALT DOWN\n" : @"ALT UP\n"];
                }
                
                if (changed & NSCommandKeyMask) {
                    down = newFlags & NSCommandKeyMask;
                    //[self _logString: down ? @"COMMAND DOWN\n" : @"COMMAND UP\n"];
                }
                
                if (changed & NSNumericPadKeyMask) {
                    down = newFlags & NSNumericPadKeyMask;
                    //[self _logString: down ? @"NUM LOCK DOWN\n" : @"NUM LOCK UP\n"];
                }

                previousFlags = newFlags;
                
                break;
            default:
                // Ignore any other events
                break;
        }
        
        // Make sure our window displays and the changes are fully flushed.  This is only relevant since we are using AppKit to display our logging.  Don't do this in your game!
        
        //[pool release];
    }
    

    NSLog(@"Seting the repeating back on...");
    SetMouseScalingEnabled(YES);
    SetKeyboardRepeatEnabled(YES);
    return;
    //[NSApp terminate: nil];
   //glutSwapBuffers();
}

-(void)dealloc
{
    //[timer release];
    
    // Restore input system settings
    SetMouseScalingEnabled(YES);
    SetKeyboardRepeatEnabled(YES);
    
    [super dealloc];
}

- (void)timerDraw:(NSTimer *)timer
{
    //[self display];
}

- (void)drawRect:(NSRect)rect 		// We do all the drawing stuff here (drawRect: is call when refreshing the view)
{
    
}

@end


