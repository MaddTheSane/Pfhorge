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
    if (self = [super initWithWindowNibName:nibFileName]) {
        mapDocument		= theDocument;
        mapLevel		= theLevel;
        theObjBeingEdited 	= theObj;
        
        [mapDocument addLevelInfoWinCon:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(levelDeallocating:)
                                                     name:PhLevelDeallocatingNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    if (mapLevel == levelDataObjectDeallocating) {
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
}

- (BOOL)windowShouldClose:(NSWindow *)sender
{
    NSLog(@"InfoCommanderWindow should close");
    [mapDocument removeLevelInfoWinCon:self];
    return YES;
}

- (IBAction)renameObjectAction:(id)sender
{
    if ([theObjBeingEdited doIHaveAName]) {
        [theInputBox setStringValue:[theObjBeingEdited phName]];
    } else {
        [theInputBox setStringValue:[NSString
                stringWithFormat:@"Object %d",
                [theObjBeingEdited index]]];
    }
    
    [renameSheetMsgIT setStringValue:[NSString
                stringWithFormat:@"Enter New Name For Object %d",
                [theObjBeingEdited index]]];
    
    // Open the sheet...
    [[self window] beginSheet:theSheet completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            [self->mapLevel setNameForObject:self->theObjBeingEdited
                                    toString:[self->theInputBox stringValue]];
            [self setupTitlesAndNames];
        }
    }];
}

- (IBAction)renameSheetApplyAction:(id)sender
{
    [theSheet orderOut:nil];
    [[self window] endSheet:theSheet returnCode:NSModalResponseOK];
}

- (IBAction)renameSheetCancelAction:(id)sender
{
    [theSheet orderOut:nil];
    [[self window] endSheet:theSheet returnCode:NSModalResponseCancel];
}

- (void)setupTitlesAndNames
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
    alert.informativeText = NSLocalizedString(@"Sorry, but the name will not be updated on the window\n[it was applied though, I think ]:=) ]…", @"Sorry, but the name will not be updated on the window\n[it was applied though, I think ]:=) ]…");
    alert.alertStyle = NSAlertStyleInformational;
    [alert runModal];
    return;
}

- (NSInteger)tagIndexNumberFromShort:(short)tagNumber
{
    //NSArray *theLevelTags = [mapLevel tags]; //phNumber
    
    NSLog(@"tagNumber requested: %d, index: %ld", tagNumber, (long)[mapLevel tagIndexNumberFromTagNumber:tagNumber]);

    return [mapLevel tagIndexNumberFromTagNumber:tagNumber];
    
    //NSLog(@"InfoWindowCommander -> Tag Number Not Found, Returning -1  count:%d", [theLevelTags count]);
    //return -1;
}

@synthesize objectBeingEdited=theObjBeingEdited;

@end
