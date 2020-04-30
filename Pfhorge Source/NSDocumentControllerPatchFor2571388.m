#import "NSDocumentControllerPatchFor2571388.h"

@implementation NSDocumentControllerPatchedFor2571388

// Reimplement a method that is invoked by both -fileExtensionsFromType:
// and -typeFromFileExtension:, effectively fixing them both.
// Warning: Even though this method appears in this patch file, don't
// consider it public.  Do not make assumptions about when this method
// will be invoked.  It may not be invoked at all in versions of AppKit in
// which 2571388 is fixed.

- (NSArray *)extensionsFromTypeDict:(NSDictionary *)inDocumentTypeInfo {
    NSArray *extensions;
    NSArray *osTypes;
    NSArray *extensionsAndHFSTypes;
    
    // Get the array that contains the file name extensions that are
    // allowable for the document type.
    
    extensions = [inDocumentTypeInfo
                  objectForKey:@"CFBundleTypeExtensions"];
    // Add entries for HFS file types if the passed-in dictionary has a
    // CFBundleTypeOSTypes entry.
    osTypes = [inDocumentTypeInfo
               objectForKey:@"CFBundleTypeOSTypes"];
    if (osTypes) {
        // For each entry in the CFBundleTypeOSTypes array, wrap what
        // should be a four-character string with apostrophes.
        int osTypeIndex;
        int osTypeCount = [osTypes count];
        NSMutableArray *hfsTypes = [NSMutableArray
                                    arrayWithCapacity:osTypeCount];
        for (osTypeIndex = 0; osTypeIndex<osTypeCount; osTypeIndex++) {
            NSString *osTypeAsFourCharString = [osTypes
                                                objectAtIndex:osTypeIndex];
            NSString *hfsType = [NSString
                                 stringWithFormat:@"\'%@\'",
                                 osTypeAsFourCharString];
            [hfsTypes addObject:hfsType];
        }
        // Add the array of HFS file types to the array being returned.
        extensionsAndHFSTypes = extensions ?
             [extensions arrayByAddingObjectsFromArray:hfsTypes] : hfsTypes;
    } else {
        // There are no HFS file types associated with this document file
        // type.  Just return the file name extensions, if there are any.
        extensionsAndHFSTypes = extensions;
    }
    // Done.
    return extensionsAndHFSTypes;
}


// Reimplement -openDocumentWithContentsOfFile:display: so that it no
// longer suffers from 2571388.

- (id)openDocumentWithContentsOfFile:(NSString *)inDocumentFilePath
                                            display:(BOOL)inDisplayDocument {
    // Try to open the document, using the already-existing Cocoa code,
    // which determines document type from file name extension.
    NSDocument *document = [super
                            openDocumentWithContentsOfFile:inDocumentFilePath
                            display:inDisplayDocument];
    // If that didn't work, try another way.
    if (!document && [[NSFileManager defaultManager]
                              fileExistsAtPath:inDocumentFilePath]) {
        // Try to figure out what kind of document we're opening, based on
        // the HFS file type.
    NSString *hfsFileType = NSHFSTypeOfFile(inDocumentFilePath);
    NSString *documentTypeName = [self typeFromFileExtension:hfsFileType];
        // If we were successful in determining the document type, try to
        // open the document.
        if (documentTypeName) {
            document = [self
                        makeDocumentWithContentsOfFile:inDocumentFilePath
                        ofType:documentTypeName];
            if (document) {
                [self addDocument:document];
                if ([self shouldCreateUI]) {
                    [document makeWindowControllers];
                    if (inDisplayDocument) {
                        [document showWindows];
                    }
                }
            }
        }
    }
    // Successful or not, done.
    return document;
}


// Reimplement -openDocumentWithContentsOfURL:display: so that it no
// longer suffers from 2571388.
- (id)openDocumentWithContentsOfURL:(NSURL *)inDocumentURL
                                     display:(BOOL)inDisplayDocument {
    NSDocument *document = nil;
    if ([inDocumentURL isFileURL]) {
        NSString *documentPath = [inDocumentURL path];
        document = [self openDocumentWithContentsOfFile:documentPath
                    display:inDisplayDocument];
    }
    return document;
}

@end
void NSDocumentControllerPatchFor2571388InstallIfNecessary(void) {
    // If the current version of AppKit is earlier than the first one in
    // which 2571388 is known to be fixed, replace the
    // NSDocumentController class with
    // NSDocumentControllerPatchedFor2571388.
    // Warning: The AppKit version for Mac OS 10.0, 10.0.1, 10.0.2, and
    // 10.0.3 is 577.0.  It's not safe however to test
    // NSAppKitVersionNumber>577.0, because Apple may or may not
    // release a product in which AppKit's version number is greater than
    // 577, but in which 2571388 is nonetheless not fixed.
    if (NSAppKitVersionNumber<588.0) {
        [NSDocumentControllerPatchedFor2571388
         poseAsClass:[NSDocumentController class]];
    }
}