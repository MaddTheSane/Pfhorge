//
//  LEInspectorController.h
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
    
@class LEMap, LEMapDraw, LELevelData, LELevelWindowController;
@class PhLineInspectorController, PhPolyInspectorController;
@class PhObjectInspectorSubController, PhTextureInspectorController;

@interface LEInspectorController : NSWindowController
{
    IBOutlet NSTabView *theMainTabMenu;
    IBOutlet NSTabView *generalTabMenu;
    IBOutlet NSTabView *controlPanelTabMenu;
    IBOutlet NSTabView *lightsTabMenu;
    IBOutlet NSTabView *texturesTabMenu;
    
    IBOutlet NSPanel *generalWindow;
    IBOutlet NSPanel *controlPanelWindow;
    IBOutlet NSPanel *lightsWindow;
    IBOutlet NSPanel *texturesWindow;
    
    IBOutlet PhLineInspectorController *lineSubController;
    IBOutlet PhPolyInspectorController *polySubController;
    IBOutlet PhObjectInspectorSubController *objectSubController;
    IBOutlet PhTextureInspectorController *textureInspectorWindowController;
    
    IBOutlet NSPopUpButton *linePrimaryLight;
    IBOutlet NSPopUpButton *lineSecondaryLight;
    IBOutlet NSPopUpButton *lineTransparentLight;
    
    IBOutlet NSComboBox *polyAmbientSound;
    IBOutlet NSPopUpButton *polyCeilingLight;
    IBOutlet NSPopUpButton *polyFloorLight;
    IBOutlet NSComboBox *polyLiquid;
    IBOutlet NSPopUpButton *polyLiquidLight;
    IBOutlet NSComboBox *polyRandomSound;
    
    IBOutlet id lineTextureExp;
    
    IBOutlet NSTabView *textureInspectorWindowTabMenu;
    
    id 				theCurrentSelection;
    LEMap 			*currentLevelDocument;
    LEMapDraw 			*currentLevelDrawView;
    LELevelData			*currentLevel;
    LELevelWindowController	*currentMainWindowController;
}
// *********************** Class Methods ***********************
+ (id)sharedInspectorController;

// *********************** Other Methods ***********************
- (void)setMainWindow:(NSWindow *)mainWindow;
// *********************** Notifcations ***********************
- (void)levelDeallocating:(NSNotification *)notification;
- (void)mainWindowChanged:(NSNotification *)notification;
//- (void)mainWindowResigned:(NSNotification *)notification;
- (void)selectionChanged:(NSNotification *)notification;
//- (void)reloadAllPhNameData:(NSNotification *)notification

// *********************** Updater Methods ***********************
- (void)reset;
-(void)updateComboMenus;

// *********************** Utilites ***********************
-(void)setTabMenusTo:(int)tabViewIndex;
- (void)updateInterfaces;

// *********************** Actions ***********************
-(IBAction)polySectionChanged:(id)sender;
-(IBAction)lineSectionChanged:(id)sender;
-(IBAction)objSectionChanged:(id)sender;

- (IBAction)showControlPanelWindow:(id)sender;
- (IBAction)showLightWindow:(id)sender;
- (IBAction)showGeneralPropertiesWindow:(id)sender;
- (IBAction)showTextureWindow:(id)sender;

// *********************** Accsessors ***********************
-(id)getTheCurrentSelection;
-(LELevelData *)currentLevel;
-(LEMapDraw *)getTheCurrentLevelDrawView;
@end
