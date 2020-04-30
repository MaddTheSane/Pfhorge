//
//  PathwaysExchange.h
//  Pfhorge
//
//  Created by Jagil on Wed Jun 18 2003.
//  LP: all the PID-specific stuff has been pushed into the methods file.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhData, LELevelData;

@interface PathwaysExchange : NSObject
{
    NSData *data;	// Keeping it very simple...
    NSData *dpinData;
}

+ (BOOL)convertPIDMapToArchived:(NSData *)theData
                         levels:(NSMutableArray *)theArchivedLevels
                     levelNames:(NSMutableArray *)theLevelNamesEXP
                   resourceData:(NSData *)dpin128Data;

- (id)initWithData:(NSData *)theData;
- (id)initWithData:(NSData *)theData resourceData:(NSData *)dpin128Data;

- (int)levelCount;
- (NSArray *)levelNames;
- (LELevelData *)getPIDLevel:(int)levNum;

@end
