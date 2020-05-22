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

@class LELevelData, PhTag, PhData;

@interface LEMapStuffParent : NSObject <NSCoding>
{
     // Pointers To Other Arrays (Data Structures)
    @protected
    BOOL useIndexNumbersInstead;
    
    // These arrays never get deallocated until the level gets deallocated...
    // They are here so that every relevent data object (objects that inherit from me)
    // can have quick accsess to any of these arrays.
    // These arrays are owned by the LELevelData object
    // that this object is a part of...
    
    NSArray	*theMapPointsST, *theMapLinesST, *theMapObjectsST;
    NSArray	*theMapPolysST, *theMapSidesST, *theMapPlatformsST;
    NSArray	*theAnnotationsST, *theMediaST, *theAmbientSoundsST;
    NSArray	*theRandomSoundsST, *theMapItemPlacmentST, *theMapLightsST;
    NSArray     *theNoteTypesST;
    
    NSArray	*theLayersST, *theLevelTagObjectsST;
    
    NSArray	*theTerminalsST;
    
    LELevelData	*theLELevelDataST;
                        
    BOOL everythingLoadedST;
    
    NSUInteger twoBytesCount;
    NSUInteger fourBytesCount;
    NSUInteger eightBytesCount;
    
    NSUndoManager *myUndoManager;
}

- (void)displayInfo;
- (instancetype)init NS_DESIGNATED_INITIALIZER;

// **************************  Coding/Copy Protocal Methods  *************************
- (void)superClassExportWithIndex:(NSMutableArray *)index selfData:(NSMutableData *)myData futureData:(NSMutableData *)futureData mainObjects:(NSSet<__kindof LEMapStuffParent*> *)mainObjs;
- (void)superClassImportWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg;
- (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet<__kindof LEMapStuffParent*> *)mainObjs;
- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

 // **************************  Object Settings  *************************
-(void)setEncodeIndexNumbersInstead:(BOOL)theChoice;

 // **************************  Advanced Accsess To Level Objects  *************************
-(id)getLightFromIndex:(short)theIndex;
-(id)getMediaFromIndex:(short)theIndex;
-(id)getAmbientSoundFromIndex:(short)theIndex;
-(id)getRandomSoundFromIndex:(short)theIndex;
-(id)getPolygonFromIndex:(short)theIndex;

 // **************************  Basic Accsess To Level Objects  *************************
@property (assign) NSUndoManager *myUndoManager;
 
-(void)setEverythingLoadedST:(BOOL)theChoice;

-(void)setTheMapPointsST:(NSArray *)theNSArray;
-(void)setTheMapLinesST:(NSArray *)theNSArray;
-(void)setTheMapObjectsST:(NSArray *)theNSArray;
-(void)setTheMapPolysST:(NSArray *)theNSArray;
-(void)setTheMapLightsST:(NSArray *)theNSArray;
-(void)setTheMapSidesST:(NSArray *)theNSArray;
-(void)setTheAnnotationsST:(NSArray *)theNSArray;
-(void)setTheMediaST:(NSArray *)theNSArray;
-(void)setTheAmbientSoundsST:(NSArray *)theNSArray;
-(void)setTheRandomSoundsST:(NSArray *)theNSArray;
-(void)setTheMapItemPlacmentST:(NSArray *)theNSArray;
-(void)setTheMapPlatformsST:(NSArray *)theNSArray;

-(void)setTheLevelTagObjectsST:(NSArray *)theNSArray;

-(void)setTheLELevelDataST:(LELevelData *)theLevel;

-(void)setTheMapLayersST:(NSArray *)theNSArray;
-(void)setTheNoteTypesST:(NSArray *)theNSArray;
-(void)setTheTerminalsST:(NSArray *)theNSArray;

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

