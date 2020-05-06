//
//  PhAnnotationNote.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Jul 10 2001.
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

#import "PhAnnotationNote.h"
#import "LEExtras.h"
#import "PhNoteGroup.h"
#import "LEPolygon.h"

@implementation PhAnnotationNote

- (NSString *)description
{
    NSString *polyField = @"[ N/A ]";
    
    if (polygon_object != nil)
        polyField = [polygon_object getPhName];
        
    NSPoint regP = [self getLocation];
    NSPoint adjP = [self getLocationAdjusted];
    
    return [NSString stringWithFormat:@"Note Index: %d   In Polygon: %@   X/Y:(%d, %d)   AdjX/AdjY:(%d, %d)", [self getIndex], polyField, (int)regP.x, (int)regP.y, (int)adjP.x, (int)adjP.y, nil];
}

- (BOOL)LEhitTest:(NSPoint)point
{
    // NSMakeRect(((int)location.x), ((int)location.y), 9, 9)
    return NSMouseInRect(point, [self drawingBounds], YES);
}

//PhStandardAttributesForNotes
//sizeWithAttributes
/*
-(NSRect)drawingBounds 
{
    static NSDictionary *att = 
                    [NSDictionary dictionaryWithObjectsAndKeys:
                        
                        [NSColor greenColor],
                        NSForegroundColorAttributeName,
                        
                        // It's the font and the size that count,
                        // not the color for this...
                        [NSFont fontWithName:@"Courier" size:16.0],
                        NSFontAttributeName, nil];
    
    NSSize size = [text sizeWithAttributes:att];
    return NSMakeRect(((int)location.x), (((int)location.y) - ((int)size.height)), ((int)size.width), ((int)size.height));
}
*/
-(void)moveBy32Point:(NSPoint)theOffset
{
    //theOffset.y += 16;
    NSPoint adjLoc = location; // [self getLocationAdjusted];
    //NSLog(@"Point Offset: (%g, %g)", theOffset.x, theOffset.y);
    
    [self setX32:((adjLoc.x / 16) + theOffset.x)];
    [self setY32:((adjLoc.y / 16) + theOffset.y)];
    [self updateBounds];
}

- (void)setX32:(int)v { v *= 16; location.x = v; }
- (void)setY32:(int)v { v *= 16; location.y = v; }
- (void)set32X:(int)v { v *= 16; location.x = v; }
- (void)set32Y:(int)v { v *= 16; location.y = v; }

 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********
- (void) encodeWithCoder:(NSCoder *)coder
{
    int tempInt;
    [super encodeWithCoder:coder];
    encodeNumInt(coder, 1);
    
    encodeShort(coder, type);
    
    tempInt = location.x;
    encodeInt(coder, tempInt);
    tempInt = location.y;
    encodeInt(coder, tempInt);
    
    encodeObj(coder, polygon_object);
    encodeObj(coder, text);
    
    encodeObj(coder, group);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    type = decodeShort(coder);
    
    location.x = decodeInt(coder);
    location.y = decodeInt(coder);
    
    polygon_object = decodeObj(coder);
    text = decodeObjRetain(coder);
    
    if (versionNum > 0)
    {
        group = decodeObjRetain(coder);
    }
    else
    {
        group = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhAnnotationNote *copy = [[PhAnnotationNote allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

- (void)dealloc
{
    [text release];
    [group release];
    
    [super dealloc];
}

// *****************   Set Accsessors   *****************

-(void)setGroup:(PhNoteGroup *)grp
{
    if (group != nil && grp != group)
    {
        [group removeObject:self];
    }
    
    [group release];
    group = [grp retain];
}

-(void)setType:(short)v { type = v; }

-(void)setLocation:(NSPoint)v { location = v; [self updateBounds]; }

-(void)setLocationX:(int)v { location.x = v; [self updateBounds]; }
-(void)setLocationY:(int)v { location.y = v; [self updateBounds]; }

-(void)setPolygonIndex:(short)v
{
    if (v > -1)
        polygon_object = [theMapPolysST objectAtIndex:v];
    else
        polygon_object = nil;
    
} // *** NEED TO FIX THIS UP FOR NEW OBJECT MODEL ***, Fixed, I think...

-(void)setPolygon_object:(LEPolygon *)v { polygon_object = v; }
-(void)setPolygon:(LEPolygon *)v { polygon_object = v; }

@synthesize text;

-(void)setText:(NSString *)v
{
    [text release];
    text = [v copy];
    [self updateBounds];
}

-(void)updateBounds
{
    NSPoint adjPoint = location;//[self getLocationAdjusted];
    
    adjPoint.x /= 16;
    adjPoint.y /= 16;
    
    NSMouseInRect(adjPoint, [self drawingBounds], YES);
    
    size = [text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                    
                                        [NSColor greenColor],
                                        NSForegroundColorAttributeName,
                    
                                        [NSFont fontWithName:@"Courier" size:16.0],
                                        NSFontAttributeName, nil]];
    
    bounds =  NSMakeRect(((int)adjPoint.x), (((int)adjPoint.y) - ((int)size.height)), ((int)size.width), ((int)size.height));
    
    //bounds.origin = location;
    //bounds.size = size;
}

-(NSRect) drawingBounds
{
    //NSPoint adjPoint = [self getLocationAdjusted];
    //bounds.origin = location;
    //bounds.size = size;
    return bounds;
}

// *****************   Get Accsessors   *****************

-(PhNoteGroup *)group
{
    return group;
}

-(PhNoteGroup *)getGroup
{
    return group;
}

-(short)type { return type; }

-(NSPoint)getLocation { return location; }
-(NSPoint)as32Point
{
    return [self getLocationAdjusted];
}

-(NSPoint)getLocationAdjusted
{
    NSPoint locationAdj;
    
    //NSLog(@"size: %g", bounds.size.height);
    
    locationAdj.x = location.x / 16;
    locationAdj.y = (location.y / 16) - bounds.size.height;
    
    return locationAdj;
}

-(short)polygonIndex { return (polygon_object == nil) ? -1 : [polygon_object getIndex]; }
-(LEPolygon *)getPolygon_object { return polygon_object; }
- (LEPolygon *)polygon { return polygon_object; }

 // **************************  Overriden Standard Methods  *************************
 
-(short)getIndex { return [theAnnotationsST indexOfObjectIdenticalTo:self]; }
 
-(void)update
{
    
}

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice { everythingLoadedST = theChoice; }

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        //[self setP1:-1];
        //[self setP2:-1];
        polygon_object = nil;
        text = nil;
        type = 0;
        location.x = 0;
        location.y = 0;
        polygon_index = 0;
        
        group = nil;
        
        bounds = NSZeroRect;
    }
    return self;
}

-(id)initWithAdjPoint:(NSPoint)point
{
    self = [super init];
    if (self != nil)
    {
        //[self setP1:-1];
        //[self setP2:-1];
        polygon_object = nil;
        text = nil;
        type = 0;
        location.x = point.x*16;
        location.y = point.y*16;
        polygon_index = 0;
        
        group = nil;
        
        bounds = NSZeroRect;
    }
    return self;
}

@end
