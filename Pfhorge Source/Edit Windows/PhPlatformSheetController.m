//
//  PhPlatformSheetController.m
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

#import "PhPlatformSheetController.h"
#import "InfoWindowCommander.h"
#import "LELevelData.h"
#import "PhPlatform.h"
#import "LEExtras.h"
#import "LEMap.h"
#import "PhTag.h"

@implementation PhPlatformSheetController
// *********************** Overridden Methods ***********************
#pragma mark -
#pragma mark Overridden Methods

- (id)initWithPlatform:(PhPlatform *)thePlatform
             withLevel:(LELevelData *)theLevel
       withMapDocument:(LEMap *)theMapDoc
{
    //if (thePlatform == nil || theLevel == nil || theMapDoc == nil)
    //    return nil;
    
    self = [super initWithLevel:theLevel
                withMapDocument:theMapDoc
                    withNibFile:@"PlatformEditor"
                 withEditingObj:thePlatform];
    
    if (self == nil)
        return nil;
    
    //[self window];
    
    platform = thePlatform;
    
    /*[[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(setupTagMenu)
            name:PhUserDidChangeNamesNotification
            object:nil];*/
    
    return self;
}

- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    if (mapLevel == levelDataObjectDeallocating) {
        [mapLevel removeMenu:tagComboMenu thatIsOfMenuType:PhLevelNameMenuTag];
        [mapDocument removeLevelInfoWinCon:self];
        mapLevel = nil;
        mapDocument = nil;
        theObjBeingEdited = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [mapLevel addMenu:tagComboMenu asMenuType:PhLevelNameMenuTag];
    [self refreshFromPlatformData];
}

// *********************** Updater/Save Methods ***********************
#pragma mark -
#pragma mark Updater Methods
- (void)setupTitlesAndNames
{
    short platformPolygonIndex = [platform polygonIndex];
    
    [statusIT setStringValue:[NSString stringWithFormat:@"Level: Map - Name: %@ - Polygon#%d - Platform#%d", platform.phName, platformPolygonIndex, [platform index]]];
    return;
}

-(void)refreshFromPlatformData
{
    // *** Instalize Variables ***
    
    unsigned long platformFlags = [platform staticFlags];
    
    // [platform polygonObject];
    // short platformPolygonIndex = [platform polygonIndex];
    // short platformIndex =  [platform index];
    
    NSInteger platformTagMenuIndex = [self tagIndexNumberFromShort:[platform tag]];
    
    
    NSLog(@"Platform Tag Index: %d  number: %d", [[platform tagObject] index], [[[platform tagObject] phNumber] intValue]);
    
    [self setupTitlesAndNames];
    
    if (platformTagMenuIndex >= 0) {
        [tagComboMenu selectItemAtIndex:platformTagMenuIndex];
    } else {
		[tagComboMenu selectItemAtIndex:-1];
        NSLog(@"A platform that just entered edit mode -> tag not found?");
	}
    
    // *** Reset Everything ***
    
    [initiallyCBMatrix deselectAllCells];
    [controllableByCBMatrix deselectAllCells];
    [hitsObstructionCBMatrix deselectAllCells];
    [activatesCBMatrix deselectAllCells];
    [deactivatesCBMatrix deselectAllCells];
    [otherOptionsCBMatrix deselectAllCells];
    
    //SelectS(extendsFromRBMatrix, 2);
    SelectS(deactivatesRBMatrix, 0);
    
    [platformIsADoorCB setState:NSOffState];
    [floorToCeilingCB setState:NSOffState];
    
    // *** Set Everything ***
    
    [typeComboMenu selectItemAtIndex:[platform type]];
    [speedTB setFloatValue:(((float)[platform speed]) / 30)];
    [delayTB setFloatValue:([platform delay] / 30)];
    [minHeightTB setIntValue:[platform minimumHeight]];
    [maxHeightTB setIntValue:[platform maximumHeight]];
    
    if ([platform minimumHeight] == -1) {
        [autoCalcMinCB setState:NSOnState];
        [minHeightTB setEnabled:NO];
    } else {
        [minHeightTB setEnabled:YES];
        [autoCalcMinCB setState:NSOffState];
    }
    
    if ([platform maximumHeight] == -1) {
        [autoCalcMaxCB setState:NSOnState];
        [maxHeightTB setEnabled:NO];
    } else {
        [maxHeightTB setEnabled:YES];
        [autoCalcMaxCB setState:NSOffState];
    }
    
    if (platformFlags & _platform_is_initially_active)
        SelectS(initiallyCBMatrix, 0);
    if (platformFlags & _platform_is_initially_extended)
        SelectS(initiallyCBMatrix, 1);
        
    if (platformFlags & _platform_deactivates_at_each_level)
        SelectS(deactivatesRBMatrix, 1);
    if (platformFlags & _platform_deactivates_at_initial_level)
        SelectS(deactivatesRBMatrix, 2);
    
    if (platformFlags & _platform_activates_adjacent_platforms_when_deactivating)
        SelectS(deactivatesCBMatrix, 2);
    if (platformFlags & _platform_extends_floor_to_ceiling)
        [floorToCeilingCB setState:NSOnState];
    else
        [floorToCeilingCB setState:NSOffState];
    
    if ((platformFlags & _platform_comes_from_floor) &&
        (platformFlags & _platform_comes_from_ceiling)) {
        SelectS(extendsFromRBMatrix, 2);
    } else {
        if (platformFlags & _platform_comes_from_floor)
            SelectS(extendsFromRBMatrix, 0);
        if (platformFlags & _platform_comes_from_ceiling)
            SelectS(extendsFromRBMatrix, 1);
    }
        
    if (platformFlags & _platform_causes_damage)
        SelectS(hitsObstructionCBMatrix, 0);
    if (platformFlags & _platform_does_not_activate_parent)
        SelectS(otherOptionsCBMatrix, 3);
    
    if (platformFlags & _platform_activates_only_once)
        SelectS(activatesCBMatrix, 0);
    if (platformFlags & _platform_activates_light)
        SelectS(activatesCBMatrix, 1);
    if (platformFlags & _platform_deactivates_light)
        SelectS(deactivatesCBMatrix, 0);
    if (platformFlags & _platform_is_player_controllable)
        SelectS(controllableByCBMatrix, 0);
    if (platformFlags & _platform_is_monster_controllable)
        SelectS(controllableByCBMatrix, 1);
    if (platformFlags & _platform_reverses_direction_when_obstructed)
        SelectS(hitsObstructionCBMatrix, 1);
    if (platformFlags & _platform_cannot_be_externally_deactivated)
        SelectS(otherOptionsCBMatrix, 0);
    if (platformFlags & _platform_uses_native_polygon_heights)
        SelectS(otherOptionsCBMatrix, 1);
    if (platformFlags & _platform_delays_before_activation)
        SelectS(otherOptionsCBMatrix, 2);
    if (platformFlags & _platform_activates_adjacent_platforms_when_activating)
        SelectS(activatesCBMatrix, 2);
    if (platformFlags & _platform_deactivates_adjacent_platforms_when_activating)
        SelectS(activatesCBMatrix, 3);
    if (platformFlags & _platforms_deactivates_adjacent_platforms_when_deactivating)
        SelectS(deactivatesCBMatrix, 1);
    if (platformFlags & _platform_contracts_slower)
        SelectS(otherOptionsCBMatrix, 4);
    if (platformFlags & _platform_activates_adjacent_platforms_at_each_level)
        SelectS(activatesCBMatrix, 4);
    if (platformFlags & _platform_is_locked)
        SelectS(otherOptionsCBMatrix, 5);
    if (platformFlags & _platform_is_secret)
        SelectS(otherOptionsCBMatrix, 6);
    if (platformFlags & _platform_is_door) // 27 ???
        [platformIsADoorCB setState:NSOnState];
}

-(void)saveChanges
{
    unsigned int theFlags = 0;
    
    if (platform == nil) {
        SEND_ERROR_MSG_TITLE(@"When I tried to save the changes to the platform, the platform was nil?", @"Platform Was Nil");
        return;
    }
    
    NSLog(@"Saving Changes To Platform: %@   |-| Index: %d", [platform phName], [platform index]);
    
    [platform setType:[typeComboMenu indexOfSelectedItem]];
    [platform setSpeed:((short)([speedTB floatValue] * 30))];
    [platform setDelay:((short)([delayTB floatValue] * 30))];
    [platform setMinimumHeight:[minHeightTB intValue]];
    [platform setMaximumHeight:[maxHeightTB intValue]];
    
    if (SState(initiallyCBMatrix, 0)){ 		(theFlags |= _platform_is_initially_active); NSLog(@"Plat: _platform_is_initially_active");}
    if (SState(initiallyCBMatrix, 1)){ 		(theFlags |= _platform_is_initially_extended); NSLog(@"Plat: _platform_is_initially_extended");}
    
    if (SState(deactivatesRBMatrix, 1)){ 	(theFlags |= _platform_deactivates_at_each_level); NSLog(@"Plat: I_platform_deactivates_at_each_level");}
    if SState(deactivatesRBMatrix, 2) 		(theFlags |= _platform_deactivates_at_initial_level);
    
    if SState(deactivatesCBMatrix, 2) 		(theFlags |= _platform_activates_adjacent_platforms_when_deactivating);
    if ([floorToCeilingCB state] == NSOnState) 	(theFlags |= _platform_extends_floor_to_ceiling);
    
    if (SState(extendsFromRBMatrix, 2))
    {
        theFlags |= _platform_comes_from_floor;
        theFlags |= _platform_comes_from_ceiling;
    }
    else
    {
        if SState(extendsFromRBMatrix, 0) 	(theFlags |= _platform_comes_from_floor);
        if SState(extendsFromRBMatrix, 1) 	(theFlags |= _platform_comes_from_ceiling);
    }
    
    if SState(hitsObstructionCBMatrix, 0) (theFlags |= _platform_causes_damage);
    if SState(otherOptionsCBMatrix, 3) (theFlags |= _platform_does_not_activate_parent);
    
    if SState(activatesCBMatrix, 0) (theFlags |= _platform_activates_only_once);
    if SState(activatesCBMatrix, 1) (theFlags |= _platform_activates_light);
    if SState(deactivatesCBMatrix, 0) (theFlags |= _platform_deactivates_light);
    if SState(controllableByCBMatrix, 0) (theFlags |= _platform_is_player_controllable);
    if SState(controllableByCBMatrix, 1) (theFlags |= _platform_is_monster_controllable);
    if SState(hitsObstructionCBMatrix, 1) (theFlags |= _platform_reverses_direction_when_obstructed);
    if SState(otherOptionsCBMatrix, 0) (theFlags |= _platform_cannot_be_externally_deactivated);
    if SState(otherOptionsCBMatrix, 1) (theFlags |= _platform_uses_native_polygon_heights);
    if SState(otherOptionsCBMatrix, 2) (theFlags |= _platform_delays_before_activation);
    if SState(activatesCBMatrix, 2) (theFlags |= _platform_activates_adjacent_platforms_when_activating);
    
    if SState(activatesCBMatrix, 3) (theFlags |= _platform_deactivates_adjacent_platforms_when_activating);
    if SState(deactivatesCBMatrix, 1) (theFlags |= _platforms_deactivates_adjacent_platforms_when_deactivating);
    if SState(otherOptionsCBMatrix, 4) (theFlags |= _platform_contracts_slower);
    if SState(activatesCBMatrix, 4) (theFlags |= _platform_activates_adjacent_platforms_at_each_level);
    if SState(otherOptionsCBMatrix, 5) (theFlags |= _platform_is_locked);
    if SState(otherOptionsCBMatrix, 6) (theFlags |= _platform_is_secret);
    if ([platformIsADoorCB state] == NSOnState) (theFlags |= _platform_is_door);
    
    [platform setStaticFlags:theFlags];
    
    [[platform polygonObject] calculateSidesForAllLines];
	
	if ([tagComboMenu indexOfSelectedItem] != -1)
		[platform setTag:[[tagComboMenu titleOfSelectedItem] intValue]];
	else
		[platform setTag:0];
}

// *********************** Actions ***********************
#pragma mark -
#pragma mark ********* Actions  *********

- (IBAction)typeOfPlatformAction:(id)sender
{
    
}

- (IBAction)copyFromAction:(id)sender
{
    
}
// maxHeightTB minHeightTB
- (IBAction)autoCalcMinHeightAction:(id)sender
{
    if ([sender state] == NSOnState) {
        [minHeightTB setIntValue:-1];
        [minHeightTB setEnabled:NO];
    } else {
        [minHeightTB setIntValue:0];
        [minHeightTB setEnabled:YES];
    }
}

- (IBAction)autoCalcMaxHeightAction:(id)sender
{
    if ([sender state] == NSOnState) {
        [maxHeightTB setIntValue:-1];
        [maxHeightTB setEnabled:NO];
    } else {
        [maxHeightTB setIntValue:0];
        [maxHeightTB setEnabled:YES];
    }
}

- (IBAction)applyAction:(id)sender
{
    [self saveChanges];
}

- (IBAction)saveAndCloseBtnAction:(id)sender
{
    [self saveChanges];
    [[self window] performClose:self];
}

- (IBAction)revertAction:(id)sender
{
    [self refreshFromPlatformData];
}

- (IBAction)renamePlatformAction:(id)sender
{
    
}


@end
