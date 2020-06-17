//
//  ScenarioResources.m
//  ACME Station
//
//  Created by thomas on Tue Nov 13 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "ScenarioResources.h"
#import "Resource.h"

#import "PhProgress.h"

static Handle ASGetResource(NSString *type, NSNumber *resID, NSString *fileName);

@implementation ScenarioResources


- (id)initWithContentsOfFile:(NSString *)fileName
{
    if (self = [super init]) {
        [self loadContentsOfFile:fileName];
    }
    return self;
}

- (BOOL)loadContentsOfFile:(NSString *)fileName
{
    FSRef			fsref;
    FSCatalogInfo	catInfo;
    ResType			restype;
    Handle			resource;
    ResID			resID;
    Str255			resName;
    Resource		*res;
    ResFileRefNum	refNum;
    int				i, j;
        
    filename = [fileName copy];
    
    typeDict = [[NSMutableDictionary alloc] init];
        
    @autoreleasepool {
        NSURL *url = [NSURL fileURLWithPath:fileName];
        CFURLGetFSRef((CFURLRef)url, &fsref);
    }
    
    FSGetCatalogInfo(&fsref, kFSCatInfoRsrcSizes, &catInfo, NULL, NULL, NULL);
    
    if (catInfo.rsrcLogicalSize && catInfo.rsrcPhysicalSize) {
        refNum = FSOpenResFile(&fsref, fsRdPerm);
        
        if (Count1Types() == 0) {
            CloseResFile(refNum);
            return YES;
        }
        
        for (i = 1; i <= Count1Types(); i++) {
            Get1IndType(&restype, i);
            
            NSMutableArray *array = [NSMutableArray array];
            
            for (j = 1; j <= Count1Resources(restype); j++) {
                SetResLoad(NO);
                
                resource = Get1IndResource(restype, j);
                
                GetResInfo(resource, &resID, NULL, resName);
                
                
                
                res = [[Resource alloc] initWithID:resID
                                              type:CFBridgingRelease(UTCreateStringForOSType(restype))
                                              name:resName[0] != 0 ? CFBridgingRelease(CFStringCreateWithPascalString(kCFAllocatorDefault, resName, kCFStringEncodingMacRoman)) : nil];
                
                [array addObject:res];
                
                ReleaseResource(resource);
                
                SetResLoad(YES);
            }
            
            [typeDict setObject:array
                forKey:CFBridgingRelease(UTCreateStringForOSType(restype))];
            
            [array sortUsingSelector:@selector(compare:)];
        }
        
        CloseResFile(refNum);
    }
    
    return YES;
}

- (void)saveToFile:(NSString *)fileName oldFile:(NSString *)oldFileName
{
    FSRef			fsref, parentfsref;
    NSString		*string;
    NSURL			*url, *parenturl;
    unichar			*uniBuffer;
    ResFileRefNum	refNum;
    NSArray<Resource*>		*array;
    Resource		*resource;
    Handle			handle;
    int				j;
    
    url = [NSURL fileURLWithPath:fileName];
    //CFURLGetFSRef(url, &fsref);
    
    parenturl = [url URLByDeletingLastPathComponent];
    CFURLGetFSRef((CFURLRef)parenturl, &parentfsref);
    string = [url lastPathComponent];
    uniBuffer = malloc(sizeof(UniChar) * string.length);
    [string getCharacters:uniBuffer range:NSMakeRange(0, string.length)];
    
    FSCreateResFile(&parentfsref, string.length, uniBuffer, 0, NULL, &fsref, NULL);
    
    free(uniBuffer);
    
    refNum = FSOpenResFile(&fsref, fsWrPerm);
    
    for (array in typeDict.objectEnumerator) {
        
        for (j = 0; j < [array count]; j++) {
            resource = [self resourceOfType:[[array objectAtIndex:j] type]
                                      index:[[[array objectAtIndex:j] resID] shortValue]
                                       load:NO];
            
            if (![resource loaded]) {
                handle = ASGetResource([[array objectAtIndex:j] type],
                                       [[array objectAtIndex:j] resID],
                                       oldFileName);
            } else {
                handle = NewHandle([[resource data] length]);
                HLock(handle);
                [[resource data] getBytes:*handle];
                HUnlock(handle);
            }
            
            UseResFile(refNum);
            
            AddResource(handle, [[array objectAtIndex:j] typeAsResType],
                        [[[array objectAtIndex:j] resID] shortValue],
                        [[array objectAtIndex:j] nameAsStr255]);
            
            WriteResource(handle);
            
            UpdateResFile(refNum);
            
            ReleaseResource(handle);
        }
    }
    
    CloseResFile(refNum);
}

Handle ASGetResource(NSString *type, NSNumber *resID, NSString *fileName)
{
    Handle			data;
    FSRef			fsref;
    ResFileRefNum	refNum, saveNum;
    ResType			resType;
    
	@autoreleasepool {
		NSURL *url = [NSURL fileURLWithPath:fileName];
		CFURLGetFSRef((CFURLRef)url, &fsref);
	}
    
    saveNum = CurResFile();
    
    refNum = FSOpenResFile(&fsref, fsRdPerm);
    
    UseResFile(refNum);
    
    resType = UTGetOSTypeFromString((__bridge CFStringRef)type);
    SetResLoad(YES);
    
    data = Get1Resource(resType, [resID shortValue]);
    
    MacLoadResource(data);
    DetachResource(data);
    //HNoPurge(data);
    HLockHi(data);
    
    CloseResFile(refNum);
    
    UseResFile(saveNum);
    
    return data;
}

- (Resource *)resourceOfType:(NSString *)type index:(ResID)index load:(BOOL)load
{
    Resource		*value = nil;
    Handle			handle;
    NSArray<Resource*>      *array = [typeDict objectForKey:type];
    NSEnumerator<Resource*> *resEnum = [array objectEnumerator];
    NSNumber                *indexAsNSNumber = @(index);
    
    for (Resource *resource in resEnum) {
        if ([[resource resID] isEqualToNumber:indexAsNSNumber]) {
            value = resource;
            break;
        }
    }
    
    if ((value) && (![value loaded]) && load) {
        [value setLoaded:YES];
        handle = ASGetResource(type, indexAsNSNumber, filename);
        [value setData:[NSData dataWithBytes:*handle length:GetHandleSize(handle)]];
        DisposeHandle(handle);
    }
    
    return value;
}

- (Resource *)resourceOfType:(NSString *)type index:(ResID)index
{
    return [self resourceOfType:type index:index load:YES];
}


- (void)saveResourcesOfType:(NSString *)type to:(NSString *)baseDirPath extention:(NSString *)fileExt progress:(BOOL)showProgress
{
    NSArray			*array = [typeDict objectForKey:type];
    NSEnumerator	*resEnum = [array objectEnumerator];
    NSFileManager	*fileManager = [NSFileManager defaultManager];
    OSType 			osTyp = UTGetOSTypeFromString((__bridge CFStringRef)type);
    NSNumber		*nsOSTyp = @(osTyp);
    
    PhProgress *progress = [PhProgress sharedPhProgress];
    
    for (Resource *resource in resEnum) {
        Handle handle = ASGetResource(type, [resource resID], filename);
        HLock(handle);
        NSData *theData = [NSData dataWithBytesNoCopy:*handle length:GetHandleSize(handle) freeWhenDone:NO];
        HUnlock(handle);
        
        [progress setInformationalText:[NSString stringWithFormat:@"Saving ‘%@’ Resource# %@…", type, [resource resID], nil]];
        
        NSString *fullPath = [baseDirPath stringByAppendingPathComponent:[[[resource resID] stringValue] stringByAppendingPathExtension:fileExt]];
        
        [fileManager createFileAtPath:fullPath
                             contents:theData
                        // May want to set creator code, etc...
						   attributes:@{NSFileHFSTypeCode: nsOSTyp}];
        DisposeHandle(handle);
    }
}


- (void)iterateResourcesOfType:(NSString *)type progress:(BOOL)showProgress block:(void(NS_NOESCAPE^)(Resource*, NSData*, PhProgress*))block
{
    NSArray         *array = [typeDict objectForKey:type];
    NSEnumerator    *resEnum = [array objectEnumerator];
    
    PhProgress *progress;
    if (showProgress) {
        progress = [PhProgress sharedPhProgress];
    } else {
        progress = nil;
    }
    
    for (Resource *resource in resEnum) @autoreleasepool {
        Handle handle = ASGetResource(type, [resource resID], filename);
        HLock(handle);
        NSData *theData = [NSData dataWithBytesNoCopy:*handle length:GetHandleSize(handle) freeWhenDone:NO];
        HUnlock(handle);
        
        block(resource, theData, progress);
        
        DisposeHandle(handle);
    }
}


- (int)count
{
    int count = 0;
    
    for (NSArray *resArray in [typeDict objectEnumerator]) {
        count += [resArray count];
    }
    
    return count;
}

- (Resource *)objectAtIndex:(int)index
{
    id  object = nil;
    int count = 0;
    
    for (NSArray *resArray in [typeDict objectEnumerator]) {
        for (NSInteger j = 0; j < [resArray count]; j++) {
            if (index == count) {
                object = [resArray objectAtIndex:j];
            }
            
            count++;
        }
    }
    
    return object;
}

- (void)addResource:(Resource *)resource
{
    NSMutableArray<Resource*> *array;
    
    array = [typeDict objectForKey:[resource type]];
    
    if (!array) {
        array = [NSMutableArray arrayWithObject:resource];
        [typeDict setObject:array forKey:[resource type]];
    } else {
        [array addObject:resource];
    }
}

- (void)removeResource:(Resource *)resource
{
    NSMutableArray	*array = [typeDict objectForKey:[resource type]];
    
    [array removeObject:resource];
    
    if ([array count] == 0) {
        [typeDict removeObjectForKey:[resource type]];
    }
}

@synthesize typeDict;

@end
