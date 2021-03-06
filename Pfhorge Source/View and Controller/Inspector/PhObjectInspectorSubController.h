//
//  PhObjectInspectorSubController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Jul 17 2001.
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

#import <AppKit/AppKit.h>

@class LEInspectorController;

@interface PhObjectInspectorSubController : NSWindowController {
    IBOutlet LEInspectorController *mainInspectorController;
    
    IBOutlet id objectWindow;
    
    IBOutlet NSTextField *objAngle;
    IBOutlet id objBox;
    IBOutlet NSMatrix *objFlags;
    IBOutlet NSPopUpButton *objItem;
    IBOutlet NSPopUpButton *objType;
    IBOutlet NSTextField *objZHeight;
    
    NSArray<NSString*> *theMonsterNames;
    NSArray<NSString*> *theItemNames;
    NSArray<NSString*> *theSceneryNames;
    NSArray<NSString*> *theSoundNames;
    NSArray<NSString*> *theGoalNames;
    NSArray<NSString*> *thePlayerNames;
}

- (void)reset;

- (void)updateInterface;
- (void)updateObjectValuesOfComboMenus;

- (void)updateObjectKindMenu;

- (IBAction)objectTypeAction:(id)sender;
- (IBAction)objectKindAction:(id)sender;
- (IBAction)objectAngleAction:(id)sender;
- (IBAction)objectHeightAction:(id)sender;
- (IBAction)objectFlagsAction:(id)sender;

- (void)setupTheObjectNames;

@end
