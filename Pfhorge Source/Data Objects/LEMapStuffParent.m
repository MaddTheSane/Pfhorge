//
//  LEMapStuffParent.m
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

#import "LEMapStuffParent.h"
#import "LELevelData.h"
#import "LEExtras.h"
#import "LEMap.h"
#import "PhTag.h"

#import "PhData.h"

@implementation LEMapStuffParent

- (void)displayInfo
{
    SEND_INFO_MSG_TITLE(@"This object does not yet support this query…", @"Detailed Information About Selected");
}


 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********

- (void)superClassExportWithIndex:(NSMutableArray *)index selfData:(NSMutableData *)myData futureData:(NSMutableData *)futureData mainObjects:(NSSet *)mainObjs
{
    return;
}

- (void)superClassImportWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg
{
    return;
}

- (long)exportWithIndex:(NSMutableArray *)index withData:(NSMutableData *)theData mainObjects:(NSSet *)mainObjs
{
    return [self index];
}

- (void)importWithIndex:(NSArray *)index withData:(PhData *)myData useOrginals:(BOOL)useOrg objTypesArr:(short *)objTypesArr
{
    return;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
    if (coder.allowsKeyedCoding) {
        [coder encodeBool:useIndexNumbersInstead forKey:@"useIndexNumbersInstead"];
    } else {
        encodeNumInt(coder, 0);
        
        encodeBOOL(coder, useIndexNumbersInstead); // 2
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    int versionNum = 0;
    
    self = [super init];
    if (coder.allowsKeyedCoding) {
        useIndexNumbersInstead = [coder decodeBoolForKey:@"useIndexNumbersInstead"];
    } else {
        versionNum = decodeNumInt(coder);
        useIndexNumbersInstead = decodeBOOL(coder); // 2
    }
    
    if (useIndexNumbersInstead) {
        // Get the ST's from the front map...
        [[[[NSDocumentController sharedDocumentController]
           currentDocument]
          getCurrentLevelLoaded]
         setUpArrayPointersFor:self];
        everythingLoadedST = YES;
    }
    
    twoBytesCount = 2;
    fourBytesCount = 4;
    eightBytesCount = 8;
    
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)copyWithZone:(NSZone *)zone
{
    LEMapStuffParent *copy = [[LEMapStuffParent allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    [self setAllObjectSTsFor:copy];
    
    return copy;
}

 // **************************  Object Settings  *************************
 #pragma mark -
#pragma mark ********* Object Settings *********

-(void)setEncodeIndexNumbersInstead:(BOOL)theChoice {
    useIndexNumbersInstead = theChoice;
}

 // **************************  Advanced Accsess To Level Objects  *************************
 #pragma mark -
#pragma mark ********* Advanced Accsess To Level Objects *********
 
-(id)getLightFromIndex:(short)theIndex
{
    if (theIndex < 0 || [theMapLightsST count] == 0)
        return nil;
    else if (theIndex >= (int)[theMapLightsST count])
        return [theMapLightsST lastObject];
    
    return [theMapLightsST objectAtIndex:theIndex];
}
 
-(id)getMediaFromIndex:(short)theIndex
{
    if (theIndex < 0 || [theMediaST count] == 0)
        return nil;
    else if (theIndex >= (int)[theMediaST count])
        return [theMediaST lastObject];
    
    return [theMediaST objectAtIndex:theIndex];
}

-(id)getAmbientSoundFromIndex:(short)theIndex
{
    if (theIndex < 0 || [theAmbientSoundsST count] == 0)
        return nil;
    else if (theIndex >= (int)[theAmbientSoundsST count])
        return [theAmbientSoundsST lastObject];
    
    return [theAmbientSoundsST objectAtIndex:theIndex];
}

-(id)getRandomSoundFromIndex:(short)theIndex
{
    if (theIndex < 0 || [theRandomSoundsST count] == 0)
        return nil;
    else if (theIndex >= (int)[theRandomSoundsST count])
        return [theRandomSoundsST lastObject];
    
    return [theRandomSoundsST objectAtIndex:theIndex];
}

-(id)getPolygonFromIndex:(short)theIndex
{
    if (theIndex < 0 || [theMapPolysST count] == 0)
        return nil;
    else if (theIndex >= [theMapPolysST count])
        return [theMapPolysST lastObject];
    
    return [theMapPolysST objectAtIndex:theIndex];
}

 // **************************  Basic Accsess To Level Objects  *************************
 #pragma mark -
#pragma mark ********* Basic Accsess To Level Objects *********

@synthesize myUndoManager;

@synthesize theNoteTypesST;

-(void)setEverythingLoadedST:(BOOL)theChoice { everythingLoadedST = theChoice; }
@synthesize theMapPointsST;
@synthesize theMapLinesST;
@synthesize theMapObjectsST;
@synthesize theMapPolysST;
@synthesize theMapLightsST;

@synthesize theMapSidesST;

@synthesize theAnnotationsST;
@synthesize theMediaST;
@synthesize theAmbientSoundsST;
@synthesize theRandomSoundsST;
@synthesize theMapItemPlacmentST;
@synthesize theMapPlatformsST;

@synthesize theLevelTagObjectsST;

@synthesize theLELevelDataST;


// Set The Map Layers
@synthesize theMapLayersST;

@synthesize theTerminalsST;


-(void)setAllObjectSTsFor:(LEMapStuffParent *)copy
{
    [copy setMyUndoManager:myUndoManager];
    
    [copy setTheNoteTypesST:theNoteTypesST];
    
    [copy setTheMapPointsST:theMapPointsST];
    [copy setTheMapLinesST:theMapLinesST];
    [copy setTheMapObjectsST:theMapObjectsST];
    [copy setTheMapPolysST:theMapPolysST];
    [copy setTheMapLightsST:theMapLightsST];
    [copy setTheMapSidesST:theMapSidesST];
    [copy setTheAnnotationsST:theAnnotationsST];
    [copy setTheMediaST:theMediaST];
    [copy setTheAmbientSoundsST:theAmbientSoundsST];
    [copy setTheRandomSoundsST:theRandomSoundsST];
    [copy setTheMapItemPlacmentST:theMapItemPlacmentST];
    [copy setTheMapPlatformsST:theMapPlatformsST];
    
    [copy setTheLevelTagObjectsST:theLevelTagObjectsST];
    
    [copy setTheLELevelDataST:theLELevelDataST];
    
    // Set The Map Layers
    [copy setTheMapLayersST:theLayersST];
    
    [copy setTheTerminalsST:theTerminalsST];
    
    [copy setEverythingLoadedST:YES];
}

//-(void)setTheTestVar:(int)theInt { TheTestVar = theInt; }

// **************************  Init and Dealloc Methods  *************************
#pragma mark -
#pragma mark ********* Init and Dealloc Methods *********

-(id)init
{
    self = [super init];
    
    if (self != nil)
    {
        everythingLoadedST = NO;
        twoBytesCount = 2;
        fourBytesCount = 4;
        eightBytesCount = 8;
        useIndexNumbersInstead = NO;
    }
    return self;
}


-(void) dealloc
{
    [super dealloc];
}

// **************************  Abstract Methods  *************************
#pragma mark -
#pragma mark ********* Abstract Methods *********

- (PhTag *)getTagForNumber:(int)theTagNumber
{
    ///PhTag *theNewTag = nil;
    NSInteger theNewTagIndexNumber = -1;
    //NSLog(@"getTagForNumber: %d", theTagNumber);
    
    theNewTagIndexNumber = [theLELevelDataST tagIndexNumberFromTagNumber:theTagNumber];
    
    
    if ([theLevelTagObjectsST count] > theNewTagIndexNumber)
        return [theLevelTagObjectsST objectAtIndex:theNewTagIndexNumber];
    else
        NSLog(@"ERROR: in getTagForNumber in LEMapStuffParent, tag index from LELevelData beyond range of tag array...");
    
    //NSLog(@"theNewTagIndexNumber == %d", theNewTagIndexNumber);
    
    return nil;
    
    //return [theLevelTagObjectsST objectAtIndex:];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Index: %d  ({[PDSuper]})", [self index], nil];
}

-(void)copySettingsTo:(id)target
{
    NSLog(@"the abstract method -(void)copySettingsTo:(id)target in the super class was called...");
    return;
}

-(BOOL) uses:(id)theObj
{
    NSLog(@"the abstract method -(BOOL) uses:(id)theObj in the super class was called...");
    return NO;
}

-(void) moveBy32Point:(NSPoint)theOffset
{ // Could have a problem with this method being called somehere???
    NSLog(@"the abstract method -(void) moveBy32Point:(NSPoint)theOffset in the super class was called...");
}

-(void)moveBy32Point:(NSPoint)theOffset pointsAlreadyMoved:(NSMutableSet *)pointsAlreadyMoved
{
    [self moveBy32Point:theOffset];
}

-(short) index
{
    NSLog(@"the abstract method -(short) index in the super class was called...");
    return -1;
}

-(short) getSpecialIndex { return [self index]; }

-(void) update
{
    NSLog(@"the abstract method -(void) update in the super class was called...");
}

-(void) updateIndexesNumbersFromObjects
{
    NSLog(@"the abstract method -(void) updateIndexesNumbersFromObjects in the super class was called...");
}

-(void) updateObjectsFromIndexes
{
    NSLog(@"the abstract method -(void) updateObjectsFromIndexes in the super class was called...");
}

-(NSRect) drawingBounds
{
    NSLog(@"the abstract method -(NSRect) drawingBounds in the super class was called...");
    return NSZeroRect;
}

-(BOOL)drawingWithinRect:(NSRect)theRect
{
    NSRect myDrawingBounds = [self drawingBounds];
    return NSIntersectsRect(theRect, myDrawingBounds);
}

-(BOOL) LEhitTest:(NSPoint)point
{ // Could have a problem with this method being called somehere???
    //NSLog(@"the abstract method -(BOOL) LEhitTest:(NSPoint)point in the super class was called...");
    return NO;
}

-(BOOL)hitTest:(NSPoint)point
{
    return [self LEhitTest:point];
}


// *** *** *** Convient Level Specific Utilites/Accessors *** *** ***
// *******************  Convient Level Specific Utilites/Accessors  *******************
#pragma mark -
#pragma mark ********* Convient Level Specific Utilites/Accessors *********

/*
- (long)exportNumberWithIndex:(NSMutableArray *)theIndex withData:(NSMutableData *)theData objectToExport:(id)obj
{
    long theNumber = [theIndex indexOfObjectIdenticalTo:obj];
    if (theNumber == NSNotFound)
    {
        [obj exportWithIndex:theIndex withData:theData mainObjects:???];
    }
    else
    {
        return theNumber;
    }
}*/


- (NSDecimalNumberHandler *)roundingSettings
{
    return [theLELevelDataST roundingSettings];
}

- (NSDecimalNumber *)divideAndRound:(int)theNumber by:(int)theDivisor
{
    return nil;//return [[NSDecimalNumber numberWithFloat:(((float)theNumber)/((float)theDivisor))] decimalNumberByRoundingAccordingToBehavior:[theLELevelDataST roundingSettings]];
}
@end
