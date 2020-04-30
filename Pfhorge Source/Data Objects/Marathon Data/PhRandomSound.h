//
//  PhRandomSound.h
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
#import "PhTypesStructresEnums.h"

//#define RANDOM_SOUND_TAG 'bonk'

#define MAXIMUM_RANDOM_SOUND_IMAGES_PER_MAP 64

enum	// sound image flags
{
	_sound_image_is_non_directional = 0x0001	// ignore direction
};

// possibly directional random sound effects
@interface PhRandomSound : PhAbstractName <NSCoding>
{
	unsigned short	flags; // word
        
	short	sound_index;
	short	volume, delta_volume;
	short	period, delta_period;
	short	direction, delta_direction; // angle
	int32_t	pitch, delta_pitch; // fixed

	short	phase; // should be NONE ???
	short	unused[3];
}

// **************************  Coding/Copy Protocal Methods  *************************
- (void) encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

// ************************** Get Accsessors *************************
- (unsigned short) getFlags;
- (short) getSound_index;
- (short) getVolume;
- (short) getDelta_volume;
- (short) getPeriod;
- (short) getDelta_period;
- (short) getDirection;
- (short) getDelta_direction;
- (long) getPitch;
- (long) getDelta_pitch;
- (short) getPhase;

// ************************** Set Accsessors *************************
- (void) setFlags:(short)v;
- (void) setSound_index:(short)v;
- (void) setVolume:(short)v;
- (void) setDelta_volume:(short)v;
- (void) setPeriod:(short)v;
- (void) setDelta_period:(short)v;
- (void) setDirection:(short)v;
- (void) setDelta_direction:(short)v;
- (void) setPitch:(long)v;
- (void) setDelta_pitch:(long)v;
- (void) setPhase:(short)v;

@end
