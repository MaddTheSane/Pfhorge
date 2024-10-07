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
#pragma mark Coding/Copy Protocal Methods
- (void) encodeWithCoder:(NSCoder *)coder
{
    if (coder.allowsKeyedCoding) {
        
    } else {
        encodeNumInt(coder, 0);
    }
}

- (id)initWithCoder:(NSCoder *)coder
{
    //self = [super init];
    
    int versionNum = 0;
    
    self = [self init];
    
    if (coder.allowsKeyedCoding) {
        
    } else {
        versionNum = decodeNumInt(coder);
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
    PhLevelNameManager *copy = [[PhLevelNameManager allocWithZone:zone] init];
    
    if (copy == nil)
        return nil;
    
    //[self setAllObjectSTsFor:copy];
    
    return copy;
}

 // **************************  Init and Dealloc Methods  *************************
#pragma mark -
#pragma mark Init and Dealloc Methods
-(id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    tagNameMenus		    = [[NSMutableSet alloc] initWithCapacity:6];
    platformNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    lightNameMenus		    = [[NSMutableSet alloc] initWithCapacity:20];
    ambientSoundNameMenus	= [[NSMutableSet alloc] initWithCapacity:0];
    randomSoundNameMenus	= [[NSMutableSet alloc] initWithCapacity:0];
    liquidNameMenus		    = [[NSMutableSet alloc] initWithCapacity:0];
    
    layerNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    polyNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];

    levelNameMenus		= [[NSMutableSet alloc] initWithCapacity:0];
    
    terminalNameMenus	= [[NSMutableSet alloc] initWithCapacity:0];
    
    
    liquidNames 	    = [[NSMutableArray alloc] initWithCapacity:0];
    tagNames 		    = [[NSMutableArray alloc] initWithCapacity:6];
    platformNames 	    = [[NSMutableArray alloc] initWithCapacity:0];
    lightNames 		    = [[NSMutableArray alloc] initWithCapacity:0];
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
}

/*
 
*tagNames, *platformNames, *lightNames,
*ambientSoundNames, *randomSoundNames,
*liquidNames, *layerNames, *polyNames,
*terminalNames;

*/

- (void)checkNameOfObject:(PhAbstractName *)obj withNameArray:(NSMutableArray<NSString*> *)arr
{
    // TODO: implement!
}

- (void)checkName:(PhAbstractName *)obj
{
    Class theClass = [obj class];
    
    if ([theClass isKindOfClass:[PhTag class]])
    {
        [self checkNameOfObject:obj withNameArray:tagNames];
    }
    else if ([theClass isKindOfClass:[Terminal class]])
    {
        // TODO: implement!
    }
    else if ([theClass isKindOfClass:[PhLayer class]])
    {
        // TODO: implement!
    }
    else if ([theClass isKindOfClass:[LEPolygon class]])
    {
        // TODO: implement!
    }
    else if ([theClass isKindOfClass:[PhMedia class]])
    {
        // TODO: implement!
    }
    else if ([theClass isKindOfClass:[PhAmbientSound class]])
    {
        // TODO: implement!
    }
    else if ([theClass isKindOfClass:[PhRandomSound class]])
    {
        // TODO: implement!
    }
    else if ([theClass isKindOfClass:[PhLight class]])
    {
        // TODO: implement!
    }
    else if ([theClass isKindOfClass:[PhItemPlacement class]])
    {
        // TODO: implement!
    }
    else if ([theClass isKindOfClass:[PhPlatform class]])
    {
        // TODO: implement!
    }
    else
    {
        // TODO: implement failure case?
    }
}


// ************************* Menu Name Managment*************************
#pragma mark -
#pragma mark Menu Name Managment

-(void)addMenu:(NSPopUpButton*)theMenuUIO asMenuType:(PhLevelNameMenuType)menuKind
{
    NSMutableSet *theMenuArray;
    
    if (theMenuUIO == nil)
        return;
    
    theMenuArray = [self menuArrayUsingMenuType:menuKind];
    [theMenuArray addObject:theMenuUIO];
    [self refreshMenu:theMenuUIO thatIsOfMenuType:menuKind];
}

-(void)removeMenu:(NSPopUpButton*)theMenuUIO thatIsOfMenuType:(PhLevelNameMenuType)menuKind
{
    NSMutableSet *theMenuArray;
    
    if (theMenuUIO == nil)
        return;
    
    theMenuArray = [self menuArrayUsingMenuType:menuKind];
    
    [theMenuArray removeObject:theMenuUIO];
}

-(void)removeMenu:(NSPopUpButton*)theMenuUIO
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

-(void)refreshMenusOfMenuType:(PhLevelNameMenuType)menuKind
{
    NSMutableSet<NSPopUpButton*> *theMenuSet = [self menuArrayUsingMenuType:menuKind];
    
    for (NSPopUpButton *theMenu in theMenuSet)
        [self refreshMenu:theMenu thatIsOfMenuType:menuKind];
    
    // [[PhColorListController sharedColorListController] updateInterfaceIfLevelDataSame:self];
}

-(void)refreshEveryMenu
{
    for (int i = 0; i < PhLevelNameMenuCountOfLevelNameMenu; i++) {
        [self refreshMenusOfMenuType:i];
    }
}

-(void)refreshMenu:(NSPopUpButton*)theMenuUIO thatIsOfMenuType:(PhLevelNameMenuType)menuKind
{
    // addItemsWithTitles   removeAllItems
    // indexOfSelectedItem  selectItemAtIndex:
    NSMutableArray *theNameArray = [self nameArrayUsingMenuType:menuKind];
    NSInteger indexOfSelectedMenuItem = [theMenuUIO indexOfSelectedItem];
    NSInteger totalNumberOfMenuItems;
    
    //NSEnumerator *enumerator;
    //NSMenuItem *item;
    //int count = 0;
    //id value;
    
    //NSLog(@"Count of theNameArray: %d", [theNameArray count]);
    
    [theMenuUIO removeAllItems];
    
    if (menuKind == PhLevelNameMenuLayer) {
        [theMenuUIO addItemWithTitle:NSLocalizedString(@"No Layer On", @"No Layer On")];
        //[theMenuUIO addItemWithTitle:@"No Layer On2"];
        totalNumberOfMenuItems = [theNameArray count] + 1;
        //NSLog(@"Updating Layer Menu With: %@", [theNameArray description]);
    } else {
        totalNumberOfMenuItems = [theNameArray count];
    }
    
    [theMenuUIO addItemsWithTitles:theNameArray];
    
    if (totalNumberOfMenuItems <= indexOfSelectedMenuItem) {
        [theMenuUIO selectItemAtIndex:([theNameArray count] - 1)];
    } else {
        [theMenuUIO selectItemAtIndex:indexOfSelectedMenuItem];
    }
    
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

- (NSMutableSet *)menuArrayUsingMenuType:(PhLevelNameMenuType)menuKind;
{    
    switch (menuKind) {
        case PhLevelNameMenuTag:
            return tagNameMenus;
        case PhLevelNameMenuPlatform:
            return platformNameMenus;
        case PhLevelNameMenuLight:
            return lightNameMenus;
        case PhLevelNameMenuAmbientSound:
            return ambientSoundNameMenus;
        case PhLevelNameMenuRandomSound:
            return randomSoundNameMenus;
        case PhLevelNameMenuLiquid:
            return liquidNameMenus;
        case PhLevelNameMenuLayer:
            return layerNameMenus;
        case PhLevelNameMenuPolygon:
            return polyNameMenus;
        case PhLevelNameMenuLevel:
            return levelNameMenus;
        case PhLevelNameMenuTerminal:
            return terminalNameMenus;
        case PhLevelNameMenuCountOfLevelNameMenu:
            NSLog(@"Got sent 'PhLevelNameMenuCountOfLevelNameMenu', which is an invalid variable to pass into %s.", __PRETTY_FUNCTION__);
            break;
    }
    NSLog(@"Returned Nil In - (NSMutableSet *)getMenuArrayUsingType:(int)menuKind");
    return nil;
}

- (NSMutableArray *)nameArrayUsingMenuType:(PhLevelNameMenuType)menuKind;
{    
    switch (menuKind) {
        case PhLevelNameMenuTag:
            return tagNames;
        case PhLevelNameMenuPlatform:
            return platformNames;
        case PhLevelNameMenuLight:
            return lightNames;
        case PhLevelNameMenuAmbientSound:
            return ambientSoundNames;
        case PhLevelNameMenuRandomSound:
            return randomSoundNames;
        case PhLevelNameMenuLiquid:
            return liquidNames;
        case PhLevelNameMenuLayer:
            return layerNames;
        case PhLevelNameMenuPolygon:
            return polyNames;
        case PhLevelNameMenuLevel:
            return levelNames;
        case PhLevelNameMenuTerminal:
            return terminalNames;
        case PhLevelNameMenuCountOfLevelNameMenu:
            NSLog(@"Got sent 'PhLevelNameMenuCountOfLevelNameMenu', which is an invalid variable to pass into %s.", __PRETTY_FUNCTION__);
            break;
    }
    NSLog(@"Returned Nil In - (NSMutableArray *)getNameArrayUsingType:(int)menuKind");
    return nil;
}

- (void)changeLevelNamesToStringArray:(NSArray *)theNames
{
    NSLog(@"changeLevelNamesTo count: %lu", (unsigned long)[theNames count]);
    [levelNames removeAllObjects];
    [levelNames addObjectsFromArray:theNames];
    [self refreshMenusOfMenuType:PhLevelNameMenuLevel];
}

// ************************* Name Array Accsess *************************
#pragma mark -
#pragma mark Name Array Accsess

-(NSMutableArray *)getLiquidNames { return liquidNames; }
-(NSMutableArray *)getRandomSoundNames { return randomSoundNames; }
-(NSMutableArray *)getAmbientSoundNames { return ambientSoundNames; }
-(NSMutableArray *)getLightNames { return lightNames; }
-(NSMutableArray *)getPlatformNames { return platformNames; }
-(NSMutableArray *)getTagNames { return tagNames; }
-(NSMutableArray *)getLayerNames { return layerNames; }
-(NSMutableArray *)getPolyNames { return polyNames; }

-(NSArray<NSString*> *)liquidNames { return [liquidNames copy]; }
-(NSArray<NSString*> *)getRandomSoundNamesCopy { return [randomSoundNames copy]; }
-(NSArray<NSString*> *)getAmbientSoundNamesCopy { return [ambientSoundNames copy]; }
-(NSArray<NSString*> *)getLightNamesCopy { return [lightNames copy]; }
-(NSArray<NSString*> *)getPlatformNamesCopy { return [platformNames copy]; }
-(NSArray<NSString*> *)getTagNamesCopy { return [tagNames copy]; }
-(NSArray<NSString*> *)getLayerNamesCopy { return [layerNames copy]; }
-(NSArray<NSString*> *)getPolyNamesCopy { return [polyNames copy]; }

@end
