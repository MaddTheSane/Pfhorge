//
//  PhLevelNameManager.h
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

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PhLevelNameMenuType) {
    PhLevelNameMenuTag = 0,
    PhLevelNameMenuLight,
    PhLevelNameMenuAmbientSound,
    PhLevelNameMenuRandomSound,
    PhLevelNameMenuLiquid,
    PhLevelNameMenuPlatform,
    PhLevelNameMenuLayer,
    PhLevelNameMenuPolygon,
    PhLevelNameMenuLevel,
    PhLevelNameMenuTerminal,
    PhLevelNameMenuCountOfLevelNameMenu
};

@class PhAbstractName;

@interface PhLevelNameManager : NSObject <NSSecureCoding>
{
    //! This is a cache of names that get updated
    //! when needed to reflect the current names for
    //! the diffrent objects that they keep track of...
    NSMutableArray<NSString*>  *tagNames, *platformNames, *lightNames,
                    *ambientSoundNames, *randomSoundNames,
                    *liquidNames, *layerNames, *polyNames,
                    *levelNames, *terminalNames;
    
    //! Whenever a menu is created that needs to be kept
    //! up to date with the above names, and always
    //! uses the same level (if a level in the front
    //! goes to the back, and resignes from the
    //! 'main window', these menus still want
    //! to be associated with the level, unlike
    //! the inspector which updates the menus
    //! itself),
    //! then it can tell the level to keep track
    //! of these menus and update them when nessary
    //! using the following arrays and methods.
    NSMutableSet<NSPopUpButton*>    *tagNameMenus, *platformNameMenus,
                    *lightNameMenus, *ambientSoundNameMenus,
                    *randomSoundNameMenus, *liquidNameMenus,
                    *layerNameMenus, *polyNameMenus, *levelNameMenus,
                    *terminalNameMenus;
    
    NSUInteger twoBytesCount;
    NSUInteger fourBytesCount;
    NSUInteger eightBytesCount;
    
}

#pragma mark Coding/Copy Protocol Methods
- (void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithCoder:(NSCoder *)coder;
- (instancetype)init NS_DESIGNATED_INITIALIZER;

#pragma mark Others
- (void)checkNameOfObject:(PhAbstractName *)obj withNameArray:(NSMutableArray<NSString*> *)arr;
- (void)checkName:(PhAbstractName *)obj;


#pragma mark Menu Name Managment
- (void)addMenu:(NSPopUpButton*)theMenuUIO asMenuType:(PhLevelNameMenuType)menuKind;
- (void)removeMenu:(NSPopUpButton*)theMenuUIO thatIsOfMenuType:(PhLevelNameMenuType)menuKind;
- (void)removeMenu:(NSPopUpButton*)theMenuUIO;
- (void)refreshMenusOfMenuType:(PhLevelNameMenuType)menuKind;
- (void)refreshEveryMenu;
- (void)refreshMenu:(NSPopUpButton*)theMenuUIO thatIsOfMenuType:(PhLevelNameMenuType)menuKind;
- (NSMutableSet<NSPopUpButton*> *)menuArrayUsingMenuType:(PhLevelNameMenuType)menuKind;
- (NSMutableArray<NSString*> *)nameArrayUsingMenuType:(PhLevelNameMenuType)menuKind;

- (void)changeLevelNamesToStringArray:(NSArray<NSString*> *)theNames;

#pragma mark Name Arrays
-(NSMutableArray<NSString*> *)getLiquidNames;
-(NSMutableArray<NSString*> *)getRandomSoundNames;
-(NSMutableArray<NSString*> *)getAmbientSoundNames;
-(NSMutableArray<NSString*> *)getLightNames;
-(NSMutableArray<NSString*> *)getPlatformNames;
-(NSMutableArray<NSString*> *)getTagNames;
-(NSMutableArray<NSString*> *)getLayerNames;
-(NSMutableArray<NSString*> *)getPolyNames;

@property (readonly, copy) NSArray<NSString*> *liquidNames;
-(NSArray<NSString*> *)getRandomSoundNamesCopy;
-(NSArray<NSString*> *)getAmbientSoundNamesCopy;
-(NSArray<NSString*> *)getLightNamesCopy;
-(NSArray<NSString*> *)getPlatformNamesCopy;
-(NSArray<NSString*> *)getTagNamesCopy;
-(NSArray<NSString*> *)getLayerNamesCopy;
-(NSArray<NSString*> *)getPolyNamesCopy;

// ************ Other Array Assesors ************
//-(NSMutableArray *)getTags;
//-(void)setTags:(NSMutableArray *)v;

/*-(NSArray *)getLightNames;
-(NSArray *)getLiquidNames;
-(NSArray *)getRandomSoundNames;
-(NSArray *)getAmbientSoundNames;*/

@end
