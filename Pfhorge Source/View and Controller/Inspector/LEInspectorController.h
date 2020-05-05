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

@interface LEInspectorController : NSWindowController
{
    IBOutlet id theMainTabMenu;
    IBOutlet id generalTabMenu;
    IBOutlet id controlPanelTabMenu;
    IBOutlet id lightsTabMenu;
    IBOutlet id texturesTabMenu;
    
    IBOutlet id generalWindow;
    IBOutlet id controlPanelWindow;
    IBOutlet id lightsWindow;
    IBOutlet id texturesWindow;
    
    IBOutlet id lineSubController;
    IBOutlet id polySubController;
    IBOutlet id objectSubController;
    IBOutlet id textureInspectorWindowController;
    
    IBOutlet id linePrimaryLight;
    IBOutlet id lineSecondaryLight;
    IBOutlet id lineTransparentLight;
    
    IBOutlet id polyAmbientSound;
    IBOutlet id polyCeilingLight;
    IBOutlet id polyFloorLight;
    IBOutlet id polyLiquid;
    IBOutlet id polyLiquidLight;
    IBOutlet id polyRandomSound;
    
    IBOutlet id lineTextureExp;
    
    IBOutlet id textureInspectorWindowTabMenu;
    
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
