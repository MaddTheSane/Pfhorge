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

#include <tgmath.h>
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
    return [NSString stringWithFormat:@"Line Index: %d", [self index], nil];
}

- (void)displayInfo
{
    NSMutableString *tis = [[NSMutableString alloc] init];
    
    [tis appendString:[NSString stringWithFormat:@"Line  : %d\n\n", [self index], nil]];
    [tis appendString:[NSString stringWithFormat:@"cPoly : %d\n", [clockwisePolygon index], nil]];
    [tis appendString:[NSString stringWithFormat:@"cSide : %d\n", [clockwisePolygonSideObject index], nil]];
    [tis appendString:[NSString stringWithFormat:@"ccPoly: %d\n", [conterclockwisePolygon index], nil]];
    [tis appendString:[NSString stringWithFormat:@"ccSide: %d\n\n", [counterclockwisePolygonSideObject index], nil]];
    [tis appendString:[NSString stringWithFormat:@"highestAdjacentFloor	: %d\n", highestAdjacentFloor, nil]];
    [tis appendString:[NSString stringWithFormat:@"lowestAdjacentCeiling	: %d\n", lowestAdjacentCeiling, nil]];
    
    [tis appendString:((flags & LELineSolid)		? @"LELineSolid		: YES\n" : @"LELineSolid\t\t: NO\n")];
    [tis appendString:((flags & LELineTransparent)		? @"TRANSPARENT_LINE		: YES\n" : @"TRANSPARENT_LINE\t\t\t: NO\n")];
    [tis appendString:((flags & LELineLandscape)		? @"LELineLandscape	: YES\n" : @"LELineLandscape	: NO\n")];
    [tis appendString:((flags & LELineElevation)		? @"LELineElevation	: YES\n" : @"LELineElevation\t: NO\n")];
    [tis appendString:((flags & LELineVariableElevation)	? @"VARIABLE_ELEVATION	: YES\n" : @"VARIABLE_ELEVATION	: NO\n")];
    [tis appendString:((flags & LELineVariableHasTransparentSide)	? @"TRANSPARENT_SIDE		: YES\n" : @"TRANSPARENT_SIDE\t\t: NO\n")];
    [tis appendString:@"\n"];
    
    if (clockwisePolygonSideObject != nil)
    {
        
        [tis appendString:@"\n cSide Type: "];
        
        switch ([clockwisePolygonSideObject type])
        {
            case LESideFull:
                [tis appendString:@"LESideFull"];
                break;
            case LESideHigh:
                [tis appendString:@"LESideHigh"];
                break;
            case LESideLow:
                [tis appendString:@"LESideLow"];
                break;
            case LESideComposite:
                [tis appendString:@"LESideComposite"];
                break;
            case LESideSplit:
                [tis appendString:@"LESideSplit"];
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
        
        switch ([counterclockwisePolygonSideObject type])
        {
            case LESideFull:
                [tis appendString:@"LESideFull"];
                break;
            case LESideHigh:
                [tis appendString:@"LESideHigh"];
                break;
            case LESideLow:
                [tis appendString:@"LESideLow"];
                break;
            case LESideComposite:
                [tis appendString:@"LESideComposite"];
                break;
            case LESideSplit:
                [tis appendString:@"LESideSplit"];
                break;
            default:
                [tis appendString:@"unkown"];
                break;
        }
        
        [tis appendString:@"\n"];
    }
    
    [tis appendString:@"\n"];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(@"Detailed Line Information…", @"Detailed Line Information…");
    alert.informativeText = tis;
    alert.alertStyle = NSAlertStyleInformational;
    [alert runModal];
}

 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********


 - (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
{
    NSInteger theNumber = [index indexOfObjectIdenticalTo:self];
    int tmpLong = 0;
    //int i = 0;
    
    if (theNumber != NSNotFound)
    {
        return theNumber;
    }
    
    NSInteger myPosition = [index count];
    
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
    tmpLong = (int)[myData length];
    saveIntToNSData(tmpLong, theData);
    [theData appendData:myData];
    [theData appendData:futureData];
    
    
    NSLog(@"Exporting Line: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    if ((int)[index indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: line %d was not at the end of the index... myPosition = %ld", [self index], (long)myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Line: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
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
    if (coder.allowsKeyedCoding) {
        [coder encodeObject:mapPoint1 forKey:@"mapPoint1"];
        [coder encodeObject:mapPoint2 forKey:@"mapPoint2"];
        
        [coder encodeInt:flags forKey:@"LineFlags"];
        
        [coder encodeInt:_Length forKey:@"length"];
        [coder encodeInt:highestAdjacentFloor forKey:@"highestAdjacentFloor"];
        [coder encodeInt:lowestAdjacentCeiling forKey:@"lowestAdjacentCeiling"];
        
        //encodeObject(coder, clockwisePolygonSideObject);
        [coder encodeObject:clockwisePolygonSideObject forKey:@"clockwisePolygonSideObject"];
        [coder encodeObject:counterclockwisePolygonSideObject forKey:@"counterclockwisePolygonSideObject"];
        //encodeObject(coder, counterclockwisePolygonSideObject);
        
        [coder encodeConditionalObject:clockwisePolygon forKey:@"clockwisePolygon"];
        [coder encodeConditionalObject:conterclockwisePolygon forKey:@"conterclockwisePolygon"];
        
        // Below is verion 2 additions
        [coder encodeBool:permanentNoSides forKey:@"permanentNoSides"];
        
        // Below is version 1 additions
        [coder encodeBool:permanentSolidLine forKey:@"permanentSolidLine"];
        [coder encodeBool:permanentLandscapeLine forKey:@"permanentLandscapeLine"];
        [coder encodeBool:permanentTransparentLine forKey:@"permanentTransparentLine"];
        [coder encodeBool:usePermanentSettings forKey:@"usePermanentSettings"];
    } else {
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
        
        if (/*!useIndexNumbersInstead*/ /* DISABLES CODE */ (YES)) {
            //encodeObject(coder, clockwisePolygonSideObject);
            [coder encodeObject:clockwisePolygonSideObject];
            [coder encodeObject:counterclockwisePolygonSideObject];
            //encodeObject(coder, counterclockwisePolygonSideObject);
            
            encodeConditionalObject(coder, clockwisePolygon);
            encodeConditionalObject(coder, conterclockwisePolygon);
        } else {
            LEMapDraw *theDrawView = [[[NSDocumentController
                                        sharedDocumentController]
                                        currentDocument]
                                        getMapDrawView];
            
            NSSet *thePolygonSelections = [theDrawView getSelectionsOfType:LEMapDrawSelectionPolygons];
            
            BOOL hasClock = [thePolygonSelections containsObject:clockwisePolygon];
            BOOL hasCClock = [thePolygonSelections containsObject:conterclockwisePolygon];
            
            [clockwisePolygonSideObject setEncodeIndexNumbersInstead:YES];
            [counterclockwisePolygonSideObject setEncodeIndexNumbersInstead:YES];
            
            if (hasClock) {
                NSLog(@"hasClock was true #%d", [self index]);
                encodeObj(coder, clockwisePolygonSideObject);
            } else {
                NSLog(@"hasClock was false, set to nil #%d", [self index]);
                encodeObj(coder, nil);
            }
            
            if (hasCClock) {
                NSLog(@"hasCClock was true #%d", [self index]);
                encodeObj(coder, counterclockwisePolygonSideObject);
            } else {
                NSLog(@"hasCClock was false, set to nil #%d", [self index]);
                encodeObj(coder, nil);
            }
        
            if (hasClock) {
                encodeObj(coder, clockwisePolygon);
            } else {
                encodeObj(coder, nil);
            }
            
            if (hasCClock) {
                encodeObj(coder, conterclockwisePolygon);
            } else {
                encodeObj(coder, nil);
            }
            
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
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        mapPoint1 = [coder decodeObjectOfClass:[LEMapPoint class] forKey:@"mapPoint1"];
        mapPoint2 = [coder decodeObjectOfClass:[LEMapPoint class] forKey:@"mapPoint2"];
        flags = [coder decodeIntForKey:@"LineFlags"];
        
        _Length = [coder decodeIntForKey:@"length"];
        highestAdjacentFloor = [coder decodeIntForKey:@"highestAdjacentFloor"];
        lowestAdjacentCeiling = [coder decodeIntForKey:@"lowestAdjacentCeiling"];
        
        clockwisePolygonSideObject = [coder decodeObjectOfClass:[LESide class] forKey:@"clockwisePolygonSideObject"];
        counterclockwisePolygonSideObject = [coder decodeObjectOfClass:[LESide class] forKey:@"counterclockwisePolygonSideObject"];
        
        
        clockwisePolygon = [coder decodeObjectOfClass:[LEPolygon class] forKey:@"clockwisePolygon"];
        conterclockwisePolygon = [coder decodeObjectOfClass:[LEPolygon class] forKey:@"conterclockwisePolygon"];
        
        permanentNoSides = [coder decodeBoolForKey:@"permanentNoSides"];
        
        permanentSolidLine = [coder decodeBoolForKey:@"permanentSolidLine"];
        permanentLandscapeLine = [coder decodeBoolForKey:@"permanentLandscapeLine"];
        permanentTransparentLine = [coder decodeBoolForKey:@"permanentTransparentLine"];
        usePermanentSettings = [coder decodeBoolForKey:@"usePermanentSettings"];
    } else {
        int versionNum = decodeNumInt(coder);
        
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
        
        switch (versionNum) {
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
                NSLog(@"clockwisePolygon was nil #%d", [self index]);
            else
                NSLog(@"clockwisePolygon was not nil #%d", [self index]);
            
            if (conterclockwisePolygon == nil)
                NSLog(@"conterclockwisePolygon was nil #%d", [self index]);
            else
                NSLog(@"conterclockwisePolygon was not nil #%d", [self index]);
        }*/
        
        //useIndexNumbersInstead = NO;
	}
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
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
            return GET_SIDE_FLAG(LELineLandscape);
            break;
        case 4:
            return GET_SIDE_FLAG(LELineElevation);
            break;
        case 5:
            return GET_SIDE_FLAG(LELineVariableElevation);
            break;
        case 6:
            return GET_SIDE_FLAG(LELineVariableHasTransparentSide);
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
        case LELineSolid:
        case 1: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(LELineSolid, v);
            break;
        case LELineTransparent:
        case 2: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(LELineTransparent, v);
            break;
        case LELineLandscape:
        case 3: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(LELineLandscape, v);
            break;
        case LELineElevation:
        case 4: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(LELineElevation, v);
            break;
        case LELineVariableElevation:
        case 5: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(LELineVariableElevation, v);
            break;
        case LELineVariableHasTransparentSide:
        case 6: // <-- is this such a good idea, could equal a flag???
            SET_LINE_FLAG(LELineVariableHasTransparentSide, v);
            break;
    }
    
    if (usePermanentSettings == YES)
    {
        if (permanentSolidLine == YES)
            flags |= LELineSolid;
        else
            flags &= ~LELineSolid;
        
        if (permanentLandscapeLine == YES)
            flags |= LELineLandscape;
        else
            flags &= ~LELineLandscape;
        
        if (permanentTransparentLine == YES)
            flags |= LELineTransparent;
        else
            flags &= ~LELineTransparent;
            
            
            // Should probably have caculateDies just return
            // before doing anything if this set…
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
 
-(short) index
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
    NSPoint theNewPoint = NSMakePoint((floor(point.x)), (floor(point.y)));
	
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

@synthesize pointIndex1=p1;
-(short)pointIndex1 { return  (mapPoint1 == nil) ? -1 : [mapPoint1 index]; }
@synthesize pointIndex2=p2;
-(short)pointIndex2 { return  (mapPoint2 == nil) ? -1 : [mapPoint2 index]; }
+ (NSSet<NSString *> *)keyPathsForValuesAffectingPointIndex1
{
	return [NSSet setWithObject:@"mapPoint1"];
}
+ (NSSet<NSString *> *)keyPathsForValuesAffectingPointIndex2
{
	return [NSSet setWithObject:@"mapPoint2"];
}
-(short) p1 { return [self pointIndex1]; }
-(short) p2 { return [self pointIndex2]; }
@synthesize mapPoint1;
@synthesize mapPoint2;
@synthesize flags;

- (BOOL)getPermanentSetting:(LELinePermanentSettings)settingToSet
{
    switch (settingToSet)
    {
        case LELinePermanentUse:
            return usePermanentSettings;
        case LELinePermanentSolid:
            return permanentSolidLine;
        case LELinePermanentTransparent:
            return permanentTransparentLine;
        case LELinePermanentLandscape:
            return permanentLandscapeLine;
        case LELinePermanentNoSides:
            return permanentNoSides;
        default:
        {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Unknown parmanent setting…";
            alert.informativeText = @"Unknown parmanent setting…";
            alert.alertStyle = NSAlertStyleInformational;
            [alert runModal];
        }
            return NO;
    }
}

@synthesize length=_Length;

// Angle of the line, 0-512 Marathon units, p1 to p2
@synthesize angle=_Angle;
// From p2 to p1
-(short) flippedAngle { return (([self angle]+256)%512); }

+(NSSet<NSString *> *)keyPathsForValuesAffectingFlippedAngle
{
	return [NSSet setWithObject:@"angle"];
}

// Degrees clockwise from vertical from p1 to p2
@synthesize azimuth=_Azimuth;
// From p2 to p1
-(short) flippedAzimuth { return (([self azimuth]+180)%360); }

+(NSSet<NSString *> *)keyPathsForValuesAffectingFlippedAzimuth
{
	return [NSSet setWithObject:@"azimuth"];
}

@synthesize highestAdjacentFloor;
@synthesize lowestAdjacentCeiling;

@dynamic clockwisePolygonSideIndex;
@dynamic counterclockwisePolygonSideIndex;

-(short) clockwisePolygonSideIndex { return (clockwisePolygonSideObject == nil) ? -1 : [clockwisePolygonSideObject index]; }
-(short) counterclockwisePolygonSideIndex { return (counterclockwisePolygonSideObject == nil) ? -1 : [counterclockwisePolygonSideObject index]; }

@synthesize clockwisePolygonSideObject;
@synthesize counterclockwisePolygonSideObject;
@dynamic clockwisePolygonOwner;
@dynamic conterclockwisePolygonOwner;
@dynamic clockwisePolygonIndex;
@dynamic conterclockwisePolygonIndex;

-(short) clockwisePolygonOwner { return (clockwisePolygon == nil) ? -1 : [clockwisePolygon index]; }
-(short) conterclockwisePolygonOwner { return (conterclockwisePolygon == nil) ? -1 : [conterclockwisePolygon index]; }
-(short) clockwisePolygonIndex { return (clockwisePolygon == nil) ? -1 : [clockwisePolygon index]; }
-(short) conterclockwisePolygonIndex { return (conterclockwisePolygon == nil) ? -1 : [conterclockwisePolygon index]; }

@synthesize clockwisePolygonObject=clockwisePolygon;
@synthesize conterclockwisePolygonObject=conterclockwisePolygon;

// ********* Set Accsessor Methods ********* 
 #pragma mark -
#pragma mark ********* Set Accsessor Methods *********
-(void) setP1:(short)s { [self setPointIndex1:s]; }
-(void) setP2:(short)s { [self setPointIndex2:s]; }

-(void) setPointIndex1:(short)s
{
    //p1 = s;
    if (s == -1)
        mapPoint1 = nil;
    else if (everythingLoadedST)
        mapPoint1 = [theMapPointsST objectAtIndex:p1];

    [self recalc];
}

-(void) setPointIndex2:(short)s
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

-(void)setFlags:(LELineFlags)v
{
    flags = v;
    
    if (usePermanentSettings == YES)
    {
        if (permanentSolidLine == YES)
            flags |= LELineSolid;
        else
            flags &= ~LELineSolid;
        
        if (permanentLandscapeLine == YES)
            flags |= LELineLandscape;
        else
            flags &= ~LELineLandscape;
        
        if (permanentTransparentLine == YES)
            flags |= LELineTransparent;
        else
            flags &= ~LELineTransparent;
    }
}

- (void)setPermanentSetting:(LELinePermanentSettings)settingToSet to:(BOOL)value
{
    switch (settingToSet)
    {
        case LELinePermanentUse:
            usePermanentSettings = value;
            break;
        case LELinePermanentSolid:
            permanentSolidLine = value;
            break;
        case LELinePermanentTransparent:
            permanentTransparentLine = value;
            break;
        case LELinePermanentLandscape:
            permanentLandscapeLine = value;
            break;
        case LELinePermanentNoSides:
            permanentNoSides = value;
            break;
        default:
        {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Unknown parmanent setting…";
            alert.informativeText = @"Unknown parmanent setting…";
            alert.alertStyle = NSAlertStyleCritical;
            [alert runModal];
        }
            break;
    }
}


// Mabye make these pointers to the polygons themselves???
//-(void) setHighestAdjacentFloor:(short)s { highestAdjacentFloor = s; }
//-(void) setLowestAdjacentCeiling:(short)s { lowestAdjacentCeiling = s; }





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
    NSInteger indexOfLineFound;
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
    

    if ([self clockwisePolygonOwner] == -1 || [self conterclockwisePolygonOwner] == -1)
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
    
    tempLinePoint2 = [currentLine mapPoint2];
    tempLinePoint1 = [currentLine mapPoint1];
    
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
        NSInteger smallestLineIndex = -1, nextMainPointIndex = -1;
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
                
                if ([thisMapLine clockwisePolygonOwner] != -1 && [thisMapLine conterclockwisePolygonOwner] != -1)
                {
                    // Might want to make sure of this in finnal lines instead, etc.???
                    NSLog(@"Line# %d already has two polygons attached to it, can't make a third polygon from it.", [thisMapLine index]);
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
        
						previousX = [currentLineSecondaryPoint x] - [currentLineMainPoint x];
						previousY = [currentLineSecondaryPoint y] - [currentLineMainPoint y];
						thisX = [theCurPoint x] - [currentLineMainPoint x];
						thisY = [theCurPoint y] - [currentLineMainPoint y];
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
                        theta = theta * 180.0 / M_PI;
                        alpha = asin(alpha);
                        alpha = alpha * 180.0 / M_PI;
                        tango = atan(tango);
                        tango = tango * 180.0 / M_PI;
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
                        }// End if ( theta <= 180.0 && theta < smallestAngle && [theCurPoint x] >= [firstPoint x])
    
                    } // End if (theCurPoint1 == firstPoint)
                } // End if (currentLine != thisMapLine)
            } // End while (currentLine == [numer nextObject])
            
            //We have found the next line to follow...
            NSLog(@"FINNAL Lowest Line Index: %ld  With Angle Of: %g", (long)smallestLineIndex, smallestAngle);
            
            if (smallestLineIndex < 0 || smallestLine == nil) // Proably -1, means it did not find a line that passed all the tests...
            {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
                alert.informativeText = NSLocalizedString(@"One of the lines was not concave reltive to the rest of the lines…", @"One of the lines was not concave reltive to the rest of the lines…");
                alert.alertStyle = NSAlertStyleCritical;
                [alert runModal];
                return nil;
            }
            
            if (lastLineToTest) {
                // Test to see and confirm that the line it choose is the same
                // as the first line that was found... 
                //NSLog(@"Second Phase Almost Complete...");
                if (smallestLine != [theNewPolyLines objectAtIndex:0])
                {
                    NSAlert *alert = [[NSAlert alloc] init];
                    alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
                    alert.informativeText = NSLocalizedString(@"When I reached the finnal line (going clockwise), the line with the smallest angle was not the orginal line!", @"When I reached the finnal line (going clockwise), the line with the smallest angle was not the orginal line!");
                    alert.alertStyle = NSAlertStyleCritical;
                    [alert runModal];
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
                        SEND_ERROR_MSG(NSLocalizedString(@"More then 8 vertices when trying to fill polygon!", @"More then 8 vertices when trying to fill polygon!"));
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
                        SEND_ERROR_MSG(NSLocalizedString(@"More then 8 vertices when trying to fill polygon!", @"More then 8 vertices when trying to fill polygon!"));
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
    
    switch ([theNewPolyVectors count]) {
        case 8:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:7] toIndex:7];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:7] toIndex:7];
        case 7:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:6] toIndex:6];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:6] toIndex:6];
        case 6:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:5] toIndex:5];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:5] toIndex:5];
        case 5:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:4] toIndex:4];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:4] toIndex:4];
        case 4:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:3] toIndex:3];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:3] toIndex:3];
        case 3:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:2] toIndex:2];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:2] toIndex:2];
        case 2:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:1] toIndex:1];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:1] toIndex:1];
        case 1:
            [theNewPolygon setVertexWithObject:[theNewPolyVectors objectAtIndex:0] toIndex:0];
            [theNewPolygon setLinesObject:[theNewPolyLines objectAtIndex:0] toIndex:0];
            break;
        case 0:
            NSLog(@"getPolyFromMe vertex count durring poly acuire was zero???");
        default:
            NSLog(@"Should of never gotten here, something is/went HORABLY wrong while polygon filling, map data in memory could be mangled badly!!!");
            // ??? should of never gotten here, something is HORABLY wrong!!! :(
            SEND_ERROR_MSG(NSLocalizedString(@"Somting is very wrong with the polygon line following, in LELine getPolyFromMe", @"Somting is very wrong with the polygon line following, in LELine getPolyFromMe"));
            return nil;
    }
    
    
    //NSLog(@"Returning The Polygon...");
    
    return theNewPolygon;
    
    // Add the new polygon to the level...
    // Next step would be to tell the level object to add the polygon...
    
} // End -(BOOL)usePaintTool:(NSPoint)mouseLoc

- (BOOL)isThereAClockWiseLineAlpha:(LEMapPoint *)alphaPoint beta:(LEMapPoint *)betaPoint theLine:(LELine *)currentLine
{
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
    for (LELine *thisMapLine in theConnectedLines)
    {
        double previousX, previousY, thisX, thisY;
        double prevX, prevY, theX, theY;
        double slope, theXfromSlop;
        LEMapPoint *theCurPoint1 = [theMapPointsST objectAtIndex:[thisMapLine pointIndex1]];
        LEMapPoint *theCurPoint2 = [theMapPointsST objectAtIndex:[thisMapLine pointIndex2]];
        LEMapPoint *theCurPoint;
        
        if (theCurPoint1 == alphaPoint) {
            theCurPoint = theCurPoint2;
        } else {
            theCurPoint = theCurPoint1;
        }
        
        //NSLog(@"Analyzing line: %d", [theLines indexOfObjectIdenticalTo:thisMapLine]);
        
        if ([thisMapLine clockwisePolygonOwner] != -1 && [thisMapLine conterclockwisePolygonOwner] != -1)
        {
            // Might want to make sure of this in finnal lines instead, etc.???
            NSLog(@"   IFIND Line# %d already has two polygons attached to it, can't make a third polygon from it, still checking...", [thisMapLine index]);
            //return NO;
            continue;
        }
        
        if (thisMapLine == currentLine)
            continue;
        
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
    
        //NSLog(@"   IFIND For Line %d  theX: %g theY: %g", [thisMapLine index], theX, theY);
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
    if (mapPoint1 == nil || mapPoint2 == nil) {
        //_Length = 0;
        //_Angle = 0;
        //_Azimuth = 0;
        return;
    }
    
    double a = 0, t = 0;
    double m = 0;
    
    short x1 = [[self mapPoint1] x32];
    short y1 = [[self mapPoint1] y32];
    short x2 = [[self mapPoint2] x32];
    short y2 = [[self mapPoint2] y32];

    short dX = x1-x2;
    short dY = y1-y2;

    // Calculate the length

    [self setLength:(sqrt(dX*dX + dY*dY))];

    // Calculate the azimuth - in integer degrees clockwise from vertical
    // As if we were a vector from p1 to p2

    // this is radians
    a = atan(((double)dY) / ((double)dX));

    // now it's degrees
    a *= (180.0 / M_PI);
    
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
            //NSLog(@"Oops! This is a zero length line, which should have been caught elsewhere!");
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
    if(m >= 360.0) {
		m -= 360.0; // <-- it's like % but i can guarantee it'll never go over 720
	}				// so no need to worry about not being enough
	
    // In 512s
    m *= (512.0/360.0);

    [self setAngle:(short)m];
}

@end
