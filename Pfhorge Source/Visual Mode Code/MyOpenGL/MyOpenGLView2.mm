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
                                                    
#import "MyOpenGLView2.h"
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <Foundation/Foundation.h>
#import "LEExtras.h"
#import "LEPolygon.h"
#import <GLKit/GLKit.h>

// Here is my Map Viewer:

// For now, I'll try to test basic OpenGL rendering and viewing -- and navigation.

#include <math.h>
//#include "MapManager.h"
//#include "KeyControls.h"

#import <ApplicationServices/ApplicationServices.h>

//#import "InputHelpers.h"


#import <AppKit/AppKit.h>
//#import "InputHelpers.h"

#include <IOKit/IOKitLib.h>
#if 0
//#import <drivers/event_status_driver.h>
#else
// TJW - The definition of NXMouseScaling is not present in the public headers right now.
//       Copied in from Darwin.   Also, event_status_driver.h imports two headers that
//       don't exist in public builds (one of which contains this typedef).

#if 0
#define NX_MAXMOUSESCALINGS 20

typedef struct evsioMouseScaling        /* Match old struct names in kernel */
{
    int numScaleLevels;
    short scaleThresholds[NX_MAXMOUSESCALINGS];
    short scaleFactors[NX_MAXMOUSESCALINGS];
} NXMouseScaling;
#endif

extern "C" {
typedef mach_port_t NXEventHandle;

extern NXEventHandle NXOpenEventStatus(void);
extern void NXCloseEventStatus(NXEventHandle handle);

extern void NXSetMouseScaling(NXEventHandle handle, NXMouseScaling *scaling);
extern void NXGetMouseScaling(NXEventHandle handle, NXMouseScaling *scaling);

extern double NXKeyRepeatInterval(NXEventHandle handle);
extern double NXKeyRepeatThreshold(NXEventHandle handle);
extern void NXSetKeyRepeatInterval(NXEventHandle handle, double seconds);
extern void NXSetKeyRepeatThreshold(NXEventHandle handle, double threshold);
}
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
        //NXSetMouseScaling(eventStatus, &originalMouseScaling);
    } else {
        // Save the old scaling value
        //NXGetMouseScaling(eventStatus, &originalMouseScaling);

        // Setting a scaling curve with one factor of -1 turns off the OS scaling.  Setting it to 1 will NOT turn off the scaling.  This will make it linear, but the OS will still throw away bits of mouse movement precision
        newScaling.numScaleLevels = 1;
        newScaling.scaleThresholds[0] = 1;
        newScaling.scaleFactors[0] = -1;
        //NXSetMouseScaling(eventStatus, &newScaling);
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
//MapManager M;

// Key-controls object
//KeyControls K;

#define kWindowWidth	512
#define kWindowHeight	256

const short TextDefaultsID = 650;

bool ShowText, ShowFramerate;
RGBColor TextColor, TextShadowColor;
// int theRenderMode;

// For finding framerates
//int PrevTick = 0;
//float AvgTickIntvl = -1; // A value of -1 means "reset"
//bool TakingAverage = false;

// Range of fog depths:
const float MIN_FOG = 1;
const float MAX_FOG = 64;

//////////////////////////// RESIZE OPENGL SCREEN \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////    This function resizes the viewport for OpenGL.
/////
//////////////////////////// RESIZE OPENGL SCREEN \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void SizeOpenGLScreen(int width, int height)            // Initialize The GL Window
{
    if (height==0)                                        // Prevent A Divide By Zero error
    {
        height=1;                                        // Make the Height Equal One
    }

    glViewport(0,0,width,height);                        // Make our viewport the whole window
                                                        // We could make the view smaller inside
                                                        // Our window if we wanted too.
                                                        // The glViewport takes (x, y, width, height)
                                                        // This basically means, what our our drawing boundries

    glMatrixMode(GL_PROJECTION);                        // Select The Projection Matrix
    glLoadIdentity();                                    // Reset The Projection Matrix

                                                        // Calculate The Aspect Ratio Of The Window
                                                        // The parameters are:
                                                        // (view angle, aspect ration of the width to the height, 
                                                        //  The closest distance to the camera before it clips, 
                  // FOV        // Ratio                //  The farthest distance before it stops drawing)
	glMultMatrixf(GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), (GLfloat)width/(GLfloat)height, 1.0f, 512.0f).m);

    glMatrixMode(GL_MODELVIEW);                            // Select The Modelview Matrix
    glLoadIdentity();                                    // Reset The Modelview Matrix
}


/////////////////////////////////   INITIALIZE OPENGL  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
//////
//////         This function handles all the initialization for openGL
//////
/////////////////////////////////   INITIALIZE OPENGL  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void InitializeGL(int width, int height)
{
    glEnable(GL_DEPTH_TEST);                                // Enables Depth Testing
    
    // Here, we turn on a light and enable lighting.  We don't need to
    // set anything else for lighting because we will just take the defaults.
    // We also want color, so we turn that on too.  We don't load any normals from
    // our .raw file so we will calculate some simple face normals to get a decent
    // perspective of the terrain.

    glEnable(GL_LIGHT0);                                // Turn on a light with defaults set
    glEnable(GL_LIGHTING);                              // Turn on lighting
    glEnable(GL_COLOR_MATERIAL);                        // Allow color
	
	SizeOpenGLScreen(width, height);                        // resize the OpenGL Viewport to the given height and width
}


///////////////////////////////// CREATE PYRAMID \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This creates a pyramid with the center being (X, Y, Z).
/////   The width and height depend on the WIDTH and HEIGHT passed in
/////
///////////////////////////////// CREATE PYRAMID \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void CreatePyramid(float x, float y, float z, int width, int height)
{
    // Start rendering the 4 triangles for the sides
    glBegin(GL_TRIANGLES);      
        
        // These vertices create the Back Side
        glColor3ub(255, 255, 0);   glVertex3f(x, y + height, z);                    // Top point
        glColor3ub(255, 255, 255); glVertex3f(x - width, y - height, z - width);    // Bottom left point
        glColor3ub(255, 0, 0); glVertex3f(x + width, y - height, z - width);  // Bottom right point

        // These vertices create the Front Side
        glColor3ub(255, 255, 0);   glVertex3f(x, y + height, z);                    // Top point
        glColor3ub(255, 255, 255); glVertex3f(x + width, y - height, z + width);  // Bottom right point
        glColor3ub(255, 0, 0); glVertex3f(x - width, y - height, z + width);    // Bottom left point

        // These vertices create the Front Left Side
        glColor3ub(255, 255, 0);   glVertex3f(x, y + height, z);                    // Top point
        glColor3ub(255, 0, 0); glVertex3f(x - width, y - height, z + width);    // Front bottom point
        glColor3ub(255, 255, 255); glVertex3f(x - width, y - height, z - width);    // Bottom back point

        // These vertices create the Front right Side
        glColor3ub(255, 255, 0);   glVertex3f(x, y + height, z);                    // Top point
        glColor3ub(255, 0, 0); glVertex3f(x + width, y - height, z - width);    // Bottom back point
        glColor3ub(255, 255, 255); glVertex3f(x + width, y - height, z + width);    // Front bottom point
            
    glEnd();

    // Now render the bottom of our pyramid

    glBegin(GL_QUADS);

        // These vertices create the bottom of the pyramid
        glColor3ub(0, 0, 255); glVertex3f(x - width, y - height, z + width);    // Front left point
        glColor3ub(0, 0, 255); glVertex3f(x + width, y - height, z + width);    // Front right point
        glColor3ub(0, 0, 255); glVertex3f(x + width, y - height, z - width);    // Back right point
        glColor3ub(0, 0, 255); glVertex3f(x - width, y - height, z - width);    // Back left point
    glEnd();
}


///////////////////////////////// DRAW 3D GRID \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This function create a simple grid to get a better view of the animation
/////
///////////////////////////////// DRAW 3D GRID \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void Draw3DSGrid()
{
    // Turn the lines GREEN
    glColor3ub(0, 255, 0);

    // Draw a 1x1 grid along the X and Z axis'
    for(float i = -256; i <= 256; i += 4)
    {
        // Start drawing some lines
        glBegin(GL_LINES);

            // Do the horizontal lines (along the X)
            glVertex3i(-256, 0, i);
            glVertex3i(256, 0, i);

            // Do the vertical lines (along the Z)
            glVertex3i(i, 0, -256);
            glVertex3i(i, 0, 256);

        // Stop drawing lines
        glEnd();
    }
}


///////////////////////////////// DRAW SPIRAL TOWERS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This draws a spiral of pyramids to maneuver around
/////
///////////////////////////////// DRAW SPIRAL TOWERS \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void DrawSpiralTowers()
{
    const float PI = 3.14159f;                          // Create a constant for PI
    const float kIncrease = PI / 16.0f;                 // This is the angle we increase by in radians
    const float kMaxRotation = PI * 6;                  // This is 1080 degrees of rotation in radians (3 circles)
    float radius = 40;                                  // We start with a radius of 40 and decrease towards the center

    // Keep looping until we go past the max degrees of rotation (which is 3 full rotations)
    for(float degree = 0; degree < kMaxRotation; degree += kIncrease)
    {
        // Here we use polar coordinates for the rotations, but we swap the y with the z
        float x = float(radius * cos(degree));          // Get the x position for the current rotation and radius
        float z = float(radius * sin(degree));          // Get the z position for the current rotation and radius

        // Create a pyramid for every degree in our spiral with a width of 1 and height of 3 
        CreatePyramid(x, 3, z, 1, 3);
    
        // Decrease the radius by the constant amount so the pyramids spirals towards the center
        radius -= 40 / (kMaxRotation / kIncrease);
    }   
}


// Fog translation: slider position (0 to 1) to actual depth
static float FogSliderToActualDepth(float Position)
    {return MIN_FOG*pow((MAX_FOG/MIN_FOG),Position);}

/*
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
*/
@implementation MyOpenGLView

-(id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	g_Camera = new CCamera();
	NSLog(@"***Made Camera 1***");
	
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	
	if (self == nil)
		return nil;
	
	g_Camera = new CCamera();
	NSLog(@"***Made Camera 2***");
	
	return self;
}

+ (void)initialize;
{
    distantPast = [[NSDate distantPast] retain];
}

///////////////////////////////// RENDER SCENE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This function renders the entire scene.
/////
///////////////////////////////// RENDER SCENE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

- (void)renderScene 
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); // Clear The Screen And The Depth Buffer
    glLoadIdentity();                                   // Reset The matrix

    // Tell OpenGL where to point the camera
    g_Camera->Look();
	
			glPolygonOffset(1,1);
			glEnable(GL_POLYGON_OFFSET_FILL);
	
    // Draw a grid so we can get a good idea of movement around the world       
    //Draw3DSGrid();

    // Draw the pyramids that spiral in to the center
    //DrawSpiralTowers();
	
	glLineWidth(1);
	
	[[theLevelData getThePolys]  makeObjectsPerformSelector:@selector(render)];
	
    // Swap the backbuffers to the foreground
    //SDL_GL_SwapBuffers();
}


///////////////////////////////// INIT GAME WINDOW \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////    This function initializes the game window.
/////
///////////////////////////////// INIT GAME WINDOW \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

- (void)Init
{
    InitializeGL(kWindowWidth, kWindowHeight);    // Init OpenGL with the global rect
    //SDL_WM_GrabInput(SDL_GRAB_ON);

    //if ( SDL_ShowCursor(SDL_DISABLE) != SDL_DISABLE )
    //          cerr << SDL_GetError() << endl;
    
    // Enable Key Repeat
    /*if( SDL_EnableKeyRepeat(100,SDL_DEFAULT_REPEAT_INTERVAL) )
    {
        cerr << "Failed enabling key repeat" << endl;
        Quit(1);
    }*/

	g_Camera = new CCamera();
	NSLog(@"***Made Camera 3***");

    // *Hint* We will put all our game init stuff here
    // Some things include loading models, textures and network initialization
                         //Position      View          Up Vector
    g_Camera->PositionCamera(0, 1.5, 6,   0, 1.5, 0,   0, 1, 0 );    
}

- (void)doMapRenderingLoopWithMapData:(LELevelData *)theLevel shapesLocation:(NSString *)theShapesLocation
{
    bool done = NO, downKey = NO, leftKey = NO, rightKey = NO, upKey = NO;
    bool forwardKey = NO, backwardKey = NO, slideLeftKey = NO, slideRightKey = NO;
    
    bool MouseButtonPressed = NO;
    
    bool  invertMouse 		= [preferences boolForKey:VMInvertMouse];
    float mouseSpeedMultiplier 	= [preferences floatForKey:VMMouseSpeed];
    NSInteger   keySpeed		= [preferences integerForKey:VMKeySpeed];
    
    NSEvent *event;
    ///NSAutoreleasePool *pool;
    double deltaX, deltaY;
    NSEventModifierFlags previousFlags = 0, newFlags, changed, down;
    unsigned int previousMouseButtons = 0, newMouseButtons;
    	//float HorizStep, VertStep;
	//HorizStep = VertStep = M.MP.GetMotionSpeed();
    
    unichar upKeyUnichar = [preferences integerForKey:VMUpKey];
    unichar downKeyUnichar = [preferences integerForKey:VMDownKey];
    unichar leftKeyUnichar = [preferences integerForKey:VMLeftKey];
    unichar rightKeyUnichar = [preferences integerForKey:VMRightKey];
    
    unichar forwardKeyUnichar = [preferences integerForKey:VMForwardKey];
    unichar backwardKeyUnichar = [preferences integerForKey:VMBackwardKey];
    unichar slideLeftKeyUnichar = [preferences integerForKey:VMSlideLeftKey];
    unichar slideRightKeyUnichar = [preferences integerForKey:VMSlideRightKey];
	
	// *** INIT STUFF ***
	[self Init];
	
    theLevelData = theLevel;
    
    if (theLevelData == nil)
        return;
    
    thePathToShapesFile = [theShapesLocation copy];
    
    // Turn off key repeat and input scaling to get something more like 'raw' input
    //SetMouseScalingEnabled(NO);
    //SetKeyboardRepeatEnabled(NO);
    
    [OGLwindow setAcceptsMouseMovedEvents:YES];
    
    // Process events
    while (!done) {
        NSEventType type;
        NSPoint MouseLoc;
		
		g_Camera->Update(forwardKey, backwardKey, leftKey, rightKey);
        
        // This polls for an event.  If there isn't an event read immediately, it will return nil.  In a real game, we would loop until we had processed all pending events and would then go about our normal game processing
        event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:distantPast inMode:NSDefaultRunLoopMode dequeue:YES];
        if (event == nil) {
            //[pool release];
            //DisplayFunc([thePathToShapesFile length] > 1);
            [self renderScene];
			
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
                //M.VC.StartDrag(MouseLoc.x,MouseLoc.y);
                MouseButtonPressed = YES;
                break;
            case NSLeftMouseUp:
            case NSRightMouseUp:
            case 26: // New undocumented 'other' mouse up
                MouseButtonPressed = NO;
                break;
            case NSSystemDefined:
			/*
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
                }*/
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
                
				/*
                if (MouseButtonPressed)
                {
                    MouseLoc = [event locationInWindow];
                    M.VC.DragTo(MouseLoc.x,MouseLoc.y);
                    M.VC.SetView();
                }*/
                break;
            case NSScrollWheel:
                //[self _logString: [NSString stringWithFormat: @"SCROLL WHEEL dx=%f dy=%f dz=%f\n", [event deltaX], [event deltaY], [event deltaZ]]];
                break;
            case NSKeyDown:
            case NSKeyUp:
                {
                    NSString *characters;
                    unichar c;
                    NSInteger characterIndex, characterCount;
                    
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
							/*
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
							*/
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
    //SetMouseScalingEnabled(YES);
    //SetKeyboardRepeatEnabled(YES);
    return;
    //[NSApp terminate: nil];
   //glutSwapBuffers();
}

-(void)dealloc
{
	delete g_Camera;
	
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


