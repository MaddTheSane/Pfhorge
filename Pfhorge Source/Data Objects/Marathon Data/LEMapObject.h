//
//  LEMapObject.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Wed Jun 20 2001.
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

enum	// map object types
{
	_saved_monster,		// .index is monster type
	_saved_object,		// .index is scenery type
	_saved_item,		// .index is item type
	_saved_player,		// .index is team bitfield
	_saved_goal,		// .index is goal number
	_saved_sound_source,	// .index is source type, .facing is sound volume
	_NUMBER_OF_OBJECT_TYPES
};

//! map object flags
typedef NS_OPTIONS(unsigned short, LEMapObjectFlags)
{
	//! initially invisible
	_map_object_is_invisible = 0x0001,
	_map_object_is_platform_sound = 0x0001,
	//! used for calculating absolute .z coordinate
	_map_object_hanging_from_ceiling = 0x0002,
	//! monster cannot activate by sight
	_map_object_is_blind = 0x0004,
	//! monster cannot activate by sound
	_map_object_is_deaf = 0x0008,
	//! used by sound sourced caused by media
	_map_object_floats = 0x0010,
	//! for items only
	_map_object_is_network_only = 0x0020

	// top four bits is activation bias for monsters
};

#define DECODE_ACTIVATION_BIAS(f) ((f)>>12)
#define ENCODE_ACTIVATION_BIAS(b) ((b)<<12)

@interface LEMapObject : LEMapStuffParent <NSCoding>
{
    short type, index, facing, polygonIndex, x, y, z, x32, y32;
    id polygonObject;
    LEMapObjectFlags flags;
}

// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)initWithMapObject:(LEMapObject *)theMapObjectToImitate withLevel:(LELevelData *)theLev;

//+(void)setEverythingLoadedST:(BOOL)theChoice;
//+(void)setTheMapPolysST:(NSArray *)theNSArray;

// Acessor Methods...

-(NSRect)as32Rect;
-(NSPoint)as32Point;

-(short)getX;
-(short)getY;
-(short)getZ;
-(short)x32;
-(short)y32;
-(short)getType;
-(short)getObjTypeIndex;
-(short)getFacing;
-(short)getPolygonIndex;
@property (assign, getter=getPolygonObject) id polygonObject;
-(LEMapObjectFlags)getFlags;
@property (getter=getMapFlags) LEMapObjectFlags mapFlags;

//-(void)moveBy32Point:(NSPoint)theOffset;

-(void)setZ:(short)s;
-(void)setX:(short)s;
-(void)setY:(short)s;
-(void)set32X:(short)s API_DEPRECATED_WITH_REPLACEMENT("-setX32:", macos(10.0, 10.7));
-(void)set32Y:(short)s API_DEPRECATED_WITH_REPLACEMENT("-setY32:", macos(10.0, 10.7));
-(void)setX32:(short)s;
-(void)setY32:(short)s;
-(void)setType:(short)s;
-(void)setIndex:(short)s;
-(void)setFacing:(short)s;
-(void)setPolygonIndex:(short)s;

@end
