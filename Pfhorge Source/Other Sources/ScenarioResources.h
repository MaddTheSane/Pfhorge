//
//  ScenarioResources.h
//  ACME Station
//
//  Created by thomas on Tue Nov 13 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Resource;
@class PhProgress;

NS_ASSUME_NONNULL_BEGIN

//TODO: Update to use MacBinary for cross-platform compatibility!
@interface ScenarioResources : NSObject {
    NSMutableDictionary<NSString*, NSMutableArray<Resource*>*>	*typeDict;
    
    NSString		*filename;
}
+ (BOOL)isAppleSingleAtURL:(NSURL*)url findResourceFork:(BOOL)rsrc_fork offset:(nullable int*)offset length:(nullable int*)length;
+ (BOOL)isMacBinaryAtURL:(NSURL*)url dataLength:(nullable int*)data_length resourceLength:(nullable int*)rsrc_length;


- (instancetype)initWithContentsOfFile:(NSString *)fileName;
- (nullable instancetype)initWithContentsOfURL:(NSURL *)fileName error:(NSError**)outError;
- (BOOL)loadContentsOfFile:(NSString *)fileName;
- (BOOL)loadContentsOfFile:(NSString *)fileName error:(NSError**)outError;
- (void)saveToFile:(NSString *)fileName oldFile:(nullable NSString *)oldFileName;

- (nullable Resource *)resourceOfType:(NSString *)type index:(ResID)index;
- (nullable Resource *)resourceOfType:(NSString *)type index:(ResID)index load:(BOOL)load;

- (void)saveResourcesOfType:(NSString *)type to:(NSString *)baseDirPath extention:(NSString *)fileExt progress:(BOOL)showProgress;
- (void)iterateResourcesOfType:(NSString *)type progress:(BOOL)showProgress block:(void(NS_NOESCAPE ^)(Resource*, NSData*, PhProgress*_Nullable))block;

@property (readonly) NSInteger count;
- (nullable Resource *)objectAtIndex:(NSInteger)index;

- (void)addResource:(Resource *)resource;
- (void)removeResource:(Resource *)resource;

@property (readonly, strong) NSMutableDictionary<NSString*, NSMutableArray<Resource*>*> *typeDict;
@end

NS_ASSUME_NONNULL_END
