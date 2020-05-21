//
//  LELevelData.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Jun 16 2001.
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
#import "LEPolygon.h"
#import "PhLevelNameManager.h"


#define GET_MISSION_FLAG(b) (mission_flags & (b))
#define SET_MISSION_FLAG(b, v) ((v) ? (mission_flags |= (b)) : (mission_flags &= ~(b)))

#define GET_ENVIRONMENT_FLAG(b) (environment_flags & (b))
#define SET_ENVIRONMENT_FLAG(b, v) ((v) ? (environment_flags |= (b)) : (environment_flags &= ~(b)))

#define GET_ENTRY_FLAG(b) (entry_point_flags & (b))
#define SET_ENTRY_FLAG(b, v) ((v) ? (entry_point_flags |= (b)) : (entry_point_flags &= ~(b)))

/*! export name types... */
typedef NS_ENUM(short, _data_name_export) {
    _data_has_no_name,
    _data_has_regular_name,
    _data_has_custom_name
};

enum/* export data primary, secondary, etc... */
{
    _data_is_primary,
    _data_is_secondary
};

/*! export data types */
typedef NS_ENUM(short, _data_type_export) {
	_data_is_polygon,
	_data_is_line,
	_data_is_object,
	_data_is_side,
	_data_is_point,
	_data_is_media,
	_data_is_light,
	_data_is_tag,
	_data_is_annotationNote,
	_data_is_ambientSound,
	_data_is_randomSound,
	_data_is_itemPlacement,
	_data_is_platform,
	_data_is_terminal,
	_data_is_terminalSection,
	_data_is_layer,
	_data_is_unknown
};


// **************************  Level Info Enumerations  *************************
#pragma mark Level Info Enumerations

enum /* clockwise/counterclockwise line result*/
{
	_line_is_counter_clockwise = 1,
	_line_is_clockwise = 0,
	_poly_could_be_bad = -1,
	_unknown = -2
};

enum /* environment_code codes */
{
	_water = 0,
	_lava,
	_sewage,
	_jjaro,
	_pfhor
};

/*! environment_code wall textre collection */
typedef NS_ENUM(short, LELevelEnvironmentCode) {
	_water_collection = 0x11, // 17
	_lava_collection, // 18
	_sewage_collection, // 19
	_jjaro_collection, // 20
	_pfhor_collection, // 21
	_landscape_collection_1 = 0x1B,
	_landscape_collection_2,
	_landscape_collection_3,
	_landscape_collection_4
};

//! entry point types - this is per map level (long)
typedef NS_OPTIONS(int, LELevelEntryPointFlags) {
	LELevelEntryPointSinglePlayer = 0x01,
	LELevelEntryPointMultiplayerCooperative = 0x02,
	LELevelEntryPointMultiplayerCarnage = 0x04,
	LELevelEntryPointMultiplayerCaptureTheFlag = 0x08,
	LELevelEntryPointMultiplayerKingOfTheHill = 0x10,
	LELevelEntryPointDefense= 0x20,
	LELevelEntryPointMultiplayerRugby= 0x40
};

//! mission flags
typedef NS_OPTIONS(unsigned short, LELevelMissionFlags) {
	LELevelMissionNone = 0x0000,
	LELevelMissionExtermination = 0x0001,
	LELevelMissionExploration = 0x0002,
	LELevelMissionRetrieval = 0x0004,
	LELevelMissionRepair = 0x0008,
	LELevelMissionRescue = 0x0010
};

//! environment flags
typedef NS_OPTIONS(unsigned short, LELevelEnvironmentFlags) {
	LELevelEnvironmentNormal = 0x0000,
	LELevelEnvironmentVacuum = 0x0001,
	LELevelEnvironmentMagnetic = 0x0002,
	LELevelEnvironmentRebellion = 0x0004,
	LELevelEnvironmentLowGravity = 0x0008,
	
	LELevelEnvironmentNetwork = 0x2000,
	LELevelEnvironmentSinglePlayer = 0x4000
};

/* Game types! */
enum {
	//! single player & combative use this
	_game_of_kill_monsters,
	//! multiple players, working together
	_game_of_cooperative_play,
	//! A team game.
	_game_of_capture_the_flag,
	_game_of_king_of_the_hill,
	_game_of_kill_man_with_ball,
	_game_of_defense,
	_game_of_rugby,
	//_game_of_tag,
	NUMBER_OF_GAME_TYPES
};

#import "LEMapObject.h"

@class LEMapPoint, LELine, PhPlatform, LEMapStuffParent,
       LESide, PhLayer, PhLight, PhTag, LEMap, Terminal,
       TerminalSection, PhNoteGroup, PhRandomSound, PhMedia,
       PhAnnotationNote, PhItemPlacement, PhAmbientSound;
@class PhLayer;
// *****************  Class Blue Print  *****************
#pragma mark Class Blueprint

@interface LELevelData : PhLevelNameManager <NSCoding>
{
    NSMutableArray<LEMapPoint*> *points;
    NSMutableArray<LELine*> *lines;
    NSMutableArray<LEPolygon*> *polys;
    NSMutableArray<LEMapObject*> *mapObjects;
    NSMutableArray<LESide*> *sides;
    NSMutableArray<PhLight*> *lights;
    NSMutableArray<PhAnnotationNote*> *notes;
    NSMutableArray<PhMedia*> *media;
    NSMutableArray<PhAmbientSound*> *ambientSounds;
    
    NSMutableArray<PhRandomSound*> *randomSounds;
    NSMutableArray<PhItemPlacement*> *itemPlacement;
    NSMutableArray<PhPlatform*> *platforms;
    
    NSMutableArray<PhLayer*>  *layersInLevel;
	PhLayer	    *currentLayer;
    // Should make these sets...
	NSMutableArray<LEMapPoint*>  *layerPoints;
	NSMutableArray<LELine*>  *layerLines;
	NSMutableArray<LEPolygon*>  *layerPolys;
	NSMutableArray<LEMapObject*>  *layerMapObjects;
	NSMutableArray<PhAnnotationNote*>  *layerNotes;
    NSMutableArray<LEPolygon*>  *namedPolyObjects;
    NSMutableArray<PhTag*>  *tags;
    
    NSMutableArray<Terminal*> *terimals;
    
    short unsigned objectCount, lineCount, pointCount, lightCount, polygonCount;
    short unsigned ambientSoundCount, randomSoundCount, platformCount, liquidCount;
    
    short	environment_code;
    short	physics_model;
    short	song_index;
    LELevelMissionFlags	mission_flags;
    LELevelEnvironmentFlags	environment_flags;
    
    NSString	*level_name;
    LELevelEntryPointFlags	entry_point_flags;
    
    //LESide *defaultSide;
    LELine *defaultLine;
    
    __unsafe_unretained LEMap *theLevelDocument;
    
    // *** Default Object Pointers ***
    LEMapObject *defaultObjects[_NUMBER_OF_OBJECT_TYPES];
    LEPolygon 	*defaultPolygon;
    LESide	*defaultSide;
    LESide	*cDefaultSide;
    LESide	*ccDefaultSide;
    BOOL	ccHasDefaultSide;
    BOOL	cHasDefaultSide;
    
    NSDecimalNumberHandler *defaultRoundingBehavior;
    
    NSMutableDictionary *levelOptions;
    
    NSMutableArray<PhNoteGroup*> *noteTypes;
    
    __weak NSUndoManager *myUndoManager;
}

@property (weak) NSUndoManager *myUndoManager;

#pragma mark Level Specific Settings
@property (readonly, strong) NSDecimalNumberHandler *roundingSettings;


#pragma mark Inital Setup Methods

//! Called after loading a marathon formated map, to set thePhName of lights, etc.
//! and to put those names in the name manager cache.
-(void)compileAndSetNameArraysFromLevel;
//! Called after loading a Pfhorge formated map, to get thePhName of lights, etc.
//! and to put those names in the name manager cache.
-(void)setUpArrayNamesForEveryObject;

#pragma mark Coding/Copy Protocal Methods
- (void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithCoder:(NSCoder *)coder;

- (instancetype)initForNewPathwaysPIDLevel;
- (instancetype)initAndGenerateNewLevelObjects;

- (void)setupDefaultObjects;

- (NSData *)exportObjects:(NSSet<__kindof LEMapStuffParent*> *)objects;
- (NSSet<__kindof LEMapStuffParent*> *)importObjects:(NSData *)theData;

#pragma mark Level Information Accessors

@property short environmentCode;
@property short physicsModel;
@property (nonatomic) short songIndex;
@property LELevelMissionFlags missionFlags;
@property LELevelEnvironmentFlags environmentFlags;
@property (copy) NSString *levelName;
@property LELevelEntryPointFlags entryPointFlags;

@end

// ••••••••••••••••••••••••••• OBJECT MANIPULATION •••••••••••••••••••••••••••
#pragma mark - Object Manipulation

@interface LELevelData (LevelDataObjectManipulation)

#pragma mark Adding Objects To Level Array Methods

-(id)addObjectWithDefaults:(Class)theClass;
-(void)addObjects:(id)objectToAdd;
-(PhTag *)addNewTagWithNumber:(NSNumber *)theTagNumber;
-(void)addPlatform:(PhPlatform *)thePlatformToAdd;
-(void)addPoint:(LEMapPoint *)thePointToAdd;
-(void)addLine:(LELine *)theLineToAdd;
-(void)addPolygonDirectly:(LEPolygon *)thePolyToAdd;
-(void)addPolygon:(LEPolygon *)thePolyToAdd;
- (PhNoteGroup *)newNoteType;
- (PhNoteGroup *)newNoteType:(NSString *)name;

    // TODO: Move following method to Pfhorge Independit Utility Functions
-(int)whatIsDirectionalRelationshipForLine:(LELine *)theLine relitiveTo:(NSArray *)lineArray;

#pragma mark Deleteing Objects From Level Array Methods

-(void)deleteObject:(id)objectToDelete;
-(void)deleteLevelObject:(LEMapObject *)theLevelObjectToRemove;
-(void)deleteLight:(PhLight *)theLightToRemove;
-(void)deleteSide:(LESide *)theSideToRemove;
-(void)deletePoint:(LEMapPoint *)thePointToRemove;
-(void)deleteLine:(LELine *)theLineToRemove;
-(void)deletePolygon:(LEPolygon *)thePolyToRemove;
-(void)deletePlatform:(PhPlatform *)thePlatformToRemove;

@end

// ••••••••••••••••••••••••••• UTILTIES •••••••••••••••••••••••••••
#pragma mark - Utilities

@interface LELevelData (LevelDataUtilites)

#pragma mark some additonal public utilites

- (void)havePointsScanForLines;

-(void)removeObjectsNotInMainArrays;

- (void)unionLevel:(LELevelData *)theLevelToImport;

-(NSInteger)tagIndexNumberFromTagNumber:(short)tagNumber;

-(Terminal *)getTerminalThatContains:(TerminalSection *)theTermSection;

-(void)setToDefaultState:(id)theObject;
-(void)makeDefault:(id)theObject;

-(void)addSidesForLine:(LELine *)theLine;
-(void)removeSidesFromLine:(LELine *)theLine;
-(void)setNameFor:(__kindof LEMapStuffParent*)theObject to:(NSString *)theName;
-(void)namePolygon:(LEPolygon *)thePoly to:(NSString *)theName;
-(void)removeNameOfPolygon:(LEPolygon *)thePoly;

-(void)resetAdjacentPolygonAssociations;


-(void)recompileTerminalNamesCache;

-(void)findObjectsAssociatedWith:(id)theObj putIn:(NSMutableSet *)theObjects;

-(void)setUpArrayPointersFor:(LEMapStuffParent *)theObject;
-(void)setUpArrayPointersForEveryObject;

-(void)adjustInitalItemPlacmentBy:(int)adjustmentNumber forIndex:(int)objectIndex isMonster:(BOOL)adjustingMonster;



@end

// ••••••••••••••••••••••••••• LAYERS •••••••••••••••••••••••••••
#pragma mark - Layers

@interface LELevelData (LevelLayers)

#pragma mark Layer Data Algorithms

-(void)setupLayersForNewPIDLevel;
-(void)setupLayers;
-(int)getLayerModeIndex; // zero is no layer
-(void)recaculateTheCurrentLayer;
-(void)setLayerModeToIndex:(int)layerIndexNumber; // zero is no layer
-(void)setLayerModeTo:(PhLayer *)theLayer;
-(void)setCurrentLayerToLastLayer;
-(void)removeLayer:(PhLayer *)theLayer;
-(void)addLayer:(PhLayer *)theLayer;

@end

// ••••••••••••••••••••••••••• DATA ACCSESSORS •••••••••••••••••••••••••••
#pragma mark - Data Accessors

@interface LELevelData (LevelDataAccsessors)
#pragma mark Level Data Accsessors

- (NSArray *)getNoteTypes API_DEPRECATED_WITH_REPLACEMENT("-noteTypes", macos(10.0, 10.7));
- (NSArray<PhNoteGroup*> *)noteTypes;

-(void)setLevelDocument:(LEMap *)theDocument;

-(void)updateCounts;

@property (readonly) unsigned short ambientSoundCount;
@property (readonly) unsigned short liquidCount;
@property (readonly) unsigned short platformCount;
@property (readonly) unsigned short lightCount;
@property (readonly) unsigned short objectCount;
@property (readonly) unsigned short polygonCount;
@property (readonly) unsigned short lineCount;
@property (readonly) unsigned short pointCount;

-(LEMap *)levelDocument;


// The below arrays SHOULD NOT be added to manualy, or deleted from...
// Unless you know EXACTLY what you are doing.  You should use the add and delete methods instead,
// I will be making more and expanding the add and delete methods soon.


-(NSArray<LEMapPoint*> *)points;
-(NSArray<LELine*> *)lines;
-(NSArray<LEPolygon*> *)polygons;
-(NSArray<LEMapObject*> *)theMapObjects;

-(NSArray<PhAnnotationNote*> *)layerNotes;
-(NSArray<LEMapPoint*> *)layerPoints;
-(NSArray<LELine*> *)layerLines;
-(NSArray<LEPolygon*> *)layerPolys;
-(NSArray<LEMapObject *> *)layerMapObjects;

-(NSArray<PhLayer*> *)layersInLevel;
-(NSArray<LEPolygon*> *)namedPolyObjects;

-(NSArray<LESide*> *)sides;
-(NSArray<PhLight*> *)lights;
-(NSArray<PhAnnotationNote*> *)notes;
-(NSArray<PhMedia*> *)media;
-(NSArray<PhAmbientSound*> *)ambientSounds;
-(NSArray<PhRandomSound*> *)randomSounds;
-(NSArray<PhItemPlacement*> *)itemPlacement;
-(NSArray<PhPlatform*> *)platforms;

-(NSArray<PhTag*> *)tags;

-(NSArray<Terminal*> *)terminals;

@end

// ••••••••••••••••••••••••••• LEVEL SETTINGS •••••••••••••••••••••••••••
#pragma mark - Level Settings

@interface LELevelData (LevelSettings)

#pragma mark Level Specific Settings

-(NSMutableDictionary *)getLevelOptionDictionary;
-(BOOL)settingExsists:(NSString *)key;
-(BOOL)settingAsBool:(NSString *)key;
-(float)settingAsFloat:(NSString *)key;
-(int)settingAsInt:(NSString *)key;

-(void)setSettingFor:(NSString *)key asBool:(BOOL)value;
-(void)setSettingFor:(NSString *)key asFloat:(float)value;
-(void)setSettingFor:(NSString *)key asInt:(int)value;

-(void)copyOptionsFromPrefs;

#pragma mark Level Information Flag Accsessors

@property (nonatomic, readonly, getter=isEnvironmentNormal) BOOL environmentNormal;
-(void)setEnvironmentNormal;
@property (nonatomic, getter=isEnvironmentVacuum) BOOL environmentVacuum;
@property (nonatomic, getter=isEnvironmentMagnetic) BOOL environmentMagnetic;
@property (nonatomic, getter=isEnvironmentRebellion) BOOL environmentRebellion;
@property (nonatomic, getter=isEnvironmentLowGravity) BOOL environmentLowGravity;
@property (nonatomic, getter=isEnvironmentNetwork) BOOL environmentNetwork;
@property (nonatomic, getter=isEnvironmentSinglePlayer) BOOL environmentSinglePlayer;

@property (nonatomic, getter=isMissionExtermination) BOOL missionExtermination;
@property (nonatomic, getter=isMissionExploration) BOOL missionExploration;
@property (nonatomic, getter=isMissionRetrieval) BOOL missionRetrieval;
@property (nonatomic, getter=isMissionRepair) BOOL missionRepair;
@property (nonatomic, getter=isMissionRescue) BOOL missionRescue;

@property (nonatomic, getter=isGameTypeSinglePlayer) BOOL gameTypeSinglePlayer;
@property (nonatomic, getter=isGameTypeCooperative) BOOL gameTypeCooperative;
@property (nonatomic, getter=isGameTypeMultiplayerCarnage) BOOL gameTypeMultiplayerCarnage;
@property (nonatomic, getter=isGameTypeCaptureTheFlag) BOOL gameTypeCaptureTheFlag;
@property (nonatomic, getter=isGameTypeKingOfTheHill) BOOL gameTypeKingOfTheHill;
@property (nonatomic, getter=isGameTypeDefense) BOOL gameTypeDefense;
@property (nonatomic, getter=isGameTypeRugby) BOOL gameTypeRugby;

//! These are methods that we probably wouldn't bother with if we weren't scriptable.
- (NSScriptObjectSpecifier *)objectSpecifier;

@end
