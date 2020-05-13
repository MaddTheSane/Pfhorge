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
#import "LEPaletteController.h"

NS_ASSUME_NONNULL_BEGIN

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

//! Selection Types
typedef NS_ENUM(int, LEMapDrawSelectionType) {
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

//! Drawing Modes
typedef NS_ENUM(int, LEMapDrawingMode) {
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
@class LELevelWindowController, PhColorListControllerDrawer;

@interface LEMapDraw : NSView
{
@protected
	
	BOOL boolArrayOptions[COUNT_OF_BOOL_ARRAY_OPTIONS];
	
	IBOutlet NSScrollView *scrollView;
	IBOutlet NSTextField *ttt;
	IBOutlet LELevelWindowController *winController;
	
	IBOutlet PhColorListControllerDrawer *colorListObject;
	IBOutlet NSDrawer *colorListDrawer;
	
	BOOL alreadySentToolUnavalbeMsg;
	
	LEMapDrawingMode drawingMode;
	short currentDrawingMode;
	
	//NSMutableArray *rects;
	//ColorRect *selectedItem;
	
	NSTimer *timer;
	
	LELevelData *currentLevel;
	
	NSBezierPath    *polyDrawingMap, *lineDrawingMap, *invalidPolyDrawingMap, *theGridDrawingMap,
	*pointDrawingMap, *monsterDrawingMap, *itemDrawingMap, *playerDrawingMap, *sceaneryDrawingMap,
	*goalDrawingMap, *soundDrawingMap, *subGridDrawingMap, *centerGridDrawingMap,
	*joinedLineDrawingMap, *zonePolyMap, *teleporterPolyMap, *platformPolyMap, *hillPolyMap;
	
	NSMutableSet<LELine*> *selectedLines;
	NSMutableSet<LEPolygon*> *selectedPolys;
	NSMutableSet *selectedPoints;
	NSMutableSet *selectedMapObjects;
	NSMutableSet *selectedNotes;
	NSMutableSet *selections;
	NSMutableSet *affectedBySelections;
	NSMutableSet *includeInBounds;
	
	// Rect Cache Lists
	NSMutableSet *rectPolys;
	NSMutableSet *rectLines;
	NSMutableSet *rectPoints;
	NSMutableSet *rectObjects;
	NSMutableSet *rectNotes;
	
	// Special Pointers for line tool...
	LEMapPoint *startPoint, *endPoint;
	LELine *newLine;
	
	// List Stuff
	NSMutableDictionary<NSNumber*,id> *numberTable;
	NSMutableArray<NSNumber*> *numberList;
	NSMutableArray *numberDrawingMaps;
	NSMutableArray<NSColor*> *colorList;
	NSMutableArray<NSString*> *nameList;
	NSMutableArray *objsList;
	
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

@property BOOL newHeightSheetOpen;

// *** Getting Information ***
- (nullable NSSet<__kindof LEMapStuffParent*> *)getSelectionsOfType:(LEMapDrawSelectionType)theSelectionsWanted; // MAKE THIS APPLESCRIPTABLE!!!

// *** Draw View Methods ***
- (void)setTheLevel:(nullable LELevelData *)theMapPoints;
- (id)initWithFrame:(NSRect)frameRect;

- (void)allocateObjects;

- (void)registerNotificationsNow;

- (void)prefsChanged;
- (void)timerDraw:(NSTimer *)incommingTimer;

- (void)drawRect:(NSRect)rect;

- (void)updateNameList:(int)theListFromNameManager; // 123 connected 321
@property (nonatomic) LEMapDrawingMode currentDrawingMode;

- (NSArray<NSNumber*> *)numberList;
- (NSArray<NSColor*> *)colorList;
- (NSArray<NSString*> *)nameList;
- (NSArray<__kindof LEMapStuffParent*> *)tableObjectList;

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

- (BOOL)useSamplerTool:(NSPoint)mouseLoc;
- (BOOL)useBrushTool:(NSPoint)mouseLoc;
- (BOOL)useArrowTool:(NSPoint)mouseLoc clickCount:(NSInteger)clickCount;
- (BOOL)useLineTool:(NSPoint)mouseLoc;
- (NSPoint)useLineToolHypothetically:(NSPoint)mouseLoc; // <--- private method!
- (BOOL)usePaintTool:(NSPoint)mouseLoc;
- (BOOL)useObjectTool:(NSPoint)mouseLoc toolType:(LEPaletteTool)tool;
- (BOOL)useZoomTool:(NSPoint)mouseLoc;

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
- (NSSet<__kindof LEMapStuffParent*> *)getRectCacheObjectsIn:(NSRect)aRect ofSelectionType:(int)selectionType exclude:(NSSet<LEMapStuffParent*> *)excludeSet;
- (void)updateRectCacheIn:(NSRect)aRect;
- (NSSet<LELine*> *)listOfLinesWithin:(NSRect)aRect;
- (nullable NSString *)gotoAndSelectIndex:(int)theIndex ofType:(int)typeOfPfhorgeObject;
- (void)deselectObject:(id)theObj;
- (BOOL)isObjectInSelections:(id)theObj;
- (BOOL)isPointInSelection:(NSPoint)thePoint;
- (void)recaculateAndRedrawEverything;
- (void)checkObjectsAssociatedWithSelection;
- (void)redrawBoundsOfSelection;
- (void)selectObject:(id)theObject byExtendingSelection:(BOOL)extSelection;
- (void)checkConcavenessOnPolys:(id)theEnumerationCapableCollection;
- (nullable LEPolygon*)findPolygonAtPoint:(NSPoint)point;
- (NSPoint)closestPointOrGridIntersectionTo:(NSPoint)mouseLoc includePoints:(BOOL)includePoints includeGrid:(BOOL)includeGrid;
-(void)updateModifierKeys:(NSEvent*)theEvent;

// ********* Actions, Etc. *********
- (IBAction)getInfoAction:(nullable id)sender;
- (IBAction)caculateSidesOnSelectedLines:(nullable id)sender;

- (IBAction)cut:(nullable id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

- (IBAction)zoomIn:(nullable id)sender;
- (IBAction)zoomOut:(nullable id)sender;
- (void)zoomBy:(float)zoomfactor;
- (IBAction)zoomNormal:(nullable id)sender;

- (IBAction)redrawEverything:(nullable id)sender;

- (IBAction)setDrawModeToNormal:(nullable id)sender;
- (IBAction)setDrawModeToCeilingHeight:(nullable id)sender;
- (IBAction)enableFloorHeightViewMode:(nullable id)sender;
- (IBAction)enableLiquidViewMode:(nullable id)sender;
- (IBAction)enableFloorLightViewMode:(nullable id)sender;
- (IBAction)enableCeilingLightViewMode:(nullable id)sender;
- (IBAction)enableLiquidLightViewMode:(nullable id)sender;
- (IBAction)enableAmbientSoundViewMode:(nullable id)sender;
- (IBAction)enableRandomSoundViewMode:(nullable id)sender;
- (IBAction)enableLayerViewMode:(nullable id)sender;
- (IBAction)renameSelectedPolygon:(nullable id)sender;

- (void)sendSelChangedNotification;

@end

NS_ASSUME_NONNULL_END
