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
@synthesize speedTB;
@synthesize delayTB;

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
    
    [platformIsADoorCB setState:NSControlStateValueOff];
    [floorToCeilingCB setState:NSControlStateValueOff];
    
    // *** Set Everything ***
    
    [typeComboMenu selectItemAtIndex:[platform type]];
    [speedTB setFloatValue:(((float)[platform speed]) / 30)];
    [delayTB setFloatValue:([platform delay] / 30)];
    [minHeightTB setIntValue:[platform minimumHeight]];
    [maxHeightTB setIntValue:[platform maximumHeight]];
    
    if ([platform minimumHeight] == -1) {
        [autoCalcMinCB setState:NSControlStateValueOn];
        [minHeightTB setEnabled:NO];
    } else {
        [minHeightTB setEnabled:YES];
        [autoCalcMinCB setState:NSControlStateValueOff];
    }
    
    if ([platform maximumHeight] == -1) {
        [autoCalcMaxCB setState:NSControlStateValueOn];
        [maxHeightTB setEnabled:NO];
    } else {
        [maxHeightTB setEnabled:YES];
        [autoCalcMaxCB setState:NSControlStateValueOff];
    }
    
    if (platformFlags & PhPlatformIsInitiallyActive)
        SelectS(initiallyCBMatrix, 0);
    if (platformFlags & PhPlatformIsInitiallyExtended)
        SelectS(initiallyCBMatrix, 1);
        
    if (platformFlags & PhPlatformDeactivatesAtEachLevel)
        SelectS(deactivatesRBMatrix, 1);
    if (platformFlags & PhPlatformDeactivatesAtInitialLevel)
        SelectS(deactivatesRBMatrix, 2);
    
    if (platformFlags & PhPlatformActivatesAdjacentPlatformsWhenDeactivating)
        SelectS(deactivatesCBMatrix, 2);
    if (platformFlags & PhPlatformExtendsFloorToCeiling)
        [floorToCeilingCB setState:NSControlStateValueOn];
    else
        [floorToCeilingCB setState:NSControlStateValueOff];
    
    if ((platformFlags & PhPlatformComesFromFloor) &&
        (platformFlags & PhPlatformComesFromCeiling)) {
        SelectS(extendsFromRBMatrix, 2);
    } else {
        if (platformFlags & PhPlatformComesFromFloor)
            SelectS(extendsFromRBMatrix, 0);
        if (platformFlags & PhPlatformComesFromCeiling)
            SelectS(extendsFromRBMatrix, 1);
    }
        
    if (platformFlags & PhPlatformCausesDamage)
        SelectS(hitsObstructionCBMatrix, 0);
    if (platformFlags & PhPlatformDoesNotActivateParent)
        SelectS(otherOptionsCBMatrix, 3);
    
    if (platformFlags & PhPlatformActivatesOnlyOnce)
        SelectS(activatesCBMatrix, 0);
    if (platformFlags & PhPlatformActivatesLight)
        SelectS(activatesCBMatrix, 1);
    if (platformFlags & PhPlatformDeactivatesLight)
        SelectS(deactivatesCBMatrix, 0);
    if (platformFlags & PhPlatformIsPlayerControllable)
        SelectS(controllableByCBMatrix, 0);
    if (platformFlags & PhPlatformIsMonsterControllable)
        SelectS(controllableByCBMatrix, 1);
    if (platformFlags & PhPlatformReversesDirectionWhenObstructed)
        SelectS(hitsObstructionCBMatrix, 1);
    if (platformFlags & PhPlatformCannotBeExternallyDeactivated)
        SelectS(otherOptionsCBMatrix, 0);
    if (platformFlags & PhPlatformUsesNativePolygonHeights)
        SelectS(otherOptionsCBMatrix, 1);
    if (platformFlags & PhPlatformDelaysBeforeActivation)
        SelectS(otherOptionsCBMatrix, 2);
    if (platformFlags & PhPlatformActivatesAdjacentPlatformsWhenActivating)
        SelectS(activatesCBMatrix, 2);
    if (platformFlags & PhPlatformDeactivatesAdjacentPlatformsWhenActivating)
        SelectS(activatesCBMatrix, 3);
    if (platformFlags & PhPlatformDeactivatesAdjacentPlatformsWhenDeactivating)
        SelectS(deactivatesCBMatrix, 1);
    if (platformFlags & PhPlatformContractsSlower)
        SelectS(otherOptionsCBMatrix, 4);
    if (platformFlags & PhPlatformActivatesAdjacentPlatformsAtEachLevel)
        SelectS(activatesCBMatrix, 4);
    if (platformFlags & PhPlatformIsLocked)
        SelectS(otherOptionsCBMatrix, 5);
    if (platformFlags & PhPlatformIsSecret)
        SelectS(otherOptionsCBMatrix, 6);
    if (platformFlags & PhPlatformIsDoor) // 27 ???
        [platformIsADoorCB setState:NSControlStateValueOn];
}

-(void)saveChanges
{
    unsigned int theFlags = 0;
    
    if (platform == nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = NSLocalizedString(@"Platform Was Nil", @"Platform Was Nil");
        alert.informativeText = NSLocalizedString(@"When I tried to save the changes to the platform, the platform was nil?", @"When I tried to save the changes to the platform, the platform was nil?");
        alert.alertStyle = NSAlertStyleCritical;
        [alert runModal];
        return;
    }
    
    NSLog(@"Saving Changes To Platform: %@   |-| Index: %d", [platform phName], [platform index]);
    
    [platform setType:[typeComboMenu indexOfSelectedItem]];
    [platform setSpeed:((short)([speedTB floatValue] * 30))];
    [platform setDelay:((short)([delayTB floatValue] * 30))];
    [platform setMinimumHeight:[minHeightTB intValue]];
    [platform setMaximumHeight:[maxHeightTB intValue]];
    
    if (SState(initiallyCBMatrix, 0)){ 		(theFlags |= PhPlatformIsInitiallyActive); NSLog(@"Plat: PhPlatformIsInitiallyActive");}
    if (SState(initiallyCBMatrix, 1)){ 		(theFlags |= PhPlatformIsInitiallyExtended); NSLog(@"Plat: PhPlatformIsInitiallyExtended");}
    
    if (SState(deactivatesRBMatrix, 1)){ 	(theFlags |= PhPlatformDeactivatesAtEachLevel); NSLog(@"Plat: IPhPlatformDeactivatesAtEachLevel");}
    if SState(deactivatesRBMatrix, 2) 		(theFlags |= PhPlatformDeactivatesAtInitialLevel);
    
    if SState(deactivatesCBMatrix, 2) 		(theFlags |= PhPlatformActivatesAdjacentPlatformsWhenDeactivating);
    if ([floorToCeilingCB state] == NSControlStateValueOn) 	(theFlags |= PhPlatformExtendsFloorToCeiling);
    
    if (SState(extendsFromRBMatrix, 2))
    {
        theFlags |= PhPlatformComesFromFloor;
        theFlags |= PhPlatformComesFromCeiling;
    }
    else
    {
        if SState(extendsFromRBMatrix, 0) 	(theFlags |= PhPlatformComesFromFloor);
        if SState(extendsFromRBMatrix, 1) 	(theFlags |= PhPlatformComesFromCeiling);
    }
    
    if SState(hitsObstructionCBMatrix, 0) (theFlags |= PhPlatformCausesDamage);
    if SState(otherOptionsCBMatrix, 3) (theFlags |= PhPlatformDoesNotActivateParent);
    
    if SState(activatesCBMatrix, 0) (theFlags |= PhPlatformActivatesOnlyOnce);
    if SState(activatesCBMatrix, 1) (theFlags |= PhPlatformActivatesLight);
    if SState(deactivatesCBMatrix, 0) (theFlags |= PhPlatformDeactivatesLight);
    if SState(controllableByCBMatrix, 0) (theFlags |= PhPlatformIsPlayerControllable);
    if SState(controllableByCBMatrix, 1) (theFlags |= PhPlatformIsMonsterControllable);
    if SState(hitsObstructionCBMatrix, 1) (theFlags |= PhPlatformReversesDirectionWhenObstructed);
    if SState(otherOptionsCBMatrix, 0) (theFlags |= PhPlatformCannotBeExternallyDeactivated);
    if SState(otherOptionsCBMatrix, 1) (theFlags |= PhPlatformUsesNativePolygonHeights);
    if SState(otherOptionsCBMatrix, 2) (theFlags |= PhPlatformDelaysBeforeActivation);
    if SState(activatesCBMatrix, 2) (theFlags |= PhPlatformActivatesAdjacentPlatformsWhenActivating);
    
    if SState(activatesCBMatrix, 3) (theFlags |= PhPlatformDeactivatesAdjacentPlatformsWhenActivating);
    if SState(deactivatesCBMatrix, 1) (theFlags |= PhPlatformDeactivatesAdjacentPlatformsWhenDeactivating);
    if SState(otherOptionsCBMatrix, 4) (theFlags |= PhPlatformContractsSlower);
    if SState(activatesCBMatrix, 4) (theFlags |= PhPlatformActivatesAdjacentPlatformsAtEachLevel);
    if SState(otherOptionsCBMatrix, 5) (theFlags |= PhPlatformIsLocked);
    if SState(otherOptionsCBMatrix, 6) (theFlags |= PhPlatformIsSecret);
    if ([platformIsADoorCB state] == NSControlStateValueOn) (theFlags |= PhPlatformIsDoor);
    
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
    if ([sender state] == NSControlStateValueOn) {
        [minHeightTB setIntValue:-1];
        [minHeightTB setEnabled:NO];
    } else {
        [minHeightTB setIntValue:0];
        [minHeightTB setEnabled:YES];
    }
}

- (IBAction)autoCalcMaxHeightAction:(id)sender
{
    if ([sender state] == NSControlStateValueOn) {
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
