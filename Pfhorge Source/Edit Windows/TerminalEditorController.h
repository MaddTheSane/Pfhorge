//
//  TerminalEditorController.h
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


#import <Cocoa/Cocoa.h>
#import "TerminalSection.h"
@class LELevelData, LEMap, TerminalSection, Terminal;

@interface TerminalEditorController : NSWindowController <NSOutlineViewDelegate, NSOutlineViewDataSource>
{
    IBOutlet NSOutlineView *theTeriminalTableView;
    IBOutlet id terminalTabView;
    IBOutlet id menuTextTabView;
    
    IBOutlet id premutationMenu;
    
    IBOutlet id informationTextView;
    IBOutlet id loginAndOffTextView;
    IBOutlet id pictureTextView;
    IBOutlet id noTextMsgTextView;
    
    IBOutlet NSImageView *loginAndOffImageView;
    IBOutlet NSImageView *pictureImageView;
    
    // Text/Section Change Controls
    IBOutlet NSColorWell *currentColorCW;
    IBOutlet id sectionTypesPopM;
    IBOutlet id indexPopM;
    IBOutlet id stylePopM;
    
    IBOutlet id pictBitRatePM;
    
    IBOutlet id sheetWarningWindow;
    
    IBOutlet id sheetWarningSubjectMT;
    IBOutlet id sheetWarningMessageMT;
    IBOutlet id sheetWarningCancelBtn;
    
    LEMap *theMap;
    LELevelData *theLevel;
    
    NSTextView *lastTextViewUsed;
    
    NSMutableArray *theTerminals;
    
    id theLastObjectEdited;
    TerminalSection *draggedTerminalSection;
    
    Terminal *poposedTerminalToDelete;
}

- (id)initWithMapDocument:(LEMap *)theDocument;

- (void)selectionChanged:(NSNotification *)aNotification;
//- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

- (void)updateViewToTerminalSection:(TerminalSection *)terminalObject;
- (void)setTextView:(id)theTextView withAttributedString:(NSAttributedString *)theString;
-(NSTextView *)getTheCurrentTextView;

- (IBAction)addANewSectionAction:(id)sender;
- (IBAction)addANewTerminalAction:(id)sender;
- (IBAction)deleteSelectedAction:(id)sender;
- (IBAction)deleteTerminalConfirmation:(id)sender;

- (IBAction)pictBitRatePMChanged:(id)sender;

- (IBAction)colorBtnMatrixAction:(id)sender;

- (IBAction)applyPlainStyleAction:(id)sender;
- (IBAction)applyBoldStyleAction:(id)sender;
- (IBAction)applyUnderlineStyleAction:(id)sender;
- (IBAction)applyItalicStyleAction:(id)sender;
//- (IBAction)stylePopMAction:(id)sender;

- (IBAction)sectionTypePopMAction:(id)sender;
- (IBAction)indexPopMAction:(id)sender;

- (IBAction)changedIndexMenuAction:(id)sender;

@end
