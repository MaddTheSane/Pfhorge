//
//  PhPluginInterface.h
//  Pfhorge
//
//  Created by Jagil on Tue Sep 10 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginProtocol.h"

@interface PhPluginManager : NSObject {
@private
	NSMutableArray<Class> *pluginClasses;
	NSMutableArray<id<PhLevelPluginProtocol>> *pluginInstances;
	NSMutableArray<NSString*> *pluginInstanceNames;
}

@property (class, readonly, retain) PhPluginManager *sharedPhPluginManager;
- (void)findPlugins;

@property (readonly, copy) NSArray<NSString*> *pluginInstanceNames;
@property (readonly, copy) NSArray<Class> *pluginClasses;
@property (readonly, copy) NSArray<id<PhLevelPluginProtocol>> *pluginInstances;

- (void)activatePluginIndex:(int)index;

 
@end
