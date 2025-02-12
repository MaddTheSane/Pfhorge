//
//  LELevelData.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Jun 16 2001.
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

#import "LEMapStuffParent.h"

#import "LELevelData.h"
#import "LELevelData-private.h"
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
#import "PhNoteGroup.h"

#import "Terminal.h"
#import "TerminalSection.h"

#import "LEExtras.h"

#import "PhData.h"


@implementation LELevelData
@synthesize levelName=level_name;
@synthesize environmentCode = environment_code;
@synthesize physicsModel=physics_model;
@synthesize songIndex=song_index;
@synthesize missionFlags=mission_flags;
@synthesize environmentFlags=environment_flags;
@synthesize entryPointFlags=entry_point_flags;
@synthesize myUndoManager;
@synthesize roundingSettings=defaultRoundingBehavior;

- (NSMutableArray<PhItemPlacement *> *)getItemPlacement
{
    return itemPlacement;
}

-(NSMutableArray *)getThePoints { return points; }

-(NSMutableArray *)getTheLines { return lines; }
-(NSMutableArray *)getThePolys { return polys; }
-(NSMutableArray *)getTheMapObjects { return mapObjects; }

-(NSMutableArray *)getLayerPoints { return layerPoints; }
-(NSMutableArray *)getLayerLines { return layerLines; }
-(NSMutableArray *)getLayerPolys { return layerPolys; }
-(NSMutableArray *)getLayerMapObjects { return layerMapObjects; }

-(NSMutableArray *)getLayersInLevel { return layersInLevel; }
-(NSMutableArray *)getNamedPolyObjects { return namedPolyObjects; }

-(NSMutableArray *)getSides { return sides; }
-(NSMutableArray *)getLights { return lights; }
-(NSMutableArray *)getNotes { return notes; }
-(NSMutableArray *)getMedia { return media; }
-(NSMutableArray *)getAmbientSounds { return ambientSounds; }
-(NSMutableArray *)getRandomSounds { return randomSounds; }
-(NSMutableArray *)getPlatforms { return platforms; }

-(NSMutableArray *)getTags { return tags; }

-(NSMutableArray *)getTerminals { return terimals; }

+ (NSSet<NSString *> *)keyPathsForValuesAffectingEnvironmentFlags
{
    return [NSSet setWithObjects:@"environmentVacuum", @"environmentMagnetic", @"environmentRebellion", @"environmentLowGravity", @"environmentNetwork", @"environmentSinglePlayer", nil];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingMissionFlags
{
    return [NSSet setWithObjects:@"missionExtermination", @"missionExploration", @"missionRetrieval", @"missionRepair", @"missionRescue", nil];
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingEntryPointFlags
{
    return [NSSet setWithObjects:@"gameTypeSinglePlayer", @"gameTypeCooperative", @"gameTypeMultiplayerCarnage", @"gameTypeCaptureTheFlag", @"gameTypeKingOfTheHill", @"gameTypeDefense", @"gameTypeRugby", nil];
}

-(void)setSongIndex:(short)v
{
    if (v > 3 || v < 0)
        v = 0;
    
    song_index = v;
}

#pragma mark -

static NSString * const LELevelDataEnvironmentCodeCoderKey = @"environment_code";
static NSString * const LELevelDataphysics_modelCoderKey = @"physics_model";
static NSString * const LELevelDatasong_indexCoderKey = @"song_index";
static NSString * const LELevelDatamission_flagsCoderKey = @"mission_flags";
static NSString * const LELevelDataenvironment_flagsCoderKey = @"environment_flags";
static NSString * const LELevelDataentry_point_flagsCoderKey = @"entry_point_flags";

    
static NSString * const LELevelDataPointsCoderKey = @"points";
static NSString * const LELevelDataLinesCoderKey = @"lines";
static NSString * const LELevelDataPolysCoderKey = @"polys";
static NSString * const LELevelDatamapObjectsCoderKey = @"mapObjects";
static NSString * const LELevelDatasidesCoderKey = @"sides";
static NSString * const LELevelDatalightsCoderKey = @"lights";
static NSString * const LELevelDatanotesCoderKey = @"notes";
static NSString * const LELevelDatamediaCoderKey = @"media";
static NSString * const LELevelDataambientSoundsCoderKey = @"ambientSounds";
static NSString * const LELevelDatarandomSoundsCoderKey = @"randomSounds";
static NSString * const LELevelDataitemPlacementCoderKey = @"itemPlacement";
static NSString * const LELevelDataplatformsCoderKey = @"platforms";

static NSString * const LELevelDataterimalsCoderKey = @"terimals";

static NSString * const LELevelDatalayersInLevelCoderKey = @"layersInLevel";
static NSString * const LELevelDatacurrentLayerCoderKey = @"currentLayer";
static NSString * const LELevelDatalayerPointsCoderKey = @"layerPoints";
static NSString * const LELevelDatalayerLinesCoderKey = @"layerLines";
static NSString * const LELevelDatalayerPolysCoderKey = @"layerPolys";
static NSString * const LELevelDatalayerMapObjectsCoderKey = @"layerMapObjects";
    
static NSString * const LELevelDatatagsCoderKey = @"tags";

static NSString * const LELevelDatalevel_nameCoderKey = @"level_name";

static NSString * const LELevelDatanoteTypesCoderKey = @"noteTypes";
static NSString * const LELevelDatalayerNotesCoderKey = @"layerNotes";


// **************************  Coding/Copy Protocol Methods  *************************
#pragma mark - Coding/Copy Protocol Methods
- (void) encodeWithCoder:(NSCoder *)coder
{
    [self resetAdjacentPolygonAssociations];
    
    [super encodeWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        [coder encodeInt:environment_code forKey:LELevelDataEnvironmentCodeCoderKey];
        [coder encodeInt:physics_model forKey:LELevelDataphysics_modelCoderKey];
        [coder encodeInt:song_index forKey:LELevelDatasong_indexCoderKey];
        [coder encodeInt:mission_flags forKey:LELevelDatamission_flagsCoderKey];
        [coder encodeInt:environment_flags forKey:LELevelDataenvironment_flagsCoderKey];
        [coder encodeInt:entry_point_flags forKey:LELevelDataentry_point_flagsCoderKey];
        
        [coder encodeObject:points forKey:LELevelDataPointsCoderKey];
        [coder encodeObject:lines forKey:LELevelDataLinesCoderKey];
        [coder encodeObject:polys forKey:LELevelDataPolysCoderKey];
        [coder encodeObject:mapObjects forKey:LELevelDatamapObjectsCoderKey];
        [coder encodeObject:sides forKey:LELevelDatasidesCoderKey];
        [coder encodeObject:lights forKey:LELevelDatalightsCoderKey];
        [coder encodeObject:notes forKey:LELevelDatanotesCoderKey];
        [coder encodeObject:media forKey:LELevelDatamediaCoderKey];
        [coder encodeObject:ambientSounds forKey:LELevelDataambientSoundsCoderKey];
        [coder encodeObject:randomSounds forKey:LELevelDatarandomSoundsCoderKey];
        [coder encodeObject:itemPlacement forKey:LELevelDataitemPlacementCoderKey];
        [coder encodeObject:platforms forKey:LELevelDataplatformsCoderKey];
        
        [coder encodeObject:terimals forKey:LELevelDataterimalsCoderKey];
        
        [coder encodeObject:layersInLevel forKey:LELevelDatalayersInLevelCoderKey];
        [coder encodeObject:currentLayer forKey:LELevelDatacurrentLayerCoderKey];
        [coder encodeObject:layerPoints forKey:LELevelDatalayerPointsCoderKey];
        [coder encodeObject:layerLines forKey:LELevelDatalayerLinesCoderKey];
        [coder encodeObject:layerPolys forKey:LELevelDatalayerPolysCoderKey];
        [coder encodeObject:layerMapObjects forKey:LELevelDatalayerMapObjectsCoderKey];
        
        [coder encodeObject:tags forKey:LELevelDatatagsCoderKey];
        
        [coder encodeObject:level_name forKey:LELevelDatalevel_nameCoderKey];
        
        [coder encodeObject:noteTypes forKey:LELevelDatanoteTypesCoderKey];
        [coder encodeObject:layerNotes forKey:LELevelDatalayerNotesCoderKey];
    } else {
        encodeNumInt(coder, 3);
        
        encodeShort(coder, environment_code);
        encodeShort(coder, physics_model);
        encodeShort(coder, song_index);
        encodeShort(coder, mission_flags);
        encodeShort(coder, environment_flags);
        encodeLong(coder, entry_point_flags);
        
        
        //encodeObj(coder, linesThatIBelongTo);
        
        encodeObj(coder, points);
        encodeObj(coder, lines);
        encodeObj(coder, polys);
        encodeObj(coder, mapObjects);
        encodeObj(coder, sides);
        encodeObj(coder, lights);
        encodeObj(coder, notes);
        encodeObj(coder, media);
        encodeObj(coder, ambientSounds);
        encodeObj(coder, randomSounds);
        encodeObj(coder, itemPlacement);
        encodeObj(coder, platforms);
        
        encodeObj(coder, terimals);
        
        encodeObj(coder, layersInLevel);
        encodeObj(coder, currentLayer);
        encodeObj(coder, layerPoints);
        encodeObj(coder, layerLines);
        encodeObj(coder, layerPolys);
        encodeObj(coder, layerMapObjects);
        
        //encodeObj(coder, namedPolyObjects);
        
        encodeObj(coder, tags);
        
        encodeObj(coder, level_name);
        
        encodeObj(coder, noteTypes);
        encodeObj(coder, layerNotes);
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    
    if (coder.allowsKeyedCoding) {
        environment_code = [coder decodeIntForKey:LELevelDataEnvironmentCodeCoderKey];
        physics_model = [coder decodeIntForKey:LELevelDataphysics_modelCoderKey];
        song_index = [coder decodeIntForKey:LELevelDatasong_indexCoderKey];
        mission_flags = [coder decodeIntForKey:LELevelDatamission_flagsCoderKey];
        environment_flags = [coder decodeIntForKey:LELevelDataenvironment_flagsCoderKey];
        entry_point_flags = [coder decodeIntForKey:LELevelDataentry_point_flagsCoderKey];
        
        // Objects are already inited due to -init being called by the super's -initWithCoder:
        [points setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [LEMapPoint class], nil] forKey:LELevelDataPointsCoderKey]];
        [lines setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [LELine class], nil] forKey:LELevelDataLinesCoderKey]];
        [polys setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [LEPolygon class], nil] forKey:LELevelDataPolysCoderKey]];
        [mapObjects setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [LEMapObject class], nil] forKey:LELevelDatamapObjectsCoderKey]];
        [sides setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [LESide class], nil] forKey:LELevelDatasidesCoderKey]];
        [lights setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhLight class], nil] forKey:LELevelDatalightsCoderKey]];
        [notes setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhAnnotationNote class], nil] forKey:LELevelDatanotesCoderKey]];
        [media setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhMedia class], nil] forKey:LELevelDatamediaCoderKey]];
        [ambientSounds setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhAmbientSound class], nil] forKey:LELevelDataambientSoundsCoderKey]];
        [randomSounds setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhRandomSound class], nil] forKey:LELevelDatarandomSoundsCoderKey]];
        [itemPlacement setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhItemPlacement class], nil] forKey:LELevelDataitemPlacementCoderKey]];
        [platforms setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhPlatform class], nil] forKey:LELevelDataplatformsCoderKey]];
        
        [terimals setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [Terminal class], nil] forKey:LELevelDataterimalsCoderKey]];
        
        [layersInLevel setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhLayer class], nil] forKey:LELevelDatalayersInLevelCoderKey]];
        currentLayer = [coder decodeObjectOfClass:[PhLayer class] forKey:LELevelDatacurrentLayerCoderKey];
        [layerPoints setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [LEMapPoint class], nil] forKey:LELevelDatalayerPointsCoderKey]];
        [layerLines setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [LELine class], nil] forKey:LELevelDatalayerLinesCoderKey]];
        [layerPolys setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [LEPolygon class], nil] forKey:LELevelDatalayerPolysCoderKey]];
        [layerMapObjects setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [LEMapObject class], nil] forKey:LELevelDatalayerMapObjectsCoderKey]];
        
        [tags setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhTag class], nil] forKey:LELevelDatatagsCoderKey]];
        
        self.levelName = [coder decodeObjectOfClass:[NSString class] forKey:LELevelDatalevel_nameCoderKey];
        
        [noteTypes setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhNoteGroup class], nil] forKey:LELevelDatanoteTypesCoderKey]];
        [layerNotes setArray:[coder decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class], [PhAnnotationNote class], nil] forKey:LELevelDatalayerNotesCoderKey]];
        
        [self havePointsScanForLines];
    } else {
        versionNum = decodeNumInt(coder);
        
        //NSLog(@"1");
        
        environment_code = decodeShort(coder);
        physics_model = decodeShort(coder);
        song_index = decodeShort(coder);
        mission_flags = decodeShort(coder);
        environment_flags = decodeShort(coder);
        entry_point_flags = decodeInt(coder);
        
        //linesThatIBelongTo = decodeObj(coder);
        //NSLog(@"1");
        
        // Objects are already inited due to -init being called by the super's -initWithCoder:
        [points setArray:decodeObj(coder)];
        //NSLog(@"2");
        [lines setArray:decodeObj(coder)];
        //NSLog(@"3");
        [polys setArray:decodeObj(coder)];
        //NSLog(@"4");
        [mapObjects setArray:decodeObj(coder)];
        //NSLog(@"5");
        [sides setArray:decodeObj(coder)];
        //NSLog(@"6");
        [lights setArray:decodeObj(coder)];
        //NSLog(@"7");
        [notes setArray:decodeObj(coder)];
        //NSLog(@"8");
        [media setArray:decodeObj(coder)];
        //NSLog(@"9");
        [ambientSounds setArray:decodeObj(coder)];
        //NSLog(@"10");
        [randomSounds setArray:decodeObj(coder)];
        //NSLog(@"11");
        [itemPlacement setArray:decodeObj(coder)];
        //NSLog(@"12");
        [platforms setArray:decodeObj(coder)];
        //NSLog(@"13");
        
        [terimals setArray:decodeObj(coder)];
        //NSLog(@"14");
        
        [layersInLevel setArray:decodeObj(coder)];
        //NSLog(@"15");
        currentLayer = decodeObjRetain(coder);
        //NSLog(@"16");
        [layerPoints setArray:decodeObj(coder)];
        //NSLog(@"17");
        [layerLines setArray:decodeObj(coder)];
        //NSLog(@"18");
        [layerPolys setArray:decodeObj(coder)];
        //NSLog(@"19");
        [layerMapObjects setArray:decodeObj(coder)];
        //NSLog(@"20");
        
        //namedPolyObjects = decodeObj(coder);
        
        /*layerPolys = [[NSMutableArray alloc] initWithCapacity:0];
         layerLines = [[NSMutableArray alloc] initWithCapacity:0];
         layerPoints = [[NSMutableArray alloc] initWithCapacity:0];
         layerMapObjects = [[NSMutableArray alloc] initWithCapacity:0];
         namedPolyObjects = [[NSMutableArray alloc] initWithCapacity:0];*/
        
        [tags setArray:decodeObj(coder)];
        
        self.levelName = decodeObj(coder);
        
        [self setUpArrayPointersForEveryObject];
        
        if (versionNum > 0) { // this is if versionNum == 1...
            [noteTypes setArray:decodeObj(coder)];
        }
        
        if (versionNum > 1) {
            [layerNotes setArray:decodeObj(coder)];
        }
        
        if (versionNum > 2) {
            
        } else {
            [self havePointsScanForLines];
        }
    }
    [self setUpArrayNamesForEveryObject];
    //[self recaculateTheCurrentLayer];
    [self setupDefaultObjects];
    [self resetAdjacentPolygonAssociations];
    
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

/*
- (id)copyWithZone:(NSZone *)zone
{
    LELevelData *copy = [[LELevelData allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    return copy;
}
*/

#pragma mark -
#pragma mark • Only called after loading marathon formated map... •
 // CALLED: after loading a marathon formated map, to set thePhName of lights, etc.
 //		and to put those names in the name manager cache.
-(void)compileAndSetNameArraysFromLevel
{
    // ambientSoundNames randomSoundNames lightNames platformNames tagNames liquidNames
    // ambientSounds randomSounds lights platforms tags media
    
    id theObj;
    NSMutableArray *tmpNumberList, *theNamesCacheArray;
    NSArray *theAcutalObjectsArray = nil;
    BOOL listIncludesNone;
    int i, j;
    
    // *** Start Main Code ***
    
    
    for (i = 0; i < 7; i++) {
        switch (i) {
            case 0:
                theNamesCacheArray = ambientSoundNames;
                theAcutalObjectsArray = ambientSounds;
                break;
            case 1:
                theNamesCacheArray = randomSoundNames;
                theAcutalObjectsArray = randomSounds;
                break;
            case 2:
                theNamesCacheArray = lightNames;
                theAcutalObjectsArray = lights;
                break;
            case 3:
                theNamesCacheArray = platformNames;
                theAcutalObjectsArray = platforms;
                break;
            case 4:
                theNamesCacheArray = liquidNames;
                theAcutalObjectsArray = media;
                break;
            case 5:
                theNamesCacheArray = layerNames;
                theAcutalObjectsArray = layersInLevel;
                break;
            case 6:
                theNamesCacheArray = terminalNames;
                theAcutalObjectsArray = terimals;
                break;
            default:
                theNamesCacheArray = nil;
                theAcutalObjectsArray = nil;
                SEND_ERROR_MSG(@"*** A Very Serious Logic Error Just Happened In The compileAndSetNameArraysFromLevel method in LELevelData");
                break;
        }
        
        if (theNamesCacheArray == nil || theAcutalObjectsArray == nil)
            continue;
        
        // Just to make sure there are no previous names...
        [theNamesCacheArray removeAllObjects];
        
        j = 0;
        for (theObj in theAcutalObjectsArray) {
            if (i < 5) {
                NSString *theName = [NSString localizedStringWithFormat:@"%d", j];
                [theObj setPhName:theName];
                
                if (theName == nil) {
                    NSLog(@"REPORT THIS PLEASE: *** theName was nil in name caching... #1");
                    [theObj setPhName:@"Name Was Nil? 1"];
                    theName = @"Name Was Nil? 1";
                    //continue;
                }
                
                [theNamesCacheArray addObject:theName];
                j++;
            }
            else if (i == 5 || i == 6) // Layers/Terminals already have there name...
            {
                if (theObj == nil) {
                    NSLog(@"REPORT THIS PLEASE: *** theObj was nil in name caching... #3");
                    continue;
                }
                
                if ([theObj phName] == nil) {
                    NSLog(@"REPORT THIS PLEASE: *** [theObj getPhName] was nil in name caching... #2");
                    [theObj setPhName:@"Name Was Nil? 2"];
                    //continue;
                }
                [theNamesCacheArray addObject:[theObj phName]];
                j++;
            }
        }
    }
    
    NSLog(@"Check To See which polygons need names...");
    
    { // Checking polygons to see if I need to name some polygons...
		LEPolygon	*thePolyPointedTo;
        id theObj;
        for (LEPolygon *thePolyToCheck in polys) {
            switch ([thePolyToCheck type]) {
                case LEPolygonPlatformOnTrigger:
                case LEPolygonPlatformOffTrigger:
                case LEPolygonTeleporter:
                    thePolyPointedTo = [thePolyToCheck permutationObject];
                    // This Might Be able To Insert Nil Objects Into An Array...
                    [self namePolygon:thePolyPointedTo to:stringFromInt([thePolyPointedTo index])];
                    break;
                default:
                    break;
            }
        }
        
        for (theObj in sides) {
            switch ([theObj permutationEffects]) {
                case 0:
                    
                    break;
                case _cpanel_effects_light:
                    
                    break;
                case _cpanel_effects_polygon:
                    thePolyPointedTo = [theObj controlPanelPermutationObject];
                    // This Might Be able To Insert Nil Objects Into An Array...
                    [self namePolygon:thePolyPointedTo to:stringFromInt([thePolyPointedTo index])];
                    break;
                case _cpanel_effects_tag:
                    
                    break;
                case _cpanel_effects_terminal:
                    
                    break;
                default:
                    NSLog(@"*** ERROR: uknown control panel permutation effect encontered in compileAndSetNameArraysFromLevel");
                    break;
            }
        }
    }
    
    NSLog(@"Compiling Tag names and numbers...");
    
    tmpNumberList = [[NSMutableArray alloc] initWithCapacity:15];
    
    // Gets Tags In Light Objects
    for (PhLight *theObj in lights) {
        NSNumber *theNumber = [NSNumber numberWithShort:[theObj tag]];
        
        if (theNumber == nil) {
            NSLog(@"*** theNumber from light tag was nil in name caching...");
            continue; // Continues at 'while (theObj = [numer nextObject]) // get next Light object'
        }
        
        //Check to see if this number is already in the list...
        if ([tmpNumberList indexOfObject:theNumber] == NSNotFound)
            [tmpNumberList addObject:theNumber];
    }
    
    // Gets Tags In Platform Objects
    for (PhPlatform *theObj in platforms) {
        NSNumber *theNumber;
        theNumber = [NSNumber numberWithShort:[theObj tag]];
        
        if (theNumber == nil) {
            NSLog(@"*** theNumber from platform tag was nil in name caching...");
            continue; // Continues at 'while (theObj = [numer nextObject]) // get next Platform object'
        }
        
        //Check to see if this number is already in the list...
        if ([tmpNumberList indexOfObject:theNumber] == NSNotFound)
            [tmpNumberList addObject:theNumber];
    }
    
    // Gets Tags In Side Objects
    for (theObj in sides) { // get next side object
        NSNumber *theNumber = nil;
        int theControlPanelType = [theObj adjustedControlPanelType];
        
        switch (theControlPanelType) {
            case _panel_tagSwitch:
                theNumber = [NSNumber numberWithShort:[theObj controlPanelPermutation]];
                break;
            case _panel_chipInserton:
                theNumber = [NSNumber numberWithShort:[theObj controlPanelPermutation]];
                break;
            case _panel_wires:
                theNumber = [NSNumber numberWithShort:[theObj controlPanelPermutation]];
                break;
        }
        
        if (theNumber == nil) {
            // NSLog(@"*** theNumber from side tag was nil in name caching...");
            continue; // Continues at 'while (theObj = [numer nextObject]) // get next side object'
        }
        
        //Check to see if this number is already in the list...
        if ([tmpNumberList indexOfObject:theNumber] == NSNotFound)
            [tmpNumberList addObject:theNumber];
    }
    
    // check to see if the array contains more then one tag...
    if ([tmpNumberList count] > 1) {
        // if it does contain more then one object, sort it...
        // *** May have to convert array to mutable array? ***
        
        // Could be just a NSArray, but I am going to, for now, cast it to NSMutableArray...
        [tmpNumberList sortUsingSelector:@selector(compare:)];
    }
    
    //if (heightMode == LEMapDrawingModeAmbientSounds || LEMapDrawingModeLiquidLights:LEMapDrawingModeLiquids
    if ([tmpNumberList indexOfObject:@((short)(-1))] == NSNotFound) {
        listIncludesNone = NO;
	//SEND_ERROR_MSG_TITLE(@"There is no -1 (NONE) tag", @"Information - Did Not Find NONE Tag");
    } else {
        listIncludesNone = YES;
        // SEND_ERROR_MSG_TITLE(@"There is a -1 (NONE) tag, is this possible? ]:=>", @"Information - Found NONE Tag ???");
    }
    
    if (tags ==  nil) {
        tags = [[NSMutableArray alloc] initWithCapacity:15];
        NSLog(@"*** Tags was nil in compileAndSetNameArraysFromLevel...");
    }
    
    //[tags removeAllObjects];
    //[tagNames removeAllObjects];
    
    // Setup tag objects from the tempary number list...
    
    // *** IMPLEMNT THE FOLLOWING TO MAKE SURE THERE ARE NO DUPLICATE TAGS!!! ***
    
    /*numer = [tmpNumberList objectEnumerator];
    while (theObj = [numer nextObject])
    {
        PhTag  *theTag = [[PhTag alloc] initWithTagNumber:theObj];
        // if (theTag compare: // NSOrderedSame
        
        // Need to implement the isEqual method in PhAbstractNumber,
        //  then use the containsObject NSArray method
        
        [self setUpArrayPointersFor:theTag]; // Setup Pointer To Other Arrays...
        [tags addObject:theTag];
        [tagNames addObject:[theTag phName]];
        [theTag release];
    }*/
    
#ifdef useDebugingLogs
    NSLog(@"Tags count from name caching: %d - %d. Both Need To Be The Same!", [tags count], [tagNames count]);
#endif
    
}


#pragma mark -
#pragma mark • Only called after loading pfhorge formated map... •
 // CALLED: after loading a Pfhorge formated map, to get thePhName of lights, etc.
 //		and to put those names in the name manager cache.
-(void)setUpArrayNamesForEveryObject
{
    [tagNames removeAllObjects];
    [platformNames removeAllObjects];
    [lightNames removeAllObjects];
    [ambientSoundNames removeAllObjects];
    [randomSoundNames removeAllObjects];
    [liquidNames removeAllObjects];
    [layerNames removeAllObjects];
    [polyNames removeAllObjects];
    [namedPolyObjects removeAllObjects];
    [terminalNames removeAllObjects];
    
    for (LEPolygon *theObj in polys) {
        if ([theObj doIHaveAName]) {
            [polyNames addObject:[theObj phName]];
            [namedPolyObjects addObject:theObj];
        }
        
        if ([theObj type] == LEPolygonPlatform) {
            if ([[theObj permutationObject] polygonObject] != theObj) {
                // The polygon points to a platform which does not point back
                // to the polygon...  This will fix that, hopefully...
                [[theObj permutationObject] setPolygonObject:theObj];
            }
        }
    }
    
    for (PhLight *theObj in lights)
        [lightNames addObject:[theObj phName]];
    
    for (PhMedia *theObj in media)
        [liquidNames addObject:[theObj phName]];
    
    for (PhAmbientSound *theObj in ambientSounds)
        [ambientSoundNames addObject:[theObj phName]];
    
    for (PhRandomSound *theObj in randomSounds)
        [randomSoundNames addObject:[theObj phName]];
    
    for (PhPlatform *theObj in platforms)
        [platformNames addObject:[theObj phName]];
    
    for (PhLayer *theObj in layersInLevel)
        [layerNames addObject:[theObj phName]];
    
    for (PhTag *theObj in tags)
        [tagNames addObject:[theObj phName]];
    
    for (Terminal *theObj in terimals)
        [terminalNames addObject:[theObj phName]];
    
    [self refreshEveryMenu];
}

/*
enum // export data types
{
	_data_is_polygon,
        _data_is_line,
        _data_is_object,
        _data_is_side,
        _data_is_point,
        _data_is_media,
        _data_is_light,
        _data_is_tag,
        _data_is_annotationNote,
        _data_is_ambientSound,
        _data_is_randomSound,
        _data_is_itemPlacement,
        _data_is_platform,
        _data_is_terminal,
        _data_is_terminalSection,
        _data_is_layer
};
*/

#pragma mark -

- (NSData *)exportObjects:(NSSet *)objects
{
    NSMutableArray *exports = [[NSMutableArray alloc] init];
    id theObj = nil;
    NSMutableData *exportData = [[NSMutableData alloc] init];
    NSMutableData *finnalData = [[NSMutableData alloc] init];
    short tmpShort = 0;
    short appendNumber = 0;
    
    for (theObj in objects) {
        if ([exports indexOfObjectIdenticalTo:theObj] == NSNotFound) {
            [theObj exportWithIndex:exports withData:exportData mainObjects:objects];
        }
    }
    
    short totalObjs = [exports count];
    int indexEntrys = totalObjs;
    
    #ifdef useDebugingLogs
        NSLog(@"Total Exports: %d", totalObjs);
    #endif
    
    [finnalData appendBytes:&indexEntrys length:4];
    
    for (theObj in exports) {
        Class theClass = [theObj class];
        
        if (theClass == [LEMapPoint class])
            appendNumber = _data_is_point;
        else if (theClass == [LELine class])
            appendNumber = _data_is_line;
        else if (theClass == [LEPolygon class])
            appendNumber = _data_is_polygon;
        else if (theClass == [LEMapObject class])
            appendNumber = _data_is_object;
        else if (theClass == [LESide class])
            appendNumber = _data_is_side;
        else if (theClass == [PhMedia class])
            appendNumber = _data_is_media;
        else if (theClass == [PhAmbientSound class])
            appendNumber = _data_is_ambientSound;
        else if (theClass == [PhRandomSound class])
            appendNumber = _data_is_randomSound;
        else if (theClass == [PhLight class])
            appendNumber = _data_is_light;
        else if (theClass == [PhItemPlacement class])
            appendNumber = _data_is_itemPlacement;
        else if (theClass == [PhPlatform class])
            appendNumber = _data_is_platform;
        else
            appendNumber = _data_is_unknown;
        
        if ([objects containsObject:theObj])
            tmpShort = _data_is_primary;
        else
            tmpShort = _data_is_secondary;
        
        
        
        _data_name_export customNameStatus = _data_has_no_name;
        
        if ([theObj isKindOfClass:[PhAbstractName class]]) {
            if ([theObj doIHaveACustomName]) {
                customNameStatus = _data_has_no_name;
            } else if ([theObj doIHaveAName]) {
                customNameStatus = _data_has_regular_name;
            } else {
                customNameStatus = _data_has_no_name;
            }
        } else {
            customNameStatus = _data_has_no_name;
        }
        
		saveShortToNSData(tmpShort, finnalData);
		saveShortToNSData(appendNumber, finnalData);
		saveShortToNSData(customNameStatus, finnalData);
    }
    
    [finnalData appendData:exportData];
    
    return [finnalData copy];
}

- (NSSet *)importObjects:(NSData *)theData
{
    PhData *myData = [[PhData alloc] initWithData:theData];
    NSMutableArray *index = [[NSMutableArray alloc] init];
    NSMutableSet *theSet = [[NSMutableSet alloc] init];
    
    ///NSEnumerator *numer = nil;
    id theObj = nil;
    
    int totalObjects;
    [myData getInt:&totalObjects];
    ///long indexBytes = totalObjects*4;
    
    short objTypesArr[totalObjects];
    BOOL objImported[totalObjects];
    _data_type_export objKindArr[totalObjects];
    _data_name_export objNameStatusArr[totalObjects];
    
    int i = 0;
    
    #ifdef useDebugingLogs
        NSLog(@"Total Imports: %d  --- Allocating Objects...", totalObjects);
    #endif
    
    for (i = 0; i < totalObjects; i++) {
        [myData getShort:&objTypesArr[i]]; // Primary or Secondary?
        objImported[i] = NO;
        [myData getShort:&objKindArr[i]]; // Light or Polygon?, etc...
        [myData getShort:&objNameStatusArr[i]]; // Name Status...
        _data_type_export objKind = objKindArr[i];
        id obj = nil;
        
        //   *points, *lines, *polys, *mapObjects, *sides,
        //   *layerPoints, *layerLines, *layerPolys, *layerMapObjects;
        
        if (objKind == _data_is_point)
            obj = [[LEMapPoint alloc] init];
        else if (objKind == _data_is_line)
            obj = [[LELine alloc] init];
        else if (objKind == _data_is_polygon)
            obj = [[LEPolygon alloc] init];
        else if (objKind == _data_is_object)
            obj = [[LEMapObject alloc] init];
        else if (objKind == _data_is_side)
            obj = [[LESide alloc] init];
        else if (objKind == _data_is_media)
            obj = [[PhMedia alloc] init];
        else if (objKind == _data_is_ambientSound)
            obj = [[PhAmbientSound alloc] init];
        else if (objKind == _data_is_randomSound)
            obj = [[PhRandomSound alloc] init];
        else if (objKind == _data_is_light)
            obj = [[PhLight alloc] init];
        else if (objKind == _data_is_itemPlacement)
            obj = [[PhItemPlacement alloc] init];
        else if (objKind == _data_is_platform)
            obj = [[PhPlatform alloc] init];
        else
        {
            NSLog(@"While importing, I found an unkown object type attempted to be imported... I will have to abort importing...");
            return nil;
        }
        
        [self setUpArrayPointersFor:obj]; 
        [index addObject:obj];
    }
    
    //NSLog(@"Importing Commencing...");
    
    BOOL stillImporting = YES;
    
    while (stillImporting) {
        for (i = 0; i < totalObjects; i++) {
            theObj = [index objectAtIndex:i];
            
            if (objImported[i] == NO && objTypesArr[i] == _data_is_primary) {
                if ([myData addToPosition:4] == NO)
                    NSLog(@"Went Beyond Import Bounds...");
                
                [theObj importWithIndex:index withData:myData useOrginals:NO objTypesArr:objTypesArr];
                objImported[i] = YES;
            } else {
                if ((i+1) != totalObjects)
                    if ([myData skipLengthLong] == NO)
                        NSLog(@"Went Beyond Import Bounds...");
            }
        }
        
        for (i = 0; i < totalObjects; i++) {
            if (objImported[i] == NO && objTypesArr[i] == _data_is_primary)
            {
                stillImporting = YES;
                break;
            } else {
                stillImporting = NO;
            }
        }
    }
    #ifdef useDebugingLogs
        NSLog(@"Done Importing...");
    #endif
    // - (void)checkPosition;
    // [getObjectFromIndex:(NSArray *)theIndex;
    
    
    for (i = 0; i < totalObjects; i++)
    {
        // short objTypesArr[totalObjects];
        // BOOL objImported[totalObjects];
        // short objKindArr[totalObjects];
        
        id obj = [index objectAtIndex:i];
        short objKind = objKindArr[i];
        BOOL objWasImported = objImported[i];
        
        if (objWasImported == NO)
            continue;
        
        /*
            _data_has_no_name,
            _data_has_regular_name,
            _data_has_custom_name
        */
        

        //   *points, *lines, *polys, *mapObjects, *sides,
        //   *layerPoints, *layerLines, *layerPolys, *layerMapObjects;
        
        if (objKind == _data_is_point)
        {
            [self addPoint:obj];
            [theSet addObject:obj];
        }
        else if (objKind == _data_is_line)
        {
            [self addLine:obj];
            [theSet addObject:obj];
        }
        else if (objKind == _data_is_polygon)
        {
            [self addPolygonDirectly:obj];
            [theSet addObject:obj];
        }
        else if (objKind == _data_is_object)
        {
            [mapObjects addObject:obj];
            [theSet addObject:obj];
            [layerMapObjects addObject:obj];
        }
        else if (objKind == _data_is_side)
        {
            [sides addObject:obj];
        }
        else if (objKind == _data_is_media)
        {
            [media addObject:obj];
        }
        else if (objKind == _data_is_ambientSound)
        {
            [ambientSounds addObject:obj];
        }
        else if (objKind == _data_is_randomSound)
        {
            [randomSounds addObject:obj];
        }
        else if (objKind == _data_is_light)
        {
            [lights addObject:obj];
        }
        else if (objKind == _data_is_itemPlacement)
        {
            [itemPlacement addObject:obj];
        }
        else if (objKind == _data_is_platform)
        {
            [platforms addObject:obj];
        }
        else
        {
            //appendNumber = _data_is_unknown; // ??? ??? ???
            
            NSLog(@"While importing, I found an unknown object type attempted to be imported...");
            continue;
        }
        
        if (objNameStatusArr[i] == _data_has_regular_name)
        {
            [obj setPhName:nil];
            [obj resetNameToMyIndex];
        }
        
    }
    
    // Tempoary Solution To The Naming Problem For Now...
    [self setUpArrayNamesForEveryObject];
    
    return theSet;
}


// ***************************  Intial Setup And Deallocation ***************************
#pragma mark - Intial Setup And Deallocation


-(LELevelData *)initForNewPathwaysPIDLevel
{
    self = [self init];
    
    if (self == nil)
        return nil;
    
    level_name = @"Untitled Level";
    
    enum {PID_LIGHT_SET_RANGE = 20};	// Kludgy way of doing "const" in plain C
    for (int i = PID_LIGHT_SET_RANGE; i >= 0; i--) {
        PhLight *newLight = [self addObjectWithDefaults:[PhLight class]];
        int intensity = (int)(((float)(i)/PID_LIGHT_SET_RANGE) * 65534) + 1;
        PhLightStaticFlags theFlags = 0;
        
        theFlags |= PhLightStaticFlagIsInitiallyActive;
        
        [newLight setType:PhLightNormal];
        [newLight setFlags:theFlags];
        [newLight setPhase:0];
        [newLight setTag:0];
        
        for (int j = 0; j < PhLightStateTotalCount; j++) {
            [newLight setFunction:PhLightFunctionConstant forState:j];
            [newLight setPeriod:60 forState:j];
            [newLight setDeltaPeriod:0 forState:j];
            [newLight setIntensity:intensity forState:j];
            [newLight setDeltaIntensity:0 forState:j];
        }
    }
    
    for (int i = 0; i < 128; i++) {
        PhItemPlacement *theNewItemPlacObj = [[PhItemPlacement alloc] init];
        [itemPlacement addObject:theNewItemPlacObj];
    }
    
    [self setupLayersForNewPIDLevel];
    [self compileAndSetNameArraysFromLevel];
    [self updateCounts];
    
    for (int i = 0; i < 15; i++) {
        [self addObjectWithDefaults:[PhTag class]];
    }
    
    [self setupDefaultObjects];
    
    [self refreshEveryMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNamesNotification object:nil];
    
    return self;
}


-(LELevelData *)initAndGenerateNewLevelObjects
{
    self = [self init];
    
    if (self == nil)
        return nil;
    
    self.levelName = @"Untitled Level";
    
    for (int i = 20; i >= 0; i--) {
        PhLight *newLight = [self addObjectWithDefaults:[PhLight class]];
        int intesity = (int)((float)((float)(i * 5) / 100) * 65534) + 1;
        PhLightStaticFlags theFlags = 0;
        
        theFlags |= PhLightStaticFlagIsInitiallyActive;
        
        [newLight setType:PhLightNormal];
        [newLight setFlags:theFlags];
        [newLight setPhase:0];
        [newLight setTag:0];
        
        for (int j = 0; j < PhLightStateTotalCount; j++) {
            [newLight setFunction:PhLightFunctionConstant forState:j];
            [newLight setPeriod:60 forState:j];
            [newLight setDeltaPeriod:0 forState:j];
            [newLight setIntensity:intesity forState:j];
            [newLight setDeltaIntensity:0 forState:j];
        }
    }
    
    for (int i = 0; i < 128; i++) {
        PhItemPlacement *theNewItemPlacObj = [[PhItemPlacement alloc] init];
        [itemPlacement addObject:theNewItemPlacObj];
    }
    
    [self setupLayers];
    [self compileAndSetNameArraysFromLevel];
    [self updateCounts];
    
    for (int i = 0; i < 15; i++) {
        [self addObjectWithDefaults:[PhTag class]];
    }
    
    [self setupDefaultObjects];
    
    [self refreshEveryMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNamesNotification object:nil];
    
    return self;
}

-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
        
    defaultRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];

    layerPolys = [[NSMutableArray alloc] init];
    layerLines = [[NSMutableArray alloc] init];
    layerPoints = [[NSMutableArray alloc] init];
    layerMapObjects = [[NSMutableArray alloc] init];
    layerNotes = [[NSMutableArray alloc] init];
    
    // There will be at least one layer...
    layersInLevel = [[NSMutableArray alloc] initWithCapacity:1];
    currentLayer = nil;
    
    points = [[NSMutableArray alloc] init];
    lines = [[NSMutableArray alloc] init];
    polys = [[NSMutableArray alloc] init];
    mapObjects = [[NSMutableArray alloc] init];
    sides = [[NSMutableArray alloc] init];
    lights = [[NSMutableArray alloc] init];
    notes = [[NSMutableArray alloc] init];
    media = [[NSMutableArray alloc] init];
    ambientSounds = [[NSMutableArray alloc] init];
    randomSounds = [[NSMutableArray alloc] init];
    itemPlacement = [[NSMutableArray alloc] init];
    platforms = [[NSMutableArray alloc] init];
    
    level_name = @"Untitled";
    
    noteTypes = [[NSMutableArray alloc] init];
    
    //defaultSide = [[LESide alloc] init];
    
    // ambientSoundNames randomSoundNames lightNames platformNames tagNames liquidNames
    // ambientSounds randomSounds lights platforms tags media
    
    // There will be at least sixteen tags to start out with...
    tags = [[NSMutableArray alloc] initWithCapacity:16];
    
    terimals = [[NSMutableArray alloc] init]; 
    
    namedPolyObjects = [[NSMutableArray alloc] init];
    
    levelOptions = [[NSMutableDictionary alloc] init];
    
    environment_code = 0;
    physics_model = 0;
    song_index = 0;
    mission_flags = 0;
    environment_flags = 0;
    
    [self refreshEveryMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNamesNotification object:nil];
    
    /*
    NSLog(@"**************************** TESTING FOR NILL ****************************");
    
    if (notContain(namedPolyObjects, nil))
        NSLog(@"OK!");
    else
        NSLog(@"PROBLEM!");
    */
    
    return self;
}

-(void)setupDefaultObjects
{
    int i = 0;
    
    for (i = 0; i < _NUMBER_OF_OBJECT_TYPES; i++)
    {
        defaultObjects[i] = [[LEMapObject alloc] init];
        [self setUpArrayPointersFor:defaultObjects[i]];
        [defaultObjects[i] setType:i];
    }
    
    defaultPolygon = [[LEPolygon alloc] init];
    [self setUpArrayPointersFor:defaultPolygon];
    [defaultPolygon setMediaLightsource:0];
    [defaultPolygon setFloorLightsource:0];
    [defaultPolygon setCeilingLightsource:0];
    
    
    defaultSide = [[LESide alloc] init];
    [self setUpArrayPointersFor:defaultSide];
    [defaultSide setPrimaryLightsourceIndex:0];
    [defaultSide setSecondaryLightsourceIndex:0];
    [defaultSide setTransparentLightsourceIndex:0];
    
    cDefaultSide  = [[LESide alloc] init];
    ccDefaultSide =[[LESide alloc] init];
    
    [defaultSide copySettingsTo:cDefaultSide];
    [defaultSide copySettingsTo:ccDefaultSide];
}

-(void)dealloc
{    //level_name = nil; // ???
    NSLog(@"Level Dealloc: %@", level_name);
    
    level_name = nil;
    
    
    // *** Deallocat Default Objects ***
    
    for (int i = 0; i < _NUMBER_OF_OBJECT_TYPES; i++) {
        defaultObjects[i] = nil;
    }
}

@end
