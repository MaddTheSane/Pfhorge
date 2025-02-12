//
//  LEMapStuffParent.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon Jun 25 2001.
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
#import "PhData.h"

@class LELevelData, LEPolygon, LESide, LEMapPoint, LELine;
@class LEMapObject;
@class Terminal;
@class PhNoteGroup, PhLight, PhMedia, PhAmbientSound, PhRandomSound;
@class PhItemPlacement, PhLayer, PhTag, PhData, PhAnnotationNote;
@class PhPlatform;

@interface LEMapStuffParent : NSObject <NSSecureCoding>
{
     // Pointers To Other Arrays (Data Structures)
    @protected
    BOOL useIndexNumbersInstead;
    
    // These arrays never get deallocated until the level gets deallocated...
    // They are here so that every relevent data object (objects that inherit from me)
    // can have quick accsess to any of these arrays.
    // These arrays are owned by the LELevelData object
    // that this object is a part of...
    
    __unsafe_unretained NSArray<LEMapPoint*> *theMapPointsST;
    __unsafe_unretained NSArray<LELine*> *theMapLinesST;
    __unsafe_unretained NSArray<LEMapObject*> *theMapObjectsST;
    __unsafe_unretained NSArray<LEPolygon*> *theMapPolysST;
    __unsafe_unretained NSArray<LESide*> *theMapSidesST;
    __unsafe_unretained NSArray<PhPlatform*> *theMapPlatformsST;
    __unsafe_unretained NSArray<PhAnnotationNote*> *theAnnotationsST;
    __unsafe_unretained NSArray<PhMedia*> *theMediaST;
    __unsafe_unretained NSArray<PhAmbientSound*> *theAmbientSoundsST;
    __unsafe_unretained NSArray<PhRandomSound*> *theRandomSoundsST;
    __unsafe_unretained NSArray<PhItemPlacement*> *theMapItemPlacmentST;
    __unsafe_unretained NSArray<PhLight*> *theMapLightsST;
    __unsafe_unretained NSArray<PhNoteGroup*> *theNoteTypesST;
    
    NSArray<PhLayer*> *theLayersST;
    __unsafe_unretained NSArray<PhTag*> *theLevelTagObjectsST;
    
    __unsafe_unretained NSArray<Terminal*> *theTerminalsST;
    
    __unsafe_unretained LELevelData	*theLELevelDataST;
                        
    BOOL everythingLoadedST;
    
    NSUInteger twoBytesCount;
    NSUInteger fourBytesCount;
    NSUInteger eightBytesCount;
    
    __unsafe_unretained NSUndoManager *myUndoManager;
}

- (void)displayInfo;
- (instancetype)init NS_DESIGNATED_INITIALIZER;

// **************************  Coding/Copy Protocol Methods  *************************
- (void)superClassExportWithIndex:(NSMutableArray *)index selfData:(NSMutableData *)myData futureData:(NSMutableData *)futureData mainObjects:(NSSet<__kindof LEMapStuffParent*> *)mainObjs;
- (void)superClassImportWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg;
- (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet<__kindof LEMapStuffParent*> *)mainObjs;
- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr;
- (id)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

 // **************************  Object Settings  *************************
-(void)setEncodeIndexNumbersInstead:(BOOL)theChoice;
@property BOOL encodeIndexNumbersInstead;

 // **************************  Advanced Accsess To Level Objects  *************************
-(PhLight*)getLightFromIndex:(short)theIndex;
-(PhMedia*)getMediaFromIndex:(short)theIndex;
-(PhAmbientSound*)getAmbientSoundFromIndex:(short)theIndex;
-(PhRandomSound*)getRandomSoundFromIndex:(short)theIndex;
-(LEPolygon*)getPolygonFromIndex:(short)theIndex;

 // **************************  Basic Accsess To Level Objects  *************************
@property (assign) NSUndoManager *myUndoManager;
 
-(void)setEverythingLoadedST:(BOOL)theChoice;

@property (assign) NSArray<LEMapPoint*> *theMapPointsST;
@property (assign) NSArray<LELine*> *theMapLinesST;
@property (assign) NSArray<LEMapObject*> *theMapObjectsST;
@property (assign) NSArray<LEPolygon*> *theMapPolysST;
@property (assign) NSArray<PhLight*> *theMapLightsST;
@property (assign) NSArray<LESide*> *theMapSidesST;
@property (assign) NSArray<PhAnnotationNote*> *theAnnotationsST;
@property (assign) NSArray<PhMedia*> *theMediaST;
@property (assign) NSArray<PhAmbientSound*> *theAmbientSoundsST;
@property (assign) NSArray<PhRandomSound*> *theRandomSoundsST;
@property (assign) NSArray<PhItemPlacement*> *theMapItemPlacmentST;
@property (assign) NSArray<PhPlatform*> *theMapPlatformsST;

@property (assign) NSArray<PhTag*> *theLevelTagObjectsST;

@property (assign) LELevelData *theLELevelDataST;

@property (assign) NSArray<PhLayer*> *theMapLayersST;
@property (assign) NSArray<PhNoteGroup*> *theNoteTypesST;
@property (assign) NSArray<Terminal*> *theTerminalsST;

-(void)setAllObjectSTsFor:(LEMapStuffParent *)copy;

// **************************  Abstract Methods  *************************
- (PhTag *)getTagForNumber:(int)theTagNumber;

- (NSString *)description;

-(void)copySettingsTo:(id)target;
-(BOOL) uses:(id)theObj;
-(void)moveBy32Point:(NSPoint)theOffset;
-(void)moveBy32Point:(NSPoint)theOffset pointsAlreadyMoved:(NSMutableSet<NSValue*> *)pointsAlreadyMoved;
-(short) index;
-(short) getSpecialIndex;
-(void) update;
-(void) updateIndexesNumbersFromObjects;
-(void) updateObjectsFromIndexes;
-(NSRect) drawingBounds;
-(BOOL)drawingWithinRect:(NSRect)theRect;
-(BOOL) LEhitTest:(NSPoint)point;


// *** *** *** Convient Level Specific Utilites/Accessors *** *** ***
- (NSDecimalNumberHandler *)roundingSettings;
- (NSDecimalNumber *)divideAndRound:(int)theNumber by:(int)theDivisor;

@end

