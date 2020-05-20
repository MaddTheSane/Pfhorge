//
//  PhPlatform.h
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

#import <Foundation/Foundation.h>
#import "LEMapStuffParent.h"
#import "PhAbstractName.h"
#import "PhTypesStructresEnums.h"

#import "PhTypesStructresEnums.h"

//#define ITEM_PLACEMENT_STRUCTURE_TAG 'plat'

#define MAXIMUM_PLATFORMS_PER_MAP 64



// ••• ••• ••• Platform Types and Constents ••• ••• •••



typedef NS_ENUM(int16_t, PhPlatformType)	// platform types
{
	_platform_is_spht_door,
	_platform_is_spht_split_door,
	_platform_is_locked_spht_door,
	_platform_is_spht_platform,
	_platform_is_noisy_spht_platform,
	_platform_is_heavy_spht_door,
	_platform_is_pfhor_door,
	_platform_is_heavy_spht_platform,
	_platform_is_pfhor_platform,

	NUMBER_OF_PLATFORM_TYPES
};



NS_ENUM(short)	// platform speeds
{
	_very_slow_platform = WORLD_ONE / (4*TICKS_PER_SECOND),
	_slow_platform = WORLD_ONE / (2*TICKS_PER_SECOND),
	_fast_platform = 2 * _slow_platform,
	_very_fast_platform = 3*_slow_platform,
	_blindingly_fast_platform = 4 * _slow_platform
};

NS_ENUM(short)	// platform delays
{
	_no_delay_platform = 0,
	_short_delay_platform = TICKS_PER_SECOND,
	_long_delay_platform = 2*TICKS_PER_SECOND,
	_extremely_long_delay_platform = 8*TICKS_PER_SECOND
};



// ••• ••• ••• Platform Flags ••• ••• •••


//! static platform flags
typedef NS_ENUM(unsigned int, PhPlatformStaticFlags)
{
	//! otherwise inactive
	_platform_is_initially_active = 0x00000001,
	//! high for floor platforms, low for ceiling platforms, closed for two_way platforms
	_platform_is_initially_extended = 0x00000002,
        
	// These both can not be set to true a the same time...
	//! this platform will deactivate each time it reaches a discrete level
	_platform_deactivates_at_each_level = 0x00000004,
	//! this platform will deactivate upon returning to its original position
	_platform_deactivates_at_initial_level = 0x00000008,
        
	_platform_activates_adjacent_platforms_when_deactivating = 0x00000010,
	//! i.e. there is no empty space when the platform is fully extended
	_platform_extends_floor_to_ceiling = 0x00000020,
	//! platform rises from floor
	_platform_comes_from_floor = 0x00000040,
	//! platform lowers from ceiling
	_platform_comes_from_ceiling = 0x00000080,
	//! when obstructed by monsters, this platform causes damage
	_platform_causes_damage = 0x00000100,
	//! does not reactive its parent (i.e. that platform which activated it)
	_platform_does_not_activate_parent = 0x00000200,
	_platform_activates_only_once = 0x00000400,
	//! activates floor and ceiling light sources while activating
	_platform_activates_light = 0x00000800,
	//! deactivates floor and ceiling lightsources while deactivating
	_platform_deactivates_light = 0x00001000,
	//! i.e. door: players can use action key to change the state and/or direction of this platform
	_platform_is_player_controllable = 0x00002000,
	//! i.e. door: monsters can expect to be able to move this platofrm even if inactive
	_platform_is_monster_controllable = 0x00004000,
	_platform_reverses_direction_when_obstructed = 0x00008000,
	//! when acctive, can only be deactivated by itself
	_platform_cannot_be_externally_deactivated = 0x00010000,
	//! complicated interpretation; uses native polygon heights during automatic min,max calculation
	_platform_uses_native_polygon_heights = 0x00020000,
	//! whether or not the platform begins with the maximum delay before moving
	_platform_delays_before_activation = 0x00040000,
	_platform_activates_adjacent_platforms_when_activating = 0x00080000,
	_platform_deactivates_adjacent_platforms_when_activating = 0x00100000,
	_platforms_deactivates_adjacent_platforms_when_deactivating = 0x00200000,
	_platform_contracts_slower = 0x00400000,
	_platform_activates_adjacent_platforms_at_each_level = 0x00800000,
	_platform_is_locked = 0x01000000,
	_platform_is_secret = 0x02000000,
	_platform_is_door = 0x04000000,
};

enum /* dynamic platform flags */
{
	_platform_is_active, /* otherwise inactive */
	_platform_is_extending, /* otherwise contracting; could be waiting between levels */
	_platform_is_moving, /* otherwise at rest (waiting between levels) */
	_platform_has_been_activated, /* in case we can only be activated once */
	_platform_was_moving, /* the platform moved unobstructed last tick */
	_platform_is_fully_extended,
	_platform_is_fully_contracted,
	_platform_was_just_activated_or_deactivated,
	_platform_floor_below_media,
	_platform_ceiling_below_media,
	NUMBER_OF_DYNAMIC_PLATFORM_FLAGS /* <=16 */
};



// ••• ••• ••• Platform Structres ••• ••• •••



struct endpoint_owner_data
{
	int16_t first_polygon_index, polygon_index_count;
	int16_t first_line_index, line_index_count;
};

struct static_platform_data_platform /* size platform-dependant */
{
	PhPlatformType type;
	int16_t speed, delay;
	world_distance maximum_height, minimum_height; /* if NONE then calculated in some reasonable way */

	PhPlatformStaticFlags static_flags;
	
	int16_t polygon_index;
	
	int16_t tag;
	
	int16_t unused[7];
};
/// const int SIZEOF_static_platform_data = 32;

struct platform_data2 /* 140 bytes */
{
	PhPlatformType type; // !
	//short uknown;
	PhPlatformStaticFlags static_flags; // !
	short speed, delay; // ! !
	short minimum_floor_height /* ! */, maximum_floor_height; // 10, 12
	short minimum_ceiling_height, maximum_ceiling_height/* ! */; // 14, 16

	short polygon_index /* ! */;

	unsigned short dynamic_flags;
	short floor_height, ceiling_height;
	short ticks_until_restart; /* if we’re not moving but are active, this is our delay until we move again */

	struct endpoint_owner_data endpoint_owners[/*MAXIMUM_VERTICES_PER_POLYGON*/ 8 ];

	short parent_platform_index; /* the platform_index which activated us, if any */
	
	short tag /* ! */;
	
	short unused[22];
};
/// const int SIZEOF_platform_data = 140;



// ••• ••• ••• Objective-C Stuff ••• ••• •••

@class PhTag;

@interface PhPlatform : PhAbstractName <NSCoding, NSCopying>
{
@private
	PhPlatformType	type;
	short	speed, delay;
	
	// world_distance:
	short	maximum_height, minimum_height; // if NONE then calculated in some reasonable way
	
	PhPlatformStaticFlags static_flags;
	
	short polygon_index;
	__kindof LEMapStuffParent	*polygon_object;
	
	short tag;
	PhTag *tagObject;
}

// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

- (void)copyInDynamicPlatformData:(NSData *)theData at:(long)locationOfBytes;

// ************************** Accsessors *************************
@property PhPlatformType type;
@property short speed;
@property short delay;
@property short maximumHeight;
@property short minimumHeight;
@property PhPlatformStaticFlags staticFlags;
@property short polygonIndex;
@property (assign) id polygonObject;
@property (nonatomic) short tag;
@property (assign) PhTag *tagObject;

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice;
//+(void)setTheMapPolysST:(NSArray *)theNSArray;

@end
