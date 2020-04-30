//
//  LEMap.m
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

#import "LEMap.h"
#import "LEMapData.h"
#import "LEMapDraw.h"
#import "LELevelData.h"
#import "PhPrefsController.h"
#import "PhProgress.h"
#import "LEExtras.h"

#import "LEMapPoint.h"
#import "LELine.h"
#import "PhAmbientSound.h"
#import "PhRandomSound.h"
#import "PhPlatform.h"
#import "PhLight.h"
#import "PhMedia.h"

#import "LELevelWindowController.h"

#import "PhItemPlacementEditorController.h"
#import "PhPlatformSheetController.h"
#import "PhLightEditorController.h"
#import "InfoWindowCommander.h"
#import "PhAmbientSndEditCon.h"
#import "PhRandomSndEditCon.h"
#import "PhLiquidEditCon.h"
#import "PhAbstractName.h"

#import "OpenGLVisualModeController.h"

#import "TerminalEditorController.h"

#import "ScenarioResources.h"
#import "Resource.h"

@implementation LEMap

/*- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple 	NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyLevel";
}*/

- (NSImage *)getPICTResourceIndex:(int)PICTIndex
{
    Resource	*resource;
    
    /*resource = [resources resourceOfType:@"PICT"
        index:CHAPTER_SCREEN_BASE + [levelPopUp indexOfSelectedItem]];*/
    
    resource = [resources resourceOfType:@"PICT" index:PICTIndex];  
        
    return [[[NSImage alloc] initWithData:[resource data]] autorelease];
    
    /*if (resource) {
        [chapterScreen setImage:[[NSImage alloc] initWithData:[resource data]]];
    }
    else {
        [chapterScreen setImage:nil];
    }*/
}

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        theRawMapData = nil;
        theMap = nil;
        theLevel = nil;
        theLevelDocumentWindowController = nil;
        
        infoWindows = [[NSMutableArray alloc] initWithCapacity:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(levelDeallocating:)
                                          name:PhLevelDeallocatingNotification
                                          object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(updateLevelStringIfCorrectLevel:)
                                          name:PhLevelStatusBarUpdate
                                          object:nil];
        
        cameFromMarathonFormatedFile = NO;
        
        resources = [[ScenarioResources alloc] init];
    }
    
    return self;
}

+ (void)initialize
{
    [PhPrefsController sharedPrefController];
}

-(void)dealloc
{
   //[[editingWindowController window] performClose:self];
    
    if (theRawMapData != nil)
        [theRawMapData release];
    if (theMap != nil)
        [theMap release];
    if (theLevel != nil)
    {
        NSLog(@"Level Dealloc Post Notification");
        
        [self releaseAllInfoWindowControllers];
        
        [[NSNotificationCenter defaultCenter]
            postNotificationName:PhLevelDeallocatingNotification
            object:theLevel];
    }
    
    if (theLevelDocumentWindowController != nil)
        [theLevelDocumentWindowController release];
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //if (infoWindows != nil)
    //    [infoWindows release];
    
    [currentLevelNames release];
    ///currentLevelNames = nil;
    
    [resources release];
    ///resources = nil;
    
    [theLevel autorelease];
    theLevel = nil;
    
    [super dealloc];
}

- (LELevelData *)getCurrentLevelLoaded { return theLevel; }
- (LELevelData *)level { return theLevel; }
- (LEMapData *)getCurrentMapLoaded { return theMap; }
- (LEMapDraw *)getMapDrawView { return [theLevelDocumentWindowController levelDrawView]; }
- (NSArray *)levelNames { return currentLevelNames; }

- (void)changeLevelNameFor:(int)theLevelIndex To:(NSString *)theNewName
{
    NSString *copy = [theNewName copy];
    [currentLevelNames replaceObjectAtIndex:theLevelIndex withObject:copy];
    [copy release];
}

- (BOOL)didIComeFromMarathonFormatedFile { return cameFromMarathonFormatedFile; }
- (void)shouldExportToMarathonFile:(BOOL)answer { shouldExportToMarathonFormat = answer; }


// ************************* Actions *************************
#pragma mark -
#pragma mark ********* Actions *********

- (IBAction)openItemPalcmentEditor:(id)sender
{
    NSEnumerator *numer;
    id theWinController;
    BOOL editorAlreadyOpen = NO;
    
    numer = [infoWindows objectEnumerator];
    while (theWinController = [numer nextObject])
    {
        if ([theWinController isKindOfClass:[PhItemPlacementEditorController class]])
        {
            [theWinController showWindow:nil];
            editorAlreadyOpen = YES;
            break;
        }
    }
    
    if (!editorAlreadyOpen)
    {
        PhItemPlacementEditorController *theEditor = [[PhItemPlacementEditorController alloc] initWithMapDocument:self];
        [theEditor showWindow:nil];
        //[theEditor release];
    }

}

- (IBAction)openTerminalEditor:(id)sender
{
    NSEnumerator *numer;
    id theWinController;
    BOOL terminalAlreadyOpen = NO;
    
    numer = [infoWindows objectEnumerator];
    while (theWinController = [numer nextObject])
    {
        if ([theWinController isKindOfClass:[TerminalEditorController class]])
        {
            [theWinController showWindow:nil];
            terminalAlreadyOpen = YES;
            break;
        }
    }
    
    if (!terminalAlreadyOpen)
    {
        TerminalEditorController *theTerminalEditor = [[TerminalEditorController alloc] initWithMapDocument:self];
        [theTerminalEditor showWindow:nil];
        [theTerminalEditor release];
    }
}

- (IBAction)enterVisualMode:(id)sender
{
    NSLog(@" *** *** *** About To Enter Visual Mode *** *** ***");
    [[[OpenGLVisualModeController alloc] initWithLevelData:theLevel] showWindow:nil];
}

- (IBAction)saveDocument:(id)sender
{
    [self saveToPfhorgeFormat:sender];
}

- (IBAction)saveToPfhorgeFormat:(id)sender
{
    [self shouldExportToMarathonFile:NO];
    
    if ([self didIComeFromMarathonFormatedFile])
        [super saveDocumentAs:sender];
    else
        [super saveDocument:sender];
}

- (IBAction)exportToMarathonFormat:(id)sender
{
    //[self shouldExportToMarathonFile:YES];
    //[self saveDocumentAs:self];
    
    SEND_ERROR_MSG_TITLE(@"- (IBAction)exportToMarathonFormat:(id)sender in LEMap is no longer used...",
                         @"No Longer Used");
}

- (BOOL)exportToMarathonFormatAtPath:(NSString *)fullPath
{
    //NSData *theFileData = [[NSFileManager defaultManager] contentsAtPath:fileName];
    NSMutableData *tempData;
    
    tempData = [[LEMapData convertLevelToDataObject:[self level]] retain];
        
    [[NSFileManager defaultManager] createFileAtPath:fullPath
        contents:tempData
        attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                    
                    [NSNumber numberWithLong:'26.°'],
                    NSFileHFSCreatorCode,
                    
                    [NSNumber numberWithLong:'sce2'],
                    NSFileHFSTypeCode, nil]];
    
    [tempData release];
    
    return YES;
}

// *********************** Info Window Managment ***********************
#pragma mark -
#pragma mark ********* Info Window Managment *********

- (void)addLevelInfoWinCon:(id)winCon
{
    ///NSLog(@"Adding Info Window...");
    [infoWindows addObject:winCon];
    ///NSLog(@"Info Window Array Count: %d", [infoWindows count]);
}

- (void)removeLevelInfoWinCon:(id)winCon
{
    ///NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    {
        NSLog(@"Removing Info Window...");
        [infoWindows removeObjectIdenticalTo:winCon];
    }
    
    ///[pool release];
   /// NSLog(@"!");
}

- (BOOL)openEditWindowForObject:(id)objectToEdit
{
    InfoWindowCommander *editingWindowController = nil;
    
    NSEnumerator *numer;
    id theWinController;
    BOOL windowAlreadyOpen = NO;
    
    numer = [infoWindows objectEnumerator];
    while (theWinController = [numer nextObject])
    {
        if (![theWinController isKindOfClass:[TerminalEditorController class]] && ![theWinController isKindOfClass:[PhItemPlacementEditorController class]])
        {
            if ([theWinController getObjectBeingEdited] == objectToEdit)
            {
                [theWinController showWindow:self];
                windowAlreadyOpen = YES;
                break;
            }
        }
        
    }
    
    if (windowAlreadyOpen)
        return YES;
    
    if ([objectToEdit isKindOfClass:[PhLight class]])
    {
            NSLog(@"Editing Light %@", [objectToEdit getPhName]);
            editingWindowController = [[PhLightEditorController alloc]
                                            initWithLight:objectToEdit
                                            withLevel:theLevel
                                            withMapDocument:self];
            [editingWindowController showWindow:self];
    }
    else if ([objectToEdit isKindOfClass:[PhMedia class]])
    {
            NSLog(@"Editing Media Named: %@", [objectToEdit getPhName]);
            editingWindowController = [[PhLiquidEditCon alloc]
                                            initWithMedia:objectToEdit
                                            withLevel:theLevel
                                            withMapDocument:self];
            [editingWindowController showWindow:self];
    }
    else if ([objectToEdit isKindOfClass:[PhAmbientSound class]])
    {
            NSLog(@"Editing Ambient Sound %@", [objectToEdit getPhName]);
            editingWindowController = [[PhAmbientSndEditCon alloc]
                                            initWithSound:objectToEdit
                                            withLevel:theLevel
                                            withMapDocument:self];
            [editingWindowController showWindow:self];
    }
    else if ([objectToEdit isKindOfClass:[PhRandomSound class]])
    {
            NSLog(@"Editing Random Sound %@", [objectToEdit getPhName]);
            editingWindowController = [[PhRandomSndEditCon alloc]
                                            initWithSound:objectToEdit
                                            withLevel:theLevel
                                            withMapDocument:self];
            [editingWindowController showWindow:self];
    }
    else if ([objectToEdit isKindOfClass:[PhPlatform class]])
    {
            NSLog(@"Editing Platform Named: %@", [objectToEdit getPhName]);
            editingWindowController = [[PhPlatformSheetController alloc]
                                            initWithPlatform:objectToEdit
                                            withLevel:theLevel
                                            withMapDocument:self];
            [editingWindowController showWindow:self];
    }
    else
    {
        SEND_ERROR_MSG(@"Pfhorge attempted to edit somthing not support currently!");
        return NO;
    }
    
    [editingWindowController release];
    
    return YES;
}

// *********************** Notifcations ***********************
#pragma mark -
#pragma mark ********* Notifcations *********

- (void)updateLevelStringIfCorrectLevel:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    if (theLevel == levelDataObjectDeallocating) 
    {
        [self tellDocWinControllerToUpdateLevelInfoString];
    }
}

- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    NSLog(@"- (void)levelDeallocating:(NSNotification *)notification");
    
    if (theLevel == levelDataObjectDeallocating)
    {
        [self releaseAllInfoWindowControllers];
        [[theLevelDocumentWindowController levelDrawView] setTheLevel:nil];
    }
}

- (void)releaseAllInfoWindowControllers
{
    ///NSAutoreleasePool*pool;
    NSLog(@"Determining If I Need To Deallocate Info Windows...");
    
    if (infoWindows != nil && [infoWindows count] > 0)
    {
        NSEnumerator *numer;
        id theWinController;
        NSLog(@"Releasing all info windows for deallocating level...");
        numer = [infoWindows objectEnumerator];
        while (theWinController = [numer nextObject])
        {
           /// pool = [[NSAutoreleasePool alloc] init];
            if ([theWinController isKindOfClass:[TerminalEditorController class]])
            {
                NSLog(@"Terminal controler releasing - - - From LEMap");
                [[theWinController window] performClose:self];
                //[theWinController release];
                
                //[self removeLevelInfoWinCon:theWinController];
            }
            else
                [[theWinController window] performClose:self];
            
            ///[pool release];
        }
        
        [infoWindows removeAllObjects];
    }

}

// *********************** Loading and Saving Levels ***********************
#pragma mark -
#pragma mark ********* Loading and Saving Levels *********

- (void)makeWindowControllers
{
    theLevelDocumentWindowController = [[LELevelWindowController allocWithZone:[self zone]] init];
    [self addWindowController:theLevelDocumentWindowController];
}

- (void)windowControllerDidLoadNibSkip:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    PhProgress *progress = [PhProgress sharedPhProgress];
    [super windowControllerDidLoadNib:aController];
    
    if (theLevel != nil)
    {
        //currentLevelNames = [[theMap getLevelNames] copy];
        [theLevel setLevelDocument:self];
        currentLevelNames = [[NSMutableArray alloc] initWithCapacity:1];
        [currentLevelNames addObject:[theLevel getLevel_name]];
        
        [[theLevelDocumentWindowController levelDrawView] setTheLevel:theLevel];
        [theLevelDocumentWindowController mapLoaded];
        [[NSNotificationCenter defaultCenter] postNotificationName:LELevelChangedNotification object:theLevel];
        
        [self tellDocWinControllerToUpdateLevelInfoString];
        [[theLevelDocumentWindowController levelDrawView] setNeedsDisplay:YES];
        
        return;
    }
    
    // Add any code here that need to be executed once the windowController has loaded the document's window.
    NSLog(@"windowControllerDidLoadNib");
    if ( theRawMapData != nil)
    {
        [progress setMinProgress:0.0];
        [progress setMaxProgress:100.0];
        [progress setProgressPostion:0.0];
        [progress setStatusText:@"Loading Level, Please Wait..."];
        [progress setInformationalText:@"Loading Level, Please Wait..."];
        [progress showWindow:self];
        
        theMap = [[LEMapData alloc] initWithMapNSData:theRawMapData];
        //[comboLevelList addItemsWithObjectValues:[theMap getLevelNames]];
        theLevel = [theMap getLevel:1];
        [theLevel setLevelDocument:self];
        [[theLevelDocumentWindowController levelDrawView] setTheLevel:theLevel];
        
        [progress setStatusText:@"Sending Level Changed Notification..."];
        [progress increaseProgressBy:5.0];
        
        // Transfer Level Names
        currentLevelNames = [[theMap getLevelNames] copy];
        
        [theLevelDocumentWindowController mapLoaded];
        [[NSNotificationCenter defaultCenter] postNotificationName:LELevelChangedNotification object:theLevel];
        
        [progress setStatusText:@"Done Loading Level!"];
        [progress increaseProgressBy:5.0];
        [progress orderOutWin:self];
        //[theLevel setLayerModeTo:nil];
        [[theLevelDocumentWindowController levelDrawView] setNeedsDisplay:YES];
        
            [theLevel updateCounts];
            [theLevel setLevelDocument:self];
            [theLevel setMyUndoManager:[self undoManager]];
            [theLevel setUpArrayPointersForEveryObject];
            [theLevel setupDefaultObjects];
    }
    else
    {
        theMap = [[LEMapData alloc] init];
        theLevel = [[LELevelData alloc] initAndGenerateNewLevelObjects];
        [theLevel setLevelDocument:self];
        currentLevelNames = [[NSMutableArray alloc] initWithCapacity:1];
        [currentLevelNames addObject:@"Untitled Level"];
        
        [[theLevelDocumentWindowController levelDrawView] setTheLevel:theLevel];
        [theLevelDocumentWindowController mapLoaded];
        [[NSNotificationCenter defaultCenter] postNotificationName:LELevelChangedNotification object:theLevel];
        //[theLevel setLayerModeTo:nil];
        [[theLevelDocumentWindowController levelDrawView] setNeedsDisplay:YES];
        
       // [aController levelSettingsSheet:self];
       [(LELevelWindowController *)aController setShowLevelSettingsSheetWhenWindowIsLoaded:YES];
        
        //[theLevelDocumentWindowController mapLoaded]; // Might want to use LELevelChangedNotification instead...
            
            [theLevel updateCounts];
            [theLevel setLevelDocument:self];
            [theLevel setMyUndoManager:[self undoManager]];
            [theLevel setUpArrayPointersForEveryObject];
            [theLevel setupDefaultObjects];
    
    }
    
    [self tellDocWinControllerToUpdateLevelInfoString];
}

- (void)loadLevel:(int)levelNumber //Starts at one, not zero... :)
{
    PhProgress *progress = [PhProgress sharedPhProgress];
    if ( theRawMapData != nil)
    {
        if (theMap == nil)
            return;
        if (theLevel != nil)
        {
            NSLog(@"Level Dealloc Post Notification");
            [self releaseAllInfoWindowControllers];
            
            [[NSNotificationCenter defaultCenter]
                postNotificationName:PhLevelDeallocatingNotification
                object:theLevel];
            [theLevel release];
        }
            
        [progress setMinProgress:0.0];
        [progress setMaxProgress:100.0];
        [progress setProgressPostion:0.0];
        [progress setStatusText:@"Loading Level, Please Wait..."];
        [progress setInformationalText:@"Loading Level, Please Wait..."];
        [progress showWindow:self];
        
        theLevel = [theMap getLevel:levelNumber];
        [[theLevelDocumentWindowController levelDrawView] setTheLevel:theLevel];
        
        [progress setStatusText:@"Sending level Changes Notification..."];
        [progress increaseProgressBy:5.0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LELevelChangedNotification object:theLevel];
	
        [progress setStatusText:@"Done Loading Level!"];
        [progress increaseProgressBy:5.0];
        [progress orderOutWin:self];
        
        //[levelDrawArea recaculateAndRedrawEverything];
        //[levelDrawArea setNeedsDisplay:YES];
        //[theLevel setLayerModeTo:nil];
        [[theLevelDocumentWindowController levelDrawView] setNeedsDisplay:YES];
        
            [theLevel updateCounts];
            [theLevel setLevelDocument:self];
            [theLevel setMyUndoManager:[self undoManager]];
            [theLevel setUpArrayPointersForEveryObject];
            [theLevel setupDefaultObjects];
    }
    
    [self tellDocWinControllerToUpdateLevelInfoString];
}

-(void)tellDocWinControllerToUpdateLevelInfoString
{
    [theLevelDocumentWindowController updateLevelInfoString];
}

#pragma mark -
#pragma mark ****************** NEW METHODS ******************

// ****************** NEW METHODS ******************

- (BOOL)writeToFile:(NSString *)fullDocumentPath ofType:(NSString *)documentTypeName
    originalFile:(NSString *)fullOriginalDocumentPath
    saveOperation:(NSSaveOperationType)saveOperationType
{
    //[self updateInternalData];
    
    NSString *pathToUse = [fullDocumentPath copy];
    /*
    if (![[fullDocumentPath pathExtension] isEqualToString:@"lev"])
    {
        [pathToUse release];
        pathToUse = [[fullDocumentPath stringByAppendingString:@".lev"] retain];
    }*/
    
    [[NSFileManager defaultManager] createFileAtPath:pathToUse
        contents:[self dataRepresentationOfType:@""]
        attributes:nil];
    
    [pathToUse release];
    
    // [wad saveToFile:fullDocumentPath oldFile:fullOriginalDocumentPath];
    // [resources saveToFile:fullDocumentPath oldFile:fullOriginalDocumentPath];
    
    return YES;
}

- (NSDictionary *)fileAttributesToWriteToFile:(NSString *)fullDocumentPath
    ofType:(NSString *)documentTypeName saveOperation:(NSSaveOperationType)saveOperationType
{
    NSMutableDictionary	*dict = [NSMutableDictionary dictionaryWithDictionary:
                            [super fileAttributesToWriteToFile:fullDocumentPath
                            ofType:documentTypeName saveOperation:saveOperationType]];
    
    [dict setObject:[NSNumber numberWithUnsignedLong:'sce2'] forKey:NSFileHFSTypeCode];
    
    return dict;
}

- (BOOL)readFromFile:(NSString *)fileName ofType:(NSString *)type
{
    BOOL value = YES;
    
    value = [self loadDataRepresentation:[[NSFileManager defaultManager] contentsAtPath:fileName] ofType:@""];
    
    if (value == NO)
        return NO;
    
    NS_DURING
    
    //[wad initWithContentsOfFile:fileName];
    [resources initWithContentsOfFile:fileName];
    
    NS_HANDLER
    if (NSRunCriticalAlertPanel(@"Error opening file",
                                @"\"%@\" has the following problems:\n\n%@",
                                @"Close", nil, nil, fileName, localException)
                                == NSAlertDefaultReturn) {
        value = NO;
        [localException raise];
    }
    NS_ENDHANDLER
    
    //[[self undoManager] removeAllActions];
    
    return value;
}

#pragma mark ****************** (END) NEW METHODS ******************
#pragma mark -

// ****************** (END) NEW METHODS ******************

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    //NSData *theLevelMapData = [theMap saveLevelAndGetMapNSData:theLevel levelToSaveIn:1];
    
    
    NSMutableData *entireMapData = [[NSMutableData alloc] initWithCapacity:(500 * 1000)];
    
    if (shouldExportToMarathonFormat == YES)
    {
        entireMapData = [LEMapData convertLevelToDataObject:(LELevelData *)theLevel];
    }
    else
    {
        short theVersionNumber = currentVersionOfPfhorgeLevelData;
        short thePfhorgeDataSig1 = 26743;
        short thePfhorgeDataSig2 = 34521;
        long thePfhorgeDataSig3 = 42296737;
        
        NSData *theLevelMapData = [NSArchiver archivedDataWithRootObject:theLevel];
        
        [entireMapData appendBytes:&theVersionNumber length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig1 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig2 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig3 length:4];
        
        [entireMapData appendData:theLevelMapData];
        
        cameFromMarathonFormatedFile = NO;
    }
    
    return entireMapData;
    
    
    // return nil;
    
    /*NSMutableData *entireMapData = [[NSMutableData alloc] initWithCapacity:(500 * 1000)];
    
    if (shouldExportToMarathonFormat == YES)
    {
        [entireMapData release];
        entireMapData = [[LEMapData convertLevelToDataObject:(LELevelData *)theLevel] retain];
    }
    else
    {
        short theVersionNumber = 3;
        short thePfhorgeDataSig1 = 26743;
        short thePfhorgeDataSig2 = 34521;
        long thePfhorgeDataSig3 = 42296737;
        
        NSData *theLevelMapData = [NSArchiver archivedDataWithRootObject:theLevel];
        
        [entireMapData appendBytes:&theVersionNumber length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig1 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig2 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig3 length:4];
        
        [entireMapData appendData:theLevelMapData];
        
        cameFromMarathonFormatedFile = NO;
    }
    
    return [entireMapData autorelease];*/
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    //theRawMapData = data;
    //theLevel = nil;
    
    //short version, dataVersion;
    BOOL loadedOk = NO;
    
    short theVersionNumber = currentVersionOfPfhorgeLevelData;
    short thePfhorgeDataSig1 = 26743;
    short thePfhorgeDataSig2 = 34521;
    long thePfhorgeDataSig3 = 42296737;
    
    short theVersionNumberFromData = 0;
    short thePfhorgeDataSig1FromData = 0;
    short thePfhorgeDataSig2FromData = 0;
    long thePfhorgeDataSig3FromData = 0;
    
   // NSRange firstOne = [aType rangeOfString:@"mmap"];
    
    [data getBytes:&theVersionNumberFromData range:NSMakeRange(0,2)];
    [data getBytes:&thePfhorgeDataSig1FromData range:NSMakeRange(2,2)];
    [data getBytes:&thePfhorgeDataSig2FromData range:NSMakeRange(4,2)];
    [data getBytes:&thePfhorgeDataSig3FromData range:NSMakeRange(6,4)];
     
     NSLog(@"loadDataRepresentation");
    
    //NSRange secondOne = [theRawString rangeOfString:@"map"];
    
    if (thePfhorgeDataSig1FromData != thePfhorgeDataSig1 ||
        thePfhorgeDataSig2FromData != thePfhorgeDataSig2 ||
        thePfhorgeDataSig3FromData != thePfhorgeDataSig3)
    {
        NSLog(@"Loading Alepha/Marathon Formated Map...");
        theRawMapData = data;
        theLevel = nil;
        
        if (theRawMapData != nil)
        {
            cameFromMarathonFormatedFile = YES;
            loadedOk = YES;
        }
    }
    /*else if (theVersionNumberFromData != theVersionNumber &&
        thePfhorgeDataSig1FromData == thePfhorgeDataSig1 &&
        thePfhorgeDataSig2FromData == thePfhorgeDataSig2 &&
        thePfhorgeDataSig3FromData == thePfhorgeDataSig3)
    {
        SEND_ERROR_MSG_TITLE(@"Can't Load This Version Of Pfhorge Map Data,\
                                Export It In Previous Version Then Open It Here.",
                             @"Can't Load Map");
        loadedOk = NO;
    }*/
    else if (/*theVersionNumberFromData == theVersionNumber &&*/
        thePfhorgeDataSig1FromData == thePfhorgeDataSig1 &&
        thePfhorgeDataSig2FromData == thePfhorgeDataSig2 &&
        thePfhorgeDataSig3FromData == thePfhorgeDataSig3)
    {
        NSLog(@"Loading Pfhorge Formated Map... ERROR, WRONG PLACE!!!");
        
        loadedOk = NO;
        cameFromMarathonFormatedFile = NO;
        theRawMapData = nil;
        
        SEND_ERROR_MSG_TITLE(@"Pfhorge formated map file loaded in wrong place! Change the file's extention to: .lev",
                             @"Change File's Extention");
        
        /*
        
        theLevel = [[NSUnarchiver unarchiveObjectWithData:
                        [data subdataWithRange:NSMakeRange(10 ,([data length] - 10))]] retain];
        if (theLevel != nil)
        {
            loadedOk = YES;
            cameFromMarathonFormatedFile = NO;
            NSLog(@"theLevel != nil...");
            [theLevel updateCounts];
        }*/
    }
    else
    {
        SEND_ERROR_MSG_TITLE(@"Can't Load File, Unknown Format.",
                             @"Can't Load File");
        loadedOk = NO;
    }
    
    NSLog(@"Returning from loadDataRepresentation...");
    
    return loadedOk;
}

// ***************************** Scripting Support Methods *****************************
#pragma mark -
#pragma mark ********* Scripting Support Methods *******
-(NSArray *)points { return [theLevel getThePoints]; }
-(NSArray *)lines { return [theLevel getTheLines]; }
-(NSArray *)objects { return [theLevel getTheMapObjects]; }
-(NSArray *)polygons { return [theLevel getThePolys]; }

- (id)handleFillWithLine:(NSScriptCommand *)command
{
    NSDictionary *args = [command evaluatedArguments];
    int lineNum = [[args objectForKey:@"linenum"] intValue];
    LEPolygon *theNewPoly;
    NSLog(@"handleFillWithLine");
    theNewPoly = [[[theLevel getTheLines] objectAtIndex:lineNum] getPolyFromMe];
    
    if (theNewPoly == nil)
    {
        SEND_ERROR_MSG(@"Sorry, but I could not fill a polygon with the line the apple script indicated (check the console)");
        return nil;
    }
    
    [theLevel addObjects:theNewPoly];
    
    return nil;
}

- (id)handleLineFromPointToPoint:(NSScriptCommand *)command
{
    NSDictionary *args = [command evaluatedArguments];
    int p1num = [[args objectForKey:@"pointone"] intValue];
    int p2num = [[args objectForKey:@"pointtwo"] intValue];
    NSArray *thePoints = [theLevel getThePoints];
    LEMapPoint *pointOne = [thePoints objectAtIndex:p1num];
    LEMapPoint *pointTwo = [thePoints objectAtIndex:p2num];
    LELine *theNewLine = [[LELine alloc] init];
    
    [theLevel addObjects:theNewLine];
    [theNewLine setMapPoint1:pointOne];
    [theNewLine setMapPoint2:pointTwo];
    
    [theNewLine release];
    
    return nil;
}

- (id)handleLineToNewPoint:(NSScriptCommand *)command
{
        // ask the command to evaluate its arguments
    NSDictionary *args = [command evaluatedArguments];
    NSDictionary *pointDef = [args objectForKey:@"plocation"];
        // if we don't have a file argument, we're doomed!
    // if (!file || [file isEqualToString:@""]) return [NSNumber numberWithBool:NO];
        // ask the Application delegate to do the work:
    // return [NSNumber numberWithBool:[[self delegate] application:self openFile:file]];
    
    NSArray *theKeys = [pointDef allKeys];
    
    int xLoc = 0;
    int yLoc = 0;
    
    LEMapPoint *theNewPoint;
    LEMapPoint *theExsistingPoint;
    LELine *theNewLine;
    
    int count = [theKeys count];
    int i;
    for (i = 0; i < count; i++)
    {
        NSNumber *theKeyNumber = [theKeys objectAtIndex:i];
        
        if ([theKeyNumber longValue] == 'Ppgx')
            xLoc = [[pointDef objectForKey:theKeyNumber] intValue];
        else if ([theKeyNumber longValue] == 'Ppgy')
            yLoc = [[pointDef objectForKey:theKeyNumber] intValue];
        else if ([theKeyNumber longValue] == 'usrf')
        {
            SEND_ERROR_MSG_TITLE(@"You use {x:(num), y:(num)} when useing lineToPoint where num can be from -32768 to 32768.",
                                 @"Apple Script Error");
            return nil;
        }
        else
        {
            long theKeyAsLong = [theKeyNumber longValue];
            char *theTagAsChar = (char *)&theKeyAsLong;
            NSString *theTagAsString = [NSString stringWithCString:theTagAsChar length:4];
            NSLog(@"Perculer key in arguments: %@", theTagAsString);
            NSLog(@"Here is the record description sent via apple script: %@", [args description]);
            SEND_ERROR_MSG_TITLE(@"You use {x:(num), y:(num)} when using lineToPoint where num can be from -32768 to 32768, but it sent perculer arguments, please e-mail the author your console messages from Pfhorge!",
                        @"Apple Script Error");
            return nil;
        }
    }
    
    theNewPoint = [[LEMapPoint alloc] initX:xLoc Y:yLoc];
    theExsistingPoint = [[theLevel getThePoints] lastObject];
    theNewLine = [[LELine alloc] init];
    
    NSLog(@"Called handleLineToNewPoint with new point location:  x:%d  y:%d", xLoc, yLoc);
    
    [theLevel addObjects:theNewLine];
    [theLevel addObjects:theNewPoint];
    [theNewLine setMapPoint1:theExsistingPoint];
    [theNewLine setMapPoint2:theNewPoint];
    
    [theNewLine release];
    [theNewPoint release];
    
    return nil;
}


- (void)setPoints:(NSArray *)thePoints
{
    // We won't allow wholesale setting of these subset keys.
    [NSException raise:NSOperationNotSupportedForKeyException format:@"Setting 'points' key is not supported."];
}

- (void)addInPoints:(LEMapPoint *)point
{
    NSLog(@"addInPoints Apple Script Command Acknowleged!");
    [theLevel addObjects:point];
}

- (void)insertInPoints:(LEMapPoint *)point atIndex:(unsigned)index {
    // MF:!!! This is not going to be ideal.  If we are being asked to, say, "make a new rectangle at after rectangle 2", we will be after rectangle 2, but we may be after some other stuff as well since we will be asked to insertInRectangles:atIndex:3...
    
    NSArray *thePoints = [self points];
    
    NSLog(@"insertInPoints Apple Script Command Acknowleged!");
    
    if (index == [thePoints count]) {
        [self addInPoints:point];
    }
    else
    {
        if (index < [thePoints count])
        {
            [self addInPoints:point/* atIndex:newIndex*/];
        }
        else
        {
            // Shouldn't happen.
            [NSException raise:NSRangeException format:@"Beyond bounds of the points array!"];
        }
    }
}

- (void)removeFromPointsAtIndex:(unsigned)index {
    NSLog(@"removeFromPointsAtIndex");
    /*NSArray *rects = [self rectangles];
    NSArray *graphics = [self graphics];
    int newIndex = [graphics indexOfObjectIdenticalTo:[rects objectAtIndex:index]];
    if (newIndex != NSNotFound) {
        [self removeGraphicAtIndex:newIndex];
    } else {
        // Shouldn't happen.
        [NSException raise:NSRangeException format:@"Could not find the given rectangle in the graphics."];
    }*/
}

- (void)replaceInPoints:(LEMapPoint *)graphic atIndex:(unsigned)index {
    NSLog(@"replaceInPoints");
   /* NSArray *rects = [self rectangles];
    NSArray *graphics = [self graphics];
    int newIndex = [graphics indexOfObjectIdenticalTo:[rects objectAtIndex:index]];
    if (newIndex != NSNotFound) {
        [self removeGraphicAtIndex:newIndex];
        [self insertGraphic:graphic atIndex:newIndex];
    } else {
        // Shouldn't happen.
        [NSException raise:NSRangeException format:@"Could not find the given rectangle in the graphics."];
    }*/
}

-(id)handleRedrawAndRecaculate:(NSScriptCommand *)command
{
    LEMapDraw *theMapViewDrawer = [theLevelDocumentWindowController levelDrawView];
    [theMapViewDrawer recaculateAndRedrawEverything];
    return nil;
}

@end
