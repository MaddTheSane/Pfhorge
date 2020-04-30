//
//  Resource.m
//  ACME Station
//
//  Created by thomas on Tue Nov 13 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "Resource.h"


@implementation Resource
- (id)initWithID:(int)newID type:(NSString *)resType name:(NSString *)resName
{
    [super init];
    
    resID = [[NSNumber numberWithUnsignedShort:newID] retain];
    type = [resType copy];
    name = [resName copy];
    
    loaded = NO;
    data = [[NSData data] retain];
    
    return self;
}

- (void)dealloc
{
    [data release];
    
    [resID release];
    [type release];
    [name release];
    
    [super dealloc];
}

- (NSComparisonResult)compare:(id)object
{
    return [(NSNumber *)object compare:resID];
}

- (NSNumber *)resID
{
    return resID;
}

- (NSString *)type
{
    return type;
}

- (ResType)typeAsResType
{
    ResType value;
    
    [type getCString:(unsigned char *)&value maxLength:4];
    
    return value;
}

- (NSString *)name
{
    return name;
}

- (ConstStr255Param)nameAsStr255
{
    static unsigned char	*string;
    
    if (!string) {
        string = malloc(256);
    }
    
    string[0] = [name length];
    [name getCString:&string[1] maxLength:255];
    
    return string;
}

- (BOOL)loaded
{
    return loaded;
}

- (void)setLoaded:(BOOL)value
{
    loaded = value;
}

- (NSData *)data
{
    return data;
}

- (void)setData:(NSData *)newData
{
    [data release];
    
    data = [newData retain];
    
    [self setLoaded:YES];
}
@end
