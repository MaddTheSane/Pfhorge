//
//  PhPolyInspectorController.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon Jul 16 2001.
//  Copyright (c) 2001 Joshua D. Orr (Jagil). All rights reserved.
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

#import "PhPolyInspectorController.h"

//Document Class
#import "LEMap.h"

//View and Controller Classes...
#import "LELevelWindowController.h"
#import "LEMapDraw.h"
#import "PhPlatformSheetController.h"
//Main Super Inspector Controller
#import "LEInspectorController.h"
#import "PhTextureInspectorController.h"

//Data Classes...
#import "LELevelData.h"
#import "LEMapObject.h"
#import "LEMapPoint.h"
#import "LEPolygon.h"
#import "LELine.h"
#import "LESide.h"
#import "PhPlatform.h"

//Other Classes...
#import "LEExtras.h"

@implementation PhPolyInspectorController

- (id)init
{
    self = [super initWithWindow:textureWindow];
    
    if (self == nil)
        return nil;
    
    //[self setWindowFrameAutosaveName:@"Inspector3"];
    
    platformEditingWindowController = nil;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateObjectValuesOfComboMenus)
    //    name:PhUserDidChangeNamesNotification object:nil];
    
    curPoly = nil;
    
    return self;
}

- (void)dealloc
{
    curPoly = nil;
    [[self window] saveFrameUsingName:@"Inspector3"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[self window] setFrameUsingName:@"Inspector3"];
    [self setWindowFrameAutosaveName:@"Inspector3"];
    [[self window] setFrameAutosaveName:@"Inspector3"];
    
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
    
    curPoly = nil;
}

- (void)reset
{
    curPoly = nil;
    lastMenuTypeCache = -1;
}

   // IBOutlet id ceilingTextureMenu;
   // IBOutlet id floorTextureMenu;
   // IBOutlet id textureOffsetMatrix;
    
-(void)updateInterface
{
    // •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
    // ••• NOTE: Should check to see if it really is a LEPolygon object... •••
    // •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
    
    LEPolygon *thePoly = [mainInspectorController getTheCurrentSelection];
    LELevelData *theLevelData = [mainInspectorController currentLevel];
    LEPolygonType curPolyType;
    id tmpObj;
    
    curPoly = thePoly;
    
    /*
    NSPoint ceilingOrigin = [thePoly ceilingOrigin];
    NSPoint floorOrigin = [thePoly getFloor_origin];
    short floorTexture = [thePoly floorTexture];
    short ceilingTexture = [thePoly ceilingTexture];
    char *theCeilingTextureChar = (char *)&ceilingTexture;
    char *theFloorTextureChar = (char *)&floorTexture;
    
    SetMatrixObjectValue(textureOffsetMatrix, 1, ceilingOrigin.x);
    SetMatrixObjectValue(textureOffsetMatrix, 2, ceilingOrigin.y);
    SetMatrixObjectValue(textureOffsetMatrix, 3, floorOrigin.x);
    SetMatrixObjectValue(textureOffsetMatrix, 4, floorOrigin.y);
    
    [ceilingTextureMenu selectItemAtIndex:((theCeilingTextureChar)[1])];
    [floorTextureMenu selectItemAtIndex:((theFloorTextureChar)[1])];
    */
    
    //[polyBox setTitle:[NSString stringWithFormat:@"Poly Index: %d", [thePoly index]]];
    
    //GET_OBJECT_FLAG(o, b)
    
    //[thePoly randomSoundImageIndex];
    //IBOutlet id yandomSound;
    
    [textureInspectorController updatePolyTextureMenus];
    
    curPolyType = [thePoly type];
    
    [type selectItemAtIndex:curPolyType];
    
    /*
    if (lastMenuTypeCache != -1)
        [theLevelData removeMenu:permutation thatsA:lastMenuTypeCache];
    else
    {
        
    }*/
    
    [theLevelData removeMenu:permutation];
    
    
    switch (curPolyType) {
        case LEPolygonLightOnTrigger:
        case LEPolygonLightOffTrigger:
            [permutationTab selectTabViewItemAtIndex:0];
            
            [platformParametersBtn setEnabled:NO];
            [permutation setEnabled:YES];
            [theLevelData addMenu:permutation asMenuType:PhLevelNameMenuLight];
            [permutation selectItemAtIndex:[thePoly permutation]];
            lastMenuTypeCache = PhLevelNameMenuLight;
            break;
            
        case LEPolygonPlatformOnTrigger:
        case LEPolygonPlatformOffTrigger:
        case LEPolygonTeleporter:
            [permutationTab selectTabViewItemAtIndex:0];
            
            tmpObj = [thePoly permutationObject];
            [permutation setEnabled:YES];
            [platformParametersBtn setEnabled:NO];
            [theLevelData addMenu:permutation asMenuType:PhLevelNameMenuPolygon];
            lastMenuTypeCache = PhLevelNameMenuPolygon;
            
            NSInteger index = [[theLevelData namedPolyObjects] indexOfObjectIdenticalTo:tmpObj];
            
            NSLog(@"index: %ld   count: %ld  named count: %lu", (long)index, (long)[permutation numberOfItems], (unsigned long)[[theLevelData namedPolyObjects] count]);
            
            if ((index != NSNotFound || index >= 0) && ([permutation numberOfItems] > index))
                [permutation selectItemAtIndex:index];
            else
                [permutation selectItemAtIndex:-1];
            
            break;
            
        case LEPolygonBase:
            [permutationTab selectTabViewItemAtIndex:1];
            
            tmpObj = [thePoly permutationObject];
            
            if (tmpObj != nil /*&& NOTE: test to make sure tmpObj is a NSNumber!!! */) {
                [permutationNumberTB setIntValue:[tmpObj intValue]];
            } else {
                [permutationNumberTB setIntValue:-1];
            }
            
            [platformParametersBtn setEnabled:NO];
            [permutation selectItemAtIndex:-1];
            [permutation setEnabled:NO];
            lastMenuTypeCache = -1;
            break;
            
        case LEPolygonPlatform:
            /*[permutation setEnabled:YES];
            [theLevelData addMenu:permutation asA:PhLevelNameMenuPlatform];
            lastMenuTypeCache = PhLevelNameMenuPlatform;
            [permutation selectItemAtIndex:[thePoly permutation]];
            [platformParametersBtn setEnabled:YES];
            break;*/
            [permutationTab selectTabViewItemAtIndex:0];
            
            [platformParametersBtn setEnabled:YES];
            [permutation selectItemAtIndex:-1];
            [permutation setEnabled:NO];
            lastMenuTypeCache = -1;
            break;
            
        case LEPolygonAutomaticExit:
            [permutationTab selectTabViewItemAtIndex:1];
            
            tmpObj = [thePoly permutationObject];
            [permutationNumberTB setIntValue:[tmpObj intValue]];
            
            [platformParametersBtn setEnabled:NO];
            [permutation selectItemAtIndex:-1];
            [permutation setEnabled:NO];
            lastMenuTypeCache = -1;
            break;
            
        default:
            [permutationTab selectTabViewItemAtIndex:0];
            [permutation selectItemAtIndex:-1];
            [permutation setEnabled:NO];
            [platformParametersBtn setEnabled:NO];
            lastMenuTypeCache = -1;
            break;
    }
    
    //[ceilingHeight setObjectValue:[[NSNumber numberWithFloat:([thePoly ceilingHeight] / (float)1024)] stringValue]];
    //[floorHeight setObjectValue:[[NSNumber numberWithFloat:([thePoly floorHeight] / (float)1024)] stringValue]];
    
    [ceilingHeight setIntValue:[thePoly ceilingHeight]];
    [floorHeight setIntValue:[thePoly floorHeight]];
    
    [liquid selectItemAtIndex:[thePoly mediaIndex] + 1];
    [ambientSound selectItemAtIndex:[thePoly ambientSoundImageIndex] + 1];
    [yandomSound selectItemAtIndex:[thePoly randomSoundImageIndex] + 1];
    
    [ceilingLight selectItemAtIndex:[thePoly ceilingLightsourceIndex]];
    [floorLight selectItemAtIndex:[thePoly floorLightsourceIndex]];
    [liquidLight selectItemAtIndex:[thePoly mediaLightsourceIndex]];
    
    [liquid setObjectValue:[liquid objectValueOfSelectedItem]];
    [ambientSound setObjectValue:[ambientSound objectValueOfSelectedItem]];
    [yandomSound setObjectValue:[yandomSound objectValueOfSelectedItem]];
    
    //[ceilingLight setObjectValue:[ceilingLight objectValueOfSelectedItem]];
    //[floorLight  setObjectValue:[floorLight objectValueOfSelectedItem]];
    //[liquidLight  setObjectValue:[liquidLight objectValueOfSelectedItem]];
}

- (void)updateObjectValuesOfComboMenus
{
    [liquid selectItemAtIndex:[liquid indexOfSelectedItem]];
    [ambientSound selectItemAtIndex:[ambientSound indexOfSelectedItem]];
    
    //[ceilingLight selectItemAtIndex:[ceilingLight indexOfSelectedItem]];
    //[floorLight selectItemAtIndex:[floorLight indexOfSelectedItem]];
    //[liquidLight selectItemAtIndex:[liquidLight indexOfSelectedItem]];
    
    [liquid setObjectValue:[liquid objectValueOfSelectedItem]];
    //NSLog(@"liquid selection number: %d", [liquid indexOfSelectedItem]);
    [ambientSound setObjectValue:[ambientSound objectValueOfSelectedItem]];
    
    //[ceilingLight setObjectValue:[ceilingLight objectValueOfSelectedItem]];
    //[floorLight  setObjectValue:[floorLight objectValueOfSelectedItem]];
    //[liquidLight  setObjectValue:[liquidLight objectValueOfSelectedItem]];
}

- (IBAction)platformParametersAction:(id)sender
{
    //[[PhPlatformParametersWindowController sharedPlatformController] showSheet];
    LEPolygon *thePoly = curPoly;//[mainInspectorController getTheCurrentSelection];
    //LELevelData *theLevelData = [mainInspectorController currentLevel];
    PhPlatform *thePolyPlatform = [thePoly permutationObject];
    
    NSArray *thePlatforms = [[mainInspectorController currentLevel] platforms];
    
    for (PhPlatform *curPlat in thePlatforms) {
        if ([curPlat polygonObject] == thePoly) {
            if (curPlat != thePolyPlatform) {
                NSLog(@"WARNING: the polygon did not point back to correct platform, I am fixing this...");
                [thePoly setPermutationObject:curPlat];
            }
            
            [[[[NSApp mainWindow] windowController] document] openEditWindowForObject:curPlat];
            
            // May want to check to make sure there is not more then one polygon pointing back
            // to the same platform, instead of just stoping with the first one found...
            break;
        }
    }
    
    
    
    //if (platformEditingWindowController != nil)
    //    [platformEditingWindowController release];
    
    /*[[[PhPlatformSheetController alloc] initWithPlatform:thePlatform
        withLevel:theLevelData
        withMapDocument:[[[NSApp mainWindow] windowController] document]] showWindow:self];*/
    
    //[platformEditingWindowController showWindow:self];
}

- (IBAction)polygonTypeAction:(id)sender
{
    LEPolygonType thePolyType = [sender indexOfSelectedItem];
    LEPolygon *thePolyInQuestion = curPoly; //((LEPolygon *)[mainInspectorController getTheCurrentSelection]);
    LELevelData *theLevelData = [mainInspectorController currentLevel];
    LEMapDraw *theDrawView = [mainInspectorController getTheCurrentLevelDrawView];
    int theOldPolyType = [thePolyInQuestion type];
    
    switch (thePolyType) {
        case LEPolygonBase:
            //SEND_ERROR_MSG_TITLE(@"Sorry, this version of Pfhorge does not support this... I will soon though...",
            //                     @"Can't Change Type");
            [self updateInterface];
            return;
        case LEPolygonPlatform:
            break;
        case LEPolygonLightOffTrigger:
        case LEPolygonLightOnTrigger:
            if ([[theLevelData lights] count] < 1)
            {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = NSLocalizedString(@"Can't Change Type", @"Can't Change Type");
                alert.informativeText = NSLocalizedString(@"Sorry, but there are no lights to choose for this level.", @"Sorry, but there are no lights to choose for this level.");
                alert.alertStyle = NSAlertStyleCritical;
                [alert runModal];
                [self updateInterface];
                return;
            }
            
            [thePolyInQuestion setPermutationObject:[[theLevelData lights] objectAtIndex:0]];
            break;
        case LEPolygonPlatformOnTrigger:
        case LEPolygonPlatformOffTrigger:
        case LEPolygonTeleporter:
            if ([[theLevelData namedPolyObjects] count] < 1)
            {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = NSLocalizedString(@"Can't Change Type", @"Can't Change Type");
                alert.informativeText = NSLocalizedString(@"Sorry, but there are no named polygons to choose for this level.", @"Sorry, but there are no named polygons to choose for this level.");
                alert.alertStyle = NSAlertStyleCritical;
                [alert runModal];
                [self updateInterface];
                return;
            }
            
            [thePolyInQuestion setPermutationObject:[[theLevelData namedPolyObjects] objectAtIndex:0]];
            break;
        case LEPolygonAutomaticExit: // For right now set permutation to nothing (nil)...
       ///     SEND_ERROR_MSG_TITLE(@"Sorry, this version of Pfhorge does not support this... I will soon though...",
       ///                          @"Can't Change Type");
       ///     [self updateInterface];
       ///     return;
       /// default:
            // Polygon type does not reqire the permutation object...
            [thePolyInQuestion setPermutationObject:nil];
            break;
        default:
            break;
    }
    
    if (theOldPolyType == LEPolygonPlatform && !(thePolyType == LEPolygonPlatform))
    {
        [theLevelData deletePlatform:[thePolyInQuestion permutationObject]];
    }
    
    [thePolyInQuestion  setType:thePolyType];
    
    if (thePolyType == LEPolygonPlatform && !(theOldPolyType == LEPolygonPlatform))
    {
        [thePolyInQuestion setPermutationObject:[theLevelData addObjectWithDefaults:[PhPlatform class]]];
    }
    
    [self updateInterface];
    [theDrawView createPolyMap];
    [theDrawView redrawBoundsOfSelection];
}

- (IBAction)ceilingHeightAction:(id)sender
{
    [curPoly setCeilingHeight:[sender intValue]];
}

- (IBAction)floorHeightAction:(id)sender
{
    [curPoly setFloorHeight:[sender intValue]];
}

- (IBAction)permutationAction:(id)sender
{
    LEPolygon *thePolyInQuestion = curPoly;//((LEPolygon *)[mainInspectorController getTheCurrentSelection]);
    LELevelData *theLevelData = [mainInspectorController currentLevel];
    ///LEMapDraw *theDrawView = [mainInspectorController getTheCurrentLevelDrawView];
    int thePolyType = [thePolyInQuestion type];
    id thePerObj = nil;
    NSInteger thePermutation = [sender indexOfSelectedItem];
    //[[mainInspectorController getTheCurrentSelection] setPermutation:[sender intValue]];
    
    switch (thePolyType)
    {
        case LEPolygonBase:
            thePerObj = nil; // For Now, I am not sure about this yet??? 
                // For right now I moved this to use a NSNumber and
                //  the Text Box in the function right after this one
                //  called - (IBAction)permutationNumberTBAction:(id)sender
            break;
        case LEPolygonPlatform:
            thePerObj = [[theLevelData platforms] objectAtIndex:thePermutation];
            break;
        case LEPolygonLightOnTrigger:
            thePerObj = [[theLevelData lights] objectAtIndex:thePermutation];
            break;
        case LEPolygonPlatformOnTrigger:
            thePerObj = [[theLevelData namedPolyObjects] objectAtIndex:thePermutation];
            break;
        case LEPolygonLightOffTrigger:
            thePerObj = [[theLevelData lights] objectAtIndex:thePermutation];
            break;
        case LEPolygonPlatformOffTrigger:
            thePerObj = [[theLevelData namedPolyObjects] objectAtIndex:thePermutation];
            break;
        case LEPolygonTeleporter:
            thePerObj = [[theLevelData namedPolyObjects] objectAtIndex:thePermutation];
            break;
        default:
            thePerObj = nil;
            break;
    }
    
    [thePolyInQuestion setPermutationObject:thePerObj];
}

- (IBAction)permutationNumberTBAction:(id)sender
{
    LEPolygon *thePolyInQuestion = curPoly;//((LEPolygon *)[mainInspectorController getTheCurrentSelection]);
    ///LELevelData *theLevelData = [mainInspectorController currentLevel];
    ///LEMapDraw *theDrawView = [mainInspectorController getTheCurrentLevelDrawView];
    int thePolyType = [thePolyInQuestion type];
    id thePerObj = nil;
    //int thePermutation = [sender indexOfSelectedItem];
    //[[mainInspectorController getTheCurrentSelection] setPermutation:[sender intValue]];
    
    switch (thePolyType)
    {
        case LEPolygonBase:
        case LEPolygonAutomaticExit:
            thePerObj = numInt([permutationNumberTB intValue]);
            break;
        default:
            thePerObj = nil;
            break;
    }
    
    [thePolyInQuestion setPermutationObject:thePerObj];
}

- (IBAction)ceilingLightAction:(id)sender
{
    [curPoly setCeilingLightsource:[sender indexOfSelectedItem]];
}

- (IBAction)floorLightAction:(id)sender
{
    [curPoly setFloorLightsource:[sender indexOfSelectedItem]];
}

- (IBAction)liauidLightAction:(id)sender
{
    [curPoly setMediaLightsource:[sender indexOfSelectedItem]];
}

- (IBAction)liquidAction:(id)sender
{
	[curPoly setMediaIndex:([sender indexOfSelectedItem] - 1)];
}

- (IBAction)randomSoundAction:(id)sender
{
    [curPoly setRandomSound:([sender indexOfSelectedItem]-1)];
}

- (IBAction)ambientSoundAction:(id)sender
{
    [curPoly setAmbientSound:([sender indexOfSelectedItem]-1)];
}


@end
