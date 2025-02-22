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

@class LEMap, PhPluginManager;
@protocol PhLevelPluginProtocol;

@interface PhPluginManager: NSObject

    /// Use this to get the plugin manager...
    + (PhPluginManager *)getThePluginManager;
    
    /// Currently Loaded Plugin Types...
    - (NSArray<Class<PhLevelPluginProtocol>> *)pluginClasses;
    
    /// Currently Instated Plugins...
    - (NSArray<id<PhLevelPluginProtocol>> *)pluginInstances;
    
    /// Lists the `LEMap` documents open,
    /// in order of front to back...
    - (NSArray<LEMap *> *)levelDocumentsOpen;
    
    /// Gives the front most LEMap level document...
    -(LEMap *)currentDocument;

@end

