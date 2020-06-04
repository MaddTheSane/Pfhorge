//
//  PhPfhorgeSingleLevelDoc.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon May 27 2002.
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


#import "PhPfhorgeSingleLevelDoc.h"
#import "LEMapData.h"
#import "LEExtras.h"
#import "LELevelWindowController.h"
#import "PhPfhorgeScenarioLevelDoc.h"

#import "ScenarioResources.h"
#import "Resource.h"

@implementation PhPfhorgeSingleLevelDoc

- (NSImage *)getPICTResourceIndex:(ResID)PICTIndex
{
    if (scenario == nil)
        return nil;
    
    return [scenario getPICTResourceIndex:PICTIndex];
}

- (id)initWithScenarioDocument:(PhPfhorgeScenarioLevelDoc *)theScenarioDoc
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    scenario = theScenarioDoc;
    
    [self registerLevelRelatedNotifications];
    [self registerScenarioRelatedNotifications];
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    scenario = nil;
    
    [self registerLevelRelatedNotifications];
    
    return self;
}

- (void)dealloc
{
    if (scenario != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (BOOL)isThereAScenarioDocumentLinked
{
    return (scenario != nil) ? (YES) : (NO);
}

- (void)registerScenarioRelatedNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(scenarioDeallocating:)
                                          name:PhScenarioDeallocatingNotification
                                          object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(scenarioLevelNameChanged:)
                                          name:PhScenarioLevelNamesChangedNotification
                                          object:nil];
}

- (void)registerLevelRelatedNotifications
{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(levelDeallocating:)
                                          name:PhLevelDeallocatingNotification
                                          object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(updateLevelStringIfCorrectLevel:)
                                          name:PhLevelStatusBarUpdateNotification
                                          object:nil];
}

- (void)scenarioDeallocating:(NSNotification *)notification
{
    id theScenarioDallocating = [notification object];
    
    if (scenario == theScenarioDallocating) {
        scenario = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)scenarioLevelNameChanged:(NSNotification *)notification
{
    id theScenarioDallocating = [notification object];
    
    if (scenario == theScenarioDallocating) {
        [theLevel changeLevelNamesToStringArray:[scenario levelNames]];
    }
}

@synthesize scenarioDocument=scenario;
- (void)setScenarioDocument:(PhPfhorgeScenarioLevelDoc *)theScenarioDoc
{
    scenario = theScenarioDoc;
    
    if (scenario == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } else {
        NSLog(@"setScenarioDocument, scenario != nil");
        [self registerScenarioRelatedNotifications];
        [theLevel changeLevelNamesToStringArray:[scenario levelNames]];
    }
}

- (void)makeWindowControllers
{
    NSLog(@"*** Subclassed LEMap - makeWindowControllers ***");
    
    theLevelDocumentWindowController = [[LELevelWindowController alloc] init];
    [self addWindowController:theLevelDocumentWindowController];
    [theLevelDocumentWindowController disableTheLevelNamesMenu:YES];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError * _Nullable *)outError {
    // TODO: properly fill NSError on failure.
    
    ///NSLog(@"*** Subclassed LEMap - dataRepresentationOfType ***");
    
    NSMutableData *entireMapData = [[NSMutableData alloc] initWithCapacity:(500 * 1000)];
    
    if (shouldExportToMarathonFormat == YES || [typeName isEqualToString:@"org.bungie.source.map"]) {
        [entireMapData setData:[LEMapData convertLevelToDataObject:theLevel error:outError]];
    } else {
        short theVersionNumber = currentVersionOfPfhorgeLevelData;
        theVersionNumber = CFSwapInt16HostToBig(theVersionNumber);
        short thePfhorgeDataSig1 = 26743;
        thePfhorgeDataSig1 = CFSwapInt16HostToBig(thePfhorgeDataSig1);
        unsigned short thePfhorgeDataSig2 = 34521;
        thePfhorgeDataSig2 = CFSwapInt16HostToBig(thePfhorgeDataSig2);
        int thePfhorgeDataSig3 = 42296737;
        thePfhorgeDataSig3 = CFSwapInt32HostToBig(thePfhorgeDataSig3);
        
        NSData *theLevelMapData = [NSKeyedArchiver archivedDataWithRootObject:theLevel];
        
        [entireMapData appendBytes:&theVersionNumber length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig1 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig2 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig3 length:4];
        
        [entireMapData appendData:theLevelMapData];
        
        cameFromMarathonFormatedFile = NO;
    }
    
    return [entireMapData autorelease];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError * _Nullable *)outError {
    // TODO: properly fill NSError on failure.
    ///NSLog(@"*** Subclassed LEMap - loadDataRepresentation ***");
    
    //short version, dataVersion;
    BOOL loadedOk = NO;
    
    short theVersionNumber = currentVersionOfPfhorgeLevelData;
    short oldVersionNumber = oldVersionOfPfhorgeLevelData;
    short thePfhorgeDataSig1 = 26743;
    unsigned short thePfhorgeDataSig2 = 34521;
    int thePfhorgeDataSig3 = 42296737;
    
    short theVersionNumberFromData = 0;
    short thePfhorgeDataSig1FromData = 0;
    unsigned short thePfhorgeDataSig2FromData = 0;
    int thePfhorgeDataSig3FromData = 0;
    
   // NSRange firstOne = [aType rangeOfString:@"mmap"];
    
    [data getBytes:&theVersionNumberFromData range:NSMakeRange(0,2)];
    [data getBytes:&thePfhorgeDataSig1FromData range:NSMakeRange(2,2)];
    [data getBytes:&thePfhorgeDataSig2FromData range:NSMakeRange(4,2)];
    [data getBytes:&thePfhorgeDataSig3FromData range:NSMakeRange(6,4)];
     
    theVersionNumberFromData = CFSwapInt16BigToHost(theVersionNumberFromData);
    thePfhorgeDataSig1FromData = CFSwapInt16BigToHost(thePfhorgeDataSig1FromData);
    thePfhorgeDataSig2FromData = CFSwapInt16BigToHost(thePfhorgeDataSig2FromData);
    thePfhorgeDataSig3FromData = CFSwapInt32BigToHost(thePfhorgeDataSig3FromData);
    
    //NSRange secondOne = [theRawString rangeOfString:@"map"];
    
    if (thePfhorgeDataSig1FromData != thePfhorgeDataSig1 ||
        thePfhorgeDataSig2FromData != thePfhorgeDataSig2 ||
        thePfhorgeDataSig3FromData != thePfhorgeDataSig3) {
        NSLog(@"--------- ERROR: Tried To Load Marathon Map In PhPfhorgeSingleLevelDoc... ---------");
        SEND_ERROR_MSG_TITLE(@"Tried To load with wrong doc class!", @"Loading Error");
        loadedOk = NO;
    } else if (theVersionNumberFromData < 2 &&
        thePfhorgeDataSig1FromData == thePfhorgeDataSig1 &&
        thePfhorgeDataSig2FromData == thePfhorgeDataSig2 &&
        thePfhorgeDataSig3FromData == thePfhorgeDataSig3) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:@{NSLocalizedRecoverySuggestionErrorKey: @"Export it from the earlier version of Pfhorge, then open it here.", NSLocalizedFailureReasonErrorKey: @"Level Is Too Old"}];
        }
        SEND_ERROR_MSG_TITLE(@"Can't load this version of pfhorge map data,"
                                "export it in earlier, release candidate 1 release of Pfhorge, then open it here.",
                             @"Level Is Too Old");
        loadedOk = NO;
    } else if (theVersionNumberFromData > theVersionNumber &&
        thePfhorgeDataSig1FromData == thePfhorgeDataSig1 &&
        thePfhorgeDataSig2FromData == thePfhorgeDataSig2 &&
        thePfhorgeDataSig3FromData == thePfhorgeDataSig3) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:@{NSLocalizedRecoverySuggestionErrorKey: @"Export it from the newer version of Pfhorge, then open it here.", NSLocalizedFailureReasonErrorKey: @"Level Is Too New"}];
        }
        SEND_ERROR_MSG_TITLE(@"Can't load this version of pfhorge map data,"
                                "export it in latter version of Pfhorge, then open it here.",
                             @"Level Is Too New");
        loadedOk = NO;
    } else if (theVersionNumberFromData == oldVersionNumber &&
        thePfhorgeDataSig1FromData == thePfhorgeDataSig1 &&
        thePfhorgeDataSig2FromData == thePfhorgeDataSig2 &&
        thePfhorgeDataSig3FromData == thePfhorgeDataSig3) {
        NSLog(@"EARILIER VERSION: %d, Current Version: %d --> I am converting it...", theVersionNumberFromData, theVersionNumber);
        theRawMapData = nil;
        theLevel = [[NSUnarchiver unarchiveObjectWithData:
                        [data subdataWithRange:NSMakeRange(10 ,([data length] - 10))]] retain];
        if (theLevel != nil){
            loadedOk = YES;
            cameFromMarathonFormatedFile = NO;
            NSLog(@"theLevel != nil...");
            [theLevel updateCounts];
            [theLevel setLevelDocument:self];
            [theLevel setMyUndoManager:[self undoManager]];
            [theLevel setUpArrayPointersForEveryObject];
            [theLevel setupDefaultObjects];
        }
    } else if (theVersionNumberFromData == theVersionNumber &&
        thePfhorgeDataSig1FromData == thePfhorgeDataSig1 &&
        thePfhorgeDataSig2FromData == thePfhorgeDataSig2 &&
        thePfhorgeDataSig3FromData == thePfhorgeDataSig3) {
        NSLog(@"Loading Pfhorge Formated Map...");
        theRawMapData = nil;
        if (@available(macOS 10.13, *)) {
            theLevel = [[NSKeyedUnarchiver unarchivedObjectOfClass:[LELevelData class] fromData:[data subdataWithRange:NSMakeRange(10, ([data length] - 10))] error:outError] retain];
        } else {
            theLevel = [[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:[data subdataWithRange:NSMakeRange(10, ([data length] - 10))] error:outError] retain];
        }

        if (theLevel != nil) {
            loadedOk = YES;
            cameFromMarathonFormatedFile = NO;
            NSLog(@"theLevel != nil...");
            [theLevel updateCounts];
            [theLevel setLevelDocument:self];
            [theLevel setMyUndoManager:[self undoManager]];
            [theLevel setUpArrayPointersForEveryObject];
            [theLevel setupDefaultObjects];
        }
    } else if (theVersionNumberFromData > 1 &&  theVersionNumberFromData < theVersionNumber &&
        thePfhorgeDataSig1FromData == thePfhorgeDataSig1 &&
        thePfhorgeDataSig2FromData == thePfhorgeDataSig2 &&
        thePfhorgeDataSig3FromData == thePfhorgeDataSig3) {
        NSLog(@"EARILIER VERSION: %d, Current Version: %d --> I am converting it...", theVersionNumberFromData, theVersionNumber);
        NSLog(@"Loading Pfhorge Formated Map...");
        
        SEND_INFO_MSG_TITLE(@"This is an eariler version of the Pfhorge level format, I will convert it for you…", @"Update Needed");
        
        theRawMapData = nil;
        theLevel = [[NSUnarchiver unarchiveObjectWithData:
                        [data subdataWithRange:NSMakeRange(10 ,([data length] - 10))]] retain];
        if (theLevel != nil) {
            loadedOk = YES;
            cameFromMarathonFormatedFile = NO;
            NSLog(@"theLevel != nil...");
            [theLevel updateCounts];
            [theLevel setLevelDocument:self];
            [theLevel setMyUndoManager:[self undoManager]];
            [theLevel setUpArrayPointersForEveryObject];
            [theLevel setupDefaultObjects];
        }
    } else {
        if (outError) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:@{NSLocalizedDescriptionKey: @"Can't Load Map", NSLocalizedFailureReasonErrorKey: @"Can't Load File, Unknown Format."}];
        }
        SEND_ERROR_MSG_TITLE(@"Can't Load File, Unknown Format.",
                             @"Can't Load Map");
        loadedOk = NO;
    }
    
    NSLog(@"Returning from loadDataRepresentation...");
    
    return loadedOk;
}

@end
