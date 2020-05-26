//
//  PhNoteGroup.h
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

#import <Cocoa/Cocoa.h>
#import "PhAbstractName.h"

@class PhAnnotationNote;

@interface PhNoteGroup : PhAbstractName <NSCoding>
{
    NSColor *noteColor;
    NSMutableArray<PhAnnotationNote*> *notes;
    
    BOOL visible;
}

// **************************  Coding/Copy Protocal Methods  *************************

@property (getter=isVisible) BOOL visible;

- (void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithCoder:(NSCoder *)coder;

- (instancetype)initWithName:(NSString *)theString;

@property (readonly) BOOL doIHaveColor;

@property (copy) NSColor *color;

-(NSArray<PhAnnotationNote*> *)objectsInThisLayer;

-(void)addObject:(id)theObj;
-(void)removeObject:(id)theObj;
-(BOOL)isObjectInHere:(id)theObj;

@end
