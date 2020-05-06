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

enum/* export name types... */
{
    _data_has_no_name,
    _data_has_regular_name,
    _data_has_custom_name
};

enum/* export data primary, secondary, etc... */
{
    _data_is_primary,
    _data_is_secondary
};

enum /* export data types */
{
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
//#pragma mark ********* Level Info Enumerations *********

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
typedef NS_OPTIONS(int, _entry_point_flag)
{
	_single_player_entry_point = 0x01,
	_multiplayer_cooperative_entry_point = 0x02,
	_multiplayer_carnage_entry_point = 0x04,
	_capture_the_flag_entry_point = 0x08,
	_king_of_hill_entry_point = 0x10,
	_defense_entry_point= 0x20,
	_rugby_entry_point= 0x40
};

//! mission flags
typedef NS_OPTIONS(short,_mission_flag)
{
	_mission_none = 0x0000,
	_mission_extermination = 0x0001,
	_mission_exploration = 0x0002,
	_mission_retrieval = 0x0004,
	_mission_repair = 0x0008,
	_mission_rescue = 0x0010
};

//! environment flags
typedef NS_OPTIONS(short, _environment_flag)
{
	_environment_normal = 0x0000,
	_environment_vacuum = 0x0001,
	_environment_magnetic = 0x0002,
	_environment_rebellion = 0x0004,
	_environment_low_gravity = 0x0008,
	
	_environment_network = 0x2000,
	_environment_single_player = 0x4000
};

/* Game types! */
enum {
	_game_of_kill_monsters,		// single player & combative use this
	_game_of_cooperative_play,	// multiple players, working together
	_game_of_capture_the_flag,	// A team game.
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

// *****************  Class Blue Print  *****************
// #pragma mark ********* Class Blue Print *********

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
    NSMutableArray  *layerPoints, *layerLines, *layerPolys, *layerMapObjects, *layerNotes;
    NSMutableArray  *namedPolyObjects;
    NSMutableArray  *tags;
    
    NSMutableArray<Terminal*> *terimals;
    
    short unsigned objectCount, lineCount, pointCount, lightCount, polygonCount;
    short unsigned ambientSoundCount, randomSoundCount, platformCount, liquidCount;
    
    LELevelEnvironmentCode	environment_code;
    short	physics_model;
    short	song_index;
    _mission_flag	mission_flags;
    _environment_flag	environment_flags;
    
    short	unused[4];
    
    NSString	*level_name;
    _entry_point_flag	entry_point_flags;
    
    //LESide *defaultSide;
    LELine *defaultLine;
    
    LEMap *theLevelDocument;
    
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
    
    NSMutableArray *noteTypes;
    
    NSUndoManager *myUndoManager;
}


// **************  Inital Setup Methods  *************
-(void)compileAndSetNameArraysFromLevel;
-(void)setUpArrayNamesForEveryObject;

// **************  Coding/Copy Protocal Methods  *************
-(void) encodeWithCoder:(NSCoder *)coder;
-(id)initWithCoder:(NSCoder *)coder;

-(LELevelData *)initForNewPathwaysPIDLevel;
-(LELevelData *)initAndGenerateNewLevelObjects;

-(void)setupDefaultObjects;

- (NSData *)exportObjects:(NSSet *)objects;
- (NSSet *)importObjects:(NSData *)theData;

// ***************** Level Information Accessors  ****************

@property LELevelEnvironmentCode environmentCode;
@property short physicsModel;
@property (nonatomic) short songIndex;
@property _mission_flag missionFlags;
@property _environment_flag environmentFlags;
@property (copy) NSString *levelName;
@property _entry_point_flag entryPointFlags;

@end

// ••••••••••••••••••••••••••• OBJECT MANIPULATION •••••••••••••••••••••••••••

@interface LELevelData (LevelDataObjectManipulation)

// *************** Adding Objects To Level Array Methods ***************

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

    // ### Move following method to Pfhorge Independit Utility Functions ###
-(int)whatIsDirectionalRelationshipForLine:(LELine *)theLine relitiveTo:(NSArray *)lineArray;

// ****************** Deleteing Objects From Level Array Methods ******************

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

@interface LELevelData (LevelDataUtilites)

// ********* some additonal public utilites *********

- (void)havePointsScanForLines;

-(void)removeObjectsNotInMainArrays;

- (void)unionLevel:(LELevelData *)theLevelToImport;

-(NSInteger)tagIndexNumberFromTagNumber:(short)tagNumber;

-(Terminal *)getTerminalThatContains:(TerminalSection *)theTermSection;

-(void)setToDefaultState:(id)theObject;
-(void)makeDefault:(id)theObject;

-(void)addSidesForLine:(LELine *)theLine;
-(void)removeSidesFromLine:(LELine *)theLine;
-(void)setNameFor:(id)theObject to:(NSString *)theName;
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

@interface LELevelData (LevelLayers)

// **************** Layer Data Agirithms ****************

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

@interface LELevelData (LevelDataAccsessors)
// *****************  Level Data Accsessors  ****************

-(NSUndoManager *)myUndoManager;
-(void)setMyUndoManager:(NSUndoManager *)value;

- (NSArray *)getNoteTypes;
- (NSArray *)noteTypes;

-(void)setLevelDocument:(LEMap *)theDocument;

-(void)updateCounts;

-(unsigned short)ambientSoundCount;
-(unsigned short)liquidCount;
-(unsigned short)platformCount;
-(unsigned short)lightCount;
-(unsigned short)objectCount;
-(unsigned short)polygonCount;
-(unsigned short)lineCount;
-(unsigned short)pointCount;

-(LEMap *)levelDocument;


// The below arrays SHOULD NOT be added to manualy, or deleted from...
// Unless you know EXZACTLY what you are doing.  You should use the add and delete methods instead,
// I will be making more and expanding the add and delete methods soon.


-(NSMutableArray<LEMapPoint*> *)getThePoints;
//-(NSArray *)points;
-(NSMutableArray<LELine*> *)getTheLines;
-(NSMutableArray<LEPolygon*> *)getThePolys;
-(NSMutableArray<LEMapObject*> *)getTheMapObjects;

-(NSArray *)layerNotes;
-(NSMutableArray *)layerPoints;
-(NSMutableArray *)layerLines;
-(NSMutableArray *)layerPolys;
-(NSMutableArray *)layerMapObjects;

-(NSMutableArray *)layersInLevel;
-(NSMutableArray *)namedPolyObjects;

-(NSMutableArray<LESide*> *)getSides;
-(NSMutableArray<PhLight*> *)getLights;
-(NSMutableArray<PhAnnotationNote*> *)getNotes;
-(NSMutableArray<PhMedia*> *)getMedia;
-(NSMutableArray<PhAmbientSound*> *)getAmbientSounds;
-(NSMutableArray<PhRandomSound*> *)getRandomSounds;
-(NSMutableArray<PhItemPlacement*> *)getItemPlacement;
-(NSMutableArray<PhPlatform*> *)getPlatforms;

-(NSMutableArray *)getTags;

-(NSMutableArray *)getTerminals;

@end

// ••••••••••••••••••••••••••• LEVEL SETTINGS •••••••••••••••••••••••••••

@interface LELevelData (LevelSettings)

// **************** Level Specific Settings ****************
-(NSDecimalNumberHandler *)roundingSettings;

-(NSMutableDictionary *)getLevelOptionDictionary;
-(BOOL)settingExsists:(NSString *)key;
-(BOOL)settingAsBool:(NSString *)key;
-(float)settingAsFloat:(NSString *)key;
-(int)settingAsInt:(NSString *)key;

-(void)setSettingFor:(NSString *)key asBool:(BOOL)value;
-(void)setSettingFor:(NSString *)key asFloat:(float)value;
-(void)setSettingFor:(NSString *)key asInt:(int)value;

-(void)copyOptionsFromPrefs;

// ****************** Level Information Flag Accsessors  ****************

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

// These are methods that we probably wouldn't bother with if we weren't scriptable.
- (NSScriptObjectSpecifier *)objectSpecifier;

@end
