/*
 *  NSAppleEventDescriptor+NDAppleScriptObject.m
 *  AppleScriptObjectProject
 *
 *  Created by Nathan Day on Fri Dec 14 2001.
 *  Copyright (c) 2001 Nathan Day. All rights reserved.
 */

#import "NSAppleEventDescriptor+NDAppleScriptObject.h"
#import "NSURL+NDCarbonUtilities.h"

@implementation NSAppleEventDescriptor (NDAppleScriptObject)

/*
 * + appleEventDescriptorWithString:
 */

+ (NSAppleEventDescriptor *)appleEventDescriptorWithString:(NSString *)aString
{
	return [self descriptorWithDescriptorType:typeUTF8Text data:[aString dataUsingEncoding:NSUTF8StringEncoding]];
}

/*
 * + aliasListDescriptorWithArray:
 */
+ (NSAppleEventDescriptor *)aliasListDescriptorWithArray:(NSArray *)aArray
{
	NSAppleEventDescriptor	* theEventList = nil;
	NSInteger				theIndex, theNumOfParam;
	
	theNumOfParam = [aArray count];
	
	if (theNumOfParam > 0) {
		theEventList = [self listDescriptor];
		
		for (theIndex = 0; theIndex < theNumOfParam; theIndex++) {
			id				theObject;
			theObject = [aArray objectAtIndex:theIndex];
			
			if ([theObject isKindOfClass:[NSString class]]) {
				theObject = [NSURL fileURLWithPath:theObject];
			}
			
			[theEventList insertDescriptor:[self aliasDescriptorWithURL:theObject] atIndex:theIndex+1];
		}
	}
	
	return theEventList;
}

/*
 * + appleEventDescriptorWithURL:
 */
+ (NSAppleEventDescriptor *)appleEventDescriptorWithURL:(NSURL *)aURL
{
	NSData *urlDat = CFBridgingRelease(CFURLCreateData(kCFAllocatorDefault, (CFURLRef)aURL, kCFStringEncodingUTF8, true));
	return [self descriptorWithDescriptorType:typeFileURL data:urlDat];
}

/*
 * + aliasDescriptorWithURL:
 */
+ (NSAppleEventDescriptor *)aliasDescriptorWithURL:(NSURL *)aURL
{
	NSAppleEventDescriptor		* theAppleEventDescriptor = nil;

	NSData *bookData = [aURL bookmarkDataWithOptions:0 includingResourceValuesForKeys:nil relativeToURL:nil error:NULL];
	if( bookData )
	{
		theAppleEventDescriptor = [self descriptorWithDescriptorType:typeBookmarkData data:bookData];
	}

	return theAppleEventDescriptor;
}

// typeBoolean
+ (NSAppleEventDescriptor *)appleEventDescriptorWithBOOL:(BOOL)aValue
{
	return [self descriptorWithDescriptorType:typeBoolean data:[NSData dataWithBytes:&aValue length: sizeof(aValue)]];
}
// typeTrue
+ (NSAppleEventDescriptor *)trueBoolDescriptor
{
	return [self descriptorWithDescriptorType:typeTrue data:[NSData data]];
}
// typeFalse
+ (NSAppleEventDescriptor *)falseBoolDescriptor
{
	return [self descriptorWithDescriptorType:typeFalse data:[NSData data]];
}
// typeShortInteger
+ (NSAppleEventDescriptor *)appleEventDescriptorWithShort:(short int)aValue
{
	return [self descriptorWithDescriptorType:typeSInt16 data:[NSData dataWithBytes:&aValue length: sizeof(aValue)]];
}
// typeLongInteger
+ (NSAppleEventDescriptor *)appleEventDescriptorWithLong:(long long)aValue
{
	return [self descriptorWithDescriptorType:typeSInt64 data:[NSData dataWithBytes:&aValue length: sizeof(aValue)]];
}
// typeInteger
+ (NSAppleEventDescriptor *)appleEventDescriptorWithInt:(int)aValue
{
	return [self descriptorWithDescriptorType:typeSInt32 data:[NSData dataWithBytes:&aValue length: sizeof(aValue)]];
}
// typeShortFloat
+ (NSAppleEventDescriptor *)appleEventDescriptorWithFloat:(float)aValue
{
	return [self descriptorWithDescriptorType:typeIEEE32BitFloatingPoint data:[NSData dataWithBytes:&aValue length: sizeof(aValue)]];
}
// typeLongFloat
+ (NSAppleEventDescriptor *)appleEventDescriptorWithDouble:(double)aValue
{
	return [self descriptorWithDescriptorType:typeIEEE64BitFloatingPoint data:[NSData dataWithBytes:&aValue length: sizeof(aValue)]];
}
// typeMagnitude
+ (NSAppleEventDescriptor *)appleEventDescriptorWithUnsignedInt:(unsigned int)aValue
{
	return [self descriptorWithDescriptorType:typeUInt32 data:[NSData dataWithBytes:&aValue length: sizeof(aValue)]];
}

/*
 * targetProcessSerialNumber
 */
- (ProcessSerialNumber)targetProcessSerialNumber
{
	NSAppleEventDescriptor	* theTarget;
	ProcessSerialNumber		theProcessSerialNumber = { 0, 0 };

	theTarget = [self attributeDescriptorForKeyword:keyAddressAttr];

	if( theTarget )
	{
		if( [theTarget descriptorType] != typeProcessSerialNumber )
			theTarget = [theTarget coerceToDescriptorType:typeProcessSerialNumber];

		[[theTarget data] getBytes:&theProcessSerialNumber length:sizeof(ProcessSerialNumber)];
	}
	return theProcessSerialNumber;
}

- (NSString*)targetProcessBundleIdentifier
{
	//TODO: test/fix!
	NSAppleEventDescriptor	* theTarget;
	NSString		*theProcessBundleID = nil;

	theTarget = [self attributeDescriptorForKeyword:keyAddressAttr];

	if( theTarget )
	{
		if( [theTarget descriptorType] != typeApplicationBundleID )
			theTarget = [theTarget coerceToDescriptorType:typeApplicationBundleID];

		theProcessBundleID = [[NSString alloc] initWithData:[theTarget data] encoding:NSUTF8StringEncoding];
	}
	return theProcessBundleID;
}

/*
 * targetCreator
 */
- (OSType)targetCreator
{
	NSAppleEventDescriptor	* theTarget;
	OSType						theCreator = 0;
	
	theTarget = [self attributeDescriptorForKeyword:keyAddressAttr];
	
	if (theTarget) {
		if ([theTarget descriptorType] != typeApplSignature) {
			theTarget = [theTarget coerceToDescriptorType:typeApplSignature];
		}
		
		theCreator = theTarget.typeCodeValue;
	}
	return theCreator;
}

/*
 * isTargetCurrentProcess
 */
- (BOOL)isTargetCurrentProcess
{
	ProcessSerialNumber		theProcessSerialNumber;

	theProcessSerialNumber = [self targetProcessSerialNumber];

	return theProcessSerialNumber.highLongOfPSN == 0 && theProcessSerialNumber.lowLongOfPSN == kCurrentProcess;
}

@end
