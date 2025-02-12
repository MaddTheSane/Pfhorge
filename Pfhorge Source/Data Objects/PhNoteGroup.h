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

NS_ASSUME_NONNULL_BEGIN

@class PhAnnotationNote;

@interface PhNoteGroup : PhAbstractName <NSSecureCoding>
{
    NSColor *noteColor;
    NSMutableArray<PhAnnotationNote*> *notes;
    
    BOOL visible;
}

// **************************  Coding/Copy Protocol Methods  *************************

@property (getter=isVisible) BOOL visible;

- (void)encodeWithCoder:(NSCoder *)coder;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithName:(NSString *)theString NS_DESIGNATED_INITIALIZER;
- (instancetype)init;

@property (readonly) BOOL doIHaveColor;

@property (copy, nullable) NSColor *color;

-(NSArray<PhAnnotationNote*> *)objectsInThisLayer;

-(void)addObject:(id)theObj;
-(void)removeObject:(id)theObj;
-(BOOL)isObjectInHere:(id)theObj;

@end

NS_ASSUME_NONNULL_END
