//
//  PhData.h
//  Pfhorge
//
//  Created by Jagil on Sun Apr 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PhTypesStructresEnums.h"


@interface PhData : NSObject {
    NSData *theData;
    long position;
}

- (id)initWithSomeData:(NSData *)value;

- (BOOL)setP:(long)value;
- (BOOL)addP:(long)value;
- (BOOL)subP:(long)value;

- (BOOL)skipObj;
- (BOOL)skipLengthLong;

-(NSData *)getSubDataLength:(long)theLength;

- (byte)getByte;
- (short)getShort;
- (long)getLong;
- (int)getInt;
- (unsigned short)getUnsignedShort;
- (unsigned long)getUnsignedLong;
- (unsigned int)getUnsignedInt;

- (long)getPosition;

- (BOOL)checkP;
- (id)getObjectFromIndex:(NSArray *)theIndex objTypesArr:(short *)objTypesArr;
- (id)getObjectFromIndexUsingLast:(NSArray *)theIndex;

@end
