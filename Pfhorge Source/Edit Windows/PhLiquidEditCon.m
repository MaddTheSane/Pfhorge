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


#import "InfoWindowCommander.h"
#import "PhLevelNameManager.h"
#import "PhLiquidEditCon.h"
#import "LELevelData.h"
#import "LEExtras.h"
#import "PhLight.h"
#import "PhMedia.h"
#import "LEMap.h"

@implementation PhLiquidEditCon

// *********************** Overridden Methods ***********************
#pragma mark -
#pragma mark ********* Overridden Methods *********

- (id)initWithMedia:(id)theMedia
            withLevel:(LELevelData *)theLevel
            withMapDocument:(LEMap *)theMapDoc
{
    if (theMedia == nil || theLevel == nil || theMapDoc == nil)
        return nil;
    
    self = [super initWithLevel:theLevel
                withMapDocument:theMapDoc
                withNibFile:@"LiquidInterface"
                withEditingObj:theMedia];
    
    if (self == nil)
        return nil;
    
    curMedia = theMedia;
    
    [self window];
    
    [mapLevel addMenu:tideLightMenu asA:_lightMenu];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
        //selector:@selector(reloadDataFromLevel)
        //name:LELevelChangedNotification
        //object:[self document]];
    
        // Active
    
    [self refreshInterfaceFromData];
    
    return self;
}

- (void)registerNotifcations
{
    [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(setupTagMenu)
            name:PhUserDidChangeNames
            object:nil];
}

- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    if (mapLevel == levelDataObjectDeallocating)
    {
        [mapLevel removeMenu:tideLightMenu thatsA:_lightMenu];
        [mapDocument removeLevelInfoWinCon:self];
        mapLevel = nil;
        mapDocument = nil;
        theObjBeingEdited = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[mapLevel updateCounts];
    //NSLog(@"PhLightEditorController dealloc");
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}


// *********************** Updater/Save Methods ***********************
#pragma mark -
#pragma mark ********* Updater Methods  *********
- (void)setupTitlesAndNames
{
    NSMutableString *infoString;
    // *** Set the name, etc. ***
    infoString = [[NSMutableString alloc] initWithString:@"Name: "];
        //[infoString appendString:[[NSNumber numberWithShort:[curRandomSound index]] stringValue]];
        //[infoString appendString:@" - Name: "];
        [infoString appendString:[curMedia getPhName]];
        [infoIT setStringValue:infoString];
        [infoString release];
    
    return;
}

-(void)setupTagMenu
{
    
}

-(void)refreshInterfaceFromData
{
    [self setupTitlesAndNames];
    if (curMedia == nil)
    {
        NSLog(@"curMedia was nil in media editor when refrshing interface!!!");
        return;
    }
    
    [typeMenu selectItemAtIndex:[curMedia type]];
    [tideLightMenu selectItemAtIndex:[[curMedia lightObject] index]];
    [transferModeMenu selectItemAtIndex:[curMedia transferMode]];
    
    [flowTB setIntValue:[curMedia currentMagnitude]];
    [angleTB setIntValue:[curMedia currentDirection]];
    [highTideMaxTB setIntValue:[curMedia high]];
    [lowTideMinTB setIntValue:[curMedia low]];
    
    [originXTB setIntValue:[curMedia origin].x];
    [originYTB setIntValue:[curMedia origin].y];
    [heightTB setIntValue:[curMedia height]];
    [minLightIntensityTB setObjectValue:[NSNumber numberWithLong:[curMedia minimumLightIntensity]]];
    [textureTB setIntValue:[curMedia texture]];

}

-(void)saveChanges
{
    NSArray *theLights = [mapLevel getLights];
    NSLog(@"Saving Media Changes...");
    
    if (curMedia == nil || mapLevel == nil || theLights == nil)
    {
        NSLog(@"Somthing was nil in media editor when saving!!!");
        return;
    }
    
    [curMedia setType:[typeMenu indexOfSelectedItem]];
    
    [curMedia setLightObject:[theLights objectAtIndex:[tideLightMenu indexOfSelectedItem]]];
    
    [curMedia setTransferMode:[transferModeMenu indexOfSelectedItem]];
    
    [curMedia setCurrentMagnitude:[flowTB intValue]];
    [curMedia setCurrentDirection:[angleTB intValue]];
    [curMedia setHigh:[highTideMaxTB intValue]];
    [curMedia setLow:[lowTideMinTB intValue]];
    
    [curMedia setOrigin:NSMakePoint([originXTB intValue], [originYTB intValue])];
    
    
    
    [curMedia setHeight:[heightTB intValue]];
    
    // Might want to get NSNumber Object value becuase of long, or double/float???
    [curMedia setMinimumLightIntensity:[minLightIntensityTB intValue]];
    [curMedia setTexture:[textureTB intValue]];
    
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
    [self saveChanges];
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
