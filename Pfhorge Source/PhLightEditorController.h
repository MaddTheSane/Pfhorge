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
    IBOutlet id infoIT;
    IBOutlet id nameIT;
    
    IBOutlet id templateComboMenu;
    IBOutlet id copyFromComboMenu;
    
    IBOutlet id phaseTB;
    IBOutlet id tagComboMenu;
    
    IBOutlet id statelessCB;
    IBOutlet id initalyActiveCB;
    
    // Active
    IBOutlet id becomeingActiveFunction;
    IBOutlet id becomeingActivePeriod;
    IBOutlet id becomeingActivePeriodChng;
    IBOutlet id becomeingActiveIntesity;
    IBOutlet id becomeingActiveIntesityChng;
        IBOutlet id becomeingActiveIntesitySlider;
    IBOutlet id becomeingActiveIntesityChngSlider;
    
    IBOutlet id primaryActiveFunction;
    IBOutlet id primaryActivePeriod;
    IBOutlet id primaryActivePeriodChng;
    IBOutlet id primaryActiveIntesity;
    IBOutlet id primaryActiveIntesityChng;
        IBOutlet id primaryActiveIntesitySlider;
    IBOutlet id primaryActiveIntesityChngSlider;
    
    IBOutlet id secondaryActiveFunction;
    IBOutlet id secondaryActivePeriod;
    IBOutlet id secondaryActivePeriodChng;
    IBOutlet id secondaryActiveIntesity;
    IBOutlet id secondaryActiveIntesityChng;
        IBOutlet id secondaryActiveIntesitySlider;
    IBOutlet id secondaryActiveIntesityChngSlider;
    
    // InInactive
    IBOutlet id becomeingInactiveFunction;
    IBOutlet id becomeingInactivePeriod;
    IBOutlet id becomeingInactivePeriodChng;
    IBOutlet id becomeingInactiveIntesity;
    IBOutlet id becomeingInactiveIntesityChng;
        IBOutlet id becomeingInactiveIntesitySlider;
    IBOutlet id becomeingInactiveIntesityChngSlider;
    
    IBOutlet id primaryInactiveFunction;
    IBOutlet id primaryInactivePeriod;
    IBOutlet id primaryInactivePeriodChng;
    IBOutlet id primaryInactiveIntesity;
    IBOutlet id primaryInactiveIntesityChng;
        IBOutlet id primaryInactiveIntesitySlider;
    IBOutlet id primaryInactiveIntesityChngSlider;
    
    IBOutlet id secondaryInactiveFunction;
    IBOutlet id secondaryInactivePeriod;
    IBOutlet id secondaryInactivePeriodChng;
    IBOutlet id secondaryInactiveIntesity;
    IBOutlet id secondaryInactiveIntesityChng;
        IBOutlet id secondaryInactiveIntesitySlider;
    IBOutlet id secondaryInactiveIntesityChngSlider;
    
    IBOutlet id theLightPhases[6][7];
    id	curLight;
}

- (id)initWithLight:(id)theLight
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
