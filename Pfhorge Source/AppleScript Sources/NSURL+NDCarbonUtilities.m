/*
 *  NSURL+NDCarbonUtilities.m category
 *  AppleScriptObjectProject
 *
 *  Created by nathan on Wed Dec 05 2001.
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 */

#import "NSURL+NDCarbonUtilities.h"

@implementation NSURL (NDCarbonUtilities)

+ (NSURL *)URLWithFSRef:(const FSRef *)aFsRef
{
	return CFBridgingRelease(CFURLCreateFromFSRef( kCFAllocatorDefault, aFsRef ));
}

- (BOOL)getFSRef:(FSRef *)aFsRef
{
	return CFURLGetFSRef( (CFURLRef)self, aFsRef );
}

- (NSString *)fileSystemPathHFSStyle
{
    return CFBridgingRelease(CFURLCopyFileSystemPath((CFURLRef)self, kCFURLHFSPathStyle));
}

@end
