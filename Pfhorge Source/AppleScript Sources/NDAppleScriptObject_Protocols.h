/*
 *  NDAppleScriptObject_Protocols.h
 *  NDAppleScriptObjectProject
 *
 *  Created by Nathan Day on Sat Feb 16 2002.
 *  Copyright (c) 2001 Nathan Day. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(SInt16, NDAESendPriority) {
	/// Post message at the end of the event queue
	NDAESendPriorityNormal = kAENormalPriority,
	/// Post message at the front of the event queue (same as \c nAttnMsg  )
	NDAESendPriorityHigh = kAEHighPriority,
};

typedef NS_OPTIONS(SInt32, NDAESendMode) {
	/// sender doesn't want a reply to event
	NDAEReplyNone = kAENoReply,
	/// sender wants a reply but won't wait
	NDAEReplyQueue = kAEQueueReply,
	/// sender wants a reply and will wait
	NDAEReplyWait = kAEWaitReply,
	/// don't reconnect if there is a sessClosedErr from PPCToolbox
	NDAEDontReconnect = kAEDontReconnect,
	/// (nReturnReceipt) sender wants a receipt of message
	NDAEWantReceipt = kAEWantReceipt,
	/// server should not interact with user
	NDAEInteractNever = kAENeverInteract,
	/// server may try to interact with user
	NDAECanInteract = kAECanInteract,
	/// server should always interact with user where appropriate
	NDAEInteractAlways = kAEAlwaysInteract,
	/// interaction may switch layer
	NDAECanSwitchLayer = kAECanSwitchLayer,
	/// don't record this event - available only in vers 1.0.1 and greater
	NDAEDontRecord = kAEDontRecord,
	/// don't send the event for recording - available only in vers 1.0.1 and greater
	NDAEDontExecute = kAEDontExecute,
	/// allow processing of non-reply events while awaiting synchronous AppleEvent reply
	NDAEProcessNonReplyEvents = kAEProcessNonReplyEvents,
	/// if set, don't automatically add any sandbox or other annotations to the event
	NDAEDoNotAutomaticallyAddAnnotationsToEvent = kAEDoNotAutomaticallyAddAnnotationsToEvent,
	
	NDAEReplyMask = NDAEReplyNone | NDAEReplyQueue | NDAEReplyWait,
	NDAEInteractMask = NDAEInteractNever | NDAECanInteract | NDAEInteractAlways,
};

@protocol NDAppleScriptObjectSendEvent <NSObject>
- (nullable NSAppleEventDescriptor *)sendAppleEvent:(NSAppleEventDescriptor *)theAppleEventDescriptor sendMode:(NDAESendMode)aSendMode sendPriority:(NDAESendPriority)aSendPriority timeOutInTicks:(SInt32)aTimeOutInTicks idleProc:(AEIdleUPP)anIdleProc filterProc:(AEFilterUPP)aFilterProc;
@end

@protocol NDAppleScriptObjectActive <NSObject>
@property (nonatomic, readonly) BOOL appleScriptActive;
@end

NS_ASSUME_NONNULL_END
