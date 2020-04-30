//
//  LELine.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 17 2001.
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

#import "LELine.h"
#import "LEMapPoint.h"
#import "LEPolygon.h"
#import "LEMapObject.h"
#import "LEExtras.h"
#import "LESide.h"
#import "LELevelData.h"
#import "LEMap.h"
#import "PhPlatform.h"

#import "PhData.h"

#define GET_SIDE_FLAG(b) (flags & (b))
#define SET_LINE_FLAG(b, v) ((v) ? (flags |= (b)) : (flags &= ~(b)))

@implementation LELine

- (NSString *)description
{
    return [NSString stringWithFormat:@"Line Index: %d", [self getIndex], nil];
}

- (void)displayInfo
{
    NSMutableString *tis = [[NSMutableString alloc] init];
    
    [tis appendString:[NSString stringWithFormat:@"Line  : %d\n\n", [self getIndex], nil]];
    [tis appendString:[NSString stringWithFormat:@"cPoly : %d\n", [clockwisePolygon getIndex], nil]];
    [tis appendString:[NSString stringWithFormat:@"cSide : %d\n", [clockwisePolygonSideObject getIndex], nil]];
    [tis appendString:[NSString stringWithFormat:@"ccPoly: %d\n", [conterclockwisePolygon getIndex], nil]];
    [tis appendString:[NSString stringWithFormat:@"ccSide: %d\n\n", [counterclockwisePolygonSideObject getIndex], nil]];
    [tis appendString:[NSString stringWithFormat:@"highestAdjacentFloor	: %d\n", highestAdjacentFloor, nil]];
    [tis appendString:[NSString stringWithFormat:@"lowestAdjacentCeiling	: %d\n", lowestAdjacentCeiling, nil]];
    
    [tis appendString:((flags & SOLID_LINE_BIT)		? @"SOLID_LINE_BIT		: YES\n" : @"SOLID_LINE_BIT\t\t: NO\n")];
    [tis appendString:((flags & TRANSPARENT_LINE_BIT)		? @"TRANSPARENT_LINE		: YES\n" : @"TRANSPARENT_LINE\t\t\t: NO\n")];
    [tis appendString:((flags & LANDSCAPE_LINE_BIT)		? @"LANDSCAPE_LINE_BIT	: YES\n" : @"LANDSCAPE_LINE_BIT	: NO\n")];
    [tis appendString:((flags & ELEVATION_LINE_BIT)		? @"ELEVATION_LINE_BIT	: YES\n" : @"ELEVATION_LINE_BIT\t: NO\n")];
    [tis appendString:((flags & VARIABLE_ELEVATION_LINE_BIT)	? @"VARIABLE_ELEVATION	: YES\n" : @"VARIABLE_ELEVATION	: NO\n")];
    [tis appendString:((flags & LINE_HAS_TRANSPARENT_SIDE_BIT)	? @"TRANSPARENT_SIDE		: YES\n" : @"TRANSPARENT_SIDE\t\t: NO\n")];
    [tis appendString:@"\n"];
    
    if (clockwisePolygonSideObject != nil)
    {
        
        [tis appendString:@"\n cSide Type: "];
        
        switch ([clockwisePolygonSideObject getType])
        {
            case _full_side:
                [tis appendString:@"_full_side"];
                break;
            case _high_side:
                [tis appendString:@"_high_side"];
                break;
            case _low_side:
                [tis appendString:@"_low_side"];
                break;
            case _composite_side:
                [tis appendString:@"_composite_side"];
                break;
            case _split_side:
                [tis appendString:@"_split_side"];
                break;
            default:
                [tis appendString:@"unkown"];
                break;
        }
        
        [tis appendString:@"\n"];
    }
    
    if (counterclockwisePolygonSideObject != nil)
    {
        
        [tis appendString:@"ccSide Type: "];
        
        switch ([counterclockwisePolygonSideObject getType])
        {
            case _full_side:
                [tis appendString:@"_full_side"];
                break;
            case _high_side:
                [tis appendString:@"_high_side"];
                break;
            case _low_side:
                [tis appendString:@"_low_side"];
                break;
            case _composite_side:
                [tis appendString:@"_composite_side"];
                break;
            case _split_side:
                [tis appendString:@"_split_side"];
                break;
            default:
                [tis appendString:@"unkown"];
                break;
        }
        
        [tis appendString:@"\n"];
    }
    
    [tis appendString:@"\n"];
    
    SEND_INFO_MSG_TITLE(tis, @"Detailed Line Information...");
    
    [tis release];
}

 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********


 - (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
 {
    long theNumber = [index indexOfObjectIdenticalTo:self];
    long tmpLong = 0;
    //int i = 0;
    
    if (theNumber != NSNotFound)
    {
        return theNumber;
    }
    
    int myPosition = [index count];
    
    [index addObject:self];
    
    NSMutableData *myData = [[NSMutableData alloc] init];
    NSMutableData *futureData = [[NSMutableData alloc] init];
    
    ExportObj(mapPoint1);
    ExportObj(mapPoint2);
    
    ExportUnsignedShort(flags);
    
    ExportShort(_Length);
    ExportShort(highestAdjacentFloor);
    ExportShort(lowestAdjacentCeiling);
    
    if (clockwisePolygon != nil && [mainObjs containsObject:clockwisePolygon])
    {
        ExportObj(clockwisePolygonSideObject);
        ExportObj(clockwisePolygon);
    }
    else
    {
        ExportNil();
        ExportNil();
    }
    
    if (conterclockwisePolygon != nil && [mainObjs containsObject:conterclockwisePolygon])
    {
        ExportObj(counterclockwisePolygonSideObject);
        ExportObj(conterclockwisePolygon);
    }
    else
    {
        ExportNil();
        ExportNil();
    }
    
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    
    
    NSLog(@"Exporting Line: %d  -- Position: %d --- myData: %d", [self getIndex], [index indexOfObjectIdenticalTo:self], [myData length]);
    
    [myData release];
    [futureData release];
    
    if ((int)[index indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %d", [self getIndex], myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Line: %d  -- Position: %d  --- Length: %d", [self getIndex], [index indexOfObjectIdenticalTo:self], [myData getPosition]);
    
    ImportObj(mapPoint1);
    ImportObj(mapPoint2);
    
    ImportUnsignedShort(flags);
    
    ImportShort(_Length);
    ImportShort(highestAdjacentFloor);
    ImportShort(lowestAdjacentCeiling);
    
    ImportObj(clockwisePolygonSideObject);
    ImportObj(clockwisePolygon);
    
    ImportObj(counterclockwisePolygonSideObject);
    ImportObj(conterclockwisePolygon);
}


- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeNumInt(coder, 2);
    
    /*
    if (useIndexNumbersInstead)
    {
        [mapPoint1 setEncodeIndexNumbersInstead:YES];
        [mapPoint2 setEncodeIndexNumbersInstead:YES];
        encodeObj(coder, mapPoint1);
        encodeObj(coder, mapPoint2);
        [mapPoint1 setEncodeIndexNumbersInstead:NO];
        [mapPoint2 setEncodeIndexNumbersInstead:NO];
    }
    else
    {*/
        encodeObj(coder, mapPoint1);
        encodeObj(coder, mapPoint2);
    /*}*/
    
    encodeUnsignedShort(coder, flags);
    
    encodeShort(coder, _Length);
    encodeShort(coder, highestAdjacentFloor);
    encodeShort(coder, lowestAdjacentCeiling);
    
    if (/*!useIndexNumbersInstead*/ YES)
    {
        //encodeObject(coder, clockwisePolygonSideObject);
        [coder encodeObject:clockwisePolygonSideObject];
        [coder encodeObject:counterclockwisePolygonSideObject];
        //encodeObject(coder, counterclockwisePolygonSideObject);
        
        encodeConditionalObject(coder, clockwisePolygon);
        encodeConditionalObject(coder, conterclockwisePolygon);
    }
    else
    {
        LEMapDraw *theDrawView = [[[NSDocumentController
                                    sharedDocumentController]
                                    currentDocument]
                                    getMapDrawView];
        
        NSSet *thePolygonSelections = [theDrawView getSelectionsOfType:_polygon_selections];
        
        BOOL hasClock = [thePolygonSelections containsObject:clockwisePolygon];
        BOOL hasCClock = [thePolygonSelections containsObject:conterclockwisePolygon];
        
        [clockwisePolygonSideObject setEncodeIndexNumbersInstead:YES];
        [counterclockwisePolygonSideObject setEncodeIndexNumbersInstead:YES];
        
        if (hasClock)
        {
            NSLog(@"hasClock was true #%d", [self getIndex]);
            encodeObj(coder, clockwisePolygonSideObject);
        }
        else
        {
            NSLog(@"hasClock was false, set to nil #%d", [self getIndex]);
            encodeObj(coder, nil);
        }
        
        if (hasCClock)
        {
            NSLog(@"hasCClock was true #%d", [self getIndex]);
            encodeObj(coder, counterclockwisePolygonSideObject);
        }
        else
        {
            NSLog(@"hasCClock was false, set to nil #%d", [self getIndex]);
            encodeObj(coder, nil);
        }
    
        if (hasClock)
            encodeObj(coder, clockwisePolygon);
        else
            encodeObj(coder, nil);
        
        if (hasCClock)
            encodeObj(coder, conterclockwisePolygon);
        else
            encodeObj(coder, nil); 
        
        [clockwisePolygonSideObject setEncodeIndexNumbersInstead:NO];
        [counterclockwisePolygonSideObject setEncodeIndexNumbersInstead:NO];
    }
    
    // Below is verion 2 additions
    encodeBOOL(coder, permanentNoSides);
    
    // Below is version 1 additions
    encodeBOOL(coder, permanentSolidLine);
    encodeBOOL(coder, permanentLandscapeLine);
    encodeBOOL(coder, permanentTransparentLine);
    encodeBOOL(coder, usePermanentSettings);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    mapPoint1 = decodeObj(coder);
    mapPoint2 = decodeObj(coder);
    flags = decodeUnsignedShort(coder);
    
    _Length = decodeShort(coder);
    highestAdjacentFloor = decodeShort(coder);
    lowestAdjacentCeiling = decodeShort(coder);
    
    clockwisePolygonSideObject = decodeObj(coder);
    counterclockwisePolygonSideObject = decodeObj(coder);
    
    
    clockwisePolygon = decodeObj(coder);
    conterclockwisePolygon = decodeObj(coder);
    
    // *** *** *** Additions *** *** ***
    
    permanentNoSides = NO;
    
    permanentSolidLine = NO;
    permanentLandscapeLine = NO;
    permanentTransparentLine = NO;
    usePermanentSettings = NO;
    
    switch (versionNum)
    {
        case 2:
            permanentNoSides = decodeBOOL(coder);
        case 1:
            permanentSolidLine = decodeBOOL(coder);
            permanentLandscapeLine = decodeBOOL(coder);
            permanentTransparentLine = decodeBOOL(coder);
            usePermanentSettings = decodeBOOL(coder);
        default:
            break;
    }

    // *** *** *** END Additions *** *** ***
    /*
    if (useIndexNumbersInstead)
        [theLELevelDataST addLine:self];*/
    /*
    if (useIndexNumbersInstead)
    {
        if (clockwisePolygon == nil)
            NSLog(@"clockwisePolygon was nil #%d", [self getIndex]);
        else
            NSLog(@"clockwisePolygon was not nil #%d", [self getIndex]);
        
        if (conterclockwisePolygon == nil)
            NSLog(@"conterclockwisePolygon was nil #%d", [self getIndex]);
        else
            NSLog(@"conterclockwisePolygon was not nil #%d", [self getIndex]);
    }*/
    
    //useIndexNumbersInstead = NO;
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    LELine *copy = [[LELine allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}


// **************************  Flag Methods  *************************
#pragma mark -
#pragma mark ********* Flag Methods *********
 
-(BOOL)getFlagSS:(short)v;
{
    switch (v)
    {
        case 1:
            return (BOOL)(flags & 0x4000);
            break;
        case 2:
            return GET_SIDE_FLAG(0x2000);
            break;
        case 3:
            return GET_SIDE_FLAG(LANDSCAPE_LINE_BIT);
            break;
        case 4:
            return GET_SIDE_FLAG(ELEVATION_LINE_BIT);
            break;
        case 5:
            return GET_SIDE_FLAG(VARIABLE_ELEVATION_LINE_BIT);
            break;
        case 6:
            return GET_SIDE_FLAG(LINE_HAS_TRANSPARENT_SIDE_BIT);
            break;
        default:
            NSLog(@"DEFAULT 2");
            break;
    }
    return NO;
}

-(void)setFlag:(unsigned short)theFlag to:(BOOL)v
 {
    switch (theFlag)
    {
        case SOLID_LINE_BIT:
        case 1: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(SOLID_LINE_BIT, v);
            break;
        case TRANSPARENT_LINE_BIT:
        case 2: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(TRANSPARENT_LINE_BIT, v);
            break;
        case LANDSCAPE_LINE_BIT:
        case 3: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(LANDSCAPE_LINE_BIT, v);
            break;
        case ELEVATION_LINE_BIT:
        case 4: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(ELEVATION_LINE_BIT, v);
            break;
        case VARIABLE_ELEVATION_LINE_BIT:
        case 5: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(VARIABLE_ELEVATION_LINE_BIT, v);
            break;
        case LINE_HAS_TRANSPARENT_SIDE_BIT:
        case 6: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(LINE_HAS_TRANSPARENT_SIDE_BIT, v);
            break;
    }
    
    if (usePermanentSettings == YES)
    {
        if (permanentSolidLine == YES)
            flags |= SOLID_LINE_BIT;
        else
            flags &= ~SOLID_LINE_BIT;
        
        if (permanentLandscapeLine == YES)
            flags |= LANDSCAPE_LINE_BIT;
        else
            flags &= ~LANDSCAPE_LINE_BIT;
        
        if (permanentTransparentLine == YES)
            flags |= TRANSPARENT_LINE_BIT;
        else
            flags &= ~TRANSPARENT_LINE_BIT;
            
            
            // Should probably have caculateDies just return
            // before doing anything if this set...
        /*
        if (permanetNoSides == NO)
            [theLevelST removeSidesFromLine:self]*/
    }
 }

// **************************  Utility Methods  *************************
#pragma mark -
#pragma mark ********* Utility Methods *********

-(NSBezierPath *)clockwiseShadowPath
{
    NSBezierPath *cShadow = [NSBezierPath bezierPath];
    
    int fx1 = 0;
    int fy1 = 0;
    
    int fx2 = 0;
    int fy2 = 0;
    
    int p1X = [mapPoint1 x32];
    int p1Y = [mapPoint1 y32];
    int p2X = [mapPoint2 x32];
    int p2Y = [mapPoint2 y32];
    
    if (p1X == p2X)
    {// Possible Vertical Line...
        if (p1Y == p2Y)
        { // no shoadow in this case...
            return nil;
        }
        else
        { // Vertical Line...
            if (p2Y > p1Y)
            { // Clock Side On The Left...
                fx1 = p1X - 5;
                fx2 = p2X - 5;
                fy1 = p1Y;
                fy2 = p2Y;
            }
            else
            { // Clock Side On The Right...
                fx1 = p1X + 5;
                fx2 = p2X + 5;
                fy1 = p1Y;
                fy2 = p2Y;
            }
        }
    }
    else if (p1Y == p2Y)
    {// Horazontial Line...
        if (p2X > p1X)
        { // Clock Side On The Bottom...
            fy1 = p1Y + 5;
            fy2 = p2Y + 5;
            fx1 = p1X;
            fx2 = p2X;
        }
        else
        { // Clock Side On The Top...
            fy1 = p1Y - 5;
            fy2 = p2Y - 5;
            fx1 = p1X;
            fx2 = p2X;
        }
    }
    else
    {
        int deltaX = p2X - p1X;
		
        int deltaY = p2Y - p1Y;
        
        //float slope = (((float)deltaY) / ((float)deltaX));
        
        //slope = slope * -1.0;
        //slope = 1/slope;
        
        int length = sqrt((deltaX * deltaX)+(deltaY * deltaY));
        
        float quadrantRaito = (float)atan((double)((double)abs(length))/((double)abs(deltaY)));// * 180.0 / 3.141593;
        
        quadrantRaito -= 0.5;
        
        int adjX = (1/quadrantRaito) * 2;
        int adjY = (int)(((float)(1*quadrantRaito)) * 6);
        
        //double theta = (double)p2X * (double)p1X + (double)p2Y * (double)p1Y;
        
        //float theOtherAngle = acos(theta) * 180.0 / 3.141593;
        
        //NSLog(@"length: %d  quadrantRaito: %g  adjX: %d  adjY: %d", length, quadrantRaito, adjX, adjY);
        
        // deltaY2 instead???
       // int theYChange = slope; // - (1/theYChange); // slope * x instead...
        
        if (deltaX < 0)
        {
            if (deltaY < 0)
            { // Upper Left Quadrant
                fx1 = p1X + adjX;
                fx2 = p2X + adjX;
                fy1 = p1Y - adjY;
                fy2 = p2Y - adjY;
            }
            else
            { // Lower Left Quadrant
                fx1 = p1X - adjX;
                fx2 = p2X - adjX;
                fy1 = p1Y - adjY;
                fy2 = p2Y - adjY;
            }
        }
        else
        {
            if (deltaY < 0)
            { // Upper Right Quadrant
                fx1 = p1X + adjX;
                fx2 = p2X + adjX;
                fy1 = p1Y + adjY;
                fy2 = p2Y + adjY;
            }
            else
            { // Lower Right Quadrant
                fx1 = p1X - adjX;
                fx2 = p2X - adjX;
                fy1 = p1Y + adjY;
                fy2 = p2Y + adjY;
            }
        }
        
        /*
        if ((fx1 < fx2 && fy1 > fy2) || (fx1 > fx2 && fy1 < fy2))
        {
            fx1 = p1X - (1/theYChange); // + x instead...
            fx2 = p2X - (1/theYChange); // + x instead...
            
            fy1 = p1Y - theYChange;
            fy2 = p2Y - theYChange;
        }
        else
        {
            fx1 = p1X + (1/theYChange); // + x instead...
            fx2 = p2X + (1/theYChange); // + x instead...
            
            fy1 = p1Y + theYChange;
            fy2 = p2Y + theYChange;
        }*/
    }
    
    [cShadow moveToPoint:[mapPoint1 as32Point]];
    [cShadow lineToPoint:NSMakePoint(fx1,fy1)];
    [cShadow lineToPoint:NSMakePoint(fx2,fy2)];
    [cShadow lineToPoint:[mapPoint2 as32Point]];
    [cShadow lineToPoint:[mapPoint1 as32Point]];
    [cShadow closePath];
    
    return cShadow;
}


// **************************  Overriden Standard Methods  *************************
#pragma mark -
#pragma mark ********* Overriden Standard Methods *********
-(BOOL)uses:(id)theObj
{
    if ([theObj isKindOfClass:[LEMapPoint class]])
    {
        if (mapPoint1 == theObj) return YES;
        if (mapPoint2 == theObj) return YES;
        return NO;
    }
    else if ([theObj isKindOfClass:[LELine class]])
    {
        return NO;
    }
    else if ([theObj isKindOfClass:[LEPolygon class]])
    {
        if (clockwisePolygon == theObj) return YES;
        if (conterclockwisePolygon == theObj) return YES;
        return NO;
    }
    else if ([theObj isKindOfClass:[LEMapObject class]])
    {
        return NO;
    }
    return NO; 
}
 
-(short) getIndex
{
    return [theMapLinesST indexOfObjectIdenticalTo:self];
}
 
-(void) update
{

}

-(void) updateIndexesNumbersFromObjects
{
    /*if (everythingLoadedST == NO)
        return;

    if (counterclockwisePolygonSideObject == nil)
        counterclockwisePolygonSideIndex = -1;
    else
        counterclockwisePolygonSideIndex = [theMapSidesST indexOfObjectIdenticalTo:counterclockwisePolygonSideObject];
    
    if (clockwisePolygonSideObject == nil)
        clockwisePolygonSideIndex = -1;
    else
        clockwisePolygonSideIndex = [theMapSidesST indexOfObjectIdenticalTo:clockwisePolygonSideObject];
    
    if (mapPoint2 == nil)
        p2 = -1;
    else
        p2 = [theMapPointsST indexOfObjectIdenticalTo:mapPoint2];
    
    if (mapPoint1 == nil)
        p1 = -1;
    else
        p1 = [theMapPointsST indexOfObjectIdenticalTo:mapPoint1];
    
    if (conterclockwisePolygon == nil)
        conterclockwisePolygonIndex = -1;
    else
        conterclockwisePolygonIndex = [theMapPolysST indexOfObjectIdenticalTo:conterclockwisePolygon];
    
    if (clockwisePolygon == nil)
        clockwisePolygonIndex = -1;
    else
        clockwisePolygonIndex = [theMapPolysST indexOfObjectIdenticalTo:clockwisePolygon];*/
}

-(void) updateObjectsFromIndexes // Get This Implmented!!!
{
    /*if (everythingLoadedST == NO)
        return;

    if (counterclockwisePolygonSideIndex == -1)
        counterclockwisePolygonSideObject = nil;
    else
        counterclockwisePolygonSideObject = [theMapSidesST objectAtIndex:counterclockwisePolygonSideIndex];
    
    if (clockwisePolygonSideIndex == -1)
        clockwisePolygonSideObject = nil;
    else
        clockwisePolygonSideObject = [theMapSidesST objectAtIndex:clockwisePolygonSideIndex];
    
    if (p2 == -1)
        mapPoint2 = nil;
    else
        mapPoint2 = [theMapPointsST objectAtIndex:p2];
    
    if (p1 == -1)
        mapPoint1 = nil;
    else
        mapPoint1 = [theMapPointsST objectAtIndex:p1];
    
    if (conterclockwisePolygonIndex == -1)
        conterclockwisePolygon = nil;
    else
        conterclockwisePolygon = [theMapPolysST objectAtIndex:conterclockwisePolygonIndex];
    
    if (clockwisePolygonIndex == -1)
        clockwisePolygon = nil;
    else
        clockwisePolygon = [theMapPolysST objectAtIndex:clockwisePolygonIndex];*/
}

-(NSRect) drawingBounds
{ 
    return LERectFromPoints([mapPoint1 as32Point], [mapPoint2 as32Point]);
}

-(void) moveBy32Point:(NSPoint)theOffset
{
    //Set the first point of this line to the new value...
    [mapPoint1 moveBy32Point:theOffset];
    //set the second point of this line to the new value...
    [mapPoint2 moveBy32Point:theOffset];
}

-(BOOL)drawingWithinRect:(NSRect)theRect
{
    NSRect myDrawingBounds = [self drawingBounds];
    
    if (myDrawingBounds.size.height == 0)
        myDrawingBounds.size.height = 2;
    
    if (myDrawingBounds.size.width == 0)
        myDrawingBounds.size.width = 2;
    
    return NSIntersectsRect(theRect, myDrawingBounds);
}

-(void)moveBy32Point:(NSPoint)theOffset pointsAlreadyMoved:(NSMutableSet *)pointsAlreadyMoved
{
    if (![pointsAlreadyMoved containsObject:(mapPoint1)])
    {
        [mapPoint1 moveBy32Point:theOffset];
        [pointsAlreadyMoved addObject:mapPoint1];
    }
    
    if (![pointsAlreadyMoved containsObject:(mapPoint2)])
    {
        [mapPoint2 moveBy32Point:theOffset];
        [pointsAlreadyMoved addObject:mapPoint2];
    }
}

- (BOOL)LEhitTest:(NSPoint)point
{
    
    NSBezierPath *tmpBP2 = [NSBezierPath bezierPath];
    NSPoint theNewPoint = NSMakePoint(((int)(point.x)), ((int)(point.y)));
	
    [tmpBP2 moveToPoint:LEAddToPoint([mapPoint1 as32Point], -2)];
    [tmpBP2 lineToPoint:LEAddToPoint([mapPoint2 as32Point], -2)];
    [tmpBP2 lineToPoint:LEAddToPoint([mapPoint2 as32Point], 2)];
    [tmpBP2 lineToPoint:LEAddToPoint([mapPoint1 as32Point], 2)];
    [tmpBP2 closePath];
	
    if ([tmpBP2 containsPoint:theNewPoint])
        return YES;
	
    return NO;
}

// ************************** Accsessor Methods *************************
// *********  Get Accsessor Methods ********* 
 #pragma mark -
#pragma mark ********* Get Accsessor Methods *********

//LEPolygon *clockwisePolygon, *conterclockwisePolygon

-(short)pointIndex1 { return  (mapPoint1 == nil) ? -1 : [mapPoint1 getIndex]; }
-(short)pointIndex2 { return  (mapPoint2 == nil) ? -1 : [mapPoint2 getIndex]; }
-(short) getP1 { return  (mapPoint1 == nil) ? -1 : [mapPoint1 getIndex]; }
-(short) getP2 { return  (mapPoint2 == nil) ? -1 : [mapPoint2 getIndex]; }
-(LEMapPoint *) getMapPoint1 { return mapPoint1; }
-(LEMapPoint *) getMapPoint2 { return mapPoint2; }
-(unsigned short) getFlags { return flags; }

- (BOOL)getPermanentSetting:(int)settingToSet
{
    switch (settingToSet)
    {
        case _use_parmanent_settings:
            return usePermanentSettings;
        case _parmanent_solid:
            return permanentSolidLine;
        case _parmanent_transparent:
            return permanentTransparentLine;
        case _parmanent_landscape:
            return permanentLandscapeLine;
        case _parmanent_no_sides:
            return permanentNoSides;
        default:
            SEND_ERROR_MSG_TITLE(@"Unknown parmanent setting...", @"Unknown parmanent setting...");
            return NO;
    }
}

-(short) getLength { return _Length; }

// Angle of the line, 0-512 Marathon units, p1 to p2
-(short) getAngle { return _Angle; }
// From p2 to p1
-(short) getFlippedAngle { return (([self getAngle]+256)%512); }

// Degrees clockwise from vertical from p1 to p2
-(short) getAzimuth { return _Azimuth; }
// From p2 to p1
-(short) getFlippedAzimuth { return (([self getAzimuth]+180)%360); }

-(short) getHighestAdjacentFloor { return highestAdjacentFloor; }
-(short) getLowestAdjacentCeiling { return lowestAdjacentCeiling; }

-(short) getClockwisePolygonSideIndex { return (clockwisePolygonSideObject == nil) ? -1 : [clockwisePolygonSideObject getIndex]; }
-(short) getCounterclockwisePolygonSideIndex { return (counterclockwisePolygonSideObject == nil) ? -1 : [counterclockwisePolygonSideObject getIndex]; }

-(id) getClockwisePolygonSideObject { return clockwisePolygonSideObject; }
-(id) getCounterclockwisePolygonSideObject { return counterclockwisePolygonSideObject; }

-(short) getClockwisePolygonOwner { return (clockwisePolygon == nil) ? -1 : [clockwisePolygon getIndex]; }
-(short) getConterclockwisePolygonOwner { return (conterclockwisePolygon == nil) ? -1 : [conterclockwisePolygon getIndex]; }
-(short) getClockwisePolygonIndex { return (clockwisePolygon == nil) ? -1 : [clockwisePolygon getIndex]; }
-(short) getConterclockwisePolygonIndex { return (conterclockwisePolygon == nil) ? -1 : [conterclockwisePolygon getIndex]; }

-(LEPolygon *) getClockwisePolygonObject { return clockwisePolygon; }
-(LEPolygon *) getConterclockwisePolygonObject { return conterclockwisePolygon; }

// ********* Set Accsessor Methods ********* 
 #pragma mark -
#pragma mark ********* Set Accsessor Methods *********
-(void) setPointIndex1:(short)s { [self setP1:s]; }
-(void) setPointIndex2:(short)s { [self setP2:s]; }

-(void) setP1:(short)s
{
    //p1 = s;
    if (s == -1)
        mapPoint1 = nil;
    else if (everythingLoadedST)
        mapPoint1 = [theMapPointsST objectAtIndex:p1];

    [self recalc];
}

-(void) setP2:(short)s
{
    //p2 = s;
    if (s == -1)
        mapPoint2 = nil;
    else if (everythingLoadedST)
        mapPoint2 = [theMapPointsST objectAtIndex:p2];

    [self recalc];
}

-(void)setMapPoint1:(LEMapPoint *)s
{
    // If it is nil, obj-c will not send any message...
    [mapPoint1 lineDisconnectedFromMe:self];
    
    mapPoint1 = s;
    
    [mapPoint1 lineConnectedToMe:self];
    
    [self recalc];
}

-(void)setMapPoint2:(LEMapPoint *)s
{
    // If it is nil, obj-c will not send any message...
    [mapPoint2 lineDisconnectedFromMe:self];
    
    mapPoint2 = s;
    
    [mapPoint2 lineConnectedToMe:self];
    
    [self recalc];
}

-(void)setMapPoint1:(LEMapPoint *)s1 mapPoint2:(LEMapPoint *)s2
{
    // If either is nil, obj-c will not send any message...
    [mapPoint1 lineDisconnectedFromMe:self];
    [mapPoint2 lineDisconnectedFromMe:self];
    
    mapPoint1 = s1;
    mapPoint2 = s2;
    
    [mapPoint1 lineConnectedToMe:self];
    [mapPoint2 lineConnectedToMe:self];
    
    [self recalc];
}

-(void)setFlags:(unsigned short)v
{
    flags = v;
    
    if (usePermanentSettings == YES)
    {
        if (permanentSolidLine == YES)
            flags |= SOLID_LINE_BIT;
        else
            flags &= ~SOLID_LINE_BIT;
        
        if (permanentLandscapeLine == YES)
            flags |= LANDSCAPE_LINE_BIT;
        else
            flags &= ~LANDSCAPE_LINE_BIT;
        
        if (permanentTransparentLine == YES)
            flags |= TRANSPARENT_LINE_BIT;
        else
            flags &= ~TRANSPARENT_LINE_BIT;
    }
}

- (void)setPermanentSetting:(int)settingToSet to:(BOOL)value
{
    switch (settingToSet)
    {
        case _use_parmanent_settings:
            usePermanentSettings = value;
            break;
        case _parmanent_solid:
            permanentSolidLine = value;
            break;
        case _parmanent_transparent:
            permanentTransparentLine = value;
            break;
        case _parmanent_landscape:
            permanentLandscapeLine = value;
            break;
        case _parmanent_no_sides:
            permanentNoSides = value;
            break;
        default:
            SEND_ERROR_MSG_TITLE(@"Unknown parmanent setting...", @"Unknown parmanent setting...");
            break;
    }
}


-(void) setLength:(short)s { _Length = s; }
-(void) setAngle:(short)s { _Angle = s; }
-(void) setAzimuth:(short)s { _Azimuth = s; }

// Mabye make these pointers to the polygons themselves???
-(void) setHighestAdjacentFloor:(short)s { highestAdjacentFloor = s; }
-(void) setLowestAdjacentCeiling:(short)s { lowestAdjacentCeiling = s; }





//	--- --- ---

-(void) setClockwisePolygonSideIndex:(short)s
{
    //clockwisePolygonSideIndex = s;
    if (s == -1)
        clockwisePolygonSideObject = nil;
    else if (everythingLoadedST)
        clockwisePolygonSideObject = [theMapSidesST objectAtIndex:s];
}
-(void) setCounterclockwisePolygonSideIndex:(short)s
{
    //counterclockwisePolygonSideIndex = s;
    if (s == -1)
        counterclockwisePolygonSideObject = nil;
    else if (everythingLoadedST)
        counterclockwisePolygonSideObject = [theMapSidesST objectAtIndex:s];
}

//	*** *** ***

-(void) setClockwisePolygonSideObject:(id)s
{
    clockwisePolygonSideObject = s;
}
-(void) setCounterclockwisePolygonSideObject:(id)s
{
    counterclockwisePolygonSideObject = s;
}

//	--- --- ---

-(void) setClockwisePolygonOwner:(short)s
{
    //clockwisePolygonIndex = s;
    if (s == -1)
        clockwisePolygon = nil;
    else if (everythingLoadedST)
        clockwisePolygon = [theMapPolysST objectAtIndex:clockwisePolygonIndex];
}

-(void) setConterclockwisePolygonOwner:(short)s
{
    //conterclockwisePolygonIndex = s;
    if (s == -1)
        conterclockwisePolygon = nil;
    else if (everythingLoadedST)
        conterclockwisePolygon = [theMapPolysST objectAtIndex:conterclockwisePolygonIndex];
}

//	*** *** ***

-(void) setClockwisePolygonIndex:(short)s
{
    //clockwisePolygonIndex = s;
    if (s == -1)
        clockwisePolygon = nil;
    else if (everythingLoadedST)
        clockwisePolygon = [theMapPolysST objectAtIndex:clockwisePolygonIndex];
}

-(void) setConterclockwisePolygonIndex:(short)s
{
    //conterclockwisePolygonIndex = s;
    if (s == -1)
        conterclockwisePolygon = nil;
    else if (everythingLoadedST)
        conterclockwisePolygon = [theMapPolysST objectAtIndex:conterclockwisePolygonIndex];
}

//	*** *** ***

-(void) setClockwisePolygonObject:(LEPolygon *)s
{
    clockwisePolygon = s;
}

-(void) setConterclockwisePolygonObject:(LEPolygon *)s
{
    conterclockwisePolygon = s;
}

//	--- --- ---

// ************************** Inzlizations And Class Methods *************************
#pragma mark -
#pragma mark ********* dealloc, class, and init methods *********

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        //[self setP1:-1];
        //[self setP2:-1];
        //[self setFlags:0];
        //[self setLength:0]; // MAKE SURE that when you move a line around you recompute this, use triangles!!!
        //[self setHighestAdjacentFloor:0]; // polygons should do this?
        //[self setLowestAdjacentCeiling:0]; // polygons should do this?
        //[self setClockwisePolygonSideIndex:-1]; // polygons should do this?
        //[self setCounterclockwisePolygonSideIndex:-1]; // polygons should do this?
        //[self setClockwisePolygonOwner:-1]; // polygons should do this?
        //[self setConterclockwisePolygonOwner:-1]; // polygons should do this?
        
        flags = 0;
        _Length = 0;
        _Angle = 0;
        _Azimuth = 0;
        
        highestAdjacentFloor = 0;
        lowestAdjacentCeiling = 0;
        
        clockwisePolygonSideObject = nil;
        counterclockwisePolygonSideObject = nil;
        
        clockwisePolygon = nil;
        conterclockwisePolygon = nil;
        
        permanentSolidLine = NO;
        permanentLandscapeLine = NO;
        permanentTransparentLine = NO;
        usePermanentSettings = NO;
        permanentNoSides = NO;
        
        mapPoint1 = nil;
        mapPoint2 = nil;
    }
    return self;
}

// ************************** Poly Routine *************************
#pragma mark -
#pragma mark ********* Poly Routine *********

-(LEPolygon *)getPolyFromMe
{
    NSEnumerator *numer;
    BOOL keepPolyFinding = YES, foundTheLine = NO;
    //BOOL foundSelection = NO
    BOOL keepFollowingTheLines = YES;
    BOOL lastLineToTest = NO;
    int indexOfLineFound;
    //int dis1, dis2;
    NSMutableArray *theNewPolyLines, *theNewPolyVectors;
    NSArray *theMapPoints, *theLines;
    //NSMutableArray *theMapObjects, *thePolys;
    LEMapPoint *currentLineMainPoint, *currentLineSecondaryPoint;
    LEMapPoint *tempLinePoint1, *tempLinePoint2;
    //LEMapPoint *curPoint;
    LELine *thisMapLine, *currentLine = nil, *previousLine;
    //NSPoint theCurPoint =/* mouseLoc*/;
    
    ///NSPoint point1, point2;
    
    NSSet *theConnectedLines;
    LEPolygon *theNewPolygon;
    
    // Prepeare The Stuff... :)   Draconic... --:=>
    theMapPoints = theMapPointsST;
    theLines = theMapLinesST;
    
    theNewPolyLines = [NSMutableArray arrayWithCapacity:8];
    theNewPolyVectors = [NSMutableArray arrayWithCapacity:8];
    
    //NSLog(@"Got Thought With Preperations For Polygon Filling...");
    

    if ([self getClockwisePolygonOwner] == -1 || [self getConterclockwisePolygonOwner] == -1)
    {
        keepPolyFinding = NO;
        foundTheLine = YES;
        indexOfLineFound = [theLines indexOfObjectIdenticalTo:self];
        currentLine = self;
        //return nil;
    }
    
    // If the line was not found, return NO...
    if (!foundTheLine && currentLine == nil)
    {
        SEND_ERROR_MSG(@"Could not fill polygon, could not find the leftmost line.");
        return nil;
    }
    
    //NSLog(@"Found the start line index: %d", [theLines indexOfObjectIdenticalTo:currentLine]);
    // If line was found, follow it around, always choosing
    // the inner most line, to see if it completes a polygon...
    
    //get The line disteance in world_units/32 from upper left corner of grid
    
    //point1 = [[theMapPoints objectAtIndex:[currentLine pointIndex1]] asPoint];
    //point2 = [[theMapPoints objectAtIndex:[currentLine pointIndex2]] asPoint];
    
    tempLinePoint2 = [currentLine getMapPoint2];
    tempLinePoint1 = [currentLine getMapPoint1];
    
    if ([self isThereAClockWiseLineAlpha:tempLinePoint2 beta:tempLinePoint1 theLine:currentLine])
    {
        currentLineMainPoint = tempLinePoint2;
        currentLineSecondaryPoint = tempLinePoint1;
    }
    else if ([self isThereAClockWiseLineAlpha:tempLinePoint1 beta:tempLinePoint2 theLine:currentLine])
    {
        currentLineMainPoint = tempLinePoint1;
        currentLineSecondaryPoint = tempLinePoint2;
    }
    else
        return nil;
    
    //NSLog(@"currentLineMainPoint index: %d", [theMapPoints indexOfObjectIdenticalTo:currentLineMainPoint]);
    //NSLog(@"currentLineSecondaryPoint index: %d", [theMapPoints indexOfObjectIdenticalTo:currentLineSecondaryPoint]);
    
    
    [theNewPolyVectors addObject:currentLineSecondaryPoint];
    [theNewPolyVectors addObject:currentLineMainPoint];
    [theNewPolyLines addObject:currentLine];
    
    
    //found the point to start...
    //if (theConnectedLines != nil)
    //    [theConnectedLines release];
    //NSLog(@"Pass theConnectedLines release");
    
    while (keepFollowingTheLines)
    {
        LELine *smallestLine;
        LEMapPoint *nextMainPoint;
        int smallestLineIndex = -1, nextMainPointIndex = -1;
        double smallestAngle = 181.9;
        
        smallestLine = nil;
        nextMainPoint = nil;
        
        theConnectedLines = [currentLineMainPoint getLinesAttachedToMe];
        
        if ([theConnectedLines count] < 2)
        {
            SEND_ERROR_MSG(@"When I was following the line around (clockwise) I found a line with no other line connecting from it (dead end).");
            return nil;
        }
        else
        {
            //NSLog(@"Found connected lines, processesing them now...");
            
            previousLine = nil; // Just to make sure...
            numer = [theConnectedLines objectEnumerator];
            while (thisMapLine = [numer nextObject])
            { 
                LEMapPoint *theCurPoint1 = [theMapPoints objectAtIndex:[thisMapLine pointIndex1]];
                LEMapPoint *theCurPoint2 = [theMapPoints objectAtIndex:[thisMapLine pointIndex2]];
                LEMapPoint *theCurPoint;
                
                if (theCurPoint1 == currentLineMainPoint)
                {
                    theCurPoint = theCurPoint2;
                }
                else
                {
                    theCurPoint = theCurPoint1;
                }
                
                //NSLog(@"Analyzing line: %d", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                
                if ([thisMapLine getClockwisePolygonOwner] != -1 && [thisMapLine getConterclockwisePolygonOwner] != -1)
                {
                    // Might want to make sure of this in finnal lines instead, etc.???
                    NSLog(@"Line# %d already has two polygons attached to it, can't make a third polygon from it.", [thisMapLine getIndex]);
                    //return NO;
                    continue;
                }
                
                if (thisMapLine != currentLine)
                {
                    if (theCurPoint != nil)
                    {
                        double previousX, previousY, thisX, thisY;
                        double prevX, prevY, theX, theY;
                        double prevLength, theLength;
                        double theta, alpha, thetaRad, tango;
                        double xrot, yrot;
                        double slope, theXfromSlop;
                        short newX, newY, newPrevX, newPrevY;
                        BOOL slopeChecksOut = NO;
        
                        previousX = [currentLineSecondaryPoint getX] - [currentLineMainPoint getX];
                        previousY = [currentLineSecondaryPoint getY] - [currentLineMainPoint getY];
                        thisX = [theCurPoint getX] - [currentLineMainPoint getX];
                        thisY = [theCurPoint getY] - [currentLineMainPoint getY];
                        prevX = previousX;
                        prevY = previousY;
                        theX = thisX;
                        theY = thisY;
                        
                        if (previousX == 0)
                        {
                            if (previousY < 0 && thisX < 0) // alpha below
                                slopeChecksOut = YES;
                            if (previousY > 0 && thisX > 0) // alpha above
                                slopeChecksOut = YES;
                            if (previousY != 0 && thisX == 0)
                            {
                                slopeChecksOut = YES;
                            }
                            else if (previousY == 0)
                            {
                                NSLog(@"There is one point directly over another (they both have the same codinates)... y");
                                slopeChecksOut = NO;
                            }
                        }
                        else if (previousY == 0)
                        {
                            if (previousX < 0 && thisY > 0)
                                slopeChecksOut = YES;
                            if (previousX > 0 && thisY < 0)
                                slopeChecksOut = YES;
                            if (previousX != 0 && thisY == 0)
                            {
                                slopeChecksOut = YES;
                            }
                            else if (previousX == 0)
                            {
                                NSLog(@"There is one point directly over another (they both have the same codinates)... x");
                                slopeChecksOut = NO;
                            }
                        }
                        
                        //NSLog(@"previousY: %g previousX: %g", previousY, previousX);
                        slope = previousY / previousX;
                        //NSLog(@"slope: %g theY: %g", slope, theY);
                        theXfromSlop = theY / slope;
                        //NSLog(@"theXfromSlop: %g", theXfromSlop);
                        
                        prevLength = sqrt( previousX * previousX + previousY * previousY );
                        previousX /= prevLength;
                        previousY /= prevLength;
        
                        theLength = sqrt( thisX * thisX + thisY * thisY );
                        thisX /= theLength;
                        thisY /= theLength;
        
                        theta = (double)previousX * (double)thisX + (double)previousY * (double)thisY;
                        //NSLog(@"Angleized Line Index: %d  theta: %g", [theLines indexOfObjectIdenticalTo:thisMapLine], theta);
                        alpha = theta;
                        tango = theta;
                        theta = acos(theta);
                        thetaRad = theta;
                        theta = theta * 180.0 / 3.141593;
                        alpha = asin(alpha);
                        alpha = alpha * 180.0 / 3.141593;
                        tango = atan(tango);
                        tango = tango * 180.0 / 3.141593;
                        //NSLog(@"Angleized Line Index: %d  Alpha: %g Tango: %g", [theLines indexOfObjectIdenticalTo:thisMapLine], alpha, tango);
                        xrot = theX * cos(thetaRad) - theY * sin(thetaRad);
                        yrot = theX * sin(thetaRad) + theY * cos(thetaRad);
                        //NSLog(@"Angleized Line Index: %d  with BEFORE rot ( %f, %f)", [theLines indexOfObjectIdenticalTo:thisMapLine], xrot, yrot);
        
                        newX = (short) xrot;
                        newY = (short) yrot;
                        newPrevX = (short)prevX;
                        newPrevY = (short)prevY;
                        xrot = (double)newX / theLength;
                        yrot = (double)newY / theLength;
                        //NSLog(@"Angleized Line Index: %d  With Angle Of: %g with rot ( %f, %f)",
                         //   [theLines indexOfObjectIdenticalTo:thisMapLine], theta, xrot, yrot);
                        
                        
                        if (theta != 180.0)
                        {
                                //NSLog(@"For Line %d  theX: %g theY: %g", [theLines indexOfObjectIdenticalTo:thisMapLine], theX, theY);
                                if (0 < prevY) // Main Point Lower
                                {
                                    if (theX >= theXfromSlop) //ok
                                    {
                                        //NSLog(@"For Line %d  (1) ", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                                        slopeChecksOut = YES;
                                    }
                                }
                                else if (0 > prevY) // Main Point Higher
                                {
                                    if (theX <= theXfromSlop) //ok
                                    {
                                        //NSLog(@"For Line %d  (2) ", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                                        slopeChecksOut = YES;
                                    }
                                }
                                else // equals
                                {
                                    if (0 > prevX) // Main Point Higher
                                    {
                                        if (theY >= prevY) //ok
                                        {
                                            //NSLog(@"For Line %d  (3) ", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                                            slopeChecksOut = YES;
                                        }
                                    }
                                    else if (prevX > 0) // Main Point Higher
                                    {
                                        if (theY <= prevY) //ok
                                        {
                                            //NSLog(@"For Line %d  (4) ", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                                            slopeChecksOut = YES;
                                        }
                                    }
                                }
                        }
                        else if (theta == 180.0)
                        {
                            slopeChecksOut = YES;
                        }
                        
                        
                        if ( theta <= 180.0 && theta < smallestAngle && slopeChecksOut)
                        {
                                smallestLine = thisMapLine;
                                smallestLineIndex = [theLines indexOfObjectIdenticalTo:thisMapLine];
                                smallestAngle = theta;
                                nextMainPoint = theCurPoint;
                                nextMainPointIndex = [theMapPoints indexOfObjectIdenticalTo:theCurPoint];
                                
                                //lastLine = curLine;
                                //lastVertex = GetLine( curLine ).GetVertex0();
                                //lastOtherVertex = GetLine( curLine ).GetVertex1();
                                
                                //NSLog(@"Lowest Line Index: %d  With Angle Of: %g", smallestLineIndex, smallestAngle);
                        }// End if ( theta <= 180.0 && theta < smallestAngle && [theCurPoint getX] >= [firstPoint getX])
    
                    } // End if (theCurPoint1 == firstPoint)
                } // End if (currentLine != thisMapLine)
            } // End while (currentLine == [numer nextObject])
            
            //We have found the next line to follow...
            NSLog(@"FINNAL Lowest Line Index: %d  With Angle Of: %g", smallestLineIndex, smallestAngle);
            
            if (smallestLineIndex < 0 || smallestLine == nil) // Proably -1, means it did not find a line that passed all the tests...
            {
                SEND_ERROR_MSG(@"One of the lines was not concave reltive to the rest of the lines...");
                return nil;
            }
            
            if (lastLineToTest) {
                // Test to see and confirm that the line it choose is the same
                // as the first line that was found... 
                //NSLog(@"Second Phase Almost Complete...");
                if (smallestLine != [theNewPolyLines objectAtIndex:0])
                {
                    SEND_ERROR_MSG(@"When I reached the finnal line (going clockwise), the line with the smallest angle was not the orginal line!");
                    return nil;
                }
                
                // *** Polygon Completed, now for the hit test! ***
                
                keepFollowingTheLines = NO;
                //NSLog(@"Second Phase Of Fill Polygon Method Found A Polygon!!!");
            }
            else
            {                
                // Need to see if the next main point is the same point as the first one...
                if ([theNewPolyVectors objectAtIndex:0] == nextMainPoint)
                {
                    // Will there be more then 8 vectors/lines in this poly?
                    if ([theNewPolyVectors count] > 8)
                    {
                        SEND_ERROR_MSG(@"More then 8 vertices when trying to fill polygon!");
                        return nil;
                    }
                    
                    // Add the new line and vector to the arrays...
                    [theNewPolyLines addObject:smallestLine];
                    
                    // Make the current main vector secondary, make new vector the main vector...
                    currentLineSecondaryPoint = currentLineMainPoint;
                    currentLineMainPoint = nextMainPoint;
                    
                    //Make The Next Current Line the one just found...
                    currentLine = smallestLine;
                    
                    lastLineToTest = YES;
                }
                else
                { // Polygon Not Yet Completed...
                    // Will there be more then 8 vectors/lines in this poly?
                    if ([theNewPolyVectors count] > 7)
                    {
                        SEND_ERROR_MSG(@"More then 8 vertices when trying to fill polygon!");
                        return nil;
                    }
                    
                    // Add the new line and vector to the arrays...
                    [theNewPolyVectors addObject:nextMainPoint];
                    [theNewPolyLines addObject:smallestLine];
                    
                    // Make the current main vector secondary, make new vector the main vector...
                    currentLineSecondaryPoint = currentLineMainPoint;
                    currentLineMainPoint = nextMainPoint;
                    
                    //Make The Next Current Line the one just found...
                    currentLine = smallestLine;
                }      
            } // End if (lastLineToTest) else
        } // End if ([theConnectedLines count] > 0) else
    } // End while (keepFollowingTheLines)
    
    //   theNewPolyVectors
    //   theNewPolyLines
    
    theNewPolygon = [[LEPolygon alloc] init];
    
    [self setAllObjectSTsFor:theNewPolygon];
    
    [theNewPolygon setVertextCount:[theNewPolyVectors count]];
    
    // Check to make sure the the count is greater then three sometime...
    
    switch ([theNewPolyVectors count])
    {
        case 8:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:7] i:7];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:7] i:7];
        case 7:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:6] i:6];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:6] i:6];
        case 6:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:5] i:5];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:5] i:5];
        case 5:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:4] i:4];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:4] i:4];
        case 4:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:3] i:3];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:3] i:3];
        case 3:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:2] i:2];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:2] i:2];
        case 2:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:1] i:1];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:1] i:1];
        case 1:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:0] i:0];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:0] i:0];
            break;
        case 0:
            NSLog(@"getPolyFromMe vertex count durring poly acuire was zero???");
        default:
            NSLog(@"Should of never gotten here, something is/went HORABLY wrong while polygon filling, map data in memory could be mangled badly!!!");
            // ??? should of never gotten here, something is HORABLY wrong!!! :(
            SEND_ERROR_MSG(@"Somting is very wrong with the polygon line following, in LELine getPolyFromMe");
            [theNewPolygon release];
            return nil;
    }
    
    
    //NSLog(@"Returning The Polygon...");
    
    return [theNewPolygon autorelease];
    
    // Add the new polygon to the level...
    // Next step would be to tell the level object to add the polygon...
    
} // End -(BOOL)usePaintTool:(NSPoint)mouseLoc

- (BOOL)isThereAClockWiseLineAlpha:(LEMapPoint *)alphaPoint beta:(LEMapPoint *)betaPoint theLine:(LELine *)currentLine
{
    NSEnumerator *numer;
    LELine *thisMapLine;
    // *** *** ***
    LELine *smallestLine;
    LEMapPoint *nextMainPoint;
    
    NSSet *theConnectedLines = [alphaPoint getLinesAttachedToMe]; 
    
    smallestLine = nil;
    nextMainPoint = nil;
    
    if ([theConnectedLines count] < 2)
    {
        NSLog(@"   IFIND When I was following the line around (clockwise) I found a line with no other line connecting from it (dead end).");
        return NO;
    }
    
    //previousLine = nil; // Just to make sure...
    numer = [theConnectedLines objectEnumerator];
    while (thisMapLine = [numer nextObject])
    {
        double previousX, previousY, thisX, thisY;
        double prevX, prevY, theX, theY;
        double slope, theXfromSlop;
        LEMapPoint *theCurPoint1 = [theMapPointsST objectAtIndex:[thisMapLine pointIndex1]];
        LEMapPoint *theCurPoint2 = [theMapPointsST objectAtIndex:[thisMapLine pointIndex2]];
        LEMapPoint *theCurPoint;
        
        if (theCurPoint1 == alphaPoint)
        {
            theCurPoint = theCurPoint2;
        }
        else
        {
            theCurPoint = theCurPoint1;
        }
        
        //NSLog(@"Analyzing line: %d", [theLines indexOfObjectIdenticalTo:thisMapLine]);
        
        if ([thisMapLine getClockwisePolygonOwner] != -1 && [thisMapLine getConterclockwisePolygonOwner] != -1)
        {
            // Might want to make sure of this in finnal lines instead, etc.???
            NSLog(@"   IFIND Line# %d already has two polygons attached to it, can't make a third polygon from it, still checking...", [thisMapLine getIndex]);
            //return NO;
            continue;
        }
        
        if (thisMapLine == currentLine)
            continue;
        
        previousX = [betaPoint getX] - [alphaPoint getX];
        previousY = [betaPoint getY] - [alphaPoint getY];
        thisX = [theCurPoint getX] - [betaPoint getX];
        thisY = [theCurPoint getY] - [betaPoint getY];
        prevX = previousX;
        prevY = previousY;
        theX = thisX;
        theY = thisY;
        
        if (previousX == 0)
        {
            if (previousY < 0 && thisX < 0)
                return YES;
            if (previousY > 0 && thisX > 0)
                return YES;
            if (previousY != 0 && thisX == 0)
            {
                if ([self isThereAClockWiseLineAlpha:theCurPoint beta:alphaPoint theLine:thisMapLine])
                    return YES;
                else
                    continue;
            }
            else
            {
                NSLog(@"There is one point directly over another (they both have the same codinates)... Skiping This Line Possiblity...");
                continue;
            }
        }
        else if (previousY == 0)
        {
            if (previousX < 0 && thisY > 0)
                return YES;
            if (previousX > 0 && thisY < 0)
                return YES;
            if (previousX != 0 && thisY == 0)
            {
                if ([self isThereAClockWiseLineAlpha:theCurPoint beta:alphaPoint theLine:thisMapLine])
                    return YES;
                else
                    continue;
            }
            else
            {
                NSLog(@"There is one point directly over another (they both have the same codinates)... Skiping This Line Possiblity...");
                continue;
            }
        }
        
        //NSLog(@"   IFIND previousY: %g previousX: %g", previousY, previousX);
        slope = previousY / previousX;
        //NSLog(@"   IFIND slope: %g theY: %g", slope, theY);
        theXfromSlop = theY / slope;
        //NSLog(@"   IFIND theXfromSlop: %g", theXfromSlop);
    
        //NSLog(@"   IFIND For Line %d  theX: %g theY: %g", [thisMapLine getIndex], theX, theY);
        if (0 < prevY) // Main Point Lower
        {
            if (theX >= theXfromSlop) //ok
            {
                return YES;
            }
        }
        else if (0 > prevY) // Main Point Higher
        {
            if (theX <= theXfromSlop) //ok
            {
                return YES;
            }
        }
        else // equals
        {
            if (0 > prevX) // Main Point Higher
            {
                if (theY >= prevY) //ok
                {
                    return YES;
                }
            }
            else if (prevX > 0) // Main Point Higher
            {
                if (theY <= prevY) //ok
                {
                    return YES;
                }
            }
        }
    } // END   while (thisMapLine = [numer nextObject])
    return NO;
}


// jra 7-26-03
// Recalculate length, azimuth, angle
// Should be called whenever one of these changes
// Called by LEMapPoint to the lines it is part of, when it moves
-(void)recalc
{
    // There's no point doing anything if
    // either one is nil...
    if (mapPoint1 == nil || mapPoint2 == nil)
    {
        //_Length = 0;
        //_Angle = 0;
        //_Azimuth = 0;
        return;
    }
    
    double a = 0, t = 0;
    double m = 0;
    
    short x1 = [[self getMapPoint1] x32];
    short y1 = [[self getMapPoint1] y32];
    short x2 = [[self getMapPoint2] x32];
    short y2 = [[self getMapPoint2] y32];

    short dX = x1-x2;
    short dY = y1-y2;

    // Calculate the length

    [self setLength:(sqrt(dX*dX + dY*dY))];

    // Calculate the azimuth - in integer degrees clockwise from vertical
    // As if we were a vector from p1 to p2

    // this is radians
    a = atan(((double)dY) / ((double)dX));

    // now it's degrees
    a *= (180.0 / 3.141592654);
    
    if(dX < 0)			// quadrant 1 or 2
    {
	if(dY > 0)		// quadrant 1
	{
	    // a will be negative, 90-0
	    t = 90.0 + a;
	}
	else if (dY < 0)	// quadrant 2
	{
	    // a will be positive, 0-90
	    t = 90.0 + a;
	}
	else			// rightwards
	{
	    t = 90.0;
	}
    }
    else if(dX > 0)		// quadrant 3 or 4
    {
	if(dY < 0)		// quadrant 3
	{
	    // a will be negative, 90-0
	    t = 270.0 + a;
	}
	else if(dY > 0)		// quadrant 4
	{
	    // a will be positive, 0-90
	    t = 270.0 + a;
	}
	else			// leftwards
	{
	    t = 270.0;
	}
    }
    else			// straight up or down
    {
	if(dY > 0)		// straight up
	{
	    t = 0.0;
	}
	else if(dY < 0 )	// straight down
	{
	    t = 180.0;
	}
	else			// p1 = p2 = zero length line!!
	{
//	    NSLog(@"Oops! This is a zero length line, which should have been caught elsewhere!");
	}
    }

    [self setAzimuth:(short)t];

    // Calculate the Marathon angle
    // 0-512 counterclockwise from rightwards
    m = t;
    
    // Let's do this a step at a time.
    
    // Counterclockwise
    m = (180.0 - m) + 180.0;
    
    // From rightwards
    m += 90.0;
    if(m >= 360.0)
    {
		m -= 360.0; // <-- it's like % but i can guarantee it'll never go over 720
	}				// so no need to worry about not being enough
	
    // In 512s
    m *= (512.0/360.0);

    [self setAngle:(short)m];
}

@end
