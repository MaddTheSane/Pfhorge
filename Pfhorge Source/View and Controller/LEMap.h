//
//  LEMap.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Jul 15 2001.
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
#import "LELevelWindowController.h"
//#import "LELevelData.h"
// #import "LEMapDraw.h"

@class LEMapData, LELevelData, ScenarioResources;
@class LEMapPoint, LELine, LEMapObject, LEPolygon;

@interface LEMap : NSDocument
{
    NSData *theRawMapData;
    LEMapData *theMap;
    LELevelData *theLevel;
    LELevelWindowController *theLevelDocumentWindowController;
    
    NSMutableArray *infoWindows;
    
    NSMutableArray *currentLevelNames;
    
    BOOL cameFromMarathonFormatedFile;
    BOOL shouldExportToMarathonFormat;
    
    // 831368824976
    
    //LELevelData *currentLevelData;
    
   // LEMapDraw *theLevelDrawer;
   
   ScenarioResources		*resources;
}

- (NSImage *)getPICTResourceIndex:(int)PICTIndex;

- (void)removeLevelInfoWinCon:(id)winCon;
- (void)addLevelInfoWinCon:(id)winCon;
- (BOOL)openEditWindowForObject:(id)objectToEdit;


- (LELevelData *)getCurrentLevelLoaded;
- (LELevelData *)level;
- (LEMapData *)getCurrentMapLoaded;
- (LEMapDraw *)getMapDrawView;
- (NSArray<NSString*> *)levelNames;
- (void)changeLevelNameForLevel:(int)theLevelIndex toString:(NSString *)theNewName;

- (BOOL)didIComeFromMarathonFormatedFile;
- (void)shouldExportToMarathonFile:(BOOL)answer;

- (IBAction)openItemPalcmentEditor:(id)sender;
- (IBAction)openTerminalEditor:(id)sender;
- (IBAction)enterVisualMode:(id)sender;
- (IBAction)saveToPfhorgeFormat:(id)sender;
- (IBAction)exportToMarathonFormat:(id)sender;

- (BOOL)exportToMarathonFormatAtPath:(NSString *)fullPath;

- (void)updateLevelStringIfCorrectLevel:(NSNotification *)notification;
- (void)levelDeallocating:(NSNotification *)notification;
- (void)releaseAllInfoWindowControllers;

- (void)tellDocWinControllerToUpdateLevelInfoString;
- (void)windowControllerDidLoadNibSkip:(NSWindowController *) aController;
- (void)loadLevel:(int)levelNumber;

// ***************************** Scripting Support Methods *****************************
#pragma mark Scripting Support Methods
- (NSArray<LEMapPoint*> *)points;
- (NSArray<LELine*> *)lines;
- (NSArray<LEMapObject*> *)objects;
- (NSArray<LEPolygon*> *)polygons;

- (id)handleFillWithLine:(NSScriptCommand *)command;
- (id)handleLineFromPointToPoint:(NSScriptCommand *)command;
- (id)handleLineToNewPoint:(NSScriptCommand *)command;

- (void)setPoints:(NSArray<LEMapPoint*> *)thePoints;
- (void)addInPoints:(LEMapPoint *)point;
- (void)insertInPoints:(LEMapPoint *)graphic atIndex:(NSInteger)index;
- (void)removeFromPointsAtIndex:(NSInteger)index;
- (void)replaceInPoints:(LEMapPoint *)graphic atIndex:(NSInteger)index;

- (id)handleRedrawAndRecaculate:(NSScriptCommand *)command;

@end
