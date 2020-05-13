//
//  PhAbstractName.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Nov 24 2001.
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


#import <Foundation/Foundation.h>
#import "LEMapStuffParent.h"



@interface PhAbstractName : LEMapStuffParent <NSCoding>
{
    NSString *myName;
}

// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) NSString *phName;
@property (nonatomic, readonly) BOOL doIHaveAName;
@property (nonatomic, readonly) BOOL doIHaveACustomName;
- (void)resetNameToMyIndex;

@end
