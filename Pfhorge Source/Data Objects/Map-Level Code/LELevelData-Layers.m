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

@implementation LELevelData (LevelLayers)
// ************************* Layer Data Agirithms *************************
#pragma mark -
#pragma mark ********* Layer Data Agirithms *********

-(void)setupLayersForNewPIDLevel
{
    NSLog(@"*** Setup Pathways Into Darkness Layers ***");
    
    [layersInLevel removeAllObjects];
    PhLayer *theNewLayer = [[PhLayer alloc] initWithName:@"PID Level Layer"];
    [layersInLevel addObject:theNewLayer];
    [self setUpArrayPointersFor:theNewLayer];
    [self setLayerModeTo:theNewLayer];
}

-(void)setupLayers
{
    NSMutableArray *records = [[NSMutableArray alloc] init];
    NSEnumerator *numer1;
    NSEnumerator *numer2;
    //NSEnumerator *numer3;
    id	theObj2;
    //id  theObj3;
    
    NSLog(@"*** Setting Up Regular Layers... ***");
    
    [layersInLevel removeAllObjects];
    
    [records addObjectsFromArray:[preferences arrayForKey:PhDefaultLayers]];
    
    // Make The Layers...
    numer1 = [records objectEnumerator];
    for (id theObj1 in numer1)
    {
        PhLayer *theNewLayer = [[PhLayer alloc] initWithName:[theObj1 objectForKey:PhDefaultLayer_Name]];
        [layersInLevel addObject:theNewLayer];
        [self setUpArrayPointersFor:theNewLayer];
    }
    
    if ([layersInLevel count] == 1)
    {
        PhLayer *theOnlyLayer = [layersInLevel objectAtIndex:0];
        for (LEPolygon *theObj1 in polys)
        {
            [theObj1 setPolyLayer:theOnlyLayer];
        }
    }
    else
    {
        // polys
        for (LEPolygon *theObj1 in polys)
        {
            int floorHeight = [theObj1 floorHeight];
            int ceilingHeight = [theObj1 ceilingHeight];
            int layerNumber = 0;
            
            numer2 = [records objectEnumerator];
            //numer3 = [layersInLevel objectEnumerator];
            while (theObj2 = [numer2 nextObject] /*|| theObj3 = [numer3 nextObject]*/)
            {
                int minFloor = [unarchivedOfClass([theObj2 objectForKey:PhDefaultLayer_FloorMin], [NSNumber class]) intValue];
                int maxFloor = [unarchivedOfClass([theObj2 objectForKey:PhDefaultLayer_FloorMax], [NSNumber class]) intValue];
                int maxCeiling = [unarchivedOfClass([theObj2 objectForKey:PhDefaultLayer_CeilingMax], [NSNumber class]) intValue];
                int minCeiling = [unarchivedOfClass([theObj2 objectForKey:PhDefaultLayer_CeilingMin], [NSNumber class]) intValue];
                
                if (((floorHeight >= minFloor) && (floorHeight <= maxFloor)) &&
                    ((ceilingHeight >= minCeiling) && (ceilingHeight <= maxCeiling)))
                {
                    [theObj1 setPolyLayer:[layersInLevel objectAtIndex:layerNumber]];
                    break;
                } // END checking floor and ceiling height
                
                layerNumber++;
                
            } // END while (theObj2 = [numer2 nextObject] /*|| theObj3 = [numer3 nextObject]*/)
        } // END while (theObj1 = [numer1 nextObject])
    }
    
    [self setLayerModeTo:[layersInLevel lastObject]];
}// END -(void)setupLayers

-(int)getLayerModeIndex // zero is no layer
{
    if (/*indexOfObject*/ nil == currentLayer)
        return 0;
    else
        return (int)([layersInLevel indexOfObjectIdenticalTo:currentLayer] + 1);
}

-(void)recaculateTheCurrentLayer
{
    PhLayer *tempLayerCache = currentLayer;
    //[self setLayerModeTo:nil];
    currentLayer = nil;
    [self setLayerModeTo:tempLayerCache];
}

-(void)setLayerModeToIndex:(int)layerIndexNumber // zero is no layer
{
    if (layerIndexNumber > 0)
        [self setLayerModeTo:[layersInLevel objectAtIndex:(layerIndexNumber - 1)]];
    else if (layerIndexNumber == 0)
        [self setLayerModeTo:nil];
    else {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Generic Error";
        alert.informativeText = @"Pfhorge atempted to set the layer index mode lower then zero, ERROR! Layer will not be changed, sorry, please try reloading the level then changing it after that.";
        alert.alertStyle = NSAlertStyleCritical;
        [alert runModal];
    }
}

-(void)setCurrentLayerToLastLayer
{
    [self setLayerModeTo:[layersInLevel lastObject]];
}

-(void)setLayerModeTo:(PhLayer *)theLayer
{
    NSEnumerator *numer;
    id theObj;
    
    if (![layersInLevel containsObject:theLayer] && theLayer != nil)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Generic Error";
        alert.informativeText = @"Sorry, but requested layer was not found in level data object!";
        alert.alertStyle = NSAlertStyleCritical;
        [alert runModal];
        return;
    }
    
    if (currentLayer == theLayer)
        return;
    
    [layerPolys removeAllObjects];
    [layerLines removeAllObjects];
    [layerPoints removeAllObjects];
    [layerMapObjects removeAllObjects];
    [layerNotes removeAllObjects];
    
    currentLayer = theLayer;
    
    if (currentLayer != nil)
    {
        [layerPolys addObjectsFromArray:[currentLayer objectsInThisLayer]];
            
        // Gets Tags In Light Objects
        numer = [layerPolys objectEnumerator];
        while (theObj = [numer nextObject])
        {
            short	theVertexCount = [theObj getTheVertexCount];
            int	i;
            //short *theVertexes = [theObj getTheVertexes];
            
            for (i = 0; i < theVertexCount; i++)
            {
                id theVertex = [theObj vertexObjectAtIndex:i];
                id theLine = [theObj lineObjectAtIndex:i];
                
                //NSLog(@"Polygon# %d  ---  Line# %d", [theObj index], [theLine index]);
                
                if (notContain(layerLines, theLine))
                    [layerLines addObject:theLine];
                
                if (notContain(layerPoints, theVertex))
                    [layerPoints addObject:theVertex];
            }
        }
        
        numer = [mapObjects objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if (contains(layerPolys, [theObj polygonObject]))
                [layerMapObjects addObject:theObj];
        }
        
        numer = [notes objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if (contains(layerPolys, [theObj polygonObject]))
                [layerNotes addObject:theObj];
        }
    }
    else
    {
        [layerPolys addObjectsFromArray:polys];
        [layerMapObjects addObjectsFromArray:mapObjects];
        [layerPoints addObjectsFromArray:points];
        [layerLines addObjectsFromArray:lines];
        [layerNotes addObjectsFromArray:notes];
    }
    
    #ifdef useDebugingLogs
        NSLog(@"Count Of layerPolys:      %d", [layerPolys count]);
        NSLog(@"Count Of layerLines:      %d", [layerLines count]);
        NSLog(@"Count Of layerPoints:     %d", [layerPoints count]);
        NSLog(@"Count Of layerMapObjects: %d", [layerMapObjects count]);
        NSLog(@"Count Of layerNotes:      %d", [layerNotes count]);
    #endif
}

-(void)removeLayer:(PhLayer *)theLayer
{
    // Need to reassigned the poys in this layer
    // to a diffrent layer, also get rid of the
    // name in the layerNames array.
    
    //[layersInLevel removeObject:theLayer];
}

-(void)addLayer:(PhLayer *)theLayer
{
    [layersInLevel addObject:theLayer];
    [layerNames addObject:[theLayer phName]];
    [self setUpArrayPointersFor:theLayer];
    
    [self refreshMenusOfMenuType:PhLevelNameMenuLayer];
}

@end
