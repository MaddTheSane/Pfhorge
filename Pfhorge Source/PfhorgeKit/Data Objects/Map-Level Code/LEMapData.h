//
//  LEMapData.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 10 2001.
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
#import <PfhorgeKit/LELevelData.h>

typedef unsigned int LevelTagType;

/*! 128 bytes, wad_header (map_header) */
typedef struct SMainMapHeader
{
    short version;
    short dataVersion;
    char *theName; //[64]; //May have to send a retain message so the char this points to is not lost?
    unsigned int checksum; // ??? How To Caculate This ???
    int mapSize; // This is bascialy the location of the trailer headers at end of map file...
    short numberOfLevels;
    short applicationSpecificDirectoryDataSize;
    short entryHeaderSize; /* if not 16, then STagHeader may be diffrent? */
    short directoryEntryBaseSize; /* if not 10, then SLevelHeader may be diffrent? */
     // ??? How To Caculate This ???
    unsigned int parentChecksum; /* if non-zero, this is the checksum of our parent, and we are simply modifications! */
    short unused[20];
} MainMapHeaderTag;

/*! 10 bytes, directory_entry */
typedef struct SLevelHeader
{
    /*! From start of file */
    int offsetToStart;
    /*! Of total level */
    int length;
    /*! For inplace modification of the mapfile! */
    short index;
} SLevelHeaderTag;

/*! 16 bytes, entry_header */
typedef struct STagHeader
{
    /*! 4 character ACSII string signifying chunk(tag) type (unsigned long) */
    LevelTagType offsetToStart;
    /*! From current file location -> ie SLevelHeader.offsetToStart + nextOffset */
    int nextOffset;
    /*! length Of entry */
    int length;
    /*! Offset for inplace expansion of data */
    int offset;
} STagHeaderTag;



enum {
    PRE_ENTRY_POINT_WADFILE_VERSION	= 0,
    WADFILE_HAS_DIRECTORY_ENTRY		= 1,
    WADFILE_SUPPORTS_OVERLAYS		= 2,
    WADFILE_HAS_INFINITY_STUFF		= 4,
    CURRENT_WADFILE_VERSION			= 4
};

typedef NS_ENUM(short, LEMapVersion) {
    MARATHON_ONE_DATA_VERSION		= 0,
    MARATHON_TWO_DATA_VERSION		= 1,
    MARATHON_INFINITY_DATA_VERSION	= 2,
    EDITOR_MAP_VERSION				= 2
};

enum {
    MAXIMUM_DIRECTORY_ENTRIES_PER_FILE	= 64,
    MAXIMUM_WADFILE_NAME_LENGTH			= 64,
    MAXIMUM_UNION_WADFILES		= 16,
    MAXIMUM_OPEN_WADFILES		= 3,
    MAXIMUM_LEVELS_PER_MAP		= 128,
    LEVEL_NAME_LENGTH			= 64 + 2
};




@class LELevelData, PhPfhorgeScenarioLevelDoc;

@interface LEMapData : NSObject {
    // Raw Map Data
    NSData *mapData;
    
    // Temp Locations for saving...
    NSMutableData *mapDataToSave;
    
    // Level Info Tag Data
    short *environment_code;
    short *physics_model;
    short *song_index;
    short *mission_flags;
    short *environment_flags;
    NSMutableArray *levelNames;
    int *entry_point_flags;
    
    // Other Data
    long theCursor;
    // Main Header For The Map File, Put this into it's own class somtime...
    struct SMainMapHeader myMainMapHeader;
    struct SLevelHeader *myLevelHeaders;
    
    bool alreadyGaveBoundingError;
}

// ***************** Class Convience Functions *****************
+ (NSMutableData *)convertLevelToDataObject:(LELevelData *)theLevel error:(NSError**)outError;
+ (NSMutableData *)mergeScenarioToMarathonMapFile:(PhPfhorgeScenarioLevelDoc *)theScenario error:(NSError**)outError;
+ (NSMutableArray *)convertMarathonDataToArchived:(NSData *)theData levelNames:(NSMutableArray *)theLevelNames error:(NSError**)outError;

- (instancetype)initWithMapNSData:(NSData *)theMap;

- (LELevelData *)getLevel:(short)levelToGet;
- (LELevelData *)getLevel:(short)levelToGet log:(BOOL)logInfo;

- (NSMutableData *)mergeScenario:(PhPfhorgeScenarioLevelDoc *)scenarioDocument error:(NSError**)outError;
- (void)exportLevelDataToMarathonFormat:(LELevelData *)level;
- (NSMutableData *)saveLevelAndGetMapNSData:(LELevelData *)level levelToSaveIn:(short)levelToSaveIn error:(NSError**)outError;

- (void)preAllocateArraysForLevel:(LELevelData *)level forLevelNumber:(int)theLevel;


- (NSInteger)getByteCountForLevel:(LELevelData *)level;

@property (readonly) long numberOfLevels;
- (NSMutableArray<NSString*> *)levelNames;


- (short)getShort;
- (id)getShortObjectFromArray:(NSArray *)theArray;
- (id)getShortZeroIsNilIfOverObjectFromArray:(NSArray *)theArray;
- (short)getUnsignedShort;
- (id)getUnsignedShortObjectFrom:(NSArray *)theArray;
- (int)getLong;
- (unsigned int)getUnsignedLong;
- (NSString*)getChar:(unsigned)theCharAmount;
- (short)getOneByteShort;

- (void)saveData:(NSData *)theData;
- (void)saveShort:(short)v;
- (void)saveUnsignedShort:(unsigned short)v;
- (void)saveLong:(int)v;
- (void)saveUnsignedLong:(unsigned int)v;
- (void)saveStringAsChar:(NSString *)v withLength:(int)length;
- (void)saveOneByteShort:(char)v;
- (void)saveEmptyBytes:(int)amount;

- (BOOL)saveMainMapHeaderForLevels:(int)numberOfLevels usingMapDataSize:(long)size;
- (BOOL)saveDirectoryEntryInfo:(LELevelData *)level;
- (BOOL)saveBasicLevelInfo:(LELevelData *)level;
- (BOOL)saveLevelHeaders:(LELevelData *)level usingMapDataSize:(long)size usingLocation:(long)loc forLevelIndex:(short)index;

- (BOOL)initHeaders;
- (BOOL)initBasicLevelInfo;
- (BOOL)initLevelHeaders;
- (BOOL)initMainHeader;

-(void)getThePointsAtOffset:(int)theDataOffset
				 withLength:(int)theDataLength
				  withLevel:(LELevelData *)curLevel
			  regularPoints:(BOOL)regPointStyle;

-(void)getTheLinesAtOffset:(int)theDataOffset
				withLength:(int)theDataLength
				 withLevel:(LELevelData *)curLevel;

-(void)getThePolygonsAtOffset:(int)theDataOffset
				   withLength:(int)theDataLength
					withLevel:(LELevelData *)curLevel;

-(void)getTheMapObjectsAtOffset:(int)theDataOffset
					 withLength:(int)theDataLength
					  withLevel:(LELevelData *)curLevel;

-(void)getTheSidesAtOffset:(int)theDataOffset
				withLength:(int)theDataLength
				 withLevel:(LELevelData *)curLevel;

-(void)getTheLightsAtOffset:(int)theDataOffset
				 withLength:(int)theDataLength
				  withLevel:(LELevelData *)curLevel;

-(void)getTheAnnotationsAtOffset:(int)theDataOffset
					  withLength:(int)theDataLength
					   withLevel:(LELevelData *)curLevel;

-(void)getTheMediaAtOffset:(int)theDataOffset
				withLength:(int)theDataLength
				 withLevel:(LELevelData *)curLevel;

-(void)getTheAmbientSoundsAtOffset:(int)theDataOffset
						withLength:(int)theDataLength
						 withLevel:(LELevelData *)curLevel;

-(void)getTheStaticPlatformsAtOffset:(int)theDataOffset
						  withLength:(int)theDataLength
						   withLevel:(LELevelData *)curLevel;

-(void)getTheDynamicPlatformsAtOffset:(int)theDataOffset
						   withLength:(int)theDataLength
							withLevel:(LELevelData *)curLevel;

-(void)getTheItemPlacementAtOffset:(int)theDataOffset
						withLength:(int)theDataLength
						 withLevel:(LELevelData *)curLevel;

-(void)getTheRandomSoundsAtOffset:(int)theDataOffset
					   withLength:(int)theDataLength
						withLevel:(LELevelData *)curLevel;

-(void)getTheTerminalsAtOffset:(int)theDataOffset
					withLength:(int)theDataLength
					 withLevel:(LELevelData *)curLevel;

-(void)getTag:(int)theTag theLevel:(short)theLevel theCurrentLevelObject:(LELevelData *)curLevel;

-(void)savePointsForLevel:(LELevelData *)level;
-(void)saveLinesForLevel:(LELevelData *)level;
-(void)savePolygonsForLevel:(LELevelData *)level;
-(void)saveObjectsForLevel:(LELevelData *)level;
-(void)saveSidesForLevel:(LELevelData *)level;
-(void)saveLightsForLevel:(LELevelData *)level;
-(void)saveNotesForLevel:(LELevelData *)level;
-(void)saveMediasForLevel:(LELevelData *)level;
-(void)saveAmbientSoundsForLevel:(LELevelData *)level;
-(void)saveRandomSoundsForLevel:(LELevelData *)level;
-(void)saveItemPlacementForLevel:(LELevelData *)level;
-(void)savePlatformsForLevel:(LELevelData *)level;
-(void)saveTerminalDataForLevel:(LELevelData *)level;


//-(void)saveTag:(long)theTag theLevelNumber:(short)levelNumber theLevelData:(LELevelData *)level;

-(void)NSLogShortFromData:(NSString *)theMessage;
-(void)NSLogUnsignedShortFromData:(NSString *)theMessage;
-(void)NSLogPointFromData:(NSString *)theMessage;
-(void)NSLogLongFromData:(NSString *)theMessage;

@end
