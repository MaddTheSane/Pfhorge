//
//  LELevelWindowController.h
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
#import "LEMapDraw.h"

enum { // Map Mananger Selection Options
    _mm_select_points = 0,
    _mm_select_lines,
    _mm_select_objects,
    _mm_select_polygons
};

enum { // Map Mananger Grid Options
    _mm_points_to_grid = 0,
    _mm_objects_to_grid,
    _mm_snap_to_other_points,
    _mm_draw_grid
};

enum { // Map Manager Object Visibility Options
    _mm_monster_vis = 0,
    _mm_player_vis,
    _mm_scenary_vis,
    _mm_sound_vis,
    _mm_item_vis,
    _mm_goal_vis
};

enum { // Map Mananger Grid Factor Menu Constents
    _mm_1_8 = 0,
    _mm_1_4,
    _mm_1_2,
    _mm_1,
    _mm_2,
    _mm_4,
    _mm_8
};


extern NSNotificationName const PhLevelDidChangeNameNotification;

@class PhAnnotationNote, PhNamesController, PhColorListControllerDrawer;
@class LEMapDraw, PhNoteGroupsCon;

@interface LELevelWindowController : NSWindowController <NSTableViewDataSource>
{
    unsigned short theExpShort;
    
    // *** outlets For Rename Dialog ***
    id objectToRename;
    
    __weak NSPanel *newHeightWindowSheet;
    __weak NSTextField *newHeightTextBox;
    
    BOOL showLevelSettingsSheetWhenWindowIsLoaded;
    BOOL disableLevelNameMenu;
    
    BOOL sheetOpen;
    
    BOOL closeIfLevelSettingsCancled;
    
    int currentLevelLoaded;
    
    PhAnnotationNote *tmpNote;
}

@property (weak) IBOutlet LEMapDraw *levelDrawView;
@property (weak) IBOutlet NSTextField *levelStatusBar;

@property (weak) IBOutlet PhNoteGroupsCon *noteGroupWinController;
@property (weak) IBOutlet NSWindow *noteGroupWindow;

@property (weak) IBOutlet NSPopUpButton *mapLevelList;
@property (weak) IBOutlet NSPopUpButton *layerNamesMenu;

@property (weak) IBOutlet NSPanel *levelSettingsSheet;
@property (weak) IBOutlet NSWindow *mainWindow;
@property (weak) IBOutlet id generalDrawerContentView;

@property (weak) IBOutlet PhNamesController *nameWindowController;

@property (weak) IBOutlet NSMatrix *environmentFlags;
@property (weak) IBOutlet NSPopUpButton *environmentTexture;
@property (weak) IBOutlet NSMatrix *gameType;
@property (weak) IBOutlet NSPopUpButton *landscape;
@property (weak) IBOutlet NSTextField *levelName;
@property (weak) IBOutlet NSMatrix *mission;
@property (weak) IBOutlet NSButton *levelSCancelBtn;

@property (weak) IBOutlet id theExSheet;


// *** outlets For Rename Dialog ***
@property (weak) IBOutlet NSWindow *rdSheet;
@property (weak) IBOutlet NSButton *rdApplyBtn;
@property (weak) IBOutlet NSButton *rdCancelBtn;
@property (weak) IBOutlet NSButton *rdRemoveBtn;
@property (weak) IBOutlet NSTextField *rdTextInputTB;
@property (weak) IBOutlet NSTextField *rdMessageIT;
@property (weak) IBOutlet id rdTitleIT;

// *** Stuff For GoTo Sheet ***
@property (weak) IBOutlet NSWindow *gotoSheet;
@property (weak) IBOutlet NSPopUpButton *gotoPfhorgeObjectTypePopMenu;
@property (weak) IBOutlet NSTextField *gotoTextInputTB;
@property (weak) IBOutlet NSTextField *gotoMsgIT;

// *** Stuff For Note Editor Sheet ***
@property (weak) IBOutlet NSWindow *annotationNoteEditorSheet;
@property (weak) IBOutlet NSPopUpButton *noteGroupPM;
@property (weak) IBOutlet NSTextField *noteTextTB;

// *** Color Window Stuff ***
@property (weak) IBOutlet PhColorListControllerDrawer *colorObject;
@property (weak) IBOutlet NSDrawer *theColorDrawer;
@property (weak) IBOutlet NSPanel *changeHeightWindowSheet;
@property (weak) IBOutlet NSTextField *changeHeightTextBox;

// *** Manager Stuff ***
@property (weak) IBOutlet NSDrawer *theManagerDrawer;
@property (weak) IBOutlet NSButton *useMapManager;
@property (weak) IBOutlet NSPopUpButton *gridFactorMenu;
@property (weak) IBOutlet NSButton *gridOptionPointsToGrid;
@property (weak) IBOutlet NSButton *gridOptionObjectsToGrid;
@property (weak) IBOutlet NSButton *gridOptionPointsToPoints;
@property (weak) IBOutlet NSButton *gridOptionDraws;

@property (weak) IBOutlet NSMatrix *objectVisabilityCheckboxes;


// *** Map Manager Non-Overide Options For ***
@property (weak) IBOutlet NSButton *selectionOptionCheckPoints;
@property (weak) IBOutlet NSButton *selectionOptionCheckLines;
@property (weak) IBOutlet NSButton *selectionOptionCheckObjects;
@property (weak) IBOutlet NSButton *selectionOptionCheckPolygons;

 // Might want to use LELevelChangedNotification instead...
- (void)mapLoaded;

// *** Map Manager Methods and Actions ***
- (IBAction)toggleMapManagerDrawer:(id)sender;
- (void)updateMapManagerInterface;
- (IBAction)mapManagerDrawerAction:(id)sender;
- (IBAction)useMapManagerCheckboxDrawerAction:(id)sender;
- (IBAction)mapManagerPerfOverrideDrawerAction:(id)sender;

// ********** Actions *********
- (IBAction)importMarathonMap:(id)sender;
- (IBAction)importPathwaysMap:(id)sender;
- (IBAction)showTheNameWindow:(id)sender;

- (IBAction)chooseLevelMenu:(id)sender;
- (IBAction)layerMenuAction:(id)sender;

- (IBAction)adjacentPolygonAssociationsResetAction:(id)sender;

- (IBAction)caculateSelectedLines:(id)sender;

// *** Level Settings Sheet Actions... ***
- (IBAction)levelSettingsSheet:(id)sender;
- (IBAction)applyLevelSettings:(id)sender;
- (IBAction)cancelLevelSettings:(id)sender;
- (IBAction)platformBtn:(id)sender;
- (IBAction)turnOnUseOptimizedDrawing:(id)sender;

// *** Rename Dialog Actions/Methods ***
- (void)renamePolyWithSheet:(LEPolygon*)thePoly;
- (IBAction)rdOkBtnAction:(id)sender;
- (IBAction)rdCancelBtnAction:(id)sender;
- (IBAction)rdRemoveBtnAction:(id)sender;

// *** Stuff For GoTo Sheet ***
- (IBAction)goToPfhorgeObjectViaIndexSheet:(id)sender;
- (IBAction)gotoOkBtnAction:(id)sender;
- (IBAction)gotoCancelBtnAction:(id)sender;

// *** Stuff For New Height Sheet ***
- (void)openNewHeightSheet;
- (IBAction)createNewHeightSheetBtn:(id)sender;
- (IBAction)cancelNewHeightSheetBtn:(id)sender;

// *** Stuff For Note Group Manager Sheet ***
- (IBAction)openNoteGroupManager:(id)sender;
- (void)openNoteGroupManager;
- (IBAction)closeNoteGroupManager:(id)sender;

// ** Stuff For Note Editor Sheet ***
- (void)openAnnotationNoteEditor:(PhAnnotationNote *)note;
- (IBAction)closeNoteEditorSheet:(id)sender;

// ********* Regular Methods *********
- (void)updateLayerSelection;
@property BOOL showLevelSettingsSheetWhenWindowIsLoaded;
- (void)updateLevelInfoString;
- (void)setUplevelDrawView;

// ************************ Utility and Update Methods ************************
-(void)updateTheLevelNamesMenu;
-(void)disableTheLevelNamesMenu:(BOOL)theAnswer;
@property (readonly, getter=isSheetAlreadyOpen) BOOL sheetAlreadyOpen;

// *** Notifications ***
- (void)aLevelDidChangeName:(NSNotification *)notification;
- (void)levelDeallocating:(NSNotification *)notification;
- (void)levelJustChanged:(NSNotification *)notification;
- (void)toolJustChanged:(NSNotification *)notification;

- (void)windowDidBecomeMain:(NSNotification *)aNotification;

- (LEMapDraw *)levelDrawView;

@property unsigned short flagNow;


// *** NSSavePanelForExportingLevelMethods ***
- (IBAction)exportMeToMarathonMap:(id)sender;

@end
