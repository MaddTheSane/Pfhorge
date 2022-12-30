//
//  LEPaletteController.m
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

#import "LEPaletteController.h"
#import "LEExtras.h"

@implementation LEPaletteController

- (IBAction)toolSelection:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LEToolChangedNotification object:self];
}

+ (id)sharedPaletteController {
    static LEPaletteController *sharedPaletteController = nil;

    if (!sharedPaletteController) {
        sharedPaletteController = [[LEPaletteController allocWithZone:NULL] init];
    }

    return sharedPaletteController;
}

- (id)init {
    self = [self initWithWindowNibName:@"ToolPallette"];
    if (self == nil)
        return nil;
    
    [self setWindowFrameAutosaveName:@"TheToolPalletteWin"];
    
    return self;
}

- (void)windowDidLoad {
    NSArray<NSCell*> *cells = [toolPalette cells];
    NSInteger i, c = [cells count];
    
    //[super windowDidLoad];

    for (i=0; i<c; i++) {
        [[cells objectAtIndex:i] setRefusesFirstResponder:YES];
    }
    
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];

    [toolPalette setIntercellSpacing:NSMakeSize(0.0, 0.0)];
    [toolPalette sizeToFit];
    [[self window] setContentSize:[toolPalette frame].size];
    [toolPalette setFrameOrigin:NSMakePoint(0.0, 0.0)];
}

- (LEPaletteTool)currentTool {
    LEPaletteTool theTool = GetTagOfSelected(toolPalette); //[toolPalette selectedColumn];
    
    return theTool;
    /*Class theClass = nil;
    if (row == SKTRectToolRow) {
        theClass = [SKTRectangle class];
    } else if (row == SKTCircleToolRow) {
        theClass = [SKTCircle class];
    } else if (row == SKTLineToolRow) {
        theClass = [SKTLine class];
    } else if (row == SKTTextToolRow) {
        theClass = [SKTTextArea class];
    }*/
}

- (void)selectArrowTool {
    ///[toolPalette selectCellAtRow:0 column:0]; // LEPaletteArrowTool // old comment?
    SelectS(toolPalette, LEPaletteToolArrow);
    [[NSNotificationCenter defaultCenter] postNotificationName:LEToolChangedNotification object:self];
}

- (void)selectLineTool {
    SelectS(toolPalette, LEPaletteToolLine);
    [[NSNotificationCenter defaultCenter] postNotificationName:LEToolChangedNotification object:self];
}

- (void)selectPaintTool {
    SelectS(toolPalette, LEPaletteToolPaint);
    [[NSNotificationCenter defaultCenter] postNotificationName:LEToolChangedNotification object:self];
}

- (void)selectHandTool {
    SelectS(toolPalette, LEPaletteToolHand);
    [[NSNotificationCenter defaultCenter] postNotificationName:LEToolChangedNotification object:self];
}

- (void)selectTextTool {
    SelectS(toolPalette, LEPaletteToolText);
    [[NSNotificationCenter defaultCenter] postNotificationName:LEToolChangedNotification object:self];
}

- (void)selectZoomTool {
    SelectS(toolPalette, LEPaletteToolZoom);
    [[NSNotificationCenter defaultCenter] postNotificationName:LEToolChangedNotification object:self];
}


// jra 7-31-03
// Tries to use the key (usually pressed by the user) to select a tool
// Uses Forge key equivalents (a, l, f, t)
- (BOOL)tryToMatchKey:(NSString *)keys
{
    // pull out first letter
    unichar key = [keys characterAtIndex:0];
    
    switch(key) {
        case 'a':
        case 'A':
            [self selectArrowTool];
            break;
            
        case 'l':	// L as in Line
        case 'L':
        case 'd':	// D as in Draw ... keeps it on the left hand
        case 'D':	// (right hand on mouse, left hand in std position)
            [self selectLineTool];
            break;
            
        case 'f':	// F as in Fill poly (Forge carryover)
        case 'F':
        case 'p':	// P as in Paint bucket OR Polygon tool
        case 'P':
            [self selectPaintTool];
            break;
            
        case 'h':
        case 'H':
            [self selectHandTool];
            break;
            
        case 't':
        case 'T':
            [self selectTextTool];
            break;
            
        case 'z':
        case 'Z':
            [self selectZoomTool];
            break;
            
        default:
            return NO;
    }
    
    return YES;		// default has already returned NO if char wasn't matched
}

@end
