//
//  PhLevelNameManager.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Dec 09 2001.
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


#import "PhLevelNameManager.h"
#import "LEExtras.h"
#import <AppKit/AppKit.h>
#import "PhColorListController.h"
#import "PhAbstractName.h"

#import "PhTag.h"
#import "PhLayer.h"

#import "LEMapPoint.h"
#import "LELine.h"
#import "LESide.h"
#import "LEPolygon.h"
#import "LEMapObject.h"
#import "PhLight.h"
#import "PhAnnotationNote.h"
#import "PhMedia.h"
#import "PhAmbientSound.h"
#import "PhRandomSound.h"
#import "PhItemPlacement.h"
#import "PhPlatform.h"

#import "Terminal.h"

@implementation PhLevelNameManager
 // **************************  Coding/Copy Protocal Methods  *************************
 #pragma mark -
#pragma mark ********* Coding/Copy Protocal Methods *********
- (void) encodeWithCoder:(NSCoder *)coder
{
    // Do I need to encode the NSObject super class?
    //[super encodeWithCoder:coder];
    
    encodeNumInt(coder, 0);
    
    /*encodeObj(coder, tagNames);
    encodeObj(coder, platformNames);
    encodeObj(coder, lightNames);
    encodeObj(coder, ambientSoundNames);
    encodeObj(coder, randomSoundNames);
    encodeObj(coder, liquidNames);
    encodeObj(coder, layerNames);
    encodeObj(coder, polyNames);*/
}

- (id)initWithCoder:(NSCoder *)coder
{
    // Do I need to decode the NSObject super class?
    //self = [super initWithCoder:coder];
    
    //self = [super init];
    
    int versionNum = 0;
    
    [self init];
    
    versionNum = decodeNumInt(coder);
    
    /*tagNames = decodeObj(coder);
    platformNames = decodeObj(coder);
    lightNames = decodeObj(coder);
    ambientSoundNames = decodeObj(coder);
    randomSoundNames = decodeObj(coder);
    liquidNames = decodeObj(coder);
    layerNames = decodeObj(coder);
    polyNames = decodeObj(coder);
    
    tagNameMenus		= [[NSMutableSet alloc] initWithCapacity:6];
    platformNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    lightNameMenus		= [[NSMutableSet alloc] initWithCapacity:20];
    ambientSoundNameMenus	= [[NSMutableSet alloc] initWithCapacity:0];
    randomSoundNameMenus	= [[NSMutableSet alloc] initWithCapacity:0];
    liquidNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    
    layerNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    polyNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    */
    
    twoBytesCount = 2;
    fourBytesCount = 4;
    eightBytesCount = 8;
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    PhLevelNameManager *copy = [[PhLevelNameManager allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    //[self setAllObjectSTsFor:copy];
    
    return copy;
}

 // **************************  Init and Dealloc Methods  *************************
 #pragma mark -
#pragma mark ********* Init and Dealloc Methods *********
-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    tagNameMenus		= [[NSMutableSet alloc] initWithCapacity:6];
    platformNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    lightNameMenus		= [[NSMutableSet alloc] initWithCapacity:20];
    ambientSoundNameMenus	= [[NSMutableSet alloc] initWithCapacity:0];
    randomSoundNameMenus	= [[NSMutableSet alloc] initWithCapacity:0];
    liquidNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    
    layerNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    polyNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];

    levelNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    
    terminalNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    
    
    liquidNames 	= [[NSMutableArray alloc] initWithCapacity:0];
    tagNames 		= [[NSMutableArray alloc] initWithCapacity:6];
    platformNames 	= [[NSMutableArray alloc] initWithCapacity:0];
    lightNames 		= [[NSMutableArray alloc] initWithCapacity:0];
    randomSoundNames 	= [[NSMutableArray alloc] initWithCapacity:0];
    ambientSoundNames 	= [[NSMutableArray alloc] initWithCapacity:0];
    
    layerNames 		= [[NSMutableArray alloc] initWithCapacity:0];
    polyNames 		= [[NSMutableArray alloc] initWithCapacity:0];
    
    levelNames 		= [[NSMutableArray alloc] initWithCapacity:0];
    
    terminalNames	= [[NSMutableArray alloc] initWithCapacity:0];
    
    
    twoBytesCount = 2;
    fourBytesCount = 4;
    eightBytesCount = 8;
    
    return self;
}

- (void)dealloc
{
    [tagNameMenus release];
    [platformNameMenus release];
    [lightNameMenus release];
    [ambientSoundNameMenus release];
    [randomSoundNameMenus release];
    [liquidNameMenus release];
    
    [layerNameMenus release];
    [polyNameMenus release];
    
    [terminalNameMenus release];
    
    
    [ambientSoundNames release];
    [randomSoundNames release];
    [lightNames release];
    [platformNames release];
    [tagNames release];
    [liquidNames release];
    
    [layerNames release];
    [polyNames release];
    
    [levelNameMenus release];
    [levelNames release];
    
    [terminalNames release];
    
    [super dealloc];
}

/*
 
*tagNames, *platformNames, *lightNames,
*ambientSoundNames, *randomSoundNames,
*liquidNames, *layerNames, *polyNames,
*terminalNames;

*/

- (void)checkNameOf:(PhAbstractName *)obj withNameArray:(NSMutableArray *)arr
{
    
}

- (void)checkName:(PhAbstractName *)obj
{
    Class theClass = [obj class];
    
    if (theClass == [PhTag class])
    {
        [self checkNameOf:obj withNameArray:tagNames];
    }
    else if (theClass == [Terminal class])
    {
        
    }
    else if (theClass == [PhLayer class])
    {
        
    }
    else if (theClass == [LEPolygon class])
    {
        
    }
    else if (theClass == [PhMedia class])
    {
        
    }
    else if (theClass == [PhAmbientSound class])
    {
        
    }
    else if (theClass == [PhRandomSound class])
    {
        
    }
    else if (theClass == [PhLight class])
    {
        
    }
    else if (theClass == [PhItemPlacement class])
    {
        
    }
    else if (theClass == [PhPlatform class])
    {
        
    }
    else
    {
        
    }
}


// ************************* Menu Name Managment*************************
#pragma mark -
#pragma mark ********* Menu Name Managment*********

-(void)addMenu:(id)theMenuUIO asA:(int)menuKind
{
    NSMutableSet *theMenuArray;
    
    if (theMenuUIO == nil)
        return;
    
    theMenuArray = [self getMenuArrayUsingType:menuKind];
    [theMenuArray addObject:theMenuUIO];
    [self refreshTheMenu:theMenuUIO thatsA:menuKind];
}

-(void)removeMenu:(id)theMenuUIO thatsA:(int)menuKind
{
    NSMutableSet *theMenuArray;
    
    if (theMenuUIO == nil)
        return;
    
    theMenuArray = [self getMenuArrayUsingType:menuKind];
    
    [theMenuArray removeObject:theMenuUIO];
}

-(void)removeMenu:(id)theMenuUIO
{
    if (theMenuUIO == nil)
        return;
    
    [tagNameMenus removeObject:theMenuUIO];
    [platformNameMenus removeObject:theMenuUIO];
    [lightNameMenus removeObject:theMenuUIO];
    [ambientSoundNameMenus removeObject:theMenuUIO];
    [randomSoundNameMenus removeObject:theMenuUIO];
    [liquidNameMenus removeObject:theMenuUIO];
    [layerNameMenus removeObject:theMenuUIO];
    [polyNameMenus removeObject:theMenuUIO];
}

-(void)refreshAllMenusOf:(int)menuKind
{
    NSMutableSet *theMenuSet = [self getMenuArrayUsingType:menuKind];
    NSEnumerator *enumerator;
    id theMenu;
    
    enumerator = [theMenuSet objectEnumerator];
    while ((theMenu = [enumerator nextObject]))
        [self refreshTheMenu:theMenu thatsA:menuKind];
    
    // [[PhColorListController sharedColorListController] updateInterfaceIfLevelDataSame:self];
}

-(void)refreshEveryMenu
{
    int i = 0;
    for (i = 0; i < _NUMBER_OF_NAME_MENU_TYPES; i++)
        [self refreshAllMenusOf:i];
}

-(void)refreshTheMenu:(id)theMenuUIO thatsA:(int)menuKind
{
    // addItemsWithTitles   removeAllItems
    // indexOfSelectedItem  selectItemAtIndex:
    NSMutableArray *theNameArray = [self getNameArrayUsingType:menuKind];
    int indexOfSelectedMenuItem = [theMenuUIO indexOfSelectedItem];
    int totalNumberOfMenuItems;
    
    //NSEnumerator *enumerator;
    //NSMenuItem *item;
    //int count = 0;
    //id value;
    
    //NSLog(@"Count of theNameArray: %d", [theNameArray count]);
    
    [theMenuUIO removeAllItems];
    
    if (menuKind == _layerMenu)
    {
        [theMenuUIO addItemWithTitle:@"No Layer On"];
        //[theMenuUIO addItemWithTitle:@"No Layer On2"];
        totalNumberOfMenuItems = [theNameArray count] + 1;
        //NSLog(@"Updating Layer Menu With: %@", [theNameArray description]);
    }
    else
        totalNumberOfMenuItems = [theNameArray count];
    
    [theMenuUIO addItemsWithTitles:theNameArray];
    
    if (totalNumberOfMenuItems <= indexOfSelectedMenuItem)
        [theMenuUIO selectItemAtIndex:([theNameArray count] - 1)];
    else
        [theMenuUIO selectItemAtIndex:indexOfSelectedMenuItem];
    
    /*
    enumerator = [theNameArray objectEnumerator];
    while ((value = [enumerator nextObject]))
    {
        [lineTextureExp addItemWithTitle:@""];
        item = [lineTextureExp itemAtIndex:count];
        [item setImage:value];
        [item setOnStateImage:nil];
        [item setMixedStateImage:nil];
        count++;
    }
    */
    //[lineTextureExp calcSize];

    //[[[lineTextureExp menu] menuRepresentation] setHorizontalEdgePadding:0.0];
    //[lineTextureExp sizeToFit];
    //[contentView addSubview:lineTextureExp];
}

- (NSMutableSet *)getMenuArrayUsingType:(int)menuKind;
{    
    switch(menuKind)
    {
        case _tagMenu:
            return tagNameMenus;
        case _platformMenu:
            return platformNameMenus;
        case _lightMenu:
            return lightNameMenus;
        case _ambientSoundMenu:
            return ambientSoundNameMenus;
        case _randomSoundMenu:
            return randomSoundNameMenus;
        case _liquidMenu:
            return liquidNameMenus;
        case _layerMenu:
            return layerNameMenus;
        case _polyMenu:
            return polyNameMenus;
        case _levelMenu:
            return levelNameMenus;
        case _terminalMenu:
            return terminalNameMenus;
    }
    NSLog(@"Returned Nil In - (NSMutableSet *)getMenuArrayUsingType:(int)menuKind");
    return nil;
}

- (NSMutableArray *)getNameArrayUsingType:(int)menuKind;
{    
    switch(menuKind)
    {
        case _tagMenu:
            return tagNames;
        case _platformMenu:
            return platformNames;
        case _lightMenu:
            return lightNames;
        case _ambientSoundMenu:
            return ambientSoundNames;
        case _randomSoundMenu:
            return randomSoundNames;
        case _liquidMenu:
            return liquidNames;
        case _layerMenu:
            return layerNames;
        case _polyMenu:
            return polyNames;
        case _levelMenu:
            return levelNames;
        case _terminalMenu:
            return terminalNames;
    }
    NSLog(@"Returned Nil In - (NSMutableArray *)getNameArrayUsingType:(int)menuKind");
    return nil;
}

- (void)changeLevelNamesTo:(NSArray *)theNames
{
    NSLog(@"changeLevelNamesTo count: %d", [theNames count]);
    [levelNames removeAllObjects];
    [levelNames addObjectsFromArray:theNames];
    [self refreshAllMenusOf:_levelMenu];
}

// ************************* Name Array Accsess *************************
#pragma mark -
#pragma mark ********* Name Array Accsess *********

-(NSMutableArray *)getLiquidNames { return liquidNames; }
-(NSMutableArray *)getRandomSoundNames { return randomSoundNames; }
-(NSMutableArray *)getAmbientSoundNames { return ambientSoundNames; }
-(NSMutableArray *)getLightNames { return lightNames; }
-(NSMutableArray *)getPlatformNames { return platformNames; }
-(NSMutableArray *)getTagNames { return tagNames; }
-(NSMutableArray *)getLayerNames { return layerNames; }
-(NSMutableArray *)getPolyNames { return polyNames; }

-(NSMutableArray *)getLiquidNamesCopy { return [[liquidNames copy] autorelease]; }
-(NSMutableArray *)getRandomSoundNamesCopy { return [[randomSoundNames copy] autorelease]; }
-(NSMutableArray *)getAmbientSoundNamesCopy { return [[ambientSoundNames copy] autorelease]; }
-(NSMutableArray *)getLightNamesCopy { return [[lightNames copy] autorelease]; }
-(NSMutableArray *)getPlatformNamesCopy { return [[platformNames copy] autorelease]; }
-(NSMutableArray *)getTagNamesCopy { return [[tagNames copy] autorelease]; }
-(NSMutableArray *)getLayerNamesCopy { return [[layerNames copy] autorelease]; }
-(NSMutableArray *)getPolyNamesCopy { return [[polyNames copy] autorelease]; }

/*
-(NSArray *)getLightNames
{
    NSMutableArray *theNames;
    int i;
    
    theNames = [[NSMutableArray alloc] init];
    
    for (i = 0; i < lightCount; i++)
        [theNames addObject:[NSString localizedStringWithFormat:@"%d", i]];
        
    return theNames;
}

-(NSArray *)getLiquidNames
{
    NSMutableArray *theNames;
    int i;
    
    theNames = [[NSMutableArray alloc] init];
    
    for (i = 0; i < liquidCount; i++)
        [theNames addObject:[NSString localizedStringWithFormat:@"%d", i]];
        
    return theNames;
}

-(NSArray *)getRandomSoundNames
{
    NSMutableArray *theNames;
    int i;
    
    theNames = [[NSMutableArray alloc] init];
    
    for (i = 0; i < randomSoundCount; i++)
        [theNames addObject:[NSString localizedStringWithFormat:@"%d", i]];
        
    return theNames;
}

-(NSArray *)getAmbientSoundNames
{
    NSMutableArray *theNames;
    int i;
    
    theNames = [[NSMutableArray alloc] init];
    
    for (i = 0; i < ambientSoundCount; i++)
        [theNames addObject:[NSString localizedStringWithFormat:@"%d", i]];
        
    return theNames;
}
*/

@end
