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

@implementation ScenarioResources


- (id)initWithContentsOfFile:(NSString *)fileName
{
    FSRef		fsref;
    CFStringRef		string;
    CFURLRef		url;
    unichar		*uniBuffer;
    FSCatalogInfo	catInfo;
    ResType		restype;
    Handle		resource;
    ResID		resID;
    Str255		resName;
    NSMutableArray	*array;
    Resource		*res;
    ResFileRefNum	refNum;
    int			i, j;
    
    [super init];
    
    filename = [fileName copy];
    
    typeDict = [[NSMutableDictionary dictionary] retain];
    
    uniBuffer = malloc(sizeof(unichar) * [fileName length]);
    
    [fileName getCharacters:uniBuffer];
    
    string = CFStringCreateWithCharacters(kCFAllocatorDefault, uniBuffer, [fileName length]);
    
    free(uniBuffer);
    
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, string, kCFURLPOSIXPathStyle, NO);
    
    CFURLGetFSRef(url, &fsref);
    
    CFRelease(string);
    CFRelease(url);
    
    FSGetCatalogInfo(&fsref, kFSCatInfoRsrcSizes, &catInfo, NULL, NULL, NULL);
    
    if (catInfo.rsrcLogicalSize && catInfo.rsrcPhysicalSize) {
        refNum = FSOpenResFile(&fsref, fsRdPerm);
        
        if (Count1Types() == 0) {
            CloseResFile(refNum);
            return self;
        }
        
        for (i = 1; i <= Count1Types(); i++) {
            Get1IndType(&restype, i);
            
            array = [NSMutableArray array];
            
            for (j = 1; j <= Count1Resources(restype); j++) {
                SetResLoad(NO);
                
                resource = Get1IndResource(restype, j);
                
                GetResInfo(resource, &resID, NULL, resName);
                
                res = [[Resource alloc] initWithID:resID
                    type:[NSString stringWithCString:(unsigned char *)&restype length:4]
                    name:[NSString stringWithCString:&resName[1] length:resName[0]]];
                
                [array addObject:[res autorelease]];
                
                ReleaseResource(resource);
                
                SetResLoad(YES);
            }
            
            [typeDict setObject:array
                forKey:[NSString
                stringWithCString:(unsigned char *)&restype
                length:4]];
            
            [array sortUsingSelector:@selector(compare:)];
        }
        
        CloseResFile(refNum);
    }
    
    return self;
}

- (void)dealloc
{
    [filename release];
    [typeDict release];
    
    [super dealloc];
}

- (void)saveToFile:(NSString *)fileName oldFile:(NSString *)oldFileName
{
    FSRef		fsref, parentfsref;
    CFStringRef		string;
    CFURLRef		url, parenturl;
    unichar		*uniBuffer;
    ResFileRefNum	refNum;
    NSArray		*array;
    Resource		*resource;
    Handle		handle;
    int			i, j;
    
    uniBuffer = malloc(sizeof(unichar) * [fileName length]);
    [fileName getCharacters:uniBuffer];
    string = CFStringCreateWithCharacters(kCFAllocatorDefault, uniBuffer, [fileName length]);
    free(uniBuffer);
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, string, kCFURLPOSIXPathStyle, NO);
    //CFURLGetFSRef(url, &fsref);
    CFRelease(string);
    
    parenturl = CFURLCreateCopyDeletingLastPathComponent(kCFAllocatorDefault, url);
    CFURLGetFSRef(parenturl, &parentfsref);
    string = CFURLCopyLastPathComponent(url);
    uniBuffer = malloc(sizeof(UniChar) * CFStringGetLength(string));
    CFStringGetCharacters(string, CFRangeMake(0, CFStringGetLength(string)), uniBuffer);
    
    FSCreateResFile(&parentfsref, CFStringGetLength(string), uniBuffer, 0, NULL, &fsref, NULL);
    
    free(uniBuffer);
    CFRelease(url);
    
    refNum = FSOpenResFile(&fsref, fsWrPerm);
    
    for (i = 0; i < ((int)[typeDict count]); i++) {
        array = [[typeDict allValues] objectAtIndex:i];
        
        for (j = 0; j < ((int)[array count]); j++) {
            resource = [self resourceOfType:[[array objectAtIndex:j] type]
                index:[[[array objectAtIndex:j] resID] shortValue]
                load:NO];
            
            if (![resource loaded]) {
                handle = ASGetResource([[array objectAtIndex:j] type],
                    [[array objectAtIndex:j] resID],
                    oldFileName);
            }
            else
            {
                handle = NewHandle([[resource data] length]);
                HLock(handle);
                [[resource data] getBytes:*handle];
            }
            
            UseResFile(refNum);
            
            AddResource(handle, [[array objectAtIndex:j] typeAsResType],
                [[[array objectAtIndex:j] resID] unsignedShortValue],
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
    Handle data;
    FSRef		fsref;
    CFStringRef		string;
    CFURLRef		url;
    unichar		*uniBuffer;
    ResFileRefNum	refNum, saveNum;
    ResType		resType;
    
    uniBuffer = malloc(sizeof(unichar) * [fileName length]);
    [fileName getCharacters:uniBuffer];
    string = CFStringCreateWithCharacters(kCFAllocatorDefault, uniBuffer, [fileName length]);
    free(uniBuffer);
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, string, kCFURLPOSIXPathStyle, NO);
    CFURLGetFSRef(url, &fsref);
    CFRelease(string);
    CFRelease(url);
    
    saveNum = CurResFile();
    
    refNum = FSOpenResFile(&fsref, fsRdPerm);
    
    UseResFile(refNum);
    
    [type getCString:(char *)&resType maxLength:4 encoding:NSMacOSRomanStringEncoding];
	resType = CFSwapInt32BigToHost(resType);
    SetResLoad(YES);
    
    data = Get1Resource(resType, [resID unsignedShortValue]);
    
    MacLoadResource(data);
    DetachResource(data);
    //HNoPurge(data);
    HLockHi(data);
    
    CloseResFile(refNum);
    
    UseResFile(saveNum);
    
    return data;
}

- (Resource *)resourceOfType:(NSString *)type index:(int)index load:(BOOL)load
{
    Resource		*resource, *value;
    Handle		handle;
    NSArray		*array;
    NSEnumerator	*resEnum;
    NSNumber		*indexAsNSNumber = [NSNumber numberWithInt:index];
    
    value = nil;
    array = [typeDict objectForKey:type];
    resEnum = [array objectEnumerator];
    
    resource = [resEnum nextObject];
    while (resource) {
        if ([[resource resID] isEqualToNumber:indexAsNSNumber]) {
            value = resource;
            break;
        }
        
        resource = [resEnum nextObject];
    }
    
    if ((value) && (![value loaded]) && load) {
        [value setLoaded:YES];
        handle = ASGetResource(type, indexAsNSNumber, filename);
        [value setData:[NSData dataWithBytesNoCopy:*handle length:GetHandleSize(handle)]];
    }
    
    return value;
}

- (Resource *)resourceOfType:(NSString *)type index:(int)index
{
    return [self resourceOfType:type index:index load:YES];
}


- (void)saveResourcesOfType:(NSString *)type to:(NSString *)baseDirPath extention:(NSString *)fileExt progress:(BOOL)showProgress
{
    Resource		*resource, *value;
    Handle		handle;
    NSArray		*array;
    NSEnumerator	*resEnum;
    NSString 		*fullPath;
    NSData 		*theData;
    NSFileManager	*fileManager = [NSFileManager defaultManager];
    
    PhProgress *progress = [PhProgress sharedPhProgress];
    
    value = nil;
    array = [typeDict objectForKey:type];
    resEnum = [array objectEnumerator];
    
    while (resource = [resEnum nextObject])
    {
        handle = ASGetResource(type, [resource resID], filename);
        theData = [NSData dataWithBytesNoCopy:*handle length:GetHandleSize(handle)];
        
        [progress setInformationalText:[NSString stringWithFormat:@"Saving PICT Resource# %@...", [[resource resID] stringValue], nil]];
        
        fullPath = [baseDirPath stringByAppendingString:[[[resource resID] stringValue] stringByAppendingString:fileExt]];
        
        [fileManager createFileAtPath:fullPath
                             contents:theData
                        // May want to set creator code, etc...
                           attributes:nil]; 
    }
}


- (int)count
{
    NSEnumerator	*typeEnum;
    NSArray		*resArray;
    int			i, count;
    
    count = 0;
    
    typeEnum = [typeDict objectEnumerator];
    
    for (i = 0; i < ((int)[typeDict count]); i++) {
        resArray = [typeEnum nextObject];
        
        count += [resArray count];
    }
    
    return count;
}

- (Resource *)objectAtIndex:(int)index
{
    NSEnumerator	*typeEnum;
    NSArray		*resArray;
    id			object;
    int			i, j, count;
    
    object = nil;
    count = 0;
    
    typeEnum = [typeDict objectEnumerator];
    
    for (i = 0; i < ((int)[typeDict count]); i++) {
        resArray = [typeEnum nextObject];
        
        for (j = 0; j < ((int)[resArray count]); j++) {
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
    NSMutableArray	*array;
    
    array = [typeDict objectForKey:[resource type]];
    
    if (!array) {
        array = [NSMutableArray arrayWithObject:resource];
        [typeDict setObject:array forKey:[resource type]];
    }
    else {
        [array addObject:resource];
    }
}

- (void)removeResource:(Resource *)resource
{
    NSMutableArray	*array;
    
    array = [typeDict objectForKey:[resource type]];
    
    [array removeObject:resource];
    
    if (![array count]) {
        [typeDict removeObjectForKey:[resource type]];
    }
}

- (NSMutableDictionary *)typeDict
{
    return typeDict;
}
@end
