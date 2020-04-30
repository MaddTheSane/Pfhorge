//
//  PhPrefsController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Aug 11 2001.
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

@class PhDynamicPrefSubController;

@interface PhPrefsController : NSWindowController
{
    IBOutlet PhDynamicPrefSubController *gridSubController;

    IBOutlet NSColorWell *polygonRegularColor;
    IBOutlet NSColorWell *polygonSelectedColor;
    IBOutlet NSColorWell *polygonPlatformColor;
    IBOutlet NSColorWell *polygonNonConcaveColor;
    IBOutlet NSColorWell *polygonHillColor;
    IBOutlet NSColorWell *polygonZoneColor;
    IBOutlet NSColorWell *polygonTeleporterExitColor;
        // Consider Moving Below To Dynamic Pref Controller
    IBOutlet NSMatrix *polygonColorTypeEnableMatrixCBs;
    
    IBOutlet NSColorWell *lineRegularColor;
    IBOutlet NSColorWell *lineSelectedColor;
    IBOutlet NSColorWell *lineConnectsPolysColor;
    
    IBOutlet NSColorWell *pointRegularColor;
    IBOutlet NSColorWell *pointSelectedColor;

    IBOutlet NSColorWell *objectSelectedColor;
    IBOutlet NSColorWell *objectItemColor;
    IBOutlet NSColorWell *objectPlayerColor;
    IBOutlet NSColorWell *objectEnemyMonsterColor;
    IBOutlet NSColorWell *objectSceanryColor;
    IBOutlet NSColorWell *objectSoundColor;
    IBOutlet NSColorWell *objectGoalColor;

    IBOutlet NSColorWell *objectBLineSelectedColor;
    IBOutlet NSColorWell *objectBLineItemColor;
    IBOutlet NSColorWell *objectBLinePlayerColor;
    IBOutlet NSColorWell *objectBLineEnemyMonsterColor;
    IBOutlet NSColorWell *objectBLineSceanryColor;
    IBOutlet NSColorWell *objectBLineSoundColor;
    IBOutlet NSColorWell *objectBLineGoalColor;
    
        // Consider Moving Below To Dynamic Pref Controller
    IBOutlet NSMatrix *objectTypeEnableMatrixCBs;

    IBOutlet NSColorWell *backgroundColor;
    IBOutlet NSColorWell *worldUnitGridColor;
    IBOutlet NSColorWell *subWorldUnitGridColor;
    IBOutlet NSColorWell *centerWorldUnitGridColor;
    
    // Visual mode Colors:
    IBOutlet NSColorWell *ceilingColor;
    IBOutlet NSColorWell *wallColor;
    IBOutlet NSColorWell *floorColor;
    IBOutlet NSColorWell *liquidColor;
    IBOutlet NSColorWell *transparentColor;
    IBOutlet NSColorWell *landscapeColor;
    IBOutlet NSColorWell *invalidSurfaceColor;
    IBOutlet NSColorWell *visualBackgroundColor;
    IBOutlet NSColorWell *wireFrameLineColor;
    
    //NSDictionary *theColors;
}
// *********************** Class Methods ***********************
+ (id)sharedPrefController;

// *********************** Regular Methods ***********************
-(void)saveColorsToPrefs;
-(void)loadColorsFromPrefs;
-(void)loadVisualModeColorsFromPrefs;

// *********************** Actions ***********************
-(IBAction)applyPrefs:(id)sender;
-(IBAction)cancelPrefs:(id)sender;
-(IBAction)resetPrefs:(id)sender;
-(IBAction)restoreDefaultColors:(id)sender;

// ***************** Visual Mode Pref Actions *****************

-(IBAction)saveVisualModeColors:(id)sender;

@end
