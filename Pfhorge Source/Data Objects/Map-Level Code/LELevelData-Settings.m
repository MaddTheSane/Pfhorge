//
//  LELevelData-Settings.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Jan 25 2003.
//  Copyright (c) 2003 Joshua D. Orr. All rights reserved.
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

#import "LEMapStuffParent.h"

#import "LELevelData.h"
#import "LEMapDraw.h"
#import "LEMap.h"

#import "PhTag.h"
#import "PhLayer.h"

#import "LEMapPoint.h"
#import "LELine.h"
#import "LESide.h"
#import "LEPolygon.h"
#import "LEMapObject.h"
#import "PhLight.h"
#import "PhAnnotationNote.h"
#import "PhMedia.h"
#import "PhAmbientSound.h"
#import "PhRandomSound.h"
#import "PhItemPlacement.h"
#import "PhPlatform.h"

#import "Terminal.h"
#import "TerminalSection.h"

#import "LEExtras.h"

@implementation LELevelData (LevelSettings)

// ************************** Level Specific Settings *************************
#pragma mark -
#pragma mark ********* Level Specific Settings *********

-(NSDecimalNumberHandler *)roundingSettings { return defaultRoundingBehavior; }


-(NSMutableDictionary *)getLevelOptionDictionary { return levelOptions; }

-(BOOL)settingExsists:(NSString *)key
{
    NSNumber *theNumber = [levelOptions objectForKey:key];
    
    if (theNumber != nil)
        return YES;
    else
        return NO;
}

-(BOOL)settingAsBool:(NSString *)key
{
    NSNumber *theNumber = [levelOptions objectForKey:key];
    if (theNumber != nil)
    {
        return [theNumber boolValue];
    }
    else
    {	//NSLog(@"nil for key: %@", key);
        return [preferences boolForKey:key];
    }
    
    return NO;
}

-(float)settingAsFloat:(NSString *)key
{
    NSNumber *theNumber = [levelOptions objectForKey:key];
    if (theNumber != nil)
    {
        return [((NSNumber *)[levelOptions objectForKey:key]) floatValue];
    }
    else
    {
        return [preferences floatForKey:key];
    }
    
    return -1.0;
}

-(int)settingAsInt:(NSString *)key
{
    NSNumber *theNumber = [levelOptions objectForKey:key];
    if (theNumber != nil)
    {
        return [((NSNumber *)[levelOptions objectForKey:key]) intValue];
    }
    else
    {
        return [preferences integerForKey:key];
    }
        
    return -1;
}

-(void)setSettingFor:(NSString *)key asBool:(BOOL)value { [levelOptions setObject:[NSNumber numberWithBool:value] forKey:key]; }
-(void)setSettingFor:(NSString *)key asFloat:(float)value { [levelOptions setObject:[NSNumber numberWithFloat:value] forKey:key]; }
-(void)setSettingFor:(NSString *)key asInt:(int)value { [levelOptions setObject:[NSNumber numberWithInt:value] forKey:key]; }

-(void)copyOptionsFromPrefs
{
    [self setSettingFor:PhSnapObjectsToGrid asBool:[preferences boolForKey:PhSnapObjectsToGrid]];
    
    [self setSettingFor:PhEnableGridBool asBool:[preferences boolForKey:PhEnableGridBool]];
    [self setSettingFor:PhSnapToPoints asBool:[preferences boolForKey:PhSnapToPoints]];
    [self setSettingFor:PhSnapToGridBool asBool:[preferences boolForKey:PhSnapToGridBool]];
    
    [self setSettingFor:PhEnableObjectEnemyMonster asBool:[preferences boolForKey:PhEnableObjectEnemyMonster]];
    [self setSettingFor:PhEnableObjectPlayer asBool:[preferences boolForKey:PhEnableObjectPlayer]];
    [self setSettingFor:PhEnableObjectSceanry asBool:[preferences boolForKey:PhEnableObjectSceanry]];
    [self setSettingFor:PhEnableObjectSound asBool:[preferences boolForKey:PhEnableObjectSound]];
    [self setSettingFor:PhEnableObjectItem asBool:[preferences boolForKey:PhEnableObjectItem]];
    [self setSettingFor:PhEnableObjectGoal asBool:[preferences boolForKey:PhEnableObjectGoal]];
    
    [self setSettingFor:PhGridFactor asFloat:[preferences floatForKey:PhGridFactor]];
    
    //PhEnableGridBool
}

// ************************** Level Information Flag Accsessors *************************
#pragma mark -
#pragma mark ********* Level Info Flags *********

-(BOOL)isEnvironmentNormal { return (environment_flags == 0)?(YES):(NO); }
-(BOOL)isEnvironmentVacuum { return GET_ENVIRONMENT_FLAG(LELevelEnvironmentVacuum); }
-(BOOL)isEnvironmentMagnetic { return GET_ENVIRONMENT_FLAG(LELevelEnvironmentMagnetic); }
-(BOOL)isEnvironmentRebellion { return GET_ENVIRONMENT_FLAG(LELevelEnvironmentRebellion); }
-(BOOL)isEnvironmentLowGravity { return GET_ENVIRONMENT_FLAG(LELevelEnvironmentLowGravity); }
-(BOOL)isEnvironmentNetwork { return GET_ENVIRONMENT_FLAG(LELevelEnvironmentNetwork); }
-(BOOL)isEnvironmentSinglePlayer { return GET_ENVIRONMENT_FLAG(LELevelEnvironmentSinglePlayer); }

-(BOOL)isMissionExtermination{ return GET_MISSION_FLAG(LELevelMissionExtermination); }
-(BOOL)isMissionExploration{ return GET_MISSION_FLAG(LELevelMissionExploration); }
-(BOOL)isMissionRetrieval{ return GET_MISSION_FLAG(LELevelMissionRetrieval); }
-(BOOL)isMissionRepair{ return GET_MISSION_FLAG(LELevelMissionRepair); }
-(BOOL)isMissionRescue{ return GET_MISSION_FLAG(LELevelMissionRescue); }

-(BOOL)isGameTypeSinglePlayer{ return GET_ENTRY_FLAG(LELevelEntryPointSinglePlayer); }
-(BOOL)isGameTypeCooperative{ return GET_ENTRY_FLAG(LELevelEntryPointMultiplayerCooperative); }
-(BOOL)isGameTypeMultiplayerCarnage{ return GET_ENTRY_FLAG(LELevelEntryPointMultiplayerCarnage); }
-(BOOL)isGameTypeCaptureTheFlag{ return GET_ENTRY_FLAG(LELevelEntryPointMultiplayerCaptureTheFlag); }
-(BOOL)isGameTypeKingOfTheHill{ return GET_ENTRY_FLAG(LELevelEntryPointMultiplayerKingOfTheHill); }
-(BOOL)isGameTypeDefense{ return GET_ENTRY_FLAG(LELevelEntryPointDefense); }
-(BOOL)isGameTypeRugby{ return GET_ENTRY_FLAG(LELevelEntryPointMultiplayerRugby); }


-(void)setEnvironmentNormal { environment_flags = LELevelEnvironmentNormal; }
-(void)setEnvironmentVacuum:(BOOL)v { SET_ENVIRONMENT_FLAG(LELevelEnvironmentVacuum, v); }
-(void)setEnvironmentMagnetic:(BOOL)v { SET_ENVIRONMENT_FLAG(LELevelEnvironmentMagnetic, v); }
-(void)setEnvironmentRebellion:(BOOL)v { SET_ENVIRONMENT_FLAG(LELevelEnvironmentRebellion, v); }
-(void)setEnvironmentLowGravity:(BOOL)v { SET_ENVIRONMENT_FLAG(LELevelEnvironmentLowGravity, v); }
-(void)setEnvironmentNetwork:(BOOL)v { SET_ENVIRONMENT_FLAG(LELevelEnvironmentNetwork, v); }
-(void)setEnvironmentSinglePlayer:(BOOL)v { SET_ENVIRONMENT_FLAG(LELevelEnvironmentSinglePlayer, v); }

-(void)setMissionExtermination:(BOOL)v { SET_MISSION_FLAG(LELevelMissionExtermination, v); }
-(void)setMissionExploration:(BOOL)v { SET_MISSION_FLAG(LELevelMissionExploration, v); }
-(void)setMissionRetrieval:(BOOL)v { SET_MISSION_FLAG(LELevelMissionRetrieval, v); }
-(void)setMissionRepair:(BOOL)v { SET_MISSION_FLAG(LELevelMissionRepair, v); }
-(void)setMissionRescue:(BOOL)v { SET_MISSION_FLAG(LELevelMissionRescue, v); }

-(void)setGameTypeSinglePlayer:(BOOL)v { SET_ENTRY_FLAG(LELevelEntryPointSinglePlayer, v); }
-(void)setGameTypeCooperative:(BOOL)v { SET_ENTRY_FLAG(LELevelEntryPointMultiplayerCooperative, v); }
-(void)setGameTypeMultiplayerCarnage:(BOOL)v { SET_ENTRY_FLAG(LELevelEntryPointMultiplayerCarnage, v); }
-(void)setGameTypeCaptureTheFlag:(BOOL)v { SET_ENTRY_FLAG(LELevelEntryPointMultiplayerCaptureTheFlag, v); }
-(void)setGameTypeKingOfTheHill:(BOOL)v { SET_ENTRY_FLAG(LELevelEntryPointMultiplayerKingOfTheHill, v); }
-(void)setGameTypeDefense:(BOOL)v { SET_ENTRY_FLAG(LELevelEntryPointDefense, v); }
-(void)setGameTypeRugby:(BOOL)v { SET_ENTRY_FLAG(LELevelEntryPointMultiplayerRugby, v); }


// These are methods that we probably wouldn't bother with if we weren't scriptable.

//NSScriptObjectSpecifier initWithContainerSpecifier:(NSScriptObjectSpecifier *)specifier key:(NSString *)key

- (NSScriptObjectSpecifier *)objectSpecifier
{
    if (theLevelDocument != nil)
    {
        NSScriptObjectSpecifier *containerRef = [theLevelDocument objectSpecifier];
        
        return [[[NSPropertySpecifier alloc]
                        initWithContainerClassDescription:[containerRef keyClassDescription]
                        /*initWith*/containerSpecifier:containerRef key:@"level"] autorelease];
    }
    else
        return nil;
}

@end
