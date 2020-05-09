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


#import "PhRandomSndEditCon.h"
#import "InfoWindowCommander.h"
#import "PhLevelNameManager.h"
#import "PhRandomSound.h"
#import "LELevelData.h"
#import "LEExtras.h"
#import "PhLight.h"
#import "LEMap.h"

@implementation PhRandomSndEditCon

// *********************** Overridden Methods ***********************
#pragma mark -
#pragma mark ********* Overridden Methods *********

- (id)initWithSound:(id)theSound
            withLevel:(LELevelData *)theLevel
            withMapDocument:(LEMap *)theMapDoc
{
    if (theSound == nil || theLevel == nil || theMapDoc == nil)
        return nil;
    
    self = [super initWithLevel:theLevel
                withMapDocument:theMapDoc
                withNibFile:@"RandomSoundInterface"
                withEditingObj:theSound];
    
    if (self == nil)
        return nil;
    
    curRandomSound = theSound;
    
    [self window];
    
    //[mapLevel addMenu:tagComboMenu asA:_tagMenu];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
        //selector:@selector(reloadDataFromLevel)
        //name:LELevelChangedNotification
        //object:[self document]];
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[mapLevel updateCounts];
    //[mapLevel removeMenu:tagComboMenu thatsA:_tagMenu];
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
    infoString = [[NSMutableString alloc] initWithString:@"RandomSound#"];
        [infoString appendString:[[NSNumber numberWithShort:[curRandomSound index]] stringValue]];
        [infoString appendString:@" - Name: "];
        [infoString appendString:[curRandomSound getPhName]];
        [infoIT setStringValue:infoString];
        [infoString release];
    
    return;
}

-(void)setupTagMenu
{
    
}

-(void)refreshInterfaceFromData
{
    ///unsigned short soundFlags = [curRandomSound flags];
    
    [self setupTitlesAndNames];
    
    // *** update rest of interface ***
    
    [typeMenu selectItemAtIndex:[curRandomSound soundIndex]];
    
    [directionTB setIntValue:[curRandomSound direction]];
    [directionDeltaTB setIntValue:[curRandomSound deltaDirection]];
    
    [volumeTB setIntValue:[curRandomSound volume]];
    [volumeDeltaTB setIntValue:[curRandomSound deltaVolume]];

    [periodTB setIntValue:[curRandomSound period]];
    [periodDeltaTB setIntValue:[curRandomSound deltaPeriod]];

    [pitchTB setIntValue:[curRandomSound pitch]];
    [pitchDeltaTB setIntValue:[curRandomSound deltaPitch]];
    
    [phaseTB setIntValue:[curRandomSound phase]];
    
    [nonDirectionalCB setState:NO];
    [nonDirectionalCB setEnabled:NO];
    
    [infoIT setStringValue:@"Name Not Here Yet... :)"];
}

-(void)saveChanges
{
    //[curMedia setType:[typeMenu indexOfSelectedItem]];
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
