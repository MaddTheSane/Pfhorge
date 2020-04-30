//
//  PhTextureInspectorController.h
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

enum {
    _c_side_radio = 0,
    _cc_side_radio = 1
};

@class LELine, LESide, LEInspectorController, LEPolygon, PhLineInspectorController;

#import <Cocoa/Cocoa.h>

@interface PhTextureInspectorController : NSWindowController
{
    IBOutlet LEInspectorController *mainInspectorController;
    
    IBOutlet PhLineInspectorController *lineInspectorController;
    
    IBOutlet NSWindow		*textureMenuWindows;
    
    IBOutlet NSMenu 		*jjaroMenu;
    IBOutlet NSMenu 		*lavaMenu;
    IBOutlet NSMenu 		*pfhorMenu;
    IBOutlet NSMenu 		*sewageMenu;
    IBOutlet NSMenu 		*waterMenu;
    
    // Side Outlets...
    
    IBOutlet NSPopUpButton 	*primaryTextureNums;
    IBOutlet NSPopUpButton 	*secondaryTextureNums;
    IBOutlet NSPopUpButton 	*transparentTextureNums;
    
    IBOutlet NSPopUpButton 	*primaryTexture;
    IBOutlet NSPopUpButton 	*secondaryTexture;
    IBOutlet NSPopUpButton 	*transparentTexture;
    
    IBOutlet NSPopUpButton 	*primaryMode;
    IBOutlet NSPopUpButton 	*secondaryMode;
    IBOutlet NSPopUpButton 	*transparentMode;

    IBOutlet NSPopUpButton 	*primaryLight;
    IBOutlet NSPopUpButton 	*secondaryLight;
    IBOutlet NSPopUpButton 	*transparentLight;
    
    // Poly Outlets...

    IBOutlet NSPopUpButton 	*ceilingTexture;
    IBOutlet NSPopUpButton 	*floorTexture;
    
    IBOutlet NSPopUpButton 	*ceilingTextureNums;
    IBOutlet NSPopUpButton 	*floorTextureNums;
    
    IBOutlet NSPopUpButton 	*ceilingMode;
    IBOutlet NSPopUpButton 	*floorMode;
    
    IBOutlet id sideTextureOffsetMatrix;
    IBOutlet id sideTextureRadioBtn;
    IBOutlet id sideLightRadioBtn;
    IBOutlet id sideControlRadioBtn;
    
    IBOutlet id polyTextureOffsetMatrix;
    
    IBOutlet id transparentTextureCheckBox;
    
    LELine *theCurrentLine;
    LESide *cSide, *ccSide, *baseSideRef;
    LEPolygon *basePolyRef;
    
    int currentEnvironment;
    
    BOOL menusSetup;
    
    NSArray *curPImages; // primay
    NSArray *curSImages; // seconday
    NSArray *curTImages; // transperent
    NSArray *curFImages; // floor
    NSArray *curCImages; // ceiling
}

- (void)reset;

- (void)setMenusToEnvironment:(int)code;
- (void)updateTextureMenuContents;
- (void)updatePolyTextureMenus;
- (LESide *)currentBaseSideRef;
- (void)updateLineTextureAndLightMenus;

// ************************* Actions - Side *************************
- (IBAction)primaryTextureMenuAction:(id)sender;
- (IBAction)secondaryTextureMenuAction:(id)sender;
- (IBAction)transparentTextureMenuAction:(id)sender;

- (IBAction)primaryTextureCollectionMenuAction:(id)sender;
- (IBAction)secondaryTextureCollectionMenuAction:(id)sender;
- (IBAction)transparentTextureCollectionMenuAction:(id)sender;

- (IBAction)primaryModeMenuAction:(id)sender;
- (IBAction)secondaryModeMenuAction:(id)sender;
- (IBAction)transparentModeMenuAction:(id)sender;

- (IBAction)sideTextureOffsetMatrixAction:(id)sender;
- (IBAction)sideRadioBtnAction:(id)sender;
- (IBAction)sideExtraRadioBtnAction:(id)sender;
- (IBAction)sideTransparencyCheckBoxAction:(id)sender;

// ********** Side Lights **********
- (IBAction)primaryLightAction:(id)sender;
- (IBAction)secondaryLightAction:(id)sender;
- (IBAction)transparentLightAction:(id)sender;

// ************************* Actions - Polygon *************************
- (IBAction)ceilingTextureMenuAction:(id)sender;
- (IBAction)floorTextureMenuAction:(id)sender;
- (IBAction)ceilingTextureCollectionMenuAction:(id)sender;
- (IBAction)floorTextureCollectionMenuAction:(id)sender;
- (IBAction)ceilingModeMenuAction:(id)sender;
- (IBAction)floorModeMenuAction:(id)sender;
- (IBAction)polyTextureOffsetMatrixAction:(id)sender;

@end
