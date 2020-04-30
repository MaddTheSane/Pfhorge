//
//  LEMapObject.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Wed Jun 20 2001.
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

#import "LEMapObject.h"
#import "LEExtras.h"
#import "LELevelData.h"
#import "PhData.h"

@implementation LEMapObject

- (NSString *)description
{
    NSString *polyField = @"[ N/A ]";
    
    if (polygonObject != nil)
        polyField = [polygonObject getPhName];
        
    
    return [NSString stringWithFormat:@"Object Index: %d   In Polygon: %@   Facing: %d   X/Y/Z:(%d, %d, %d)   AdjX/AdjY:(%d, %d)", [self getIndex], polyField, facing, x, y, z, x32, y32, nil];
}

 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********

- (long)exportWithIndex:(NSMutableArray *)theIndex withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
 {
    long theNumber = [theIndex indexOfObjectIdenticalTo:self];
    long tmpLong = 0;
    //int i = 0;
    
    if (theNumber != NSNotFound)
    {
        return theNumber;
    }
    
    int myPosition = [theIndex count];
    
    [theIndex addObject:self];
    
    NSMutableData *myData = [[NSMutableData alloc] init];
    NSMutableData *futureData = [[NSMutableData alloc] init];
    
    // *** Start Exporting ***
    
    ExportShort(type);
    ExportShort(index);
    ExportShort(facing);
    
    ExportShort(x);
    ExportShort(y);
    ExportShort(z);
    
    ExportShort(x32);
    ExportShort(y32);
    
    ExportUnsignedShort(flags);
    
    if (polygonObject != nil && [mainObjs containsObject:polygonObject])
    {
        ExportObjIndex(polygonObject, theIndex);
    }
    else
    {
        ExportNil();
    }
    
    // *** End Exporting ***
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    
    NSLog(@"Exporting Map Object: %d  -- Position: %d --- myData: %d", [self getIndex], [theIndex indexOfObjectIdenticalTo:self], [myData length]);
    
    [myData release];
    [futureData release];
    
    if ((int)[theIndex indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %d", [self getIndex], myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [theIndex indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)theIndex withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Map Object: %d  -- Position: %d  --- Length: %d", [self getIndex], [theIndex indexOfObjectIdenticalTo:self], [myData getPosition]);
    
    ImportShort(type);
    ImportShort(index);
    ImportShort(facing);
    
    ImportShort(x);
    ImportShort(y);
    ImportShort(z);
    
    ImportShort(x32);
    ImportShort(y32);
    
    ImportUnsignedShort(flags);
    
    // If this is nill, may want to do a quick
    // check to see if it is over a polygon...
    ImportObjIndex(polygonObject, theIndex);
}



-(id)initWithMapObject:(LEMapObject *)theMapObjectToImitate withLevel:(LELevelData *)theLev
{
    self = [self init];
    
    if (self == nil)
        return nil;
    
    [theLev setUpArrayPointersFor:self];
    [theMapObjectToImitate copySettingsTo:self];
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    type = 1;
    index = 1;
    facing = 0;
    polygonIndex = -1;
    x = 0;
    y = 0;
    z = 0;
    x32 = 0;
    y32 = 0;
    polygonObject = nil;
    flags = 0;
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeNumInt(coder, 0);
    
    
    encodeShort(coder, type);
    encodeShort(coder, index);
    encodeShort(coder, facing);
    encodeShort(coder, x);
    encodeShort(coder, y);
    encodeShort(coder, z);
    
    /*if (!useIndexNumbersInstead)
        encodeObj(coder, polygonObject);
    else
        encodeObj(coder, nil);*/
    
    encodeConditionalObject(coder, polygonObject);
    
    encodeUnsignedShort(coder, flags);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    type = decodeShort(coder);
    index = decodeShort(coder);
    facing = decodeShort(coder);
    x = decodeShort(coder);
    y = decodeShort(coder);
    z = decodeShort(coder);
    
    x32 = x / 16;
    y32 = y / 16;
    
    polygonObject = decodeObj(coder);
    
    flags = decodeUnsignedShort(coder);
    
    //if (useIndexNumbersInstead)
    //    [theLELevelDataST addObjects:self];
    
    //useIndexNumbersInstead = NO;
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    LEMapObject *copy = [[LEMapObject allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

-(void)copySettingsTo:(id)target
{
    LEMapObject *theTarget = (LEMapObject *)target;
    
    [theTarget setZ:z];
    //[theTarget setX:x];
    //[theTarget setY:y];
    ///[theTarget set32X:];
    ///[theTarget set32Y:];
    [theTarget setType:type];
    [theTarget setIndex:index];
    [theTarget setFacing:facing];
    ///[theTarget setPolygonIndex:-1];
    [theTarget setPolygonObject:polygonObject];
    [theTarget setMapFlags:flags];
}

// **************************  Other Methods  *************************
#pragma mark -
#pragma mark ********* Other Methods *********


-(NSRect)drawingBounds
{
    if (type == _saved_monster || type == _saved_player)
        return NSMakeRect(x32 - 10, y32 - 10, 20, 20);
    else
        return NSMakeRect(x32 - 3, y32 - 3, 6, 6);
}

-(void)moveBy32Point:(NSPoint)theOffset
{
    //[self set32X:(x32 + theOffset.x)];
    //[self set32Y:(y32 + theOffset.y)];
	
	float fx = (theOffset.x * ((float)16));
	float fy = (theOffset.y * ((float)16));
	x += (short)(fx + .5);
	y += (short)(fy + .5);
	x32 = x / 16;
	y32 = y / 16;
}

 // **************************  Overriden Standard Methods  *************************
#pragma mark -
#pragma mark ********* Overriden Standard Methods *********

-(short)getIndex { return [theMapObjectsST indexOfObjectIdenticalTo:self]; }

-(void)updateIndexesNumbersFromObjects
{
    if (polygonObject == nil)
        polygonIndex = -1;
    else
        polygonIndex = [theMapPolysST indexOfObjectIdenticalTo:polygonObject];
}

-(void)updateObjectsFromIndexes
{
    if (polygonIndex == -1)
        polygonObject = nil;
    else if (everythingLoadedST)
        polygonObject = [theMapPolysST objectAtIndex:polygonIndex];
}

// **************************  Flag Methods  *************************
#pragma mark -
#pragma mark ********* Flag Methods *********


// *****************   Get Accsessors   *****************
#pragma mark -
#pragma mark ********* Get Accsessors  *********

-(NSRect)as32Rect { return NSMakeRect(x32 - 2, y32 - 2, 4, 4); }
-(NSPoint)as32Point { return NSMakePoint(x32, y32); }
-(short)getZ { return z; }
-(short)getX { return x; }
-(short)getY { return y; }
-(short)x32 { return x32; }
-(short)y32 { return y32; }
-(short)getType { return type; }
-(short)getObjTypeIndex { return index; }
-(short)getFacing { return facing; }
-(short)getPolygonIndex { return (polygonObject == nil) ? -1 : [polygonObject getIndex]; }
-(id)getPolygonObject { return polygonObject; }
-(unsigned short)getFlags { return flags; }
-(short unsigned)getMapFlags { return flags; }

// *****************   Set Accsessors   *****************
#pragma mark -
#pragma mark ********* Set Accsessors  *********

-(void)setZ:(short)s { z = s; }
-(void)setX:(short)s
{
    x = s;
    x32 = s / 16;
}

-(void)setY:(short)s
{
    y = s;
    y32 = s / 16;
}

-(void)set32X:(short)s
{
    x32 = s;
    x = s * 16;
}

-(void)set32Y:(short)s
{
    y32 = s;
    y = s * 16;
}

-(void)setX32:(short)s
{
    x32 = s;
    x = s * 16;
}

-(void)setY32:(short)s
{
    y32 = s;
    y = s * 16;
}

-(void)setType:(short)s
{ // _saved_item _saved_monster
    
    if (type == s || _NUMBER_OF_OBJECT_TYPES <= s)
        return;
    
    if (type == _saved_monster)
        [theLELevelDataST adjustInitalItemPlacmentBy:-1 forIndex:index isMonster:YES];
    else if (type == _saved_item)
        [theLELevelDataST adjustInitalItemPlacmentBy:-1 forIndex:index isMonster:NO];
    
    if (s == _saved_item)
        [theLELevelDataST adjustInitalItemPlacmentBy:1 forIndex:index isMonster:NO];
    else if (s == _saved_monster)
        [theLELevelDataST adjustInitalItemPlacmentBy:1 forIndex:index isMonster:YES];
    
    type = s;
}

-(void)setIndex:(short)s
{
    if (index == s || s >= 64)
        return;
    
    if (type == _saved_monster)
    {
        [theLELevelDataST adjustInitalItemPlacmentBy:-1 forIndex:index isMonster:YES];
        [theLELevelDataST adjustInitalItemPlacmentBy:1 forIndex:s isMonster:YES];
    }
    else if (type == _saved_item)
    {
        [theLELevelDataST adjustInitalItemPlacmentBy:-1 forIndex:index isMonster:NO];
        [theLELevelDataST adjustInitalItemPlacmentBy:1 forIndex:s isMonster:NO];
    }
    
    index = s;
} // make like --> getObjTypeIndex

-(void)setFacing:(short)s { facing = s; }

-(void)setPolygonIndex:(short)s
{
    //polygonIndex = s;
    if (s == -1)
        polygonObject = nil;
    else if (everythingLoadedST)
        polygonObject = [theMapPolysST objectAtIndex:s];
}

-(void)setPolygonObject:(id)s
{
    polygonObject = s;
}

-(void)setMapFlags:(unsigned short)us { flags = us; }

@end
