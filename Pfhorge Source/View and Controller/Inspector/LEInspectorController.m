//
//  LEInspectorController.m
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

#import "LEInspectorController.h"

//Document Class
#import "LEMap.h"

//View and Controller Classes...
#import "LELevelWindowController.h"
#import "LEMapDraw.h"
#import "PhPlatformSheetController.h"
//Sub Controller Classes...
#import "PhLineInspectorController.h"
#import "PhPolyInspectorController.h"
#import "PhObjectInspectorSubController.h"
#import "PhTextureInspectorController.h"

//Data Classes...
#import "LELevelData.h"
#import "LEMapObject.h"
#import "LEMapPoint.h"
#import "LEPolygon.h"
#import "LELine.h"
#import "LESide.h"

#import "PhTextureRepository.h"

//Other Classes...
#import "LEExtras.h"

@implementation LEInspectorController
//LESelectionChangedNotification

// *********************** Overridden Methods ***********************
#pragma mark -
#pragma mark ••••••••• Overridden Methods •••••••••

- (id)init
{
    self = [super initWithWindowNibName:@"Inspector"];
    //[self setWindowFrameAutosaveName:@"Inspector1"];
    [self window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(levelDeallocating:)
                                          name:PhLevelDeallocatingNotification
                                          object:nil];
    return self;
}

- (void)dealloc
{
    [[self window] saveFrameUsingName:@"Inspector1"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)windowDidLoad
{
    //NSMenuItem *item;
    //NSDictionary *theTextures = (NSDictionary *)[[PhTextureRepository sharedTextureRepository] getTextureCollection:0];
    //NSEnumerator *enumerator;
    //id value;
    //int count = 0;

    [super windowDidLoad];
    
    [[self window] setFrameUsingName:@"Inspector1"];
    [self setWindowFrameAutosaveName:@"Inspector1"];
    [[self window] setFrameAutosaveName:@"Inspector1"];
    
    [self setMainWindow:[NSApp mainWindow]];
    
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllPhNameData:)
        name:PhUserDidChangeNames object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowChanged:) 	name:NSWindowDidBecomeMainNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainWindowResigned:) 	name:NSWindowDidResignMainNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) 	name:LESelectionChangedNotification object:nil];
    
    [theMainTabMenu selectTabViewItemAtIndex:3];
    
    // Load textures into experemental Menu...
    // Using the IBOutlet lineTextureExp
    
    // Image popup Using IBOutlet...
    //lineTextureExp = [lineTextureExp initWithFrame:NSMakeRect(20.0, 150.0, 42.0, 42.0) pullsDown:NO];
    
    /**************************************************
    [[lineTextureExp cell] setBezelStyle:0];
    [[lineTextureExp cell] setArrowPosition:0];
    
    enumerator = [theTextures objectEnumerator];
    while ((value = [enumerator nextObject]))
    {
        [lineTextureExp addItemWithTitle:@""];
        item = [lineTextureExp itemAtIndex:count];
        [item setImage:value];
        [item setOnStateImage:nil];
        [item setMixedStateImage:nil];
        count++;
    }
    
    [lineTextureExp calcSize];

    [[[lineTextureExp menu] menuRepresentation] setHorizontalEdgePadding:0.0];
    **************************************************/
    
    //[lineTextureExp sizeToFit];
    //[contentView addSubview:lineTextureExp];
    
    //[self selectionChanged:nil];
    if (currentLevelDrawView != nil)
        [currentLevelDrawView sendSelChangedNotification];
    else
        [self selectionChanged:nil];
}

// *********************** Class Methods ***********************
#pragma mark -
#pragma mark ••••••••• Class Methods •••••••••

+ (id)sharedInspectorController {
    static LEInspectorController *sharedInspectorController = nil;

    if (!sharedInspectorController) {
        sharedInspectorController = [[LEInspectorController allocWithZone:[self zone]] init];
    }

    return sharedInspectorController;
}

// *********************** Other Methods ***********************
#pragma mark -
#pragma mark ••••••••• Other Methods •••••••••

- (void)setMainWindow:(NSWindow *)mainWindow {
    NSWindowController *controller = [mainWindow windowController];
    //[mainWindow close];
    //return;
    
    [self reset];
    
    if (controller && [controller isKindOfClass:[LELevelWindowController class]]) {
        currentLevelDocument = [(LELevelWindowController *)controller document];
        currentLevelDrawView = [(LELevelWindowController *)controller levelDrawView];
        currentLevel = [currentLevelDocument getCurrentLevelLoaded];
        currentMainWindowController = (LELevelWindowController *)controller;
       // NSLog(@"Calling...");
        [textureInspectorWindowController setMenusToEnvironment:[currentLevel environmentCode]];
        
    } else {
        currentLevelDocument = nil;
        currentLevelDrawView = nil;
        currentLevel = nil;
        currentMainWindowController = nil;
    }
    [self updateComboMenus];
}

// *********************** Notifcations ***********************
#pragma mark -
#pragma mark ••••••••• Notifcations •••••••••

- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    [self reset];
    
    if (currentLevel == levelDataObjectDeallocating)
    {
        currentLevelDocument = nil;
        currentLevelDrawView = nil;
        currentLevel = nil;
        currentMainWindowController = nil;
        [self updateComboMenus];
    }
}


- (void)mainWindowChanged:(NSNotification *)notification {
    ///NSLog(@"NSWindowDidBecomeMainNotification");
    [self reset];
    [self setMainWindow:[notification object]];
    [currentLevelDrawView sendSelChangedNotification];
}

- (void)mainWindowResigned:(NSNotification *)notification {
    ///NSLog(@"NSWindowDidResignMainNotification");
    [self reset];
    [self setTabMenusTo:3];
    [self setMainWindow:nil];
}

- (void)reloadAllPhNameData:(NSNotification *)notification {
    //NSLog(@"PhUserDidChangeNames Notification");
    [self updateComboMenus];
    ///[self selectionChanged:nil];
}

- (void)selectionChanged:(NSNotification *)notification
{
    NSArray *theSelections = nil;
    id theObject = [notification object];
    id tmpSelection = nil;
    
    [self reset];
    
    [textureInspectorWindowController updateTextureMenuContents];
    
    if (notification != nil)
    {
        if (theObject == nil)
        {
            notification = nil;
        }
        else
        {
            if ([theObject isKindOfClass:[NSSet class]])
            {
                
            }
            else
            {
                NSLog(@"The Notification Did Not Have A NSSet!");
                SEND_ERROR_MSG(@"The - (void)selectionChanged:(NSNotification *)notification Did Not Have A NSSet!");
                [self setTabMenusTo:3];
                theCurrentSelection = nil;
                return;
                //[self setMainWindow:nil];
            }
            
            if ([theObject count] > 0)
                theSelections = [theObject allObjects];
            else
            {
                [self setTabMenusTo:3];
                theCurrentSelection = nil;
                return;
            }
            
            tmpSelection = [theSelections objectAtIndex:0];
        }
        
    }
    /*else // bascialy: (notification == nil)
    {
        // Nothing To Do Here Yet, But In The Future...
        ///theCurrentSelection = nil;
    }*/
    
    if (notification == nil || tmpSelection == nil) {
    
        [self setTabMenusTo:3];
        theCurrentSelection = nil;
        return;
        
    } else if ([tmpSelection isKindOfClass:[LEMapPoint class]]) {
    
        [self setTabMenusTo:3];
        theCurrentSelection = nil;
        return;
        
    } else if ([tmpSelection isKindOfClass:[LELine class]]) {
    
        [self setTabMenusTo:0];
        theCurrentSelection = tmpSelection;
        [lineSubController updateLineInterface];
        
    } else if ([tmpSelection isKindOfClass:[LEPolygon class]]) {
    
        [self setTabMenusTo:1];
        theCurrentSelection = tmpSelection;
        [polySubController updateInterface];
        
    } else if ([tmpSelection isKindOfClass:[LEMapObject class]]) {
    
        [self setTabMenusTo:2];
        theCurrentSelection = tmpSelection;
        [objectSubController updateInterface];
        
    } else {
    
        [self setTabMenusTo:3];
        theCurrentSelection = nil;
        return;
        
    }
    
    return;
}

- (void)updateInterfaces
{
    [self reset];
    
    [textureInspectorWindowController updateTextureMenuContents];
        
    if (theCurrentSelection == nil) {
    
        [self setTabMenusTo:3];
        theCurrentSelection = nil;
        return;
        
    } else if ([theCurrentSelection isKindOfClass:[LEMapPoint class]]) {
    
        [self setTabMenusTo:3];
        theCurrentSelection = nil;
        return;
        
    } else if ([theCurrentSelection isKindOfClass:[LELine class]]) {
    
        [self setTabMenusTo:0];
        [lineSubController updateLineInterface];
        
    } else if ([theCurrentSelection isKindOfClass:[LEPolygon class]]) {
    
        [self setTabMenusTo:1];
        [polySubController updateInterface];
        
    } else if ([theCurrentSelection isKindOfClass:[LEMapObject class]]) {
    
        [self setTabMenusTo:2];
        [objectSubController updateInterface];
        
    } else {
    
        [self setTabMenusTo:3];
        theCurrentSelection = nil;
        return;
        
    }
    
    return;
}

// *********************** Updater Methods ***********************
#pragma mark -
#pragma mark ••••••••• Updater Methods •••••••••

- (void)reset
{
    [lineSubController reset];
    [polySubController reset];
    [objectSubController reset];
    [textureInspectorWindowController reset];
}

-(void)updateComboMenus
{
    [linePrimaryLight removeAllItems];
    [lineSecondaryLight removeAllItems];
    [lineTransparentLight removeAllItems];
    
    [polyAmbientSound removeAllItems];
    [polyCeilingLight removeAllItems];
    [polyFloorLight removeAllItems];
    [polyLiquid removeAllItems];
    [polyLiquidLight removeAllItems];
    [polyRandomSound removeAllItems];
    
    if (currentLevel != nil)
    {
        NSArray *theCurrentLevelLightNames;
    
        theCurrentLevelLightNames = [currentLevel getLightNamesCopy];
        
        //NOTE: The NSArrays may not get released when you call the methods
        //	to get the arrays directly in the messages!!! Check This Out!!!
        
        [linePrimaryLight addItemsWithTitles:theCurrentLevelLightNames];
        [lineSecondaryLight addItemsWithTitles:theCurrentLevelLightNames];
        [lineTransparentLight addItemsWithTitles:theCurrentLevelLightNames];
        
        [polyAmbientSound addItemWithObjectValue:@"None"];
        [polyAmbientSound addItemsWithObjectValues:[currentLevel getAmbientSoundNamesCopy]];
        
        [polyCeilingLight addItemsWithTitles:theCurrentLevelLightNames];
        [polyFloorLight addItemsWithTitles:theCurrentLevelLightNames];
        
        [polyLiquid addItemWithObjectValue:@"None"];
        [polyLiquid addItemsWithObjectValues:[currentLevel getLiquidNamesCopy]];
        
        [polyLiquidLight addItemsWithTitles:theCurrentLevelLightNames];
        
        [polyRandomSound addItemWithObjectValue:@"None"];
        [polyRandomSound addItemsWithObjectValues:[currentLevel getRandomSoundNamesCopy]];
        
        //[theCurrentLevelLightNames release];
    }
}

// *********************** Utilites ***********************
#pragma mark -
#pragma mark ••••••••• Utilites •••••••••

-(void)setTabMenusTo:(int)tabViewIndex
{
    [generalTabMenu selectTabViewItemAtIndex:tabViewIndex];
    [controlPanelTabMenu selectTabViewItemAtIndex:tabViewIndex];
    [lightsTabMenu selectTabViewItemAtIndex:tabViewIndex];
    [texturesTabMenu selectTabViewItemAtIndex:tabViewIndex];
    [textureInspectorWindowTabMenu selectTabViewItemAtIndex:tabViewIndex];
}


// *********************** Actions ***********************
#pragma mark -
#pragma mark ••••••••• Actions •••••••••

-(IBAction)polySectionChanged:(id)sender
{ // Need to add action and set it up in IB!!!

}

-(IBAction)lineSectionChanged:(id)sender
{ // Need to add action and set it up in IB!!!

}

-(IBAction)objSectionChanged:(id)sender
{ // Need to add action and set it up in IB!!!

}

//    IBOutlet id lineSubController;
//    IBOutlet id polySubController;
//    IBOutlet id objectSubController;

- (IBAction)showControlPanelWindow:(id)sender
{
    [self showWindow:sender];
}

- (IBAction)showLightWindow:(id)sender {
    //[lightsWindow setFrameTopLeftPoint:NSMakePoint(100,100)];
    [lineSubController showWindow:sender];
}

- (IBAction)showGeneralPropertiesWindow:(id)sender
{
    [objectSubController showWindow:sender];
}

- (IBAction)showTextureWindow:(id)sender
{
    [textureInspectorWindowController showWindow:sender];
    /*[polySubController showWindow:sender];*/
}


// *********************** Accsessors ***********************
#pragma mark -
#pragma mark ••••••••• Accsessors •••••••••

-(id)getTheCurrentSelection { return theCurrentSelection; }
-(LELevelData *)currentLevel { return currentLevel; }
-(LEMapDraw *)getTheCurrentLevelDrawView { return currentLevelDrawView; }

@end
