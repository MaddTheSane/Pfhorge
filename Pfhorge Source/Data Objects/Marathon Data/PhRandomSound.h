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

//! sound image flags
typedef NS_ENUM(unsigned short, PhRandomSoundFlags) {
    //! ignore direction
	_sound_image_is_non_directional = 0x0001
};

//! possibly directional random sound effects
@interface PhRandomSound : PhAbstractName <NSSecureCoding>
{
	PhRandomSoundFlags	flags; // word
        
	short	sound_index;
	short	volume, delta_volume;
	short	period, delta_period;
	short	direction, delta_direction; // angle
	int32_t	pitch, delta_pitch; // fixed

	short	phase; // should be NONE ???
}

// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithCoder:(NSCoder *)coder;

// ************************** Accsessors *************************
@property PhRandomSoundFlags flags;
@property short soundIndex;
@property short volume;
@property short deltaVolume;
@property short period;
@property short deltaPeriod;
@property short direction;
@property short deltaDirection;
@property int32_t pitch;
@property int32_t deltaPitch;
@property short phase;

@end
