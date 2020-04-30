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


#import <AppKit/AppKit.h>
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

#define ExportObjPosIndex(obj, i) if (obj != nil) { tmpLong = [obj getIndex]; } else { tmpLong = -1; } [myData appendBytes:&tmpLong length:4]
#define ExportObjPos(obj) ExportObjPosIndex(obj, index)
#define ExportObjIndex(obj, i) if (obj != nil) { tmpLong = [(obj) exportWithIndex:(i) withData:futureData mainObjects:mainObjs]; } else { tmpLong = -1; } [myData appendBytes:&tmpLong length:4]
#define ExportObj(obj) ExportObjIndex(obj, index)
#define ExportNil() tmpLong = -1; [myData appendBytes:&tmpLong length:4]

#define ExportShort(v) [myData appendBytes:&v length:2] 
#define ExportLong(v) [myData appendBytes:&v length:4]
#define ExportUnsignedShort(v) [myData appendBytes:&v length:2] 
#define ExportUnsignedLong(v) [myData appendBytes:&v length:4]

#define ExportTag(obj) { short tmpShort = [(obj) getSpecialIndex]; ExportShort(tmpShort); }

//#define ExportBool(v) tmpLong = (long)v; [myData appendBytes:&tmpLong length:4]

// *** *** ***

#define GetIndexAdv(obj) (obj != nil) ? [obj getIndex] : -1

#define FileAttributes(fmngr, path) [(fmngr) fileAttributesAtPath:(path) traverseLink:YES]
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

#define OPEN_SHEET(s, w) ([NSApp beginSheet:(s) modalForWindow:(w) modalDelegate:self didEndSelector:NULL contextInfo:nil])

#define GetTagOfSelected(o) [[(o) selectedCell] tag]
#define SState(o, t) ([[(o) cellWithTag:(t)] state] == NSOnState)
#define SelectS(o, t) ([(o) selectCellWithTag:(t)])

// This will deselect if needed...
#define SelectSIf(o, t, q) ((q) ? ([(o) selectCellWithTag:(t)]) : ([[(o) cellWithTag:(t)] setState:NSOffState]))

#define SetMatrixObjectValue(o, t, n) [[(o) cellWithTag:(t)] setObjectValue:[[NSNumber numberWithShort:(n)] stringValue]];
#define GetMatrixIntValue(o, t) [[(o) cellWithTag:(t)] intValue];

#define SSetEnabled(m, t, v) [[(m) cellWithTag:(t)] setEnabled:(v)]


// Other Usful Data Micro Functions
#define numInt(v)				[NSNumber numberWithInt:(v)]
#define numShort(v)				[NSNumber numberWithShort:(v)]
#define numLong(v)				[NSNumber numberWithLong:(v)]
#define numFloat(v)				[NSNumber numberWithFloat:(v)]
#define numDouble(v)				[NSNumber numberWithDouble:(v)]
#define numUnsignedLong(v)			[NSNumber numberWithUnsignedLong:(v)]
#define numUnsignedShort(v)			[NSNumber numberWithUnsignedShort:(v)]

#define stringFromInt(v)			[numInt(v) stringValue]


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

#define encodeInt(coder, value)			[(coder) encodeBytes:&(value) length:fourBytesCount]
#define encodeShort(coder, value)		[(coder) encodeBytes:&(value) length:twoBytesCount]
#define encodeLong(coder, value)		[(coder) encodeBytes:&(value) length:fourBytesCount]
#define encodeFloat(coder, value)		[(coder) encodeBytes:&(value) length:fourBytesCount]
#define encodeDouble(coder, value)		[(coder) encodeBytes:&(value) length:eightBytesCount]
#define encodeUnsignedLong(coder, value)	[(coder) encodeBytes:&(value) length:fourBytesCount]
#define encodeUnsignedShort(coder, value)	[(coder) encodeBytes:&(value) length:twoBytesCount]
#define encodeObj(coder, value)			[(coder) encodeObject:(value)]
#define encodeConditionalObject(coder, value)	[(coder) encodeConditionalObject:(value)]

#define decodeInt(coder)			(int)*(int *)([(coder) decodeBytesWithReturnedLength:&fourBytesCount])
#define decodeShort(coder)			*(short *)([(coder) decodeBytesWithReturnedLength:&twoBytesCount])
#define decodeLong(coder)			*(long *)([(coder) decodeBytesWithReturnedLength:&fourBytesCount])
#define decodeFloat(coder)			*(float *)([(coder) decodeBytesWithReturnedLength:&fourBytesCount])
#define decodeDouble(coder)			*(double *)([(coder) decodeBytesWithReturnedLength:&eightBytesCount])
#define decodeUnsignedLong(coder)		*(unsigned long *)([(coder) decodeBytesWithReturnedLength:&fourBytesCount])
#define decodeUnsignedShort(coder)		*(unsigned short *)([(coder) decodeBytesWithReturnedLength:&twoBytesCount])
#define decodeObj(coder)			[(coder) decodeObject] // used to be retained!!!
#define decodeObjRetain(coder)			[[(coder) decodeObject] retain]

//encodeBytes:(const void *)address length:(unsigned)numBytes

// Preferences Micro Functions
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

// Undo Stuff...
#define undo                                    [myUndoManager prepareWithInvocationTarget:self]
#define undoWith(t)                             [myUndoManager prepareWithInvocationTarget:(t)]

//Exsamples:

//#define POLYGON_IS_DETACHED_BIT 0x4000
//#define POLYGON_IS_DETACHED(p) ([p getFlag] & POLYGON_IS_DETACHED_BIT)
//#define SET_POLYGON_DETACHED_STATE(p,v) ((v) ? [s setFlag:([s getFlag] | POLYGON_IS_DETACHED_BIT)] : [s setFlag:([s getFlag] & ~POLYGON_IS_DETACHED_BIT)])


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

// *********************** Enums  ***********************

enum
{
    _vm_wire_frame_render_mode = 0,
    _vm_color_render_mode = 1,
    _vm_texture_render_mode = 2
};

enum
{
    _clockwise,
    _counter_clockwise
};

// *********************** EXTERN Variables ***********************
// ********* Notifications *********
extern NSString *PhLevelDeallocatingNotification;
extern NSString *PhUserDidChangePrefs;
extern NSString *PhUserDidChangeNames;
extern NSString *LELevelChangedNotification;
extern NSString *LESelectionChangedNotification;
extern NSString *LEToolChangedNotification;
extern NSString *PhLevelStatusBarUpdate;

// ********* Visual Settings *********
extern NSString *VMKeySpeed;
extern NSString *VMMouseSpeed;
extern NSString *VMInvertMouse;

extern NSString *VMUpKey;
extern NSString *VMDownKey;
extern NSString *VMLeftKey;
extern NSString *VMRightKey;
extern NSString *VMForwardKey;
extern NSString *VMBackwardKey;
extern NSString *VMSlideLeftKey;
extern NSString *VMSlideRightKey;

extern NSString *VMCeilingColor;
extern NSString *VMFloorColor;
extern NSString *VMWallColor;
extern NSString *VMLiquidColor;
extern NSString *VMTransparentColor;
extern NSString *VMLandscapeColor;
extern NSString *VMInvalidSurfaceColor;
extern NSString *VMWireFrameLineColor;
extern NSString *VMBackGroundColor;


extern NSString *VMShapesPath;
extern NSString *VMRenderMode;
extern NSString *VMStartPosition;

extern NSString *VMShowLiquids;
extern NSString *VMShowTransparent;
extern NSString *VMShowLandscapes;
extern NSString *VMShowInvalid;
extern NSString *VMShowObjects;

extern NSString *VMLiquidsTransparent;
extern NSString *VMUseFog;
extern NSString *VMFogDepth;

extern NSString *VMSmoothRendering;

extern NSString *VMUseLighting;
extern NSString *VMWhatLighting;

extern NSString *VMPlatformState;
extern NSString *VMVisibleSide;
extern NSString *VMVerticalLook;
extern NSString *VMFieldOfView;
extern NSString *VMVisibilityMode;

// ********* Default Layer Settings *********
extern NSString *PhDefaultLayers;
extern NSString *PhDefaultLayer_Name;
extern NSString *PhDefaultLayer_FloorMin;
extern NSString *PhDefaultLayer_FloorMax;
extern NSString *PhDefaultLayer_CeilingMin;
extern NSString *PhDefaultLayer_CeilingMax;

// ********* General Settings *********
extern NSString *PhEnableAntialiasing;
extern NSString *PhEnableObjectOutling;
extern NSString *PhDrawOnlyLayerPoints;
extern NSString *PhSelectObjectWhenCreated;
extern NSString *PhSplitPolygonLines;
extern NSString *PhSplitNonPolygonLines;
extern NSString *PhSnapToLines;
extern NSString *PhSnapObjectsToGrid;
extern NSString *PhSnapToGridBool;
extern NSString *PhSnapToPoints;
extern NSString *PhSnapToPointsLength;

extern NSString *PhUseRightAngleSnap;
extern NSString *PhUseIsometricAngleSnap;
extern NSString *PhSnapFromPoints;
extern NSString *PhSnapFromLength;

// ********* Object Type Visability Settings *********
extern NSString *PhEnableObjectItem;
extern NSString *PhEnableObjectPlayer;
extern NSString *PhEnableObjectEnemyMonster;
extern NSString *PhEnableObjectSceanry;
extern NSString *PhEnableObjectSound;
extern NSString *PhEnableObjectGoal;

// ********* Polygon Color Visability Settings *********
extern NSString *PhEnablePlatfromPolyColoring;
extern NSString *PhEnableConvexPolyColoring;
extern NSString *PhEnableZonePolyColoring;
extern NSString *PhEnableTeleporterExitPolyColoring;
extern NSString *PhEnableHillPolyColoring;

// ********* Grid Settings *********
extern NSString *PhGridFactor;
extern NSString *PhEnableGridBool;

// ********* Current Phorge Information *********

extern int currentVersionOfPfhorgeLevelData;

extern NSString *currentPhorgeVersion; // = @"0.3.0 alpha";

extern NSString *PhPrefVersion; // = @"PhPrefVersion";
extern NSString *PhPhorgePrefVersion; // = @"PhPhorgePrefVersion";
extern NSString *PhPhorgeColors; // = @"PhPhorgeColors";

// ********* PhPhorgeColors Strings *********
extern NSString *PhPolygonRegularColor; // = @"PhPolygonRegularColor";
extern NSString *PhPolygonSelectedColor; // = @"PhPolygonSelectedColor";
extern NSString *PhPolygonPlatformColor; // = @"PhPolygonPlatformColor";
extern NSString *PhPolygonNonConcaveColor; // = @"PhPolygonNonConcaveColor";
extern NSString *PhPolygonTeleporterColor;
extern NSString *PhPolygonZoneColor;
extern NSString *PhPolygonHillColor;

extern NSString *PhLineRegularColor; // = @"PhLineRegularColor";
extern NSString *PhLineSelectedColor; // = @"PhLineSelectedColor";
extern NSString *PhLineConnectsPolysColor; // = @"PhLineConnectsPolysColor";

extern NSString *PhPointRegularColor; // = @"PhPointRegularColor";
extern NSString *PhPointSelectedColor; // = @"PhPointSelectedColor";

extern NSString *PhObjectSelectedColor; // = @"PhObjectSelectedColor";
extern NSString *PhObjectItemColor; // = @"PhObjectItemColor";
extern NSString *PhObjectPlayerColor; // = @"PhObjectPlayerColor";
extern NSString *PhObjectFriendlyMonsterColor; // = @"PhObjectFriendlyMonsterColor";
extern NSString *PhObjectNeutralMonsterColor; // = @"PhObjectNeutralMonsterColor";
extern NSString *PhObjectEnemyMonsterColor; // = @"PhObjectEnemyMonsterColor";
extern NSString *PhObjectSceanryColor; // = @"PhObjectSceanryColor";
extern NSString *PhObjectSoundColor; // = @"PhObjectSoundColor";
extern NSString *PhObjectGoalColor; // = @"PhObjectGoalColor";

extern NSString *PhObjectBLineSelectedColor; // = @"PhObjectBLineSelectedColor";
extern NSString *PhObjectBLineItemColor; // = @"PhObjectBLineItemColor";
extern NSString *PhObjectBLinePlayerColor; // = @"PhObjectBLinePlayerColor";
extern NSString *PhObjectBLineFriendlyMonsterColor; // = @"PhObjectBLineFriendlyMonsterColor";
extern NSString *PhObjectBLineNeutralMonsterColor; // = @"PhObjectBLineNeutralMonsterColor";
extern NSString *PhObjectBLineEnemyMonsterColor; // = @"PhObjectBLineEnemyMonsterColor";
extern NSString *PhObjectBLineSceanryColor; // = @"PhObjectBLineSceanryColor";
extern NSString *PhObjectBLineSoundColor; // = @"PhObjectBLineSoundColor";
extern NSString *PhObjectBLineGoalColor; // = @"PhObjectBLineGoalColor";

extern NSString *PhBackgroundColor; // = @"PhBackgroundColor";
extern NSString *PhWorldUnitGridColor; // = @"PhWorldUnitGridColor";
extern NSString *PhSubWorldUnitGridColor; // = @"PhSubWorldUnitGridColor";
extern NSString *PhCenterWorldUnitGridColor;
// *********************** End EXTERN Variables ***********************

