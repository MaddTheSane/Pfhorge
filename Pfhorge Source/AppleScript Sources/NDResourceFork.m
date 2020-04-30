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

OSErr createResourceFork( NSURL * aURL );

@implementation NDResourceFork

/*
 * resourceForkForReadingAtURL:
 */
+ (id)resourceForkForReadingAtURL:(NSURL *)aURL
{
	return [[[self alloc] initForReadingAtURL:aURL] autorelease];
}

/*
 * resourceForkForWritingAtURL:
 */
+ (id)resourceForkForWritingAtURL:(NSURL *)aURL
{
	return [[[self alloc] initForWritingAtURL:aURL] autorelease];
}

/*
 * resourceForkForReadingAtPath:
 */
+ (id)resourceForkForReadingAtPath:(NSString *)aPath
{
	return [[[self alloc] initForReadingAtPath:aPath] autorelease];
}

/*
 * resourceForkForWritingAtPath:
 */
+ (id)resourceForkForWritingAtPath:(NSString *)aPath
{
	return [[[self alloc] initForWritingAtPath:aPath] autorelease];
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
- (id)initForPermission:(char)aPermission AtURL:(NSURL *)aURL
{
	OSErr			theError = !noErr;
	FSRef			theFsRef;

	if( ( self = [self init] ) && [aURL getFSRef:&theFsRef] )
	{
		fileReference = FSOpenResFile ( &theFsRef, aPermission );
		
		theError = fileReference > 0 ? ResError( ) : !noErr;
		
/*
		if( noErr != theError )		// file has no resource fork
		{
			theError = createResourceFork( aURL );
			fileReference = FSOpenResFile ( &theFsRef, aPermission );;
			theError = fileReference > 0 ? ResError( ) : !noErr;
		}
 */	}

	if( noErr != theError )
	{
		[self release];
		self = nil;
	}

	return self;
}

/*
 * initForReadingAtPath:
 */
- (id)initForReadingAtPath:(NSString *)aPath
{
	if( [[NSFileManager defaultManager] fileExistsAtPath:aPath] )
		return [self initForPermission:fsRdPerm AtURL:[NSURL fileURLWithPath:aPath]];
	else
		return nil;
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
	CloseResFile( fileReference );
	[super dealloc];
}

- (BOOL)addData:(NSData *)aData type:(ResType)aType Id:(ResID)anID name:(NSString *)aName
{
	Handle		theResHandle;
	
	if( [self removeType:aType Id:anID] )
	{
		FSIORefNum		thePreviousRefNum;

		thePreviousRefNum = CurResFile();	// save current resource
		UseResFile( fileReference );    			// set this resource to be current
	
		// copy NSData's bytes to a handle
		if ( noErr == PtrToHand ( [aData bytes], &theResHandle, [aData length] ) )
		{
			Str255			thePName;
			CFStringGetPascalString((CFStringRef)aName, thePName, 255, kCFStringEncodingMacRoman);
			
			HLock( theResHandle );
			AddResource( theResHandle, aType, anID, thePName );
			HUnlock( theResHandle );
			
			UseResFile( thePreviousRefNum );     		// reset back to resource previously set
	
//			DisposeHandle( theResHandle );
			return ( ResError( ) == noErr );
		}
	}
	
	return NO;
}

/*
 * dataForType:Id:
 */
- (NSData *)dataForType:(ResType)aType Id:(ResID)anID
{
	NSData		* theData = nil;
	Handle		theResHandle;
	FSIORefNum	thePreviousRefNum;

	thePreviousRefNum = CurResFile();	// save current resource
	
	UseResFile( fileReference );    		// set this resource to be current
	
	theResHandle = Get1Resource( aType, anID );

	if ( noErr ==  ResError( ) )
	{
		HLock(theResHandle);
		theData = [NSData dataWithBytes:*theResHandle length:GetHandleSize( theResHandle )];
		HUnlock(theResHandle);
	}
	
	if ( theResHandle )
		ReleaseResource( theResHandle );

	UseResFile( thePreviousRefNum );     		// reset back to resource previously set
	
	return theData;
}

/*
 * removeType: Id:
 */
- (BOOL)removeType:(ResType)aType Id:(short)anID
{
	Handle		theResHandle;
	
	UseResFile( fileReference );    			// set this resource to be current

	theResHandle = Get1Resource( aType, anID );
	if ( ResError( ) == noErr )
	{
		RemoveResource( theResHandle );			// Disposed of in current resource file
		return ( ResError( ) == noErr );
	}
	return YES;
}

@end

OSErr createResourceFork( NSURL * aURL )
{
	FSRef					theParentFsRef,
							theFsRef;
	NSURL					* theUrl;
	
	theUrl = [aURL URLByDeletingLastPathComponent];

	if( [aURL getFSRef:&theParentFsRef] )
	{
		NSData			* theFileName;

		theFileName = [[[aURL path] lastPathComponent] dataUsingEncoding:NSUnicodeStringEncoding];
		FSCreateResFile ( &theParentFsRef, [theFileName length], [theFileName bytes], kFSCatInfoNone, NULL, &theFsRef, NULL );
	}
	
	return ( ResError( ) == noErr );
}
