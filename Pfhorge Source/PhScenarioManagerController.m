//
//  PhScenarioManagerController.m
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 02 2002.
//  Copyright (c) 2002 Joshua D. Orr. All rights reserved.
//

#import "PhScenarioManagerController.h"
#import "PhPfhorgeScenarioLevelDoc.h"
#import "LEExtras.h"

@implementation PhScenarioManagerController

// *********************** init and dealloc ***********************
#pragma mark -
#pragma mark ********* init and dealloc *********

- (id)init
{
    self = [super initWithWindowNibName:@"MapManager"];
    //[self window];
    
    if (self == nil)
        return nil;
    
    alreadyNotifiedOfBecomingMain = NO;
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self setupDataSourceForLevelTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
    ///[[self document] windowControllerDidLoadNib:self];
    
    [theLevelTable registerForDraggedTypes:[NSArray 				
        arrayWithObjects:@"PfhorgeScenarioLevelsTableData", nil]];
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
    if (!alreadyNotifiedOfBecomingMain)
    {
        [[self document] windowControllerDidLoadNib:self];
        alreadyNotifiedOfBecomingMain = YES;
    }
}

- (void)setupDataSourceForLevelTable
{
    [theLevelTable setDataSource:[[self document] dataObjectForLevelNameTable]];
    [theLevelTable setDelegate:[[self document] dataObjectForLevelNameTable]];
    [[[self document] dataObjectForLevelNameTable] setTableView:theLevelTable];
    [theLevelTable reloadData];
}

// *********************** Table Delegate Notifications ***********************
#pragma mark -
#pragma mark ********* Table Delegate Notifications *********

// *** Delegate Messages ***

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    int theSelectedRow = [theLevelTable selectedRow];
    
    if (theSelectedRow < 0)
        return;
}

- (IBAction)notDoneYet:(id)sender
{
    SEND_INFO_MSG_TITLE(@"This does not work yet...", @"Please Be Aware");
}

- (IBAction)reloadLevelTable:(id)sender
{
    [theLevelTable reloadData];
}


- (IBAction)mergeScenarioToMap:(id)sender
{
    NSSavePanel *theSavePanel = [NSSavePanel savePanel];
    
    SEND_INFO_MSG_TITLE(@"Please be aware that merging is not done yet, it may or may not work. Exporting a single level works much better right now...", @"Warning");
    
    [theSavePanel setPrompt:@"Export"];
    
    [theSavePanel beginSheetForDirectory:nil file:nil modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    
    
}

- (IBAction)rescanProjectDirectory:(id)sender
{
    [[self document] rescanProjectDirectoryNow];
}

- (IBAction)editSelectedLevel:(id)sender
{
    [[[self document] dataObjectForLevelNameTable] editSelected:theLevelTable];
}

- (IBAction)exportSelectedToMarathonMap:(id)sender
{
    NSSavePanel *theSavePanel = [NSSavePanel savePanel];
    
    [theSavePanel setPrompt:@"Export Single Level"];
    
    [theSavePanel beginSheetForDirectory:nil file:nil modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(savePanelDidEndForSingleExport:returnCode:contextInfo:) contextInfo:NULL];
}

- (IBAction)deleteSelectedLevel:(id)sender
{
    SEND_INFO_MSG_TITLE(@"For now, delete level in finder then rescan the folder.",
                         @"Not Directly Supported Yet");
}

// ********* END ACTIONS *********

- (void)savePanelDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{

    if (returnCode != NSOKButton)
        return;
    
    [[self document] saveMergedMapTo:[sheet filename]];
    
    
}

- (void)savePanelDidEndForSingleExport:(id)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{

    if (returnCode != NSOKButton)
        return;
    
    [[self document] exportLevelToMarathonMap:[sheet filename]];
}

@end
