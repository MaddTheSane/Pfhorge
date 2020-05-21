//
//  PhData.h
//  Pfhorge
//
//  Created by Jagil on Sun Apr 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PhTypesStructresEnums.h"


//! This assumes the data is in big-endian format.
@interface PhData : NSObject {
    NSData *theData;
    NSInteger position;
}

- (instancetype)initWithData:(NSData *)value NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (BOOL)setP:(long)value;
- (BOOL)addP:(long)value;
- (BOOL)subP:(long)value;

- (BOOL)skipObj;
- (BOOL)skipLengthLong;

-(NSData *)getSubDataWithLength:(NSInteger)theLength;

- (byte)getByte;
- (short)getShort;
- (long long)getLong;
- (int)getInt;
- (unsigned short)getUnsignedShort;
- (unsigned long long)getUnsignedLong;
- (unsigned int)getUnsignedInt;

@property (readonly) NSInteger currentPosition;
@property (readonly) NSInteger length;

- (BOOL)checkPosition;
- (id)getObjectFromIndex:(NSArray *)theIndex objTypesArr:(short *)objTypesArr;
- (id)getObjectFromIndexUsingLast:(NSArray *)theIndex;

@end
