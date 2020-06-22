//
//  PhData.m
//  Pfhorge
//
//  Created by Jagil on Sun Apr 06 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "PhData.h"
#import "LELevelData.h"
#import "PathwaysExchange.h"

@implementation PhData

- (id)initWithData:(NSData *)value
{
    if (self = [super init]) {
        position = 0;
        
        theData = [value copy];
    }
    
    return self;
}

- (BOOL)setPosition:(long)value
{
    [self willChangeValueForKey:@"currentPosition"];
    position = value;
    [self didChangeValueForKey:@"currentPosition"];
    return [self checkPosition];
}
- (BOOL)addToPosition:(long)value
{
    [self willChangeValueForKey:@"currentPosition"];
    position += value;
    [self didChangeValueForKey:@"currentPosition"];
    return [self checkPosition];
}
- (BOOL)subtractFromPosition:(long)value
{
    [self willChangeValueForKey:@"currentPosition"];
    position -= value;
    [self didChangeValueForKey:@"currentPosition"];
    return [self checkPosition];
}

- (BOOL)skipObject { [self addToPosition:4]; return [self checkPosition]; }

- (BOOL)skipLengthLong
{
    int theLength;
    BOOL valid = [self getInt:&theLength];
    if (!valid) {
        return NO;
    }
    
    return [self addToPosition:theLength];
}

- (NSData *)getSubDataWithLength:(NSInteger)theLength
{
    [self checkPosition];
    NSRange range = NSMakeRange(position, theLength);
    if (theData.length < NSMaxRange(range)) {
        return nil;
    }
    NSData *subData = [theData subdataWithRange:range];
    [self addToPosition:theLength];
    return subData;
}

- (BOOL)getByte:(byte*)toGet
{
    if (position + 1 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:toGet range:NSMakeRange(position, 1)];
    position += 1;
    return YES;

}

- (BOOL)getShort:(short*)toGet
{
    short value;
    if (position + 2 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 2)];
    *toGet = CFSwapInt16BigToHost(value);
    position += 2;
    return YES;
}

- (BOOL)getLong:(long long*)toGet
{
    long long value;
    if (position + 8 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 8)];
    *toGet = CFSwapInt64BigToHost(value);
    position += 8;
    return YES;
}

- (BOOL)getInt:(int*)toGet
{
    int value;
    if (position + 4 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 4)];
    *toGet = CFSwapInt32BigToHost(value);
    position += 4;
    return YES;
}

- (BOOL)getUnsignedShort:(unsigned short*)toGet
{
    unsigned short value;
    if (position + 2 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 2)];
    *toGet = CFSwapInt16BigToHost(value);
    position += 2;
    return YES;
}

- (BOOL)getUnsignedLong:(unsigned long long*)toGet
{
    unsigned long long value;
    if (position + 8 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 8)];
    *toGet = CFSwapInt64BigToHost(value);
    position += 8;
    return YES;
}

- (BOOL)getUnsignedInt:(unsigned int*)toGet
{
    unsigned int value;
    if (position + 4 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 4)];
    *toGet = CFSwapInt32BigToHost(value);
    position += 4;
    return YES;
}

- (NSInteger)length { return [theData length]; };

@synthesize currentPosition=position;

- (BOOL)checkPosition
{
    if (position >= [theData length]) {
        NSLog(@"WARNING: Position: %ld   Excedded Length: %lu", (long)position, (unsigned long)[theData length]);
        position = 0;
        return NO;
    }
    
    return YES;
}

- (id)getObjectFromIndex:(NSArray *)theIndex objTypesArr:(short *)objTypesArr
{
    int indexNum;
    BOOL valid = [self getInt:&indexNum];
    if (!valid) {
        return nil;
    }
    
    if (indexNum == -1) {
        return nil;
    } else if (indexNum < [theIndex count] && indexNum >= 0) {
        objTypesArr[indexNum] = _data_is_primary;
        return [theIndex objectAtIndex:indexNum];
    }
    
    return nil;
}

- (id)getObjectFromIndexUsingLast:(NSArray *)theIndex
{
    int indexNum;
    BOOL valid = [self getInt:&indexNum];
    if (!valid) {
        return nil;
    }

    if (indexNum == -1) {
        return nil;
    } else if (indexNum < [theIndex count] && indexNum >= 0) {
        return [theIndex objectAtIndex:indexNum];
    } else if (indexNum >= [theIndex count]) {
        return [theIndex lastObject];
    }
    
    return nil;
}

@end

@implementation PhLEData

- (BOOL)getShort:(short*)toGet
{
    short value;
    if (position + 2 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 2)];
    *toGet = CFSwapInt16LittleToHost(value);
    position += 2;
    return YES;

}

- (BOOL)getInt:(int*)toGet
{
    int value;
    if (position + 4 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 4)];
    *toGet = CFSwapInt32LittleToHost(value);
    position += 4;
    return YES;
}

- (BOOL)getLong:(long long*)toGet
{
    long long value;
    if (position + 8 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 8)];
    *toGet = CFSwapInt64LittleToHost(value);
    position += 8;
    return YES;
}

- (BOOL)getUnsignedShort:(unsigned short*)toGet
{
    unsigned short value;
    if (position + 2 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 2)];
    *toGet = CFSwapInt16LittleToHost(value);
    position += 2;
    return YES;
}

- (BOOL)getUnsignedInt:(unsigned int*)toGet
{
    unsigned int value;
    if (position + 4 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 4)];
    *toGet = CFSwapInt32LittleToHost(value);
    position += 4;
    return YES;
}

- (BOOL)getUnsignedLong:(unsigned long long*)toGet
{
    unsigned long long value;
    if (position + 8 > theData.length) {
        return NO;
    }
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 8)];
    *toGet = CFSwapInt64LittleToHost(value);
    position += 8;
    return YES;
}

@end
