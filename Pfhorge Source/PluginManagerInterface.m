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
#import "PhPluginManager.h"

@implementation PhPluginManager (ForPlugins)

    // Use this to get the plugin manager...
    + (PhPluginManager *)getThePluginManager
    {
        return [PhPluginManager sharedPhPluginManager];
    }
    
    // Currently Loaded Plugin Types...
    - (NSArray *)pluginClasses
    {
        return pluginClasses;
    }
    
    // Currently Instated Plugins...
    - (NSArray *)pluginInstances
    {
        return pluginInstances;
    }
    
    // Lists the LEMap documents open,
    //    in order of front to back...
    - (NSArray *)levelDocumentsOpen;
    {
        NSArray *theArray = [[NSDocumentController sharedDocumentController] documents];
        return ([theArray count] < 1) ? nil : theArray;
    }
    
    // Gives the front most LEMap level document...
    -(LEMap *)currentDocument
    {
        return [[NSDocumentController sharedDocumentController] currentDocument];
    }

@end

