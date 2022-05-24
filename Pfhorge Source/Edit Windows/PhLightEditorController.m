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

- (id)initWithLight:(PhLight*)theLight
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
    NSLog(@"PhLightEditorController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[mapLevel updateCounts];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    theLightPhases[PhLightStateBecomingActive][0] = becomeingActivePeriod;
    theLightPhases[PhLightStateBecomingActive][1] = becomeingActivePeriodChng;
    theLightPhases[PhLightStateBecomingActive][2] = becomeingActiveIntesity;
    theLightPhases[PhLightStateBecomingActive][3] = becomeingActiveIntesityChng;
    theLightPhases[PhLightStateBecomingActive][4] = becomeingActiveFunction;
        theLightPhases[PhLightStateBecomingActive][5] = becomeingActiveIntesitySlider;
    theLightPhases[PhLightStateBecomingActive][6] = becomeingActiveIntesityChngSlider;
    
    theLightPhases[PhLightStatePrimaryActive][0] = primaryActivePeriod;
    theLightPhases[PhLightStatePrimaryActive][1] = primaryActivePeriodChng;
    theLightPhases[PhLightStatePrimaryActive][2] = primaryActiveIntesity;
    theLightPhases[PhLightStatePrimaryActive][3] = primaryActiveIntesityChng;
    theLightPhases[PhLightStatePrimaryActive][4] = primaryActiveFunction;
        theLightPhases[PhLightStatePrimaryActive][5] = primaryActiveIntesitySlider;
    theLightPhases[PhLightStatePrimaryActive][6] = primaryActiveIntesityChngSlider;
    
    theLightPhases[PhLightStateSecondaryActive][0] = secondaryActivePeriod;
    theLightPhases[PhLightStateSecondaryActive][1] = secondaryActivePeriodChng;
    theLightPhases[PhLightStateSecondaryActive][2] = secondaryActiveIntesity;
    theLightPhases[PhLightStateSecondaryActive][3] = secondaryActiveIntesityChng;
    theLightPhases[PhLightStateSecondaryActive][4] = secondaryActiveFunction;
        theLightPhases[PhLightStateSecondaryActive][5] = secondaryActiveIntesitySlider;
    theLightPhases[PhLightStateSecondaryActive][6] = secondaryActiveIntesityChngSlider;
    
        // InInactive
    theLightPhases[PhLightStateBecomingInactive][0] = becomeingInactivePeriod;
    theLightPhases[PhLightStateBecomingInactive][1] = becomeingInactivePeriodChng;
    theLightPhases[PhLightStateBecomingInactive][2] = becomeingInactiveIntesity;
    theLightPhases[PhLightStateBecomingInactive][3] = becomeingInactiveIntesityChng;
    theLightPhases[PhLightStateBecomingInactive][4] = becomeingInactiveFunction;
        theLightPhases[PhLightStateBecomingInactive][5] = becomeingInactiveIntesitySlider;
    theLightPhases[PhLightStateBecomingInactive][6] = becomeingInactiveIntesityChngSlider;
    
    theLightPhases[PhLightStatePrimaryInactive][0] = primaryInactivePeriod;
    theLightPhases[PhLightStatePrimaryInactive][1] = primaryInactivePeriodChng;
    theLightPhases[PhLightStatePrimaryInactive][2] = primaryInactiveIntesity;
    theLightPhases[PhLightStatePrimaryInactive][3] = primaryInactiveIntesityChng;
    theLightPhases[PhLightStatePrimaryInactive][4] = primaryInactiveFunction;
        theLightPhases[PhLightStatePrimaryInactive][5] = primaryInactiveIntesitySlider;
    theLightPhases[PhLightStatePrimaryInactive][6] = primaryInactiveIntesityChngSlider;

    theLightPhases[PhLightStateSecondaryInactive][0] = secondaryInactivePeriod;
    theLightPhases[PhLightStateSecondaryInactive][1] = secondaryInactivePeriodChng;
    theLightPhases[PhLightStateSecondaryInactive][2] = secondaryInactiveIntesity;
    theLightPhases[PhLightStateSecondaryInactive][3] = secondaryInactiveIntesityChng;
    theLightPhases[PhLightStateSecondaryInactive][4] = secondaryInactiveFunction;
        theLightPhases[PhLightStateSecondaryInactive][5] = secondaryInactiveIntesitySlider;
    theLightPhases[PhLightStateSecondaryInactive][6] = secondaryInactiveIntesityChngSlider;
    
    [mapLevel addMenu:tagComboMenu asMenuType:PhLevelNameMenuTag];
    
    [self refreshInterfaceFromData];
}


// *********************** Updater/Save Methods ***********************
#pragma mark -
#pragma mark ********* Updater Methods  *********
- (void)setupTitlesAndNames
{
    NSString *infoString = [NSString stringWithFormat:@"Light#%d - Name: %@", [curLight index], [curLight phName]];
    [infoIT setStringValue:infoString];
    
    [nameIT setStringValue:[@"Current Name: " stringByAppendingString:[curLight phName]]];
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
	
	
	
	if ([theLightPhases[PhLightStatePrimaryActive][0] intValue]  == 0
	 && [theLightPhases[PhLightStateSecondaryActive][0] intValue]  == 0)
	{
		SEND_ERROR_MSG_TITLE(@"The primary and secondary active periods are both zero, the light was not saved.",
							 @"Problem");
		return NO;
	}
	
	if ([theLightPhases[PhLightStatePrimaryInactive][0] intValue] == 0
	 && [theLightPhases[PhLightStateSecondaryInactive][0] intValue]  == 0)
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
