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

- (id)initWithSomeData:(NSData *)value
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    position = 0;
    
    theData = [value copy];
    
    return self;
}

- (void)dealloc
{
    [theData release];
    [super dealloc];
}

- (BOOL)setP:(long)value { position = value; return [self checkP]; }
- (BOOL)addP:(long)value { position += value; return [self checkP]; }
- (BOOL)subP:(long)value { position -= value; return [self checkP]; }

- (BOOL)skipObj { [self addP:4]; return [self checkP]; }

- (BOOL)skipLengthLong
{
    long theLength = [self getInt];
    
    [self addP:theLength];
    
    return [self checkP];
}

- (NSData *)getSubDataLength:(long)theLength
{
    [self checkP];
    NSData *subData = [theData subdataWithRange:NSMakeRange(position, theLength)];
    [self addP:theLength];
    return subData;
}
/*
- (BOOL)getBool
{
    long value;
    [self checkP];
    [theData getBytes:&value range:NSMakeRange(position, 4)];
    position += 4;
    return value;
}
*/
- (byte)getByte
{
    byte value;
    [self checkP];
    [theData getBytes:&value range:NSMakeRange(position, 1)];
    position += 1;
    return value;
}

- (short)getShort
{
    short value;
    [self checkP];
    [theData getBytes:&value range:NSMakeRange(position, 2)];
	value = CFSwapInt16BigToHost(value);
    position += 2;
    return value;
}

- (long)getLong
{
    long value;
    [self checkP];
    [theData getBytes:&value range:NSMakeRange(position, 8)];
	value = CFSwapInt64BigToHost(value);
    position += 8;
    return value;
}

- (int)getInt
{
    int value;
    [self checkP];
    [theData getBytes:&value range:NSMakeRange(position, 4)];
	value = CFSwapInt32BigToHost(value);
    position += 4;
    return value;
}

- (unsigned short)getUnsignedShort
{
    unsigned short value;
    [self checkP];
    [theData getBytes:&value range:NSMakeRange(position, 2)];
	value = CFSwapInt16HostToBig(value);
    position += 2;
    return value;
}

- (unsigned long)getUnsignedLong
{
    unsigned long value;
    [self checkP];
    [theData getBytes:&value range:NSMakeRange(position, 8)];
	value = CFSwapInt64HostToBig(value);
    position += 8;
    return value;
}

- (unsigned int)getUnsignedInt
{
    unsigned int value;
    [self checkP];
    [theData getBytes:&value range:NSMakeRange(position, 4)];
	value = CFSwapInt32HostToBig(value);
    position += 4;
    return value;
}

- (long)length { return [theData length]; };

- (long)getPosition { return position; };

- (BOOL)checkP
{
    if (position >= ((long)[theData length]))
    {
		NSLog(@"WARNING: Position: %d   Excedded Length: %lu", position, (unsigned long)[theData length]);
        position = 0;
        return NO;
    }
    
    return YES;
}

- (id)getObjectFromIndex:(NSArray *)theIndex objTypesArr:(short *)objTypesArr
{
    int indexNum = [self getInt];
    
    if (indexNum == -1)
        return nil;
    else if (indexNum < ((int)[theIndex count]) && indexNum >= 0)
    {
        objTypesArr[indexNum] = _data_is_primary;
        return [theIndex objectAtIndex:indexNum];
    }
    
    return nil;
}

- (id)getObjectFromIndexUsingLast:(NSArray *)theIndex
{
    int indexNum = [self getInt];
    
    if (indexNum == -1)
        return nil;
    else if (indexNum < ((int)[theIndex count]) && indexNum >= 0)
    {
        return [theIndex objectAtIndex:indexNum];
    }
    else if (indexNum >= ((int)[theIndex count]))
    {
        return [theIndex lastObject];
    }
    
    return nil;
}

- (NSString *)getPascalString
{
    int length = [self getByte];
    
    unsigned char theChar[length];
    const char *theCharConstPntr;
    int i;
    NSString *theTmpCharString;
    
    for (i = 0; i < length; i++)
    {
        theChar[i] = [self getByte];
        
        // Just in case, although it should not be nessary...
        if (theChar[i] == 0)
            break;
    }
    
    theCharConstPntr = theChar;
    theTmpCharString = @(theCharConstPntr); //length:theCharAmount];
    
    return theTmpCharString;
}

@end
