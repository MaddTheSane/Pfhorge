//
//  ScenarioResources.h
//  ACME Station
//
//  Created by thomas on Tue Nov 13 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Resource;

//TODO: Update to use MacBinary for cross-platform compatibility!
@interface ScenarioResources : NSObject {
    NSMutableDictionary<NSString*, NSMutableArray<Resource*>*>	*typeDict;
    
    NSString		*filename;
}
- (id)initWithContentsOfFile:(NSString *)fileName;
- (BOOL)loadContentsOfFile:(NSString *)fileName;
- (void)saveToFile:(NSString *)fileName oldFile:(NSString *)oldFileName;

- (Resource *)resourceOfType:(NSString *)type index:(ResourceIndex)index;
- (Resource *)resourceOfType:(NSString *)type index:(ResourceIndex)index load:(BOOL)load;

- (void)saveResourcesOfType:(NSString *)type to:(NSString *)baseDirPath extention:(NSString *)fileExt progress:(BOOL)showProgress;

- (int)count;
- (Resource *)objectAtIndex:(int)index;

- (void)addResource:(Resource *)resource;
- (void)removeResource:(Resource *)resource;

@property (readonly, strong) NSMutableDictionary<NSString*, NSMutableArray<Resource*>*> *typeDict;
@end
