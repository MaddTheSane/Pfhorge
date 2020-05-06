//
//  PhMedia.h
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
#import "PhAbstractName.h"

//#define MEDIA_TAG 'medi'
#define MAXIMUM_MEDIAS_PER_MAP 16

//! media  types
typedef NS_ENUM(short, PhMediaType)
{
	_media_water,
	_media_lava,
	_media_goo,
	_media_sewage,
	_media_jjaro,
	NUMBER_OF_MEDIA_TYPES
};

enum	// media flags
{
	_media_sound_obstructed_by_floor, // this media makes no sound when under the floor
	NUMBER_OF_MEDIA_FLAGS
};

#define MEDIA_SOUND_OBSTRUCTED_BY_FLOOR(m) TEST_FLAG16((m)->flags, _media_sound_obstructed_by_floor)

#define SET_MEDIA_SOUND_OBSTRUCTED_BY_FLOOR(m,v) SETFLAG16((m)->flags, _media_sound_obstructed_by_floor, (v))

enum	// media detonation types
{
	_small_media_detonation_effect,
	_medium_media_detonation_effect,
	_large_media_detonation_effect,
	_large_media_emergence_effect,
	NUMBER_OF_MEDIA_EMERGENCE_TYPES
};

enum	// media sounds
{
	_media_snd_feet_entering,
	_media_snd_feet_leaving,
	_media_snd_head_entering,
	_media_snd_head_leaving,
	_media_snd_splashing,
	_media_snd_ambient_over,
	_media_snd_ambient_under,
	_media_snd_platform_entering,
	_media_snd_platform_leaving,

	NUMBER_OF_MEDIA_SOUNDS
};

@interface PhMedia : PhAbstractName <NSCoding> /* 32 bytes */
{
	PhMediaType	type;
	unsigned short	flags;

	/* this light is not used as a real light; instead, the
	intensity of this light is used to determing the height
	of the media: height = (high-low)*intensity ... this
	sounds gross, but it makes media height as flexible as
	light intensities; clearly discontinuous light functions
	(e.g. strobes) should not be used */
	short	light_index;
        id	light_object;

	/* this is the maximum external velocity due to current;
	acceleration is 1/32nd of this */
	short	current_direction;
	short	current_magnitude;

	short	low, high;

	NSPoint origin;
	short 	height;

	int 	minimum_light_intensity; // ??? Object ???
	short 	texture;
	short 	transfer_mode;

	short	unused[2];
}

// **************************  Coding/Copy Protocal Methods  *************************
- (void) encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

// ************************** Flag Accssors *************************

-(BOOL)getFlag:(unsigned short)theFlag;
-(void)setFlag:(unsigned short)theFlag to:(BOOL)v;

// *****************   Accsessors   *****************

@property PhMediaType type;
@property unsigned short flags;

@property short lightIndex;
@property (assign) id lightObject;

@property short currentDirection;
@property short currentMagnitude;

@property short low;
@property short high;

@property NSPoint origin;
@property short height;

@property int minimumLightIntensity; // ??? Object ???
@property short texture;
@property short transferMode;

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice;
//+(void)setTheMapLightsST:(NSArray *)theNSArray;

@end
