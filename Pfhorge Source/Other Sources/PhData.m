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
    self = [super init];
    
    if (self == nil)
        return nil;
    
    position = 0;
    
    theData = [value copy];
    
    return self;
}

- (BOOL)setP:(long)value { position = value; return [self checkPosition]; }
- (BOOL)addP:(long)value { position += value; return [self checkPosition]; }
- (BOOL)subP:(long)value { position -= value; return [self checkPosition]; }

- (BOOL)skipObj { [self addP:4]; return [self checkPosition]; }

- (BOOL)skipLengthLong
{
    int theLength = [self getInt];
    
    [self addP:theLength];
    
    return [self checkPosition];
}

- (NSData *)getSubDataWithLength:(NSInteger)theLength
{
    [self checkPosition];
    NSData *subData = [theData subdataWithRange:NSMakeRange(position, theLength)];
    [self addP:theLength];
    return subData;
}

- (byte)getByte
{
    byte value;
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 1)];
    position += 1;
    return value;
}

- (short)getShort
{
    short value;
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 2)];
	value = CFSwapInt16BigToHost(value);
    position += 2;
    return value;
}

- (long long)getLong
{
    long long value;
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 8)];
	value = CFSwapInt64BigToHost(value);
    position += 8;
    return value;
}

- (int)getInt
{
    int value;
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 4)];
	value = CFSwapInt32BigToHost(value);
    position += 4;
    return value;
}

- (unsigned short)getUnsignedShort
{
    unsigned short value;
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 2)];
	value = CFSwapInt16HostToBig(value);
    position += 2;
    return value;
}

- (unsigned long long)getUnsignedLong
{
    unsigned long long value;
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 8)];
	value = CFSwapInt64HostToBig(value);
    position += 8;
    return value;
}

- (unsigned int)getUnsignedInt
{
    unsigned int value;
    [self checkPosition];
    [theData getBytes:&value range:NSMakeRange(position, 4)];
	value = CFSwapInt32HostToBig(value);
    position += 4;
    return value;
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
    int indexNum = [self getInt];
    
    if (indexNum == -1) {
        return nil;
    } else if (indexNum < ((int)[theIndex count]) && indexNum >= 0) {
        objTypesArr[indexNum] = _data_is_primary;
        return [theIndex objectAtIndex:indexNum];
    }
    
    return nil;
}

- (id)getObjectFromIndexUsingLast:(NSArray *)theIndex
{
    int indexNum = [self getInt];
    
    if (indexNum == -1) {
        return nil;
    } else if (indexNum < ((int)[theIndex count]) && indexNum >= 0) {
        return [theIndex objectAtIndex:indexNum];
    } else if (indexNum >= ((int)[theIndex count])) {
        return [theIndex lastObject];
    }
    
    return nil;
}

- (NSString *)getPascalString
{
    int length = [self getByte];
    
    unsigned char theChar[length];
    const unsigned char *theCharConstPntr;
    NSString *theTmpCharString;
    
    for (int i = 0; i < length; i++) {
        theChar[i] = [self getByte];
        
        // Just in case, although it should not be nessary...
        if (theChar[i] == 0)
            break;
    }
    
    theCharConstPntr = theChar;
    theTmpCharString = [NSString stringWithCString:(const char*)theCharConstPntr encoding:NSMacOSRomanStringEncoding];
    
    return theTmpCharString;
}

@end
