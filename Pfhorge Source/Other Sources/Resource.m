//
//  Resource.m
//  ACME Station
//
//  Created by thomas on Tue Nov 13 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "Resource.h"


@implementation Resource
- (id)initWithID:(ResID)newID type:(NSString *)resType name:(NSString *)resName
{
    [super init];
    
    resID = [@(newID) retain];
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

@synthesize resID;
@synthesize type;

- (ResType)typeAsResType
{
    return UTGetOSTypeFromString((CFStringRef)type);
}

@synthesize name;

- (ConstStr255Param)nameAsStr255
{
    static unsigned char	*string;
    
    if (!string) {
        string = malloc(256);
    }
    CFStringGetPascalString((CFStringRef)name, string, 256, kCFStringEncodingMacRoman);
    
    return string;
}

@synthesize loaded;
+ (NSSet<NSString *> *)keyPathsForValuesAffectingLoaded
{
    return [NSSet setWithObject:@"data"];
}

@synthesize data;

- (void)setData:(NSData *)newData
{
    [data release];
    
    data = [newData retain];
    
    [self setLoaded:YES];
}
@end
