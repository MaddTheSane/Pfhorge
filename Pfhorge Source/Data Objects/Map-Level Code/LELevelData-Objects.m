//
//  LELevelData-Objects.m
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
#import "PhNoteGroup.h"

#import "Terminal.h"
#import "TerminalSection.h"

#import "LEExtras.h"

@implementation LELevelData (LevelDataObjectManipulation)
// *************************** Adding Objects To Level Array Methods ***************************
#pragma mark -
#pragma mark *********  Adding Objects To Level Array Methods *********

//#define showDebugDeletionsAndAddtions

-(id)new:(Class)theClass { return [self addObjectWithDefaults:theClass]; }

-(id)addObjectWithDefaults:(Class)theClass /*useCC:(BOOL)useCC*/
{
    LEMapDraw *theDrawView = [theLevelDocument getMapDrawView];
    
    BOOL useCC = NO;
    
    if (theClass == [LEMapPoint class])
    {
	LEMapPoint *newPoint = [[LEMapPoint alloc] init];
        [self setUpArrayPointersFor:newPoint];
        [self addPoint:newPoint];
        [newPoint release];
        return newPoint;
    }
    else if (theClass == [LELine class])
    {
	LELine *newLine = [[LELine alloc] init];
        [self setUpArrayPointersFor:newLine];
        [self addLine:newLine];
        [newLine release];
        return newLine;
    }
    else if (theClass == [LEPolygon class])
    {
	NSLog(@"Can't add a polygon object this way, yet... ]:=>");
    }
    else if (theClass == [LEMapObject class])
    {
        LEMapObject *theNewObject = [[LEMapObject alloc] initWithMapObject:defaultObjects[_saved_monster] withLevel:self];
        [mapObjects addObject:theNewObject];
        [layerMapObjects addObject:theNewObject];
        //[self setUpArrayPointersFor:theNewObject];
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added LEMapObject with index #%d", [theNewObject getIndex]);
        #endif
        [theNewObject release];
        return theNewObject;
    }
    else if (theClass == [LESide class])
    {
	//LESide *theNewSide = [defaultSide copy];
        LESide *theNewSide = [[LESide alloc] init];
        [sides addObject:theNewSide];
        
        if (useCC == YES && ccHasDefaultSide == YES)
        {
            //[ccDefaultSide copySettingsTo:theNewSide];
            
            // For right now, just use the defaultSide...
            [defaultSide copySettingsTo:theNewSide];
        }
        else
        {	// If possible, the default side should be
                // a clockwise side...
            [defaultSide copySettingsTo:theNewSide];
        }
        
        
        [self setUpArrayPointersFor:theNewSide];
        
        // Why is this setting lights, when the default settings
        // were just copyed over to the new side?
        
        //[theNewSide setPrimary_lightsource_object:[lights objectAtIndex:0]];
        //[theNewSide setSecondary_lightsource_object:[lights objectAtIndex:0]];
        //[theNewSide setTransparent_lightsource_object:[lights objectAtIndex:0]];
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added LESide object with index #%d", [theNewSide getIndex]);
        #endif
        [theNewSide release];
        return theNewSide;
    }
    else if (theClass == [PhLight class])//([theClass isKindOfClass:[PhLight class]])
    {
        PhLight *theNewObj = [[PhLight alloc] init];
        NSString *theName;
        [lights addObject:theNewObj];
        [self setUpArrayPointersFor:theNewObj];
        
        theName = [NSString localizedStringWithFormat:@"%d", [theNewObj index]];
        [theNewObj setPhName:theName];
        [lightNames addObject:theName];
        
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added PhLight object with index #%d", [theNewObj getIndex]);
        #endif
        [theNewObj release];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
        [theDrawView updateNameList:_lightMenu];
        return theNewObj;
    }
    else if (theClass == [PhMedia class])
    {
        PhMedia *theNewObj = [[PhMedia alloc] init];
        NSString *theName;
        [media addObject:theNewObj];
        [self setUpArrayPointersFor:theNewObj];
        
        theName = [NSString localizedStringWithFormat:@"%d", [theNewObj index]];
        [theNewObj setPhName:theName];
        [liquidNames addObject:theName];
        
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added PhMedia object with index #%d", [theNewObj getIndex]);
        #endif
        [theNewObj release];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
        [theDrawView updateNameList:_liquidMenu];
        return theNewObj;
    }
    else if (theClass == [PhAmbientSound class])
    {
        PhAmbientSound *theNewObj = [[PhAmbientSound alloc] init];
        NSString *theName;
        [ambientSounds addObject:theNewObj];
        [self setUpArrayPointersFor:theNewObj];
        
        theName = [NSString localizedStringWithFormat:@"%d", [theNewObj index]];
        [theNewObj setPhName:theName];
        [ambientSoundNames addObject:theName];
        
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added PhAmbientSound object with index #%d", [theNewObj getIndex]);
        #endif
        [theNewObj release];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
        [theDrawView updateNameList:_ambientSoundMenu];
        return theNewObj;
    }
    else if (theClass == [PhRandomSound class])
    {
        PhRandomSound *theNewObj = [[PhRandomSound alloc] init];
        NSString *theName;
        [randomSounds addObject:theNewObj];
        [self setUpArrayPointersFor:theNewObj];
        
        theName = [NSString localizedStringWithFormat:@"%d", [theNewObj index]];
        [theNewObj setPhName:theName];
        [randomSoundNames addObject:theName];
        
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added PhRandomSound object with index #%d", [theNewObj getIndex]);
        #endif
        [theNewObj release];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
        [theDrawView updateNameList:_randomSoundMenu];
        return theNewObj;
    }
    else if (theClass == [PhItemPlacement class])
    {
	PhItemPlacement *theNewObj = [[PhItemPlacement alloc] init];
        [itemPlacement addObject:theNewObj];
        [self setUpArrayPointersFor:theNewObj];
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added PhItemPlacement object with index #%d", [theNewObj getIndex]);
        #endif
        [theNewObj release];
        return theNewObj;
    }
    else if (theClass == [PhPlatform class])
    {
	PhPlatform *theNewObj = [[PhPlatform alloc] init];
        NSString *theName;
        [platforms addObject:theNewObj];
        [self setUpArrayPointersFor:theNewObj];
        
        theName = [NSString localizedStringWithFormat:@"%d", [theNewObj index]];
        [theNewObj setPhName:theName];
        [platformNames addObject:theName];
        
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added PhPlatform object with index #%d", [theNewObj getIndex]);
        #endif
        [theNewObj release];
        ///[[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
        return theNewObj;
    }
    else if (theClass == [PhAnnotationNote class])
    {
	PhAnnotationNote *theNewObj = [[PhAnnotationNote alloc] init];
        [notes addObject:theNewObj];
        [layerNotes addObject:theNewObj];
        [self setUpArrayPointersFor:theNewObj];
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added PhAnnotationNote object with index #%d", [theNewObj getIndex]);
        #endif
        [theNewObj release];
        return theNewObj;
    }
    else if (theClass == [PhTag class])
    {
        NSNumber *theNum = [NSNumber numberWithInt:(([[[tags lastObject] phNumber] intValue]) + 1)];
        PhTag *theNewTag = [self addNewTagWithNumber:theNum]; // this adds to naems and sets up array pointers...
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Added PhTag object with index #%d", [theNewTag getIndex]);
        #endif
        [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
        return theNewTag;
    }
    else if (theClass == [PhLayer class])
    {
        PhLayer *theNewLayer = [[PhLayer alloc] initWithName:@"Untitled Layer"];
        [self addLayer:theNewLayer];
        [self setUpArrayPointersFor:theNewLayer];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
        [theDrawView updateNameList:_layerMenu];
        
        return [theNewLayer autorelease];
    }
    else
        SEND_ERROR_MSG(@"I tried to add a unknown object class to level?");
    
    return nil;
}

-(void)addObject:(id)objectToAdd
{
    [self addObjects:objectToAdd];
}

-(void)addObjects:(id)objectToAdd
{
    BOOL nameRequired = NO;
    
    [self setUpArrayPointersFor:objectToAdd];
    
    // Check to make sure there are no duplicate objects added!!!
    
    if ([objectToAdd isKindOfClass:[LEMapPoint class]])
    {
        [self addPoint:objectToAdd];
    }
    else if ([objectToAdd isKindOfClass:[LELine class]])
    {
        [self addLine:objectToAdd];
    }
    else if ([objectToAdd isKindOfClass:[LEPolygon class]])
    {
        [self addPolygon:objectToAdd];
    }
    else if ([objectToAdd isKindOfClass:[LEMapObject class]])
    { // Might want to do some extra checking...
        [mapObjects addObject:objectToAdd];
        [layerMapObjects addObject:objectToAdd];
    }
    else if ([objectToAdd isKindOfClass:[LESide class]])
    {
        [sides addObject:objectToAdd];
    }
    
    /*    *points, *lines, *polys, *mapObjects, *sides,
                    *lights, *notes, *media, *ambientSounds,
                    *randomSounds, *itemPlacement, *platforms;
    */
    
    else if ([objectToAdd isKindOfClass:[PhLayer class]])
    {
        [layersInLevel addObject:objectToAdd];
        
        nameRequired = YES;
    }
    else if ([objectToAdd isKindOfClass:[PhAnnotationNote class]])
    {
        if (notContain(notes, objectToAdd))
            [notes addObject:objectToAdd];
        
        [layerNotes addObject:objectToAdd];
        
        nameRequired = NO;
    }
    else if ([objectToAdd isKindOfClass:[PhPlatform class]])
    {
        //nameRequired = YES;
        [self addPlatform:objectToAdd];
    }
    else if ([objectToAdd isKindOfClass:[PhRandomSound class]])
    {
        nameRequired = YES;
    }
    else if ([objectToAdd isKindOfClass:[PhAmbientSound class]])
    {
        nameRequired = YES;
    }
    else if ([objectToAdd isKindOfClass:[PhMedia class]])
    {
        nameRequired = YES;
    }
    else if ([objectToAdd isKindOfClass:[PhLight class]])
    {
        nameRequired = YES;
    }
    else if ([objectToAdd isKindOfClass:[PhTag class]])
    {
        nameRequired = YES;
    }
    else
    {
        // Unknown Object Class...
        nameRequired = NO;
    }
    
    if ([objectToAdd isKindOfClass:[PhAbstractName class]] && nameRequired == YES)
    {
        // if it has a name, then its a custom name...
        if ([objectToAdd doIHaveAName] == NO)
        { // No name, so make the name the objects index number...
            [objectToAdd resetNameToMyIndex];
        }
        
        [self checkName:objectToAdd];
    }
    
    [[NSNotificationCenter defaultCenter]
            postNotificationName:PhLevelStatusBarUpdate
            object:self];
    
    // ????????
    //[[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNames object:nil];
}

-(PhTag *)addNewTagWithNumber:(NSNumber *)theTagNumber
{
    //NSNumber *theTagNum = [NSNumber numberWithInt:theTagInt];
    
    PhTag *theNewObj = [[PhTag alloc] initWithTagNumber:theTagNumber];
    NSString *theName;
    [tags addObject:theNewObj];
    [self setUpArrayPointersFor:theNewObj];
    
    theName = [theTagNumber stringValue];
    [theNewObj setPhName:theName];
    [tagNames addObject:theName];
    #ifdef showDebugDeletionsAndAddtions
    NSLog(@"Added PhTag object with tag number #%d", [theTagNumber intValue]);
    #endif
    [theNewObj release];
    return theNewObj;
}

-(void)addPlatform:(PhPlatform *)thePlatformToAdd
{
    NSString *theName = nil;
    [platforms addObject:thePlatformToAdd];
    [self setUpArrayPointersFor:thePlatformToAdd];
    
    theName = [NSString localizedStringWithFormat:@"%d", [thePlatformToAdd index]];
    [thePlatformToAdd setPhName:theName];
    [platformNames addObject:theName];
}

-(void)addPoint:(LEMapPoint *)thePointToAdd
{
    if ([points indexOfObjectIdenticalTo:thePointToAdd] == NSNotFound)
    {
        [points addObject:thePointToAdd];
    }
    
    [self setUpArrayPointersFor:thePointToAdd];
    
    if ([layerPoints indexOfObjectIdenticalTo:thePointToAdd] == NSNotFound)
    {
        [layerPoints addObject:thePointToAdd];
    }
}

-(void)addLine:(LELine *)theLineToAdd
{
    // ********* Make sure to set the clockwise/counter clocksie stuff
    // 		Correctly, and set the highes/lowest ajcent ceiling/floor
    //		Also, give this the templates settings!!! *********
    
    if ([lines indexOfObjectIdenticalTo:theLineToAdd] == NSNotFound)
    {
        [lines addObject:theLineToAdd];
    }
    
    [self setUpArrayPointersFor:theLineToAdd];
    
    if ([layerLines indexOfObjectIdenticalTo:theLineToAdd] == NSNotFound)
    {
        [layerLines addObject:theLineToAdd];
    }
}

-(void)addPolygonDirectly:(LEPolygon *)thePolyToAdd
{
    //int c = [thePolyToAdd getTheVertexCount];
    //NSEnumerator *numer;
    //id thisObj;
    //int i;
    
    
    if ([polys indexOfObjectIdenticalTo:thePolyToAdd] != NSNotFound)
        return; // Might want to do some more checking at this point...
    
    NSLog(@"Directly Adding Polygon");
    
    if ([polys indexOfObjectIdenticalTo:thePolyToAdd] == NSNotFound)
    {
        [polys addObject:thePolyToAdd]; // Check it out first?
    }
    
    [self setUpArrayPointersFor:thePolyToAdd]; 
    
    if (currentLayer != nil)
        [thePolyToAdd setPolyLayer:currentLayer];
    else
        [thePolyToAdd setPolyLayer:[layersInLevel lastObject]];
    
    if ([layerPolys indexOfObjectIdenticalTo:thePolyToAdd] == NSNotFound)
    {
        [layerPolys addObject:thePolyToAdd];
    }
    
    [thePolyToAdd calculateSidesForAllLines];
    
    if ([thePolyToAdd doIHaveAName] == YES)
    {
        [self namePolygon:thePolyToAdd to:[thePolyToAdd phName]];
    }
}

-(void)addPolygon:(LEPolygon *)thePolyToAdd
{
    NSEnumerator *numer;
    ///NSEnumerator *numer2;
    
    // *** Make sure to do checks here to make sure this polygon is ok!!! ***
    // *** Also, give this the templates settings!!! ***
    
    if (thePolyToAdd != nil)
    {
        NSMutableArray *polyLines = [[NSMutableArray alloc] initWithCapacity:1];
        int i;
        int c = [thePolyToAdd getTheVertexCount];
        id thisObj/*, thisObj2*/;
        NSRect newPolyRect;
        #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Adding Polygon");
        #endif
        [polys addObject:thePolyToAdd]; // Check it out first?
        [self setUpArrayPointersFor:thePolyToAdd];        
        //[thePolyToAdd updateObjectsFromIndexes];
        
        [thePolyToAdd setFloorLightsourceObject:[lights objectAtIndex:0]];
        [thePolyToAdd setCeilingLightsourceObject:[lights objectAtIndex:0]];
        [thePolyToAdd setMediaLightsourceObject:[lights objectAtIndex:0]];
        
        if (currentLayer != nil)
            [thePolyToAdd setPolyLayer:currentLayer];
        else
            [thePolyToAdd setPolyLayer:[layersInLevel lastObject]];
        
        [layerPolys addObject:thePolyToAdd];
        [thePolyToAdd setPolyLayer:currentLayer];
        
        newPolyRect = [thePolyToAdd drawingBounds];
        
        // getLineObjects
        for(i = 0; i < c; i++)
            [polyLines addObject:[thePolyToAdd lineObjectAtIndex:i]];
        
        i = -1;
        numer = [polyLines objectEnumerator];
        while (thisObj = [numer nextObject])
        {
            LEPolygon *poly1 = [thisObj clockwisePolygonObject];
            LEPolygon *poly2 = [thisObj conterclockwisePolygonObject];
            ///LEMapPoint *p1 = [thisObj mapPoint1]; // Beta Point
            ///LEMapPoint *p2 = [thisObj mapPoint2]; // Alpha Point
            LEPolygon *otherPoly;
            int result;
            //NSRect otherPolyRect;
            
            if (poly1 != nil)
            {
                otherPoly = poly1;
                i++;
                [thePolyToAdd setAdjacentPolygonObject:otherPoly toIndex:i];
            }
            else if (poly2 != nil)
            {
                otherPoly = poly2;
                i++;
                [thePolyToAdd setAdjacentPolygonObject:otherPoly toIndex:i];
            }
            else if (poly1 != nil && poly2 != nil)
            { // This line could already have two polygons???
                SEND_ERROR_MSG(@"When setting Clockwise, Etc. Ownership, while adding poly to level poly array, both where not nil??? Major Error With Level File!");
                return; // Delete from poly array?
            }
            else
            {
                otherPoly = nil; 
                //i++;
                //[thePolyToAdd setAdjacentPolygonObject:otherPoly i:i];
            }
            
            //p32n1 p32n2 newPolyRect
            
            result = [self whatIsDirectionalRelationshipForLine:thisObj relitiveTo:polyLines];
            
            
            
            //   Let the caculateSides line function do
            //   the following that has been commented out...
            
            
            /*[(LELine *)thisObj setFlags:0];
            
            if (otherPoly != nil)
            {
                [thisObj setFlag:LELineTransparent to:YES];
                [thisObj setFlag:LELineSolid to:NO];
            }
            else
            {
                [thisObj setFlag:LELineTransparent to:NO];
                [thisObj setFlag:LELineSolid to:YES];
            }*/
            
            
            switch (result)
            {
                case _line_is_clockwise:
                    [thisObj setClockwisePolygonObject:thePolyToAdd];
                    [thisObj setConterclockwisePolygonObject:otherPoly];
                    break;
                case _line_is_counter_clockwise:
                    [thisObj setClockwisePolygonObject:otherPoly];
                    [thisObj setConterclockwisePolygonObject:thePolyToAdd];
                    break;
                case _poly_could_be_bad:
                    SEND_ERROR_MSG_TITLE(@"Polygon that was just added and/or lines/points making it up could be corupted!",
                                         @"Bad Polygon/Lines/Points");
                    NSLog(@"Bad data detected, in future releases I will attempt to fix this problem...");
                    break;
                case _unknown:
                    SEND_ERROR_MSG_TITLE(@"Polygon that was just added and/or lines/points making it up are/is in a unknown state!",
                                         @"Polygon In Unknown State");
                    NSLog(@"Somthing strange and unknown happned, please send me a bug report about this!...");
                    break;
                default:
                    SEND_ERROR_MSG_TITLE(@"In the level->addPolygon: method, an unknown result code was returned...",
                                         @"Major Program Logic Error");
                    NSLog(@"Major Program Logic Error: In the level->addPolygon: method, an unknown result code was returned... Bug Report!!!");
                    break;
            }
            
            //if (otherPoly == nil)
            
            [self addSidesForLine:thisObj];
            
        }
        
        //[??? unionSet:polyLines];
        // Might want to call updateIndexesFromObjects instead?
        [polyLines release];
    }
    else
        SEND_ERROR_MSG(@"A nil polygon was attempted to being added to the level polygons array, ERROR");
    
}

- (PhNoteGroup *)newNoteType
{
    PhNoteGroup *noteType = [[PhNoteGroup alloc] init];
    [noteTypes addObject:noteType];
    [self setUpArrayPointersFor:noteType];
    return noteType;
}

- (PhNoteGroup *)newNoteType:(NSString *)name
{
    PhNoteGroup *noteType = [[PhNoteGroup alloc] initWithName:name];
    [noteTypes addObject:noteType];
    [self setUpArrayPointersFor:noteType];
    return noteType;
}

#pragma mark -
#pragma mark ••• Move This To Utility Functions •••

    // ### Move following method to Pfhorge Independit Utility Functions ###
-(int)whatIsDirectionalRelationshipForLine:(LELine *)theLine relitiveTo:(NSArray *)lineArray
{
    NSEnumerator *numer;
    LELine *thisMapLine = nil, *tmpLine, *currentLine = theLine;
    ///LEMapPoint *theCurPoint1;
    ///LEMapPoint *theCurPoint2;
    // *** *** ***
    LELine *smallestLine;
    LEMapPoint *nextMainPoint, *alphaPoint, *betaPoint;
    NSInteger countOfLineArray = [lineArray count];
    NSInteger i;
    
    alphaPoint = [currentLine mapPoint2];
    betaPoint = [currentLine mapPoint1];
    
    //NSSet *theConnectedLines = [alphaPoint getLinesAttachedToMe]; 
    
    for (i = 0; i < countOfLineArray; i++)
    {
        double previousX, previousY, thisX, thisY;
        double prevX, prevY, theX, theY;
        double slope, theXfromSlop;
        //LEMapPoint *theCurPoint1 = [theMapPointsST objectAtIndex:[thisMapLine pointIndex1]];
        //LEMapPoint *theCurPoint2 = [theMapPointsST objectAtIndex:[thisMapLine pointIndex2]];
        LEMapPoint *theCurPoint = nil;
        
        if (thisMapLine != nil)
        {
            betaPoint = alphaPoint;
            currentLine = thisMapLine;
            alphaPoint = nil;
            
            if ([currentLine mapPoint1] == betaPoint)
            {
                alphaPoint = [currentLine mapPoint2];
            }
            else if ([currentLine mapPoint2] == betaPoint)
            {
                alphaPoint = [currentLine mapPoint1];
            }
            else
            {
                SEND_ERROR_MSG_TITLE(@"Polygon Lines Not All The Way Connected: ghost point in level->whatIsDirectional method.",
                                     @"MAJOR Polygon Adding Error");
                NSLog(@"Polygon Lines Not All The Way Connected: ghost point in level->whatIsDirectional method.");
                return _poly_could_be_bad;
            }
        }

        thisMapLine = nil;
        
        numer = [lineArray objectEnumerator];
        while (tmpLine = [numer nextObject])
        {
            LEMapPoint *theCurPoint1 = [tmpLine mapPoint1];
            LEMapPoint *theCurPoint2 = [tmpLine mapPoint2];
            
            if (tmpLine == currentLine)
                continue;
            
            if (theCurPoint1 == alphaPoint)
            {
                theCurPoint = theCurPoint2;
                thisMapLine = tmpLine;
                break;
            }
            else if (theCurPoint2 == alphaPoint)
            {
                theCurPoint = theCurPoint1;
                thisMapLine = tmpLine;
                break;
            }
        }
        
        if (thisMapLine == nil || theCurPoint == nil)
        {
            SEND_ERROR_MSG_TITLE(@"Polygon Lines Not All The Way Connected: level->whatIsDirectional method",
                                 @"MAJOR Polygon Adding Error");
            NSLog(@"Polygon Lines Not All The Way Connected: level->whatIsDirectional method.");
            return _poly_could_be_bad;
        }
        
        smallestLine = nil;
        nextMainPoint = nil;
        
        if (thisMapLine == currentLine)
            return _unknown;
        
		previousX = [betaPoint x] - [alphaPoint x];
		previousY = [betaPoint y] - [alphaPoint y];
		thisX = [theCurPoint x] - [betaPoint x];
		thisY = [theCurPoint y] - [betaPoint y];
        prevX = previousX;
        prevY = previousY;
        theX = thisX;
        theY = thisY;
        
        if (previousX == 0)
        {
            if (previousY < 0 && thisX < 0)
                return _line_is_clockwise;
            else if (previousY > 0 && thisX > 0)
                return _line_is_clockwise;
            else if (previousY != 0 && thisX == 0)
                continue;
            else if (previousY != 0)
                return _line_is_counter_clockwise;
            else
            {
                SEND_ERROR_MSG_TITLE(@"X There is one point directly over another: in level->whatIsDirectional method",
                            @"Minor Polygon Adding Error");
                NSLog(@"X Two points with same cordianates with line apart of poly: in level->whatIsDirectional method... px: %g  py: %g", previousX, previousY);
                return _poly_could_be_bad;
            }
        }
        else if (previousY == 0)
        {
            if (previousX < 0 && thisY > 0)
                return _line_is_clockwise;
            if (previousX > 0 && thisY < 0)
                return _line_is_clockwise;
            if (previousX != 0 && thisY == 0)
                continue;
            else if (previousX != 0)
                return _line_is_counter_clockwise;
            else
            {
                SEND_ERROR_MSG_TITLE(@"Y There is one point directly over another: in level->whatIsDirectional method",
                            @"Minor Polygon Adding Error");
                NSLog(@"Y Two points with same cordianates with line apart of poly: in level->whatIsDirectional method... px: %g  py: %g", previousX, previousY);
                return _poly_could_be_bad;
            }
        }
        
        //NSLog(@"   IFIND previousY: %g previousX: %g", previousY, previousX);
        slope = previousY / previousX;
        //NSLog(@"   IFIND slope: %g theY: %g", slope, theY);
        theXfromSlop = theY / slope;
        //NSLog(@"   IFIND theXfromSlop: %g", theXfromSlop);
    
        //NSLog(@"   IFIND For Line %d  theX: %g theY: %g", [thisMapLine index], theX, theY);
        if (0 < prevY) // Main Point Lower
        {
            if (theX >= theXfromSlop) //ok
            {
                return _line_is_clockwise;
            }
        }
        else if (0 > prevY) // Main Point Higher
        {
            if (theX <= theXfromSlop) //ok
            {
                return _line_is_clockwise;
            }
        }
        else // equals
        {
            if (0 > prevX) // Main Point Higher
            {
                if (theY >= prevY) //ok
                {
                    return _line_is_clockwise;
                }
            }
            else if (prevX > 0) // Main Point Higher
            {
                if (theY <= prevY) //ok
                {
                    return _line_is_clockwise;
                }
            }
        }
        return _line_is_counter_clockwise;
    } // END for (i = 0; i < countOfLineArray; i++)
    return _unknown;
}

// *************************** Deleteing Objects From Level Array Methods ***************************
#pragma mark -
#pragma mark ********* Deleteing Objects From Level Array Methods *********

-(void)deleteObject:(id)objectToDelete
{
    if ([objectToDelete isKindOfClass:[LEMapPoint class]])
        [self deletePoint:objectToDelete];
        
    else if ([objectToDelete isKindOfClass:[LELine class]])
        [self deleteLine:objectToDelete];
        
    else if ([objectToDelete isKindOfClass:[LEPolygon class]])
        [self deletePolygon:objectToDelete];
        
    else if ([objectToDelete isKindOfClass:[LEMapObject class]])
        [self deleteLevelObject:objectToDelete];
    else if ([objectToDelete isKindOfClass:[PhAnnotationNote class]])
        [self deleteNote:objectToDelete];
    else
        SEND_ERROR_MSG(@"Not Implemented Yet, Sorry!");
    
    /*
    else if ([objectToDelete isKindOfClass:[PhLayer class]])
    ;
    else if ([objectToDelete isKindOfClass:[PhTag class]])
    ;
    else if ([objectToDelete isKindOfClass:[PhPlatform class]])
    ;
    else if ([objectToDelete isKindOfClass:[PhRandomSound class]])
    ;
    else if ([objectToDelete isKindOfClass:[PhAmbientSound class]])
    ;
    else if ([objectToDelete isKindOfClass:[PhMedia class]])
    ;
    else if ([objectToDelete isKindOfClass:[PhLight class]])
    ;
    else if ([objectToDelete isKindOfClass:[PhTag class]])
    ;*/
}

- (void)deleteNote:(PhAnnotationNote *)note
{
    // This should make the note check to see if it's
    // in a group and remove it's self from that group
    // if nessary...
    [note setGroup:nil];

    [layerNotes removeObjectIdenticalTo:note];
    [notes removeObjectIdenticalTo:note];
}

-(void)deleteLevelObject:(LEMapObject *)theLevelObjectToRemove
{
    int theObjType = [theLevelObjectToRemove type];
    
    //NSLog(@"Can't Delete Map Object: %d. This feature not implmented yet!", [theLevelObjectToRemove index]);
    
    if (theObjType == _saved_monster)
        [self adjustInitalItemPlacmentBy:-1 forIndex:[theLevelObjectToRemove getObjTypeIndex] isMonster:YES];
    else if (theObjType == _saved_item)
        [self adjustInitalItemPlacmentBy:-1 forIndex:[theLevelObjectToRemove getObjTypeIndex] isMonster:NO];
    
    
    [mapObjects removeObjectIdenticalTo:theLevelObjectToRemove];
    [layerMapObjects removeObjectIdenticalTo:theLevelObjectToRemove];
    
    /// Fill This Out!
}

-(void)deleteLight:(PhLight *)theLightToRemove
{
    NSEnumerator *numer;
    id thisObj;
    #ifdef showDebugDeletionsAndAddtions
    NSLog(@"Deleteing Light: %d", [theLightToRemove getIndex]);
    #endif
    numer = [sides objectEnumerator];
    while ((thisObj = [numer nextObject]))
        [thisObj setLightsThatAre:theLightToRemove to:[lights objectAtIndex:0]];
    
    numer = [media objectEnumerator];
    while ((thisObj = [numer nextObject]))
        [thisObj setLightsThatAre:theLightToRemove to:[lights objectAtIndex:0]];
    
    numer = [polys objectEnumerator];
    while ((thisObj = [numer nextObject]))
        [thisObj setLightsThatAre:theLightToRemove to:[lights objectAtIndex:0]];
        
    [lights removeObjectIdenticalTo:theLightToRemove];
    [[theLevelDocument getMapDrawView] updateNameList:_lightMenu];
}

-(void)deleteSide:(LESide *)theSideToRemove
{
    #ifdef showDebugDeletionsAndAddtions
        NSLog(@"Deleting Side #%d!", [theSideToRemove getIndex]);
    #endif
    
    [sides removeObjectIdenticalTo:theSideToRemove];
    
    // make sure you set coraspnding lines that refer to
    // this line to nil!!!
    
    /// Fill This Out!
}

-(void)deletePoint:(LEMapPoint *)thePointToRemove
{
    NSSet *theLinesToDelete;
    NSEnumerator *numer;
    id thisObj;
    #ifdef showDebugDeletionsAndAddtions
    NSLog(@"Deleteing Point: %d", [thePointToRemove getIndex]);
    #endif
    theLinesToDelete = [thePointToRemove getLinesAttachedToMe];
    
    numer = [theLinesToDelete objectEnumerator];
    
    while ((thisObj = [numer nextObject]))
        [self deleteLine:thisObj];
    
    [points removeObjectIdenticalTo:thePointToRemove];
    [layerPoints removeObjectIdenticalTo:thePointToRemove];
}

-(void)deleteLine:(LELine *)theLineToRemove
{
    LELine *theLine = theLineToRemove;
    LEPolygon *clockwisePoly = [theLine clockwisePolygonObject];
    LEPolygon *counterclockPoly = [theLine conterclockwisePolygonObject];
    
    [theLine setClockwisePolygonObject:nil];
    [theLine setConterclockwisePolygonObject:nil];
    
    [clockwisePoly removeAssociationOfObject:theLineToRemove];
    [counterclockPoly removeAssociationOfObject:theLineToRemove];
    
    //NSLog(@"*deleteing line 1");
    #ifdef showDebugDeletionsAndAddtions
    NSLog(@"Deleteing Line: %d", [theLineToRemove getIndex]);
    #endif
    if (clockwisePoly != nil)
        [self deletePolygon:clockwisePoly];
    //NSLog(@"*deleteing line 1 a");
    if ((counterclockPoly != nil) && (counterclockPoly != clockwisePoly))
        [self deletePolygon:counterclockPoly];
    
    //NSLog(@"*deleteing line 2");
    
    LESide *clockwiseSide = [theLine clockwisePolygonSideObject];
    LESide *counterclockSide = [theLine counterclockwisePolygonSideObject];
    
    //Aobve Polygon Deletions should delete the sides, but just in case...
    if (clockwiseSide != nil)
    {
        //NSLog(@"*deleteing line 2 a");
        //[sides removeObjectIdenticalTo:clockwiseSide];
        //NSLog(@"*deleteing line 2 b");
        [theLine setClockwisePolygonSideObject:nil];
        //NSLog(@"*deleteing line 2 c");
        
        [clockwiseSide setPolygon_object:nil];
        [clockwiseSide setLine_object:nil];
    }
    //NSLog(@"*deleteing line 3");
    if ((counterclockSide != nil) && (counterclockSide != clockwiseSide))
    {
        //[sides removeObjectIdenticalTo:counterclockSide];
        [theLine setCounterclockwisePolygonSideObject:nil]; 
        
        [counterclockSide setPolygon_object:nil];
        [counterclockSide setLine_object:nil];
    }
    //NSLog(@"*deleteing line 4");
    
    NSEnumerator *numer = nil;
    id thisObj = nil;
        
    numer = [sides objectEnumerator];
    while (thisObj = [numer nextObject])
    {
        if ([thisObj getline_object] == theLineToRemove)
        {
            [thisObj setLine_object:nil];
            [thisObj setPolygon_object:nil];
            [self deleteSide:thisObj];
        }
    }
    
    [theLineToRemove setMapPoint1:nil];
    [theLineToRemove setMapPoint2:nil];
    [theLineToRemove setMapPoint1:nil mapPoint2:nil];
    [lines removeObjectIdenticalTo:theLineToRemove];
    [layerLines removeObjectIdenticalTo:theLineToRemove];
}

-(void)deletePolygon:(LEPolygon *)thePolyToRemove
{
    int i;
    int vc = [thePolyToRemove getTheVertexCount];
    NSEnumerator *numer = nil;
    id thisObj = nil;
    ///id tmpObj = nil;
    
    // ********* ¡ALERT!: Make sure to delete poly platform if it has one!!! :!ALERT¡ *********
    #ifdef showDebugDeletionsAndAddtions
    NSLog(@"Deleteing Polygon: %d", [thePolyToRemove getIndex]);
    #endif
    // *** *** ***
    
    if ([thePolyToRemove type] == _polygon_is_platform)
    {
        PhPlatform *thePlatform = [thePolyToRemove permutationObject];
        
        if ([thePlatform isKindOfClass:[PhPlatform class]])
        {
            [thePolyToRemove setPermutationObject:nil];
            [thePlatform setPolygonObject:nil];
            [self deletePlatform:thePlatform];
        }
        else
        {
            // *** *** *** NOTE *** *** ***
            // Not sure what else to do...
            // This is a mjor error, but since the polygon is going to
            //   be deleted, there should be no more problems (hopefully)...
            //   May want to do addtional checks to be sure everything is ok!
            [thePolyToRemove setPermutationObject:nil];
        }
    }
    // *** *** ***
    
    // Polygon should check to see if it is an NSNumber
    // 	and release it if it is...
    [thePolyToRemove setPermutationObject:nil];
    
    for(i = 0; i < vc; i++)
    {
        LELine *theLine = [thePolyToRemove lineObjectAtIndex:i];
        LEPolygon *clockwisePoly = [theLine clockwisePolygonObject];
        LEPolygon *counterclockPoly = [theLine conterclockwisePolygonObject];
        LESide *clockwiseSide = [theLine clockwisePolygonSideObject];
        LESide *counterclockSide = [theLine counterclockwisePolygonSideObject];
        
        if (clockwisePoly == thePolyToRemove)
        {
            [theLine setClockwisePolygonObject:nil];
            [theLine setClockwisePolygonSideObject:nil];
            [self deleteSide:clockwiseSide];
        }
        else
        {
            [clockwisePoly removeAssociationOfObject:thePolyToRemove];
        }
        
        if (counterclockPoly == thePolyToRemove)
        {
            [theLine setConterclockwisePolygonObject:nil];
            [theLine setCounterclockwisePolygonSideObject:nil];
            [self deleteSide:counterclockSide];
        }
        else
        {
            [counterclockPoly removeAssociationOfObject:thePolyToRemove];
        }
        
        
        // caculateSides should set flags appropiatly,
        // and it should also acknowlege any special
        // flags that tell the line not to autoset...
        [theLine caculateSides];
        //[theLine setFlags:0];
        //[theLine setFlag:LELineSolid to:YES];
    }
    
    /*
    [thePolyToRemove retain];
    
    [polys removeObjectIdenticalTo:thePolyToRemove];
    [thePolyToRemove setPolyLayer:nil];
    [layerPolys removeObjectIdenticalTo:thePolyToRemove];
    */
    
    numer = [mapObjects objectEnumerator];
    while (thisObj = [numer nextObject])
    {
        if ([thisObj polygonObject] == thePolyToRemove)
        {
            [thisObj setPolygonObject:nil];
            [self deleteLevelObject:thisObj];
        }
    }
    
    numer = [notes objectEnumerator];
    while (thisObj = [numer nextObject])
    {
        if ([thisObj polygonObject] == thePolyToRemove)
        {
            [thisObj setPolygon_object:nil];
        }
    }
    
    numer = [platforms objectEnumerator];
    while (thisObj = [numer nextObject])
    {
        if ([thisObj polygonObject] == thePolyToRemove)
        {
            [thisObj setPolygon_object:nil];
            [self deletePlatform:thisObj];
        }
    }
    
    numer = [sides objectEnumerator];
    while (thisObj = [numer nextObject])
    {
        if ([thisObj getpolygon_object] == thePolyToRemove)
        {
            LELine *theLine = [thisObj getline_object];
            
            if (theLine != nil)
            {
                LESide *clockwiseSide = [theLine clockwisePolygonSideObject];
                LESide *counterclockSide = [theLine counterclockwisePolygonSideObject];
                
                if (clockwiseSide == thisObj)
                {
                    [theLine setClockwisePolygonSideObject:nil];
                }
                else if (counterclockSide == thisObj)
                {
                    [theLine setCounterclockwisePolygonSideObject:nil];
                }
            }
            
            [thisObj setLine_object:nil];
            [thisObj setPolygon_object:nil];
            [self deleteSide:thisObj];
        }
    }
    
    // Make Sure Name Is Removed...
    [self removeNameOfPolygon:thePolyToRemove];
    
    
    [polys removeObjectIdenticalTo:thePolyToRemove];
    [thePolyToRemove setPolyLayer:nil];
    [layerPolys removeObjectIdenticalTo:thePolyToRemove];
}

-(void)deletePlatform:(PhPlatform *)thePlatformToRemove
{
    #ifdef showDebugDeletionsAndAddtions
    NSLog(@"Deleteing Platfrom: %d", [thePlatformToRemove getIndex]);
    #endif
    
    LEPolygon *poly = [thePlatformToRemove polygonObject];
    
    if ([poly type] == _polygon_is_platform)
    {
        PhPlatform *thePlatform = [poly permutationObject];
        
        if (thePlatformToRemove == thePlatform)
        {
            [poly setPermutationObject:nil];
            [poly setType:_polygon_is_normal];
        }
        else
        { // Platform to remove not the same as whats attached to the polygon...
            NSLog(@"PROBLEM: Platform to remove not the same as whats attached to the polygon in -(void)deletePlatform:(PhPlatform *)thePlatformToRemove...");
            
            // Go Though Polygons In Search Of Platfrom...
            NSEnumerator *numer = [polys objectEnumerator];
            LEPolygon *thisPoly = nil;
            while (thisPoly = [numer nextObject])
            {
                if (thePlatformToRemove == [thisPoly permutationObject])
                {
                    // Same Object!!!
                    [thisPoly setPermutationObject:nil];
                    [thisPoly setType:_polygon_is_normal];
                }
            }
        }
    }
    
    [thePlatformToRemove setPolygonObject:nil];
    [platforms removeObjectIdenticalTo:thePlatformToRemove];
}

- (void)deleteNoteType:(PhNoteGroup *)noteT
{
    // Go though an make sure that the notes no longer
    // refer to the noteGroups/noteTypes...
    [noteTypes removeObjectIdenticalTo:noteT];
}

@end
