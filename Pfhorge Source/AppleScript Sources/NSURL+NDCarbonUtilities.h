/*
 *  NSURL+NDCarbonUtilities.h category
 *  AppleScriptObjectProject
 *
 *  Created by nathan on Wed Dec 05 2001.
 *  Copyright (c) 2001 __CompanyName__. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface NSURL (NDCarbonUtilities)
+ (NSURL *)URLWithFSRef:(const FSRef *)aFsRef API_DEPRECATED("FSRefs are deprecated", macos(10.0,10.9));
- (BOOL)getFSRef:(FSRef *)aFsRef API_DEPRECATED("FSRefs are deprecated", macos(10.0,10.9));
@property (readonly, copy) NSString *fileSystemPathHFSStyle API_DEPRECATED("FSRefs are deprecated", macos(10.0,10.9));
@end
