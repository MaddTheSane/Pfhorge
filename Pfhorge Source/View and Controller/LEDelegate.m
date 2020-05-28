//
//  LEDelegate.m
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

#import "PhDefaultLayerController.h"
#import "PhStartupWinController.h"
#import "LEInspectorController.h"
#import "LEPaletteController.h"
#import "PhTextureRepository.h"
#import "PhPrefsController.h"
#import "LEDelegate.h"
#import "LEExtras.h"
#import "LEMap.h"

#import "crc.h"

#import "PhPluginManager.h"

@implementation LEDelegate

/*- (void)createTrickyMenu {
    // There's really no need for this menu to be created programatically.
    // It could just as easily be created in IB.
    // I'm creating it here just to make it clear there's no special magic
    // going on to get these slightly trickier features to work.
    
    NSMenu *newMenu;
    NSMenuItem *newItem;

    // Add the submenu
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Tricky" action:NULL keyEquivalent:@""];
    newMenu = [[NSMenu allocWithZone:[NSMenu menuZone]] initWithTitle:@"Tricky"];
    [newItem setSubmenu:newMenu];
    [newMenu release];
    [[NSApp mainMenu] addItem:newItem];
    [newItem release];

    // Add some tricky items
    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Empty Trash..." action:NULL keyEquivalent:@"T"];
    [newItem setTag:EmptyTrashItemTag];
    [newItem setTarget:self];
    [newItem setAction:@selector(emptyTrash:)];
    [newMenu addItem:newItem];
    [newItem release];

    [newMenu addItem:[NSMenuItem separatorItem]];

    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Radio 1" action:NULL keyEquivalent:@""];
    [newItem setTag:Radio1Tag];
    [newItem setTarget:self];
    [newItem setAction:@selector(radioAction:)];
    [newItem setOnStateImage:[NSImage imageNamed:@"NSMenuRadio"]];
    [newMenu addItem:newItem];
    [newItem release];

    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Radio 2" action:NULL keyEquivalent:@""];
    [newItem setTag:Radio2Tag];
    [newItem setTarget:self];
    [newItem setAction:@selector(radioAction:)];
    [newItem setOnStateImage:[NSImage imageNamed:@"NSMenuRadio"]];
    [newMenu addItem:newItem];
    [newItem release];

    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Radio 3" action:NULL keyEquivalent:@""];
    [newItem setTag:Radio3Tag];
    [newItem setTarget:self];
    [newItem setAction:@selector(radioAction:)];
    [newItem setOnStateImage:[NSImage imageNamed:@"NSMenuRadio"]];
    [newMenu addItem:newItem];
    [newItem release];

    [newMenu addItem:[NSMenuItem separatorItem]];

    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Switch1" action:NULL keyEquivalent:@""];
    [newItem setTag:Switch1Tag];
    [newItem setTarget:self];
    [newItem setAction:@selector(switch1Action:)];
    [newMenu addItem:newItem];
    [newItem release];

    newItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Show Something" action:NULL keyEquivalent:@""];
    [newItem setTag:Switch2Tag];
    [newItem setTarget:self];
    [newItem setAction:@selector(switch2Action:)];
    [newMenu addItem:newItem];
    [newItem release];
}*/

// *********************** Class Methods ***********************
+ (id)sharedAppDelegateController:(LEDelegate *)del {
    static LEDelegate *sharedAppDelegateController = nil;
    
    if (del == nil)
    {
        if (!sharedAppDelegateController) {
            sharedAppDelegateController = [[LEDelegate alloc] init];
        }
    }
    else
    {
        sharedAppDelegateController = del;
    }
    
    return sharedAppDelegateController;
}

-(LEDelegate *)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    [LEDelegate sharedAppDelegateController:self];
        
    return self;
}


// *** Regular Stuff ***
//	After returning from this method, the application's icon in the dock will stop bouncing.
//	Here we scan the application's plug-in folder for plug-ins and try to activate them.

- (void)applicationWillFinishLaunching:(NSNotification*)notification {
    [[PhPluginManager sharedPhPluginManager] findPlugins];
}




// ************************* Plugin Methods *************************
#pragma mark -
#pragma mark Plugin Methods

// + (PhPluginManager *)sharedPhPluginManager {pluginInstanceNames

- (void)setupPluginMenu
{
    PhPluginManager *thePluginManager = [PhPluginManager sharedPhPluginManager];
    NSArray *thePluginNames = [thePluginManager pluginInstanceNames];
    NSArray *thePlugins = [thePluginManager pluginInstances];
    NSEnumerator *numer = [thePluginNames objectEnumerator];
    NSEnumerator *numer2 = [thePlugins objectEnumerator];
    NSString *theString;
    id thePlugin;
    
    while ((theString = [numer nextObject]) &&
            (thePlugin = [numer2 nextObject]))
    {
        NSMenuItem *newItem = [[NSMenuItem alloc]
        initWithTitle:theString action:NULL keyEquivalent:@""];
        
        [newItem setRepresentedObject:thePlugin];
        [newItem setTarget:self];
        [newItem setAction:@selector(pluginMenuItemAction:)];
        [thePluginMenu addItem:newItem];
        [newItem release];
    }
    // activatePluginIndex
}



- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    scriptPaths = [[NSMutableArray alloc] initWithCapacity:3];
    PhStartupWinController *startupWinController = nil;
    
    [PhPrefsController sharedPrefController];
    [PhDefaultLayerController sharedLayerDefaultsController];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSAppleEventManagerWillProcessFirstEventNotification
                                                        object:[NSAppleEventManager sharedAppleEventManager]];
    
    [self setupAppleScriptMenu];
    [self setupPluginMenu];
    
     // Load The Textures
    //[[PhTextureRepository sharedTextureRepository] loadTheTextures];

    //[PhPrefsController sharedPrefController];
    //[PhDefaultLayerController sharedLayerDefaultsController];
    
     // A Test For The Textures and the Loading Window of the Future...
    startupWinController = [[PhStartupWinController alloc] init];
    
    [startupWinController showWindow:self];
    
    [startupWinController loadTexturesNow];
    
    [LEInspectorController sharedInspectorController];
    [LEPaletteController sharedPaletteController];
	[self thePalette:self];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    
}

-(void)recursiveBuildMenuAtFolder:(NSString *)thePath usingMenu:(NSMenu *)theMenu
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *subpaths;
    //BOOL isDir;
    NSString *fileName;
    NSEnumerator *numer;
    NSMenu *newMenu;
    NSMenuItem *newItem;
    
    if (!IsPathDirectory(manager, thePath))
    {
        NSLog(@"thePath for recursiveBuildMenuAtFolder: in delagate was not a folder.");
        SEND_ERROR_MSG_TITLE(@"thePath for recursiveBuildMenuAtFolder: in delagate was not a folder.",
                             @"Script Folder Error");
        return;
    }
    
    subpaths = [manager contentsOfDirectoryAtPath:thePath error:NULL];
    numer = [subpaths objectEnumerator];
    while (fileName = [numer nextObject])
    {
        NSString *fullPath = [thePath stringByAppendingPathComponent:fileName];
        NSString *onlyName = [fileName stringByDeletingPathExtension];
        
        if ([[fileName substringToIndex:1] isEqualToString:@"."])
            continue;
        
        if (IsPathDirectory(manager, fullPath))
        {
            newItem = [[NSMenuItem alloc]
                        initWithTitle:onlyName action:NULL keyEquivalent:@""];
            newMenu = [[NSMenu alloc] initWithTitle:onlyName];
            
            [newItem setSubmenu:newMenu];
            [newMenu release];
            [theMenu addItem:newItem];
            [newItem release];
            
            [self recursiveBuildMenuAtFolder:fullPath usingMenu:newMenu];
        }
        else if ([[fileName pathExtension] isEqualToString:@"scpt"])
        {
            NSString *copyOfFullPath = [fullPath copy];
            
            [scriptPaths addObject:copyOfFullPath];
            
            newItem = [[NSMenuItem alloc]
                initWithTitle:onlyName action:NULL keyEquivalent:@""];
            
            [newItem setRepresentedObject:copyOfFullPath];
            [newItem setTarget:self];
            [newItem setAction:@selector(scriptMenuItemAction:)];
            [theMenu addItem:newItem];
            [newItem release];
            [copyOfFullPath release];
        }
        else
        {
            static BOOL alreadyHadLecture = NO;
            if (!alreadyHadLecture)
                SEND_ERROR_MSG_TITLE(@"Unknown file(s) in scripts folder, see console for details.",
                                     @"Unknown Script File(s)");
            
            NSLog(@"Unkown file '%@' in scripts folder at location: '%@'", fileName, fullPath);
            alreadyHadLecture = YES;
        }
    } // END while (fileName = [numer nextObject])
}

-(void)setupAppleScriptMenu
{
    NSFileManager *manager = [NSFileManager defaultManager];
    //NSDirectoryEnumerator *enumerator;
    //NSString *file;
    BOOL isDir = NO;
    NSString *scriptFolder = [@"~/Library/Pfhorge Scripts" stringByExpandingTildeInPath];
    BOOL exsists = [manager fileExistsAtPath:scriptFolder isDirectory:&isDir];
    
    if (!exsists)
    { // For attributes use a dict with key "NSFileExtensionHidden"
      // set to a NSNumber containing a BOOL...
        
        //NSString *theExScriptPath = [[NSBundle mainBundle] pathForResource:@"Example Script" ofType:@"scpt"];
        BOOL isNewDir = NO;
        
        SEND_ERROR_MSG_TITLE(@"Script folder does not exist. Please see read me for details about using this. Creating it…",
                                @"Creating Script Folder");
        
        NSLog(@"Script folder does not exsist at: '%@', attempting to create it...", scriptFolder);
        
            // In the future verifi that the folder where created!!!
        [manager createDirectoryAtPath:scriptFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        //[manager createDirectoryAtPath:[scriptFolder stringByAppendingString:@"/You Can Have Sub-Folders"] attributes:nil];
        
        if (![manager fileExistsAtPath:scriptFolder isDirectory:&isNewDir])
        {
            SEND_ERROR_MSG_TITLE(@"Could not create script folder, there will be no scripts in script menu. (See Console)",
                                @"Can't Create Script Folder");
            return;
        }
        
        /*if ([manager fileExistsAtPath:theExScriptPath])
            [manager copyPath:theExScriptPath toPath:[scriptFolder stringByAppendingString:@"/Example Script.scpt"] handler:nil];
        else
        {
            NSLog(@"Missing the example script resource...");
        }*/
    }
    else if (!isDir)
    {
        NSLog(@"Sorry, could not use or create script folder, a file is already at: %@", scriptFolder);
        SEND_ERROR_MSG_TITLE(@"A File Is Already At Script Folder Location, see console for location.",
                             @"Error Creating Script Folder");
        return;
    }
    
    NSLog(@"Getting Scripts At: %@", scriptFolder);
    
    if ([[manager contentsOfDirectoryAtPath:scriptFolder error:NULL] count] == 0)
    {
        NSMenuItem *newItem;
        
        newItem = [[NSMenuItem alloc]
                    initWithTitle:@"There Are No Scripts In The Scripts Folder"
                    action:NULL keyEquivalent:@""];
        [newItem setTarget:nil];
        [newItem setAction:nil];
        [theAppleScriptMenu addItem:newItem];
        [newItem release];
        
        newItem = [[NSMenuItem alloc]
                    initWithTitle:@"See Read Me For Details On How To Use Scripts"
                    action:NULL keyEquivalent:@""];
        [newItem setTarget:nil];
        [newItem setAction:nil];
        [theAppleScriptMenu addItem:newItem];
        [newItem release];
        
        newItem = [[NSMenuItem alloc]
                    initWithTitle:@"   ********* Notes *********"
                    action:NULL keyEquivalent:@""];
        [newItem setTarget:nil];
        [newItem setAction:nil];
        [theAppleScriptMenu addItem:newItem];
        [newItem release];
        
        newItem = [[NSMenuItem alloc]
                    initWithTitle:@"Use Compiled Scripts Here Only"
                    action:NULL keyEquivalent:@""];
        [newItem setTarget:nil];
        [newItem setAction:nil];
        [theAppleScriptMenu addItem:newItem];
        [newItem release];
        
        newItem = [[NSMenuItem alloc]
                    initWithTitle:@"Files In Scripts Folder Need A '.scpt' Extension"
                    action:NULL keyEquivalent:@""];
        [newItem setTarget:nil];
        [newItem setAction:nil];
        [theAppleScriptMenu addItem:newItem];
        [newItem release];
        
        newItem = [[NSMenuItem alloc]
                    initWithTitle:@"You can use folders in the script folder ]:=>"
                    action:NULL keyEquivalent:@""];
        [newItem setTarget:nil];
        [newItem setAction:nil];
        [theAppleScriptMenu addItem:newItem];
        [newItem release];
        
        newItem = [[NSMenuItem alloc]
                    initWithTitle:@"The example script creates a new map and creates"
                    action:NULL keyEquivalent:@""];
        [newItem setTarget:nil];
        [newItem setAction:nil];
        [theAppleScriptMenu addItem:newItem];
        [newItem release];
        newItem = [[NSMenuItem alloc]
                    initWithTitle:@"   five polygons in the center of the map."
                    action:NULL keyEquivalent:@""];
        [newItem setTarget:nil];
        [newItem setAction:nil];
        [theAppleScriptMenu addItem:newItem];
        [newItem release];
        
        return;
    }
    
    [self recursiveBuildMenuAtFolder:scriptFolder usingMenu:theAppleScriptMenu];
}

// ************************* Actions *************************
#pragma mark -
#pragma mark Actions

- (IBAction)pluginMenuItemAction:(id)sender
{
    id<PhLevelPluginProtocol> thePlugin = [sender representedObject];
    NSLog(@"Activating Plugin Name: %@", [thePlugin name]);
    [thePlugin activate];
}

- (IBAction)scriptMenuItemAction:(id)sender
{
    NSString *fullPathToScript = [sender representedObject];
    
    NSLog(@"Running Script At: %@", fullPathToScript);
    createAndExecuteScriptObject(fullPathToScript);
}

- (IBAction)exectuteScriptExample:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowedFileTypes = @[@"scpt"];
    NSModalResponse returnCode = [panel runModal];
    
    if (returnCode == NSModalResponseOK)
    {
        NSString *path = [panel URL].path;
        NSLog(@"The Path: %@", path);
        //NSString *thePath = @"Test Script.scpt";
        createAndExecuteScriptObject(path);
    }
}

- (IBAction)theInspector:(id)sender
{
    [LEInspectorController sharedInspectorController];
}

// NSApplication Delagate Message...
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}



- (IBAction)theGeneralProperties:(id)sender
{
    [[LEInspectorController sharedInspectorController] showGeneralPropertiesWindow:sender];
}

- (IBAction)theControlPanels:(id)sender
{
    [[LEInspectorController sharedInspectorController] showControlPanelWindow:sender];
}

- (IBAction)theLights:(id)sender
{
    [[LEInspectorController sharedInspectorController] showLightWindow:sender];
}

- (IBAction)theTextures:(id)sender
{
    NSLog(@"- (IBAction)theTextures:(id)sender");
    [[LEInspectorController sharedInspectorController] showTextureWindow:sender];
}



- (IBAction)thePalette:(id)sender
{
    [[LEPaletteController sharedPaletteController] showWindow:sender];
}

- (IBAction)thePrefs:(id)sender
{
    [[PhPrefsController sharedPrefController] showWindow:sender];
}

- (IBAction)theLayerDefaults:(id)sender
{
    [[PhDefaultLayerController sharedLayerDefaultsController] showWindow:sender];
}

- (IBAction)newPhorgeLevel:(id)sender
{
	NSError *err;
	NSDocument *doc = [[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:@"com.xmission.dragons.pfhorge.level" error:&err];
	[[NSDocumentController sharedDocumentController] addDocument:doc];
	[doc makeWindowControllers];
	[doc showWindows];
}

- (LEMapDraw *)getCurrentLevelDrawViewShowErrors
{
	LEMapDraw *view = [self getCurrentLevelDrawView];
	
	if (view == nil)
		{ SEND_ERROR_MSG_TITLE(@"Could not find an open map.", @"No Current Map"); }
	
	return view;
}

- (LEMapDraw *)getCurrentLevelDrawView
{
	LEMap *mapDocument = (LEMap *)[[NSDocumentController sharedDocumentController] currentDocument];
	
	if (mapDocument == nil)
		return nil;
	
	return [mapDocument getMapDrawView];
}

- (IBAction)redrawEverything:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setNeedsDisplay:YES]; }

- (IBAction)setDrawModeToNormal:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeNormal]; }
- (IBAction)setDrawModeToCeilingHeight:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeCeilingHeight]; }
- (IBAction)enableFloorHeightViewMode:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeFloorHeight]; }
- (IBAction)enableLiquidViewMode:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeLiquids]; }
- (IBAction)enableFloorLightViewMode:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeFloorLights]; }
- (IBAction)enableCeilingLightViewMode:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeCeilingLights]; }
- (IBAction)enableLiquidLightViewMode:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeLiquidLights]; }
- (IBAction)enableAmbientSoundViewMode:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeAmbientSounds]; }
- (IBAction)enableRandomSoundViewMode:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeRandomSounds]; }
- (IBAction)enableLayerViewMode:(id)sender { [[self getCurrentLevelDrawViewShowErrors] setCurrentDrawingMode:LEMapDrawingModeLayers]; }

- (IBAction)newPhorgeScenario:(id)sender
{
    ///NSLog(@"---sen---");
	NSError *err;
	NSDocument *doc = [[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:@"com.xmission.dragons.pfhorge.scenario" error:&err];
	[[NSDocumentController sharedDocumentController] addDocument:doc];
	[doc makeWindowControllers];
	[doc showWindows];
}

- (IBAction)testTheCheckSumOnAFile:(id)sender
{
    //NSArray	*fileTypes	= [NSArray arrayWithObject:NSFileTypeForHFSTypeCode('maps')];
    NSOpenPanel	*op		= [NSOpenPanel openPanel];
    
    [op	setAllowsMultipleSelection:NO];
    [op setTitle:@"Checksum Test"];
    [op setPrompt:@"Check"];
    
    NSModalResponse returnCode = [op runModal];
    NSString		*fileName = nil;
    NSFileManager 	*fileManager = [NSFileManager defaultManager];
    
    NSData *theData;
    
    if (returnCode == NSModalResponseOK)
    {
        fileName = op.URL.path;
        theData = [fileManager contentsAtPath:fileName];
        [self testOutChecksum:theData];
    }
}

- (void)testOutChecksum:(NSData *)theData
{
	// TODO: byteswap!
    NSMutableData *newData = [[NSMutableData alloc] init];
    unsigned int oldCheckSum1;
    unsigned int oldCheckSum2;
	unsigned int oldCheckSum3;
    //[mapData deserializeDataAt:&theUnsignedLong ofObjCType:@encode(unsigned long) atCursor:&theCursor context:nil];
    [theData getBytes:&oldCheckSum1 range:NSMakeRange(68,4)];
    [newData setData:theData];
    [newData getBytes:&oldCheckSum2 range:NSMakeRange(68,4)];
    
    unsigned int ulongZero = 0;
    
    NSRange checksumRange = NSMakeRange(68, 4);
    [newData replaceBytesInRange:checksumRange withBytes:&ulongZero];
    [newData getBytes:&oldCheckSum3 range:NSMakeRange(68,4)];
	
    //unsigned char *buffer = [newData mutableBytes];
    //long theLength = [newData length];
    //unsigned long theChecksum = calculate_data_crc(buffer, theLength);
	unsigned int theChecksum = calculate_crc_for_nsdata(newData);
    
    // at 68 for 4 bytes...
    NSLog(@"Caculated Checksum: %d   -   The Old Checksum: %d   -   The Old Transfer Checksum: %d  -  Supposed To Be Zero: %d", theChecksum, oldCheckSum1, oldCheckSum2, oldCheckSum3);
    
    [newData release];
}

@end
