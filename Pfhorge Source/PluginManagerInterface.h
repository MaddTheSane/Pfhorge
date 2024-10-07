//
//  Written by Rainer Brockerhoff for MacHack 2002.
//  Copyright (c) 2002 Rainer Brockerhoff.
//	rainer@brockerhoff.net
//	http://www.brockerhoff.net/
//
//	This is part of the sample code for the MacHack 2002 paper "Plugged-in Cocoa".
//	You may reuse this code anywhere as long as you assume all responsibility.
//	If you do so, please put a short acknowledgement in the documentation or "About" box.
//

#import <Cocoa/Cocoa.h>
//#import "PhPluginManager.h"

@class LEMap, PhPluginManager;

@interface PhPluginManager (ForPlugins)

//! Use this to get the plugin manager...
+ (nonnull PhPluginManager *)getThePluginManager;

// Currently Loaded Plugin Types...
//- (NSArray *)pluginClasses;

// Currently Instated Plugins...
//- (NSArray *)pluginInstances;

//! Lists the LEMap documents open,
//! in order of front to back...
- (nullable NSArray<LEMap *> *)levelDocumentsOpen;

//! Gives the frontmost LEMap level document...
-(nullable LEMap *)currentDocument;

@end

