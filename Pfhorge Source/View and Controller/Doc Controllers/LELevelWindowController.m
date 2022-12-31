//
//  LELevelWindowController.m
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

#import "LELevelWindowController.h"
#import "PhNamesController.h"

#import "PhColorListControllerDrawer.h"

#import "LEPaletteController.h"
#import "LEMapDraw.h"
#import "LEMap.h"
#import "LEMapData.h"
#import "LELevelData.h"
#import "PhPlatformSheetController.h"

#import "LEExtras.h"

#import "LEInspectorController.h"

#import "PhNoteGroupsCon.h"
#import "PhNoteGroup.h"
#import "PhAnnotationNote.h"

enum	// side flags
{
	_control_panel_status_NEW = 0x0001,
	_side_is_control_panel_NEW = 0x0002,
	_side_is_repair_switch_NEW = 0x0004,
	_side_is_destructive_switch_NEW = 0x0008,
	_side_is_lighted_switch_NEW = 0x0010,
	_side_switch_can_be_destroyed_NEW = 0x0020,
	_side_switch_can_only_be_hit_by_projectiles_NEW = 0x0040,

	_editor_dirty_bit_NEW = 0x4000 // used by the editor
};

#define SIDE_IS_CONTROL_PANEL_NEW(s) ([s getFlagNow] & _side_is_control_panel_NEW)
#define SET_SIDE_CONTROL_PANEL_NEW(s,t) ((t) ? [s setFlagNow:([s getFlagNow] | (unsigned short) LESideIsControlPanel)] : [s setFlagNow:([s getFlagNow] & (unsigned short)~_side_is_control_panel_NEW)])

#define THE_TEST_PLEASEWORK(p,v) ([p setFlagNow:[p getFlagNow] + v])

#define SState(o, t) ([[(o) cellWithTag:(t)] state] == NSControlStateValueOn)

NSString *const PhLevelDidChangeNameNotification = @"PhLevelDidChangeName";

@implementation LELevelWindowController
@synthesize levelDrawView;
@synthesize levelStatusBar;

@synthesize noteGroupWinController;
@synthesize noteGroupWindow;

@synthesize mapLevelList;
@synthesize layerNamesMenu;
@synthesize levelSettingsSheet;
@synthesize mainWindow;
@synthesize generalDrawerContentView;

@synthesize nameWindowController;

@synthesize environmentFlags;
@synthesize environmentTexture;
@synthesize gameType;
@synthesize landscape;
@synthesize levelName;
@synthesize mission;
@synthesize levelSCancelBtn;

@synthesize theExSheet;


// *** outlets For Rename Dialog ***
@synthesize rdSheet;
@synthesize rdApplyBtn;
@synthesize rdCancelBtn;
@synthesize rdRemoveBtn;
@synthesize rdTextInputTB;
@synthesize rdMessageIT;
@synthesize rdTitleIT;

// *** Stuff For GoTo Sheet ***
@synthesize gotoSheet;
@synthesize gotoPfhorgeObjectTypePopMenu;
@synthesize gotoTextInputTB;
@synthesize gotoMsgIT;

// *** Stuff For Note Editor Sheet ***
@synthesize annotationNoteEditorSheet;
@synthesize noteGroupPM;
@synthesize noteTextTB;

// *** Color Window Stuff ***
@synthesize colorObject;
@synthesize theColorDrawer;
@synthesize changeHeightWindowSheet=newHeightWindowSheet;
@synthesize changeHeightTextBox=newHeightTextBox;

// *** Manager Stuff ***
@synthesize theManagerDrawer;
@synthesize useMapManager;
@synthesize gridFactorMenu;
@synthesize objectVisabilityCheckboxes;

- (id)init
{
    self = [super initWithWindowNibName:@"MyLevel"];
    //[self window];
    
    sheetOpen = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(levelDeallocating:)
        name:PhLevelDeallocatingNotification
        object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(aLevelDidChangeName:)
        name:PhLevelDidChangeNameNotification
        object:nil];
    
    showLevelSettingsSheetWhenWindowIsLoaded = NO;
    disableLevelNameMenu = NO;
    closeIfLevelSettingsCancled = NO;
    
    currentLevelLoaded = 0;
    
    tmpNote = nil;
    
    return self;
}

- (void)dealloc
{
    tmpNote = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*- (void)windowDidLoad
{
    ///[[[self document] getCurrentLevelLoaded] addMenu:layerNamesMenu asA:PhLevelNameMenuLayer];
    ///[removeMenu:layerNamesMenu thatsA:PhLevelNameMenuLayer];
}*/

- (void)awakeFromNib
{
    [noteGroupWinController awake];
    //[super awakeFromNib];
    //NSLog(@"Awake From Nib Called!!!");
}

//The map has been loaded at the first level objects have been loaded...
- (void)mapLoaded
{
    NSEnumerator *numer;
    
    NSString *levname;
    
    // Might want to use LELevelChangedNotification instead...

    // Select the first level in the level menu...
    [mapLevelList removeAllItems];
    
    // NSLog(@"*** *** *** LEVEL NAME COUNT: %d *** *** ***", [[[self document] levelNames] count]);
    // NSLog(@"Level Names Array: %@", [[self document] levelNames]);
    
    numer = [[[self document] levelNames] objectEnumerator];
    while (levname = [numer nextObject])
    {
            // [[self document] levelNames]
    
            //NSString *copyOfFullPath = [[fullPath copy] autorelease];
            
            //[scriptPaths addObject:copyOfFullPath];
            
            NSMenuItem *newItem = [[NSMenuItem alloc]
                initWithTitle:levname action:NULL keyEquivalent:@""];
            
            [newItem setRepresentedObject:nil];
            [newItem setTarget:nil];
            [newItem setAction:nil];
            [[mapLevelList menu] addItem:newItem];
    }
    
    //[mapLevelList addItemsWithTitles:[[self document] levelNames]];
    [mapLevelList selectItemAtIndex:0];
    // Make sure that it reflects this
    //[mapLevelList setObjectValue:[mapLevelList objectValueOfSelectedItem]];
    //[mapLevelList setObjectValue:@"Choose Level:"];
    
    [[[self document] getCurrentLevelLoaded] addMenu:layerNamesMenu asMenuType:PhLevelNameMenuLayer];
    
    [self updateLayerSelection];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender
{
    return [[self document] undoManager];
}

// ************************ General Actions ************************
#pragma mark -
#pragma mark ********* General Actions *********

- (IBAction)showTheNameWindow:(id)sender
{
    [nameWindowController showWindow:sender];
    [nameWindowController updateInterface];
}

- (IBAction)chooseLevelMenu:(id)sender
{
    NSInteger selectedItem = [sender indexOfSelectedItem];
    if (selectedItem != -1 && currentLevelLoaded != selectedItem) {
        [[self document] loadLevel:(int)(selectedItem + 1)];
        //[generalDrawerContentView setNextKeyView:levelDrawView];
        //[sender selectItemAtIndex:[sender indexOfSelectedItem]];
        
        //[sender setObjectValue:[sender itemObjectValueAtIndex:[sender indexOfSelectedItem]]];
        //[mapLevelList setObjectValue:[mapLevelList objectValueOfSelectedItem]];
        
        currentLevelLoaded = selectedItem;
    }
    //[mapLevelList setObjectValue:@"Choose Level:"];
    [[LEInspectorController sharedInspectorController] setMainWindow:[self window]];
}

- (IBAction)layerMenuAction:(id)sender
{
    NSLog(@"Layer Menu Action Recived, Changing Layer...");
    if ([sender indexOfSelectedItem] != -1) {
        [[[self document] getCurrentLevelLoaded] setLayerModeToIndex:[sender indexOfSelectedItem]];
        [levelDrawView recaculateAndRedrawEverything];
        // I may or may not get rid of this in the future.
        // I think chaning the layer may be a good place to
        // always clear the undo/redo stack...
        // ******************************************** Temp Undo Manager Clear **************************************
        [levelDrawView clearSelections];
        [levelDrawView updateTheSelections];
        [[[self document] undoManager] removeAllActions];
        [self updateLevelInfoString];
        [levelDrawView recaculateAndRedrawEverything];
    }
}

- (IBAction)turnOnUseOptimizedDrawing:(id)sender
{
    [mainWindow useOptimizedDrawing:YES];
    NSLog(@"window optimized drawing flag on!");
}

- (IBAction)importMarathonMap:(id)sender
{
    NSArray	*fileTypes	= @[NSFileTypeForHFSTypeCode('sce2'), NSFileTypeForHFSTypeCode(0x736365B0) /*'sce∞'*/, @"lev", @"org.bungie.source.map"];
    NSOpenPanel	*op		= [NSOpenPanel openPanel];
    op.allowedFileTypes = fileTypes;
    
    if ([self isSheetAlreadyOpen])
        return;
    
    [op	setAllowsMultipleSelection:NO];
    [op setTitle:@"Combine Pfhorge/Aleph/Marathon Map"];
    [op setPrompt:@"Combine/Import"];
    
    [op beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        [self savePanelDidEndForMapImport:op returnCode:result contextInfo:NULL];
    }];
    
    sheetOpen = YES;
}

- (IBAction)importPathwaysMap:(id)sender
{
    NSArray	*fileTypes	= @[NSFileTypeForHFSTypeCode('maps'), @"lev"];
    NSOpenPanel	*op		= [NSOpenPanel openPanel];
    
    if ([self isSheetAlreadyOpen])
        return;
    
    [op	setAllowsMultipleSelection:NO];
    [op setTitle:@"Combine Pfhorge/Aleph/Marathon Map"];
    [op setPrompt:@"Combine/Import"];
    op.allowedFileTypes = fileTypes;
    
    [op beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        [self savePanelDidEndForMapImport:op returnCode:result contextInfo:NULL];
    }];
    
    sheetOpen = YES;
}

- (IBAction)adjacentPolygonAssociationsResetAction:(id)sender
{
    [[[self document] getCurrentLevelLoaded] resetAdjacentPolygonAssociations];
    [[[self document] getCurrentLevelLoaded] removeObjectsNotInMainArrays];
    
}

- (IBAction)caculateSelectedLines:(id)sender
{
    [levelDrawView caculateSidesOnSelectedLines:nil];
    [[LEInspectorController sharedInspectorController] updateInterfaces];
}

// Sheet Actions, etc...

// ************************ Level Settings Sheet Actions/Methods ************************
#pragma mark -
#pragma mark ********* Level Settings Sheet Actions/Methods *********

- (IBAction)levelSettingsSheet:(id)sender // rename to levelSettingsSheetOpen (or Activate), etc... ---:=>
{
    // Get the level data...
    LELevelData *theLevel = [[self document] getCurrentLevelLoaded];
    NSString *theLevelNameTmp = nil;
    
    NSLog(@"Level Settigns Sheet");
    
    if ([self isSheetAlreadyOpen])
        return;
    
    //NSMutableString *levelInfoString;
    //levelInfoString = [[NSMutableString alloc] initWithString:@"Flags: "];
    
    // *** Update the sheet with the level data... ***
    
    // these two pseudo-environments are used to prevent items
    // from arriving in the items.c code...
    // figure this out later...
    //if ([theLevel isEnvironmentSinglePlayer])
        //???
    //if ([theLevel isEnvironmentNetwork])
        //???
        
    //if ([theLevel environmentFlags] == 0)
        // Nothing is set, but that includes above also...
    
    if (showLevelSettingsSheetWhenWindowIsLoaded)
        closeIfLevelSettingsCancled = YES;
    else
        closeIfLevelSettingsCancled = NO;
    
    [levelSCancelBtn setEnabled:YES];
    
    [environmentFlags deselectAllCells];
    [mission deselectAllCells];
    [gameType deselectAllCells];
        
    if ([theLevel isEnvironmentVacuum])
        [environmentFlags selectCellAtRow:0 column:0];
    if ([theLevel isEnvironmentRebellion])
        [environmentFlags selectCellAtRow:1 column:0];
    if ([theLevel isEnvironmentLowGravity])
        [environmentFlags selectCellAtRow:2 column:0];
    if ([theLevel isEnvironmentMagnetic])
        [environmentFlags selectCellAtRow:3 column:0];
    
    if ([theLevel isMissionExtermination])
        [mission selectCellAtRow:0 column:0];
    if ([theLevel isMissionExploration])
        [mission selectCellAtRow:1 column:0];
    if ([theLevel isMissionRetrieval])
        [mission selectCellAtRow:2 column:0];
    if ([theLevel isMissionRepair])
        [mission selectCellAtRow:3 column:0];
    if ([theLevel isMissionRescue])
        [mission selectCellAtRow:4 column:0];
        
    if ([theLevel isGameTypeSinglePlayer])
        [gameType selectCellAtRow:0 column:0];
    if ([theLevel isGameTypeCooperative])
        [gameType selectCellAtRow:1 column:0];
    if ([theLevel isGameTypeMultiplayerCarnage])
        [gameType selectCellAtRow:2 column:0];
    if ([theLevel isGameTypeCaptureTheFlag])
        [gameType selectCellAtRow:3 column:0];
    if ([theLevel isGameTypeKingOfTheHill])
        [gameType selectCellAtRow:4 column:0];
    if ([theLevel isGameTypeDefense])
        [gameType selectCellAtRow:5 column:0];
    if ([theLevel isGameTypeRugby])
        [gameType selectCellAtRow:6 column:0];
    
    // Set the level name...
    theLevelNameTmp = [theLevel levelName];
    NSLog(@"thelevelNameTmp: %@", theLevelNameTmp);
    if (theLevelNameTmp == nil)
    {
        NSLog(@"The level name was nil, setting it 'Untitled'");
        theLevelNameTmp = @"Untitled";
    }
    
    [levelName setStringValue:theLevelNameTmp];
    
    //-(short)physicsModel;
    //-(short)songIndex;
    [environmentTexture selectItemAtIndex:[theLevel environmentCode]];
    /*	_water = 0,
	_lava,
	_sewage,
	_jjaro,
	_pfhor */
    
    // Song index is apperently used by Forge for which landscape to use...
    [landscape selectItemAtIndex:[theLevel songIndex]];
    
    // Open the sheet...
    [NSApp beginSheet:levelSettingsSheet modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
    sheetOpen = YES;
}

- (IBAction)platformBtn:(id)sender
{
    //NSPanel *theP = theExSheet;//[[PhPlatformParametersWindowController sharedPlatformController] getSheet];
    //[NSApp beginSheet:theP modalForWindow:mainWindow modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction)applyLevelSettings:(id)sender
{
    //-(void)setPhysicsModel:(short)v;
    //-(void)setSongIndex:(short)v;
    
    LELevelData *theLevel = [[self document] getCurrentLevelLoaded];
    //BOOL thereIsAMissionType = NO;
    BOOL thereIsAGameType = NO;
    int i;
    
    for (i = 1; i <= NUMBER_OF_GAME_TYPES; i++) {
        if (SState(gameType, i))
            thereIsAGameType = YES;
        /*if (SState(mission, i))
            thereIsAMissionType = YES;*/
    }
    
    
    if (!thereIsAGameType /*|| !thereIsAMissionType*/) {
        NSMutableString *theProblemMsg = [[NSMutableString alloc] initWithString:@"Need To Fix:\n\n"];
        
        if (!thereIsAGameType)
            [theProblemMsg appendString:@"No Game Type Selected\n"];
        /*if (!thereIsAMissionType)
            [theProblemMsg appendString:@"No Mission Selected\n"];*/
        
        SEND_ERROR_MSG_TITLE(theProblemMsg, @"Problem With Choices");
        
        return;
    }
    
    [levelSettingsSheet orderOut:nil];
    [NSApp endSheet:levelSettingsSheet];
    
    sheetOpen = NO;
    
    //[sender setEnabled:NO];
    
    [theLevel setEntryPointFlags:0];
    if SState(gameType, 1) [theLevel setGameTypeSinglePlayer:YES];
    if SState(gameType, 2) [theLevel setGameTypeCooperative:YES];
    if SState(gameType, 3) [theLevel setGameTypeMultiplayerCarnage:YES];
    if SState(gameType, 4) [theLevel setGameTypeCaptureTheFlag:YES];
    if SState(gameType, 5) [theLevel setGameTypeKingOfTheHill:YES];
    if SState(gameType, 6) [theLevel setGameTypeDefense:YES];
    if SState(gameType, 7) [theLevel setGameTypeRugby:YES];
    
    [theLevel setMissionFlags:0];
    if SState(mission, 1) [theLevel setMissionExtermination:YES];
    if SState(mission, 2) [theLevel setMissionExploration:YES];
    if SState(mission, 3) [theLevel setMissionRetrieval:YES];
    if SState(mission, 4) [theLevel setMissionRepair:YES];
    if SState(mission, 5) [theLevel setMissionRescue:YES];
    
    [theLevel setEnvironmentFlags:0];
    if SState(environmentFlags, 1) [theLevel setEnvironmentVacuum:YES];
    if SState(environmentFlags, 2) [theLevel setEnvironmentRebellion:YES];
    if SState(environmentFlags, 3) [theLevel setEnvironmentLowGravity:YES];
    if SState(environmentFlags, 4) [theLevel setEnvironmentMagnetic:YES];
    
    [theLevel setEnvironmentCode:[environmentTexture indexOfSelectedItem]];
    //May need to release the previous NSString...  do it in the level
    //data object setLevelName method, not here!!!
    
    // Sets the landscape, which for Forge is stored in the song_index of the 'Minf' tag...
    [theLevel setSongIndex:[landscape indexOfSelectedItem]];
    
    [theLevel setLevelName:[levelName stringValue]];
    
    [[self document] changeLevelNameForLevel:[mapLevelList indexOfSelectedItem] toString:[levelName stringValue]];
    
    [self updateTheLevelNamesMenu];
    
    showLevelSettingsSheetWhenWindowIsLoaded = NO;
}

- (IBAction)cancelLevelSettings:(id)sender
{
    [levelSettingsSheet orderOut:nil];
    [NSApp endSheet:levelSettingsSheet];
    
    sheetOpen = NO;
    
    if (closeIfLevelSettingsCancled) {
        // Should Get Rid Of New Document...
        NSLog(@"Closing Document...");
        [[self document] close];
    }
    
    showLevelSettingsSheetWhenWindowIsLoaded = NO;
}

- (IBAction)warnAboutLandscapeSetting:(id)sender
{
	static BOOL alreadyWarned = NO;
	
	if (!alreadyWarned) {
		alreadyWarned = YES;
		SEND_INFO_MSG_TITLE(@"This setting will tell Aleph One/Marathon what landscape texture set to load. If you wish to use a two diffrent landscapes, you will need to use MML to load the other landscape texture sets.", @"Please Note");
	}
}


// ************************ Utility and Update Methods ************************
#pragma mark -
#pragma mark ********* Utility and Update Methods *********

- (void)updateTheLevelNamesMenu
{
    NSInteger theLevelIndex = [mapLevelList indexOfSelectedItem];
    [mapLevelList removeAllItems];
    [mapLevelList addItemsWithTitles:[[self document] levelNames]];
    [mapLevelList selectItemAtIndex:theLevelIndex];
}

- (void)disableTheLevelNamesMenu:(BOOL)theAnswer
{
    disableLevelNameMenu = theAnswer;
}

- (BOOL)isSheetAlreadyOpen
{
    if (sheetOpen == YES) {
        SEND_ERROR_MSG_TITLE(@"Sorry, sheet already opened in this document, finish with that sheet then do this",
                             @"Temporarily Can't Do Command");
        return YES;
    } else {
        return NO;
    }
}

// ************************ Map Manager ************************
#pragma mark -
#pragma mark ********* Map Mananger *********

- (IBAction)toggleMapManagerDrawer:(id)sender
{
    [theManagerDrawer toggle:self];
}

- (void)updateMapManagerInterface
{
    LELevelData *theCurrentLevel = [[self document] getCurrentLevelLoaded];
    NSDictionary *theOptionDict = [theCurrentLevel getLevelOptionDictionary];
    float gridFactor = 0.00;
    
    if ([theOptionDict count] == 1) {
        [gridFactorMenu setEnabled:YES];
        
        gridFactor = [theCurrentLevel settingAsFloat:PhGridFactor];
        
        if (gridFactor == 0.125)
            [gridFactorMenu selectItemAtIndex:_mm_1_8];
        else if (gridFactor == 0.250)
            [gridFactorMenu selectItemAtIndex:_mm_1_4];
        else if (gridFactor == 0.500)
            [gridFactorMenu selectItemAtIndex:_mm_1_2];
        else if (gridFactor == 1.000)
            [gridFactorMenu selectItemAtIndex:_mm_1];
        else if (gridFactor == 2.000)
            [gridFactorMenu selectItemAtIndex:_mm_2];
        else if (gridFactor == 4.000)
            [gridFactorMenu selectItemAtIndex:_mm_4];
        else if (gridFactor == 8.000)
            [gridFactorMenu selectItemAtIndex:_mm_8];
        else
            [gridFactorMenu selectItemAtIndex:-1];
        
        return;
    } else if ([theOptionDict count] > 0) {
        [useMapManager setState:NSControlStateValueOn];
        
        _gridOptionPointsToGrid.enabled = YES;
        _gridOptionObjectsToGrid.enabled = YES;
        _gridOptionPointsToPoints.enabled = YES;
        _gridOptionDraws.enabled = YES;
        [objectVisabilityCheckboxes setEnabledOfMatrixCellsTo:YES];
        [gridFactorMenu setEnabled:YES];
    } else {
        [useMapManager setState:NSControlStateValueOff];
        
        _gridOptionPointsToGrid.enabled = NO;
        _gridOptionObjectsToGrid.enabled = NO;
        _gridOptionPointsToPoints.enabled = NO;
        _gridOptionDraws.enabled = NO;
        [objectVisabilityCheckboxes setEnabledOfMatrixCellsTo:NO];
        [gridFactorMenu setEnabled:NO];
        
        return;
    }
    
    _gridOptionPointsToGrid.state = NSControlStateValueOff;
    _gridOptionObjectsToGrid.state = NSControlStateValueOff;
    _gridOptionPointsToPoints.state = NSControlStateValueOff;
    _gridOptionDraws.state = NSControlStateValueOff;
    [objectVisabilityCheckboxes deselectAllCells];
    
    /*
     ??? --> PhSnapToPoints
     */
    
    if ([theCurrentLevel settingAsBool:PhSnapObjectsToGrid])
        _gridOptionObjectsToGrid.state = NSControlStateValueOn;
    if ([theCurrentLevel settingAsBool:PhEnableGridBool])
        _gridOptionDraws.state = NSControlStateValueOn;
    if ([theCurrentLevel settingAsBool:PhSnapToGridBool])
        _gridOptionPointsToGrid.state = NSControlStateValueOn;
    if ([theCurrentLevel settingAsBool:PhSnapToPoints])
        _gridOptionPointsToPoints.state = NSControlStateValueOn;
    
    if ([theCurrentLevel settingAsBool:PhEnableObjectEnemyMonster])
        SelectS(objectVisabilityCheckboxes, _mm_monster_vis);
    if ([theCurrentLevel settingAsBool:PhEnableObjectPlayer])
        SelectS(objectVisabilityCheckboxes, _mm_player_vis);
    if ([theCurrentLevel settingAsBool:PhEnableObjectSceanry])
        SelectS(objectVisabilityCheckboxes, _mm_scenary_vis);
    if ([theCurrentLevel settingAsBool:PhEnableObjectSound])
        SelectS(objectVisabilityCheckboxes, _mm_sound_vis);
    if ([theCurrentLevel settingAsBool:PhEnableObjectItem])
        SelectS(objectVisabilityCheckboxes, _mm_item_vis);
    if ([theCurrentLevel settingAsBool:PhEnableObjectGoal])
        SelectS(objectVisabilityCheckboxes, _mm_goal_vis);
    
    gridFactor = [theCurrentLevel settingAsFloat:PhGridFactor];
    
    if (gridFactor == 0.125)
        [gridFactorMenu selectItemAtIndex:_mm_1_8];
    else if (gridFactor == 0.250)
        [gridFactorMenu selectItemAtIndex:_mm_1_4];
    else if (gridFactor == 0.500)
        [gridFactorMenu selectItemAtIndex:_mm_1_2];
    else if (gridFactor == 1.000)
        [gridFactorMenu selectItemAtIndex:_mm_1];
    else if (gridFactor == 2.000)
        [gridFactorMenu selectItemAtIndex:_mm_2];
    else if (gridFactor == 4.000)
        [gridFactorMenu selectItemAtIndex:_mm_4];
    else if (gridFactor == 8.000)
        [gridFactorMenu selectItemAtIndex:_mm_8];
    else
        [gridFactorMenu selectItemAtIndex:-1];
    
    
    
    // *** *** *** Important Notes About Below *** *** ***
    
    // Don't need to overrid prefs for these
    // and they currently don't go though the level
    // specific settings pipe.
    
    // I think I want to have these go though the level specific options settings
    // like the above settings. When you do this have a good net in place togive default
    // answers when these settings are not defined in the level specific options becuase
    // these options should not be in the global prefs, and so there are no entrys in the
    // defaults database.  Although you may want to put them in the defaults data base on startup
    // but have not global control of them.
    
    //  SelectSIf(Matrix, Tag, BOOL);
    
    if ([levelDrawView boolOptionsFor:_mapoptions_select_points])
        [_selectionOptionCheckPoints setState:NSControlStateValueOn];
    else
        [_selectionOptionCheckPoints setState:NSControlStateValueOff];

    if ([levelDrawView boolOptionsFor:_mapoptions_select_lines])
        [_selectionOptionCheckLines setState:NSControlStateValueOn];
    else
        [_selectionOptionCheckLines setState:NSControlStateValueOff];
    
    if ([levelDrawView boolOptionsFor:_mapoptions_select_objects])
        [_selectionOptionCheckObjects setState:NSControlStateValueOn];
    else
        [_selectionOptionCheckObjects setState:NSControlStateValueOff];
    
    if ([levelDrawView boolOptionsFor:_mapoptions_select_polygons])
        [_selectionOptionCheckPolygons setState:NSControlStateValueOn];
    else
        [_selectionOptionCheckPolygons setState:NSControlStateValueOff];
    
    /**************************************************
    SelectSIf(selectionOptionCheckboxes, _mm_select_points, [levelDrawView boolOptionsFor:_mapoptions_select_points]);
    SelectSIf(selectionOptionCheckboxes, _mm_select_lines, [levelDrawView boolOptionsFor:_mapoptions_select_lines]);
    SelectSIf(selectionOptionCheckboxes, _mm_select_objects, [levelDrawView boolOptionsFor:_mapoptions_select_objects]);
    SelectSIf(selectionOptionCheckboxes, _mm_select_polygons, [levelDrawView boolOptionsFor:_mapoptions_select_polygons]);
    **************************************************/
}

- (IBAction)mapManagerDrawerAction:(id)sender
{
    //LELevelData *theCurrentLevel = [[self document] getCurrentLevelLoaded];
    
    [levelDrawView setBoolOptionsFor:_mapoptions_select_points to: _selectionOptionCheckPoints.state == NSControlStateValueOn];
    [levelDrawView setBoolOptionsFor:_mapoptions_select_lines to:_selectionOptionCheckLines.state == NSControlStateValueOn];
    [levelDrawView setBoolOptionsFor:_mapoptions_select_objects to:_selectionOptionCheckObjects.state == NSControlStateValueOn];
    [levelDrawView setBoolOptionsFor:_mapoptions_select_polygons to:_selectionOptionCheckPolygons.state == NSControlStateValueOn];
    
    [self updateMapManagerInterface];
}

- (IBAction)mapManagerPerfOverrideForGridSizeDrawerAction:(id)sender
{
    NSInteger menuSelection = [gridFactorMenu indexOfSelectedItem];
    float theGridFactor = 0.00;
    switch (menuSelection) {
        case _mm_1_8:
            theGridFactor = 0.125;
            break;
        case _mm_1_4:
            theGridFactor = 0.250;
            break;
        case _mm_1_2:
            theGridFactor = 0.500;
            break;
        case _mm_1:
            theGridFactor = 1.000;
            break;
        case _mm_2:
            theGridFactor = 2.000;
            break;
        case _mm_4:
            theGridFactor = 4.000;
            break;
        case _mm_8:
            theGridFactor = 8.000;
            break;
        default:
            theGridFactor = 1.000;
            break;
    }
    
    [[[self document] getCurrentLevelLoaded] setSettingFor:PhGridFactor asFloat:theGridFactor];
    [levelDrawView prefsChanged];
}

- (IBAction)mapManagerPerfOverrideDrawerAction:(id)sender
{
    NSInteger menuSelection = [gridFactorMenu indexOfSelectedItem];
    LELevelData *theCurrentLevel = [[self document] getCurrentLevelLoaded];
    float theGridFactor = 0.00;
    
    [theCurrentLevel setSettingFor:PhSnapObjectsToGrid asBool:_gridOptionObjectsToGrid.state == NSControlStateValueOn];
    [theCurrentLevel setSettingFor:PhEnableGridBool asBool:_gridOptionDraws.state == NSControlStateValueOn];
    [theCurrentLevel setSettingFor:PhSnapToPoints asBool:_gridOptionPointsToPoints.state == NSControlStateValueOn];
    [theCurrentLevel setSettingFor:PhSnapToGridBool asBool:_gridOptionPointsToGrid.state == NSControlStateValueOn];
    
    [theCurrentLevel setSettingFor:PhEnableObjectEnemyMonster asBool:SState(objectVisabilityCheckboxes, _mm_monster_vis)];
    [theCurrentLevel setSettingFor:PhEnableObjectPlayer asBool:SState(objectVisabilityCheckboxes, _mm_player_vis)];
    [theCurrentLevel setSettingFor:PhEnableObjectSceanry asBool:SState(objectVisabilityCheckboxes, _mm_scenary_vis)];
    [theCurrentLevel setSettingFor:PhEnableObjectSound asBool:SState(objectVisabilityCheckboxes, _mm_sound_vis)];
    [theCurrentLevel setSettingFor:PhEnableObjectItem asBool:SState(objectVisabilityCheckboxes, _mm_item_vis)];
    [theCurrentLevel setSettingFor:PhEnableObjectGoal asBool:SState(objectVisabilityCheckboxes, _mm_goal_vis)];
    
    switch (menuSelection) {
        case _mm_1_8:
            theGridFactor = 0.125;
            break;
        case _mm_1_4:
            theGridFactor = 0.250;
            break;
        case _mm_1_2:
            theGridFactor = 0.500;
            break;
        case _mm_1:
            theGridFactor = 1.000;
            break;
        case _mm_2:
            theGridFactor = 2.000;
            break;
        case _mm_4:
            theGridFactor = 4.000;
            break;
        case _mm_8:
            theGridFactor = 8.000;
            break;
        default:
            theGridFactor = 1.000;
            break;
    }
    
    [theCurrentLevel setSettingFor:PhGridFactor asFloat:theGridFactor];
    
    [levelDrawView prefsChanged];
}

- (IBAction)useMapManagerCheckboxDrawerAction:(id)sender
{
    if ([sender state] == NSControlStateValueOff)
        [[[[self document] getCurrentLevelLoaded] getLevelOptionDictionary] removeAllObjects];
    else
        [[[self document] getCurrentLevelLoaded] copyOptionsFromPrefs];
    
    [self updateMapManagerInterface];
    
    [levelDrawView prefsChanged];
}

// ************************ Rename Dialog Actions/Methods ************************
#pragma mark -
#pragma mark ********* Rename Dialog Actions/Methods *********

- (void)renamePolyWithSheet:(__kindof LEMapStuffParent*)thePoly
{
    if ([self isSheetAlreadyOpen])
        return;
    
    objectToRename = thePoly;
    
    if ([thePoly doIHaveAName]) {
        [rdRemoveBtn setEnabled:YES];
        [rdTextInputTB setStringValue:[thePoly phName]];
    } else {
        [rdRemoveBtn setEnabled:NO];
        [rdTextInputTB setStringValue:[NSString
                                       stringWithFormat:@"Poly %d",
                                       [thePoly index]]];
    }
    
    [rdMessageIT setStringValue:[NSString
                                 stringWithFormat:@"Enter New Name For Polygon #%d",
                                 [thePoly index]]];
    // Open the sheet...
    [mainWindow beginSheet:rdSheet completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    sheetOpen = YES;
}

- (IBAction)rdOkBtnAction:(id)sender
{
    [[[self document] getCurrentLevelLoaded]
     namePolygon:objectToRename
     to:[rdTextInputTB stringValue]];
    
    [rdSheet orderOut:nil];
    [mainWindow endSheet:rdSheet returnCode:NSModalResponseOK];
    
    sheetOpen = NO;
}

- (IBAction)rdCancelBtnAction:(id)sender
{
    [rdSheet orderOut:nil];
    [mainWindow endSheet:rdSheet returnCode:NSModalResponseCancel];
    
    sheetOpen = NO;
}

- (IBAction)rdRemoveBtnAction:(id)sender
{
    [[[self document] getCurrentLevelLoaded]
     removeNameOfPolygon:objectToRename];
    
    [rdSheet orderOut:nil];
    [mainWindow endSheet:rdSheet returnCode:2];
    
    sheetOpen = NO;
}

// ************************ Go To Sheet Actions/Methods ************************
#pragma mark -
#pragma mark ********* Go To Sheet Actions/Methods *********

- (IBAction)goToPfhorgeObjectViaIndexSheet:(id)sender
{
    if ([self isSheetAlreadyOpen])
        return;
    
    // Open the sheet...
    [mainWindow beginSheet:gotoSheet completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    sheetOpen = YES;
}

- (IBAction)gotoOkBtnAction:(id)sender
{
    NSString *theReply = [levelDrawView
                          gotoAndSelectIndex:[gotoTextInputTB intValue]
                          ofType:(LEMapGoToType)[gotoPfhorgeObjectTypePopMenu indexOfSelectedItem]];
    
    if (theReply != nil) {
        [gotoMsgIT setStringValue:theReply];
    } else {
        [gotoSheet orderOut:nil];
        [mainWindow endSheet:gotoSheet returnCode:NSModalResponseOK];
        
        sheetOpen = NO;
    }
}

- (IBAction)gotoCancelBtnAction:(id)sender
{
    [gotoSheet orderOut:nil];
    [mainWindow endSheet:gotoSheet returnCode:NSModalResponseCancel];
    
    sheetOpen = NO;
}

// ************************ Add New Height Actions/Methods ************************
#pragma mark -
#pragma mark ********* Add New Height Actions/Methods *********

- (void)openNewHeightSheet
{
    if ([self isSheetAlreadyOpen])
        return;
    
    [[self window] beginSheet:newHeightWindowSheet completionHandler:^(NSModalResponse returnCode) {
        
    }];
    sheetOpen = YES;
}

- (IBAction)createNewHeightSheetBtn:(id)sender
{
    [levelDrawView addNewHeight:[NSNumber numberWithShort:((short)[newHeightTextBox intValue])]];
    [colorObject updateInterface:levelDrawView];
    
    //[levelDrawView setNewHeightSheetOpen:NO];
    
    sheetOpen = NO;
    
    [newHeightWindowSheet orderOut:nil];
    [[self window] endSheet:newHeightWindowSheet returnCode:NSModalResponseOK];
}

- (IBAction)cancelNewHeightSheetBtn:(id)sender
{
    //[levelDrawView setNewHeightSheetOpen:NO];
    
    sheetOpen = NO;
    
    [newHeightWindowSheet orderOut:nil];
    [[self window] endSheet:newHeightWindowSheet returnCode:NSModalResponseCancel];
}

// ************************ Note Group Manager Actions/Methods ************************
#pragma mark -
#pragma mark ********* Note Group Manager Actions/Methods *********

- (IBAction)openNoteGroupManager:(id)sender
{
    [self openNoteGroupManager];
}

- (void)openNoteGroupManager
{
    if ([self isSheetAlreadyOpen])
        return;
    
    [[self window] beginSheet:noteGroupWindow completionHandler:^(NSModalResponse returnCode) {
        
    }];
    sheetOpen = YES;
}

- (IBAction)closeNoteGroupManager:(id)sender
{
    [levelDrawView recaculateAndRedrawEverything];
    
    sheetOpen = NO;
    
    [noteGroupWindow orderOut:nil];
    [[self window] endSheet:noteGroupWindow];
}


// ************************ Annotation Notes Actions/Methods ************************
#pragma mark -
#pragma mark ********* Annotation Notes Actions/Methods *********
/*
- (IBAction)openNoteGroupManager:(id)sender
{
    [self openNoteGroupManager];
}
*/

    // *** Stuff For Note Editor Sheet ***
    //IBOutlet id annotationNoteEditorSheet;
    //IBOutlet id noteGroupPM;
    //IBOutlet id noteTextTB;

- (void)openAnnotationNoteEditor:(PhAnnotationNote *)note
{
    id obj = nil;
    
    if ([self isSheetAlreadyOpen])
        return;
    
    NSArray *types = [[[self document] getCurrentLevelLoaded] noteTypes];
    
    [noteGroupPM removeAllItems];
    
    [noteGroupPM addItemWithTitle:@"[No Group]"];
    
    for (obj in types) {
        [noteGroupPM addItemWithTitle:[obj phName]];
    }
    
    tmpNote = note;
    
    int index = -1;
    
    if ([tmpNote group] != nil)
        index = [[tmpNote group] index];
    
    NSLog(@"index: %d", index);
    
    if (index >= 0 && index < [types count]) {
        [noteGroupPM selectItemAtIndex:(index + 1)];
    } else {
        [noteGroupPM selectItemAtIndex:0];
    }
    
    [noteTextTB setStringValue:[tmpNote text]];
    
    [[self window] beginSheet:annotationNoteEditorSheet completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    [noteTextTB selectText:nil];
    sheetOpen = YES;
}

- (IBAction)closeNoteEditorSheet:(id)sender
{
    [tmpNote setText:[noteTextTB stringValue]];
    NSArray *types = [[[self document] getCurrentLevelLoaded] noteTypes];
    NSInteger index = [noteGroupPM indexOfSelectedItem];
    
    if (index > 0) {
        PhNoteGroup *grp = [types objectAtIndex:(index - 1)];
        [grp addObject:tmpNote];
    } else {
        [tmpNote setGroup:nil];
    }
    
    [levelDrawView recaculateAndRedrawEverything];
    
    sheetOpen = NO;
    
    [annotationNoteEditorSheet orderOut:nil];
    [[self window] endSheet:annotationNoteEditorSheet];
    tmpNote = nil;
}


// ************************ Some Regular Methods ************************
#pragma mark -
#pragma mark ********* Some Regular Methods *********

- (void)updateLayerSelection
{
    LELevelData *theCurLevel = [[self document] getCurrentLevelLoaded];
    
    int theCurLayerNumber = [theCurLevel getLayerModeIndex]; // zero is no layer on...
    
    [layerNamesMenu selectItemAtIndex:theCurLayerNumber];
}

@synthesize showLevelSettingsSheetWhenWindowIsLoaded;

- (void)updateLevelInfoString
{
    NSMutableString *levelInfoString;
    LELevelData *theLevel = [[self document] getCurrentLevelLoaded];
    NSSet *theSelections = [levelDrawView getSelectionsOfType:LEMapDrawSelectionAll];
    NSInteger theSelectionsCount = [theSelections count];
    
    if (theSelections == nil || theSelectionsCount < 1) {
        [theLevel updateCounts];
        
        ///levelInfoString = [[levelDrawView rectArrayDescription] retain];
        
        
        
        levelInfoString = [[NSMutableString alloc] initWithFormat:@"Points: %d   Lines: %d   Polygons: %d   Objects: %d   Platforms: %d   Media: %d   Lights: %d   Ambient Sounds: %d", [theLevel pointCount], [theLevel lineCount], [theLevel polygonCount], [theLevel objectCount], [theLevel platformCount], [theLevel liquidCount], [theLevel lightCount], [theLevel ambientSoundCount]];
        
        [self setFlagNow:0];
        // SIDE_IS_CONTROL_PANEL(s)
        // SET_SIDE_CONTROL_PANEL(s,t)
        //SET_SIDE_CONTROL_PANEL_NEW(self,NO);
        
        //if (SIDE_IS_CONTROL_PANEL_NEW(self))
        //    [levelInfoString appendString:@" YES "];
        //else
        //    [levelInfoString appendString:@" NO "];
        //[levelInfoString appendString:[[NSNumber numberWithShort:[self flagNow]] stringValue]];
        
        
        
    }
    else
    {
        if (theSelectionsCount == 1)
        {
            //id theSelctedObj = [[theSelections allObjects] objectAtIndex:0];
            id theSelctedObj = [theSelections anyObject];
            levelInfoString = [[NSMutableString alloc] initWithString:[theSelctedObj description]];
        }
        else // (theSelectionsCount > 1)
        {
            levelInfoString = [[NSMutableString alloc] initWithString:[[NSNumber numberWithShort:theSelectionsCount] stringValue]];
            [levelInfoString appendString:@" Objects Selected…"];
        }
    }
    [levelStatusBar setStringValue:levelInfoString];
}

- (void)setUplevelDrawView
{
    //You may have to change the window contrleer the
    //levelDrawView uses to this one, when does this
    //method (setUplevelDrawView) get called anyway?
    
    [levelDrawView setNeedsDisplay:YES];
}

// *********************** Notifcations ***********************
#pragma mark -
#pragma mark ********* Notifcations *********

- (void)aLevelDidChangeName:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    if ([[self document] getCurrentLevelLoaded] == levelDataObjectDeallocating) {
        [self updateTheLevelNamesMenu];
    }
}

// *** Level about to deallocate... ***
- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    if ([[self document] getCurrentLevelLoaded] == levelDataObjectDeallocating) {
        [levelDataObjectDeallocating removeMenu:layerNamesMenu thatIsOfMenuType:PhLevelNameMenuLayer];
    }
}

- (void)levelJustChanged:(NSNotification *)notification
{
    id levelDataObject = [notification object];
    
    if ([[self document] getCurrentLevelLoaded] == levelDataObject) {
        
    }
}

- (void)toolJustChanged:(NSNotification *)notification
{
    // Just set the correct cursor
    LEPaletteTool currentTool = [[LEPaletteController sharedPaletteController] currentTool];
    NSCursor *theCursor = nil;
    
    switch (currentTool) {
        case LEPaletteToolLine:
            theCursor = NSCursor.crosshairCursor;
            break;
            
        case LEPaletteToolHand:
            theCursor = NSCursor.openHandCursor;
            break;
            
        case LEPaletteToolPaint:
        case LEPaletteToolText:
        case LEPaletteToolZoom:
        case LEPaletteToolSampler:
        case LEPaletteToolBrush:
        case LEPaletteToolMonster:
        case LEPaletteToolPlayer:
        case LEPaletteToolItem:
        case LEPaletteToolScenery:
        case LEPaletteToolSound:
        case LEPaletteToolGoal:
        case LEPaletteToolArrow:
        default:
            //NSLog(@"toolJustChanged Arrow");
            theCursor = [NSCursor arrowCursor];
            break;
    }
    
    [[levelDrawView enclosingScrollView] setDocumentCursor:theCursor];
    //NSLog(@"toolJustChanged AFTER");
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
    if ([aNotification object] == [self window]) {
        if (showLevelSettingsSheetWhenWindowIsLoaded) {
            NSLog(@"Mandatory: Opening Level Sheet For New Level...");
            [levelSCancelBtn setEnabled:NO];
            [self levelSettingsSheet:self];
            showLevelSettingsSheetWhenWindowIsLoaded = NO;
        }
    }
}

- (void)windowDidLoad
{
    NSScrollView *enclosingScrollView;
    
    [super windowDidLoad];
    
     /********* IMPLMENT THIS FUNTION IN LEMapDraw.m and LEMapDraw.h !!! **********/
    //[levelDrawView setDrawWindowController:self];
    
    [self setUplevelDrawView];
	
	[self window];

    enclosingScrollView = [levelDrawView enclosingScrollView];
    
    [enclosingScrollView setHasHorizontalRuler:YES];
    [enclosingScrollView setHasVerticalRuler:YES];
    //[enclosingScrollView setBorderType:((NSInterfaceStyleForKey(nil, enclosingScrollView) == NSWindows95InterfaceStyle) ? NSBezelBorder : NSNoBorder)];
    
    [enclosingScrollView setBackgroundColor:[NSColor blackColor]];
    
    
    [enclosingScrollView setDrawsBackground:YES];
    [enclosingScrollView setScrollsDynamically:YES];
    
    [[enclosingScrollView contentView] setCopiesOnScroll:YES];
    
    [[self window] makeFirstResponder:levelDrawView];

    [self toolJustChanged:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolJustChanged:) name:LEToolChangedNotification object:[LEPaletteController sharedPaletteController]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelJustChanged:) name:LELevelChangedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
    
    
    [[self document] windowControllerDidLoadNib:self];
    
    ///windowDidExpose:notification
    
    [mapLevelList setEnabled:!disableLevelNameMenu];
    
    
    // *** Color Object Instalizeation ***
    [colorObject setLevelWindowController:self];
    [theColorDrawer close];
    
    [theManagerDrawer close];
    [self updateMapManagerInterface];
}

- (void)setDocument:(NSDocument *)document {
    [super setDocument:document];
    [self setUplevelDrawView];
}

@synthesize flagNow=theExpShort;

// *********************** Table Data Source Updater Methods ***********************
#pragma mark -
#pragma mark Table Data Source Updater Methods

// *** Data Source Messages ***

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return 3;
}

-(id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
           row:(NSInteger)rowIndex
{
    
    return @"TEST";
}



// *** NSSavePanel Exporting Methods ***
- (IBAction)exportMeToMarathonMap:(id)sender
{
    NSSavePanel *theSavePanel = [NSSavePanel savePanel];
    
    if ([self isSheetAlreadyOpen])
        return;
    
    [theSavePanel setPrompt:@"Export"];
    theSavePanel.allowedFileTypes = @[@"org.bungie.source.map"];
    
    [theSavePanel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        sheetOpen = NO;
        
        if (result != NSModalResponseOK)
            return;
        
        //[[self document] writeToURL:[sheet URL] ofType:@"org.bungie.source.map" forSaveOperation:NSSaveToOperation originalContentsURL:[[self document] fileURL] error:NULL];
        [[self document] exportToMarathonFormatAtPath:[theSavePanel URL].path];
    }];
    
    sheetOpen = YES;
}

- (void)savePanelDidEndForMapImport:(NSOpenPanel*)sheet returnCode:(NSModalResponse)returnCode contextInfo:(void  *)contextInfo
{
    sheetOpen = NO;
    
    if (returnCode != NSModalResponseOK)
        return;
    
    NSLog(@"Importing...");
    
    [[NSDocumentController sharedDocumentController]
     openDocumentWithContentsOfURL:[sheet URL] display:NO completionHandler:^(NSDocument * _Nullable theMapDocToImport, BOOL documentWasAlreadyOpen, NSError * _Nullable error) {
        if (theMapDocToImport != nil) {
            [[(LEMap *)[self document] level] unionLevel:[(LEMap *)theMapDocToImport level]];
            [theMapDocToImport close];
            [[(LEMap *)[self document] level] setCurrentLayerToLastLayer];
            [self updateLayerSelection];
            [levelDrawView recaculateAndRedrawEverything];
        } else {
            SEND_ERROR_MSG_TITLE(@"While importing, the new document was nil?", @"Import Problem");
        }
    }];
}

@end
