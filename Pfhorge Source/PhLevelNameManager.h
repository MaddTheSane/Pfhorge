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

#import <Foundation/Foundation.h>

enum {
    _tagMenu = 0,
    _lightMenu,
    _ambientSoundMenu,
    _randomSoundMenu,
    _liquidMenu,
    _platformMenu,
    _layerMenu,
    _polyMenu,
    _levelMenu,
    _terminalMenu,
    _NUMBER_OF_NAME_MENU_TYPES
};

@class PhAbstractName;

@interface PhLevelNameManager : NSObject <NSCoding>
{
    // This is a cache of names that get updated
    // when needed to reflect the current names for
    // the diffrent objects that they keep track of...
    NSMutableArray  *tagNames, *platformNames, *lightNames,
                    *ambientSoundNames, *randomSoundNames,
                    *liquidNames, *layerNames, *polyNames,
                    *levelNames, *terminalNames;
    
    // Whenever a menu is created that needs to be kept
    // up to date with the above names, and always
    // uses the same level (if a level in the front
    // goes to the back, and resignes from the
    /// 'main window', these menus still want
    // to be associated with the level, unlike
    // the inspector which updates the menus
    // itself),
    // then it can tell the level to keep track
    // of these menus and update them when nessary
    // using the following arrays and methods.
    NSMutableSet    *tagNameMenus, *platformNameMenus,
                    *lightNameMenus, *ambientSoundNameMenus,
                    *randomSoundNameMenus, *liquidNameMenus,
                    *layerNameMenus, *polyNameMenus, *levelNameMenus,
                    *terminalNameMenus;
    
    unsigned twoBytesCount;
    unsigned fourBytesCount;
    unsigned eightBytesCount;
    
}

// **************************  Coding/Copy Protocal Methods  *************************
- (void) encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;


//  ************ Others ************
- (void)checkName:(PhAbstractName *)obj;


// ************ Menu Name Managment ************
-(void)addMenu:(id)theMenuUIO asA:(int)menuKind;
-(void)removeMenu:(id)theMenuUIO thatsA:(int)menuKind;
-(void)removeMenu:(id)theMenuUIO;
-(void)refreshAllMenusOf:(int)menuKind;
-(void)refreshEveryMenu;
-(void)refreshTheMenu:(id)theMenuUIO thatsA:(int)menuKind;
- (NSMutableSet *)getMenuArrayUsingType:(int)menuKind;
- (NSMutableArray *)getNameArrayUsingType:(int)menuKind;

- (void)changeLevelNamesTo:(NSArray *)theNames;

// ************ Name Array's ************
-(NSMutableArray *)getLiquidNames;
-(NSMutableArray *)getRandomSoundNames;
-(NSMutableArray *)getAmbientSoundNames;
-(NSMutableArray *)getLightNames;
-(NSMutableArray *)getPlatformNames;
-(NSMutableArray *)getTagNames;
-(NSMutableArray *)getLayerNames;
-(NSMutableArray *)getPolyNames;

-(NSMutableArray *)getLiquidNamesCopy;
-(NSMutableArray *)getRandomSoundNamesCopy;
-(NSMutableArray *)getAmbientSoundNamesCopy;
-(NSMutableArray *)getLightNamesCopy;
-(NSMutableArray *)getPlatformNamesCopy;
-(NSMutableArray *)getTagNamesCopy;
-(NSMutableArray *)getLayerNamesCopy;
-(NSMutableArray *)getPolyNamesCopy;

// ************ Other Array Assesors ************
//-(NSMutableArray *)getTags;
//-(void)setTags:(NSMutableArray *)v;

/*-(NSArray *)getLightNames;
-(NSArray *)getLiquidNames;
-(NSArray *)getRandomSoundNames;
-(NSArray *)getAmbientSoundNames;*/

@end
