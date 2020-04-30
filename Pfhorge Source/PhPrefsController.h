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

@interface PhPrefsController : NSWindowController
{
    IBOutlet id gridSubController;

    IBOutlet id polygonRegularColor;
    IBOutlet id polygonSelectedColor;
    IBOutlet id polygonPlatformColor;
    IBOutlet id polygonNonConcaveColor;
    IBOutlet id polygonHillColor;
    IBOutlet id polygonZoneColor;
    IBOutlet id polygonTeleporterExitColor;
        // Consider Moving Below To Dynamic Pref Controller
    IBOutlet id polygonColorTypeEnableMatrixCBs;
    
    IBOutlet id lineRegularColor;
    IBOutlet id lineSelectedColor;
    IBOutlet id lineConnectsPolysColor;
    
    IBOutlet id pointRegularColor;
    IBOutlet id pointSelectedColor;

    IBOutlet id objectSelectedColor;
    IBOutlet id objectItemColor;
    IBOutlet id objectPlayerColor;
    IBOutlet id objectEnemyMonsterColor;
    IBOutlet id objectSceanryColor;
    IBOutlet id objectSoundColor;
    IBOutlet id objectGoalColor;

    IBOutlet id objectBLineSelectedColor;
    IBOutlet id objectBLineItemColor;
    IBOutlet id objectBLinePlayerColor;
    IBOutlet id objectBLineEnemyMonsterColor;
    IBOutlet id objectBLineSceanryColor;
    IBOutlet id objectBLineSoundColor;
    IBOutlet id objectBLineGoalColor;
    
        // Consider Moving Below To Dynamic Pref Controller
    IBOutlet id objectTypeEnableMatrixCBs;

    IBOutlet id backgroundColor;
    IBOutlet id worldUnitGridColor;
    IBOutlet id subWorldUnitGridColor;
    IBOutlet id centerWorldUnitGridColor;
    
    // Visual mode Colors:
    IBOutlet id ceilingColor;
    IBOutlet id wallColor;
    IBOutlet id floorColor;
    IBOutlet id liquidColor;
    IBOutlet id transparentColor;
    IBOutlet id landscapeColor;
    IBOutlet id invalidSurfaceColor;
    IBOutlet id visualBackgroundColor;
    IBOutlet id wireFrameLineColor;
    
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
