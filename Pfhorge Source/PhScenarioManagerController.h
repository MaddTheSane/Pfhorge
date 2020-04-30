//
//  PhScenarioManagerController.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 02 2002.
//  Copyright (c) 2002 Joshua D. Orr. All rights reserved.
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



#import <AppKit/AppKit.h>


@interface PhScenarioManagerController : NSWindowController
{
    IBOutlet NSTableView *theLevelTable;
    
    BOOL alreadyNotifiedOfBecomingMain;
}

- (void)setupDataSourceForLevelTable;

- (IBAction)notDoneYet:(id)sender;
- (IBAction)reloadLevelTable:(id)sender;
- (IBAction)mergeScenarioToMap:(id)sender;
- (IBAction)rescanProjectDirectory:(id)sender;
- (IBAction)editSelectedLevel:(id)sender;
- (IBAction)exportSelectedToMarathonMap:(id)sender;
- (IBAction)deleteSelectedLevel:(id)sender;

- (void)savePanelDidEnd:(id)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
- (void)savePanelDidEndForSingleExport:(id)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

@end
