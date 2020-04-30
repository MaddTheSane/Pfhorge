//
//  PhNoteGroupsCon.h
//  Pfhorge
//
//  Created by Jagil on Wed Oct 29 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PhNoteGroup;

@interface PhNoteGroupsCon : NSObject
{
    IBOutlet id mainController;
    
    IBOutlet id table;
}

- (void)awake;
- (NSArray *)data;
- (PhNoteGroup *)entryAtIndex:(int)index;

@end
