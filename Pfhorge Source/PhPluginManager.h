//
//  PhPluginInterface.h
//  Pfhorge
//
//  Created by Jagil on Tue Sep 10 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginProtocol.h"

@protocol PhLevelPluginProtocol;

@interface PhPluginManager : NSObject {
@private
	NSMutableArray<Class<PhLevelPluginProtocol>> *pluginClasses;
	NSMutableArray<id<PhLevelPluginProtocol>> *pluginInstances;
	NSMutableArray<NSString*> *pluginInstanceNames;
}

@property (class, readonly, retain) PhPluginManager *sharedPhPluginManager;
- (void)findPlugins;

@property (readonly, copy) NSArray<NSString*> *pluginInstanceNames;
@property (readonly, copy) NSArray<Class<PhLevelPluginProtocol>> *pluginClasses;
@property (readonly, copy) NSArray<id<PhLevelPluginProtocol>> *pluginInstances;

- (void)activatePluginIndex:(int)index;

 
@end
