//
//  TerminalEditorController.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Thu Mar 14 2002.
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


#import "PhItemPlacementEditorController.h"

#import "PhItemPlacement.h"

#import "LEMap.h"
#import "LELevelData.h"

#import "PhPfhorgeSingleLevelDoc.h"

#import "LEExtras.h"

@implementation PhItemPlacementEditorController
// Data Source methods

- (id)initWithMapDocument:(LEMap *)theDocument
{
    self = [super initWithWindowNibName:@"ItemPlacementEditor"];
    
    if (self == nil)
        return nil;
    
    ///[self window];
    
    [theDocument addLevelInfoWinCon:self];
    
    theMap = theDocument;
    theLevel = [theDocument getCurrentLevelLoaded];
    
    theItemPlacmentObjects = [theLevel getItemPlacement];
    
    [self setupTheObjectNames];
    monstersStartAt = [theItemNames count];
    numberOfTableRows = [theMonsterNames count] + monstersStartAt;
    
    return self;
}

- (id)init
{
    self = [super initWithWindowNibName:@"ItemPlacementEditor"];
    
    if (self == nil)
        return nil;
    
    ///[self window];
    
    //[theDocument addLevelInfoWinCon:self];
    
    theMap = nil;
    theLevel = nil;
    
    theItemPlacmentObjects = nil;
    
    [self setupTheObjectNames];
    monstersStartAt = [theItemNames count];
    numberOfTableRows = [theMonsterNames count] + monstersStartAt;
    
    return self;
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"Item Placement Editor Controller Deallocating...");
    //[theLevel removeMenu:premutationMenu];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [theMap removeLevelInfoWinCon:self];
    
    [theMonsterNames release];
    [theItemNames release];
    
    [super dealloc];
}

/*- (void)nibDidLoad
{
    [super nibDidLoad];
}*/

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:)
        name:NSOutlineViewSelectionDidChangeNotification object:nil];*/
    
    /*[theTeriminalTableView registerForDraggedTypes:[NSArray 				
        arrayWithObjects:PfhorgeTerminalSectionDataPasteboardType, nil]];*/
    
    [self updateUserInterface];
}

// *********************** Utilites ***********************
#pragma mark -
#pragma mark ********* Utilites *********

- (BOOL)windowShouldClose:(id)sender
{
    ///[mapDocument removeLevelInfoWinCon:self];
    NSLog(@"Item Placement Editor windowShouldClose...");
    [theMap removeLevelInfoWinCon:self];
    //[self release];
    return YES;
}

- (PhItemPlacement *)objectForRow:(NSInteger)row
{
    if (row < 0)
        return nil;
    
    if (monstersStartAt <= row)
        return [theItemPlacmentObjects objectAtIndex:((row - monstersStartAt) + 64)];
    else
        return [theItemPlacmentObjects objectAtIndex:row];
}

- (BOOL)isSomthingSelected { return ([theTableView selectedRow] >= 0); }

- (PhItemPlacement *)selectedObject { return [self objectForRow:[theTableView selectedRow]]; }

// *********************** User Interface Methods ***********************
#pragma mark -
#pragma mark ********* User Interface Methods *********

- (void)updateUserInterface
{
    PhItemPlacement *theSelectedObj = [self selectedObject];
    unsigned short flags = [theSelectedObj flags];
    ///IBOutlet NSTableView *theTableView;
    
    int randomChancePercent = ((int)((((float)[theSelectedObj randomChance]) / 65535) * 100));
    
    [initalCountTB setIntValue:[theSelectedObj initialCount]];
    [maxCountTB setIntValue:[theSelectedObj maximumCount]];
    [minCountTB setIntValue:[theSelectedObj minimumCount]];
    [totalCountTB setIntValue:[theSelectedObj randomCount]];
    
    [appearenceTB setIntValue:randomChancePercent];
    [appearenceSlider setIntValue:randomChancePercent];
    
    if (flags & PhItemPlacementReappersInRandomLocation)
        [randomCB setState:NSOnState];
    else
        [randomCB setState:NSOffState];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    [self updateUserInterface];
    [theTableView reloadData];
}

- (IBAction)itemPlacementTableViewDidChange:(id)sender
{
    [self updateUserInterface];
    [theTableView reloadData];
}

- (IBAction)initalCountTBChanged:(id)sender
{
    [[self selectedObject] setInitialCount:[sender intValue]];
    [theTableView reloadData];
}

- (IBAction)maxCountTBChanged:(id)sender
{
    [[self selectedObject] setMaximumCount:[sender intValue]];
    [theTableView reloadData];
}

- (IBAction)minCountTBChanged:(id)sender
{
    [[self selectedObject] setMinimumCount:[sender intValue]];
    [theTableView reloadData];
}

- (IBAction)totalCountTBChanged:(id)sender
{
    [[self selectedObject] setRandomCount:[sender intValue]];
    [theTableView reloadData];
}

- (IBAction)apperenceTBChanged:(id)sender
{
    float thePrecentMultiplier = (((float)[sender intValue]) / 100);
    [[self selectedObject] setRandomChance:((unsigned short)(65535 * thePrecentMultiplier))];
    [appearenceSlider setIntValue:[sender intValue]];
    [theTableView reloadData];
}

- (IBAction)apperenceSliderChanged:(id)sender
{
    float thePrecentMultiplier = (((float)[sender intValue]) / 100);
    [[self selectedObject] setRandomChance:((unsigned short)(65535 * thePrecentMultiplier))];
    [appearenceTB setIntValue:[sender intValue]];
    // [theTableView reloadData];
}

- (IBAction)randomCheckboxDidChange:(id)sender
{
    if ([sender state] == NSOnState)
        [[self selectedObject] setFlags:PhItemPlacementReappersInRandomLocation];
    else
        [[self selectedObject] setFlags:0];
}

// *********************** Table Updater Methods ***********************
#pragma mark -
#pragma mark ********* Table Updater Methods *********

// *** Data Source Messages ***

- (BOOL)tableView:(NSTableView *)aTableView
    shouldEditTableColumn:(NSTableColumn *)col
    row:(NSInteger)rowIndex
{
    
    /*if ([[col identifier] isEqualToString:PhNumberOfObject])
        return NO;
    
    else if ([[col identifier] isEqualToString:PhNameOfObject])
        return YES;*/
    
    return NO;
}

// *** Data Source Methods ***

/*- (void)tableView:(NSTableView *)view
    willDisplayCell:(id)cell
    forTableColumn:(NSTableColumn *)col
    row:(int)row
{
    [cell setBackgroundColor: [colors objectAtIndex:row]];
}*/

- (NSInteger)numberOfRowsInTableView:(NSTableView *)view
{
   // return [theItemPlacmentObjects count];
    
    return numberOfTableRows;
}

- (id)tableView:(NSTableView *)view
    objectValueForTableColumn:(NSTableColumn *)col
    row:(NSInteger)row
{
    id theCurNameObj = nil;
    NSString *theColumIdentifier = [col identifier];
    
    ///NSLog(@"Row: %d, monstersStartAt: %d", row, monstersStartAt);
    
    if ([theColumIdentifier isEqualToString:@"Index"])
    {
        
        if (monstersStartAt <= row)
            return [theMonsterNames objectAtIndex:(row - monstersStartAt)];
        else
            return [theItemNames objectAtIndex:row];
        
        return [NSNumber numberWithInt:row];
    }
    
    else 
    {
        if (monstersStartAt <= row)
            theCurNameObj = [theItemPlacmentObjects objectAtIndex:((row - monstersStartAt) + 64)];
        else
            theCurNameObj = [theItemPlacmentObjects objectAtIndex:row];
        if 	([theColumIdentifier isEqualToString:@"Inital"])
            return [NSNumber numberWithInt:[theCurNameObj initialCount]];
        else if ([theColumIdentifier isEqualToString:@"Total"])
            return [NSNumber numberWithInt:[theCurNameObj randomCount]];
        else if ([theColumIdentifier isEqualToString:@"Max"])
            return [NSNumber numberWithInt:[theCurNameObj maximumCount]];
        else if ([theColumIdentifier isEqualToString:@"Min"])
            return [NSNumber numberWithInt:[theCurNameObj minimumCount]];
        else if ([theColumIdentifier isEqualToString:@"Percent"])
            return [NSNumber numberWithInt:((int)((((float)[theCurNameObj randomChance]) / 65535) * 100))];
        else if ([[col identifier] isEqualToString:@"Random"])
        {
            if ([theCurNameObj flags] & PhItemPlacementReappersInRandomLocation)
                return @"X";
            else
                return @" ";
        }
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)aTableView
    setObjectValue:anObject
    forTableColumn:(NSTableColumn *)col
    row:(NSInteger)rowIndex
{
    //id theRecord;
    //PhAbstractName *theCurNameObj= [currentArray objectAtIndex:row];
    
    /*NSParameterAssert(rowIndex >= 0 && rowIndex < [currentArray count]);
     
    if ([[col identifier] isEqualToString:PhNameOfObject])
        [theLevelDataObject setNameFor:[currentArray objectAtIndex:rowIndex] to:anObject];
    
    else if ([[col identifier] isEqualToString:PhNumberOfObject])
    {
        if (currentDisplayMode == _display_tags)
            return;
        
        else
            return;
    }*/
    
    return;
}

-(void)setupTheObjectNames
{
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
        @"Flame Thrower Canister",
        @"Extravision Powerup",
        @"Oxygen Powerup",
        @"Energy Powerup x1",
        @"Energy Powerup x2",
        @"Energy Powerup x3",
        @"Shotgun",
        @"Shotgun Cartridges",
        @"S'pht Door Key",
        @"Uplink Chip",
        @"Light Blue Ball",
        @"Red Ball",
        @"Violet Ball",
        @"Yellow Ball",
        @"Brown Ball",
        @"Orange Ball",
        @"Blue Ball",
        @"Green Ball",
        @"Submachine Gun",
        @"Submachine Gun Clip", @"", @"*** Monsters ***", @"", nil];
        
        theMonsterNames = [[NSArray alloc] initWithObjects:
        @"Marine",
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
        @"Hummer Major",
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


