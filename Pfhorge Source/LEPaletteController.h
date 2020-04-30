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

enum { // Old Tool enum Names (still work)
       // Although these still work, I highly recemmend that you use the new ones...
    LEPaletteArrowTool = 0,
    LEPaletteLineTool,
    LEPalettePaintTool,
    LEPaletteObjectTool,
    LEPaletteCommentTool,
    LEPaletteDeleteTool, // Proably won't need this...
};

// jra: Uh, the above doesn't jibe with the actual tool palette's configuration.
// Which is ok because nobody in our code uses it anymore. Suggest removal?

enum { // New Tool enum Names, recommend these be used.
    _arrow_tool = 0,
    _line_tool,
    _paint_tool,
    _text_tool,
    _hand_tool,
    _zoom_tool,
    _sampler_tool,
    _brush_tool,
     // Object Creation Tools
    _monster_tool = 10,
    _player_tool,
    _item_tool,
    _scenary_tool,
    _sound_tool,
    _goal_tool
};

@interface LEPaletteController : NSWindowController
{
    IBOutlet id toolPalette;
}

+ (id)sharedPaletteController;

- (IBAction)toolSelection:(id)sender;
- (unsigned short)getCurrentTool;


- (BOOL)tryToMatchKey:(NSString *)keys;

- (void)selectArrowTool;
- (void)selectLineTool;
- (void)selectPaintTool;
- (void)selectTextTool;
- (void)selectHandTool;
- (void)selectZoomTool;

@end

