//
//  LEMapPoint.m
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

#import "LEMapPoint.h"
#import "LEMapStuffParent.h"
#import "LELine.h"
#import "LEMap.h"
#import "LELevelData.h"
#import "LEExtras.h"

#import "PhData.h"

@implementation LEMapPoint

- (NSString *)description
{
    return [NSString stringWithFormat:@"Point Index: %d    X/Y:(%d, %d)   AdjX/AdjY:(%d, %d)",[self index], x, y, x32, y32, nil];
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
    
    NSInteger myPosition = [index count];
    
    [index addObject:self];
    
    NSMutableData *myData = [[NSMutableData alloc] init];
    NSMutableData *futureData = [[NSMutableData alloc] init];
    
    ExportShort(x);
    ExportShort(y);
    
    ExportShort(x32);
    ExportShort(y32);
    
    
    // *** *** **** Splice Data Together *** *** ***
    tmpLong = [myData length];
    [theData appendBytes:&tmpLong length:4];
    [theData appendData:myData];
    [theData appendData:futureData];
    

    
    NSLog(@"Exporting Point: %d  -- Position: %lu --- myData: %lu", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], (unsigned long)[myData length]);
    
    [myData release];
    [futureData release];
    
    if ((int)[index indexOfObjectIdenticalTo:self] != myPosition)
    {
        NSLog(@"BIG EXPORT ERROR: point %d was not at the end of the index... myPosition = %ld", [self index], (long)myPosition);
        //return -1;
        //return [index indexOfObjectIdenticalTo:self]
    }
    
    return [index indexOfObjectIdenticalTo:self];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    NSLog(@"Importing Point: %d  -- Position: %lu  --- Length: %ld", [self index], (unsigned long)[index indexOfObjectIdenticalTo:self], [myData currentPosition]);
    
    ImportShort(x);
    ImportShort(y);
    
    ImportShort(x32);
    ImportShort(y32);
}


- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		[coder encodeObject:lines forKey:@"lines"];
		[coder encodeInt:x forKey:@"x"];
		[coder encodeInt:y forKey:@"y"];
	} else {
		encodeNumInt(coder, 1);
		
		encodeShort(coder, x);
		encodeShort(coder, y);
		
		encodeObj(coder, lines);
	}
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		x = [coder decodeIntForKey:@"x"];
		y = [coder decodeIntForKey:@"y"];
		
		x32 = x / 16;
		y32 = y / 16;
		
		lines = [[coder decodeObjectForKey:@"lines"] retain];
	} else {
		versionNum = decodeNumInt(coder);
		
		x = decodeShort(coder);
		y = decodeShort(coder);
		x32 = x / 16;
		y32 = y / 16;
		
		if (versionNum > 0) {
			lines = decodeObjRetain(coder);
		} else {
			lines = [[NSMutableSet alloc] init];
		}
		
		//if (useIndexNumbersInstead)
		//    [theLELevelDataST addPoint:self];
		
		//useIndexNumbersInstead = NO;
	}
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    LEMapPoint *copy = [[LEMapPoint allocWithZone:zone] initX:x Y:y];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

// **************************  delloc/init Methods  *************************
#pragma mark -
#pragma mark ********* dealloc/init Methods *********

-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    x = 0;
    y = 0;
    x32 = 0;
    y32 = 0;
    lines = [[NSMutableSet alloc] init];
    
    return self;
}

-(id)initX32:(short)theX32 Y32:(short)theY32
{
    self = [super init];
    if (self)
    {
        x = theX32 * 16;
        y = theY32 * 16;
        x32 = theX32;
        y32 = theY32;
        //cleanUp = NO;
        lines = [[NSMutableSet alloc] init];
    }
    return self;
}

-(id)initX:(short)theX Y:(short)theY
{
    self = [super init];
    if (self)
    {
        x = theX;
        y = theY;
        x32 = theX / 16;
        y32 = theY / 16;
        //cleanUp = NO;
        lines = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [lines release];
    [super dealloc];
}

// **************************  Regular Methods  *************************
#pragma mark -
#pragma mark ********* Regular Methods  *********
-(short) index { return [theMapPointsST indexOfObjectIdenticalTo:self]; }

-(NSRect)drawingBounds { return [self as32Rect]; }

-(void)setX:(short)theX Y:(short)theY
{
	[self willChangeValueForKey:@"x"];
	[self willChangeValueForKey:@"y"];
    x = theX; x32 = theX / 16;
    y = theY; y32 = theY / 16;
	[self didChangeValueForKey:@"x"];
	[self didChangeValueForKey:@"y"];
    [self tellLinesAttachedToMeToRecalc];
}

-(void)setX:(short)theX
{
    //[undo setX:x];
    x = theX; x32 = theX / 16;
    [self tellLinesAttachedToMeToRecalc];
}
-(void)setY:(short)theY
{
    //[undo setY:y];
    y = theY; y32 = theY / 16;
    [self tellLinesAttachedToMeToRecalc];
}

-(void)set32X:(short)theX
{
	self.x32 = theX;
}
-(void)set32Y:(short)theY
{
	self.y32 = theY;
}

-(void)setX32:(short)theX
{
    //[undo setX32:x32];
    x = theX * 16; x32 = theX;
    [self tellLinesAttachedToMeToRecalc];
}
-(void)setY32:(short)theY
{
    //[undo setY32:y32];
    y = theY * 16; y32 = theY;
    [self tellLinesAttachedToMeToRecalc];
}

-(void)moveBy32Point:(NSPoint)theOffset
{
    //[self setX32:(x32 + theOffset.x)];
    //[self setY32:(y32 + theOffset.y)];
	
	float fx = (theOffset.x * ((float)16));
	float fy = (theOffset.y * ((float)16));
	x += (short)(fx + .5);
	y += (short)(fy + .5);
	x32 = x / 16;
	y32 = y / 16;
}

-(void)moveBy32Point:(NSPoint)theOffset pointsAlreadyMoved:(NSMutableSet *)pointsAlreadyMoved
{
    if (![pointsAlreadyMoved containsObject:self])
    {
        [self setX32:(x32 + theOffset.x)];
        [self setY32:(y32 + theOffset.y)];
        [pointsAlreadyMoved addObject:self];
    }
}

-(NSPoint)asPoint { return NSMakePoint(x, y); }
+ (NSSet<NSString *> *)keyPathsForValuesAffectingAsPoint
{
	return [NSSet setWithObjects:@"x", @"y", nil];
}
-(NSPoint)as32Point { return NSMakePoint(x32, y32); }
+ (NSSet<NSString *> *)keyPathsForValuesAffectingAs32Point
{
	return [NSSet setWithObjects:@"x32", @"y32", nil];
}
-(NSRect)as32Rect { return NSMakeRect(x32 - 3, y32 - 3, 6, 6); }
+ (NSSet<NSString *> *)keyPathsForValuesAffectingAs32Rect
{
	return [NSSet setWithObjects:@"x32", @"y32", nil];
}

-(NSSet *)getLinesAttachedToMe
{
    return lines;
}

-(NSArray *)linesAttachedToMeAsArray
{
    return [lines allObjects];
}

-(void)scanAndUpdateLines
{
   /// int myIndex = [theMapPointsST indexOfObjectIdenticalTo:self];
    //NSMutableSet *theLines;
    NSEnumerator *numer;
    LELine *thisMapLine;
    
    [lines removeAllObjects];
    
    //theLines = [[NSMutableSet alloc] initWithCapacity:3];
    numer = [theMapLinesST reverseObjectEnumerator];
    while (thisMapLine = [numer nextObject])
    {
        if ([thisMapLine uses:self])
            [lines addObject:thisMapLine];
    }
}

-(void)lineConnectedToMe:(LELine *)obj
{
    // sets can't have duplicate objects,
    // so no need to check...
    [lines addObject:obj];
}

-(void)lineDisconnectedFromMe:(LELine *)obj
{
    [lines removeObject:obj];
}

-(void)tellLinesAttachedToMeToRecalc
{   
                        // jdo change: An array is not nessary, a set will do :)
    NSEnumerator *numer = [[self getLinesAttachedToMe] objectEnumerator];
    LELine *curLine;
    while((curLine = [numer nextObject]))
    {
	[curLine recalc];
    }
}

-(short)xgl { return x/128; }
+ (NSSet<NSString *> *)keyPathsForValuesAffectingXgl
{
	return [NSSet setWithObject:@"x"];
}
@dynamic xgl;
-(short)ygl { return y/128; }
+ (NSSet<NSString *> *)keyPathsForValuesAffectingYgl
{
	return [NSSet setWithObject:@"y"];
}
@dynamic ygl;
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
-(short)getX { return x; }
-(short)getY { return y; }

// These are methods that we probably wouldn't bother with if we weren't scriptable.

- (NSScriptObjectSpecifier *)objectSpecifier
{
    //NSArray *graphics = [[self document] graphics];
    int index = [self index];
    
    if (index != -1 && [theLELevelDataST levelDocument] != nil)
    {
        NSScriptObjectSpecifier *containerRef = [[theLELevelDataST levelDocument] objectSpecifier];
        
        return [[[NSIndexSpecifier allocWithZone:[self zone]]
                        initWithContainerClassDescription:[containerRef keyClassDescription]
                        containerSpecifier:containerRef key:@"points" index:index] autorelease];
    }
    else //[[[NSPropertySpecifier allocWithZone:[self zone]] initWithContainerClassDescription: nil containerSpecifier:spec key:@"foregroundColor"] autorelease];
        return nil;
}


// **************************  High School Geometry Functions ;)  *************************
#pragma mark -
#pragma mark ********* High School Geometry Functions ;) *********


-(LEMapPoint *)nearestMapPointInRange:(int)maxDist
{
    LEMapPoint *curPoint;

    id theMapPoints = [theLELevelDataST getThePoints];
    NSEnumerator *numer;
    numer = [theMapPoints reverseObjectEnumerator];

    int bestDist = 50000;
    LEMapPoint *bestPoint = nil;
    
    int theDist = 0;
    
    // The point is not allocated here, so there is no need to
    // release the point latter on.  If we wanted to keep this point
    // for a while, we would send a retain message to it, to make sure
    // it does not get released before we would have been done with it,
    // and release it our selves latter one.  BUT we only need this point temprarly,
    // so there is no need to do a retain and release...
    
    while (curPoint = (LEMapPoint *)[numer nextObject])
    {
	theDist = [curPoint distanceToPoint:self];

	if(theDist > maxDist)
	{
	    continue;
	}

	if (theDist < bestDist)
	{
	    bestDist = theDist;
	    bestPoint = curPoint;
	}
    }

    if(bestPoint == nil)	// found none
    {
	return nil;
    }
    
    
    // No need for an autorelease, see comment eariler in this function for details...
    return bestPoint;
}


// The point returned here IS NOT PART OF THE LEVEL!
// Before using it you should:
// -Check if there's already a point at this grid coord you can use (see also nearestMapPoint...)
// -Add it to the level object:
//     [currentLevel addObjects: (the point I return) ];
//     [rectPoints addObject: (the point I return) ];
// -Possibly other stuff?
-(LEMapPoint *)nearestGridPointInRange:(int)maxDist
{
    int pci = 0;
    
    LEMapPoint **pointCache = malloc(500 * sizeof(LEMapPoint *));
    assert(pointCache);
    
    int pointCacheMax = 500;
    int gridCordY;
    int gridCordX;
    float gridFactor = [theLELevelDataST settingAsFloat:PhGridFactor];
    int numberOfGridLines = (int)((float)64 * gridFactor);
    int minXCord = [self x32] - maxDist;
    int maxXCord = [self x32] + maxDist;
    int maxYCord = [self y32] + maxDist;
    int minYCord = [self y32] - maxDist;

    for  (gridCordY = minYCord; gridCordY <= maxYCord ; gridCordY++)
    {
	if (gridCordY % numberOfGridLines == 0)
	{
	    for  (gridCordX = minXCord; gridCordX <= maxXCord; gridCordX++)
	    {
		if (gridCordX % numberOfGridLines == 0)
		{
		    if (pointCacheMax > pci)
		    {
			//NSLog(@"Grid Pint Found On: (%d, %d)", gridCordX, gridCordY);
                        
                        // This has been explictily allocated, so we need to release it latter...
			pointCache[pci] = [[LEMapPoint alloc] initX32:gridCordX Y32:gridCordY];
			pci++;
		    }
		    else
			break;
		}
	    }
	}
    }

    if (pci == 0) // No points in range...
    {
        free(pointCache);
	return nil;
    }
    else if (pci == 1) // Only one point in range...
    {
        LEMapPoint *thePoint = pointCache[0];
        free(pointCache);
        
        // The reason for this autorelease is explained below...
	return [thePoint autorelease];
    }
    else // More then one point in range...
    {
        int bestDist = 50000;
	int i;
	LEMapPoint *bestPoint = nil;
        
        int theDist = 0;
        
	for (i = 0; i < pci; i++)
	{
	    theDist = [self distanceToPoint:(pointCache[i])];

	    if(theDist > maxDist)
	    {
		continue;
	    }

	    if (theDist < bestDist)
	    {
                // If bestPoint is not nil, this will do nothing,
                // but if it is not nil, it will release
                // the previous best point...
                [bestPoint release];
                
		bestDist = theDist;
		bestPoint = pointCache[i];
                
                // This should not be nessary, but just in case, becuase
                // this object could be potentialy released latter
                // and I hate leaving pointers that could point to
                // non-existent object, because a message to one (function call)
                // will crash the program...
                pointCache[i] = nil;
	    }
            else
            {
                // This point is for sure not a best point, so release it...
                [pointCache[i] release];
                
                // And like above, the only diffrence here is that I know
                // for sure that this point no longer exsists, so I even more
                // want to set it to nil :)
                pointCache[i] = nil;
            }
	}
        
        // All points except for one should now be released,
        // and all pointers in the point Cache should be nil...
        free(pointCache);
        
	if(bestPoint == nil)	// found none -- can't happen?
	{
	    return nil;
	}
        
        // Auto Release is the best thing to do here,
        // because whoever gets this point did not explictiy
        // allocate the point object, so they should not own it
        // automaticaly.  If they want to keep it, they should
        // send a retain message to the point.  If they don't send a
        // retain message, this autorelease will get rid of the object
        // at the end of this loop of the run loop.
        
        // We no longer need to own the point, but sense we are giving it to someone
        // autorelease it to delay release until next event loop...
	return [bestPoint autorelease];
    }
}


-(short)distanceToPoint:(LEMapPoint *)target;
{
    return [self distanceToNSPoint:[target as32Point]];
}


-(short)distanceToNSPoint:(NSPoint)target;
{
    int tX, tY, dX, dY;
    
    tX = target.x;
    tY = target.y;

    dX = [self x32] - tX;
    dY = [self y32] - tY;

    // slight optimization - obvious cases for vertical/horizontal
    if(dX == 0) { return abs(dY); }
    if(dY == 0) { return abs(dX); }

    return sqrt((dY * dY) + (dX * dX));
}


@end
