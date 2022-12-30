/*
 *  NSAppleEventDescriptor+NDAppleScriptObject.h
 *  AppleScriptObjectProject
 *
 *  Created by Nathan Day on Fri Dec 14 2001.
 *  Copyright (c) 2001 Nathan Day. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface NSAppleEventDescriptor (NDAppleScriptObject)

+ (NSAppleEventDescriptor *)appleEventDescriptorWithString:(NSString *)aString;

+ (NSAppleEventDescriptor *)aliasListDescriptorWithArray:(NSArray *)aArray;

+ (NSAppleEventDescriptor *)appleEventDescriptorWithURL:(NSURL *)aURL;
+ (NSAppleEventDescriptor *)aliasDescriptorWithURL:(NSURL *)aURL DEPRECATED_ATTRIBUTE;
+ (NSAppleEventDescriptor *)bookmarkDescriptorWithURL:(NSURL *)aURL;

+ (NSAppleEventDescriptor *)appleEventDescriptorWithBOOL:(BOOL)aValue;
+ (NSAppleEventDescriptor *)trueBoolDescriptor;
+ (NSAppleEventDescriptor *)falseBoolDescriptor;
+ (NSAppleEventDescriptor *)appleEventDescriptorWithShort:(short int)aValue;
+ (NSAppleEventDescriptor *)appleEventDescriptorWithLong:(long long)aValue;
+ (NSAppleEventDescriptor *)appleEventDescriptorWithInt:(int)aValue;
+ (NSAppleEventDescriptor *)appleEventDescriptorWithFloat:(float)aValue;
+ (NSAppleEventDescriptor *)appleEventDescriptorWithDouble:(double)aValue;
+ (NSAppleEventDescriptor *)appleEventDescriptorWithUnsignedInt:(unsigned int)aValue;

- (ProcessSerialNumber)targetProcessSerialNumber;
- (NSString*)targetProcessBundleIdentifier;

@property (readonly) OSType targetCreator;
@property (readonly, getter=isTargetCurrentProcess) BOOL targetCurrentProcess;

@end
