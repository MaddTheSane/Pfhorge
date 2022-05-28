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
        polyField = [polygon_object phName];
        
    NSPoint regP = [self location];
    NSPoint adjP = [self locationAdjusted];
    
    return [NSString stringWithFormat:@"Note Index: %d   In Polygon: %@   X/Y:(%d, %d)   AdjX/AdjY:(%d, %d)", [self index], polyField, (int)regP.x, (int)regP.y, (int)adjP.x, (int)adjP.y, nil];
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
    NSPoint adjLoc = location; // [self locationAdjusted];
    //NSLog(@"Point Offset: (%g, %g)", theOffset.x, theOffset.y);
    
    [self setX32:((adjLoc.x / 16) + theOffset.x)];
    [self setY32:((adjLoc.y / 16) + theOffset.y)];
    [self updateBounds];
}

- (int)x32 { return location.x / 16; }
- (int)y32 { return location.y / 16; }
- (void)setX32:(int)v { v *= 16; location.x = v; }
- (void)setY32:(int)v { v *= 16; location.y = v; }

 // **************************  Coding/Copy Protocal Methods  *************************
#pragma mark -
#pragma mark Coding/Copy Protocal Methods
- (void) encodeWithCoder:(NSCoder *)coder
{
    int tempInt;
    [super encodeWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        [coder encodeInt:type forKey:@"type"];
        
        [coder encodePoint:location forKey:@"location"];
        
        [coder encodeObject:polygon_object forKey:@"polygon_object"];
        [coder encodeObject:text forKey:@"text"];
        
        [coder encodeObject:group forKey:@"group"];
    } else {
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
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (coder.allowsKeyedCoding) {
        type = [coder decodeIntForKey:@"type"];
        
        location = [coder decodePointForKey:@"location"];
        
        polygon_object = [coder decodeObjectOfClass:[LEPolygon class] forKey:@"polygon_object"];
        text = [coder decodeObjectOfClass:[NSString class] forKey:@"text"];
        
        group = [coder decodeObjectOfClass:[PhNoteGroup class] forKey:@"group"];
    } else {
        int versionNum = decodeNumInt(coder);
        
        type = decodeShort(coder);
        
        location.x = decodeInt(coder);
        location.y = decodeInt(coder);
        
        polygon_object = decodeObj(coder);
        text = decodeObjRetain(coder);
        
        if (versionNum > 0) {
            group = decodeObjRetain(coder);
        } else {
            group = nil;
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
    PhAnnotationNote *copy = [[PhAnnotationNote allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

- (void)dealloc
{
}

// *****************   Set Accsessors   *****************

@synthesize group;
-(void)setGroup:(PhNoteGroup *)grp
{
    if (group != nil && grp != group)
    {
        [group removeObject:self];
    }
    
    group = grp;
}

@synthesize type;
@synthesize location;

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

@synthesize polygonObject=polygon_object;
-(void)setPolygon:(LEPolygon *)v { polygon_object = v; }

@synthesize text;

-(void)setText:(NSString *)v
{
    text = [v copy];
    [self updateBounds];
}

-(void)updateBounds
{
    NSPoint adjPoint = location;//[self locationAdjusted];
    
    adjPoint.x /= 16;
    adjPoint.y /= 16;
    
    NSMouseInRect(adjPoint, [self drawingBounds], YES);
    
    size = [text sizeWithAttributes:@{NSForegroundColorAttributeName: [NSColor greenColor],
                                      NSFontAttributeName: [NSFont fontWithName:@"Courier" size:16.0]
    }];
    
    bounds =  NSMakeRect(((int)adjPoint.x), (((int)adjPoint.y) - ((int)size.height)), ((int)size.width), ((int)size.height));
    
    //bounds.origin = location;
    //bounds.size = size;
}

-(NSRect) drawingBounds
{
    //NSPoint adjPoint = [self locationAdjusted];
    //bounds.origin = location;
    //bounds.size = size;
    return bounds;
}

// *****************   Get Accsessors   *****************

-(PhNoteGroup *)getGroup
{
    return self.group;
}

-(NSPoint)as32Point
{
    return [self locationAdjusted];
}

-(NSPoint)locationAdjusted
{
    NSPoint locationAdj;
    
    //NSLog(@"size: %g", bounds.size.height);
    
    locationAdj.x = location.x / 16;
    locationAdj.y = (location.y / 16) - bounds.size.height;
    
    return locationAdj;
}

-(short)polygonIndex { return (polygon_object == nil) ? -1 : [polygon_object index]; }
- (LEPolygon *)polygon { return polygon_object; }

 // **************************  Overriden Standard Methods  *************************
 
-(short)index { return [theAnnotationsST indexOfObjectIdenticalTo:self]; }
 
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
        //polygon_index = 0;
        
        group = nil;
        
        bounds = NSZeroRect;
    }
    return self;
}

-(id)initWithAdjPoint:(NSPoint)point
{
    self = [super init];
    if (self != nil) {
        //[self setP1:-1];
        //[self setP2:-1];
        polygon_object = nil;
        text = nil;
        type = 0;
        location.x = point.x*16;
        location.y = point.y*16;
        //polygon_index = 0;
        
        group = nil;
        
        bounds = NSZeroRect;
    }
    return self;
}

- (void)setNoteType:(id)noteType
{
	NSLog(@"PhAnnotationNote got sent this noteType: %@", noteType);
}
@end
