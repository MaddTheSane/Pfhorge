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
    if (self = [super init]) {
        resID = @(newID);
        type = [resType copy];
        name = [resName copy];
        
        loaded = NO;
        data = [NSData data];
    }
    return self;
}

- (NSComparisonResult)compare:(id)object
{
    return [(NSNumber *)object compare:resID];
}

@synthesize resID;
@synthesize type;

- (ResType)typeAsResType
{
    return UTGetOSTypeFromString((__bridge CFStringRef)type);
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
    data = newData;
    
    [self setLoaded:YES];
}
@end
