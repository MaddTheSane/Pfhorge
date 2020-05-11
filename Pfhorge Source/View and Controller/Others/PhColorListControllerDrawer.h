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

@interface PhColorListControllerDrawer : NSObject <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet id colorListDataSource;
    IBOutlet NSTableView *colorListTable;
    IBOutlet NSTableColumn *colorListTableHeader;
    IBOutlet NSScrollView *colorListTableScrollView;
    IBOutlet NSTextField *status;
    
    IBOutlet LEMapDraw *drawViewDirect;
    IBOutlet LELevelWindowController *windowContollerDirect;
    IBOutlet LELevelWindowController *mainWindowDirect;
    
    IBOutlet NSPanel *newHeightWindowSheet;
    IBOutlet NSTextField *newHeightTextBox;
    
    IBOutlet NSDrawer *theDrawer;
    
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

// *********************** Action Methods ***********************

// *********************** Other Methods ***********************
- (void)setLevelWindowController:(LELevelWindowController *)mainWindController;
- (void)updateInterfaceIfLevelDataSame:(LELevelData *)levdata;

// *********************** Updater Methods ***********************
- (void)updateInterface:(LEMapDraw *)theView;

// ***********************Accsessor Methods ***********************
- (NSInteger)getSelection;
- (NSNumber *)getSelectedNumber;

- (void)setSelectionToNumber:(NSNumber *)theNumberToSelect;

@end
