//
//  PhNoteGroupsCon.m
//  Pfhorge
//
//  Created by Jagil on Wed Oct 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "PhNoteGroupsCon.h"
#import "PhNoteGroup.h"
#import "LELevelData.h"
#import "LEMap.h"

@implementation PhNoteGroupsCon
// *********************** Table Data Source Updater Methods ***********************
#pragma mark -
#pragma mark ••••••••• Table Data Source Updater Methods •••••••••

// *** Data Source Messages ***

- (void)awake
{
    //[super awakeFromNib];
    /*
    if (table == nil)
        NSLog(@"Awake From Nib Called!!! NILL ---");
    else
        NSLog(@"Awake From Nib Called!!! ---");
    */
    
    NSButtonCell *toggleSwitch = [[[NSButtonCell alloc] init] autorelease];
    
    [toggleSwitch setButtonType:NSSwitchButton];
    [toggleSwitch setEnabled:YES];
    [toggleSwitch setTitle:@""];
    //[toggleSwitch setSelectable:YES];
    [[table tableColumnWithIdentifier:@"visible"] setDataCell:toggleSwitch];
    //[[scheduleTable tableColumnWithIdentifier:@"override"] setEditable:YES];
    //[[table tableColumnWithIdentifier:@"loop"] setDataCell:toggleSwitch];
    
    //[toggleSwitch release];
}

- (NSArray *)data
{
    return [[(LEMap*)[mainController document] getCurrentLevelLoaded] noteTypes];
}

- (PhNoteGroup *)entryAtIndex:(NSInteger)index
{
    return [[self data] objectAtIndex:index];
}

- (id)getSelectedObjectFromTable:(NSTableView *)aTableView
{
    //NSArray *theObjects = [self arrayFromTable:aTableView];
    
    if ([aTableView selectedRow] < 0)
        return nil;
    else
    {
        return [self entryAtIndex:[aTableView selectedRow]];
    }
}


- (NSArray *)arrayFromTable:(NSTableView *)aTableView
{
    // Only one table...
    return [self data];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSArray *theArray = [self arrayFromTable:aTableView];
    
    if (theArray == nil)
        return 0;
    else
        return [theArray count];
}

-(id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)col 
    row:(NSInteger)rowIndex
{
    NSArray *theArray = [self arrayFromTable:aTableView];
    
    if (theArray == nil)
        return nil;
    else // based on header!!!
    {
        NSString *theColumIdentifier = [col identifier];
        
        //return @"Tmp...";
        
        PhNoteGroup *grp = [self entryAtIndex:rowIndex];
        
        if (grp == nil)
        {
			NSLog(@"theEntry in table get object value is nil For Row#: %ld", (long)rowIndex);
            return nil;
        }
        else if ([theColumIdentifier isEqualToString:@"visible"])
        {
            if ([grp visible] == YES)
                return [NSNumber numberWithInt:1];
            else
                return [NSNumber numberWithInt:0];
        }
        else if ([theColumIdentifier isEqualToString:@"group"])
        {
            return [grp getPhName];
        }
        else
        {
            NSLog(@"Unknown Column In PhNoteGroupsCon");
        }
    }
    
    return nil;
}


- (BOOL)tableView:(NSTableView *)aTableView
    shouldEditTableColumn:(NSTableColumn *)col
    row:(NSInteger)rowIndex
{
    // Spawn a new schedule window with this day...
    
    return YES;
}

- (void)tableView:(NSTableView *)aTableView
    setObjectValue:anObject
    forTableColumn:(NSTableColumn *)col
    row:(NSInteger)rowIndex
{
    NSString *theColumIdentifier = [col identifier];
    
    if ([theColumIdentifier isEqualToString:@"visible"])
    {
        if ([anObject boolValue])
        {
            [[self getSelectedObjectFromTable:aTableView] setVisible:YES];
        }
        else
        {
           [[self getSelectedObjectFromTable:aTableView] setVisible:NO];
        }
    }
    else if ([theColumIdentifier isEqualToString:@"group"])
    {
        // anObject should be a NSString object, may want to check...
        [[self getSelectedObjectFromTable:aTableView] setPhName:anObject];
    }
}


- (void)tableView:(NSTableView *)view
    willDisplayCell:(id)cell
    forTableColumn:(NSTableColumn *)col
    row:(NSInteger)row
{
    //[cell setBackgroundColor: [colors objectAtIndex:row]];
    
    //[cell setForegroundColor: [colors objectAtIndex:row]];
    
   // return;
    /*
    [cell setTextColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    
    if ((row % 2) == 1) // odd...
    {
        // Might want to use light blue color here instead, or light green? ]:=>
        [cell setBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:0.8 blue:0.8 alpha:1.0]];
    }
    else
    {
        [cell setBackgroundColor:[NSColor colorWithCalibratedRed:0.8 green:1.0 blue:0.8 alpha:1.0]];
    }*/
}


- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
    return NO;
}

- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    /*NSTableView *tableView = [aNotification object];
    
    if (tableView == scheduleTable)
        [self updateInterface];
    else
        return;*/
        
    //NSLog(@"Selected Date: %d", [[[self getSelectedObjectFromTable:scheduleTable] myDate] dayOfMonth]);
}


@end
