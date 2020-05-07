//
//  PhPrefsController.m
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

#import "PhDynamicPrefSubController.h"
#import "PhPrefsController.h"
#import "LEExtras.h"
    
@implementation PhPrefsController

- (id)init
{
    self = [super initWithWindowNibName:@"Prefs"];
      
    //theColors
    
    return self;
}

+ (void)initialize {
    // Variables
	// [preferences setInteger:[snapFromPointLengthSlider intValue] forKey:PhSnapFromLength];
    NSMutableDictionary *theMutableColors;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *appDefaults = [NSMutableDictionary
        dictionaryWithObject:@"050" forKey:PhPhorgePrefVersion];
    
    theMutableColors = [[NSMutableDictionary alloc] initWithCapacity:30];
    
    // Set the values    
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:.14 blue:0.0 alpha:1.00]) forKey:PhPolygonRegularColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.00]) forKey:PhPolygonSelectedColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.05 blue:0.58 alpha:1.00]) forKey:PhPolygonPlatformColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.75 green:0.50 blue:1.00 alpha:1.00]) forKey:PhPolygonTeleporterColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.58 blue:0.58 alpha:1.00]) forKey:PhPolygonZoneColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:1.00 green:0.00 blue:0.00 alpha:1.00]) forKey:PhPolygonNonConcaveColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.75 green:0.50 blue:0.00 alpha:1.00]) forKey:PhPolygonHillColor];
    
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.59 green:0.60 blue:1.0 alpha:1.0]) forKey:PhLineRegularColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.00 green:0.0 blue:1.0 alpha:1.0]) forKey:PhLineSelectedColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.85 blue:0.85 alpha:1.0]) forKey:PhLineConnectsPolysColor];
    
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:1.0]) forKey:PhPointRegularColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0]) forKey:PhPointSelectedColor];
    // ??? --> [theMutableColors setObject:archive([NSColor cyanColor] forKey:PhObjectSelectedColor];
    
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:.26 alpha:1.0]) forKey:PhObjectSelectedColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.36 blue:0.0 alpha:1.0]) forKey:PhObjectItemColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.31 green:0.31 blue:0.0 alpha:1.0]) forKey:PhObjectPlayerColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.14 green:0.0 blue:0.35 alpha:1.0]) forKey:PhObjectFriendlyMonsterColor];
    //[theMutableColors setObject:archive() forKey:PhObjectNeutralMonsterColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.35 green:0.0 blue:0.0 alpha:1.0]) forKey:PhObjectEnemyMonsterColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.39 green:0.0 blue:0.39 alpha:1.0]) forKey:PhObjectSceanryColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.42 blue:0.42 alpha:1.0]) forKey:PhObjectSoundColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.47 blue:0.22 alpha:1.0]) forKey:PhObjectGoalColor];
    
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0]) forKey:PhObjectBLineSelectedColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0]) forKey:PhObjectBLineItemColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:1.0]) forKey:PhObjectBLinePlayerColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.39 green:0.0 blue:1.0 alpha:1.0]) forKey:PhObjectBLineFriendlyMonsterColor];
    //[theMutableColors setObject:archive() forKey:PhObjectBLineNeutralMonsterColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0]) forKey:PhObjectBLineEnemyMonsterColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:1.0 green:0.0 blue:1.0 alpha:1.0]) forKey:PhObjectBLineSceanryColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:1.0 blue:1.0 alpha:1.0]) forKey:PhObjectBLineSoundColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.57 alpha:1.0]) forKey:PhObjectBLineGoalColor];
    
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0]) forKey:PhBackgroundColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0]) forKey:PhWorldUnitGridColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0]) forKey:PhSubWorldUnitGridColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.33 green:1.0 blue:0.33 alpha:1.0]) forKey:PhCenterWorldUnitGridColor];
    
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.5 alpha:1.0]) forKey:VMCeilingColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.0 alpha:1.0]) forKey:VMWallColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.5 green:0.0 blue:0.0 alpha:1.0]) forKey:VMFloorColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.5 blue:0.5 alpha:1.0]) forKey:VMLiquidColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0]) forKey:VMTransparentColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.5 green:1.0 blue:1.0 alpha:1.0]) forKey:VMLandscapeColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:1.0 green:0.0 blue:1.0 alpha:1.0]) forKey:VMInvalidSurfaceColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]) forKey:VMWireFrameLineColor];
    [theMutableColors setObject:archive([NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0]) forKey:VMBackGroundColor];
     
    //[appDefaults setObject:theMutableColors forKey:PhPhorgeColors];
    
    [appDefaults addEntriesFromDictionary:theMutableColors];
    
     //Test...
    [appDefaults setObject:@"Default Registration Domain..." forKey:@"TEST"];
        
    [appDefaults setObject:@YES forKey:PhEnablePlatfromPolyColoring];
    [appDefaults setObject:@YES forKey:PhEnableConvexPolyColoring];
    [appDefaults setObject:@YES forKey:PhEnableZonePolyColoring];
    [appDefaults setObject:@YES forKey:PhEnableTeleporterExitPolyColoring];
    [appDefaults setObject:@YES forKey:PhEnableHillPolyColoring];
    
    [appDefaults setObject:@YES forKey:PhEnableObjectItem];
    [appDefaults setObject:@YES forKey:PhEnableObjectPlayer];
    [appDefaults setObject:@YES forKey:PhEnableObjectEnemyMonster];
    [appDefaults setObject:@YES forKey:PhEnableObjectSceanry];
    [appDefaults setObject:@YES forKey:PhEnableObjectSound];
    [appDefaults setObject:@YES forKey:PhEnableObjectGoal];
    
    // *** Grid Defaults ***
    [appDefaults setObject:[NSNumber numberWithFloat:1]  forKey:PhGridFactor];
    [appDefaults setObject:@YES  forKey:PhEnableGridBool];
    [appDefaults setObject:@YES  forKey:PhSnapToGridBool];
    
    // *** General Defaults ***
    [appDefaults setObject:@YES  forKey:PhEnableAntialiasing];
    [appDefaults setObject:@YES  forKey:PhEnableObjectOutling];

    [appDefaults setObject:@YES forKey:PhSnapToPoints];
    [appDefaults setObject:@YES forKey:PhSnapObjectsToGrid];
    [appDefaults setObject:@NO forKey:PhSnapToLines];
    [appDefaults setObject:@YES forKey:PhSplitNonPolygonLines];
    [appDefaults setObject:@YES forKey:PhSplitPolygonLines];
    [appDefaults setObject:@YES forKey:PhSelectObjectWhenCreated];
    [appDefaults setObject:@YES forKey:PhDrawOnlyLayerPoints];
    
    [appDefaults setObject:@15 forKey:PhSnapToPointsLength];

    // *** Visual Mode Defaults ***
    [appDefaults setObject:@NO  forKey:VMInvertMouse];
    [appDefaults setObject:@33  forKey:VMKeySpeed];
    [appDefaults setObject:@1.0f  forKey:VMMouseSpeed];

    [appDefaults setObject:[NSNumber numberWithInt:0x38]  forKey:VMUpKey];
    [appDefaults setObject:[NSNumber numberWithInt:0x35]  forKey:VMDownKey];
    [appDefaults setObject:[NSNumber numberWithInt:0x34]  forKey:VMLeftKey];
    [appDefaults setObject:[NSNumber numberWithInt:0x36]  forKey:VMRightKey];
    [appDefaults setObject:[NSNumber numberWithInt:0xf700]  forKey:VMForwardKey];
    [appDefaults setObject:[NSNumber numberWithInt:0xf701]  forKey:VMBackwardKey];
    [appDefaults setObject:[NSNumber numberWithInt:0x37]  forKey:VMSlideLeftKey];
    [appDefaults setObject:[NSNumber numberWithInt:0x39]  forKey:VMSlideRightKey];
    
    
    
    [appDefaults setObject:@YES forKey:VMShowLiquids];
    [appDefaults setObject:@YES forKey:VMShowTransparent];
    [appDefaults setObject:@YES forKey:VMShowLandscapes];
    [appDefaults setObject:@YES forKey:VMShowInvalid];
    [appDefaults setObject:@NO forKey:VMUseFog];
    [appDefaults setObject:@YES forKey:VMSmoothRendering];
    [appDefaults setObject:@YES forKey:VMUseLighting];
    
    
    // LP: I would highly recemmend putting enums for these popup menus
    //		in LEExtras!
    
    [appDefaults setObject:@0  forKey:VMWhatLighting];
    [appDefaults setObject:@0  forKey:VMVisibleSide];
    [appDefaults setObject:@0  forKey:VMVerticalLook];
    [appDefaults setObject:@0  forKey:VMFieldOfView];
    [appDefaults setObject:@0  forKey:VMVisibilityMode];
    
    [appDefaults setObject:@1.0f  forKey:VMFogDepth];
    
    [appDefaults setObject:@3 forKey:VMRenderMode];
    [appDefaults setObject:@0  forKey:VMStartPosition];
     
    [appDefaults setObject:@"" forKey:VMShapesPath];
    
    //[preferences boolForKey:PhEnableAntialiasing];
    
    
    // Default Settings For Recently Added Snap-From and Angle-Snap
    [appDefaults setObject:@YES forKey:PhUseRightAngleSnap];
    [appDefaults setObject:@NO forKey:PhUseIsometricAngleSnap];
    [appDefaults setObject:@YES forKey:PhSnapFromPoints];
    [appDefaults setObject:@16  forKey:PhSnapFromLength];
    
    
    [defaults registerDefaults:appDefaults];
    NSLog(@"Done Registering The Prefrence Defaults...");
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self loadVisualModeColorsFromPrefs];
    [self loadColorsFromPrefs];
    [gridSubController mainPrefWindowLoaded];
}

// *********************** Class Methods ***********************
+ (id)sharedPrefController {
    static PhPrefsController *sharedPrefController = nil;

    if (!sharedPrefController) {
        sharedPrefController = [[PhPrefsController alloc] init];
    }

    return sharedPrefController;
}

-(void)loadVisualModeColorsFromPrefs
{
    [ceilingColor setColor:getArchColor(VMCeilingColor)];
    [wallColor setColor:getArchColor(VMWallColor)];
    [floorColor setColor:getArchColor(VMFloorColor)];
    [liquidColor setColor:getArchColor(VMLiquidColor)];
    [transparentColor setColor:getArchColor(VMTransparentColor)];
    [landscapeColor setColor:getArchColor(VMLandscapeColor)];
    [invalidSurfaceColor setColor:getArchColor(VMInvalidSurfaceColor)];
    [wireFrameLineColor setColor:getArchColor(VMWireFrameLineColor)];
    [visualBackgroundColor setColor:getArchColor(VMBackGroundColor)];
}

-(void)loadColorsFromPrefs
{
    // *** Loading Some BOOL's For A Few Matrixes ***
    
    [polygonColorTypeEnableMatrixCBs deselectAllCells];
    
    if (prefBool(PhEnablePlatfromPolyColoring))
        SelectS(polygonColorTypeEnableMatrixCBs, 1);
    if (prefBool(PhEnableConvexPolyColoring))
        SelectS(polygonColorTypeEnableMatrixCBs, 2);
    if (prefBool(PhEnableZonePolyColoring))
        SelectS(polygonColorTypeEnableMatrixCBs, 3);
    if (prefBool(PhEnableTeleporterExitPolyColoring))
        SelectS(polygonColorTypeEnableMatrixCBs, 4);
    if (prefBool(PhEnableHillPolyColoring))
        SelectS(polygonColorTypeEnableMatrixCBs, 5);
    
    [objectTypeEnableMatrixCBs deselectAllCells];
    
    if (prefBool(PhEnableObjectItem))
        SelectS(objectTypeEnableMatrixCBs, 1);
    if (prefBool(PhEnableObjectPlayer))
        SelectS(objectTypeEnableMatrixCBs, 2);
    if (prefBool(PhEnableObjectEnemyMonster))
        SelectS(objectTypeEnableMatrixCBs, 3);
    if (prefBool(PhEnableObjectSceanry))
        SelectS(objectTypeEnableMatrixCBs, 4);
    if (prefBool(PhEnableObjectSound))
        SelectS(objectTypeEnableMatrixCBs, 5);
    if (prefBool(PhEnableObjectGoal))
        SelectS(objectTypeEnableMatrixCBs, 6);
    
    // *** Loading Colors ***
    
    [polygonRegularColor setColor:getArchColor(PhPolygonRegularColor)];
    [polygonSelectedColor setColor:getArchColor(PhPolygonSelectedColor)];
    [polygonPlatformColor setColor:getArchColor(PhPolygonPlatformColor)];
    [polygonNonConcaveColor setColor:getArchColor(PhPolygonNonConcaveColor)];
    [polygonTeleporterExitColor setColor:getArchColor(PhPolygonTeleporterColor)];
    [polygonZoneColor setColor:getArchColor(PhPolygonZoneColor)];
    [polygonHillColor setColor:getArchColor(PhPolygonHillColor)];
    
    [lineRegularColor setColor:getArchColor(PhLineRegularColor)];
    [lineSelectedColor setColor:getArchColor(PhLineSelectedColor)];
    [lineConnectsPolysColor setColor:getArchColor(PhLineConnectsPolysColor)];
    
    [pointRegularColor setColor:getArchColor(PhPointRegularColor)];
    [pointSelectedColor setColor:getArchColor(PhPointSelectedColor)];
    
    [objectSelectedColor setColor:getArchColor(PhObjectSelectedColor)];
    [objectItemColor setColor:getArchColor(PhObjectItemColor)];
    [objectPlayerColor setColor:getArchColor(PhObjectPlayerColor)];
    //[objectFriendlyMonsterColor setColor:getArchColor(PhObjectFriendlyMonsterColor)];
    //[objectNeutralMonsterColor setColor:getArchColor(PhObjectNeutralMonsterColor)];
    [objectEnemyMonsterColor setColor:getArchColor(PhObjectEnemyMonsterColor)];
    [objectSceanryColor setColor:getArchColor(PhObjectSceanryColor)];
    [objectSoundColor setColor:getArchColor(PhObjectSoundColor)];
    [objectGoalColor setColor:getArchColor(PhObjectGoalColor)];
    
    [objectBLineSelectedColor setColor:getArchColor(PhObjectBLineSelectedColor)];
    [objectBLineItemColor setColor:getArchColor(PhObjectBLineItemColor)];
    [objectBLinePlayerColor setColor:getArchColor(PhObjectBLinePlayerColor)];
    //[objectBLineFriendlyMonsterColor setColor:getArchColor(PhObjectBLineFriendlyMonsterColor)];
    //[objectBLineNeutralMonsterColor setColor:getArchColor(PhObjectBLineNeutralMonsterColor)];
    [objectBLineEnemyMonsterColor setColor:getArchColor(PhObjectBLineEnemyMonsterColor)];
    [objectBLineSceanryColor setColor:getArchColor(PhObjectBLineSceanryColor)];
    [objectBLineSoundColor setColor:getArchColor(PhObjectBLineSoundColor)];
    [objectBLineGoalColor setColor:getArchColor(PhObjectBLineGoalColor)];
    
    [backgroundColor setColor:getArchColor(PhBackgroundColor)];
    [worldUnitGridColor setColor:getArchColor(PhWorldUnitGridColor)];
    [subWorldUnitGridColor setColor:getArchColor(PhSubWorldUnitGridColor)];
    [centerWorldUnitGridColor setColor:getArchColor(PhCenterWorldUnitGridColor)];
    
    NSLog(@"done loading the colors...");
}

-(void)saveColorsToPrefs
{
   //NSMutableDictionary *colorDictionary = [[NSMutableDictionary alloc] initWithCapacity:30];
    
    // *** Saving Some BOOL's From A Few Matrixes ***
    NSLog(@"Saving other prefs..."); 
    
    [preferences setBool:SState(polygonColorTypeEnableMatrixCBs, 1) forKey:PhEnablePlatfromPolyColoring];
    [preferences setBool:SState(polygonColorTypeEnableMatrixCBs, 2) forKey:PhEnableConvexPolyColoring];
    [preferences setBool:SState(polygonColorTypeEnableMatrixCBs, 3) forKey:PhEnableZonePolyColoring];
    [preferences setBool:SState(polygonColorTypeEnableMatrixCBs, 4) forKey:PhEnableTeleporterExitPolyColoring];
    [preferences setBool:SState(polygonColorTypeEnableMatrixCBs, 5) forKey:PhEnableHillPolyColoring];
    
    [preferences setBool:SState(objectTypeEnableMatrixCBs, 1) forKey:PhEnableObjectItem];
    [preferences setBool:SState(objectTypeEnableMatrixCBs, 2) forKey:PhEnableObjectPlayer];
    [preferences setBool:SState(objectTypeEnableMatrixCBs, 3) forKey:PhEnableObjectEnemyMonster];
    [preferences setBool:SState(objectTypeEnableMatrixCBs, 4) forKey:PhEnableObjectSceanry];
    [preferences setBool:SState(objectTypeEnableMatrixCBs, 5) forKey:PhEnableObjectSound];
    [preferences setBool:SState(objectTypeEnableMatrixCBs, 6) forKey:PhEnableObjectGoal];
    
    NSLog(@"Saving the colors prefs..."); //26
    
    setArchColor(PhPolygonRegularColor, [polygonRegularColor color]);
    setArchColor(PhPolygonSelectedColor, [polygonSelectedColor color]);
    setArchColor(PhPolygonPlatformColor, [polygonPlatformColor color]);
    setArchColor(PhPolygonNonConcaveColor, [polygonNonConcaveColor color]);
    setArchColor(PhPolygonHillColor, [polygonHillColor color]);
    setArchColor(PhPolygonZoneColor, [polygonZoneColor color]);
    setArchColor(PhPolygonTeleporterColor, [polygonTeleporterExitColor color]);
    
    setArchColor(PhLineRegularColor, [lineRegularColor color]);
    setArchColor(PhLineSelectedColor, [lineSelectedColor color]);
    setArchColor(PhLineConnectsPolysColor, [lineConnectsPolysColor color]);
    
    setArchColor(PhPointRegularColor, [pointRegularColor color]);
    setArchColor(PhPointSelectedColor, [pointSelectedColor color]);
    
    setArchColor(PhObjectSelectedColor, [objectSelectedColor color]);
    setArchColor(PhObjectItemColor, [objectItemColor color]);
    setArchColor(PhObjectPlayerColor, [objectPlayerColor color]);
    //setArchColor(PhObjectFriendlyMonsterColor, [objectFriendlyMonsterColor color]);
    //setArchColor(PhObjectNeutralMonsterColor, [objectNeutralMonsterColor color]);
    setArchColor(PhObjectEnemyMonsterColor, [objectEnemyMonsterColor color]);
    setArchColor(PhObjectSceanryColor, [objectSceanryColor color]);
    setArchColor(PhObjectSoundColor, [objectSoundColor color]);
    setArchColor(PhObjectGoalColor, [objectGoalColor color]);
    
    setArchColor(PhObjectBLineSelectedColor, [objectBLineSelectedColor color]);
    setArchColor(PhObjectBLineItemColor, [objectBLineItemColor color]);
    setArchColor(PhObjectBLinePlayerColor, [objectBLinePlayerColor color]);
    //setArchColor(PhObjectBLineFriendlyMonsterColor, [objectBLineFriendlyMonsterColor color]);
    //setArchColor(PhObjectBLineNeutralMonsterColor, [objectBLineNeutralMonsterColor color]);
    setArchColor(PhObjectBLineEnemyMonsterColor, [objectBLineEnemyMonsterColor color]);
    setArchColor(PhObjectBLineSceanryColor, [objectBLineSceanryColor color]);
    setArchColor(PhObjectBLineSoundColor, [objectBLineSoundColor color]);
    setArchColor(PhObjectBLineGoalColor, [objectBLineGoalColor color]);
    
    setArchColor(PhBackgroundColor, [backgroundColor color]);
    setArchColor(PhWorldUnitGridColor, [worldUnitGridColor color]);
    setArchColor(PhSubWorldUnitGridColor, [subWorldUnitGridColor color]);
    setArchColor(PhCenterWorldUnitGridColor, [centerWorldUnitGridColor color]);
    
    //[preferences synchronize];
    
    //NSLog(@"Done saveing the colors, loading them back into interface to confirm...");
    //[self loadColorsFromPrefs];
    //NSLog(@"Crashing at point 1...");
    
    NSLog(@"Sending PhUserDidChangePrefs Notication...");
    [[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePrefs object:nil];
    NSLog(@"Sent!");
    /*
    [numberTable addEntriesFromDictionary:
            [NSDictionary dictionaryWithObject:
                                        forKey:curNumber ]];
    
    NSData *theColors = [NSArchiver archivedDataWithRootObject:theDictionary];
    */
}

// *********************** Actions ***********************

-(IBAction)saveVisualModeColors:(id)sender
{
    setArchColor(VMCeilingColor, [ceilingColor color]);
    setArchColor(VMWallColor, [wallColor color]);
    setArchColor(VMFloorColor, [floorColor color]);
    setArchColor(VMLiquidColor, [liquidColor color]);
    setArchColor(VMTransparentColor, [transparentColor color]);
    setArchColor(VMLandscapeColor, [landscapeColor color]);
    setArchColor(VMInvalidSurfaceColor, [invalidSurfaceColor color]);
    setArchColor(VMWireFrameLineColor, [wireFrameLineColor color]);
    setArchColor(VMBackGroundColor, [visualBackgroundColor color]);
}

-(IBAction)applyPrefs:(id)sender { [self saveColorsToPrefs]; NSLog(@"Passing point 2b...");}
-(IBAction)cancelPrefs:(id)sender { NSLog(@"Passing Point 3...");[self loadColorsFromPrefs]; }
-(IBAction)resetPrefs:(id)sender { }
-(IBAction)restoreDefaultColors:(id)sender
{
    [polygonRegularColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.14 blue:0.0 alpha:1.00]];
    [polygonSelectedColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.00]];
    [polygonPlatformColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.58 blue:0.0 alpha:1.00]];
    [polygonNonConcaveColor setColor:[NSColor colorWithCalibratedRed:1.00 green:0.00 blue:0.00 alpha:1.00]];
    [polygonHillColor setColor:[NSColor colorWithCalibratedRed:0.75 green:0.50 blue:0.00 alpha:1.00]];
    [polygonZoneColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.58 blue:0.58 alpha:1.00]];
    [polygonTeleporterExitColor setColor:[NSColor colorWithCalibratedRed:0.75 green:0.50 blue:1.00 alpha:1.00]];
    
    [lineRegularColor setColor:[NSColor colorWithCalibratedRed:0.59 green:0.60 blue:1.0 alpha:1.0]];
    [lineSelectedColor setColor:[NSColor colorWithCalibratedRed:0.00 green:0.0 blue:1.0 alpha:1.0]];
    [lineConnectsPolysColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.85 blue:0.85 alpha:1.0]];
    
    [pointRegularColor setColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:1.0]];
    [pointSelectedColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0]];
    
    [objectSelectedColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.26 alpha:1.0]];
    [objectItemColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.36 blue:0.0 alpha:1.0]];
    [objectPlayerColor setColor:[NSColor colorWithCalibratedRed:0.31 green:0.31 blue:0.0 alpha:1.0]];
    //[objectFriendlyMonsterColor setColor:[NSColor colorWithCalibratedRed:0.14 green:0.0 blue:0.35 alpha:1.0]];
    //[objectNeutralMonsterColor setColor:[NSColor redColor]];
    [objectEnemyMonsterColor setColor:[NSColor colorWithCalibratedRed:0.35 green:0.0 blue:0.0 alpha:1.0]];
    [objectSceanryColor setColor:[NSColor colorWithCalibratedRed:0.39 green:0.0 blue:0.39 alpha:1.0]];
    [objectSoundColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.42 blue:0.42 alpha:1.0]];
    [objectGoalColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.47 blue:0.22 alpha:1.0]];
    
    [objectBLineSelectedColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0]];
    [objectBLineItemColor setColor:[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0]];
    [objectBLinePlayerColor setColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.0 alpha:1.0]];
    //[objectBLineFriendlyMonsterColor setColor:[NSColor colorWithCalibratedRed:0.39 green:0.0 blue:1.0 alpha:1.0]];
    //[objectBLineNeutralMonsterColor setColor:[NSColor redColor]];
    [objectBLineEnemyMonsterColor setColor:[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
    [objectBLineSceanryColor setColor:[NSColor colorWithCalibratedRed:1.0 green:0.0 blue:1.0 alpha:1.0]];
    [objectBLineSoundColor setColor:[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:1.0 alpha:1.0]];
    [objectBLineGoalColor setColor:[NSColor colorWithCalibratedRed:0.0 green:1.0 blue:0.57 alpha:1.0]];
    
    [backgroundColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    [worldUnitGridColor setColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0]];
    [subWorldUnitGridColor setColor:[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.0]];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:PhUserDidChangePrefs object:nil];
}

@end
