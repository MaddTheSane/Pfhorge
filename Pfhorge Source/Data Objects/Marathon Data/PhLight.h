//
//  LELight.h
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

//#define LIGHTSOURCE_TAG 'LITE'

#define MAXIMUM_LIGHTS_PER_MAP 64

enum	// default light types
{
	_normal_light,
	_strobe_light,
	_media_light,
	NUMBER_OF_LIGHT_TYPES
};

enum	//states
{
	_light_primary_active = 0,
	_light_secondary_active,
        _light_becoming_active,
	
	_light_primary_inactive,
	_light_secondary_inactive,
        _light_becoming_inactive,
        _NUMBER_OF_LIGHT_STATES
};

// static light data

enum	//lighting functions
{
	_constant_lighting_function,	// maintain final intensity for period
	_linear_lighting_function,	// linear transition between initial and final intensity over period
	_smooth__lighting_function,	// sine transition between inital and final intensity over period
	_flicker_lighting_function,	// intensity in [smooth_intensity(t),final_intensity]
	NUMBER_OF_LIGHTING_FUNCTIONS
};

/* as intensities, transition function are given the primary
periods of the active and inactive state, plus the intensity
at the time of transition */
struct lighting_function_specification	// 2*3 + 4*2 = 14 bytes
{
	short function;

	short period, delta_period;
	int32_t	intensity, delta_intensity; // used to be a fixed type :)
};

enum	// static flags
{
	_light_is_initially_active = 0x0001,
	_light_has_slaved_intensities = 0x0002,
	_light_is_stateless = 0x0004,
	NUMBER_OF_STATIC_LIGHT_FLAGS // <= 16
};

#define LIGHT_IS_INITIALLY_ACTIVE TEST_FLAG16(flags, _light_is_initially_active)
#define LIGHT_IS_STATELESS TEST_FLAG16(flags, _light_is_stateless)

#define SET_LIGHT_IS_INITIALLY_ACTIVE(v) SET_FLAG16(flags, _light_is_initially_active, (v))
#define SET_LIGHT_IS_STATELESS(v) SET_FLAG16(flags, _light_is_stateless, (v))

@class PhTag;

@interface PhLight : PhAbstractName <NSCoding>
{
    	short type;
	unsigned short flags;

	short phase;	// initializer, so lights may start out-of-phase with each other
        
	struct lighting_function_specification light_states[6];
        
	short tag;
        PhTag *tagObject;
	short unused[4];
}


// **************************  Coding/Copy Protocal Methods  *************************
- (void) encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;


// ************************** Flag Accssors *************************

-(BOOL)getFlag:(unsigned short)theFlag;
-(void)setFlag:(unsigned short)theFlag to:(BOOL)v;

// *****************   Set Accsessors   *****************

-(void)setType:(short)v;
-(void)setFlags:(unsigned short)v;

-(void)setPhase:(short)v;

-(void)setFunction:(short)v forState:(short)i;
-(void)setPeriod:(short)v forState:(short)i;
-(void)setDelta_period:(short)v forState:(short)i;
-(void)setIntensity:(long)v forState:(short)i; 
-(void)setDelta_intensity:(long)v forState:(short)i; // used to be a fixed type :)

-(void)setTag:(short)v;
-(void)setTagObject:(PhTag *)value;

// *****************   Get Accsessors   *****************

-(short)getType;
-(unsigned short)getFlags;

-(short)getPhase;

-(short)getFunction_forState:(short)i;
-(short)getPeriod_forState:(short)i;
-(short)getDelta_period_forState:(short)i;
-(long)getIntensity_forState:(short)i; 
-(long)getDelta_intensity_forState:(short)i; // used to be a fixed type :)

-(short)getTag;
-(PhTag *)getTagObject;

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice;

@end
