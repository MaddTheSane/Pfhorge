/*
 *  NDResourceFork.m
 *
 *  Created by nathan on Wed Dec 05 2001.
 *  Copyright (c) 2001 Nathan Day. All rights reserved.
 *
 *	Currently ResourceFork will not add resource forks to files
 *	or create new files with resource forks
 *
 */

#import "NDResourceFork.h"
#import "NSURL+NDCarbonUtilities.h"

static OSErr createResourceFork(NSURL * aURL);

@implementation NDResourceFork

/*
 * resourceForkForReadingAtURL:
 */
+ (id)resourceForkForReadingAtURL:(NSURL *)aURL
{
	return [[self alloc] initForReadingAtURL:aURL];
}

/*
 * resourceForkForWritingAtURL:
 */
+ (id)resourceForkForWritingAtURL:(NSURL *)aURL
{
	return [[self alloc] initForWritingAtURL:aURL];
}

/*
 * resourceForkForReadingAtPath:
 */
+ (id)resourceForkForReadingAtPath:(NSString *)aPath
{
	return [[self alloc] initForReadingAtPath:aPath];
}

/*
 * resourceForkForWritingAtPath:
 */
+ (id)resourceForkForWritingAtPath:(NSString *)aPath
{
	return [[self alloc] initForWritingAtPath:aPath];
}

/*
 * initForReadingAtURL:
 */
- (id)initForReadingAtURL:(NSURL *)aURL
{
	return [self initForPermission:fsRdPerm AtURL:aURL];
}

/*
 * initForWritingAtURL:
 */
- (id)initForWritingAtURL:(NSURL *)aURL
{
	return [self initForPermission:fsWrPerm AtURL:aURL];
}

/*
 * initForPermission:AtURL:
 */
- (id)initForPermission:(SInt8)aPermission AtURL:(NSURL *)aURL
{
	OSErr			theError = !noErr;
	FSRef			theFsRef;

	if ((self = [self init]) && [aURL getFSRef:&theFsRef]) {
		HFSUniStr255 forkName;
		FSGetResourceForkName(&forkName);
		theError = FSOpenResourceFile(&theFsRef, forkName.length, forkName.unicode, aPermission, &fileReference);
		
/*
		if (noErr != theError) {	// file has no resource fork
			theError = createResourceFork(aURL);
			fileReference = FSOpenResFile(&theFsRef, aPermission);
			theError = fileReference > 0 ? ResError() : !noErr;
		}
 */	}

	if (noErr != theError) {
		return nil;
	}

	return self;
}

- (id)initForPermission:(SInt8)aPermission AtURL:(NSURL *)aURL error:(NSError**)outError
{
	OSErr			theError = !noErr;
	FSRef			theFsRef;

	if ((self = [self init]) && [aURL getFSRef:&theFsRef]) {
		HFSUniStr255 forkName;
		FSGetResourceForkName(&forkName);
		theError = FSOpenResourceFile(&theFsRef, forkName.length, forkName.unicode, aPermission, &fileReference);
		
/*
		if (noErr != theError) {	// file has no resource fork
			theError = createResourceFork(aURL);
			fileReference = FSOpenResFile(&theFsRef, aPermission);
			theError = fileReference > 0 ? ResError() : !noErr;
		}
 */	}

	if (noErr != theError) {
		if (outError) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:theError userInfo:@{NSURLErrorKey: aURL}];
		}
		return nil;
	}

	return self;
}

/*
 * initForReadingAtPath:
 */
- (id)initForReadingAtPath:(NSString *)aPath
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:aPath]) {
		return [self initForPermission:fsRdPerm AtURL:[NSURL fileURLWithPath:aPath]];
	} else {
		return nil;
	}
}

/*
 * initForWritingAtPath:
 */
- (id)initForWritingAtPath:(NSString *)aPath
{
	return [self initForPermission:fsWrPerm AtURL:[NSURL fileURLWithPath:aPath]];
}

/*
 * dealloc
 */
- (void)dealloc
{
	CloseResFile(fileReference);
}

- (BOOL)addData:(NSData *)aData type:(ResType)aType Id:(ResID)anID name:(NSString *)aName
{
	Handle		theResHandle;
	
	if( [self removeType:aType Id:anID] )
	{
		ResFileRefNum		thePreviousRefNum;

		thePreviousRefNum = CurResFile();	// save current resource
		UseResFile(fileReference);    		// set this resource to be current
	
		// copy NSData's bytes to a handle
		if (noErr == PtrToHand([aData bytes], &theResHandle, [aData length])) {
			Str255			thePName;
			CFStringGetPascalString((CFStringRef)aName, thePName, 255, kCFStringEncodingMacRoman);
			
			HLock(theResHandle);
			AddResource(theResHandle, aType, anID, thePName);
			HUnlock(theResHandle);
			
			UseResFile(thePreviousRefNum);     		// reset back to resource previously set
	
			DisposeHandle(theResHandle);
			return (ResError() == noErr);
		}
	}
	
	return NO;
}

/*
 * dataForType:Id:
 */
- (NSData *)dataForType:(ResType)aType Id:(ResID)anID
{
	NSData			* theData = nil;
	Handle			theResHandle;
	ResFileRefNum	thePreviousRefNum;

	thePreviousRefNum = CurResFile();	// save current resource
	
	UseResFile(fileReference);    		// set this resource to be current
	
	theResHandle = Get1Resource(aType, anID);

	if (noErr == ResError()) {
		HLock(theResHandle);
		theData = [NSData dataWithBytes:*theResHandle length:GetHandleSize(theResHandle)];
		HUnlock(theResHandle);
	}
	
	if (theResHandle)
		ReleaseResource(theResHandle);

	UseResFile(thePreviousRefNum);     // reset back to resource previously set
	
	return theData;
}

/*
 * removeType: Id:
 */
- (BOOL)removeType:(ResType)aType Id:(short)anID
{
	Handle		theResHandle;
	
	UseResFile(fileReference);    				// set this resource to be current

	theResHandle = Get1Resource(aType, anID);
	if (ResError() == noErr) {
		RemoveResource(theResHandle);			// Disposed of in current resource file
		return (ResError() == noErr);
	}
	return YES;
}

- (BOOL)removeType:(ResType)aType Id:(short)anID error:(NSError *__autoreleasing  _Nullable * _Nullable)outError
{
	Handle		theResHandle;
	OSErr		error;
	
	UseResFile(fileReference);    				// set this resource to be current

	theResHandle = Get1Resource(aType, anID);
	error = ResError();
	if (error == noErr) {
		RemoveResource(theResHandle);			// Disposed of in current resource file
		error = ResError();
		if (error != noErr) {
			if (outError) {
				*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
			}
			
			return NO;
		}
		return (ResError() == noErr);
	} else if (error != resNotFound) {
		if (outError) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
		}
		return NO;
	}
	return YES;
}

- (nullable NSData *)dataForType:(ResType)aType Id:(ResID)anID error:(NSError**)outError
{
	NSData			* theData = nil;
	Handle			theResHandle;
	ResFileRefNum	thePreviousRefNum;
	OSErr			error;

	thePreviousRefNum = CurResFile();	// save current resource
	
	UseResFile(fileReference);    		// set this resource to be current
	
	theResHandle = Get1Resource(aType, anID);
	error = ResError();

	if (error == noErr) {
		HLock(theResHandle);
		theData = [NSData dataWithBytes:*theResHandle length:GetHandleSize(theResHandle)];
		HUnlock(theResHandle);
	}
	
	if (theResHandle)
		ReleaseResource(theResHandle);

	UseResFile(thePreviousRefNum);     // reset back to resource previously set
	
	if (!theData) {
		if (outError) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
		}
		return nil;
	}
	return theData;

}

- (BOOL)addData:(NSData *)aData type:(ResType)aType Id:(ResID)anID name:(nullable NSString *)aName error:(NSError**)outError
{
	Handle		theResHandle;
	
	if ([self removeType:aType Id:anID error:outError]) {
		ResFileRefNum		thePreviousRefNum;

		thePreviousRefNum = CurResFile();	// save current resource
		UseResFile(fileReference);    		// set this resource to be current
	
		// copy NSData's bytes to a handle
		OSErr error = PtrToHand([aData bytes], &theResHandle, [aData length]);
		if (noErr == error) {
			Str255			thePName;
			CFStringGetPascalString((CFStringRef)aName, thePName, 255, kCFStringEncodingMacRoman);
			
			HLock(theResHandle);
			AddResource(theResHandle, aType, anID, thePName);
			HUnlock(theResHandle);
			
			UseResFile(thePreviousRefNum);     		// reset back to resource previously set
	
			DisposeHandle(theResHandle);
			error = ResError();
			if (error != noErr) {
				if (outError) {
					*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
				}
				return NO;
			}
			return YES;
		} else {
			if (outError) {
				*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
			}
			return NO;
		}
	}
	
	return NO;
}

@end

OSErr createResourceFork(NSURL * aURL)
{
	FSRef					theParentFsRef,
							theFsRef;
	NSURL					* theUrl;
	
	theUrl = [aURL URLByDeletingLastPathComponent];

	if ([aURL getFSRef:&theParentFsRef]) {
		NSData			* theFileName;

		theFileName = [[aURL lastPathComponent] dataUsingEncoding:NSUnicodeStringEncoding];
		FSCreateResFile(&theParentFsRef, [theFileName length], [theFileName bytes], kFSCatInfoNone, NULL, &theFsRef, NULL);
	}
	
	return ResError();
}
