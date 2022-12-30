//
//  PhData.h
//  Pfhorge
//
//  Created by Jagil on Sun Apr 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PfhorgeKit/PhTypesStructresEnums.h>

NS_ASSUME_NONNULL_BEGIN

//! This assumes the data is in big-endian format.
@interface PhData : NSObject {
    NSData *theData;
    NSInteger position;
}

- (instancetype)initWithData:(NSData *)value NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (BOOL)setPosition:(long)value;
- (BOOL)addToPosition:(long)value;
- (BOOL)subtractFromPosition:(long)value;

- (BOOL)skipObject;
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
- (nullable id)getObjectFromIndex:(NSArray *)theIndex objTypesArr:(short *)objTypesArr NS_REFINED_FOR_SWIFT;
- (nullable id)getObjectFromIndexUsingLast:(NSArray *)theIndex NS_REFINED_FOR_SWIFT;

@end

//! For little-endian data.
@interface PhLEData : PhData

@end

NS_ASSUME_NONNULL_END
