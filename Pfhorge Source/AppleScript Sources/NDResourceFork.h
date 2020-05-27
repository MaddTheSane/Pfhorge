/*
 *  NDResourceFork.h
 *  AppleScriptObjectProject
 *
 *  Created by nathan on Wed Dec 05 2001.
 *  Copyright (c) 2001 Nathan Day. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

NS_ASSUME_NONNULL_BEGIN

@interface NDResourceFork : NSObject
{
	ResFileRefNum		fileReference;
}

+ (nullable instancetype)resourceForkForReadingAtURL:(NSURL *)aURL;
+ (nullable instancetype)resourceForkForWritingAtURL:(NSURL *)aURL;
+ (nullable instancetype)resourceForkForReadingAtPath:(NSString *)aPath;
+ (nullable instancetype)resourceForkForWritingAtPath:(NSString *)aPath;

- (nullable instancetype)initForReadingAtURL:(NSURL *)aURL;
- (nullable instancetype)initForWritingAtURL:(NSURL *)aURL;
- (nullable instancetype)initForReadingAtPath:(NSString *)aPath;
- (nullable instancetype)initForWritingAtPath:(NSString *)aPath;
- (nullable instancetype)initForPermission:(SInt8)aPermission AtURL:(NSURL *)aURL;

- (BOOL)addData:(NSData *)aData type:(ResType)aType Id:(ResID)anID name:(nullable NSString *)aName;
- (nullable NSData *)dataForType:(ResType)aType Id:(ResID)anID;
- (BOOL)removeType:(ResType)aType Id:(ResID)anID;

@end

NS_ASSUME_NONNULL_END
