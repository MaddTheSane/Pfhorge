//
//  Resource.h
//  ACME Station
//
//  Created by thomas on Tue Nov 13 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Resource : NSObject {
    NSNumber	*resID;
    NSString	*type;
    NSString	*name;
    
    BOOL	loaded;
    NSData	*data;
}
- (id)initWithID:(int)newID type:(NSString *)resType name:(NSString *)resName;

- (NSComparisonResult)compare:(id)object;

- (NSNumber *)resID;
- (NSString *)type;
- (ResType)typeAsResType;
- (NSString *)name;
- (ConstStr255Param)nameAsStr255;
- (BOOL)loaded;
- (void)setLoaded:(BOOL)value;
- (NSData *)data;
- (void)setData:(NSData *)newData;
@end
