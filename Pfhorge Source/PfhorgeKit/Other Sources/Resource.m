//
//  Resource.m
//  ACME Station
//
//  Created by thomas on Tue Nov 13 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "Resource.h"


@implementation Resource {
    Str255 nameAsStr255;
}
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
    if (nameAsStr255[0] == 0 && name.length != 0) {
        CFStringGetPascalString((CFStringRef)name, nameAsStr255, 256, kCFStringEncodingMacRoman);
    }
    return nameAsStr255;
}

@synthesize loaded;
+ (NSSet<NSString *> *)keyPathsForValuesAffectingLoaded
{
    return [NSSet setWithObject:@"data"];
}

@synthesize data;

- (void)setData:(NSData *)newData
{
    data = [newData copy];
    
    loaded = YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Resource '%@' (%@) named \"%@\", is loaded: %@", type, resID, name, loaded ? @"YES" : @"NO"];
}

@end
