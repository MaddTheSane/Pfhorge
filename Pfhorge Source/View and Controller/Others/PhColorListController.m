//
//  PhColorListController.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 10 2001.
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

#import "PhColorListController.h"

//Document Class
#import "LEMap.h"

//View and Controller Classes...
#import "LELevelWindowController.h"
#import "LEMapDraw.h"
#import "PhPlatformSheetController.h"

//Data Classes...
#import "LELevelData.h"
#import "LEMapObject.h"
#import "LEMapPoint.h"
#import "LEPolygon.h"
#import "LELine.h"
#import "LESide.h"

#import "PhLayer.h"
#import "PhAmbientSound.h"
#import "PhRandomSound.h"
#import "PhMedia.h"
#import "PhLight.h"

//Other Classes...
#import "LEExtras.h"



//[theLevelDataObject addObjectWithDefaults:[PhLight class]]; 


@implementation PhColorListController

//LESelectionChangedNotification

// *********************** Overridden Methods ***********************

- (id)init
{
    self = [super initWithWindowNibName:@"ColorList"];
    
    if (self == nil)
        return nil;
    
    [self setWindowFrameAutosaveName:@"ColorListWindow"];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([friend respondsToSelector:[invocation selector]])
        [invocation invokeWithTarget:friend];
    else
        [self doesNotRecognizeSelector:aSelector];
}
*/

- (IBAction)redrawEverything:(id)sender { [currentLevelDrawView setNeedsDisplay:YES]; }

- (IBAction)setDrawModeToNormal:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeNormal]; }
- (IBAction)setDrawModeToCeilingHeight:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeCeilingHeight]; }
- (IBAction)enableFloorHeightViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeFloorHeight]; }
- (IBAction)enableLiquidViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeLiquids]; }
- (IBAction)enableFloorLightViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeFloorLights]; }
- (IBAction)enableCeilingLightViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeCeilingLights]; }
- (IBAction)enableLiquidLightViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeLiquidLights]; }
- (IBAction)enableAmbientSoundViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeAmbientSounds]; }
- (IBAction)enableRandomSoundViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeRandomSounds]; }
- (IBAction)enableLayerViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:LEMapDrawingModeLayers]; }

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    [self setMainWindow:[NSApp mainWindow]];
    
    [(NSPanel *)[self window] setFloatingPanel:YES];
    //[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainWindowChanged:)
                                                 name:NSWindowDidBecomeMainNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainWindowResigned:)
                                                 name:NSWindowDidResignMainNotification
                                               object:nil];
    
    [[[[colorListTable tableColumns] objectAtIndex:0] dataCell]
     setDrawsBackground:YES];
    
    [[[[colorListTable tableColumns] objectAtIndex:0] dataCell]
     setEditable:YES];
}

// *********************** Class Methods ***********************
+ (id)sharedColorListController {
    static PhColorListController *sharedColorListController = nil;
    
    if (!sharedColorListController) {
        sharedColorListController = [[PhColorListController alloc] init];
    }
    
    return sharedColorListController;
}

// *********************** Action Methods ***********************
- (IBAction)createNewHeightSheetBtn:(id)sender
{
    [currentLevelDrawView addNewHeight:[NSNumber numberWithShort:((short)[newHeightTextBox intValue])]];
    [self updateInterface:currentLevelDrawView];
    
    newHeightSheetOpen = NO;
    [currentLevelDrawView setNewHeightSheetOpen:NO];
    [newHeightWindowSheet orderOut:nil];
    [self.window endSheet:newHeightWindowSheet];
    [colorListTable reloadData];
}

- (IBAction)cancelNewHeightSheetBtn:(id)sender
{
    newHeightSheetOpen = NO;
    [currentLevelDrawView setNewHeightSheetOpen:NO];
    [newHeightWindowSheet orderOut:nil];
    [self.window endSheet:newHeightWindowSheet];
}

// *********************** Other Methods ***********************
- (void)setMainWindow:(NSWindow *)mainWindow {
    NSWindowController *controller = (id)[mainWindow delegate];
    //[mainWindow close];
    //return;
    
    if (controller && [controller isKindOfClass:[LELevelWindowController class]]) {
        /// NSLog(@"1");
        currentLevelDocument = [(LELevelWindowController *)controller document];
        currentLevelDrawView = [(LELevelWindowController *)controller levelDrawView];
        currentLevel = [currentLevelDocument getCurrentLevelLoaded];
        currentMainWindowController = (LELevelWindowController *)controller;
        [(NSWindow *)[self window] orderFront:self];
        [self updateInterface:currentLevelDrawView];
        [drawerObject setNextResponder:currentLevelDrawView];
    } else if (controller != nil && [controller isKindOfClass:[PhColorListController class]]) {
        /// NSLog(@"2");
        return;
    } else {
        /// NSLog(@"3");
        currentLevelDocument = nil;
        currentLevelDrawView = nil;
        currentLevel = nil;
        currentMainWindowController = nil;
        [(NSWindow *)[self window] orderOut:self];
        [self cancelNewHeightSheetBtn:nil];
        [self updateInterface:currentLevelDrawView];
    }
}

- (void)updateInterfaceIfLevelDataSame:(LELevelData *)levdata
{
    if (currentLevel == nil)
        return;
    
    if (currentLevel == levdata) {
        [self updateInterface:currentLevelDrawView];
    }
}

// *********************** Notifcations ***********************

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    //int theSelectedRow = [self selectedRow];
    
}

- (void)mainWindowChanged:(NSNotification *)notification {
    //NSLog(@"NSWindowDidBecomeMainNotification");
    [self setMainWindow:[notification object]];
    //[currentLevelDrawView sendSelChangedNotification];
}

- (void)mainWindowResigned:(NSNotification *)notification {
    //NSLog(@"NSWindowDidResignMainNotification");
    [self setMainWindow:nil];
}

// *********************** Updater Methods ***********************

- (NSInteger)getSelection { return [colorListTable selectedRow] - 1; }

- (NSNumber *)getSelectedNumber
{
    if ([self getSelection] < 0) {
        return nil;
    } else {
        return [[numbers objectAtIndex:[self getSelection]] copy];
    }
}

- (void)setSelectionToNumber:(NSNumber *)theNumberToSelect
{
    NSInteger selectNumber = ([numbers indexOfObject:theNumberToSelect] + 1);
    
    [colorListTable scrollRowToVisible:selectNumber];
    [colorListTable selectRowIndexes:[NSIndexSet indexSetWithIndex:selectNumber] byExtendingSelection:NO];
}

-(void)updateInterface:(LEMapDraw *)theView
{
    NSMutableString *levelInfoString = nil;
    
    if (currentLevelDrawView == nil) {
        /*if (numbers != nil)
            [numbers release];
        if (colors != nil)
            [colors release];*/
        numbers = nil;
        colors = nil;
        names = nil;
        objs = nil;
        
        if (newHeightSheetOpen)
            [self cancelNewHeightSheetBtn:nil];
        
        //NSLog(@"updateInterface nil");
    } else {
        if ([currentLevelDrawView newHeightSheetOpen]) {
            if (!newHeightSheetOpen) {
                [[self window] beginSheet:newHeightWindowSheet completionHandler:^(NSModalResponse returnCode) {
                    
                }];
                
                newHeightSheetOpen = YES;
            }
        }
        
        numbers = [currentLevelDrawView numberList];
        colors = [currentLevelDrawView colorList];
        names = [currentLevelDrawView nameList];
        objs = [currentLevelDrawView tableObjectList];
        
        levelInfoString = [[NSMutableString alloc] initWithString:
                           [[NSNumber numberWithInteger:[numbers count]] stringValue]];
        [levelInfoString appendString:@" Listed"];
        [status setStringValue:levelInfoString];
        
        if (numbers == nil || colors == nil) {
            [[self window] orderOut:self];
            //return;
        }
        //[numbers retain];
        //[colors retain];
        //NSLog(@"updateInterface != nil");
        /// NSLog(@"Numbers Array Count: %d and Colors Array Count: %d, if these are not equal, ERROR!", [numbers count], [colors count]);
        if ([numbers count] != [colors count]) {
            NSLog(@"ERROR: Numbers array count and colors array count are not equal: (Numbers: %lu Colors: %lu)", (unsigned long)[numbers count], (unsigned long)[colors count]);
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
            alert.informativeText = NSLocalizedString(@"Numbers array count and colors array count are not equal (check console for more details), ERROR!", @"Numbers array count and colors array count are not equal (check console for more details), ERROR!");
            alert.alertStyle = NSAlertStyleCritical;
            [alert runModal];
        }
    }
    
    [colorListTable reloadData];
}

// *********************** Table Updater Methods ***********************

- (void)tableView:(NSTableView *)view
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)col
              row:(NSInteger)row
{
    if (row == 0) {
        [cell setBackgroundColor:[NSColor whiteColor]];
    } else {
        [cell setBackgroundColor:[colors objectAtIndex:(row - 1)]];
    }
    //[cell setForegroundColor: [colors objectAtIndex:row]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)view
{
    return [names count] + 1;
}

- (id)tableView:(NSTableView *)view
objectValueForTableColumn:(NSTableColumn *)col
            row:(NSInteger)row
{
    if (row == 0)
        return @"Double Click For New";
   /// NSLog(@"objAtIndex: %d", row);
    return [names objectAtIndex:(row - 1)];
}

- (BOOL)tableView:(NSTableView *)aTableView
shouldEditTableColumn:(NSTableColumn *)col
              row:(NSInteger)rowIndex
{
    NSParameterAssert(rowIndex >= 0 && rowIndex < (((int)[names count]) + 1));
    //NSLog(@"editing somthing...");
    
    
    if (rowIndex == 0) {
        // Add new object...
        LEMapDrawingMode drawMode = [currentLevelDrawView currentDrawingMode];
        id newObj = nil;
        switch(drawMode) {
            case LEMapDrawingModeCeilingHeight:
            case LEMapDrawingModeFloorHeight:
                // Open the sheet...
                [self.window beginSheet:newHeightWindowSheet completionHandler:^(NSModalResponse returnCode) {
                    
                }];
                
                newHeightSheetOpen = YES;
                [currentLevelDrawView setNewHeightSheetOpen:YES];
                break;
            case LEMapDrawingModeLayers:
                newObj = [currentLevel addObjectWithDefaults:[PhLayer class]];
                break;
            case LEMapDrawingModeFloorLights:
            case LEMapDrawingModeCeilingLights:
            case LEMapDrawingModeLiquidLights:
                newObj = [currentLevel addObjectWithDefaults:[PhLight class]];
                break;
            case LEMapDrawingModeAmbientSounds:
                newObj = [currentLevel addObjectWithDefaults:[PhAmbientSound class]];
                break;
            case LEMapDrawingModeRandomSounds:
                newObj = [currentLevel addObjectWithDefaults:[PhRandomSound class]];
                break;
            case LEMapDrawingModeLiquids:
                newObj = [currentLevel addObjectWithDefaults:[PhMedia class]];
                break;
            default:
                newObj = nil;
                break;
        }
        
        if (newObj == nil)
            return NO;
        
        [currentLevelDocument openEditWindowForObject:newObj];
        
        return NO;
    }
    
    if (objs == nil)
        return NO;
    
    if ([[numbers objectAtIndex:0] intValue] == -1) {
        if (rowIndex == 1) {
            return NO;
        } else {
            [currentLevelDocument openEditWindowForObject:[objs objectAtIndex:(rowIndex - 2)]];
        }
    } else {
        //NSLog(@"editing light...");
        [currentLevelDocument openEditWindowForObject:[objs objectAtIndex:(rowIndex - 1)]];
    }
    
    return NO;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)col
              row:(NSInteger)rowIndex
{
    // Should never get here for right now, acutally...
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
    alert.informativeText = NSLocalizedString(@"Color List Table Attempted To Set Object.", @"Color List Table Attempted To Set Object.");
    alert.alertStyle = NSAlertStyleCritical;
    [alert runModal];
    return;
}

@end
