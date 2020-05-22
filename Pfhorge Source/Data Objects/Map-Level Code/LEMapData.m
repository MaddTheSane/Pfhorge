//
//  LEMapData.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 10 2001.
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

#import "LEMapData.h"
#import "LELevelData.h"
#import "LELevelData-private.h"

// 
#import "LEMapPoint.h"
#import "LELine.h"
#import "LEPolygon.h"
#import "LEMapObject.h"
#import "LESide.h"
#import "PhLight.h"
#import "PhAnnotationNote.h"
#import "PhMedia.h"
#import "PhAmbientSound.h"
#import "PhRandomSound.h"
#import "PhItemPlacement.h"
#import "PhPlatform.h"

#import "LEMapStuffParent.h"
#import "LEExtras.h"
#import "PhProgress.h"

#import "Terminal.h"

#import "PhPfhorgeScenarioLevelDoc.h"
#import "PhScenarioData.h"

#import "LEExtras.h"

#import "crc.h"

BOOL setupPointerArraysDurringLoading = YES;

//#undef useDebugingLogs


// •••••••••••••••••••••• LEMapData implementation •••••••••••••••••••••••••••
#pragma mark -
#pragma mark ••••••••• LEMapData implementation •••••••••

@implementation LEMapData

// ***************************** Class Convience Functions *****************************
#pragma mark -
#pragma mark ********* Class Convience Functions *********
+ (NSMutableData *)convertLevelToDataObject:(LELevelData *)theLevel
{
    LEMapData *theTmpMarathonMap = [[LEMapData alloc] init];
    NSMutableData *theMaraAlephFormatedData = [theTmpMarathonMap saveLevelAndGetMapNSData:theLevel levelToSaveIn:1];
    return theMaraAlephFormatedData;
}

+ (NSMutableData *)mergeScenarioToMarathonMapFile:(PhPfhorgeScenarioLevelDoc *)theScenario
{
    LEMapData *theTmpMarathonMap = [[LEMapData alloc] init];
    NSMutableData *theMaraAlephFormatedData = [theTmpMarathonMap mergeScenario:theScenario];
    return theMaraAlephFormatedData;
}

+ (NSMutableArray *)convertMarathonDataToArchived:(NSData *)theData levelNames:(NSMutableArray *)theLevelNamesEXP
{
    // NOTE: Check for (theTmpMarathonMap == nil)
    LEMapData *theTmpMarathonMap = [[LEMapData alloc] initWithMapNSData:theData];
    long numberOfLevels = [theTmpMarathonMap numberOfLevels];
    NSMutableArray *theLevelNames = [theTmpMarathonMap levelNames];
    int i = 0;
    
    short theVersionNumber = currentVersionOfPfhorgeLevelData;
    theVersionNumber = CFSwapInt16HostToBig(theVersionNumber);
    short thePfhorgeDataSig1 = 26743;
    thePfhorgeDataSig1 = CFSwapInt16HostToBig(thePfhorgeDataSig1);
    unsigned short thePfhorgeDataSig2 = 34521;
    thePfhorgeDataSig2 = CFSwapInt16HostToBig(thePfhorgeDataSig2);
    int thePfhorgeDataSig3 = 42296737;
    thePfhorgeDataSig3 = CFSwapInt32HostToBig(thePfhorgeDataSig3);
    
    NSMutableArray *theArchivedLevels = [[NSMutableArray alloc] initWithCapacity:numberOfLevels];
    
    PhProgress *progress = [PhProgress sharedPhProgress];
    
    [progress setMaxProgress:(numberOfLevels+1)];
    [progress setProgressPostion:0.0];
    
    for (i = 1; i <= numberOfLevels; i++) {
        LELevelData *currentLevel;
        NSData *theLevelMapData = nil;
        NSMutableData *entireMapData = [[NSMutableData alloc] initWithCapacity:12];
        
        [progress setStatusText:[NSString stringWithFormat:@"Converting \"%@\"…", [theLevelNames objectAtIndex:(i - 1)], nil]];
        
        [progress setSecondMinProgress:0.0];
        [progress setSecondMaxProgress:100.0];
        [progress setSecondProgressPostion:0.0];
        [progress setSecondStatusText:@"Loading Level, Please Wait…"];
        
        [progress setUseSecondBarOnly:YES];
        currentLevel = [theTmpMarathonMap getLevel:i log:NO];
        [progress setUseSecondBarOnly:NO];
        if (currentLevel == nil) {
            SEND_ERROR_MSG_TITLE(@"Could not convert one of the levels…",
                                 @"Converting Error");
            continue;
        }
        
        [progress setSecondStatusText:@"Archiving Level Into Binary Data…"];
        [progress increaseSecondProgressBy:5.0];
        
        theLevelMapData = [NSKeyedArchiver archivedDataWithRootObject:currentLevel];
        
        [progress setSecondStatusText:@"Saving Level…"];
        [progress increaseSecondProgressBy:5.0];
        
        [entireMapData appendBytes:&theVersionNumber length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig1 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig2 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig3 length:4];
        
        [entireMapData appendData:theLevelMapData];
        
        [theArchivedLevels addObject:entireMapData];
        [theLevelNamesEXP addObject:[theLevelNames objectAtIndex:(i - 1)]];
        
        [progress increaseProgressBy:1.0];
    }
    
    return theArchivedLevels;
}

// ***************************** init/dealloc methods *****************************
#pragma mark -
#pragma mark ********* init/dealloc methods *********
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    //[self initHeaders];
    return self;
}

- (id)initWithData:(NSData *)theMapp
{
    self = [self initWithMapNSData:theMapp];
    return self;
}

- (id)initWithMapNSData:(NSData *)theMapp
{
    self = [super init];
    
    if ( theMapp != nil ) {
        mapData = theMapp;
    } else {
        //numberOfLevels = 909;
        return nil;
    }
    
    [self initHeaders];
    return self;
}

// ***************************** Advanced Data Processing Functions *****************************
#pragma mark -
#pragma mark ********* Advanced Data Processing Functions *********
- (NSMutableData *)mergeScenario:(PhPfhorgeScenarioLevelDoc *)scenarioDocument
{
    PhScenarioData *scenarioData = [scenarioDocument dataObjectForLevelNameTable];
    int levelCount = [scenarioData levelCount]; // getLevelPathForLevel:(int)number
    LELevelData *theLevel = nil;
    int i = 0;
    
    NSMutableData *mainHeaderData = [[NSMutableData alloc] initWithCapacity:0];
    NSMutableData *levelData = [[NSMutableData alloc] initWithCapacity:0];
    NSMutableData *levelHeaderData = [[NSMutableData alloc] initWithCapacity:0];
    
    
    ///   mapDataToSave
    
    for (i = 0; i < levelCount; i++) {
        NSString *fileName = [scenarioData getLevelPathForLevel:i];
        NSData *theFileData = [[NSFileManager defaultManager] contentsAtPath:fileName];
        NSMutableData *tempData = [[NSMutableData alloc] initWithCapacity:200000];
        
        theLevel =	[NSKeyedUnarchiver unarchiveObjectWithData:
                     [theFileData subdataWithRange:NSMakeRange(10 ,([theFileData length] - 10))]];
        
        mapDataToSave = tempData;
        [self exportLevelDataToMarathonFormat:theLevel];
        
        mapDataToSave = levelHeaderData;
        [self saveLevelHeaders:theLevel
              usingMapDataSize:[tempData length]
                 usingLocation:([levelData length] + 128)
                 forLevelIndex:i];
        
        [levelData appendData:tempData];
    }
    
    mapDataToSave = mainHeaderData;
    [self saveMainMapHeaderForLevels:levelCount usingMapDataSize:[levelData length]];
    
    mapDataToSave = nil;
    
    [mainHeaderData appendData:levelData];
    [mainHeaderData appendData:levelHeaderData];
    
#ifdef useDebugingLogs
    NSLog(@"Returning Merged Map File");
#endif
    unsigned char *buffer = [mainHeaderData mutableBytes];
    long theLength = [mainHeaderData length];
    unsigned long theChecksum = calculate_data_crc(buffer, theLength);
    // at 68 for 4 bytes...
#ifdef useDebugingLogs
    NSLog(@"Checksum Im Merge: %d", theChecksum);
#endif
    NSRange checksumRange = {68, 4};
    [mainHeaderData replaceBytesInRange:checksumRange withBytes:&theChecksum];
    
    return mainHeaderData;
}

- (void)exportLevelDataToMarathonFormat:(LELevelData *)level
{
    //int levelToSaveIn = 1;
    
    //   Get the points into this level... ('PNTS')
    //[self saveTag:'PNTS' theLevelNumber:levelToSaveIn theLevelData:level];
    [self savePointsForLevel:level];
    
    //   Get the lines into this level... ('LINS')
    //[self saveTag:'LINS' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveLinesForLevel:level];
    
    //   Get the polys into this level... ('POLY')
    //[self saveTag:'POLY' theLevelNumber:levelToSaveIn theLevelData:level];
    [self savePolygonsForLevel:level];
    
    //   Get the objects into this level... ('OBJS')
    //[self saveTag:'OBJS' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveObjectsForLevel:level];
    
    //   Get the sides into this level... ('SIDS')
    //[self saveTag:'SIDS' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveSidesForLevel:level];
    
    //   Get the lights into this level... ('LITE')
    //[self saveTag:'LITE' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveLightsForLevel:level];
    
    //   Get the annotations (notes) into this level... ('NOTE')
    //[self saveTag:'NOTE' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveNotesForLevel:level];
    
    //   Get the liquids (media) into this level... ('medi')
    //[self saveTag:'medi' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveMediasForLevel:level];
    
    //   Get the ambient sounds (like the wind) into this level... ('ambi')
    //[self saveTag:'ambi' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveAmbientSoundsForLevel:level];
    
    // *** New ***
    
    //   Get the platforms (like the wind) into this level... ('plat')
    //[self saveTag:'plat' theLevelNumber:levelToSaveIn theLevelData:level];
    [self savePlatformsForLevel:level];
    
    //   Get the item placment entrys (like the wind) into this level... ('plac')
    //[self saveTag:'plac' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveItemPlacementForLevel:level];
    
    //   Get the random sounds (like driping sounds) into this level... ('bonk')
    //[self saveTag:'bonk' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveRandomSoundsForLevel:level];
    
    //   Get the terminals into this level... ('term')
    //[self saveTag:'term' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveTerminalDataForLevel:level];
    
    // *** End New ***
    
    [self saveBasicLevelInfo:level];
}



- (NSMutableData *)saveLevelAndGetMapNSData:(LELevelData *)level levelToSaveIn:(short)levelToSaveIn
{
    NSInteger projectedLevelByteCount = [self getByteCountForLevel:level];
    long levelLength;
    NSMutableData *levelData;
    NSMutableData *levelHeaderData;
    NSMutableData *mapHeaderData;
    NSMutableData *entireMapData;
    
#ifdef useDebugingLogs
    NSLog(@"save projectedLevelByteCount: %d", projectedLevelByteCount);
#endif
    mapDataToSave = [[NSMutableData alloc] initWithCapacity:MAX(projectedLevelByteCount, 500 * 1000)];
    
    //   -(void)saveTag:(long)theTag theLevelNumber:(short)levelNumber theLevelData:(LELevelData *)level
    
#ifdef useDebugingLogs
    NSLog(@"*Begining Phase 1 loading process into level %d from file...*", levelToSaveIn);
#endif
    
    //   Get the points into this level... ('PNTS')
#ifdef useDebugingLogs
    NSLog(@"*Saving points from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'PNTS' theLevelNumber:levelToSaveIn theLevelData:level];
    [self savePointsForLevel:level];
    
    //   Get the lines into this level... ('LINS')
#ifdef useDebugingLogs
    NSLog(@"*Saving lines from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'LINS' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveLinesForLevel:level];
    
    //   Get the polys into this level... ('POLY')
#ifdef useDebugingLogs
    NSLog(@"*Saving poly's from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'POLY' theLevelNumber:levelToSaveIn theLevelData:level];
    [self savePolygonsForLevel:level];
    
    //   Get the objects into this level... ('OBJS')
#ifdef useDebugingLogs
    NSLog(@"*Saving objects from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'OBJS' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveObjectsForLevel:level];
    
    //   Get the sides into this level... ('SIDS')
#ifdef useDebugingLogs
    NSLog(@"*Saving sides from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'SIDS' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveSidesForLevel:level];
    
    //   Get the lights into this level... ('LITE')
#ifdef useDebugingLogs
    NSLog(@"*Saving lights from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'LITE' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveLightsForLevel:level];
    
    //   Get the annotations (notes) into this level... ('NOTE')
    //NSLog(@"*Saving annotations from file into level %d*", levelToSaveIn);
    //[self saveTag:'NOTE' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveNotesForLevel:level];
    
    //   Get the liquids (media) into this level... ('medi')
#ifdef useDebugingLogs
    NSLog(@"*Saving liquids from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'medi' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveMediasForLevel:level];
    
    //   Get the ambient sounds (like the wind) into this level... ('ambi')
#ifdef useDebugingLogs
    NSLog(@"*Saving ambient sounds from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'ambi' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveAmbientSoundsForLevel:level];
    
    // *** New ***
    
    //   Get the platforms (like the wind) into this level... ('plat')
#ifdef useDebugingLogs
    NSLog(@"*Saving platforms from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'plat' theLevelNumber:levelToSaveIn theLevelData:level];
    [self savePlatformsForLevel:level];
    
    //   Get the item placment entrys (like the wind) into this level... ('plac')
#ifdef useDebugingLogs
    NSLog(@"*Saving item placment data from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'plac' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveItemPlacementForLevel:level];
    
    //   Get the random sounds (like driping sounds) into this level... ('bonk')
#ifdef useDebugingLogs
    NSLog(@"*Saving random sounds from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'bonk' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveRandomSoundsForLevel:level];
    
    //   Get the terminals into this level... ('bonk')
#ifdef useDebugingLogs
    NSLog(@"*Saving terminals from file into level %d*", levelToSaveIn);
#endif
    //[self saveTag:'term' theLevelNumber:levelToSaveIn theLevelData:level];
    [self saveTerminalDataForLevel:level];
    
    // *** End New ***
    
    [self saveBasicLevelInfo:level];
    
    levelLength = [mapDataToSave length];
    
    levelData = mapDataToSave;
    mapDataToSave = [[NSMutableData alloc] initWithCapacity:128];
    
    [self saveMainMapHeaderForLevels:1 usingMapDataSize:levelLength];
    mapHeaderData = mapDataToSave;
    
    mapDataToSave = [[NSMutableData alloc] initWithCapacity:10];
    [self saveLevelHeaders:level usingMapDataSize:levelLength usingLocation:128 forLevelIndex:0];
    levelHeaderData = mapDataToSave;
    
    mapDataToSave = nil;
    
#ifdef useDebugingLogs
    NSLog(@" * The level header length after saving level into it:   %d", [levelHeaderData length]);
    NSLog(@" * The map header length after saving level into it:     %d", [mapHeaderData length]);
    NSLog(@" * The level data length after saving level into it:     %d", levelLength);
#endif
    entireMapData = [[NSMutableData alloc] initWithCapacity:(500 * 1000)];
    
    [entireMapData appendData:mapHeaderData];
    [entireMapData appendData:levelData];
    [entireMapData appendData:levelHeaderData];
    
    mapHeaderData = nil;
    levelData = nil;
    levelHeaderData = nil;
    
#ifdef useDebugingLogs
    NSLog(@"|*| Entire level data length after saving level into it:   %d", [entireMapData length]);
#endif
    
    
    unsigned char *buffer = [entireMapData mutableBytes];
    long theLength = [entireMapData length];
    unsigned long theChecksum = calculate_data_crc(buffer, theLength);
    // at 68 for 4 bytes...
#ifdef useDebugingLogs
    NSLog(@"Checksum In Single Level: %d", theChecksum);
#endif
    NSRange checksumRange = {68, 4};
    [entireMapData replaceBytesInRange:checksumRange withBytes:&theChecksum];
    
    return entireMapData;
}

- (LELevelData *)getLevel:(short)levelToGet
{
    return [self getLevel:levelToGet log:YES];
}

#define NSLog1(i) if (NSLogTheInfo == YES) { NSLog(i); }
#define NSLogs(i, a) if (NSLogTheInfo == YES) { NSLog(i, a); }

- (LELevelData *)getLevel:(short)levelToGet log:(BOOL)NSLogTheInfo
{
    //to keep track of the level data...
    LELevelData *theLevel;
    // I use this at the end to test geting the first polygon...
    //NSMutableArray *test;
    PhProgress *progress = [PhProgress sharedPhProgress];
    //NSEnumerator *numer;
    //id curObj;
    //int i;
    
    BOOL logInfo = YES;
    
    //Make a level object to put all this stuff into...
#ifdef useDebugingLogs
    NSLogs(@"getLevel -> *Allocating and Initating the level data file for level %d...*", levelToGet);
#endif
    theLevel = [[LELevelData alloc] init];
    
    [self preAllocateArraysForLevel:theLevel forLevelNumber:levelToGet];
    
    //Update the counts on all the stuff :)
    [theLevel updateCounts];
    
    // *********** Setup Master Array Pointers ***********
    if (logInfo == YES) {
        [progress setStatusText:@"Setting Level Pointers..."];
        [progress increaseProgressBy:5.0];
    }
    
   /*
     //set the pointers for the point objects...
    [LEMapPoint setTheMapLinesST:[theLevel getTheLines]];
    [LEMapPoint setTheMapObjectsST:[theLevel theMapObjects]];
    [LEMapPoint setTheMapPointsST:[theLevel getThePoints]];
    [LEMapPoint setTheMapPolysST:[theLevel getThePolys]];
   
    //set the pointers for the line objects...
    [LELine setTheMapLinesST:[theLevel getTheLines]];
    [LELine setTheMapObjectsST:[theLevel theMapObjects]];
    [LELine setTheMapPointsST:[theLevel getThePoints]];
    [LELine setTheMapPolysST:[theLevel getThePolys]];
    [LELine setTheMapSidesST:[theLevel sides]];
    
    //Set the pointers for the poly objects...
    [LEPolygon setTheMapLinesST:[theLevel getTheLines]];
    [LEPolygon setTheMapObjectsST:[theLevel theMapObjects]];
    [LEPolygon setTheMapPointsST:[theLevel getThePoints]];
    [LEPolygon setTheMapPolysST:[theLevel getThePolys]];
    [LEPolygon setTheMapLightsST:[theLevel getLights]];
    
    //Sides
    [LESide setTheMapLightsST:[theLevel getLights]];
    
    //Objects
    [LEMapObject setTheMapPolysST:[theLevel getThePolys]];
    */
    
    [theLevel setEnvironmentCode:environment_code[levelToGet - 1]];
    [theLevel setPhysicsModel:physics_model[levelToGet - 1]];
    [theLevel setSongIndex:song_index[levelToGet - 1]];
    [theLevel setMissionFlags:mission_flags[levelToGet - 1]];
    [theLevel setEnvironmentFlags:environment_flags[levelToGet - 1]];
    
    
    /*if (setupPointerArraysDurringLoading)
    {
        NSArray *points = [theLevel getThePoints];
        NSArray *lines = [theLevel getTheLines];
        NSArray *polygons = [theLevel getThePolys];
        NSArray *mapObjects = [theLevel theMapObjects];
        NSArray *sides = [theLevel sides];
        NSArray *lights = [theLevel getLights];
        NSArray *notes = [theLevel notes];
        NSArray *media = [theLevel getMedia];
        NSArray *ambientSounds = [theLevel ambientSounds];
        NSArray *randomSounds = [theLevel randomSounds];
        NSArray *itemPlacment = [theLevel getItemPlacement];
        NSArray *platforms = [theLevel getPlatforms];
        
        for(i = 0; i < 12; i++)
            {
            switch (i)
            {
                case 0:
                    //NSLog(@"PPP");
                    numer = [points objectEnumerator];
                    break;
                case 1:
                    numer = [lines objectEnumerator];
                    break;
                case 2:
                    numer = [polygons objectEnumerator];
                    break;
                case 3:
                    numer = [mapObjects objectEnumerator];
                    break;
                case 4:
                    numer = [sides objectEnumerator];
                    break;
                case 5:
                    numer = [lights objectEnumerator];
                    break;
                case 6:
                    numer = [notes objectEnumerator];
                    break;
                case 7:
                    numer = [media objectEnumerator];
                    break;
                case 8:
                    numer = [ambientSounds objectEnumerator];
                    break;
                case 9:
                    numer = [randomSounds objectEnumerator];
                    break;
                case 10:
                    numer = [itemPlacment objectEnumerator];
                    break;
                case 11:
                    numer = [platforms objectEnumerator];
                    break;
                default:
                    break;
            }
            
            if ((i > 11) || (i < 0))
                break;
            
            while (curObj = [numer nextObject])
            {
                [curObj setTheMapLinesST:lines];
                [curObj setTheMapObjectsST:mapObjects];
                [curObj setTheMapPointsST:points];
                [curObj setTheMapPolysST:polygons];
                [curObj setTheMapLightsST:lights];
                [curObj setTheMapSidesST:sides];
                [curObj setTheAnnotationsST:notes];
                [curObj setTheMediaST:media];
                [curObj setTheAmbientSoundsST:ambientSounds];
                [curObj setTheRandomSoundsST:randomSounds];
                [curObj setTheMapItemPlacmentST:itemPlacment];
                [curObj setTheMapPlatformsST:platforms];
                
                [curObj setEverythingLoadedST:YES];
            }
        } // END for(i = 0; i < 12; i++)
    } // END (setupPointerArraysDurringLoading)*/
    
    
    //Tell them everything is loaded...
    /*
    [LEMapPoint setEverythingLoadedST:YES];
    [LELine setEverythingLoadedST:YES];
    [LEPolygon setEverythingLoadedST:YES];
    [LEMapObject setEverythingLoadedST:YES];
    */
    /*	Tell them to get the objects from
     *  the corasponding index numbers...
     */
     
    // *********** END Setup Master Array Pointers ***********
    
#ifdef useDebugingLogs
    NSLogs(@"*Begining Phase 1 loading process for level %d from file...*", levelToGet);
#endif
    
    alreadyGaveBoundingError = NO;
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Terminals…"];
        [progress increaseProgressBy:4.0];
    }
    //   Get the random sounds (like driping sounds) for this level... ('bonk')
#ifdef useDebugingLogs
    NSLogs(@"*Loading terminals from file for level %d*", levelToGet);
#endif
    [self getTag:'term' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Points…"];
        [progress increaseProgressBy:5.0];
    }
    
    //   Get the points for this level... ('PNTS')
#ifdef useDebugingLogs
    NSLogs(@"*Loading points from file for level %d*", levelToGet);
#endif
    [self getTag:'PNTS' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Lines…"];
        [progress increaseProgressBy:5.0];
    }
    //   Get the lines for this level... ('LINS')
#ifdef useDebugingLogs
    NSLogs(@"*Loading lines from file for level %d*", levelToGet);
#endif
    [self getTag:'LINS' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Polygons…"];
        [progress increaseProgressBy:5.0];
    }
    //   Get the polys for this level... ('POLY')
#ifdef useDebugingLogs
    NSLogs(@"*Loading poly's from file for level %d*", levelToGet);
#endif
    [self getTag:'POLY' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Objects…"];
        [progress increaseProgressBy:5.0];
    }
    //   Get the objects for this level... ('OBJS')
#ifdef useDebugingLogs
    NSLogs(@"*Loading objects from file for level %d*", levelToGet);
#endif
    [self getTag:'OBJS' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Sides…"];
        [progress increaseProgressBy:5.0];
    }
    //   Get the sides for this level... ('SIDS')
#ifdef useDebugingLogs
    NSLogs(@"*Loading sides from file for level %d*", levelToGet);
#endif
    [self getTag:'SIDS' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Lights…"];
        [progress increaseProgressBy:5.0];
    }
    //   Get the lights for this level... ('LITE')
#ifdef useDebugingLogs
    NSLogs(@"*Loading lights from file for level %d*", levelToGet);
#endif
    [self getTag:'LITE' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Annotations…"];
        [progress increaseProgressBy:5.0];
    }
    //   Get the annotations (notes) for this level... ('NOTE')
#ifdef useDebugingLogs
    NSLogs(@"*Loading annotations from file for level %d*", levelToGet);
#endif
    [self getTag:'NOTE' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Liquids…"];
        [progress increaseProgressBy:5.0];
    }
    //   Get the liquids (media) for this level... ('medi')
#ifdef useDebugingLogs
    NSLogs(@"*Loading liquids from file for level %d*", levelToGet);
#endif
    [self getTag:'medi' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Ambient Sounds…"];
        [progress increaseProgressBy:4.0];
    }
    //   Get the ambient sounds (like the wind) for this level... ('ambi')
#ifdef useDebugingLogs
    NSLogs(@"*Loading ambient sounds from file for level %d*", levelToGet);
#endif
    [self getTag:'ambi' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    // *** New ***
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Platforms…"];
        [progress increaseProgressBy:4.0];
    }
    //   Get the platforms (like the wind) for this level... ('plat')
#ifdef useDebugingLogs
    NSLogs(@"*Loading platforms from file for level %d*", levelToGet);
#endif
    [self getTag:'plat' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Item Placement Entries…"];
        [progress increaseProgressBy:4.0];
    }
    //   Get the item placment entrys (like the wind) for this level... ('plac')
#ifdef useDebugingLogs
    NSLogs(@"*Loading item placment data from file for level %d*", levelToGet);
#endif
    [self getTag:'plac' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES) {
        [progress setStatusText:@"Loading Random Sounds…"];
        [progress increaseProgressBy:4.0];
    }
    //   Get the random sounds (like driping sounds) for this level... ('bonk')
#ifdef useDebugingLogs
    NSLogs(@"*Loading random sounds from file for level %d*", levelToGet);
#endif
    [self getTag:'bonk' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    // *** End New ***
    
#ifdef useDebugingLogs
    NSLogs(@"*Done loading level %d from the file!*", levelToGet);
    NSLog1(@"*Transfering Level Info (Minf) data in map object to level object...*");
#endif
    
    if (logInfo == YES) {
        [progress setStatusText:@"Geting Level Information…"];
        [progress increaseProgressBy:5.0];
    }
    
    // The following just transfers the address to a pointer, but
    // you might want to actully copy the data over, or work
    // with the retain messages, because when this object (LEMapData)
    // gets deallocated, it may dealocate the level name which
    // the theLevel (LELevelData) has a pointer to...
    [theLevel setLevelName:[levelNames objectAtIndex:(levelToGet - 1)]];
    
    [theLevel setEntryPointFlags:entry_point_flags[levelToGet - 1]];
#ifdef useDebugingLogs
    NSLogs(@"The Levels Entry Point Flag Value: %d", entry_point_flags[levelToGet - 1]);
    
    NSLogs(@"*Phase 1 Loading Completed For Level %d!*", levelToGet);
    NSLogs(@"*Begining Phase 2 Loading For Level %d...*", levelToGet);
#endif
    
    
    if (logInfo == YES) {
        [progress setStatusText:@"Setting Object Pointers From Array Using Index Numbers…"];
        [progress increaseProgressBy:3.0];
    }
    
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getTheLines]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel theMapObjects]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getThePoints]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getThePolys]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel sides]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getLights]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel notes]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getMedia]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getAmbientSounds]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getRandomSounds]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getItemPlacement]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getPlatforms]];
    
    /*numer = [[theLevel getThePolys] objectEnumerator];
    while (curObj = [numer nextObject])
    {
   	if (![[[theLevel getThePolys] objectAtIndex:272] isPolygonConcave])
            NSLog(@"Poly 272 is not concave!");
        else
            NSLog(@"Poly 272 is concave!");
    }*/
   
    
    /*NSLog(@"*********************************");
       	if (![[[theLevel getThePolys] objectAtIndex:273] isPolygonConcave])
            NSLog(@"Poly 273 is not concave!");
        else
            NSLog(@"Poly 273 is concave!");
    NSLog(@"*********************************");*/
    
    
    // Test each polygon for concavness...

    if (logInfo == YES) {
        [progress setStatusText:@"Testing Every Polygon For Concavness…"];
        [progress increaseProgressBy:5.0];
    }
    //[self performSelector:@selector(isPolygonConcave) withEachObjectInArray:[theLevel getThePolys]];
    
#ifdef useDebugingLogs
    NSLogs(@"*Phase 2 Loading Completed For Level %d!*", levelToGet);
    NSLogs(@"*Done Loading Level %d!*", levelToGet);
    
    NSLog1(@"Doing some pre-caculations..");
    NSLog1(@"Seting up layers for the level..");
#endif
    
    if (logInfo == YES)
        [progress setStatusText:@"Seting up default layers…"];
    
    // This function Sets Up The Initall Layers
    // Ethier From Loading Them From The Level
    // Data File, or if those aren't avaliable
    // (currently no layers are saved, but
    //   when they start saving with the
    //   level, this function will check this)
    // it uses the default layer settings.
    [theLevel setupLayers];
    
    if (logInfo == YES)
        [progress increaseProgressBy:8.0];
    
#ifdef useDebugingLogs
    NSLog1(@"Compiling And Caching List Of Custom Names In Level...");
#endif
    
    if (logInfo == YES) {
        [progress setStatusText:@"Compiling And Caching List Of Custom Names In Level…"];
        [progress increaseProgressBy:3.0];
    }
    
    [theLevel compileAndSetNameArraysFromLevel];
    
    /*
    NSLog(@"*Doing vertex count for polygon 273 test...*");
    test = [theLevel getThePolys];
    if ([test count] > 2)
    {
        NSLog(@"*TEST:(Number Should Be greater then 2 but less then 9) Vertex count of poly 273: %d*",
        [[test objectAtIndex:273] getTheVertexCount]);
    }
    */
#ifdef useDebugingLogs
    NSLogs(@"*Returning 'LELevelData theLevel' for level: %d*", levelToGet);
#endif
    
    if (logInfo == YES) {
        [progress setStatusText:@"Returning Level To Map Document Controller…"];
        [progress increaseProgressBy:1.0];
    }
    
    //Return the level, with all of its data, etc...
    return theLevel;
}

- (NSInteger)getByteCountForLevel:(LELevelData *)level
{
    NSInteger pointsByteCount = ([[level points] count]) * 4; // 16
    NSInteger linesByteCount = ([[level lines] count]) * 32; // 32
    NSInteger polygonsByteCount = ([[level polygons] count]) * 128; // 128
    NSInteger mapObjectsByteCount = ([[level theMapObjects] count]) * 16; // 16
    NSInteger sidesByteCount = ([[level sides] count]) * 64; // 64
    NSInteger lightsByteCount = ([[level lights] count]) * 100; // 100
    //int notesByteCount = ([[level notes] count]) * 72; // 72
    NSInteger mediaByteCount = ([[level media] count]) * 32; // 32
    NSInteger ambientSoundsByteCount = ([[level ambientSounds] count]) * 16; // 16
    NSInteger randomSoundsByteCount = ([[level randomSounds] count]) * 32; // 32
    NSInteger itemPlacmentByteCount = ([[level itemPlacement] count]) * 12; // 12
    NSInteger platformsByteCount = ([[level platforms] count]) * 32; // 32
    
    NSInteger byteCount = pointsByteCount + linesByteCount + polygonsByteCount +
                    mapObjectsByteCount + sidesByteCount + lightsByteCount +
                    mediaByteCount + ambientSoundsByteCount + randomSoundsByteCount +
                    itemPlacmentByteCount + platformsByteCount;
    
    return byteCount;
}

- (void)preAllocateArraysForLevel:(LELevelData *)level forLevelNumber:(int)theLevel
{
/*
    int pointsByteCount = ([[level getThePoints] count]) * 4; // 16 or 4
    int linesByteCount = ([[level getTheLines] count]) * 32; // 32
    int polygonsByteCount = ([[level getThePolys] count]) * 128; // 128
    int mapObjectsByteCount = ([[level theMapObjects] count]) * 16; // 16
    int sidesByteCount = ([[level sides] count]) * 64; // 64
    int lightsByteCount = ([[level getLights] count]) * 100; // 100
    int notesByteCount = ([[level notes] count]) * 72; // 72
    int mediaByteCount = ([[level getMedia] count]) * 32; // 32
    int ambientSoundsByteCount = ([[level getAmbientSounds] count]) * 16; // 16
    int randomSoundsByteCount = ([[level randomSounds] count]) * 32; // 32
    int itemPlacmentByteCount = ([[level itemPlacement] count]) * 12; // 12
    int platformsByteCount = ([[level getPlatforms] count]) * 32; // 32
  */
  
    BOOL foundTheTag;
    long this_offset;
    //NSMutableArray *theDataToReturn = nil;
    //    NSString *theTagAsString;
    //
    //    theTagAsString = [[NSString alloc] init];
    
    //Set the cursor to the first byte of the level
    theCursor = myLevelHeaders[theLevel-1].offsetToStart;
    
    //Set it so that it uses current cursor location and
    //does not try to use this_offset...
    this_offset = -1;
    foundTheTag = NO;
    
    while (myLevelHeaders[theLevel - 1].length > (this_offset - myLevelHeaders[theLevel - 1].offsetToStart)) {
        int next_offset, length, offset;
        OSType tag;
        NSMutableArray *theArray = nil;
        int amountOfObjects = 0;
        Class theClass = nil;
        
        if (this_offset != -1)
            theCursor = this_offset;
        else
            this_offset = theCursor;
        
        tag = [self getLong];
        next_offset = [self getLong];
        length = [self getLong];
        offset = [self getLong];
        
        foundTheTag = NO;
        
        switch (tag) {
            case 'PNTS':
                theArray = [level getThePoints];
                amountOfObjects = length / 4;
                theClass = [LEMapPoint class];
                foundTheTag = YES;
                break;
            case 'EPNT':
                theArray = [level getThePoints];
                amountOfObjects = length / 16;
                theClass = [LEMapPoint class];
                foundTheTag = YES;
                break;
            case 'LINS':
                theArray = [level getTheLines];
                amountOfObjects = length / 32;
                theClass = [LELine class];
                foundTheTag = YES;
                break;
            case 'POLY':
                theArray = [level getThePolys];
                amountOfObjects = length / 128;
                theClass = [LEPolygon class];
                foundTheTag = YES;
                break;
            case 'OBJS':
                theArray = [level getTheMapObjects];
                amountOfObjects = length / 16;
                theClass = [LEMapObject class];
                foundTheTag = YES;
                break;
            case 'SIDS':
                theArray = [level getSides];
                amountOfObjects = length / 64;
                theClass = [LESide class];
                foundTheTag = YES;
                break;
                
            case 'LITE':
                theArray = [level getLights];
                amountOfObjects = length / 100;
                theClass = [PhLight class];
                foundTheTag = YES;
                break;
                
            case 'NOTE':
                theArray = [level getNotes];
                amountOfObjects = length / 72;
                theClass = [PhAnnotationNote class];
                foundTheTag = YES;
                break;
                
            case 'medi':
                theArray = [level getMedia];
                amountOfObjects = length / 32;
                theClass = [PhMedia class];
                foundTheTag = YES;
                break;
                
            case 'ambi':
                theArray = [level getAmbientSounds];
                amountOfObjects = length / 16;
                theClass = [PhAmbientSound class];
                foundTheTag = YES;
                break;
                
            case 'plat': // also 'PLAT' ??? diffrent platform tag???
                theArray = [level getPlatforms];
                amountOfObjects = length / 32;
                theClass = [PhPlatform class];
                foundTheTag = YES;
                break;
            case 'PLAT': // also 'PLAT' ??? diffrent platform tag???
                theArray = [level getPlatforms];
                amountOfObjects = length / 140;
                theClass = [PhPlatform class];
                foundTheTag = YES;
                break;
                
            case 'plac':
                theArray = [level getItemPlacement];
                amountOfObjects = length / 12;
                theClass = [PhItemPlacement class];
                foundTheTag = YES;
                break;
                
            case 'bonk':
                theArray = [level getRandomSounds];
                amountOfObjects = length / 32;
                theClass = [PhRandomSound class];
                foundTheTag = YES;
                break;
                
            case 'term':
                foundTheTag = NO;
                break;
                
            default:
                NSLog(@"   PreAllocation Process Detected Unknown Tag: %@",
                      CFBridgingRelease(UTCreateStringForOSType(tag)));
            case 'Minf':
                if (next_offset == 0 /* && !foundTheTag */) {
#ifdef useDebugingLogs
                    NSLog(@"   PreAllocation Completed...");
#endif
                    //[theDataToReturn release];
                    return;
                }
                this_offset = myLevelHeaders[theLevel-1].offsetToStart + next_offset;
                continue;
                
        } //End switch (theTag)
        
        if (foundTheTag) {
            int i;
            //NSString *theTmpTagString = CFBridgingRelease(UTCreateStringForOSType(tag));
            [theArray removeAllObjects];
            
#ifdef useDebugingLogs
            NSLog(@"   PreAllocating %d objects for tag '%@'", amountOfObjects, CFBridgingRelease(UTCreateStringForOSType(tag)));
#endif
            
            for (i = 0; i < amountOfObjects; i++) {
                id theObj = [[theClass alloc] init];
                [theArray addObject:theObj];
                
                [level setUpArrayPointersFor:theObj];
            }
        }
        
        if (next_offset == 0 /* && !foundTheTag */) {
#ifdef useDebugingLogs
            NSLog(@"   PreAllocation Completed...");
#endif
            //[theDataToReturn release];
            return;
        }
        this_offset = myLevelHeaders[theLevel-1].offsetToStart + next_offset;
        
    } // End while (GoOn == YES)
#ifdef useDebugingLogs
    NSLog(@"   PreAllocation Completed...");
#endif
    return;
}

// ***************************** Basic Data Accsessor Functions *****************************
#pragma mark -
#pragma mark ********* Basic Data Accsessor Functions *********

- (long)numberOfLevels
{
    return myMainMapHeader.numberOfLevels;
}

- (NSMutableArray *)levelNames
{
    return levelNames;
}

// ***************************** Load Data Functions *****************************
#pragma mark -
#pragma mark ********* Load Data Functions *********

- (short)getShort
{
    short theShort;
    //[mapData deserializeDataAt:&theShort ofObjCType:@encode(short) atCursor:&theCursor context:nil];
    [mapData getBytes:&theShort range:NSMakeRange(theCursor,2)];
    theShort = CFSwapInt16BigToHost(theShort);
    theCursor += 2;
    return theShort;
}

-(id)getShortObjectFromArray:(NSArray *)theArray
{
    short theShortNum;
    NSInteger theArrayCount = [theArray count];
    [mapData getBytes:&theShortNum range:NSMakeRange(theCursor,2)];
    theShortNum = CFSwapInt16BigToHost(theShortNum);
    theCursor += 2;
    
    if ((theShortNum >= theArrayCount)) {
        NSLog(@"Bounding Error: %d   Array Count: %ld", theShortNum, (long)theArrayCount);
        if (!alreadyGaveBoundingError)
            SEND_ERROR_MSG(@"Bad Map Data, Bounding Error: Map Trying To Refrence Beyond The Bounds Of An Array! Setting It To Last Item In Array…");
        alreadyGaveBoundingError = YES;
        return [theArray lastObject];
    } else {
        return (theShortNum < 0) ? (nil) : ([theArray objectAtIndex:theShortNum]);
    }
}

-(id)getShortZeroIsNilIfOverObjectFromArray:(NSArray *)theArray
{
    short theShortNum;
    NSInteger theArrayCount = [theArray count];
    [mapData getBytes:&theShortNum range:NSMakeRange(theCursor,2)];
    theShortNum = CFSwapInt16BigToHost(theShortNum);
    theCursor += 2;
    
    if (theShortNum < 1 && theArrayCount < 1) {
        return nil;
    } else if ((theShortNum >= theArrayCount)) {
        return nil;
    }
    /*else if ((theShortNum >= theArrayCount))
    {
        NSLog(@"Bounding Error: %d   Array Count: %d", theShortNum, theArrayCount);
        if (!alreadyGaveBoundingError)
            SEND_ERROR_MSG(@"Bad Map Data, Bounding Error: Map Trying To Refrence Beyond The Bounds Of An Array! Setting It To Last Item In Array...");
        alreadyGaveBoundingError = YES;
        return [theArray lastObject];
    }*/
    else {
        return (theShortNum < 0) ? (nil) : ([theArray objectAtIndex:theShortNum]);
    }
}

- (short)getUnsignedShort
{
    unsigned short theUnsignedShort;
    //[mapData deserializeDataAt:&theShort ofObjCType:@encode(short) atCursor:&theCursor context:nil];
    [mapData getBytes:&theUnsignedShort range:NSMakeRange(theCursor,2)];
    theUnsignedShort = CFSwapInt16BigToHost(theUnsignedShort);
    theCursor += 2;
    return theUnsignedShort;
}

-(id)getUnsignedShortObjectFrom:(NSArray *)theArray
{
    unsigned short theUnsignedShort;
    [mapData getBytes:&theUnsignedShort range:NSMakeRange(theCursor,2)];
    theUnsignedShort = CFSwapInt16BigToHost(theUnsignedShort);
    theCursor += 2;
    return [theArray objectAtIndex:theUnsignedShort];
}

- (int)getLong
{
    int theLong;
    //[mapData deserializeDataAt:&theLong ofObjCType:@encode(long) atCursor:&theCursor context:nil];
    [mapData getBytes:&theLong range:NSMakeRange(theCursor,4)];
    theLong = CFSwapInt32BigToHost(theLong);
    theCursor += 4;
    return theLong;
}

- (unsigned int)getUnsignedLong
{
    unsigned int theUnsignedLong;
    //[mapData deserializeDataAt:&theUnsignedLong ofObjCType:@encode(unsigned long) atCursor:&theCursor context:nil];
    [mapData getBytes:&theUnsignedLong range:NSMakeRange(theCursor,4)];
    theUnsignedLong = CFSwapInt32BigToHost(theUnsignedLong);
    theCursor += 4;
    return theUnsignedLong;
}

- (NSString*)getChar:(unsigned)theCharAmount
{
    NSData *strData = [mapData subdataWithRange:NSMakeRange(theCursor, theCharAmount)];
    theCursor += theCharAmount;
    NSString *theTmpCharString = [[NSString alloc] initWithData:strData encoding:NSMacOSRomanStringEncoding];
    NSRange range = [theTmpCharString rangeOfString:@"\0"];
    if (range.location != NSNotFound) {
        NSString *theTrimmedCharString = [theTmpCharString substringToIndex:range.location];
        return theTrimmedCharString;
    }
    
    return theTmpCharString;
}

- (short)getOneByteShort
{
    char theChar;
    
    //[mapData deserializeDataAt:&theLetter ofObjCType:@encode(char) atCursor:&theCursor context:nil];
    [mapData getBytes:&theChar range:NSMakeRange(theCursor,1)];
    theCursor++;
    
    return (short)theChar;
}

// ***************************** Save Data Functions *****************************
#pragma mark -
#pragma mark ********* Save Data Functions *********

- (void)saveData:(NSData *)theData { [mapDataToSave appendData:theData]; }
- (void)saveShort:(short)v 
{ 
    short theData = CFSwapInt16HostToBig(v);
    [mapDataToSave appendBytes:&theData length:2];
}

- (void)saveUnsignedShort:(unsigned short)v 
{ 
    short theShort = CFSwapInt16HostToBig(v);
    [mapDataToSave appendBytes:&theShort length:2];
}

- (void)saveLong:(int)v
{ 
    int theLong = CFSwapInt32HostToBig(v);
    [mapDataToSave appendBytes:&theLong length:4];
}

- (void)saveUnsignedLong:(unsigned int)v
{ 
    int theLong = CFSwapInt32HostToBig(v);
    [mapDataToSave appendBytes:&theLong length:4];
}

- (void)saveStringAsChar:(NSString *)v withLength:(int)length
{
    const char *theStringAsCString = [v cStringUsingEncoding:NSMacOSRomanStringEncoding];
    ssize_t theStringLength = strlen(theStringAsCString);
    char nullChar = '\0';
    
    if (length < 0) {
        NSLog(@"••• ERROR: Tried to saved a string of negative length in LEMapData->saveStringAsChar:");
        return;
    }
    
    if (theStringLength >= length) {
        [mapDataToSave appendBytes:theStringAsCString length:(length-1)];
    } else {
        [mapDataToSave appendBytes:theStringAsCString length:theStringLength];
        [self saveEmptyBytes:(int)((length - theStringLength) - 1)];
    }
    
    [mapDataToSave appendBytes:&nullChar length:1];
}

- (void)saveOneByteShort:(char)v { [mapDataToSave appendBytes:&v length:1]; }

- (void)saveEmptyBytes:(int)amount
{ 
    //int i;
    //int c = amount / 2;
    // for (i = 0; i < c; i++)
    //    [self saveShort:0];
    [mapDataToSave increaseLengthBy:amount];
}

// ***************************** Save Header Functions *****************************01
#pragma mark -
#pragma mark ********* Save Header Functions *********

- (BOOL)saveMainMapHeaderForLevels:(int)numberOfLevels usingMapDataSize:(long)size
{
    // Note: add tests to see if these methods were sucsesfull or not!!!
    
    [self saveShort:4];//myMainMapHeader.version];
    
    [self saveShort:1];//myMainMapHeader.dataVersion];
    
    
    [self saveStringAsChar:@"Merged Map Files" withLength:16];
    
    [self saveEmptyBytes:48];
    
    //theCursor += 64;
    
    [self saveUnsignedLong:0]; //myMainMapHeader.checksum];
    
    [self saveLong:(int)(size+128)];
    
    //The Location Of The Number of Levels is byte 77
    [self saveShort:numberOfLevels];
    
    [self saveShort:74];
    //[self saveShort:myMainMapHeader.applicationSpecificDirectoryDataSize];
    //NSlog(@"save applicationSpecificDirectoryDataSize: %d ", myMainMapHeader.applicationSpecificDirectoryDataSize);
    
    [self saveShort:16];
    //[self saveShort:myMainMapHeader.entryHeaderSize = [self getShort];
    //NSlog(@"save entryHeaderSize: %d ", myMainMapHeader.entryHeaderSize);
    
    [self saveShort:10];
    //[self saveShort:myMainMapHeader.directoryEntryBaseSize = [self getShort];
    //NSlog(@"save directoryEntryBaseSize: %d ", myMainMapHeader.directoryEntryBaseSize);
    
    [self saveUnsignedLong:0];
    //[self saveUnsignedLong:myMainMapHeader.parentChecksum];
    //NSlog(@"save parentChecksum: %d ", myMainMapHeader.parentChecksum);
    
    [self saveEmptyBytes:40];
    
    #ifdef useDebugingLogs
        NSLog(@"Saved the map header.");
    #endif
    return YES;
    
    /*
    // Get the header for the map...
    //NSLog(@"initMainHeader");
    [self initMainHeader];
    
    levelNames = [NSMutableArray arrayWithCapacity:[self numberOfLevels]];
    [levelNames retain];
    
    // get the indvidual level headers...
    //NSLog(@"initLevelHeaders");
    [self initLevelHeaders];
    
    // Get the basic information about each level, such as the name, etc.
    //NSLog(@"initBasicLevelInfo");
    [self initBasicLevelInfo];
    
    return YES;
    */
    return NO;
}

/*
	short mission_flags;
	short environment_flags;
	long entry_point_flags;
	char level_name[LEVEL_NAME_LENGTH];
*/

- (BOOL)saveDirectoryEntryInfo:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 12)];
    //theObjects = [level getItemPlacement];
    //int objCount = 1;
    //int lengthFromTop = [mapDataToSave length];
    //int objByteCount = 74; //(objCount * 88 /* objs length */);
    
    NSString *theLevelName = [level levelName];
    
    [self saveShort:[level missionFlags]];
    [self saveShort:[level environmentFlags]];
    [self saveLong:[level entryPointFlags]];
    
    [self saveStringAsChar:theLevelName withLength:66];
    
#ifdef useDebugingLogs
    NSLog(@"Saved the level directory entry.   SIZE: %d", [mapDataToSave length]);
#endif
    return YES;
}


- (BOOL)saveBasicLevelInfo:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 12)];
    //theObjects = [level getItemPlacement];
    //int objCount = 1;
    //int lengthFromTop = [mapDataToSave length];
    int objByteCount = 88; //(objCount * 88 /* objs length */);
    
    NSString *theLevelName = [level levelName];
    
    [self saveLong:'Minf'];
    // Going to be zero, for now I am assuming that this is the last tag... :)
    [self saveLong:0/*(lengthFromTop + objByteCount + 1)*/]; // next offset
    [self saveLong:objByteCount]; // length
    [self saveLong:0]; // offset, for inplace expansion of data???
    
    
    [self saveShort:[level environmentCode]];
    [self saveShort:[level physicsModel]];
    [self saveShort:[level songIndex]];
    [self saveShort:[level missionFlags]];
    [self saveShort:[level environmentFlags]];
    
    [self saveEmptyBytes:8];
    
    
    
    [self saveStringAsChar:theLevelName withLength:66];
    //[self saveEmptyBytes:60];
    
    [self saveLong:[level entryPointFlags]];
    
#ifdef useDebugingLogs
    NSLog(@"Saved the level info object ('Minf'). SIZE: %d", [mapDataToSave length]);
#endif
    return YES;
}

- (BOOL)saveLevelHeaders:(LELevelData *)level usingMapDataSize:(long)size usingLocation:(long)loc forLevelIndex:(short)index
{
    [self saveLong:(int)loc];
    [self saveLong:(int)size];
    [self saveShort:index];
    [self saveDirectoryEntryInfo:level];
#ifdef useDebugingLogs
    NSLog(@"Saved the level header.");
#endif
    return YES;
}

// ***************************** Get Header Functions *****************************
#pragma mark -
#pragma mark ********* Get Header Functions *********

- (BOOL)initHeaders
{
    // Note: add tests to see if these methods were sucsesfull or not!!!
    
    // Get the header for the map...
    //NSLog(@"initMainHeader");
    [self initMainHeader];
    
    levelNames = [NSMutableArray arrayWithCapacity:[self numberOfLevels]];
    
    // get the indvidual level headers...
    //NSLog(@"initLevelHeaders");
    [self initLevelHeaders];
    
    // Get the basic information about each level, such as the name, etc.
    //NSLog(@"initBasicLevelInfo");
    [self initBasicLevelInfo];
    
#ifdef useDebugingLogs
    NSLog(@"Number Of Leves: %d   -   Number Of Level Names: %d", [self getNumberOfLevels], [[self getLevelNames] count]);
#endif
    return YES;
}

- (BOOL)initBasicLevelInfo
{
    int i;
    environment_flags = (short *) malloc (sizeof(short) * [self numberOfLevels]);
    environment_code = (short *) malloc (sizeof(short) * [self numberOfLevels]);
    physics_model = (short *) malloc (sizeof(short) * [self numberOfLevels]);
    song_index = (short *) malloc (sizeof(short) * [self numberOfLevels]);
    mission_flags = (short *) malloc (sizeof(short) * [self numberOfLevels]);
    entry_point_flags = (int *) malloc (sizeof(int) * [self numberOfLevels]);
    
    for (i = 0; i < [self numberOfLevels]; i++) {
        BOOL GoOn;
        long this_offset;
        //Set the cursor to the first byte of the level
        theCursor = myLevelHeaders[i].offsetToStart;
        //Set it so that it uses current cursor location and
        //does not try to use this_offset...
        this_offset = -1;
        GoOn = YES;
        
#ifdef useDebugingLogs
        NSLog(@"Scaning level (initBasicLevelInfo): %d", i+1);
#endif
        while (GoOn == YES /*&& theCursor < (theCursor + myLevelHeaders[i].length) */) { // Logicaly check this out some time!!!
            int next_offset, length, offset;
            OSType tag;
            //NSString *theTagAsString;
            //char *theTagAsChar;
            
            //NSLog(@"Scaning of level: %d", i+1);
            if (this_offset != -1) {
                theCursor = this_offset;
            }
            
            //NSLog(@"BEFORE %d tag: %d", i+1, tag);
            tag = [self getLong];
            //NSLog(@"Level %d tag: %d", i+1, tag);
            
            //theTagAsChar = (char*)tag;
            //theTagAsString = [NSString stringWithCString:theTagAsChar length:4];
            //NSLog(@"Level %d tag as string: %@", i+1, theTagAsString);
            
            //theCursor -= 4;
            
            //NSLog(@"||| The Tag: %@ ||||", [self getChar:4]);
            
            
            next_offset = [self getLong];
            //NSLog(@"Level %d next_offset: %d", i+1,  next_offset);
            length = [self getLong];
            //NSLog(@"Map/Level %d info tag length: %d", i+1, length);
            offset = [self getLong];
            //NSLog(@"Level %d offset: %d", i+1, offset);
            
            if (tag == 'Minf') //Map Info Tag
            {
                /*
                #define MAP_INFO_TAG 'Minf'
                struct static_data
                {
                    short environment_code;
                    
                    short physics_model;
                    short song_index;
                    short mission_flags;
                    short environment_flags;
                    
                    short unused[4];
                    
                    char level_name[LEVEL_NAME_LENGTH];
                    long entry_point_flags;
                }*/
                
                NSString *thisLevelsName;
                
                //NSLog(@"Map/Level info tag length: %d", length);
                
                environment_code[i] = [self getShort];
                
                physics_model[i] = [self getShort];
                song_index[i] = [self getShort];
                mission_flags[i] = [self getShort];
                environment_flags[i] = [self getShort];
                
                theCursor += 8; //skip unsed shorts...
                
                //get the level name
                thisLevelsName = [self getChar:66];
                [levelNames addObject:thisLevelsName];
                
#ifdef useDebugingLogs
                NSLog(@"Level# %d  -  Name: %@", i, thisLevelsName);
#endif
                entry_point_flags[i] = [self getLong];
                
                GoOn = NO;
            }
            this_offset = myLevelHeaders[i].offsetToStart + next_offset;
        }
    }
    return YES;
}

- (BOOL)initLevelHeaders
{
    int i;
    
    //Set the cursor to the first byte of the first trailer
    theCursor = myMainMapHeader.mapSize;
    
    // Allocate the memory nessary to hold the header information for all the levels...
    myLevelHeaders = (struct SLevelHeader *) malloc (sizeof(struct SLevelHeader) * [self numberOfLevels]);
    
    // Fill out all the array of structures with the header information from the file...
    for (i = 0; i < [self numberOfLevels]; i++) {
        myLevelHeaders[i].offsetToStart = [self getLong];
        //NSLog(@"offsetToStart for level %d: %d ", i+1, myLevelHeaders[i].offsetToStart);
        
        myLevelHeaders[i].length = [self getLong];
        //NSLog(@"length for level %d: %d ", i+1, myLevelHeaders[i].length);
        
        myLevelHeaders[i].index = [self getShort];
        //NSLog(@"index for level %d: %d ", i+1, myLevelHeaders[i].index);
        
        theCursor += myMainMapHeader.applicationSpecificDirectoryDataSize;
    }
    return YES;
}

- (BOOL)initMainHeader
{
    //Set the cursor to the first byte
    theCursor = 0;
    
    // 2
    myMainMapHeader.version = [self getShort];
#ifdef useDebugingLogs
    NSLog(@"version: %d ", myMainMapHeader.version);
#endif
    // 1
    myMainMapHeader.dataVersion = [self getShort];
#ifdef useDebugingLogs
    NSLog(@"dataVersion: %d ", myMainMapHeader.dataVersion);
#endif
    //myMainMapHeader.theName = [self getChar:64];
    
    /* tTCS = [self getChar:64]; */
    
    //tTCS = [NSString stringWithCString:myMainMapHeader.theName];
    //tTCS = [NSString stringWithCString:myMainMapHeader.theName length:64];
    
    /*  //NSlog(@"theFileName: %@ ", tTCS); */
    
    theCursor += 64;
    myMainMapHeader.checksum = [self getUnsignedLong];
#ifdef useDebugingLogs
    NSLog(@"checksum: %d ", myMainMapHeader.checksum);
#endif
    myMainMapHeader.mapSize = [self getLong];
#ifdef useDebugingLogs
    NSLog(@"mapSize: %d ", myMainMapHeader.mapSize);
#endif
    //The Location Of The Number of Levels is byte 77
    myMainMapHeader.numberOfLevels = [self getShort];
#ifdef useDebugingLogs
    NSLog(@"numberOfLevels: %d ", myMainMapHeader.numberOfLevels);
#endif
    myMainMapHeader.applicationSpecificDirectoryDataSize = [self getShort];
#ifdef useDebugingLogs
    NSLog(@"applicationSpecificDirectoryDataSize: %d ", myMainMapHeader.applicationSpecificDirectoryDataSize);
#endif
    myMainMapHeader.entryHeaderSize = [self getShort];
#ifdef useDebugingLogs
    NSLog(@"entryHeaderSize: %d ", myMainMapHeader.entryHeaderSize);
#endif
    myMainMapHeader.directoryEntryBaseSize = [self getShort];
#ifdef useDebugingLogs
    NSLog(@"directoryEntryBaseSize: %d ", myMainMapHeader.directoryEntryBaseSize);
#endif
    myMainMapHeader.parentChecksum = [self getUnsignedLong];
    //NSLog(@"parentChecksum: %d ", myMainMapHeader.parentChecksum);
    
    return YES;
}

// ***************************** Save Level Headers *****************************
#pragma mark -
#pragma mark ********* Save Level Headers *********

// ***************************** Get Tag Data Functions *****************************
#pragma mark -
#pragma mark ********* Get Tag Data Functions *********

-(void)getThePointsAtOffset:(long)theDataOffset
                 withLength:(long)theDataLength
                  withLevel:(LELevelData *)curLevel
              regularPoints:(BOOL)regPointStyle
{
    NSArray *thePointArray = [curLevel points];
    LEMapPoint *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [thePointArray objectEnumerator];
    if (!regPointStyle) {
        // tag == 'EPNT'
        if ((theDataLength % 16)  > 0) {
            NSLog(@"WARNING: Non Integer Number Of Extended Points, File Could Be Corupted!");
        }
        while (((theDataLength + theDataOffset) > theCursor)
               && (theObj = [numer nextObject])) {
            theCursor += 6;
            [theObj setX:[self getShort] Y:[self getShort]];
            //[theObj setX:[self getShort]];
            //[theObj setY:[self getShort]];
            theCursor += 6;
        }
    } else{ //case 'PNTS'
        if ((theDataLength % 4)  > 0) {
            NSLog(@"WARNING: Non Integer Number Of Points, File Could Be Corupted!");
        }
        while (((theDataLength + theDataOffset) > theCursor)
               && (theObj = [numer nextObject])) {
            [theObj setX:[self getShort] Y:[self getShort]];
            //[theObj setX:[self getShort]];
            //[theObj setY:[self getShort]];
        }
    }
    
    return;
}

-(void)getTheLinesAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{
    // *** 'LINS' *** 32 bytes each
    NSArray *theLineArray = [curLevel lines];
    NSArray *thePolyArray = [curLevel polygons];
    NSArray *theSideArray = [curLevel sides];
    NSArray *thePointArray = [curLevel points];
    LELine *theObj;
    NSEnumerator *numer;
    int i = -1;
    
    theCursor = theDataOffset;
    numer = [theLineArray objectEnumerator];
    if ((theDataLength % 32)  > 0) {
        NSLog(@"WARNING: Non Integer Number Of Ambient Sounds, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        i++;
        ///NSLog(@"\n			*** *** *** Line %d *** *** ***\n", i);
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setMapPoint1"];
#endif
        
        //[theObj setMapPoint1:[self getShortObjectFromArray:thePointArray]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setMapPoint2"];
#endif
        //[theObj setMapPoint2:];
        [theObj setMapPoint1:[self getShortObjectFromArray:thePointArray] mapPoint2:[self getShortObjectFromArray:thePointArray]];
        
#ifdef useDebugingLogs
        [self NSLogUnsignedShortFromData:@"setFlags"];
#endif
        [theObj setFlags:[self getUnsignedShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setLength"];
#endif
        [theObj setLength:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setHighestAdjacentFloor"];
#endif
        [theObj setHighestAdjacentFloor:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setLowestAdjacentCeiling"];
#endif
        [theObj setLowestAdjacentCeiling:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setClockwisePolygonSideObject"];
#endif
        [theObj setClockwisePolygonSideObject:[self getShortObjectFromArray:theSideArray]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setCounterclockwisePolygonSideObject"];
#endif
        [theObj setCounterclockwisePolygonSideObject:[self getShortObjectFromArray:theSideArray]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setClockwisePolygonObject"];
#endif
        [theObj setClockwisePolygonObject:[self getShortObjectFromArray:thePolyArray]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setConterclockwisePolygonObject"];
#endif
        [theObj setConterclockwisePolygonObject:[self getShortObjectFromArray:thePolyArray]];
        
        theCursor += 12; //Skip the unused part of each line... :)
    }
    return;
}

-(void)getThePolygonsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{
    // *** 'POLY' *** 128 bytes each
    NSArray *thePolyArray = [curLevel polygons];
    NSArray *theLightArray = [curLevel lights];
    NSArray *theSideArray = [curLevel sides];
    NSArray *theLineArray = [curLevel lines];
    NSArray *thePointArray = [curLevel points];
    NSArray *theMediaArray = [curLevel media];
    NSArray *theAmbientArray = [curLevel ambientSounds];
    NSArray *thePlatformArray = [curLevel platforms];
    NSArray *theRandomArray = [curLevel randomSounds];
    NSArray *theObjectArray = [curLevel theMapObjects];
    
    NSInteger countOfPlatformArray = [thePlatformArray count];
    int i, c = -1, vertextCount;
    
    LEPolygon *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [thePolyArray objectEnumerator];
    if ((theDataLength % 128)  > 0) {
        NSLog(@"WARNING: Non Integer Number Of Polygons, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        short thePermutation;
        LEPolygonType theType;
        id thePerObj;
        
        c++;
        ///NSLog(@"\n			*** *** *** Polygon %d *** *** ***\n", c);
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"theType"];
#endif
        theType = [self getShort];
        
        [theObj setType:theType];
#ifdef useDebugingLogs
        [self NSLogUnsignedShortFromData:@"setFlags"];
#endif
        [theObj setFlags:[self getUnsignedShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"thePermutation"];
#endif
        thePermutation = [self getShort];
        
        if (thePermutation < 0) {
            thePerObj = nil;
        } else {
            switch (theType) {
                case _polygon_is_base:
                    thePerObj = nil; // For Now, I am not sure about this yet???
                    break;
                case _polygon_is_platform:
                    if (countOfPlatformArray > thePermutation)
                        thePerObj = [thePlatformArray objectAtIndex:thePermutation];
                    else
                        thePerObj = nil;
#ifdef useDebugingLogs
                    NSLog(@"poly platfrom tag number: %d, poly index: %d, thePermutation: %d", [thePerObj getTag], [theObj getIndex], thePermutation);
#endif
                    break;
                case _polygon_is_light_on_trigger:
                    thePerObj = [theLightArray objectAtIndex:thePermutation];
                    break;
                case _polygon_is_platform_on_trigger:
                    thePerObj = [thePolyArray objectAtIndex:thePermutation];
                    break;
                case _polygon_is_light_off_trigger:
                    thePerObj = [theLightArray objectAtIndex:thePermutation];
                    break;
                case _polygon_is_platform_off_trigger:
                    thePerObj = [thePolyArray objectAtIndex:thePermutation];
                    break;
                case _polygon_is_teleporter:
                    thePerObj = [thePolyArray objectAtIndex:thePermutation];
                    break;
                case _polygon_is_automatic_exit:
                    //NSLog(@"AUTOMATIC EXIT: %d", thePermutation);
                    thePerObj = [NSNumber numberWithInt:thePermutation];
                    break;
                default:
                    thePerObj = nil;
                    break;
            }
        }
        
        [theObj setPermutationObject:thePerObj];
        
        //[theObj setPermutation:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setVertextCount"];
#endif
        vertextCount = [self getShort];
        [theObj setVertextCount:vertextCount];
        
        for (i = 0; i < 8; i++) {
            if (i < vertextCount) {
#ifdef useDebugingLogs
                [self NSLogShortFromData:@"[theObj setVertexWithObject:[self getShortObjectFrom:thePointArray] i:i]"];
#endif
                [theObj setVertexWithObject:[self getShortObjectFromArray:thePointArray] toIndex:i];
            } else {
                theCursor += 2;
                [theObj setVertexWithObject:nil toIndex:i];
            }
        }
        
        for (i = 0; i < 8; i++) {
            if (i < vertextCount) {
#ifdef useDebugingLogs
                [self NSLogShortFromData:@"[theObj setLinesObject:[self getShortObjectFrom:theLineArray] i:0]"];
#endif
                [theObj setLinesObject:[self getShortObjectFromArray:theLineArray] toIndex:i]; //
            } else {
                theCursor += 2;
                [theObj setLinesObject:nil toIndex:i];
            }
        }
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setFloor_texture"];
#endif
        [theObj setFloorTexture:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setCeiling_texture"];
#endif
        [theObj setCeilingTexture:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setFloor_height:"];
#endif
        [theObj setFloorHeightNoSides:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setCeiling_height:"];
#endif
        [theObj setCeilingHeightNoSides:[self getShort]];
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setFloor_lightsourceObject"];
#endif
        [theObj setFloorLightsourceObject:[self getShortObjectFromArray:theLightArray]]; //
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setCeiling_lightsourceObject"];
#endif
        [theObj setCeilingLightsourceObject:[self getShortObjectFromArray:theLightArray]]; //
        
#ifdef useDebugingLogs
        [self NSLogLongFromData:@"setArea"];
#endif
        [theObj setArea:[self getLong]];
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setFirst_objectObject"];
#endif
        [theObj setFirstObjectObject:[self getShortZeroIsNilIfOverObjectFromArray:theObjectArray]]; //
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setFirst_exclusion_zone_index"];
#endif
        [theObj setFirstExclusionZoneIndex:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setLine_exclusion_zone_count"];
#endif
        [theObj setLineExclusionZoneCount:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setPoint_exclusion_zone_count"];
#endif
        [theObj setPointExclusionZoneCount:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setFloor_transfer_mode"];
#endif
        [theObj setFloorTransferMode:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setCeiling_transfer_mode"];
#endif
        [theObj setCeilingTransferMode:[self getShort]];
        
        for (i = 0; i < 8; i++)
        {
            if (i < vertextCount)
            {
#ifdef useDebugingLogs
                [self NSLogShortFromData:@"setAdjacent_polygonObject:[self getShortObjectFrom:thePolyArray] i:0]"];
#endif
                [theObj setAdjacentPolygonObject:[self getShortZeroIsNilIfOverObjectFromArray:thePolyArray] toIndex:i]; //
            }
            else
            {
                theCursor += 2;
                [theObj setAdjacentPolygonObject:nil toIndex:i];
            }
        }
        
        // I think the following is the closest polygon
        // index within One World Unit. But how do
        // you decide which one is closer if more
        // then one polygon shares a line with this
        // polygon?  I am thinking this list only
        // incorparates polygons within One World Unit
        // and they also can't chare a line with this
        // polygon becuase the above array already lists
        // all touching polygons for easy refrence...
        // Ask the Marathon-Developer list about the
        // following two entrys...
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"blank"];
#endif
        theCursor += 2; // Skip the sound sources for right now...
        //[theObj setFirstNeighborObject:[self getShortObjectFromArray:thePolyArray]]; //
        
        // I think this is the number of polygons
        // within One World Unit of polygon
        // boarders?  Or is it from the center
        // of the polygon?  I am going with
        // the boarders for right now...
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setNeighbor_count"];
#endif
        [theObj setNeighborCount:[self getShort]];
        
#ifdef useDebugingLogs
        [self NSLogPointFromData:@"setCenter"];
#endif
        [theObj setCenter:NSMakePoint([self getShort], [self getShort])];
        
        for (i = 0; i < 8; i++)
        {
            if (i < vertextCount)
            {
#ifdef useDebugingLogs
                [self NSLogShortFromData:@"setSidesObject:[self getShortObjectFrom:theSideArray] i:0]"];
#endif
                [theObj setSidesObject:[self getShortZeroIsNilIfOverObjectFromArray:theSideArray] toIndex:i]; //
            }
            else
            {
                theCursor += 2;
                [theObj setSidesObject:nil toIndex:i];
            }
        }
        
#ifdef useDebugingLogs
        [self NSLogPointFromData:@"setFloor_origin"];
#endif
        [theObj setFloorOrigin:NSMakePoint([self getShort], [self getShort])];
#ifdef useDebugingLogs
        [self NSLogPointFromData:@"setCeiling_origin"];
#endif
        [theObj setCeilingOrigin:NSMakePoint([self getShort], [self getShort])];
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setMediaObject"];
#endif
        [theObj setMediaObject:[self getShortObjectFromArray:theMediaArray]]; //
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setMedia_lightsourceObject"];
#endif
        [theObj setMediaLightsourceObject:[self getShortObjectFromArray:theLightArray]]; //
        
        //[theObj setSoundSources:[self getShort]]; // *** I am not sure about this one ***
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"blank"];
#endif
        theCursor += 2; // Skip the sound sources for right now...
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setAmbient_soundObject"];
#endif
        [theObj setAmbientSoundObject:[self getShortObjectFromArray:theAmbientArray]]; //
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setRandom_soundObject"];
#endif
        [theObj setRandomSoundObject:[self getShortZeroIsNilIfOverObjectFromArray:theRandomArray]]; //
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"blank"];
#endif
        theCursor+=2; // Skip the unused short
    }
    return;
}

// [ objectAtIndex:

-(void)getTheMapObjectsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{
    // *** 'OBJS' *** 16 bytes each
    NSArray *theObjectArray = [curLevel theMapObjects];
    NSArray *thePolyArray = [curLevel polygons];
    LEMapObject *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theObjectArray objectEnumerator];
    if ((theDataLength % 16) > 0) {
        NSLog(@"WARNING: Non Integer Number Of Map Objects, File Could Be Corupted!");
    }
    
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        [theObj setType:[self getShort]];
        [theObj setIndex:[self getShort]];
        [theObj setFacing:[self getShort]];
        [theObj setPolygonObject:[self getShortObjectFromArray:thePolyArray]];
        [theObj setX:[self getShort]];
        [theObj setY:[self getShort]];
        [theObj setZ:[self getShort]];
        [theObj setMapFlags:[self getUnsignedShort]];
    }
    return;
}

-(void)getTheSidesAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{
    // *** 'SIDS' *** 64 bytes each
    NSArray *theSideArray = [curLevel sides];
    NSArray *theLightArray = [curLevel lights];
    NSArray *theLineArray = [curLevel lines];
    NSArray *thePolyArray = [curLevel polygons];
    
    LESide *theObj;
    NSEnumerator *numer;
    
    int i = -1;
    
    theCursor = theDataOffset;
    numer = [theSideArray objectEnumerator];
    if ((theDataLength % 64) > 0) {
        NSLog(@"WARNING: Non Integer Number Of Sides, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        struct side_texture_definition theTempSideTextureDefinition;
        struct side_exclusion_zone theTempExclusionZone;
        
        i++;
        ///NSLog(@"\n			*** *** *** Side %d *** *** ***\n", i);
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setType"];
#endif
        [theObj setType:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogUnsignedShortFromData:@"setFlags"];
#endif
        [theObj setFlags:[self getUnsignedShort]];
        
        theTempSideTextureDefinition.x0 = [self getShort];
        theTempSideTextureDefinition.y0 = [self getShort];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"P texture"];
#endif
        theTempSideTextureDefinition.texture = [self getShort]; // 3oisudjlifslkf sujdlifj ldsf
        theCursor -= 2;
        theTempSideTextureDefinition.textureCollection = [self getOneByteShort];
        theTempSideTextureDefinition.textureNumber = [self getOneByteShort];
        [theObj setPrimaryTextureStruct:theTempSideTextureDefinition];
        
        theTempSideTextureDefinition.x0 = [self getShort];
        theTempSideTextureDefinition.y0 = [self getShort];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"S texture"];
#endif
        theTempSideTextureDefinition.texture = [self getShort];
        theCursor -= 2;
        theTempSideTextureDefinition.textureCollection = [self getOneByteShort];
        theTempSideTextureDefinition.textureNumber = [self getOneByteShort];
        [theObj setSecondaryTextureStruct:theTempSideTextureDefinition];
        
        theTempSideTextureDefinition.x0 = [self getShort];
        theTempSideTextureDefinition.y0 = [self getShort];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"T texture"];
#endif
        theTempSideTextureDefinition.texture = [self getShort];
        theCursor -= 2;
        theTempSideTextureDefinition.textureCollection = [self getOneByteShort];
        theTempSideTextureDefinition.textureNumber = [self getOneByteShort];
        [theObj setTransparentTextureStruct:theTempSideTextureDefinition];
        
        
#ifdef useDebugingLogs
        [self NSLogPointFromData:@"theTempExclusionZone 0"];
#endif
        theTempExclusionZone.e0.x = [self getShort];
        theTempExclusionZone.e0.y = [self getShort];
#ifdef useDebugingLogs
        [self NSLogPointFromData:@"theTempExclusionZone 1"];
#endif
        theTempExclusionZone.e1.x = [self getShort];
        theTempExclusionZone.e1.y = [self getShort];
#ifdef useDebugingLogs
        [self NSLogPointFromData:@"theTempExclusionZone 2"];
#endif
        theTempExclusionZone.e2.x = [self getShort];
        theTempExclusionZone.e2.y = [self getShort];
#ifdef useDebugingLogs
        [self NSLogPointFromData:@"theTempExclusionZone 3"];
#endif
        theTempExclusionZone.e3.x = [self getShort];
        theTempExclusionZone.e3.y = [self getShort];
        
        [theObj setExclusionZone:theTempExclusionZone];
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setControl_panel_type"];
#endif
        [theObj setControlPanelType:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setControl_panel_permutation"];
#endif
        [theObj setControlPanelPermutation:[self getShort]];
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setPrimary_transfer_mode"];
#endif
        [theObj setPrimaryTransferMode:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setSecondary_transfer_mode"];
#endif
        [theObj setSecondaryTransferMode:[self getShort]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setTransparent_transfer_mode"];
#endif
        [theObj setTransparentTransferMode:[self getShort]];
        
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setPolygon_object"];
#endif
        [theObj setPolygonObject:[self getShortObjectFromArray:thePolyArray]];
#ifdef useDebugingLogs
        [self NSLogShortFromData:@"setLine_object"];
#endif
        [theObj setLineObject:[self getShortObjectFromArray:theLineArray]];
        
#ifdef useDebugingLogs
        [self NSLogLongFromData:@"setPrimary_lightsource_object"];
#endif
        [theObj setPrimaryLightsourceObject:[self getShortObjectFromArray:theLightArray]];
#ifdef useDebugingLogs
        [self NSLogLongFromData:@"setSecondary_lightsource_object"];
#endif
        [theObj setSecondaryLightsourceObject:[self getShortObjectFromArray:theLightArray]];
#ifdef useDebugingLogs
        [self NSLogLongFromData:@"setTransparent_lightsource_object"];
#endif
        [theObj setTransparentLightsourceObject:[self getShortObjectFromArray:theLightArray]];
        
#ifdef useDebugingLogs
        [self NSLogLongFromData:@"setAmbient_delta"];
#endif
        [theObj setAmbientDelta:[self getLong]];
        
        theCursor+=2; // Skip the unused short
    }
    return;
}

-(void)getTheLightsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{
    // *** 'LITE' *** 100 bytes each
    NSArray *theLightArray = [curLevel lights];
    PhLight *theObj;
    NSEnumerator *numer;
    int i = 0;
    
    theCursor = theDataOffset;
    numer = [theLightArray objectEnumerator];
    if ((theDataLength % 100)  > 0) {
        NSLog(@"WARNING: Non Integer Number Of Lights, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        [theObj setType:[self getShort]];
        [theObj setFlags:[self getUnsignedShort]];
        
        [theObj setPhase:[self getShort]];
        
        for (i = 0; i < 6; i++) {
            [theObj setFunction:[self getShort] forState:i];
            [theObj setPeriod:[self getShort]forState:i];
            [theObj setDeltaPeriod:[self getShort] forState:i];
            [theObj setIntensity:[self getLong] forState:i];
            [theObj setDeltaIntensity:[self getLong] forState:i];
        }
        
        [theObj setTag:[self getShort]]; // May Want To Make It Point To Tag Object
        
        theCursor+=8; // Skip the 4 unused shorts
    }
    return;
}

-(void)getTheAnnotationsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{
    // *** 'NOTE' *** 72 bytes each
    NSArray *theAnnotationArray = [curLevel notes];
    NSArray *thePolyArray = [curLevel polygons];
    PhAnnotationNote *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theAnnotationArray objectEnumerator];
    if ((theDataLength % 72)  > 0) {
        NSLog(@"WARNING: Non Integer Number Of Annotation Notes, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        [theObj setType:[self getShort]];
        
        [theObj setLocation:NSMakePoint([self getShort], [self getShort])];
        [theObj setPolygonObject:[self getShortObjectFromArray:thePolyArray]];
        
        [theObj setText:[self getChar:64]];
    }
    return;
}

-(void)getTheMediaAtOffset:(long)theDataOffset
                withLength:(long)theDataLength
                 withLevel:(LELevelData *)curLevel
{
    // *** 'medi' *** 32 bytes each
    NSArray *theMediaArray = [curLevel media];
    NSArray *theLightArray = [curLevel lights];
    PhMedia *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theMediaArray objectEnumerator];
    if ((theDataLength % 32)  > 0) {
        NSLog(@"WARNING: Non Integer Number Of Medias, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        [theObj setType:[self getShort]];
        [theObj setFlags:[self getUnsignedShort]];
        
        [theObj setLightObject:[self getShortObjectFromArray:theLightArray]];
        
        [theObj setCurrentDirection:[self getShort]];
        [theObj setCurrentMagnitude:[self getShort]];
        
        [theObj setLow:[self getShort]];
        [theObj setHigh:[self getShort]];
        
        [theObj setOrigin:NSMakePoint([self getShort], [self getShort])];
        [theObj setHeight:[self getShort]];
        
        [theObj setMinimumLightIntensity:[self getLong]]; // ??? Should Make Object Pointer ???
        [theObj setTexture:[self getShort]];
        [theObj setTransferMode:[self getShort]];
        
        theCursor+=4; // Skip the 2 unused shorts
    }
}

-(void)getTheAmbientSoundsAtOffset:(long)theDataOffset
                        withLength:(long)theDataLength
                         withLevel:(LELevelData *)curLevel
{
    // *** 'ambi' *** 16 bytes each
    NSArray *theAmbientArray = [curLevel ambientSounds];
    PhAmbientSound *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theAmbientArray objectEnumerator];
    if ((theDataLength % 16)  > 0) {
        NSLog(@"WARNING: Non Integer Number Of Ambient Sounds, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        [theObj setFlags:[self getUnsignedShort]];
        
        [theObj setSoundIndex:[self getShort]];
        [theObj setVolume:[self getShort]];
        
        theCursor+=10; // Skip the 5 unused shorts
    }
}

-(void)getTheStaticPlatformsAtOffset:(long)theDataOffset
                          withLength:(long)theDataLength
                           withLevel:(LELevelData *)curLevel
{
    // *** 'plat' *** 32 bytes each   Merged Maps have 'PLAT' ???
    NSArray *thePlatformArray = [curLevel platforms];
    NSArray *thePolyArray = [curLevel polygons];
    PhPlatform *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [thePlatformArray objectEnumerator];
    if ((theDataLength % 32)  > 0) {
        NSLog(@"WARNING: Non Integer Number Of Static Platforms, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        [theObj setType:[self getShort]];
        [theObj setSpeed:[self getShort]];
        [theObj setDelay:[self getShort]];
        [theObj setMaximumHeight:[self getShort]];
        [theObj setMinimumHeight:[self getShort]];
        [theObj setStaticFlags:[self getUnsignedLong]];
        [theObj setPolygonObject:[self getShortObjectFromArray:thePolyArray]];
        [theObj setTag:[self getShort]];
        
#ifdef useDebugingLogs
        NSLog(@"Platfrom Tag: %d, index: %d", [theObj getTag], [theObj getIndex]);
#endif
        
        theCursor+=14; // Skip the 7 unused bytes
    }
}

-(void)getTheDynamicPlatformsAtOffset:(long)theDataOffset
                           withLength:(long)theDataLength
                            withLevel:(LELevelData *)curLevel
{	// *** 'PLAT' ***
    NSArray *thePlatformArray = [curLevel platforms];
    //NSArray *thePolyArray = [curLevel polygons];
    PhPlatform *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [thePlatformArray objectEnumerator];
    if ((theDataLength % 140)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Dynamic Platforms, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        [theObj copyInDynamicPlatformData:mapData at:theCursor];
        
        theCursor+=140; // Skip the 7 unused bytes
    }
    return;
}


-(void)getTheItemPlacementAtOffset:(long)theDataOffset
                        withLength:(long)theDataLength
                         withLevel:(LELevelData *)curLevel
{
    // *** 'plac' *** 12 bytes each
    NSArray *theItemArray = [curLevel itemPlacement];
    PhItemPlacement *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theItemArray objectEnumerator];
    if ((theDataLength % 12)  > 0) {
        NSLog(@"WARNING: Non Integer Number Of Item Placments, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        [theObj setFlags:[self getShort]];
        
        [theObj setInitialCount:[self getShort]];
        [theObj setMinimumCount:[self getShort]];
        [theObj setMaximumCount:[self getShort]];
        
        [theObj setRandomCount:[self getShort]];
        [theObj setRandomChance:[self getUnsignedShort]];
    }
}

-(void)getTheRandomSoundsAtOffset:(long)theDataOffset
                       withLength:(long)theDataLength
                        withLevel:(LELevelData *)curLevel
{
    // *** 'bonk' *** 32 bytes each
    NSArray *theRandomArray = [curLevel randomSounds];
    PhRandomSound *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theRandomArray objectEnumerator];
    if ((theDataLength % 32)  > 0) {
        NSLog(@"WARNING: Non Integer Number Of Random Sounds, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
           && (theObj = [numer nextObject])) {
        [theObj setFlags:[self getShort]];
        [theObj setSoundIndex:[self getShort]];
        [theObj setVolume:[self getShort]];
        [theObj setDeltaVolume:[self getShort]];
        [theObj setPeriod:[self getShort]];
        [theObj setDeltaPeriod:[self getShort]];
        [theObj setDirection:[self getShort]];
        [theObj setDeltaDirection:[self getLong]];
        [theObj setPitch:[self getLong]];
        [theObj setDeltaPitch:[self getShort]];
        [theObj setPhase:[self getShort]];
        
        theCursor+=6; // Skip the 5 unused shorts
    }
    return;
}

-(void)getTheTerminalsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                     withLevel:(LELevelData *)curLevel
{
    ///[data getBytes:&length range:NSMakeRange(0, 2)];
    
    NSMutableArray *theTerminalArray = [curLevel getTerminals];
    //PhRandomSound *theObj;
    //NSEnumerator *numer;
    
    int count = 0;
    
    theCursor = theDataOffset;
    //numer = [theRandomArray objectEnumerator];
    while (((theDataLength + theDataOffset) > theCursor))
    { /*   && (theObj = [numer nextObject])   */
        int terminalLength = [self getShort]; // length of terminal...
        NSData *theTerminalRawData = [mapData subdataWithRange:NSMakeRange((theCursor - 2), terminalLength)];
        Terminal *theTerm = [[Terminal alloc] initWithTerminalData:theTerminalRawData terminalNumber:count withLevel:curLevel];
        [theTerminalArray addObject:theTerm];
        theCursor += (terminalLength - 2);
        count++;
    }
#ifdef useDebugingLogs
    NSLog(@"Number Of Terminals Loaded: %d", [theTerminalArray count]);
#endif
}

#pragma mark -

-(void)getTag:(long)theTag theLevel:(short)theLevel theCurrentLevelObject:(LELevelData *)curLevel
{
    BOOL GoOn, foundTheTag;
    long this_offset;
    //NSMutableArray *theDataToReturn = nil;
//    NSString *theTagAsString;
//
//    theTagAsString = [[NSString alloc] init];
    
    //Set the cursor to the first byte of the level
    theCursor = myLevelHeaders[theLevel-1].offsetToStart;
    
    //Set it so that it uses current cursor location and
    //does not try to use this_offset...
    this_offset = -1;
    
    GoOn = YES;
    foundTheTag = NO;
    
    while (GoOn == YES  && myLevelHeaders[theLevel - 1].length > (this_offset - myLevelHeaders[theLevel - 1].offsetToStart)) {
        long next_offset, length, offset, tag;
        
        if (this_offset != -1)
            theCursor = this_offset;
        else
            this_offset = theCursor;
       
        tag = [self getLong];
        next_offset = [self getLong];
        length = [self getLong];
        offset = [self getLong];
        
        if (tag == theTag || (theTag == 'PNTS' && tag == 'EPNT') || (theTag == 'plat' && tag == 'PLAT')) {
            //int theCount = 0;
            switch (tag) {
                case 'PNTS':
                    [self getThePointsAtOffset:(this_offset + 16)
                                    withLength:length withLevel:curLevel regularPoints:YES];
                    foundTheTag = YES;
                    break;
                case 'EPNT':
                    [self getThePointsAtOffset:(this_offset + 16)
                                    withLength:length withLevel:curLevel regularPoints:NO];
                    foundTheTag = YES;
                    break;
                case 'LINS':
                    [self getTheLinesAtOffset:(this_offset + 16)
                                   withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                case 'POLY':
                    [self getThePolygonsAtOffset:(this_offset + 16)
                                      withLength:length withLevel:curLevel];
                    foundTheTag = YES; // <-- DEAL WITH THIS
                    break;
                case 'OBJS':
                    [self getTheMapObjectsAtOffset:(this_offset + 16)
                                        withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                case 'SIDS':
                    [self getTheSidesAtOffset:(this_offset + 16)
                                   withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                    
                case 'LITE':
                    [self getTheLightsAtOffset:(this_offset + 16)
                                    withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                    
                case 'NOTE':
                    [self getTheAnnotationsAtOffset:(this_offset + 16)
                                         withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                    
                case 'medi':
                    [self getTheMediaAtOffset:(this_offset + 16)
                                   withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                    
                case 'ambi':
                    [self getTheAmbientSoundsAtOffset:(this_offset + 16)
                                           withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                    
                case 'plat':
                    [self getTheStaticPlatformsAtOffset:(this_offset + 16)
                                             withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                case 'PLAT':
                    [self getTheDynamicPlatformsAtOffset:(this_offset + 16)
                                              withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                    
                case 'plac':
                    [self getTheItemPlacementAtOffset:(this_offset + 16)
                                           withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                    
                case 'bonk':
                    [self getTheRandomSoundsAtOffset:(this_offset + 16)
                                          withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
                    
                case 'term':
                    [self getTheTerminalsAtOffset:(this_offset + 16)
                                       withLength:length withLevel:curLevel];
                    foundTheTag = YES;
                    break;
            } //End switch (theTag)
            
            GoOn = NO;
            
            //if (theDataToReturn != nil)
            //[theDataToReturn retain];
            
            return;
            
        } // End if (tag == theTag)
        
        
        if (next_offset == 0 && !foundTheTag) {
#ifdef useDebugingLogs
            NSLog(@"Importent:  Level %d did not have the tag...", theLevel);
#endif
            //[theDataToReturn release];
            return;
        }
        
        
        this_offset = myLevelHeaders[theLevel-1].offsetToStart + next_offset;
        
    } // End while (GoOn == YES)
}

// ***************************** Save Data Functions **********************************
#pragma mark -
#pragma mark ********* Save Data Functions *********

- (void)saveEntryHeader:(OSType)tag next_offset:(long)nextOffset length:(long)length offset:(long)offset
{
    [self saveLong:tag];
    [self saveLong:(int)(nextOffset + length + 16)]; // next offset
    [self saveLong:(int)length]; // length
    [self saveLong:(int)offset]; // offset, for inplace expansion of data???
}

- (void)savePointsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 4)];
    
    NSArray *theObjects = [level points];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'PNTS' next_offset:[mapDataToSave length] length:(objCount * 4 /* point length */) offset:0];
    
    for (LEMapPoint *currentObj in theObjects) {
        [self saveShort:[currentObj x]];
        [self saveShort:[currentObj y]];
    }
    
#ifdef useDebugingLogs
    NSLog(@"Saved %d point objects.", objCount);
#endif
}


- (void)saveLinesForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 32)];
    
    NSArray *theObjects = [level lines];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'LINS' next_offset:[mapDataToSave length] length:(objCount * 32 /* line length */) offset:0];
    
    for (LELine *currentObj in theObjects) {
        [self saveShort:[currentObj pointIndex1]];
        [self saveShort:[currentObj pointIndex2]];
        [self saveUnsignedShort:[currentObj flags]];
        [self saveShort:[currentObj length]];
        [self saveShort:[currentObj highestAdjacentFloor]];
        [self saveShort:[currentObj lowestAdjacentCeiling]];
        [self saveShort:[currentObj clockwisePolygonSideIndex]];
        [self saveShort:[currentObj counterclockwisePolygonSideIndex]];
        [self saveShort:[currentObj clockwisePolygonOwner]];
        [self saveShort:[currentObj conterclockwisePolygonOwner]];
        
        [self saveEmptyBytes:12]; //Skip the unused part of each line... :)
    }
    
#ifdef useDebugingLogs
    NSLog(@"Saved %d line objects.", objCount);
#endif
}

- (void)savePolygonsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 128)];
    NSArray *theObjects = [level polygons];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'POLY' next_offset:[mapDataToSave length] length:(objCount * 128 /* poly length */) offset:0];
    
    for (LEPolygon *currentObj in theObjects) {
        [self saveShort:[currentObj type]];
        [self saveUnsignedShort:[currentObj flags]];
        [self saveShort:[currentObj permutation]];
        
        [self saveShort:[currentObj getTheVertexCount]];
        
        [self saveShort:[currentObj vertexIndexesAtIndex:0]];
        [self saveShort:[currentObj vertexIndexesAtIndex:1]];
        [self saveShort:[currentObj vertexIndexesAtIndex:2]];
        [self saveShort:[currentObj vertexIndexesAtIndex:3]];
        [self saveShort:[currentObj vertexIndexesAtIndex:4]];
        [self saveShort:[currentObj vertexIndexesAtIndex:5]];
        [self saveShort:[currentObj vertexIndexesAtIndex:6]];
        [self saveShort:[currentObj vertexIndexesAtIndex:7]];
        
        [self saveShort:[currentObj lineIndexesAtIndex:0]];
        [self saveShort:[currentObj lineIndexesAtIndex:1]];
        [self saveShort:[currentObj lineIndexesAtIndex:2]];
        [self saveShort:[currentObj lineIndexesAtIndex:3]];
        [self saveShort:[currentObj lineIndexesAtIndex:4]];
        [self saveShort:[currentObj lineIndexesAtIndex:5]];
        [self saveShort:[currentObj lineIndexesAtIndex:6]];
        [self saveShort:[currentObj lineIndexesAtIndex:7]];
        
        [self saveShort:[currentObj floorTexture]];
        [self saveShort:[currentObj ceilingTexture]];
        [self saveShort:[currentObj floorHeight]];
        [self saveShort:[currentObj ceilingHeight]];
        [self saveShort:[currentObj floorLightsourceIndex]];
        [self saveShort:[currentObj ceilingLightsourceIndex]];
        
        //[self saveLong:[currentObj area]];
        [self saveLong:0];
        
        //[self saveShort:[currentObj firstObjectIndex]];
        //[self saveShort:[currentObj firstExclusionZoneIndex]];
        //[self saveShort:[currentObj lineExclusionZoneCount]];
        //[self saveShort:[currentObj pointExclusionZoneCount]];
        [self saveShort:-1];
        [self saveShort:0];
        [self saveShort:0];
        [self saveShort:0];
        
        [self saveShort:[currentObj floorTransferMode]];
        [self saveShort:[currentObj ceilingTransferMode]];
        
        //[self saveShort:[currentObj adjacentPolygonIndexesAtIndex:0]];
        //[self saveShort:[currentObj adjacentPolygonIndexesAtIndex:1]];
        //[self saveShort:[currentObj adjacentPolygonIndexesAtIndex:2]];
        //[self saveShort:[currentObj adjacentPolygonIndexesAtIndex:3]];
        //[self saveShort:[currentObj adjacentPolygonIndexesAtIndex:4]];
        //[self saveShort:[currentObj adjacentPolygonIndexesAtIndex:5]];
        //[self saveShort:[currentObj adjacentPolygonIndexesAtIndex:6]];
        //[self saveShort:[currentObj adjacentPolygonIndexesAtIndex:7]];
        [self saveShort:0];
        [self saveShort:0];
        [self saveShort:0];
        [self saveShort:0];
        [self saveShort:0];
        [self saveShort:0];
        [self saveShort:0];
        [self saveShort:0];
        
        //[self saveShort:[currentObj firstNeighborIndex]];
        //[self saveShort:[currentObj neighborCount]];
        [self saveShort:0];
        [self saveShort:0];
        
        //[self saveShort:[currentObj center].x];
        //[self saveShort:[currentObj center].y];
        [self saveShort:0];
        [self saveShort:0];
        
        // NSLog(@"\np\n");	*** 	***	***	***	***	***	***	***	***
        
        [self saveShort:[currentObj sideIndexesAtIndex:0]];
        [self saveShort:[currentObj sideIndexesAtIndex:1]];
        [self saveShort:[currentObj sideIndexesAtIndex:2]];
        [self saveShort:[currentObj sideIndexesAtIndex:3]];
        [self saveShort:[currentObj sideIndexesAtIndex:4]];
        [self saveShort:[currentObj sideIndexesAtIndex:5]];
        [self saveShort:[currentObj sideIndexesAtIndex:6]];
        [self saveShort:[currentObj sideIndexesAtIndex:7]];
        
        [self saveShort:[currentObj floorOrigin].x];
        [self saveShort:[currentObj floorOrigin].y];
        
        [self saveShort:[currentObj ceilingOrigin].x];
        [self saveShort:[currentObj ceilingOrigin].y];
        
        [self saveShort:[currentObj mediaIndex]];
        [self saveShort:[currentObj mediaLightsourceIndex]];
        
        //[self saveShort:[currentObj soundSourceIndexes]];
        [self saveShort:0];
        
        [self saveShort:[currentObj ambientSoundImageIndex]];
        [self saveShort:[currentObj randomSoundImageIndex]];
        
        [self saveEmptyBytes:2]; //Skip the unused part... :)
    }
    
#ifdef useDebugingLogs
    NSLog(@"Saved %d polygon objects.", objCount);
#endif
}

- (void)saveObjectsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 16)];
    NSArray *theObjects = [level theMapObjects];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'OBJS' next_offset:[mapDataToSave length] length:(objCount * 16 /* objs length */) offset:0];
    
    for (LEMapObject *currentObj in theObjects) {
        [self saveShort:[currentObj type]];
        [self saveShort:[currentObj getObjTypeIndex]];
        [self saveShort:[currentObj facing]];
        [self saveShort:[currentObj polygonIndex]];
        [self saveShort:[currentObj x]];
        [self saveShort:[currentObj y]];
        [self saveShort:[currentObj z]];
        [self saveUnsignedShort:[currentObj mapFlags]];
    }
#ifdef useDebugingLogs
    NSLog(@"Saved %d map objects (Monsters, Items, Etc.).", objCount);
#endif
}

- (void)saveSidesForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 64)];
    NSArray *theObjects = [level sides];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'SIDS' next_offset:[mapDataToSave length] length:(objCount * 64 /* objs length */) offset:0];
    
    for (LESide *currentObj in theObjects) {
        struct side_texture_definition theTempSideTextureDefinition;
        struct side_exclusion_zone theTempExclusionZone;
        
        [self saveShort:[currentObj type]];
        [self saveShort:[currentObj flags]];
        
        // ***
        
        theTempSideTextureDefinition = [currentObj primaryTextureStruct];
        
        [self saveShort:theTempSideTextureDefinition.x0];
        [self saveShort:theTempSideTextureDefinition.y0];
        //theTempSideTextureDefinition.texture = [self getShort]; // 3oisudjlifslkf sujdlifj ldsf
        //theCursor -= 2;
        [self saveShort:theTempSideTextureDefinition.texture];
        //[self saveOneByteShort:theTempSideTextureDefinition.textureCollection];
        //[self saveOneByteShort:/*(char)*/theTempSideTextureDefinition.textureNumber]; // *** May Need to Cast It??? ***
        
        // ---
        
        theTempSideTextureDefinition = [currentObj secondaryTextureStruct];
        
        [self saveShort:theTempSideTextureDefinition.x0];
        [self saveShort:theTempSideTextureDefinition.y0];
        //theTempSideTextureDefinition.texture = [self getShort];
        //theCursor -= 2;
        [self saveShort:theTempSideTextureDefinition.texture];
        //[self saveOneByteShort:theTempSideTextureDefinition.textureCollection = [self getOneByteShort]];
        //[self saveOneByteShort:theTempSideTextureDefinition.textureNumber = [self getOneByteShort]];
        
        // ---
        
        theTempSideTextureDefinition = [currentObj transparentTextureStruct];
        
        [self saveShort:theTempSideTextureDefinition.x0];
        [self saveShort:theTempSideTextureDefinition.y0];
        //theTempSideTextureDefinition.texture = [self getShort];
        //theCursor -= 2;
        [self saveShort:theTempSideTextureDefinition.texture];
        //[self saveOneByteShort:theTempSideTextureDefinition.textureCollection];
        //[self saveOneByteShort:theTempSideTextureDefinition.textureNumber];
        
        // ***
        
        theTempExclusionZone = [currentObj exclusionZone];
        
        [self saveShort:theTempExclusionZone.e0.x];
        [self saveShort:theTempExclusionZone.e0.y];
        [self saveShort:theTempExclusionZone.e1.x];
        [self saveShort:theTempExclusionZone.e1.y];
        [self saveShort:theTempExclusionZone.e2.x];
        [self saveShort:theTempExclusionZone.e2.y];
        [self saveShort:theTempExclusionZone.e3.x];
        [self saveShort:theTempExclusionZone.e3.y];
        
        [self saveShort:[currentObj controlPanelType]];
        [self saveShort:[currentObj controlPanelPermutation]];
        
        [self saveShort:[currentObj primaryTransferMode]];
        [self saveShort:[currentObj secondaryTransferMode]];
        [self saveShort:[currentObj transparentTransferMode]];
        
        [self saveShort:[currentObj polygonIndex]];
        [self saveShort:[currentObj lineIndex]];
        
        [self saveShort:[currentObj primaryLightsourceIndex]];
        [self saveShort:[currentObj secondaryLightsourceIndex]];
        [self saveShort:[currentObj transparentLightsourceIndex]];
        
        [self saveLong:[currentObj ambientDelta]];
        
        [self saveEmptyBytes:2]; //Skip the unused part... :)
    }
#ifdef useDebugingLogs
    NSLog(@"Saved %d side objects.", objCount);
#endif
}

- (void)saveLightsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 100)];
    NSArray *theObjects = [level lights];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'LITE' next_offset:[mapDataToSave length] length:(objCount * 100 /* light length */) offset:0];
    
    for (PhLight *currentObj in theObjects) {
        int i;
        
        [self saveShort:[currentObj type]];
        [self saveUnsignedShort:[currentObj flags]];
        
        [self saveShort:[currentObj phase]];
        
        for (i = 0; i < 6; i++)
        {
            [self saveShort:[currentObj functionForState:i]];
            [self saveShort:[currentObj periodForState:i]];
            [self saveShort:[currentObj deltaPeriodForState:i]];
            [self saveLong:[currentObj intensityForState:i]];
            [self saveLong:[currentObj deltaIntensityForState:i]];
        }
        
        [self saveShort:[currentObj tag]];
        
        [self saveEmptyBytes:8]; //Skip the unused part... :)
    }
#ifdef useDebugingLogs
    NSLog(@"Saved %d light objects.", objCount);
#endif
}

- (void)saveNotesForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 72)];
    
    NSArray *theObjects = [level notes];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'NOTE' next_offset:[mapDataToSave length] length:(objCount * 72 /* annotation length */) offset:0];
    
    for (PhAnnotationNote *currentObj in theObjects) {
        [self saveShort:[currentObj type]];
        
        [self saveShort:[currentObj location].x];
        [self saveShort:[currentObj location].y];
        [self saveShort:[currentObj polygonIndex]];
        
        [self saveStringAsChar:[currentObj text] withLength:64];
        
    }
#ifdef useDebugingLogs
    NSLog(@"Saved %d annotation objects.", objCount);
#endif
}

- (void)saveMediasForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 32)];
    NSArray *theObjects = [level media];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'medi' next_offset:[mapDataToSave length] length:(objCount * 32 /* media length */) offset:0];
    
    for (PhMedia *currentObj in theObjects) {
        [self saveShort:[currentObj type]];
        [self saveUnsignedShort:[currentObj flags]];
        
        [self saveShort:[currentObj lightIndex]];
        
        [self saveShort:[currentObj currentDirection]];
        [self saveShort:[currentObj currentMagnitude]];
        
        [self saveShort:[currentObj low]];
        [self saveShort:[currentObj high]];
        
        [self saveShort:[currentObj origin].x];
        [self saveShort:[currentObj origin].y];
        
        [self saveShort:[currentObj height]];
        
        [self saveLong:[currentObj minimumLightIntensity]]; // ??? Should Make Object Pointer ???
        [self saveShort:[currentObj texture]];
        [self saveShort:[currentObj transferMode]];
        
        [self saveEmptyBytes:4]; //Skip the unused part... :)
    }
#ifdef useDebugingLogs
    NSLog(@"Saved %d media (water, lava, etc.) objects.", objCount);
#endif
}

- (void)saveAmbientSoundsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 16)];
    NSArray *theObjects = [level ambientSounds];
    long objCount = [theObjects count];
    PhAmbientSound *currentObj = nil;
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'ambi' next_offset:[mapDataToSave length] length:(objCount * 16 /* object length */) offset:0];
    
    for (currentObj in theObjects) {
        [self saveUnsignedShort:[currentObj flags]];
        
        [self saveShort:[currentObj soundIndex]];
        [self saveShort:[currentObj volume]];
        
        [self saveEmptyBytes:10]; //Skip the unused part... :)
    }
#ifdef useDebugingLogs
    NSLog(@"Saved %d ambient sound objects.", objCount);
#endif
}

- (void)saveRandomSoundsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 28)];
    NSArray *theObjects = [level randomSounds];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'bonk' next_offset:[mapDataToSave length] length:(objCount * 32 /* random_sound length */) offset:0];
    
    for (PhRandomSound *currentObj in theObjects) {
        [self saveShort:[currentObj flags]];
        [self saveShort:[currentObj soundIndex]];
        [self saveShort:[currentObj volume]];
        [self saveShort:[currentObj deltaVolume]];
        [self saveShort:[currentObj period]];
        [self saveShort:[currentObj deltaPeriod]];
        [self saveShort:[currentObj direction]];
        [self saveShort:[currentObj deltaDirection]];
        [self saveLong:[currentObj pitch]];
        [self saveLong:[currentObj deltaPitch]];
        [self saveShort:[currentObj phase]];
        
        [self saveEmptyBytes:6]; //Skip the unused part... :)
    }
#ifdef useDebugingLogs
    NSLog(@"Saved %d random sound objects.", objCount);
#endif
}

- (void)saveItemPlacementForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 12)];
    NSArray *theObjects = [level itemPlacement];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'plac' next_offset:[mapDataToSave length] length:(objCount * 12 /* objs length */) offset:0];
    
    for (PhItemPlacement *currentObj in theObjects) {
        [self saveShort:[currentObj flags]];
        
        [self saveShort:[currentObj initialCount]];
        [self saveShort:[currentObj minimumCount]];
        [self saveShort:[currentObj maximumCount]];
        
        [self saveShort:[currentObj randomCount]];
        [self saveUnsignedShort:[currentObj randomChance]];
    }
#ifdef useDebugingLogs
    NSLog(@"Saved %d item placement objects.", objCount);
#endif
}

- (void)savePlatformsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 32)];
    NSArray *theObjects = [level platforms];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    [self saveEntryHeader:'plat' next_offset:[mapDataToSave length] length:(objCount * 32 /* platform length */) offset:0];
    
    for (PhPlatform *currentObj in theObjects) {
        [self saveShort:[currentObj type]];
        [self saveShort:[currentObj speed]];
        [self saveShort:[currentObj delay]];
        [self saveShort:[currentObj maximumHeight]];
        [self saveShort:[currentObj minimumHeight]];
        [self saveUnsignedLong:[currentObj staticFlags]];
        [self saveShort:[currentObj polygonIndex]];
        [self saveShort:[currentObj tag]];
        
        [self saveEmptyBytes:14]; //Skip the unused part... :)
    }
#ifdef useDebugingLogs
    NSLog(@"Saved %d platform objects.", objCount);
#endif
}

- (void)saveTerminalDataForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 28)];
    NSArray *theObjects = [level terminals];
    long objCount = [theObjects count];
    
    if (objCount < 1)
        return;
    
    {
        NSMutableData *theTerminalData = [[NSMutableData alloc] initWithCapacity:0];
        for (Terminal *currentObj in theObjects)
            [theTerminalData appendData:[currentObj getTerminalAsMarathonData]];
        
        [self saveEntryHeader:'term' next_offset:[mapDataToSave length] length:[theTerminalData length] offset:0];
        //    Proably extra blank space for expation, I guess???
        [self saveData:theTerminalData];
    }
}
/*
-(void)saveTag:(long)theTag theLevelNumber:(short)levelNumber theLevelData:(LELevelData *)level
{
    */
    /*
    -(NSMutableArray *)getThePoints;
    -(NSMutableArray *)getTheLines;
    -(NSMutableArray *)getThePolys;
    -(NSMutableArray *)theMapObjects;
    -(NSMutableArray *)sides;
    -(NSMutableArray *)getLights;
    -(NSMutableArray *)getNotes;
    -(NSMutableArray *)getMedia;
    -(NSMutableArray *)getAmbientSounds;
    -(NSMutableArray *)getRandomSounds;
    -(NSMutableArray *)getItemPlacement;
    -(NSMutableArray *)getPlatforms;
    */
    /*
    NSEnumerator *numer;
    //long theCount = 0;
    id currentObj = nil;
    
    NSArray *theObjects = nil;
    long objCount = 0;
    long lengthFromTop = 0;
    long objByteCount = 0;
    
    switch (theTag)
    {
        case 'OBJS':
            break;
        
        case 'SIDS':
            break;
        
        case 'LITE':
            break;
        
        case 'NOTE':   //   getNotes
            break;
        
        case 'medi':
            break;
        
        case 'ambi':
            break;
        
        case 'plat':
            break;
        
        case 'plac':
            break;
            
        case 'bonk':
            break;
        
        case 'term':
            break;
        
    } //End switch (theTag)
}
*/

// ************************ Data Loging Functions *****************************
#pragma mark -
#pragma mark ********* Data Loging Functions *********

-(void)NSLogShortFromData:(NSString *)theMessage
{
    return;
    NSLog(@"%@ : %d", theMessage, [self getShort]);
    theCursor -= 2;
    
}
///NSLogLongFromData
-(void)NSLogUnsignedShortFromData:(NSString *)theMessage
{
    return;
    NSLog(@"%@ : %d", theMessage, [self getUnsignedShort]);
    theCursor -= 2;
}

-(void)NSLogPointFromData:(NSString *)theMessage
{
    return;
    NSLog(@"%@ ->   x: %d   y: %d", theMessage, [self getShort], [self getShort]);
    theCursor -= 4;
}

-(void)NSLogLongFromData:(NSString *)theMessage
{
    return;
    NSLog(@"%@ : %d", theMessage, [self getLong]);
    theCursor -= 4;
}

@end
