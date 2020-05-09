//
//  PhNamesController.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Thu Nov 22 2001.
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

//
// This is going to be the controller that controls the names window,
// which allows you to edit the names of the tags, etc.
//
// Right now, I am developing this as a sheet.


#import "PhPlatformSheetController.h"
#import "LELevelWindowController.h"
#import "PhLightEditorController.h"
#import "PhAmbientSndEditCon.h"
#import "PhRandomSndEditCon.h"
#import "PhNamesController.h"
#import "PhLiquidEditCon.h"
#import "PhAbstractName.h"
#import "LELevelData.h"
#import "LEMapDraw.h"
#import "LEExtras.h"
#import "PhLayer.h"
#import "LEMap.h"
#import "PhTag.h"

#import "PhLight.h"
#import "PhAmbientSound.h"
#import "PhRandomSound.h"
#import "PhMedia.h"
#import "PhPlatform.h"



@implementation PhNamesController

// *********************** EXTERN Variables ***********************
#pragma mark -
#pragma mark ********* ||| EXTERN Variables ||| *********
static NSString *const PhNumberOfObject = @"#";
static NSString *const PhNameOfObject = @"Name";

// *********************** Action Methods ***********************
#pragma mark -
#pragma mark ********* Action Methods *********

- (IBAction)editBtnAction:(id)sender
{
    editingWindowController = nil;
    
    if (currentDisplayMode == _display_polys)
    {
        SEND_ERROR_MSG(@"Can't Edit Polygons Here (Use General Inspector)");
        return;
    }
    else if (currentDisplayMode == _display_layers)
    {
        SEND_ERROR_MSG(@"Ability to edit the color of the layer comming soon!");
        return;
    }
    
    if ([self isSomthingSelected])
        [[theLevelWindowControllerOutlet document] openEditWindowForObject:[self getSelectedObject]];
    else
        SEND_ERROR_MSG(@"Sorry, but you need to select something first...");
}

- (IBAction)defaultBtnAction:(id)sender { SEND_ERROR_MSG(@"Command Not Implemented Yet..."); }
- (IBAction)deleteBtnAction:(id)sender
{
    if (currentDisplayMode == _display_polys && [self isSomthingSelected])
    {
        [theLevelDataObject removeNameOfPolygon:[self getSelectedObject]];
        [self reloadDataFromLevel];
        return;
    }
    
    if ([self isSomthingSelected])
        [[(LEMap *)[theLevelWindowControllerOutlet document] level] deleteObject:[self getSelectedObject]];
    else
        SEND_ERROR_MSG(@"Sorry, but you need to select something first...");
    [self reloadDataFromLevel];
}

- (IBAction)deleteAllBtnAction:(id)sender
{
    SEND_ERROR_MSG(@"The Delete All Command Not Implemented Yet...");
    //[self reloadDataFromLevel];
}

- (IBAction)addBtnAction:(id)sender
{
    /* use addObjectWithDefaults:(Class)theClass */
   switch(currentDisplayMode)
    {
        case _display_tags:
            [theLevelDataObject addObjectWithDefaults:[PhTag class]];
            break;
	case _display_lights:
	    [theLevelDataObject addObjectWithDefaults:[PhLight class]];
            break;
	case _display_ambient_sounds:
            [theLevelDataObject addObjectWithDefaults:[PhAmbientSound class]];
            break;
	case _display_random_sounds:
            [theLevelDataObject addObjectWithDefaults:[PhRandomSound class]];
            break;
	case _display_liquids:
            [theLevelDataObject addObjectWithDefaults:[PhMedia class]];
            break;
	case _display_platforms:
            [theLevelDataObject addObjectWithDefaults:[PhPlatform class]];
            break;
        case _display_polys:
            SEND_ERROR_MSG(@"Can't Add Polys Here, select a polygon and use the 'Tools->Set Poly Name' menu item.");
            return;
        case _display_layers:
            [theLevelDataObject addObjectWithDefaults:[PhLayer class]];
            break;
	default:
            SEND_ERROR_MSG(@"Can't Add More Of These Yet...");
            return;
    }
    
    [self reloadDataFromLevel];
}

- (IBAction)duplicateBtnAction:(id)sender {SEND_ERROR_MSG(@"Command Not Implemented Yet..."); }
- (IBAction)okBtnAction:(id)sender { SEND_ERROR_MSG(@"Command Not Implemented Yet...");}
- (IBAction)editingMenuAction:(id)sender { [self setDisplayEditMode:[sender indexOfSelectedItem]];  }

// *********************** Overridden Methods ***********************
#pragma mark -
#pragma mark ********* Overridden Methods *********

- (id)init
{
    self = [super initWithWindow:theNameWindow];
    
    if (self == nil)
        return nil;
    
    //[self window];
    
    //theLevelDataObject = [[theLevelWindowControllerOutlet document] getCurrentLevelLoaded];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self
    //                                      selector:@selector(levelDeallocating:)
    //                                      name:PhLevelDeallocatingNotification
    //                                      object:nil];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (editingWindowController != nil)
        [editingWindowController release];
    
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(reloadDataFromLevel)
        name:LELevelChangedNotification
        object:nil];
    NSLog(@"LOAD");
    [self setDisplayEditMode:_display_tags];
}

// *********************** Updater Methods ***********************
#pragma mark -
#pragma mark ********* Updater Methods  *********

-(void)updateInterface { [self setDisplayEditMode:currentDisplayMode]; }

-(void)reloadDataFromLevel
{
    currentArray = nil;
    currentNameArray = nil;
    //NSLog(@"PhNamesController->reloadDataFromLevel->Message To User: Geting the level...");
    theLevelDataObject = [[theLevelWindowControllerOutlet document] getCurrentLevelLoaded];
    [self setDisplayEditMode:currentDisplayMode];
}

-(void)setDisplayEditMode:(int)theRequestedDisplayMode
{
    // Get the Document
    LEMap *theMapDocumentController = [theLevelWindowControllerOutlet document];
    // Get The Level Data
    LELevelData *theLevelData = [theMapDocumentController getCurrentLevelLoaded];
    theLevelDataObject = [[theLevelWindowControllerOutlet document] getCurrentLevelLoaded];
    
    //[theTable reloadData];
    
    // Set the mode
    currentDisplayMode = theRequestedDisplayMode;
    
    switch(currentDisplayMode)
    {
        case _display_tags:
            currentArray = [theLevelData getTags];
            currentNameArray = [theLevelData getTagNames];
            break;
	case _display_lights:
	    currentArray = [theLevelData getLights];
            currentNameArray = [theLevelData getLightNames];
            break;
	case _display_ambient_sounds:
	    currentArray = [theLevelData getAmbientSounds];
            currentNameArray = [theLevelData getAmbientSoundNames];
            break;
	case _display_random_sounds:
            currentArray = [theLevelData getRandomSounds];
            currentNameArray = [theLevelData getRandomSoundNames];
            break;
	case _display_liquids:
	    currentArray = [theLevelData getMedia];
            currentNameArray = [theLevelData getLiquidNames];
            break;
	case _display_platforms:
            currentArray = [theLevelData getPlatforms];
            currentNameArray = [theLevelData getPlatformNames];
            break;
        case _display_polys:
            currentArray = [theLevelData namedPolyObjects];
            currentNameArray = [theLevelData getPolyNames];
            break;
        case _display_layers:
            currentArray = [theLevelData layersInLevel];
            currentNameArray = [theLevelData getLayerNames];
            break;
	default:
            SEND_ERROR_MSG(@"Unkown Edit Item Currently Selected!");
            currentArray = nil;
            currentNameArray = nil;
            break;
    }
    
    [theTable reloadData];
}

// *********************** Accsessor Methods ***********************
#pragma mark -
#pragma mark ********* Accsessor Methods *********

- (int)getSelection { return [theTable selectedRow]; }

- (BOOL)isSomthingSelected { return ([theTable selectedRowIndexes].count >= 0); }

- (id)getSelectedObject
{
    return [currentArray objectAtIndex:[theTable selectedRow]];
}

- (NSString *)getSelectedName
{
    return [[[currentNameArray objectAtIndex:[theTable selectedRow]] copy] autorelease];
}

// *********************** Notifcations ***********************
#pragma mark -
#pragma mark ********* Notifcations *********

- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    
    ///return;
    
    
    //NSLog(@"- (void)levelDeallocating:(NSNotification *)notification");
    
    /*if ([levelDataObjectDeallocating isKindOfClass:[LELevelData class]] &&
            [theLevelDataObject isKindOfClass:[LELevelData class]])
    {
        NSLog(@"It is a level object!!!");
    }*/
    
    if (theLevelDataObject == levelDataObjectDeallocating)
    {
        //NSLog(@"Level object was the same!!!");
        // My Level Is Deallocating!!!
        // Do Stuff Here!!!
        
        currentArray = nil;
        
        if (editingWindowController != nil)
        {
            NSLog(@"Releasing editingWindowController");
            [[editingWindowController window] performClose:self];
        }
        
        editingWindowController = nil;
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    //int theSelectedRow = [self selectedRow];
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification
{
    NSWindow *theWin = [aNotification object];
    
    if (theWin == theNameWindow)
    {
        //[self reloadDataFromLevel];
    }
}

// *********************** Table Updater Methods ***********************
#pragma mark -
#pragma mark ********* Table Updater Methods *********

// *** Data Source Messages ***

- (BOOL)tableView:(NSTableView *)aTableView
shouldEditTableColumn:(NSTableColumn *)col
			  row:(NSInteger)rowIndex
{
    if ([[col identifier] isEqualToString:PhNumberOfObject])
        return NO;
    
    else if ([[col identifier] isEqualToString:PhNameOfObject])
        return YES;
    
    return NO;
}

// *** Data Source Methods ***

/*- (void)tableView:(NSTableView *)view
    willDisplayCell:(id)cell
    forTableColumn:(NSTableColumn *)col
    row:(int)row
{
    [cell setBackgroundColor: [colors objectAtIndex:row]];
}*/

- (NSInteger)numberOfRowsInTableView:(NSTableView *)view
{
    return [currentArray count];
}

- (id)tableView:(NSTableView *)view
objectValueForTableColumn:(NSTableColumn *)col
			row:(NSInteger)row
{
    /*PhAbstractName **/ id theCurNameObj= [currentArray objectAtIndex:row];
    
    if (currentDisplayMode == _display_tags)
    {
        if ([[col identifier] isEqualToString:PhNumberOfObject])
            return [theCurNameObj getPhNumber];
            
        else if ([[col identifier] isEqualToString:PhNameOfObject])
            return [theCurNameObj getPhName];
    }
    else
    {
        if ([[col identifier] isEqualToString:PhNumberOfObject])
            return [NSNumber numberWithShort:[theCurNameObj index]];
            
        else if ([[col identifier] isEqualToString:PhNameOfObject])
            return [theCurNameObj getPhName];
    }
    return nil;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)col
			  row:(NSInteger)rowIndex
{
    //id theRecord;
    //PhAbstractName *theCurNameObj= [currentArray objectAtIndex:row];
    
    NSParameterAssert(rowIndex >= 0 && rowIndex < ((int)[currentArray count]));
     
	if ([[col identifier] isEqualToString:PhNameOfObject]) {
        [theLevelDataObject setNameFor:[currentArray objectAtIndex:rowIndex] to:anObject];
    
	} else if ([[col identifier] isEqualToString:PhNumberOfObject]) {
		if (currentDisplayMode == _display_tags) {
            return;
        
		} else {
            return;
		}
    }
    
    return;
}




@end
