//
//  PhLightEditorController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon Dec 03 2001.
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
#import "InfoWindowCommander.h"

@class PhLight, LELevelData, LEMap;

@interface PhLightEditorController : InfoWindowCommander
{
    IBOutlet NSTextField *infoIT;
    IBOutlet NSTextField *nameIT;
    
    IBOutlet NSPopUpButton *templateComboMenu;
    IBOutlet NSPopUpButton *copyFromComboMenu;
    
    IBOutlet NSTextField *phaseTB;
    IBOutlet NSPopUpButton *tagComboMenu;
    
    IBOutlet NSButtonCell *statelessCB;
    IBOutlet NSButtonCell *initalyActiveCB;
    
    // Active
    IBOutlet NSPopUpButton *becomeingActiveFunction;
    IBOutlet NSFormCell *becomeingActivePeriod;
    IBOutlet NSFormCell *becomeingActivePeriodChng;
    IBOutlet NSFormCell *becomeingActiveIntesity;
    IBOutlet NSFormCell *becomeingActiveIntesityChng;
    IBOutlet NSSlider *becomeingActiveIntesitySlider;
    IBOutlet NSSlider *becomeingActiveIntesityChngSlider;
    
    IBOutlet NSPopUpButton *primaryActiveFunction;
    IBOutlet NSFormCell *primaryActivePeriod;
    IBOutlet NSFormCell *primaryActivePeriodChng;
    IBOutlet NSFormCell *primaryActiveIntesity;
    IBOutlet NSFormCell *primaryActiveIntesityChng;
    IBOutlet NSSlider *primaryActiveIntesitySlider;
    IBOutlet NSSlider *primaryActiveIntesityChngSlider;
    
    IBOutlet NSPopUpButton *secondaryActiveFunction;
    IBOutlet NSFormCell *secondaryActivePeriod;
    IBOutlet NSFormCell *secondaryActivePeriodChng;
    IBOutlet NSFormCell *secondaryActiveIntesity;
    IBOutlet NSFormCell *secondaryActiveIntesityChng;
    IBOutlet NSSlider *secondaryActiveIntesitySlider;
    IBOutlet NSSlider *secondaryActiveIntesityChngSlider;
    
    // Inactive
    IBOutlet NSPopUpButton *becomeingInactiveFunction;
    IBOutlet NSFormCell *becomeingInactivePeriod;
    IBOutlet NSFormCell *becomeingInactivePeriodChng;
    IBOutlet NSFormCell *becomeingInactiveIntesity;
    IBOutlet NSFormCell *becomeingInactiveIntesityChng;
    IBOutlet NSSlider *becomeingInactiveIntesitySlider;
    IBOutlet NSSlider *becomeingInactiveIntesityChngSlider;
    
    IBOutlet NSFormCell *primaryInactiveFunction;
    IBOutlet NSFormCell *primaryInactivePeriod;
    IBOutlet NSFormCell *primaryInactivePeriodChng;
    IBOutlet NSFormCell *primaryInactiveIntesity;
    IBOutlet NSFormCell *primaryInactiveIntesityChng;
    IBOutlet NSSlider *primaryInactiveIntesitySlider;
    IBOutlet NSSlider *primaryInactiveIntesityChngSlider;
    
    IBOutlet NSFormCell *secondaryInactiveFunction;
    IBOutlet NSFormCell *secondaryInactivePeriod;
    IBOutlet NSFormCell *secondaryInactivePeriodChng;
    IBOutlet NSFormCell *secondaryInactiveIntesity;
    IBOutlet NSFormCell *secondaryInactiveIntesityChng;
    IBOutlet NSSlider *secondaryInactiveIntesitySlider;
    IBOutlet NSSlider *secondaryInactiveIntesityChngSlider;
    
    IBOutlet id theLightPhases[6][7];
    __unsafe_unretained PhLight *curLight;
}

- (id)initWithLight:(PhLight*)theLight
            withLevel:(LELevelData *)theLevel
            withMapDocument:(LEMap *)theMapDoc;

- (void)registerNotifcations;

-(void)refreshInterfaceFromData;
-(BOOL)saveChanges;

- (IBAction)templateAction:(id)sender;
- (IBAction)copyFromMenuAction:(id)sender;

- (IBAction)saveBtnAction:(id)sender;
- (IBAction)saveAndCloseBtnAction:(id)sender;
- (IBAction)revertBtnAction:(id)sender;
- (IBAction)renameBtnAction:(id)sender;

@end
