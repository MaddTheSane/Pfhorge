//
//  PhTag.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Thu Nov 22 2001.
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


#import "PhTag.h"
#import "LEExtras.h"

@implementation PhTag
 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********
- (void) encodeWithCoder:(NSCoder *)coder
{
    int tagVersionNumber = 1;
    [super encodeWithCoder:coder];
    
    encodeInt(coder, tagVersionNumber);
}

- (id)initWithCoder:(NSCoder *)coder
{
    int loadingVersionNumber;
    
    self = [super initWithCoder:coder];
    
    loadingVersionNumber = decodeInt(coder);
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhTag *copy = [[PhTag allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

 // **************************  Init and Dealloc Methods  *************************
 #pragma mark -
#pragma mark ********* Init and Dealloc Methods *********
-(PhTag *)init
{
    self = [super initWithNumber:@-1];
    if (self == nil)
        return nil;
    return self;
}

-(PhTag *)initWithTagNumber:(NSNumber *)thePhNumber
{
    self = [super initWithNumber:thePhNumber];
    if (self == nil)
        return nil;
    return self;
}

-(short) getSpecialIndex { return [assignedNumber intValue]; }
-(short) index { return [theLevelTagObjectsST indexOfObjectIdenticalTo:self]; }

@end
