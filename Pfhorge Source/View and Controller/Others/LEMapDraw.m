//
//  LEMapDraw.m
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

//View and Controller Classes...
#include <tgmath.h>
#import "LEMapDraw.h"
#import "LEPaletteController.h"
#import "LELevelWindowController.h"
#import "PhColorListController.h"
#import "PhLevelNameManager.h"

#import "PhColorListControllerDrawer.h"

//Data Classes...
#import "LELevelData.h"
#import "LEMapPoint.h"
#import "LELine.h"
#import "LEPolygon.h"
#import "LEMapObject.h"
#import "PhAbstractName.h"
#import "PhPlatform.h"

#import "PhAnnotationNote.h"
#import "PhNoteGroup.h"

//Other Classes...
#import "LEExtras.h"

// Trig tables for PhSin etc fast functions
#import "trigTables.h"

enum {
    LEEDrawNothing = 0,
    LEEDrawLineConnected = 1,
    LEEDrawLineNotConnected,
};

//This Class...
@implementation LEMapDraw

/* These images are displayed as markers on the rulers. */
//static NSImage *leftImage;
//static NSImage *rightImage;
//static NSImage *topImage;
//static NSImage *bottomImage;

/* These strings are used to identify the markers. */

#define STR_LEFT   @"Left Edge"
#define STR_RIGHT  @"Right Edge"
#define STR_TOP    @"Top Edge"
#define STR_BOTTOM @"Bottom Edge"

#define UpdateLevelStatusBar() [winController updateLevelInfoString]


@synthesize newHeightSheetOpen;


// *************************** Getting Information ***************************
#pragma mark -
#pragma mark ********* Getting Information *********
- (NSSet *)getSelectionsOfType:(LEMapDrawSelectionType)theSelectionsWanted
{
    ///NSMutableSet *selectedLines, *selectedPolys, *selectedPoints, *selectedMapObjects;
    ///NSMutableSet *selections, *affectedBySelections, *includeInBounds;
    
    switch (theSelectionsWanted)
    {
        case _all_selections:           return selections;
        case _point_selections:         return selectedPoints;
        case _line_selections:          return selectedLines;
        case _polygon_selections:       return selectedPolys;
        case _object_selections:        return selectedMapObjects;
        case _note_selections:          return selectedNotes;
        case _affected_by_selections:   return affectedBySelections;
        case _include_in_bounds:        return includeInBounds;
        default:                        break;
    }
    
    return nil;
}


// *************************** View Methods ***************************
#pragma mark -
#pragma mark ********* View Methods *********

/*+ (void)initialize
{
    
    static BOOL beenHere = NO;
    NSBundle *mainBundle;
    NSString *path;
    NSArray *upArray;
    NSArray *downArray;

    if (beenHere) return;

    beenHere = YES;

    mainBundle = [NSBundle mainBundle];
    path = [mainBundle pathForResource:@"EdgeMarkerLeft" ofType:@"tiff"];
    leftImage = [[NSImage alloc] initByReferencingFile:path];

    path = [mainBundle pathForResource:@"EdgeMarkerRight" ofType:@"tiff"];
    rightImage = [[NSImage alloc] initByReferencingFile:path];

    path = [mainBundle pathForResource:@"EdgeMarkerTop" ofType:@"tiff"];
    topImage = [[NSImage alloc] initByReferencingFile:path];

    path = [mainBundle pathForResource:@"EdgeMarkerBottom" ofType:@"tiff"];
    bottomImage = [[NSImage alloc] initByReferencingFile:path];

    upArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0], nil];
    downArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5],
        [NSNumber numberWithFloat:0.2], nil];
    [NSRulerView registerUnitWithName:@"Grummets"
        abbreviation:NSLocalizedString(@"gt", @"Grummets abbreviation string")
        unitToPointsConversionFactor:100.0
        stepUpCycle:upArray stepDownCycle:downArray];

    return;
}
*/

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id)init
{
    int i;
    NSGraphicsContext *tContext;
    
    NSLog(@"init of NSView");
    
    self = [super init];
    
    if (!self)
        return nil;
    
    myUndoManager = nil;
    
    rectPolys = nil;
    rectLines = nil;
    rectPoints = nil;
    rectObjects = nil;
    rectNotes = nil;
    
    // Set The Bool Array To Default Values...
    for (i = 0; i < COUNT_OF_BOOL_ARRAY_OPTIONS; i++)
    {
        boolArrayOptions[i] = YES;
    }
    
    //Set default NSBezier Stuff...
    [NSBezierPath setDefaultLineWidth:0];
    
    isAntialiasingOn = YES;
    shouldObjectOutline = YES;
    
    needToCreatPolyMap = YES;
    drawingHeightMapNeedsUpdating = YES;
    numberListNeedsUpdating = YES;
    //[self setCurrentDrawingMode:_drawNormaly];
    drawingMode = _drawNormaly;
    // selectedPoints = [[NSMutableSet alloc] initWithCapacity:1];
    
    tContext =[NSGraphicsContext currentContext];
    [tContext setShouldAntialias:YES];	// <- Antialiasing On
    //Get the information
    
    // Register Notifcations, Etc.
    [self registerNotificationsNow];
    
    //Set default NSBezier Stuff...
    [NSBezierPath setDefaultLineWidth:0];
    
    caculateTheGrid = YES;
    
    alreadySentToolUnavalbeMsg = NO;
    
    shouldNotGetNewObjectsForTiledCache = NO;
    
    drawBoundingBox = NO;
    boundingBox = NSZeroRect;
    
    [self allocateObjects];
    
    return self;
}

- (void)setTheLevel:(LELevelData *)theLevel
{    
    //NSMutableArray *rects;
    //ColorRect *selectedItem;
    
    //[myUndoManager disableUndoRegistration]
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    currentLevel = nil;
    
    [myUndoManager removeAllActions];
    myUndoManager = nil;
    
    NSLog(@"setTheLevel Begining");
    
    [self clearSelections];
    [self updateTheSelections];
    
    
    // List Stuff...
    
    numberList = nil;
    numberDrawingMaps = nil;
    colorList = nil;
    numberTable = nil;
    
    selectedPoints = nil;
    selectedMapObjects = nil;
    selectedLines = nil;
    selectedPolys = nil;
    affectedBySelections = nil;
    includeInBounds = nil;
    
    selectedNotes = [[NSMutableSet alloc] init];

    [self clearSelections];
        
    needToCreatPolyMap = YES;
    drawingHeightMapNeedsUpdating = NO;
    numberListNeedsUpdating = NO;
    
    monsterDrawingMap = [NSBezierPath bezierPath];
    playerDrawingMap = [NSBezierPath bezierPath];
    sceaneryDrawingMap = [NSBezierPath bezierPath];
    goalDrawingMap = [NSBezierPath bezierPath];
    soundDrawingMap = [NSBezierPath bezierPath];
    itemDrawingMap = [NSBezierPath bezierPath];
    
    currentLevel = theLevel;
    // release with a new method called
    // setupLevelForFirstTime, or somthing like that...
    [self setCurrentDrawingMode:_drawNormaly];
    [self createPolyMap];
    [self createObjectMaps];
    caculateTheGrid = YES;
    [self drawTheGrid];
    
    [self clearRectCache];
    
    [self prefsChanged];
    
    [self zoomNormal:nil];
    
    myUndoManager = [[winController document] undoManager];
    [myUndoManager removeAllActions];
    
    // Register Notifcations, Etc.
    [self registerNotificationsNow];
	
    return;
}


- (id)initWithFrame:(NSRect)frameRect
{
    int i;
    NSGraphicsContext *tContext;
    
    //NSRect aRect;
    //ColorRect *firstRect;
    NSLog(@"initWithFrame of NSView");
    self = [super initWithFrame:frameRect];
    if (!self) return nil;
    
    myUndoManager= nil;
    rectPolys = nil;
    rectLines = nil;
    rectPoints = nil;
    rectObjects = nil;
    rectNotes = nil;
    
    // Set The Bool Array To Default Values...
    for (i = 0; i < COUNT_OF_BOOL_ARRAY_OPTIONS; i++)
    {
        boolArrayOptions[i] = YES;
    }
    
    //Set default NSBezier Stuff...
    [NSBezierPath setDefaultLineWidth:0];
    
    //Set the orgin for the middle
    [self setBoundsOrigin:NSMakePoint(-2048.5, -2048.5)]; // (32768) <-> (2048)
    
    isAntialiasingOn = YES;
    shouldObjectOutline = YES;
    
    shouldNotGetNewObjectsForTiledCache = NO;
    
    //rects = [[NSMutableArray alloc] init];
    //selectedItem = nil;

    //aRect = NSMakeRect(30.0, 45.0, 57.0, 118.0);
    //firstRect = [[ColorRect alloc] initWithFrame:aRect color:[NSColor blueColor]];
    //[rects addObject:firstRect];
    //[firstRect release];
    
    needToCreatPolyMap = YES;
    drawingHeightMapNeedsUpdating = YES;
    numberListNeedsUpdating = YES;
    //[self setCurrentDrawingMode:_drawNormaly];
    drawingMode = _drawNormaly;
    // selectedPoints = [[NSMutableSet alloc] initWithCapacity:1];
    
    tContext =[NSGraphicsContext currentContext];
    [tContext setShouldAntialias:YES];	// <- Antialiasing on
    //Get the information

    //Set default NSBezier Stuff...
    [NSBezierPath setDefaultLineWidth:0];
    
    caculateTheGrid = YES;
    
    [self registerNotificationsNow];
    
    alreadySentToolUnavalbeMsg = NO;
    
    drawBoundingBox = NO;
    
    boundingBox = NSZeroRect;
    
    [self allocateObjects];
    
    return self;
}

- (void)allocateObjects
{
    rectPolys = [[NSMutableSet alloc] init];
    rectLines = [[NSMutableSet alloc] init];
    rectPoints = [[NSMutableSet alloc] init];
    rectObjects = [[NSMutableSet alloc] init];
    rectNotes = [[NSMutableSet alloc] init];
}

- (void)registerNotificationsNow
{
    // Use this to send prefs changed notifcations from other places...
    //[[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
        
    //Set default NSBezier Stuff...
    [NSBezierPath setDefaultLineWidth:0];
    
    trans = [NSAffineTransform transform];
    [trans translateXBy:2048.5 yBy:2048.5];
    
    //isAntialiasingOn = [preferences boolForKey:PhEnableAntialiasing];
    //shouldObjectOutline = [preferences boolForKey:PhEnableObjectOutling];
    [self prefsChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefsChanged)
        name:PhUserDidChangePreferencesNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoHappened)
        name:NSUndoManagerDidUndoChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redoHappened)
        name:NSUndoManagerDidRedoChangeNotification object:nil];
}

- (void)drawRect:(NSRect)aRect
{
/*
    if (cachedImage == nil)
    {
        cachedImage = [[NSImage alloc] initWithSize:NSMakeSize(4096, 4096)];
        cachedImageRep = [[NSCachedImageRep alloc]
                                initWithSize:NSMakeSize(4096, 4096)
                                depth:[[NSScreen mainScreen] depth]
                                separate:YES
                                alpha:NO];
        [cachedImageRep setBitsPerSample:8];
        [cachedImage addRepresentation:cachedImageRep];
        [cachedImage setFlipped:YES];

        [cachedImage lockFocusOnRepresentation:cachedImageRep];
    }
        
        //Unlock the NSImage Focus
        [cachedImage unlockFocus];
    }
    else
    {
        [cachedImage compositeToPoint:NSMakePoint(-2048, 2048) operation:NSCompositeCopy];
    }*/
    
    switch ([self currentDrawingMode])
    {
        case _drawNormaly:
            [self drawNormal:aRect];
            break;
        case _drawAbnormaly:
            [self drawNormal:aRect];
            break;
        case _drawCeilingHeight:
        case _drawFloorHeight:
        case _drawLiquids:
        case _drawFloorLights:
        case _drawCeilingLights:
        case _drawLiquidLights:
        case _drawAmbientSounds:
        case _drawLayers:
            [self drawCeilingHeight:aRect];
            break;
        case _drawRandomSounds:
            [self drawNormal:aRect];
            break;
        default:
            [self drawNormal:aRect];
            break;
    }
    
    
}

- (void)updateNameList:(int)theListFromNameManager
{
    BOOL needToReCache = NO;
    switch(drawingMode)
    {
        case _drawLayers:
            if (theListFromNameManager == _layerMenu)
                needToReCache = YES;
            break;
        case _drawFloorLights:
        case _drawCeilingLights:
        case _drawLiquidLights:
            if (theListFromNameManager == _lightMenu)
                needToReCache = YES;
            break;
        case _drawAmbientSounds:
            if (theListFromNameManager == _ambientSoundMenu)
                needToReCache = YES;
            break;
        case _drawRandomSounds:
            if (theListFromNameManager == _randomSoundMenu)
                needToReCache = YES;
            break;
        case _drawLiquids:
            if (theListFromNameManager == _liquidMenu)
                needToReCache = YES;
            break;
        default:
            needToReCache = NO;
            break;
    }
    
    if (needToReCache == YES)
    {
        [self setCurrentDrawingMode:drawingMode];
    }
    
    return;
}

- (void)setCurrentDrawingMode:(LEMapDrawingMode)mode
{
    int previousDrawingMode = drawingMode;
    drawingHeightMapNeedsUpdating = YES;
    numberListNeedsUpdating = YES;
    
    [self clearRectCache];
    
    if (mode != _drawNormaly)
    {
        /*if (drawingMode == _drawNormaly)
        {
            //[[PhColorListController sharedColorListController] showWindow:self];
            
        }*/
        
        [colorListDrawer open];
        
        drawingMode = mode;
        [self createSpecialDrawingList];
        [self updateRectCacheIn:[self bounds]];
        [self createSpecialDrawingMap];
    }
    else if (mode == _drawNormaly)
    {
        drawingMode = mode;
		
        numberList = nil;
        numberDrawingMaps = nil;
        colorList = nil;
        nameList = nil;
        
        ///[[PhColorListController sharedColorListController] updateInterface:self];
        [colorListObject updateInterface:self];
        
        [colorListDrawer close];
        
        [self updateRectCacheIn:[self bounds]];
        
        //[[PhColorListController sharedColorListController] performClose:self];
    }
    else
    {
        [self updateRectCacheIn:[self bounds]];
        SEND_ERROR_MSG(@"Was not _drawNormal but it was a the same time? LOGIC ERROR");
    }
    //[self setNeedsDisplay:YES];
    
    if (previousDrawingMode == _drawLayers)
    {
        [currentLevel recaculateTheCurrentLayer];
        [self createObjectMaps];
        [self createPolyMap];
        [self createLineMap];
        [self updateRectCacheIn:[self bounds]];
    }
    
    // Once I get undo support in the other view modes
    // I will not do this anymore...
    // ******************************************** Temp Undo Manager Clear **************************************
    [myUndoManager removeAllActions];
    [self display];
}

@synthesize currentDrawingMode=drawingMode;
- (NSArray *)numberList { return numberList; }
- (NSArray *)colorList { return colorList; }
- (NSArray *)nameList
{
    return nameList; 
}
- (NSArray *)tableObjectList { return objsList; }

- (void)addNewHeight:(NSNumber *)theNewHeight
{
    NSEnumerator *numer, *numer2, *numer3, *numer4;
    NSNumber *curNumber;
    NSString *curName;
    NSBezierPath *curMap;
    NSColor *curColor;
    //NSNumber *theNumber;
    ///id thisObj;
    
    double hueMultiplier = 0.0;
    
    NSInteger i = 0;
    NSInteger tmpNumberListCorrectedCount = 0;
    
    NSNumber *negitiveNum = [NSNumber numberWithShort:((short)(-1))];
    
    ///NSArray *theStuff;
    
    NSNumber *copyOfNumber = [theNewHeight copy];
    NSInteger indexOfNewNumber = 0;
    
    if (!(drawingMode == _drawFloorHeight || drawingMode == _drawCeilingHeight))
    {
        NSLog(@"WARNING: [LEMapDraw addNewHeight:%d] was called but drawingMode is not drawing heights...", 
                                                [theNewHeight intValue]);
        return;
    }
    
    if ([numberList containsObject:copyOfNumber])
    {
        SEND_ERROR_MSG_TITLE(@"A Height With That Number Already Exsists",
                             @"Already Exsists");
        return;
    }
    
    [numberTable removeAllObjects];
    [colorList removeAllObjects];
    
    // Add, Sort, And Find Index Of New Number...
    [numberList addObject:copyOfNumber];
    [numberList sortUsingSelector:@selector(compare:)];
    indexOfNewNumber = [numberList indexOfObjectIdenticalTo:copyOfNumber];
    
    // Insert name of the new number...
    [nameList insertObject:[copyOfNumber stringValue] atIndex:indexOfNewNumber];
    
    // Insert drawing map for new number...
    [numberDrawingMaps insertObject:[NSBezierPath bezierPath] atIndex:indexOfNewNumber];
    
    // Time to reconstruct the colorList with new colors...
    
    if (![numberList containsObject:negitiveNum])
    {
        /// listIncludesNone = NO;
        tmpNumberListCorrectedCount = [numberList count];
        hueMultiplier = (1.0 / ((float)tmpNumberListCorrectedCount));
    }
    else
    {
        /// listIncludesNone = YES;
        tmpNumberListCorrectedCount = [numberList count] - 1;
        hueMultiplier = (1.0 / ((float)tmpNumberListCorrectedCount));
        
        [colorList addObject:[NSColor 
            colorWithCalibratedHue: 0.0
                        saturation: 0.0
                        brightness: 0.89
                             alpha: 1.0 ]];
    }
    
    //Create the colors...
    for (i = 0; i < tmpNumberListCorrectedCount; i++)
    {
        [colorList addObject:[NSColor
            colorWithCalibratedHue: (hueMultiplier * i)
                        saturation: 1.0
                        brightness: 1.0
                             alpha: 1.0 ]];
    }
    
    /// NSMutableDictionary *numberTable;
    /// NSMutableArray *numberList, *numberDrawingMaps, *colorList, *nameList, *objsList;
    
    //Create a dictonary from the arrays...
    numer = [numberList objectEnumerator];
    numer2 = [numberDrawingMaps objectEnumerator];
    numer3 = [colorList objectEnumerator];
    numer4 = [nameList objectEnumerator];
    while  ((curNumber 	= [numer nextObject])	&& 
            (curMap 	= [numer2 nextObject])	&&
            (curName 	= [numer4 nextObject])	&&
            (curColor 	= [numer3 nextObject]))
    {
       /* if ([curNumber isEqual:negitiveNum])
        {
            curColor = 
        }
        else
            curColor = [numer3 nextObject];*/
            
        [numberTable addEntriesFromDictionary:
            [NSDictionary dictionaryWithObject:
                [NSArray arrayWithObjects:curMap, curColor, curName, nil]
            forKey:curNumber] ];
    }
    
    NSLog(@"numberTable: %lu colorList: %lu numberList:%lu nameList:%lu", (unsigned long)[numberTable count], (unsigned long)[colorList count], (unsigned long)[numberList count], (unsigned long)[nameList count]);
}

// *************************** Methods that draw the graphics ***************************
#pragma mark -
#pragma mark ********* Methods that draw the graphics *********

- (void)drawCeilingHeight:(NSRect)aRect
{
    NSEnumerator *numer;
    NSBezierPath *curDrawingMap, *tmpBP, *tmpBP2;
    NSArray *theStuff, *theMapPoints, *theMapLines;
    NSRect r;
    LELine *thisMapLine;
    
    [self updateRectCacheIn:aRect];
    
    [self createSpecialDrawingMap];
    
    if (numberListNeedsUpdating)
        [self createSpecialDrawingList];
    if (drawingHeightMapNeedsUpdating || numberListNeedsUpdating)
        [self createSpecialDrawingMap];
    
    [NSBezierPath setDefaultLineWidth:0];
    [NSBezierPath clipRect:aRect];
    
    [[NSGraphicsContext currentContext] setShouldAntialias:isAntialiasingOn]; // <- Antialiasing Off/On
    
    [[NSColor blackColor] set];
    NSRectFill(aRect); 	// Find better soulution, I don't think this needs to be here?
                        // I think you can use "Background Color" somthing or the other? instead!
    
    //NSLog(@"Before SM Count: %d", [numberTable count]);
    numer = [numberTable objectEnumerator];
    while (theStuff = [numer nextObject])
    {
        curDrawingMap = [theStuff objectAtIndex:0];
        [(NSColor*)[theStuff objectAtIndex:1] set];
        if (![curDrawingMap isEmpty])
            [curDrawingMap fill];
        //[[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:1.0 alpha:1.0] set];
        //[[NSColor whiteColor] set];
        //[curDrawingMap stroke];
    }
    
    theMapPoints = [currentLevel getThePoints];
    theMapLines = [currentLevel getTheLines];
    
    r.origin.x = aRect.origin.x - 100;
    r.origin.y = aRect.origin.y - 100;
    r.size.width = aRect.size.width + 200;
    r.size.height = aRect.size.height + 200;
    
    numer = [rectLines objectEnumerator];
    
    tmpBP = [NSBezierPath bezierPath];
    tmpBP2 = [NSBezierPath bezierPath];
    while (thisMapLine = [numer nextObject])
    {
       /*if ([self mouse:[[thisMapLine mapPoint1] as32Point] inRect:r] ||
            [self mouse:[[thisMapLine mapPoint2] as32Point] inRect:r]) { */
       
             //[NSBezierPath strokeLineFromPoint:[[theMapPoints objectAtIndex:[thisMapLine pointIndex1]] as32Point]
             //                          toPoint:[[theMapPoints objectAtIndex:[thisMapLine pointIndex2]] as32Point]];
            
            if ([thisMapLine clockwisePolygonOwner] != -1 && [thisMapLine conterclockwisePolygonOwner] != -1)
            {
                [tmpBP2 moveToPoint:[[thisMapLine mapPoint1] as32Point]];
                [tmpBP2 lineToPoint:[[thisMapLine mapPoint2] as32Point]];
            }
            else
            {
                [tmpBP moveToPoint:[[thisMapLine mapPoint1] as32Point]];
                [tmpBP lineToPoint:[[thisMapLine mapPoint2] as32Point]];
            }
    
       /* } */
   }
   
    if (![tmpBP isEmpty])
    {
        //[tmpBP setClip];
        [[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:1.0 alpha:1.0] set];
        [tmpBP stroke];
    }
    if (![tmpBP2 isEmpty])
    {
        [[NSColor colorWithCalibratedRed:0.0 green:0.85 blue:0.85 alpha:1.0] set];
        [tmpBP2 stroke];
    }
    
    //NSLog(@"After SM");
}

- (void)drawNormal:(NSRect)aRect // ********* Draw Normal Function *********
{
    NSEnumerator *numer;
    //NSGraphicsContext * tContext;
    LEMapPoint *thisMapPoint;
    LELine *thisMapLine;
    LEPolygon *thisMapPoly;
    LEMapObject *thisMapObject;
    NSArray *theMapPoints, *theMapLines, /* *theMapObjects,*/ *theMapPolys;  
    NSRect r;    
    NSBezierPath *tmpBP, *tmpBP2;
    
    //-(NSMutableArray *)layerPoints;
    //-(NSMutableArray *)layerLines;
    //-(NSMutableArray *)layerPolys;
    //-(NSMutableArray *)layerMapObjects;

   //     aRect.origin.x = -2048;
   //     aRect.origin.y = -2048;
   //     aRect.size.width = 4096;
  //      aRect.size.height = 4096;
    
    
    [self updateRectCacheIn:aRect];
    [self createObjectMaps];
    [self createPolyMap];
    [self createLineMap];
    
    //[NSBezierPath setDefaultLineWidth:0];
    
    [[NSGraphicsContext currentContext] setShouldAntialias:isAntialiasingOn]; // <- Antialiasing Off/On
    
    //Get the information
    
    if ([currentLevel settingAsBool:PhDrawOnlyLayerPoints])
        theMapPoints = [currentLevel layerPoints];
    else
        theMapPoints = [currentLevel getThePoints];
    
    theMapLines = [currentLevel getTheLines];
    //theMapObjects = [currentLevel theMapObjects];
    theMapPolys = [currentLevel getThePolys];
    
    //Set default NSBezier Stuff...
    [NSBezierPath setDefaultLineWidth:0];
    [NSBezierPath clipRect:aRect];
    
    // ********* Draw Background *********
    activateArchColor(PhBackgroundColor);
    NSRectFill(aRect); 	// Find better soulution, I don't think this needs to be here?
                        // I think you can use "Background Color" something or the other? instead!
    
    // ********* Draw Grid *********
    [self drawTheGrid];
    
    // ********* Draw Polygons *********
    [self drawThePolygons:aRect];
    
    // ********* Draw Any Selected Polygons *********
    if ([selectedPolys count] > 0)
    {
        NSBezierPath *polyPath = [NSBezierPath bezierPath];
        
        activateArchColor(PhPolygonSelectedColor); //Selected Polygonal Color
        numer = [selectedPolys objectEnumerator];
        while (thisMapPoly = [numer nextObject])
        { 
            [thisMapPoly thePolyMap:polyPath];
            if (![polyPath isEmpty])
            {
                [polyPath fill];
                [polyPath removeAllPoints];
            }
        }
    }
    
    //return;
    
    // ********* Draw Line Map *********
    tmpBP = lineDrawingMap;
    tmpBP2 = joinedLineDrawingMap;
    
    /*r.origin.x = aRect.origin.x - 100;
    r.origin.y = aRect.origin.y - 100;
    r.size.width = aRect.size.width + 200;
    r.size.height = aRect.size.height + 200;
    
    numer = [theMapLines objectEnumerator];
    
    tmpBP = [NSBezierPath bezierPath];
    tmpBP2 = [NSBezierPath bezierPath];
    //[tmpBP clipRect:[self bounds]];
    
    while (thisMapLine = [numer nextObject])
    {
       if ([self mouse:[[theMapPoints objectAtIndex:[thisMapLine pointIndex1]] as32Point] inRect:r] ||
            [self mouse:[[theMapPoints objectAtIndex:[thisMapLine pointIndex2]] as32Point] inRect:r]) { 
       
             //[NSBezierPath strokeLineFromPoint:[[theMapPoints objectAtIndex:[thisMapLine pointIndex1]] as32Point]
             //                          toPoint:[[theMapPoints objectAtIndex:[thisMapLine pointIndex2]] as32Point]];
            
            if ([thisMapLine clockwisePolygonOwner] != -1 && [thisMapLine conterclockwisePolygonOwner] != -1)
            {
                [tmpBP2 moveToPoint:[[theMapPoints objectAtIndex:[thisMapLine pointIndex1]] as32Point]];
                [tmpBP2 lineToPoint:[[theMapPoints objectAtIndex:[thisMapLine pointIndex2]] as32Point]];
            }
            else
            {
                [tmpBP moveToPoint:[[theMapPoints objectAtIndex:[thisMapLine pointIndex1]] as32Point]];
                [tmpBP lineToPoint:[[theMapPoints objectAtIndex:[thisMapLine pointIndex2]] as32Point]];
            }
    
       }
   }*/
   
    if (![tmpBP isEmpty]) // Regular
    {
        //[tmpBP setClip];
        activateArchColor(PhLineRegularColor);
        [self strokeABezierPath:tmpBP];
    }
    if (![tmpBP2 isEmpty]) // Between poly's
    {
        activateArchColor(PhLineConnectsPolysColor);
        [self strokeABezierPath:tmpBP2];
    }
    
    //[NSBezierPath clipRect:aRect];
    
    // ********* Draw The Points *********
    
    r.origin.x = aRect.origin.x - 1;
    r.origin.y = aRect.origin.y - 1;
    r.size.width = aRect.size.width + 2;
    r.size.height = aRect.size.height + 2;
    
    activateArchColor(PhPointRegularColor); // Regular Point Color
    
    numer = [theMapPoints objectEnumerator];
    while ((thisMapPoint = [numer nextObject]))
    {
        if ([self mouse:[thisMapPoint as32Point] inRect:r])
        {
            NSRect theMapPointRect = [thisMapPoint as32Rect];
            //theMapPointRect.origin.x = theMapPointRect.origin.x + 2048;
            //theMapPointRect.origin.y = theMapPointRect.origin.y + 2048;
            NSRectFill(theMapPointRect);
        }
    }
    
    // ********** Draw The Objects ********
    [self drawTheObjects:aRect];
    
    
    // ********** Draw Selected Lines ********
    
    if ([selectedLines count] > 0)
    {
        activateArchColor(PhLineSelectedColor); // Selected Lines
        numer = [selectedLines objectEnumerator];
        while (thisMapLine = [numer nextObject])
        { 
            [NSBezierPath strokeLineFromPoint:[[thisMapLine mapPoint1] as32Point]
                                      toPoint:[[thisMapLine mapPoint2] as32Point]];
            
        }
        
        archColorWithAlpha(PhLineRegularColor, 0.3); // Selected Lines Clock-Wise Side
        numer = [selectedLines objectEnumerator];
        while (thisMapLine = [numer nextObject])
        { 
            NSBezierPath *theShadowPath = [thisMapLine clockwiseShadowPath];
            if (theShadowPath != nil && ![theShadowPath isEmpty])
                [theShadowPath fill];
        }
   }
   
    // ********* Draw Selected Objects *********
    
    if ([selectedMapObjects count] > 0)
    {
        activateArchColor(PhObjectSelectedColor); // Selected Objects Fill
        numer = [selectedMapObjects objectEnumerator];
        while (thisMapObject = [numer nextObject]) { NSRectFill([thisMapObject as32Rect]); }
    }
    
    // ********* Draw Selected Points *********
    
    //NSLog(@"Selected Points Set Count(drawRect): %d", [selectedPoints count]);
    if ([selectedPoints count] > 0)
    {
        activateArchColor(PhPointSelectedColor); // Selected Points
        numer = [selectedPoints objectEnumerator];
        while ((thisMapPoint = [numer nextObject])) { NSRectFill([thisMapPoint as32Rect]); }
    }
    
    
    // ********* Draw Annotation Notes ********
    
    [self drawAnnotationNotes:aRect];
    
    // ********* Draw Bounding Box *********
                            
    if (drawBoundingBox == YES)
    {
        /*boundingBox.origin.x += 5;
        boundingBox.origin.y += 5;
        boundingBox.size.width -= 5;
        boundingBox.size.height -= 5;*/
        
        archColorWithAlpha(PhLineSelectedColor, 0.20); //PhPointRegularColor
        [NSBezierPath fillRect:boundingBox];
        
        archColorWithAlpha(PhLineSelectedColor, 0.90); //PhLineSelectedColor
        [NSBezierPath strokeRect:boundingBox];
    }
    
    
    // ********* End Of Regular Drawing Routine *********
    
    return;
}

-(void)drawThePolygons:(NSRect)aRect // ********* Draw Polygons *********
{
    if (currentLevel == nil)
        return;
    
    if (polyDrawingMap == nil || invalidPolyDrawingMap == nil)
        [self createPolyMap];
        
    archColorWithAlpha(PhPolygonRegularColor, 0.9);
    
    //activateArchColor(PhPolygonRegularColor);
    if (![polyDrawingMap isEmpty])
        [self fillABezierPath:polyDrawingMap];
    
    if (shouldDrawConvexPolyObjects)
    {
        archColorWithAlpha(PhPolygonNonConcaveColor, 0.9);
        if (![invalidPolyDrawingMap isEmpty])
            [self fillABezierPath:invalidPolyDrawingMap];
    }
    
    if (shouldDrawHillPolyObjects)
    {
        archColorWithAlpha(PhPolygonHillColor, 0.9);
        if (![hillPolyMap isEmpty])
            [self fillABezierPath:hillPolyMap];
    }
    
    if (shouldDrawZonePolyObjects)
    {
        archColorWithAlpha(PhPolygonZoneColor, 0.9);
        if (![zonePolyMap isEmpty])
            [self fillABezierPath:zonePolyMap];
    }
    
    if (shouldDrawTeleporterExitPolyObjects)
    {
        archColorWithAlpha(PhPolygonTeleporterColor, 0.9);
        if (![teleporterPolyMap isEmpty])
            [self fillABezierPath:teleporterPolyMap];
    }
    
    if (shouldDrawPlatfromPolyObjects)
    {
        archColorWithAlpha(PhPolygonPlatformColor, 0.9);
        if (![platformPolyMap isEmpty])
            [self fillABezierPath:platformPolyMap];
    }
}

-(void)drawTheObjects:(NSRect)aRect // ********* Draw Objects *********
{
    //NSColor *tmpColor1, *tmpColor2;
    //LEMapObject *thisMapObject;
    //NSEnumerator *numer;
    //NSRect r;
    
    //r.origin.x = aRect.origin.x - 2;
    //r.origin.y = aRect.origin.y - 2;
    //r.size.width = aRect.size.width + 4;
    //r.size.height = aRect.size.height + 4;
    
    //tmpColor1 = getArchColor(PhObjectBLineEnemyMonsterColor); // activateArchColor
    //tmpColor2 = getArchColor(PhObjectBLineItemColor); // activateArchColor
    
    //numer = [[currentLevel theMapObjects] objectEnumerator];
    
    [NSBezierPath setDefaultLineWidth:0];
    
    if (![monsterDrawingMap isEmpty])
    {
        activateArchColor(PhObjectEnemyMonsterColor);
        [self fillABezierPath:monsterDrawingMap];
        if (shouldObjectOutline)
        {
            activateArchColor(PhObjectBLineEnemyMonsterColor);
            [self strokeABezierPath:monsterDrawingMap];
        }
    }
    if (![playerDrawingMap isEmpty])
    {
        activateArchColor(PhObjectPlayerColor);
        [self fillABezierPath:playerDrawingMap];
        if (shouldObjectOutline)
        {
            activateArchColor(PhObjectBLinePlayerColor);
            [self strokeABezierPath:playerDrawingMap];
        }
    }
    if (![sceaneryDrawingMap isEmpty])
    {
        activateArchColor(PhObjectSceanryColor);
        [self fillABezierPath:sceaneryDrawingMap];
        if (shouldObjectOutline)
        {
            activateArchColor(PhObjectBLineSceanryColor);
            [self strokeABezierPath:sceaneryDrawingMap];
        }
    }
    if (![goalDrawingMap isEmpty])
    {
        activateArchColor(PhObjectGoalColor);
        [self fillABezierPath:goalDrawingMap];
        if (shouldObjectOutline)
        {
            activateArchColor(PhObjectBLineGoalColor);
            [self strokeABezierPath:goalDrawingMap];
        }
    }
    if (![soundDrawingMap isEmpty])
    {
        activateArchColor(PhObjectSoundColor);
        [self fillABezierPath:soundDrawingMap];
        if (shouldObjectOutline)
        {
            activateArchColor(PhObjectBLineSoundColor);
            [self strokeABezierPath:soundDrawingMap];
        }
    }
    if (![itemDrawingMap isEmpty])
    {
        activateArchColor(PhObjectItemColor);
        [self fillABezierPath:itemDrawingMap];
        if (shouldObjectOutline)
        {
            activateArchColor(PhObjectBLineItemColor);
            [self strokeABezierPath:itemDrawingMap];
        }
    }
}

-(void)drawTheGrid // ********* Draw The Grid *********
{
    //NSBezierPath *tmpBezierPath = nil;
    
    //Set default NSBezier Stuff...
    [NSBezierPath setDefaultLineWidth:0];
    
    if (theGridDrawingMap == nil)
        theGridDrawingMap = [NSBezierPath bezierPath];
    if (subGridDrawingMap == nil)
        subGridDrawingMap = [NSBezierPath bezierPath];
    if (centerGridDrawingMap == nil)
        centerGridDrawingMap = [NSBezierPath bezierPath];
    
    //Set default NSBezier Stuff...
    //[NSBezierPath setDefaultLineWidth:0];
    
    
    if (caculateTheGrid)
    {
        int i;
        float gridFactor = [currentLevel settingAsFloat:PhGridFactor]; // Used to be one...
        int gridFactorNeg = (int)((float)-32 / gridFactor);
        int gridFactorPos = (int)((float)32 / gridFactor);
        int gridSpacingFactor = (int)((float)2048 / gridFactorPos);
        NSBezierPath *currentGridDrawingMap;
        
        [theGridDrawingMap removeAllPoints];
        [subGridDrawingMap removeAllPoints];
        [centerGridDrawingMap removeAllPoints];
        
        if ([currentLevel settingAsBool:PhEnableGridBool])
        {
            for  (i = gridFactorNeg; i < gridFactorPos ; i++)
            {
                int gridYCordinate = (i * gridSpacingFactor);
                
                if (gridYCordinate == 0)
                    currentGridDrawingMap = centerGridDrawingMap;
                else if (gridYCordinate % 64 == 0)
                    currentGridDrawingMap = theGridDrawingMap;
                else
                    currentGridDrawingMap = subGridDrawingMap;
                
                [currentGridDrawingMap moveToPoint:NSMakePoint(-2048, gridYCordinate)];
                [currentGridDrawingMap lineToPoint:NSMakePoint(2048, gridYCordinate)];
            }
            for  (i = gridFactorNeg; i < gridFactorPos; i++)
            {
                int gridXCordinate = (i * gridSpacingFactor);
                
                if (gridXCordinate == 0)
                    currentGridDrawingMap = centerGridDrawingMap;
                else if (gridXCordinate % 64 == 0)
                    currentGridDrawingMap = theGridDrawingMap;
                else
                    currentGridDrawingMap = subGridDrawingMap;
                    
                [currentGridDrawingMap moveToPoint:NSMakePoint((i * gridSpacingFactor), 2048)];
                [currentGridDrawingMap lineToPoint:NSMakePoint((i * gridSpacingFactor), -2048)];
            }
        }
        
        //tmpBezierPath = [trans transformBezierPath:theGridDrawingMap];
        //[theGridDrawingMap release];
        //theGridDrawingMap = [tmpBezierPath retain];
        
        caculateTheGrid = NO;
    }
    
    if (![theGridDrawingMap isEmpty])
    {
        activateArchColor(PhWorldUnitGridColor); // World Unit Grid Color
        [self strokeABezierPath:theGridDrawingMap];
    }
    
    if (![centerGridDrawingMap isEmpty])
    {
        activateArchColor(PhCenterWorldUnitGridColor); // Center World Unit Grid Color
        [self strokeABezierPath:centerGridDrawingMap];
    }
    /*if (![theGridDrawingMap isEmpty])
    {
        activateArchColor(PhWorldUnitGridColor); // World Unit Grid Color
        [theGridDrawingMap stroke];
    }*/
    if (![subGridDrawingMap isEmpty])
    {
        activateArchColor(PhSubWorldUnitGridColor); // Sub-World Unit Grid Color
        [self strokeABezierPath:subGridDrawingMap];
    }
    return;
}


- (void)fillABezierPath:(NSBezierPath *)thePathObject
{
    //[[trans transformBezierPath:thePathObject] fill];
    [thePathObject fill];
}

- (void)strokeABezierPath:(NSBezierPath *)thePathObject
{
    //[[trans transformBezierPath:thePathObject] stroke];
    [thePathObject stroke];
}

- (void)drawAnnotationNotes:(NSRect)aRect
{
    NSEnumerator *numer = nil;
    PhAnnotationNote *note = nil;
    PhNoteGroup *grp = nil;
    NSColor *color = nil;
    
    //NSLog(@"A");
    
    //numer = [[currentLevel getNotes] objectEnumerator];
    numer = [rectNotes objectEnumerator];
    while (note = [numer nextObject])
    {
        grp = [note group];
        
        if (grp != nil)
        {
            if ([grp isVisible] == NO)
                continue;
            
            if ([grp color] != nil)
                color = [grp color];
            else
                color = [NSColor greenColor];
        }
        else
            color = [NSColor greenColor];
        
        if ([selectedNotes containsObject:note])
        {
            color = unarchive(prefColor(PhLineSelectedColor));
        }
        
        // sizeWithAttributes:
        
        //NSRect bounds = [note drawingBounds];
        //activateArchColor(PhLineSelectedColor);
        //NSRectFill(bounds);
        
        [[note text] drawAtPoint:[note locationAdjusted] withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                    
                                        color,
                                        NSForegroundColorAttributeName,
                    
                                        [NSFont fontWithName:@"Courier" size:16.0],
                                        NSFontAttributeName, nil]];
    }
    
}


// *************************** Methods for creating the drawing maps :) ***************************
#pragma mark -
#pragma mark ********* Methods for creating the drawing maps :) *********

-(void)createObjectMaps
{
    LEMapObject *thisMapObject;
    NSEnumerator *numer;
    //NSRect r;
    BOOL showAngle;
    NSBezierPath *theCurDrawingMap;
    
    //LEPolygon *thisPolygon;
    //NSArray *thePolys, *theMapPoints;
    NSSet *theMapObjects;
         
    if (currentLevel == nil) //There is no level currently...
        return;
    
    [monsterDrawingMap removeAllPoints];
    [playerDrawingMap removeAllPoints];
    [sceaneryDrawingMap removeAllPoints];
    [goalDrawingMap removeAllPoints];
    [soundDrawingMap removeAllPoints];
    [itemDrawingMap removeAllPoints];
    
    //   ---   ---   ---
    
    //tmpColor1 = getArchColor(PhObjectBLineEnemyMonsterColor); // activateArchColor
    //tmpColor2 = getArchColor(PhObjectBLineItemColor); // activateArchColor
    
    //-(NSMutableArray *)layerPoints;
    //-(NSMutableArray *)layerLines;
    //-(NSMutableArray *)layerPolys;
    //-(NSMutableArray *)layerMapObjects;
    
    theMapObjects = rectObjects;//[currentLevel layerMapObjects];
    
    numer = [theMapObjects objectEnumerator];
    while (thisMapObject = [numer nextObject])
    {
        //NSLog(@"*1* examining object: %d - %d", [thisMapObject index], [theMapObjects indexOfObjectIdenticalTo:thisMapObject]);
        //NSBez
        switch ([thisMapObject type])
        {
            case _saved_monster:
                if (!shouldDrawEnemyMonstersObjects)
                    continue;
                showAngle = YES;
                theCurDrawingMap = monsterDrawingMap;
                break;
            case _saved_player:
                if (!shouldDrawPlayerObjects)
                    continue;
                showAngle = YES;
                theCurDrawingMap = playerDrawingMap;
                break;
            case _saved_object:
                if (!shouldDrawSceanryObjects)
                    continue;
                showAngle = NO;
                theCurDrawingMap = sceaneryDrawingMap;
                break;
            case _saved_item:
                if (!shouldDrawItemObjects)
                    continue;
                showAngle = NO;
                theCurDrawingMap = itemDrawingMap;
                break;
            case _saved_goal:
                if (!shouldDrawGoalObjects)
                    continue;
                showAngle = NO;
                theCurDrawingMap = goalDrawingMap;
                break;
            case _saved_sound_source:
                if (!shouldDrawSoundObjects)
                    continue;
                showAngle = NO;
                theCurDrawingMap = soundDrawingMap;
                break;
            default:
                showAngle = NO;
                theCurDrawingMap = nil;
                NSLog(@"ERROR: unkown object type??? Object Index: %lu, I will skip it...", (unsigned long)[[currentLevel layerMapObjects] indexOfObjectIdenticalTo:thisMapObject]);
                return;
        }
        
        if (showAngle)
        {
            //x and y are the object's coordinates
            //NSBezierPath *theTriangle;
            //you know the angle
            float angle = [thisMapObject facing] / 256.0 * M_PI;
            ///NSPoint objPoints[3];
            NSPoint p1, p2, p3;
            
            short x = [thisMapObject x32];
            short y = [thisMapObject y32];
            
            // marathon angles are between 0 and 512 degrees
            // we convert to radians here
            
            p1.x = x + (short)(6.0 * cos(angle + (225.0 / 180.0 * M_PI)));
            p1.y = y + (short)(6.0 * sin(angle + (225.0 / 180.0 * M_PI)));
            /* if you imagine the triangle point upwards, this is the bottom left (225
            degrees (out of 360) from north) 6 is the distance of the point from the
            centre */
            
            p2.x = x + (short)(6.0 * cos(angle + (135.0 / 180.0 * M_PI)));
            p2.y = y + (short)(6.0 * sin(angle + (135.0 / 180.0 * M_PI)));
            /* this is the bottom right */
            
            p3.x = x + (short)(8.0 * cos(angle));
            p3.y = y + (short)(8.0 * sin(angle));
            /* this is the top point  8 pixels from the centre*/
            
            // use: theCurDrawingMap
            //[theCurDrawingMap appendBezierPathWithPoints:objPoints count:3];
            [theCurDrawingMap moveToPoint:p1];
            [theCurDrawingMap lineToPoint:p2];//theCurDrawingMap
            [theCurDrawingMap lineToPoint:p3];
            //[monsterDrawingMap lineToPoint:p1];
            /*NSLog(@"Closeing Path on object: %d, [thisMapObject y32]: %d",
                    [theMapObjects indexOfObjectIdenticalTo:thisMapObject], [thisMapObject y32]);*/
            [theCurDrawingMap closePath];
            
            //you might want to scale the 6 and 8, and change the 135 and 225 degree
            //angles. ; I might Might... :)
        }
        else
        {
            NSPoint objPoints[4];
            
            //[thisMapObject x32]-2, [thisMapObject y32]-2, 4, 4
            objPoints[0].x = [thisMapObject x32] - 2;
            objPoints[0].y = [thisMapObject y32] - 2;
            objPoints[1].x = [thisMapObject x32] + 2;
            objPoints[1].y = objPoints[0].y;
            objPoints[2].x = objPoints[1].x;
            objPoints[2].y = [thisMapObject y32] + 2;
            objPoints[3].x = objPoints[0].x;
            objPoints[3].y = objPoints[2].y;
            
            //[theCurDrawingMap appendBezierPathWithPoints:objPoints count:4];
            [theCurDrawingMap moveToPoint:objPoints[0]];
            [theCurDrawingMap lineToPoint:objPoints[1]];
            [theCurDrawingMap lineToPoint:objPoints[2]];
            [theCurDrawingMap lineToPoint:objPoints[3]];
            [theCurDrawingMap closePath];
        }
    }
}

- (BOOL)createSpecialDrawingMap
{
    LEPolygon *thisPolygon;
    NSSet *thePolys, *theMapPoints;
    NSEnumerator *numer;
    NSBezierPath *curDrawingMap;
    int heightMode = [self currentDrawingMode];
     
    if (currentLevel == nil) //There is no level currently...
        return NO;
    
    theMapPoints = rectPoints;//[currentLevel getThePoints];
    thePolys = rectPolys;//[currentLevel getThePolys];
    
    numer = [numberTable objectEnumerator];
    
    while ((curDrawingMap = [[numer nextObject] objectAtIndex:0]))
    {
        [curDrawingMap removeAllPoints];
    }
    
    for (LEPolygon *thisPolygon in thePolys)
    {
        short theCurrentVertexCount;
        //short *theVertexes;
        short i;
        
        switch (heightMode)
        {
            case _drawCeilingHeight:
                curDrawingMap = [[numberTable objectForKey:[NSNumber numberWithShort:[thisPolygon ceilingHeight]]] objectAtIndex:0];
                break;
            case _drawFloorHeight:
                curDrawingMap = [[numberTable objectForKey:[NSNumber numberWithShort:[thisPolygon floorHeight]]] objectAtIndex:0];
                break;
            case _drawLiquids:
                curDrawingMap = [[numberTable objectForKey:[NSNumber numberWithShort:[thisPolygon mediaIndex]]] objectAtIndex:0];
                break;
            case _drawFloorLights:
                curDrawingMap = [[numberTable objectForKey:[NSNumber numberWithShort:[thisPolygon floorLightsourceIndex]]] objectAtIndex:0];
                break;
            case _drawCeilingLights:
                curDrawingMap = [[numberTable objectForKey:[NSNumber numberWithShort:[thisPolygon ceilingLightsourceIndex]]] objectAtIndex:0];
                break;
            case _drawLiquidLights:
                curDrawingMap = [[numberTable objectForKey:[NSNumber numberWithShort:[thisPolygon mediaLightsourceIndex]]] objectAtIndex:0];
                break;
            case _drawAmbientSounds:
                curDrawingMap = [[numberTable objectForKey:[NSNumber numberWithShort:[thisPolygon ambientSoundImageIndex]]] objectAtIndex:0];
                break;
            case _drawLayers: //currentLevel
                curDrawingMap = [[numberTable objectForKey:[NSNumber numberWithShort:[[thisPolygon polyLayer] index]]] objectAtIndex:0];
                break;
            default:
                NSLog(@"Unknown Number Drawing Mode In Number Poly Map Creation!");
                return NO;
        }
        
        if (curDrawingMap == nil)
        {
            SEND_ERROR_MSG(@"ERROR: no key value for height!!! 101");
            return NO;
        }
        
        //thisPolygon = [thePolys objectAtIndex:44];
        
        theCurrentVertexCount = [thisPolygon getTheVertexCount];
        //theVertexes = [thisPolygon getTheVertexes];
        
        //NSLog(@"The Poly Vertex Count (drawing): %d", theCurrentVertexCount);
        
        //If there is not at least 3 points, there can be no polygon as far as marathon is concerned (in theory) :)
        if (theCurrentVertexCount > 2) 
        {
            //NSLog(@"moving to point index: %d", theVertexes[0]);
            [curDrawingMap moveToPoint:[[thisPolygon vertexObjectAtIndex:0] as32Point]];
            for (i = 1; i < theCurrentVertexCount; i++)
            {
                // theTmpPoint = [[theMapPoints objectAtIndex:theVertexes[i]] as32Point];
                
                //NSLog(@"creating line to point index: %d   which has x: %d  y: %d",
                //theVertexes[i], [[theMapPoints objectAtIndex:theVertexes[i]] x32],
                //[[theMapPoints objectAtIndex:theVertexes[i]] y32]);
                
                [curDrawingMap lineToPoint:[[thisPolygon vertexObjectAtIndex:i] as32Point]];
            }
            [curDrawingMap closePath];
        }
    }
    
    drawingHeightMapNeedsUpdating = NO;
    //[self setNeedsDisplay:YES];
    //NSLog(@"Done with special drawing map creation! :)");
    return YES;
}

-(void)createPolyMap
{
    LEPolygon *thisPolygon;
    NSSet *thePolys, *theMapPoints;
    NSEnumerator *numer;
     
    if (currentLevel == nil) //There is no level currently...
        return;
    
    if (polyDrawingMap == nil) //release this if not nill?
        polyDrawingMap = [NSBezierPath bezierPath];
    if (invalidPolyDrawingMap == nil) //release this if not nill?
        invalidPolyDrawingMap = [NSBezierPath bezierPath];
    if (platformPolyMap == nil)
        platformPolyMap = [NSBezierPath bezierPath];
    if (teleporterPolyMap == nil)
        teleporterPolyMap = [NSBezierPath bezierPath];
    if (zonePolyMap == nil)
        zonePolyMap = [NSBezierPath bezierPath];
    if (hillPolyMap == nil)
        hillPolyMap = [NSBezierPath bezierPath];
    
    // I don't set to two above to nil becuase I allocate another
    // NSBezierPath for them on the very next step...
    
    [polyDrawingMap removeAllPoints];
    [invalidPolyDrawingMap removeAllPoints];
    [zonePolyMap removeAllPoints];
    [teleporterPolyMap removeAllPoints];
    [platformPolyMap removeAllPoints];
    [hillPolyMap removeAllPoints];
    
    //-(NSMutableArray *)layerPoints;
    //-(NSMutableArray *)layerLines;
    //-(NSMutableArray *)layerPolys;
    
    theMapPoints = rectPoints;//[currentLevel layerPoints];
    thePolys = rectPolys;//[currentLevel layerPolys];
    
    numer = [thePolys objectEnumerator];
    
    while (thisPolygon = [numer nextObject])
    {
        NSBezierPath *polyDrawingMapPntr;
        short theCurrentVertexCount;
        //short *theVertexes;
        short i;
        
        //thisPolygon = [thePolys objectAtIndex:44];
        
        theCurrentVertexCount = [thisPolygon getTheVertexCount];
        //theVertexes = [thisPolygon getTheVertexes];
        
        //NSLog(@"The Poly Vertex Count (drawing): %d", theCurrentVertexCount);
        
        //If there is not at least 3 points, there can be no polygon as far as marathon is concerned (in theory) :)
        if (theCurrentVertexCount > 2) 
        {
            int curPolyType = [thisPolygon type];
            
            if ((![thisPolygon polygonConcaveFlag]) && shouldDrawConvexPolyObjects)
                polyDrawingMapPntr = invalidPolyDrawingMap;
            
            else if (curPolyType == _polygon_is_normal)
                polyDrawingMapPntr = polyDrawingMap;
            
            else if (curPolyType == _polygon_is_platform && shouldDrawPlatfromPolyObjects)
                polyDrawingMapPntr = platformPolyMap;
            
            else if ((curPolyType == _polygon_is_teleporter ||
                     curPolyType == _polygon_is_automatic_exit)
                     && shouldDrawTeleporterExitPolyObjects)
                polyDrawingMapPntr = teleporterPolyMap;
            
            else if (curPolyType == _polygon_is_zone_border && shouldDrawZonePolyObjects)
                polyDrawingMapPntr = zonePolyMap;
            
            else if ((curPolyType == _polygon_is_hill || curPolyType == _polygon_is_base)
                            && shouldDrawHillPolyObjects)
                polyDrawingMapPntr = hillPolyMap;
            
            else 
                polyDrawingMapPntr = polyDrawingMap;
            
            //NSLog(@"moving to point index: %d", theVertexes[0]);
            [polyDrawingMapPntr moveToPoint:[[thisPolygon vertexObjectAtIndex:0] as32Point]];
            for (i = 1; i < theCurrentVertexCount; i++)
            {
                // theTmpPoint = [[theMapPoints objectAtIndex:theVertexes[i]] as32Point];
                
                //NSLog(@"creating line to point index: %d   which has x: %d  y: %d",
                //theVertexes[i], [[theMapPoints objectAtIndex:theVertexes[i]] x32],
                //[[theMapPoints objectAtIndex:theVertexes[i]] y32]);
                
                [polyDrawingMapPntr lineToPoint:[[thisPolygon vertexObjectAtIndex:i] as32Point]];
            }
            [polyDrawingMapPntr closePath];
        }
    }
    //NSLog(@"I Caculated The Poly Map! The New Polygonal Information should not be in effect...");
    
    [self createLineMap];
    
    return;
}

-(void)createLineMap
{
    LELine *thisLine;
    NSSet *theMapLines, *theMapPoints;
    NSEnumerator *numer;
    
    if (currentLevel == nil) //There is no level currently...
    {
        joinedLineDrawingMap = nil;
        lineDrawingMap = nil;
        
        return;
    }
    
    if (lineDrawingMap == nil)
        lineDrawingMap = [[NSBezierPath alloc] init];
    
    if (joinedLineDrawingMap == nil)
        joinedLineDrawingMap = [[NSBezierPath alloc] init];
    
    [lineDrawingMap removeAllPoints];
    
    [joinedLineDrawingMap removeAllPoints];
    
    //-(NSMutableArray *)layerPoints;
    //-(NSMutableArray *)layerLines;
    //-(NSMutableArray *)layerPolys;
    
    theMapPoints = rectPoints;//[currentLevel layerPoints];
    theMapLines = rectLines;//[currentLevel layerLines];
    
    numer = [theMapLines objectEnumerator];
    
    while ((thisLine = [numer nextObject]))
    {
        if ([thisLine clockwisePolygonObject] != nil && [thisLine conterclockwisePolygonObject] != nil)
        {
            [joinedLineDrawingMap moveToPoint:[[thisLine mapPoint1] as32Point]];
            [joinedLineDrawingMap lineToPoint:[[thisLine mapPoint2] as32Point]];
        }
        else
        {
            [lineDrawingMap moveToPoint:[[thisLine mapPoint1] as32Point]];
            [lineDrawingMap lineToPoint:[[thisLine mapPoint2] as32Point]];
        }
    }
}

// *************************** List Methods ***************************
#pragma mark -
#pragma mark ********* List Methods *********

-(BOOL)createSpecialDrawingList
{
    LEPolygon *thisPolygon;
    NSArray *thePolys, *theMapPoints, *theAmbientSounds, *theLights, *theLiquids, *theLevelLayerArray;
    NSMutableArray *tmpNumberList, *tmpNumberDrawingMaps, *tmpColorList, *tmpNameList, *tmpObjsList;
    NSEnumerator *numer, *numer2, *numer3, *numer4;
    NSNumber *curNumber;
    NSString *curName;
    NSBezierPath *curMap;
    NSColor *curColor;
    NSNumber *theNumber;
    id thisObj;
    
    int heightMode = [self currentDrawingMode];
    NSInteger tmpNumberListCorrectedCount, tmpNumberListCount;
    int i;
    float hueMultiplier;
    BOOL listIncludesNone;
    
    //Remove all previous entrys...
    [numberTable removeAllObjects];
    //[numberList removeAllObjects];
    [numberDrawingMaps removeAllObjects];
    [colorList removeAllObjects];
    [nameList removeAllObjects];
    [objsList removeAllObjects];
    
    // *** Start Main Code ***
     
    if (currentLevel == nil) //There is no level currently...
        return NO;
    
    if (numberTable == nil)
        numberTable = [[NSMutableDictionary alloc] initWithCapacity:1];
    if (nameList == nil)
        nameList = [[NSMutableArray alloc] initWithCapacity:1];
    if (objsList == nil)
        objsList =  [[NSMutableArray alloc] initWithCapacity:1];
      
    tmpNumberList = [[NSMutableArray alloc] initWithCapacity:1];
    tmpNameList = [[NSMutableArray alloc] initWithCapacity:1];
    tmpObjsList = [[NSMutableArray alloc] initWithCapacity:1];
    
    //numberTable = NSMutableDictionary;
    
    
    theMapPoints = [currentLevel getThePoints];
    thePolys = [currentLevel getThePolys];
    theAmbientSounds = [currentLevel getAmbientSounds];
    theLights = [currentLevel getLights];
    theLiquids = [currentLevel getMedia];
    theLevelLayerArray = [currentLevel layersInLevel];
    //getRandomSounds
    //getPlatforms
    
    if (heightMode == _drawCeilingHeight || heightMode == _drawFloorHeight)
    {
        numer = [thePolys objectEnumerator];
        while (thisPolygon = [numer nextObject])
        {
            // Get the correct height...
            switch (heightMode)
            {
                case _drawCeilingHeight:
                    theNumber = [NSNumber numberWithShort:[thisPolygon ceilingHeight]];
                    break;
                case _drawFloorHeight:
                    theNumber = [NSNumber numberWithShort:[thisPolygon floorHeight]];
                    break;
                default:
                    SEND_ERROR_MSG(@"Unkown list query mode, #103.");
                    [self setDrawModeToNormal:self];
                    return NO;
                    break;
            }
            
            //Check to see if this number is already in the list...
            if ([tmpNumberList indexOfObject:theNumber] == NSNotFound)
            {
                [tmpNumberList addObject:theNumber];
            }
        }
        
        tmpNumberListCount = [tmpNumberList count];
        
        // check to see if the array contains more then one height...
        if (tmpNumberListCount > 1)
        {
            // if it does contain more then one object, sort it...
            [tmpNumberList sortUsingSelector:@selector(compare:)];
        }
    }
    else
    {
        NSArray<PhAbstractName*> *theArray = nil;
        // Get the correct height...
        switch (heightMode)
        {
            case _drawCeilingHeight:
            case _drawFloorHeight:
                SEND_ERROR_MSG(@"Sorry, but an error occured puting together the list, #101.");
                [self setDrawModeToNormal:self];
                return NO;
            case _drawLiquids:
                theArray = theLiquids;
                [tmpNumberList addObject:@-1];
                [tmpNameList addObject:@"NONE"];
                break;
            case _drawFloorLights:
            case _drawCeilingLights:
            case _drawLiquidLights:
               theArray = theLights;
                break;
            case _drawAmbientSounds:
                theArray = theAmbientSounds;
                [tmpNumberList addObject:@-1];
                [tmpNameList addObject:@"NONE"];
                break;
            case _drawLayers:
                theArray = theLevelLayerArray;
                break;
            default:
                SEND_ERROR_MSG(@"Unkown list query mode, #102.");
                [self setDrawModeToNormal:self];
                return NO;
        } // end switch (heightMode)
        
        for (PhAbstractName *thisObj in theArray)
        {
            [tmpNumberList addObject:[NSNumber numberWithInt:[thisObj index]]];
            [tmpNameList addObject:[thisObj phName]];
        }
    } // end else
    
    // *** Get the assoicated Objects ***
    
    numer = [tmpNumberList objectEnumerator];
    for (NSNumber *theNumber in tmpNumberList)
    {
        // Get the correct height...
        if (heightMode == _drawCeilingHeight || heightMode == _drawFloorHeight)
            break;
        
        if ([theNumber intValue] == -1)
            continue;
        
        switch (heightMode)
        {
            case _drawLiquids:
                thisObj = [theLiquids objectAtIndex:[theNumber integerValue]];
                break;
            case _drawFloorLights:
                thisObj = [theLights objectAtIndex:[theNumber integerValue]];
                break;
            case _drawCeilingLights:
                thisObj = [theLights objectAtIndex:[theNumber integerValue]];
                break;
            case _drawLiquidLights:
                thisObj = [theLights objectAtIndex:[theNumber integerValue]];
                break;
            case _drawAmbientSounds:
                thisObj = [theAmbientSounds objectAtIndex:[theNumber integerValue]];
                break;
            case _drawLayers: //currentLevel
                thisObj = [theLevelLayerArray objectAtIndex:[theNumber integerValue]];
                break;
            default:
                SEND_ERROR_MSG(@"Unkown list query mode, #105.");
                [self setDrawModeToNormal:self];
                return NO;
                break;
        }
        
        if (thisObj == nil)
        {
            // thisObj should not be nil at this point, ERROR
            SEND_ERROR_MSG(@"When geting objects from the list, one of them was nil!");
            [self setDrawModeToNormal:self];
            return NO;
        }
        
        //Check to see if thisObj is already in the list...
        // It should not be, but just to make sure!!!
        if ([tmpObjsList indexOfObjectIdenticalTo:thisObj] == NSNotFound)
        {
            [tmpObjsList addObject:thisObj];
        }
        else // there should be no duplicates, ERROR
        {
            SEND_ERROR_MSG(@"When geting objects from the list, there was a duplicate!");
            [self setDrawModeToNormal:self];
            return NO;
        }
    }

    if (heightMode == _drawCeilingHeight || heightMode == _drawFloorHeight)
    {
        for (NSNumber *curNumber in tmpNumberList)
        {
            NSString *theName;
            
            if ([curNumber intValue] == -1) {
                theName = @"NONE";
            } else {
                // Get the correct height...
                switch (heightMode)
                {
                    case _drawCeilingHeight:
                        //theName = [[NSNumber numberWithFloat:(([curNumber floatValue])/((float)1024))] stringValue];
                        theName = [curNumber stringValue];
                        //theName = [[[NSDecimalNumber numberWithFloat:(([curNumber floatValue])/((float)1024))] decimalNumberByRoundingAccordingToBehavior:[currentLevel roundingSettings]] stringValue];
                        
                        //ceilingHeightAsDecimalString
                        
                        break;
                    case _drawFloorHeight:
                        theName = [curNumber stringValue];
                        //theName = [[NSNumber numberWithFloat:(([curNumber floatValue])/((float)1024))] stringValue];
                        
                        //theName = [[[NSDecimalNumber numberWithFloat:(([curNumber floatValue])/((float)1024))] decimalNumberByRoundingAccordingToBehavior:[currentLevel roundingSettings]] stringValue];
                        
                        break;
                    default:
                        SEND_ERROR_MSG(@"Unkown list query mode, #104.");
                        [self setDrawModeToNormal:self];
                        return NO;
                        break;
                }
            }
            
            [tmpNameList addObject:theName];
        }
    } // END if (heightMode == _drawCeilingHeight || heightMode == _drawFloorHeight)
    
    tmpNumberListCount = [tmpNumberList count];
    
    //Allocate the array...
    tmpNumberDrawingMaps = [[NSMutableArray alloc] initWithCapacity:1];
    
    //Create the drawing maps...
    for (i = 0; i < tmpNumberListCount; i++)
    {
        [tmpNumberDrawingMaps addObject:[NSBezierPath bezierPath]];
    }
    
    //Allocate the array...
    tmpColorList = [[NSMutableArray alloc] initWithCapacity:1];
    
    //if (heightMode == _drawAmbientSounds || _drawLiquidLights:_drawLiquids
    if ([tmpNumberList indexOfObject:[NSNumber numberWithShort:((short)(-1))]] == NSNotFound)
    {
        listIncludesNone = NO;
        tmpNumberListCorrectedCount = [tmpNumberList count];
        hueMultiplier = (1.0 / ((float)tmpNumberListCorrectedCount));
    }
    else
    {
        listIncludesNone = YES;
        tmpNumberListCorrectedCount = [tmpNumberList count] - 1;
        hueMultiplier = (1.0 / ((float)tmpNumberListCorrectedCount));
    }
    
    //Create the colors...
    for (i = 0; i < tmpNumberListCorrectedCount; i++)
    {
        [tmpColorList addObject:[NSColor
            colorWithCalibratedHue: (hueMultiplier * i)
                        saturation: 1.0
                        brightness: 1.0
                             alpha: 1.0 ]];
    }
    
    //Create a dictonary from the arrays...
    numer = [tmpNumberList objectEnumerator];
    numer2 = [tmpNumberDrawingMaps objectEnumerator];
    numer3 = [tmpColorList objectEnumerator];
    numer4 = [tmpNameList objectEnumerator];
    while  ((curNumber = [numer nextObject]) && 
            (curMap = [numer2 nextObject]) &&
            (curName = [numer4 nextObject]))
    {
        if ([curNumber isEqual:[NSNumber numberWithShort:-1]])
        {
            curColor = [NSColor
            colorWithCalibratedHue: 0.0
                        saturation: 0.0
                        brightness: 0.89
                             alpha: 1.0 ];
        }
        else
        {
            curColor = [numer3 nextObject];
        }
            
        [numberTable addEntriesFromDictionary:
            [NSDictionary dictionaryWithObject:
                [NSArray arrayWithObjects:curMap, curColor, curName, nil]
            forKey:curNumber]
        ];
    }
    
    if (listIncludesNone)
    {
        [tmpColorList insertObject:
                [NSColor colorWithCalibratedHue: 0.0
                                     saturation: 0.0
                                     brightness: 0.89
                                          alpha: 1.0	]
                                        atIndex: 0	];
    }
    
    //Keep Track Of The Arrays...
    if (numberList != nil) {
        numberList = nil;
    }
    if (numberDrawingMaps != nil) {
        numberDrawingMaps = nil;
    }
    if (colorList != nil) {
        colorList = nil;
    }
    if (nameList != nil) {
        nameList = nil;
    }
    if (objsList != nil) {
        objsList = nil;
    }
    
    numberList = tmpNumberList;
    NSLog(@"numberList count: %lu", (unsigned long)[numberList count]);
    
    if ([tmpObjsList count] > 0)
    {
        objsList = tmpObjsList;
    }
    else
    {
        tmpObjsList = nil;
        objsList = nil;
    }
    
    numberDrawingMaps =  tmpNumberDrawingMaps;
    colorList =  tmpColorList;
    nameList = tmpNameList;
    
    //release the temp arrays...
    //[tmpNumberList release];
    //[tmpNumberDrawingMaps release];
    //[tmpColorList release];
    
    numberListNeedsUpdating = NO;
    
    //[[PhColorListController sharedColorListController] updateInterface:self];
    [colorListObject updateInterface:self];
    return YES;
}

// *************************** Moving/Dragging Methods ***************************
#pragma mark -
#pragma mark ********* Moving/Dragging Methods *********

-(void)recenterViewToPoint:(NSPoint)newctr
{
    // Get the document visible rect - what portion of us is currently visible
    NSRect dvr = [scrollView documentVisibleRect];

    // Find the center point in the window
    NSPoint viewctr;
    viewctr.x = dvr.origin.x + (dvr.size.width / 2.0);
    viewctr.y = dvr.origin.y + (dvr.size.height / 2.0);

    // What's the offset between the real center and the intended center?
    NSPoint offset;
    offset.x = newctr.x - viewctr.x;
    offset.y = newctr.y - viewctr.y;

    // Apply that difference to the origin to get the new origin
    NSPoint neworigin;
    neworigin.x = offset.x + dvr.origin.x;
    neworigin.y = offset.y + dvr.origin.y;

    [self scrollPoint:neworigin];
}


- (void)moveSelectedTo:(NSPoint)theLocation
{
    
    
    if ([selectedPoints count] > 0 || [selectedMapObjects count] > 0 || [selectedNotes count] > 0)
    {
        /*BOOL cPolyM = NO, cMonsterM = NO, cItemM = NO, cPlayerM = NO,
                cSceaneryM = NO, cGoalM = NO, cSoundM = NO;*/
        id curObj;
        //NSRect drawingBounds = NSUnionRect([self drawingBoundsForSelections],
        //                        [self drawingBoundsForObjects:includeInBounds]);
        NSRect oldDrawingBounds = [self drawingBoundsForSelections];
        NSEnumerator *numer = [selections objectEnumerator];
        
        numer = [selectedPoints objectEnumerator];
        while (curObj = [numer nextObject])
        {
            [(LEMapPoint *)undoWith(curObj) setY32:[curObj y32]];
            [(LEMapPoint *)undoWith(curObj) setX32:[curObj x32]];
            [(LEMapPoint *)curObj setY32:theLocation.y];
            [(LEMapPoint *)curObj setX32:theLocation.x];
        }
        
        numer = [selectedMapObjects objectEnumerator];
        while (curObj = [numer nextObject])
        {
			[(LEMapObject *)undoWith(curObj) setY32:[curObj y32]];
			[(LEMapObject *)undoWith(curObj) setX32:[curObj x32]];
			[(LEMapObject *)curObj setY32:theLocation.y];
			[(LEMapObject *)curObj setX32:theLocation.x];
        }
        
        numer = [selectedNotes objectEnumerator];
        while (curObj = [numer nextObject])
        {
            [(PhAnnotationNote *)undoWith(curObj) set32Y:[curObj y32]];
            [(PhAnnotationNote *)undoWith(curObj) set32X:[curObj x32]];
            [(PhAnnotationNote *)curObj set32Y:theLocation.y];
            [(PhAnnotationNote *)curObj set32X:theLocation.x];
        }
        
        /*if (cMonsterM)
            [self createObjectMaps];
        else if (cItemM)
            [self createObjectMaps];
        else if (cPlayerM)
            [self createObjectMaps];
        else if (cSceaneryM)
            [self createObjectMaps];
        else if (cGoalM)
            [self createObjectMaps];
        else if (cSoundM)
            [self createObjectMaps];*/
        
    // if (cPolyM)
        [self checkConcavenessOnPolys:includeInBounds];
        [self checkConcavenessOnPolys:selections];
        [self createPolyMap];
        
        NSRect boundingBoxHere = NSUnionRect(oldDrawingBounds, [self drawingBoundsForSelections]);
        
        boundingBoxHere.origin.x -= 6;
        boundingBoxHere.origin.y -= 6;
        boundingBoxHere.size.width += 12;
        boundingBoxHere.size.height += 12;
        
        [self setNeedsDisplayInRect:boundingBoxHere];
        //[self checkObjectsAssociatedWithSelection];
        
        UpdateLevelStatusBar();
    }
}


- (void)moveSelectedBy:(NSPoint)theOffset
{
    //affectedBySelections
    //includeInBounds 
    
    NSPoint newPoint;
    
    newPoint.x = -theOffset.x;
    newPoint.y = -theOffset.y;
    
    [(id)undo moveSelectedBy:newPoint];
    
    if ([selections count] > 0)
    {
        BOOL cPolyM = NO, cMonsterM = NO, cItemM = NO, cPlayerM = NO,
                cSceaneryM = NO, cGoalM = NO, cSoundM = NO;
        id thisObj;
        
        NSMutableSet *pointsAlreadyMoved = [[NSMutableSet alloc] initWithCapacity:36];
        
        //NSRect drawingBounds = NSUnionRect([self drawingBoundsForSelections],
        //                        [self drawingBoundsForObjects:includeInBounds]);
        NSRect oldDrawingBounds = [self drawingBoundsForSelections];
        NSEnumerator *numer = [selections objectEnumerator];
        
        while ((thisObj = [numer nextObject]))
        {
            [thisObj moveBy32Point:theOffset pointsAlreadyMoved:pointsAlreadyMoved];
            
            //case [thisObj isKindOfClass:[LEMapPoint class]]:
            //    break;
            //case [thisObj isKindOfClass:[LELine class]]:
            //    break;
            if ([thisObj isKindOfClass:[LEPolygon class]])
                cPolyM = YES;
            else if ([thisObj isKindOfClass:[LEMapObject class]])
            {
                switch ([(LEMapObject*)thisObj type])
                {
                    case _saved_monster:
                        cMonsterM = YES;
                        break;
                    case _saved_player:
                        cPlayerM = YES;
                        break;
                    case _saved_object:
                        cSceaneryM = YES;
                        break;
                    case _saved_item:
                        cItemM = YES;
                        break;
                    case _saved_goal:
                        cGoalM = YES;
                        break;
                    case _saved_sound_source:
                        cSoundM = YES;
                        break;
                    default:
                        SEND_ERROR_MSG(@"ERROR: unkown object type in selections!");
                        break;
                }
            }
            //else
            //    NSLog(@"Unknown class moved in selections!");
        }
        
        numer = [affectedBySelections objectEnumerator];
        while ((thisObj = [numer nextObject]))
        {
            //   case [thisObj isKindOfClass:[LEMapPoint class]]:
            //       break;
            //   case [thisObj isKindOfClass:[LELine class]]:
            //       break;
            if ([thisObj isKindOfClass:[LEPolygon class]])
                cPolyM = YES;
            else if ([thisObj isKindOfClass:[LEMapObject class]])
            {
                switch ([(LEMapObject*)thisObj type])
                {
                    case _saved_monster:
                        cMonsterM = YES;
                        break;
                    case _saved_player:
                        cPlayerM = YES;
                        break;
                    case _saved_object:
                        cSceaneryM = YES;
                        break;
                    case _saved_item:
                        cItemM = YES;
                        break;
                    case _saved_goal:
                        cGoalM = YES;
                        break;
                    case _saved_sound_source:
                        cSoundM = YES;
                        break;
                    default:
                        SEND_ERROR_MSG(@"ERROR: unkown object type in affectedBySelections!");
                        break;
                }
            }
            //else
            //    NSLog(@"Unknown class moved in affectedBySelections!");
        }
        

        if (cMonsterM)
            [self createObjectMaps];
        else if (cItemM)
            [self createObjectMaps];
        else if (cPlayerM)
            [self createObjectMaps];
        else if (cSceaneryM)
            [self createObjectMaps];
        else if (cGoalM)
            [self createObjectMaps];
        else if (cSoundM)
            [self createObjectMaps];
        
    // if (cPolyM)
        [self checkConcavenessOnPolys:includeInBounds];
        [self checkConcavenessOnPolys:selections];
        [self createPolyMap];
        
        NSRect boundingBoxHere = NSUnionRect(oldDrawingBounds, [self drawingBoundsForSelections]);
        
        boundingBoxHere.origin.x -= 6;
        boundingBoxHere.origin.y -= 6;
        boundingBoxHere.size.width += 12;
        boundingBoxHere.size.height += 12;
        
        [self setNeedsDisplayInRect:boundingBoxHere];
        
        pointsAlreadyMoved = nil;
        
        UpdateLevelStatusBar();
    }
}



- (void)mouseDown:(NSEvent *)theEvent
{
    [self updateModifierKeys:theEvent];

    switch ([self currentDrawingMode])
    {
        case _drawNormaly:
            [self mouseDownNormal:theEvent];
            break;
        case _drawAbnormaly:
            [self mouseDownNormal:theEvent];
            break;
        case _drawCeilingHeight:
        case _drawFloorHeight:
        case _drawLiquids:
        case _drawFloorLights:
        case _drawCeilingLights:
        case _drawLiquidLights:
        case _drawAmbientSounds:
        case _drawLayers:
            [self mouseDownHeightMap:theEvent];
            break;
        default:
            [self mouseDownNormal:theEvent];
            break;
    }
    return;
}

- (void)mouseDownHeightMap:(NSEvent *)theEvent
{
    //int theSelection = [[PhColorListController sharedColorListController] selectionIndex];
    PhColorListControllerDrawer *theColorListController = colorListObject; //[PhColorListController sharedColorListController];
    NSNumber *selectedNumber = [theColorListController getSelectedNumber];
    // Get the mouse point and convert it to this view's cordinate system....
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSArray *thePolys = [currentLevel getThePolys];
    NSEnumerator *numer;
    id curObj;
    BOOL foundSelection = NO;
    LEMapDrawingMode drawMode = [self currentDrawingMode];
    
    LEPaletteTool curTool = [[LEPaletteController sharedPaletteController] getCurrentTool];
    
    if (curTool == LEPaletteToolHand || commandDown)
    {
        [self dragScroll:theEvent];
        return;
    }
    else if (curTool == LEPaletteToolSampler)
        optionDown = YES;
    
    if (selectedNumber == nil && optionDown == NO)
    {
        NSLog(@"There is no number currently selected.");
        return;
    }
    
    //NSLog(@"Runing hit detection on polys...");
    numer = [thePolys reverseObjectEnumerator];
    while (curObj = [numer nextObject])
    {
        //if ([self mouse:mouseLoc inRect:[curObj theDrawingBound]])
        //{
            if ([curObj LEhitTest:mouseLoc])
            {
                //NSLog(@"Hit Test returned YES for a poly!!!");
                
                foundSelection = YES;
                switch (drawMode)
                {
                    case _drawCeilingHeight:
                        if (!optionDown)
                            [curObj setCeilingHeight:[selectedNumber shortValue]];
                        else
                            selectedNumber = [NSNumber numberWithInt:[curObj ceilingHeight]];
                        break;
                    case _drawFloorHeight:
                        if (!optionDown)
                            [curObj setFloorHeight:[selectedNumber shortValue]];
                        else
                            selectedNumber = [NSNumber numberWithInt:[curObj floorHeight]];
                        break;
                    case _drawLiquids:
                        if (!optionDown)
                            [curObj setMediaIndex:[selectedNumber shortValue]];
                        else
                            selectedNumber = [NSNumber numberWithInt:[curObj mediaIndex]];
                        break;
                    case _drawFloorLights:
                        if (!optionDown)
                            [curObj setFloorLightsource:[selectedNumber shortValue]];
                        else
                            selectedNumber = [NSNumber numberWithInt:[curObj floorLightsourceIndex]];
                        break;
                    case _drawCeilingLights:
                        if (!optionDown)
                            [curObj setCeilingLightsource:[selectedNumber shortValue]];
                        else
                            selectedNumber = [NSNumber numberWithInt:[curObj ceilingLightsourceIndex]];
                        break;
                    case _drawLiquidLights:
                        if (!optionDown)
                            [curObj setMediaLightsource:[selectedNumber shortValue]];
                        else
                            selectedNumber = [NSNumber numberWithInt:[curObj mediaLightsourceIndex]];
                        break;
                    case _drawAmbientSounds:
                        if (!optionDown)
                            [curObj setAmbientSound:[selectedNumber shortValue]];
                        else
                            selectedNumber = [NSNumber numberWithInt:[curObj ambientSoundImageIndex]];
                        break;
                    case _drawLayers: //currentLevel
                        if (!optionDown)
                            [curObj setPolyLayer:[[currentLevel layersInLevel] objectAtIndex:[selectedNumber shortValue]]];
                        else
                             selectedNumber = [NSNumber numberWithInteger:[[currentLevel layersInLevel] indexOfObjectIdenticalTo:[curObj polyLayer]]];
                        break;
                    default:
                        NSLog(@"*** Hit detection in 'mouseDownHeightMap' which is the wrong method, %@",
                                @"going to try to fix this by going to 'mouseDownNormal'! ***");
                        [self mouseDownNormal:theEvent];
                        return;
                }
                
                if (selectedNumber == nil && optionDown)
                {
                    NSLog(@"Tried to get number information to set color table with, but selectedNumber was nil?");
                    SEND_ERROR_MSG_TITLE(@"Tried to get number information to set color table with, but selectedNumber was nil?",
                                         @"Color Table Option Feature Error");
                }
                else if (optionDown)
                    [theColorListController setSelectionToNumber:selectedNumber];
                else
                {
                    // Reacaulate the drawing map...
                    drawingHeightMapNeedsUpdating = YES;
                    [self createSpecialDrawingMap];
                    //NSLog(@"setting the needs dsiplay method...");
                    [self setNeedsDisplayInRect:[curObj drawingBounds]];
                    [self displayIfNeeded];
                }
                break;
            }
        //}
    }
}


- (void)mouseDownNormal:(NSEvent *)theEvent
{
    NSEnumerator *numer;
    //ColorRect *oldselectedItem = selectedItem;
    //ColorRect *thisRect;
    NSPoint mouseLoc;
    NSPoint mouseOffset;
    NSEventMask eventMask;
    LEPaletteTool currentTool;
    BOOL dragged = NO;
    BOOL timerOn = NO;
    BOOL onlyScrolling = NO;
    
    BOOL snapToNearestPoint = NO;
    BOOL snapToGrid = NO;
    int  snapToPointLength = 0;
    BOOL snapToLines = NO;
    BOOL snapToAngle = NO;
    NSPoint startPt;
    
    BOOL addtionalSelections = NO;
    BOOL noNeedToEnterDragLoop = NO;
    
    BOOL quitAfterSelectionUndo = NO;
    
    NSPoint pointCache[500];
    int pointCacheMax = 500;
    //int pointCacheCount = 0;
    
    //BOOL foundSelection = NO;
    NSEvent *autoscrollEvent = nil;
    NSMutableArray *theMapPoints, *thePolys, *theLines, *theMapObjects;
    NSRect oldDrawingBounds;
    id curObj;
    //NSMutableString *levelInfoString;
    //Later Stuff...
    NSPoint origPoint, curPoint, lastPoint;
    //_gvFlags.rubberbandIsDeselecting = (([theEvent modifierFlags] & NSAlternateKeyMask) ? YES : NO);
    origPoint = curPoint = lastPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    //NSLog(@"Click Count: %d", [theEvent clickCount]);
    
    NSInteger clickCount = [theEvent clickCount];
    
    // Prepeare The Stuff... :)   Draconic... --:=>
    
    // New stuff, makes it much better in the drag loop...
    // Initally set it to nil...
    startPoint = nil;
    endPoint = nil;
    newLine = nil;
    
    if (![[self window] makeFirstResponder:self]) // Find Out Exzactly What This Does!
    {
        quitAfterSelectionUndo = YES;
        return;
    }
    
    // Record Current Selections
    
    // *selectedLines, *selectedPolys, *selectedPoints, *selectedMapObjects, *selectedNotes;
    // *selections, *affectedBySelections, *includeInBounds;
    
    NSMutableSet *selectedLinesCpy = [selectedLines mutableCopy];
    NSMutableSet *selectedPolysCpy = [selectedPolys mutableCopy];
    NSMutableSet *selectedPointsCpy = [selectedPoints mutableCopy];
    NSMutableSet *selectedMapObjectsCpy = [selectedMapObjects mutableCopy];
    NSMutableSet *selectedNotesCpy = [selectedNotes mutableCopy];
    NSMutableSet *selectionsCpy = [selections mutableCopy];
    NSMutableSet *affectedBySelectionsCpy = [affectedBySelections mutableCopy];
    NSMutableSet *includeInBoundsCpy = [includeInBounds mutableCopy];
    
    // ************************************ May want to make these get the rect caches, and not the layer caches... ************************************
    
    theMapPoints = [currentLevel getThePoints];
    thePolys = [currentLevel getThePolys];
    theLines = [currentLevel getTheLines];
    theMapObjects = [currentLevel theMapObjects];
	
    // Make the current drawing mode nothing...
    currentDrawingMode = LEEDrawNothing;
    
    //Get The Currently Selected Tool on the tool palette utility window...
    currentTool = [[LEPaletteController sharedPaletteController] getCurrentTool];
	
    // Get the mouse point and convert it to this view's cordinate system....
    mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    

    
    
    /*****************************************************************
     *** *** *** END PREPERATIONS, BEGINING DOING STUFF :) *** *** ***
     *****************************************************************/
    
    if (commandDown)
    {
        [self dragScroll:theEvent];
        quitAfterSelectionUndo = YES;
        goto finishUpMouseDownNormal;
    }
    
    if (optionDown)
    {
	// Normally, option temporarily switches to eyedropper tool
	// But when the zoom tool is selected, option switches between zoom out and in
	if(currentTool != LEPaletteToolZoom)
	    currentTool = LEPaletteToolSampler;
    }
	
    //Drawing bounds for any selections
    oldDrawingBounds = [self drawingBoundsForSelections];
	
    // Run the methods that pretain to the currently selected tool...
    switch (currentTool)
    {
        case LEPaletteToolLine:
            // Clear Any Old Selections
            
            //if (!shiftDown)
                [self clearSelections];

	    // Get the *real* line start point, for snap-to-angle
	    startPt = [self useLineToolHypothetically:mouseLoc];

            [self useLineTool:mouseLoc];
            
            addtionalSelections = YES;
            
            break;
       
        case LEPaletteToolPaint:
            // Clear Any Old Selections
            if (!shiftDown)
                [self clearSelections];
            
            if( ! [self usePaintTool:mouseLoc])
            {
		quitAfterSelectionUndo = YES;
                break;
            }
	    // else
            break;
        
        case LEPaletteToolSampler:
            [self clearSelections];
            [self useArrowTool:mouseLoc clickCount:clickCount];
            //Update the selctions set...
            [self updateTheSelections];
            [self useSamplerTool:mouseLoc];
            break;
        
        case LEPaletteToolBrush:
            [self clearSelections];
            [self useArrowTool:mouseLoc clickCount:clickCount];
            //Update the selctions set...
            [self updateTheSelections];
            [self useBrushTool:mouseLoc];
            break;
            
        case LEPaletteToolHand:
            [self dragScroll:theEvent];
            //onlyScrolling = YES;
            quitAfterSelectionUndo = YES;
            break;

	case LEPaletteToolZoom:
	    [self useZoomTool:mouseLoc];
            quitAfterSelectionUndo = YES;
            break;
	
	case LEPaletteToolText:
            [self useTextTool:mouseLoc];
            quitAfterSelectionUndo = YES;
            break;
        
        case LEPaletteToolMonster:
        case LEPaletteToolPlayer:
        case LEPaletteToolItem:
        case LEPaletteToolScenery:
        case LEPaletteToolSound:
        case LEPaletteToolGoal:
            if( ! [self useObjectTool:mouseLoc toolType:currentTool])
            {
                quitAfterSelectionUndo = YES;
                break;
            }
            else
                addtionalSelections = YES;
            break;
        
        case LEPaletteToolArrow:
        default:
            if (!shiftDown)
            {
                NSSet *theOldSelections = [NSSet setWithSet:selections];
                addtionalSelections = [self useArrowTool:mouseLoc clickCount:clickCount];
                [self updateTheSelections];
                if (![selections isEqualToSet:theOldSelections])
                {
                    [selectedLines minusSet:theOldSelections];
                    [selectedPolys minusSet:theOldSelections];
                    [selectedPoints minusSet:theOldSelections];
                    [selectedMapObjects minusSet:theOldSelections];
                }
            }
            else
                addtionalSelections = [self useArrowTool:mouseLoc clickCount:clickCount];
                
            
            break;
    }
    
    shouldNotGetNewObjectsForTiledCache = NO;
    
    // When execution gets here, look to see
    // if any selections need to be recorded for undo...
    finishUpMouseDownNormal:;
    
    
    
    // - (NSSet *)getSelectionsOfType:(int)theSelectionsWanted _COUNT_OF_SELECTION_TYPES
    
    int i = 0;
    
    for (i = 0; i < _COUNT_OF_SELECTION_TYPES; i++)
    {
        NSSet *theOrgSet = [self getSelectionsOfType:i];
        NSMutableSet *theCpySet = nil;
        
        switch (i)
        {
            case _all_selections:           theCpySet = selectionsCpy; break;
            case _point_selections:         theCpySet = selectedPointsCpy; break;
            case _line_selections:          theCpySet = selectedLinesCpy; break;
            case _polygon_selections:       theCpySet = selectedPolysCpy; break;
            case _object_selections:        theCpySet = selectedMapObjectsCpy; break;
            case _note_selections:          theCpySet = selectedNotesCpy; break;
            case _affected_by_selections:   theCpySet = affectedBySelectionsCpy; break;
            case _include_in_bounds:        theCpySet = includeInBoundsCpy; break;
            default:
                SEND_ERROR_MSG(@"Selection Undo In Unknown State... Do Not Use Undo!\n\nDetails: Unknown Selection Type At End Of MoustDownNormal:(NSEvent *)event...");
                continue; // continue for loop...
        }
        
        numer = [theOrgSet objectEnumerator];
        while (curObj = [numer nextObject])
        {
            if ([theCpySet containsObject:curObj])
                // This object's selection status has not changed...
                [theCpySet removeObject:curObj];
            else
                // This object is a new selection...
                [(id)undo undoSelection:curObj ofType:i];
        }
        
        numer = [theCpySet objectEnumerator];
        while (curObj = [numer nextObject])
        {
            // This object is a old deselection...
            [(id)undo undoDeselection:curObj ofType:i];
        }
    }
    
    if (quitAfterSelectionUndo == YES)
        return;
    
    //[winController updateLevelInfoString];
    
    //Update the selctions set...
    [self updateTheSelections];
    
    //Update the screen to reflect any changes, get a fresh screen, etc.
    [self setNeedsDisplayInRect:NSUnionRect(oldDrawingBounds, [self drawingBoundsForSelections])];
    
    [self setNeedsDisplay:YES];
    
    // Send the selection event...
    // May want to send of self and impliment accsessors for the
    // selction sets...
    [self sendSelChangedNotification];
    
    // Get the starting point, in case the mouse is dragged...
    origPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    // Make an event mask that will prevent events that we will not use
    // to not call use, therfore not wasting CPU time...
    eventMask = NSLeftMouseDraggedMask | NSLeftMouseUpMask | NSPeriodicMask;
    
    // Determin if I should snap to nearest point
    if ([selections count] == 1 && ([selectedPoints count] == 1 || [selectedMapObjects count] == 1))
    {
        /*
            PhSnapToGridBool
            
            PhSplitPolygonLines
            PhSplitNonPolygonLines
            
            PhSnapToLines
            
            PhSnapToPoints
            PhSnapToPointsLength
        */
        
        
        // This is not used right at this moment, I temporarly took
        //  the checkbox in the prefs GUI out, I will put it back in when
        //  I get around to making this work:
        //
        //snapToLines = [currentLevel settingAsBool:PhSnapToLines];
        
        snapToNearestPoint = NO;
        snapToGrid = NO;

        // See also below where this check will be repeated, but with shift-key to switch it
        
        if ([selectedPoints count] == 1)
        {
            snapToNearestPoint = [currentLevel settingAsBool:PhSnapToPoints];
            snapToGrid = [currentLevel settingAsBool:PhSnapToGridBool];
        }
        else if ([selectedMapObjects count] == 1)
            snapToGrid = [currentLevel settingAsBool:PhSnapObjectsToGrid]; //PhSnapObjectsToGrid

        snapToPointLength = [currentLevel settingAsInt:PhSnapToPointsLength];
    }

    BOOL controlKeyWasJustDown = NO;
    BOOL shiftWasJustDown = NO;

    BOOL snapToGridOriginally = snapToGrid;
    BOOL snapToNearestPointOriginally = snapToNearestPoint;
    
    BOOL rightAngleSnap = [currentLevel settingAsBool:PhUseRightAngleSnap];
    BOOL isometricSnap = [currentLevel settingAsBool:PhUseIsometricAngleSnap];

    // attn Joshua: preferences code needed here :)
    
    // get the list of angles, for snap-to-angle
    // Code more readable with a autorelease rather then a regular release latter in the code...
    NSMutableArray *snapAzs = [[NSMutableArray alloc] init];
    if(rightAngleSnap == YES &&  isometricSnap == NO /* using right angle snap */)
    {
        [snapAzs addObject:@0];
        [snapAzs addObject:@90];
        [snapAzs addObject:@180];
        [snapAzs addObject:@270];
        [snapAzs addObject:@360];
    }
    else if(rightAngleSnap == NO &&  isometricSnap == YES /* using isometric snap */)
    {
        [snapAzs addObject:@0];
        [snapAzs addObject:@60];
        [snapAzs addObject:@120];
        [snapAzs addObject:@180];
        [snapAzs addObject:@240];
        [snapAzs addObject:@300];
        [snapAzs addObject:@360];
    }
    else if (rightAngleSnap == YES &&  isometricSnap == YES /* both isometic and right angle snap */)
    {
        [snapAzs addObject:@0];
        [snapAzs addObject:@60];
        [snapAzs addObject:@90];
        [snapAzs addObject:@120];
        [snapAzs addObject:@180];
        [snapAzs addObject:@240];
        [snapAzs addObject:@270];
        [snapAzs addObject:@300];
        [snapAzs addObject:@360];
    }
    
    //NSLog(@"mouse down normal 1");
    
    /* *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *
     * The following is the drag loop, program execution stays here while  *
     * 			a drag operation is in progress.		   *
     * *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** */
    while ((theEvent = [[self window] nextEventMatchingMask:eventMask]))
    {
        NSRect visibleRect = [self visibleRect];
        curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        mouseOffset = NSMakePoint(curPoint.x - lastPoint.x, curPoint.y - lastPoint.y);
        
        shouldNotGetNewObjectsForTiledCache = YES;
        
        switch ([theEvent type]) 
        {    
            case NSPeriodic:   //    *** NSPeriodic ***
                shouldNotGetNewObjectsForTiledCache = NO;
                
                if (autoscrollEvent)
                    [self autoscroll:autoscrollEvent];
                
                if (onlyScrolling)
                    [self scrollBy:mouseOffset];
                else
                    [self moveSelectedBy:mouseOffset];
                
                break;
        
            case NSLeftMouseDragged:   //    *** NSLeftMouseDragged ***
                
                // You may want to get rid of this for scrolling in a View Mode
                //    sure as "View Ceiling Height"...


                // jra 7-25-03: POLICY CHANGE! shiftDown, controlDown, etc, will be
                // updated here so that they can be used by tools for various things
                // (ortho (45/90 degree) drawing, swapping snap to grid, etc)

                [self updateModifierKeys:theEvent];
                
                if (addtionalSelections == YES /* && currentTool != LEPaletteToolArrow*/)
                {
                    if (onlyScrolling)
                    {
                        [self scrollBy:mouseOffset];
                        ///NSLog(@"Scroll By: (%g, %g)", mouseOffset.x, mouseOffset.y);
                        break;
                    }
                    
                    dragged = YES;

                    // If the user presses the control key, switch the snap to grid setting.
                    if (controlKeyDown != controlKeyWasJustDown)
                    {
                        if(currentTool != LEPaletteToolLine || !shiftDown)
                        {
                            controlKeyWasJustDown = controlKeyDown;

                            // this check appears above where snapToGrid was initially set
                            // I'll put it here
                            if([selections count] == 1)
                            {
                            snapToGrid = !snapToGrid;
                            }
                        }
                    }

                    // If the user presses the Shift key, and we're a line,
                    // snap motion to angle
                    if (currentTool == LEPaletteToolLine)
                    {
                        if(shiftDown != shiftWasJustDown)
                        {
                            shiftWasJustDown = shiftDown;

                            // We don't want snap mucking with our angles
                            if(shiftDown)
                            {
                                snapToGrid = NO;
                                snapToNearestPoint = NO;

                                snapToAngle = YES;
                            }
                            else
                            {
                                snapToGrid = snapToGridOriginally;
                                snapToNearestPoint = snapToNearestPointOriginally;

                                snapToAngle = NO;
                            }
                        }
                    }

                    
                    if (snapToNearestPoint || snapToGrid)
                    {
                        NSEnumerator *numer;
                        NSArray *mapPointsArray;
                        NSMutableArray *thePointsInRange = [[NSMutableArray alloc] initWithCapacity:0];
                        LEMapPoint *theSelectedP = endPoint; //[selectedPoints anyObject]; // *** MAKE SURE YOU MAKE IT MULTIPOINT FRENDLY!!! ***
                        id curObj;
                        
                        NSRect snapToRect = NSMakeRect(curPoint.x - snapToPointLength,
                                                        curPoint.y - snapToPointLength,
                                                        snapToPointLength*2,
                                                        snapToPointLength*2);
                        
                        int pci = 0;
                        
                        //pointCacheCount = 0;
                        
                        // Prepeare The Stuff... :)   Draconic... --:=>
                        
                        if (snapToNearestPoint && currentTool == LEPaletteToolLine)
                        {
                                // Only need to check current layer points...
                            mapPointsArray = [currentLevel layerPoints];
                            
                                // Determin if there are any close points,,,
                            numer = [mapPointsArray reverseObjectEnumerator];
                            while (curObj = [numer nextObject])
                            {
                                
                                if ([self mouse:[curObj as32Point] inRect:snapToRect]
                                    && curObj != theSelectedP)
                                {
                                    if (pointCacheMax > pci)
                                    {
                                        pointCache[pci] = NSMakePoint([curObj x32], [curObj y32]);
                                        pci++;
                                        //[thePointsInRange addObject:curObj];
                                    }
                                    else
                                        break;
                                }
                            }
                        }
                        
                        if (snapToGrid)
                        {
                            // Determine if gird snap is needed...
                            int gridCordY;
                            int gridCordX;
                            float gridFactor = [currentLevel settingAsFloat:PhGridFactor]; // Used to be one...
                            int numberOfGridLines = (int)((float)64 * gridFactor);
                            int minXCord = curPoint.x - snapToPointLength;
                            int maxXCord = curPoint.x + snapToPointLength;
                            int maxYCord = curPoint.y + snapToPointLength;
                            int minYCord = curPoint.y - snapToPointLength;
                            
                            for  (gridCordY = minYCord; gridCordY <= maxYCord ; gridCordY++)
                            {
                                if (gridCordY % numberOfGridLines == 0)
                                {
                                    for  (gridCordX = minXCord; gridCordX <= maxXCord; gridCordX++)
                                    {
                                        if (gridCordX % numberOfGridLines == 0)
                                        {
                                            if (pointCacheMax > pci)
                                            {
                                                //NSLog(@"Grid Pint Found On: (%d, %d)", gridCordX, gridCordY);
                                                pointCache[pci] = NSMakePoint(gridCordX, gridCordY);
                                                pci++;
                                            }
                                            else
                                                break;
                                        }
                                    }
                                }
                            }
                        }
    
                        
                        
                        if (pci == 0) // No points in range...
                            [self moveSelectedTo:curPoint];
                        else if (pci == 1) // Only one point in range...
                        {
                            //[theSelectedP setY32:[thePointInRange y32]];
                            //[theSelectedP setX32:[thePointInRange x32]];
                            [self moveSelectedTo:(pointCache[0])];
                            
                            [self checkObjectsAssociatedWithSelection];                    
                        }
                        else // More then one point in range...
                        {
                            int shortestDistance = 50000;
                            int i;
                            NSPoint shortestDistanceNSPoint = pointCache[0];
                            
                            //LEMapPoint *shortestDistancePoint = nil;
                            //numer = [thePointsInRange reverseObjectEnumerator];
                            //while (curObj = [numer nextObject])
                            
                            int mX = curPoint.x;
                            int mY = curPoint.y;
                            
                            for (i = 0; i < pci; i++)
                            {
                                int cX = pointCache[i].x;
                                int cY = pointCache[i].y;
                                
                                int dX = mX - cX;
                                int dY = mY - cY;
                                
                                int theDist = sqrt((dY * dY) + (dX * dX));
                                
                                if (theDist < shortestDistance)
                                {
                                        shortestDistance = theDist;
                                        //shortestDistancePoint = curObj;
                                        
                                        shortestDistanceNSPoint = pointCache[i];
                                }
                            }
                            
                            //if (shortestDistancePoint != nil)
                                [self moveSelectedTo:shortestDistanceNSPoint];
                        }
                    } // END if (snapToNearestPoint || snapToGrid)

		    // Snap-to-angle?
                    else if(snapToAngle && currentTool == LEPaletteToolLine)
                    {
                        // assumptions this code makes:
                        //  -this is the line tool
                        //  -it has exactly one selected point
                        //  -this point appears conveniently in selectedPoints
                        //  -this point has exactly one line attached to it, the line in question
                        //  -the line calculates its azimuth like a vector FROM the start point TO the
                        //   one that moves around (the one in selectedPoints)
			
                        short tgtLength;
                        short curAz;
                        short tgtAz;
                        short tX, tY;
                        LELine *theLine;
                        LEMapPoint *thePt;
			NSEnumerator *numer;
			NSNumber *cur;
			short bestAz = 0;
			short bestDiff;

			// move the point to where it WOULD be
                        // so as to force the line to recompute where it WOULD be
                        // so as to get the length & azimuth it WOULD have
                        [self moveSelectedTo:curPoint];

                        // get the currently drawing line
                        thePt = endPoint; //[selectedPoints anyObject]; // <-- ONLY usable if there's ONE item
                        theLine = newLine; //[[thePt linesAttachedToMeAsArray] objectAtIndex:0];

                        // get its azimuth
                        curAz = [theLine azimuth];

                        // and length
                        tgtLength = [theLine length];
                        
                        // compare it to the list of angles
			bestDiff = 1000;	// to trigger the first time
			numer = [snapAzs objectEnumerator];

			while(cur = [numer nextObject])
			{   
			    if(abs([cur shortValue] - curAz) < bestDiff)
			    {
				bestAz = [cur shortValue];
				bestDiff = abs(bestAz - curAz);
			    }
			}

			tgtAz = bestAz;

                        // force it to that angle @ its current length
                        
                        tX = (int)(PhSin(tgtAz) * (double)tgtLength + 0.8); // 0.8 to counteract integer truncation
                        tY = (int)(PhCos(tgtAz) * (double)tgtLength + 0.8); // otherwise the values are too small

                        //NSLog(@"tgt length = %d", tgtLength);
                        //NSLog(@"complength = %d", (int)sqrt((tX*tX)+(tY*tY)));

                        [self moveSelectedTo:NSMakePoint(startPt.x+tX, startPt.y-tY)];

                    } // END if (snapToAngle)
                    else
					{
						//if ([count selectedPoints] != [count selections])
							[self moveSelectedBy:mouseOffset];
						//else
						//	[self moveSelectedTo:NSMakePoint(startPt.x+tX, startPt.y-tY)];
					}
					
                    if (![self mouse:curPoint inRect:visibleRect])
                    {
                        if (NO == timerOn)
                        {
                            [NSEvent startPeriodicEventsAfterDelay:0.1 withPeriod:0.1];
                            timerOn = YES;
                            autoscrollEvent = theEvent;
                        }
                        else
                        {
                            autoscrollEvent = theEvent;
                        }
                        break;
                    }
                    else if (YES == timerOn)
                    {
                        [NSEvent stopPeriodicEvents];
                        timerOn = NO;
                        autoscrollEvent = nil;
                    }
                }
                
                if (!addtionalSelections && currentTool == LEPaletteToolArrow)
                { // Bounding-Box Drag Selecting....
                    NSRect tmpRect = LERectFromPoints(mouseLoc, curPoint);
                    drawBoundingBox = YES;
                    boundingBox = NSUnionRect(tmpRect, boundingBox);
                    
                    boundingBox.origin.x -= 6;
                    boundingBox.origin.y -= 6;
                    boundingBox.size.width += 12;
                    boundingBox.size.height += 12;
                    
                    [self setNeedsDisplayInRect:boundingBox];
                    
                    boundingBox = tmpRect;
                    
                    // drawingWithinRect
                    
                    // Select Objects Within Bounding Box...
                    
                    [self selectWithinRect:boundingBox registerUndos:YES];
                    //[self setNeedsDisplayInRect:[self drawingBoundsForSelections]]; // drawingBoundsForObjects
                }
                
                [self displayIfNeeded];
                
                break;
        
            case NSLeftMouseUp:   //    *** NSLeftMouseUp ***
                
                boundingBox.origin.x -= 6;
                boundingBox.origin.y -= 6;
                boundingBox.size.width += 12;
                boundingBox.size.height += 12;
                    
                [self setNeedsDisplayInRect:boundingBox];
                
                drawBoundingBox = NO;
                boundingBox = NSZeroRect;
                
                if (YES == timerOn)
                {
                    [NSEvent stopPeriodicEvents];
                    timerOn = NO;
                    autoscrollEvent = nil;
                }
                
                shouldNotGetNewObjectsForTiledCache = NO;
                
                if (onlyScrolling)
                {
                    //[self scrollBy:mouseOffset];
                    return;
                }
                
                    // A line has possible been in the proccess of being maped out...
                if (currentDrawingMode == LEEDrawLineConnected ||
                    currentDrawingMode == LEEDrawLineNotConnected) // != LEEDrawNothing
                {
                    NSLog(@"Doing Line Stuff...");
                    //int c = [theMapPoints count];
                    BOOL firstOne = YES;
                    LEMapPoint *theSelectedP = endPoint;//[selectedPoints anyObject]; // *** MAKE SURE YOU MAKE IT MULTIPOINT FRENDLY!!! ***
                    NSPoint locationOfSelectedPoint = [theSelectedP as32Point];
                    NSPoint loc1 = [endPoint as32Point];
                    NSPoint loc2 = [startPoint as32Point];
                    
                    if (loc1.x == loc2.x && loc1.y == loc2.y)
                    {
                        
                        [self clearSelections];
                        [currentLevel deletePoint:endPoint];
                        [currentLevel deleteLine:newLine];
                        // Just in case...
                        endPoint = nil;
                        newLine = nil;
                        [self clearRectCache];
                        [selectedPoints addObject:startPoint];
                        [(id)undo undoSelection:startPoint ofType:_point_selections];
                        [(id)undo undoSelection:startPoint ofType:_all_selections];
                        [self updateTheSelections];
                    }
                    else
                    {
                        switch (currentDrawingMode)
                        {
                            case LEEDrawLineConnected:
                            case LEEDrawLineNotConnected:
                                // This can modify the orginal array we are going though, so need to enumerate a copy...
                                numer = [[[theMapPoints reverseObjectEnumerator] allObjects] objectEnumerator];
                                while (curObj = [numer nextObject])
                                {
                                    if (curObj == endPoint)
                                        continue;
                                    
                                    // Rect Cache Lists
                                    //NSMutableSet *rectPolys, *rectLines, *rectPoints, *rectObjects, *rectNotes;
                                    
                                    // Special Pointers for line tool...
                                    //LEMapPoint *startPoint, endPoint;
                                    //LELine *newLine;
                                    
                                    if (([self mouse:locationOfSelectedPoint inRect:[curObj as32Rect]]) /*&& (!firstOne)*/)
                                    {
                                        // This counts on the fact that new objects
                                        // are usally added to the end of the array.
                                        // I should not make that assumption, and should fix this...
                                        [newLine setMapPoint2:curObj];
                                        [self clearSelections];
                                        [currentLevel deletePoint:endPoint];
                                        // Found new end point for the line...
                                        endPoint = curObj;
                                        // Should just use a [self selectObject:] for this :)
                                        // number will not be used anymore...
                                        numer = [[endPoint getLinesAttachedToMe] objectEnumerator];
                                        while (curObj = [numer nextObject])
                                        {
                                            if (curObj == newLine)
                                                continue;
                                            
                                            if ([curObj uses:startPoint])
                                            { // Two lines connecting the same points...
                                                [currentLevel deleteLine:newLine];
                                                break;
                                            }
                                        }
                                        
                                        [selectedPoints addObject:endPoint];
                                        [self updateTheSelections];
                                        
                                        [(id)undo undoSelection:endPoint ofType:_point_selections];
                                        [(id)undo undoSelection:endPoint ofType:_all_selections];
                                        
                                        // To make sure rect cache does not have
                                        // any objects that are no longer in the level...
                                        [self clearRectCache];
                                        
                                        break; // break out of while (curObj = [numer nextObject])
                                    }
                                    //else { firstOne = NO; }
                                } // End while (curObj = [numer nextObject])
                                break; // break out of case LEEDrawLineNotConnected:
                            default:
                                break;
                        } // End switch (currentDrawingMode) 
                    }    
                } // End if (currentDrawingMode != LEEDrawNothing)
                
                // Test each polygon for concavness...
                //NOTE: I Will eventually have a list of polygons
                //effected by the drag operation so that I don't
                //have to test all the polygons, but just the ones
                //effected by the drag...
                //if (currentTool == LEPaletteArrowTool)
                //    [self performSelector:@selector(isPolygonConcave) withEachObjectInArray:thePolys];
                
                //[self createPolyMap];
                //[self createObjectMaps];
                
                //[self setNeedsDisplay:YES];
                
                [self checkSelectedObjects];
                
                // ***************** This is for PhAnnotationNotes ******************
                
                [self checkSelectedNotes];
                
                UpdateLevelStatusBar();
                
                return;
        
            default:
                return;
        } // END switch ([theEvent type])
        
        lastPoint = curPoint;
        
    } // END while (theEvent = [[self window] nextEventMatchingMask:eventMask])
}

- (void)dragScroll:(NSEvent *)theEvent
{
    BOOL keepOn = YES;
    NSPoint start = [theEvent locationInWindow];//[self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSPoint before = NSZeroPoint;
    NSRect origVisibleRect = [self visibleRect];
    while (keepOn)
    {
        theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        switch ([theEvent type])
        {
            case NSLeftMouseDragged:
                {
                    NSPoint now = [theEvent locationInWindow];//[self convertPoint:[theEvent locationInWindow] fromView:nil];
                    if (! NSEqualPoints(now, before))
                    {
                        NSSize delta;
                        NSRect curVisibleRect;
                        delta.width = start.x - now.x;
                        delta.height = now.y - start.y;
                        
                        
                        curVisibleRect = origVisibleRect;
                        NSPoint tmp = curVisibleRect.origin;
                        NSPoint org = tmp;//[self convertPoint:tmp fromView:nil];
                        
                        org.x += delta.width;
                        //org.y += before.y - start.y;
                        org.y += delta.height;
                        //[self scrollBy:curVisibleRect.origin];
                        //[self scrollRectToVisible:curVisibleRect];
                        [self scrollPoint:org];
                        [self display];
                        /*
                        org.y += delta.height;
                        [self scrollPoint:org];
                        [self display];*/
                        
                        before = now;
                    }
                    break;
                }
            case NSLeftMouseUp:
            default:
                keepOn = NO;
                break;
        }
    }
	//[self setNeedsDisplay:YES];
}

- (void)mouseScrollingStaringAt:(NSPoint)mouseLoc
{
    NSRect visibleRect = NSMakeRect(0, 0, 0, 0);
    NSPoint curPoint = mouseLoc;
    NSPoint mouseOffset = NSMakePoint(0, 0);
    NSPoint lastPoint = mouseLoc;
    NSEvent *theEvent = nil;
    BOOL timerOn = NO;
    NSEventMask eventMask = NSEventMaskLeftMouseDragged | NSEventMaskLeftMouseUp | NSEventMaskPeriodic;
    NSEvent *autoscrollEvent = nil;
    
    // rect.origin.(x/y)
    
    // * *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ****
    // * The following is the drag loop, program execution stays here while  	*
    // * 		a drag operation for scrolling is in progress.		*
    // * *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ****
    while ((theEvent = [[self window] nextEventMatchingMask:eventMask]))
    {
        visibleRect = [self visibleRect];
        curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        mouseOffset = NSMakePoint((lastPoint.x - curPoint.x), (lastPoint.y - curPoint.y));
        lastPoint = curPoint;
        
        shouldNotGetNewObjectsForTiledCache = NO;
        
        switch ([theEvent type]) 
        {    
            case NSPeriodic:   //    *** NSPeriodic ***
                shouldNotGetNewObjectsForTiledCache = NO;
                if (autoscrollEvent) [self autoscroll:autoscrollEvent];
                [self scrollBy:mouseOffset];
                break;
        
            case NSLeftMouseDragged:   //    *** NSLeftMouseDragged ***
                [self scrollBy:mouseOffset];
        
                if (![self mouse:curPoint inRect:visibleRect])
                {
                    if (NO == timerOn)
                    {
                        [NSEvent startPeriodicEventsAfterDelay:0.1 withPeriod:0.1];
                        timerOn = YES;
                        autoscrollEvent = theEvent;
                    }
                    else
                    {
                        autoscrollEvent = theEvent;
                    }
                    break;
                }
                else if (YES == timerOn)
                {
                    [NSEvent stopPeriodicEvents];
                    timerOn = NO;
                    autoscrollEvent = nil;
                }
        
                [self displayIfNeeded];
                break;
        
            case NSLeftMouseUp:   //    *** NSLeftMouseUp ***
                
                shouldNotGetNewObjectsForTiledCache = NO;
                
                if (YES == timerOn)
                {
                    [NSEvent stopPeriodicEvents];
                    timerOn = NO;
                    autoscrollEvent = nil;
                }
                return;
        
            default:
                break;
        } // END switch ([theEvent type])
        
    } // END while (theEvent = [[self window] nextEventMatchingMask:eventMask])
}

// *************************** Tool Methods ***************************
#pragma mark -
#pragma mark ********* Tool Methods *********

- (BOOL)useSamplerTool:(NSPoint)mouseLoc
{
    // Ignoring the mouseLoc for right now, will use that soon though...
    
    id thisObj;
    NSEnumerator *numer = [selections objectEnumerator];
    
    while ((thisObj = [numer nextObject]))
    {
        [currentLevel makeDefault:thisObj];
    }
    
    return YES;
}

- (BOOL)useBrushTool:(NSPoint)mouseLoc
{
    // Ignoring the mouseLoc for right now, will use that soon though...
    
    id thisObj;
    NSEnumerator *numer = [selections objectEnumerator];
    
    while ((thisObj = [numer nextObject]))
    {
        [currentLevel setToDefaultState:thisObj];
    }
    
    return YES;
}

-(BOOL)useArrowTool:(NSPoint)mouseLoc clickCount:(NSInteger)count
{
    NSEnumerator *numer;
    BOOL foundSelection = NO;
    NSSet *theMapPoints, *thePolys, *theLines, *theMapObjects;
    NSSet *theNotes = nil;
    id curObj;
    BOOL pointInsideAlreadySelectedObject = NO;

    // Prepeare The Stuff... :)   Draconic... --:=>
    
    theMapPoints = rectPoints; // [currentLevel layerPoints]; // rectPoints
    thePolys = rectPolys; //[currentLevel layerPolys];
    theLines = rectLines; //[currentLevel layerLines];
    theMapObjects = rectObjects; //[currentLevel layerMapObjects];
    
    // Will probably want to filter this out in the future...
    theNotes = rectNotes;//[currentLevel getNotes];
    
    if ([self isPointInSelection:mouseLoc])
        pointInsideAlreadySelectedObject = YES;
    
    // Clear Any Old Selections
    if (!pointInsideAlreadySelectedObject && !shiftDown)
        [self clearSelections];
    
    // selectedNotes LEhitTest
    
    if (boolArrayOptions[_mapoptions_select_notes] == YES)
    {
        //NSLog(@"Runing hit detection on notes...");
        numer = [theNotes objectEnumerator];
        while (curObj = [numer nextObject])
        {
            //if ([self mouse:mouseLoc inRect:[curObj theDrawingBound]])
            //{
                if ([curObj LEhitTest:mouseLoc])
                {
                    BOOL objInSelections = [self isObjectInSelections:curObj];
                    
                    NSLog(@"Found a note: %@", [curObj text]);
                    
                    if (!shiftDown && !objInSelections)
                    {
                        [self clearSelections];
                    }
                    else if (shiftDown && objInSelections)
                    {
                        [self deselectObject:curObj];
                        return YES;
                    }
                    
                    //NSLog(@"Hit Test returned YES for a line!!!");
                    [selectedNotes addObject:curObj];
                    
                    if (count == 2)
                    { // Double Click... Need to open the editor sheet...
                        [winController openAnnotationNoteEditor:curObj];
                    }
                    
                    //foundSelection = YES;
                    //Find objects that would be affected by moving
                    //this point around...
                    //[currentLevel findObjectsAssociatedWith:curObj putIn:includeInBounds];
                    //NSLog(@"RETURN YES, 3!!!");
                    return YES;
                }
            //}
        }
    }
    
    if (boolArrayOptions[_mapoptions_select_points] == YES)
    {	//NSLog(@"Looking For Points...");
        numer = [theMapPoints objectEnumerator];
        while (curObj = [numer nextObject])
        {
            if ([self mouse:mouseLoc inRect:[curObj as32Rect]])
            {
                BOOL objInSelections = [self isObjectInSelections:curObj];
                
                if (!shiftDown && !objInSelections)
                {//NSLog(@"!shiftDown && !objInSelections, Clearing Selections...");
                    [self clearSelections];
                }
                else if (shiftDown && objInSelections)
                {//NSLog(@"shiftDown && objInSelections, Clearing Selections...");
                    [self deselectObject:curObj];
                    return YES;
                }
                
                //NSLog(@"Selecting A Point...");
                
                [selectedPoints addObject:curObj];
                
                //foundSelection = YES;
                //Find objects that would be affected by moving
                //this point around...
                [currentLevel findObjectsAssociatedWith:curObj putIn:includeInBounds];
                //NSLog(@"RETURN YES, 1!!!");
                return YES;
            }
        }
    }
    if (/*!foundSelection && */boolArrayOptions[_mapoptions_select_objects] == YES)
    {
        //NSLog(@"Runing hit detection on level objects...");
        numer = [theMapObjects objectEnumerator];
        while (curObj = [numer nextObject])
        {
            if ([self mouse:mouseLoc inRect:[curObj as32Rect]])
            {
                BOOL objInSelections = [self isObjectInSelections:curObj];
                
                if (!shiftDown && !objInSelections)
                {
                    [self clearSelections];
                }
                else if (shiftDown && objInSelections)
                {
                    [self deselectObject:curObj];
                    return YES;
                }
                
                [selectedMapObjects addObject:curObj];
                //foundSelection = YES;
                //Find objects that would be affected by moving
                //this point around...
                [currentLevel findObjectsAssociatedWith:curObj putIn:includeInBounds];
                //NSLog(@"RETURN YES, 2!!!");
                return YES;
            }
        }
    }
    if (/*!foundSelection && */boolArrayOptions[_mapoptions_select_lines] == YES)
    {
        //NSLog(@"Runing hit detection on lines...");
        numer = [theLines objectEnumerator];
        while (curObj = [numer nextObject])
        {
            //if ([self mouse:mouseLoc inRect:[curObj theDrawingBound]])
            //{
                if ([curObj LEhitTest:mouseLoc])
                {
                    BOOL objInSelections = [self isObjectInSelections:curObj];
                    
                    if (!shiftDown && !objInSelections)
                    {
                        [self clearSelections];
                    }
                    else if (shiftDown && objInSelections)
                    {
                        [self deselectObject:curObj];
                        return YES;
                    }
                    
                    //NSLog(@"Hit Test returned YES for a line!!!");
                    [selectedLines addObject:curObj];
                    //foundSelection = YES;
                    //Find objects that would be affected by moving
                    //this point around...
                    [currentLevel findObjectsAssociatedWith:curObj putIn:includeInBounds];
                    //NSLog(@"RETURN YES, 3!!!");
                    return YES;
                }
            //}
        }
    }
    if (/*!foundSelection && */boolArrayOptions[_mapoptions_select_polygons] == YES)
    {
        //NSLog(@"Runing hit detection on polys...");
        numer = [thePolys objectEnumerator];
        while (curObj = [numer nextObject])
        {
            //if ([self mouse:mouseLoc inRect:[curObj theDrawingBound]])
            //{
                if ([curObj LEhitTest:mouseLoc])
                {
                    BOOL objInSelections = [self isObjectInSelections:curObj];
                    
                    if (!shiftDown && !objInSelections)
                    {
                        [self clearSelections];
                    }
                    else if (shiftDown && objInSelections)
                    {
                        [self deselectObject:curObj];
                        return YES;
                    }
                
                    //NSLog(@"Hit Test returned YES for a polygon!!!");
                    [selectedPolys addObject:curObj];
                    //foundSelection = YES;
                    //Find objects that would be affected by moving
                    //this point around...
                    [currentLevel findObjectsAssociatedWith:curObj putIn:includeInBounds];
                    //NSLog(@"RETURN YES, 4!!!");
                    return YES;
                }
            //}
        }
    }
    //NSLog(@"RETURN NO, NO SELECTIONS!!!");
    return NO;
}

- (BOOL)usePaintTool:(NSPoint)mouseLoc
{
    NSEnumerator *numer;
    BOOL keepPolyFinding = YES, foundTheLine = NO;
    //BOOL foundSelection = NO
    BOOL keepFollowingTheLines = YES;
    BOOL lastLineToTest = NO;
    NSInteger indexOfLineFound;
    //int dis1, dis2;
    NSMutableArray *theMapPoints, *theLines, *theNewPolyLines, *theNewPolyVectors;
    //NSMutableArray *theMapObjects, *thePolys;
    LEMapPoint *currentLineMainPoint, *currentLineSecondaryPoint;
    //LEMapPoint *curPoint;
    LELine *thisMapLine, *currentLine = nil, *previousLine;
    NSPoint theCurPoint = mouseLoc;
    NSPoint point1, point2;
    NSSet *theConnectedLines;
    LEPolygon *theNewPolygon;
    NSSet *thePossibleLeftMostLines = [self listOfLinesWithin:NSMakeRect(-2048, theCurPoint.y-1, (theCurPoint.x + 2048), 2)];
    
    //NSLog(@"Runing hit detection on polys...");
    numer = [[currentLevel layerPolys] reverseObjectEnumerator];
    for (LEMapStuffParent *curObj in numer)
    {
        //if ([self mouse:mouseLoc inRect:[curObj theDrawingBound]])
        //{
            if ([curObj LEhitTest:mouseLoc])
            {
                SEND_ERROR_MSG_TITLE(@"Already a polygon there (if this is wrong, sorry, will be more acurate in future)...",
                                     @"Polygon Filling Error");
                return NO;
            }
        //}
    }

    // Prepeare The Stuff... :)   Draconic... --:=>
    
    theMapPoints = [currentLevel getThePoints];
    theLines = [currentLevel getTheLines];
    
    theNewPolyLines = [NSMutableArray arrayWithCapacity:8];
    theNewPolyVectors = [NSMutableArray arrayWithCapacity:8];
    
    NSLog(@"Got Thought With Preperations...");
    
    // Find the line closest to the left of the point...
    while (keepPolyFinding)
    {
        if (theCurPoint.x < -2047)
        {
            keepPolyFinding = NO;
            foundTheLine = NO;
            indexOfLineFound = -1;
            SEND_ERROR_MSG(@"Did not find a leftmost line.");
            return NO;
        }
        numer = [thePossibleLeftMostLines objectEnumerator];
        while (thisMapLine = [numer nextObject])
        {
            //NSLog(@"1");
            if ([thisMapLine clockwisePolygonOwner] == -1 || [thisMapLine conterclockwisePolygonOwner] == -1)
            {
                //NSLog(@"2");
                if ([thisMapLine LEhitTest:theCurPoint])
                {
                    //NSLog(@"3");
                    keepPolyFinding = NO;
                    foundTheLine = YES;
                    indexOfLineFound = [theLines indexOfObjectIdenticalTo:thisMapLine];
                    currentLine = thisMapLine;
                    break;
                }
            }
        } 
        theCurPoint.x -= 1;
        //NSLog(@"next y-2 point: ( %f, %f)", theCurPoint.x, theCurPoint.y); 
    } // END while (keepPolyFinding)
     //NSLog(@"Got Thought With Line Finding...");
    // If the line was not found, return NO...
    if (!foundTheLine && currentLine == nil)
    {
        SEND_ERROR_MSG(@"Could not fill polygon, could not find the leftmost line.");
        return NO;
    }
    NSLog(@"Found the line index: %lu", (unsigned long)[theLines indexOfObjectIdenticalTo:currentLine]);
    // If line was found, follow it around, always choosing
    // the inner most line, to see if it completes a polygon...
    
    //get The line disteance in world_units/32 from upper left corner of grid
    
    point1 = [[currentLine mapPoint1] asPoint];
    point2 = [[currentLine mapPoint2] asPoint];
    
    if (point1.y < point2.y)
    {
        currentLineMainPoint = [currentLine mapPoint1];
        currentLineSecondaryPoint = [currentLine mapPoint2];
    }
    else if (point1.y > point2.y)
    {
        currentLineMainPoint = [currentLine mapPoint2];
        currentLineSecondaryPoint = [currentLine mapPoint1];
    }
    else
    {
        if (point1.x > point2.x)
        {
            currentLineMainPoint = [currentLine mapPoint2];
            currentLineSecondaryPoint = [currentLine mapPoint1];
        }
        else
        {
            currentLineMainPoint = [currentLine mapPoint1];
            currentLineSecondaryPoint = [currentLine mapPoint2];
        }
    }
    
    //NSLog(@"currentLineMainPoint index: %d", [theMapPoints indexOfObjectIdenticalTo:currentLineMainPoint]);
    //NSLog(@"currentLineSecondaryPoint index: %d", [theMapPoints 
    //    indexOfObjectIdenticalTo:currentLineSecondaryPoint]);
    
    
    [theNewPolyVectors addObject:currentLineSecondaryPoint];
    [theNewPolyVectors addObject:currentLineMainPoint];
    [theNewPolyLines addObject:currentLine];
    
    
    //found the point to start...
    //if (theConnectedLines != nil)
    //    [theConnectedLines release];
    //NSLog(@"Pass theConnectedLines release");
    
    while (keepFollowingTheLines)
    {
        LELine *smallestLine;
        LEMapPoint *nextMainPoint;
        NSInteger smallestLineIndex = -1, nextMainPointIndex = -1;
        double smallestAngle = 181.0;
        
        smallestLine = nil;
        nextMainPoint = nil;
        
        theConnectedLines = [currentLineMainPoint getLinesAttachedToMe];
        
        if ([theConnectedLines count] < 2)
        {
            SEND_ERROR_MSG(@"When I was following the line around (clockwise) I found a line with no other line connecting from it (dead end).");
            return NO;
        }
        else
        {
            //NSLog(@"Found connected lines, processesing them now...");
            
            [[NSColor redColor] set];
            previousLine = nil; // Just to make sure...
            numer = [theConnectedLines objectEnumerator];
            while (thisMapLine = [numer nextObject])
            { 
                LEMapPoint *theCurPoint1 = [thisMapLine mapPoint1];
                LEMapPoint *theCurPoint2 = [thisMapLine mapPoint2];
                LEMapPoint *theCurPoint;
                if (theCurPoint1 == currentLineMainPoint)
                {
                    theCurPoint = theCurPoint2;
                }
                else
                {
                    theCurPoint = theCurPoint1;
                }
                
                //NSLog(@"Analyzing line: %d", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                
                if ([thisMapLine clockwisePolygonOwner] != -1 && [thisMapLine conterclockwisePolygonOwner] != -1)
                {
                    // Might want to make sure of this in finnal lines instead, etc.???
                    //NSLog(@"Line# %d already has two polygons attached to it, can't make a third polygon from it.", [thisMapLine index]);
                    //return NO;
                    continue;
                }
                
                if (thisMapLine != currentLine)
                {
                    if (theCurPoint != nil)
                    {
                        double previousX, previousY, thisX, thisY;
                        double prevX, prevY, theX, theY;
                        double prevLength, theLength;
                        double theta, alpha, thetaRad, tango;
                        double xrot, yrot;
                        double slope, theXfromSlop;
                        short newX, newY, newPrevX, newPrevY;
                        BOOL slopeChecksOut = NO;
        
						previousX = [currentLineSecondaryPoint x] - [currentLineMainPoint x];
						previousY = [currentLineSecondaryPoint y] - [currentLineMainPoint y];
						thisX = [theCurPoint x] - [currentLineMainPoint x];
						thisY = [theCurPoint y] - [currentLineMainPoint y];
                        prevX = previousX;
                        prevY = previousY;
                        theX = thisX;
                        theY = thisY;
                        //NSLog(@"previousY: %g previousX: %g", previousY, previousX);
                        slope = previousY / previousX;
                        //NSLog(@"slope: %g theY: %g", slope, theY);
                        theXfromSlop = theY / slope;
                        //NSLog(@"theXfromSlop: %g", theXfromSlop);
                        
                        prevLength = sqrt( previousX * previousX + previousY * previousY );
                        previousX /= prevLength;
                        previousY /= prevLength;
        
                        theLength = sqrt( thisX * thisX + thisY * thisY );
                        thisX /= theLength;
                        thisY /= theLength;
        
                        theta = (double)previousX * (double)thisX + (double)previousY * (double)thisY;
                        //NSLog(@"Angleized Line Index: %d  theta: %g", [theLines indexOfObjectIdenticalTo:thisMapLine], theta);
                        alpha = theta;
                        tango = theta;
                        theta = acos(theta);
                        thetaRad = theta;
                        theta = theta * 180.0 / M_PI;
                        alpha = asin(alpha);
                        alpha = alpha * 180.0 / M_PI;
                        tango = atan(tango);
                        tango = tango * 180.0 / M_PI;
                        //NSLog(@"Angleized Line Index: %d  Alpha: %g Tango: %g", [theLines indexOfObjectIdenticalTo:thisMapLine], alpha, tango);
                        xrot = theX * cos(thetaRad) - theY * sin(thetaRad);
                        yrot = theX * sin(thetaRad) + theY * cos(thetaRad);
                    // NSLog(@"Angleized Line Index: %d  with BEFORE rot ( %f, %f)", [theLines indexOfObjectIdenticalTo:thisMapLine], xrot, yrot);
        
                        newX = (short) xrot;
                        newY = (short) yrot;
                        newPrevX = (short)prevX;
                        newPrevY = (short)prevY;
                        xrot = (double)newX / theLength;
                        yrot = (double)newY / theLength;
                        //NSLog(@"Angleized Line Index: %d  With Angle Of: %g with rot ( %f, %f)",
                        //    [theLines indexOfObjectIdenticalTo:thisMapLine], theta, xrot, yrot);
                        
                        
                        if (theta != 180.0)
                        {
                                //NSLog(@"For Line %d  theX: %g theY: %g", [theLines indexOfObjectIdenticalTo:thisMapLine], theX, theY);
                                if (0 < prevY) // Main Point Lower
                                {
                                    if (theX >= theXfromSlop) //ok
                                    {
                                        //NSLog(@"For Line %d  (1) ", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                                        slopeChecksOut = YES;
                                    }
                                }
                                else if (0 > prevY) // Main Point Higher
                                {
                                    if (theX <= theXfromSlop) //ok
                                    {
                                        //NSLog(@"For Line %d  (2) ", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                                        slopeChecksOut = YES;
                                    }
                                }
                                else // equals
                                {
                                    if (0 > prevX) // Main Point Higher
                                    {
                                        if (theY >= prevY) //ok
                                        {
                                            //NSLog(@"For Line %d  (3) ", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                                            slopeChecksOut = YES;
                                        }
                                    }
                                    else if (prevX > 0) // Main Point Higher
                                    {
                                        if (theY <= prevY) //ok
                                        {
                                            //NSLog(@"For Line %d  (4) ", [theLines indexOfObjectIdenticalTo:thisMapLine]);
                                            slopeChecksOut = YES;
                                        }
                                    }
                                }
                        }
                        else if (theta == 180.0)
                        {
                            slopeChecksOut = YES;
                        }
                        
                        
                        if ( theta <= 180.0 && theta < smallestAngle && slopeChecksOut)
                        {
                                smallestLine = thisMapLine;
                                smallestLineIndex = [theLines indexOfObjectIdenticalTo:thisMapLine];
                                smallestAngle = theta;
                                nextMainPoint = theCurPoint;
                                nextMainPointIndex = [theMapPoints indexOfObjectIdenticalTo:theCurPoint];
                                
                                //lastLine = curLine;
                                //lastVertex = GetLine( curLine ).GetVertex0();
                                //lastOtherVertex = GetLine( curLine ).GetVertex1();
                                
                                //NSLog(@"Lowest Line Index: %d  With Angle Of: %g", smallestLineIndex, smallestAngle);
                        }// End if ( theta <= 180.0 && theta < smallestAngle && [theCurPoint x] >= [firstPoint x])
    
                    } // End if (theCurPoint1 == firstPoint)
                } // End if (currentLine != thisMapLine)
            } // End while (currentLine = [numer nextObject])
            
            //We have found the next line to follow...
            NSLog(@"FINNAL Lowest Line Index: %ld  With Angle Of: %g", (long)smallestLineIndex, smallestAngle);
            
            if (smallestLineIndex < 0 || smallestLine == nil) // Proably -1, means it did not find a line that passed all the tests...
            {
                SEND_ERROR_MSG(@"One of the lines was not concave.");
                return NO;
            }
            
            if (lastLineToTest) {
                // Test to see and confirm that the line it choose is the same
                // as the first line that was found... 
                //NSLog(@"Second Phase Almost Complete...");
                if (smallestLine != [theNewPolyLines objectAtIndex:0])
                {
                    SEND_ERROR_MSG(@"When I reached the finnal line (going clockwise), the line with the smallest angle was not the orginal line!");
                    return NO;
                }
                
                // *** Polygon Completed, now for the hit test! ***
                
                keepFollowingTheLines = NO;
                NSLog(@"Second Phase Of Fill Polygon Method Found A Polygon!!!");
            }
            else
            {                
                // Need to see if the next main point is the same point as the first one...
                if ([theNewPolyVectors objectAtIndex:0] == nextMainPoint)
                {
                    // Will there be more then 8 vectors/lines in this poly?
                    if ([theNewPolyVectors count] > 8)
                    {
                        SEND_ERROR_MSG(@"More then 8 vertices when trying to fill polygon!");
                        return NO;
                    }
                    
                    // Add the new line and vector to the arrays...
                    [theNewPolyLines addObject:smallestLine];
                    
                    // Make the current main vector secondary, make new vector the main vector...
                    currentLineSecondaryPoint = currentLineMainPoint;
                    currentLineMainPoint = nextMainPoint;
                    
                    //Make The Next Current Line the one just found...
                    currentLine = smallestLine;
                    
                    lastLineToTest = YES;
                }
                else
                { // Polygon Not Yet Completed...
                    // Will there be more then 8 vectors/lines in this poly?
                    if ([theNewPolyVectors count] > 7)
                    {
                        SEND_ERROR_MSG(@"More then 8 vertices when trying to fill polygon!");
                        return NO;
                    }
                    
                    // Add the new line and vector to the arrays...
                    [theNewPolyVectors addObject:nextMainPoint];
                    [theNewPolyLines addObject:smallestLine];
                    
                    // Make the current main vector secondary, make new vector the main vector...
                    currentLineSecondaryPoint = currentLineMainPoint;
                    currentLineMainPoint = nextMainPoint;
                    
                    //Make The Next Current Line the one just found...
                    currentLine = smallestLine;
                }      
            } // End if (lastLineToTest) else
        } // End if ([theConnectedLines count] > 0) else
    } // End while (keepFollowingTheLines)
    
    //   theNewPolyVectors
    //   theNewPolyLines
    
    theNewPolygon = [[LEPolygon alloc] init];
    
    [currentLevel setUpArrayPointersFor:theNewPolygon];
    
    [theNewPolygon setVertextCount:[theNewPolyVectors count]];
    
    switch ([theNewPolyVectors count])
    {
        case 8:
            [theNewPolygon setV8:[theMapPoints indexOfObjectIdenticalTo:[theNewPolyVectors objectAtIndex:7]]];
            [theNewPolygon setLines:[theLines indexOfObjectIdenticalTo:[theNewPolyLines objectAtIndex:7]] toIndex:7];
        case 7:
            [theNewPolygon setV7:[theMapPoints indexOfObjectIdenticalTo:[theNewPolyVectors objectAtIndex:6]]];
            [theNewPolygon setLines:[theLines indexOfObjectIdenticalTo:[theNewPolyLines objectAtIndex:6]] toIndex:6];
        case 6:
            [theNewPolygon setV6:[theMapPoints indexOfObjectIdenticalTo:[theNewPolyVectors objectAtIndex:5]]];
            [theNewPolygon setLines:[theLines indexOfObjectIdenticalTo:[theNewPolyLines objectAtIndex:5]] toIndex:5];
        case 5:
            [theNewPolygon setV5:[theMapPoints indexOfObjectIdenticalTo:[theNewPolyVectors objectAtIndex:4]]];
            [theNewPolygon setLines:[theLines indexOfObjectIdenticalTo:[theNewPolyLines objectAtIndex:4]] toIndex:4];
        case 4:
            [theNewPolygon setV4:[theMapPoints indexOfObjectIdenticalTo:[theNewPolyVectors objectAtIndex:3]]];
            [theNewPolygon setLines:[theLines indexOfObjectIdenticalTo:[theNewPolyLines objectAtIndex:3]] toIndex:3];
        case 3:
            [theNewPolygon setV3:[theMapPoints indexOfObjectIdenticalTo:[theNewPolyVectors objectAtIndex:2]]];
            [theNewPolygon setLines:[theLines indexOfObjectIdenticalTo:[theNewPolyLines objectAtIndex:2]] toIndex:2];
        case 2:
            [theNewPolygon setV2:[theMapPoints indexOfObjectIdenticalTo:[theNewPolyVectors objectAtIndex:1]]];
            [theNewPolygon setLines:[theLines indexOfObjectIdenticalTo:[theNewPolyLines objectAtIndex:1]] toIndex:1];
        case 1:
            [theNewPolygon setV1:[theMapPoints indexOfObjectIdenticalTo:[theNewPolyVectors objectAtIndex:0]]];
            [theNewPolygon setLines:[theLines indexOfObjectIdenticalTo:[theNewPolyLines objectAtIndex:0]] toIndex:0];
            break;
        case 0:
        default:
            NSLog(@"should of never gotten here, something is HORABLY wrong!!!");
            // ??? should of never gotten here, something is HORABLY wrong!!! :(
            break;
    }
    
    // Check to see if the mouse click point is
    // in the new polygon, just to make sure...
    /*
    if (![theNewPolygon LEhitTest:mouseLoc])
    {
        NSLog(@"The hittest for the new polygon returned false!!!");
        return NO;
    }
    */
    
    NSLog(@"the new polygon hit test ok!");
    // Add the new polygon to the level...
    if (theNewPolygon == nil)
    {
        SEND_ERROR_MSG(@"theNewPolygon was nil, ERROR");
        return NO;
    }
    else
    {
        //*rectPolys, *rectLines, *rectPoints, *rectObjects;
        [currentLevel addObjects:theNewPolygon];
        [rectPolys addObject:theNewPolygon];
    }
        
    NSLog(@"Copying default settings to polygon...");
    
    [currentLevel setToDefaultState:theNewPolygon];
    //Update the Polygon Drawing Map...
    [self createPolyMap];
    [self setNeedsDisplayInRect:[theNewPolygon drawingBounds]];
    
    NSLog(@"Success!");
    
    // the new polygon was as far as I know,
    // sucsesfully intergrated within the level :)
    return YES;
} // End -(BOOL)usePaintTool:(NSPoint)mouseLoc



// jra 7-25-03: Complete rewrite, adding snap-from-point and snap-from-grid
//
// This method is called when the user clicks in the map with the line tool selected.
//  It is responsible for creating the new line object and new endpoint, and adding
//  the new endpoint to the selectedObjections collection so it will follow the mouse in the
//  drag run loop. It also must set currentDrawingMode to LEEDrawLineConnected or
//  LEEDrawLineNotConnected.

// Historical note: Before the rewrite this was done at the end of the method,
//  however the code has been changed so that at that point the difference is unknowable.
//  I don't think this makes a huge difference (during testing, stuck on Connected, it worked fine)
//  but I'm going make it work anyway.

- (BOOL)useLineTool:(NSPoint)mouseLoc
{

    // jra 7-25-03: What's going on here?
    // If user clicked directly on an existing point, start from it (old behavior)
    // Otherwise, if snap-from-point is on, start from the nearest point if one exists
    // Otherwise, if there were no nearby points and snap-from-grid is on, start from the
    //   nearest grid point
    // Otherwise, if snap-from-point or there were no neraby points and snap-from-grid is
    //   off (it's guaranteed to get one unless you set a huge grid and a tiny snap-from
    //   distance in which case you probably don't want it to snap), create a new point at
    //   the click location
    // If the user is holding down the shift key while they click to start the line
    //   (in otherwords, if shiftDown is true), the snap-from-grid setting is swapped (on->off, 
    //    off->on), which seems to be the most effective use of a hot key to switch one of the
    //    snap-from settings.

    LEMapPoint *pointToStartFrom = nil;

    LEMapPoint *curMousePoint;
    curMousePoint = [[LEMapPoint alloc] initX32:mouseLoc.x Y32:mouseLoc.y];
    // encapsulation break! It needs to know how to get to the current level
    // so we tell it.
    [curMousePoint setTheLELevelDataST:currentLevel];

    // Clicked directly on an existing point
    
    LEMapPoint *curPoint;
    NSMutableArray *theMapPoints;
    theMapPoints = [currentLevel getThePoints];

    NSEnumerator *numer;
    numer = [theMapPoints reverseObjectEnumerator];
    
    while (curPoint = [numer nextObject])	// iterate points
    {
	// clicked directly on this point?          \/ returns drawable rect
	if ([self mouse:mouseLoc inRect:[curPoint as32Rect]])
	{
	    // look out - only one point will be considered like this!!!
	    // but that's ok because that's how the old behavior worked anyway
	    // if anybody really cares they're welcome to add a check here to
	    // figure out which point the user clicked "most directly" on
	    pointToStartFrom = curPoint;
	    currentDrawingMode = LEEDrawLineConnected;
	    break;
	}
    }

    // Snap-from-points
    if(pointToStartFrom == nil)	// didn't get one yet
    {
	BOOL snapFromNearestPoint = [currentLevel settingAsBool:PhSnapFromPoints];
        
	int snapFromPointLength = [currentLevel settingAsInt:PhSnapFromLength];
	
	if(snapFromNearestPoint)	// should we snap from points?
	{
	    // find closest point within max snap from distance
	    pointToStartFrom = [curMousePoint nearestMapPointInRange:snapFromPointLength];
	    currentDrawingMode = LEEDrawLineConnected;
	}
    }

    // Snap-from-grid
    if(pointToStartFrom == nil)	// didn't get one yet
    {
	BOOL snapFromGrid = NO;
	snapFromGrid = YES; // [currentLevel settingAsBool:PhSnapFromGridBool];

        // if user holds shift key down as they click, we switch the snap-from-grid behavior
        // this makes it easy for a user to switchi between on-grid and off-grid drawing.
        if(controlKeyDown)
        {
            snapFromGrid = !snapFromGrid;
        }
        
	int snapFromGridLength = 0;
	snapFromGridLength = 16; // [currentLevel settingAsInt:PhSnapFromGridLength];	
	if(snapFromGrid)	// should we snap from grid points?
	{
	    // find closest grid point within max snap from distance
	    pointToStartFrom = [curMousePoint nearestGridPointInRange:snapFromGridLength];

	    // the point doesn't exist yet, so create it and add it to the level
	    if(pointToStartFrom)	// it might return nil, if the dist is too small
	    {
                // This will retain the point.
		[currentLevel addObjects:pointToStartFrom];
                
                // This will also retain the point, until it is removed
                // from the array. (same as above).
		[rectPoints addObject:pointToStartFrom];
		currentDrawingMode = LEEDrawLineNotConnected;
	    }
	}
    }

    // Create new point
    if(pointToStartFrom == nil)	// still didn't get one yet
    {
	// all of the above failed - so create a new point at the mouse click
        // Need to release this after adding it to the level
	pointToStartFrom = [[LEMapPoint alloc] init];
	
	[pointToStartFrom setX32:mouseLoc.x];
	[pointToStartFrom setY32:mouseLoc.y];
	
	[currentLevel addObjects:pointToStartFrom];
	[rectPoints addObject:pointToStartFrom];
        
	currentDrawingMode = LEEDrawLineNotConnected;
    }

    // guaranteed to have a real, usable point here to start the line from
    
    LELine *theNewLine;
    LEMapPoint *theNewPoint;	// endpoint of the line that starts at pointToStartFrom

    theNewPoint = [[LEMapPoint alloc] init];
    [theNewPoint setX32:mouseLoc.x];
    [theNewPoint setY32:mouseLoc.y];

    [currentLevel addObjects:theNewPoint]; // Need to do this though LELevel object!!!
    [rectPoints addObject:theNewPoint];
    
    theNewPoint = nil;
    
    theNewLine = [[LELine alloc] init];
    [currentLevel addObjects:theNewLine]; // Need to do this though LELevel object!!!
    [rectLines addObject:theNewLine];
    
    theNewLine = nil;
    
    [theNewLine setMapPoint1:pointToStartFrom];
    [theNewLine setMapPoint2:theNewPoint];
    
    // New stuff, makes it much better in the drag loop
    // in mouse down normal... :)
    startPoint = pointToStartFrom;
    endPoint = theNewPoint;
    newLine = theNewLine;
    
    [affectedBySelections addObject:theNewLine];
    [affectedBySelections addObject:theNewPoint];
    [affectedBySelections addObject:pointToStartFrom];
    [includeInBounds addObject:theNewLine];
    
    // jra 7-25-03: these lines were found commented - RC11F.
    //[theNewLine updateObjectsFromIndexes];
    [selectedPoints addObject:theNewPoint];
    //[theNewLine updateObjectsFromIndexes];

    return YES;
} // end useLineTool


// jra 7-26-03: This method acts like useLineTool, but it does nothing and simply
// returns the point the line WOULD start from.
// Used by snap-to-angle, and possibly useLineTool itself.
-(NSPoint)useLineToolHypothetically:(NSPoint)mouseLoc
{

    // jra 7-25-03: What's going on here?
    // If user clicked directly on an existing point, start from it (old behavior)
    // Otherwise, if snap-from-point is on, start from the nearest point if one exists
    // Otherwise, if there were no nearby points and snap-from-grid is on, start from the
    //   nearest grid point
    // Otherwise, if snap-from-point or there were no neraby points and snap-from-grid is
    //   off (it's guaranteed to get one unless you set a huge grid and a tiny snap-from
    //   distance in which case you probably don't want it to snap), create a new point at
    //   the click location
    // If the user is holding down the shift key while they click to start the line
    //   (in otherwords, if shiftDown is true), the snap-from-grid setting is swapped (on->off,
    //    off->on), which seems to be the most effective use of a hot key to switch one of the
    //    snap-from settings.

    LEMapPoint *pointToStartFrom = nil;

    LEMapPoint *curMousePoint;
    curMousePoint = [[LEMapPoint alloc] initX32:mouseLoc.x Y32:mouseLoc.y];
    // encapsulation break! It needs to know how to get to the current level
    // so we tell it.
    [curMousePoint setTheLELevelDataST:currentLevel];

    // Clicked directly on an existing point

    LEMapPoint *curPoint;
    NSMutableArray *theMapPoints;
    theMapPoints = [currentLevel getThePoints];

    NSEnumerator *numer;
    numer = [theMapPoints reverseObjectEnumerator];

    while (curPoint = [numer nextObject])	// iterate points
    {
	// clicked directly on this point?          \/ returns drawable rect
	if ([self mouse:mouseLoc inRect:[curPoint as32Rect]])
	{
	    // look out - only one point will be considered like this!!!
	    // but that's ok because that's how the old behavior worked anyway
	    // if anybody really cares they're welcome to add a check here to
	    // figure out which point the user clicked "most directly" on
	    pointToStartFrom = curPoint;
	    break;
	}
    }

    // Snap-from-points
    if(pointToStartFrom == nil)	// didn't get one yet
    {
	BOOL snapFromNearestPoint = NO;
	snapFromNearestPoint = YES; // [currentLevel settingAsBool:PhSnapFromPoints];

	int snapFromPointLength = 0;
	snapFromPointLength = 16; // [currentLevel settingAsInt:PhSnapFromPointsLength];

	if(snapFromNearestPoint)	// should we snap from points?
	{
	    // find closest point within max snap from distance
	    pointToStartFrom = [curMousePoint nearestMapPointInRange:snapFromPointLength];
	}
    }

    // Snap-from-grid
    if(pointToStartFrom == nil)	// didn't get one yet
    {
	BOOL snapFromGrid = NO;
	snapFromGrid = YES; // [currentLevel settingAsBool:PhSnapFromGridBool];

        // if user holds shift key down as they click, we switch the snap-from-grid behavior
        // this makes it easy for a user to switchi between on-grid and off-grid drawing.
        if(controlKeyDown)
        {
            snapFromGrid = !snapFromGrid;
        }

	int snapFromGridLength = 0;
	snapFromGridLength = 16; // [currentLevel settingAsInt:PhSnapFromGridLength];
	
	if(snapFromGrid)	// should we snap from grid points?
	{
	    // find closest grid point within max snap from distance
	    pointToStartFrom = [curMousePoint nearestGridPointInRange:snapFromGridLength];
	}
    }

    // Create new point
    if(pointToStartFrom == nil)	// still didn't get one yet
    {
	// all of the above failed - so create a new point at the mouse click
	pointToStartFrom = [[LEMapPoint alloc] init];
	
	[pointToStartFrom setX32:mouseLoc.x];
	[pointToStartFrom setY32:mouseLoc.y];
    }
    return NSMakePoint([pointToStartFrom x32], [pointToStartFrom y32]);
}



- (BOOL)useObjectTool:(NSPoint)mouseLoc toolType:(LEPaletteTool)tool
{
    LEMapObject *theNewObject = nil;
    NSPoint pointToUse = mouseLoc;
    LEPolygon *thePoly = nil;
    
    //if ([preferences boolForKey:PhSnapObjectsToGrid])
    //    pointToUse = [self closestPointOrGridIntersectionTo:mouseLoc includePoints:NO includeGrid:YES];
    
     // 50000 = max distance, that should cover anything.
     // the currentLevel thing is part of a minor kludge - the C function can't get
     // to the currentLevel object to get the grid factor so it has to be passed in.
     
     // JDO: Changed it so it gets the setting from the Level object.  This will make it
     //      so that the map manager drawer can override the setting from the prefs.
    
    // For right now, I think I will leave it commented out...
    // When placing objects, you can click and drag objects and it can snap to the grid
    // at that point.
    
    /*
     if ([currentLevel settingAsBool:PhSnapObjectsToGrid])
     {
	    LEMapPoint *foo = nil, *bar = nil;
	    bar = [[LEMapPoint alloc] initX32:mouseLoc.x Y32:mouseLoc.y];
	    foo = nearestGridPoint(bar, 50000, [currentLevel settingAsFloat:PhGridFactor]);
	    if(foo)
	    {
	        pointToUse.x = [foo x32];
	        pointToUse.y = [foo y32];
	    }
	    [foo release];
	    [bar release];
     }
    */
    
    thePoly = [self findPolygonAtPoint:pointToUse];
    
    // Clear Any Old Selections
    /*if (!shiftDown)
        [self clearSelections];*/
    
    if (thePoly != nil)
    {
        theNewObject = [currentLevel addObjectWithDefaults:[LEMapObject class]];
        [rectObjects addObject:theNewObject];
        
        switch (tool)
        {
            case LEPaletteToolMonster:
                [theNewObject setType:_saved_monster];
                break;
            case LEPaletteToolPlayer:
                [theNewObject setType:_saved_player];
                break;
            case LEPaletteToolItem:
                [theNewObject setType:_saved_item];
                break;
            case LEPaletteToolScenery:
                [theNewObject setType:_saved_object];
                break;
            case LEPaletteToolSound:
                [theNewObject setType:_saved_sound_source];
                break;
            case LEPaletteToolGoal:
                [theNewObject setType:_saved_goal];
                break;
			default:
				break;
        }
        
        // gets default state for the specific object type...
        [currentLevel setToDefaultState:theNewObject];
        
		[theNewObject setX32:(short)(pointToUse.x)];
		[theNewObject setY32:(short)(pointToUse.y)];
        //[theNewobject setIndex:0];
        //[theNewobject setFacing:0];
        
        [theNewObject setPolygonObject:thePoly];
        
        [self createObjectMaps];
        // [theNewobject drawingBounds];
            // Clear Any Old Selections
        
        if ([currentLevel settingAsBool:PhSelectObjectWhenCreated])
            [self selectObject:theNewObject byExtendingSelection:shiftDown];
        else
            [self setNeedsDisplayInRect:[theNewObject drawingBounds]];
        
        return YES;
    }
    else
    {
        SEND_ERROR_MSG(@"Sorry, but you need to have a polygon where you click.");
        return NO;
    }
}


// jra 8-2-03: Currently just debugging
-(BOOL)useZoomTool:(NSPoint)mouseLoc
{
    [self recenterViewToPoint:mouseLoc];

    if(optionDown)
	[self zoomOut:self];
    else
	[self zoomIn:self];
    
    return YES;
}

-(BOOL)useTextTool:(NSPoint)mouseLoc
{
    PhAnnotationNote *newNote = [[PhAnnotationNote alloc] initWithAdjPoint:mouseLoc];
    [(id)currentLevel addObject:newNote];
    [newNote setText:@"Type Annotation Note Here..."];
    [winController openAnnotationNoteEditor:newNote];
    return YES;
}

// *************************** Matence And Utility Methods ***************************
#pragma mark -
#pragma mark ********* Matence And Utility Methods *********


- (void)checkSelectedObjects
{
    if ([selectedMapObjects count] > 0)
    {
        NSMutableSet *objsCopy = [selectedMapObjects mutableCopy];
        NSEnumerator *pNumer = nil;
        //BOOL polyWasFoundForObject = NO;
        BOOL polyWasNotFoundForAtLeastOneObject = NO;
        // Get Bezier Path Of Poly
        // Then Do Hit Test When Muliple
        // Objects Can Be Selected
        
        /*************************
            *  JDO: Fixed this so it will finnaly work with multiple objects selected...
            *  I thought that since there was a good chance that the objects may be in the same polygon
            *  that when I find a polygon for one of the objects, I see if that polygon will work for
            *  the other objects. May not have to search all polygons in the current layer again that way...
            *************************/
        
        LEMapObject *theMapObj = nil;
        NSPoint thePoint = NSZeroPoint;
        LEPolygon *poly = nil;
        
        while ((theMapObj = [objsCopy anyObject]))
        {
            theMapObj = [objsCopy anyObject];
            thePoint = [theMapObj as32Point];
            poly = [self findPolygonAtPoint:thePoint];
            [theMapObj setPolygonObject:poly];
            [objsCopy removeObject:theMapObj];
            
            if (poly == nil /*!polyWasFoundForObject*/)
            {
                [theMapObj setPolygonObject:nil];
                polyWasNotFoundForAtLeastOneObject = YES;
            }
            else
            {
                // This will change the orginal set, this will make a copy
                // easily, and this should work for anything that responds to the
                // objectEnumerator message, so you don't have to worry about which
                // collection object your numerating though...
                pNumer = [[[objsCopy objectEnumerator] allObjects] objectEnumerator];
                while (theMapObj = [pNumer nextObject])
                {
                    thePoint = [theMapObj as32Point];
                    if ([poly LEhitTest:thePoint])
                    {
                        [theMapObj setPolygonObject:poly];
                        //polyWasFoundForObject = YES;
                        [objsCopy removeObject:theMapObj];
                    }
                }
            }
        }
        
        if (polyWasNotFoundForAtLeastOneObject)
            SEND_ERROR_MSG_TITLE(@"Selected map object is not in a polygon, if you do not fix this the object it is in danger of being deleted...",
                @"Map Object Error");
    }
}

- (void)checkSelectedNotes
{
    if ([selectedNotes count] > 0)
    {
        NSMutableSet *objsCopy = [selectedNotes mutableCopy];
        NSEnumerator *pNumer = nil;
        //BOOL polyWasFoundForObject = NO;
        BOOL polyWasNotFoundForAtLeastOneObject = NO;
        // Get Bezier Path Of Poly
        // Then Do Hit Test When Muliple
        // Objects Can Be Selected
        
        /*************************
            *  JDO: Fixed this so it will finnaly work with multiple notes selected...
            *  I thought that since there was a good chance that the notes may be in the same polygon
            *  that when I find a polygon for one of the notes, I see if that polygon will work for
            *  the other notes. May not have to search all polygons in the current layer again that way...
            *************************/
        
        PhAnnotationNote *theNote = nil;
        NSPoint thePoint = NSZeroPoint;
        LEPolygon *poly = nil;
        
        while ((theNote = [objsCopy anyObject]))
        {
            theNote = [objsCopy anyObject];
            // could be: [theNote locationAdjusted]
            thePoint = [theNote locationAdjusted];
            poly = [self findPolygonAtPoint:thePoint];
            [theNote setPolygonObject:poly];
            [objsCopy removeObject:theNote];
            
            if (poly == nil /*!polyWasFoundForObject*/)
            {
                [theNote setPolygonObject:nil];
                polyWasNotFoundForAtLeastOneObject = YES;
            }
            else
            {
                // This will change the orginal set, this will make a copy
                // easily, and this should work for anything that responds to the
                // objectEnumerator message, so you don't have to worry about which
                // collection object your numerating though...
                pNumer = [[[objsCopy objectEnumerator] allObjects] objectEnumerator];
                while (theNote = [pNumer nextObject])
                {
                    thePoint = [theNote locationAdjusted];
                    if ([poly LEhitTest:thePoint])
                    {
                        [theNote setPolygonObject:poly];
                        //polyWasFoundForObject = YES;
                        [objsCopy removeObject:theNote];
                    }
                }
            }
        }
        
        if (polyWasNotFoundForAtLeastOneObject)
            SEND_ERROR_MSG_TITLE(@"Selected annotation note is not in a polygon, if you do not fix this the object it is in danger of being deleted...",
                @"Map Object Error");
    }
}

- (void)clearRectCache
{
    [rectPolys removeAllObjects];
    [rectLines removeAllObjects];
    [rectPoints removeAllObjects];
    [rectObjects removeAllObjects];
    [rectNotes removeAllObjects];
    
    [self updateRectCacheIn:[self visibleRect]];
}

- (void)clearSelections
{
    if (selectedPoints == nil)
    {
        selectedPoints = [[NSMutableSet alloc] init];
    }
    if (selectedLines == nil)
    {
        selectedLines = [[NSMutableSet alloc] init];
    }
    if (selectedPolys == nil)
    {
        selectedPolys = [[NSMutableSet alloc] init];
    }
    if (selectedMapObjects == nil)
    {
        selectedMapObjects = [[NSMutableSet alloc] init];
    }
    if (affectedBySelections == nil)
    {
        affectedBySelections = [[NSMutableSet alloc] init];
    }
    if (includeInBounds == nil)
    {
        includeInBounds = [[NSMutableSet alloc] init];
    }
    if (selectedNotes == nil)
    {
        selectedNotes = [[NSMutableSet alloc] init];
    }
    
    [selectedNotes removeAllObjects];
    
    [selectedPoints removeAllObjects];
    [selectedMapObjects removeAllObjects];
    [selectedLines removeAllObjects];
    [selectedPolys removeAllObjects];
    [affectedBySelections removeAllObjects];
    [includeInBounds removeAllObjects];
    //[self updateTheSelections];
    
    return;
}

/*-(LEMapPoint *)getPointUnderRect:(NSPoint)mouseLoc
{
    
} */

- (NSRect)drawingBoundsForSelections
{
    NSRect rect = NSZeroRect;
    NSEnumerator *numer;
    BOOL firstDone = NO;
    id theCurObj;
    //unsigned i, c = [theObjs count];
    
    if ([selections count] < 1)
        return NSZeroRect;
    
    //NSLog(@"drawingBoundsForSelections 1");
    numer = [selections objectEnumerator];
    while (theCurObj = [numer nextObject]) {
        //NSLog(@"drawingBoundsForSelections 1a");
        if (!firstDone)
        {
            //NSLog(@"drawingBoundsForSelections 1b");
            rect = [theCurObj drawingBounds];
            //NSLog(@"drawingBoundsForSelections 1c");
            firstDone = YES;
        }
        else
        {
            //NSLog(@"drawingBoundsForSelections 1d");
            rect = NSUnionRect(rect, [theCurObj drawingBounds]);
        }
        //NSLog(@"drawingBoundsForSelections 1e");
    }
    //NSLog(@"drawingBoundsForSelections 2");
    numer = [includeInBounds objectEnumerator];
    while (theCurObj = [numer nextObject]) {
        if (!firstDone)
        {
            rect = [theCurObj drawingBounds];
            firstDone = YES;
        }
        else
        {
            rect = NSUnionRect(rect, [theCurObj drawingBounds]);
        }
    }
    if (rect.size.height < 2.0)
    {
        rect.size.height = 2.0;
        rect.origin.y -= 1.0;
    }
    if (rect.size.width < 2.0)
    {
        rect.size.width = 2.0;
        rect.origin.x -= 1.0;
    }
    return rect;
}

- (NSRect)drawingBoundsForObjects:(id)theSentObjs //NSArray, or some other collection object...
{
    NSRect rect = NSZeroRect;
    NSEnumerator *numer;
    
   // NSLog(@"Before!!!");
   
    numer = [theSentObjs objectEnumerator];
    for (LEMapStuffParent *theCurObj in numer)
            rect = NSUnionRect(rect, [theCurObj drawingBounds]);
    
    /*if (rect.size.height < 2.0)
    {
        rect.size.height = 2.0;
        rect.origin.y -= 1.0;
    }
    if (rect.size.width < 2.0)
    {
        rect.size.width = 2.0;
        rect.origin.x -= 1.0;
    }*/
    
    /*
    for (i=0; i<c; i++) {
        if (i==0) {
            NSLog(@"In Before!!!");
            rect = [[theObjs objectAtIndex:i] drawingBounds];
            NSLog(@"In After!!!");
        } else {
            rect = NSUnionRect(rect, [[theObjs objectAtIndex:i] drawingBounds]);
        }
    }
    */
    //NSLog(@"After!!!");
    return rect;
}

- (void)updateTheSelections
{
    // Might want to put code in here for
    // finding any objects that might be effected by the selections
    // and add them to the affected list?
    
    //affectedBySelections
    //includeInBounds 
    
    if (selections == nil)
    {
        selections = [[NSMutableSet alloc] init];
    }
    
    [selections removeAllObjects];
    
    if (selectedPoints != nil) { [selections unionSet:selectedPoints]; }
    if (selectedLines != nil) { [selections unionSet:selectedLines]; }
    if (selectedPolys != nil) { [selections unionSet:selectedPolys]; }
    if (selectedMapObjects != nil) { [selections unionSet:selectedMapObjects]; }
    if (selectedNotes != nil) { [selections unionSet:selectedNotes]; }
}

- (LEPolygon*)findPolygonAtPoint:(NSPoint)point
{
    NSEnumerator *numer;
    NSArray *thePolys;
    
    thePolys = [currentLevel layerPolys];
    numer = [thePolys reverseObjectEnumerator];
    for (LEPolygon *curObj in numer)
    {
        //if ([self mouse:point inRect:[curObj theDrawingBound]])
        //{
            if ([curObj LEhitTest:point])
                return curObj;
        //}
    }
    
    return nil;
}

// *************************** Keyboard Commands, Etc. ***************************
#pragma mark -
#pragma mark ********* Keyboard Commands, Etc. *********

// Keyboard commands
- (void)keyDown:(NSEvent *)event
{
    // Ask the palette if this is a tool hotkey
    if([[LEPaletteController sharedPaletteController] tryToMatchKey:[event characters]])
        return;
    
    // Otherwise, pass it on to the key binding manager.  This will end up calling insertText: or some command selector.
	int num = [[event characters] intValue];
    switch (num)
    {
        case 1:
            [currentLevel setSettingFor:PhGridFactor asFloat:0.125];
            break;
        case 2:
            [currentLevel setSettingFor:PhGridFactor asFloat:0.250];
            break;
        case 3:
            [currentLevel setSettingFor:PhGridFactor asFloat:0.500];
            break;
        case 4:
            [currentLevel setSettingFor:PhGridFactor asFloat:1.000];
            break;
        case 5:
            [currentLevel setSettingFor:PhGridFactor asFloat:2.000];
            break;
        case 6:
            [currentLevel setSettingFor:PhGridFactor asFloat:4.000];
            break;
        case 7:
            [currentLevel setSettingFor:PhGridFactor asFloat:8.000];
            break;
		default:
			[self interpretKeyEvents:[NSArray arrayWithObject:event]];
            break;
    }
	
	
    if (num > 0 && num < 8)
	{
		[winController updateMapManagerInterface];
		[[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePreferencesNotification object:nil];
	}
	
    // Handle the event we got
	/*
    NSEventType type;
	NSString *theStr = nil;
    type = [event type];
    switch (type)
    {
        case NSKeyDown:
			theStr = [event characters];
			if ([theStr isEqualToString:@"1"])
				
			break;
        case NSKeyUp:
			break;
        case NSFlagsChanged:
            //NSLog(@"NSFlagged Changed Down, Repeat: %@", (([event isARepeat]) ? @"YES" : @"NO"));
            //break;
        default:
            //NSLog(@"Key Down");
            [self interpretKeyEvents:[NSArray arrayWithObject:event]];
            break;
    }
	*/
}

- (void)keyUp:(NSEvent *)event
{
    // Handle the event we got
    NSEventType type;
    type = [event type];
    switch (type)
    {
        //case NSKeyDown:
        //case NSKeyUp:
        case NSFlagsChanged:
           // NSLog(@"NSFlagged Changed Up, Repeat: %@", (([event isARepeat]) ? @"YES" : @"NO"));
           // break;
        default:
            //NSLog(@"Key Up");
            break;
    }
}

- (void)insertText:(NSString *)str
{
    NSBeep();
}

/*- (void)hideKnobsMomentarily {
    if (_unhideKnobsTimer) {
        [_unhideKnobsTimer invalidate];
        _unhideKnobsTimer = nil;
    }
    _unhideKnobsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(unhideKnobs:) userInfo:nil repeats:NO];
    _gvFlags.knobsHidden = YES;
    [self invalidateGraphics:[self selectedGraphics]];
}

- (void)unhideKnobs:(NSTimer *)timer {
    _gvFlags.knobsHidden = NO;
    [self invalidateGraphics:[self selectedGraphics]];
    [_unhideKnobsTimer invalidate];
    _unhideKnobsTimer = nil;
}*/

- (void)moveSelectedGraphicsByPoint:(NSPoint)delta {
    NSLog(@"moveSelectedGraphicsByPoint");
    [self moveSelectedBy:delta];
/*
    NSArray *selection = [self selectedGraphics];
    unsigned i, c = [selection count];
    if (c > 0) {
        [self hideKnobsMomentarily];
        for (i=0; i<c; i++) {
            [[selection objectAtIndex:i] moveBy:delta];
        }
        [[self undoManager] setActionName:NSLocalizedStringFromTable(@"Nudge", @"UndoStrings", @"Action name for nudge keyboard commands.")];
    }
*/
}

- (void)moveLeft:(id)sender
{
    [self moveSelectedBy:NSMakePoint(-1.0, 0.0)];
    [self checkSelectedNotes];
    [self checkSelectedObjects];
    UpdateLevelStatusBar();
}

- (void)moveRight:(id)sender
{
    [self moveSelectedBy:NSMakePoint(1.0, 0.0)];
    [self checkSelectedNotes];
    [self checkSelectedObjects];
    UpdateLevelStatusBar();
}

- (void)moveUp:(id)sender
{
    [self moveSelectedBy:NSMakePoint(0.0, -1.0)];
    [self checkSelectedNotes];
    [self checkSelectedObjects];
    UpdateLevelStatusBar();
}

- (void)moveDown:(id)sender
{
    [self moveSelectedBy:NSMakePoint(0.0, 1.0)];
    [self checkSelectedNotes];
    [self checkSelectedObjects];
    UpdateLevelStatusBar();
}


- (void)moveForwardAndModifySelection:(id)sender {
    // We will use this to move by the grid spacing.
    //[self moveSelectedGraphicsByPoint:NSMakePoint([self gridSpacing], 0.0)];
}

- (void)moveBackwardAndModifySelection:(id)sender {
    // We will use this to move by the grid spacing.
    //[self moveSelectedGraphicsByPoint:NSMakePoint(-[self gridSpacing], 0.0)];
}

- (void)moveUpAndModifySelection:(id)sender {
    // We will use this to move by the grid spacing.
    //[self moveSelectedGraphicsByPoint:NSMakePoint(0.0, -[self gridSpacing])];
}

- (void)moveDownAndModifySelection:(id)sender {
    // We will use this to move by the grid spacing.
    //[self moveSelectedGraphicsByPoint:NSMakePoint(0.0, [self gridSpacing])];
}

// jra 8-2-03: These two are identical. Hence, make one call the other.
- (void)deleteForward:(id)sender
{
    [self deleteBackward:sender];
}

- (void)deleteBackward:(id)sender
{
    NSEnumerator *numer;
    id theCurObj;
    NSRect oldDrawingBounds = [self drawingBoundsForSelections];
    
    numer = [selections objectEnumerator];
    while (theCurObj = [numer nextObject])
        [currentLevel deleteObject:theCurObj];
    
    [self clearSelections];
    [self createPolyMap]; //Update the Polygon Drawing Map...
    [self clearRectCache];
    [self setNeedsDisplayInRect:oldDrawingBounds];
    
    // For right now, because a object removed from the level
    // could be in the undo stack.  Once I have object creation and deleation
    // undo support, this will not be nessary (because the object would be put
    // back into the level before it's deselection could be undone...
    // ******************************************** Temp Undo Manager Clear **************************************
    [myUndoManager removeAllActions];
}

// *************************** Utilities, Etc. ***************************
#pragma mark -
#pragma mark ********* Utilities, Etc. *********

-(BOOL)isThereAPolyAt:(NSPoint)mouseLoc
{
    NSEnumerator *numer;
    NSSet *thePolys;
    id curObj;
    
    thePolys = rectPolys;//[currentLevel layerPolys];
    //NSLog(@"Runing hit detection on polys...");
    numer = [thePolys objectEnumerator];
    while (curObj = [numer nextObject])
    {
        //if ([self mouse:mouseLoc inRect:[curObj theDrawingBound]])
        //{
            if ([curObj LEhitTest:mouseLoc])
            {
                return YES;
            }
        //}
    }
    
    return NO;
}

-(BOOL)isThereAPointAt:(NSPoint)mouseLoc
{
    NSEnumerator *numer;
    NSSet *theMapPoints;
    id curObj;
    
    theMapPoints = rectPoints;//[currentLevel layerPoints];
    
    numer = [theMapPoints objectEnumerator];
    while (curObj = [numer nextObject])
    {
        if ([self mouse:mouseLoc inRect:[curObj as32Rect]])
        {
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)isThereALineAt:(NSPoint)mouseLoc
{
    NSEnumerator *numer;
    NSSet *theLines;
    id curObj;
    
    theLines = rectLines;//[currentLevel layerLines];
    //NSLog(@"Runing hit detection on lines...");
    numer = [theLines objectEnumerator];
    while (curObj = [numer nextObject])
    {
        //if ([self mouse:mouseLoc inRect:[curObj theDrawingBound]])
        //{
            if ([curObj LEhitTest:mouseLoc])
            {
                return YES;
            }
        //}
    }
    return NO;
}

-(BOOL)isThereAObjectAt:(NSPoint)mouseLoc
{
    NSEnumerator *numer;
    NSSet *theMapObjects;
    id curObj;
    
    theMapObjects = rectObjects;//[currentLevel layerMapObjects];
    
    //NSLog(@"Runing hit detection on level objects...");
    numer = [theMapObjects objectEnumerator];
    while (curObj = [numer nextObject])
    {
        if ([self mouse:mouseLoc inRect:[curObj as32Rect]])
        {
            return YES;
        }
    }
    return NO;
}



- (void)scrollBy:(NSPoint)aPoint
{
    NSRect vis = [self visibleRect];
    NSPoint theOrigin = vis.origin;
    
    theOrigin.x = theOrigin.x + aPoint.x;
    theOrigin.y = theOrigin.y + aPoint.y;
    
    //NSLog(@"Scroll By: (%g, %g)", aPoint.x, aPoint.y);
    
    [self scrollPoint:theOrigin];
}

- (NSString *)rectArrayDescription
{
    return [NSString stringWithFormat:@"rectLines: %lu  rectObjects: %lu  rectPolys:%lu  rectPoints:%lu  rectNotes: %lu",
            (unsigned long)[rectLines count], (unsigned long)[rectObjects count], (unsigned long)[rectPolys count], (unsigned long)[rectPoints count], (unsigned long)[rectNotes count]];
}

//TODO: Need to add PhAnnotationNote support...
- (void)selectWithinRect:(NSRect)aRect registerUndos:(BOOL)regUndos
{
    NSSet *tmpSet = nil;
    id theObj;
    NSEnumerator *numer;
    NSMutableSet *diffSet = nil;
    
// // 
    
    diffSet = [[NSMutableSet alloc] init];
    // these should be lines that have not been selected yet, because it's excluding
    // the 'selectedLines' set, and they should not be in the 'selections' set either...
    tmpSet = [self getRectCacheObjectsIn:aRect ofSelectionType:_line_selections exclude:selectedLines];
    [selectedLines unionSet:tmpSet];
    
    if (regUndos == YES)
    {
        numer = [tmpSet objectEnumerator];
        while (theObj = [numer nextObject])
        {
            [currentLevel findObjectsAssociatedWith:theObj putIn:diffSet];
            [(id)undo undoSelection:theObj ofType:_line_selections];
            // For now, assume that this object will be newly put into
            // the master 'selections' set...
            [(id)undo undoSelection:theObj ofType:_all_selections];
        }
        
        // See what new additions there are...
        [diffSet minusSet:includeInBounds];
        [includeInBounds unionSet:diffSet];
        numer = [diffSet objectEnumerator];
        while (theObj = [numer nextObject])
            [(id)undo undoSelection:theObj ofType:_include_in_bounds];
    }
    else
    {
        numer = [tmpSet objectEnumerator];
        while (theObj = [numer nextObject])
            [currentLevel findObjectsAssociatedWith:theObj putIn:diffSet];
    }
    
    /*
    
    _all_selections = 0,
    _point_selections,
    _line_selections,
    _polygon_selections,
    _object_selections,
    _note_selections,
    _affected_by_selections,
    _include_in_bounds,
    
    */
    
    
    [diffSet removeAllObjects];
    tmpSet = [self getRectCacheObjectsIn:aRect ofSelectionType:_point_selections exclude:selectedPoints];
    [selectedPoints unionSet:tmpSet];
    if (regUndos == YES)
    {
        numer = [tmpSet objectEnumerator];
        while (theObj = [numer nextObject])
        {
            [currentLevel findObjectsAssociatedWith:theObj putIn:diffSet];
            [(id)undo undoSelection:theObj ofType:_point_selections];
            // For now, assume that this object will be newly put into
            // the master 'selections' set...
            [(id)undo undoSelection:theObj ofType:_all_selections];
        }
        
        // See what new additions there are...
        [diffSet minusSet:includeInBounds];
        [includeInBounds unionSet:diffSet];
        numer = [diffSet objectEnumerator];
        while (theObj = [numer nextObject])
            [(id)undo undoSelection:theObj ofType:_include_in_bounds];
    }
    else
    {
        numer = [tmpSet objectEnumerator];
        while (theObj = [numer nextObject])
            [currentLevel findObjectsAssociatedWith:theObj putIn:diffSet];
    }
    
    
    [diffSet removeAllObjects];
    tmpSet = [self getRectCacheObjectsIn:aRect ofSelectionType:_polygon_selections exclude:selectedPolys];
    [selectedPolys unionSet:tmpSet];
    if (regUndos == YES)
    {
        numer = [tmpSet objectEnumerator];
        while (theObj = [numer nextObject])
        {
            [currentLevel findObjectsAssociatedWith:theObj putIn:diffSet];
            [(id)undo undoSelection:theObj ofType:_polygon_selections];
            // For now, assume that this object will be newly put into
            // the master 'selections' set...
            [(id)undo undoSelection:theObj ofType:_all_selections];
        }
        
        // See what new additions there are...
        [diffSet minusSet:includeInBounds];
        [includeInBounds unionSet:diffSet];
        numer = [diffSet objectEnumerator];
        while (theObj = [numer nextObject])
            [(id)undo undoSelection:theObj ofType:_include_in_bounds];
    }
    else
    {
        numer = [tmpSet objectEnumerator];
        while (theObj = [numer nextObject])
            [currentLevel findObjectsAssociatedWith:theObj putIn:diffSet];
    }
    
    
    tmpSet = [self getRectCacheObjectsIn:aRect ofSelectionType:_object_selections exclude:selectedMapObjects];
    [selectedMapObjects unionSet:tmpSet];
    if (regUndos == YES)
    {
        numer = [tmpSet objectEnumerator];
        while (theObj = [numer nextObject])
        {
            [(id)undo undoSelection:theObj ofType:_object_selections];
            // For now, assume that this object will be newly put into
            // the master 'selections' set...
            [(id)undo undoSelection:theObj ofType:_all_selections];
        }
    }
    
    
    tmpSet = [self getRectCacheObjectsIn:aRect ofSelectionType:_note_selections exclude:selectedMapObjects];
    [selectedNotes unionSet:tmpSet];
    if (regUndos == YES)
    {
        numer = [tmpSet objectEnumerator];
        while (theObj = [numer nextObject])
        {
            //[currentLevel findObjectsAssociatedWith:theObj putIn:diffSet];
            [(id)undo undoSelection:theObj ofType:_note_selections];
            // For now, assume that this object will be newly put into
            // the master 'selections' set...
            [(id)undo undoSelection:theObj ofType:_all_selections];
        }
    }
    
    // I don't think you need to put note assoications in includeInBounds...
    // Same with map objects, right now findObjectsAssoiciatedWith does not
    //  do anything for a map object...
    
    //[self setNeedsDisplayInRect:[self drawingBoundsForObjects:tmpSet]];
    
    [self updateTheSelections];
    [self sendSelChangedNotification];
    [self setNeedsDisplayInRect:[self drawingBoundsForSelections]];
}

- (NSSet *)getRectCacheObjectsIn:(NSRect)aRect ofSelectionType:(int)selectionType exclude:(NSSet *)excludeSet
{
    /* Find new objects in the 'aRect', exclude objects in excludeSet */
    //NSRect theFrame = [self visibleRect];
    id theObj;
    NSEnumerator *numer;
    NSMutableSet *rectSet = [[NSMutableSet alloc] init];
    
    switch(selectionType)
    {
        case _point_selections:
            if (boolArrayOptions[_mapoptions_select_points])
            {
                numer = [rectPoints objectEnumerator];
                while (theObj = [numer nextObject])
                {
                    if (!([excludeSet containsObject:theObj]) && [theObj drawingWithinRect:aRect])
                        [rectSet addObject:theObj];
                }
            }
            break;
        
        case _line_selections:
            if (boolArrayOptions[_mapoptions_select_lines])
            {
                numer = [rectLines objectEnumerator];
                while (theObj = [numer nextObject])
                {
                    if (!([excludeSet containsObject:theObj]) && [theObj drawingWithinRect:aRect])
                        [rectSet addObject:theObj];
                }
            }
            break;
        
        case _polygon_selections:
            if (boolArrayOptions[_mapoptions_select_polygons])
            {
                numer = [rectPolys objectEnumerator];
                while (theObj = [numer nextObject])
                {
                    if (!([excludeSet containsObject:theObj]) && [theObj drawingWithinRect:aRect])
                        [rectSet addObject:theObj];
                }
            }
            break;
        
        case _object_selections:
            if (boolArrayOptions[_mapoptions_select_objects])
            {
                numer = [rectObjects objectEnumerator];
                while (theObj = [numer nextObject])
                {
                    if (!([excludeSet containsObject:theObj]) && [theObj drawingWithinRect:aRect])
                        [rectSet addObject:theObj];
                }
            }
            break;
        case _note_selections: // rectNotes
            if (boolArrayOptions[_mapoptions_select_notes])
            {
                numer = [rectNotes objectEnumerator];
                while (theObj = [numer nextObject])
                {
                    if (!([excludeSet containsObject:theObj]) && [theObj drawingWithinRect:aRect])
                        [rectSet addObject:theObj];
                }
            }
            break;
    }// END switch
    
    return [rectSet copy];
    
}// END function

- (void)updateRectCacheIn:(NSRect)aRect
{
    if (!shouldNotGetNewObjectsForTiledCache)
    {
        /* Find new objects in the 'aRect', remove objects
            no longer in the frame rect */
        NSRect theFrame = [self visibleRect];
        id theObj;
        NSEnumerator *numer;
        
        numer = [[[rectPoints objectEnumerator] allObjects] objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if (![theObj drawingWithinRect:theFrame])
                [rectPoints removeObject:theObj];
        }
        numer = [[[rectLines objectEnumerator] allObjects] objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if (![theObj drawingWithinRect:theFrame])
                [rectLines removeObject:theObj];
        }
        numer = [[[rectPolys objectEnumerator] allObjects] objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if (![theObj drawingWithinRect:theFrame])
                [rectPolys removeObject:theObj];
        }
        numer = [[[rectObjects objectEnumerator] allObjects] objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if (![theObj drawingWithinRect:theFrame])
                [rectObjects removeObject:theObj];
        }
        numer = [[[rectNotes objectEnumerator] allObjects] objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if (![theObj drawingWithinRect:theFrame])
                [rectNotes removeObject:theObj];
        }
        
        // *** *** ***
        
        numer = [[currentLevel layerLines] objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if ([theObj drawingWithinRect:aRect])
                [rectLines addObject:theObj];
        }
        
        if ([preferences boolForKey:PhDrawOnlyLayerPoints])
            numer = [[currentLevel layerPoints] objectEnumerator];
        else
            numer = [[currentLevel getThePoints] objectEnumerator];
        
        //numer = [[currentLevel layerPoints] objectEnumerator];
        
        while (theObj = [numer nextObject])
        {
            if ([theObj drawingWithinRect:aRect])
                [rectPoints addObject:theObj];
        }
        
        numer = [[currentLevel layerPolys] objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if ([theObj drawingWithinRect:aRect])
                [rectPolys addObject:theObj];
        }
        numer = [[currentLevel layerMapObjects] objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if ([theObj drawingWithinRect:aRect])
                [rectObjects addObject:theObj];
        }
        numer = [[currentLevel layerNotes] objectEnumerator];
        while (theObj = [numer nextObject])
        {
            if ([theObj drawingWithinRect:aRect])
                [rectNotes addObject:theObj];
        }
        
        //shouldNotGetNewObjectsForTiledCache = YES;
        
        ///UpdateLevelStatusBar();
    }
    
    shouldNotGetNewObjectsForTiledCache = NO;
}

- (NSSet *)listOfLinesWithin:(NSRect)aRect
{
    NSMutableSet *theTmpRectLines = [[NSMutableSet alloc] initWithCapacity:50];
    NSEnumerator *numer;
    LELine *theObj;
    
    numer = [[currentLevel layerLines] objectEnumerator];
    while (theObj = [numer nextObject])
    {
        if ([theObj drawingWithinRect:aRect])
            [theTmpRectLines addObject:theObj];
    }
    //NSLog(@"listOfLinesWithin count: %d", [theTmpRectLines count]);
    return [theTmpRectLines copy];
}
        
- (NSString *)gotoAndSelectIndex:(int)theIndex ofType:(int)typeOfPfhorgeObject
{
    NSArray *arrayOne = nil, *arrayTwo = nil;
    id obj1 = nil, obj2 = nil;

    switch(typeOfPfhorgeObject)
    {
        case _goto_polygon:
            arrayOne = [currentLevel getThePolys];
            arrayTwo = [currentLevel layerPolys];
            break;
        case _goto_object:
            arrayOne = [currentLevel theMapObjects];
            arrayTwo = [currentLevel layerMapObjects];
            break;
        case _goto_platform:
            arrayOne = [currentLevel getPlatforms];
            
            if ([arrayOne count] <= theIndex)
                return @"Platform Index Beyond Bounds";
            
            obj1 = [arrayOne objectAtIndex:theIndex];
            obj2 = [(PhPlatform *)obj1 polygonObject];
            arrayTwo = [currentLevel layerPolys];
            
            if ([arrayTwo containsObject:obj2])
                [self selectObject:obj2 byExtendingSelection:NO];
            else
                return @"Platform's Polygon Not In Visible Layer";
            
            [self scrollRectToVisible:[self drawingBoundsForSelections]];
            
            return nil;
        case _goto_line:
            arrayOne = [currentLevel getTheLines];
            arrayTwo = [currentLevel layerLines];
            break;
        case _goto_point:
            arrayOne = [currentLevel getThePoints];
            arrayTwo = [currentLevel layerPoints];
            break;
    }
    
    if ([arrayOne count] <= theIndex)
        return @"Index Beyond Bounds";
    
    obj1 = [arrayOne objectAtIndex:theIndex];
    
    if ([arrayTwo containsObject:obj1])
        [self selectObject:obj1 byExtendingSelection:NO];
    else
        return @"Not In Visible Layer";
    
    [self scrollRectToVisible:[self drawingBoundsForSelections]];
    
    return nil;
}

- (void)deselectObject:(id)theObj
{
    Class theClass = [theObj class];
    
    [selections removeObject:theObj];
    
    if (theClass == [LEMapPoint class])
	[selectedPoints removeObject:theObj];
        
    else if (theClass == [LELine class])
        [selectedLines removeObject:theObj];
        
    else if (theClass == [LEPolygon class])
	[selectedPolys removeObject:theObj];
        
    else if (theClass == [LEMapObject class])
        [selectedMapObjects removeObject:theObj];
    
    else if (theClass == [PhAnnotationNote class])
        [selectedNotes removeObject:theObj];
}

- (BOOL)isObjectInSelections:(id)theObj
{
    if ([selections containsObject:theObj] == YES)
        return YES;
    
    return NO;
}

- (BOOL)isPointInSelection:(NSPoint)thePoint
{
    NSEnumerator *numer = nil;//[selections objectEnumerator];
    id thisObj = nil;
    
    if (selections == nil)
        return NO;
    
    //[self isThereAObjectAt:thePoint];
    
    // selectedMapObjects
    // selectedLines
    // selectedPoints
    // selectedPolys
    
    
    numer = [selections objectEnumerator];
    
    while ((thisObj = [numer nextObject]))
    {
        if ([thisObj LEhitTest:thePoint])
            return YES;
    }
    
    return NO;
}

- (void)recaculateAndRedrawEverything
{
    [self clearRectCache];
    
    if (drawingMode == _drawNormaly || drawingMode == _drawAbnormaly)
    {
        [self createObjectMaps];
        [self createPolyMap];
        [self createLineMap];
    }
    else
    {
        [self createSpecialDrawingMap];
    }
    [self display];
}

- (void)redrawBoundsOfSelection
{
    [self setNeedsDisplayInRect:[self drawingBoundsForSelections]];
}

- (void)checkObjectsAssociatedWithSelection
{
    [self moveSelectedBy:NSMakePoint(0.0, 0.0)];
}

- (void)selectObject:(id)theObject byExtendingSelection:(BOOL)extSelection
{
    Class theClass = [theObject class];
    
    // Clear Any Old Selections
    if (!extSelection || theObject == nil)
        [self clearSelections];
    
    if (theObject == nil)
        return;
    
    if (theClass == [LEMapPoint class])
	[selectedPoints addObject:theObject];
        
    else if (theClass == [LELine class])
        [selectedLines addObject:theObject];
        
    else if (theClass == [LEPolygon class])
	[selectedPolys addObject:theObject];
        
    else if (theClass == [LEMapObject class])
        [selectedMapObjects addObject:theObject];
    
    else if (theClass == [PhAnnotationNote class])
        [selectedNotes addObject:theObject];
    
    else
    {
        [self updateTheSelections];
        [self display];
        SEND_ERROR_MSG(@"Tryed To Select An Object Of Unknown Class...");
        return;
    }
    
    [currentLevel findObjectsAssociatedWith:theObject putIn:includeInBounds];
    [self updateTheSelections];
    [self setNeedsDisplayInRect:[theObject drawingBounds]];
    [self sendSelChangedNotification];
}

- (void)checkConcavenessOnPolys:(id)theEnumerationCapableCollection
{
        NSEnumerator *numer = [theEnumerationCapableCollection objectEnumerator];
        id thisObj;
        
        while ((thisObj = [numer nextObject]))
        {
            if ([thisObj isKindOfClass:[LEPolygon class]])
            {
                [thisObj isPolygonConcave];
                continue;
            }
        }
}

// OBSOLETE!!!
// USE LEMAPPOINT'S NEARESTMAPPOINT OR NEARESTGRIDPOINT METHODS INSTEAD
// THIS DOES NOT WORK (yet) \/
- (NSPoint)closestPointOrGridIntersectionTo:(NSPoint)mouseLoc includePoints:(BOOL)includePoints includeGrid:(BOOL)includeGrid
{
    NSPoint pointCache[100];
    int pointCacheMax = 100;
    int pci = 0;
    NSPoint shortestDistanceNSPoint = NSMakePoint(0,0);
    int snapToPointLength = [currentLevel settingAsInt:PhSnapToPointsLength];
    CGFloat gridFactor = [currentLevel settingAsFloat:PhGridFactor]; // Used to be one...
    
   /* if (includePoints == YES)
    {
        NSRect snapToRect = NSMakeRect(mouseLoc.x - snapToPointLength,
                                        mouseLoc.y - snapToPointLength,
                                        snapToPointLength*2,
                                        snapToPointLength*2);
        
            // Only need to check current layer points...
        NSArray *mapPointsArray = [currentLevel layerPoints];
        NSEnumerator *numer;
        is curObj;
        
            // Determin if there are any close points,,,
        numer = [mapPointsArray reverseObjectEnumerator];
        while (curObj = [numer nextObject])
        {
            
            if ([self mouse:[curObj as32Point] inRect:snapToRect]
                && curObj != theSelectedP)
            {
                if (pointCacheMax > pci)
                {
                    pointCache[pci] = NSMakePoint([curObj x32], [curObj y32]);
                    pci++;
                    //[thePointsInRange addObject:curObj];
                }
                else
                    break;
            }
        }
    }*/
    
    if (includeGrid == YES)
    {
        int gridCordY;
        int gridCordX;
        int numberOfGridLines = (int)(64.0 * gridFactor);
        int minXCord = mouseLoc.x - snapToPointLength;
        int maxXCord = mouseLoc.x + snapToPointLength;
        int maxYCord = mouseLoc.y + snapToPointLength;
        int minYCord = mouseLoc.y - snapToPointLength;
        
        for  (gridCordY = minYCord; gridCordY <= maxYCord; gridCordY++)
        {
            if (gridCordY % numberOfGridLines == 0)
            {
                for  (gridCordX = minXCord; gridCordX <= maxXCord; gridCordX++)
                {
                    if (gridCordX % numberOfGridLines == 0)
                    {
                        if (pointCacheMax > pci)
                        {
                            //NSLog(@"Grid Pint Found On: (%d, %d)", gridCordX, gridCordY);
                            pointCache[pci] = NSMakePoint(gridCordX, gridCordY);
                            pci++;
                        }
                        else
                            break;
                    }
                }
            }
        }
    }
    
    if (pci == 0) // No points in range...
    {
        shortestDistanceNSPoint = mouseLoc;
    }
    else if (pci == 1) // Only one point in range...
    {
        shortestDistanceNSPoint = pointCache[0];
    }
    else // More then one point in range...
    {
        int shortestDistance = 50000;
        int i = 0;
        NSPoint shortestDistanceNSPoint = pointCache[0];
        
        int mX = mouseLoc.x;
        int mY = mouseLoc.y;
        
        //LEMapPoint *shortestDistancePoint = nil;
        //numer = [thePointsInRange reverseObjectEnumerator];
        //while (curObj = [numer nextObject])
        
        for (i = 0; i < pci; i++)
        {
            int dX = mX - (pointCache[i].x);
            int dY = mY - (pointCache[i].y);
            int theDist = sqrt(((dY * dY) + (dX * dX)));
            
            if (theDist < shortestDistance)
            {
                shortestDistance = theDist;
                shortestDistanceNSPoint = pointCache[i];
            }
        }
        
        //if (shortestDistancePoint != nil)
            //[self moveSelectedTo:shortestDistanceNSPoint];
    }
    
    return shortestDistanceNSPoint;
}


// jra 7-25-03: Updates the modifier key variables (shiftDown, etc)
-(void)updateModifierKeys:(NSEvent*)theEvent
{
    NSEventModifierFlags newFlags = [theEvent modifierFlags];

    if (newFlags & NSAlphaShiftKeyMask)
        capsLockDown = YES;
    else
        capsLockDown = NO;

    if (newFlags & NSShiftKeyMask)
        shiftDown = YES;
    else
        shiftDown = NO;

    if (newFlags & NSControlKeyMask)
        controlKeyDown = YES;
    else
        controlKeyDown = NO;

    if (newFlags & NSAlternateKeyMask)
        optionDown = YES;
    else
        optionDown = NO;

    if (newFlags & NSCommandKeyMask)
        commandDown = YES;
    else
        commandDown = NO;
}

// *************************** This Is To Help Support Undo/Redo ***************************
#pragma mark -
#pragma mark ********* This Is To Help Support Undo/Redo *********


-(void)undoSelection:(id)obj ofType:(int)type
{
    // Won't matter if it's nil, because a message to nil does nothing...
    // But it might be usefull to still check for nil so that
    // it is known that a error occured...
    [(NSMutableSet*)[self getSelectionsOfType:type] removeObject:obj];
    [(id)undo undoDeselection:obj ofType:type];
}

-(void)undoDeselection:(id)obj ofType:(int)type
{
    [(NSMutableSet*)[self getSelectionsOfType:type] addObject:obj];
    [(id)undo undoSelection:obj ofType:type];
}


-(void)affectedBySelectionsAdd:(id)obj
{
    NSLog(@"Call To A Method Which Is Not Complete (affectedBySelectionsAdd:)");
}

-(void)includeInBoundsAdd:(id)obj
{
    NSLog(@"Call To A Method Which Is Not Complete (includeInBoundsAdd:)");
}

-(void)addObjectToLevel:(id)obj
{
    NSLog(@"Call To A Method Which Is Not Complete (addObjectToLevel:)");
}

-(void)removeObjectFromLevel:(id)obj
{
    NSLog(@"Call To A Method Which Is Not Complete (removeObjectFromLevel:)");
}



// *************************** Notification Methods/Functions ***************************
#pragma mark -
#pragma mark ********* Notification Methods/Functions *********

- (void)undoHappened
{
    [self checkSelectedNotes];
    [self checkSelectedObjects];
    [self checkConcavenessOnPolys:includeInBounds];
    [self checkConcavenessOnPolys:selections];
    [self recaculateAndRedrawEverything];
    UpdateLevelStatusBar();
}

- (void)redoHappened
{
    [self undoHappened];
}

- (void)prefsChanged
{
    // This updates Anything That Needs it, And Marks
    // This view for redrawing...
    NSLog(@"Setting prefs in map view...");
    caculateTheGrid = YES;
    isAntialiasingOn = [currentLevel settingAsBool:PhEnableAntialiasing];
    shouldObjectOutline = [currentLevel settingAsBool:PhEnableObjectOutling];
    
    shouldDrawItemObjects = [currentLevel settingAsBool:PhEnableObjectItem];
    shouldDrawPlayerObjects = [currentLevel settingAsBool:PhEnableObjectPlayer];
    shouldDrawEnemyMonstersObjects = [currentLevel settingAsBool:PhEnableObjectEnemyMonster];
    shouldDrawSceanryObjects = [currentLevel settingAsBool:PhEnableObjectSceanry];
    shouldDrawSoundObjects = [currentLevel settingAsBool:PhEnableObjectSound];
    shouldDrawGoalObjects = [currentLevel settingAsBool:PhEnableObjectGoal];
    shouldDrawPlatfromPolyObjects = [currentLevel settingAsBool:PhEnablePlatfromPolyColoring];
    shouldDrawConvexPolyObjects = [currentLevel settingAsBool:PhEnableConvexPolyColoring];
    shouldDrawZonePolyObjects = [currentLevel settingAsBool:PhEnableZonePolyColoring];
    shouldDrawTeleporterExitPolyObjects = [currentLevel settingAsBool:PhEnableTeleporterExitPolyColoring];
    shouldDrawHillPolyObjects = [currentLevel settingAsBool:PhEnableHillPolyColoring];
    
    [self createObjectMaps];
    
    [self createPolyMap];
    //[self createLineMap];
    
    //[self display];
    if (timer != nil)
    {
        [timer invalidate];
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.05
        target:self 
        selector:@selector(timerDraw:) 
        userInfo:nil 
        repeats:NO];

    NSLog(@"Done setting prefs in map view...");
}

- (void)timerDraw:(NSTimer *)incommingTimer
{
    [self setNeedsDisplay:YES];
    timer = nil;
}

// *************************** For Changing/Getting Settings ***************************
#pragma mark -
#pragma mark ********* For Changing/Getting Settings *********
//COUNT_OF_BOOL_ARRAY_OPTIONS

- (BOOL)setBoolOptionsFor:(int)theSetting to:(BOOL)value
{
    if (theSetting < 0 || theSetting >= COUNT_OF_BOOL_ARRAY_OPTIONS)
        return NO;
    
    boolArrayOptions[theSetting] = value;

    return YES;
}

- (BOOL)boolOptionsFor:(int)theSetting
{
    if (theSetting < 0 || theSetting >= COUNT_OF_BOOL_ARRAY_OPTIONS)
        return NO;
    
    return ((boolArrayOptions[theSetting]) ? YES : NO);
}

// *************************** First Responder Actions ***************************
#pragma mark -
#pragma mark ********* First Responder Actions *********

- (IBAction)getInfoAction:(id)sender
{
    [[selections anyObject] displayInfo];
}

- (IBAction)caculateSidesOnSelectedLines:(id)sender
{
    // selectedLines
    NSEnumerator *numer = [selectedLines objectEnumerator];
    id thisObj;
    
    while ((thisObj = [numer nextObject]))
    {
        [thisObj caculateSides];
    }
}

#pragma mark -

- (IBAction)cut:(id)sender
{
    [self copy:sender];
    [self deleteForward:sender];
}

- (IBAction)copy:(id)sender
{

    // - (NSSet *)importObjects:(NSData *)theData
    // - (NSData *)exportObjects:(NSSet *)theData
    
    if ([selections count] > 0)
    {
        NSPasteboard *thePasteboard = [NSPasteboard generalPasteboard];
        //id curObj = nil;
        //NSEnumerator *numer = [selections objectEnumerator];
        NSData *theLevelMapData = nil;
       /* int theChangeCount = */ [thePasteboard declareTypes:[NSArray arrayWithObjects:@"PhorgeSelectionData", nil]
                                owner:nil];
        
       // numer = [selections objectEnumerator];
        
        NSLog(@"Count of selections: %lu", (unsigned long)[selections count]);
        
        theLevelMapData = [currentLevel exportObjects:selections];
        
        //while (curObj = [numer nextObject])
        //    [curObj setEncodeIndexNumbersInstead:YES];
        
        //theLevelMapData = [NSArchiver archivedDataWithRootObject:[selections allObjects]];
        
        //numer = [selections objectEnumerator];
        //while (curObj = [numer nextObject])
        //    [curObj setEncodeIndexNumbersInstead:NO];
        
        [thePasteboard setData:theLevelMapData forType:@"PhorgeSelectionData"];
    }
    
    return;
    
    
    if ([selections count] > 0)
    {
        NSPasteboard *thePasteboard = [NSPasteboard generalPasteboard];
        id curObj = nil;
        NSEnumerator *numer = nil;//[selections objectEnumerator];
        NSData *theLevelMapData = nil;
       /* int theChangeCount = */ [thePasteboard declareTypes:[NSArray arrayWithObjects:@"PhorgeSelectionData", nil]
                                owner:nil];
        
        numer = [selections objectEnumerator];
        
        NSLog(@"Count of selections: %lu", (unsigned long)[selections count]);
        
        while (curObj = [numer nextObject])
            [curObj setEncodeIndexNumbersInstead:YES];
        
        theLevelMapData = [NSArchiver archivedDataWithRootObject:[selections allObjects]];
        
        numer = [selections objectEnumerator];
        while (curObj = [numer nextObject])
            [curObj setEncodeIndexNumbersInstead:NO];
        
        [thePasteboard setData:theLevelMapData forType:@"PhorgeSelectionData"];
    }
}

- (IBAction)paste:(id)sender
{
    NSPasteboard *thePasteboard = [NSPasteboard generalPasteboard];
    NSArray *theTypes = [thePasteboard types];
    
    if ([theTypes containsObject:@"PhorgeSelectionData"])
    {
        NSSet *theSelections = nil;
        id curObj = nil;
        NSEnumerator *numer = nil;
        
        NSLog(@"Type was found, begining to unarchive and paste data...");
        //theSelections = [[NSSet setWithArray:[NSUnarchiver unarchiveObjectWithData:[thePasteboard dataForType:@"PhorgeSelectionData"]]] retain];
        
        theSelections = [currentLevel importObjects:[thePasteboard dataForType:@"PhorgeSelectionData"]];
        
        // Clear Any Old Selections
        [self clearSelections];
        
        // Don't you need to add it to the level first???
        
        numer = [theSelections objectEnumerator];
        while (curObj = [numer nextObject])
        {
            [self selectObject:curObj byExtendingSelection:YES];
        }
        
        //Update the selctions set...
        [self updateTheSelections];
        //[theSelections release]; // autoreleased...
        
        [self setNeedsDisplayInRect:[self drawingBoundsForSelections]];
    }

    return;
    
    if ([theTypes containsObject:@"PhorgeSelectionData"])
    {
        NSSet *theSelections = nil;
        id curObj = nil;
        NSEnumerator *numer = nil;
        
        NSLog(@"Type was found, begining to unarchive and paste data...");
        theSelections = [NSSet setWithArray:[NSUnarchiver unarchiveObjectWithData:[thePasteboard dataForType:@"PhorgeSelectionData"]]];
        
        // Clear Any Old Selections
        [self clearSelections];
        
        // Don;t YOu need to add it to the level first???
        
        numer = [theSelections objectEnumerator];
        while (curObj = [numer nextObject])
        {
            if ([curObj isKindOfClass:[LEMapPoint class]])
                [selectedPoints addObject:curObj];
            else if ([curObj isKindOfClass:[LELine class]])
                [selectedLines addObject:curObj];
            else if ([curObj isKindOfClass:[LEPolygon class]])
                [selectedPolys addObject:curObj];
            else if ([curObj isKindOfClass:[LEMapObject class]])
                [selectedMapObjects addObject:curObj];
            else
                NSLog(@"Unknown Object In Paste Data...");
        }
        //Update the selctions set...
        [self updateTheSelections];
        
        [self setNeedsDisplayInRect:[self drawingBoundsForSelections]];
    }
}

#pragma mark -

#define ZOOMINFACTOR   (1.2)
#define ZOOMOUTFACTOR  (1.0 / ZOOMINFACTOR)

- (IBAction)zoomIn:(id)sender
{
    [self zoomBy:ZOOMINFACTOR];
}

- (IBAction)zoomOut:(id)sender
{
    [self zoomBy:ZOOMOUTFACTOR];
}

-(void)zoomBy:(float)zoomfactor;
{
    NSRect tempRect;
    NSRect oldBounds;
    //NSScrollView *scrollView = [self enclosingScrollView];
    
    // Get the current view center
    NSRect docVisRect = [scrollView documentVisibleRect];
    NSPoint oldOrigin;
    oldOrigin.x = docVisRect.origin.x;
    oldOrigin.y = docVisRect.origin.y;
    
    NSPoint oldViewCtr;
    oldViewCtr.x = oldOrigin.x + (docVisRect.size.width / 2.0);
    oldViewCtr.y = oldOrigin.y + (docVisRect.size.height / 2.0);

    NSPoint oldOffset;
    oldOffset.x = oldViewCtr.x - oldOrigin.x;
    oldOffset.y = oldViewCtr.y - oldOrigin.y;

    // Do the actual zoom
        oldBounds = [self bounds];
    tempRect = [self frame];
    tempRect.size.width = zoomfactor * NSWidth(tempRect);
    tempRect.size.height = zoomfactor * NSHeight(tempRect);
    [self setFrame:tempRect];

    // This was left here, looks like no-op

    [self setBoundsSize:oldBounds.size];
    [self setBoundsOrigin:oldBounds.origin];

    // Calculate the new view origin
    NSPoint newOffset;
    newOffset.x = oldOffset.x / zoomfactor;
    newOffset.y = oldOffset.y / zoomfactor;
    
    NSPoint newOrigin;
    newOrigin.x = oldViewCtr.x - newOffset.x;
    newOrigin.y = oldViewCtr.y - newOffset.y;

    // Ask our nearest ancestor NSClipView to make this its new (view) origin
    [self scrollPoint:newOrigin];

    [self setNeedsDisplay:YES];

    return;
}


- (IBAction)zoomNormal:(id)sender
{
    NSRect tempRect;
    NSRect oldBounds;
    //NSScrollView *scrollView = [self enclosingScrollView];

    // Get the current view center
    NSRect docVisRect = [scrollView documentVisibleRect];
    NSPoint oldOrigin;
    oldOrigin.x = docVisRect.origin.x;
    oldOrigin.y = docVisRect.origin.y;

    NSPoint oldViewCtr;
    oldViewCtr.x = oldOrigin.x + (docVisRect.size.width / 2.0);
    oldViewCtr.y = oldOrigin.y + (docVisRect.size.height / 2.0);

    NSPoint oldOffset;
    oldOffset.x = oldViewCtr.x - oldOrigin.x;
    oldOffset.y = oldViewCtr.y - oldOrigin.y;

    // Do the actual zoom
    oldBounds = [self bounds];
    tempRect = [self frame];
    float zoomfactor = 4096.0 / tempRect.size.width;
    tempRect.size.width = zoomfactor * NSWidth(tempRect);
    tempRect.size.height = zoomfactor * NSHeight(tempRect);
    [self setFrame:tempRect];

    // This was left here, looks like no-op

    [self setBoundsSize:oldBounds.size];
    [self setBoundsOrigin:oldBounds.origin];

    // Calculate the new view origin
    NSPoint newOffset;
    newOffset.x = oldOffset.x / zoomfactor;
    newOffset.y = oldOffset.y / zoomfactor;

    NSPoint newOrigin;
    newOrigin.x = oldViewCtr.x - newOffset.x;
    newOrigin.y = oldViewCtr.y - newOffset.y;

    // Ask our nearest ancestor NSClipView to make this its new (view) origin
    [self scrollPoint:newOrigin];

    [self setNeedsDisplay:YES];

    return;
}

#pragma mark -

- (IBAction)redrawEverything:(id)sender { [self setNeedsDisplay:YES]; }

- (IBAction)setDrawModeToNormal:(id)sender { [self setCurrentDrawingMode:_drawNormaly]; }
- (IBAction)setDrawModeToCeilingHeight:(id)sender { [self setCurrentDrawingMode:_drawCeilingHeight]; }
- (IBAction)enableFloorHeightViewMode:(id)sender { [self setCurrentDrawingMode:_drawFloorHeight]; }
- (IBAction)enableLiquidViewMode:(id)sender { [self setCurrentDrawingMode:_drawLiquids]; }
- (IBAction)enableFloorLightViewMode:(id)sender { [self setCurrentDrawingMode:_drawFloorLights]; }
- (IBAction)enableCeilingLightViewMode:(id)sender { [self setCurrentDrawingMode:_drawCeilingLights]; }
- (IBAction)enableLiquidLightViewMode:(id)sender { [self setCurrentDrawingMode:_drawLiquidLights]; }
- (IBAction)enableAmbientSoundViewMode:(id)sender { [self setCurrentDrawingMode:_drawAmbientSounds]; }
- (IBAction)enableRandomSoundViewMode:(id)sender { [self setCurrentDrawingMode:_drawRandomSounds]; }
- (IBAction)enableLayerViewMode:(id)sender { [self setCurrentDrawingMode:_drawLayers]; }
- (IBAction)recalculateTheGrid:(id)sender { caculateTheGrid = YES; }

- (IBAction)renameSelectedPolygon:(id)sender
{
    if ([selectedPolys count] > 0)
    {
        NSEnumerator *numer;
        id thisPolygon;
        numer = [selectedPolys objectEnumerator];
        while (thisPolygon = [numer nextObject])
            [winController renamePolyWithSheet:thisPolygon];
    }
    else
        SEND_ERROR_MSG(@"Sorry, but you need to select a polygon first");
}

-(void)sendSelChangedNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LESelectionChangedNotification object:selections];
    UpdateLevelStatusBar();
}

// *************************** Standard Overridden Methods For Settings ***************************
#pragma mark -
#pragma mark ********* Standard Overridden Methods For Settings *********

- (BOOL)isFlipped { return YES; }
- (BOOL)isOpaque { return YES; }
- (BOOL)acceptsFirstResponder { return YES; }
- (BOOL)becomeFirstResponder { return YES; }

// jra hates this behavior; more legitimately, it's really annoying if the user
// can't instantly undo (which they can't)

// JDO: Make this user changeable...
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent { return YES; }

@end

    // **********************************
    // ********* obsolete stuff *********
    // **********************************
    
    //[textString drawAtPoint:NSMakePoint(100, 100)];

    
    //[NSBezierPath fillRect:NSMakeRect(x, y, 10, 10)];
    
    /*
    //NSLog(@"Called The DrawRect");
    
    //[[NSColor whiteColor] set];
   // NSRectFill(aRect);

    //numer = [rects objectEnumerator];
    //while (thisRect = [numer nextObject]) {
    //    if (NSIntersectsRect([thisRect frame], aRect)) {
    //        [thisRect drawRect:aRect selected:(thisRect == selectedItem)];
    //    }
   // }

    [[NSColor blackColor] set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(-1000.0, 0.0) toPoint:NSMakePoint(1000.0, 0.0)];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(0.0, -1000.0) toPoint:NSMakePoint(0.0, 1000.0)];
    
    // NEW NEW NEW NEW NEW NEW NEW NEW NEW //

    // Calculate where the ball should go.
    
    x = 10;//rect->origin.x + rect->size.width * RandFloat();
    y = 10;//rect->origin.x + rect->size.height * RandFloat();

    // Set the current colour to a random RGB value.

    //[[NSColor colorWithDeviceRed:RandFloat() green:RandFloat() blue:RandFloat() alpha:1.0] set];
    [[NSColor blackColor] set];

    // Now construct a bezier path for an circle and draw it.
    
    oval = [NSBezierPath bezierPath];
    [oval appendBezierPathWithOvalInRect:NSMakeRect(x, y, 10, 10)];
    [oval fill];

    // Now set the current colour to black and draw
    // the text centred in the ball.
    
    [[NSColor blackColor] set];
    //[textString drawAtPoint:NSMakePoint(x + kBallSize / 2 - textSize.width / 2,
    //  

    return;
    */
