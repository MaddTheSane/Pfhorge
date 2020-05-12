//
//  PhLayer.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Dec 18 2001.
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


#import "PhLayer.h"
#import "LEExtras.h"

@implementation PhLayer
 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********
- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		[coder encodeObject:layerColor forKey:@"layerColor"];
		[coder encodeObject:objectsInThisLayer forKey:@"objectsInThisLayer"];
	} else {
    encodeNumInt(coder, 0);
    
    
    encodeObj(coder, layerColor);
    encodeObj(coder, objectsInThisLayer);
	}
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
	if (coder.allowsKeyedCoding) {
		layerColor = [[coder decodeObjectOfClass:[NSColor class] forKey:@"layerColor"] retain];
		objectsInThisLayer = [[coder decodeObjectForKey:@"objectsInThisLayer"] retain];
	} else {
    versionNum = decodeNumInt(coder);
    
    layerColor = decodeObjRetain(coder);
    objectsInThisLayer = decodeObjRetain(coder);
	}
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhLayer *copy = [[PhLayer allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

 // **************************  Init and Dealloc Methods  *************************
 #pragma mark -
#pragma mark ********* Init and Dealloc Methods *********

-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    [self setPhName:@"No Name"];
    objectsInThisLayer = [[NSMutableArray alloc] init];
    
    layerColor = nil;
    
    return self;
}

-(id)initWithName:(NSString *)theString
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    [self setPhName:theString];
    objectsInThisLayer = [[NSMutableArray alloc] init];
    
    layerColor = nil;
    
    return self;
}

-(void)dealloc
{
    [layerColor release];
    [objectsInThisLayer release];
    
    [super dealloc];
}

// ********* Overridden Methods *********
-(short) index { return [theLayersST indexOfObjectIdenticalTo:self]; }

+ (NSSet<NSString *> *)keyPathsForValuesAffectingDoIHaveColor
{
	return [NSSet setWithObject:@"layerColor"];
}
-(BOOL)doIHaveColor { return (layerColor != nil); }
@synthesize layerColor;

-(NSArray *)objectsInThisLayer { return objectsInThisLayer; }

-(void)addObjectToLayer:(id)theObj { [objectsInThisLayer addObject:theObj]; }
-(void)removeObjectFromLayer:(id)theObj { [objectsInThisLayer removeObject:theObj]; }
-(BOOL)isObjectInLayer:(id)theObj { return ([objectsInThisLayer containsObject:theObj]); }

@end
