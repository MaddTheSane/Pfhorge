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
    NSMutableData *theMaraAlephFormatedData = [[theTmpMarathonMap saveLevelAndGetMapNSData:theLevel levelToSaveIn:1] retain];
    [theTmpMarathonMap release];
    return [theMaraAlephFormatedData autorelease];
}

+ (NSMutableData *)mergeScenarioToMarathonMapFile:(PhPfhorgeScenarioLevelDoc *)theScenario
{
    LEMapData *theTmpMarathonMap = [[LEMapData alloc] init];
    NSMutableData *theMaraAlephFormatedData = [[theTmpMarathonMap mergeScenario:theScenario] retain];
    [theTmpMarathonMap release];
    return [theMaraAlephFormatedData autorelease];
}

+ (NSMutableArray *)convertMarathonDataToArchived:(NSData *)theData levelNames:(NSMutableArray *)theLevelNamesEXP
{
    // NOTE: Check for (theTmpMarathonMap == nil)
    LEMapData *theTmpMarathonMap = [[LEMapData alloc] initWithMapNSData:theData];
    long numberOfLevels = [theTmpMarathonMap getNumberOfLevels];
    NSMutableArray *theLevelNames = [theTmpMarathonMap getLevelNames];
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
    
    for (i = 1; i <= numberOfLevels; i++)
    {
        LELevelData *currentLevel;
        NSData *theLevelMapData = nil;
        NSMutableData *entireMapData = [[NSMutableData alloc] initWithCapacity:12];
        
        [progress setStatusText:[NSString stringWithFormat:@"Converting \"%@\"...", [theLevelNames objectAtIndex:(i - 1)], nil]];
        
        [progress setSecondMinProgress:0.0];
        [progress setSecondMaxProgress:100.0];
        [progress setSecondProgressPostion:0.0];
        [progress setSecondStatusText:@"Loading Level, Please Wait..."];
        
        [progress useSecondBarOnly:YES];
        currentLevel = [theTmpMarathonMap getLevel:i log:NO];
        [progress useSecondBarOnly:NO];
        if (currentLevel == nil)
        {
            SEND_ERROR_MSG_TITLE(@"Could not convert one of the levels...",
                                 @"Converting Error");
            continue;
        }
        
        [progress setSecondStatusText:@"Archiving Level Into Binary Data..."];
        [progress increaseSecondProgressBy:5.0];
        
        theLevelMapData = [NSArchiver archivedDataWithRootObject:currentLevel];
        
        [progress setSecondStatusText:@"Saving Level..."];
        [progress increaseSecondProgressBy:5.0];
        
        [entireMapData appendBytes:&theVersionNumber length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig1 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig2 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig3 length:4];
        
        [entireMapData appendData:theLevelMapData];
        
        [theArchivedLevels addObject:entireMapData];
        [theLevelNamesEXP addObject:[theLevelNames objectAtIndex:(i - 1)]];
        
        [currentLevel release];
        
        [progress increaseProgressBy:1.0];
    }
    
    return [theArchivedLevels autorelease];
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
        [mapData retain];
    }
    else {
        //numberOfLevels = 909;
        [self autorelease];
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
      
    for (i = 0; i < levelCount; i++)
    {
        NSString *fileName = [scenarioData getLevelPathForLevel:i];
        NSData *theFileData = [[NSFileManager defaultManager] contentsAtPath:fileName];
        NSMutableData *tempData = [[NSMutableData alloc] initWithCapacity:200000];
        
        theLevel =	[[NSUnarchiver unarchiveObjectWithData:
                        [theFileData subdataWithRange:NSMakeRange(10 ,([theFileData length] - 10))]] retain];
        
        mapDataToSave = tempData;
        [self exportLevelDataToMarathonFormat:theLevel];
        
        mapDataToSave = levelHeaderData;
        [self saveLevelHeaders:theLevel 
                usingMapDataSize:[tempData length]
                usingLocation:([levelData length] + 128)
		forLevelIndex:i];
        
        [levelData appendData:tempData];
        [tempData release];
    }
    
    mapDataToSave = mainHeaderData;
    [self saveMainMapHeaderForLevels:levelCount usingMapDataSize:[levelData length]];
    
    mapDataToSave = nil;
    
    [mainHeaderData appendData:levelData];
    [mainHeaderData appendData:levelHeaderData];
    
    [levelData release];
    [levelHeaderData release];
    
    
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
    
    return [mainHeaderData autorelease];
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
    long projectedLevelByteCount = [self getByteCountForLevel:level];
    long levelLength;
    NSMutableData *levelData;
    NSMutableData *levelHeaderData;
    NSMutableData *mapHeaderData;
    NSMutableData *entireMapData;
    
    #ifdef useDebugingLogs
        NSLog(@"save projectedLevelByteCount: %d", projectedLevelByteCount);
    #endif
    mapDataToSave = [[NSMutableData alloc] initWithCapacity:500 * 1000];
    
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
    
    [mapHeaderData release];
    [levelData release];
    [levelHeaderData release];
    
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
    
    return [entireMapData autorelease];
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
    if (logInfo == YES)
   {
        [progress setStatusText:@"Setting Level Pointers..."];
        [progress increaseProgressBy:5.0];
    }
    
   /*
     //set the pointers for the point objects...
    [LEMapPoint setTheMapLinesST:[theLevel getTheLines]];
    [LEMapPoint setTheMapObjectsST:[theLevel getTheMapObjects]];
    [LEMapPoint setTheMapPointsST:[theLevel getThePoints]];
    [LEMapPoint setTheMapPolysST:[theLevel getThePolys]];
   
    //set the pointers for the line objects...
    [LELine setTheMapLinesST:[theLevel getTheLines]];
    [LELine setTheMapObjectsST:[theLevel getTheMapObjects]];
    [LELine setTheMapPointsST:[theLevel getThePoints]];
    [LELine setTheMapPolysST:[theLevel getThePolys]];
    [LELine setTheMapSidesST:[theLevel getSides]];
    
    //Set the pointers for the poly objects...
    [LEPolygon setTheMapLinesST:[theLevel getTheLines]];
    [LEPolygon setTheMapObjectsST:[theLevel getTheMapObjects]];
    [LEPolygon setTheMapPointsST:[theLevel getThePoints]];
    [LEPolygon setTheMapPolysST:[theLevel getThePolys]];
    [LEPolygon setTheMapLightsST:[theLevel getLights]];
    
    //Sides
    [LESide setTheMapLightsST:[theLevel getLights]];
    
    //Objects
    [LEMapObject setTheMapPolysST:[theLevel getThePolys]];
    */
    
    [theLevel setEnvironment_code:environment_code[levelToGet - 1]];
    [theLevel setPhysics_model:physics_model[levelToGet - 1]];
    [theLevel setSong_index:song_index[levelToGet - 1]];
    [theLevel setMission_flags:mission_flags[levelToGet - 1]];
    [theLevel setEnvironment_flags:environment_flags[levelToGet - 1]];
    
    
    /*if (setupPointerArraysDurringLoading)
    {
        NSArray *points = [theLevel getThePoints];
        NSArray *lines = [theLevel getTheLines];
        NSArray *polygons = [theLevel getThePolys];
        NSArray *mapObjects = [theLevel getTheMapObjects];
        NSArray *sides = [theLevel getSides];
        NSArray *lights = [theLevel getLights];
        NSArray *notes = [theLevel getNotes];
        NSArray *media = [theLevel getMedia];
        NSArray *ambientSounds = [theLevel getAmbientSounds];
        NSArray *randomSounds = [theLevel getRandomSounds];
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
    
    if (logInfo == YES)
    {
        [progress setStatusText:@"Loading Terminals..."];
        [progress increaseProgressBy:4.0];
    }
    //   Get the random sounds (like driping sounds) for this level... ('bonk')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading terminals from file for level %d*", levelToGet);
    #endif
    [self getTag:'term' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Points..."];
        [progress increaseProgressBy:5.0];
    }
    
    //   Get the points for this level... ('PNTS')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading points from file for level %d*", levelToGet);
    #endif
    [self getTag:'PNTS' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Lines..."];
        [progress increaseProgressBy:5.0];
    }
    //   Get the lines for this level... ('LINS')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading lines from file for level %d*", levelToGet);
    #endif
    [self getTag:'LINS' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Polygons..."];
        [progress increaseProgressBy:5.0];
    }
    //   Get the polys for this level... ('POLY')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading poly's from file for level %d*", levelToGet);
    #endif
    [self getTag:'POLY' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Objects..."];
        [progress increaseProgressBy:5.0];
    }
    //   Get the objects for this level... ('OBJS')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading objects from file for level %d*", levelToGet);
    #endif
    [self getTag:'OBJS' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Sides..."];
        [progress increaseProgressBy:5.0];
    }
    //   Get the sides for this level... ('SIDS')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading sides from file for level %d*", levelToGet);
    #endif
    [self getTag:'SIDS' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Lights..."];
        [progress increaseProgressBy:5.0];
    }
    //   Get the lights for this level... ('LITE')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading lights from file for level %d*", levelToGet);
    #endif
    [self getTag:'LITE' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Annotations..."];
        [progress increaseProgressBy:5.0];
    }
    //   Get the annotations (notes) for this level... ('NOTE')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading annotations from file for level %d*", levelToGet);
    #endif
    [self getTag:'NOTE' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Liquids..."];
        [progress increaseProgressBy:5.0];
    }
    //   Get the liquids (media) for this level... ('medi')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading liquids from file for level %d*", levelToGet);
    #endif
    [self getTag:'medi' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Ambient Sounds..."];
        [progress increaseProgressBy:4.0];
    }
    //   Get the ambient sounds (like the wind) for this level... ('ambi')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading ambient sounds from file for level %d*", levelToGet);
    #endif
    [self getTag:'ambi' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    // *** New ***
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Platforms..."];
        [progress increaseProgressBy:4.0];
    }
     //   Get the platforms (like the wind) for this level... ('plat')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading platforms from file for level %d*", levelToGet);
    #endif
    [self getTag:'plat' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Item Placement Entrys..."];
        [progress increaseProgressBy:4.0];
    }
    //   Get the item placment entrys (like the wind) for this level... ('plac')
    #ifdef useDebugingLogs
        NSLogs(@"*Loading item placment data from file for level %d*", levelToGet);
    #endif
    [self getTag:'plac' theLevel:levelToGet theCurrentLevelObject:theLevel];
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Loading Random Sounds..."];
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
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Geting Level Information..."];
        [progress increaseProgressBy:5.0];
    }
    
    // The following just transfers the address to a pointer, but
    // you might want to actully copy the data over, or work
    // with the retain messages, because when this object (LEMapData)
    // gets deallocated, it may dealocate the level name which
    // the theLevel (LELevelData) has a pointer to...
    [theLevel setLevel_name:[levelNames objectAtIndex:(levelToGet - 1)]];
    
    [theLevel setEntry_point_flags:entry_point_flags[levelToGet - 1]];
    #ifdef useDebugingLogs
        NSLogs(@"The Levels Entry Point Flag Value: %d", entry_point_flags[levelToGet - 1]);
        
        NSLogs(@"*Phase 1 Loading Completed For Level %d!*", levelToGet);
        NSLogs(@"*Begining Phase 2 Loading For Level %d...*", levelToGet);
    #endif
    
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Setting Object Pointers From Array Using Index Numbers..."];
        [progress increaseProgressBy:3.0];
    }
    
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getTheLines]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getTheMapObjects]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getThePoints]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getThePolys]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getSides]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getLights]];
    //[self performSelector:@selector(updateObjectsFromIndexes) withEachObjectInArray:[theLevel getNotes]];
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

    if (logInfo == YES)
   {
        [progress setStatusText:@"Testing Every Polygon For Concavness..."];
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
        [progress setStatusText:@"Seting up default layers..."];
    
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
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Compiling And Caching List Of Custom Names In Level..."];
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
    
    if (logInfo == YES)
   {
        [progress setStatusText:@"Returning Level To Map Document Controller..."];
        [progress increaseProgressBy:1.0];
    }
    
    //Return the level, with all of its data, etc...
    return theLevel;
}

- (long)getByteCountForLevel:(LELevelData *)level
{
    int pointsByteCount = ([[level getThePoints] count]) * 4; // 16
    int linesByteCount = ([[level getTheLines] count]) * 32; // 32
    int polygonsByteCount = ([[level getThePolys] count]) * 128; // 128
    int mapObjectsByteCount = ([[level getTheMapObjects] count]) * 16; // 16
    int sidesByteCount = ([[level getSides] count]) * 64; // 64
    int lightsByteCount = ([[level getLights] count]) * 100; // 100
    //int notesByteCount = ([[level getNotes] count]) * 72; // 72
    int mediaByteCount = ([[level getMedia] count]) * 32; // 32
    int ambientSoundsByteCount = ([[level getAmbientSounds] count]) * 16; // 16
    int randomSoundsByteCount = ([[level getRandomSounds] count]) * 32; // 32
    int itemPlacmentByteCount = ([[level getItemPlacement] count]) * 12; // 12
    int platformsByteCount = ([[level getPlatforms] count]) * 32; // 32
    
    int byteCount = pointsByteCount + linesByteCount + polygonsByteCount +
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
    int mapObjectsByteCount = ([[level getTheMapObjects] count]) * 16; // 16
    int sidesByteCount = ([[level getSides] count]) * 64; // 64
    int lightsByteCount = ([[level getLights] count]) * 100; // 100
    int notesByteCount = ([[level getNotes] count]) * 72; // 72
    int mediaByteCount = ([[level getMedia] count]) * 32; // 32
    int ambientSoundsByteCount = ([[level getAmbientSounds] count]) * 16; // 16
    int randomSoundsByteCount = ([[level getRandomSounds] count]) * 32; // 32
    int itemPlacmentByteCount = ([[level getItemPlacement] count]) * 12; // 12
    int platformsByteCount = ([[level getPlatforms] count]) * 32; // 32
  */  
  
    BOOL foundTheTag;
    long this_offset;
    //NSMutableArray *theDataToReturn = nil;
    NSString *theTagAsString;
    
    theTagAsString = [[NSString alloc] init];
    
    //Set the cursor to the first byte of the level
    theCursor = myLevelHeaders[theLevel-1].offsetToStart;
    
    //Set it so that it uses current cursor location and
    //does not try to use this_offset...
    this_offset = -1;
    foundTheTag = NO;
    
    while (myLevelHeaders[theLevel - 1].length > (this_offset - myLevelHeaders[theLevel - 1].offsetToStart))
    {        
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
        
        switch (tag)
        {  
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
                if (next_offset == 0 /* && !foundTheTag */)
                {
                    #ifdef useDebugingLogs
                        NSLog(@"   PreAllocation Completed...");
                    #endif
                    //[theDataToReturn release];
                    return;
                }
                this_offset = myLevelHeaders[theLevel-1].offsetToStart + next_offset;
                continue;
            
        } //End switch (theTag)
        
        if (foundTheTag)
        {
            int i;
            NSString *theTmpTagString = CFBridgingRelease(UTCreateStringForOSType(tag));
            [theArray removeAllObjects];
            
            #ifdef useDebugingLogs
                NSLog(@"   PreAllocating %d objects for tag '%@'", amountOfObjects, theTmpTagString);
            #endif
            
            for (i = 0; i < amountOfObjects; i++)
            {
                id theObj = [[theClass alloc] init];
                [theArray addObject:theObj];
                
                [level setUpArrayPointersFor:theObj];
                
                [theObj release];
            }
        }
        
        if (next_offset == 0 /* && !foundTheTag */)
        {
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

- (long)getNumberOfLevels
{
    return myMainMapHeader.numberOfLevels;
}

- (NSMutableArray *)getLevelNames
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

-(id)getShortObjectFrom:(NSArray *)theArray
{
    short theShortNum;
    int theArrayCount = [theArray count];
    [mapData getBytes:&theShortNum range:NSMakeRange(theCursor,2)];
	theShortNum = CFSwapInt16BigToHost(theShortNum);
    theCursor += 2;
    
    if ((theShortNum >= theArrayCount))
    {
        NSLog(@"Bounding Error: %d   Array Count: %d", theShortNum, theArrayCount);
        if (!alreadyGaveBoundingError)
            SEND_ERROR_MSG(@"Bad Map Data, Bounding Error: Map Trying To Refrence Beyond The Bounds Of An Array! Setting It To Last Item In Array...");
        alreadyGaveBoundingError = YES;
        return [theArray lastObject];
    }
    else
        return (theShortNum < 0) ? (nil) : ([theArray objectAtIndex:theShortNum]);
}

-(id)getShortZeroIsNilIfOverObjectFrom:(NSArray *)theArray
{
    short theShortNum;
    int theArrayCount = [theArray count];
    [mapData getBytes:&theShortNum range:NSMakeRange(theCursor,2)];
	theShortNum = CFSwapInt16BigToHost(theShortNum);
    theCursor += 2;
    
    if (theShortNum < 1 && theArrayCount < 1)
    {
        return nil;
    }
    else if ((theShortNum >= theArrayCount))
    {
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
    else
        return (theShortNum < 0) ? (nil) : ([theArray objectAtIndex:theShortNum]);
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

- (id)getChar:(unsigned)theCharAmount
 {
    int theCharLength = theCharAmount;
    char theChar[theCharLength];
    const char *theCharConstPntr;
    int i;
    NSString *theTmpCharString;
    for (i = 0; i < theCharLength; i++)
    {
        char theLetter;
        //[mapData deserializeDataAt:&theLetter ofObjCType:@encode(char) atCursor:&theCursor context:nil];
        [mapData getBytes:&theLetter range:NSMakeRange(theCursor,1)];
        theCursor++;
        theChar[i] = theLetter;
    }
    theCharConstPntr = theChar;
    theTmpCharString = @(theCharConstPntr); //length:theCharAmount];
    
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
    const char *theStringAsCString = [v UTF8String];
    int theStringLength = strlen(theStringAsCString);
    char nullChar = '\0';
    
    if (length < 0)
    {
        NSLog(@"••• ERROR: Tried to saved a string of negitive length in LEMapData->saveStringAsChar:");
        return;
    }
    
    if (theStringLength >= length)
        [mapDataToSave appendBytes:theStringAsCString length:(length-1)];
    else
    {
        [mapDataToSave appendBytes:theStringAsCString length:theStringLength];
        [self saveEmptyBytes:((length - theStringLength) - 1)];
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
    
    [self saveLong:(size+128)];
    
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
    
    levelNames = [NSMutableArray arrayWithCapacity:[self getNumberOfLevels]];
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
    
    NSString *theLevelName = [level getLevel_name];
    
    [self saveShort:[level getMission_flags]];
    [self saveShort:[level getEnvironment_flags]];
    [self saveLong:[level getEntry_point_flags]];
    
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
    
    NSString *theLevelName = [level getLevel_name];
    
    [self saveLong:'Minf'];
    // Going to be zero, for now I am assuming that this is the last tag... :)
    [self saveLong:0/*(lengthFromTop + objByteCount + 1)*/]; // next offset
    [self saveLong:objByteCount]; // length
    [self saveLong:0]; // offset, for inplace expansion of data???
    
    
    [self saveShort:[level getEnvironment_code]];
    [self saveShort:[level getPhysics_model]];
    [self saveShort:[level getSong_index]];
    [self saveShort:[level getMission_flags]];
    [self saveShort:[level getEnvironment_flags]];
    
    [self saveEmptyBytes:8];
    
    
    
    [self saveStringAsChar:theLevelName withLength:66];
    //[self saveEmptyBytes:60];
    
    [self saveLong:[level getEntry_point_flags]];
    
    #ifdef useDebugingLogs
        NSLog(@"Saved the level info object ('Minf'). SIZE: %d", [mapDataToSave length]);
    #endif
    return YES;
}

- (BOOL)saveLevelHeaders:(LELevelData *)level usingMapDataSize:(long)size usingLocation:(long)loc forLevelIndex:(short)index
{
    [self saveLong:loc];
    [self saveLong:size];
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
    
    levelNames = [NSMutableArray arrayWithCapacity:[self getNumberOfLevels]];
    [levelNames retain];
    
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
    environment_flags = (short *) malloc (sizeof(short) * [self getNumberOfLevels]);
    environment_code = (short *) malloc (sizeof(short) * [self getNumberOfLevels]);
    physics_model = (short *) malloc (sizeof(short) * [self getNumberOfLevels]);
    song_index = (short *) malloc (sizeof(short) * [self getNumberOfLevels]);
    mission_flags = (short *) malloc (sizeof(short) * [self getNumberOfLevels]);
    entry_point_flags = (long *) malloc (sizeof(long) * [self getNumberOfLevels]);
    
    for (i = 0; i < [self getNumberOfLevels]; i++)
    {
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
        while (GoOn == YES /*&& theCursor < (theCursor + myLevelHeaders[i].length) */) // Logicaly check this out some time!!!
        {
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
    myLevelHeaders = (struct SLevelHeader *) malloc (sizeof(struct SLevelHeader) * [self getNumberOfLevels]);
    
    // Fill out all the array of structures with the header information from the file...
    for (i = 0; i < [self getNumberOfLevels]; i++)
    {
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
    NSArray *thePointArray = [curLevel getThePoints];
    LEMapPoint *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [thePointArray objectEnumerator];
    if (!regPointStyle)
    { // tag == 'EPNT'
    if ((theDataLength % 16)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Extended Points, File Could Be Corupted!");
    }
        while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
        {
            theCursor += 6;
            [theObj setX:[self getShort] Y:[self getShort]];
            //[theObj setX:[self getShort]];
            //[theObj setY:[self getShort]];
            theCursor += 6;
        }
    }
    else
    { //case 'PNTS'
    if ((theDataLength % 4)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Points, File Could Be Corupted!");
    }
        while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
        {
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
{ // *** 'LINS' *** 32 bytes each
    NSArray *theLineArray = [curLevel getTheLines];
    NSArray *thePolyArray = [curLevel getThePolys];
    NSArray *theSideArray = [curLevel getSides];
    NSArray *thePointArray = [curLevel getThePoints];
    LELine *theObj;
    NSEnumerator *numer;
    int i = -1;
    
    theCursor = theDataOffset;
    numer = [theLineArray objectEnumerator];
    if ((theDataLength % 32)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Ambient Sounds, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        i++;
        ///NSLog(@"\n			*** *** *** Line %d *** *** ***\n", i);
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setMapPoint1"];
        #endif
        
        //[theObj setMapPoint1:[self getShortObjectFrom:thePointArray]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setMapPoint2"];
        #endif
        //[theObj setMapPoint2:];
        [theObj setMapPoint1:[self getShortObjectFrom:thePointArray] mapPoint2:[self getShortObjectFrom:thePointArray]];
        
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
        [theObj setClockwisePolygonSideObject:[self getShortObjectFrom:theSideArray]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setCounterclockwisePolygonSideObject"];
        #endif
        [theObj setCounterclockwisePolygonSideObject:[self getShortObjectFrom:theSideArray]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setClockwisePolygonObject"];
        #endif
        [theObj setClockwisePolygonObject:[self getShortObjectFrom:thePolyArray]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setConterclockwisePolygonObject"];
        #endif
        [theObj setConterclockwisePolygonObject:[self getShortObjectFrom:thePolyArray]];
        
        theCursor += 12; //Skip the unused part of each line... :)
    }
    return;
}

-(void)getThePolygonsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{ // *** 'POLY' *** 128 bytes each
    NSArray *thePolyArray = [curLevel getThePolys];
    NSArray *theLightArray = [curLevel getLights];
    NSArray *theSideArray = [curLevel getSides];
    NSArray *theLineArray = [curLevel getTheLines];
    NSArray *thePointArray = [curLevel getThePoints];
    NSArray *theMediaArray = [curLevel getMedia];
    NSArray *theAmbientArray = [curLevel getAmbientSounds];
    NSArray *thePlatformArray = [curLevel getPlatforms];
    NSArray *theRandomArray = [curLevel getRandomSounds];
    NSArray *theObjectArray = [curLevel getTheMapObjects];
    
    int countOfPlatformArray = [thePlatformArray count];
    int i, c = -1, vertextCount;
    
    LEPolygon *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [thePolyArray objectEnumerator];
    if ((theDataLength % 128)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Polygons, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        short thePermutation;
        short theType;
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
        
        if (thePermutation < 0)
        {
            thePerObj = nil;
        }
        else
        {
            switch (theType)
            {
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
        
        for (i = 0; i < 8; i++)
        {
            if (i < vertextCount)
            {
                #ifdef useDebugingLogs
            [self NSLogShortFromData:@"[theObj setVertexWithObject:[self getShortObjectFrom:thePointArray] i:i]"];
        #endif
                [theObj setVertexWithObject:[self getShortObjectFrom:thePointArray] i:i];
            }
            else
            {
                theCursor += 2;
                [theObj setVertexWithObject:nil i:i];
            }
        }
        
        for (i = 0; i < 8; i++)
        {
            if (i < vertextCount)
            {
                #ifdef useDebugingLogs
            [self NSLogShortFromData:@"[theObj setLinesObject:[self getShortObjectFrom:theLineArray] i:0]"];
        #endif
                [theObj setLinesObject:[self getShortObjectFrom:theLineArray] i:i]; //
            }
            else
            {
                theCursor += 2;
                [theObj setLinesObject:nil i:i];
            }
        }
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setFloor_texture"];
        #endif
        [theObj setFloor_texture:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setCeiling_texture"];
        #endif
        [theObj setCeiling_texture:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setFloor_height:"];
        #endif
        [theObj setFloor_height_no_sides:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setCeiling_height:"];
        #endif
        [theObj setCeiling_height_no_sides:[self getShort]];
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setFloor_lightsourceObject"];
        #endif
        [theObj setFloor_lightsourceObject:[self getShortObjectFrom:theLightArray]]; //
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setCeiling_lightsourceObject"];
        #endif
        [theObj setCeiling_lightsourceObject:[self getShortObjectFrom:theLightArray]]; //
        
        #ifdef useDebugingLogs
            [self NSLogLongFromData:@"setArea"];
        #endif
        [theObj setArea:[self getLong]];
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setFirst_objectObject"];
        #endif
        [theObj setFirst_objectObject:[self getShortZeroIsNilIfOverObjectFrom:theObjectArray]]; //
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setFirst_exclusion_zone_index"];
        #endif
        [theObj setFirst_exclusion_zone_index:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setLine_exclusion_zone_count"];
        #endif
        [theObj setLine_exclusion_zone_count:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setPoint_exclusion_zone_count"];
        #endif
        [theObj setPoint_exclusion_zone_count:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setFloor_transfer_mode"];
        #endif
        [theObj setFloor_transfer_mode:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setCeiling_transfer_mode"];
        #endif
        [theObj setCeiling_transfer_mode:[self getShort]];
        
        for (i = 0; i < 8; i++)
        {
            if (i < vertextCount)
            {
                #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setAdjacent_polygonObject:[self getShortObjectFrom:thePolyArray] i:0]"];
        #endif
                [theObj setAdjacent_polygonObject:[self getShortZeroIsNilIfOverObjectFrom:thePolyArray] i:i]; //
            }
            else
            {
                theCursor += 2;
                [theObj setAdjacent_polygonObject:nil i:i];
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
        //[theObj setFirst_neighborObject:[self getShortObjectFrom:thePolyArray]]; //
        
        // I think this is the number of polygons
        // within One World Unit of polygon
        // boarders?  Or is it from the center
        // of the polygon?  I am going with
        // the boarders for right now...
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setNeighbor_count"];
        #endif
        [theObj setNeighbor_count:[self getShort]];
        
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
                [theObj setSidesObject:[self getShortZeroIsNilIfOverObjectFrom:theSideArray] i:i]; //
            }
            else
            {
                theCursor += 2;
                [theObj setSidesObject:nil i:i];
            }
        }
        
        #ifdef useDebugingLogs
            [self NSLogPointFromData:@"setFloor_origin"];
        #endif
        [theObj setFloor_origin:NSMakePoint([self getShort], [self getShort])];
        #ifdef useDebugingLogs
            [self NSLogPointFromData:@"setCeiling_origin"];
        #endif
        [theObj setCeiling_origin:NSMakePoint([self getShort], [self getShort])];
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setMediaObject"];
        #endif
        [theObj setMediaObject:[self getShortObjectFrom:theMediaArray]]; //
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setMedia_lightsourceObject"];
        #endif
        [theObj setMedia_lightsourceObject:[self getShortObjectFrom:theLightArray]]; //
        
        //[theObj setSound_sources:[self getShort]]; // *** I am not sure about this one ***
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"blank"];
        #endif
        theCursor += 2; // Skip the sound sources for right now...
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setAmbient_soundObject"];
        #endif
        [theObj setAmbient_soundObject:[self getShortObjectFrom:theAmbientArray]]; //
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setRandom_soundObject"];
        #endif
        [theObj setRandom_soundObject:[self getShortZeroIsNilIfOverObjectFrom:theRandomArray]]; //
        
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
{	// *** 'OBJS' *** 16 bytes each
    NSArray *theObjectArray = [curLevel getTheMapObjects];
    NSArray *thePolyArray = [curLevel getThePolys];
    LEMapObject *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theObjectArray objectEnumerator];
    if ((theDataLength % 16)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Map Objects, File Could Be Corupted!");
    }
    
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        [theObj setType:[self getShort]];
        [theObj setIndex:[self getShort]];
        [theObj setFacing:[self getShort]];
        [theObj setPolygonObject:[self getShortObjectFrom:thePolyArray]];
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
{	// *** 'SIDS' *** 64 bytes each
    NSArray *theSideArray = [curLevel getSides];
    NSArray *theLightArray = [curLevel getLights];
    NSArray *theLineArray = [curLevel getTheLines];
    NSArray *thePolyArray = [curLevel getThePolys];
    
    LESide *theObj;
    NSEnumerator *numer;
    
    int i = -1;
    
    theCursor = theDataOffset;
    numer = [theSideArray objectEnumerator];
    if ((theDataLength % 64)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Sides, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
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
        [theObj setPrimary_texture:theTempSideTextureDefinition];
        
        theTempSideTextureDefinition.x0 = [self getShort];
        theTempSideTextureDefinition.y0 = [self getShort];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"S texture"];
        #endif
        theTempSideTextureDefinition.texture = [self getShort];
        theCursor -= 2;
        theTempSideTextureDefinition.textureCollection = [self getOneByteShort];
        theTempSideTextureDefinition.textureNumber = [self getOneByteShort];
        [theObj setSecondary_texture:theTempSideTextureDefinition];
        
        theTempSideTextureDefinition.x0 = [self getShort];
        theTempSideTextureDefinition.y0 = [self getShort];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"T texture"];
        #endif
        theTempSideTextureDefinition.texture = [self getShort];
        theCursor -= 2;
        theTempSideTextureDefinition.textureCollection = [self getOneByteShort];
        theTempSideTextureDefinition.textureNumber = [self getOneByteShort];
        [theObj setTransparent_texture:theTempSideTextureDefinition];
        
        
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
        
        [theObj setExclusion_zone:theTempExclusionZone];
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setControl_panel_type"];
        #endif
        [theObj setControl_panel_type:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setControl_panel_permutation"];
        #endif
        [theObj setControl_panel_permutation:[self getShort]];
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setPrimary_transfer_mode"];
        #endif
        [theObj setPrimary_transfer_mode:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setSecondary_transfer_mode"];
        #endif
        [theObj setSecondary_transfer_mode:[self getShort]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setTransparent_transfer_mode"];
        #endif
        [theObj setTransparent_transfer_mode:[self getShort]];
        
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setPolygon_object"];
        #endif
        [theObj setPolygon_object:[self getShortObjectFrom:thePolyArray]];
        #ifdef useDebugingLogs
            [self NSLogShortFromData:@"setLine_object"];
        #endif
        [theObj setLine_object:[self getShortObjectFrom:theLineArray]];
        
        #ifdef useDebugingLogs
            [self NSLogLongFromData:@"setPrimary_lightsource_object"];
        #endif
        [theObj setPrimary_lightsource_object:[self getShortObjectFrom:theLightArray]];
        #ifdef useDebugingLogs
            [self NSLogLongFromData:@"setSecondary_lightsource_object"];
        #endif
        [theObj setSecondary_lightsource_object:[self getShortObjectFrom:theLightArray]];
        #ifdef useDebugingLogs
            [self NSLogLongFromData:@"setTransparent_lightsource_object"];
        #endif
        [theObj setTransparent_lightsource_object:[self getShortObjectFrom:theLightArray]];
        
        #ifdef useDebugingLogs
            [self NSLogLongFromData:@"setAmbient_delta"];
        #endif
        [theObj setAmbient_delta:[self getLong]];
        
        theCursor+=2; // Skip the unused short
    }
    return;
}

-(void)getTheLightsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{	// *** 'LITE' *** 100 bytes each
    NSArray *theLightArray = [curLevel getLights];
    PhLight *theObj;
    NSEnumerator *numer;
    int i = 0;
    
    theCursor = theDataOffset;
    numer = [theLightArray objectEnumerator];
    if ((theDataLength % 100)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Lights, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        [theObj setType:[self getShort]];
        [theObj setFlags:[self getUnsignedShort]];
        
        [theObj setPhase:[self getShort]];
        
        for (i = 0; i < 6; i++)
        {
            [theObj setFunction:[self getShort] forState:i];
            [theObj setPeriod:[self getShort]forState:i];
            [theObj setDelta_period:[self getShort] forState:i];
            [theObj setIntensity:[self getLong] forState:i]; 
            [theObj setDelta_intensity:[self getLong] forState:i];
        }
        
        [theObj setTag:[self getShort]]; // May Want To Make It Point To Tag Object
        
        theCursor+=8; // Skip the 4 unused shorts
    }
    return;
}

-(void)getTheAnnotationsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{	// *** 'NOTE' *** 72 bytes each
    NSArray *theAnnotationArray = [curLevel getNotes];
    NSArray *thePolyArray = [curLevel getThePolys];
    PhAnnotationNote *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theAnnotationArray objectEnumerator];
    if ((theDataLength % 72)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Annotation Notes, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        [theObj setType:[self getShort]];
        
        [theObj setLocation:NSMakePoint([self getShort], [self getShort])];
        [theObj setPolygon_object:[self getShortObjectFrom:thePolyArray]];
        
        [theObj setText:[self getChar:64]];
    }
    return;
}

-(void)getTheMediaAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{	// *** 'medi' *** 32 bytes each
    NSArray *theMediaArray = [curLevel getMedia];
    NSArray *theLightArray = [curLevel getLights];
    PhMedia *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theMediaArray objectEnumerator];
    if ((theDataLength % 32)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Medias, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        [theObj setType:[self getShort]];
        [theObj setFlags:[self getUnsignedShort]];
        
        [theObj setLight_object:[self getShortObjectFrom:theLightArray]];
        
        [theObj setCurrent_direction:[self getShort]];
        [theObj setCurrent_magnitude:[self getShort]];
        
        [theObj setLow:[self getShort]];
        [theObj setHigh:[self getShort]];
        
        [theObj setOrigin:NSMakePoint([self getShort], [self getShort])];
        [theObj setHeight:[self getShort]];
        
        [theObj setMinimum_light_intensity:[self getLong]]; // ??? Should Make Object Pointer ???
        [theObj setTexture:[self getShort]];
        [theObj setTransfer_mode:[self getShort]];
        
        theCursor+=4; // Skip the 2 unused shorts
    }
    return;
}

-(void)getTheAmbientSoundsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{	// *** 'ambi' *** 16 bytes each
    NSArray *theAmbientArray = [curLevel getAmbientSounds];
    PhAmbientSound *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theAmbientArray objectEnumerator];
    if ((theDataLength % 16)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Ambient Sounds, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        [theObj setFlags:[self getUnsignedShort]];
        
        [theObj setSound_index:[self getShort]];
        [theObj setVolume:[self getShort]];
        
        theCursor+=10; // Skip the 5 unused shorts
    }
    return;
}

-(void)getTheStaticPlatformsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{	// *** 'plat' *** 32 bytes each   Merged Maps have 'PLAT' ???
    NSArray *thePlatformArray = [curLevel getPlatforms];
    NSArray *thePolyArray = [curLevel getThePolys];
    PhPlatform *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [thePlatformArray objectEnumerator];
    if ((theDataLength % 32)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Static Platforms, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        [theObj setType:[self getShort]];
        [theObj setSpeed:[self getShort]];
        [theObj setDelay:[self getShort]];
        [theObj setmaximum_height:[self getShort]];
        [theObj setminimum_height:[self getShort]];
        [theObj setStatic_flags:[self getUnsignedLong]];
        [theObj setPolygon_object:[self getShortObjectFrom:thePolyArray]];
        [theObj setTag:[self getShort]];
        
        #ifdef useDebugingLogs
        NSLog(@"Platfrom Tag: %d, index: %d", [theObj getTag], [theObj getIndex]);
        #endif
        
        theCursor+=14; // Skip the 7 unused bytes
    }
    return;
}

-(void)getTheDynamicPlatformsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{	// *** 'PLAT' ***
    NSArray *thePlatformArray = [curLevel getPlatforms];
    //NSArray *thePolyArray = [curLevel getThePolys];
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
{	// *** 'plac' *** 12 bytes each
    NSArray *theItemArray = [curLevel getItemPlacement];
    PhItemPlacement *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theItemArray objectEnumerator];
    if ((theDataLength % 12)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Item Placments, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        [theObj setFlags:[self getShort]];
    
        [theObj setInitial_count:[self getShort]];
        [theObj setMinimum_count:[self getShort]];
        [theObj setMaximum_count:[self getShort]];
    
        [theObj setRandom_count:[self getShort]];
        [theObj setRandom_chance:[self getUnsignedShort]];
    }
    return;
}

-(void)getTheRandomSoundsAtOffset:(long)theDataOffset
                    withLength:(long)theDataLength
                    withLevel:(LELevelData *)curLevel
{	// *** 'bonk' *** 32 bytes each
    NSArray *theRandomArray = [curLevel getRandomSounds];
    PhRandomSound *theObj;
    NSEnumerator *numer;
    
    theCursor = theDataOffset;
    numer = [theRandomArray objectEnumerator];
    if ((theDataLength % 32)  > 0)
    {
        NSLog(@"WARNING: Non Integer Number Of Random Sounds, File Could Be Corupted!");
    }
    while (((theDataLength + theDataOffset) > theCursor)
                && (theObj = [numer nextObject]))
    {
        [theObj setFlags:[self getShort]];
        [theObj setSound_index:[self getShort]];
        [theObj setVolume:[self getShort]];
        [theObj setDelta_volume:[self getShort]];
        [theObj setPeriod:[self getShort]];
        [theObj setDelta_period:[self getShort]];
        [theObj setDirection:[self getShort]];
        [theObj setDelta_direction:[self getLong]];
        [theObj setPitch:[self getLong]];
        [theObj setDelta_pitch:[self getShort]];
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
        [theTerm release];
        theCursor += (terminalLength - 2);
        count++;
    }
    #ifdef useDebugingLogs
        NSLog(@"Number Of Terminals Loaded: %d", [theTerminalArray count]);
    #endif
    return;
}

#pragma mark -

-(void)getTag:(long)theTag theLevel:(short)theLevel theCurrentLevelObject:(LELevelData *)curLevel
{
    BOOL GoOn, foundTheTag;
    long this_offset;
    //NSMutableArray *theDataToReturn = nil;
    NSString *theTagAsString;
    
    theTagAsString = [[NSString alloc] init];
    
    //Set the cursor to the first byte of the level
    theCursor = myLevelHeaders[theLevel-1].offsetToStart;
    
    //Set it so that it uses current cursor location and
    //does not try to use this_offset...
    this_offset = -1;
    
    GoOn = YES;
    foundTheTag = NO;
    
    while (GoOn == YES  && myLevelHeaders[theLevel - 1].length > (this_offset - myLevelHeaders[theLevel - 1].offsetToStart)  )
    {        
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
            switch (tag)
            {  
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
        
        
        if (next_offset == 0 && !foundTheTag)
        {
            #ifdef useDebugingLogs
                NSLog(@"Importent:  Level %d did not have the tag...", theLevel);
            #endif
            //[theDataToReturn release];
            return;
        }
        
        
        this_offset = myLevelHeaders[theLevel-1].offsetToStart + next_offset;
        
    } // End while (GoOn == YES)
    
    return;
}

// ***************************** Save Data Functions **********************************
#pragma mark -
#pragma mark ********* Save Data Functions *********

- (void)saveEntryHeader:(OSType)tag next_offset:(long)nextOffset length:(long)length offset:(long)offset
{

    [self saveLong:tag];
    [self saveLong:(nextOffset + length + 16)]; // next offset
    [self saveLong:length]; // length
    [self saveLong:offset]; // offset, for inplace expansion of data???

}

- (void)savePointsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 4)];
    
    NSArray *theObjects = [level getThePoints];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
    
    [self saveEntryHeader:'PNTS' next_offset:[mapDataToSave length] length:(objCount * 4 /* point length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    { 
	[self saveShort:[currentObj getX]];
	[self saveShort:[currentObj getY]];
    }
    
    #ifdef useDebugingLogs
        NSLog(@"Saved %d point objects.", objCount);
    #endif
}


- (void)saveLinesForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 32)];
    
    NSArray *theObjects = [level getTheLines];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
    
    [self saveEntryHeader:'LINS' next_offset:[mapDataToSave length] length:(objCount * 32 /* line length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {                
	[self saveShort:[currentObj getP1]];
	[self saveShort:[currentObj getP2]];
	[self saveUnsignedShort:[currentObj getFlags]];
	[self saveShort:[currentObj getLength]];
	[self saveShort:[currentObj getHighestAdjacentFloor]];
	[self saveShort:[currentObj getLowestAdjacentCeiling]];
	[self saveShort:[currentObj getClockwisePolygonSideIndex]];
	[self saveShort:[currentObj getCounterclockwisePolygonSideIndex]];
	[self saveShort:[currentObj getClockwisePolygonOwner]];
	[self saveShort:[currentObj getConterclockwisePolygonOwner]];
	
	[self saveEmptyBytes:12]; //Skip the unused part of each line... :)
    }
    
    #ifdef useDebugingLogs
        NSLog(@"Saved %d line objects.", objCount);
    #endif
}

- (void)savePolygonsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 128)];
    NSArray *theObjects = [level getThePolys];
    long objCount = [theObjects count];
    id currentObj = nil;
            
    if (objCount < 1)
	return;
    
    [self saveEntryHeader:'POLY' next_offset:[mapDataToSave length] length:(objCount * 128 /* poly length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {
	[self saveShort:[currentObj getType]];
	[self saveUnsignedShort:[currentObj getFlags]];
	[self saveShort:[currentObj getPermutation]];
	
	[self saveShort:[currentObj getTheVertexCount]];
	
	[self saveShort:[currentObj getVertexIndexes:0]]; 
	[self saveShort:[currentObj getVertexIndexes:1]]; 
	[self saveShort:[currentObj getVertexIndexes:2]]; 
	[self saveShort:[currentObj getVertexIndexes:3]]; 
	[self saveShort:[currentObj getVertexIndexes:4]]; 
	[self saveShort:[currentObj getVertexIndexes:5]]; 
	[self saveShort:[currentObj getVertexIndexes:6]]; 
	[self saveShort:[currentObj getVertexIndexes:7]];
	
	[self saveShort:[currentObj getLineIndexes:0]]; 
	[self saveShort:[currentObj getLineIndexes:1]]; 
	[self saveShort:[currentObj getLineIndexes:2]]; 
	[self saveShort:[currentObj getLineIndexes:3]]; 
	[self saveShort:[currentObj getLineIndexes:4]]; 
	[self saveShort:[currentObj getLineIndexes:5]]; 
	[self saveShort:[currentObj getLineIndexes:6]]; 
	[self saveShort:[currentObj getLineIndexes:7]];
	
	[self saveShort:[currentObj getFloor_texture]];
	[self saveShort:[currentObj getCeiling_texture]];
	[self saveShort:[currentObj getFloor_height]];
	[self saveShort:[currentObj getCeiling_height]];
	[self saveShort:[currentObj getFloor_lightsource_index]]; 
	[self saveShort:[currentObj getCeiling_lightsource_index]]; 
	
	//[self saveLong:[currentObj getArea]];
	[self saveLong:0];
	
	//[self saveShort:[currentObj getFirst_object_index]]; 
	//[self saveShort:[currentObj getFirst_exclusion_zone_index]];
	//[self saveShort:[currentObj getLine_exclusion_zone_count]];
	//[self saveShort:[currentObj getPoint_exclusion_zone_count]];
	[self saveShort:-1]; 
	[self saveShort:0];
	[self saveShort:0];
	[self saveShort:0];
	
	[self saveShort:[currentObj getFloor_transfer_mode]];
	[self saveShort:[currentObj getCeiling_transfer_mode]];
	
	//[self saveShort:[currentObj getAdjacent_polygon_indexes:0]]; 
	//[self saveShort:[currentObj getAdjacent_polygon_indexes:1]]; 
	//[self saveShort:[currentObj getAdjacent_polygon_indexes:2]]; 
	//[self saveShort:[currentObj getAdjacent_polygon_indexes:3]]; 
	//[self saveShort:[currentObj getAdjacent_polygon_indexes:4]]; 
	//[self saveShort:[currentObj getAdjacent_polygon_indexes:5]]; 
	//[self saveShort:[currentObj getAdjacent_polygon_indexes:6]]; 
	//[self saveShort:[currentObj getAdjacent_polygon_indexes:7]];
	[self saveShort:0];
	[self saveShort:0];
	[self saveShort:0];
	[self saveShort:0];
	[self saveShort:0];
	[self saveShort:0];
	[self saveShort:0];
	[self saveShort:0];
	
	//[self saveShort:[currentObj getFirst_neighbor_index]]; 
	//[self saveShort:[currentObj getNeighbor_count]];
	[self saveShort:0]; 
	[self saveShort:0];
	
	//[self saveShort:[currentObj getCenter].x];
	//[self saveShort:[currentObj getCenter].y];
	[self saveShort:0];
	[self saveShort:0];
	
	// NSLog(@"\np\n");	*** 	***	***	***	***	***	***	***	***
	
	[self saveShort:[currentObj getSide_indexes:0]]; 
	[self saveShort:[currentObj getSide_indexes:1]]; 
	[self saveShort:[currentObj getSide_indexes:2]]; 
	[self saveShort:[currentObj getSide_indexes:3]]; 
	[self saveShort:[currentObj getSide_indexes:4]]; 
	[self saveShort:[currentObj getSide_indexes:5]]; 
	[self saveShort:[currentObj getSide_indexes:6]]; 
	[self saveShort:[currentObj getSide_indexes:7]];
	
	[self saveShort:[currentObj getFloor_origin].x];
	[self saveShort:[currentObj getFloor_origin].y];
	
	[self saveShort:[currentObj getCeiling_origin].x];
	[self saveShort:[currentObj getCeiling_origin].y];
	
	[self saveShort:[currentObj getMedia_index]];
	[self saveShort:[currentObj getMedia_lightsource_index]];
	
	//[self saveShort:[currentObj getSound_source_indexes]];
	[self saveShort:0];
	
	[self saveShort:[currentObj getAmbient_sound_image_index]];
	[self saveShort:[currentObj getRandom_sound_image_index]];
	
	[self saveEmptyBytes:2]; //Skip the unused part... :)
    }
    
    #ifdef useDebugingLogs
        NSLog(@"Saved %d polygon objects.", objCount);
    #endif
}

- (void)saveObjectsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 16)];
    NSArray *theObjects = [level getTheMapObjects];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
	
    [self saveEntryHeader:'OBJS' next_offset:[mapDataToSave length] length:(objCount * 16 /* objs length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {
	[self saveShort:[currentObj getType]];
	[self saveShort:[currentObj getObjTypeIndex]];
	[self saveShort:[currentObj getFacing]];
	[self saveShort:[currentObj getPolygonIndex]];
	[self saveShort:[currentObj getX]];
	[self saveShort:[currentObj getY]];
	[self saveShort:[currentObj getZ]];
	[self saveUnsignedShort:[currentObj getMapFlags]];
    }
    #ifdef useDebugingLogs
        NSLog(@"Saved %d map objects (Monsters, Items, Etc.).", objCount);
    #endif
}

- (void)saveSidesForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 64)];
    NSArray *theObjects = [level getSides];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
    
    [self saveEntryHeader:'SIDS' next_offset:[mapDataToSave length] length:(objCount * 64 /* objs length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {
	struct side_texture_definition theTempSideTextureDefinition;
	struct side_exclusion_zone theTempExclusionZone;
	
	[self saveShort:[currentObj getType]];
	[self saveShort:[currentObj getFlags]];
	
	// ***
	
	theTempSideTextureDefinition = [currentObj getPrimary_texture];
	
	[self saveShort:theTempSideTextureDefinition.x0];
	[self saveShort:theTempSideTextureDefinition.y0];
	//theTempSideTextureDefinition.texture = [self getShort]; // 3oisudjlifslkf sujdlifj ldsf
	//theCursor -= 2;
	[self saveShort:theTempSideTextureDefinition.texture];
	//[self saveOneByteShort:theTempSideTextureDefinition.textureCollection];
	//[self saveOneByteShort:/*(char)*/theTempSideTextureDefinition.textureNumber]; // *** May Need to Cast It??? ***
	
	// ---
	
	theTempSideTextureDefinition = [currentObj getSecondary_texture];
	
	[self saveShort:theTempSideTextureDefinition.x0];
	[self saveShort:theTempSideTextureDefinition.y0];
	//theTempSideTextureDefinition.texture = [self getShort];
	//theCursor -= 2;
	[self saveShort:theTempSideTextureDefinition.texture];
	//[self saveOneByteShort:theTempSideTextureDefinition.textureCollection = [self getOneByteShort]];
	//[self saveOneByteShort:theTempSideTextureDefinition.textureNumber = [self getOneByteShort]];
	
	// ---
	
	theTempSideTextureDefinition = [currentObj getTransparent_texture];
	
	[self saveShort:theTempSideTextureDefinition.x0];
	[self saveShort:theTempSideTextureDefinition.y0];
	//theTempSideTextureDefinition.texture = [self getShort];
	//theCursor -= 2;
	[self saveShort:theTempSideTextureDefinition.texture];
	//[self saveOneByteShort:theTempSideTextureDefinition.textureCollection];
	//[self saveOneByteShort:theTempSideTextureDefinition.textureNumber];
	
	// ***
	
	theTempExclusionZone = [currentObj getExclusion_zone];
	
	[self saveShort:theTempExclusionZone.e0.x];
	[self saveShort:theTempExclusionZone.e0.y];
	[self saveShort:theTempExclusionZone.e1.x];
	[self saveShort:theTempExclusionZone.e1.y];
	[self saveShort:theTempExclusionZone.e2.x];
	[self saveShort:theTempExclusionZone.e2.y];
	[self saveShort:theTempExclusionZone.e3.x];
	[self saveShort:theTempExclusionZone.e3.y];
		
	[self saveShort:[currentObj getControl_panel_type]];
	[self saveShort:[currentObj getControl_panel_permutation]];
		
	[self saveShort:[currentObj getPrimary_transfer_mode]];
	[self saveShort:[currentObj getSecondary_transfer_mode]];
	[self saveShort:[currentObj getTransparent_transfer_mode]];
	
	[self saveShort:[currentObj getPolygon_index]];
	[self saveShort:[currentObj getLine_index]];
	
	[self saveShort:[currentObj getPrimary_lightsource_index]];
	[self saveShort:[currentObj getSecondary_lightsource_index]];
	[self saveShort:[currentObj getTransparent_lightsource_index]];
	
	[self saveLong:[currentObj getAmbient_delta]];
	
	[self saveEmptyBytes:2]; //Skip the unused part... :)
    }
    #ifdef useDebugingLogs
        NSLog(@"Saved %d side objects.", objCount);
    #endif
}

- (void)saveLightsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 100)];
    NSArray *theObjects = [level getLights];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
	
    [self saveEntryHeader:'LITE' next_offset:[mapDataToSave length] length:(objCount * 100 /* light length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {
	int i;
	
	[self saveShort:[currentObj getType]];
	[self saveUnsignedShort:[currentObj getFlags]];
	
	[self saveShort:[currentObj getPhase]];
	
	for (i = 0; i < 6; i++)
	{
	    [self saveShort:[currentObj getFunction_forState:i]];
	    [self saveShort:[currentObj getPeriod_forState:i]];
	    [self saveShort:[currentObj getDelta_period_forState:i]];
	    [self saveLong:[currentObj getIntensity_forState:i]]; 
	    [self saveLong:[currentObj getDelta_intensity_forState:i]];
	}
	
	[self saveShort:[currentObj getTag]];
	
	[self saveEmptyBytes:8]; //Skip the unused part... :)
    }
    #ifdef useDebugingLogs
        NSLog(@"Saved %d light objects.", objCount);
    #endif
}

- (void)saveNotesForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 72)];
    
    NSArray *theObjects = [level getNotes];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
	
    [self saveEntryHeader:'NOTE' next_offset:[mapDataToSave length] length:(objCount * 72 /* annotation length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {
	[self saveShort:[currentObj getType]];
	
	[self saveShort:[currentObj getLocation].x];
	[self saveShort:[currentObj getLocation].y];
	[self saveShort:[currentObj getPolygon_index]];
	
	[self saveStringAsChar:[currentObj getText] withLength:64];
	
    }
    #ifdef useDebugingLogs
        NSLog(@"Saved %d annotation objects.", objCount);
    #endif
}

- (void)saveMediasForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 32)];
    NSArray *theObjects = [level getMedia];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
    
    [self saveEntryHeader:'medi' next_offset:[mapDataToSave length] length:(objCount * 32 /* media length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {    
	[self saveShort:[currentObj getType]];
	[self saveUnsignedShort:[currentObj getFlags]];
	
	[self saveShort:[currentObj getLight_index]];
	
	[self saveShort:[currentObj getCurrent_direction]];
	[self saveShort:[currentObj getCurrent_magnitude]];
	
	[self saveShort:[currentObj getLow]];
	[self saveShort:[currentObj getHigh]];
	
	[self saveShort:[currentObj getOrigin].x];
	[self saveShort:[currentObj getOrigin].y];
	
	[self saveShort:[currentObj getHeight]];
	
	[self saveLong:[currentObj getMinimum_light_intensity]]; // ??? Should Make Object Pointer ???
	[self saveShort:[currentObj getTexture]];
	[self saveShort:[currentObj getTransfer_mode]];
	
	[self saveEmptyBytes:4]; //Skip the unused part... :)
    }
    #ifdef useDebugingLogs
        NSLog(@"Saved %d media (water, lava, etc.) objects.", objCount);
    #endif
}

- (void)saveAmbientSoundsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 16)];
    NSArray *theObjects = [level getAmbientSounds];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
    
    [self saveEntryHeader:'ambi' next_offset:[mapDataToSave length] length:(objCount * 16 /* object length */) offset:0];
    NSEnumerator *
    numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {
	[self saveUnsignedShort:[currentObj getFlags]];
	
	[self saveShort:[currentObj getSound_index]];
	[self saveShort:[currentObj getVolume]];
	
	[self saveEmptyBytes:10]; //Skip the unused part... :)
    }
    #ifdef useDebugingLogs
        NSLog(@"Saved %d ambient sound objects.", objCount);
    #endif
}

- (void)saveRandomSoundsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 28)];
    NSArray *theObjects = [level getRandomSounds];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
    
    [self saveEntryHeader:'bonk' next_offset:[mapDataToSave length] length:(objCount * 32 /* random_sound length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {                
	[self saveShort:[currentObj getFlags]];
	[self saveShort:[currentObj getSound_index]];
	[self saveShort:[currentObj getVolume]];
	[self saveShort:[currentObj getDelta_volume]];
	[self saveShort:[currentObj getPeriod]];
	[self saveShort:[currentObj getDelta_period]];
	[self saveShort:[currentObj getDirection]];
	[self saveShort:[currentObj getDelta_direction]];
	[self saveLong:[currentObj getPitch]];
	[self saveLong:[currentObj getDelta_pitch]];
	[self saveShort:[currentObj getPhase]];
	
	[self saveEmptyBytes:6]; //Skip the unused part... :)
    }
    #ifdef useDebugingLogs
        NSLog(@"Saved %d random sound objects.", objCount);
    #endif
}

- (void)saveItemPlacementForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 12)];
    NSArray *theObjects = [level getItemPlacement];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
    
    [self saveEntryHeader:'plac' next_offset:[mapDataToSave length] length:(objCount * 12 /* objs length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {
	[self saveShort:[currentObj getFlags]];
	
	[self saveShort:[currentObj getInitial_count]];
	[self saveShort:[currentObj getMinimum_count]];
	[self saveShort:[currentObj getMaximum_count]];
	
	[self saveShort:[currentObj getRandom_count]];
	[self saveUnsignedShort:[currentObj getRandom_chance]];
    }
    #ifdef useDebugingLogs
        NSLog(@"Saved %d item placement objects.", objCount);
    #endif
}

- (void)savePlatformsForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 32)];
    NSArray *theObjects = [level getPlatforms];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
    
    [self saveEntryHeader:'plat' next_offset:[mapDataToSave length] length:(objCount * 32 /* platform length */) offset:0];
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    while (currentObj = [numer nextObject])
    {
	[self saveShort:[currentObj getType]];
	[self saveShort:[currentObj getSpeed]];
	[self saveShort:[currentObj getDelay]];
	[self saveShort:[currentObj getmaximum_height]];
	[self saveShort:[currentObj getminimum_height]];
	[self saveUnsignedLong:[currentObj getStatic_flags]];
	[self saveShort:[currentObj getPolygon_index]];
	[self saveShort:[currentObj getTag]];
	
	[self saveEmptyBytes:14]; //Skip the unused part... :)
    }
    #ifdef useDebugingLogs
        NSLog(@"Saved %d platform objects.", objCount);
    #endif
}

- (void)saveTerminalDataForLevel:(LELevelData *)level
{
    //theDataToReturn = [[NSMutableArray allocWithZone:[self zone]] initWithCapacity:(length / 28)];
    NSArray *theObjects = [level getTerminals];
    long objCount = [theObjects count];
    id currentObj = nil;
    
    if (objCount < 1)
	return;
    
    NSEnumerator *numer = [theObjects objectEnumerator];
    {
	NSMutableData *theTerminalData = [[NSMutableData alloc] initWithCapacity:0];
	while (currentObj = [numer nextObject])
	    [theTerminalData appendData:[currentObj getTerminalAsMarathonData]];
	    
	[self saveEntryHeader:'term' next_offset:[mapDataToSave length] length:[theTerminalData length] offset:0];
			    //    Proably extra blank space for expation, I guess???
	[self saveData:theTerminalData];
	
	[theTerminalData release];
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
    -(NSMutableArray *)getTheMapObjects;
    -(NSMutableArray *)getSides;
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
