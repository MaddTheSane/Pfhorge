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
    if (self = [super initWithWindowNibName:@"DefaultLayerEditor"]) {
        
    }
    
    return self;

}

// *********************** Class Methods ***********************
+ (PhDefaultLayerController *)sharedLayerDefaultsController
{
    static PhDefaultLayerController *sharedLayerDefaultsController = nil;

    if (!sharedLayerDefaultsController) {
        sharedLayerDefaultsController = [[PhDefaultLayerController alloc] init];
    }

    return sharedLayerDefaultsController;
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *ARecord = [NSMutableDictionary dictionary];
        NSDictionary *appDefaults;
        
        NSLog(@"Registering the Layer Defaults");
        
        ARecord[PhDefaultLayer_Name] = @"Default Layer";
        ARecord[PhDefaultLayer_FloorMin] = @-9216;
        ARecord[PhDefaultLayer_FloorMax] = @9216;
        ARecord[PhDefaultLayer_CeilingMin] = @-9216;
        ARecord[PhDefaultLayer_CeilingMax] = @9216;
        
        appDefaults = @{PhDefaultLayers: @[ARecord]};
        
        [defaults registerDefaults:appDefaults];
    });
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
    NSInteger index = [tableView selectedRow];
    if (index >= 0) {
        [records insertObject:[self createRecord] atIndex:index];
        [tableView reloadData];
    }
}

-(IBAction)deleteRecord:(id)sender
{
    NSIndexSet *rowIndexes = [tableView selectedRowIndexes];
    NSInteger index = 0;
    NSMutableArray *tempArray = [NSMutableArray array];
    id tempObject;
    
    while ( (index = [rowIndexes indexGreaterThanIndex:index]) != NSNotFound) {
        if (index != ([records count] - 1)) {
            tempObject = [records objectAtIndex:index]; // No modification, no problem
            [tempArray addObject:tempObject]; // keep track of the record to delete in tempArray
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
            alert.informativeText = NSLocalizedString(@"Sorry, you can't edit or delete the default layer! :(  Any other selected layers will be deleted however.", @"Sorry, you can't edit or delete the default layer! :(  Any other selected layers will be deleted however.");
            alert.alertStyle = NSAlertStyleCritical;
            [alert runModal];
        }
    }
    
    NSEnumerator *enumerator = [tempArray objectEnumerator];
    for (id index in enumerator) {
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
    [record setObject:cMax forKey:PhDefaultLayer_CeilingMax];
    [record setObject:fMax forKey:PhDefaultLayer_FloorMax];
    [record setObject:fMin forKey:PhDefaultLayer_FloorMin];
    [record setObject:cMin forKey:PhDefaultLayer_CeilingMin];
    
    return record;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    NSIndexSet *enumerator = [tableView selectedRowIndexes];
    NSInteger index = 0;
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
    
    while ( (index = [enumerator indexGreaterThanIndex:index]) != NSNotFound )
    {
        if (index != (((int)[records count]) - 1))
        {
            tempObject = [records objectAtIndex:index]; // No modification, no problem
            //[tempArray addObject:tempObject]; // keep track of the record to delete in tempArray
            //[record setObject:theName forKey:PhDefaultLayer_Name];
            [tempObject setObject:cMax forKey:PhDefaultLayer_CeilingMax];
            [tempObject setObject:fMax forKey:PhDefaultLayer_FloorMax];
            [tempObject setObject:fMin forKey:PhDefaultLayer_FloorMin];
            [tempObject setObject:cMin forKey:PhDefaultLayer_CeilingMin];
        }
        else
        {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
            alert.informativeText = NSLocalizedString(@"Sorry, you can't edit or delete the default layer! :(  Any other selected layers will be deleted however.", @"Sorry, you can't edit or delete the default layer! :(  Any other selected layers will be deleted however.");
            alert.alertStyle = NSAlertStyleCritical;
            [alert runModal];
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
    NSIndexSet *rowIndexes = [tableView selectedRowIndexes];
    NSInteger index = 0;
    //NSMutableArray *tempArray = [NSMutableArray array];
    id tempObject;
    
    NSString *theName = [nameTB stringValue];
    
    while ((index = [rowIndexes indexGreaterThanIndex:index]) != NSNotFound) {
        if (index != ([records count] - 1)) {
            tempObject = [records objectAtIndex:index]; // No modification, no problem
            //[tempArray addObject:tempObject]; // keep track of the record to delete in tempArray
            [tempObject setObject:theName forKey:PhDefaultLayer_Name];
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = NSLocalizedString(@"Generic Error", @"Generic Error");
            alert.informativeText = NSLocalizedString(@"Sorry, you can't edit or delete the default layer! :(  Any other selected layers will be deleted however.", @"Sorry, you can't edit or delete the default layer! :(  Any other selected layers will be deleted however.");
            alert.alertStyle = NSAlertStyleCritical;
            [alert runModal];
        }
    }
    [tableView reloadData];
}

// *********************** Table Delegate Notifications ***********************
#pragma mark - Table Delegate Notifications

// *** Delegate Messages ***

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger theSelectedRow = [tableView selectedRow];
    id theRecord;
    
    if (theSelectedRow < 0)
        return;
    
    theRecord = [records objectAtIndex:theSelectedRow];
    [nameTB setStringValue:[theRecord objectForKey:PhDefaultLayer_Name]];
    
    [floorMinSB setFloatValue:([unarchivedOfClass([theRecord objectForKey:PhDefaultLayer_FloorMin], [NSNumber class]) floatValue] / ((float)WORLD_ONE))];
    [ceilingMinSB setFloatValue:([unarchivedOfClass([theRecord objectForKey:PhDefaultLayer_CeilingMin], [NSNumber class]) floatValue] / ((float)WORLD_ONE))];
    [ceilingMaxSB setFloatValue:([unarchivedOfClass([theRecord objectForKey:PhDefaultLayer_CeilingMax], [NSNumber class]) floatValue] / ((float)WORLD_ONE))];
    [floorMaxSB setFloatValue:([unarchivedOfClass([theRecord objectForKey:PhDefaultLayer_FloorMax], [NSNumber class]) floatValue] / ((float)WORLD_ONE))];
    
    [floorMaxTB setFloatValue:([unarchivedOfClass([theRecord objectForKey:PhDefaultLayer_FloorMax], [NSNumber class]) floatValue] / ((float)WORLD_ONE))];
    [ceilingMaxTB setFloatValue:([unarchivedOfClass([theRecord objectForKey:PhDefaultLayer_CeilingMax], [NSNumber class]) floatValue] / ((float)WORLD_ONE))];
    [ceilingMinTB setFloatValue:([unarchivedOfClass([theRecord objectForKey:PhDefaultLayer_CeilingMin], [NSNumber class]) floatValue] / ((float)WORLD_ONE))];
    [floorMinTB setFloatValue:([unarchivedOfClass([theRecord objectForKey:PhDefaultLayer_FloorMin], [NSNumber class]) floatValue] / ((float)WORLD_ONE))];
}

// *********************** Table Data Source Updater Methods ***********************
#pragma mark - Table Data Source Updater Methods

// *** Data Source Messages ***

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [records count];
}

-(id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
           row:(NSInteger)rowIndex
{
    id theRecord, theValue;
    
    theRecord = [records objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:[aTableColumn identifier]];
    
    if ([[aTableColumn identifier] isEqualToString:PhDefaultLayer_Name]) {
        // Nothing Right Now...
    } else {
        float floatValue = (float)(((float)[theValue floatValue]) / ((float)WORLD_ONE));
        theValue = @(floatValue);
    }
    
    return theValue;
}

@end
