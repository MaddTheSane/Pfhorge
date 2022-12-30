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
#import <PfhorgeKit/LEMapStuffParent.h>
#import <PfhorgeKit/PhAbstractName.h>

//#define LIGHTSOURCE_TAG 'LITE'

#define MAXIMUM_LIGHTS_PER_MAP 64

//! default light types
typedef NS_ENUM(short, PhLightTypes) {
	PhLightNormal,
	PhLightStrobe,
	PhLightMedia,
	PhLightTypesCount
};

//! states
typedef NS_ENUM(short, PhLightState) {
	PhLightStatePrimaryActive = 0,
	PhLightStateSecondaryActive,
	PhLightStateBecomingActive,
	
	PhLightStatePrimaryInactive,
	PhLightStateSecondaryInactive,
	PhLightStateBecomingInactive,
	PhLightStateTotalCount
};

// static light data

//!lighting functions
typedef NS_ENUM(short, PhLightFunction) {
	//! maintain final intensity for period
	PhLightFunctionConstant,
	//! linear transition between initial and final intensity over period
	PhLightFunctionLinear,
	//! sine transition between inital and final intensity over period
	PhLightFunctionSmooth,
	//! intensity in [smooth_intensity(t),final_intensity]
	PhLightFunctionFlicker,
	
	PhLightFunctionTotalCount
};

/*! as intensities, transition function are given the primary
periods of the active and inactive state, plus the intensity
at the time of transition */
struct lighting_function_specification	// 2*3 + 4*2 = 14 bytes
{
	PhLightFunction function;

	short period, delta_period;
	int32_t	intensity, delta_intensity; // used to be a fixed type :)
};

//! static flags
typedef NS_OPTIONS(unsigned short, PhLightStaticFlags) {
	PhLightStaticFlagIsInitiallyActive = 0x0001,
	PhLightStaticFlagHasSlavedIntensities = 0x0002,
	PhLightStaticFlagIsStateless = 0x0004,
};

#define LIGHT_IS_INITIALLY_ACTIVE TEST_FLAG16(flags, PhLightStaticFlagIsInitiallyActive)
#define LIGHT_IS_STATELESS TEST_FLAG16(flags, PhLightStaticFlagIsStateless)

#define SETPhLightStaticFlagIsInitiallyActive(v) SET_FLAG16(flags, PhLightStaticFlagIsInitiallyActive, (v))
#define SETPhLightStaticFlagIsStateless(v) SET_FLAG16(flags, PhLightStaticFlagIsStateless, (v))

@class PhTag;

@interface PhLight : PhAbstractName <NSSecureCoding, NSCopying>
{
	PhLightTypes type;
	PhLightStaticFlags flags;

	short phase;	// initializer, so lights may start out-of-phase with each other
        
	struct lighting_function_specification light_states[PhLightStateTotalCount];
        
	short tag;
	__unsafe_unretained PhTag *tagObject;
}


// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (instancetype)init;


// ************************** Flag Accssors *************************

-(BOOL)getFlag:(PhLightStaticFlags)theFlag;
-(void)setFlag:(PhLightStaticFlags)theFlag to:(BOOL)v;

// *****************   Accsessors   *****************

@property PhLightTypes type;
@property PhLightStaticFlags flags;

@property short phase;

-(void)setFunction:(PhLightFunction)v forState:(PhLightState)i;
-(void)setPeriod:(short)v forState:(PhLightState)i;
-(void)setDeltaPeriod:(short)v forState:(PhLightState)i;
-(void)setIntensity:(int)v forState:(PhLightState)i;
-(void)setDeltaIntensity:(int)v forState:(PhLightState)i; // used to be a fixed type :)

@property (nonatomic) short tag;
@property (assign) PhTag *tagObject;

-(PhLightFunction)functionForState:(PhLightState)i;
-(short)periodForState:(PhLightState)i;
-(short)deltaPeriodForState:(PhLightState)i;
-(int)intensityForState:(PhLightState)i;
-(int)deltaIntensityForState:(PhLightState)i; // used to be a fixed type :)

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice;

@end
