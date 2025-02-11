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

typedef NS_ENUM(SInt8, NDResourceForkPermission) {
	NDResourceForkPermissionCurrent = fsCurPerm,
	NDResourceForkPermissionRead = fsRdPerm,
	NDResourceForkPermissionWrite = fsWrPerm,
	NDResourceForkPermissionReadWrite = fsRdWrPerm,
	NDResourceForkPermissionReadWriteShare = fsRdWrShPerm,
} NS_SWIFT_NAME(NDResourceFork.Permissions);

@interface NDResourceFork : NSObject
{
	ResFileRefNum		fileReference;
}

+ (nullable instancetype)resourceForkForReadingAtURL:(NSURL *)aURL NS_SWIFT_UNAVAILABLE("Use throwable initializers instead");
+ (nullable instancetype)resourceForkForWritingAtURL:(NSURL *)aURL NS_SWIFT_UNAVAILABLE("Use throwable initializers instead");
+ (nullable instancetype)resourceForkForReadingAtPath:(NSString *)aPath NS_SWIFT_UNAVAILABLE("Use URL methods instead");
+ (nullable instancetype)resourceForkForWritingAtPath:(NSString *)aPath NS_SWIFT_UNAVAILABLE("Use URL methods instead");

- (nullable instancetype)initForReadingAtURL:(NSURL *)aURL NS_SWIFT_UNAVAILABLE("Use throwable initializers instead");
- (nullable instancetype)initForWritingAtURL:(NSURL *)aURL NS_SWIFT_UNAVAILABLE("Use throwable initializers instead");
- (nullable instancetype)initForReadingAtURL:(NSURL *)aURL error:(NSError**)outError;
- (nullable instancetype)initForWritingToURL:(NSURL *)aURL error:(NSError**)outError;
- (nullable instancetype)initForReadingAtPath:(NSString *)aPath NS_SWIFT_UNAVAILABLE("Use URL methods instead");
- (nullable instancetype)initForWritingAtPath:(NSString *)aPath NS_SWIFT_UNAVAILABLE("Use URL methods instead");
- (nullable instancetype)initForPermission:(NDResourceForkPermission)aPermission AtURL:(NSURL *)aURL NS_SWIFT_UNAVAILABLE("Use throwable initializers instead");
- (nullable instancetype)initWithPermission:(NDResourceForkPermission)aPermission AtURL:(NSURL *)aURL error:(NSError**)outError NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (BOOL)addData:(NSData *)aData type:(ResType)aType Id:(ResID)anID name:(nullable NSString *)aName NS_SWIFT_UNAVAILABLE("Use throwable methods instead");
- (nullable NSData *)dataForType:(ResType)aType Id:(ResID)anID NS_SWIFT_UNAVAILABLE("Use throwable methods instead");
- (BOOL)removeType:(ResType)aType Id:(ResID)anID NS_SWIFT_UNAVAILABLE("Use throwable methods instead");

- (BOOL)addData:(NSData *)aData type:(ResType)aType Id:(ResID)anID name:(nullable NSString *)aName error:(NSError**)outError;
- (nullable NSData *)dataForType:(ResType)aType Id:(ResID)anID error:(NSError**)outError;
- (BOOL)removeType:(ResType)aType Id:(ResID)anID error:(NSError**)outError;

@end

NS_ASSUME_NONNULL_END
