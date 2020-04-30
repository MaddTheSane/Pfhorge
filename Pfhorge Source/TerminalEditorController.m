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


#import "TerminalEditorController.h"
#import "LEMap.h"
#import "LELevelData.h"

#import "PhPfhorgeSingleLevelDoc.h"

#import "Terminal.h"
#import "TerminalSection.h"

#import "LEExtras.h"

@implementation TerminalEditorController
// Data Source methods

- (id)initWithMapDocument:(LEMap *)theDocument
{
    self = [super initWithWindowNibName:@"TerminalInterface"];
    
    NSLog(@"Init'd Nib File for Terminal Controller...");
    
    if (self == nil)
        return nil;
    
    ///[self window];
    
    [theDocument addLevelInfoWinCon:self];
    
    theMap = theDocument;
    theLevel = [theDocument getCurrentLevelLoaded];
    theTerminals = [theLevel getTerminals];
    NSLog(@"Done Init'd Nib File for Terminal Controller...");
    
    theLastObjectEdited = nil;
    lastTextViewUsed = nil;
    draggedTerminalSection = nil;
    poposedTerminalToDelete = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(levelDeallocating:)
                                          name:PhLevelDeallocatingNotification
                                          object:nil];
    return self;
}

- (void)levelDeallocating:(NSNotification *)notification
{
    id levelDataObjectDeallocating = [notification object];
    
    if (theLevel == levelDataObjectDeallocating)
    {
        [theLevel removeMenu:premutationMenu];
        [theMap removeLevelInfoWinCon:self];
        theLevel = nil;
        theMap = nil;
    }
}

- (void)dealloc
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"Terminal Controller Deallocating...");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

/*- (void)nibDidLoad
{
    [super nibDidLoad];
}*/

- (void)windowDidLoad
{
    [super windowDidLoad];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:)
        name:NSOutlineViewSelectionDidChangeNotification object:nil];
    
    [theTeriminalTableView registerForDraggedTypes:[NSArray 				
        arrayWithObjects:@"PfhorgeTerminalSectionData", nil]];
    
    [self selectionChanged:nil];
}

- (BOOL)windowShouldClose:(id)sender
{
    ///[mapDocument removeLevelInfoWinCon:self];
    NSLog(@"Terminal Controller windowShouldClose...");
    [theMap removeLevelInfoWinCon:self];
    //[self release];
    return YES;
}

#pragma mark -
#pragma mark ********* Outline View Data and Delgate Methods *********

- (void)selectionChanged:(NSNotification *)aNotification
{
    id theSelectedObj;
    int theSelectedRow = [theTeriminalTableView selectedRow];
    
    if (theSelectedRow > -1)
        theSelectedObj = [theTeriminalTableView itemAtRow:theSelectedRow];
    else
        theSelectedObj = nil;
    
    if (theLastObjectEdited != nil && [theLastObjectEdited isKindOfClass:[TerminalSection class]])
    {
        if ([self getTheCurrentTextView] != nil)
            [theLastObjectEdited setText:((NSMutableAttributedString *)[[self getTheCurrentTextView] textStorage])];
    }
    
    theLastObjectEdited = theSelectedObj;
    [self updateViewToTerminalSection:theSelectedObj];
}

/*- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    [self NSOutlineViewSelectionDidChangeNotification:nil];
}*/

// *** Data ***
    
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil)
        return [theTerminals count];
    else if ([item isKindOfClass:[TerminalSection class]])
        return 0;
    else if ([item isKindOfClass:[Terminal class]])
        return [[item theSections] count];
    else
    {
        SEND_ERROR_MSG_TITLE(@"Unknown Class Object Encountered In Terimal Controller Data.",
                             @"Unknown Object");
        return 0;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if (item == nil)
        return YES;
    else if ([item isKindOfClass:[TerminalSection class]])
        return NO;
    else if ([item isKindOfClass:[Terminal class]])
        return YES;
    else
    {
        SEND_ERROR_MSG_TITLE(@"Unknown Class Object Encountered In Terimal Controller Data.",
                             @"Unknown Object");
        return NO;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
    if (item == nil)
        return [theTerminals objectAtIndex:index];
    else if ([item isKindOfClass:[Terminal class]])
        return [[item theSections] objectAtIndex:index];
    else if ([item isKindOfClass:[TerminalSection class]])
        return nil;
    else
    {
        SEND_ERROR_MSG_TITLE(@"Unknown Class Object Encountered In Terimal Controller Data.",
                             @"Unknown Object");
        return nil;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return (item == nil) ? @"The Terminals" : (id)[item getPhName];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray*)items toPasteboard:(NSPasteboard*)pboard
{
    id obj = [items objectAtIndex:0];
    
    /// NSLog(@"writeItems");
    
    if ([obj isKindOfClass:[TerminalSection class]])
    {
        NSData *theData = [NSArchiver archivedDataWithRootObject:obj];
        draggedTerminalSection = obj;
        // Don't retain since this is just holding temporaral drag information,
        // and it is only used during a drag!  We could put this in the pboard actually.
        
        // Provide data for our custom type, and simple NSStrings.
        [pboard declareTypes:[NSArray arrayWithObjects:@"PfhorgeTerminalSectionData", nil] owner:self];
        
        // the actual data doesn't matter since DragDropSimplePboardType drags aren't recognized by anyone but us!.
        [pboard setData:theData forType:@"PfhorgeTerminalSectionData"];
        return YES;
    }
    else
        return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView*)outlineView validateDrop:(id)info proposedItem:(id)item proposedChildIndex:(int)index
{ // NSDraggingInfo
    ///NSLog(@"validateDrop");
    
    BOOL targetNodeIsValid = NO;
    //BOOL isOnDropTypeProposal = index==NSOutlineViewDropOnItemIndex;
    
    if (item == nil)
        targetNodeIsValid = NO;
    
    if ([item isKindOfClass:[Terminal class]])
        targetNodeIsValid = YES;
    
    return targetNodeIsValid ? NSDragOperationGeneric : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView acceptDrop:(id)info item:(id)item childIndex:(int)index
{ // NSDraggingInfo
    // draggedTerminalSection may not exsist, and may not be nil in that case. 
    //	it should not happen, but it is a possiblity.  Deal with this possibility elagently in the future...
    Terminal *theTerm = [theLevel getTerminalThatContains:draggedTerminalSection];
    NSMutableArray *destArray = [item theSections];
    int rowNumberForItem = -1;
    
    [draggedTerminalSection retain];
    [[theTerm theSections] removeObject:draggedTerminalSection];
    
    if (((int)[destArray count]) <= index || NSOutlineViewDropOnItemIndex == index)
        [destArray addObject:draggedTerminalSection];
    else
        [destArray insertObject:draggedTerminalSection atIndex:index];
    
    [outlineView reloadData];
    
    rowNumberForItem = [outlineView rowForItem:draggedTerminalSection];
    if (rowNumberForItem > -1)
        [outlineView selectRow:rowNumberForItem byExtendingSelection:NO];
    else
        [outlineView selectRow:0 byExtendingSelection:NO];
    
    //[theTeriminalTableView selectItems:[NSArray arrayWithObjects:draggedTerminalSection, nil] byExtendingSelection: NO];
    
    ///NSLog(@"acceptDrop");
    
    // Since is should of been validated, proably ok without checking...
    // 	But maby you should anyway, just in case...
    
    draggedTerminalSection = nil;
    
    [theLevel recompileTerminalNamesCache];
    
    return YES;
}

#pragma mark -
#pragma mark ********* Outline View Updater And Action Methods *********

- (IBAction)addANewSectionAction:(id)sender
{
    int selectedRowNumber = [theTeriminalTableView selectedRow];
    id theSelectedObj = nil;
    int rowNumberForItem = -1;
    TerminalSection *theNewSection = [[TerminalSection alloc] init];
    
    if (selectedRowNumber >= 0)
        theSelectedObj = [theTeriminalTableView itemAtRow:selectedRowNumber];
    
    if ([theSelectedObj isKindOfClass:[Terminal class]] && theSelectedObj != nil)
    {
        [[theSelectedObj theSections] addObject:theNewSection];
    }
    else
    {
        Terminal *theTerm = [theLevel getTerminalThatContains:theSelectedObj];
        NSMutableArray *destArray;
        int theSelectedItemsIndex;
        
        if (theTerm == nil)
        {
            NSMutableArray *terminals = [theLevel getTerminals];
            if ([terminals count] <= 0)
            {
                SEND_ERROR_MSG(@"Must have a terminal to add sections to first. 103");
                [theNewSection release];
                NSLog(@"past release...");
                return;
            }
            else
                theTerm = [terminals lastObject];
        }
        
        // CHANGE_NOTE: In future, call a Termianl class method for creating sections in that terminal...
        
        destArray = [theTerm theSections];
        theSelectedItemsIndex = ([destArray indexOfObjectIdenticalTo:theSelectedObj] + 1);
        
        [theNewSection setType:[(TerminalSection *)theSelectedObj type]];
        
        if (((int)[destArray count]) <= theSelectedItemsIndex)
            [destArray addObject:theNewSection];
        else
            [destArray insertObject:theNewSection atIndex:theSelectedItemsIndex];
    }
    
    [theTeriminalTableView reloadData];
    
    rowNumberForItem = [theTeriminalTableView rowForItem:theNewSection];
    if (rowNumberForItem > -1)
        [theTeriminalTableView selectRow:rowNumberForItem byExtendingSelection:NO];
    else
        [theTeriminalTableView selectRow:0 byExtendingSelection:NO];
    
    [theNewSection release];
    
}

- (IBAction)addANewTerminalAction:(id)sender
{
    int selectedRowNumber = [theTeriminalTableView selectedRow];
    id theSelectedObj = nil;
    int rowNumberForItem = -1;
    NSMutableArray *terminals = [theLevel getTerminals];
    Terminal *theNewTerminal = [[Terminal alloc] init];
    
    if (selectedRowNumber >= 0)
        theSelectedObj = [theTeriminalTableView itemAtRow:selectedRowNumber];
    
    if (theSelectedObj != nil)
    {
        id theTerminal = nil;
        
        if ([theSelectedObj isKindOfClass:[Terminal class]])
            theTerminal = theSelectedObj;
        else
            theTerminal = [theLevel getTerminalThatContains:theSelectedObj];
        
        rowNumberForItem = ([terminals indexOfObjectIdenticalTo:theTerminal] + 1);
    }
    else
        rowNumberForItem = 0;
    
    if (((int)[terminals count]) <= rowNumberForItem || rowNumberForItem < 0)
        [terminals addObject:theNewTerminal];
    else
        [terminals insertObject:theNewTerminal atIndex:rowNumberForItem];
    
    [theNewTerminal setPhName:[NSString stringWithFormat:@"Terminal %d", ([terminals count] - 1)]];
    
    [theTeriminalTableView reloadData];
    
    rowNumberForItem = [theTeriminalTableView rowForItem:theNewTerminal];
    if (rowNumberForItem > -1)
        [theTeriminalTableView selectRow:rowNumberForItem byExtendingSelection:NO];
    else
        [theTeriminalTableView selectRow:0 byExtendingSelection:NO];
    
    [theNewTerminal release];
    [theLevel recompileTerminalNamesCache];
}

- (IBAction)deleteSelectedAction:(id)sender
{
    int selectedRowNumber = [theTeriminalTableView selectedRow];
    id theSelectedObj = nil;
    //int rowNumberForItem = -1;
    //NSMutableArray *terminals = [theLevel getTerminals];
    
    if (selectedRowNumber >= 0)
        theSelectedObj = [theTeriminalTableView itemAtRow:selectedRowNumber];
        
    if ([theSelectedObj isKindOfClass:[Terminal class]])
    {
        poposedTerminalToDelete = theSelectedObj;
        
    // Open the sheet...
    [NSApp beginSheet:sheetWarningWindow
       modalForWindow:[self window]
        modalDelegate:self
       didEndSelector:NULL
          contextInfo:nil];
    }
    else if ([theSelectedObj isKindOfClass:[TerminalSection class]])
    {
        Terminal *theTerm = [theLevel getTerminalThatContains:theSelectedObj];
        NSMutableArray *sections = [theTerm theSections];
        
        [sections removeObjectIdenticalTo:theSelectedObj];
        theLastObjectEdited = nil;
        [theTeriminalTableView reloadData];
    
        [theTeriminalTableView selectRow:0 byExtendingSelection:NO];
        [theLevel recompileTerminalNamesCache];
    }
    else
        SEND_ERROR_MSG(@"Selected item is not a Terminal or TerminalSection class???");
}

- (IBAction)deleteTerminalConfirmation:(id)sender
{
    int oldIndexRowForTerminal = 0;
    
    if ([[sender title] isEqualToString:@"Cancel"] || poposedTerminalToDelete == nil)
    {
        poposedTerminalToDelete = nil;
        
        // Hide the sheet...
        [sheetWarningWindow orderOut:nil];
        [NSApp endSheet:sheetWarningWindow];
        return;
    }
    
    oldIndexRowForTerminal = [theTeriminalTableView rowForItem:poposedTerminalToDelete];
    
    //[theTeriminalTableView itemAtRow:selectedRowNumber];
    
    // CHANGE_NOTE: In future, make a seperate method for handling the deletion...
    
    [[theLevel getTerminals] removeObject:poposedTerminalToDelete];
    poposedTerminalToDelete = nil;
    theLastObjectEdited = nil;
    [sheetWarningWindow orderOut:nil];
    [NSApp endSheet:sheetWarningWindow];
    
    [theTeriminalTableView reloadData];
    
    [theTeriminalTableView selectRow:0 byExtendingSelection:NO];
    [theLevel recompileTerminalNamesCache];
}

///_no_section_type
- (void)updateViewToTerminalSection:(TerminalSection *)terminalObject
{
    int theType = _no_section_type;
    NSAttributedString *theText = nil;
    ///NSLog(@"Updating...");
    if (terminalObject == nil)
    {
        theType = _no_section_type;
        theText = nil;
        [sectionTypesPopM setEnabled:NO];
        [indexPopM setEnabled:NO];
        [stylePopM setEnabled:NO];
        [sectionTypesPopM selectItemAtIndex:-1];
        [indexPopM setIntValue:0];
    }
    else if ([terminalObject isKindOfClass:[TerminalSection class]])
    {
        theType = [terminalObject type];
        theText = [terminalObject text];
        [sectionTypesPopM setEnabled:YES];
        [indexPopM setEnabled:YES];
        [stylePopM setEnabled:YES];
        [sectionTypesPopM selectItemAtIndex:theType];
        [indexPopM setIntValue:(int)[terminalObject permutation]];
    }
    else if ([terminalObject isKindOfClass:[Terminal class]])
    {
        theType = _no_section_type;
        theText = nil;
        [sectionTypesPopM setEnabled:NO];
        [indexPopM setEnabled:NO];
        [stylePopM setEnabled:NO];
        [sectionTypesPopM selectItemAtIndex:-1];
        [indexPopM setIntValue:0];
    }
    else
    {
        SEND_ERROR_MSG_TITLE(@"Unknown Class Object Encountered In Terimal Controller Data... updateViewToTerminalSection",
                             @"Unknown Object");
        theType = _no_section_type;
        theText = nil;
        [sectionTypesPopM setEnabled:NO];
        [indexPopM setEnabled:NO];
        [stylePopM setEnabled:NO];
        [sectionTypesPopM selectItemAtIndex:-1];
        [indexPopM setIntValue:0];
    }
    
    lastTextViewUsed = nil;
    
    /// NSLog(@"removeMenu BEFORE");
    [theLevel removeMenu:premutationMenu];
    /// NSLog(@"removeMenu AFTER");
    
    switch (theType)
    {
        case _logon_section:
        case _logoff_section:   ///   theText
            [terminalTabView selectTabViewItemAtIndex:1];
            [menuTextTabView selectTabViewItemAtIndex:1];
            [self setTextView:loginAndOffTextView withAttributedString:theText];
            [loginAndOffImageView setImage:[theMap getPICTResourceIndex:[terminalObject permutation]]];
            break;
        case _information_section:
            [self setTextView:informationTextView withAttributedString:theText];
            [terminalTabView selectTabViewItemAtIndex:0];
            [menuTextTabView selectTabViewItemAtIndex:1];
            break;
        case _pict_section:
            [pictureImageView setImage:[theMap getPICTResourceIndex:[terminalObject permutation]]];
        case _checkpoint_section:
            [self setTextView:pictureTextView withAttributedString:theText];
            [terminalTabView selectTabViewItemAtIndex:2];
            [menuTextTabView selectTabViewItemAtIndex:1];
            break;
        case _camera_section:
        case _static_section:
        case _tag_section:
        case _sound_section:
        case _movie_section:
        case _track_section:
            [terminalTabView selectTabViewItemAtIndex:3];
            [menuTextTabView selectTabViewItemAtIndex:1];
            break;
        case _delimiter_section:
        case _success_section:
        case _failure_section:
        case _unfinished_section:
            [terminalTabView selectTabViewItemAtIndex:3];
            [menuTextTabView selectTabViewItemAtIndex:1];
            break;
        case _new_level_teleport_section:
            [terminalTabView selectTabViewItemAtIndex:3];
            
            if ([theMap isKindOfClass:[PhPfhorgeSingleLevelDoc class]])
            {
                NSLog(@"PhPfhorgeSingleLevelDoc confirmed");
                if ([(PhPfhorgeSingleLevelDoc *)theMap isThereAScenarioDocumentLinked])
                {
                    NSLog(@"SETING UP LEVEL NAME MENU!!! confirmed");
                    [menuTextTabView selectTabViewItemAtIndex:0];
                    [theLevel addMenu:premutationMenu asA:_levelMenu];
					if ([terminalObject permutation] < [premutationMenu numberOfItems])
						[premutationMenu selectItemAtIndex:[terminalObject permutation]];
					else
					{
						NSLog(@"new level terminal section level index beyond scenerio bounds...");
						[menuTextTabView selectTabViewItemAtIndex:1];
					}
                }
                else
                    [menuTextTabView selectTabViewItemAtIndex:1];
            }
            else
                [menuTextTabView selectTabViewItemAtIndex:1];
            
            break;
        case _map_teleport_section:
            [theLevel addMenu:premutationMenu asA:_polyMenu];
            [terminalTabView selectTabViewItemAtIndex:3];
            [menuTextTabView selectTabViewItemAtIndex:0];
            
            if ([terminalObject permutationObject] != nil)
                [premutationMenu selectItemAtIndex:[[theLevel namedPolyObjects] indexOfObjectIdenticalTo:[terminalObject permutationObject]]];
            else
                [premutationMenu selectItemAtIndex:-1];
            break;
        case _no_section_type:
        default:
            [terminalTabView selectTabViewItemAtIndex:3];
            [menuTextTabView selectTabViewItemAtIndex:1];
            break;
    }
}

-(NSTextView *)getTheCurrentTextView
{
    return lastTextViewUsed; 
}

 /*   
    IBOutlet id informationTextView;
    IBOutlet id loginAndOffTextView;
    IBOutlet id pictureTextView;
    IBOutlet id noTextMsgTextView;
*/
- (void)setTextView:(id)theTextView withAttributedString:(NSAttributedString *)theString
{
    [[theTextView textStorage] setAttributedString:theString];
    lastTextViewUsed = theTextView;
    [lastTextViewUsed setInsertionPointColor:[NSColor colorWithCalibratedRed:0.00 green:1.00 blue:1.00 alpha:1.00]];
    /*
    int theTextViewLength = [[theTextView string] length];
    int theStringLength = [theString length];
    NSData *theRTFData = [theString RTFFromRange:NSMakeRange(0, theStringLength) documentAttributes:nil];
    ///NSLog(@"View String Length: %d", theTextViewLength);
    ///NSLog(@"Text String Length: %d", theStringLength);
    //.NSLog(@"Text String:\n\n%@\n\n", theString);
   /// NSLog(@"NSData data Length: %d", [theRTFData length]);
    //[theTextView setRichText:YES];
    [theTextView replaceCharactersInRange:NSMakeRange(0, theTextViewLength) withRTF:theRTFData];
    ///NSLog(@"********* DONE *********");
    
    ///[theTextView setString:theString];*/
}


- (IBAction)colorBtnMatrixAction:(id)sender
{
    NSColor *theTextColor;
    NSMutableAttributedString *theTextAtriString = [[NSMutableAttributedString alloc] initWithString:@""];
    id theSelectedObj = [theTeriminalTableView itemAtRow:[theTeriminalTableView selectedRow]];
    int theCellTagClickedOn = -1;
    
    [theTextAtriString setAttributedString:[[self getTheCurrentTextView] textStorage]];
    
    if (![theSelectedObj isKindOfClass:[TerminalSection class]])
        return;
    
    theCellTagClickedOn = [[sender selectedCell] tag];
    
    
    
    switch (theCellTagClickedOn)
    {
        case 0:
            theTextColor = [NSColor greenColor];
            break;
        case 1:
            theTextColor = [NSColor whiteColor];
            break;
        case 2:
            theTextColor = [NSColor redColor];
            break;
        case 3: // dim green
            theTextColor = [NSColor colorWithCalibratedRed:0.00 green:0.50 blue:0.00 alpha:1.00];
            break;
        case 4:
            theTextColor = [NSColor cyanColor];
            break;
        case 5:
            theTextColor = [NSColor yellowColor];
            break;
        case 6:  // dim red
            theTextColor = [NSColor colorWithCalibratedRed:0.50 green:0.00 blue:0.00 alpha:1.00];
            break;
        case 7:
            theTextColor = [NSColor blueColor];
            break;
        default:
            theTextColor = [NSColor greenColor];
            break;
    }
    
    [theTextAtriString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                
                [NSNumber numberWithInt:theCellTagClickedOn],
                @"PhColorTerminalAttribute",
                
                theTextColor,
                NSForegroundColorAttributeName, nil]
            
            range:[[self getTheCurrentTextView] selectedRange]];
    
    [theSelectedObj setText:theTextAtriString];
    
    [self updateViewToTerminalSection:theSelectedObj];
                    
}

- (IBAction)applyPlainStyleAction:(id)sender
{
    NSMutableAttributedString *theTextAtriString = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    id theSelectedObj = [theTeriminalTableView itemAtRow:[theTeriminalTableView selectedRow]];
    
    if (![theSelectedObj isKindOfClass:[TerminalSection class]])
        return;
    
    [theTextAtriString setAttributedString:[[self getTheCurrentTextView] textStorage]]; 
    
    [theTextAtriString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
            
            [NSFont fontWithName:@"Courier" size:12.0],
            NSFontAttributeName,
            
            @"NO",
            @"PhItalicTerminalAttribute",
            
            @"NO",
            @"PhBoldTerminalAttribute",
            
            [NSNumber numberWithInt:0],
            NSUnderlineStyleAttributeName, nil]
            
        range:[[self getTheCurrentTextView] selectedRange]];
        
    [theSelectedObj setText:theTextAtriString];
    [self updateViewToTerminalSection:theSelectedObj];
}

- (IBAction)applyBoldStyleAction:(id)sender
{
    NSMutableAttributedString *theTextAtriString = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    id theSelectedObj = [theTeriminalTableView itemAtRow:[theTeriminalTableView selectedRow]];
    
            NSAttributedString *attrStr = theTextAtriString; 
            NSRange limitRange;
            NSRange effectiveRange;
            id attributeValue; 
            NSFont *boldFont = [NSFont fontWithName:@"Courier-Bold" size:12.0];
            NSFont *boldFontItalic = [[NSFontManager sharedFontManager]
                                    convertFont:[NSFont fontWithName:@"Courier-Bold" size:12.0]
                                    toHaveTrait:NSItalicFontMask];
            NSFont *fontToUse;
    
    if (![theSelectedObj isKindOfClass:[TerminalSection class]])
        return;
    
    [theTextAtriString setAttributedString:[[self getTheCurrentTextView] textStorage]]; 
    
            limitRange = [[self getTheCurrentTextView] selectedRange];
                            //NSMakeRange(0, [attrStr length]);
            
            while (limitRange.length > 0)
            {
                attributeValue = [attrStr attribute:@"PhItalicTerminalAttribute"
                atIndex:limitRange.location longestEffectiveRange:&effectiveRange
                inRange:limitRange];
                
                // familyName italicAngle
                
                // NSLog(@"italicAngle: %g  - Font Name: %@", [attributeValue italicAngle], [attributeValue fontName]); 
                
                if ([attributeValue isEqualTo:@"YES"])
                    fontToUse = boldFontItalic;
                else
                    fontToUse = boldFont;
                
                [theTextAtriString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                        
                        @"YES",
                        @"PhBoldTerminalAttribute",
                        
                        fontToUse,
                        NSFontAttributeName, nil]
                    range:effectiveRange];
            
                limitRange = NSMakeRange(NSMaxRange(effectiveRange),
                NSMaxRange(limitRange) - NSMaxRange(effectiveRange));
            }
        
        
    [theSelectedObj setText:theTextAtriString];
    [self updateViewToTerminalSection:theSelectedObj];
}

- (IBAction)applyUnderlineStyleAction:(id)sender
{
    NSMutableAttributedString *theTextAtriString = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    id theSelectedObj = [theTeriminalTableView itemAtRow:[theTeriminalTableView selectedRow]];
    
    if (![theSelectedObj isKindOfClass:[TerminalSection class]])
        return;
    
    [theTextAtriString setAttributedString:[[self getTheCurrentTextView] textStorage]]; 
    
    [theTextAtriString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:1],
            NSUnderlineStyleAttributeName, nil]
        range:[[self getTheCurrentTextView] selectedRange]];
        
    [theSelectedObj setText:theTextAtriString];
    [self updateViewToTerminalSection:theSelectedObj];
}

- (IBAction)applyItalicStyleAction:(id)sender
{
    NSMutableAttributedString *theTextAtriString = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    id theSelectedObj = [theTeriminalTableView itemAtRow:[theTeriminalTableView selectedRow]];
    
            NSAttributedString *attrStr = theTextAtriString; 
            NSRange limitRange;
            NSRange effectiveRange;
            id attributeValue;
            NSFont *boldItalicFont = [[NSFontManager sharedFontManager]
                                    convertFont:[NSFont fontWithName:@"Courier-Bold" size:12.0]
                                    toHaveTrait:NSItalicFontMask];
            NSFont *regItalicFont = [[NSFontManager sharedFontManager]
                                    convertFont:[NSFont fontWithName:@"Courier" size:12.0]
                                    toHaveTrait:NSItalicFontMask];
            NSFont *fontToUse;
    
    if (![theSelectedObj isKindOfClass:[TerminalSection class]])
        return;
    
    [theTextAtriString setAttributedString:[[self getTheCurrentTextView] textStorage]]; 
    
            limitRange = [[self getTheCurrentTextView] selectedRange];
                            //NSMakeRange(0, [attrStr length]);
            
            while (limitRange.length > 0)
            {
                attributeValue = [attrStr attribute:NSFontAttributeName
                atIndex:limitRange.location longestEffectiveRange:&effectiveRange
                inRange:limitRange];
                
                // familyName italicAngle
                
                NSLog(@"italicAngle: %g  - Font Name: %@", [attributeValue italicAngle], [attributeValue fontName]); 
                
                if ([[attributeValue fontName] isEqualToString:@"Courier-Bold"])
                    fontToUse = boldItalicFont;
                else
                    fontToUse = regItalicFont;
                
                [theTextAtriString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                fontToUse,
                NSFontAttributeName,
                
                @"YES",
                @"PhItalicTerminalAttribute", nil]
                
                range:effectiveRange];
            
                limitRange = NSMakeRange(NSMaxRange(effectiveRange),
                NSMaxRange(limitRange) - NSMaxRange(effectiveRange));
            }
        
    [theSelectedObj setText:theTextAtriString];
    [self updateViewToTerminalSection:theSelectedObj];
}

- (IBAction)stylePopMAction:(id)sender
{
    NSColor *theTextColor;
    NSMutableAttributedString *theTextAtriString = [[NSMutableAttributedString alloc] initWithString:@""];
    id theSelectedObj = [theTeriminalTableView itemAtRow:[theTeriminalTableView selectedRow]];
    
            NSAttributedString *attrStr = theTextAtriString; 
            NSRange limitRange;
            NSRange effectiveRange;
            id attributeValue;
            NSFont *boldFont = [NSFont fontWithName:@"Courier-Bold" size:12.0];
            NSFont *regFont = [NSFont fontWithName:@"Courier" size:12.0];
            NSFont *fontToUse;
            
    NSLog(@"stylePopMAction");
    
    [theTextAtriString setAttributedString:[[self getTheCurrentTextView] textStorage]];
    
    
    if (![theSelectedObj isKindOfClass:[TerminalSection class]])
        return;
    
    switch ([sender indexOfSelectedItem])
    {
        case 0:
            theTextColor = [NSColor greenColor];
            break;
        case 1:

            break;
        case 2:
            [theTextAtriString setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:1],
            NSUnderlineStyleAttributeName, nil]
            range:[[self getTheCurrentTextView] selectedRange]];
            break;
        
        case 3: // dim green 
            
            //= [[self getTheCurrentTextView] attributedSubstringFromRange:[[self getTheCurrentTextView] selectedRange]];
            limitRange = [[self getTheCurrentTextView] selectedRange];
                            //NSMakeRange(0, [attrStr length]);
            
            while (limitRange.length > 0)
            {
                attributeValue = [attrStr attribute:NSFontAttributeName
                atIndex:limitRange.location longestEffectiveRange:&effectiveRange
                inRange:limitRange];
                
                // familyName italicAngle
                
                NSLog(@"italicAngle: %g", [attributeValue italicAngle]); 
                
                if ([[attributeValue familyName] isEqualToString:@"Courier-Bold"])
                    fontToUse = boldFont;
                else
                    fontToUse = regFont;
                
                [theTextAtriString setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                [[NSFontManager sharedFontManager] convertFont:fontToUse toHaveTrait:NSItalicFontMask],
                NSFontAttributeName, nil]
                range:effectiveRange];
            
                limitRange = NSMakeRange(NSMaxRange(effectiveRange),
                NSMaxRange(limitRange) - NSMaxRange(effectiveRange));
            }

            break;
        default:
            /// theTextColor = [NSColor greenColor];
            break;
    }
    

    
    [theSelectedObj setText:theTextAtriString];
    
    [self updateViewToTerminalSection:theSelectedObj];
}
- (IBAction)sectionTypePopMAction:(id)sender
{
    id theSelectedObj = [theTeriminalTableView itemAtRow:[theTeriminalTableView selectedRow]];
    
    if ([theSelectedObj isKindOfClass:[TerminalSection class]])
    {
        [(TerminalSection *)theSelectedObj setType:[sender indexOfSelectedItem]];
        [theTeriminalTableView reloadData];
        [self selectionChanged:nil];
    }
}
- (IBAction)indexPopMAction:(id)sender
{
    id theSelectedObj = [theTeriminalTableView itemAtRow:[theTeriminalTableView selectedRow]];
    
    if ([theSelectedObj isKindOfClass:[TerminalSection class]])
    {
        [(TerminalSection *)theSelectedObj setPermutation:[sender intValue]];
        [self selectionChanged:nil];
    }
}

- (IBAction)changedIndexMenuAction:(id)sender
{
    id theSelectedObj = [theTeriminalTableView itemAtRow:[theTeriminalTableView selectedRow]];
    int theType = _no_section_type;
    
    if ([theSelectedObj isKindOfClass:[TerminalSection class]])
    {
        theType = [(TerminalSection *)theSelectedObj type];
        if (theType == _new_level_teleport_section)
        {
            [theSelectedObj setPermutation:[sender indexOfSelectedItem]];
            /// [theSelectedObj setPermutationObject:nil];
        }
        else if (theType == _map_teleport_section)
        {
            [theSelectedObj setPermutationObject:
                            [[theLevel namedPolyObjects]
                                objectAtIndex:[sender indexOfSelectedItem]]];
        }
        
    }
}

- (IBAction)pictBitRatePMChanged:(id)sender
{
    return;
}


@end



