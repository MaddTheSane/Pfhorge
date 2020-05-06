//
//  TerminalEditorController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Thu Mar 14 2002.
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

@class LELevelData, LEMap, PhItemPlacement;

@interface PhItemPlacementEditorController : NSWindowController <NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTableView *theTableView;
    IBOutlet NSFormCell *initalCountTB;
    IBOutlet NSFormCell *maxCountTB;
    IBOutlet NSFormCell *minCountTB;
    IBOutlet NSFormCell *totalCountTB;
    
    IBOutlet NSFormCell *appearenceTB;
    IBOutlet NSSlider *appearenceSlider;
    
    IBOutlet NSButton *randomCB;
    
    LEMap *theMap;
    LELevelData *theLevel;
    NSMutableArray *theItemPlacmentObjects;
    
    NSArray<NSString*> *theMonsterNames;
    NSArray<NSString*> *theItemNames;
    
    NSInteger numberOfTableRows;
    NSInteger monstersStartAt;
}

- (id)initWithMapDocument:(LEMap *)theDocument;

// *********************** Utilites ***********************

//- (BOOL)windowShouldClose:(id)sender;
- (PhItemPlacement *)objectForRow:(NSInteger)row;
- (BOOL)isSomthingSelected;
- (PhItemPlacement *)selectedObject;

// *********************** User Interface Methods ***********************
- (void)updateUserInterface;

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (IBAction)itemPlacementTableViewDidChange:(id)sender;

- (IBAction)initalCountTBChanged:(id)sender;
- (IBAction)maxCountTBChanged:(id)sender;
- (IBAction)minCountTBChanged:(id)sender;
- (IBAction)totalCountTBChanged:(id)sender;
- (IBAction)apperenceTBChanged:(id)sender;
- (IBAction)apperenceSliderChanged:(id)sender;
- (IBAction)randomCheckboxDidChange:(id)sender;

-(void)setupTheObjectNames;

@end
