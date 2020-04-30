//
//  LEDelegate.h
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

@interface LEDelegate : NSObject
{
    IBOutlet NSMenu *theAppleScriptMenu;
    IBOutlet NSMenu *thePluginMenu;
    
    NSMutableArray *scriptPaths;
    
    NSMutableArray* pluginClasses;	// an array of all plug-in classes
}

+ (id)sharedAppDelegateController:(LEDelegate *)del;


//- (void)activatePlugin:(NSString*)path; // Plugin Method...

- (void)setupPluginMenu;

- (IBAction)theInspector:(id)sender;

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender;

-(void)recursiveBuildMenuAtFolder:(NSString *)thePath usingMenu:(NSMenu *)theMenu;
-(void)setupAppleScriptMenu;


- (IBAction)pluginMenuItemAction:(id)sender;
- (IBAction)scriptMenuItemAction:(id)sender;

- (IBAction)exectuteScriptExsample:(id)sender;

- (IBAction)theGeneralProperties:(id)sender;
- (IBAction)theControlPanels:(id)sender;
- (IBAction)theLights:(id)sender;
- (IBAction)theTextures:(id)sender;

- (IBAction)thePalette:(id)sender;
- (IBAction)thePrefs:(id)sender;
- (IBAction)theLayerDefaults:(id)sender;

- (IBAction)newPhorgeLevel:(id)sender;
- (IBAction)newPhorgeScenario:(id)sender;

- (IBAction)testTheCheckSumOnAFile:(id)sender;
- (void)testOutChecksum:(NSData *)theData;

@end



