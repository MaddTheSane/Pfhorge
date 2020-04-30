//
//  PhPfhorgeScenarioLevelDoc.m
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


#import "PhPfhorgeScenarioLevelDoc.h"
#import "PhPfhorgeSingleLevelDoc.h"
#import "LEExtras.h"
#import "LEMapData.h"
#import "ScenarioResources.h"
#import "Resource.h"

#import "PhProgress.h"

#import "LEMapData.h"

#import "PathwaysExchange.h"

NSString *PhScenarioDeallocatingNotification = @"PhScenarioDeallocatingNotification";
NSString *PhScenarioLevelNamesChangedNotification = @"PhScenarioLevelNamesChangedNotification";

@implementation PhPfhorgeScenarioLevelDoc

- (NSImage *)getPICTResourceIndex:(int)PICTIndex
{
    /*resource = [resources resourceOfType:@"PICT"
        index:CHAPTER_SCREEN_BASE + [levelPopUp indexOfSelectedItem]];*/
    
    BOOL isDir = NO;
    BOOL exsists = NO;
    NSString *fullImagePath;
    
    NSLog(@"getPICTResourceIndex in the scenerio document called...");
    
    fullImagePath  = [[[[self getFullPathForDirectory]
                            stringByAppendingString:@"Images/"]
                            stringByAppendingString:[[NSNumber numberWithInt:PICTIndex] stringValue]]
                                stringByAppendingString:@".pict"];
    
    exsists = [[NSFileManager defaultManager] fileExistsAtPath:fullImagePath isDirectory:&isDir];
    
    if (exsists && !isDir)
        return [[[NSImage alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:fullImagePath]] autorelease];
    else
    {
        NSLog(@"image not found at: %@", fullImagePath);
        return nil;//[[[NSImage alloc] initWithData:[resource data]] autorelease];
    }
}

-(id)init
{
    NSString *myFullFilePath;
    self = [super init];
    
    if (self == nil)
        return nil;
    
    myFullFilePath = [[self fileName] stringByDeletingLastPathComponent];
    
    if (![myFullFilePath isEqualToString:@"/"])
        myFullFilePath  = [[myFullFilePath stringByAppendingString:@"/"] retain];
    else
        [myFullFilePath retain];
    
    // May want the scenario data boject to get the path dynamicaly from me...
    
    //scenarioData = [[PhScenarioData alloc] initWithProjectDirectory:myFullFilePath];
    scenarioData = nil;
    
    [myFullFilePath release];
    
    return self;
}

- (void)dealloc
{
    NSLog(@"*** Scenario Dealloc Post Notification ***");
    [[NSNotificationCenter defaultCenter]
            postNotificationName:PhScenarioDeallocatingNotification
            object:self];
    
    [super dealloc];
}

- (void)openADocumentFile:(NSString *)fullPath
{
    NSLog(@"Attempting To Open: %@", fullPath);
    
    [[NSDocumentController sharedDocumentController]
            openDocumentWithContentsOfFile:fullPath
                                   display:YES];
    if ([[NSDocumentController sharedDocumentController] documentForFileName:fullPath] == nil)
        NSLog(@"NIL");
    [[[NSDocumentController sharedDocumentController] documentForFileName:fullPath] setScenarioDocument:self];
}

/// + 

- (void)reloadLevelTable:(id)sender
{
    [theScenarioDocumentWindowController reloadLevelTable:sender];
    
    [[NSNotificationCenter defaultCenter]
            postNotificationName:PhScenarioLevelNamesChangedNotification
            object:self];
}

- (IBAction)importMarathonMap:(id)sender
{
    NSArray	*fileTypes	= [NSArray arrayWithObject:NSFileTypeForHFSTypeCode('sce2')];
    NSOpenPanel	*op		= [NSOpenPanel openPanel];
    
    [op	setAllowsMultipleSelection:NO];
    [op setTitle:@"Import Marathon Wad"];
    [op setPrompt:@"Import"];
    
    [op beginSheetForDirectory:nil file:nil types:fileTypes
        modalForWindow:[theScenarioDocumentWindowController window] modalDelegate:self
        didEndSelector:@selector(importMapScriptDone:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)importPathwaysMap:(id)sender
{
    NSArray	*fileTypes	= [NSArray arrayWithObject:NSFileTypeForHFSTypeCode('maps')];
    NSOpenPanel	*op		= [NSOpenPanel openPanel];
    
    [op	setAllowsMultipleSelection:NO];
    [op setTitle:@"Import Pathways Map"];
    [op setPrompt:@"Import"];
    
    [op beginSheetForDirectory:nil file:nil types:fileTypes
        modalForWindow:[theScenarioDocumentWindowController window] modalDelegate:self
        didEndSelector:@selector(importPIDMapScriptDone:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)cut:(id)sender
{

}
- (IBAction)copy:(id)sender
{

}
- (IBAction)paste:(id)sender
{

}



- (void)importMapScriptDone:(NSOpenPanel *)sheet returnCode:(int)returnCode
    contextInfo:(void  *)contextInfo
{
    NSString	*fileName = nil;
    NSMutableArray *archivedLevels = nil;
    NSMutableArray *levelNames = [[NSMutableArray alloc] initWithCapacity:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imageDir = [[self getFullPathForDirectory] stringByAppendingString:@"Images/"];
    BOOL isDir = NO;
    
    BOOL exsists = NO;
    
    PhProgress *progress = [PhProgress sharedPhProgress];
    
    if (returnCode == NSOKButton)
    {
        ScenarioResources *maraResources;
        fileName = [[sheet filenames] objectAtIndex:0];
        
        [progress setMinProgress:0.0];
        [progress setMaxProgress:100.0];
        [progress setProgressPostion:0.0];
        [progress setStatusText:@"Importing Marathon Data..."];
        [progress setInformationalText:@"Loading Marathon Data Into Memory..."];
        [progress showWindow:self];
        
        maraResources = [[ScenarioResources alloc] initWithContentsOfFile:fileName];
        
        archivedLevels = [LEMapData 
            convertMarathonDataToArchived:[fileManager
                           contentsAtPath:fileName] 
                               levelNames:levelNames];
                               
        [progress setStatusText:@"Saving All The Levels..."];
        
        [self saveArrayOfNSDatas:archivedLevels
                   withFileNames:levelNames
                         baseDir:[self getFullPathForDirectory]];
                         
        [progress setStatusText:@"Adding Level Names To Scenario Document..."];
        
        [scenarioData addLevelNames:levelNames];
        
        [progress setStatusText:@"Extracting and Saving Resources..."];
        
        exsists = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
        
        if (exsists && !isDir)
        {
            SEND_ERROR_MSG_TITLE(@"File named 'Image' already exsists in scenario folder, can get images.",
                                 @"Can Create Images Folder");
            [maraResources release];
            [progress orderOutWin:self];
            return;
        }
        
        if (!exsists)
        {
            BOOL succsessfull = YES;
            succsessfull = [fileManager createDirectoryAtPath:[imageDir stringByDeletingPathExtension] attributes:nil];
            if (!succsessfull)
            {
                SEND_ERROR_MSG(@"Could not create images folder");
                [maraResources release];
                [progress orderOutWin:self];
                return;
            }
        }
        
        [maraResources saveResourcesOfType:@"PICT" to:imageDir extention:@".pict" progress:YES];
        [maraResources release];
        
        [progress increaseProgressBy:1.0];
        [progress setStatusText:@"Done Converting Level!"];
        [progress orderOutWin:self];
    }
    
    [self saveDocument:nil];
}


- (void)importPIDMapScriptDone:(NSOpenPanel *)sheet returnCode:(int)returnCode
    contextInfo:(void  *)contextInfo
{
    NSString		*fileName = nil;
    NSMutableArray 	*archivedLevels =[[NSMutableArray alloc] init];
    NSMutableArray 	*levelNames = [[NSMutableArray alloc] init];
    NSFileManager 	*fileManager = [NSFileManager defaultManager];
    //NSString *imageDir = [[self getFullPathForDirectory] stringByAppendingString:@"Images/"];
    
    PhProgress *progress = [PhProgress sharedPhProgress];
    
    if (returnCode == NSOKButton)
    {
        fileName = [[sheet filenames] objectAtIndex:0];
        
        [progress setMinProgress:0.0];
        [progress setMaxProgress:100.0];
        [progress setProgressPostion:0.0];
        [progress setStatusText:@"Importing Pathways Into Darkness Map..."];
        [progress setInformationalText:@"Importing Pathways Into Darkness Map..."];
        [progress showWindow:self];
        
        
        BOOL isDir = NO;
        
        NSString *pathPathwaysApp = [fileName stringByDeletingLastPathComponent];
        NSData *dpin128ResourceData = nil;
        
        if ([pathPathwaysApp length] > 1)
        {
            // No slash, need to prepend it...
            pathPathwaysApp = [[pathPathwaysApp stringByAppendingString:@"/Pathways Into Darkness"] retain];
        }
        else
        {
            // root path is a single slash, so don't need to prepend a slash...
            pathPathwaysApp = [[pathPathwaysApp stringByAppendingString:@"Pathways Into Darkness"] retain];
        }
        
        BOOL exsists = [fileManager fileExistsAtPath:pathPathwaysApp isDirectory:&isDir];
        
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
        
        
        [PathwaysExchange convertPIDMapToArchived:[fileManager
                                   contentsAtPath:fileName] 
                                           levels:archivedLevels
                                       levelNames:levelNames
                                     resourceData:dpin128ResourceData];
        
        // I don't need this any more, PathwaysExchange should have retained
        // it if it needed it keep it...
        [dpin128ResourceData release];
        
        [progress setStatusText:@"Saving All The Levels..."];
        
        [self saveArrayOfNSDatas:archivedLevels
                   withFileNames:levelNames
                         baseDir:[self getFullPathForDirectory]];
                         
        [progress setStatusText:@"Adding Level Names To Scenario Document..."];
        
        [scenarioData addLevelNames:levelNames];
        
        [progress increaseProgressBy:1.0];
        [progress setStatusText:@"Done Converting Level!"];
        [progress orderOutWin:self];
    }
    
    [self saveDocument:nil];
}


// ****************** Document Overidden Methods ******************
#pragma mark -
#pragma mark еееееееее Document Overidden Methods еееееееее

- (void)makeWindowControllers
{
    theScenarioDocumentWindowController = [[PhScenarioManagerController allocWithZone:[self zone]] init];
    [self addWindowController:theScenarioDocumentWindowController];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    if (scenarioData == nil)
    {
        scenarioData = [[PhScenarioData alloc] initWithProjectDirectory:@""];
        [self saveDocumentWithDelegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:NULL];
        NSLog(@"*** *** ***");
    }
    else
    {
        [scenarioData setProjectDirectory:[self getFullPathForDirectory]];
        [scenarioData setTheScenarioDocument:self];
    }
}

- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)contextInfo
{
    if (scenarioData != nil && didSave == NO) // Make Sure There Are No Sheets...
        [self close];
    else if (scenarioData != nil && didSave == YES) // New Doc Did Get Saved...
    {
        [scenarioData setProjectDirectory:[self getFullPathForDirectory]];
        [scenarioData setTheScenarioDocument:self];
        
        [theScenarioDocumentWindowController setupDataSourceForLevelTable];
    }
    else
        SEND_ERROR_MSG(@"scenarioData == nil, but why am I in the \"document:didSave:contextInfo:\"?");
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel
{
    /// NSLog(@"SAVING PANEL PERPARATION");
    return YES;
}

- (NSData *)dataRepresentationOfType:(NSString *)type {
    // Implement to provide a persistent data representation of your document OR remove this and implement the file-wrapper or file path based save methods.
    return [NSArchiver archivedDataWithRootObject:scenarioData];
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)type {
    // Implement to load a persistent data representation of your document OR remove this and implement the file-wrapper or file path based load methods.
    scenarioData = [[NSUnarchiver unarchiveObjectWithData:data] retain];
    
    return (scenarioData == nil) ? (NO) : (YES);
}

- (NSDictionary *)fileAttributesToWriteToFile:(NSString *)fullDocumentPath ofType:(NSString *)documentTypeName saveOperation:(NSSaveOperationType)saveOperationType
{
    return [super fileAttributesToWriteToFile:fullDocumentPath ofType:documentTypeName saveOperation:saveOperationType];
}

// ****************** Utilites ******************
#pragma mark -
#pragma mark еееееееее Utilites еееееееее
- (void)exportLevelToMarathonMap:(NSString *)fullPath
{
    NSString *fileName = [scenarioData getLevelPathForSelected];
    NSData *theFileData = [[NSFileManager defaultManager] contentsAtPath:fileName];
    NSMutableData *tempData; //= [[NSMutableData alloc] initWithCapacity:200000];
    LELevelData *theLevel;
    
    theLevel =  [[NSUnarchiver unarchiveObjectWithData:
                [theFileData subdataWithRange:NSMakeRange(10 ,([theFileData length] - 10))]] retain];
    
    tempData = [[LEMapData convertLevelToDataObject:theLevel] retain];
        
    [[NSFileManager defaultManager] createFileAtPath:fullPath
        contents:tempData
        attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                    
                    [NSNumber numberWithLong:'26.░'],
                    NSFileHFSCreatorCode,
                    
                    [NSNumber numberWithLong:'sce2'],
                    NSFileHFSTypeCode, nil]];
    
    [tempData release];
    [theLevel release];
}

- (void)rescanProjectDirectoryNow
{
    [scenarioData scanProjectDirectory];
    [self reloadLevelTable:nil];
}


- (NSString *)getFullPathForDirectory
{
    NSString *myFullFilePath = [[self fileName] stringByDeletingLastPathComponent];
    
    if (![myFullFilePath isEqualToString:@"/"])
        myFullFilePath  = [[myFullFilePath stringByAppendingString:@"/"] retain];
    else
        [myFullFilePath retain];
    
    // May want the scenario data object to get the path dynamicaly from me...
    
    return [myFullFilePath autorelease];
}

- (void)saveArrayOfNSDatas:(NSArray *)theDataObjs withFileNames:(NSArray *)theFileNames baseDir:(NSString *)basePath
{
    NSEnumerator *dataNumer, *fileNumer;
    NSData *fdata;
    NSString *fname;
    NSString *fpath;
    
    dataNumer = [theDataObjs objectEnumerator];
    fileNumer = [theFileNames objectEnumerator];
    while ((fdata = [dataNumer nextObject]) && 
           (fname = [fileNumer nextObject]))
    {
        fpath = [[basePath stringByAppendingString:fname] stringByAppendingString:@".lev"];
        
        [[NSFileManager defaultManager] createFileAtPath:fpath
                                                contents:fdata
                                              // May want to set creator code, etc...
                                              attributes:nil]; 
    }
    
}

- (void)saveMergedMapTo:(NSString *)fullPath
{
    NSData *mergedMap = [LEMapData mergeScenarioToMarathonMapFile:self];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *subpaths;
    NSEnumerator *numer;
    NSString *fileName;
    BOOL isDir = YES;
    BOOL exsists = NO;
    NSString *fullImageDirPath = nil;
    ScenarioResources *maraResources;
    
    [manager createFileAtPath:fullPath
        contents:mergedMap
        attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                    
                    [NSNumber numberWithLong:'26.░'],
                    NSFileHFSCreatorCode,
                    
                    [NSNumber numberWithLong:'sce2'],
                    NSFileHFSTypeCode, nil]];
    
    
    

    
    NSLog(@"Scaning Image Folder FOr Resources Now...");
    
    fullImageDirPath  = [[self getFullPathForDirectory] stringByAppendingString:@"Images/"];
    
    exsists = [manager fileExistsAtPath:fullImageDirPath isDirectory:&isDir];
    
    if (!exsists || !isDir)
        return;
    
    maraResources = [[ScenarioResources alloc] initWithContentsOfFile:fullPath];
    
    subpaths = [manager directoryContentsAtPath:fullImageDirPath];
    numer = [subpaths objectEnumerator];
    while (fileName = [numer nextObject])
    {
        NSString *fullResourcePath = [fullImageDirPath stringByAppendingString:fileName];
        
        if (IsPathDirectory(manager, fullResourcePath))
        {
            continue;
        }
        else if ([[fileName pathExtension] isEqualToString:@"pict"])
        {
            int thePictResourceNumber = [[fileName stringByDeletingPathExtension] intValue];
            Resource *theResource;
            
            if (thePictResourceNumber < 128)
                continue;
            
            theResource = [[Resource alloc] initWithID:thePictResourceNumber type:@"PICT" name:@""];
            [theResource setData:[manager contentsAtPath:fullResourcePath]];
            [maraResources addResource:theResource];
            [theResource release];
        }
    }
    
    [maraResources saveToFile:fullPath oldFile:nil];
    [maraResources release];
}

// ****************** Information ******************
#pragma mark -
#pragma mark еееееееее Information ееееееее

- (id)dataObjectForLevelNameTable
{
    return scenarioData;
}

- (NSArray *)getLevelNames
{
    return [scenarioData levelFileNames];
}

@end



