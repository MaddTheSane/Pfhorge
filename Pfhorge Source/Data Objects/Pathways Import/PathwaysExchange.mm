//
//  PathwaysExchange.m
//  Pfhorge
//
//  Created by Jagil on Wed Jun 18 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//


#import "PathwaysToMarathon.h"
#import "PathwaysExchange.h"
#import "LEExtras.h"
#import "PhData.h"
#import "PhProgress.h"


@implementation PathwaysExchange

+ (BOOL)convertPIDMapToArchived:(NSData *)theData
                         levels:(NSMutableArray *)theArchivedLevels
                     levelNames:(NSMutableArray *)theLevelNamesEXP
                   resourceData:(NSData *)dpin128Data
{
    // NOTE: Check for (exchange == nil)
    PathwaysExchange *exchange = [[PathwaysExchange alloc] initWithData:theData resourceData:dpin128Data];
    long numberOfLevels = [exchange levelCount];
    NSArray *theLevelNames = [exchange levelNames];
    int i = 0;
    
    short theVersionNumber = currentVersionOfPfhorgeLevelData;
    short thePfhorgeDataSig1 = 26743;
    unsigned short thePfhorgeDataSig2 = 34521;
    int thePfhorgeDataSig3 = 42296737;
    
    PhProgress *progress = [PhProgress sharedPhProgress];
    
    [progress setMaxProgress:(numberOfLevels+1)];
    [progress setProgressPostion:0.0];
    
    for (i = 1; i <= numberOfLevels; i++)
    {
        LELevelData *currentLevel;
        NSData *theLevelMapData = nil;
        NSMutableData *entireMapData = [[NSMutableData alloc] init];
        
        [progress setStatusText:[NSString stringWithFormat:@"Converting \"%@\"...",
                [theLevelNames objectAtIndex:(i - 1)], nil]];
        
        [progress setSecondMinProgress:0.0];
        [progress setSecondMaxProgress:10.0];
        [progress setSecondProgressPostion:0.0];
        [progress setSecondStatusText:@"Loading Level, Please Wait..."];
        
        [progress setUseSecondBarOnly:YES];
        currentLevel = [exchange getPIDLevel:i]; // Autoreleased....
        [progress setUseSecondBarOnly:NO];
        
        if (currentLevel == nil)
        {
            SEND_ERROR_MSG_TITLE(@"Could not convert one of the levels...",
                                 @"Converting Error");
            NSLog(@"Could not convert PID level: %d (One Based)", i);
            continue;
        }
        
        [progress setSecondStatusText:@"Archiving Level Into Binary Data..."];
        [progress increaseSecondProgressBy:5.0];
        
        theLevelMapData = [NSKeyedArchiver archivedDataWithRootObject:currentLevel];
        
        [progress setSecondStatusText:@"Saving Level..."];
        [progress increaseSecondProgressBy:5.0];
        
        theVersionNumber = CFSwapInt16HostToBig(theVersionNumber);
        thePfhorgeDataSig1 = CFSwapInt16HostToBig(thePfhorgeDataSig1);
        thePfhorgeDataSig2 = CFSwapInt16HostToBig(thePfhorgeDataSig2);
        thePfhorgeDataSig3 = CFSwapInt32HostToBig(thePfhorgeDataSig3);

        [entireMapData appendBytes:&theVersionNumber length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig1 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig2 length:2];
        [entireMapData appendBytes:&thePfhorgeDataSig3 length:4];
        
        [entireMapData appendData:theLevelMapData];
        
        [theArchivedLevels addObject:entireMapData];
        [theLevelNamesEXP addObject:[[theLevelNames objectAtIndex:(i - 1)] copy]];
        
        //[currentLevel release]; Not Nessary, sinced it is autoreleased...
        
        [progress increaseProgressBy:1.0];
    }
    
    return YES;
}


- (id)initWithData:(NSData *)theData
{    
    self = [super init];
    
    if (self == nil)
        return nil;
    
    data = [theData copy];
    
    dpinData = nil;
    
    // Sanity checks
    
    // Was all the data alignment set OK?
    assert(sizeof(PID_Door) == 8);
    assert(sizeof(PID_LevelChange) == 8);
    assert(sizeof(PID_Monster) == 4);
    assert(sizeof(PID_Wall) == 2);
    assert(sizeof(PID_Sector) == 16);
    assert(sizeof(PID_Position) == 8);
    assert(sizeof(PID_Level) == 16834);
    assert(sizeof(PID_PlayerItem) == 8);
    assert(sizeof(PID_WeaponPerform) == 6);
    assert(sizeof(PID_PlayerState) == 2876);
    assert(sizeof(PID_MonsterState) == 8);
    assert(sizeof(PID_PickupAssign) == 4);
    assert(sizeof(PID_ItemState) == 16);
    assert(sizeof(PID_LevelState) == 9112);
    
    int length = [data length];
    int rem = length % sizeof(PID_Level);
    if (rem != 0)
    {
        NSLog(@"Bad PID map-data file: remainder of %d bytes", rem);
        
        // No reason to stay allocated, release self and return nil...
        return nil;
    }
    
    return self;
}

- (id)initWithData:(NSData *)theData resourceData:(NSData *)dpin128Data
{
	if (self = [self initWithData:theData]) {
		dpinData = [dpin128Data copy];
	}
	
	return self;
}

- (int)levelCount
{
    NSInteger length = [data length];
    return int(length/sizeof(PID_Level));
}

- (NSArray *)levelNames
{
    int levels = [self levelCount];
    
    // Need to cache this...
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:levels];
    
    PID_Level *Levels = (PID_Level *)([data bytes]);
    
    for (int i = 0; i < levels; i++)
    {
        NSString *name = GetLevelName(Levels[i]);
       
        if (name == nil)
        {
            NSLog(@"One of the PID level names was nil.");
            [names addObject:@"Unknown Name"];
        }
        else
        {
            [names addObject:name];
        }
    }
    
    return [names copy];
}

- (LELevelData *)getPIDLevel:(int)levNum
{
    LELevelData *level = nil;

    PID_Level *Levels = (PID_Level *)([data bytes]);
    PID_Level& PL = Levels[levNum-1];	// One-based to zero-based
    
    if (dpinData)
    {
        PID_LevelState *LevelStates = (PID_LevelState *)([dpinData bytes]) + sizeof(PID_PlayerState);
        PID_LevelState& PLS = LevelStates[levNum-1];	// One-based to zero-based
        
        level = PathwaysToMarathon(PL,PLS);
    }
    else
    {
        PID_LevelState BlankState;
        memset(&BlankState,0,sizeof(BlankState));
        
        level = PathwaysToMarathon(PL,BlankState);
    }
    
    return level;
}

@end
