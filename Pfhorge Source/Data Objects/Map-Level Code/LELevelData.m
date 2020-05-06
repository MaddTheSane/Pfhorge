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

#import "PhData.h"


@interface LELevelData (private)
    /*-(void)setThePoints:(NSMutableArray *)thePoints;
    -(void)setTheLines:(NSMutableArray *)theLines;
    -(void)setThePolys:(NSMutableArray *)thePolygons;
    -(void)setTheMapObjects:(NSMutableArray *)theMapObjects;
    -(void)setSides:(NSMutableArray *)Sides;
    -(void)setLights:(NSMutableArray *)v;
    -(void)setNotes:(NSMutableArray *)v;
    -(void)setMedia:(NSMutableArray *)v;
    -(void)setAmbientSounds:(NSMutableArray *)v;
    -(void)setRandomSounds:(NSMutableArray *)v;
    -(void)setItemPlacement:(NSMutableArray *)v;
    -(void)setPlatforms:(NSMutableArray *)v;
    
    -(void)setTags:(NSMutableArray *)v;*/
@end


@implementation LELevelData
@synthesize levelName=level_name;
@synthesize environmentCode = environment_code;
@synthesize physicsModel=physics_model;
@synthesize songIndex=song_index;
@synthesize missionFlags=mission_flags;
@synthesize environmentFlags=environment_flags;
@synthesize entryPointFlags=entry_point_flags;

-(void)setSongIndex:(short)v
{
    if (v > 3 || v < 0)
        v = 0;
    
    song_index = v;
}

// **************************  Coding/Copy Protocal Methods  *************************
#pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********
- (void) encodeWithCoder:(NSCoder *)coder
{
    [self resetAdjacentPolygonAssociations];
    
    [super encodeWithCoder:coder];
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

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    defaultRoundingBehavior = [[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES] retain];
    
    //NSLog(@"1");
    
    environment_code = decodeShort(coder);
    physics_model = decodeShort(coder);
    song_index = decodeShort(coder);
    mission_flags = decodeShort(coder);
    environment_flags = decodeShort(coder);
    entry_point_flags = decodeInt(coder);
    
    //linesThatIBelongTo = decodeObj(coder);
    //NSLog(@"1");
    
    
    points = decodeObjRetain(coder);
    //NSLog(@"2");
    lines = decodeObjRetain(coder);
    //NSLog(@"3");
    polys = decodeObjRetain(coder);
    //NSLog(@"4");
    mapObjects = decodeObjRetain(coder);
    //NSLog(@"5");
    sides = decodeObjRetain(coder);
    //NSLog(@"6");
    lights = decodeObjRetain(coder);
    //NSLog(@"7");
    notes = decodeObjRetain(coder);
    //NSLog(@"8");
    media = decodeObjRetain(coder);
    //NSLog(@"9");
    ambientSounds = decodeObjRetain(coder);
    //NSLog(@"10");
    randomSounds = decodeObjRetain(coder);
    //NSLog(@"11");
    itemPlacement = decodeObjRetain(coder);
    //NSLog(@"12");
    platforms = decodeObjRetain(coder);
    //NSLog(@"13");
    
    terimals = decodeObjRetain(coder);
    //NSLog(@"14");
    
    layersInLevel = decodeObjRetain(coder);
    //NSLog(@"15");
    currentLayer = decodeObjRetain(coder);
    //NSLog(@"16");
    layerPoints = decodeObjRetain(coder);
    //NSLog(@"17");
    layerLines = decodeObjRetain(coder);
    //NSLog(@"18");
    layerPolys = decodeObjRetain(coder);
    //NSLog(@"19");
    layerMapObjects = decodeObjRetain(coder);
    //NSLog(@"20");
    
    //namedPolyObjects = decodeObj(coder);
    
    /*layerPolys = [[NSMutableArray alloc] initWithCapacity:0];
    layerLines = [[NSMutableArray alloc] initWithCapacity:0];
    layerPoints = [[NSMutableArray alloc] initWithCapacity:0];
    layerMapObjects = [[NSMutableArray alloc] initWithCapacity:0];
    namedPolyObjects = [[NSMutableArray alloc] initWithCapacity:0];*/
    
    tags = decodeObjRetain(coder);
    
    level_name = decodeObjRetain(coder);
    
    [self setUpArrayPointersForEveryObject];
    
    if (versionNum > 0) // this is if versionNum == 1...
       { noteTypes = decodeObjRetain(coder); }
    else
       { noteTypes = [[NSMutableArray alloc] init]; }
    
    if (versionNum > 1)
       { layerNotes = decodeObjRetain(coder); }
    else
       { layerNotes = [[NSMutableArray alloc] init]; }
    
    if (versionNum > 2)
    {
        
    }
    else
    {
        [self havePointsScanForLines];
    }
    
    [self setUpArrayNamesForEveryObject];
    //[self recaculateTheCurrentLayer];
    [self setupDefaultObjects];
    [self resetAdjacentPolygonAssociations];
    
    return self;
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
    NSEnumerator *numer;
    BOOL listIncludesNone;
    int i, j;
    
    // *** Start Main Code ***
    
    
    for (i = 0; i < 7; i++)
    {
        switch (i)
        {
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
        numer = [theAcutalObjectsArray objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if (i < 5)
            {
                NSString *theName = [NSString localizedStringWithFormat:@"%d", j];
                [theObj setPhName:theName];
                
                if (theName == nil)
                {
                    NSLog(@"REPORT THIS PLEASE: *** theName was nil in name caching... #1");
                    [theObj setPhName:@"Name Was Nil? 1"];
                    theName = @"Name Was Nil? 1";
                    //continue;
                }
                
                [theNamesCacheArray addObject:theName];
                j++;
            }
            else if (i == 5 || i == 6) // Layers/Terminals arleady have there name...
            {
                if (theObj == nil)
                {
                    NSLog(@"REPORT THIS PLEASE: *** theObj was nil in name caching... #3");
                    continue;
                }
                
                if ([theObj getPhName] == nil)
                {
                    NSLog(@"REPORT THIS PLEASE: *** [theObj getPhName] was nil in name caching... #2");
                    [theObj setPhName:@"Name Was Nil? 2"];
                    //continue;
                }
                [theNamesCacheArray addObject:[theObj getPhName]];
                j++;
            }
        }
    }
    
    NSLog(@"Check To See which polygons need names...");
    
    { // Checking polygons to see if I need to name some polygons...
        LEPolygon *thePolyToCheck;
        id thePolyPointedTo;
        id theObj;
        NSEnumerator *spenumer = [polys objectEnumerator];
        while (thePolyToCheck = [spenumer nextObject])
        {
            switch ([thePolyToCheck getType])
            {
                case _polygon_is_platform_on_trigger:
                case _polygon_is_platform_off_trigger:
                case _polygon_is_teleporter:
                    thePolyPointedTo = [thePolyToCheck getPermutationObject];
                    // This Might Be able To Insert Nil Objects Into An Array...
                    [self namePolygon:thePolyPointedTo to:stringFromInt([thePolyPointedTo getIndex])];
                    break;
                default:
                    break;
            }
        }
        
        spenumer = [sides objectEnumerator];
        while (theObj = [spenumer nextObject])
        {
            switch ([theObj getPermutationEffects])
            {
                case 0:
                    
                    break;
                case _cpanel_effects_light:
                    
                    break;
                case _cpanel_effects_polygon:
                    thePolyPointedTo = [theObj getControl_panel_permutation_object];
                    // This Might Be able To Insert Nil Objects Into An Array...
                    [self namePolygon:thePolyPointedTo to:stringFromInt([thePolyPointedTo getIndex])];
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
    numer = [lights objectEnumerator];
    for (PhLight *theObj in numer)
    {
        NSNumber *theNumber;
        theNumber = [NSNumber numberWithShort:[theObj tag]];
        
        if (theNumber == nil)
        {
            NSLog(@"*** theNumber from light tag was nil in name caching...");
            continue; // Continues at 'while (theObj = [numer nextObject]) // get next Light object'
        }
        
        //Check to see if this number is already in the list...
        if ([tmpNumberList indexOfObject:theNumber] == NSNotFound)
            [tmpNumberList addObject:theNumber];
    }
    
    // Gets Tags In Platform Objects
    numer = [platforms objectEnumerator];
    for (PhPlatform *theObj in numer)
    {
        NSNumber *theNumber;
        theNumber = [NSNumber numberWithShort:[theObj tag]];
        
        if (theNumber == nil)
        {
            NSLog(@"*** theNumber from platform tag was nil in name caching...");
            continue; // Continues at 'while (theObj = [numer nextObject]) // get next Platform object'
        }
        
        //Check to see if this number is already in the list...
        if ([tmpNumberList indexOfObject:theNumber] == NSNotFound)
            [tmpNumberList addObject:theNumber];
    }
    
    // Gets Tags In Side Objects
    numer = [sides objectEnumerator];
    while (theObj = [numer nextObject]) // get next side object
    {
        NSNumber *theNumber = nil;
        int theControlPanelType = [theObj getAdjustedControlPanelType];
        
        switch (theControlPanelType)
        {
            case _panel_tagSwitch:
                theNumber = [NSNumber numberWithShort:[theObj getControl_panel_permutation]];
                break;
            case _panel_chipInserton:
                theNumber = [NSNumber numberWithShort:[theObj getControl_panel_permutation]];
                break;
            case _panel_wires:
                theNumber = [NSNumber numberWithShort:[theObj getControl_panel_permutation]];
                break;
        }
        
        if (theNumber == nil)
        {
            // NSLog(@"*** theNumber from side tag was nil in name caching...");
            continue; // Continues at 'while (theObj = [numer nextObject]) // get next side object'
        }
        
        //Check to see if this number is already in the list...
        if ([tmpNumberList indexOfObject:theNumber] == NSNotFound)
            [tmpNumberList addObject:theNumber];
    }
    
    // check to see if the array contains more then one tag...
    if ([tmpNumberList count] > 1)
    {
        // if it does contain more then one object, sort it...
        // *** May have to convert array to mutable array? ***
        
        // Could be just a NSArray, but I am going to, for now, cast it to NSMutableArray...
        NSMutableArray *sortedArray = (NSMutableArray *)[tmpNumberList sortedArrayUsingSelector:@selector(compare:)];
        
        [tmpNumberList release];
        tmpNumberList = sortedArray;
        [tmpNumberList retain];
    }
    
    //if (heightMode == _drawAmbientSounds || _drawLiquidLights:_drawLiquids
    if ([tmpNumberList indexOfObject:[NSNumber numberWithShort:((short)(-1))]] == NSNotFound)
    {
        listIncludesNone = NO;
	//SEND_ERROR_MSG_TITLE(@"There is no -1 (NONE) tag", @"Information - Did Not Find NONE Tag");
    }
    else
    {
        listIncludesNone = YES;
        // SEND_ERROR_MSG_TITLE(@"There is a -1 (NONE) tag, is this possible? ]:=>", @"Information - Found NONE Tag ???");
    }
    
    if (tags ==  nil)
    {
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
        [tagNames addObject:[theTag getPhName]];
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
    NSEnumerator *numer;
    id theObj;
    
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
    
    numer = [polys objectEnumerator];
    while (theObj = [numer nextObject])
    {
        if ([theObj doIHaveAName])
        {
            [polyNames addObject:[theObj getPhName]];
            [namedPolyObjects addObject:theObj];
        }
        
        if ([theObj getType] == _polygon_is_platform)
        {
            if ([[theObj getPermutationObject] polygonObject] != theObj)
            { // The polygon points to a platform which does not point back
              //   to the polygon...  This will fix that, hopefully...
                [[theObj getPermutationObject] setPolygon_object:theObj];
            }
        }
    }
    
    numer = [lights objectEnumerator];
    while (theObj = [numer nextObject])
        [lightNames addObject:[theObj getPhName]];
    
    numer = [media objectEnumerator];
    while (theObj = [numer nextObject])
        [liquidNames addObject:[theObj getPhName]];
    
    numer = [ambientSounds objectEnumerator];
    while (theObj = [numer nextObject])
        [ambientSoundNames addObject:[theObj getPhName]];
    
    numer = [randomSounds objectEnumerator];
    while (theObj = [numer nextObject])
        [randomSoundNames addObject:[theObj getPhName]];
    
    numer = [platforms objectEnumerator];
    while (theObj = [numer nextObject])
        [platformNames addObject:[theObj getPhName]];
    
    numer = [layersInLevel objectEnumerator];
    while (theObj = [numer nextObject])
        [layerNames addObject:[theObj getPhName]];
    
    numer = [tags objectEnumerator];
    while (theObj = [numer nextObject])
        [tagNames addObject:[theObj getPhName]];

    numer = [terimals objectEnumerator];
    while (theObj = [numer nextObject])
        [terminalNames addObject:[theObj getPhName]];
    
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
    NSEnumerator *numer = nil;
    id theObj = nil;
    NSMutableData *exportData = [[NSMutableData alloc] init];
    NSMutableData *finnalData = [[NSMutableData alloc] init];
    short tmpShort = 0;
    short appendNumber = 0;
    
    numer = [objects objectEnumerator];
    while (theObj = [numer nextObject])
    {
        if ([exports indexOfObjectIdenticalTo:theObj] == NSNotFound)
        {
            [theObj exportWithIndex:exports withData:exportData mainObjects:objects];
        }
    }
    
    short totalObjs = [exports count];
    long indexEntrys = totalObjs;
    
    #ifdef useDebugingLogs
        NSLog(@"Total Exports: %d", totalObjs);
    #endif
    
    [finnalData appendBytes:&indexEntrys length:4];
    
    numer = [exports objectEnumerator];
    while (theObj = [numer nextObject])
    {
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
        
        
        
        int customNameStatus = _data_has_no_name;
        
        if ([theObj isKindOfClass:[PhAbstractName class]])
        {
            if ([theObj doIHaveACustomName])
            {
                customNameStatus = _data_has_no_name;
            }
            else if ([theObj doIHaveAName])
            {
                customNameStatus = _data_has_regular_name;
            }
            else
            {
                customNameStatus = _data_has_no_name;
            }
        }
        else
        {
            customNameStatus = _data_has_no_name;
        }
        
        
        
        [finnalData appendBytes:&tmpShort length:2];
        [finnalData appendBytes:&appendNumber length:2];
        [finnalData appendBytes:&customNameStatus length:2];
    }
    
    [finnalData appendData:exportData];
    
    [exportData release];
    [exports release];
    
    return [finnalData autorelease];
}

- (NSSet *)importObjects:(NSData *)theData
{
    PhData *myData = [[[PhData alloc] initWithSomeData:theData] autorelease];
    NSMutableArray *index = [[[NSMutableArray alloc] init] autorelease];
    NSMutableSet *theSet = [[[NSMutableSet alloc] init] autorelease];
    
    ///NSEnumerator *numer = nil;
    id theObj = nil;
    
    int totalObjects = [myData getInt];
    ///long indexBytes = totalObjects*4;
    
    short objTypesArr[totalObjects];
    BOOL objImported[totalObjects];
    short objKindArr[totalObjects];
    short objNameStatusArr[totalObjects];
    
    int i = 0;
    
    #ifdef useDebugingLogs
        NSLog(@"Total Imports: %d  --- Allocating Objects...", totalObjects);
    #endif
    
    for (i = 0; i < totalObjects; i++)
    {
        objTypesArr[i] = [myData getShort]; // Primary or Secondary?
        objImported[i] = NO;
        objKindArr[i] = [myData getShort]; // Light or Polygon?, etc...
        objNameStatusArr[i] = [myData getShort]; // Name Status...
        short objKind = objKindArr[i];
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
        [obj release];
    }
    
    //NSLog(@"Importing Commencing...");
    
    BOOL stillImporting = YES;
    
    while (stillImporting)
    {
        for (i = 0; i < totalObjects; i++)
        {
            theObj = [index objectAtIndex:i];
            
            if (objImported[i] == NO && objTypesArr[i] == _data_is_primary)
            {
                if ([myData addP:4] == NO)
                    NSLog(@"Went Beyond Import Bounds...");
                
                [theObj importWithIndex:index withData:myData useOrginals:NO objTypesArr:objTypesArr];
                objImported[i] = YES;
            }
            else
            {
                if ((i+1) != totalObjects)
                    if ([myData skipLengthLong] == NO)
                        NSLog(@"Went Beyond Import Bounds...");
            }
        }
        
        for (i = 0; i < totalObjects; i++)
        {
            if (objImported[i] == NO && objTypesArr[i] == _data_is_primary)
            {
                stillImporting = YES;
                break;
            }
            else
            {
                stillImporting = NO;
            }
        }
    }
    #ifdef useDebugingLogs
        NSLog(@"Done Importing...");
    #endif
    // - (void)checkP;
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
#pragma mark -
#pragma mark ********* Intial Setup And Deallocation *********


-(LELevelData *)initForNewPathwaysPIDLevel
{
    int i, j;
    
    [self init];
    
    if (self == nil)
        return nil;
    
    level_name = [@"Untitled Level" retain];
    
    enum {PID_LIGHT_SET_RANGE = 20};	// Kludgy way of doing "const" in plain C
    for (i = PID_LIGHT_SET_RANGE; i >= 0; i--)
    {
        PhLight *newLight = [self addObjectWithDefaults:[PhLight class]];
        long intensity = (long)(((float)(i)/PID_LIGHT_SET_RANGE) * 65534) + 1;
        unsigned short theFlags = 0;
        
        theFlags |= PhLightStaticFlagIsInitiallyActive;
        
        [newLight setType:_normal_light];
        [newLight setFlags:theFlags];
        [newLight setPhase:0];
        [newLight setTag:0];
        
        for (j = 0; j < _NUMBER_OF_LIGHT_STATES; j++)
        {
            [newLight setFunction:_constant_lighting_function forState:j];
            [newLight setPeriod:60 forState:j];
            [newLight setDeltaPeriod:0 forState:j];
            [newLight setIntensity:intensity forState:j];
            [newLight setDeltaIntensity:0 forState:j];
        }
    }
    
    for (i = 0; i < 128; i++)
    {
        PhItemPlacement *theNewItemPlacObj = [[PhItemPlacement alloc] init];
        [itemPlacement addObject:theNewItemPlacObj];
        [theNewItemPlacObj release];
    }
    
    [self setupLayersForNewPIDLevel];
    [self compileAndSetNameArraysFromLevel];
    [self updateCounts];
    
    for (i = 0; i < 15; i++)
        [self addObjectWithDefaults:[PhTag class]];
    
    [self setupDefaultObjects];
    
    [self refreshEveryMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
    
    return self;
}


-(LELevelData *)initAndGenerateNewLevelObjects
{
    int i, j;
    
    [self init];
    
    if (self == nil)
        return nil;
    
    level_name = [@"Untitled Level" retain];
    
    for (i = 20; i >= 0; i--)
    {
        PhLight *newLight = [self addObjectWithDefaults:[PhLight class]];
        long intesity = (long)((float)((float)(i * 5) / 100) * 65534) + 1;
        unsigned short theFlags = 0;
        
        theFlags |= PhLightStaticFlagIsInitiallyActive;
        
        [newLight setType:_normal_light];
        [newLight setFlags:theFlags];
        [newLight setPhase:0];
        [newLight setTag:0];
        
        for (j = 0; j < _NUMBER_OF_LIGHT_STATES; j++)
        {
            [newLight setFunction:_constant_lighting_function forState:j];
            [newLight setPeriod:60 forState:j];
            [newLight setDeltaPeriod:0 forState:j];
            [newLight setIntensity:intesity forState:j];
            [newLight setDeltaIntensity:0 forState:j];
        }
    }
    
    for (i = 0; i < 128; i++)
    {
        PhItemPlacement *theNewItemPlacObj = [[PhItemPlacement alloc] init];
        [itemPlacement addObject:theNewItemPlacObj];
        [theNewItemPlacObj release];
    }
    
    [self setupLayers];
    [self compileAndSetNameArraysFromLevel];
    [self updateCounts];
    
    for (i = 0; i < 15; i++)
        [self addObjectWithDefaults:[PhTag class]];
    
    [self setupDefaultObjects];
    
    [self refreshEveryMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
    
    return self;
}

-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
        
    defaultRoundingBehavior = [[NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES] retain];

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
    
    level_name = [[NSString alloc] initWithString:@"Untitled"];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
    
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
    [defaultPolygon setMedia_lightsource:0];
    [defaultPolygon setFloor_lightsource:0];
    [defaultPolygon setCeiling_lightsource:0];
    
    
    defaultSide = [[LESide alloc] init];
    [self setUpArrayPointersFor:defaultSide];
    [defaultSide setPrimary_lightsource_index:0];
    [defaultSide setSecondary_lightsource_index:0];
    [defaultSide setTransparent_lightsource_index:0];
    
    cDefaultSide  = [[LESide alloc] init];
    ccDefaultSide =[[LESide alloc] init];
    
    [defaultSide copySettingsTo:cDefaultSide];
    [defaultSide copySettingsTo:ccDefaultSide];
}

-(void)dealloc
{    //level_name = nil; // ???
    NSLog(@"Level Dealloc: %@", level_name);
    
    level_name = nil;
    
    [points release];
    [lines release];
    [polys release];
    [mapObjects release];
    [sides release];
    [lights release];
    [notes release];
    [media release];
    [ambientSounds release];
    [randomSounds release];
    [itemPlacement release];
    [platforms release];
    
    [tags release];
    
    [terimals release];
    
    [level_name release];
    
    currentLayer = nil;
    [layersInLevel release];
    
    [layerPoints release];
    [layerLines release];
    [layerPolys release];
    [layerMapObjects release];
    [layerNotes release];
    
    [namedPolyObjects release];
    
    [levelOptions release];
    
    // *** Deallocat Default Objects ***
    
    int i = 0;
    
    for (i = 0; i < _NUMBER_OF_OBJECT_TYPES; i++)
    {
        [defaultObjects[i] release];
        defaultObjects[i] = nil;
    }
    
    [defaultPolygon release];
    defaultPolygon = nil;
    
    [defaultSide release];
    defaultSide = nil;
    
    [cDefaultSide release];
    [ccDefaultSide release];
    cDefaultSide = nil;
    ccDefaultSide = nil;
    
    [noteTypes dealloc];
    
    [super dealloc];
}








@end
