/*
 *  NDResourceFork.h
 *  AppleScriptObjectProject
 *
 *  Created by nathan on Wed Dec 05 2001.
 *  Copyright (c) 2001 Nathan Day. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface NDResourceFork : NSObject
{
	FSIORefNum		fileReference;
}

+ (instancetype)resourceForkForReadingAtURL:(NSURL *)aURL;
+ (instancetype)resourceForkForWritingAtURL:(NSURL *)aURL;
+ (instancetype)resourceForkForReadingAtPath:(NSString *)aPath;
+ (instancetype)resourceForkForWritingAtPath:(NSString *)aPath;

- (instancetype)initForReadingAtURL:(NSURL *)aURL;
- (instancetype)initForWritingAtURL:(NSURL *)aURL;
- (instancetype)initForReadingAtPath:(NSString *)aPath;
- (instancetype)initForWritingAtPath:(NSString *)aPath;
- (instancetype)initForPermission:(char)aPermission AtURL:(NSURL *)aURL;

- (BOOL)addData:(NSData *)aData type:(ResType)aType Id:(ResID)anID name:(NSString *)aName;
- (NSData *)dataForType:(ResType)aType Id:(ResID)anID;
- (BOOL)removeType:(ResType)aType Id:(ResID)anID;

@end
