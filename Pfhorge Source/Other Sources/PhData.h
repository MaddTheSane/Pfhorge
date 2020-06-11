//
//  PhData.h
//  Pfhorge
//
//  Created by Jagil on Sun Apr 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PhTypesStructresEnums.h"

NS_ASSUME_NONNULL_BEGIN

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

-(nullable NSData *)getSubDataWithLength:(NSInteger)theLength;

- (BOOL)getByte:(byte*)toGet NS_REFINED_FOR_SWIFT;
- (BOOL)getShort:(short*)toGet NS_REFINED_FOR_SWIFT;
- (BOOL)getInt:(int*)toGet NS_REFINED_FOR_SWIFT;
- (BOOL)getLong:(long long*)toGet NS_REFINED_FOR_SWIFT;
- (BOOL)getUnsignedShort:(unsigned short*)toGet NS_REFINED_FOR_SWIFT;
- (BOOL)getUnsignedInt:(unsigned int*)toGet NS_REFINED_FOR_SWIFT;
- (BOOL)getUnsignedLong:(unsigned long long*)toGet NS_REFINED_FOR_SWIFT;

@property (readonly) NSInteger currentPosition;
@property (readonly) NSInteger length;

- (BOOL)checkPosition;
- (nullable id)getObjectFromIndex:(NSArray *)theIndex objTypesArr:(short *)objTypesArr;
- (nullable id)getObjectFromIndexUsingLast:(NSArray *)theIndex;

@end

//! This assumes the data is in little-endian format.
@interface PhLEData : PhData

@end

NS_ASSUME_NONNULL_END
