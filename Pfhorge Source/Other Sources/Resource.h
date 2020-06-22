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
- (instancetype)initWithID:(ResID)newID type:(NSString *)resType name:(NSString *)resName;

- (NSComparisonResult)compare:(id)object;

@property (readonly, copy) NSNumber *resID;
@property (readonly, copy) NSString *type;
@property (nonatomic, readonly) ResType typeAsResType;
@property (readonly, copy) NSString *name;
- (ConstStr255Param)nameAsStr255 NS_RETURNS_INNER_POINTER;
@property (nonatomic, readonly) ConstStr255Param nameAsStr255;
@property BOOL loaded;
@property (nonatomic, copy) NSData *data;
@end
