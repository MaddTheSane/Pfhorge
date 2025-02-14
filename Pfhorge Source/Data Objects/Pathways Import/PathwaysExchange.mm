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
    
    for (i = 1; i <= numberOfLevels; i++) {
        LELevelData *currentLevel;
        NSData *theLevelMapData = nil;
        NSMutableData *entireMapData = [[NSMutableData alloc] init];
        
        [progress setStatusText:[NSString stringWithFormat:NSLocalizedString(@"Converting \"%@\"...", @"Converting “%@”…"),
                [theLevelNames objectAtIndex:(i - 1)], nil]];
        
        [progress setSecondMinProgress:0.0];
        [progress setSecondMaxProgress:10.0];
        [progress setSecondProgressPostion:0.0];
        [progress setSecondStatusText:NSLocalizedString(@"Loading Level, Please Wait…", @"Loading Level, Please Wait…")];
        
        [progress setUseSecondBarOnly:YES];
        currentLevel = [exchange getPIDLevel:i]; // Autoreleased....
        [progress setUseSecondBarOnly:NO];
        
        if (currentLevel == nil) {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.informativeText = NSLocalizedString(@"Converting Error", @"Converting Error");
            alert.messageText = NSLocalizedString(@"Could not convert one of the levels…", @"Could not convert one of the levels…");
            alert.alertStyle = NSAlertStyleCritical;
            [alert runModal];
            NSLog(@"Could not convert PID level: %d (One Based)", i);
            continue;
        }
        
        [progress setSecondStatusText:NSLocalizedString(@"Archiving Level Into Binary Data…", @"Archiving Level Into Binary Data…")];
        [progress increaseSecondProgressBy:5.0];
        
        theLevelMapData = [NSKeyedArchiver archivedDataWithRootObject:currentLevel requiringSecureCoding:NO error:NULL];
        
        [progress setSecondStatusText:NSLocalizedString(@"Saving Level…", @"Saving Level…")];
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
    static_assert(sizeof(PID_Door) == 8, "sizeof(PID_Door) != 8");
    static_assert(sizeof(PID_LevelChange) == 8, "sizeof(PID_LevelChange) != 8");
    static_assert(sizeof(PID_Monster) == 4, "sizeof(PID_Monster) != 4");
    static_assert(sizeof(PID_Wall) == 2, "sizeof(PID_Wall) != 2");
    static_assert(sizeof(PID_Sector) == 16, "sizeof(PID_Sector) != 16");
    static_assert(sizeof(PID_Position) == 8, "sizeof(PID_Position) != 8");
    static_assert(sizeof(PID_Level) == 16834, "sizeof(PID_Level) != 16834");
    static_assert(sizeof(PID_PlayerItem) == 8, "sizeof(PID_PlayerItem) != 8");
    static_assert(sizeof(PID_WeaponPerform) == 6, "sizeof(PID_WeaponPerform) != 6");
    static_assert(sizeof(PID_PlayerState) == 2876, "sizeof(PID_PlayerState) != 2876");
    static_assert(sizeof(PID_MonsterState) == 8, "sizeof(PID_MonsterState) != 8");
    static_assert(sizeof(PID_PickupAssign) == 4, "sizeof(PID_PickupAssign) != 4");
    static_assert(sizeof(PID_ItemState) == 16, "sizeof(PID_ItemState) != 16");
    static_assert(sizeof(PID_LevelState) == 9112, "sizeof(PID_LevelState) != 9112");
    
    NSUInteger length = [data length];
    NSUInteger rem = length % sizeof(PID_Level);
    if (rem != 0) {
        NSLog(@"Bad PID map-data file: remainder of %lu bytes", static_cast<unsigned long>(rem));
        
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
    
    for (int i = 0; i < levels; i++) {
        NSString *name = GetLevelName(Levels[i]);
       
        if (name == nil) {
            NSLog(@"One of the PID level names was nil.");
            [names addObject:@"Unknown Name"];
        } else {
            [names addObject:name];
        }
    }
    
    return [names copy];
}

static inline void byteswapDoor(PID_Door &door)
{
    door.x = CFSwapInt16BigToHost(door.x);
    door.y = CFSwapInt16BigToHost(door.y);
    door.Direction = (PID_Door::open_direction)CFSwapInt16BigToHost(door.Direction);
    door.Texture = CFSwapInt16BigToHost(door.Texture);
}

static inline void byteswapLevelChange(PID_LevelChange &levelChange)
{
    levelChange.Type = (PID_LevelChange::level_change_type)CFSwapInt16BigToHost(levelChange.Type);
    levelChange.Level = CFSwapInt16BigToHost(levelChange.Level);
    levelChange.x = CFSwapInt16BigToHost(levelChange.x);
    levelChange.y = CFSwapInt16BigToHost(levelChange.y);
}

static inline void byteswapMonster(PID_Monster &monster)
{
    monster.Type = (PID_Monster::pid_monster_type)CFSwapInt16BigToHost(monster.Type);
    monster.Frequency = CFSwapInt16BigToHost(monster.Frequency);
}

static void byteswapLevel(PID_Level& PLS)
{
    PLS.LevelNumber = CFSwapInt32BigToHost(PLS.LevelNumber);
    PLS.Height10 = CFSwapInt16BigToHost(PLS.Height10);
    PLS.Start.x = CFSwapInt32BigToHost(PLS.Start.x);
    PLS.Start.y = CFSwapInt32BigToHost(PLS.Start.y);
    for (int i = 0; i < PID_Level::NUMBER_OF_TEXTURES; i++) {
        PLS.TextureList[i] = CFSwapInt16BigToHost(PLS.TextureList[i]);
    }
    
    for (int i = 0; i < PID_Level::NUMBER_OF_DOORS; i++) {
        byteswapDoor(PLS.DoorList[i]);
    }
    
    for (int i = 0; i < PID_Level::NUMBER_OF_LEVELCHANGES; i++) {
        byteswapLevelChange(PLS.LevelChangeList[i]);
    }
    
    for (int i = 0; i < PID_Level::NUMBER_OF_MONSTER_TYPES_PRESENT; i++) {
        byteswapMonster(PLS.MonsterList[i]);
    }
    // Skipping PLS.SectorList: none of the data types are big enough to need byte-swapping
}

static void byteswapLevelState(PID_LevelState& PLS)
{
    PLS.NumMonsters = CFSwapInt16BigToHost(PLS.NumMonsters);
    for (int i = 0; i < PID_LevelState::MAXIMUM_NUMBER_OF_MONSTERS; i++) {
        PLS.MonsterList[i].Type = CFSwapInt16BigToHost(PLS.MonsterList[i].Type);
        PLS.MonsterList[i].Health = CFSwapInt16BigToHost(PLS.MonsterList[i].Health);
        //Skipping PLS.MonsterList[i].Unused
        PLS.MonsterList[i].ItemID = CFSwapInt16BigToHost(PLS.MonsterList[i].ItemID);
    }
    
    PLS.NumAssigns = CFSwapInt16BigToHost(PLS.NumAssigns);
    for (int i = 0; i < PID_LevelState::MAXIMUM_NUMBER_OF_ASSIGNS; i++) {
        PLS.AssignList[i].ItemID = CFSwapInt16BigToHost(PLS.AssignList[i].ItemID);
        PLS.AssignList[i].PickupID = CFSwapInt16BigToHost(PLS.AssignList[i].PickupID);
    }
    
    for (int i = 0; i < PID_LevelState::MAXIMUM_NUMBER_OF_PICKUPS; i++) {
        PLS.PickupList[i].Type = CFSwapInt16BigToHost(PLS.PickupList[i].Type);
        PLS.PickupList[i].Activity = CFSwapInt16BigToHost(PLS.PickupList[i].Activity);
        PLS.PickupList[i].Quantity = CFSwapInt16BigToHost(PLS.PickupList[i].Quantity);
        PLS.PickupList[i].ContainedItem = CFSwapInt16BigToHost(PLS.PickupList[i].ContainedItem);
    }

    // skipping PLS.Unknown1
    
    for (int i = 0; i < PID_LevelState::MAXIMUM_NUMBER_OF_ITEMS; i++) {
        PLS.Items[i].Pos.x = CFSwapInt32BigToHost(PLS.Items[i].Pos.x);
        PLS.Items[i].Pos.y = CFSwapInt32BigToHost(PLS.Items[i].Pos.y);
        PLS.Items[i].Texture = CFSwapInt16BigToHost(PLS.Items[i].Texture);
        PLS.Items[i].Flags = CFSwapInt16BigToHost(PLS.Items[i].Flags);
        // skipping PLS.Items[i].Unused
        PLS.Items[i].NextItem = CFSwapInt16BigToHost(PLS.Items[i].NextItem);
    }

    // skipping PLS.Unknown2
}

- (LELevelData *)getPIDLevel:(int)levNum
{
    LELevelData *level = nil;

    PID_Level *Levels = (PID_Level *)([data bytes]);
    // copy, so we can byte swap it safely.
    PID_Level PL = Levels[levNum-1];	// One-based to zero-based
    byteswapLevel(PL);
    if (dpinData) {
        PID_LevelState *LevelStates = (PID_LevelState *)([dpinData bytes]) + sizeof(PID_PlayerState);
        // copy, so we can byte swap it safely.
        PID_LevelState PLS = LevelStates[levNum-1];	// One-based to zero-based
        byteswapLevelState(PLS);
        
        level = PathwaysToMarathon(PL,PLS);
    } else {
        PID_LevelState BlankState;
        memset(&BlankState,0,sizeof(BlankState));
        
        level = PathwaysToMarathon(PL,BlankState);
    }
    
    return level;
}

@end
