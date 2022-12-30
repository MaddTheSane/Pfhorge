//
//  LEPaletteController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Jul 15 2001.
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


#import <Cocoa/Cocoa.h>

//! New Tool enum Names, recommend these be used.
typedef NS_ENUM(NSInteger, LEPaletteTool) {
    LEPaletteToolArrow = 0,
    LEPaletteToolLine,
    LEPaletteToolPaint,
    LEPaletteToolText,
    LEPaletteToolHand,
    LEPaletteToolZoom,
    LEPaletteToolSampler,
    LEPaletteToolBrush,
    // Object Creation Tools
    LEPaletteToolMonster = 10,
    LEPaletteToolPlayer,
    LEPaletteToolItem,
    LEPaletteToolScenery,
    LEPaletteToolSound,
    LEPaletteToolGoal
};

@interface LEPaletteController : NSWindowController
{
    IBOutlet NSMatrix *toolPalette;
}

@property (class, readonly, retain) LEPaletteController *sharedPaletteController;

- (IBAction)toolSelection:(id)sender;
- (LEPaletteTool)currentTool;


- (BOOL)tryToMatchKey:(NSString *)keys NS_SWIFT_NAME(tryToMatch(key:));

- (void)selectArrowTool;
- (void)selectLineTool;
- (void)selectPaintTool;
- (void)selectTextTool;
- (void)selectHandTool;
- (void)selectZoomTool;

@end

