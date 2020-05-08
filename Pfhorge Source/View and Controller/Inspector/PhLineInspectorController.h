//
//  PhLineInspectorController.h
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

@class LESide, LELine;

@interface PhLineInspectorController : NSWindowController {
    
    // Outlet to the main inspector controller instance...
    IBOutlet id mainInspectorController;
    IBOutlet id textureInspectorController;
    
    IBOutlet id lightWindow;
    
    // IBOutlet id  ??? ??? ???
    
    // Regular Line UI Outlets...
    IBOutlet id lineBox;
    IBOutlet id lineIsControlPanel;
    IBOutlet id lineControlPanelFlags;
    IBOutlet id lineControlPanelType;
    IBOutlet id lineFlags;
    IBOutlet id emptyFlag;
    
    IBOutlet id linePermutation;
    IBOutlet id linePermutationTextBox;
    IBOutlet NSTabView *linePermutationTabView;
    
    // Light UI Outlets...
    IBOutlet id linePrimaryLight;
    IBOutlet id lineSecondaryLight;
    IBOutlet id lineTransparentLight;
    
    // Texture UI Outlets...
    IBOutlet id primaryTextureMenu;
    IBOutlet id secondaryTextureMenu;
    IBOutlet id transparentTextureMenu;
    IBOutlet id textureOffsetMatrix;
    
    LELine *theCurrentSelection;
    LESide *cSide, *ccSide, *baseSideRef;
    
    int prevEnviroCode;
    NSArray *theWaterNames, *theLavaNames, *theSewageNames, *thePfhorNames, *theJjaroNames;
}

- (void)reset;

- (void)updateLineInterface;
- (void)updateObjectValuesOfComboMenus;
- (void)saveControlPanelFlags;

- (IBAction)controlPanelStatusAction:(id)sender;
- (IBAction)controlPanelTypeAction:(id)sender;
- (IBAction)controlPanelPermutationAction:(id)sender;
- (IBAction)regularFlagsAction:(id)sender;
- (IBAction)emptyFlagAction:(id)sender;
- (IBAction)controlPanelFlagsAction:(id)sender;
//- (IBAction)primaryLightAction:(id)sender;
//- (IBAction)secondaryLightAction:(id)sender;
//- (IBAction)transparentLightAction:(id)sender;

/*
- (IBAction)primaryTextureMenuAction:(id)sender;
- (IBAction)secondaryTextureMenuAction:(id)sender;
- (IBAction)transparentTextureMenuAction:(id)sender;
- (IBAction)textureOffsetMatrixAction:(id)sender;
*/

// ****************** Names Of Control Panels ****************

-(void)setupTheControlPanelNames;

@end
