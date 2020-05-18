//
//  PhLightEditorController.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon Dec 03 2001.
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


#import "PhLightEditorController.h"
#import "InfoWindowCommander.h"
#import "PhLevelNameManager.h"
#import "LELevelData.h"
#import "LEExtras.h"
#import "PhLight.h"
#import "LEMap.h"

@implementation PhLightEditorController

// *********************** Overridden Methods ***********************
#pragma mark -
#pragma mark ********* Overridden Methods *********

- (id)initWithLight:(id)theLight
            withLevel:(LELevelData *)theLevel
            withMapDocument:(LEMap *)theMapDoc
{
    NSString *theNibFileName = @"LightEditor";
    
    if (theLight == nil || theLevel == nil || theMapDoc == nil)
        return nil;
    
    self = [super initWithLevel:theLevel
                withMapDocument:theMapDoc
                withNibFile:theNibFileName
                withEditingObj:theLight];
    
    if (self == nil)
        return nil;
    
    curLight = theLight;
    
    //[self window];
    
    return self;
}

- (void)registerNotifcations
{
    [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(setupTagMenu)
            name:PhUserDidChangeNamesNotification
            object:nil];
}

- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    if (mapLevel == levelDataObjectDeallocating)
    {
        [mapLevel removeMenu:tagComboMenu thatsA:_tagMenu];
        [mapDocument removeLevelInfoWinCon:self];
        mapLevel = nil;
        mapDocument = nil;
        theObjBeingEdited = nil;
    }
}

- (void)dealloc
{
    NSLog(@"PhLightEditorController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[mapLevel updateCounts];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    theLightPhases[_light_becoming_active][0] = becomeingActivePeriod;
    theLightPhases[_light_becoming_active][1] = becomeingActivePeriodChng;
    theLightPhases[_light_becoming_active][2] = becomeingActiveIntesity;
    theLightPhases[_light_becoming_active][3] = becomeingActiveIntesityChng;
    theLightPhases[_light_becoming_active][4] = becomeingActiveFunction;
        theLightPhases[_light_becoming_active][5] = becomeingActiveIntesitySlider;
    theLightPhases[_light_becoming_active][6] = becomeingActiveIntesityChngSlider;
    
    theLightPhases[_light_primary_active][0] = primaryActivePeriod;
    theLightPhases[_light_primary_active][1] = primaryActivePeriodChng;
    theLightPhases[_light_primary_active][2] = primaryActiveIntesity;
    theLightPhases[_light_primary_active][3] = primaryActiveIntesityChng;
    theLightPhases[_light_primary_active][4] = primaryActiveFunction;
        theLightPhases[_light_primary_active][5] = primaryActiveIntesitySlider;
    theLightPhases[_light_primary_active][6] = primaryActiveIntesityChngSlider;
    
    theLightPhases[_light_secondary_active][0] = secondaryActivePeriod;
    theLightPhases[_light_secondary_active][1] = secondaryActivePeriodChng;
    theLightPhases[_light_secondary_active][2] = secondaryActiveIntesity;
    theLightPhases[_light_secondary_active][3] = secondaryActiveIntesityChng;
    theLightPhases[_light_secondary_active][4] = secondaryActiveFunction;
        theLightPhases[_light_secondary_active][5] = secondaryActiveIntesitySlider;
    theLightPhases[_light_secondary_active][6] = secondaryActiveIntesityChngSlider;
    
        // InInactive
    theLightPhases[_light_becoming_inactive][0] = becomeingInactivePeriod;
    theLightPhases[_light_becoming_inactive][1] = becomeingInactivePeriodChng;
    theLightPhases[_light_becoming_inactive][2] = becomeingInactiveIntesity;
    theLightPhases[_light_becoming_inactive][3] = becomeingInactiveIntesityChng;
    theLightPhases[_light_becoming_inactive][4] = becomeingInactiveFunction;
        theLightPhases[_light_becoming_inactive][5] = becomeingInactiveIntesitySlider;
    theLightPhases[_light_becoming_inactive][6] = becomeingInactiveIntesityChngSlider;
    
    theLightPhases[_light_primary_inactive][0] = primaryInactivePeriod;
    theLightPhases[_light_primary_inactive][1] = primaryInactivePeriodChng;
    theLightPhases[_light_primary_inactive][2] = primaryInactiveIntesity;
    theLightPhases[_light_primary_inactive][3] = primaryInactiveIntesityChng;
    theLightPhases[_light_primary_inactive][4] = primaryInactiveFunction;
        theLightPhases[_light_primary_inactive][5] = primaryInactiveIntesitySlider;
    theLightPhases[_light_primary_inactive][6] = primaryInactiveIntesityChngSlider;

    theLightPhases[_light_secondary_inactive][0] = secondaryInactivePeriod;
    theLightPhases[_light_secondary_inactive][1] = secondaryInactivePeriodChng;
    theLightPhases[_light_secondary_inactive][2] = secondaryInactiveIntesity;
    theLightPhases[_light_secondary_inactive][3] = secondaryInactiveIntesityChng;
    theLightPhases[_light_secondary_inactive][4] = secondaryInactiveFunction;
        theLightPhases[_light_secondary_inactive][5] = secondaryInactiveIntesitySlider;
    theLightPhases[_light_secondary_inactive][6] = secondaryInactiveIntesityChngSlider;
    
    [mapLevel addMenu:tagComboMenu asA:_tagMenu];
    
    [self refreshInterfaceFromData];
}


// *********************** Updater/Save Methods ***********************
#pragma mark -
#pragma mark ********* Updater Methods  *********
- (void)setupTitlesAndNames
{
    NSMutableString *infoString, *lightNameString;
    infoString = [[NSMutableString alloc] initWithString:@"Light#"];
        [infoString appendString:[[NSNumber numberWithShort:[curLight index]] stringValue]];
        [infoString appendString:@" - Name: "];
        [infoString appendString:[curLight phName]];
        [infoIT setStringValue:infoString];
        [infoString release];
    
    lightNameString = [[NSMutableString alloc] initWithString:@"Current Name: "];
        [lightNameString appendString:[curLight phName]];
        [nameIT setStringValue:lightNameString];
        [lightNameString release];
    return;
}

-(void)setupTagMenu // WHen user changes the name of a light, or tag, etc, a notificaiton will call this...
{
	// May want to do a few things here...
    // **************** ******************* *****************
}

-(void)refreshInterfaceFromData
{
    // -(short)type;
    // -(short)tag;
    
    //unsigned short theFlags = [light flags];
    int i;
    NSInteger lightTagMenuIndex = [self tagIndexNumberFromShort:[curLight tag]];
    
    [self setupTitlesAndNames];
    
    if (lightTagMenuIndex != -1)
        [tagComboMenu selectItemAtIndex:lightTagMenuIndex];
    else
        NSLog(@"Light that just entered edit mode -> tag not found?"); 
    
    //[curLight getPhName];
    [phaseTB setIntValue:[curLight phase]];
    
    for (i = 0; i < 6; i++)
    {
        float intensity = [curLight intensityForState:i];
        float deltaIntensity = [curLight deltaIntensityForState:i];
        
        [theLightPhases[i][0] setIntValue:[curLight periodForState:i]];
        [theLightPhases[i][1] setIntValue:[curLight deltaPeriodForState:i]];
        
        intensity = intensity / 65535;
        intensity = intensity * 100;

        deltaIntensity = deltaIntensity / 65535;
        deltaIntensity = deltaIntensity * 100;
        
        [theLightPhases[i][2] setIntValue:intensity];
        [theLightPhases[i][3] setIntValue:deltaIntensity];
        [theLightPhases[i][5] setIntValue:intensity];
        [theLightPhases[i][6] setIntValue:deltaIntensity];
        
        [theLightPhases[i][4] selectItemAtIndex:[curLight functionForState:i]];
        
        //NSLog(@"State %d has function# %d",i,[curLight functionForState:i]);
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidChangeNotification object:self];
    

    
    
    // *** Reset Everything ***
}

-(BOOL)saveChanges
{
    // -(short)type;
    // -(short)tag;
    //NSMutableString *infoString, *lightNameString;
    //unsigned short theFlags = [light flags];
    int i;
    //[curLight getPhName];
    [curLight setPhase:[phaseTB intValue]];
    
	if ([tagComboMenu indexOfSelectedItem] != -1)
		[curLight setTag:[[tagComboMenu titleOfSelectedItem] intValue]];
	else
		[curLight setTag:0];
	
	
	
	if ([theLightPhases[_light_primary_active][0] intValue]  == 0
	 && [theLightPhases[_light_secondary_active][0] intValue]  == 0)
	{
		SEND_ERROR_MSG_TITLE(@"The primary and secondary active periods are both zero, the light was not saved.",
							 @"Problem");
		return NO;
	}
	
	if ([theLightPhases[_light_primary_inactive][0] intValue] == 0
	 && [theLightPhases[_light_secondary_inactive][0] intValue]  == 0)
	{
		SEND_ERROR_MSG_TITLE(@"The primary and secondary inactive periods are both zero, the light was not saved.",
							 @"Problem");
		return NO;
	}
		
    for (i = 0; i < 6; i++)
    {
        float intensity = [theLightPhases[i][2] intValue];
        float deltaIntensity = [theLightPhases[i][3] intValue];
        intensity = intensity / 100;
        intensity = intensity * 65535;
        deltaIntensity = deltaIntensity / 100;
        deltaIntensity = deltaIntensity * 65535;
        
        
        [curLight setIntensity:intensity forState:i];
        [curLight setDeltaIntensity:deltaIntensity forState:i];
        
        [curLight setPeriod:[theLightPhases[i][0] intValue] forState:i];
        [curLight setDeltaPeriod:[theLightPhases[i][1] intValue] forState:i];
        
        [curLight setFunction:[theLightPhases[i][4] indexOfSelectedItem] forState:i];
        
        //NSLog(@"State %d has function# %d",i,[curLight functionForState:i]);
    }
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidChangeNotification object:self];
    
    // *** Reset Everything ***
	return YES;
}


// *********************** Actions ***********************
#pragma mark -
#pragma mark ********* Actions  *********
- (IBAction)templateAction:(id)sender
{
    
}

- (IBAction)copyFromMenuAction:(id)sender
{
    
}
- (IBAction)saveBtnAction:(id)sender
{
    [self saveChanges];
}
- (IBAction)saveAndCloseBtnAction:(id)sender
{
    if ([self saveChanges])
		[[self window] performClose:self];
}
- (IBAction)revertBtnAction:(id)sender
{
    [self refreshInterfaceFromData];
}

- (IBAction)renameBtnAction:(id)sender
{
    
}

@end
