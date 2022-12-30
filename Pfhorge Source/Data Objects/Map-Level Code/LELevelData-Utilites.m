//
//  LELevelData-Utilites.m
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

@interface LELevelData (other)
-(void)setTheNoteTypesST:(NSArray *)theNSArray;
@end

@implementation LELevelData (LevelDataUtilites)

#pragma mark -

- (void)havePointsScanForLines
{
    NSEnumerator *numer = [points objectEnumerator];
    LEMapPoint *thisObj;
    while (thisObj = [numer nextObject])
    {
        [thisObj scanAndUpdateLines];
    }
}

- (void)recompileTerminalNamesCache
{
    NSEnumerator *numer;
    id theObj;
    
    [terminalNames removeAllObjects];
    
    numer = [terimals objectEnumerator];
    while (theObj = [numer nextObject])
        [terminalNames addObject:[theObj phName]];
    
    [self refreshMenusOfMenuType:PhLevelNameMenuTerminal];
}

- (void)adjustInitalItemPlacmentBy:(int)adjustmentNumber forIndex:(int)objectIndex isMonster:(BOOL)adjustingMonster
{
    if (objectIndex < 0 || objectIndex >= 64)
        return;
    
    if (adjustingMonster)
        [[itemPlacement objectAtIndex:(objectIndex + 64)] adjustTheInitalCountBy:adjustmentNumber];
    else
        [[itemPlacement objectAtIndex:objectIndex] adjustTheInitalCountBy:adjustmentNumber];
}



// ************************* Other Methods *************************
#pragma mark -
#pragma mark ********* Other Methods *********

- (void)unionLevel:(LELevelData *)theLevelToImport
{
    //NSLog(@"\n\n*** Union Level... ***\nPCount:%d\n", [[theLevelToImport getThePolys] count]);
    
    if (theLevelToImport == nil)
    {
        NSLog(@"In Union Level, theLevelToImport == nil");
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Problem Importing";
        alert.informativeText = @"Problem importing a level, the level to import was nil?";
        alert.alertStyle = NSAlertStyleCritical;
        [alert runModal];
        return;
    }
    
    [points addObjectsFromArray:[theLevelToImport points]];
    [lines addObjectsFromArray:[theLevelToImport lines]];
    [polys addObjectsFromArray:[theLevelToImport polygons]];
    [mapObjects addObjectsFromArray:[theLevelToImport theMapObjects]];
    [lights addObjectsFromArray:[theLevelToImport lights]];
    [sides addObjectsFromArray:[theLevelToImport sides]];
    [notes addObjectsFromArray:[theLevelToImport notes]];
    [media addObjectsFromArray:[theLevelToImport media]];
    [ambientSounds addObjectsFromArray:[theLevelToImport ambientSounds]];
    [randomSounds addObjectsFromArray:[theLevelToImport randomSounds]];
    
    // *** NOTE: Should a replace them? There are only
    //		   suposed to be 128 as far as I know...
    //[itemPlacement addObjectsFromArray:[theLevelToImport points]];
    
    [platforms addObjectsFromArray:[theLevelToImport platforms]];
    
    [layersInLevel addObjectsFromArray:[theLevelToImport layersInLevel]];
    [tags addObjectsFromArray:[theLevelToImport tags]];
    [terimals addObjectsFromArray:[theLevelToImport terminals]];
    
    [self setUpArrayNamesForEveryObject];
    [self setUpArrayPointersForEveryObject];
    [self recompileTerminalNamesCache];
    [self refreshEveryMenu];
    
    [self refreshMenusOfMenuType:PhLevelNameMenuLayer];
    
    NSLog(@"layerNames: %@", [layerNames description]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNamesNotification object:nil];
    [[theLevelDocument getMapDrawView] updateNameList:PhLevelNameMenuLayer];
    [self recaculateTheCurrentLayer];
    
    [theLevelDocument tellDocWinControllerToUpdateLevelInfoString];
}

- (NSInteger)tagIndexNumberFromTagNumber:(short)tagNumber
{
    //NSArray *theLevelTags = [self tags]; //phNumber
    NSEnumerator *numer;
    NSNumber *currentTagNumber = [NSNumber numberWithShort:tagNumber];
    PhTag *theNewTag = nil;
    NSInteger theTagNumber = 0;
    
    ///NSLog(@"tagIndexNumberFromTagNumber called tagNumber Geting: %d", tagNumber);
    
    numer = [tags objectEnumerator];
    for (__kindof LEMapStuffParent *thisObj in numer)
    {
        if ([[thisObj phNumber] isEqualToNumber:currentTagNumber])
        {
            ///NSLog(@"Returning Tag Index: %d  tagsCount: %d currentTagNumber: %d TagNumber Returning: %d", [thisObj index], [tags count], [currentTagNumber intValue], [[thisObj phNumber] intValue]);
            return [thisObj index];
        }
    }
    
    // If there is no exsisting tag with the given number (tagNumber)
    //	then create a new tag with that number...
    
    theNewTag = [[PhTag alloc] initWithTagNumber:[NSNumber numberWithInt:tagNumber]];
    
    
    // *** Change addNewTagWithNumber to sort and use that instead in the future!!! ***
    
    
    [tags addObject:theNewTag];
    [tags sortUsingSelector:@selector(compare:)];
    theTagNumber = [tags indexOfObjectIdenticalTo:theNewTag];
    [tagNames insertObject:[theNewTag phName] atIndex:theTagNumber];
    
    [self setUpArrayPointersFor:theNewTag];
    
    ///NSLog(@"newTag: %d", [[theNewTag phNumber] intValue]);
    
    
    [self refreshEveryMenu];
    
    return theTagNumber;
}

-(Terminal *)getTerminalThatContains:(TerminalSection *)theTermSection
{
    NSEnumerator *numer = [terimals objectEnumerator];
    id thisObj = nil;
    
    if (theTermSection == nil)
        return nil;
    
    while (thisObj = [numer nextObject])
    {
        if ([thisObj doYouHaveThisSection:theTermSection])
            return thisObj;
    }
    return nil;
}

-(void)setToDefaultState:(id)theObject
{
    /*for (i = 0; i < _NUMBER_OF_OBJECT_TYPES; i++)
    {
        defaultObjects[i] = [[LEMapObject alloc] init];
        [defaultObjects[i] setType:i];
    }
    
    defaultPolygon = [[LEPolygon alloc] init];
    defaultSide = [[LESide alloc] init];*/

    Class theClass = [theObject class];
    
    // MAKE THIS INTO A SWITCH!!!
    
    if (theClass == [LEMapPoint class])
    {
	//[self addPoint:
    }
    else if (theClass == [LELine class])
    {
        if ([theObject clockwisePolygonSideObject] != nil)
            [cDefaultSide copySettingsTo:[theObject clockwisePolygonSideObject]];
        if ([theObject counterclockwisePolygonSideObject] != nil)
            [ccDefaultSide copySettingsTo:[theObject counterclockwisePolygonSideObject]];
    }
    else if (theClass == [LESide class])
    {
       [defaultSide copySettingsTo:theObject]; 
    }
    else if (theClass == [LEPolygon class])
    {
        id theObj;
        [defaultPolygon copySettingsTo:theObject];
        theObj = [theObject permutationObject];
        if ([theObj class] == [PhPlatform class])
            [self addPlatform:theObj];
    }
    else if (theClass == [LEMapObject class])
    {
        int theObjType = [(LEMapObject*)theObject type];
        if (theObjType >= 0 && theObjType < _NUMBER_OF_OBJECT_TYPES)
        {
            [defaultObjects[theObjType] copySettingsTo:theObject];
            //NSLog(@"Copyed default object With Type %d to object...", theObjType);
        }
        else
            /*NSLog(@"Object With Type %d has unknown type...", theObjType)*/;
        
    }
}

-(void)makeDefault:(id)theObject
{
    Class theClass = [theObject class];
     
    if (theClass == [LEMapPoint class])
    {
		// no default settings for points yet...
    }
    else if (theClass == [LELine class])
    {
        if ([theObject clockwisePolygonSideObject] == nil)
            ccHasDefaultSide = NO;
        else
        {
            [[theObject counterclockwisePolygonSideObject] copySettingsTo:ccDefaultSide];
            ccHasDefaultSide = YES;
            [ccDefaultSide copySettingsTo:defaultSide];
        }
        
        if ([theObject clockwisePolygonSideObject] == nil)
            cHasDefaultSide = NO;
        else
        {
            [[theObject clockwisePolygonSideObject] copySettingsTo:cDefaultSide];
            cHasDefaultSide = YES;
            [cDefaultSide copySettingsTo:defaultSide];
        }
    }
    else if (theClass == [LESide class])
    {
       [theObject copySettingsTo:defaultSide]; 
    }
    else if (theClass == [LEPolygon class])
    {
        [theObject copySettingsTo:defaultPolygon];
    }
    else if (theClass == [LEMapObject class])
    {
        int theObjType = [(LEMapObject*)theObject type];
        if (theObjType >= 0 && theObjType < _NUMBER_OF_OBJECT_TYPES)
        {
            [theObject copySettingsTo:defaultObjects[theObjType]];
            //NSLog(@"Made object With Type %d default object...", theObjType);
        }
        else
            NSLog(@"Object With Type %d has unknown type, can't make it a default object...", theObjType);
        
        /*
        switch ([theObject type])
        {
            case _saved_monster:
                [theObject copySettingsTo:defaultObjects[[theObject type]]];
                break;
            case _saved_object:
                
                break;
            case _saved_item:
                
                break;
            case _saved_player:
                
                break;
            case _saved_goal:
                
                break;
            case _saved_sound_source:
                
                break;
        }
        */
    }
    
}

-(void)addSidesForLine:(LELine *)theLine
{
    [theLine caculateSides];
    
    // Used to be some addtional code here...
    // It is now the responsibility of the
    // caculateSides method/function to
    // do this correctly...
}

-(void)removeSidesFromLine:(LELine *)theLine
{   // Should let caculate sides do this,
    // but it may be usfull to get rid of the sides
    // no matter what...
    //
    // Update:  Yes it is, because caculateSides method
    //          in LELine may call this function if
    //          noSides for that line is permently set...
    
    LEPolygon *clockPoly = [theLine clockwisePolygonObject];
    LEPolygon *counterclockPoly = [theLine conterclockwisePolygonObject];
    LESide *clockSide = [theLine clockwisePolygonSideObject];
    LESide *counterclockSide = [theLine counterclockwisePolygonSideObject];
    NSLog(@"removeSidesFromLine 1 [LELevelData-Utilites->removeSidesFromLine]");
    if (clockSide != nil)
    {
        int polyLineNumber = [clockPoly getLineNumberFor:theLine];
        
        NSParameterAssert(polyLineNumber != -1);
        
        [clockSide setPolygonObject:nil];
        [clockSide setLineObject:nil];
        
        [theLine setClockwisePolygonSideObject:nil];
        [clockPoly setSidesObject:nil toIndex:polyLineNumber];
        //NSLog(@"removeSidesFromLine 1a");
        [self deleteSide:clockSide];
    }
    //NSLog(@"removeSidesFromLine 2");
    if (counterclockSide != nil)
    {
        int polyLineNumber = [counterclockPoly getLineNumberFor:theLine];
        
        NSParameterAssert(polyLineNumber != -1);
        
        [counterclockSide setPolygonObject:nil];
        [counterclockSide setLineObject:nil];
        
        [theLine setCounterclockwisePolygonSideObject:nil];
        [counterclockPoly setSidesObject:nil toIndex:polyLineNumber];
        //NSLog(@"removeSidesFromLine 2a");
        [self deleteSide:counterclockSide];
    }
    //NSLog(@"removeSidesFromLine 3");
}

-(void)checkNameForObject:(id)obj
{
    if ([obj isKindOfClass:[PhAbstractName class]] == YES)
    {
        
    }
    else
    {
        NSLog(@"Could not check name on an object because it does not inherit from PhAbstractName...");
    }
}

-(void)setNameForObject:(__kindof LEMapStuffParent*)theObject toString:(NSString *)theName
{
    LEMapDraw *theDrawView = [theLevelDocument getMapDrawView];
    
    // NOTE:  This assumes that most of these objects already have some
    //  	kind of name (which they should).
    //	Should modify this so that it checks first and makes sure they have a name
    //   just in case!!!
    
    //NSLog(@"***************** PROBLEM WITH NAMING METHOD USED ********************")
    
    //return;
    
    if ([theObject isKindOfClass:[LEPolygon class]])
    {
        if (theName != nil)
            [self namePolygon:theObject to:theName];
        else
            [self removeNameOfPolygon:theObject];
        
        return;
    }
    
    [theObject setPhName:theName]; 
    
    [self checkNameForObject:theObject];
    
    if ([theObject isKindOfClass:[PhLayer class]])
    {
        [layerNames replaceObjectAtIndex:[theObject index]
                             withObject:[theName copy]];
        [self refreshMenusOfMenuType:PhLevelNameMenuLayer];
        [theDrawView updateNameList:PhLevelNameMenuLayer];
    }
    else if ([theObject isKindOfClass:[PhTag class]])
    {
        [tagNames replaceObjectAtIndex:[theObject index]
                             withObject:[theName copy]];
        [self refreshMenusOfMenuType:PhLevelNameMenuTag];
        [theDrawView updateNameList:PhLevelNameMenuTag];
    }
    else if ([theObject isKindOfClass:[PhPlatform class]])
    {
        [platformNames replaceObjectAtIndex:[theObject index]
                             withObject:[theName copy]];
        [self refreshMenusOfMenuType:PhLevelNameMenuPlatform];
        [theDrawView updateNameList:PhLevelNameMenuPlatform];
    }
    else if ([theObject isKindOfClass:[PhRandomSound class]])
    {
        [randomSoundNames replaceObjectAtIndex:[theObject index]
                             withObject:[theName copy]];
        [self refreshMenusOfMenuType:PhLevelNameMenuRandomSound];
        [theDrawView updateNameList:PhLevelNameMenuRandomSound];
    }
    else if ([theObject isKindOfClass:[PhAmbientSound class]])
    {
        [ambientSoundNames replaceObjectAtIndex:[theObject index]
                             withObject:[theName copy]];
        [self refreshMenusOfMenuType:PhLevelNameMenuAmbientSound];
        [theDrawView updateNameList:PhLevelNameMenuAmbientSound];
    }
    else if ([theObject isKindOfClass:[PhMedia class]])
    {
        [liquidNames replaceObjectAtIndex:[theObject index]
                             withObject:[theName copy]];
        [self refreshMenusOfMenuType:PhLevelNameMenuLiquid];
        [theDrawView updateNameList:PhLevelNameMenuLiquid];
    }
    else if ([theObject isKindOfClass:[PhLight class]])
    {
        [lightNames replaceObjectAtIndex:[theObject index]
                             withObject:[theName copy]];
        [self refreshMenusOfMenuType:PhLevelNameMenuLight];
        [theDrawView updateNameList:PhLevelNameMenuLight];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNamesNotification object:nil];
}


-(void)namePolygon:(LEPolygon *)thePoly to:(NSString *)theName
{
    [thePoly setPhName:theName];
    
    if (thePoly == nil)
    {
        NSLog(@"*** ERROR: thePoly was nil in namePolygon:to: in LELevelData-Utilities.m");
        return;
    }
    
    if (theName == nil)
    {
        NSLog(@"*** ERROR: theName was nil in namePolygon:to: in LELevelData-Utilities.m");
        return;
    }
    
    if ([namedPolyObjects containsObject:thePoly])
    {
        [polyNames replaceObjectAtIndex:[namedPolyObjects indexOfObjectIdenticalTo:thePoly]
                             withObject:[theName copy]];
    }
    else
    {
    
        [namedPolyObjects addObject:thePoly];
        [polyNames addObject:[theName copy]];
    }
    
    [self refreshMenusOfMenuType:PhLevelNameMenuPolygon];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangeNamesNotification object:nil];
}

-(void)removeNameOfPolygon:(LEPolygon *)thePoly
{
    NSInteger theNamedPolyOrginalIndex = [namedPolyObjects indexOfObjectIdenticalTo:thePoly];
    
    if (theNamedPolyOrginalIndex < 0 || theNamedPolyOrginalIndex == NSNotFound)
    {
        [thePoly setPhName:nil];
        [self refreshMenusOfMenuType:PhLevelNameMenuPolygon];
        return;
    }
    
    [namedPolyObjects removeObject:thePoly];
    [thePoly setPhName:nil];
    [polyNames removeObjectAtIndex:theNamedPolyOrginalIndex];
    [self refreshMenusOfMenuType:PhLevelNameMenuPolygon];
}



 // **************************  Useful Public Utilites  *************************
 #pragma mark -
#pragma mark ********* Useful Public Utilites *********


-(void)removeObjectsNotInMainArrays
{
    NSEnumerator *numer;
    LEPolygon *thisPoly;
    LESide *thisSide;
    
    NSLog(@"running -(void)removeObjectsNotInMainArrays...");
    
    numer = [sides objectEnumerator];
    while (thisSide = [numer nextObject])
    {
        //controlPanelType
        
        if ([thisSide flags] & LESideIsControlPanel)
        {
            NSLog(@"Control Panel Flags: %d   -   Line Index: %d", [thisSide flags], [thisSide lineIndex]);
        }
        
        if ([thisSide permutationEffects] == _cpanel_effects_polygon)
        {
            if ([thisSide controlPanelPermutationObject] == nil)
            {
                if ([thisSide flags] & LESideIsControlPanel)
                {
                    NSLog(@"There is a side with control panel effect 'polygon' and its a nil permuation object... CONTROL PANEL FLAG...");
                }
                else
                {
                    NSLog(@"There is a side with control panel effect 'polygon' and its a nil permuation object...");
                }
                
            }
        }
    }
    
    
    numer = [polys objectEnumerator];
    while (thisPoly = [numer nextObject])
    {
        short	theVertexCount = [thisPoly getTheVertexCount];
        int	i;
        BOOL getRidOfPolygon = NO;
        //short *theVertexes = [theObj getTheVertexes];
        
        
        if ([thisPoly type] == _polygon_is_platform)
        {
            if ([thisPoly permutationObject] == nil)
            {
                NSLog(@"There is a polygon type of reg platform with a nil permuation object...");
            }
        }
        else if ([thisPoly type] == _polygon_is_platform_on_trigger)
        {
            if ([thisPoly permutationObject] == nil)
            {
                NSLog(@"There is a polygon type of on platform with a nil permuation object...");
            }
        }
        else if ([thisPoly type] == _polygon_is_platform_off_trigger)
        {
            if ([thisPoly permutationObject] == nil)
            {
                NSLog(@"There is a polygon type of off platform with a nil permuation object...");
            }
        }
        
        for (i = 0; i < theVertexCount; i++)
        {
            id theVertex = [thisPoly vertexObjectAtIndex:i];
            id theLine = [thisPoly lineObjectAtIndex:i];
            
            //NSLog(@"Polygon# %d  ---  Line# %d", [theObj index], [theLine index]);
            
            //points, *lines
            
            if ([lines indexOfObjectIdenticalTo:theLine] == NSNotFound)
            {
                NSLog(@"In Polygon# %d - pLine# %d - did not exsist in main array...", [thisPoly index], i);
                [thisPoly setLinesObject:nil toIndex:i];
                getRidOfPolygon = YES;
            }
            
            if ([points indexOfObjectIdenticalTo:theVertex] == NSNotFound)
            {
                NSLog(@"In Polygon# %d - vertex# %d - did not exsist in main array...", [thisPoly index], i);
                [thisPoly setVertexWithObject:nil toIndex:i];
                getRidOfPolygon = YES;
            }
        }
        
        if (getRidOfPolygon == YES)
        {
            NSLog(@"Deleting Polygon# %d due to major fundamental problem...", [thisPoly index]);
            [self deletePolygon:thisPoly];
        }
    }
}

-(void)resetAdjacentPolygonAssociations
{
    NSEnumerator *numer;
    LEPolygon *thisPoly;
    
    numer = [polys objectEnumerator];
    while ((thisPoly = [numer nextObject]))
    {
        [thisPoly setAllAdjacentPolygonPointersToNil];
    }
}


// Belongs In *** Other Methods *** Section
-(void)findObjectsAssociatedWith:(id)theObj putIn:(NSMutableSet *)theObjects
{
    NSEnumerator *numer;
    id thisObj;
    NSMutableSet *tmpList1 = [[NSMutableSet alloc] initWithCapacity:1];
    
    if ([theObj isKindOfClass:[LEMapPoint class]])
    {
        //NSMutableArray *points, *lines, *polys;
        
        numer = [layerLines objectEnumerator];
        while ((thisObj = [numer nextObject]))
            if ([thisObj uses:theObj]) [tmpList1 addObject:thisObj];
        
        numer = [tmpList1 objectEnumerator];
        while ((thisObj = [numer nextObject]))
        {
            LEPolygon *poly1 = [thisObj clockwisePolygonObject];
            LEPolygon *poly2 = [thisObj conterclockwisePolygonObject];
            //NSLog(@"BEFORE: Polygon Set LevelData Function Count: %d", [theObjects count]);
            //NSLog(@"poly1 index: %d   poly2 index: %d", [poly1 index], [poly2 index]);
            if ((poly1 != nil) && (![theObjects containsObject:poly1]))
                [theObjects addObject:poly1];
            if ((poly2 != nil) && (![theObjects containsObject:poly2]))
                [theObjects addObject:poly2];
            //NSLog(@"AFTER: Polygon Set LevelData Function Count: %d", [theObjects count]);
        }
        
        [theObjects unionSet:tmpList1];
        return;
    }
    else if ([theObj isKindOfClass:[LELine class]])
    {
        //NSMutableArray *points, *lines, *polys;
        //LEPolygon *poly1 = [theObj clockwisePolygonObject];
        //LEPolygon *poly2 = [theObj conterclockwisePolygonObject];
        LEMapPoint *point1 = [theObj mapPoint1];
        LEMapPoint *point2 = [theObj mapPoint2];
        
        [theObjects addObject:point1];
        [theObjects addObject:point2];
        
        numer = [layerLines objectEnumerator];
        while ((thisObj = [numer nextObject]))
        {
            if ([thisObj uses:point1]) [tmpList1 addObject:thisObj];
            if ([thisObj uses:point2]) [tmpList1 addObject:thisObj];
        }
           
        numer = [tmpList1 objectEnumerator];
        while ((thisObj = [numer nextObject]))
        {
            LEPolygon *poly1 = [thisObj clockwisePolygonObject];
            LEPolygon *poly2 = [thisObj conterclockwisePolygonObject];
            
            if (poly1 != nil)
                [theObjects addObject:poly1];
            if (poly2 != nil)
                [theObjects addObject:poly2];
        }
        
        [theObjects unionSet:tmpList1];
        return;
    }
    else if ([theObj isKindOfClass:[LEPolygon class]])
    {
        int i;
        // getLineObjects
        
        for(i = 0; i < [theObj getTheVertexCount]; i++)
            [tmpList1 addObject:[theObj lineObjectAtIndex:i]];
        
        LEMapPoint *maraPoint = nil;
        
        for(i = 0; i < [theObj getTheVertexCount]; i++)
        {
            maraPoint = [theObj vertexObjectAtIndex:i];
            [theObjects addObject:maraPoint];
            [theObjects unionSet:[maraPoint getLinesAttachedToMe]];
        }
        
        numer = [tmpList1 objectEnumerator];
        while ((thisObj = [numer nextObject]))
        {
            LEPolygon *poly1 = [thisObj clockwisePolygonObject];
            LEPolygon *poly2 = [thisObj conterclockwisePolygonObject];
            
            if (poly1 != nil && poly1 != theObj)
                [theObjects addObject:poly1];
            if (poly2 != nil && poly2 != theObj)
                [theObjects addObject:poly2];
        }
        
        [theObjects unionSet:tmpList1];
        return;
    }
    else if ([theObj isKindOfClass:[LEMapObject class]])
    {
        return;
    }
    else if ([theObj isKindOfClass:[TerminalSection class]])      
    {
       /* numer = [terimals objectEnumerator];
        while (thisObj = [numer nextObject])
        {
            if ([thisObj doYouHaveThisSection:theObj])
                return thisObj;
        }*/
        
        return;
    }
}

// Belongs In *** Other Methods *** Section
-(void)setUpArrayPointersFor:(LEMapStuffParent *)theObject;
{
    [theObject setTheNoteTypesST:noteTypes];
    [theObject setTheMapLinesST:lines];
    [theObject setTheMapObjectsST:mapObjects];
    [theObject setTheMapPointsST:points];
    [theObject setTheMapPolysST:polys];
    [theObject setTheMapLightsST:lights];
    [theObject setTheMapSidesST:sides];
    [theObject setTheAnnotationsST:notes];
    [theObject setTheMediaST:media];
    [theObject setTheAmbientSoundsST:ambientSounds];
    [theObject setTheRandomSoundsST:randomSounds];
    [theObject setTheMapItemPlacmentST:itemPlacement];
    [theObject setTheMapPlatformsST:platforms];
    [theObject setTheMapLayersST:layersInLevel];
    [theObject setTheLevelTagObjectsST:tags];
    [theObject setTheLELevelDataST:self];
    [theObject setMyUndoManager:myUndoManager];
    
    [theObject setTheTerminalsST:terimals];
    
    [theObject setEverythingLoadedST:YES];
}

-(void)setUpArrayPointersForEveryObject
{
    NSEnumerator *numer;
    id theObj;
    
    numer = [noteTypes objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [lines objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [mapObjects objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [points objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [polys objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [lights objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [sides objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [notes objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [media objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [ambientSounds objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [randomSounds objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [itemPlacement objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [platforms objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [layersInLevel objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
    
    numer = [tags objectEnumerator];
    while (theObj = [numer nextObject])
        [self setUpArrayPointersFor:theObj];
}


@end
