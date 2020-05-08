//
//  LEPolygon.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon Jun 18 2001.
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
#import <Cocoa/Cocoa.h>
#import "LEMapStuffParent.h"
#import "PhLayer.h"
//#import "LEMarathon2Structres.h"

// ********* Polygon Object enum's, macro functions, and constants *********

#define MAXIMUM_VERTICES_PER_POLYGON 8

//! polygon types
typedef NS_ENUM(short, LEPolygonType) {
    _polygon_is_normal,
    _polygon_is_item_impassable,
    _polygon_is_monster_impassable,
    //! for King of The Hill
    _polygon_is_hill,
    //! for ctf, rugby, etc (team number in permutation)
    _polygon_is_base,
    //! Needs an object pointer? plaftform index
    _polygon_is_platform,
    //! Needs an object pointer? light index
    _polygon_is_light_on_trigger,
    //! Needs an object pointer? poly index
    _polygon_is_platform_on_trigger,
    //! Needs an object pointer? light index
    _polygon_is_light_off_trigger,
    //! Needs an object pointer? poly index
    _polygon_is_platform_off_trigger,
    //! Needs an object pointer? poly index
    _polygon_is_teleporter,
    _polygon_is_zone_border,
    //! Needs an object pointer?
    _polygon_is_goal,
    _polygon_is_visible_monster_trigger,
    _polygon_is_invisible_monster_trigger,
    _polygon_is_dual_monster_trigger,
    //! activates all items in this zone
    _polygon_is_item_trigger,
    _polygon_must_be_explored,
                                // Needs an object pointer?
    //! if success conditions are met, causes automatic transport to next level
    _polygon_is_automatic_exit,
    
    // NOTE: New Marathon 1 types!!!
    //   Add Support For These!
    _polygon_is_minor_ouch,
    _polygon_is_major_ouch,
    _polygon_is_glue,
    _polygon_is_glue_trigger,
    _polygon_is_superglue
};

typedef NS_OPTIONS(unsigned short, LEPolygonFlags) {
    POLYGON_IS_DETACHED_BIT = 0x4000,
};
#define POLYGON_IS_DETACHED (flags & POLYGON_IS_DETACHED_BIT)
#define SET_POLYGON_DETACHED_STATE(v) ((v) ? (flags |= POLYGON_IS_DETACHED_BIT) : (flags &= ~POLYGON_IS_DETACHED_BIT))

@class LEMapPoint, LELine, PhLayer;

#import "PhAbstractName.h"

@interface LEPolygon : PhAbstractName <NSCoding>
{
    PhLayer *polyLayer;
    
    // Program Polygonal Stuff
    BOOL polygonConcave;
    
    // Polygonal Data
    LEPolygonType	type;
    LEPolygonFlags	flags; // used to be of type word
    
    short	permutation;
    id		permutationObject;
    
    short 	vertexCountForPoly;
    short 	vertexIndexes[ MAXIMUM_VERTICES_PER_POLYGON ];
    id	 	vertexObjects[ MAXIMUM_VERTICES_PER_POLYGON ];
    
    short	lineIndexes [ MAXIMUM_VERTICES_PER_POLYGON ];
    id		lineObjects [ MAXIMUM_VERTICES_PER_POLYGON ];
    
    short	floor_texture, ceiling_texture; // shape_descriptor - short
    short	floor_height, ceiling_height; // world_distance
    short	floor_lightsource_index, ceiling_lightsource_index;
    __unsafe_unretained id		floor_lightsource_object, ceiling_lightsource_object;
    
    int	area;		// in world distance^2
    
    short	first_object_index; // index added, is it really an index?
    id		first_object_pointer; // added pointer for less confusion...
    
    /* precalculated impassibility information; each polygon has
    a list of lines and points that anything big (i.e. monsters
    but not projectiles) inside it must check against when
    ending a move inside it */
    
    short	first_exclusion_zone_index;
    id		first_exclusion_zone_object;
    short	line_exclusion_zone_count;
    short	point_exclusion_zone_count;
    
    short	floor_transfer_mode;
    short	ceiling_transfer_mode;
    
    short	adjacent_polygon_indexes[ MAXIMUM_VERTICES_PER_POLYGON ];
    id		adjacent_polygon_objects[ MAXIMUM_VERTICES_PER_POLYGON ];
    
    // a list of polygons withing WORLD_ONE of us
    short	first_neighbor_index;
    id		first_neighbor_object;
    short	neighbor_count;
    
    NSPoint	center; //world_point2d is a NSPoint for now...
    
    short	side_indexes[ MAXIMUM_VERTICES_PER_POLYGON ];
    id		side_objects[ MAXIMUM_VERTICES_PER_POLYGON ];
    
    
    NSPoint	floor_origin, ceiling_origin; //world_point2d is a NSPoint for now...
    
    short	media_index;
    id		media_object;
    short	media_lightsource_index;
    id		media_lightsource_object;
    
    /* NONE terminated list of _saved_sound_source indexes
    which must be checked while a listener is inside this
    polygon (can be none) */
    short	sound_source_indexes; //???
    id		sound_source_objects; //???
    
    // either can be NONE
    short	ambient_sound_image_index;
    id		ambient_sound_image_object;
    short	random_sound_image_index;
    id		random_sound_image_object;
    
    short	unused[1];
}


// ****************** Texture Methods ********************
-(void)setCeilingTextureOnly:(char)number;
-(void)setFloorTextureOnly:(char)number;
-(void)setCeilingTextureCollectionOnly:(char)number;
-(void)setFloorTextureCollectionOnly:(char)number;
-(void)resetTextureCollectionOnly;
-(void)setTextureCollectionOnly:(char)number;
-(char)ceilingTextureOnly;
-(char)floorTextureOnly;
-(char)ceilingTextureCollectionOnly;
-(char)floorTextureCollectionOnly;

// I would not reccemend using this function any more, since the ceiling could be diffrent.
// Before is was assumed that the floor and ceiling would be in the same colleciton,
// that assumtion can not be made anymore...
-(char)textureCollectionOnly;

// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)initWithPolygon:(LEPolygon *)thePolygonToImitate;


// ******************** Utilties ***********************
-(void)calculateSidesForAllLines;
-(int)getLineNumberFor:(LELine *)theLine;
-(void)setLightsThatAre:(id)theLightInQuestion to:(id)setToLight;
-(void)thePolyMap:(NSBezierPath *)poly;
-(void)removeAssoticationOf:(id)theObj;
-(void)setAllAdjacentPolygonPointersToNil;

// ****************** Polygon Layer *********************
-(PhLayer *)polyLayer;
-(void)setPolyLayer:(PhLayer *)theLayer;

// ********************* Acessor Methods *********************
// ********** Set **********
-(void)setPolygonConcaveFlag:(BOOL)v;

-(void)setType:(LEPolygonType)v;
-(void)setFlags:(LEPolygonFlags)v;
-(void)setPermutation:(short)v;

-(void)setPermutationObject:(id)theObject;

-(void)setVertextCount:(short)vCount;
-(void)setV1:(short)v; //
-(void)setV2:(short)v; //
-(void)setV3:(short)v; //
-(void)setV4:(short)v; //
-(void)setV5:(short)v; //
-(void)setV6:(short)v; //
-(void)setV7:(short)v; //
-(void)setV8:(short)v; //

-(void)setVertexWith:(short)v i:(short)i; //
-(void)setVertexWithObject:(id)v i:(short)i;

-(void)setLines:(short)v i:(short)i; //
-(void)setLinesObject:(id)v i:(short)i;

-(void)setFloorTexture:(short)v;
-(void)setCeilingTexture:(short)v;

-(void)setFloor_height_no_sides:(short)v;
-(void)setCeiling_height_no_sides:(short)v;

-(void)setFloor_height:(short)v;
-(void)setCeiling_height:(short)v;

-(NSDecimalNumber *)getFloor_height_decimal;
-(NSDecimalNumber *)getCeiling_height_decimal;

-(NSString *)getFloor_height_decimal_string;
-(NSString *)getCeiling_height_decimal_string;

-(void)setFloor_lightsource:(short)v; //
-(void)setFloor_lightsourceObject:(id)v;

-(void)setCeiling_lightsource:(short)v; //
-(void)setCeiling_lightsourceObject:(id)v;

-(void)setArea:(int)v;

-(void)setFirst_object:(short)v; //
-(void)setFirst_objectObject:(id)v;

-(void)setFirst_exclusion_zone_index:(short)v;
-(void)setLine_exclusion_zone_count:(short)v;
-(void)setPoint_exclusion_zone_count:(short)v;

-(void)setFloor_transfer_mode:(short)v;
-(void)setCeiling_transfer_mode:(short)v;

-(void)setAdjacent_polygon:(short)v i:(short)i; //
-(void)setAdjacent_polygonObject:(id)v i:(short)i;

-(void)setFirst_neighbor:(short)v; //
-(void)setFirst_neighborObject:(id)v;

-(void)setNeighbor_count:(short)v;
-(void)setCenter:(NSPoint)v;

-(void)setSides:(short)v i:(short)i; //
-(void)setSidesObject:(id)v i:(short)i;

-(void)setFloor_origin:(NSPoint)v;
-(void)setCeiling_origin:(NSPoint)v;

-(void)setMedia:(short)v; //
-(void)setMediaIndex:(short)v; //
-(void)setMediaObject:(id)v;

-(void)setMedia_lightsource:(short)v; //
-(void)setMedia_lightsourceObject:(id)v;

-(void)setSound_sources:(short)v; //
-(void)setSound_sourcesObject:(id)v;

-(void)setAmbient_sound:(short)v; //
-(void)setAmbient_soundObject:(id)v;

-(void)setRandom_sound:(short)v; //
-(void)setRandom_soundObject:(id)v;


// ********** Get **********
-(BOOL)getPolygonConcaveFlag;

-(LEPolygonType)getType;
-(LEPolygonFlags)getFlags;
-(short)getPermutation;
-(id)getPermutationObject;

-(short *)getTheVertexes NS_RETURNS_INNER_POINTER; // might want to have this option avaliable for all c arrays in this object?
-(short)getTheVertexCount;

-(short)getVertexIndexes:(short)i; //
-(short)getLineIndexes:(short)i; ///
-(NSArray *)getVertexArray;
-(id)getVertexObject:(short)i; ///
-(NSArray *)getLineArray;
-(id)getLineObject:(short)i; ///
//-(id)getLineObjects; ///

-(short)getFloor_texture;
-(short)getCeiling_texture;
-(short)getFloor_height;
-(short)getCeiling_height;

-(short)getFloor_lightsource_index; //
-(short)getCeiling_lightsource_index; //
-(id)getFloor_lightsource_object; //
-(id)getCeiling_lightsource_object; //

-(int)getArea;

-(short)getFirst_object_index; //
-(id)getFirst_neighbor_object; //

-(short)getFirst_exclusion_zone_index;
-(short)getLine_exclusion_zone_count;
-(short)getPoint_exclusion_zone_count;
-(short)getFloor_transfer_mode;
-(short)getCeiling_transfer_mode;

-(short)getAdjacent_polygon_indexes:(short)i; //
-(id)getAdjacent_polygon_objects:(short)i; //

-(short)getFirst_neighbor_index; //
-(short)getNeighbor_count;
-(NSPoint)getCenter;

-(short)getSide_indexes:(short)i; //
-(id)getSide_objects:(short)i; //

-(NSPoint)getFloor_origin;
-(NSPoint)getCeiling_origin;

-(short)getMedia_index; //
-(short)getMedia_lightsource_index; //
-(short)getSound_source_indexes; //
-(short)getAmbient_sound_image_index; //
-(short)getRandom_sound_image_index; //

- (void)render;

// **************************** Polygon Concave Verification ***********************************
@property (readonly, getter=isPolygonConcave) BOOL polygonConcave;

@end
