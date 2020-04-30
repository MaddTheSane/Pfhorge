//
//  LEMapDraw.h
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
#import "LELevelData.h"
#import <AppKit/AppKit.h>

enum // BOOL Options Array Numbers
{
    _mapoptions_select_points = 0,
    _mapoptions_select_lines,
    _mapoptions_select_objects,
    _mapoptions_select_polygons,
    _mapoptions_select_notes,
    COUNT_OF_BOOL_ARRAY_OPTIONS
};

enum // Pfhorge Go To Object Types
{
    _goto_polygon = 0,
    _goto_object,
    _goto_platform,
    _goto_line,
    _goto_point
};

enum // Selection Types
{
    _all_selections = 0,
    _point_selections,
    _line_selections,
    _polygon_selections,
    _object_selections,
    _note_selections,
    _affected_by_selections,
    _include_in_bounds,
    _COUNT_OF_SELECTION_TYPES
};

enum // Drawing Modes
{
    _drawNormaly = 0,
    _drawAbnormaly,
    _drawCeilingHeight,
    _drawFloorHeight,
    _drawLiquids,
    _drawFloorLights,
    _drawCeilingLights,
    _drawLiquidLights,
    _drawAmbientSounds,
    _drawRandomSounds,
    _drawLayers
};

@class LEMapPoint, LELine;

@interface LEMapDraw : NSView
{
    @protected
        
        BOOL boolArrayOptions[COUNT_OF_BOOL_ARRAY_OPTIONS];
        
        IBOutlet id scrollView;
        IBOutlet id ttt;
        IBOutlet id winController;
        
        IBOutlet id colorListObject;
        IBOutlet id colorListDrawer;
        
        BOOL alreadySentToolUnavalbeMsg;
        
        short drawingMode;
        short currentDrawingMode;
        
        //NSMutableArray *rects;
        //ColorRect *selectedItem;
        
        NSTimer *timer;
        
        LELevelData *currentLevel;
        
        NSBezierPath    *polyDrawingMap, *lineDrawingMap, *invalidPolyDrawingMap, *theGridDrawingMap,
                        *pointDrawingMap, *monsterDrawingMap, *itemDrawingMap, *playerDrawingMap, *sceaneryDrawingMap,
                        *goalDrawingMap, *soundDrawingMap, *subGridDrawingMap, *centerGridDrawingMap,
                        *joinedLineDrawingMap, *zonePolyMap, *teleporterPolyMap, *platformPolyMap, *hillPolyMap;
                        
        NSMutableSet *selectedLines, *selectedPolys, *selectedPoints, *selectedMapObjects, *selectedNotes;
        NSMutableSet *selections, *affectedBySelections, *includeInBounds;
        
        // Rect Cache Lists
        NSMutableSet *rectPolys, *rectLines, *rectPoints, *rectObjects, *rectNotes;
        
        // Special Pointers for line tool...
        LEMapPoint *startPoint, *endPoint;
        LELine *newLine;
        
        // List Stuff
        NSMutableDictionary *numberTable;
        NSMutableArray *numberList, *numberDrawingMaps, *colorList, *nameList, *objsList;
        
        BOOL needToCreatPolyMap, drawingHeightMapNeedsUpdating, numberListNeedsUpdating, caculateTheGrid;
        BOOL isAntialiasingOn, shouldObjectOutline, shouldDrawItemObjects, shouldDrawPlayerObjects;
        BOOL shouldDrawEnemyMonstersObjects, shouldDrawSceanryObjects, shouldDrawSoundObjects;
        BOOL shouldDrawGoalObjects, shouldDrawPlatfromPolyObjects, shouldDrawConvexPolyObjects;
        BOOL shouldDrawZonePolyObjects, shouldDrawTeleporterExitPolyObjects, shouldDrawHillPolyObjects;
        
        BOOL optionDown, commandDown, shiftDown, controlKeyDown, capsLockDown;
        
        BOOL shouldNotGetNewObjectsForTiledCache;
        
        BOOL drawBoundingBox;
        NSRect boundingBox;
        
        NSImage *cachedImage;
        NSImageRep *cachedImageRep;
        NSAffineTransform *trans;
        
        NSUndoManager *myUndoManager;
        
    @public
        // Color Sheet Boolean;
        BOOL newHeightSheetOpen;
}

- (BOOL)newHeightSheetOpen;
- (void)setNewHeightSheetOpen:(BOOL)theValue;

// *** Getting Information ***
- (NSSet *)getSelectionsOfType:(int)theSelectionsWanted; // MAKE THIS APPLESCRIPTABLE!!!

// *** Draw View Methods ***
- (void)setTheLevel:(LELevelData *)theMapPoints;
- (id)initWithFrame:(NSRect)frameRect;

- (void)allocateObjects;

- (void)registerNotificationsNow;

- (void)prefsChanged;
- (void)timerDraw:(NSTimer *)incommingTimer;

- (void)drawRect:(NSRect)rect;

- (void)updateNameList:(int)theListFromNameManager; // 123 connected 321
- (void)setCurrentDrawingMode:(int)mode;
- (int)currentDrawingMode;

- (NSArray *)getNumberList;
- (NSArray *)getColorList;
- (NSArray *)getNameList;
- (NSArray *)getTableObjectList;

- (void)addNewHeight:(NSNumber *)theNewHeight; // 123 connected 321

- (void)drawCeilingHeight:(NSRect)aRect;
- (void)drawNormal:(NSRect)aRect;

- (void)drawThePolygons:(NSRect)aRect;
- (void)drawTheObjects:(NSRect)aRect;
- (void)drawTheGrid;
- (void)fillABezierPath:(NSBezierPath *)thePathObject;
- (void)strokeABezierPath:(NSBezierPath *)thePathObject;

- (void)drawAnnotationNotes:(NSRect)aRect;

- (void)createObjectMaps;
- (void)createPolyMap;
- (void)createLineMap;
- (BOOL)createSpecialDrawingList;
- (BOOL)createSpecialDrawingMap;

-(void)recenterViewToPoint:(NSPoint)newctr;

- (void)moveSelectedTo:(NSPoint)theLocation;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseDownHeightMap:(NSEvent *)theEvent;
- (void)mouseDownNormal:(NSEvent *)theEvent;
- (void)dragScroll:(NSEvent *)theEvent;
- (void)mouseScrollingStaringAt:(NSPoint)mouseLoc;

-(BOOL)useSamplerTool:(NSPoint)mouseLoc;
-(BOOL)useBrushTool:(NSPoint)mouseLoc;
- (BOOL)useArrowTool:(NSPoint)mouseLoc clickCount:(int)clickCount;
- (BOOL)useLineTool:(NSPoint)mouseLoc;
-(NSPoint)useLineToolHypothetically:(NSPoint)mouseLoc; // <--- private method!
- (BOOL)usePaintTool:(NSPoint)mouseLoc;
-(BOOL)useObjectTool:(NSPoint)mouseLoc toolType:(int)tool;
-(BOOL)useZoomTool:(NSPoint)mouseLoc;

- (void)clearSelections;
- (NSRect)drawingBoundsForSelections;
- (NSRect)drawingBoundsForObjects:(id)theSentObjs;
- (void)updateTheSelections;

// *************************** For Changing/Getting Settings ***************************

- (BOOL)setBoolOptionsFor:(int)theSetting to:(BOOL)value;
- (BOOL)boolOptionsFor:(int)theSetting;

// ********* Utilities *********
-(BOOL)isThereAPolyAt:(NSPoint)mouseLoc;
-(BOOL)isThereAPointAt:(NSPoint)mouseLoc;
-(BOOL)isThereALineAt:(NSPoint)mouseLoc;
-(BOOL)isThereAObjectAt:(NSPoint)mouseLoc;

- (void)scrollBy:(NSPoint)aPoint;
- (void)clearRectCache;
- (NSString *)rectArrayDescription;
- (void)selectWithinRect:(NSRect)aRect registerUndos:(BOOL)regUndos;
- (NSMutableSet *)getRectCacheObjectsIn:(NSRect)aRect ofSelectionType:(int)selectionType exclude:(NSSet *)excludeSet;
- (void)updateRectCacheIn:(NSRect)aRect;
- (NSMutableSet *)listOfLinesWithin:(NSRect)aRect;
- (NSString *)gotoAndSelectIndex:(int)theIndex ofType:(int)typeOfPfhorgeObject;
- (void)deselectObject:(id)theObj;
- (BOOL)isObjectInSelections:(id)theObj;
- (BOOL)isPointInSelection:(NSPoint)thePoint;
- (void)recaculateAndRedrawEverything;
- (void)checkObjectsAssociatedWithSelection;
- (void)redrawBoundsOfSelection;
- (void)selectObject:(id)theObject byExtendingSelection:(BOOL)extSelection;
- (void)checkConcavenessOnPolys:(id)theEnumerationCapableCollection;
- (id)findPolygonAtPoint:(NSPoint)point;
- (NSPoint)closestPointOrGridIntersectionTo:(NSPoint)mouseLoc includePoints:(BOOL)includePoints includeGrid:(BOOL)includeGrid;
-(void)updateModifierKeys:(NSEvent*)theEvent;

// ********* Actions, Etc. *********
- (IBAction)getInfoAction:(id)sender;
- (IBAction)caculateSidesOnSelectedLines:(id)sender;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (void)zoomBy:(float)zoomfactor;
- (IBAction)zoomNormal:(id)sender;

- (IBAction)redrawEverything:(id)sender;

- (IBAction)setDrawModeToNormal:(id)sender;
- (IBAction)setDrawModeToCeilingHeight:(id)sender;
- (IBAction)enableFloorHeightViewMode:(id)sender;
- (IBAction)enableLiquidViewMode:(id)sender;
- (IBAction)enableFloorLightViewMode:(id)sender;
- (IBAction)enableCeilingLightViewMode:(id)sender;
- (IBAction)enableLiquidLightViewMode:(id)sender;
- (IBAction)enableAmbientSoundViewMode:(id)sender;
- (IBAction)enableRandomSoundViewMode:(id)sender;
- (IBAction)enableLayerViewMode:(id)sender;
- (IBAction)renameSelectedPolygon:(id)sender;

- (void)sendSelChangedNotification;

@end

