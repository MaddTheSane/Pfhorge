//
//  PhPlatformSheetController.h
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
#import <PfhorgeKit/InfoWindowCommander.h>

@class PhPlatform;

@interface PhPlatformSheetController : InfoWindowCommander
{
    IBOutlet NSWindow *theWindow;
    
    IBOutlet NSTextField *statusIT;
    
    IBOutlet NSPopUpButton *tagComboMenu;
    IBOutlet NSPopUpButton *copyFromComboMenu;
    IBOutlet NSPopUpButton *typeComboMenu;
    
    IBOutlet NSTextField *minHeightTB;
    IBOutlet NSTextField *maxHeightTB;
    
    IBOutlet NSButton *autoCalcMinCB;
    IBOutlet NSButton *autoCalcMaxCB;
    IBOutlet NSButton *platformIsADoorCB;
    IBOutlet NSButton *floorToCeilingCB;
    
    IBOutlet NSMatrix *initiallyCBMatrix;
    IBOutlet NSMatrix *controllableByCBMatrix;
    IBOutlet NSMatrix *hitsObstructionCBMatrix;
    IBOutlet NSMatrix *activatesCBMatrix;
    IBOutlet NSMatrix *deactivatesCBMatrix;
    IBOutlet NSMatrix *otherOptionsCBMatrix;
    
    IBOutlet NSMatrix *extendsFromRBMatrix;
    IBOutlet NSMatrix *deactivatesRBMatrix;
    
    
    
    PhPlatform *platform;
}

@property (weak) IBOutlet NSTextField *speedTB;
@property (weak) IBOutlet NSTextField *delayTB;

- (instancetype)initWithPlatform:(PhPlatform *)thePlatform
					   withLevel:(LELevelData *)theLevel
				 withMapDocument:(LEMap *)theMapDoc;

-(void)refreshFromPlatformData;
-(void)saveChanges;

- (IBAction)typeOfPlatformAction:(id)sender;
- (IBAction)copyFromAction:(id)sender;
- (IBAction)autoCalcMinHeightAction:(id)sender;
- (IBAction)autoCalcMaxHeightAction:(id)sender;
- (IBAction)applyAction:(id)sender;
- (IBAction)saveAndCloseBtnAction:(id)sender;
- (IBAction)revertAction:(id)sender;
- (IBAction)renamePlatformAction:(id)sender;

@end
