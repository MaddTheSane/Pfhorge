//
//  PhPolyInspectorController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon Jul 16 2001.
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

#import <AppKit/AppKit.h>

@class PhPlatformSheetController, LEPolygon, LEInspectorController;
@class PhTextureInspectorController;

@interface PhPolyInspectorController : NSWindowController {
    IBOutlet LEInspectorController *mainInspectorController;
    IBOutlet PhTextureInspectorController *textureInspectorController;
    
    IBOutlet NSPanel *textureWindow;
    
    IBOutlet NSButton *platformParametersBtn;
    IBOutlet NSComboBox *ambientSound;
    IBOutlet id polyBox;
    IBOutlet NSTextField *ceilingHeight;
    IBOutlet NSPopUpButton *ceilingLight;
    IBOutlet NSTextField *floorHeight;
    IBOutlet NSPopUpButton *floorLight;
    IBOutlet NSComboBox *liquid;
    IBOutlet NSPopUpButton *liquidLight;
    IBOutlet NSPopUpButton *permutation;
    IBOutlet NSComboBox *yandomSound;
    IBOutlet NSPopUpButton *type;
    
    IBOutlet NSPopUpButton *ceilingTextureMenu;
    IBOutlet NSPopUpButton *floorTextureMenu;
    //IBOutlet id textureOffsetMatrix;
    
    IBOutlet NSTabView *permutationTab;
    IBOutlet NSTextField *permutationNumberTB;
    
    PhPlatformSheetController *platformEditingWindowController;
    int lastMenuTypeCache;
    
    LEPolygon *curPoly;
}

- (void)reset;

- (void)updateInterface;
- (void)updateObjectValuesOfComboMenus;

- (IBAction)platformParametersAction:(id)sender;
- (IBAction)polygonTypeAction:(id)sender;
- (IBAction)ceilingHeightAction:(id)sender;
- (IBAction)floorHeightAction:(id)sender;
- (IBAction)permutationAction:(id)sender;
- (IBAction)permutationNumberTBAction:(id)sender;
- (IBAction)ceilingLightAction:(id)sender;
- (IBAction)floorLightAction:(id)sender;
- (IBAction)liauidLightAction:(id)sender;
- (IBAction)liquidAction:(id)sender;
- (IBAction)randomSoundAction:(id)sender;
- (IBAction)ambientSoundAction:(id)sender;

// The Enviroment Codes and Wall Collection Numbers...
    /*
    _water_collection
    _lava_collection
    _sewage_collection
    _jjaro_collection
    _pfhor_collection
    */
    
@end
