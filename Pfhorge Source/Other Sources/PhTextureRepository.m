//
//  PhTextureRepository.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Jul 21 2001.
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

#import "PhTextureRepository.h"
#import <Foundation/Foundation.h>

#import "LELevelData.h"

#import "extractbitmap.h"

#import "LEExtras.h"

@implementation PhTextureRepository

- (PhTextureRepository *)init
{
    self = [super init];
    if (self != nil)
    {
        waterTextures = nil;
        lavaTextures = nil;
        sewageTextures = nil;
        jjaroTextures = nil;
        pfhorTextures = nil;
        
        landscape1 = nil;
        landscape2 = nil;
        landscape3 = nil;
        landscape4 = nil;
    }
    return self;
}

// *********************** Class Methods ***********************
+ (id)sharedTextureRepository {
    static PhTextureRepository *sharedTextureRepository = nil;

    if (!sharedTextureRepository) {
        sharedTextureRepository = [[PhTextureRepository alloc] init];
    }

    return sharedTextureRepository;
}

// *********************** Other Methods ***********************

-(void)loadTextureSet:(int)textureSet
{
    NSURL *theShapesPath = [preferences URLForKey:VMShapesPath];
    
    if (!theShapesPath) {
        NSLog(@"*** No valid shapes file! ***");
        return;
    }
    
    switch (textureSet) {
        case _water:
            NSLog(@"*** Loading Water Textures ***");
            waterTextures = getAllTexturesOfWithError(17, 0, theShapesPath, NULL);
            break;
            
        case _lava:
            NSLog(@"*** Loading Lava Textures ***");
            lavaTextures = getAllTexturesOfWithError(18, 0, theShapesPath, NULL);
            break;
            
        case _sewage:
            NSLog(@"*** Loading Sewage Textures ***");
            sewageTextures = getAllTexturesOfWithError(19, 0, theShapesPath, NULL);
            break;
            
        case _jjaro:
            NSLog(@"*** Loading Jjaro Textures ***");
            jjaroTextures = getAllTexturesOfWithError(20, 0, theShapesPath, NULL);
            break;
            
        case _pfhor:
            NSLog(@"*** Loading Pfhor Textures ***");
            pfhorTextures = getAllTexturesOfWithError(21, 0, theShapesPath, NULL);
            break;
        case 99:
            NSLog(@"*** Loading Landscapes 1 ***");
            landscape1 = getAllTexturesOfWithError(27, 0, theShapesPath, NULL);
            NSLog(@"*** Loading Landscapes 2 ***");
            landscape2 = getAllTexturesOfWithError(28, 0, theShapesPath, NULL);
            NSLog(@"*** Loading Landscapes 3 ***");
            landscape3 = getAllTexturesOfWithError(29, 0, theShapesPath, NULL);
            NSLog(@"*** Loading Landscapes 4 ***");
            landscape4 = getAllTexturesOfWithError(30, 0, theShapesPath, NULL);
            break;
    }
}

-(void)loadTheTextures
{
    NSURL *theShapesPath = [preferences URLForKey:VMShapesPath];
    
    // (Collection, Color Table, Shapes Path)
    
    // SHould release these to make, in case this function gets called more then once...
    waterTextures = nil;
    lavaTextures = nil;
    sewageTextures = nil;
    jjaroTextures = nil;
    pfhorTextures = nil;
    
    landscape1 = nil;
    landscape2 = nil;
    landscape3 = nil;
    landscape4 = nil;
    
    if (theShapesPath == nil)
        return;
    
    NSLog(@"*** Loading Water Textures ***");
    waterTextures = getAllTexturesOfWithError(17, 0, theShapesPath, NULL);
    NSLog(@"*** Loading Lava Textures ***");
    lavaTextures = getAllTexturesOfWithError(18, 0, theShapesPath, NULL);
    NSLog(@"*** Loading Sewage Textures ***");
    sewageTextures = getAllTexturesOfWithError(19, 0, theShapesPath, NULL);
    NSLog(@"*** Loading Jjaro Textures ***");
    jjaroTextures = getAllTexturesOfWithError(20, 0, theShapesPath, NULL);
    NSLog(@"*** Loading Pfhor Textures ***");
    pfhorTextures = getAllTexturesOfWithError(21, 0, theShapesPath, NULL);
    
    NSLog(@"*** Loading Landscapes 1 ***");
    landscape1 = getAllTexturesOfWithError(27, 0, theShapesPath, NULL);
    NSLog(@"*** Loading Landscapes 2 ***");
    landscape2 = getAllTexturesOfWithError(28, 0, theShapesPath, NULL);
    NSLog(@"*** Loading Landscapes 3 ***");
    landscape3 = getAllTexturesOfWithError(29, 0, theShapesPath, NULL);
    NSLog(@"*** Loading Landscapes 4 ***");
    landscape4 = getAllTexturesOfWithError(30, 0, theShapesPath, NULL);
    
    NSLog(@"*** Done Loading Textures ***");
}

// *********************** Get Methods ***********************
-(NSArray *)getTextureCollection:(int)collection
{
    switch (collection) {
        case _water:
            return waterTextures;
            break;
        case _lava:
            return lavaTextures;
            break;
        case _sewage:
            return sewageTextures;
            break;
        case _jjaro:
            return jjaroTextures;
            break;
        case _pfhor:
            return pfhorTextures;
            break;
        default:
            return nil;
            break;
    }
    return nil;
}

- (NSArray *)collection:(LELevelEnvironmentCode)collection
{
    switch (collection) {
        case _water_collection:
            return waterTextures;
            break;
        case _lava_collection:
            return lavaTextures;
            break;
        case _sewage_collection:
            return sewageTextures;
            break;
        case _jjaro_collection:
            return jjaroTextures;
            break;
        case _pfhor_collection:
            return pfhorTextures;
            break;
        case _landscape_collection_1:
            return landscape1;
            break;
        case _landscape_collection_2:
            return landscape2;
            break;
        case _landscape_collection_3:
            return landscape3;
            break;
        case _landscape_collection_4:
            return landscape4;
            break;
        default:
            return nil;
            break;
    }
}

@end
