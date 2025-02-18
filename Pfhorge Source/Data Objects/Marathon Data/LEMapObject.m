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
        polyField = [polygonObject phName];
        
    
    return [NSString stringWithFormat:@"Object Index: %d   In Polygon: %@   Facing: %d   X/Y/Z:(%d, %d, %d)   AdjX/AdjY:(%d, %d)", [self index], polyField, facing, x, y, z, x32, y32, nil];
}

 // **************************  Coding/Copy Protocol Methods  *************************
#pragma mark - Coding/Copy Protocol Methods

- (long)exportWithIndex:(NSMutableArray *)theIndex withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
{
    NSInteger theNumber = [theIndex indexOfObjectIdenticalTo:self];
    int tmpLong = 0;
    //int i = 0;
    
    if (theNumber != NSNotFound) {
        return theNumber;
    }
    
    int myPosition = (int)[theIndex count];
    
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
    
    if (polygonObject != nil && [mainObjs containsObject:polygonObject]) {
        ExportObjIndex(polygonObject, theIndex);
    } else {
        ExportNil();
    }
    
    // *** End Exporting ***
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = (int)[myData length];
	saveIntToNSData(tmpLong, theData);
    [theData appendData:myData];
    [theData appendData:futureData];
    
    NSLog(@"Exporting Map Object: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[theIndex indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    if ([theIndex indexOfObjectIdenticalTo:self] != myPosition) {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %d", [self index], myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [theIndex indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)theIndex withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Map Object: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[theIndex indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
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
    if (self = [self init]) {
        [theLev setUpArrayPointersFor:self];
        [theMapObjectToImitate copySettingsTo:self];
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
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
    }
    return self;
}

- (void)dealloc
{
}

static NSString * const LEMapObjectCoderPolygonObjectKey = @"polygonObject";
static NSString * const LEMapObjectCoderTypeKey = @"type";
static NSString * const LEMapObjectCoderIndexKey = @"index";
static NSString * const LEMapObjectCoderFacingKey = @"facing";
static NSString * const LEMapObjectCoderXKey = @"x";
static NSString * const LEMapObjectCoderYKey = @"y";
static NSString * const LEMapObjectCoderZKey = @"z";
static NSString * const LEMapObjectCoderFlagsKey = @"flags";

- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        [coder encodeInt:type forKey:LEMapObjectCoderTypeKey];
        [coder encodeInt:index forKey:LEMapObjectCoderIndexKey];
        [coder encodeInt:facing forKey:LEMapObjectCoderFacingKey];
        [coder encodeInt:x forKey:LEMapObjectCoderXKey];
        [coder encodeInt:y forKey:LEMapObjectCoderYKey];
        [coder encodeInt:z forKey:LEMapObjectCoderZKey];
        [coder encodeConditionalObject:polygonObject forKey:LEMapObjectCoderPolygonObjectKey];
        [coder encodeInt:flags forKey:LEMapObjectCoderFlagsKey];
    } else {
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
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        if (coder.allowsKeyedCoding) {
            polygonObject = [coder decodeObjectOfClass:[LEPolygon class] forKey:LEMapObjectCoderPolygonObjectKey];
            type = [coder decodeIntForKey:LEMapObjectCoderTypeKey];
            
            index = [coder decodeIntForKey:LEMapObjectCoderIndexKey];
            facing = [coder decodeIntForKey:LEMapObjectCoderFacingKey];
            x = [coder decodeIntForKey:LEMapObjectCoderXKey];
            y = [coder decodeIntForKey:LEMapObjectCoderYKey];
            z = [coder decodeIntForKey:LEMapObjectCoderZKey];
            x32 = x / 16;
            y32 = y / 16;
            flags = [coder decodeIntForKey:LEMapObjectCoderFlagsKey];
        } else {
            /*int versionNum = */decodeNumInt(coder);
            
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
        }
    }
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
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
#pragma mark - Other Methods


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
	
	CGFloat fx = (theOffset.x * ((CGFloat)16));
	CGFloat fy = (theOffset.y * ((CGFloat)16));
	x += (short)(fx + .5);
	y += (short)(fy + .5);
	x32 = x / 16;
	y32 = y / 16;
}

 // **************************  Overriden Standard Methods  *************************
#pragma mark - Overriden Standard Methods

-(short)index { return [theMapObjectsST indexOfObjectIdenticalTo:self]; }

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
#pragma mark - Flag Methods


// *****************   Get Accsessors   *****************
#pragma mark - Get Accsessors

-(NSRect)as32Rect { return NSMakeRect(x32 - 2, y32 - 2, 4, 4); }
+ (NSSet<NSString *> *)keyPathsForValuesAffectingAs32Rect
{
	return [NSSet setWithObjects:@"x32", @"y32", nil];
}
-(NSPoint)as32Point { return NSMakePoint(x32, y32); }
+ (NSSet<NSString *> *)keyPathsForValuesAffectingAs32Point
{
	return [NSSet setWithObjects:@"x32", @"y32", nil];
}
@synthesize z;
@synthesize x;
+ (NSSet<NSString *> *)keyPathsForValuesAffectingX
{
	return [NSSet setWithObject:@"x32"];
}
@synthesize y;
+ (NSSet<NSString *> *)keyPathsForValuesAffectingY
{
	return [NSSet setWithObject:@"y32"];
}
@synthesize x32;
+ (NSSet<NSString *> *)keyPathsForValuesAffectingX32
{
	return [NSSet setWithObject:@"x"];
}
@synthesize y32;
+ (NSSet<NSString *> *)keyPathsForValuesAffectingY32
{
	return [NSSet setWithObject:@"y"];
}
@synthesize type;
-(short)getObjTypeIndex { return index; }
@synthesize facing;
@dynamic polygonIndex;
-(short)polygonIndex { return (polygonObject == nil) ? -1 : [polygonObject index]; }
@synthesize polygonObject;
-(LEMapObjectFlags)flags { return flags; }
@synthesize mapFlags=flags;

// *****************   Set Accsessors   *****************
#pragma mark - Set Accsessors

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

-(void)setType:(LEMapObjectType)s
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
    
    if (type == _saved_monster) {
        [theLELevelDataST adjustInitalItemPlacmentBy:-1 forIndex:index isMonster:YES];
        [theLELevelDataST adjustInitalItemPlacmentBy:1 forIndex:s isMonster:YES];
    } else if (type == _saved_item) {
        [theLELevelDataST adjustInitalItemPlacmentBy:-1 forIndex:index isMonster:NO];
        [theLELevelDataST adjustInitalItemPlacmentBy:1 forIndex:s isMonster:NO];
    }
    
    index = s;
} // make like --> getObjTypeIndex

-(void)setPolygonIndex:(short)s
{
    //polygonIndex = s;
    if (s == -1)
        polygonObject = nil;
    else if (everythingLoadedST)
        polygonObject = [theMapPolysST objectAtIndex:s];
}

@end
