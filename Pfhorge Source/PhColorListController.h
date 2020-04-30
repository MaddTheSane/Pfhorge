//
//  PhColorListController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 10 2001.
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

@interface PhColorListController : NSWindowController
{
    IBOutlet id colorListDataSource;
    IBOutlet id colorListTable;
    IBOutlet id colorListTableHeader;
    IBOutlet id colorListTableScrollView;
    IBOutlet id status;
	
	IBOutlet id drawerObject;
    
    IBOutlet id newHeightWindowSheet;
    IBOutlet id newHeightTextBox;
    
    id 				theCurrentSelection;
    LEMap 			*currentLevelDocument;
    LEMapDraw 			*currentLevelDrawView;
    LELevelData			*currentLevel;
    LELevelWindowController	*currentMainWindowController;
    
    //Table Data
    NSArray *numbers;
    NSArray *colors;
    NSArray *names;
    NSArray *objs;
    
    BOOL newHeightSheetOpen;
}


// *********************** Class Methods ***********************
+ (id)sharedColorListController;

// *********************** Action Methods ***********************
- (IBAction)createNewHeightSheetBtn:(id)sender;
- (IBAction)cancelNewHeightSheetBtn:(id)sender;

// *********************** Other Methods ***********************
- (void)setMainWindow:(NSWindow *)mainWindow;
- (void)updateInterfaceIfLevelDataSame:(LELevelData *)levdata;

// *********************** Updater Methods ***********************
- (void)updateInterface:(LEMapDraw *)theView;

// ***********************Accsessor Methods ***********************
- (int)getSelection;
- (NSNumber *)getSelectedNumber;

- (void)setSelectionToNumber:(NSNumber *)theNumberToSelect;

- (void)mainWindowChanged:(NSNotification *)notification;
- (void)mainWindowResigned:(NSNotification *)notification;

@end
