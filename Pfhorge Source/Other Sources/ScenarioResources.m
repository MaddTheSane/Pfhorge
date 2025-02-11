//
//  ScenarioResources.m
//  ACME Station
//
//  Created by thomas on Tue Nov 13 2001.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "ScenarioResources.h"
#import "Resource.h"
#import "PhData.h"
#import "NSURL+NDCarbonUtilities.h"

#import "PhProgress.h"

static Handle ASGetResource(NSString *type, NSNumber *resID, NSString *fileName);
static Handle ASGetResourceURL(NSString *type, NSNumber *resID, NSURL *url);

@interface ScenarioResources ()
- (BOOL)loadContentsOfURL:(NSURL *)fileURL error:(NSError**)outError;
@end

@implementation ScenarioResources

+ (BOOL)isAppleSingleAtURL:(NSURL*)url findResourceFork:(BOOL)rsrc_fork offset:(int*)offset length:(int*)length
{
    NSData *aData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:NULL];
    if (!aData) {
        return NO;
    }
    PhData *dat = [[PhData alloc] initWithData:aData];
    uint32 ident;
    uint32 version;
    if (!([dat getUnsignedInt:&ident] &&
          [dat getUnsignedInt:&version])) {
        return NO;
    }
    
    if (ident != 0x00051600 || version != 0x00020000) {
        return NO;
    }

    // Find fork
    const uint32_t req_id = rsrc_fork ? 2 : 1;
    if (![dat setPosition:0x18]) {
        return NO;
    }
    short num_entries;
    if (![dat getShort:&num_entries]) {
        return NO;
    }
    
    while (num_entries--) {
        uint32_t id2;
        int32_t ofs;
        int32_t len;
        if (!([dat getUnsignedInt:&id2] && [dat getInt:&ofs] && [dat getInt:&len])) {
            return NO;
        }
        if (id2 == req_id) {
            if (offset) {
                *offset = ofs;
            }
            if (length) {
                *length = len;
            }
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isMacBinaryAtURL:(NSURL*)url dataLength:(int*)data_length resourceLength:(int*)rsrc_length
{
    // This recognizes up to macbinary III (0x81)
    NSData *aData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:NULL];
    if (!aData || aData.length < 128) {
        return NO;
    }
    
    uint8_t header[128];
    [aData getBytes:header length:sizeof(header)];
    
    if (header[0] || header[1] > 63 || header[74] || header[123] > 0x81) {
        return NO;
    }
    
    // Check CRC
    uint16_t crc = 0;
    for (int i=0; i<124; i++) {
        uint16_t data = header[i] << 8;
        for (int j=0; j<8; j++) {
            if ((data ^ crc) & 0x8000) {
                crc = (crc << 1) ^ 0x1021;
            } else {
                crc <<= 1;
            }
            data <<= 1;
        }
    }
    //printf("crc %02x\n", crc);
    if (crc != ((header[124] << 8) | header[125])) {
        return NO;
    }
    
    // CRC valid, extract fork sizes
    if (data_length) {
        *data_length = (header[83] << 24) | (header[84] << 16) | (header[85] << 8) | header[86];
    }
    if (rsrc_length) {
        *rsrc_length = (header[87] << 24) | (header[88] << 16) | (header[89] << 8) | header[90];
    }
    return YES;
}

- (id)initWithContentsOfFile:(NSString *)fileName
{
    if (self = [super init]) {
        [self loadContentsOfFile:fileName];
    }
    return self;
}

- (instancetype)initWithContentsOfURL:(NSURL *)fileName error:(NSError**)outError
{
    if (self = [super init]) {
        if (![self loadContentsOfURL:fileName error:outError]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)loadContentsOfFile:(NSString *)fileName
{
    return [self loadContentsOfURL:[NSURL fileURLWithPath:fileName] error:NULL];
}

- (BOOL)loadContentsOfFile:(NSString *)fileName error:(NSError**)outError;
{
    return [self loadContentsOfURL:[NSURL fileURLWithPath:fileName] error:outError];
}

- (BOOL)loadContentsOfURL:(NSURL *)fileURL error:(NSError**)outError
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
    OSStatus        err;
        
    filename = [fileURL.path copy];
    
    typeDict = [[NSMutableDictionary alloc] init];
        
    if (![fileURL getFSRef:&fsref]) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:fnfErr userInfo:@{NSURLErrorKey: fileURL}];
        }
        return NO;
    }
    
    err = FSGetCatalogInfo(&fsref, kFSCatInfoRsrcSizes, &catInfo, NULL, NULL, NULL);
    if (err != noErr) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:@{NSURLErrorKey: fileURL}];
        }
    }
    
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
    NSURL *oldURL = nil;
    if (oldFileName) {
        oldURL = [NSURL fileURLWithPath:oldFileName];
    }
    [self saveToURL:[NSURL fileURLWithPath:fileName] oldFileURL:oldURL];
}

- (void)saveToURL:(NSURL *)url oldFileURL:(nullable NSURL *)oldFileName
{
    FSRef			    fsref, parentfsref;
    NSString		    *string;
    NSURL			    *parenturl;
    unichar			    *uniBuffer;
    ResFileRefNum	    refNum;
    NSArray<Resource*>	*array;
    Resource		    *resource;
    Handle			    handle;
    
    parenturl = [url URLByDeletingLastPathComponent];
    [parenturl getFSRef:&parentfsref];
    string = [url lastPathComponent];
    uniBuffer = malloc(sizeof(UniChar) * string.length);
    [string getCharacters:uniBuffer range:NSMakeRange(0, string.length)];
    
    FSCreateResFile(&parentfsref, string.length, uniBuffer, 0, NULL, &fsref, NULL);
    
    free(uniBuffer);
    
    refNum = FSOpenResFile(&fsref, fsWrPerm);
    
    for (array in typeDict.objectEnumerator) {
        
        for (Resource *res in array) {
            resource = [self resourceOfType:[res type]
                                      index:[[res resID] shortValue]
                                       load:NO];
            
            if (![resource loaded]) {
                handle = ASGetResourceURL([res type],
                                          [res resID],
                                          oldFileName);
            } else {
                handle = NewHandle([[resource data] length]);
                HLock(handle);
                [[resource data] getBytes:*handle length:[[resource data] length]];
                HUnlock(handle);
            }
            
            UseResFile(refNum);
            
            AddResource(handle, [res typeAsResType],
                        [[res resID] shortValue],
                        [res nameAsStr255]);
            
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
		[url getFSRef:&fsref];
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

Handle ASGetResourceURL(NSString *type, NSNumber *resID, NSURL *url)
{
    Handle            data;
    FSRef            fsref;
    ResFileRefNum    refNum, saveNum;
    ResType            resType;
    
    [url getFSRef:&fsref];
    
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
        [value setData:[[NSData alloc] initWithBytesNoCopy:*handle length:GetHandleSize(handle) deallocator:^(void * _Nonnull bytes, NSUInteger length) {
            DisposeHandle(handle);
        }]];
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
    NSFileManager	*fileManager = [NSFileManager defaultManager];
    OSType 			osTyp = UTGetOSTypeFromString((__bridge CFStringRef)type);
    NSNumber		*nsOSTyp = @(osTyp);
    
    PhProgress *progress = [PhProgress sharedPhProgress];
    
    for (Resource *resource in array) @autoreleasepool {
        Handle handle = ASGetResource(type, [resource resID], filename);
        HLock(handle);
        NSData *theData = [[NSData alloc] initWithBytesNoCopy:*handle length:GetHandleSize(handle) deallocator:^(void * _Nonnull bytes, NSUInteger length) {
            HUnlock(handle);
            DisposeHandle(handle);
        }];
        
        [progress setInformationalText:[NSString stringWithFormat:@"Saving ‘%@’ Resource# %@…", type, [resource resID], nil]];
        
        NSString *fullPath = [baseDirPath stringByAppendingPathComponent:[[[resource resID] stringValue] stringByAppendingPathExtension:fileExt]];
        
        [fileManager createFileAtPath:fullPath
                             contents:theData
                        // May want to set creator code, etc...
						   attributes:@{NSFileHFSTypeCode: nsOSTyp}];
    }
}


- (void)iterateResourcesOfType:(NSString *)type progress:(BOOL)showProgress block:(void(NS_NOESCAPE^)(Resource*, NSData*, PhProgress*))block
{
    NSArray<Resource*> *array = [typeDict objectForKey:type];
    
    PhProgress *progress;
    if (showProgress) {
        progress = [PhProgress sharedPhProgress];
    } else {
        progress = nil;
    }
    
    for (Resource *resource in array) @autoreleasepool {
        Handle handle = ASGetResource(type, [resource resID], filename);
        HLock(handle);
        NSData *theData = [[NSData alloc] initWithBytesNoCopy:*handle length:GetHandleSize(handle) deallocator:^(void * _Nonnull bytes, NSUInteger length) {
            HUnlock(handle);
            DisposeHandle(handle);
        }];

        block(resource, theData, progress);
    }
}


- (NSInteger)count
{
    NSInteger count = 0;
    
    for (NSArray *resArray in [typeDict objectEnumerator]) {
        count += [resArray count];
    }
    
    return count;
}

- (Resource *)objectAtIndex:(NSInteger)index
{
    id          object = nil;
    NSInteger   count = 0;
    
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
