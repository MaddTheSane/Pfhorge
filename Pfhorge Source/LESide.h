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

enum	// side flags
{
	_control_panel_status = 0x0001,
	_side_is_control_panel = 0x0002,
	_side_is_repair_switch = 0x0004,
	_side_is_destructive_switch = 0x0008,
	_side_is_lighted_switch = 0x0010,
	_side_switch_can_be_destroyed = 0x0020,
	_side_switch_can_only_be_hit_by_projectiles = 0x0040,

	_editor_dirty_bit = 0x4000 // used by the editor (Not Used In Pfhorge)
};

enum	//control panel side types // THIS IS CURRENTLY INACURATE!!!
{
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

#define SIDE_IS_CONTROL_PANEL(s) ((s)->flags & _side_is_control_panel)
#define SET_SIDE_CONTROL_PANEL(s,t) ((t) ? (s->flags |= (word) _side_is_control_panel) : (s->flags &= (word)~_side_is_control_panel))

#define GET_CONTROL_PANEL_STATUS(s) ((s)->flags & _control_panel_status)
#define SET_CONTROL_PANEL_STATUS(s,t) ((t) ? (s->flags |= (word) _control_panel_status) : (s->flags &= (word)~_control_panel_status))

#define SIDE_IS_REPAIR_SWITCH(s) ((s)->flags & _side_is_repair_switch)
#define SET_SIDE_IS_REPAIR_SWITCH(s,t) ((t) ? (s->flags |= (word) _side_is_repair_switch) : (s->flags &= (word) ~ _side_is_repair_switch))

// flags used by Vulcan
#define SIDE_IS_DIRTY(s) ((s)->flags &_editor_dirty_bit)
#define SET_SIDE_IS_DIRTY(s, t) ((t)?(s->flags|=(word)_editor_dirty_bit):(s->flags&=(word)~_editor_dirty_bit)

enum // side types (largely redundant; most of this could be guessed for examining adjacent polygons)
{
	_full_side,	// primary texture is mapped floor-to-ceiling
	_high_side, // primary texture is mapped on a panel coming down from the ceiling (implies 2 adjacent polygons)
	_low_side, // primary texture is mapped on a panel coming up from the floor (implies 2 adjacent polygons)
	_composite_side, //primary texture is mapped floor-to-ceiling, secondary texture is mapped into it (i.e., control panel)
	_split_side // primary texture is mapped onto a panel coming down from the ceiling, secondary texture is mapped on a panel coming up from the floor
};

typedef struct side_texture_definition
{
	world_distance		x0, y0;
	shape_descriptor	texture;
        
        // These have been added, they are not apart of the orginal structure defintion...
        short int		textureCollection; // Obsolete... This was not in the orginal structure!
        short int		textureNumber; // Obsolete... This was not in the orginal structure!
}side_texture_definition;

typedef struct side_exclusion_zone
{
	NSPoint	e0, e1, e2, e3;
}side_exclusion_zone;

@interface LESide : LEMapStuffParent <NSCopying, NSCoding>
{
   // struct side_data // 64 bytes
        short		type;
        unsigned short	flags;
        
        struct 	side_texture_definition		primary_texture;
        struct 	side_texture_definition		secondary_texture;
        struct 	side_texture_definition		transparent_texture;	// not drawn if texture == NONE
        
        /* all sides have the potential of being impassable; the exclusion zone
                is the area near the side which cannont be walked through */
        struct side_exclusion_zone	exclusion_zone;
        
        short		control_panel_type; // only valid if side->flags & _side_is_control_panel
        short		control_panel_permutation; //platform index, light source index, etc...
        id		control_panel_permutation_object;
        
        int 		permutationEffects;
        
        short		primary_transfer_mode;
        short		secondary_transfer_mode;
        short		transparent_transfer_mode;
        
        short		polygon_index, line_index;
        id		polygon_object, line_object;
        
        short		primary_lightsource_index;
        short		secondary_lightsource_index;
        short		transparent_lightsource_index;
        
        id		primary_lightsource_object;
        id		secondary_lightsource_object;
        id		transparent_lightsource_object;
        
        long		ambient_delta;
        
        short		unused[1];
}

// **************************  Coding/Copy Protocal Methods  *************************
- (void) encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
-(id)initWithSide:(LESide *)theSideToImitate;

// ***************** Copy Methods *****************
- (id)copyWithZone:(NSZone *)zone;

// ************************** Utilties **************************
-(void)setLightsThatAre:(id)theLightInQuestion to:(id)setToLight;

// ************************** Flag Accssors *************************

-(BOOL)getFlagS:(short)theFlag;
-(void)setFlag:(unsigned short)theFlag to:(BOOL)v;

// *****************   Set Accsessors   *****************
-(void)setPrimaryTexture:(char)number;
-(void)setSecondaryTexture:(char)number;
-(void)setTransparentTexture:(char)number;

-(void)setPrimaryTextureCollection:(char)number;
-(void)setSecondaryTextureCollection:(char)number;
-(void)setTransparentTextureCollection:(char)number;

-(void)resetTextureCollection;
-(void)setTextureCollection:(char)number;

-(void)setType:(short)v;
-(void)setFlags:(unsigned short)v;
        
-(void)setPrimary_texture:(struct side_texture_definition)v;
-(void)setSecondary_texture:(struct side_texture_definition)v;
-(void)setTransparent_texture:(struct side_texture_definition)v;

-(void)setExclusion_zone:(struct side_exclusion_zone)v;
        
-(void)setControl_panel_type:(short)v;
-(void)setControl_panel_permutation:(short)v;
-(void)setControl_panel_permutation_object:(id)v;
        
-(void)setPrimary_transfer_mode:(short)v;
-(void)setSecondary_transfer_mode:(short)v;
-(void)setTransparent_transfer_mode:(short)v;
        
-(void)setPolygon_index:(short)v;
-(void)setLine_index:(short)v;

-(void)setPolygon_object:(id)v;
-(void)setLine_object:(id)v;
        
-(void)setPrimary_lightsource_index:(short)v;
-(void)setSecondary_lightsource_index:(short)v;
-(void)setTransparent_lightsource_index:(short)v;

-(void)setPrimary_lightsource_object:(id)v;
-(void)setSecondary_lightsource_object:(id)v;
-(void)setTransparent_lightsource_object:(id)v;
        
-(void)setAmbient_delta:(long)v;

// *****************   Get Accsessors   *****************
-(char)primaryTexture;
-(char)secondaryTexture;
-(char)transparentTexture;

-(char)primaryTextureCollection;
-(char)secondaryTextureCollection;
-(char)transparentTextureCollection;

-(char)textureCollection;

-(short)getType;
-(unsigned short)getFlags;
        
-(struct side_texture_definition)getPrimary_texture;
-(struct side_texture_definition)getSecondary_texture;
-(struct side_texture_definition)getTransparent_texture;

-(struct side_exclusion_zone)getExclusion_zone;

-(int)getPermutationEffects;

-(short)getControl_panel_type;
-(short)getControl_panel_permutation;
-(id)getControl_panel_permutation_object;
        
-(short)getPrimary_transfer_mode;
-(short)getSecondary_transfer_mode;
-(short)getTransparent_transfer_mode;
        
-(short)getPolygon_index;
-(short)getLine_index;

-(id)getpolygon_object;
-(id)getline_object;
        
-(short)getPrimary_lightsource_index;
-(short)getSecondary_lightsource_index;
-(short)getTransparent_lightsource_index;
                
-(id)getprimary_lightsource_object;
-(id)getsecondary_lightsource_object;
-(id)gettransparent_lightsource_object;

-(long)getAmbient_delta;

//  ************************** Other Usful Methods *************************
-(short)getAdjustedControlPanelType;

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice;
//+(void)setTheMapPointsST:(NSArray *)theNSArray;
//+(void)setTheMapLinesST:(NSArray *)theNSArray;
//+(void)setTheMapObjectsST:(NSArray *)theNSArray;
//+(void)setTheMapPolysST:(NSArray *)theNSArray;
//+(void)setTheMapLightsST:(NSArray *)theNSArray;


@end