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

- (instancetype)initForReadingAtURL:(NSURL *)aURL error:(NSError *__autoreleasing  _Nullable *)outError
{
	return [self initWithPermission:fsRdPerm AtURL:aURL error:outError];
}

- (instancetype)initForWritingToURL:(NSURL *)aURL error:(NSError *__autoreleasing  _Nullable * _Nullable)outError
{
	return [self initWithPermission:fsWrPerm AtURL:aURL error:outError];
}

/*
 * initForPermission:AtURL:
 */
- (id)initForPermission:(NDResourceForkPermission)aPermission AtURL:(NSURL *)aURL
{
	return self = [self initWithPermission:aPermission AtURL:aURL error:NULL];
}

- (id)initWithPermission:(NDResourceForkPermission)aPermission AtURL:(NSURL *)aURL error:(NSError**)outError
{
	OSErr			theError = !noErr;
	FSRef			theFsRef;

	if ((self = [super init])) {
		if (![aURL getFSRef:&theFsRef]) {
			if (outError) {
				*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:fnfErr userInfo:@{NSURLErrorKey: aURL}];
			}
			return nil;
		}
		HFSUniStr255 forkName;
		FSGetResourceForkName(&forkName);
		theError = FSOpenResourceFile(&theFsRef, forkName.length, forkName.unicode, aPermission, &fileReference);
		
		if (resFNotFound == theError && aPermission == fsWrPerm) {	// file has no resource fork
			theError = createResourceFork(aURL);
			if (theError != noErr) {
				if (outError) {
					*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:fnfErr userInfo:@{NSURLErrorKey: aURL}];
				}
				return nil;
			}
			theError = FSOpenResourceFile(&theFsRef, forkName.length, forkName.unicode, aPermission, &fileReference);
		}
	}

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
	return [self addData:aData type:aType Id:anID name:aName error:NULL];
}

/*
 * dataForType:Id:
 */
- (NSData *)dataForType:(ResType)aType Id:(ResID)anID
{
	return [self dataForType:aType Id:anID error:NULL];
}

/*
 * removeType: Id:
 */
- (BOOL)removeType:(ResType)aType Id:(short)anID
{
	return [self removeType:aType Id:anID error:NULL];
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
		return (error == noErr);
	} else if (error != resNotFound) {
		if (outError) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil];
		}
		return NO;
	}
	return YES;
}

- (nullable NSData *)dataForType:(ResType)aType Id:(ResID)anID error:(NSError *__autoreleasing  _Nullable * _Nullable)outError
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
		HFSUniStr255 forkName;
		FSGetResourceForkName(&forkName);
		return FSCreateResourceFile(&theParentFsRef, [theFileName length], [theFileName bytes], kFSCatInfoNone, NULL, forkName.length, forkName.unicode, &theFsRef, NULL);
	}
	
	return fnfErr;
}
