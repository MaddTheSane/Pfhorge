//
//  PhNoteGroupsCon.h
//  Pfhorge
//
//  Created by Jagil on Wed Oct 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PhNoteGroup, LELevelWindowController;

@interface PhNoteGroupsCon : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet LELevelWindowController *mainController;
    
    IBOutlet NSTableView *table;
}

- (void)awake;
- (NSArray *)data;
- (PhNoteGroup *)entryAtIndex:(NSInteger)index;

@end
