
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "LELevelData.h"

#include "GLMain.h"
#include "Camera.h"

enum {
    wireframedPolys = 0,
    coloredPolys = 1,
    texturedPolys = 2
};

@interface MyOpenGLView : NSOpenGLView
{
    IBOutlet NSWindow *OGLwindow;
    
    NSTimer *timer;
    
    LELevelData *theLevelData;
    NSString *thePathToShapesFile;
	
	CCamera *g_Camera;
}

- (void)Init;
- (void)renderScene;

- (void)doMapRenderingLoopWithMapData:(LELevelData *)theLevel shapesLocation:(NSString *)theShapesLocation;

- (void)timerDraw:(NSTimer *)timer;

- (void)drawRect:(NSRect)rect;

@end
