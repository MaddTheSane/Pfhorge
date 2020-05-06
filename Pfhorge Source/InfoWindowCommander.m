//
//  InfoWindowCommander.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Fri Dec 14 2001.
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
#import "PhAbstractNumber.h"
#import "LELevelData.h"
#import "LEExtras.h"
#import "LEMap.h"


@implementation InfoWindowCommander

- (id)initWithLevel:(LELevelData *)theLevel
                       withMapDocument:(LEMap *)theDocument
                           withNibFile:(NSString *)nibFileName
                        withEditingObj:(id)theObj;
{
    self = [super initWithWindowNibName:nibFileName];
    
    if (self == nil)
        return nil;
        
    mapDocument		= theDocument;
    mapLevel		= theLevel;
    theObjBeingEdited 	= theObj;
    
    [mapDocument addLevelInfoWinCon:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(levelDeallocating:)
                                          name:PhLevelDeallocatingNotification
                                          object:nil];
    
    return self;
}

- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    if (mapLevel == levelDataObjectDeallocating)
    {
        [mapDocument removeLevelInfoWinCon:self];
        mapLevel = nil;
        mapDocument = nil;
        theObjBeingEdited = nil;
    }
}

- (void)dealloc
{
    NSLog(@"InfoCommanderWindow dealloc");
    [mapDocument removeLevelInfoWinCon:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (BOOL)windowShouldClose:(id)sender
{
    NSLog(@"InfoCommanderWindow should close");
    [mapDocument removeLevelInfoWinCon:self];
    return YES;
}

- (IBAction)renameObjectAction:(id)sender
{
    if ([theObjBeingEdited doIHaveAName])
    {
        [theInputBox setStringValue:[theObjBeingEdited getPhName]];
    }
    else
    {
        [theInputBox setStringValue:[NSString
                stringWithFormat:@"Object %d",
                [theObjBeingEdited getIndex]]];
    }
    
    [renameSheetMsgIT setStringValue:[NSString
                stringWithFormat:@"Enter New Name For Object %d",
                [theObjBeingEdited getIndex]]];
    
        // Open the sheet...
    [NSApp  beginSheet:theSheet
            modalForWindow:[self window]
            modalDelegate:self
            didEndSelector:NULL
            contextInfo:nil];
}

- (IBAction)renameSheetApplyAction:(id)sender
{
    [mapLevel setNameFor:theObjBeingEdited
            to:[theInputBox stringValue]];
    
    [theSheet orderOut:nil];
    [NSApp endSheet:theSheet];
    [self setupTitlesAndNames];
}

- (IBAction)renameSheetCancelAction:(id)sender
{
    [theSheet orderOut:nil];
    [NSApp endSheet:theSheet];
}

- (void)setupTitlesAndNames
{
    SEND_ERROR_MSG(@"Sorry, but the name will not be updated on the window\
                        [it was applied though, I think ]:=) ]...");
    return;
}

- (int)tagIndexNumberFromShort:(short)tagNumber
{
    //NSArray *theLevelTags = [mapLevel getTags]; //getPhNumber
    
    NSLog(@"tagNumber requested: %d, index: %ld", tagNumber, (long)[mapLevel tagIndexNumberFromTagNumber:tagNumber]);

    return [mapLevel tagIndexNumberFromTagNumber:tagNumber];
    
    //NSLog(@"InfoWindowCommander -> Tag Number Not Found, Returning -1  count:%d", [theLevelTags count]);
    //return -1;
}

- (id)getObjectBeingEdited
{
    return theObjBeingEdited;
}


@end


