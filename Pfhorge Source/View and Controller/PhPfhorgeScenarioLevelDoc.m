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
#import <PfhorgeKit/PhPfhorgeSingleLevelDoc.h>
#import <PfhorgeKit/LEExtras.h>
#import <PfhorgeKit/LEMapData.h>
#import <PfhorgeKit/ScenarioResources.h>
#import <PfhorgeKit/Resource.h>
#import "Pfhorge-Swift.h"

#import "PhProgress.h"

#import "LEMapData.h"

#import "PathwaysExchange.h"

@implementation PhPfhorgeScenarioLevelDoc

- (NSImage *)getPICTResourceIndex:(ResID)PICTIndex
{
    /*resource = [resources resourceOfType:@"PICT"
        index:CHAPTER_SCREEN_BASE + [levelPopUp indexOfSelectedItem]];*/
    
    BOOL isDir = NO;
    BOOL exsists = NO;
    NSString *fullImagePath;
    
    NSLog(@"getPICTResourceIndex in the scenerio document called...");
    
    NSMutableArray *tmpImgPaths = [NSMutableArray arrayWithCapacity:5];
    for (NSString *extension in @[@"pict", @"png", @"jpeg", @"jpg", @"bmp"]) {
        fullImagePath  = [[[self fullPathForDirectory]
                                stringByAppendingPathComponent:@"Images/"]
                                stringByAppendingPathComponent:[[@(PICTIndex) stringValue]
                                    stringByAppendingPathExtension:extension]];
        
        [tmpImgPaths addObject:fullImagePath];
    }
    
    for (NSString *path in tmpImgPaths) {
        exsists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        if (exsists) {
            fullImagePath = path;
            break;
        }
    }
    
    if (exsists && !isDir) {
        return [[NSImage alloc] initWithContentsOfFile:fullImagePath];
    } else {
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
    
    myFullFilePath = [[self fileURL] URLByDeletingLastPathComponent].path;
    
    if (![myFullFilePath isEqualToString:@"/"])
        myFullFilePath  = [myFullFilePath stringByAppendingString:@"/"];
    
    // May want the scenario data boject to get the path dynamicaly from me...
    
    //scenarioData = [[PhScenarioData alloc] initWithProjectDirectory:myFullFilePath];
    scenarioData = nil;
    
    return self;
}

- (void)dealloc
{
    NSLog(@"*** Scenario Dealloc Post Notification ***");
    [[NSNotificationCenter defaultCenter]
     postNotificationName:PhScenarioDeallocatingNotification
     object:self];
}

- (void)openADocumentFile:(NSString *)fullPath
{
    NSLog(@"Attempting To Open: %@", fullPath);
    
	[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:fullPath] display:YES completionHandler:^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error) {
		if (!document) {
			NSLog(@"NIL, error: %@", error);
		}
		[(PhPfhorgeSingleLevelDoc*)document setScenarioDocument:self];
	}];
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
    NSArray	*fileTypes	= @[NSFileTypeForHFSTypeCode('sce2'), NSFileTypeForHFSTypeCode(0x736365B0) /*'sce∞'*/, @"org.bungie.source.map"];
    NSOpenPanel	*op		= [NSOpenPanel openPanel];
    
    [op	setAllowsMultipleSelection:NO];
    [op setTitle:@"Import Marathon Wad"];
    [op setPrompt:@"Import"];
    op.allowedFileTypes = fileTypes;

    [op beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSModalResponse result) {
        NSString    *fileName = nil;
        NSMutableArray *archivedLevels = nil;
        NSMutableArray *levelNames = [NSMutableArray arrayWithCapacity:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *imageDir = [[self fullPathForDirectory] stringByAppendingPathComponent:@"Images"];
        BOOL isDir = NO;
        
        BOOL exsists = NO;
        
        PhProgress *progress = [PhProgress sharedPhProgress];
        
        if (result == NSModalResponseOK) {
            ScenarioResources *maraResources;
            NSURL *fileURL = op.URL;
            fileName = fileURL.path;
            
            [progress setMinProgress:0.0];
            [progress setMaxProgress:100.0];
            [progress setProgressPostion:0.0];
            [progress setStatusText:@"Importing Marathon Data…"];
            [progress setInformationalText:@"Loading Marathon Data Into Memory…"];
            [progress showWindow:self];
            
            maraResources = [[ScenarioResources alloc] initWithContentsOfFile:fileName];
            
            archivedLevels = [LEMapData
                convertMarathonDataToArchived:[NSData dataWithContentsOfURL:fileURL]
                                   levelNames:levelNames error:NULL];
                                   
            [progress setStatusText:@"Saving All The Levels…"];
            
            [self saveArrayOfNSDatas:archivedLevels
                       withFileNames:levelNames
                             baseDir:[self fullPathForDirectory]];
                             
            [progress setStatusText:@"Adding Level Names To Scenario Document…"];
            
            [scenarioData addLevelNames:levelNames];
            
            [progress setStatusText:@"Extracting and Saving Resources…"];
            
            exsists = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
            
            if (exsists && !isDir) {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Can Create Images Folder";
                alert.informativeText = @"File named 'Image' already exsists in scenario folder, can get images.";
                alert.alertStyle = NSAlertStyleCritical;
                [alert runModal];
                [progress orderOutWin:self];
                return;
            }
            
            if (!exsists) {
                BOOL succsessfull = YES;
                succsessfull = [fileManager createDirectoryAtPath:[imageDir stringByDeletingPathExtension] withIntermediateDirectories:YES attributes:nil error:NULL];
                if (!succsessfull) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    alert.messageText = @"Generic Error";
                    alert.informativeText = @"Could not create images folder";
                    alert.alertStyle = NSAlertStyleCritical;
                    [alert runModal];
                    [progress orderOutWin:self];
                    return;
                }
            }
            
            [maraResources iterateResourcesOfType:@"PICT" progress:YES block:^(Resource * resource, NSData *dat, PhProgress *progress) {
                PhPictConversionBinaryFormat format;
                NSError *err=nil;
                NSData *convDat = [PhPictConversion convertPICTfromData:dat returnedFormat:&format error:&err];
                NSString *savePath;
                if (!convDat) {
                    // TODO: store errors for later review by the user
                    NSLog(@"%@", err);
                    [progress setInformationalText:[NSString stringWithFormat:@"Saving ‘%@’ Resource# %@…", @"PICT", [resource resID], nil]];
                    NSString * pictPath = [imageDir stringByAppendingPathComponent:[[[resource resID] stringValue] stringByAppendingPathExtension:@"pict"]];
                    
                    [fileManager createFileAtPath:pictPath
                                         contents:dat
                                       attributes:@{NSFileHFSTypeCode: @((OSType)'PICT'),
                                                    NSFileHFSCreatorCode: @((OSType)'ttxt')
                                       }];
                    return;
                }
                
                switch (format) {
                    case PhPictConversionBinaryFormatJPEG:
                        savePath = [imageDir stringByAppendingPathComponent:[[[resource resID] stringValue] stringByAppendingPathExtension:@"jpeg"]];
                        break;
                        
                    case PhPictConversionBinaryFormatBitmap:
                        savePath = [imageDir stringByAppendingPathComponent:[[[resource resID] stringValue] stringByAppendingPathExtension:@"bmp"]];
                        break;
                        
                    case PhPictConversionBinaryFormatPNG:
                        savePath = [imageDir stringByAppendingPathComponent:[[[resource resID] stringValue] stringByAppendingPathExtension:@"png"]];
                        break;

                    default:
                        savePath = nil;
                        break;
                }
                
                [progress setInformationalText:[NSString stringWithFormat:@"Saving converted ‘%@’ Resource# %@…", @"PICT", [resource resID]]];
                BOOL success = [convDat writeToFile:savePath options:NSDataWritingAtomic error:&err];
                if (!success) {
                    // TODO: store errors for later review by the user
                    NSLog(@"%@", err);
                }
            }];
            
            [progress increaseProgressBy:1.0];
            [progress setStatusText:@"Done Converting Level!"];
            [progress orderOutWin:self];
        }
        
        [self saveDocument:nil];
    }];

}

- (IBAction)importPathwaysMap:(id)sender
{
    NSArray	*fileTypes	= @[NSFileTypeForHFSTypeCode('maps')];
    NSOpenPanel	*op		= [NSOpenPanel openPanel];
    
    [op	setAllowsMultipleSelection:NO];
    [op setTitle:@"Import Pathways Map"];
    [op setPrompt:@"Import"];
    op.allowedFileTypes = fileTypes;
    
    [op beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSModalResponse result) {
        NSString        *fileName = nil;
        NSMutableArray  *archivedLevels = [[NSMutableArray alloc] init];
        NSMutableArray  *levelNames = [[NSMutableArray alloc] init];
        NSFileManager   *fileManager = [NSFileManager defaultManager];
        //NSString *imageDir = [[self fullPathForDirectory] stringByAppendingString:@"Images/"];
        
        PhProgress *progress = [PhProgress sharedPhProgress];
        
        if (result == NSModalResponseOK) {
            fileName = op.URL.path;
            
            [progress setMinProgress:0.0];
            [progress setMaxProgress:100.0];
            [progress setProgressPostion:0.0];
            [progress setStatusText:@"Importing Pathways Into Darkness Map…"];
            [progress setInformationalText:@"Importing Pathways Into Darkness Map…"];
            [progress showWindow:self];
            
            
            BOOL isDir = NO;
            
            NSString *pathPathwaysApp = [fileName stringByDeletingLastPathComponent];
            NSData *dpin128ResourceData = nil;
            
            pathPathwaysApp = [pathPathwaysApp stringByAppendingPathComponent:@"Pathways Into Darkness"];
            
            BOOL exsists = [fileManager fileExistsAtPath:pathPathwaysApp isDirectory:&isDir];
            
            if ((exsists) && (!isDir)) {
                // Data will be dallocated after fileResources gets released...
                ScenarioResources *fileResources = [[ScenarioResources alloc] initWithContentsOfFile:pathPathwaysApp];
                // Copy data (or we could just retain it, since it's immutable, which is waht the copy method
                //   probabaly does with NSData objects) so we will have it after fileResources gets released...
                dpin128ResourceData = [[[fileResources resourceOfType:@"dpin" index:128] data] copy];
                
                // Should be able to just release it now, but just in case..
                pathPathwaysApp = nil;

                NSLog(@"Was Able To Load 'Pathways Into Darkness' dpin 128 resource...");
            } else {
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
            
            [progress setStatusText:@"Saving All The Levels…"];
            
            [self saveArrayOfNSDatas:archivedLevels
                       withFileNames:levelNames
                             baseDir:[self fullPathForDirectory]];
                             
            [progress setStatusText:@"Adding Level Names To Scenario Document…"];
            
            [self->scenarioData addLevelNames:levelNames];
            
            [progress increaseProgressBy:1.0];
            [progress setStatusText:@"Done Converting Level!"];
            [progress orderOutWin:self];
        }
        
        [self saveDocument:nil];
    }];
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


// ****************** Document Overidden Methods ******************
#pragma mark -
#pragma mark ••••••••• Document Overidden Methods •••••••••

- (void)makeWindowControllers
{
    theScenarioDocumentWindowController = [[PhScenarioManagerController alloc] init];
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
        [scenarioData setProjectDirectory:[self fullPathForDirectory]];
        [scenarioData setTheScenarioDocument:self];
    }
}

- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)contextInfo
{
    if (scenarioData != nil && didSave == NO) // Make Sure There Are No Sheets...
        [self close];
    else if (scenarioData != nil && didSave == YES) // New Doc Did Get Saved...
    {
        [scenarioData setProjectDirectory:[self fullPathForDirectory]];
        [scenarioData setTheScenarioDocument:self];
        
        [theScenarioDocumentWindowController setupDataSourceForLevelTable];
    }
    else {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Generic Error";
        alert.informativeText = @"scenarioData == nil, but why am I in the \"document:didSave:contextInfo:\"?";
        alert.alertStyle = NSAlertStyleCritical;
        [alert runModal];
    }
}

- (BOOL)prepareSavePanel:(NSSavePanel *)savePanel
{
    /// NSLog(@"SAVING PANEL PERPARATION");
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError * _Nullable *)outError {
    return [NSKeyedArchiver archivedDataWithRootObject:scenarioData requiringSecureCoding:YES error:outError];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError * _Nullable *)outError {
    scenarioData = [NSKeyedUnarchiver unarchivedObjectOfClass:[PhScenarioData class] fromData:data error:outError];
	if (!scenarioData) {
		scenarioData = [NSUnarchiver unarchiveObjectWithData:data];
	}
    
    return (scenarioData == nil) ? (NO) : (YES);
}

/*
- (NSDictionary *)fileAttributesToWriteToFile:(NSString *)fullDocumentPath ofType:(NSString *)documentTypeName saveOperation:(NSSaveOperationType)saveOperationType
{
    return [super fileAttributesToWriteToFile:fullDocumentPath ofType:documentTypeName saveOperation:saveOperationType];
}
*/
// ****************** Utilites ******************
#pragma mark -
#pragma mark ••••••••• Utilites •••••••••
- (void)exportLevelToMarathonMap:(NSString *)fullPath
{
    NSString *fileName = [scenarioData getLevelPathForSelected];
    NSData *theFileData = [[NSFileManager defaultManager] contentsAtPath:fileName];
    NSMutableData *tempData; //= [[NSMutableData alloc] initWithCapacity:200000];
    
    LELevelData *theLevel =  [NSKeyedUnarchiver unarchivedObjectOfClass:
                              [LELevelData class] fromData:
                              [theFileData subdataWithRange:NSMakeRange(10, ([theFileData length] - 10))] error:NULL];
    
    tempData = [LEMapData convertLevelToDataObject:theLevel error:NULL];
        
    [[NSFileManager defaultManager] createFileAtPath:fullPath
	  contents:tempData
	attributes:@{NSFileHFSCreatorCode: @((OSType)0x32362EB0), // '26.∞'
				 NSFileHFSTypeCode: @((OSType)'sce2')
	}];
}

- (BOOL)exportLevelToMarathonMap:(NSString *)fullPath error:(NSError **)outError
{
    NSString *fileName = [scenarioData getLevelPathForSelected];
    NSData *theFileData = [NSData dataWithContentsOfFile:fileName options:0 error:outError];
    if (!theFileData) {
        return NO;
    }
    LELevelData *theLevel =  [NSKeyedUnarchiver unarchivedObjectOfClass:
                              [LELevelData class] fromData:
                              [theFileData subdataWithRange:NSMakeRange(10, ([theFileData length] - 10))] error:outError];
    
    if (theLevel == nil) {
        return NO;
    }
    
    NSData *tempData = [LEMapData convertLevelToDataObject:theLevel error:outError];
    
    if (tempData == nil) {
        return NO;
    }

    BOOL success = [tempData writeToFile:fullPath options:0 error:outError];
    if (!success) {
        return NO;
    }
    
    NSError *tmpErr;
    success = [[NSFileManager defaultManager] setAttributes:
     @{NSFileHFSCreatorCode: @((OSType)0x32362EB0), // '26.∞'
       NSFileHFSTypeCode: @((OSType)'sce2')
    } ofItemAtPath:fullPath error:&tmpErr];
    if (!success) {
        //Just write the error out into the log
        NSLog(@"Unable to set file attributes: %@", tmpErr);
    }
    
    return YES;
}

- (void)rescanProjectDirectoryNow
{
    [scenarioData scanProjectDirectory];
    [self reloadLevelTable:nil];
}

- (NSURL *)fullPathURLForDirectory
{
	return [[self fileURL] URLByDeletingLastPathComponent];
}
- (NSString *)fullPathForDirectory
{
    return self.fullPathURLForDirectory.path;
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
        fpath = [[basePath stringByAppendingPathComponent:fname] stringByAppendingPathExtension:@"pfhlev"];
        
        [[NSFileManager defaultManager] createFileAtPath:fpath
                                                contents:fdata
                                              // May want to set creator code, etc...
                                              attributes:@{NSFileHFSTypeCode: @((OSType)'PfhL'),
                                                           NSFileHFSCreatorCode: @((OSType)'PFrg')}];
    }
    
}

- (void)saveMergedMapTo:(NSString *)fullPath
{
    NSData *mergedMap = [LEMapData mergeScenarioToMarathonMapFile:self error:NULL];
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
				   attributes:@{NSFileHFSCreatorCode: @((OSType)0x32362EB0), // '26.∞'
								NSFileHFSTypeCode: @((OSType)'sce2')
				   }];
    
    NSLog(@"Scaning Images folder for resources now...");
    
    fullImageDirPath  = [[self fullPathForDirectory] stringByAppendingPathComponent:@"Images/"];
    
    exsists = [manager fileExistsAtPath:fullImageDirPath isDirectory:&isDir];
    
    if (!exsists || !isDir)
        return;
    
    maraResources = [[ScenarioResources alloc] initWithContentsOfFile:fullPath];
    
    subpaths = [manager contentsOfDirectoryAtPath:fullImageDirPath error:NULL];
    numer = [subpaths objectEnumerator];
    while (fileName = [numer nextObject])
    {
        NSString *fullResourcePath = [fullImageDirPath stringByAppendingPathComponent:fileName];
        
        if (IsPathDirectory(manager, fullResourcePath)) {
            continue;
        } else if ([[fileName pathExtension] isEqualToString:@"pict"]) {
            int thePictResourceNumber = [[fileName stringByDeletingPathExtension] intValue];
            Resource *theResource;
            
            if (thePictResourceNumber < 128)
                continue;
            
            theResource = [[Resource alloc] initWithID:thePictResourceNumber type:@"PICT" name:@""];
            [theResource setData:[manager contentsAtPath:fullResourcePath]];
            [maraResources addResource:theResource];
        } else if ([[fileName pathExtension] isEqualToString:@"png"]) {
            int thePictResourceNumber = [[fileName stringByDeletingPathExtension] intValue];
            Resource *theResource;
            
            if (thePictResourceNumber < 128)
                continue;
            
            NSError *err;
            NSData *pictData = [PhPictConversion convertFileAtURLToPICT:[NSURL fileURLWithPath:fullResourcePath] error:&err];
            if (!pictData) {
                NSLog(@"%@", err);
                continue;
            }
            theResource = [[Resource alloc] initWithID:thePictResourceNumber type:@"PICT" name:@""];
            [theResource setData:pictData];
            [maraResources addResource:theResource];
        } else if ([[fileName pathExtension] isEqualToString:@"jpeg"] || [[fileName pathExtension] isEqualToString:@"jpg"]) {
            int thePictResourceNumber = [[fileName stringByDeletingPathExtension] intValue];
            Resource *theResource;
            
            if (thePictResourceNumber < 128)
                continue;
            
            NSError *err;
            NSData *pictData = [PhPictConversion convertFileAtURLToPICT:[NSURL fileURLWithPath:fullResourcePath] error:&err];
            if (!pictData) {
                NSLog(@"%@", err);
                continue;
            }
            theResource = [[Resource alloc] initWithID:thePictResourceNumber type:@"PICT" name:@""];
            [theResource setData:pictData];
            [maraResources addResource:theResource];
        } else if ([[fileName pathExtension] isEqualToString:@"bmp"]) {
            int thePictResourceNumber = [[fileName stringByDeletingPathExtension] intValue];
            Resource *theResource;
            
            if (thePictResourceNumber < 128)
                continue;
            
            NSError *err;
            NSData *pictData = [PhPictConversion convertFileAtURLToPICT:[NSURL fileURLWithPath:fullResourcePath] error:&err];
            if (!pictData) {
                NSLog(@"%@", err);
                continue;
            }
            theResource = [[Resource alloc] initWithID:thePictResourceNumber type:@"PICT" name:@""];
            [theResource setData:pictData];
            [maraResources addResource:theResource];
        }
    }
    
    [maraResources saveToFile:fullPath oldFile:nil];
}

- (BOOL)saveMergedMapToPath:(NSString *)fullPath error:(NSError**)outError
{
    NSData *mergedMap = [LEMapData mergeScenarioToMarathonMapFile:self error:outError];
    if (!mergedMap) {
        return NO;
    }
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
                   attributes:@{NSFileHFSCreatorCode: @((OSType)0x32362EB0), // '26.∞'
                                NSFileHFSTypeCode: @((OSType)'sce2')
                   }];
    
    NSLog(@"Scaning Images folder for resources now...");
    
    fullImageDirPath  = [[self fullPathForDirectory] stringByAppendingPathComponent:@"Images/"];
    
    exsists = [manager fileExistsAtPath:fullImageDirPath isDirectory:&isDir];
    
    if (!exsists || !isDir) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSFilePathErrorKey: fullImageDirPath}];
        }
        return NO;
    }
    
    maraResources = [[ScenarioResources alloc] initWithContentsOfFile:fullPath];
    
    subpaths = [manager contentsOfDirectoryAtPath:fullImageDirPath error:NULL];
    numer = [subpaths objectEnumerator];
    while (fileName = [numer nextObject]) {
        NSString *fullResourcePath = [fullImageDirPath stringByAppendingPathComponent:fileName];
        
        if (IsPathDirectory(manager, fullResourcePath)) {
            continue;
        } else if ([[fileName pathExtension] isEqualToString:@"pict"]) {
            int thePictResourceNumber = [[fileName stringByDeletingPathExtension] intValue];
            Resource *theResource;
            
            if (thePictResourceNumber < 128) {
                continue;
            }
            
            theResource = [[Resource alloc] initWithID:thePictResourceNumber type:@"PICT" name:@""];
            [theResource setData:[manager contentsAtPath:fullResourcePath]];
            [maraResources addResource:theResource];
        } else if ([[fileName pathExtension] isEqualToString:@"png"]) {
            int thePictResourceNumber = [[fileName stringByDeletingPathExtension] intValue];
            Resource *theResource;
            
            if (thePictResourceNumber < 128) {
                continue;
            }
            if ([maraResources resourceOfType:@"PICT" index:thePictResourceNumber load:NO] != nil) {
                continue;
            }
            
            NSError *err;
            NSData *pictData = [PhPictConversion convertFileAtURLToPICT:[NSURL fileURLWithPath:fullResourcePath] error:&err];
            if (!pictData) {
                NSLog(@"%@", err);
                continue;
            }
            theResource = [[Resource alloc] initWithID:thePictResourceNumber type:@"PICT" name:@""];
            [theResource setData:pictData];
            [maraResources addResource:theResource];
        } else if ([[fileName pathExtension] isEqualToString:@"jpg"] || [[fileName pathExtension] isEqualToString:@"jpeg"]) {
            int thePictResourceNumber = [[fileName stringByDeletingPathExtension] intValue];
            Resource *theResource;
            
            if (thePictResourceNumber < 128) {
                continue;
            }
            if ([maraResources resourceOfType:@"PICT" index:thePictResourceNumber load:NO] != nil) {
                continue;
            }
            
            NSError *err;
            NSData *pictData = [PhPictConversion convertFileAtURLToPICT:[NSURL fileURLWithPath:fullResourcePath] error:&err];
            if (!pictData) {
                NSLog(@"%@", err);
                continue;
            }
            theResource = [[Resource alloc] initWithID:thePictResourceNumber type:@"PICT" name:@""];
            [theResource setData:pictData];
            [maraResources addResource:theResource];
        } else if ([[fileName pathExtension] isEqualToString:@"bmp"]) {
            int thePictResourceNumber = [[fileName stringByDeletingPathExtension] intValue];
            Resource *theResource;
            
            if (thePictResourceNumber < 128) {
                continue;
            }
            if ([maraResources resourceOfType:@"PICT" index:thePictResourceNumber load:NO] != nil) {
                continue;
            }
            
            NSError *err;
            NSData *pictData = [PhPictConversion convertFileAtURLToPICT:[NSURL fileURLWithPath:fullResourcePath] error:&err];
            if (!pictData) {
                NSLog(@"%@", err);
                continue;
            }
            theResource = [[Resource alloc] initWithID:thePictResourceNumber type:@"PICT" name:@""];
            [theResource setData:pictData];
            [maraResources addResource:theResource];
        }
    }
    
    [maraResources saveToFile:fullPath oldFile:nil];

    return YES;
}

// ****************** Information ******************
#pragma mark -
#pragma mark ••••••••• Information ••••••••

- (id)dataObjectForLevelNameTable
{
    return scenarioData;
}

- (NSArray *)levelNames
{
    return [scenarioData levelFileNames];
}

@end
