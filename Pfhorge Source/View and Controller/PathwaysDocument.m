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

#import "PathwaysExchange.h"

#import "PathwaysDocument.h"
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

@implementation PathwaysDocument

/*- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple 	NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyLevel";
}*/

-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    cameFromMarathonFormatedFile = YES;
    
    return self;
}

+ (void)initialize
{
    [PhPrefsController sharedPrefController];
}

-(void)dealloc
{
    resources = nil;
    [pidMap release];
    pidMap = nil;
    
    [dpin128ResourceData release];
    dpin128ResourceData = nil;
    
    [super dealloc];
}



// ************************* Actions *************************
#pragma mark -
#pragma mark ********* Actions *********

- (IBAction)saveToPfhorgeFormat:(id)sender
{
    [self shouldExportToMarathonFile:NO];
    
    if ([self didIComeFromMarathonFormatedFile])
    {
        NSLog(@"YES == didIComeFromMarathonFormatedFile...");
        [self saveDocumentAs:self];
    }
    else
    {
        NSLog(@"NO == didIComeFromMarathonFormatedFile...");
        [self saveDocument:self];
    }
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
	attributes:@{NSFileHFSCreatorCode: @((OSType)0x32362EB0), // '26.∞'
				 NSFileHFSTypeCode: @((OSType)'sce2')
	}];
    
    [tempData release];
    
    return YES;
}

// *********************** Loading and Saving Levels ***********************
#pragma mark -
#pragma mark ********* Loading and Saving Levels *********

- (void)initallyLoadInTheDataNow
{
    PhProgress *progress = nil;//[PhProgress sharedPhProgress];
    
    // Add any code here that need to be executed once the windowController has loaded the document's window.
    NSLog(@"initallyLoadInTheDataNow");
    
    if (theLevel != nil)
    {
        return;
    }
    else if (theRawMapData != nil && theLevel == nil)
    {
        [progress setMinProgress:0.0];
        [progress setMaxProgress:10.0];
        [progress setProgressPostion:0.0];
        NSLog(@"Attempting To Load PID Level");
        [progress setStatusText:@"Loading PID Level, Please Wait..."];
        [progress setInformationalText:@"Loading PID Level, Please Wait..."];
        [progress showWindow:self];
        
        theMap = nil;
        
        //theMap = [[LEMapData alloc] initWithMapNSData:theRawMapData];
        //[comboLevelList addItemsWithObjectValues:[theMap levelNames]];
        //theLevel = [theMap getLevel:1];
        
        
        // ••• ••• ••• Load The Data Into A PathwaysExchange object... ••• ••• •••
        
        //pidMap = [[PathwaysExchange alloc] initWithData:theRawMapData];
        pidMap = [[PathwaysExchange alloc] initWithData:theRawMapData resourceData:dpin128ResourceData];
        theLevel = [[pidMap getPIDLevel:1] retain];
        
        [progress setStatusText:@"Sending PID Level Changed Notification..."];
        [progress increaseProgressBy:5.0];
        
        // Transfer Level Names
        //currentLevelNames = [[NSMutableArray alloc] init];
        
        //[currentLevelNames addObject:@"PID Level"];
        
        currentLevelNames = [[pidMap levelNames] mutableCopy];
        
        // *** *** ***
        
        [progress setStatusText:@"Done Loading PID Level!"];
        [progress increaseProgressBy:5.0];
        [progress orderOutWin:self];
        //[theLevel setLayerModeTo:nil];
        //[[theLevelDocumentWindowController levelDrawView] setNeedsDisplay:YES];
        
        //[theLevelDocumentWindowController mapLoaded];
        //[[NSNotificationCenter defaultCenter] postNotificationName:LELevelChangedNotification object:theLevel];
        [theLevel setLevelDocument:self];
        //[[theLevelDocumentWindowController levelDrawView] setTheLevel:theLevel];
        [theLevel setMyUndoManager:[self undoManager]];
        [theLevel setUpArrayPointersForEveryObject];
        [theLevel setupDefaultObjects];
    }
    else
    {
    }
    
    //[self tellDocWinControllerToUpdateLevelInfoString];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    PhProgress *progress = [PhProgress sharedPhProgress];
    [super windowControllerDidLoadNibSkip:aController];
    
    // Add any code here that need to be executed once the windowController has loaded the document's window.
    NSLog(@"windowControllerDidLoadNib");
    
    if (theLevel != nil)
    {
        //currentLevelNames = [[theMap levelNames] copy];
        [theLevel setLevelDocument:self];
        //currentLevelNames = [[NSMutableArray alloc] initWithCapacity:1];
        //[currentLevelNames addObject:[theLevel levelName]];
        
        //currentLevelNames = [[pidMap levelNames] retain];
        
        [[theLevelDocumentWindowController levelDrawView] setTheLevel:theLevel];
        [theLevelDocumentWindowController mapLoaded];
        [[NSNotificationCenter defaultCenter] postNotificationName:LELevelChangedNotification object:theLevel];
        
        [self tellDocWinControllerToUpdateLevelInfoString];
        [[theLevelDocumentWindowController levelDrawView] setNeedsDisplay:YES];
        
        return;
    }
    
    if (theRawMapData != nil && theLevel == nil)
    {
        [progress setMinProgress:0.0];
        [progress setMaxProgress:10.0];
        [progress setProgressPostion:0.0];
        NSLog(@"Attempting To Load PID Level");
        [progress setStatusText:@"Loading PID Level, Please Wait..."];
        [progress setInformationalText:@"Loading PID Level, Please Wait..."];
        [progress showWindow:self];
        
        theMap = nil;
        
        //theMap = [[LEMapData alloc] initWithMapNSData:theRawMapData];
        //[comboLevelList addItemsWithObjectValues:[theMap levelNames]];
        //theLevel = [theMap getLevel:1];
        
        pidMap = [[PathwaysExchange alloc] initWithData:theRawMapData];
        theLevel = [[pidMap getPIDLevel:1] retain];
        
        [theLevel setLevelDocument:self];
        [[theLevelDocumentWindowController levelDrawView] setTheLevel:theLevel];
        
        [progress setStatusText:@"Sending PID Level Changed Notification..."];
        [progress increaseProgressBy:5.0];
        
        // Transfer Level Names
        //currentLevelNames = [[NSMutableArray alloc] init];
        
        //[currentLevelNames addObject:@"PID Level"];
        
        currentLevelNames = [[pidMap levelNames] mutableCopy];
        
        // *** *** ***
        
        [theLevelDocumentWindowController mapLoaded];
        [[NSNotificationCenter defaultCenter] postNotificationName:LELevelChangedNotification object:theLevel];
        
        [progress setStatusText:@"Done Loading PID Level!"];
        [progress increaseProgressBy:5.0];
        [progress orderOutWin:self];
        //[theLevel setLayerModeTo:nil];
        [[theLevelDocumentWindowController levelDrawView] setNeedsDisplay:YES];
        
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
       
        [theLevel setLevelDocument:self];
        [theLevel setMyUndoManager:[self undoManager]];
        [theLevel setUpArrayPointersForEveryObject];
        [theLevel setupDefaultObjects];
        
        //[theLevelDocumentWindowController mapLoaded]; // Might want to use LELevelChangedNotification instead...
    }
    
    [self tellDocWinControllerToUpdateLevelInfoString];
    [self setFileType:@"pfhlev"];
}

- (void)loadLevel:(int)levelNumber //Starts at one, not zero... :)
{
   // PhProgress *progress = [PhProgress sharedPhProgress];
    if ( theRawMapData != nil)
    {
        if (pidMap == nil)
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
        
        // The pidMap object returns a autoreleased LELevel, so need to retain it...
        theLevel = [[pidMap getPIDLevel:levelNumber] retain];
        [[theLevelDocumentWindowController levelDrawView] setTheLevel:theLevel];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LELevelChangedNotification object:theLevel];

        [[theLevelDocumentWindowController levelDrawView] setNeedsDisplay:YES];
        
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

#if 0
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError * _Nullable *)outError
{
    //[self updateInternalData];
    
    
    
    NSString *pathToUse = [url.path copy];
    /*
    if (![[fullDocumentPath pathExtension] isEqualToString:@"pfhlev"])
    {
        [pathToUse release];
        pathToUse = [[fullDocumentPath stringByAppendingPathComponent:@"pfhlev"] copy];
    }
    */
    
    NSLog(@"writeToFile  for a Pathways (PID) map...  Path: %@", pathToUse);
    
    [[NSFileManager defaultManager] createFileAtPath:pathToUse
        contents:[self dataOfType:@"" error:NULL]
        attributes:nil];
    
    [pathToUse release];
    
    
    // [wad saveToFile:fullDocumentPath oldFile:fullOriginalDocumentPath];
    // [resources saveToFile:fullDocumentPath oldFile:fullOriginalDocumentPath];
    
    return YES;
}
#endif

-(NSDictionary<NSString *,id> *)fileAttributesToWriteToURL:(NSURL *)url ofType:(NSString *)documentTypeName forSaveOperation:(NSSaveOperationType)saveOperationType originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError * _Nullable *)outError
{
    NSMutableDictionary	*dict = [NSMutableDictionary dictionaryWithDictionary:
                            [super fileAttributesToWriteToURL:url ofType:documentTypeName forSaveOperation:saveOperationType originalContentsURL:absoluteOriginalContentsURL error:outError]];
	if ([documentTypeName isEqualToString:@"org.bungie.source.map"]) {
		[dict addEntriesFromDictionary:@{NSFileHFSCreatorCode: @((OSType)0x32362EB0), // '26.∞'
					 NSFileHFSTypeCode: @((OSType)'sce2')
		}];
	} else {
		[dict setObject:@((OSType)'PfhL') forKey:NSFileHFSTypeCode];
		[dict setObject:@((OSType)'PFrg') forKey:NSFileHFSCreatorCode];
	}

    return dict;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)type error:(NSError * _Nullable *)outError
{
    BOOL value = YES;
    BOOL isDir = NO;
    NSString *fileName = [url path];
    
    pathPathwaysApp = [fileName stringByDeletingLastPathComponent];
    
    if ([pathPathwaysApp length] > 1)
    {
        // No slash, need to prepend it...
        pathPathwaysApp = [[pathPathwaysApp stringByAppendingPathComponent:@"/Pathways Into Darkness"] retain];
    }
    else
    {
        // root path is a single slash, so don't need to prepend a slash...
        pathPathwaysApp = [[pathPathwaysApp stringByAppendingPathComponent:@"Pathways Into Darkness"] retain];
    }
    
    BOOL exsists = [[NSFileManager defaultManager] fileExistsAtPath:pathPathwaysApp isDirectory:&isDir];
    
    if ((exsists) && (!isDir))
    {
        // Data will be dallocated after fileResources gets released...
        ScenarioResources *fileResources = [[ScenarioResources alloc] initWithContentsOfFile:pathPathwaysApp];
        // Copy data (or we could just retain it, since it's immutable, which is waht the copy method
        //   probabaly does with NSData objects) so we will have it after fileResources gets released...
        dpin128ResourceData = [[[fileResources resourceOfType:@"dpin" index:128] data] copy];
        
        // Should be able to just release it now, but just in case..
        [fileResources autorelease];
        
        NSLog(@"Was Able To Load 'Pathways Into Darkness' dpin 128 resource...");
    }
    else
    {
        [pathPathwaysApp release];
        pathPathwaysApp = nil;
        dpin128ResourceData = nil;
        
        NSLog(@"Was NOT Able To Load 'Pathways Into Darkness' dpin 128 resource...");
    }
    
    [self readFromData:[[NSFileManager defaultManager] contentsAtPath:fileName] ofType:type error:outError];
    
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

- (NSData *)dataOfType:(NSString *)aType error:(NSError * _Nullable *)outError
{
    NSMutableData *entireMapData = [[NSMutableData alloc] init];
    
    shouldExportToMarathonFormat = NO;
    
    if (shouldExportToMarathonFormat == YES || [aType isEqualToString:@"org.bungie.source.map"])
    {
        [entireMapData setData:[LEMapData convertLevelToDataObject:theLevel]];
    }
    else
    {
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

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)aType error:(NSError * _Nullable *)outError
{
    BOOL loadedOk = NO;
     
     NSLog(@"loadDataRepresentation");
     
    NSLog(@"Loading Pathways Into Darkness Map...");
    theRawMapData = [data retain];
    theLevel = nil;
    
    cameFromMarathonFormatedFile = YES;
    
    [self initallyLoadInTheDataNow];
    
    NSLog(@"Returning from loadDataRepresentation...");
    
    return loadedOk;
}

@end
