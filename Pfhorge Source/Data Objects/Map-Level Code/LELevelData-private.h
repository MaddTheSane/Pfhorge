//
//  LELevelData-private.h
//  Pfhorge
//
//  Created by C.W. Betts on 5/19/20.
//

#ifndef LELevelData_private_h
#define LELevelData_private_h

#import "LELevelData.h"

@interface LELevelData ()
// raw getters
// The below arrays SHOULD NOT be added to manualy, or deleted from...
// Unless you know EXACTLY what you are doing.  You should use the add and delete methods instead,
// I will be making more and expanding the add and delete methods soon.
-(NSMutableArray<LEMapPoint*> *)getThePoints;
-(NSMutableArray<PhItemPlacement*> *)getItemPlacement;

-(NSMutableArray<LELine*> *)getTheLines;
-(NSMutableArray<LEPolygon*> *)getThePolys;
-(NSMutableArray<LEMapObject*> *)getTheMapObjects;

//-(NSMutableArray<PhAnnotationNote*> *)getLayerNotes;
-(NSMutableArray<LEMapPoint*> *)getLayerPoints;
-(NSMutableArray<LELine*> *)getLayerLines;
-(NSMutableArray<LEPolygon*> *)getLayerPolys;
-(NSMutableArray<LEMapObject *> *)getLayerMapObjects;

-(NSMutableArray<PhLayer*> *)getLayersInLevel;
-(NSMutableArray<LEPolygon*> *)getNamedPolyObjects;

-(NSMutableArray<LESide*> *)getSides;
-(NSMutableArray<PhLight*> *)getLights;
-(NSMutableArray<PhAnnotationNote*> *)getNotes;
-(NSMutableArray<PhMedia*> *)getMedia;
-(NSMutableArray<PhAmbientSound*> *)getAmbientSounds;
-(NSMutableArray<PhRandomSound*> *)getRandomSounds;
-(NSMutableArray<PhPlatform*> *)getPlatforms;

-(NSMutableArray<PhTag*> *)getTags;

-(NSMutableArray<Terminal*> *)getTerminals;

@end
#endif /* LELevelData_private_h */
