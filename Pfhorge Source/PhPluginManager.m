//
//  PhPluginInterface.m
//  Pfhorge
//
//  Created by Jagil on Tue Sep 10 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "PhPluginManager.h"
//#import "PluginInterface.h"

@interface PhPluginManager (private)
    - (void)activatePlugin:(NSString*)path;
    - (void)initializePlugins;
    - (void)instantiatePlugins:(Class)pluginClass;
@end

@implementation PhPluginManager

- (id)init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    pluginClasses = [[NSMutableArray alloc] init];
    pluginInstances = [[NSMutableArray alloc] init];
    pluginInstanceNames = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc
{
    [pluginClasses release];
    [pluginInstances release];
    [pluginInstanceNames release];
	
	[super dealloc];
}

// ************************* Accsessor Methods *************************
#pragma mark -
#pragma mark ееееееееее Accsessor Methods еееееееее

- (NSArray *)pluginInstanceNames { return pluginInstanceNames; }
- (NSArray *)pluginClasses { return pluginClasses; }
- (NSArray *)pluginInstances { return pluginInstances; }
 
// ************************* Convience Methods *************************
#pragma mark -
#pragma mark ееееееееее Convience Methods еееееееее

- (void)activatePluginIndex:(int)index
{
    [[pluginInstances objectAtIndex:index] activate];
}


// ************************* Utilties *************************
#pragma mark -
#pragma mark ееееееееее Utilties еееееееее

- (void)findPlugins
{
    BOOL isDir = NO;
    BOOL exsists = NO;
    NSString* folderPath = [[NSBundle mainBundle] builtInPlugInsPath];
    
    NSLog(@"Loading Plugins...");
    
    if (folderPath) {
        NSEnumerator* enumerator = [[NSBundle pathsForResourcesOfType:@"plugin" inDirectory:folderPath] objectEnumerator];
        NSString* pluginPath;
        while ((pluginPath = [enumerator nextObject])) {
            [self activatePlugin:pluginPath];
        }
    }
    
    folderPath = [[@"~/Library/Application Support/Pfhorge" stringByExpandingTildeInPath] stringByAppendingString:@"/"];
    //NSLog(@"Getting Plugins At: %@", folderPath);
    exsists = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
    

    if (!exsists)
    {
        NSLog(@"Creating Support Folder...");
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath attributes:nil];
    }
    /*if (exsists && (!isDir));
    {
        NSLog(@"A file exsits is place for support folder!!!");
        return;
    } */
    
    else if (folderPath) {
        NSEnumerator* enumerator = [[NSBundle pathsForResourcesOfType:@"plugin" inDirectory:folderPath] objectEnumerator];
        NSString* pluginPath;
        while ((pluginPath = [enumerator nextObject])) {
                [self activatePlugin:pluginPath];
        }
    }
    
    [self initializePlugins];
}


// ************************* Private Methods *************************
#pragma mark -
#pragma mark ееееееееее Private Methods еееееееее

//	This is called to activate each plug-in, meaning that each candidate bundle is checked,
//	loaded if it seems to contain a valid plug-in, and the plug-in's class' initiateClass
//	method is called. If this returns YES, it means that the plug-in agrees to run and the
//	class is added to the pluginClass array. Some plug-ins might refuse to be activated
//	depending on some external condition.

- (void)activatePlugin:(NSString*)path {
	NSBundle* pluginBundle = [NSBundle bundleWithPath:path];
	
	NSLog(@"   Activating Plugin: %@", path);
	
	if (pluginBundle) {
		NSDictionary* pluginDict = [pluginBundle infoDictionary];
		NSString* pluginName = [pluginDict objectForKey:@"NSPrincipalClass"];
		if (pluginName) {
			Class pluginClass = NSClassFromString(pluginName);
			if (!pluginClass) {
				pluginClass = [pluginBundle principalClass];
				if ([pluginClass conformsToProtocol:@protocol(PhLevelPluginProtocol)] &&
					[pluginClass isKindOfClass:[NSObject class]] &&
					[pluginClass initializeClass:pluginBundle])
				{
					NSLog(@"      ... Activated!");
					[pluginClasses addObject:pluginClass];
				}
			}
		}
	}
}



       
- (void)initializePlugins
{
    NSEnumerator* enumerator = [pluginClasses objectEnumerator];
    Class pluginClass;
    while ((pluginClass = [enumerator nextObject]))
    {
        [self instantiatePlugins:pluginClass];
    }
    //[theWindow makeKeyAndOrderFront:self];
}


//	A plug-in class can return multiple plug-in objects, so we ask each one to return an enumerator of
//	plug-in instances. We pass the window as argument for this call; some plug-ins might refuse to
//	instantiate themselves depending on the argument. Each plug-in instance is asked to return a view
//	which is resized and added to the main window's tab view, and the plug-in is then added to the
//	instances array.

- (void)instantiatePlugins:(Class)pluginClass {
	NSEnumerator* plugs = [pluginClass pluginsFor:self];
	NSObject<PhLevelPluginProtocol>* plugin;
	while ((plugin = [plugs nextObject])) {
		//NSTabViewItem* tab = [[[NSTabViewItem alloc] initWithIdentifier:nil] autorelease];
		//NSView* view = [plugin theView];
		//NSRect frame = [theTabView contentRect];
		//[view setFrame:frame];
		//[tab setView:view];
		//[tab setLabel:[plugin theViewName]];
		//[theTabView addTabViewItem:tab];
		[pluginInstances addObject:plugin];
		//[plugin showWindow:nil];
		//NSLog(@"ShowWindow called for plugin...");
		
		[pluginInstanceNames addObject:[plugin name]];
	}
}



// *********************** Class Methods ***********************
#pragma mark -
#pragma mark ееееееееее Class Methods ееееееееее
+ (PhPluginManager *)sharedPhPluginManager {
	static PhPluginManager *sharedPuginManagerController = nil;
	
	if (!sharedPuginManagerController) {
		sharedPuginManagerController = [[PhPluginManager alloc] init];
	}
	
	return sharedPuginManagerController;
}
@end
