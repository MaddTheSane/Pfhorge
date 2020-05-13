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

#import "PhColorListControllerDrawer.h"
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

#import "PhTextureRepository.h"

//Other Classes...
#import "LEExtras.h"



//[theLevelDataObject addObjectWithDefaults:[PhLight class]]; 


@implementation PhColorListControllerDrawer

//LESelectionChangedNotification

// *********************** Overridden Methods ***********************

- (id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (IBAction)redrawEverything:(id)sender { [currentLevelDrawView setNeedsDisplay:YES]; }

- (IBAction)setDrawModeToNormal:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawNormaly]; }
- (IBAction)setDrawModeToCeilingHeight:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawCeilingHeight]; }
- (IBAction)enableFloorHeightViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawFloorHeight]; }
- (IBAction)enableLiquidViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawLiquids]; }
- (IBAction)enableFloorLightViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawFloorLights]; }
- (IBAction)enableCeilingLightViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawCeilingLights]; }
- (IBAction)enableLiquidLightViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawLiquidLights]; }
- (IBAction)enableAmbientSoundViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawAmbientSounds]; }
- (IBAction)enableRandomSoundViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawRandomSounds]; }
- (IBAction)enableLayerViewMode:(id)sender { [currentLevelDrawView setCurrentDrawingMode:_drawLayers]; }


// *********************** Action Methods ***********************

// *********************** Other Methods ***********************
- (void)setLevelWindowController:(LELevelWindowController *)mainWindController
{
    NSWindowController *controller = mainWindController;
    //[mainWindow close];
    //return;
    
    if (controller != nil && [controller isKindOfClass:[LELevelWindowController class]])
    {
        //NSLog(@"SETING UP COLOR DRAWER OBJECT...");
        currentLevelDocument = [(LELevelWindowController *)controller document];
        currentLevelDrawView = [(LELevelWindowController *)controller levelDrawView];
        currentLevel = [currentLevelDocument getCurrentLevelLoaded];
        currentMainWindowController = (LELevelWindowController *)controller;
        ///[(NSWindow *)[self window] orderFront:self];
        
		[theDrawer setNextResponder:currentLevelDrawView];
		
		if (currentLevelDrawView == nil)
			NSLog(@"ERROR: NIL in currentLevelDrawView");
		
        [theDrawer open];
        
        [self updateInterface:currentLevelDrawView];
        
        [[[[colorListTable tableColumns] objectAtIndex:0] dataCell] 
            setDrawsBackground:YES];
        
        [[[[colorListTable tableColumns] objectAtIndex:0] dataCell] 
            setAlignment:NSCenterTextAlignment];
        
        [[[[colorListTable tableColumns] objectAtIndex:0] dataCell] 
            setEditable:YES];
        
    }
    else if (controller != nil && [controller isKindOfClass:[PhColorListController class]])
    {
        NSLog(@"PhColorListController found in setLevelWindowController in PhColrListControllerDrawer...");
        return;
    }
    else
    {
       NSLog(@"3");
        currentLevelDocument = nil;
        currentLevelDrawView = nil;
        currentLevel = nil;
        currentMainWindowController = nil;
        ///[(NSWindow *)[self window] orderOut:self];
        [theDrawer close];
        
        /* [self cancelNewHeightSheetBtn:nil]; */
        [self updateInterface:currentLevelDrawView];
    }
    
}

- (void)updateInterfaceIfLevelDataSame:(LELevelData *)levdata
{
    if (currentLevel == nil)
        return;
    
    if (currentLevel == levdata)
    {
        [self updateInterface:currentLevelDrawView];
    }
}

// *********************** Notifcations ***********************

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    //int theSelectedRow = [self selectedRow];
    
}

// *********************** Updater Methods ***********************

- (NSInteger)getSelection { return [colorListTable selectedRow] - 1; }

- (NSNumber *)getSelectedNumber
{
    if ([self getSelection] < 0)
        return nil;
    else
        return [[[numbers objectAtIndex:[self getSelection]] copy] autorelease];
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
    
    if (currentLevelDrawView == nil || [currentLevelDrawView currentDrawingMode] == _drawNormaly)
    {   //NSLog(@"UPDATE - NIL");
        /*if (numbers != nil)
            [numbers release];
        if (colors != nil)
            [colors release];*/
        numbers = nil;
        colors = nil;
        names = nil;
        objs = nil;
        
        /*if (newHeightSheetOpen)
            [self cancelNewHeightSheetBtn:nil];*/
        
        //NSLog(@"updateInterface nil");
    }
    else
    {   //NSLog(@"UPDATE - OK"); 
        
        if ([currentLevelDrawView newHeightSheetOpen])
        {
            if (!newHeightSheetOpen)
            {
                /*[NSApp  beginSheet:newHeightWindowSheet
                        modalForWindow:[self window]
                        modalDelegate:self
                        didEndSelector:NULL
                        contextInfo:nil];*/
                
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
        [levelInfoString release];
        
        if (numbers == nil || colors == nil)
        {
            /*  [(NSWindow *)[self window] orderOut:self]; */
            
            //return;
        }
        //[numbers retain];
        //[colors retain];
        //NSLog(@"updateInterface != nil");
        /// NSLog(@"Numbers Array Count: %d and Colors Array Count: %d, if these are not equal, ERROR!", [numbers count], [colors count]);
        if ([numbers count] != [colors count])
        {
			NSLog(@"ERROR: Numbers array count and colors array count are not equal: (Numbers: %lu Colors: %lu)", (unsigned long)[numbers count], (unsigned long)[colors count]);
            SEND_ERROR_MSG(@"Numbers array count and colors array count are not equal (check console for more details), ERROR!");
        }
    }
    
	
	//NSLog(@"UDPATE");
    [colorListTable reloadData];
}

// *********************** Table Updater Methods ***********************

- (void)tableView:(NSTableView *)view
  willDisplayCell:(id)cell
   forTableColumn:(NSTableColumn *)col
			  row:(NSInteger)row
{
    if (row == 0)
        [cell setBackgroundColor:[NSColor whiteColor]];
    else
        [cell setBackgroundColor:[colors objectAtIndex:(row - 1)]];
        
    [cell setAlignment:NSCenterTextAlignment];
    //[cell setForegroundColor: [colors objectAtIndex:row]];
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)view
{
    if (names == nil)
        return 0;
    
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

    
    if (rowIndex == 0)
    {
        // Add new object...
        int drawMode = [currentLevelDrawView currentDrawingMode];
        id newObj = nil;
        switch(drawMode)
        {
            case _drawCeilingHeight:
            case _drawFloorHeight:
                // Open the sheet...
                
                /*[NSApp  beginSheet:newHeightWindowSheet
                        modalForWindow:[self window]
                        modalDelegate:self
                        didEndSelector:NULL
                        contextInfo:nil];*/
                
                [currentMainWindowController openNewHeightSheet];
                
                
                //newHeightSheetOpen = YES;
                //[currentLevelDrawView setNewHeightSheetOpen:YES];
                break;
            case _drawLayers:
                newObj = [currentLevel addObjectWithDefaults:[PhLayer class]];
                break;
            case _drawFloorLights:
            case _drawCeilingLights:
            case _drawLiquidLights:
                newObj = [currentLevel addObjectWithDefaults:[PhLight class]];
                break;
            case _drawAmbientSounds:
                newObj = [currentLevel addObjectWithDefaults:[PhAmbientSound class]];
                break;
            case _drawRandomSounds:
                newObj = [currentLevel addObjectWithDefaults:[PhRandomSound class]];
                break;
            case _drawLiquids:
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
    
    if ([[numbers objectAtIndex:0] intValue] == -1)
    {
        if (rowIndex == 1)
            return NO;
        else
            [currentLevelDocument openEditWindowForObject:[objs objectAtIndex:(rowIndex - 2)]];
    }
    else
    {
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
    SEND_ERROR_MSG(@"Color List Table Attempted To Set Object.");
    return;
}

@end
