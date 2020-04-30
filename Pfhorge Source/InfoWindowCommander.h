//
//  InfoWindowCommander.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Fri Dec 14 2001.
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

@class LELevelData, LEMap;

@interface InfoWindowCommander : NSWindowController
{
    IBOutlet id theSheet;
    IBOutlet id theInputBox;
    IBOutlet id renameSheetMsgIT;
    
    LELevelData *mapLevel;
    LEMap	*mapDocument;
    id		theObjBeingEdited;
}

- (IBAction)renameObjectAction:(id)sender;
- (IBAction)renameSheetApplyAction:(id)sender;
- (IBAction)renameSheetCancelAction:(id)sender;

- (void)setupTitlesAndNames;

- (id)initWithLevel:(LELevelData *)theLevel
                    withMapDocument:(LEMap *)theDocument
                    withNibFile:(NSString *)nibFileName
                    withEditingObj:(id)theObj;

- (int)tagIndexNumberFromShort:(short)tagNumber;
- (id)getObjectBeingEdited;
@end
