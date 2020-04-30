//
//  PhDefaultLayerController.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Dec 18 2001.
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


#import "PhDefaultLayerController.h"
#import "PhTypesStructresEnums.h"
#import "LEExtras.h"


@implementation PhDefaultLayerController

/* Borrowed a little for O'Reliey Table Tutorial */

- (PhDefaultLayerController *)init
{
    self = [super initWithWindowNibName:@"DefaultLayerEditor"];
    
    if (self == nil)
        return nil;
    
    return self;

}

// *********************** Class Methods ***********************
+ (PhDefaultLayerController *)sharedLayerDefaultsController
{
    static PhDefaultLayerController *sharedLayerDefaultsController = nil;

    if (!sharedLayerDefaultsController) {
        sharedLayerDefaultsController = [[PhDefaultLayerController alloc/*WithZone:[self zone]*/] init];
    }

    return sharedLayerDefaultsController;
}

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *theRecords = [[NSMutableArray alloc] init];
    NSMutableDictionary *ARecord = [NSMutableDictionary dictionary];
    NSDictionary *appDefaults;
    
    NSLog(@"Registering the Layer Defaults");
    
    [ARecord setObject:@"Default Layer"				forKey:PhDefaultLayer_Name];
    [ARecord setObject:archive([NSNumber numberWithInt:-9216])	forKey:PhDefaultLayer_FloorMin];
    [ARecord setObject:archive([NSNumber numberWithInt:9216])	forKey:PhDefaultLayer_FloorMax];
    [ARecord setObject:archive([NSNumber numberWithInt:-9216])	forKey:PhDefaultLayer_CeilingMin];
    [ARecord setObject:archive([NSNumber numberWithInt:9216])	forKey:PhDefaultLayer_CeilingMax];
    
    [theRecords addObject:ARecord];
    
    appDefaults = [NSDictionary dictionaryWithObject:theRecords forKey:PhDefaultLayers];
    
    [defaults registerDefaults:appDefaults];
}

-(void)awakeFromNib
{
    records = [[NSMutableArray alloc] init];
    [records addObjectsFromArray:[preferences arrayForKey:PhDefaultLayers]];
}

-(IBAction)revertToSavedPrefs:(id)sender
{
    if (records != nil)
    {
        [records release];
        records = nil;
    }
    records = [[NSMutableArray alloc] init];
    [records addObjectsFromArray:[preferences arrayForKey:PhDefaultLayers]];
    [tableView reloadData];
}

-(IBAction)addRecord:(id)sender
{
    [records insertObject:[self createRecord] atIndex:0];
    [tableView reloadData];
}

-(IBAction)insertRecord:(id)sender
{
    int index = [tableView selectedRow];
    if (index >= 0)
    {
        [records insertObject:[self createRecord] atIndex:index];
        [tableView reloadData];
    }
}

-(IBAction)deleteRecord:(id)sender
{
    NSEnumerator *enumerator = [tableView selectedRowEnumerator];
    id index;
    NSMutableArray *tempArray = [NSMutableArray array];
    id tempObject;
    
    while ( (index = [enumerator nextObject]) )
    {
        if ([index intValue] != (((int)[records count]) - 1))
        {
            tempObject = [records objectAtIndex:[index intValue]]; // No modification, no problem
            [tempArray addObject:tempObject]; // keep track of the record to delete in tempArray
        }
        else
        {
            SEND_ERROR_MSG(@"Sorry, you can't edit or delete the default layer! :(  Any other selected layers will be deleted however.");
        }
    }
    
    enumerator = [tempArray objectEnumerator];
    while (index = [enumerator nextObject])
    {
        [records removeObjectIdenticalTo:index]; // we're golden
    }
    
    [tableView reloadData];
}

-(IBAction)saveToPrefs:(id)sender
{
    [preferences setObject:records forKey:PhDefaultLayers];
}

-(NSDictionary *)createRecord
{
    NSMutableDictionary *record = [NSMutableDictionary dictionary];
    
    NSString *theName = [nameTB stringValue];
    
    int intFMax = (int)(((float)[floorMaxTB floatValue]) * ((float)WORLD_ONE));
    int intFMin = (int)(((float)[floorMinTB floatValue]) * ((float)WORLD_ONE));
    int intCMax = (int)(((float)[ceilingMaxTB floatValue]) * ((float)WORLD_ONE));
    int intCMin = (int)(((float)[ceilingMinTB floatValue]) * ((float)WORLD_ONE));
    
    NSNumber *fMax = [NSNumber numberWithInt:intFMax];
    NSNumber *fMin = [NSNumber numberWithInt:intFMin];
    NSNumber *cMax = [NSNumber numberWithInt:intCMax];
    NSNumber *cMin = [NSNumber numberWithInt:intCMin];
    
    [record setObject:theName forKey:PhDefaultLayer_Name];
    [record setObject:archive(cMax) forKey:PhDefaultLayer_CeilingMax];
    [record setObject:archive(fMax) forKey:PhDefaultLayer_FloorMax];
    [record setObject:archive(fMin) forKey:PhDefaultLayer_FloorMin];
    [record setObject:archive(cMin) forKey:PhDefaultLayer_CeilingMin];
    
    return record;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    NSEnumerator *enumerator = [tableView selectedRowEnumerator];
    id index;
   // NSMutableArray *tempArray = [NSMutableArray array];
    id tempObject;
    
    int intFMax = (int)(((float)[floorMaxTB floatValue]) * ((float)WORLD_ONE));
    int intFMin = (int)(((float)[floorMinTB floatValue]) * ((float)WORLD_ONE));
    int intCMax = (int)(((float)[ceilingMaxTB floatValue]) * ((float)WORLD_ONE));
    int intCMin = (int)(((float)[ceilingMinTB floatValue]) * ((float)WORLD_ONE));
    
    NSNumber *fMax = [NSNumber numberWithInt:intFMax];
    NSNumber *fMin = [NSNumber numberWithInt:intFMin];
    NSNumber *cMax = [NSNumber numberWithInt:intCMax];
    NSNumber *cMin = [NSNumber numberWithInt:intCMin];
    
    while ( (index = [enumerator nextObject]) )
    {
        if ([index intValue] != (((int)[records count]) - 1))
        {
            tempObject = [records objectAtIndex:[index intValue]]; // No modification, no problem
            //[tempArray addObject:tempObject]; // keep track of the record to delete in tempArray
            //[record setObject:theName forKey:PhDefaultLayer_Name];
            [tempObject setObject:archive(cMax) forKey:PhDefaultLayer_CeilingMax];
            [tempObject setObject:archive(fMax) forKey:PhDefaultLayer_FloorMax];
            [tempObject setObject:archive(fMin) forKey:PhDefaultLayer_FloorMin];
            [tempObject setObject:archive(cMin) forKey:PhDefaultLayer_CeilingMin];
        }
        else
        {
            SEND_ERROR_MSG(@"Sorry, you can't edit or delete the default layer! :(  Any other selected layers will be deleted however.");
        }
    }
    [tableView reloadData];
}

-(IBAction)changeBtn:(id)sender
{
    [self controlTextDidChange:nil];
    [self changeName:nil];
    [tableView reloadData];
}

-(IBAction)changeName:(id)sender
{
    NSEnumerator *enumerator = [tableView selectedRowEnumerator];
    id index;
    //NSMutableArray *tempArray = [NSMutableArray array];
    id tempObject;
    
    NSString *theName = [nameTB stringValue];
    
    while ( (index = [enumerator nextObject]) )
    {
        if ([index intValue] != (((int)[records count]) - 1))
        {
            tempObject = [records objectAtIndex:[index intValue]]; // No modification, no problem
            //[tempArray addObject:tempObject]; // keep track of the record to delete in tempArray
            [tempObject setObject:theName forKey:PhDefaultLayer_Name];
        }
        else
        {
            SEND_ERROR_MSG(@"Sorry, you can't edit or delete the default layer! :(  Any other selected layers will be deleted however.");
        }
    }
    [tableView reloadData];
}

// *********************** Table Delegate Notifications ***********************
#pragma mark -
#pragma mark ********* Table Delegate Notifications *********

// *** Delegate Messages ***

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    int theSelectedRow = [tableView selectedRow];
    id theRecord;
    
    if (theSelectedRow < 0)
        return;
    
    theRecord = [records objectAtIndex:theSelectedRow];
    [nameTB setStringValue:[theRecord objectForKey:PhDefaultLayer_Name]];
    
    [floorMinSB setFloatValue:([unarchive([theRecord objectForKey:PhDefaultLayer_FloorMin]) floatValue] / ((float)WORLD_ONE))];
    [ceilingMinSB setFloatValue:([unarchive([theRecord objectForKey:PhDefaultLayer_CeilingMin]) floatValue] / ((float)WORLD_ONE))];
    [ceilingMaxSB setFloatValue:([unarchive([theRecord objectForKey:PhDefaultLayer_CeilingMax]) floatValue] / ((float)WORLD_ONE))];
    [floorMaxSB setFloatValue:([unarchive([theRecord objectForKey:PhDefaultLayer_FloorMax]) floatValue] / ((float)WORLD_ONE))];
    
    [floorMaxTB setFloatValue:([unarchive([theRecord objectForKey:PhDefaultLayer_FloorMax]) floatValue] / ((float)WORLD_ONE))];
    [ceilingMaxTB setFloatValue:([unarchive([theRecord objectForKey:PhDefaultLayer_CeilingMax]) floatValue] / ((float)WORLD_ONE))];
    [ceilingMinTB setFloatValue:([unarchive([theRecord objectForKey:PhDefaultLayer_CeilingMin]) floatValue] / ((float)WORLD_ONE))];
    [floorMinTB setFloatValue:([unarchive([theRecord objectForKey:PhDefaultLayer_FloorMin]) floatValue] / ((float)WORLD_ONE))];
}

// *********************** Table Data Source Updater Methods ***********************
#pragma mark -
#pragma mark ********* Table Data Source Updater Methods *********

// *** Data Source Messages ***

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [records count];
}

-(id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn 
    row:(int)rowIndex 
{
    id theRecord, theValue;
    
    theRecord = [records objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:[aTableColumn identifier]];
    
    if ([[aTableColumn identifier] isEqualToString:PhDefaultLayer_Name])
    {
        // Nothing Right Now...
    }
    else
    {
        float floatValue = (float)(((float)[unarchive(theValue) floatValue]) / ((float)WORLD_ONE));
        theValue = [NSNumber numberWithFloat:floatValue];
    }
    
    return theValue;
}



@end
