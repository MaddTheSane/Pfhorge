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

+ (instancetype)appleScriptObjectWithString:(NSString *) aString;
+ (instancetype)appleScriptObjectWithData:(NSData *) aData;
+ (instancetype)appleScriptObjectWithContentsOfFile:(NSString *) aPath;
+ (instancetype)appleScriptObjectWithContentsOfURL:(NSURL *) aURL;

- (instancetype)initWithString:(NSString *)aString modeFlags:(SInt32)aModeFlags;
- (instancetype)initWithContentsOfFile:(NSString *)aPath;
- (instancetype)initWithContentsOfFile:(NSString *)aPath component:(Component)aComponent;
- (instancetype)initWithContentsOfURL:(NSURL *)anURL;
- (instancetype)initWithContentsOfURL:(NSURL *)aURL component:(Component)aComponent;
- (instancetype)initWithData:(NSData *)aDesc;

- (instancetype)initWithString:(NSString *)aString modeFlags:(SInt32)aModeFlags component:(Component)aComponent;
- (instancetype)initWithData:(NSData *)aData component:(Component)aComponent;

- (NSData *)data;

- (BOOL)execute;
- (BOOL)executeOpen:(NSArray *)aParameters;
- (BOOL)executeEvent:(NSAppleEventDescriptor *)anEvent;

- (NSArray<NSString*> *)arrayOfEventIdentifier;
- (BOOL)respondsToEventClass:(AEEventClass)aEventClass eventID:(AEEventID)aEventID;

- (NSAppleEventDescriptor *)resultAppleEventDescriptor;
- (id)resultObject;
- (id)resultData;
- (NSString *)resultAsString;

@property (strong) NDAppleScriptObject *contextAppleScriptObject;
@property SInt32 executionModeFlags;

- (void)setDefaultTarget:(NSAppleEventDescriptor *)aDefaultTarget;
- (void)setDefaultTargetAsCreator:(OSType)aCreator;
- (void)setFinderAsDefaultTarget;

@property (retain) id appleEventSendTarget;
@property (retain) id activateTarget;

- (NSAppleEventDescriptor *)targetNoProcess;

- (BOOL)writeToURL:(NSURL *)aURL;
- (BOOL)writeToURL:(NSURL *)aURL Id:(short)anID;
- (BOOL)writeToFile:(NSString *)aPath;
- (BOOL)writeToFile:(NSString *)aPath Id:(short)anID;

@end
