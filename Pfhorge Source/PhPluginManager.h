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
        NSMutableArray *pluginClasses;
        NSMutableArray *pluginInstances;
        NSMutableArray *pluginInstanceNames;
}

+ (PhPluginManager *)sharedPhPluginManager;
- (void)findPlugins;

- (NSArray *)pluginInstanceNames;
- (NSArray *)pluginClasses;
- (NSArray *)pluginInstances;

- (NSArray *)pluginInstanceNames;
- (void)activatePluginIndex:(int)index;

 
@end
