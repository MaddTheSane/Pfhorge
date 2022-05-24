//
//  PhLineInspectorController.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon Jul 16 2001.
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

#import "PhLineInspectorController.h"

//Document Class
#import "LEMap.h"

//View and Controller Classes...
#import "LELevelWindowController.h"
#import "LEMapDraw.h"
#import "PhPlatformSheetController.h"
#import "PhTextureInspectorController.h"

//Main Super Inspector Controller
#import "LEInspectorController.h"

//Data Classes...
#import "LELevelData.h"
#import "LEMapObject.h"
#import "LEMapPoint.h"
#import "LEPolygon.h"
#import "LELine.h"
#import "LESide.h"
#import "PhTag.h"
#import "PhLight.h"
#import "Terminal.h"

//Other Classes...
#import "LEExtras.h"


@implementation PhLineInspectorController

- (id)init
{
    self = [super initWithWindow:lightWindow];
    if (self == nil)
        return nil;
    

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateObjectValuesOfComboMenus)
    //    name:PhUserDidChangeNamesNotification object:nil];
    
    prevEnviroCode = -1; // Change to NONE sometime!!!
    return self;
}

- (void)dealloc
{
    [[self window] saveFrameUsingName:@"Inspector2"];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[self window] setFrameUsingName:@"Inspector2"];
    [self setWindowFrameAutosaveName:@"Inspector2"];
    [[self window] setFrameAutosaveName:@"Inspector2"];
    
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
}

- (void)reset
{
    theCurrentSelection = nil;
    cSide = nil;
    ccSide = nil;
    baseSideRef = nil;
}

-(void)updateLineInterface
{    
    BOOL lSolid, lTransparent, lLandscape, doNotAutoSetFlags; //lTransparentSide;
    BOOL sIsControlPanel, sIsReapirSwitch, sIsDestructiveSwitch;
    BOOL sIsLightedSwitch, sCanBeDestroyed, sOnlyToggledByProjectiles;
    BOOL sIsInitalyOn, lHasSide;
    LEPolygon *cPoly, *ccPoly;
    
    LELevelData *theLevelData = [mainInspectorController currentLevel];
    
    unsigned short lineFlagsNumber;
    
    theCurrentSelection = [mainInspectorController getTheCurrentSelection];
    lineFlagsNumber = [theCurrentSelection flags];
    cPoly = [theCurrentSelection clockwisePolygonObject];
    ccPoly = [theCurrentSelection conterclockwisePolygonObject];
    
    [lineBox setTitle:[NSString stringWithFormat:@"Line Index: %d", [theCurrentSelection index]]];
    //[lineBox setTitle:[[NSNumber numberWithShort:[theCurrentSelection index]] stringValue]];
    
    lSolid 		= (([theCurrentSelection flags] & 0x4000) ? YES : NO);
    lTransparent 	= (([theCurrentSelection flags] & 0x2000) ? YES : NO);
    lLandscape 		= (([theCurrentSelection flags] & 0x1000) ? YES : NO);
    //lTransparentSide 	= (([theCurrentSelection flags] & 0x200) ? YES : NO);
    
    doNotAutoSetFlags	= [theCurrentSelection getPermanentSetting:LELinePermanentUse];
    
    cSide = [theCurrentSelection clockwisePolygonSideObject];
    ccSide = [theCurrentSelection counterclockwisePolygonSideObject];
    
    [lineFlags deselectAllCells];
    [emptyFlag setState:NSControlStateValueOff];
    [lineControlPanelFlags deselectAllCells];
    
    if (lineFlagsNumber & LELineSolid)
        SelectS(lineFlags, 1);
    if (lineFlagsNumber & LELineTransparent)
        SelectS(lineFlags, 2);
    if (lineFlagsNumber & LELineLandscape)
        SelectS(lineFlags, 3);
    
    if (doNotAutoSetFlags == NO)
        SelectS(lineFlags, 4);
    
    // Updates The Texture Inspector...
    [textureInspectorController updateLineTextureAndLightMenus];
    
    /*if (cSide != nil)
        baseSideRef = cSide;
    else if (ccSide != nil)
        baseSideRef = ccSide;
    else
        baseSideRef = nil;*/
        
    baseSideRef = [textureInspectorController currentBaseSideRef];
    
    if (baseSideRef == nil)
    {
        lHasSide = NO;
        [emptyFlag setState:NSControlStateValueOn];
        [linePrimaryLight setEnabled:NO];
        [lineSecondaryLight setEnabled:NO];
        [lineTransparentLight setEnabled:NO];
        [lineIsControlPanel setEnabled:NO];
        
        [lineIsControlPanel setState:NSControlStateValueOff];
        [lineControlPanelFlags setEnabledOfMatrixCellsTo:NO];
        [lineControlPanelType setEnabled:NO];
        [linePermutation setEnabled:NO];
        
        //[textureOffsetMatrix setEnabledOfMatrixCellsTo:NO];
        
        //[primaryTextureMenu setEnabled:NO];
        //[secondaryTextureMenu setEnabled:NO];
        //[transparentTextureMenu setEnabled:NO];
    }
    else //if (baseSideRef != nil)
    {
        //struct side_texture_definition primaryTex; 	//= [baseSideRef primaryTextureStruct];
        //struct side_texture_definition secondaryTex; 	//= [baseSideRef secondaryTextureStruct];
        //struct side_texture_definition transparentTex; 	//= [baseSideRef transparentTextureStruct];
        
        /*
	LESideFull,	// primary texture is mapped floor-to-ceiling
	LESideHigh, 	// primary texture is mapped on a panel coming down from the ceiling (implies 2 adjacent polygons)
	LESideLow, 	// primary texture is mapped on a panel coming up from the floor (implies 2 adjacent polygons)
	LESideComposite,// primary texture is mapped floor-to-ceiling, secondary texture is mapped into it (i.e., control panel)
	LESideSplit 	// primary texture is mapped onto a panel coming down from the ceiling,
                        // secondary texture is mapped on a panel coming up from the floor
        */
        
        
        //short		x0, y0;
        //short int	textureCollection;
        //short int	textureNumber;
        
        lHasSide = YES;
        
        [linePrimaryLight setEnabled:YES];
        [lineSecondaryLight setEnabled:YES];
        [lineTransparentLight setEnabled:YES];
        [lineIsControlPanel setEnabled:YES];
        
        sIsInitalyOn			= [baseSideRef getFlagS:1];
        sIsControlPanel 		= [baseSideRef getFlagS:2];
        sIsReapirSwitch			= [baseSideRef getFlagS:3];
        sIsDestructiveSwitch		= [baseSideRef getFlagS:4];
        sIsLightedSwitch		= [baseSideRef getFlagS:5];
        sCanBeDestroyed			= [baseSideRef getFlagS:6];
        sOnlyToggledByProjectiles	= [baseSideRef getFlagS:7];
	
        //[linePrimaryLight selectItemAtIndex:[baseSideRef primaryLightsourceIndex]];
        //[lineSecondaryLight selectItemAtIndex:[baseSideRef secondaryLightsourceIndex]];
        //[lineTransparentLight selectItemAtIndex:[baseSideRef transparentLightsourceIndex]];
        
        //[linePrimaryLight setObjectValue:[linePrimaryLight objectValueOfSelectedItem]];
        //[lineSecondaryLight  setObjectValue:[lineSecondaryLight objectValueOfSelectedItem]];
        //[lineTransparentLight  setObjectValue:[lineTransparentLight objectValueOfSelectedItem]];
        
        if (sIsControlPanel)
        {
            BOOL enviromentChanged = NO;
            int controlPanelType = -1;
            int permutationEffects = 0;
            NSInteger terminalIndex = -1;
            
            [lineIsControlPanel setState:NSControlStateValueOn];
            
            [lineControlPanelFlags setEnabledOfMatrixCellsTo:YES];
            [lineControlPanelType setEnabled:YES];
            [linePermutation setEnabled:YES];
            
            if (sIsInitalyOn)
                SelectS(lineControlPanelFlags, 1);
            if (sIsReapirSwitch)
                SelectS(lineControlPanelFlags, 2);
            if (sIsDestructiveSwitch)
                SelectS(lineControlPanelFlags, 3);
            if (sIsLightedSwitch)
                SelectS(lineControlPanelFlags, 4);
            if (sCanBeDestroyed)
                SelectS(lineControlPanelFlags, 5);
            if (sOnlyToggledByProjectiles)
                SelectS(lineControlPanelFlags, 6);
                
            ///NSLog(@"Control Panel Type: %d", [baseSideRef controlPanelType]);
            
            if (prevEnviroCode != [[mainInspectorController currentLevel] environmentCode])
            {
                enviromentChanged = YES;
                prevEnviroCode = [[mainInspectorController currentLevel] environmentCode];
                [lineControlPanelType removeAllItems];
            }
            
            if (theWaterNames == nil || theLavaNames == nil ||
                theSewageNames == nil || thePfhorNames == nil ||
                theJjaroNames == nil)
                {
                    [self setupTheControlPanelNames];
                }
            
            switch (prevEnviroCode)
            {
                case _water:
                    if (enviromentChanged) [lineControlPanelType addItemsWithTitles:theWaterNames];
                    controlPanelType = ([baseSideRef controlPanelType] - waterOffset);
                    [lineControlPanelType selectItemAtIndex:controlPanelType];
                    break;
                case _lava:
                    if (enviromentChanged) [lineControlPanelType addItemsWithTitles:theLavaNames];
                    controlPanelType = ([baseSideRef controlPanelType] - lavaOffset);
                    [lineControlPanelType selectItemAtIndex:controlPanelType];
                    break;
                case _sewage:
                    if (enviromentChanged) [lineControlPanelType addItemsWithTitles:theSewageNames];
                    controlPanelType = ([baseSideRef controlPanelType] - sewageOffset);
                    [lineControlPanelType selectItemAtIndex:controlPanelType];
                    break;
                case _jjaro:
                    if (enviromentChanged) [lineControlPanelType addItemsWithTitles:thePfhorNames];
                    controlPanelType = ([baseSideRef controlPanelType] - jjaroOffset);
                    ///NSLog(@"lineControlPanelType: %d", controlPanelType);
                    [lineControlPanelType selectItemAtIndex:controlPanelType];
                    break;
                case _pfhor:
                    if (enviromentChanged) [lineControlPanelType addItemsWithTitles:theJjaroNames];
                    controlPanelType = ([baseSideRef controlPanelType] - pfhorOffset);
                    [lineControlPanelType selectItemAtIndex:controlPanelType];
                    break;
                default:
                    NSLog(@"When updating the control panel inspector, encountered an unknown enviromental code...");
                    return;
                    break;
            }
            
            if (prevEnviroCode == _water)
                switch(controlPanelType)
                {
                    case 3:
                    case 6:
                    case 9:
                        permutationEffects = _cpanel_effects_tag;
                        break;
                    case 4:
                        permutationEffects = _cpanel_effects_light;      
                        break;
                    case 5:
                        permutationEffects = _cpanel_effects_polygon;
                        break;
                    case 8:
                        permutationEffects = _cpanel_effects_terminal;
                        break;
                }
            else
            {
                switch(controlPanelType)
                {
                    case 5:
                    case 9:
                    case 10:
                        permutationEffects = _cpanel_effects_tag;
                        break;
                    case 3:
                        permutationEffects = _cpanel_effects_light;      
                        break;
                    case 4:
                        permutationEffects = _cpanel_effects_polygon;
                        break;
                    case 7:
                        permutationEffects = _cpanel_effects_terminal;
                        break;
                }
            }
            
            // Cache Previous Type???
            [theLevelData removeMenu:linePermutation];
            
            switch(permutationEffects)
            {
                case 0:
                    [linePermutation selectItemAtIndex:-1];
                    [linePermutation removeAllItems];
                    break;
                case _cpanel_effects_tag:
                    [theLevelData addMenu:linePermutation asMenuType:PhLevelNameMenuTag];
                    [linePermutation selectItemAtIndex:[[theLevelData tags]
                        indexOfObjectIdenticalTo:[baseSideRef controlPanelPermutationObject]]];
                    break;
                case _cpanel_effects_light:
                    [theLevelData addMenu:linePermutation asMenuType:PhLevelNameMenuLight];
                    [linePermutation selectItemAtIndex:[[theLevelData lights]
                        indexOfObjectIdenticalTo:[baseSideRef controlPanelPermutationObject]]];
                    break;
                case _cpanel_effects_polygon:
                    [theLevelData addMenu:linePermutation asMenuType:PhLevelNameMenuPolygon];
                    [linePermutation selectItemAtIndex:-1];
                    
    //IBOutlet id linePermutation;
    //IBOutlet id linePermutationTextBox;
    //IBOutlet id linePermutationTabView;
                    
                    {
                        NSInteger objIndex = [[theLevelData namedPolyObjects] indexOfObjectIdenticalTo:[baseSideRef controlPanelPermutationObject]];
                        
                        if (objIndex < 0)
                            [linePermutation selectItemAtIndex:-1];
                        else
                            [linePermutation selectItemAtIndex:objIndex];
                    }
                    
                    // Got to get the index from the names polygon list...
                    
                    //[linePermutation selectItemAtIndex:[[theLevelData getThePolys]
                        //indexOfObjectIdenticalTo:[baseSideRef controlPanelPermutationObject]]];
                    break;
                case _cpanel_effects_terminal:
                    terminalIndex = [[theLevelData terminals] 
                                indexOfObjectIdenticalTo:[baseSideRef controlPanelPermutationObject]];
                    
                    [theLevelData addMenu:linePermutation asMenuType:PhLevelNameMenuTerminal];
                    
                    if ([linePermutation numberOfItems] > terminalIndex &&  terminalIndex >= -1)
                        [linePermutation selectItemAtIndex:terminalIndex];
                    else
                    {
                        [linePermutation selectItemAtIndex:-1];
                        //SEND_ERROR_MSG_TITLE(([NSString stringWithFormat:@"Unknown Terminal Index: %d, this terminal is not a terminal Pfhorge knows about.  I am asumming the terminal is in an external file and not within this Pfhorge map. I will leave the index number alone for right now, I will have a better way to handle this in the near future.", terminalIndex, nil]), (@"Terminal Beyond Bounds"));
                    }
                    
                    break;
                default:
                    [linePermutation selectItemAtIndex:-1];
                    [linePermutation removeAllItems];
                    NSLog(@"Error: unkown _cpanel_effect in updateLineInterface in PhLineInspectorController");
                    break;
            }
            
            //[linePermutation setObjectValue:[[NSNumber numberWithShort:[baseSideRef controlPanelPermutation]] stringValue]];
        }
        else
        {
            [lineIsControlPanel setState:NSControlStateValueOff];
            [lineControlPanelFlags setEnabledOfMatrixCellsTo:NO];
            [lineControlPanelType setEnabled:NO];
            [linePermutation setEnabled:NO];
        }        
    } // END else //if (baseSideRef != nil)
}

- (void)updateObjectValuesOfComboMenus
{
    //[linePrimaryLight setObjectValue:[linePrimaryLight objectValueOfSelectedItem]];
    //[lineSecondaryLight  setObjectValue:[lineSecondaryLight objectValueOfSelectedItem]];
    //[lineTransparentLight  setObjectValue:[lineTransparentLight objectValueOfSelectedItem]];
    //[lineControlPanelType setObjectValue:[lineControlPanelType objectValueOfSelectedItem]];
    //[linePermutation setObjectValue:[[NSNumber numberWithShort:[baseSideRef controlPanelPermutation]] stringValue]];
}

- (void)saveControlPanelFlags
{
    id sender = lineControlPanelFlags;
    unsigned short theFlags = 0;
    
    theFlags |= LESideIsControlPanel;
        
    if SState(sender, 1) (theFlags |= LESideControlPanelStatus);
    if SState(sender, 2) (theFlags |= LESideIsRepairSwitch);
    if SState(sender, 3) (theFlags |= LESideIsDestructiveSwitch);
    if SState(sender, 4) (theFlags |= LESideIsLightedSwitch);
    if SState(sender, 5) (theFlags |= LESideSwitchCanBeDestroyed);
    if SState(sender, 6) (theFlags |= LESideSwitchCanOnlyBeByProjectiles);
    
    // ((v) ? ((i) |= (b)) : ((i) &= ~(b))
    
    [baseSideRef setFlags:theFlags];
    //[ccSide setFlags:theFlags];
}

// *************************** Actions ***************************

- (IBAction)controlPanelStatusAction:(id)sender
{
    if ([sender state] == NSControlStateValueOn)
    {
        [lineControlPanelType selectItemAtIndex:0];
        [self controlPanelTypeAction:lineControlPanelType];
        
        [self saveControlPanelFlags];
        [lineControlPanelFlags setEnabledOfMatrixCellsTo:YES];
        [lineControlPanelType setEnabled:YES];
        [linePermutation setEnabled:YES];
    }
    else
    {
        [baseSideRef setFlags:0];
        //[ccSide setFlags:0];
        [baseSideRef setControlPanelPermutationObject:nil];
        //[ccSide setControlPanelPermutationObject:nil];
        [baseSideRef setControlPanelType:0];
        //[ccSide setControlPanelType:0];
        
        [lineControlPanelFlags setEnabledOfMatrixCellsTo:NO];
        [lineControlPanelType setEnabled:NO];
        [linePermutation setEnabled:NO];
    }
    
    [self updateLineInterface];
}

- (IBAction)controlPanelTypeAction:(id)sender
{
    switch ([[mainInspectorController currentLevel] environmentCode])
    {
        case _water:
            [baseSideRef  setControlPanelType:([sender indexOfSelectedItem] + waterOffset)];
            //[ccSide  setControlPanelType:([sender indexOfSelectedItem] + waterOffset)];
            break;
        case _lava:
            [baseSideRef  setControlPanelType:([sender indexOfSelectedItem] + lavaOffset)];
            //[ccSide  setControlPanelType:([sender indexOfSelectedItem] + lavaOffset)];
            break;
        case _sewage:
            [baseSideRef  setControlPanelType:([sender indexOfSelectedItem] + sewageOffset)];
            //[ccSide  setControlPanelType:([sender indexOfSelectedItem] + sewageOffset)];
            break;
        case _jjaro:
            [baseSideRef  setControlPanelType:([sender indexOfSelectedItem] + jjaroOffset)];
            //[ccSide  setControlPanelType:([sender indexOfSelectedItem] + jjaroOffset)];
            break;
        case _pfhor:
            [baseSideRef  setControlPanelType:([sender indexOfSelectedItem] + pfhorOffset)];
            //[ccSide  setControlPanelType:([sender indexOfSelectedItem] + pfhorOffset)];
            break;
        default:
            SEND_ERROR_MSG(@"ERROR: An unknown contol panel type Attempted to be selected...");
            break;
    }
    
    [self updateLineInterface];
}

- (IBAction)controlPanelPermutationAction:(id)sender
{
    LELevelData *theLevelData = [mainInspectorController currentLevel];
    
    switch([baseSideRef permutationEffects])
    {
        case 0:
            [linePermutation selectItemAtIndex:-1];
            [linePermutation removeAllItems];
            break;
        case _cpanel_effects_tag:
            [baseSideRef setControlPanelPermutationObject:
                [[theLevelData tags] objectAtIndex:[sender indexOfSelectedItem]]];
            break;
        case _cpanel_effects_light:
            [baseSideRef setControlPanelPermutationObject:
                [[theLevelData lights] objectAtIndex:[sender indexOfSelectedItem]]];
            break;
        case _cpanel_effects_polygon:
            //[linePermutation selectItemAtIndex:-1];
            
    //IBOutlet id linePermutation;
    //IBOutlet id linePermutationTextBox;
    //IBOutlet id linePermutationTabView;
            
            {
                NSInteger objIndex = [sender indexOfSelectedItem];
                
                if (objIndex < 0)
                    [baseSideRef setControlPanelPermutationObject:nil];
                else
                    [baseSideRef setControlPanelPermutationObject:[[theLevelData namedPolyObjects] objectAtIndex:objIndex]];
            }
            
            // Got to get the index from the names polygon list...
            
            //[linePermutation selectItemAtIndex:[[theLevelData getThePolys]
                //indexOfObjectIdenticalTo:[baseSideRef controlPanelPermutationObject]]];
            break;
        case _cpanel_effects_terminal:
            [baseSideRef setControlPanelPermutationObject:
                [[theLevelData terminals] objectAtIndex:[sender indexOfSelectedItem]]];
            break;
        default:
            [linePermutation selectItemAtIndex:-1];
            [linePermutation removeAllItems];
            NSLog(@"Error: unkown _cpanel_effect in controlPanelPermutationAction in PhLineInspectorController");
            break;
    }
    
    [self updateLineInterface];
}

- (IBAction)regularFlagsAction:(id)sender
{
    unsigned short theFlags = 0;
    
    LELine *curLine = [mainInspectorController getTheCurrentSelection];
    
    //- (BOOL)getPermanentSetting:LELinePermanentUse;
    //- (void)setPermanentSetting:(int)settingToSet to:(BOOL)value;
    
    if SState(sender, 4)
    {
        [curLine setPermanentSetting:LELinePermanentUse to:NO];
    }
    else
    {
        [curLine setPermanentSetting:LELinePermanentUse to:YES];
    }
    
    if SState(sender, 1)
    {
        [curLine setPermanentSetting:LELinePermanentSolid to:YES];
        theFlags |= 0x4000;
    }
    else
    {
        [curLine setPermanentSetting:LELinePermanentSolid to:NO];
    }
    
    if SState(sender, 2)
    {
        [curLine setPermanentSetting:LELinePermanentTransparent to:YES];
        theFlags |= 0x2000;
    }
    else
    {
        [curLine setPermanentSetting:LELinePermanentTransparent to:NO];
    }
    
    if SState(sender, 3)
    {
        [curLine setPermanentSetting:LELinePermanentLandscape to:YES];
        theFlags |= 0x1000;
    }
    else
    {
        [curLine setPermanentSetting:LELinePermanentLandscape to:NO];
    }
    
    // Use a button instead of a check box (or somthing)
    // to delete a side, figure somthing out!!!
    
    // ((v) ? ((i) |= (b)) : ((i) &= ~(b))
    
    [curLine setFlags:theFlags];
}

// LELinePermanentNoSides

- (IBAction)emptyFlagAction:(id)sender
{
    LELevelData *theLevel = [mainInspectorController currentLevel];
    LELine *theLine = [mainInspectorController getTheCurrentSelection];
    
    if ([sender state] == NSControlStateValueOff)
    { // Was off, now on, add side...
        
        [theLine setPermanentSetting:LELinePermanentNoSides to:NO];
        [theLevel addSidesForLine:theLine];
        cSide = [theLine clockwisePolygonSideObject];
        ccSide = [theLine counterclockwisePolygonSideObject];
    }
    else if ([sender state] == NSControlStateValueOn)
    { // Was on, now off, delete side...
        [theLine setPermanentSetting:LELinePermanentNoSides to:YES];
        [theLevel removeSidesFromLine:theLine];
        cSide = nil;
        ccSide = nil;
        baseSideRef = nil;
    }
    else
    {
        NSLog(@"The empty checkbox does not support mixed states at this time, it will be set to the NSControlStateValueOff.");
        [sender setState:NSControlStateValueOff];
        return;
    }
    [self updateLineInterface];
}

- (IBAction)controlPanelFlagsAction:(id)sender
{
    [self saveControlPanelFlags];
}



// *** Texture UI Actions ***

/*
        struct side_texture_definition primaryTex 	= [cSide primaryTextureStruct];
        struct side_texture_definition secondaryTex 	= [cSide secondaryTextureStruct];
        struct side_texture_definition transparentTex 	= [cSide transparentTextureStruct];
        
        // Update the texture offset fields...
        SetMatrixObjectValue(textureOffsetMatrix, 1, primaryTex.x0);
        SetMatrixObjectValue(textureOffsetMatrix, 2, primaryTex.y0);
        SetMatrixObjectValue(textureOffsetMatrix, 3, secondaryTex.x0);
        SetMatrixObjectValue(textureOffsetMatrix, 4, secondaryTex.y0);
        SetMatrixObjectValue(textureOffsetMatrix, 5, transparentTex.x0);
        SetMatrixObjectValue(textureOffsetMatrix, 6, transparentTex.y0);
        
        [primaryTextureMenu selectItemAtIndex:primaryTex.textureNumber];
        [secondaryTextureMenu selectItemAtIndex:secondaryTex.textureNumber];
        [transparentTextureMenu selectItemAtIndex:transparentTex.textureNumber];

*/

// The Enviroment Codes and Wall Collection Numbers...
    /*
    _water_collection
    _lava_collection
    _sewage_collection
    _jjaro_collection
    _pfhor_collection
    */



// ****************** Names Of Control Panels ****************

-(void)setupTheControlPanelNames
{
       theWaterNames = [[NSArray alloc] initWithObjects:
        @"Oxgen",
        @"Shield 1x",
        @"Shield 2x",
        @"Chip Insertion", // 3
        @"Light Switch", // 4
        @"Platform Switch", // 5
        @"Tag Switch", // 6
        @"Pattern Buffer",
        @"Computer Terminal", // 8
        @"Wires", nil]; // 9
        
        theLavaNames = [[NSArray alloc] initWithObjects:
        @"Shield 1x",
        @"Shield 2x",
        @"Shield 3x",
        @"Light Switch", // LIGHT 3
        @"Platform Switch", // POLYGON 4
        @"Tag Switch", // TAG 5
        @"Pattern Buffer",
        @"Computer Terminal", // TERMINAL 7
        @"Oxgen",
        @"Chip Insertion", // TAG 9
        @"Wires", nil]; // TAG 10
        
        theSewageNames = [[NSArray alloc] initWithObjects:
        @"Shield 1x",
        @"Shield 2x",
        @"Shield 3x",
        @"Light Switch",
        @"Platform Switch",
        @"Tag Switch",
        @"Pattern Buffer",
        @"Computer Terminal",
        @"Oxgen",
        @"Chip Insertion",
        @"Wires", nil];
        
        thePfhorNames = [[NSArray alloc] initWithObjects:
        @"Shield 1x",
        @"Shield 2x",
        @"Shield 3x",
        @"Light Switch",
        @"Platform Switch",
        @"Tag Switch",
        @"Pattern Buffer",
        @"Computer Terminal",
        @"Oxgen",
        @"Chip Insertion",
        @"Wires", nil];
        
        theJjaroNames = [[NSArray alloc] initWithObjects:
        @"Shield 1x",
        @"Shield 2x",
        @"Shield 3x",
        @"Light Switch",
        @"Platform Switch",
        @"Tag Switch",
        @"Pattern Buffer",
        @"Computer Terminal",
        @"Oxgen",
        @"Chip Insertion",
        @"Wires", nil];
}


@end
