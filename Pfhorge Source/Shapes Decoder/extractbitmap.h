#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

extern NSErrorDomain const LEShapesImportErrorDomain;
typedef NS_ERROR_ENUM(LEShapesImportErrorDomain, LEShapesImportErrors) {
	LEShapesImportCouldNotReadCollectionHeader,
	LEShapesImportCouldNotReadColorTable,
	LEShapesImportCouldNotReadBitmapInfo,
	LEShapesImportReturnedNilImageRep,
};

NSArray<NSImage*> * _Nullable getAllTexturesOf(int theCollection, int theColorTable, const char *theShapesPath) NS_SWIFT_NAME(getAllTextures(collection:colorTable:shapesPath:));

NSArray<NSImage*> * _Nullable getAllTexturesOfWithError(int theCollection, int theColorTable, NSURL *theShapesPath, NSError *_Nullable __autoreleasing* _Nullable outError) NS_REFINED_FOR_SWIFT;

NS_ASSUME_NONNULL_END
