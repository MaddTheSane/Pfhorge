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


extern NSString *PhLevelDidChangeName;

@class PhAnnotationNote, PhNamesController, PhColorListControllerDrawer;
@class LEMapDraw, PhNoteGroupsCon;

@interface LELevelWindowController : NSWindowController <NSTableViewDataSource>
{
    IBOutlet LEMapDraw *levelDrawView;
    IBOutlet NSTextField *levelStatusBar;
    
    IBOutlet PhNoteGroupsCon *noteGroupWinController;
    IBOutlet NSWindow *noteGroupWindow;
    
    IBOutlet NSPopUpButton *mapLevelList;
    IBOutlet NSPopUpButton *layerNamesMenu;
    
    IBOutlet NSPanel *levelSettingsSheet;
    IBOutlet NSWindow *mainWindow;
    IBOutlet id generalDrawerContentView;
    
    IBOutlet PhNamesController *nameWindowController;
    
    IBOutlet NSMatrix *environmentFlags;
    IBOutlet NSPopUpButton *environmentTexture;
    IBOutlet NSMatrix *gameType;
    IBOutlet NSPopUpButton *landscape;
    IBOutlet NSTextField *levelName;
    IBOutlet NSMatrix *mission;
    IBOutlet NSButton *levelSCancelBtn;
    
    IBOutlet id theExSheet;
    
    unsigned short theExpShort;
    
    // *** outlets For Rename Dialog ***
    IBOutlet NSWindow *rdSheet;
    IBOutlet NSButton *rdApplyBtn;
    IBOutlet NSButton *rdCancelBtn;
    IBOutlet NSButton *rdRemoveBtn;
    IBOutlet NSTextField *rdTextInputTB;
    IBOutlet NSTextField *rdMessageIT;
    IBOutlet id rdTitleIT;
    id objectToRename;
    
    // *** Stuff For GoTo Sheet ***
    IBOutlet NSWindow *gotoSheet;
    IBOutlet NSPopUpButton *gotoPfhorgeObjectTypePopMenu;
    IBOutlet NSTextField *gotoTextInputTB;
    IBOutlet NSTextField *gotoMsgIT;

    // *** Stuff For Note Editor Sheet ***
    IBOutlet NSWindow *annotationNoteEditorSheet;
    IBOutlet NSPopUpButton *noteGroupPM;
    IBOutlet NSTextField *noteTextTB;
    
    // *** Color Window Stuff ***
    IBOutlet PhColorListControllerDrawer *colorObject;
    IBOutlet NSDrawer *theColorDrawer;
    IBOutlet NSPanel *newHeightWindowSheet;
    IBOutlet NSTextField *newHeightTextBox;
    
    // *** Manager Stuff ***
    IBOutlet NSDrawer *theManagerDrawer;
    IBOutlet NSButton *useMapManager;
    IBOutlet NSPopUpButton *gridFactorMenu;
    IBOutlet NSMatrix *gridOptionCheckboxes;
    IBOutlet NSMatrix *objectVisabilityCheckboxes;
    
    // *** Map Manager Non-Overide Options For ***
    IBOutlet NSMatrix *selectionOptionCheckboxes;
    
    
    BOOL showLevelSettingsSheetWhenWindowIsLoaded;
    BOOL disableLevelNameMenu;
    
    BOOL sheetOpen;
    
    BOOL closeIfLevelSettingsCancled;
    
    int currentLevelLoaded;
    
    PhAnnotationNote *tmpNote;
}

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
- (void)renamePolyWithSheet:(id)thePoly;
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
- (void)setShowLevelSettingsSheetWhenWindowIsLoaded:(BOOL)theChoice;
- (void)updateLevelInfoString;
- (void)setUplevelDrawView;

// ************************ Utility and Update Methods ************************
-(void)updateTheLevelNamesMenu;
-(void)disableTheLevelNamesMenu:(BOOL)theAnswer;
- (BOOL)isSheetAlreadyOpen;

// *** Notifications ***
- (void)aLevelDidChangeName:(NSNotification *)notification;
- (void)levelDeallocating:(NSNotification *)notification;
- (void)levelJustChanged:(NSNotification *)notification;
- (void)toolJustChanged:(NSNotification *)notification;

- (void)windowDidBecomeMain:(NSNotification *)aNotification;

- (void)loadUpCursors;
- (LEMapDraw *)levelDrawView;

-(unsigned short)getFlagNow;
-(void)setFlagNow:(unsigned short)s;


// *** NSSavePanelForExportingLevelMethods ***
- (IBAction)exportMeToMarathonMap:(id)sender;
- (void)savePanelDidEnd:(NSSavePanel*)sheet returnCode:(NSModalResponse)returnCode contextInfo:(void  *)contextInfo;

@end
