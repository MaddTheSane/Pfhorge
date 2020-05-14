//
//  OpenGLVisualModeController.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Feb 23 2002.
//  Copyright (c) 2001 Joshua D. Orr. All rights reserved.
//  
//  E-Mail:   dragons@xmission.com
//  
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//  or you can read it by running the program and selecting Phorge->About Phorge


#import "OpenGLVisualModeController.h"
#import "MyOpenGLView2.h"
#include "LEExtras.h"

@implementation OpenGLVisualModeController

// *********************** Class Methods ***********************
/*+ (id)sharedOpenGLVisualModeController {
    static OpenGLVisualModeController *sharedOpenGLVisualModeController = nil;

    if (!sharedOpenGLVisualModeController) {
        sharedOpenGLVisualModeController = [[OpenGLVisualModeController alloc] init];
    }

    return sharedOpenGLVisualModeController;
}*/

// *********************** Overridden/Regular Methods ***********************
#pragma mark -
#pragma mark ********* Overridden Methods *********

- (id)initWithLevelData:(LELevelData *)theLevel
{
    self = [super initWithWindowNibName:@"OpenGLVisualMode"];
    
    if (self == nil)
        return nil;
    
    levelData = [theLevel retain];
    
    return self;
}

/*- (void)awakeFromNib
{
    ///[super awakeFromNib];
    //[self showWindow:nil];
}*/

- (void)dealloc
{
    ///[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [levelData release];
    levelData = nil;
    
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    //[self saveChanges];
    
    [OpenGLViewOGLV doMapRenderingLoopWithMapData:levelData
                    shapesLocation:[preferences stringForKey:VMShapesPath]];
    
    //[[self window] performClose:self];
}

@end
