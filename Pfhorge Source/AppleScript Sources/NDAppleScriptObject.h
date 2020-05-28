/*
 *  NDAppleScriptObject.h
 *  NDAppleScriptObjectProject
 *
 *  Created by nathan on Thu Nov 29 2001.
 *  Copyright (c) 2001 Nathan Day. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import "NDAppleScriptObject_Protocols.h"

@interface NDAppleScriptObject : NSObject <NDAppleScriptObjectSendEvent, NDAppleScriptObjectActive>
{
@private
	OSAID										compiledScriptID,
												resultingValueID;
	NDAppleScriptObject					* contextAppleScriptObject;
	id<NDAppleScriptObjectSendEvent>	sendAppleEventTarget;
	id<NDAppleScriptObjectActive>		activeTarget;
	ComponentInstance					osaComponent;

	SInt32								executionModeFlags;
}

+ (id)compileExecuteString:(NSString *) aString;
+ (Component)findNextComponent;

+ (instancetype)appleScriptObjectWithString:(NSString *) aString NS_SWIFT_UNAVAILABLE("");
+ (instancetype)appleScriptObjectWithData:(NSData *) aData NS_SWIFT_UNAVAILABLE("");
+ (instancetype)appleScriptObjectWithContentsOfFile:(NSString *) aPath NS_SWIFT_UNAVAILABLE("");
+ (instancetype)appleScriptObjectWithContentsOfURL:(NSURL *) aURL NS_SWIFT_UNAVAILABLE("");

- (instancetype)initWithString:(NSString *)aString modeFlags:(SInt32)aModeFlags NS_SWIFT_UNAVAILABLE("");
- (instancetype)initWithContentsOfFile:(NSString *)aPath NS_SWIFT_UNAVAILABLE("");
- (instancetype)initWithContentsOfFile:(NSString *)aPath component:(Component)aComponent NS_SWIFT_UNAVAILABLE("");
- (instancetype)initWithContentsOfURL:(NSURL *)anURL NS_SWIFT_UNAVAILABLE("");
- (instancetype)initWithContentsOfURL:(NSURL *)aURL component:(Component)aComponent NS_SWIFT_UNAVAILABLE("");
- (instancetype)initWithData:(NSData *)aDesc NS_SWIFT_UNAVAILABLE("");

- (instancetype)initWithString:(NSString *)aString modeFlags:(SInt32)aModeFlags component:(Component)aComponent NS_SWIFT_UNAVAILABLE("");
- (instancetype)initWithData:(NSData *)aData component:(Component)aComponent NS_SWIFT_UNAVAILABLE("");
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

//NSError initializers
- (instancetype)initWithString:(NSString *)aString modeFlags:(SInt32)aModeFlags component:(Component)aComponent error:(NSError**)outError NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithData:(NSData *)aData component:(Component)aComponent error:(NSError**)outError NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithString:(NSString *)aString modeFlags:(SInt32)aModeFlags error:(NSError**)outError;
- (instancetype)initWithContentsOfURL:(NSURL *)anURL error:(NSError**)outError;
- (instancetype)initWithContentsOfURL:(NSURL *)aURL component:(Component)aComponent error:(NSError**)outError;
- (instancetype)initWithData:(NSData *)aDesc error:(NSError**)outError;

- (NSData *)data;

- (BOOL)execute;
- (BOOL)executeOpen:(NSArray *)aParameters;
- (BOOL)executeEvent:(NSAppleEventDescriptor *)anEvent NS_SWIFT_UNAVAILABLE("");
- (BOOL)executeEvent:(NSAppleEventDescriptor *)anEvent error:(NSError**)outError;

- (NSArray<NSString*> *)arrayOfEventIdentifier;
- (BOOL)respondsToEventClass:(AEEventClass)aEventClass eventID:(AEEventID)aEventID;

- (NSAppleEventDescriptor *)resultAppleEventDescriptor;
- (id)resultObject;
- (NSData*)resultData;
- (NSString *)resultAsString;

@property (strong) NDAppleScriptObject *contextAppleScriptObject;
@property SInt32 executionModeFlags;

- (void)setDefaultTarget:(NSAppleEventDescriptor *)aDefaultTarget;
- (void)setDefaultTargetAsCreator:(OSType)aCreator;
- (void)setFinderAsDefaultTarget;

@property (retain) id<NDAppleScriptObjectSendEvent> appleEventSendTarget;
@property (retain) id<NDAppleScriptObjectActive> activateTarget;

- (NSAppleEventDescriptor *)targetNoProcess;

- (BOOL)writeToURL:(NSURL *)aURL NS_SWIFT_UNAVAILABLE("");
- (BOOL)writeToURL:(NSURL *)aURL Id:(ResID)anID NS_SWIFT_UNAVAILABLE("");
- (BOOL)writeToFile:(NSString *)aPath NS_SWIFT_UNAVAILABLE("");
- (BOOL)writeToFile:(NSString *)aPath Id:(ResID)anID NS_SWIFT_UNAVAILABLE("");

//! If \c anID is INT16_MIN, writes to data fork instead.
- (BOOL)writeToURL:(NSURL *)aURL ID:(ResID)anID error:(NSError**)outError;

- (BOOL)writeToURL:(NSURL *)aURL resourceFork:(BOOL)useRes error:(NSError**)outError;
- (BOOL)writeToURL:(NSURL *)aURL error:(NSError**)outError;

@end
