//
//  PhNoteGroup.m
//  Pfhorge
//
//  Created by Jagil on Wed Oct 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
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


#import "LEExtras.h"
#import "PhNoteGroup.h"
#import "PhAnnotationNote.h"

@implementation PhNoteGroup
 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********
- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    encodeNumInt(coder, 0);
    
    encodeObj(coder, noteColor);
    encodeObj(coder, notes);
    encodeBOOL(coder, visible);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    self = [super initWithCoder:coder];
    versionNum = decodeNumInt(coder);
    
    noteColor = decodeObjRetain(coder);
    notes = decodeObjRetain(coder);
    visible = decodeBOOL(coder);
    
    return self;
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
    notes = [[NSMutableArray alloc] init];
    
    noteColor = nil;
    visible = YES;
    
    return self;
}

-(id)initWithName:(NSString *)theString;
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    [self setPhName:theString];
    notes = [[NSMutableArray alloc] init];
    noteColor = nil;
    
    visible = YES;
    
    return self;
}

-(void)dealloc
{
    NSEnumerator *numer = [notes objectEnumerator];
    PhAnnotationNote *thisObj = nil;
    
    while (thisObj = [numer nextObject])
    {
        [thisObj setNoteType:nil];
    }
    
    [noteColor release];
    [notes release];
    
    [super dealloc];
}

// ********* Overridden Methods *********

@synthesize visible;

-(short)index { return [theNoteTypesST indexOfObjectIdenticalTo:self]; }

+ (NSSet<NSString *> *)keyPathsForValuesAffectingDoIHaveColor
{
	return [NSSet setWithObject:@"layerColor"];
}
-(BOOL)doIHaveColor { return (noteColor != nil); }
@synthesize color=noteColor;

-(NSArray *)objectsInThisLayer { return notes; }

-(void)addObject:(id)theObj
{
    if ([theObj isKindOfClass:[PhAnnotationNote class]])
    {
        [notes addObject:theObj]; [theObj setGroup:self];
    }
}

-(void)removeObject:(id)theObj { [notes removeObject:theObj]; }
-(BOOL)isObjectInHere:(id)theObj { return ([notes containsObject:theObj]); }

@end
