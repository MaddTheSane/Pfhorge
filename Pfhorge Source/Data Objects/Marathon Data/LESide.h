//
//  LESide.h
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
#import "PhTypesStructresEnums.h"
#include "shapes-structs.h"

enum {
    _cpanel_effects_light = 1,
    _cpanel_effects_polygon,
    _cpanel_effects_tag,
    _cpanel_effects_terminal
};


//#define SIDE_TAG 'SIDS'
enum /* environment control panel offsets */
{
    pfhorOffset = 32,
    jjaroOffset = 43,
    sewageOffset = 21,
    lavaOffset = 10,
    waterOffset = 0
};

//! side flags
typedef NS_OPTIONS(unsigned short, LESideFlags) {
	LESideControlPanelStatus = 0x0001,
	LESideIsControlPanel = 0x0002,
	LESideIsRepairSwitch = 0x0004,
	LESideIsDestructiveSwitch = 0x0008,
	LESideIsLightedSwitch = 0x0010,
	LESideSwitchCanBeDestroyed = 0x0020,
	LESideSwitchCanOnlyBeByProjectiles = 0x0040,

	LESideEditorDirtyBit = 0x4000 //!< used by the editor (Not Used In Pfhorge)
};

//! control panel side types // FIXME: THIS IS CURRENTLY INACURATE!!!
typedef NS_ENUM(short, LESideControlPanelType) {
	_panel_singleShield,
	_panel_doubleShield,
	_panel_tripleShield,
	_panel_lightSwitch, // Light index
	_panel_platformSwitch, // Platfrom index
	_panel_tagSwitch, // Tag number
	_panel_patternBuffer,
	_panel_computerTerminal,
	_panel_oxygen,
	_panel_chipInserton, // tag number
	_panel_wires, // tag number
	NUMBER_OF_CONTROL_PANELS
};

#define SIDE_IS_CONTROL_PANEL(s) ((s)->flags & LESideIsControlPanel)
#define SET_SIDE_CONTROL_PANEL(s,t) ((t) ? (s->flags |= (word) LESideIsControlPanel) : (s->flags &= (word)~LESideIsControlPanel))

#define GET_CONTROL_PANEL_STATUS(s) ((s)->flags & LESideControlPanelStatus)
#define SET_CONTROL_PANEL_STATUS(s,t) ((t) ? (s->flags |= (word) LESideControlPanelStatus) : (s->flags &= (word)~LESideControlPanelStatus))

#define SIDE_IS_REPAIR_SWITCH(s) ((s)->flags & LESideIsRepairSwitch)
#define SET_SIDE_IS_REPAIR_SWITCH(s,t) ((t) ? (s->flags |= (word) LESideIsRepairSwitch) : (s->flags &= (word) ~ LESideIsRepairSwitch))

// flags used by Vulcan
#define SIDE_IS_DIRTY(s) ((s)->flags &LESideEditorDirtyBit)
#define SET_SIDE_IS_DIRTY(s, t) ((t)?(s->flags|=(word)LESideEditorDirtyBit):(s->flags&=(word)~LESideEditorDirtyBit)

//! side types (largely redundant; most of this could be guessed for examining adjacent polygons)
typedef NS_ENUM(short, LESideType) {
	//! primary texture is mapped floor-to-ceiling
	LESideFull,
	//! primary texture is mapped on a panel coming down from the ceiling (implies 2 adjacent polygons)
	LESideHigh,
	//! primary texture is mapped on a panel coming up from the floor (implies 2 adjacent polygons)
	LESideLow,
	//! primary texture is mapped floor-to-ceiling, secondary texture is mapped into it (i.e., control panel)
	LESideComposite,
	//! primary texture is mapped onto a panel coming down from the ceiling, secondary texture is mapped on a panel coming up from the floor
	LESideSplit
};

typedef struct side_texture_definition
{
	world_distance		x0, y0;
	shape_descriptor	texture;
	
	// These have been added, they are not a part of the orginal structure defintion...
	short int		textureCollection; //!< Obsolete... This was not in the orginal structure!
	short int		textureNumber; //!< Obsolete... This was not in the orginal structure!
}side_texture_definition;

typedef struct side_exclusion_zone
{
	NSPoint	e0, e1, e2, e3;
}side_exclusion_zone;

@class PhLight, LEPolygon, LELine;

@interface LESide : LEMapStuffParent <NSCopying, NSSecureCoding>
{
	// struct side_data // 64 bytes
	LESideType	type;
	LESideFlags	flags;
	
	struct 	side_texture_definition		primary_texture;
	struct 	side_texture_definition		secondary_texture;
	struct 	side_texture_definition		transparent_texture;	//!< not drawn if texture == NONE
	
	/*! all sides have the potential of being impassable; the exclusion zone
	 is the area near the side which cannont be walked through */
	struct side_exclusion_zone	exclusion_zone;
	
	//! only valid if side->flags & LESideIsControlPanel
	short		control_panel_type;
	short		control_panel_permutation; //platform index, light source index, etc...
    __unsafe_unretained __kindof LEMapStuffParent	*control_panel_permutation_object;
	
	int 		permutationEffects;
	
	short		primary_transfer_mode;
	short		secondary_transfer_mode;
	short		transparent_transfer_mode;
	
	short		polygon_index, line_index;
    __unsafe_unretained LEPolygon	*polygon_object;
    __unsafe_unretained LELine		*line_object;
	
	short		primary_lightsource_index;
	short		secondary_lightsource_index;
	short		transparent_lightsource_index;
	
    __unsafe_unretained PhLight *primary_lightsource_object;
    __unsafe_unretained PhLight *secondary_lightsource_object;
    __unsafe_unretained PhLight *transparent_lightsource_object;
	
	int		ambient_delta;
}

// **************************  Coding/Copy Protocol Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (instancetype)initWithSide:(LESide *)theSideToImitate;

// ***************** Copy Methods *****************
- (id)copyWithZone:(NSZone *)zone;

// ************************** Utilties **************************
- (void)setLightsThatAre:(PhLight*)theLightInQuestion to:(PhLight*)setToLight;

// ************************** Flag Accssors *************************

- (BOOL)getFlagS:(short)theFlag;
- (void)setFlag:(unsigned short)theFlag to:(BOOL)v;

// *****************   Set Accsessors   *****************
- (void)setPrimaryTexture:(char)number;
- (void)setSecondaryTexture:(char)number;
- (void)setTransparentTexture:(char)number;

- (void)setPrimaryTextureCollection:(char)number;
- (void)setSecondaryTextureCollection:(char)number;
- (void)setTransparentTextureCollection:(char)number;

- (void)resetTextureCollection;
- (void)setTextureCollection:(char)number;
        
- (void)setPrimaryTextureStruct:(struct side_texture_definition)v;
- (void)setSecondaryTextureStruct:(struct side_texture_definition)v;
- (void)setTransparentTextureStruct:(struct side_texture_definition)v;

- (void)setExclusionZone:(struct side_exclusion_zone)v;
        
- (void)setControlPanelType:(short)v;
- (void)setControlPanelPermutation:(short)v;

- (void)setPolygonIndex:(short)v;
- (void)setLineIndex:(short)v;
        
- (void)setPrimaryLightsourceIndex:(short)v;
- (void)setSecondaryLightsourceIndex:(short)v;
- (void)setTransparentLightsourceIndex:(short)v;
        
@property int ambientDelta;

// *****************   Get Accsessors   *****************
- (char)primaryTexture;
- (char)secondaryTexture;
- (char)transparentTexture;

- (char)primaryTextureCollection;
- (char)secondaryTextureCollection;
- (char)transparentTextureCollection;

- (char)textureCollection;

@property LESideType type;
@property LESideFlags flags;
        
@property struct side_texture_definition primaryTextureStruct;
@property struct side_texture_definition secondaryTextureStruct;
@property struct side_texture_definition transparentTextureStruct;

@property struct side_exclusion_zone exclusionZone;

- (int)permutationEffects;

@property (nonatomic) short controlPanelType;
-(short)controlPanelPermutation;
@property (assign) __kindof LEMapStuffParent *controlPanelPermutationObject;
        
@property short primaryTransferMode;
@property short secondaryTransferMode;
@property short transparentTransferMode;
        
-(short)polygonIndex;
-(short)lineIndex;

@property (assign) LEPolygon *polygonObject;
@property (assign) LELine *lineObject;
        
-(short)primaryLightsourceIndex;
-(short)secondaryLightsourceIndex;
-(short)transparentLightsourceIndex;
                
@property (assign) PhLight *primaryLightsourceObject;
@property (assign) PhLight *secondaryLightsourceObject;
@property (assign) PhLight *transparentLightsourceObject;

//  ************************** Other Usful Methods *************************
@property (readonly) short adjustedControlPanelType;

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice;
//+(void)setTheMapPointsST:(NSArray *)theNSArray;
//+(void)setTheMapLinesST:(NSArray *)theNSArray;
//+(void)setTheMapObjectsST:(NSArray *)theNSArray;
//+(void)setTheMapPolysST:(NSArray *)theNSArray;
//+(void)setTheMapLightsST:(NSArray *)theNSArray;


@end
