//
//  PhNamesController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Thu Nov 22 2001.
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


//
// This is going to be the controller that controls the names window,
// which allows you to edit the names of the tags, etc.
//
// Right now, I am developing this as a sheet.

#import <AppKit/AppKit.h>

@class PhAbstractName, LELevelData;

enum /* display modes */
{
	_display_tags = 0,
	_display_lights,
	_display_ambient_sounds,
	_display_random_sounds,
        _display_liquids,
	_display_platforms,
        _display_polys,
        _display_layers // Need to add this to menu, etc...
};

@interface PhNamesController : NSWindowController {
    IBOutlet id theLevelWindowControllerOutlet;
    IBOutlet id theLevelDrawView;
    
    IBOutlet id theNameWindow;
    IBOutlet id theTable;
    IBOutlet id editBtn;
    IBOutlet id defaultBtn;
    IBOutlet id deleteBtn;
    IBOutlet id deleteAllBtn;
    IBOutlet id addBtn;
    IBOutlet id duplicateBtn;
    IBOutlet id okBtn;
    IBOutlet id editingMenu;
    
    int currentDisplayMode;
    NSArray *currentArray;
    NSMutableArray *currentNameArray;
    id editingWindowController;
    LELevelData *theLevelDataObject;
}

// *********************** Action Methods ***********************
- (IBAction)editBtnAction:(id)sender;
- (IBAction)defaultBtnAction:(id)sender;
- (IBAction)deleteBtnAction:(id)sender;
- (IBAction)deleteAllBtnAction:(id)sender;
- (IBAction)addBtnAction:(id)sender;
- (IBAction)duplicateBtnAction:(id)sender;
- (IBAction)okBtnAction:(id)sender;
- (IBAction)editingMenuAction:(id)sender;

// *********************** Updater Methods ***********************
-(void)updateInterface;
-(void)reloadDataFromLevel;
-(void)setDisplayEditMode:(int)theRequestedDisplayMode;

- (void)levelDeallocating:(NSNotification *)notification;

// *********************** Accsessor Methods ***********************
- (int)getSelection;
- (BOOL)isSomthingSelected;
- (id)getSelectedObject;
- (NSString *)getSelectedName;

@end
