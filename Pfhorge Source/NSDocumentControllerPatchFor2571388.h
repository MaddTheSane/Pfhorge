#import <Cocoa/Cocoa.h>

//extern double NSAppKitVersionNumber;

@interface NSDocumentControllerPatchedFor2571388 : NSDocumentController

- (NSArray *)extensionsFromTypeDict:(NSDictionary *)inDocumentTypeInfo;
- (id)openDocumentWithContentsOfFile:(NSString *)inDocumentFilePath
                                            display:(BOOL)inDisplayDocument;
- (id)openDocumentWithContentsOfURL:(NSURL *)inDocumentURL
                                     display:(BOOL)inDisplayDocument;

@end

void NSDocumentControllerPatchFor2571388InstallIfNecessary(void);