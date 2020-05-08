//
//  PhPfhorgeScenarioLevelDoc.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Mon May 27 2002.
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



#import <AppKit/AppKit.h>
#import "PhScenarioData.h"
#import "PhScenarioManagerController.h"

extern NSString *PhScenarioDeallocatingNotification;
extern NSString *PhScenarioLevelNamesChangedNotification;

@interface PhPfhorgeScenarioLevelDoc : NSDocument
{
    PhScenarioData *scenarioData;
    PhScenarioManagerController *theScenarioDocumentWindowController;
}

- (NSImage *)getPICTResourceIndex:(ResID)PICTIndex;
- (void)openADocumentFile:(NSString *)fullPath;

// *** Open User Utilites ***

- (void)reloadLevelTable:(id)sender;
- (IBAction)importMarathonMap:(id)sender;
- (IBAction)importPathwaysMap:(id)sender;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;

- (void)importMapScriptDone:(NSOpenPanel *)sheet returnCode:(NSModalResponse)returnCode contextInfo:(void *)contextInfo;

    
// *** Document Methods ***
- (void)windowControllerDidLoadNib:(NSWindowController *) aController;
- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)contextInfo;

// *** Utilites ***
- (NSString *)getFullPathForDirectory;
- (void)saveArrayOfNSDatas:(NSArray<NSData*> *)theDataObjs withFileNames:(NSArray<NSString*> *)theFileNames baseDir:(NSString *)basePath;

- (void)rescanProjectDirectoryNow;
- (void)exportLevelToMarathonMap:(NSString *)fullPath;
- (void)saveMergedMapTo:(NSString *)fullPath;

// *** Information ***
- (id)dataObjectForLevelNameTable;
- (NSArray<NSString*> *)getLevelNames;

@end
