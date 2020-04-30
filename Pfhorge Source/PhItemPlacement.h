//
//  PhItemPlacement.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jul 08 2001.
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

#define ITEM_PLACEMENT_STRUCTURE_TAG 'plac'
/* ---------- new object frequency structures. */

#define MAXIMUM_OBJECT_TYPES 64

enum // flags for object_frequency_definition
{
	_reappears_in_random_location= 0x0001
};

@interface PhItemPlacement : LEMapStuffParent <NSCoding>
{
	unsigned short flags;
	
	short initial_count;   // number that initially appear. can be greater than maximum_count
	short minimum_count;   // this number of objects will be maintained.
	short maximum_count;   // canÍt exceed this, except at the beginning of the level.
	
	short random_count;    // maximum random occurences of the object
	unsigned short random_chance;    // in (0, 65535]
}

+ (PhItemPlacement *)itemPlacementObjWithDefaults;

// **************************  Coding/Copy Protocal Methods  *************************
- (void) encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

- (void)adjustTheInitalCountBy:(int)value;

// ************************** Get Accsessors *************************
- (unsigned short)getFlags;
	
- (short)getInitial_count;
- (short)getMinimum_count;
- (short)getMaximum_count;
	
- (short)getRandom_count;
- (unsigned short)getRandom_chance;

// ************************** Set Accsessors *************************
- (void)setFlags:(short)v;

- (void)setInitial_count:(short)v;
- (void)setMinimum_count:(short)v;
- (void)setMaximum_count:(short)v;

- (void)setRandom_count:(short)v;
- (void)setRandom_chance:(unsigned short)v;

@end
