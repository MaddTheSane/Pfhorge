//
//  PhObjectInspectorSubController.m
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

#import "PhObjectInspectorSubController.h"

//Document Class
#import "LEMap.h"

//View and Controller Classes...
#import "LELevelWindowController.h"
#import "LEMapDraw.h"
#import "PhPlatformSheetController.h"

//Main Super Inspector Controller
#import "LEInspectorController.h"

//Data Classes...
#import "LELevelData.h"
#import "LEMapObject.h"
#import "LEMapPoint.h"
#import "LEPolygon.h"
#import "LELine.h"
#import "LESide.h"

//Other Classes...
#import "LEExtras.h"

@implementation PhObjectInspectorSubController

- (id)init
{
    self = [super initWithWindow:objectWindow];
    
    if (self == nil)
        return nil;
        
    //[self setWindowFrameAutosaveName:@"Inspector4"];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateObjectValuesOfComboMenus)
    //    name:PhUserDidChangeNamesNotification object:nil];
        
    return self;
}

- (void)dealloc
{
    [[self window] saveFrameUsingName:@"Inspector4"];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[self window] setFrameUsingName:@"Inspector4"];
    [self setWindowFrameAutosaveName:@"Inspector4"];
    [[self window] setFrameAutosaveName:@"Inspector4"];
    
    [(NSPanel *)[self window] setFloatingPanel:YES];
    [(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
}

- (void)reset
{
   // curPoly = nil;
}

-(void)updateInterface
{
    LEMapObject *theObj = [mainInspectorController getTheCurrentSelection];
    unsigned short theFlags = [theObj mapFlags];
    
    //[objBox setTitle:[NSString stringWithFormat:@"Object Index: %d", [theObj index]]];
    
    [objType selectItemAtIndex:[theObj type]];
    [self updateObjectKindMenu];
    //NSLog(@"Setting The Index...");
    
    
    if ([objItem numberOfItems] > [theObj getObjTypeIndex]) {
        [objItem selectItemAtIndex:[theObj getObjTypeIndex]];
    } else {
        [objItem selectItemAtIndex:-1];
		SEND_ERROR_MSG_TITLE(([NSString stringWithFormat:@"Object Index [#%d] is beyond the range of object kinds, %ld", [theObj getObjTypeIndex], (long)[objItem numberOfItems]]), @"Selected Object Kind Beyond Range");
    }
    //NSLog(@"DONE: Setting The Index...");
    //[objItem setObjectValue:[objItem objectValueOfSelectedItem]];
    [objAngle setObjectValue:[NSNumber numberWithShort:[theObj facing]]];
    [objZHeight setObjectValue:[NSNumber numberWithShort:[theObj z]]];
        
    [objFlags deselectAllCells];
    
    // _map_object_is_invisible  and  _map_object_is_platform_sound  are same number!
    // apperently top four bits (first hexadecmial number) is monster activation bias...
    
    if (theFlags & _map_object_is_invisible) {
        SelectS(objFlags, 1);
    }
    //if (theFlags & _map_object_is_platform_sound)
    //    SelectS(objFlags, 2);
    if (theFlags & _map_object_hanging_from_ceiling) {
        SelectS(objFlags, 3);
    }
    if (theFlags & _map_object_is_blind) {
        SelectS(objFlags, 4);
    }
    if (theFlags & _map_object_is_deaf) {
        SelectS(objFlags, 5);
    }
    if (theFlags & _map_object_floats) {
        SelectS(objFlags, 6);
    }
    if (theFlags & _map_object_is_network_only) {
        SelectS(objFlags, 8);
    }
}

- (void)updateObjectValuesOfComboMenus
{
    //[objItem setObjectValue:[objItem objectValueOfSelectedItem]];
}

-(void)updateObjectKindMenu
{
    LEMapObject *theObj = [mainInspectorController getTheCurrentSelection];
    int theObjType = [theObj type];
    ///int theObjIndex = [theObj getObjTypeIndex];
    
    [objItem removeAllItems];
    [objFlags setEnabledOfMatrixCellsTo:YES];
    
    if (theMonsterNames == nil)
        [self setupTheObjectNames];
    
    /// NSLog(@"Setting Up Object Type Menu... theObjType: %d theObjIndex: %d", theObjType, theObjIndex);
    
    switch (theObjType) {
        case _saved_monster:
            //NSLog(@"Adding Enemy Names To Object Menu");
            [objItem addItemsWithTitles:theMonsterNames];
            SSetEnabled(objFlags, 2, NO);
            SSetEnabled(objFlags, 6, NO);
            break;
        case _saved_object:
            //NSLog(@"Adding scenery Names To Object Menu");
            [objItem addItemsWithTitles:theSceneryNames];
            SSetEnabled(objFlags, 1, NO);
            SSetEnabled(objFlags, 2, NO);
            SSetEnabled(objFlags, 4, NO);
            SSetEnabled(objFlags, 5, NO);
            SSetEnabled(objFlags, 6, NO);
            break;
        case _saved_item:
            //NSLog(@"Adding item Names To Object Menu");
            [objItem addItemsWithTitles:theItemNames];
            SSetEnabled(objFlags, 1, NO);
            SSetEnabled(objFlags, 2, NO);
            SSetEnabled(objFlags, 4, NO);
            SSetEnabled(objFlags, 5, NO);
            SSetEnabled(objFlags, 6, NO);
            break;
        case _saved_player:
            //NSLog(@"Adding player Names To Object Menu");
            [objItem addItemsWithTitles:thePlayerNames];
            SSetEnabled(objFlags, 1, NO);
            SSetEnabled(objFlags, 2, NO);
            SSetEnabled(objFlags, 3, NO);
            SSetEnabled(objFlags, 4, NO);
            SSetEnabled(objFlags, 5, NO);
            SSetEnabled(objFlags, 6, NO);
            break;
        case _saved_goal:
            //NSLog(@"Adding goal Names To Object Menu");
            [objItem addItemsWithTitles:theGoalNames];
            SSetEnabled(objFlags, 1, NO);
            SSetEnabled(objFlags, 2, NO);
            SSetEnabled(objFlags, 3, NO);
            SSetEnabled(objFlags, 4, NO);
            SSetEnabled(objFlags, 5, NO);
            SSetEnabled(objFlags, 6, NO);
            break;
        case _saved_sound_source:
            //NSLog(@"Adding sound Names To Object Menu");
            [objItem addItemsWithTitles:theSoundNames];
            SSetEnabled(objFlags, 1, NO);
            SSetEnabled(objFlags, 3, NO);
            SSetEnabled(objFlags, 4, NO);
            SSetEnabled(objFlags, 5, NO);
            break;
        default:
            NSLog(@"ERROR: Adding default (NONE) Names To Object Menu, ERROR...");
            //GOT TO COME UP WITH DOCUMENT ERROR MESSAGING!!!
            //Perhaps though mainInspectorController and from there
            //the document controller?
            SEND_ERROR_MSG(@"Some unkown object type was found?");
            [objFlags setEnabledOfMatrixCellsTo:NO];
            break;
    }
    SSetEnabled(objFlags, 2, NO);
}

/*

    [objType selectItemAtIndex:[theObj type]];
    [self updateObjectKindMenu];
    [objItem selectItemAtIndex:[theObj index]];
    [objItem setObjectValue:[objItem objectValueOfSelectedItem]];
    [objAngle setObjectValue:[[NSNumber numberWithShort:[theObj facing]] stringValue]];
    [objZHeight setObjectValue:[[NSNumber numberWithShort:[theObj z]] stringValue]];
    
*/

- (IBAction)objectTypeAction:(id)sender
{
    if ([sender indexOfSelectedItem] != -1) {
        LEMapDraw *levelDrawView = [mainInspectorController getTheCurrentLevelDrawView];
        LEMapObject *theObj = [mainInspectorController getTheCurrentSelection];
        
        [theObj setType:[sender indexOfSelectedItem]];
        [theObj setIndex:0];
        
        [self updateInterface];
        
        [levelDrawView createObjectMaps];
        [levelDrawView redrawBoundsOfSelection];
        
        //[objItem selectItemAtIndex:0];
        //[self updateObjectKindMenu];
        //[self objectKindAction:objItem];
    }
}

- (IBAction)objectKindAction:(id)sender
{
    if ([sender indexOfSelectedItem] != -1) {
        LEMapDraw *levelDrawView = [mainInspectorController getTheCurrentLevelDrawView];
        LEMapObject *theObj = [mainInspectorController getTheCurrentSelection];
        [theObj  setType:[objType indexOfSelectedItem]];
        [theObj setIndex:[sender indexOfSelectedItem]]; // may be setObjTypeIndex in future...
        
        [levelDrawView createObjectMaps];
        [levelDrawView redrawBoundsOfSelection];
    }
}

- (IBAction)objectAngleAction:(id)sender
{
    LEMapDraw *levelDrawView = [mainInspectorController getTheCurrentLevelDrawView];
    [[mainInspectorController getTheCurrentSelection] setFacing:[sender intValue]];
    [levelDrawView createObjectMaps];
    [levelDrawView redrawBoundsOfSelection];
}

- (IBAction)objectHeightAction:(id)sender
{
    [[mainInspectorController getTheCurrentSelection] setZ:[sender intValue]];
}

- (IBAction)objectFlagsAction:(id)sender
{
    unsigned short theFlags = 0;
    
    if SState(sender, 1) (theFlags |= _map_object_is_invisible);
    //if SState(sender, 2) (theFlags |= _map_object_is_platform_sound);
    if SState(sender, 3) (theFlags |= _map_object_hanging_from_ceiling);
    if SState(sender, 4) (theFlags |= _map_object_is_blind);
    if SState(sender, 5) (theFlags |= _map_object_is_deaf);
    if SState(sender, 6) (theFlags |= _map_object_floats);
    if SState(sender, 8) (theFlags |= _map_object_is_network_only);
    
    // ((v) ? ((i) |= (b)) : ((i) &= ~(b))
    
    [[mainInspectorController getTheCurrentSelection] setMapFlags:theFlags];
}

// **************************** Initlizations, Class Methods, Etc. ****************************

-(void)setupTheObjectNames
{
       theGoalNames = [[NSArray alloc] initWithObjects:
        @"Goal 0",
        @"Goal 1",
        @"Goal 2",
        @"Goal 3",
        @"Goal 4",
        @"Goal 5",
        @"Goal 6",
        @"Goal 7",
        @"Goal 8",
        @"Goal 9",
        @"Goal 10", nil];
        
        thePlayerNames = [[NSArray alloc] initWithObjects:
        @"_violet_team",
        @"_red_team",
        @"_tan_team",
        @"_light_blue_team",
        @"_yellow_team",
        @"_brown_team",
        @"_blue_team",
        @"_green_team", nil];
        
        theItemNames = [[NSArray alloc] initWithObjects:
        @"Knife",
        @"Magnum Pistol",
        @"Magnum Magazine",
        @"Plasma Pistol",
        @"Plasma Energy Cell",
        @"Assault Rifle",
        @"AR Magazine",
        @"AR Grenade Magazine",
        @"Missile Launcher",
        @"Missile 2 Pack",
        @"Invisibility Powerup",
        @"Invincibility Powerup",
        @"Infravision Power",
        @"Alien Shotgun",
        @"Alien Shotgun Magazine",
        @"Flamethrower",
        @"Flamethrower Canister",
        @"Extravision Powerup",
        @"Oxygen Powerup",
        @"Energy Powerup x1",
        @"Energy Powerup x2",
        @"Energy Powerup x3",
        @"Shotgun",
        @"Shotgun Cartridges",
        @"S'pht Door Key",
        @"Uplink Chip",
        @"Base Ball or Light Blue Ball",
        @"Red Ball",
        @"Violet Ball",
        @"Yellow Ball",
        @"Brown Ball",
        @"Orange Ball",
        @"Blue Ball",
        @"Green Ball",
        @"Submachine Gun",
        @"Submachine Gun Clip", nil];
        
        theSceneryNames = [[NSArray alloc] initWithObjects:
        // Lava Follows
        @"light dirt",
        @"dark dirt",
        @"bones 1",
        @"bone 2",
        @"ribs",
        @"skull",
        @"hanging light 1",
        @"hanging light 2",
        @"small cylinder",
        @"large cylinder",
        @"block 1",
        @"block 2",
        @"block 3",
        // Water Follows
        @"Pistol Clip",
        @"Short Light",
        @"Long Light",
        @"Siren",
        @"Rocks",
        @"Blood Puddles",
        @"Water Filtration Device",
        @"Bloody Gun",
        @"Bloody Stuff",
        @"Puddles",
        @"Big Puddles",
        @"Security Monitor",
        @"Alien Trachcan",
        @"Machine",
        @"Fighter's Staff",
        // Sewage Follows
        @"stubby green light",
        @"long green light",
        @"junk",
        @"big antenna 1",
        @"big antenna 2",
        @"alien supply can",
        @"bones",
        @"big bones",
        @"pfhor pieces",
        @"bob pieces",
        @"bob blood",
        // Alien Follows
        @"green light",
        @"small alien light",
        @"alien ceiling rod light",
        @"bulbous yellow alien object",
        @"square grey organic object",
        @"pfhor skeleton",
        @"pfhor mask",
        @"green stuff",
        @"hunter shield",
        @"bones",
        @"alien sludge",
        // Jjaro Follows
        @"short ceiling light",
        @"long light",
        @"weird rod",
        @"pfhor ship",
        @"sun",
        @"large glass container",
        @"nub 1",
        @"nub 2",
        @"lh'owon",
        @"floor whip antenna",
        @"ceiling whip antenna", nil];
        
        theSoundNames = [[NSArray alloc] initWithObjects:
        @"Water",
        @"Sewage",
        @"Lava",
        @"Goo",
        @"Under Media",
        @"Wind",
        @"Waterfall",
        @"Siren",
        @"Fann",
        @"S'pht Door",
        @"S'pht Platform",
        @"Heavy S'pht Door",
        @"Heavy S'pht Platform",
        @"Light Machinery",
        @"Heavy Machinery",
        @"Transformer",
        @"Sparking Transformer",
        @"Machine Binder",
        @"Machine Bookpress",
        @"Machine Puncher",
        @"Electric Hum",
        @"Siren",
        @"Night Wind",
        @"Pfhor Door",
        @"Pfhor Platform",
        @"Pfhor Ship #1",
        @"Pfhor Ship #2",
        @"Jjaro Ship", nil];
        
        theMonsterNames = [[NSArray alloc] initWithObjects:
        @"Marine Monster?",
        @"Tick Energy",
        @"Tick Oxygen",
        @"Tick Kamakazi",
        @"Compiler Minor",
        @"Compiler Major",
        @"Compiler Invisible Minor",
        @"Compiler Invisible Major",
        @"Fighter Minor",
        @"Fighter Major",
        @"Fighter Projectile Minor",
        @"Fighter Projectile Major",
        @"Civilian Crew",
        @"Civilian Science",
        @"Civilian Security",
        @"Civilian Assimilated",
        @"Hummer Minor",
        @"Hummer Jaor",
        @"Hummer Big Minor",
        @"Hummer Big Major",
        @"Hummer Possessed",
        @"Cyborg Minor",
        @"Cyborg Major",
        @"Cyborg Grenade Minor",
        @"Cyborg Grenade Major",
        @"Enforcer Minor",
        @"Enforcer Major",
        @"Hunter Minor",
        @"Hunter Major",
        @"Trooper Minor",
        @"Trooper Major",
        @"Mother of all Cyborgs",
        @"Mother of all Hunters",
        @"Yeti Sewage",
        @"Yeti Water",
        @"Yeti Lava",
        @"Defender Minor",
        @"Defender Major",
        @"Juggernaut Minor",
        @"Juggernaut Major",
        @"Tiny Fighter",
        @"Tiny Bob",
        @"Tiny Yeti",
        @"Civilian Fusion Crew",
        @"Civilian Fusion Science",
        @"Civilian Fusion Security",
        @"Civilian Fusion Assimilated", nil];
}

@end
