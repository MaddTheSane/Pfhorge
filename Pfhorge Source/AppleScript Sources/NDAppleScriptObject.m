/*
 *  NDAppleScriptObject.m
 *  NDAppleScriptObjectProject
 *
 *  Created by nathan on Thu Nov 29 2001.
 *  Copyright (c) 2001 Nathan Day. All rights reserved.
 */

#import "NDAppleScriptObject.h"
#import "NSURL+NDCarbonUtilities.h"
#import "NDResourceFork.h"
#import "NSAppleEventDescriptor+NDAppleScriptObject.h"

static const ResID		kScriptResourceID = 128;
static const OSType		kFinderCreatorCode = 'MACS';

static OSASendUPP				defaultSendProc = NULL;
static SRefCon					defaultSendProcRefCon = 0;
static OSAActiveProcPtr			defaultActiveProcPtr = NULL;
static SRefCon					defaultActiveProcRefCon = 0;

static OSErr AppleScriptActiveProc(SRefCon aRefCon);
static OSErr AppleEventSendProc(const AppleEvent *theAppleEvent, AppleEvent *reply, AESendMode sendMode, AESendPriority sendPriority, SInt32 timeOutInTicks, AEIdleUPP idleProc, AEFilterUPP filterProc, SRefCon refCon);

@interface NDAppleScriptObject ()
+ (ComponentInstance)OSAComponent;
+ (id)objectForAEDesc:(const AEDesc *)aDesc;
- (OSAID)compileString:(NSString *)aString modeFlags:(SInt32)aModeFlags;
- (ComponentInstance)OSAComponent;
- (OSAID)loadData:(NSData *)aData;

@property (readonly) OSAID compiledScriptID;
- (OSAID)contextID;

- (void)setSendProc;
- (void)setActiveProc;
@end

@interface NSString (NDAEDescCreation)
+ (id)stringWithAEDesc:(const AEDesc *)aDesc;
+ (id)stringWithUTF8AEDesc:(const AEDesc *)aDesc;
+ (id)stringWithCStringAEDesc:(const AEDesc *)aDesc;
@end

@interface NSArray (NDAEDescCreation)
+ (id)arrayWithAEDesc:(const AEDesc *)aDesc;
@end

@interface NSDictionary (NDAEDescCreation)
+ (id)dictionaryWithAEDesc:(const AEDesc *)aDesc;
@end

@interface NSData (NDAEDescCreation)
+ (id)dataWithAEDesc:(const AEDesc *)aDesc;
@end

@interface NSNumber (NDAEDescCreation)
+ (id)numberWithAEDesc:(const AEDesc *)aDesc;
@end

@interface NSURL (NDAEDescCreation)
+ (id)URLWithAEDesc:(const AEDesc *)aDesc;
@end

@interface NSAppleEventDescriptor (NDAEDescCreation)
+ (id)appleEventDescriptorWithAEDesc:(const AEDesc *)aDesc;
- (BOOL)AEDesc:(AEDesc *)aDescPtr;
@end

@implementation NDAppleScriptObject

static ComponentInstance		defaultOSAComponent = NULL;

/*
 * + compileExecuteString:
 */
+ (id)compileExecuteString:(NSString *) aString
{
	OSAID		theResultID;
	AEDesc		theResultDesc = { typeNull, NULL },
				theScriptDesc = { typeNull, NULL };
	id			theResultObject = nil;

	if ((AECreateDesc(typeUTF8Text, [aString UTF8String], [aString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], &theScriptDesc) ==  noErr) && (OSACompileExecute([self OSAComponent], &theScriptDesc, kOSANullScript, kOSAModeNull, &theResultID) ==  noErr)) {
		if (OSACoerceToDesc([self OSAComponent], theResultID, typeWildCard, kOSAModeNull, &theResultDesc) == noErr ) {
			if (theResultDesc.descriptorType != typeNull) {
				theResultObject = [self objectForAEDesc:&theResultDesc];
				AEDisposeDesc( &theResultDesc );
			}
		}
		AEDisposeDesc(&theScriptDesc);
		if (theResultID != kOSANullScript) {
			OSADispose([self OSAComponent], theResultID);
		}
	}
	
	return theResultObject;
}

/*
 * findNextComponent
 */
+ (Component)findNextComponent
{
	ComponentDescription		theReturnCompDesc;
	static Component			theLastComponent = NULL;
	ComponentDescription		theComponentDesc;

	theComponentDesc.componentType = kOSAComponentType;
	theComponentDesc.componentSubType = kOSAGenericScriptingComponentSubtype;
	theComponentDesc.componentManufacturer = 0;
	theComponentDesc.componentFlags =  kOSASupportsCompiling | kOSASupportsGetSource
												| kOSASupportsAECoercion | kOSASupportsAESending
												| kOSASupportsConvenience | kOSASupportsDialects
												| kOSASupportsEventHandling;
	
	theComponentDesc.componentFlagsMask = theComponentDesc.componentFlags;

	do {
		theLastComponent = FindNextComponent(theLastComponent, &theComponentDesc);
	} while (GetComponentInfo(theLastComponent, &theReturnCompDesc, NULL, NULL, NULL) == noErr && theComponentDesc.componentSubType == kOSAGenericScriptingComponentSubtype);

	return theLastComponent;
}

/*
 * closeDefaultComponent
 */
+ (void)closeDefaultComponent
{
	if (defaultOSAComponent != NULL) {
		CloseComponent(defaultOSAComponent);
		defaultOSAComponent = NULL;
	}
}

/*
 * + appleScriptObjectWithString:
 */
+ (id)appleScriptObjectWithString:(NSString *) aString
{
	return [[self alloc] initWithString:aString modeFlags:kOSAModeCompileIntoContext];
}

/*
 * + appleScriptObjectWithData:
 */
+ (id)appleScriptObjectWithData:(NSData *) aData
{
	return [[self alloc] initWithData:aData];
}

/*
 * + appleScriptObjectWithPath:
 */
+ (id)appleScriptObjectWithContentsOfFile:(NSString *) aPath
{
	return [[self alloc] initWithContentsOfFile:aPath];
}

/*
 * + appleScriptObjectWithURL:
 */
+ (id)appleScriptObjectWithContentsOfURL:(NSURL *) aURL
{
	return [[self alloc] initWithContentsOfURL:aURL];
}


/*
 * - initWithString:modeFlags:
 */
- (id)initWithString:(NSString *)aString modeFlags:(SInt32)aModeFlags
{
	return [self initWithString:aString modeFlags:aModeFlags component:NULL];
}

/*
 * - initWithContentsOfFile:
 */
- (id)initWithContentsOfFile:(NSString *)aPath
{
	return [self initWithContentsOfFile:aPath component:NULL];
}

/*
 * - initWithContentsOfFile:component:
 */
- (id)initWithContentsOfFile:(NSString *)aPath component:(Component)aComponent
{
	NSData		* theData;

	theData = [[NDResourceFork resourceForkForReadingAtPath:aPath] dataForType:kOSAScriptResourceType Id:kScriptResourceID];
	
	if (theData != nil) {
		self = [self initWithData:theData component:aComponent];
	} else {
		self = [self initWithData:[NSData dataWithContentsOfFile:aPath] component:aComponent];
	}
	
	return self;
}

/*
 * initWithContentsOfURL:
 */
- (id)initWithContentsOfURL:(NSURL *)aURL
{
	return [self initWithContentsOfURL:aURL component:NULL];
}

/*
 * - initWithContentsOfURL:
 */
- (id)initWithContentsOfURL:(NSURL *)aURL component:(Component)aComponent
{
	NSData		* theData;
	
	theData = [[NDResourceFork resourceForkForReadingAtURL:aURL] dataForType:kOSAScriptResourceType Id:kScriptResourceID];
	
	if (theData != nil) {
		self = [self initWithData:theData component:aComponent];
	} else {
		self = [self initWithData:[NSData dataWithContentsOfURL:aURL] component:aComponent];
	}
	
	return self;
}

/*
 * - initWithAppleEventDescriptor:
 */
- (id)initWithAppleEventDescriptor:(NSAppleEventDescriptor *)aDescriptor
{
	if ([aDescriptor descriptorType] == cScript) {
		self = [self initWithData:[aDescriptor data]];
	} else {
		return nil;
	}
	
	return self;
}

/*
 * - initWithData:
 */
- (id)initWithData:(NSData *)aData
{
	return [self initWithData:aData component:NULL];
}

/*
 * - initWithString:modeFlags:component:
 */
- (id)initWithString:(NSString *)aString modeFlags:(SInt32)aModeFlags component:(Component)aComponent
{
	if (self = [super init]) {
		if (aComponent != NULL) {
			osaComponent = OpenComponent(aComponent);
		} else {
			osaComponent = NULL;
		}

		compiledScriptID = [self compileString:aString modeFlags: aModeFlags];
		resultingValueID = kOSANullScript;
		executionModeFlags = kOSAModeNull;
		osaComponent = NULL;

		if (compiledScriptID == kOSANullScript) {
			return nil;
		}
	}

	return self;
}

/*
 * - initWithData:componet:
 */
- (id)initWithData:(NSData *)aData component:(Component)aComponent
{
	if (self = [super init]) {
		if (aComponent != NULL) {
			osaComponent = OpenComponent(aComponent);
		} else {
			osaComponent = NULL;
		}

		compiledScriptID = [self loadData:aData];
		resultingValueID = kOSANullScript;
		executionModeFlags = kOSAModeNull;
		osaComponent = NULL;

		if (compiledScriptID == kOSANullScript) {
			return nil;
		}
	}

	return self;
}

/*
 * - dealloc
 */
-(void)dealloc
{
	if (compiledScriptID != kOSANullScript)
		OSADispose([self OSAComponent], compiledScriptID);
	if (resultingValueID != kOSANullScript)
		OSADispose([self OSAComponent], resultingValueID);

	if (osaComponent != NULL)
		CloseComponent(osaComponent);
}

/*
 * - data
 */
- (NSData *)data
{
	NSData				* theData = nil;
	OSStatus			theError;
	AEDesc				theDesc = { typeNull, NULL };
	
	theError = OSAStore([self OSAComponent], compiledScriptID, typeOSAGenericStorage, kOSAModeNull, &theDesc);
	if (noErr == theError) {
		theData = [NSData dataWithAEDesc: &theDesc];
		AEDisposeDesc(&theDesc);
	}
	
	return (noErr == theError) ? theData : nil;
}

/*
 * - execute
 */
- (BOOL)execute
{
	OSStatus		theError;
	
	[self setSendProc];
	[self setActiveProc];
	theError = OSAExecute([self OSAComponent], compiledScriptID, [self contextID], [self executionModeFlags], &resultingValueID);

	return (theError == noErr);
}

/*
 * - executeOpen:
 */
- (BOOL)executeOpen:(NSArray *)aParameters
{
	NSAppleEventDescriptor	* theEvent = nil,
	* theEventList = nil,
	* theTarget = nil;

	theTarget = [self targetNoProcess];
	theEventList = [NSAppleEventDescriptor aliasListDescriptorWithArray:aParameters];

	if (theTarget != nil && theEventList != nil) {
		theEvent = [NSAppleEventDescriptor appleEventWithEventClass:kCoreEventClass eventID:kAEOpenDocuments targetDescriptor:theTarget returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];

		[theEvent setParamDescriptor:theEventList forKeyword:keyDirectObject];
	}

	return (theEvent != nil) ? [self executeEvent:theEvent] : NO;
}

/*
 * - executeEvent:
 */
- (BOOL)executeEvent:(NSAppleEventDescriptor *)anEvent
{
	AEDesc				theEventDesc;
	BOOL				theSuccess= NO;
	
	if ([anEvent AEDesc:&theEventDesc]) {
		[self setSendProc];
		[self setActiveProc];
		theSuccess = OSAExecuteEvent([self OSAComponent], &theEventDesc, compiledScriptID, [self executionModeFlags], &resultingValueID) == noErr;
		AEDisposeDesc(&theEventDesc);
	}

	return theSuccess;
}

/*
 * - arrayOfEventIdentifier
 */
- (NSArray *)arrayOfEventIdentifier
{
	NSArray			* theNamesArray = nil;
	AEDescList		theNamesDescList;
	if (OSAGetHandlerNames([self OSAComponent], kOSAModeNull, compiledScriptID, &theNamesDescList) == noErr) {
		theNamesArray = [NDAppleScriptObject objectForAEDesc: &theNamesDescList];
		AEDisposeDesc(&theNamesDescList);
	}

	return theNamesArray;
}

/*
 * - respondsToEventClass:eventID:
 */
- (BOOL)respondsToEventClass:(AEEventClass)aEventClass eventID:(AEEventID)aEventID 
{
	NSString		* theEventClass,
					* theEventID;
	theEventClass = CFBridgingRelease(UTCreateStringForOSType(aEventClass));
	theEventID = CFBridgingRelease(UTCreateStringForOSType(aEventID));
	
	return [[self arrayOfEventIdentifier] containsObject:[theEventClass stringByAppendingString:theEventID]];
}

/*
 * resultDescriptor
 */
- (NSAppleEventDescriptor *)resultAppleEventDescriptor
{
	AEDesc					theResultDesc = { typeNull, NULL };
	NSAppleEventDescriptor	* theResult = nil;
	
	if (OSACoerceToDesc([self OSAComponent], resultingValueID, typeWildCard, kOSAModeNull, &theResultDesc) == noErr) {
		theResult = [NSAppleEventDescriptor descriptorWithDescriptorType:theResultDesc.descriptorType data:[NSData dataWithAEDesc:&theResultDesc]];
		AEDisposeDesc(&theResultDesc);
	}
	
	return theResult;
}

/*
 * resultObject
 */
- (id)resultObject
{
	id				theResult = nil;

	if (resultingValueID != kOSANullScript) {
		AEDesc		theResultDesc = { typeNull, NULL };

		if (OSACoerceToDesc([self OSAComponent], resultingValueID, typeWildCard, kOSAModeNull, &theResultDesc) == noErr) {
			theResult = [NDAppleScriptObject objectForAEDesc: &theResultDesc];
			AEDisposeDesc(&theResultDesc);
		}
	}

	return theResult;
}

/*
 * resultData
 */
- (id)resultData
{
	id				theResult = nil;
	
	if (resultingValueID != kOSANullScript) {
		AEDesc		theResultDesc = { typeNull, NULL };
		
		if (OSACoerceToDesc([self OSAComponent], resultingValueID, typeWildCard, kOSAModeNull, &theResultDesc) == noErr) {
			theResult = [NSData dataWithAEDesc: &theResultDesc];
			AEDisposeDesc(&theResultDesc);
		}
	}
	
	return theResult;
}

/*
 * - resultAsString
 */
- (NSString *)resultAsString
{
	AEDesc		theResultDesc = { typeNull, NULL };
	NSString	* theResult = nil;
	
	if (OSADisplay([self OSAComponent], resultingValueID, typeChar, kOSAModeNull, &theResultDesc) == noErr) {
		theResult = [NSString stringWithAEDesc:&theResultDesc];
		AEDisposeDesc(&theResultDesc);
	}
	
	return theResult;
}

@synthesize contextAppleScriptObject;

/*
 * - executionModeFlags
 */
@synthesize executionModeFlags;

/*
 * - setDefaultTarget:
 */
- (void)setDefaultTarget:(NSAppleEventDescriptor *)aDefaultTarget
{
	AEAddressDesc		theTargetDesc;
	if ([aDefaultTarget AEDesc:(AEDesc*)&theTargetDesc]) {
		OSASetDefaultTarget([self OSAComponent], &theTargetDesc);
	} else {
		NSLog(@"Could not set default target");
	}
}

/*
 * - setDefaultTargetAsCreator:
 */
- (void)setDefaultTargetAsCreator:(OSType)aCreator
{
	NSAppleEventDescriptor	* theAppleEventDescriptor;

	theAppleEventDescriptor = [NSAppleEventDescriptor descriptorWithDescriptorType:typeApplSignature data:[NSData dataWithBytes:&aCreator length:sizeof(aCreator)]];
	[self setDefaultTarget:theAppleEventDescriptor];
}

/*
 * - setFinderAsDefaultTarget
 */
- (void)setFinderAsDefaultTarget
{
	[self setDefaultTargetAsCreator:kFinderCreatorCode];
}

/*
 * appleEventSendTarget
 */
@synthesize appleEventSendTarget=sendAppleEventTarget;

/*
 * activateTarget
 */
@synthesize activateTarget=activeTarget;

/*
 * sendAppleEvent:sendMode:sendPriority:timeOutInTicks:idleProc:filterProc:
 */
- (NSAppleEventDescriptor *)sendAppleEvent:(NSAppleEventDescriptor *)theAppleEventDescriptor sendMode:(AESendMode)aSendMode sendPriority:(AESendPriority)aSendPriority timeOutInTicks:(SInt32)aTimeOutInTicks idleProc:(AEIdleUPP)anIdleProc filterProc:(AEFilterUPP)aFilterProc
{
	AppleEvent				theAppleEvent;
	NSAppleEventDescriptor	* theReplyAppleEventDesc = nil;

	if ([theAppleEventDescriptor AEDesc:&theAppleEvent]) {
		AppleEvent					theReplyAppleEvent;
		
		if (defaultSendProc != NULL) {
			if (defaultSendProc(&theAppleEvent, &theReplyAppleEvent, aSendMode, aSendPriority, aTimeOutInTicks, anIdleProc, aFilterProc, defaultSendProcRefCon) == noErr) {
				theReplyAppleEventDesc = [NSAppleEventDescriptor appleEventDescriptorWithAEDesc:&theReplyAppleEvent];
			}
		}
	}
	
	return theReplyAppleEventDesc;
}

/*
 * appleScriptActive
 */
- (BOOL)appleScriptActive
{
	if (defaultActiveProcPtr != NULL) {
		return defaultActiveProcPtr(defaultActiveProcRefCon) == noErr;
	} else {
		return NO;
	}
}

/*
 * targetNoProcess
 */
- (NSAppleEventDescriptor *)targetNoProcess
{
	unsigned int				theCurrentProcess = kNoProcess; //kCurrentProcess;

	return [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber data:[NSData dataWithBytes:&theCurrentProcess length:sizeof(theCurrentProcess)]];
}

/*
 * description
 */
- (NSString *)description
{
	AEDesc		theDesc = { typeNull, NULL };
	NSString	*theResult = nil;

	if (OSAGetSource([self OSAComponent], compiledScriptID, typeChar, &theDesc) == noErr) {
		theResult = [NSString stringWithAEDesc: &theDesc];
		AEDisposeDesc(&theDesc);
	}

	return theResult;
}

/*
 * writeToURL:
 */
- (BOOL)writeToURL:(NSURL *)aURL
{
	return [self writeToURL:aURL Id:kScriptResourceID];
}

/*
 * writeToURL:Id:
 */
- (BOOL)writeToURL:(NSURL *)aURL Id:(ResID)anID
{
	NSData			* theData;
	NDResourceFork	* theResourceFork;
	
	if ((theData = [self data]) && (theResourceFork = [NDResourceFork resourceForkForWritingAtURL:aURL])) {
		return [theResourceFork addData:theData type:kOSAScriptResourceType Id:anID name:@"script"];
	} else {
		return NO;
	}
}

/*
 * writeToFile:
 */
- (BOOL)writeToFile:(NSString *)aPath
{
	return [self writeToURL:[NSURL fileURLWithPath:aPath] Id:kScriptResourceID];
}

/*
 * writeToFile:Id:
 */
- (BOOL)writeToFile:(NSString *)aPath Id:(ResID)anID
{
	return [self writeToURL:[NSURL fileURLWithPath:aPath] Id:anID];
}


/*
 * OSAComponent
 */
+ (ComponentInstance)OSAComponent
{
	if (defaultOSAComponent == NULL) {
		defaultOSAComponent = OpenDefaultComponent(kOSAComponentType, kAppleScriptSubtype);
	}
	return defaultOSAComponent;
}

/*
 * + appleScriptObjectWithAEDesc:
 */
+ (id)appleScriptObjectWithAEDesc:(const AEDesc *)aDesc
{
	NSData		* theData;
	
	theData = [NSData dataWithAEDesc: aDesc];

	return (theData == nil) ? nil : [[self alloc] initWithData:theData];
}

/*
 * + objectForAEDesc:
 */
+ (id)objectForAEDesc:(const AEDesc *)aDesc
{
	id			theResult;

#if 0
	char		*theType = (char*)&aDesc->descriptorType;
	NSLog(@"objectForAEDesc: recieved type '%c%c%c%c'\n",theType[0],theType[1],theType[2],theType[3]);
#endif

	switch (aDesc->descriptorType) {
		case typeBoolean:					//	1-byte Boolean value
		case typeSInt16:					//	16-bit integer
		case typeSInt32:					//	32-bit integer
		case typeSInt64:					//	64-bit integer
		case typeIEEE32BitFloatingPoint:	//	SANE single
		case typeIEEE64BitFloatingPoint:	//	SANE double
		case typeUInt16:					//	unsigned 16-bit integer
		case typeUInt32:					//	unsigned 32-bit integer
		case typeUInt64:					//	unsigned 64-bit integer
		case typeTrue:						//	TRUE Boolean value
		case typeFalse:						//	FALSE Boolean value
			theResult = [NSNumber numberWithAEDesc:aDesc];
			break;
		case typeChar:						//	unterminated string
			theResult = [NSString stringWithAEDesc:aDesc];
			break;
		case typeCString:					//	null-terminated string
			theResult = [NSString stringWithCStringAEDesc:aDesc];
			break;
		case typeUTF8Text:					//	null-terminated
			theResult = [NSString stringWithUTF8AEDesc:aDesc];
			break;
		case typeAEList:					//	list of descriptor records
			theResult = [NSArray arrayWithAEDesc:aDesc];
			break;
		case typeAERecord:					//	list of keyword-specified 
			theResult = [NSDictionary dictionaryWithAEDesc:aDesc];
			break;
		case typeAppleEvent:				//	Apple event record
			theResult = [NSAppleEventDescriptor appleEventDescriptorWithAEDesc:aDesc];
			break;
		case typeAlias:						// alias record
		case typeFileURL:
		case typeBookmarkData:				// file bookmark
			theResult = [NSURL URLWithAEDesc:aDesc];
			break;
//		case typeEnumerated:					// enumerated data
//			break;
		case cScript:						// script data
			theResult = [NDAppleScriptObject appleScriptObjectWithAEDesc:aDesc];
			break;
		case cEventIdentifier:
			theResult = [NSString stringWithAEDesc: aDesc];
			break;
		default:
			theResult = [NSData dataWithAEDesc: aDesc];
			break;
	}
	
	return theResult;
}

/*
 * - compileString:
 */
- (OSAID)compileString:(NSString *)aString modeFlags:(SInt32)aModeFlags
{
	OSAID			theCompiledScript = kOSANullScript;
	AEDesc			theScriptDesc = { typeNull, NULL };
	
	if (AECreateDesc(typeUTF8Text, [aString UTF8String], [aString lengthOfBytesUsingEncoding:NSUTF8StringEncoding], &theScriptDesc) == noErr) {
		OSACompile([self OSAComponent], &theScriptDesc, aModeFlags, &theCompiledScript);
		AEDisposeDesc(&theScriptDesc);
	}
	
	return theCompiledScript;
}

/*
 * OSAComponent
 */
- (ComponentInstance)OSAComponent
{
	if (osaComponent == NULL) {
		return [NDAppleScriptObject OSAComponent];
	} else {
		return osaComponent;
	}
}

/*
 * - loadData:
 */
- (OSAID)loadData:(NSData *)aData
{
	AEDesc		theScriptDesc = { typeNull, NULL };
	OSAID		theCompiledScript = kOSANullScript;
	
	if (AECreateDesc(typeOSAGenericStorage, [aData bytes], [aData length], &theScriptDesc) == noErr) {
		OSALoad([self OSAComponent], &theScriptDesc, kOSAModeCompileIntoContext, &theCompiledScript);
		AEDisposeDesc(&theScriptDesc);
	}
	
	return theCompiledScript;
}

/*
 * - compiledScriptID
 */
@synthesize compiledScriptID;

/*
 * - contextID
 */
- (OSAID)contextID
{
	return (contextAppleScriptObject) ? [contextAppleScriptObject compiledScriptID] : kOSANullScript;
}

/*
 * - setSendProc
 */
- (void)setSendProc
{
	if (defaultSendProc == NULL) {
		if (OSAGetSendProc([self OSAComponent], &defaultSendProc, &defaultSendProcRefCon) != noErr) {
			defaultSendProc = NULL;
			NSLog(@"Could not get default AppleScript send procedure");
		}
	}

	if (OSASetSendProc([self OSAComponent], AppleEventSendProc, (__bridge SRefCon)self) != noErr) {
		NSLog(@"Could not set AppleScript send procedure");
	}
}

/*
 * function AppleEventSendProc
 */
OSErr AppleEventSendProc( const AppleEvent *anAppleEvent, AppleEvent *aReply, AESendMode aSendMode, AESendPriority aSendPriority, SInt32 aTimeOutInTicks, AEIdleUPP anIdleProc, AEFilterUPP aFilterProc, SRefCon aRefCon )
{
	NSAppleEventDescriptor		* theAppleEventDescriptor = nil,
	* theAppleEventDescReply;
	
	theAppleEventDescriptor = [NSAppleEventDescriptor appleEventDescriptorWithAEDesc:anAppleEvent];
	
	if (theAppleEventDescriptor) {
		id<NDAppleScriptObjectSendEvent> theSendTarget;
		//static BOOL					hasFirstEventBeenSent = NO;
		
		/*if( [theAppleEventDescriptor isTargetCurrentProcess] && !hasFirstEventBeenSent )
		 {
		 hasFirstEventBeenSent = YES;
		 [[NSNotificationCenter defaultCenter] postNotificationName:NSAppleEventManagerWillProcessFirstEventNotification object:[NSAppleEventManager sharedAppleEventManager]];
		 }*/
		
		theSendTarget = [(__bridge NDAppleScriptObject*)aRefCon appleEventSendTarget];
		
		if (theSendTarget != nil) {
			theAppleEventDescReply = [theSendTarget sendAppleEvent:theAppleEventDescriptor sendMode:aSendMode sendPriority:aSendPriority timeOutInTicks:aTimeOutInTicks idleProc:anIdleProc filterProc:aFilterProc];
		} else {
			theAppleEventDescReply = [(__bridge NDAppleScriptObject*)aRefCon sendAppleEvent:theAppleEventDescriptor sendMode:aSendMode sendPriority:aSendPriority timeOutInTicks:aTimeOutInTicks idleProc:anIdleProc filterProc:aFilterProc];
		}
		
		if (![theAppleEventDescReply AEDesc:(AEDesc*)aReply])
			theAppleEventDescriptor = nil;			// ERROR
	}
	
	return (theAppleEventDescriptor == nil) ? errOSASystemError : noErr;
}

/*
 * setActiveProc
 */
- (void)setActiveProc
{
	if (activeTarget != nil) {
		if (defaultActiveProcPtr == NULL) {
			if (OSAGetActiveProc([self OSAComponent], &defaultActiveProcPtr, &defaultActiveProcRefCon) != noErr) {
				defaultActiveProcPtr = NULL;
				NSLog(@"Could not get default AppleScript send procedure");
			}
		}
		
		if (OSASetActiveProc([self OSAComponent], AppleScriptActiveProc , (__bridge SRefCon)activeTarget) != noErr)
			NSLog(@"Could not set AppleScript activation procedure.");
	} else {
		if (OSASetActiveProc([self OSAComponent], NULL , 0) != noErr)
			NSLog(@"Could not restore default AppleScript activation procedure.");
	}
}

/*
 * function AppleScriptActiveProc
 */
OSErr AppleScriptActiveProc( SRefCon aRefCon )
{
	return [(__bridge id)aRefCon appleScriptActive] ? noErr : errOSASystemError;
}

@end

@implementation NSString (NDAEDescCreation)

/*
 * + stringWithAEDesc:
 */
+ (id)stringWithAEDesc:(const AEDesc *)aDesc
{
	NSData			* theTextData;
	
	theTextData = [NSData dataWithAEDesc: aDesc];
	
	return ( theTextData == nil ) ? nil : [[NSString alloc] initWithData:theTextData encoding:NSMacOSRomanStringEncoding];
}

+ (id)stringWithUTF8AEDesc:(const AEDesc *)aDesc
{
	NSData			* theTextData;
	
	theTextData = [NSData dataWithAEDesc: aDesc];
	
	//TODO: trim last byte if \0.
	return ( theTextData == nil ) ? nil : [[NSString alloc] initWithData:theTextData encoding:NSUTF8StringEncoding];
}

+ (id)stringWithCStringAEDesc:(const AEDesc *)aDesc
{
	NSData			* theTextData;
	
	theTextData = [NSData dataWithAEDesc: aDesc];
	
	//TODO: trim last byte if \0.
	NSString *theText = ( theTextData == nil ) ? nil : [[NSString alloc] initWithData:theTextData encoding:NSMacOSRomanStringEncoding];
	return theText;
}

@end

@implementation NSArray (NDAEDescCreation)

/*
 * + arrayWithAEDesc:
 */
+ (id)arrayWithAEDesc:(const AEDesc *)aDesc
{
	long				theNumOfItems;
	id					theInstance = nil;
	
	AECountItems(aDesc, &theNumOfItems);
	theInstance = [NSMutableArray arrayWithCapacity:theNumOfItems];
	
	for (long theIndex = 1; theIndex <= theNumOfItems; theIndex++) {
		AEDesc		theDesc = { typeNull, NULL };
		AEKeyword	theAEKeyword;
		
		if (AEGetNthDesc(aDesc, theIndex, typeWildCard, &theAEKeyword, &theDesc) == noErr) {
			[theInstance addObject: [NDAppleScriptObject objectForAEDesc: &theDesc]];
			AEDisposeDesc(&theDesc);
		}
	}
	
	return theInstance;
}

@end

@implementation NSDictionary (NDAEDescCreation)

/*
 * + dictionaryWithAEDesc:
 */
+ (id)dictionaryWithAEDesc:(const AEDesc *)aDesc
{
	id					theInstance = nil;
	AEDesc				theListDesc = { typeNull, NULL };
	AEKeyword			theAEKeyword;

	if (AEGetNthDesc(aDesc, 1, typeWildCard, &theAEKeyword, &theListDesc) == noErr) {
		long				theNumOfItems;
		
		AECountItems(&theListDesc, &theNumOfItems);
		theInstance = [NSMutableDictionary dictionaryWithCapacity:theNumOfItems];
	
		for (long theIndex = 1; theIndex <= theNumOfItems; theIndex += 2) {
			AEDesc theDesc = { typeNull, NULL },
			theKeyDesc = { typeNull, NULL };
			
	
			if ((AEGetNthDesc(&theListDesc, theIndex + 1, typeWildCard, &theAEKeyword, &theDesc) == noErr) && (AEGetNthDesc(&theListDesc, theIndex, typeWildCard, &theAEKeyword, &theKeyDesc) == noErr)) {
				[theInstance setObject: [NDAppleScriptObject objectForAEDesc: &theDesc] forKey:[NSString stringWithAEDesc: &theKeyDesc]];
				AEDisposeDesc(&theDesc);
				AEDisposeDesc(&theKeyDesc);
			} else {
				AEDisposeDesc(&theDesc);
				theInstance = nil;
				break;
			}
		}
		AEDisposeDesc(&theListDesc);
	}
	
	return theInstance;
}

@end

@implementation NSData (NDAEDescCreation)

/*
 * + dataWithAEDesc:
 */
+ (id)dataWithAEDesc:(const AEDesc *)aDesc
{
	NSMutableData *			theInstance;

	theInstance = [NSMutableData dataWithLength: (unsigned int)AEGetDescDataSize(aDesc)];
	
	if (AEGetDescData(aDesc, [theInstance mutableBytes], [theInstance length]) != noErr) {
		theInstance = nil;
	}
	
	return theInstance;
}

@end

@implementation NSNumber (NDAEDescCreation)

+ (id)numberWithAEDesc:(const AEDesc *)aDesc
{
	id						theInstance = nil;
	
	switch (aDesc->descriptorType) {
		case typeBoolean:					//	1-byte Boolean value
		{
			BOOL		theBoolean;
			if (AEGetDescData(aDesc, &theBoolean, sizeof(BOOL)) == noErr)
				theInstance = @(theBoolean);
			break;
		}
		case typeSInt16:					//	16-bit integer
		{
			short int		theInteger;
			if (AEGetDescData(aDesc, &theInteger, sizeof(short int)) == noErr)
				theInstance = @(theInteger);
			break;
		}
		case typeSInt32:					//	32-bit integer
		{
			int		theInteger;
			if (AEGetDescData(aDesc, &theInteger, sizeof(int)) == noErr)
				theInstance = @(theInteger);
			break;
		}
		case typeIEEE32BitFloatingPoint:	//	SANE single
		{
			float		theFloat;
			if( AEGetDescData(aDesc, &theFloat, sizeof(float)) == noErr )
				theInstance = @(theFloat);
			break;
		}
		case typeIEEE64BitFloatingPoint:	//	SANE double
		{
			double theFloat;
			if (AEGetDescData(aDesc, &theFloat, sizeof(double)) == noErr)
				theInstance = @(theFloat);
			break;
		}
		case typeUInt32:					//	unsigned 32-bit integer
		{
			unsigned int		theInteger;
			if (AEGetDescData(aDesc, &theInteger, sizeof(unsigned int)) == noErr)
				theInstance = @(theInteger);
			break;
		}
		case typeUInt16:					//	unsigned 16-bit integer
		{
			unsigned short		theInteger;
			if (AEGetDescData(aDesc, &theInteger, sizeof(unsigned short)) == noErr)
				theInstance = @(theInteger);
			break;
		}
		case typeUInt64:					//	unsigned 64-bit integer
		{
			unsigned long long theInteger;
			if (AEGetDescData(aDesc, &theInteger, sizeof(unsigned long long)) == noErr)
				theInstance = @(theInteger);
			break;
		}
		case typeSInt64:					//	signed 64-bit integer
		{
			long long		theInteger;
			if (AEGetDescData(aDesc, &theInteger, sizeof(long long)) == noErr)
				theInstance = @(theInteger);
			break;
		}
		case typeTrue:						//	TRUE Boolean value
			theInstance = @YES;
			break;
		case typeFalse:						//	FALSE Boolean value
			theInstance = @NO;
			break;
		default:
			theInstance = nil;
			break;
	}
	
	return theInstance;
}

@end

@implementation NSURL (NDAEDescCreation)

/*
 * + URLWithAEDesc:
 */
+ (id)URLWithAEDesc:(const AEDesc *)aDesc
{
	unsigned int	theSize;
	id				theURL = nil;
	OSAError		theError;
	
	theSize = (unsigned int)AEGetDescDataSize(aDesc);

	switch(aDesc->descriptorType) {
		case typeAlias:							//	alias record
		{
			NSMutableData *mutDat = [NSMutableData dataWithLength:theSize];
			NSData *bookData;
			
			theError = AEGetDescData(aDesc, mutDat.mutableBytes, theSize);
			bookData = CFBridgingRelease(CFURLCreateBookmarkDataFromAliasRecord(kCFAllocatorDefault, (__bridge CFDataRef)mutDat));

			theURL = [NSURL URLByResolvingBookmarkData:bookData options:0 relativeToURL:nil bookmarkDataIsStale:NULL error:NULL];
			break;
		}
			
		case typeBookmarkData:
		{
			NSMutableData *mutDat = [NSMutableData dataWithLength:theSize];
			theError = AEGetDescData(aDesc, mutDat.mutableBytes, theSize);
			if (theError != noErr) {
				return theURL;
			}
			theURL = [NSURL URLByResolvingBookmarkData:mutDat options:0 relativeToURL:nil bookmarkDataIsStale:NULL error:NULL];
			break;
		}
			
		case typeFileURL:
		{
			NSMutableData *mutDat = [NSMutableData dataWithLength:theSize];
			theError = AEGetDescData(aDesc, mutDat.mutableBytes, theSize);
			
			theURL = CFBridgingRelease(CFURLCreateWithBytes(kCFAllocatorDefault, mutDat.bytes, theSize, kCFStringEncodingUTF8, NULL));
			break;
		}
	}
	
	return theURL;
}

@end

@implementation NSAppleEventDescriptor (NDAEDescCreation)
+ (id)appleEventDescriptorWithAEDesc:(const AEDesc *)aDesc
{
	return [self descriptorWithDescriptorType:aDesc->descriptorType data:[NSData dataWithAEDesc:aDesc]];
}

- (BOOL)AEDesc:(AEDesc *)aDescPtr
{
	NSData		* theData;

	theData = [self data];
	return AECreateDesc([self descriptorType], [theData bytes], [theData length], aDescPtr) == noErr;
}
@end
