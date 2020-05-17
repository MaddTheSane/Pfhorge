//
//  LEExtras.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Jun 18 2001.
//  Copyright (c) 2001 Joshua D. Orr. All rights reserved.
//  
//  E-Mail:   dragons@xmission.com
//  
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//  or you can read it by running the program and selecting Phorge->About Phorge


#import <Cocoa/Cocoa.h>
#import "ErrorNotificationWinController.h"
#import "NDAppleScriptObject.h"
#import "NSAppleEventDescriptor+NDAppleScriptObject.h"

/*extern unsigned twoBytesCount;
extern unsigned fourBytesCount;
extern unsigned eightBytesCount;*/


//getObjectFromIndexUsingLast

//#define useDebugingLogs

#define notContain(arr, obj) [(arr) indexOfObjectIdenticalTo:(obj)] == NSNotFound
#define contains(arr, obj) [(arr) indexOfObjectIdenticalTo:(obj)] != NSNotFound

#define ImportTag(objp) objp = [self getTagForNumber:[myData getShort]]

#define ImportObjIndexPos(objp, i) objp = [myData getObjectFromIndexUsingLast:(i)]
//#define ImportObjPos(objp) objp = [myData getObjectFromIndex:index]
#define ImportObjIndex(objp, i) objp = [myData getObjectFromIndex:(i) objTypesArr:objTypesArr]
#define ImportObj(objp) objp = [myData getObjectFromIndex:index objTypesArr:objTypesArr]
#define ImportShort(v) v = [myData getShort]
#define ImportLong(v) v = [myData getLong]
#define ImportInt(v) v = [myData getInt]
#define ImportUnsignedShort(v) v = [myData getUnsignedShort]
#define ImportUnsignedInt(v) v = [myData getUnsignedInt]
#define ImportUnsignedLong(v) v = [myData getUnsignedLong]

#define SkipObj() [myData skipObj]

//#define ImportBool(v) v = [myData getBool]

// *** *** ***

#define ExportObjPosIndex(obj, i) if (obj != nil) { tmpLong = [obj index]; } else { tmpLong = -1; } saveIntToNSData((int)tmpLong, myData)
#define ExportObjPos(obj) ExportObjPosIndex(obj, index)
#define ExportObjIndex(obj, i) if (obj != nil) { tmpLong = [(obj) exportWithIndex:(i) withData:futureData mainObjects:mainObjs]; } else { tmpLong = -1; } saveIntToNSData((int)tmpLong, myData)
#define ExportObj(obj) ExportObjIndex(obj, index)
#define ExportNil() tmpLong = -1; [myData appendBytes:&tmpLong length:4]

#define ExportShort(v) saveShortToNSData(v, myData)
#define ExportLong(v) saveIntToNSData(v, myData)
#define ExportUnsignedShort(v) saveShortToNSData(v, myData)
#define ExportUnsignedLong(v) saveIntToNSData(v, myData)

#define ExportTag(obj) { short tmpShort = [(obj) getSpecialIndex]; ExportShort(tmpShort); }

//#define ExportBool(v) tmpLong = (long)v; [myData appendBytes:&tmpLong length:4]

// *** *** ***

#define GetIndexAdv(obj) (obj != nil) ? [(LEMapStuffParent*)(obj) index] : -1

#define FileAttributes(fmngr, path) [(fmngr) attributesOfItemAtPath:(path) error:NULL]
#define IsPathDirectory(fmngr, path) [[FileAttributes(fmngr, path) fileType] isEqualToString:NSFileTypeDirectory]

#define Antialiasing_ON YES

#define SEND_ERROR() ([[ErrorNotificationWinController sharedErrorController] standardGenericError])
#define SEND_ERROR_MSG(m) ([[ErrorNotificationWinController sharedErrorController] standardGenericErrorMsg:(m)])
#define SEND_ERROR_MSG_TITLE(m, t) ([[ErrorNotificationWinController sharedErrorController] standardGenericErrorMsg:(m) title:(t)])
#define _SEND_ERROR_MSG_TITLE(m, t) (SEND_ERROR_MSG_TITLE(m, t))


#define SEND_INFO_MSG_TITLE(m, t) ([[ErrorNotificationWinController sharedErrorController] standardInfoMsg:(m) title:(t)])

#define GETI_FLAG(i, b) ((i) & (b))
#define SETI_FLAG(i, b, v) ((v) ? ((i) |= (b)) : ((i) &= ~(b))

#define GET_SELF_FLAG(b) (flags & (b))
#define SET_SELF_FLAG(b, v) ((v) ? (flags |= (b)) : (flags &= ~(b)))

#define GET_OBJECT_FLAG(o, b) ([(o) getFlags] & (b))
#define SET_OBJECT_FLAG(o, b, v) ((v) ? [(o) setFlags:([(o) getFlags] | (b))] : [(o) setFlags:([(o) getFlags] & ~(b))])

#define GET_OBJECTNUM_FLAG(o, b, f) ([(o) getFlag:(f)] & (b))
#define SET_OBJECTNUM_FLAG(o, b, v, f) ((v) ? [(o) setFlag:(f) with:([(o) getFlag] | (b))] : [(o) setFlag:(f) with:([(o) getFlag] & ~(b))])

#define GetTagOfSelected(o) [[(o) selectedCell] tag]
#define SState(o, t) ([[(o) cellWithTag:(t)] state] == NSOnState)
#define SelectS(o, t) ([(o) selectCellWithTag:(t)])

// This will deselect if needed...
#define SelectSIf(o, t, q) ((q) ? ([(o) selectCellWithTag:(t)]) : ([[(o) cellWithTag:(t)] setState:NSOffState]))

#define SetMatrixObjectValue(o, t, n) [[(o) cellWithTag:(t)] setObjectValue:[[NSNumber numberWithShort:(n)] stringValue]];
#define GetMatrixIntValue(o, t) [[(o) cellWithTag:(t)] intValue];

#define SSetEnabled(m, t, v) [[(m) cellWithTag:(t)] setEnabled:(v)]


#pragma mark Other Usful Data Micro Functions
#define numInt(v)				[NSNumber numberWithInt:(v)]
#define numInteger(v)			[NSNumber numberWithInteger:(v)]
#define numShort(v)				[NSNumber numberWithShort:(v)]
#define numLong(v)				[NSNumber numberWithLong:(v)]
#define numFloat(v)				[NSNumber numberWithFloat:(v)]
#define numDouble(v)				[NSNumber numberWithDouble:(v)]
#define numUnsignedLong(v)			[NSNumber numberWithUnsignedLong:(v)]
#define numUnsignedShort(v)			[NSNumber numberWithUnsignedShort:(v)]

#define stringFromInt(v)			[numInt(v) stringValue]
#define stringFromInteger(v)		[numInteger(v) stringValue]


#define encodeNumInt(coder, value)		[(coder) encodeObject:numInt(value)]
#define encodeNumShort(coder, value)		[(coder) encodeObject:numShort(value)]
/*#define encodeLong(coder, value)		[(coder) encodeObject:numLong(value)]
#define encodeFloat(coder, value)		[(coder) encodeObject:numFloat(value)]
#define encodeDouble(coder, value)		[(coder) encodeObject:numDouble(value)]
#define encodeUnsignedLong(coder, value)	[(coder) encodeObject:numUnsignedLong(value)]
#define encodeUnsignedShort(coder, value)	[(coder) encodeObject:numUnsignedShort(value)]
#define encodeObj(coder, value)			[(coder) encodeObject:(value)]*/
#define encodeBOOL(coder, value)		encodeNumInt(coder, ((value) ? 1 : 0))

#define decodeNumInt(coder)			[[(coder) decodeObject] intValue]
#define decodeNumShort(coder)			[[(coder) decodeObject] shortValue]
/*#define decodeLong(coder)			[[(coder) decodeObject] longValue]
#define decodeFloat(coder)			[[(coder) decodeObject] floatValue]
#define decodeDouble(coder)			[[(coder) decodeObject] doubleValue]
#define decodeUnsignedLong(coder)		[[(coder) decodeObject] unsignedLongValue]
#define decodeUnsignedShort(coder)		[[(coder) decodeObject] unsignedShortValue]
#define decodeObj(coder)			[[(coder) decodeObject] retain]*/
#define decodeBOOL(coder)			((decodeNumInt(coder) == 1) ? YES : NO)

#if __BIG_ENDIAN__
#define encodeInt(coder, value)			[(coder) encodeBytes:&(value) length:fourBytesCount]
#define encodeShort(coder, value)		[(coder) encodeBytes:&(value) length:twoBytesCount]
#define encodeLong(coder, value)		[(coder) encodeBytes:&(value) length:fourBytesCount]
#define encodeFloat(coder, value)		[(coder) encodeBytes:&(value) length:fourBytesCount]
#define encodeDouble(coder, value)		[(coder) encodeBytes:&(value) length:eightBytesCount]
#define encodeUnsignedLong(coder, value)	[(coder) encodeBytes:&(value) length:fourBytesCount]
#define encodeUnsignedShort(coder, value)	[(coder) encodeBytes:&(value) length:twoBytesCount]
#else
static inline void encodeInt(NSCoder *coder, int value)
{
	value = CFSwapInt32BigToHost(value);
	[coder encodeBytes:&(value) length:sizeof(int)];
}
static inline void encodeShort(NSCoder *coder, short value)
{
	value = CFSwapInt16BigToHost(value);
	[coder encodeBytes:&(value) length:sizeof(short)];
}
#define encodeLong		encodeInt
static inline void encodeFloat(NSCoder *coder, float value)
{
	union Swap {
		float v;
		uint32_t sv;
	} result;
	result.v = value;
	result.sv = CFSwapInt32BigToHost(result.sv);
	[coder encodeBytes:&(result.v) length:sizeof(float)];
}
static inline void encodeDouble(NSCoder *coder, double value)
{
	union Swap {
		double v;
		uint64_t sv;
	} result;
	result.v = value;
	result.sv = CFSwapInt64BigToHost(result.sv);
	[coder encodeBytes:&(result.v) length:sizeof(double)];
}
static inline void encodeUnsignedLong(NSCoder *coder, unsigned int value)
{
	value = CFSwapInt32BigToHost(value);
	[coder encodeBytes:&(value) length:sizeof(int)];
}
static inline void encodeUnsignedShort(NSCoder *coder, unsigned short value)
{
	value = CFSwapInt16BigToHost(value);
	[coder encodeBytes:&(value) length:sizeof(unsigned short)];
}
#endif
#define encodeObj(coder, value)			[(coder) encodeObject:(value)]
#define encodeConditionalObject(coder, value)	[(coder) encodeConditionalObject:(value)]

#if __BIG_ENDIAN__
#define decodeInt(coder)			(int)*(int *)([(coder) decodeBytesWithReturnedLength:&fourBytesCount])
#define decodeShort(coder)			*(short *)([(coder) decodeBytesWithReturnedLength:&twoBytesCount])
#define decodeLong(coder)			*(long *)([(coder) decodeBytesWithReturnedLength:&fourBytesCount])
#define decodeFloat(coder)			*(float *)([(coder) decodeBytesWithReturnedLength:&fourBytesCount])
#define decodeDouble(coder)			*(double *)([(coder) decodeBytesWithReturnedLength:&eightBytesCount])
#define decodeUnsignedInt(coder)            (unsigned int)*(unsigned int*)([(coder) decodeBytesWithReturnedLength:&fourBytesCount])
#define decodeUnsignedLong(coder)		*(unsigned long *)([(coder) decodeBytesWithReturnedLength:&fourBytesCount])
#define decodeUnsignedShort(coder)		*(unsigned short *)([(coder) decodeBytesWithReturnedLength:&twoBytesCount])
#else
static inline int decodeInt(NSCoder *coder)
{
	NSUInteger fourBytesCount = 4;
	int value = (int)*(int *)([coder decodeBytesWithReturnedLength:&fourBytesCount]);
	return CFSwapInt32BigToHost(value);
}
static inline short decodeShort(NSCoder *coder)
{
	NSUInteger twoBytesCount = 2;
	short value = *(short *)([coder decodeBytesWithReturnedLength:&twoBytesCount]);
	return CFSwapInt16BigToHost(value);
}
#define decodeLong			decodeInt
static inline float decodeFloat(NSCoder *coder)
{
	NSUInteger fourBytesCount = 4;
	union Swap {
		float v;
		uint32_t sv;
	} result;
	result.sv = *(uint32_t *)([coder decodeBytesWithReturnedLength:&fourBytesCount]);
	result.sv = CFSwapInt32BigToHost(result.sv);
	return result.v;
}
static inline double decodeDouble(NSCoder *coder)
{
	NSUInteger eightBytesCount = 8;
	union Swap {
		double v;
		uint64_t sv;
	} result;
	result.sv = *(uint64_t *)([coder decodeBytesWithReturnedLength:&eightBytesCount]);
	result.sv = CFSwapInt64BigToHost(result.sv);
	return result.v;
}
static inline unsigned int decodeUnsignedInt(NSCoder *coder)
{
	NSUInteger fourBytesCount = 4;;
	unsigned int value = *(unsigned int*)([coder decodeBytesWithReturnedLength:&fourBytesCount]);
	return CFSwapInt32BigToHost(value);
}
#define decodeUnsignedLong		decodeUnsignedInt
static inline unsigned short decodeUnsignedShort(NSCoder *coder)
{
	NSUInteger twoBytesCount = 2;
	unsigned short value = *(unsigned short *)([(coder) decodeBytesWithReturnedLength:&twoBytesCount]);
	return CFSwapInt16BigToHost(value);
}
#endif
#define decodeObj(coder)			[(coder) decodeObject] // used to be retained!!!
#if __has_feature(objc_arc)
#define decodeObjRetain(coder)			[(coder) decodeObject]
#else
#define decodeObjRetain(coder)			[[(coder) decodeObject] retain]
#endif

//encodeBytes:(const void *)address length:(unsigned)numBytes

#pragma mark Preferences Micro Functions
#define preferences 				[NSUserDefaults standardUserDefaults]
#define prefBool(key)				[preferences boolForKey:(key)]
#define archive(Obj) 				[NSKeyedArchiver archivedDataWithRootObject:(Obj)]
static inline id unarchive(NSData *Obj) {
    id outObj = [NSKeyedUnarchiver unarchiveObjectWithData:Obj];
    if (outObj) {
        return outObj;
    }
    return [NSUnarchiver unarchiveObjectWithData:Obj];
}
#define prefColor(colorKey) 			[preferences objectForKey:(colorKey)]
#define prefSetColor(colorKey, colorValue) 	[preferences setObject:(colorValue) forKey:(colorKey)]
#define getArchColor(colorKey) 			unarchive(prefColor(colorKey))
#define setArchColor(colorKey, colorValue) 	prefSetColor((colorKey), (archive(colorValue)))
#define activateArchColor(colorKey) 		[(NSColor*)unarchive(prefColor(colorKey)) set]
#define archColorWithAlpha(colorKey, alpha) 	[[getArchColor(colorKey) colorWithAlphaComponent:(alpha)] set];

#pragma mark Undo Stuff...
#define undo                                    [myUndoManager prepareWithInvocationTarget:self]
#define undoWith(t)                             [myUndoManager prepareWithInvocationTarget:(t)]

//Examples:

//#define POLYGON_IS_DETACHED_BIT 0x4000
//#define POLYGON_IS_DETACHED(p) ([p getFlag] & POLYGON_IS_DETACHED_BIT)
//#define SET_POLYGON_DETACHED_STATE(p,v) ((v) ? [s setFlag:([s getFlag] | POLYGON_IS_DETACHED_BIT)] : [s setFlag:([s getFlag] & ~POLYGON_IS_DETACHED_BIT)])


#define saveShortToNSData(_number, _y) {short hi = CFSwapInt16HostToBig(_number); [(_y) appendBytes:&hi length:2];}
#define saveIntToNSData(_x, _y) {int hi = CFSwapInt32HostToBig(_x); [(_y) appendBytes:&hi length:4];}

static inline short loadShortFromNSData(NSData *dat, NSInteger offset)
{
	short type;
	[dat getBytes:&type range:NSMakeRange(offset, 2)];
	return CFSwapInt16BigToHost(type);
}

static inline int loadIntFromNSData(NSData *dat, NSInteger offset)
{
	int type;
	[dat getBytes:&type range:NSMakeRange(offset, 4)];
	return CFSwapInt32BigToHost(type);
}

@interface NSObject (LEExtras)

- (void)performSelector:(SEL)sel withEachObjectInArray:(NSArray *)array;
- (void)performSelector:(SEL)sel withEachObjectInSet:(NSSet *)set;
// *********************** Utilites ***********************
- (void)setEnabledOfMatrixCellsTo:(BOOL)v;

@end

@interface SendTarget : NSObject <NDAppleScriptObjectSendEvent, NDAppleScriptObjectActive>
{
	NDAppleScriptObject		* appleScriptObject;
	unsigned int				OK_Enough;
}
+ (id)sendTargetWithAppleScriptObject:(NDAppleScriptObject *)anObject;
@end

NSRect LERectFromPoints(NSPoint point1, NSPoint point2);
NSPoint LEAddToPoint(NSPoint point1, float theSum);
void createAndExecuteScriptObject( NSString * aPath );

//int LECompareLines(id line1, id line2, NSPoint thePoint);
//int LEDistanceOfLine(NSRect theBoundsOfLine);

#pragma mark Enums

enum
{
    _vm_wire_frame_render_mode = 0,
    _vm_color_render_mode = 1,
    _vm_texture_render_mode = 2
};

typedef NS_ENUM(int, LESideDirection)
{
    _clockwise,
    _counter_clockwise
};

#pragma mark - EXTERN Variables
#pragma mark Notifications
extern NSNotificationName const PhLevelDeallocatingNotification;
extern NSNotificationName const PhUserDidChangePreferencesNotification;
extern NSNotificationName const PhUserDidChangeNamesNotification;
extern NSNotificationName const LELevelChangedNotification;
extern NSNotificationName const LESelectionChangedNotification;
extern NSNotificationName const LEToolChangedNotification;
extern NSNotificationName const PhLevelStatusBarUpdateNotification;

#pragma mark Visual Settings
extern NSString *const VMKeySpeed;
extern NSString *const VMMouseSpeed;
extern NSString *const VMInvertMouse;

extern NSString *const VMUpKey;
extern NSString *const VMDownKey;
extern NSString *const VMLeftKey;
extern NSString *const VMRightKey;
extern NSString *const VMForwardKey;
extern NSString *const VMBackwardKey;
extern NSString *const VMSlideLeftKey;
extern NSString *const VMSlideRightKey;

extern NSString *const VMCeilingColor;
extern NSString *const VMFloorColor;
extern NSString *const VMWallColor;
extern NSString *const VMLiquidColor;
extern NSString *const VMTransparentColor;
extern NSString *const VMLandscapeColor;
extern NSString *const VMInvalidSurfaceColor;
extern NSString *const VMWireFrameLineColor;
extern NSString *const VMBackGroundColor;


extern NSString *const VMShapesPath;
extern NSString *const VMRenderMode;
extern NSString *const VMStartPosition;

extern NSString *const VMShowLiquids;
extern NSString *const VMShowTransparent;
extern NSString *const VMShowLandscapes;
extern NSString *const VMShowInvalid;
extern NSString *const VMShowObjects;

extern NSString *const VMLiquidsTransparent;
extern NSString *const VMUseFog;
extern NSString *const VMFogDepth;

extern NSString *const VMSmoothRendering;

extern NSString *const VMUseLighting;
extern NSString *const VMWhatLighting;

extern NSString *const VMPlatformState;
extern NSString *const VMVisibleSide;
extern NSString *const VMVerticalLook;
extern NSString *const VMFieldOfView;
extern NSString *const VMVisibilityMode;

#pragma mark Default Layer Settings
extern NSString *const PhDefaultLayers;
extern NSString *const PhDefaultLayer_Name;
extern NSString *const PhDefaultLayer_FloorMin;
extern NSString *const PhDefaultLayer_FloorMax;
extern NSString *const PhDefaultLayer_CeilingMin;
extern NSString *const PhDefaultLayer_CeilingMax;

#pragma mark General Settings
extern NSString *const PhEnableAntialiasing;
extern NSString *const PhEnableObjectOutling;
extern NSString *const PhDrawOnlyLayerPoints;
extern NSString *const PhSelectObjectWhenCreated;
extern NSString *const PhSplitPolygonLines;
extern NSString *const PhSplitNonPolygonLines;
extern NSString *const PhSnapToLines;
extern NSString *const PhSnapObjectsToGrid;
extern NSString *const PhSnapToGridBool;
extern NSString *const PhSnapToPoints;
extern NSString *const PhSnapToPointsLength;

extern NSString *const PhUseRightAngleSnap;
extern NSString *const PhUseIsometricAngleSnap;
extern NSString *const PhSnapFromPoints;
extern NSString *const PhSnapFromLength;

#pragma mark Object Type Visability Settings
extern NSString *const PhEnableObjectItem;
extern NSString *const PhEnableObjectPlayer;
extern NSString *const PhEnableObjectEnemyMonster;
extern NSString *const PhEnableObjectSceanry;
extern NSString *const PhEnableObjectSound;
extern NSString *const PhEnableObjectGoal;

#pragma mark Polygon Color Visability Settings
extern NSString *const PhEnablePlatfromPolyColoring;
extern NSString *const PhEnableConvexPolyColoring;
extern NSString *const PhEnableZonePolyColoring;
extern NSString *const PhEnableTeleporterExitPolyColoring;
extern NSString *const PhEnableHillPolyColoring;

#pragma mark Grid Settings
extern NSString *const PhGridFactor;
extern NSString *const PhEnableGridBool;

#pragma mark Current Phorge Information

//! Version that used questionable use of NSArchiver
extern const short oldVersionOfPfhorgeLevelData;

extern const short currentVersionOfPfhorgeLevelData;

extern NSString *const PhPrefVersion; // = @"PhPrefVersion";
extern NSString *const PhPhorgePrefVersion; // = @"PhPhorgePrefVersion";
extern NSString *const PhPhorgeColors; // = @"PhPhorgeColors";

#pragma mark PhPhorgeColors Strings
extern NSString *const PhPolygonRegularColor; // = @"PhPolygonRegularColor";
extern NSString *const PhPolygonSelectedColor; // = @"PhPolygonSelectedColor";
extern NSString *const PhPolygonPlatformColor; // = @"PhPolygonPlatformColor";
extern NSString *const PhPolygonNonConcaveColor; // = @"PhPolygonNonConcaveColor";
extern NSString *const PhPolygonTeleporterColor;
extern NSString *const PhPolygonZoneColor;
extern NSString *const PhPolygonHillColor;

extern NSString *const PhLineRegularColor; // = @"PhLineRegularColor";
extern NSString *const PhLineSelectedColor; // = @"PhLineSelectedColor";
extern NSString *const PhLineConnectsPolysColor; // = @"PhLineConnectsPolysColor";

extern NSString *const PhPointRegularColor; // = @"PhPointRegularColor";
extern NSString *const PhPointSelectedColor; // = @"PhPointSelectedColor";

extern NSString *const PhObjectSelectedColor; // = @"PhObjectSelectedColor";
extern NSString *const PhObjectItemColor; // = @"PhObjectItemColor";
extern NSString *const PhObjectPlayerColor; // = @"PhObjectPlayerColor";
extern NSString *const PhObjectFriendlyMonsterColor; // = @"PhObjectFriendlyMonsterColor";
extern NSString *const PhObjectNeutralMonsterColor; // = @"PhObjectNeutralMonsterColor";
extern NSString *const PhObjectEnemyMonsterColor; // = @"PhObjectEnemyMonsterColor";
extern NSString *const PhObjectSceanryColor; // = @"PhObjectSceanryColor";
extern NSString *const PhObjectSoundColor; // = @"PhObjectSoundColor";
extern NSString *const PhObjectGoalColor; // = @"PhObjectGoalColor";

extern NSString *const PhObjectBLineSelectedColor; // = @"PhObjectBLineSelectedColor";
extern NSString *const PhObjectBLineItemColor; // = @"PhObjectBLineItemColor";
extern NSString *const PhObjectBLinePlayerColor; // = @"PhObjectBLinePlayerColor";
extern NSString *const PhObjectBLineFriendlyMonsterColor; // = @"PhObjectBLineFriendlyMonsterColor";
extern NSString *const PhObjectBLineNeutralMonsterColor; // = @"PhObjectBLineNeutralMonsterColor";
extern NSString *const PhObjectBLineEnemyMonsterColor; // = @"PhObjectBLineEnemyMonsterColor";
extern NSString *const PhObjectBLineSceanryColor; // = @"PhObjectBLineSceanryColor";
extern NSString *const PhObjectBLineSoundColor; // = @"PhObjectBLineSoundColor";
extern NSString *const PhObjectBLineGoalColor; // = @"PhObjectBLineGoalColor";

extern NSString *const PhBackgroundColor; // = @"PhBackgroundColor";
extern NSString *const PhWorldUnitGridColor; // = @"PhWorldUnitGridColor";
extern NSString *const PhSubWorldUnitGridColor; // = @"PhSubWorldUnitGridColor";
extern NSString *const PhCenterWorldUnitGridColor;

#pragma mark Terminal Keys
extern NSAttributedStringKey const PhTerminalBoldAttributeName NS_SWIFT_NAME(PhTerminalBold);
extern NSAttributedStringKey const PhTerminalColorAttributeName NS_SWIFT_NAME(PhTerminalColor);
extern NSAttributedStringKey const PhTerminalItalicAttributeName NS_SWIFT_NAME(PhTerminalItalic);

#pragma mark Pasteboard types
extern NSPasteboardType const PhorgeSelectionDataPasteboardType NS_SWIFT_NAME(PhorgeSelectionData);

// *********************** End EXTERN Variables ***********************

