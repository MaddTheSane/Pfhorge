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
    long theLength = [self getLong];
    
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
    [theData getBytes:&value range:NSMakeRange(position, 4)];
	value = CFSwapInt32BigToHost(value);
    position += 4;
    return value;
}

- (int)getInt
{
    return [self getLong];
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
    [theData getBytes:&value range:NSMakeRange(position, 4)];
	value = CFSwapInt32HostToBig(value);
    position += 4;
    return value;
}

- (unsigned int)getUnsignedInt
{
    return [self getUnsignedLong];
}

- (long)length { return [theData length]; };

- (long)getPosition { return position; };

- (BOOL)checkP
{
    if (position >= ((long)[theData length]))
    {
        NSLog(@"WARNING: Position: %d   Excedded Length: %d", position, [theData length]);
        position = 0;
        return NO;
    }
    
    return YES;
}

- (id)getObjectFromIndex:(NSArray *)theIndex objTypesArr:(short *)objTypesArr
{
    long indexNum = [self getLong];
    
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
    long indexNum = [self getLong];
    
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
        if (theChar[i] == NULL)
            break;
    }
    
    theCharConstPntr = theChar;
    theTmpCharString = [NSString stringWithCString:theCharConstPntr]; //length:theCharAmount];
    
    return theTmpCharString;
}

@end
