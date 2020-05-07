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
    NSString *theShapesPath = [preferences stringForKey:VMShapesPath];
    
    if (!theShapesPath || theShapesPath.length == 0) {
        NSLog(@"*** No valid shapes file! ***");
        return;
    }
    
    switch (textureSet) {
        case _water:
            NSLog(@"*** Loading Water Textures ***");
            waterTextures = getAllTexturesOf(17, 0, [theShapesPath fileSystemRepresentation]);
            break;
            
        case _lava:
            NSLog(@"*** Loading Lava Textures ***");
            lavaTextures = getAllTexturesOf(18, 0, [theShapesPath fileSystemRepresentation]);
            break;
            
        case _sewage:
            NSLog(@"*** Loading Sewage Textures ***");
            sewageTextures = getAllTexturesOf(19, 0, [theShapesPath fileSystemRepresentation]);
            break;
            
        case _jjaro:
            NSLog(@"*** Loading Jjaro Textures ***");
            jjaroTextures = getAllTexturesOf(20, 0, [theShapesPath fileSystemRepresentation]);
            break;
            
        case _pfhor:
            NSLog(@"*** Loading Pfhor Textures ***");
            pfhorTextures = getAllTexturesOf(21, 0, [theShapesPath fileSystemRepresentation]);
            break;
        case 99:
            NSLog(@"*** Loading Landscapes 1 ***");
            landscape1 = getAllTexturesOf(27, 0, [theShapesPath fileSystemRepresentation]);
            NSLog(@"*** Loading Landscapes 2 ***");
            landscape2 = getAllTexturesOf(28, 0, [theShapesPath fileSystemRepresentation]);
            NSLog(@"*** Loading Landscapes 3 ***");
            landscape3 = getAllTexturesOf(29, 0, [theShapesPath fileSystemRepresentation]);
            NSLog(@"*** Loading Landscapes 4 ***");
            landscape4 = getAllTexturesOf(30, 0, [theShapesPath fileSystemRepresentation]);
            break;
    }
}

-(void)loadTheTextures
{
    NSString *theShapesPath = [preferences stringForKey:VMShapesPath];
    
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
    
    if (theShapesPath == nil || [theShapesPath length] <= 0)
        return;
    
    NSLog(@"*** Loading Water Textures ***");
    waterTextures = getAllTexturesOf(17, 0, [theShapesPath fileSystemRepresentation]);
    NSLog(@"*** Loading Lava Textures ***");
    lavaTextures = getAllTexturesOf(18, 0, [theShapesPath fileSystemRepresentation]);
    NSLog(@"*** Loading Sewage Textures ***");
    sewageTextures = getAllTexturesOf(19, 0, [theShapesPath fileSystemRepresentation]);
    NSLog(@"*** Loading Jjaro Textures ***");
    jjaroTextures = getAllTexturesOf(20, 0, [theShapesPath fileSystemRepresentation]);
    NSLog(@"*** Loading Pfhor Textures ***");
    pfhorTextures = getAllTexturesOf(21, 0, [theShapesPath fileSystemRepresentation]);
    
    NSLog(@"*** Loading Landscapes 1 ***");
    landscape1 = getAllTexturesOf(27, 0, [theShapesPath fileSystemRepresentation]);
    NSLog(@"*** Loading Landscapes 2 ***");
    landscape2 = getAllTexturesOf(28, 0, [theShapesPath fileSystemRepresentation]);
    NSLog(@"*** Loading Landscapes 3 ***");
    landscape3 = getAllTexturesOf(29, 0, [theShapesPath fileSystemRepresentation]);
    NSLog(@"*** Loading Landscapes 4 ***");
    landscape4 = getAllTexturesOf(30, 0, [theShapesPath fileSystemRepresentation]);
    
    NSLog(@"*** Done Loading Textures ***");
    ///[waterTextures addEntriesFromDictionary:[NSDictionary dictionaryWithObject:theImage forKey:@19]];
    
    
    /*

    NSFileWrapper *collectionsDir = [[NSFileWrapper alloc] initWithPath:@"~/Documents/Texture Enhancement Pack s/Textures/Marathon Infinity Textures/"];
    NSString *theWaterTextureMainDir = @"/Users/jagildra/Documents/Texture Enhancement Pack s/Textures/Marathon Infinity Textures/17 Water/";
    
    NSFileWrapper *water;
    //, *sewage, *lava, *pfhor, *jjaro;
        
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:theWaterTextureMainDir];
    NSString *pname;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *subpaths;
    BOOL isDir;
    NSString *fileName;
    NSEnumerator *numer;
    
    if ([manager fileExistsAtPath:theWaterTextureMainDir isDirectory:&isDir] && isDir)
    {
        NSLog(@"Water Texture Directory Found!");
        subpaths = [manager subpathsAtPath:theWaterTextureMainDir];
        numer = [subpaths objectEnumerator];
        while (fileName = [numer nextObject])
        {
            NSImage *texture = [[NSImage alloc] initWithContentsOfFile:[theWaterTextureMainDir stringByAppendingString:fileName]];
            //NSImage *texture = [[NSImage alloc] initWithSize:NSMakeSize(20.0, 20.0)];
            NSNumber *textureNumber = [NSNumber numberWithInt:[[fileName stringByDeletingPathExtension] intValue]];
            [texture setSize:NSMakeSize(60.0, 60.0)];
            [waterTextures addEntriesFromDictionary:[NSDictionary dictionaryWithObject:texture forKey:textureNumber]];
            NSLog(@"Water texture %@ loaded!", fileName);
        }
    }
    else
    {
        NSLog(@"No Water Textures Found...");
    }
    
    return;
    
    while (pname = [direnum nextObject]) {
        if ([[pname pathExtension] isEqualToString:@"rtfd"]) {            
            if ([[[direnum fileAttributes] fileType] isEqualToString:NSFileTypeDirectory])
            {
                [direnum skipDescendents];
            }
        }
        else {
            
        }
    }
    
    water = [[collectionsDir fileWrappers] objectForKey:@"19 Water"];
    
    if (water == nil)
        return;
    if ([water isDirectory])
    {
        NSDictionary *theFiles = [water fileWrappers];
        NSEnumerator *enumerator = [theFiles objectEnumerator];
        id value;
                
        while ((value = [enumerator nextObject]))
        {
            ///NSImage *texture = [[NSImage alloc] initWithContentsOfFile:@"~/Documents/Texture Enhancement Pack s/Textures/Marathon Infinity Textures/17 Water/00.jpg"];
            //[waterTextures addEntriesFromDictionary:[NSDictionary dictionaryWithObject: forKey:@"The Key Value"]];
        }    
    }*/
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
