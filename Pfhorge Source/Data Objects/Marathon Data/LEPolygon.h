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
    LEPolygonNormal,
    LEPolygonItemImpassable,
    LEPolygonMonsterImpassable,
    //! for King of The Hill
    LEPolygonHill,
    //! for ctf, rugby, etc (team number in permutation)
    LEPolygonBase,
    //! Needs an object pointer? plaftform index
    LEPolygonPlatform,
    //! Needs an object pointer? light index
    LEPolygonLightOnTrigger,
    //! Needs an object pointer? poly index
    LEPolygonPlatformOnTrigger,
    //! Needs an object pointer? light index
    LEPolygonLightOffTrigger,
    //! Needs an object pointer? poly index
    LEPolygonPlatformOffTrigger,
    //! Needs an object pointer? poly index
    LEPolygonTeleporter,
    LEPolygonZoneBorder,
    //! Needs an object pointer?
    LEPolygonGoal,
    LEPolygonVisibleMonsterTrigger,
    LEPolygonInvisibleMonsterTrigger,
    LEPolygonDualMonsterTrigger,
    //! activates all items in this zone
    LEPolygonItemTrigger,
    LEPolygonMustBeExplored,
                                // Needs an object pointer?
    //! if success conditions are met, causes automatic transport to next level
    LEPolygonAutomaticExit,
    
    //! NOTE: New Marathon 1 types!!!
    //!   Add Support For These!
    LEPolygonMinorOuch,
    LEPolygonMajorOuch,
    LEPolygonGlue,
    LEPolygonGlueTrigger,
    LEPolygonSuperglue
};

typedef NS_OPTIONS(unsigned short, LEPolygonFlags) {
    POLYGON_IS_DETACHED_BIT = 0x4000,
};
#define POLYGON_IS_DETACHED (flags & POLYGON_IS_DETACHED_BIT)
#define SET_POLYGON_DETACHED_STATE(v) ((v) ? (flags |= POLYGON_IS_DETACHED_BIT) : (flags &= ~POLYGON_IS_DETACHED_BIT))

@class LEMapPoint, LELine, PhLayer;

#import "PhAbstractName.h"

@class PhLight, LESide, PhMedia;

@interface LEPolygon : PhAbstractName <NSSecureCoding>
{
    __unsafe_unretained PhLayer *polyLayer;
    
    // Program Polygonal Stuff
    BOOL polygonConcave;
    
    // Polygonal Data
    LEPolygonType	type;
    LEPolygonFlags	flags; // used to be of type word
    
    short	permutation;
    id		permutationObject;
    
    short 	vertexCountForPoly;
    short 	vertexIndexes[ MAXIMUM_VERTICES_PER_POLYGON ];
    LEMapPoint *vertexObjects[ MAXIMUM_VERTICES_PER_POLYGON ];
    
    short	lineIndexes [ MAXIMUM_VERTICES_PER_POLYGON ];
    LELine	*lineObjects [ MAXIMUM_VERTICES_PER_POLYGON ];
    
    short	floor_texture, ceiling_texture; // shape_descriptor - short
    short	floor_height, ceiling_height; // world_distance
    short	floor_lightsource_index, ceiling_lightsource_index;
    __unsafe_unretained PhLight		*floor_lightsource_object, __unsafe_unretained *ceiling_lightsource_object;
    
    int	area;		// in world distance^2
    
    short	first_object_index; // index added, is it really an index?
    __unsafe_unretained __kindof LEMapStuffParent	*first_object_pointer; // added pointer for less confusion...
    
    /* precalculated impassibility information; each polygon has
    a list of lines and points that anything big (i.e. monsters
    but not projectiles) inside it must check against when
    ending a move inside it */
    
    short	first_exclusion_zone_index;
    __kindof LEMapStuffParent	*first_exclusion_zone_object;
    short	line_exclusion_zone_count;
    short	point_exclusion_zone_count;
    
    short	floor_transfer_mode;
    short	ceiling_transfer_mode;
    
    short	adjacent_polygon_indexes[ MAXIMUM_VERTICES_PER_POLYGON ];
    __kindof LEMapStuffParent	*adjacent_polygon_objects[ MAXIMUM_VERTICES_PER_POLYGON ];
    
    // a list of polygons withing WORLD_ONE of us
    short	first_neighbor_index;
    __unsafe_unretained __kindof LEMapStuffParent	*first_neighbor_object;
    short	neighbor_count;
    
    NSPoint	center; //!< world_point2d is a NSPoint for now...
    
    short	side_indexes[ MAXIMUM_VERTICES_PER_POLYGON ];
    LESide	*side_objects[ MAXIMUM_VERTICES_PER_POLYGON ];
    
    
    NSPoint	floor_origin, ceiling_origin; //!< world_point2d is a NSPoint for now...
    
    short	media_index;
    __unsafe_unretained PhMedia	*media_object;
    short	media_lightsource_index;
    __unsafe_unretained __kindof LEMapStuffParent	*media_lightsource_object;
    
    /*! NONE terminated list of _saved_sound_source indexes
    which must be checked while a listener is inside this
    polygon (can be none) */
    short	sound_source_indexes; //???
    __unsafe_unretained __kindof LEMapStuffParent	*sound_source_objects; //???
    
    // either can be NONE
    short	ambient_sound_image_index;
    __unsafe_unretained __kindof LEMapStuffParent	*ambient_sound_image_object;
    short	random_sound_image_index;
    __unsafe_unretained __kindof LEMapStuffParent	*random_sound_image_object;
}


// ****************** Texture Methods ********************
-(void)setCeilingTextureOnly:(char)number;
-(void)setFloorTextureOnly:(char)number;
-(void)setCeilingTextureCollectionOnly:(char)number;
-(void)setFloorTextureCollectionOnly:(char)number;
-(void)resetTextureCollectionOnly;
-(void)setTextureCollectionOnly:(char)number;
@property char ceilingTextureOnly;
@property char floorTextureOnly;
@property char ceilingTextureCollectionOnly;
@property char floorTextureCollectionOnly;

//! I would not recommend using this function any more, since the ceiling could be different.
//! Before it was assumed that the floor and ceiling would be in the same colleciton,
//! that assumtion can not be made anymore...
@property char textureCollectionOnly;

// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)initWithPolygon:(LEPolygon *)thePolygonToImitate;


// ******************** Utilties ***********************
-(void)calculateSidesForAllLines;
-(int)getLineNumberFor:(LELine *)theLine;
-(void)setLightsThatAre:(PhLight*)theLightInQuestion to:(PhLight*)setToLight;
-(void)thePolyMap:(NSBezierPath *)poly;
-(void)removeAssociationOfObject:(__kindof LEMapStuffParent*)theObj;
-(void)setAllAdjacentPolygonPointersToNil;

// ****************** Polygon Layer *********************
@property (nonatomic, assign) PhLayer *polyLayer;

// ********************* Acessor Methods *********************

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

-(void)setVertexWith:(short)v toIndex:(short)i; //
-(void)setVertexWithObject:(LEMapPoint*)v toIndex:(short)i;

-(void)setLines:(short)v toIndex:(short)i; //
-(void)setLinesObject:(LELine*)v toIndex:(short)i;

-(void)setFloorTexture:(short)v;
-(void)setCeilingTexture:(short)v;

-(void)setFloorHeightNoSides:(short)v;
-(void)setCeilingHeightNoSides:(short)v;

-(void)setFloorHeight:(short)v;
-(void)setCeilingHeight:(short)v;

@property (readonly, copy) NSDecimalNumber *floorHeightAsDecimal;
@property (readonly, copy) NSDecimalNumber *ceilingHeightAsDecimal;

@property (readonly, copy) NSString *floorHeightAsDecimalString;
@property (readonly, copy) NSString *ceilingHeightAsDecimalString;

-(void)setFloorLightsource:(short)v; //

-(void)setCeilingLightsource:(short)v; //

-(void)setArea:(int)v;

-(void)setFirstObject:(short)v; //
-(void)setFirstObjectObject:(id)v;

-(void)setFirstExclusionZoneIndex:(short)v;
-(void)setLineExclusionZoneCount:(short)v;
-(void)setPointExclusionZoneCount:(short)v;

-(void)setFloorTransferMode:(short)v;
-(void)setCeilingTransferMode:(short)v;

-(void)setAdjacentPolygon:(short)v toIndex:(short)i; //
-(void)setAdjacentPolygonObject:(id)v toIndex:(short)i;

-(void)setFirstNeighbor:(short)v; //
-(void)setFirstNeighborObject:(id)v;

-(void)setNeighborCount:(short)v;

-(void)setSides:(short)v toIndex:(short)i; //
-(void)setSidesObject:(LESide*)v toIndex:(short)i;

-(void)setMedia:(short)v API_DEPRECATED_WITH_REPLACEMENT("-setMediaIndex:", macos(10.0, 10.7)); //
-(void)setMediaIndex:(short)v; //
@property (assign) PhMedia *mediaObject;

-(void)setMediaLightsource:(short)v; //
@property (assign) id mediaLightsourceObject;

-(void)setSoundSources:(short)v; //
@property (assign) id soundSourcesObject;

-(void)setAmbientSound:(short)v; //
@property (assign) id ambientSoundObject;

-(void)setRandomSound:(short)v; //
@property (assign) id randomSoundObject;


// ********** Get **********
@property BOOL polygonConcaveFlag;

@property (nonatomic) LEPolygonType type;
@property LEPolygonFlags flags;
@property short permutation;
-(id)permutationObject;

-(short *)getTheVertexes NS_RETURNS_INNER_POINTER; // might want to have this option avaliable for all c arrays in this object?
-(short)getTheVertexCount;

-(short)vertexIndexesAtIndex:(short)i; //
-(short)lineIndexesAtIndex:(short)i; ///
@property (readonly, copy) NSArray<LEMapPoint*> *vertexArray;
-(LEMapPoint*)vertexObjectAtIndex:(short)i; ///
@property (readonly, copy) NSArray<LELine*> *lineArray;
-(LELine*)lineObjectAtIndex:(short)i; ///
//-(id)getLineObjects; ///

@property short floorTexture;
@property short ceilingTexture;
@property (nonatomic) short floorHeight;
@property (nonatomic) short ceilingHeight;

@property (readonly) short floorLightsourceIndex; //
@property (readonly) short ceilingLightsourceIndex; //
@property (assign) PhLight *floorLightsourceObject; //
@property (assign) PhLight *ceilingLightsourceObject; //

@property int area;

@property (readonly) short firstObjectIndex; //
-(id)firstNeighborObject; //

@property short firstExclusionZoneIndex;
@property short lineExclusionZoneCount;
@property short pointExclusionZoneCount;
@property short floorTransferMode;
@property short ceilingTransferMode;

-(short)adjacentPolygonIndexesAtIndex:(short)i; //
-(id)adjacentPolygonObjectAtIndex:(short)i; //

@property (readonly) short firstNeighborIndex; //
@property short neighborCount;
@property (readwrite) NSPoint center;

-(short)sideIndexesAtIndex:(short)i; //
-(LESide*)sideObjectAtIndex:(short)i; //

@property NSPoint floorOrigin;
@property NSPoint ceilingOrigin;

@property short mediaIndex; //
@property (readonly) short mediaLightsourceIndex; //
@property (readonly) short soundSourceIndexes; //
@property (readonly) short ambientSoundImageIndex; //
@property (readonly) short randomSoundImageIndex; //

- (void)render;

// **************************** Polygon Concave Verification ***********************************
@property (readonly, getter=isPolygonConcave) BOOL polygonConcave;

@end
