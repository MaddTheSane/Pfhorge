//
//  LELevelData-Data.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Jan 25 2003.
//  Copyright (c) 2003 Joshua D. Orr. All rights reserved.
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
#import "LEMapDraw.h"
#import "LEMap.h"

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
#import "TerminalSection.h"

#import "LEExtras.h"

@implementation LELevelData (LevelDataAccsessors)

-(NSUndoManager *)myUndoManager
{
    return myUndoManager;
}

-(void)setMyUndoManager:(NSUndoManager *)value
{
    myUndoManager = value;
}

- (NSArray *)getNoteTypes
{
    return noteTypes;
}

- (NSArray *)noteTypes
{
    return noteTypes;
}


#pragma mark -

-(void)updateCounts
{
    
    //Point Count
    if (points != nil) {
        pointCount = [points count];
    }
    else {
        pointCount = 0;
    }
    
    //Object Count
    if (mapObjects != nil) {
        objectCount = [mapObjects count];
    }
    else {
        objectCount = 0;
    }
    
    //Polygon Count
    if (polys != nil) {
        polygonCount = [polys count];
    }
    else {
        polygonCount = 0;
    }
    
    //Line Count
    if (lines != nil) {
        lineCount = [lines count];
    }
    else {
        lineCount = 0;
    }
    
    //Light Count
    if (lights != nil) {
        lightCount = [lights count];
    }
    else {
        lightCount = 0;
    }
    
    //Ambient Sound Count
    if (ambientSounds != nil) {
        ambientSoundCount = [ambientSounds count];
    }
    else {
        ambientSoundCount = 0;
    }
    
    //Platforms Count
    if (platforms != nil) {
        platformCount = [platforms count];
    }
    else {
        platformCount = 0;
    }
    
    //Liquid Count
    if (media != nil) {
        liquidCount = [media count];
    }
    else {
        liquidCount = 0;
    }
    
}

 //Make these names have -> getVariablename <- as names!!!
-(unsigned short)ambientSoundCount { return ambientSoundCount; }
-(unsigned short)liquidCount { return liquidCount; }
-(unsigned short)platformCount { return platformCount; }
-(unsigned short)lightCount { return lightCount; }
-(unsigned short)objectCount { return objectCount; }
-(unsigned short)polygonCount { return polygonCount; }
-(unsigned short)lineCount { return lineCount; }
-(unsigned short)pointCount { return pointCount; }


// ************************* Level Data Accsessors *************************
#pragma mark -
#pragma mark ********* Level Data Accsessors *********

-(void)setLevelDocument:(LEMap *)theDocument { theLevelDocument = theDocument; }

//-(void)setThePoints:(NSMutableArray *)thePoints { return; [points release];  points = thePoints; [points retain]; }
//-(void)setTheLines:(NSMutableArray *)theLines { return; [lines release]; lines = theLines; [lines retain]; }
//-(void)setThePolys:(NSMutableArray *)thePolygons { return; [polys release]; polys = thePolygons; [polys retain]; }
//-(void)setTheMapObjects:(NSMutableArray *)theMapObjects { return; [mapObjects release]; mapObjects = theMapObjects; [mapObjects retain]; }
//-(void)setSides:(NSMutableArray *)v { return; [sides release]; sides = v; [sides retain]; }
//-(void)setLights:(NSMutableArray *)v { return; [lights release]; lights = v; [lights retain]; }
//-(void)setNotes:(NSMutableArray *)v { return; [notes release]; notes = v; [notes retain]; }
//-(void)setMedia:(NSMutableArray *)v { return; [media release]; media = v; [media retain]; }
//-(void)setAmbientSounds:(NSMutableArray *)v { return; [ambientSounds release]; ambientSounds = v; [ambientSounds retain]; }
//-(void)setRandomSounds:(NSMutableArray *)v {return;  [randomSounds release]; randomSounds = v; [randomSounds retain]; }
//-(void)setItemPlacement:(NSMutableArray *)v { return; [itemPlacement release]; itemPlacement = v; [itemPlacement retain]; }
//-(void)setPlatforms:(NSMutableArray *)v { return; [platforms release]; platforms = v; [platforms retain]; }

//-(void)setTags:(NSMutableArray *)v { return; [tags release]; tags = v; [tags retain]; }

-(LEMap *)levelDocument { return theLevelDocument; }




// The below arrays SHOULD NOT be added to manualy, or deleted from...
// Unless you know EXACTLY what you are doing.  You should use the add and delete methods instead,
// I will be making more and expanding the add and delete methods soon.


-(NSMutableArray *)getThePoints { return points; }
//-(NSArray *)points { return points; }

-(NSMutableArray *)getTheLines { return lines; }
-(NSMutableArray *)getThePolys { return polys; }
-(NSMutableArray *)getTheMapObjects { return mapObjects; }

-(NSArray *)layerNotes { return layerNotes; }
-(NSMutableArray *)layerPoints { return layerPoints; }
-(NSMutableArray *)layerLines { return layerLines; }
-(NSMutableArray *)layerPolys { return layerPolys; }
-(NSMutableArray *)layerMapObjects { return layerMapObjects; }

-(NSMutableArray *)layersInLevel { return layersInLevel; }
-(NSMutableArray *)namedPolyObjects { return namedPolyObjects; }

-(NSMutableArray *)getSides { return sides; }
-(NSMutableArray *)getLights { return lights; }
-(NSMutableArray *)getNotes { return notes; }
-(NSMutableArray *)getMedia { return media; }
-(NSMutableArray *)getAmbientSounds { return ambientSounds; }
-(NSMutableArray *)getRandomSounds { return randomSounds; }
-(NSMutableArray *)getItemPlacement { return itemPlacement; }
-(NSMutableArray *)getPlatforms { return platforms; }

-(NSMutableArray *)getTags { return tags; }

-(NSMutableArray *)getTerminals { return terimals; }

@end