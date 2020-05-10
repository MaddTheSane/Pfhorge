#import "PhTextureInspectorController.h"
#import "PhTextureRepository.h"
#import "LELevelData.h"

#include <stdio.h>
#include <errno.h>


#import "PhLineInspectorController.h"

//Document Class
#import "LEMap.h"

//View and Controller Classes...
#import "LELevelWindowController.h"
#import "LEMapDraw.h"
#import "PhPlatformSheetController.h"
#import "PhTextureInspectorController.h"
#import "PhLineInspectorController.h"

//Main Super Inspector Controller
#import "LEInspectorController.h"

//Data Classes...
#import "LELevelData.h"
#import "LEMapObject.h"
#import "LEMapPoint.h"
#import "LEPolygon.h"
#import "LELine.h"
#import "LESide.h"

//Other Classes...
#import "LEExtras.h"

@interface PhTextureInspectorController (private)

    - (void)setMenusTo:(NSMenu *)menu;
    - (void)setMenusToUseImages:(NSArray *)images;
    - (void)updateMenu:(NSPopUpButton *)menu withImages:(NSArray *)images;
    - (void)setupTextureUIWithSide:(LESide *)side enableTransparentTexture:(BOOL)lTransparentSide;
    - (void)addNumbersForMenu:(NSPopUpButton *)menu upTo:(int)maxItem;
    
@end

@implementation PhTextureInspectorController
    
- (id)init
{
    self = [super initWithWindow:textureMenuWindows];
    
    if (self == nil)
        return nil;
    
    currentEnvironment = -1;
    menusSetup = NO;
    
    basePolyRef = nil;
    baseSideRef = nil;
    
    curPImages = nil;
    curSImages = nil;
    curTImages = nil;
    curFImages = nil;
    curCImages = nil;
    
    return self;
}

- (void)dealloc
{
    basePolyRef = nil;
    baseSideRef = nil;
    
    [[self window] saveFrameUsingName:@"Inspector5"];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[self window] setFrameUsingName:@"Inspector5"];
    [self setWindowFrameAutosaveName:@"Inspector5"];
    [[self window] setFrameAutosaveName:@"Inspector5"];
    
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    
    basePolyRef = nil;
    baseSideRef = nil;
}

- (void)reset
{
    theCurrentLine = nil;
    cSide = nil;
    ccSide = nil;
    baseSideRef = nil;
    basePolyRef = nil;
}

- (void)setMenusToEnvironment:(int)code
{
    // This method for right now is no longer nessary...
    // I am redesining (again }:=>) some aspects of the texture inspector...
    
    currentEnvironment = code;
    
    return; 
    
    if (currentEnvironment != code)
    {
        PhTextureRepository *textures = [PhTextureRepository sharedTextureRepository];
        NSArray *images = [textures getTextureCollection:code];

        if (images != nil)
             [self setMenusToUseImages:images];
        else // Error if it gets to this point...
        {
                NSLog(@"Default, Enviroment Code=%d", code);
                [self setMenusToUseImages:nil];
        }
        
        fprintf(stderr, ".\n");
        
        currentEnvironment = code;
    }
    
    return;
}

- (void)updateTextureMenuContents
{
    if (menusSetup == NO)
    {
        //PhTextureRepository *textures = [PhTextureRepository sharedTextureRepository];
        NSLog(@"updateTextureMenuContents...");
        
        /*[self updateMenu:waterMenu withImages:[textures getTextureCollection:_water]];
        [self updateMenu:lavaMenu withImages:[textures getTextureCollection:_lava]];
        [self updateMenu:sewageMenu withImages:[textures getTextureCollection:_sewage]];
        [self updateMenu:jjaroMenu withImages:[textures getTextureCollection:_jjaro]];
        [self updateMenu:pfhorMenu withImages:[textures getTextureCollection:_pfhor]];*/
        
        [primaryTexture setPullsDown:NO];
        [[primaryTexture cell] setBezelStyle:NSBezelStyleRegularSquare];
        [[primaryTexture cell] setArrowPosition:NSPopUpArrowAtBottom];
        [[primaryTexture cell] setImagePosition:NSImageOnly];

        [secondaryTexture setPullsDown:NO];
        [[secondaryTexture cell] setBezelStyle:NSBezelStyleRegularSquare];
        [[secondaryTexture cell] setArrowPosition:NSPopUpArrowAtBottom];
        [[secondaryTexture cell] setImagePosition:NSImageOnly];

        [transparentTexture setPullsDown:NO];
        [[transparentTexture cell] setBezelStyle:NSBezelStyleRegularSquare];
        [[transparentTexture cell] setArrowPosition:NSPopUpArrowAtBottom];
        [[transparentTexture cell] setImagePosition:NSImageOnly];

        [ceilingTexture setPullsDown:NO];
        [[ceilingTexture cell] setBezelStyle:NSBezelStyleRegularSquare];
        [[ceilingTexture cell] setArrowPosition:NSPopUpArrowAtBottom];
        [[ceilingTexture cell] setImagePosition:NSImageOnly];

        [floorTexture setPullsDown:NO];
        [[floorTexture cell] setBezelStyle:NSBezelStyleRegularSquare];
        [[floorTexture cell] setArrowPosition:NSPopUpArrowAtBottom];
        [[floorTexture cell] setImagePosition:NSImageOnly];
    
        menusSetup = YES;
    }
}

- (void)setMenusTo:(NSMenu *)menu
{
    // This is a really early function that is 
    // no longer used...
    return;
    
    [primaryTexture setMenu:menu];
    [secondaryTexture setMenu:menu];
    [transparentTexture setMenu:menu];
    
    [ceilingTexture setMenu:menu];
    [floorTexture setMenu:menu];
}

- (void)setMenusToUseImages:(NSArray *)images
{
    // This should no longer be nessary to call, but just in case
    // I have decided to leave it able to function...
    // The updateMenu:withImages: function is used directly instead...
    
    //int count = [images count];
    
    [self updateMenu:primaryTexture withImages:images];
    [self updateMenu:secondaryTexture withImages:images];
    [self updateMenu:transparentTexture withImages:images];
    [self updateMenu:ceilingTexture withImages:images];
    [self updateMenu:floorTexture withImages:images];
    
    // SEND_ERROR_MSG(([NSString stringWithFormat:@"images Count: %d", count, nil]));
    
    //[self addNumbersForMenu:primaryTextureNums upTo:count];
    //[self addNumbersForMenu:secondaryTextureNums upTo:count];
    //[self addNumbersForMenu:transparentTextureNums upTo:count];
    //[self addNumbersForMenu:ceilingTextureNums upTo:count];
    //[self addNumbersForMenu:floorTextureNums upTo:count];
}

// - (NSArray *)collection:(int)collection

- (void)updateMenu:(NSPopUpButton *)menu withImages:(NSArray *)images
{
    NSEnumerator *numer;
    NSImage *image;
    id item;
    
    //fprintf(stderr, "Seting Up Menu Items: ");
    
    //NSArray *curPImages; // primay
    //NSArray *curSImages; // seconday
    //NSArray *curTImages; // transperent
    //NSArray *curFImages; // floor
    //NSArray *curCImages; // ceiling
    
    if (menu == primaryTexture)
    {
        if (curPImages == images)
            return;
        else
            curPImages = images;
    }
    else if (menu == secondaryTexture)
    {
        if (curSImages == images)
            return;
        else
            curSImages = images;
    }
    else if (menu == transparentTexture)
    {
        if (curTImages == images)
            return;
        else
            curTImages = images;
    }
    
    [menu removeAllItems];
    
    numer = [images objectEnumerator];
    while (image = [numer nextObject])
    {
        //fprintf(stderr, ".");
        [menu addItemWithTitle:@""];
        item = [menu lastItem];
        
        //item = [menu addItemWithTitle:@"" action:nil keyEquivalent:@""];
        [item setImage:image];
        [item setOnStateImage:nil];
        [item setMixedStateImage:nil];
    }
    // fprintf(stderr, ".");
}

- (void)updatePolyTextureMenus
{
    // NOTE: Check to make surereturned object is a polygon!
    LEPolygon *thePoly = [mainInspectorController getTheCurrentSelection];
    
    short ceilingTransferMode = [thePoly ceilingTransferMode];
    short floorTransferMode = [thePoly floorTransferMode];

    NSPoint ceilingOrigin = [thePoly ceilingOrigin];
    NSPoint floorOrigin = [thePoly floorOrigin];
    char floorTextureChar = [thePoly floorTextureOnly];
    char ceilingTextureChar = [thePoly ceilingTextureOnly];
    
    int fColl = [thePoly floorTextureCollectionOnly];
    int cColl = [thePoly ceilingTextureCollectionOnly];
    
    basePolyRef = thePoly;
    
    if (([ceilingMode numberOfItems] - 1) > ceilingTransferMode && ceilingTransferMode >= 0)
        [ceilingMode selectItemAtIndex:(ceilingTransferMode + 1)];
    else
        [ceilingMode selectItemAtIndex:-1];
    
    if (([floorMode numberOfItems] - 1) > floorTransferMode && floorTransferMode >= 0)
        [floorMode selectItemAtIndex:(floorTransferMode + 1)];
    else
        [floorMode selectItemAtIndex:-1];
    
    
    SetMatrixObjectValue(polyTextureOffsetMatrix, 1, ceilingOrigin.x);
    SetMatrixObjectValue(polyTextureOffsetMatrix, 2, ceilingOrigin.y);
    SetMatrixObjectValue(polyTextureOffsetMatrix, 3, floorOrigin.x);
    SetMatrixObjectValue(polyTextureOffsetMatrix, 4, floorOrigin.y);
    
    //[ceilingTextureMenu selectItemAtIndex:floorTexture];
    //[floorTextureMenu selectItemAtIndex:ceilingTexture];
    
    
    // Primary Texture Collection
    
    if (fColl < 0 || (fColl > 4 && fColl < 10) || fColl > 13)
    {
        NSLog(@"Collection Out Of Bounds For Floor of Polygon: %d", [thePoly index]);
        
        [floorTextureNums selectItemAtIndex:-1];
    }
    else
    {
        [self updateMenu:floorTexture withImages:[[PhTextureRepository sharedTextureRepository] collection:(fColl + 0x11)]];
        
        if (fColl > 4)
            [floorTextureNums selectItemAtIndex:(fColl - 5)];
        else
            [floorTextureNums selectItemAtIndex:fColl];
    }
    
    
    // Secondary Texture Collection
    
    if (cColl < 0 || (cColl > 4 && cColl < 10) || cColl > 13)
    {
        NSLog(@"Collection Out Of Bounds For Ceiling of Polygon: %d", [thePoly index]);
        
        [ceilingTextureNums selectItemAtIndex:-1];
    }
    else
    {
        [self updateMenu:ceilingTexture withImages:[[PhTextureRepository sharedTextureRepository] collection:(cColl + 0x11)]];
        
        if (cColl > 4)
            [ceilingTextureNums selectItemAtIndex:(cColl - 5)];
        else
            [ceilingTextureNums selectItemAtIndex:cColl];
    }
    
    
    // Floor Colletion Number Choosen
    
    if ([floorTexture numberOfItems] > floorTextureChar && floorTextureChar < 0)
        [floorTexture selectItemAtIndex:floorTextureChar];
    else
    {
        [self addNumbersForMenu:floorTexture upTo:(floorTextureChar + 1)];
        [floorTexture selectItemAtIndex:floorTextureChar];
    }
    
    
    // Ceiling Colletion Number Choosen
    
    if ([ceilingTexture numberOfItems] > ceilingTextureChar)
        [ceilingTexture selectItemAtIndex:ceilingTextureChar];
    else
    {
        [self addNumbersForMenu:ceilingTexture upTo:(ceilingTextureChar + 1)];
        [ceilingTexture selectItemAtIndex:ceilingTextureChar];
    }
        
    /*
    if ([floorTextureNums numberOfItems] > floorTextureChar)
        [floorTextureNums selectItemAtIndex:floorTextureChar];
    else
    {
        [self addNumbersForMenu:floorTextureNums upTo:(floorTextureChar + 1)];
        [floorTextureNums selectItemAtIndex:floorTextureChar];
    }
    
    if ([ceilingTextureNums numberOfItems] > ceilingTextureChar)
        [ceilingTextureNums selectItemAtIndex:ceilingTextureChar];
    else
    {
        [self addNumbersForMenu:ceilingTextureNums upTo:(ceilingTextureChar + 1)];
        [ceilingTextureNums selectItemAtIndex:ceilingTextureChar];
    }
    */
}

- (LESide *)currentBaseSideRef
{
    return baseSideRef;
}

- (void)updateLineTextureAndLightMenus
{
    // LELevelData *theLevelData = [mainInspectorController currentLevel];
    
    // NOTE: Check to make sure returned object is a LELine!
    LELine *theCurrentSelection = [mainInspectorController getTheCurrentSelection];
    BOOL lLandscape = NO;
    BOOL lTransparentSide = NO;
    
    unsigned short flags = 0;
    
    // Check to make sure that this is actually a LELine...
    theCurrentLine = theCurrentSelection;//[mainInspectorController getTheCurrentSelection];
    
    flags = [theCurrentSelection flags];
    
        // Cache the flags, to reduce call count...
        // Do I need these here?
    //lSolid 		= ([theCurrentSelection flags] & 0x4000);
    //lTransparent 	= ([theCurrentSelection flags] & 0x2000);
    
    lLandscape 		= ((flags & LANDSCAPE_LINE_BIT) ? YES : NO);
    lTransparentSide 	= ((flags & LINE_HAS_TRANSPARENT_SIDE_BIT) ? YES : NO);
    
        // Get the sides of the line...
    cSide = [theCurrentSelection clockwisePolygonSideObject];
    ccSide = [theCurrentSelection counterclockwisePolygonSideObject];
    //NSLog(((flags & LINE_HAS_TRANSPARENT_SIDE_BIT) ? @"TTRANSPARENT_SIDE: YES" : @"TTRANSPARENT_SIDE: NO"));
        // These are not managed by thie function...
    //[lineFlags deselectAllCells];
    //[emptyFlag setState:NSOffState];
    //[lineControlPanelFlags deselectAllCells];
    
        // Do I need these here?
    //if (lineFlagsNumber & SOLID_LINE_BIT)
    //    SelectS(lineFlags, 1);
    //if (lineFlagsNumber & TRANSPARENT_LINE_BIT)
     //   SelectS(lineFlags, 2);
     
    
    if (lLandscape == YES)
    {
        // SelectS(lineFlags, 3)
    }
    if (lTransparentSide == YES)
    { // Should Probably make another checkbox for this...
        // Might be useful for the user to set this manually...
        [transparentTextureCheckBox setState:NSOnState];
    }
    else
        [transparentTextureCheckBox setState:NSOffState];
    
    baseSideRef = nil;
    
    if (cSide == nil && ccSide == nil)
    {
        [self setupTextureUIWithSide:nil enableTransparentTexture:NO];
        baseSideRef = nil;
        [sideTextureRadioBtn setEnabledOfMatrixCellsTo:NO];
        [sideLightRadioBtn setEnabledOfMatrixCellsTo:NO];
        [sideControlRadioBtn setEnabledOfMatrixCellsTo:NO];
    }
    else if (cSide != nil && ccSide == nil)
    {
        [self setupTextureUIWithSide:cSide enableTransparentTexture:lTransparentSide];
        SelectS(sideTextureRadioBtn, _c_side_radio);
        SelectS(sideLightRadioBtn, _c_side_radio);
        SelectS(sideControlRadioBtn, _c_side_radio);
        [sideTextureRadioBtn setEnabledOfMatrixCellsTo:NO];
        [sideLightRadioBtn setEnabledOfMatrixCellsTo:NO];
        [sideControlRadioBtn setEnabledOfMatrixCellsTo:NO];
        baseSideRef = cSide;
    }
    else if (cSide == nil && ccSide != nil)
    {
        [self setupTextureUIWithSide:ccSide enableTransparentTexture:lTransparentSide];
        SelectS(sideTextureRadioBtn, _cc_side_radio);
        SelectS(sideLightRadioBtn, _cc_side_radio);
        SelectS(sideControlRadioBtn, _cc_side_radio);
        [sideTextureRadioBtn setEnabledOfMatrixCellsTo:NO];
        [sideLightRadioBtn setEnabledOfMatrixCellsTo:NO];
        [sideControlRadioBtn setEnabledOfMatrixCellsTo:NO];
        baseSideRef = ccSide;
    }
    else // if (cSide != nil && ccSide != nil)
    {
        [sideTextureRadioBtn setEnabledOfMatrixCellsTo:YES];
        [sideLightRadioBtn setEnabledOfMatrixCellsTo:YES];
        [sideControlRadioBtn setEnabledOfMatrixCellsTo:YES];
        
        if (GetTagOfSelected(sideTextureRadioBtn) == _cc_side_radio)
        {
            SelectS(sideLightRadioBtn, _cc_side_radio);
            SelectS(sideControlRadioBtn, _cc_side_radio);
            [self setupTextureUIWithSide:ccSide enableTransparentTexture:lTransparentSide];
            baseSideRef = ccSide;
        }
        else if (GetTagOfSelected(sideTextureRadioBtn) == _c_side_radio)
        {
            SelectS(sideLightRadioBtn, _c_side_radio);
            SelectS(sideControlRadioBtn, _c_side_radio);
            [self setupTextureUIWithSide:cSide enableTransparentTexture:lTransparentSide];
            baseSideRef = cSide;
        }
        else
        {
            SEND_ERROR_MSG_TITLE(@"Don't know which side to have inspector inspect", @"Please Report This Error");
            [self reset];
            [self setupTextureUIWithSide:nil enableTransparentTexture:NO];
            [sideTextureRadioBtn setEnabledOfMatrixCellsTo:NO];
            [sideLightRadioBtn setEnabledOfMatrixCellsTo:NO];
            [sideControlRadioBtn setEnabledOfMatrixCellsTo:NO];
            return;
        }
    }
    
    // GetTagOfSelected(radioMatrix);
}

- (void)setupTextureUIWithSide:(LESide *)side enableTransparentTexture:(BOOL)lTransparentSide
{
        /*
	_full_side,	// primary texture is mapped floor-to-ceiling
	_high_side, 	// primary texture is mapped on a panel coming down from the ceiling (implies 2 adjacent polygons)
	_low_side, 	// primary texture is mapped on a panel coming up from the floor (implies 2 adjacent polygons)
	_composite_side,// primary texture is mapped floor-to-ceiling, secondary texture is mapped into it (i.e., control panel)
	_split_side 	// primary texture is mapped onto a panel coming down from the ceiling,
                        // secondary texture is mapped on a panel coming up from the floor
        */
        
        // For Right Now...
        //[transparentTextureCheckBox setEnabled:NO];
        
        BOOL doPriT = YES;
        BOOL doSecT = YES;
        BOOL doTraT = YES;
        
        if (side != nil)
        {
            int sideType = [side type];
            
            if (sideType == _full_side || sideType == _high_side || sideType == _low_side)
            {
                [primaryTexture setEnabled:YES];
                [secondaryTexture setEnabled:NO];
                [primaryTextureNums setEnabled:YES];
                [secondaryTextureNums setEnabled:NO];
                [primaryLight setEnabled:YES];
                [secondaryLight setEnabled:NO];
            }
            else // if (sideType == _split_side || sideType == _composite_side)
            {
                [primaryTexture setEnabled:YES];
                [secondaryTexture setEnabled:YES];
                [primaryTextureNums setEnabled:YES];
                [secondaryTextureNums setEnabled:YES];
                [primaryLight setEnabled:YES];
                [secondaryLight setEnabled:YES];
            }
        }
        else // no side...
        {
            [primaryTexture setEnabled:NO];
            [primaryTextureNums setEnabled:NO];
            [transparentTexture setEnabled:NO];
            [transparentTextureNums setEnabled:NO];
            [secondaryTexture setEnabled:NO];
            [secondaryTextureNums setEnabled:NO];
            [sideTextureOffsetMatrix setEnabledOfMatrixCellsTo:NO];
            [primaryLight setEnabled:NO];
            [secondaryLight setEnabled:NO];
            [transparentLight setEnabled:NO];
            return;
        }
        
        if (lTransparentSide == YES)
        {
            [transparentTexture setEnabled:YES];
            [transparentTextureNums setEnabled:YES];
            [transparentLight setEnabled:YES];
        }
        else // No Transparent Side...
        {
            [transparentTexture setEnabled:NO];
            [transparentTextureNums setEnabled:NO];
            [transparentLight setEnabled:NO];
        }
        
        /*
        struct side_texture_definition primaryTex; 	//= [baseSideRef primaryTexture];
        struct side_texture_definition secondaryTex; 	//= [baseSideRef getSecondary_texture];
        struct side_texture_definition transparentTex; 	//= [baseSideRef getTransparent_texture];
        */
        
        // NOTE: Need to do caching below!!!
        
        // Update the texture offset fields...
        
        short pTransMode = [side getPrimary_transfer_mode];
        short sTransMode = [side getSecondary_transfer_mode];
        short tTransMode = [side getTransparent_transfer_mode];
        
        if (([primaryMode numberOfItems] - 1) > pTransMode && pTransMode >= 0)
            [primaryMode selectItemAtIndex:(pTransMode + 1)];
        else
            [primaryMode selectItemAtIndex:-1];
        
        if (([secondaryMode numberOfItems] - 1) > sTransMode && sTransMode >= 0)
            [secondaryMode selectItemAtIndex:(sTransMode + 1)];
        else
            [secondaryMode selectItemAtIndex:-1];
        
        if (([transparentMode numberOfItems] - 1) > tTransMode && tTransMode >= 0)
            [transparentMode selectItemAtIndex:(tTransMode + 1)];
        else
            [transparentMode selectItemAtIndex:-1];

        
        short pLight = [side getPrimary_lightsource_index];
        short sLight = [side getSecondary_lightsource_index];
        short tLight = [side getTransparent_lightsource_index];
        
        if ([primaryLight numberOfItems] > pLight && pLight >= 0)
            [primaryLight selectItemAtIndex:pLight];
        else
            [primaryLight selectItemAtIndex:-1];
        
        if ([secondaryLight numberOfItems] > sLight && sLight >= 0)
        {
            NSLog(@"Secondary Light Was Ok...");
            [secondaryLight selectItemAtIndex:sLight];
        }
        else
        {
			NSLog(@"Secondary Light was out of range: %d  num of items: %ld", sLight, (long)[secondaryLight numberOfItems]);
            [secondaryLight selectItemAtIndex:-1];
        }
        
        if ([transparentLight numberOfItems] > tLight && tLight >= 0)
            [transparentLight selectItemAtIndex:tLight];
        else
            [transparentLight selectItemAtIndex:-1];
        
        
        [sideTextureOffsetMatrix setEnabledOfMatrixCellsTo:YES];
        
        SetMatrixObjectValue(sideTextureOffsetMatrix, 1, [side getPrimary_texture].x0);
        SetMatrixObjectValue(sideTextureOffsetMatrix, 2, [side getPrimary_texture].y0);
        SetMatrixObjectValue(sideTextureOffsetMatrix, 3, [side getSecondary_texture].x0);
        SetMatrixObjectValue(sideTextureOffsetMatrix, 4, [side getSecondary_texture].y0);
        SetMatrixObjectValue(sideTextureOffsetMatrix, 5, [side getTransparent_texture].x0);
        SetMatrixObjectValue(sideTextureOffsetMatrix, 6, [side getTransparent_texture].y0);
        
        
        int pColl = [side primaryTextureCollection];
        int sColl = [side secondaryTextureCollection];
        int tColl = [side transparentTextureCollection];
        
        // Primary Texture Collection
        
        if (pColl < 0 || (pColl > 4 && pColl < 10) || pColl > 13)
        {
            NSLog(@"Collection Out Of Bounds For Primary of Side: %d  Line: %d...",
                    [side index], [side getLine_index]);
            
            [primaryTextureNums selectItemAtIndex:-1];
            doPriT = NO;
        }
        else
        {
            [self updateMenu:primaryTexture withImages:[[PhTextureRepository sharedTextureRepository] collection:(pColl + 0x11)]];
            
            if (pColl > 4)
                [primaryTextureNums selectItemAtIndex:(pColl - 5)];
            else
                [primaryTextureNums selectItemAtIndex:pColl];
        }
        
        // Secondary Texture Collection
        
        if (sColl < 0 || (sColl > 4 && sColl < 10) || sColl > 13)
        {
            NSLog(@"Collection Out Of Bounds For Secondary of Side: %d  Line: %d...",
                    [side index], [side getLine_index]);
            
            [secondaryTextureNums selectItemAtIndex:-1];
            doSecT = NO;
        }
        else
        {
            [self updateMenu:secondaryTexture withImages:[[PhTextureRepository sharedTextureRepository] collection:(sColl + 0x11)]];
            
            if (sColl > 4)
                [secondaryTextureNums selectItemAtIndex:(sColl - 5)];
            else
                [secondaryTextureNums selectItemAtIndex:sColl];
        }
        
        // Transparent Texture Collection
        
        if (tColl < 0 || (tColl > 4 && tColl < 10) || tColl > 13)
        {
            NSLog(@"Collection Out Of Bounds For Transperent of Side: %d  Line: %d...",
                    [side index], [side getLine_index]);
            
            [transparentTextureNums selectItemAtIndex:-1];
            doTraT = NO;
        }
        else
        {
            [self updateMenu:transparentTexture withImages:[[PhTextureRepository sharedTextureRepository] collection:(tColl + 0x11)]];
            
            if (tColl > 4)
                [transparentTextureNums selectItemAtIndex:(tColl - 5)];
            else
                [transparentTextureNums selectItemAtIndex:tColl];
        }
        
        //Update texture menus...
        // In the future, instead of setting them to -1
        //   if the texture is out of range, numbers in them after the images...
        
        if ([primaryTexture numberOfItems] > [side primaryTexture] && doPriT == YES)
            [primaryTexture selectItemAtIndex:[side primaryTexture]];
        else
        {
            [self addNumbersForMenu:primaryTexture upTo:([side primaryTexture] + 1)];
            [primaryTexture selectItemAtIndex:[side primaryTexture]];
        }
        
        if ([secondaryTexture numberOfItems] > [side secondaryTexture] && doSecT == YES)
            [secondaryTexture selectItemAtIndex:[side secondaryTexture]];
        else
        {
            [self addNumbersForMenu:secondaryTexture upTo:([side secondaryTexture] + 1)];
            [secondaryTexture selectItemAtIndex:[side secondaryTexture]];
        }
        
        if (/*lTransparentSide == YES &&*/ [transparentTexture numberOfItems] > [side transparentTexture] && doTraT == YES)
            [transparentTexture selectItemAtIndex:[side transparentTexture]];
        else// if (lTransparentSide == YES)
        {
            [self addNumbersForMenu:transparentTexture upTo:([side transparentTexture] + 1)];
            [transparentTexture selectItemAtIndex:[side transparentTexture]];
        }
}

- (void)addNumbersForMenu:(NSPopUpButton *)menu upTo:(int)maxItem
{
    NSInteger i;
    NSInteger numberOfItems = [menu numberOfItems];
    
    // Remember, Max Is NOT zero based based...
    // but the menu is, 20 max items would be zero to 19 numbers...
    
    for (i = numberOfItems; i < maxItem; i++)
        [menu addItemWithTitle:stringFromInteger(i)];
}

// ************************* Actions - Side *************************
#pragma mark -
#pragma mark ••••••••• Actions - Side •••••••••

- (IBAction)primaryTextureMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    [baseSideRef setPrimaryTexture:number];
    [self updateLineTextureAndLightMenus];
}

- (IBAction)secondaryTextureMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    [baseSideRef setSecondaryTexture:number];
    [self updateLineTextureAndLightMenus];
}

- (IBAction)transparentTextureMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    [baseSideRef setTransparentTexture:number];
    [self updateLineTextureAndLightMenus];
}

- (IBAction)primaryTextureCollectionMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    
    if (number < 0)
        return;
    
    if (number > 4)
	{
        number += 5;
		[baseSideRef setPrimaryTexture:0];
	}
    
    [baseSideRef setPrimaryTextureCollection:number];
    [self updateLineTextureAndLightMenus];
}

- (IBAction)secondaryTextureCollectionMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    
    if (number < 0)
        return;
    
    if (number > 4)
	{
        number += 5;
		[baseSideRef setSecondaryTexture:0];
	}
    
    [baseSideRef setSecondaryTextureCollection:number];
    [self updateLineTextureAndLightMenus];
}

- (IBAction)transparentTextureCollectionMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    
    if (number < 0)
        return;
    
    if (number > 4)
	{
        number += 5;
		[baseSideRef setTransparentTexture:0];
	}
    
    [baseSideRef setTransparentTextureCollection:number];
    [self updateLineTextureAndLightMenus];
}

- (IBAction)primaryModeMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    
    if (number > 0)
        [baseSideRef setPrimary_transfer_mode:(number - 1)];
    else
        [self updateLineTextureAndLightMenus];
}

- (IBAction)secondaryModeMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    
    if (number > 0)
        [baseSideRef setSecondary_transfer_mode:(number - 1)];
    else
        [self updateLineTextureAndLightMenus];
}

- (IBAction)transparentModeMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    
    if (number > 0)
        [baseSideRef setTransparent_transfer_mode:(number - 1)];
    else
        [self updateLineTextureAndLightMenus];
}

- (IBAction)sideTextureOffsetMatrixAction:(id)sender
{
	struct side_texture_definition thePTex = {0};
    struct side_texture_definition theSTex;
    struct side_texture_definition theTTex;
    
    char *theTexChar = NULL;
    short theCurrentEnviroCode = [[mainInspectorController currentLevel] environmentCode];
    
    theTexChar = (char *)&thePTex.texture;
    thePTex.x0 = GetMatrixIntValue(sideTextureOffsetMatrix, 1);
    thePTex.y0 = GetMatrixIntValue(sideTextureOffsetMatrix, 2);
    (theTexChar)[0] = (0x11 + theCurrentEnviroCode);
    (theTexChar)[1] = (char)([primaryTextureNums indexOfSelectedItem]);
    thePTex.textureNumber = [primaryTextureNums indexOfSelectedItem];
    [baseSideRef setPrimaryTextureStruct:thePTex];
    
    theTexChar = (char *)&theSTex.texture;
    theSTex.x0 = GetMatrixIntValue(sideTextureOffsetMatrix, 3);
    theSTex.y0 = GetMatrixIntValue(sideTextureOffsetMatrix, 4);
    (theTexChar)[0] = (0x11 + theCurrentEnviroCode);
    (theTexChar)[1] = (char)([secondaryTextureNums indexOfSelectedItem]);
    theSTex.textureNumber = [secondaryTextureNums indexOfSelectedItem];
    [baseSideRef setSecondaryTextureStruct:theSTex];
    
    theTexChar = (char *)&theTTex.texture;
    theTTex.x0 = GetMatrixIntValue(sideTextureOffsetMatrix, 5);
    theTTex.y0 = GetMatrixIntValue(sideTextureOffsetMatrix, 6);
    (theTexChar)[0] = (0x11 + theCurrentEnviroCode);
    (theTexChar)[1] = (char)([transparentTextureNums indexOfSelectedItem]);
    theTTex.textureNumber = [transparentTextureNums indexOfSelectedItem];
    [baseSideRef setTransparentTextureStruct:theTTex];
}

- (IBAction)sideRadioBtnAction:(id)sender
{
    [lineInspectorController updateLineInterface];
}

- (IBAction)sideExtraRadioBtnAction:(id)sender
{
    SelectS(sideTextureRadioBtn, GetTagOfSelected(sender));
    [lineInspectorController updateLineInterface];
}

- (IBAction)sideTransparencyCheckBoxAction:(id)sender
{
    BOOL checkBoxState = (([sender state] == NSOnState) ? YES : NO);// NSOffState NSOnState
    unsigned short flags = [theCurrentLine flags];
    //((flags & LINE_HAS_TRANSPARENT_SIDE_BIT) ? YES : NO);
    
    // GET_SELF_FLAG(LINE_HAS_TRANSPARENT_SIDE_BIT);
    
    // this uses the flags unsigned short above...
    SET_SELF_FLAG(LINE_HAS_TRANSPARENT_SIDE_BIT, checkBoxState);
    
    //((checkBoxState) ? (flags |= (LINE_HAS_TRANSPARENT_SIDE_BIT)) : (flags &= ~(LINE_HAS_TRANSPARENT_SIDE_BIT));
    
    [theCurrentLine setFlags:flags];
    
    [self updateLineTextureAndLightMenus];
}

#pragma mark -
// ********** Side Lights **********
#pragma mark ••••••••• Side Lights •••••••••

- (IBAction)primaryLightAction:(id)sender
{
    [baseSideRef  setPrimary_lightsource_index:[sender indexOfSelectedItem]];
}

- (IBAction)secondaryLightAction:(id)sender
{
    [baseSideRef  setSecondary_lightsource_index:[sender indexOfSelectedItem]];
}

- (IBAction)transparentLightAction:(id)sender
{
    [baseSideRef  setTransparent_lightsource_index:[sender indexOfSelectedItem]];
}


// ************************* Actions - Polygon *************************
#pragma mark -
#pragma mark ••••••••• Actions - Polygon •••••••••


// The Enviroment Codes and Wall Collection Numbers...
    /*
    _water_collection
    _lava_collection
    _sewage_collection
    _jjaro_collection
    _pfhor_collection
    */

- (IBAction)ceilingTextureMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[basePolyRef resetTextureCollectionOnly];
    [basePolyRef setCeilingTextureOnly:number];
    [self updatePolyTextureMenus];
}

- (IBAction)floorTextureMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[basePolyRef resetTextureCollectionOnly];
    [basePolyRef setFloorTextureOnly:number];
    [self updatePolyTextureMenus];
}

- (IBAction)ceilingTextureCollectionMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    
    if (number < 0)
        return;
    
    if (number > 4)
        number += 5;
    
    [basePolyRef setCeilingTextureCollectionOnly:number];
    [self updatePolyTextureMenus];
}

- (IBAction)floorTextureCollectionMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[baseSideRef resetTextureCollection];
    
    if (number < 0)
        return;
    
    if (number > 4)
        number += 5;
    
    [basePolyRef setFloorTextureCollectionOnly:number];
    [self updatePolyTextureMenus];
}

- (IBAction)ceilingModeMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[basePolyRef resetTextureCollectionOnly];
    [basePolyRef setCeilingTransferMode:(number - 1)];
}

- (IBAction)floorModeMenuAction:(id)sender
{
    char number = [sender indexOfSelectedItem];
    //[basePolyRef resetTextureCollectionOnly];
    [basePolyRef setFloorTransferMode:(number - 1)];
}

- (IBAction)polyTextureOffsetMatrixAction:(id)sender
{
    //LEPolygon *thePoly = [mainInspectorController getTheCurrentSelection];
    NSPoint theNewFloorOrigin, theNewCeilingOrigin;
    
    theNewFloorOrigin.x = GetMatrixIntValue(sender, 3);
    theNewFloorOrigin.y = GetMatrixIntValue(sender, 4);
    
    theNewCeilingOrigin.x = GetMatrixIntValue(sender, 1);
    theNewCeilingOrigin.y = GetMatrixIntValue(sender, 2);
    
    [basePolyRef setCeilingOrigin:theNewCeilingOrigin];
    [basePolyRef setFloorOrigin:theNewFloorOrigin];
}

@end
