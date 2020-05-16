//
//  LEExtras.m
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

#import <Foundation/Foundation.h>
#import "LEExtras.h"
#import "LELine.h"
#import "NDAppleScriptObject.h"
#import "NSAppleEventDescriptor+NDAppleScriptObject.h"

/*unsigned twoBytesCoun = 2;
unsigned fourBytesCount = 4;
unsigned eightBytesCount = 8;*/

// *********************** EXTERN Variables ***********************
// ********* Notifications *********
NSString *const PhLevelDeallocatingNotification = @"PhLevelDeallocatingNotification";
NSString *const PhUserDidChangePreferencesNotification = @"PhUserDidChangePref";
NSString *const PhUserDidChangeNamesNotification = @"PhUserDidChangeName";
NSString *const LELevelChangedNotification = @"LELevelChangedNotification";
NSString *const LESelectionChangedNotification = @"LESelectionChangedNotification";
NSString *const LEToolChangedNotification = @"LEToolChangedNotification";
NSString *const PhLevelStatusBarUpdateNotification = @"PhLevelStatusBarUpdate";

// ********* Visual Settings *********
NSString *const VMKeySpeed = @"VMKeySpeed";
NSString *const VMMouseSpeed = @"VMMouseSpeed";
NSString *const VMInvertMouse = @"VMInvertMouse";

NSString *const VMUpKey = @"VMUpKey";
NSString *const VMDownKey = @"VMDownKey";
NSString *const VMLeftKey = @"VMLeftKey";
NSString *const VMRightKey = @"VMRightKey";
NSString *const VMForwardKey = @"VMForwardKey";
NSString *const VMBackwardKey = @"VMBackwardKey";
NSString *const VMSlideLeftKey = @"VMSlideLeftKey";
NSString *const VMSlideRightKey = @"VMSlideRightKey";

NSString *const VMCeilingColor = @"VMCeilingColor";
NSString *const VMFloorColor = @"VMFloorColor";
NSString *const VMWallColor = @"VMWallColor";
NSString *const VMLiquidColor = @"VMLiquidColor";
NSString *const VMTransparentColor = @"VMTransparentColor";
NSString *const VMLandscapeColor = @"VMLandscapeColor";
NSString *const VMInvalidSurfaceColor = @"VMInvalidSurfaceColor";
NSString *const VMWireFrameLineColor = @"VMWireFrameLineColor";
NSString *const VMBackGroundColor = @"VMBackGroundColor";


NSString *const VMShapesPath = @"VMShapesPath";
NSString *const VMRenderMode = @"VMRenderMode";
NSString *const VMStartPosition = @"VMStartPosition";

NSString *const VMShowLiquids = @"VMShowLiquids";
NSString *const VMShowTransparent = @"VMShowTransparent";
NSString *const VMShowLandscapes = @"VMShowLandscapes";
NSString *const VMShowInvalid = @"VMShowInvalid";
NSString *const VMShowObjects = @"VMShowObjects";

NSString *const VMLiquidsTransparent = @"VMLiquidsTransparent";
NSString *const VMUseFog = @"VMUseFog";
NSString *const VMFogDepth = @"VMFogDepth";

NSString *const VMSmoothRendering = @"VMSmoothRendering";

NSString *const VMUseLighting = @"VMUseLighting";
NSString *const VMWhatLighting = @"VMWhatLighting";

NSString *const VMPlatformState = @"VMPlatformState";
NSString *const VMVisibleSide = @"VMVisibleSide";
NSString *const VMVerticalLook = @"VMVerticalLook";
NSString *const VMFieldOfView = @"VMFieldOfView";
NSString *const VMVisibilityMode = @"VMVisibilityMode";

// ********* Default Layer Settings *********
NSString *const PhDefaultLayers = @"PhDefaultLayers";
NSString *const PhDefaultLayer_Name = @"Name";
NSString *const PhDefaultLayer_FloorMin = @"Floor Min";
NSString *const PhDefaultLayer_FloorMax = @"Floor Max";
NSString *const PhDefaultLayer_CeilingMin = @"Ceiling Min";
NSString *const PhDefaultLayer_CeilingMax = @"Ceiling Max";

// ********* General Settings *********
NSString *const PhEnableAntialiasing = @"PhEnableAntialiasing";
NSString *const PhEnableObjectOutling = @"PhEnableObjectOutling";
NSString *const PhDrawOnlyLayerPoints = @"PhDrawOnlyLayerPoints";
NSString *const PhSelectObjectWhenCreated = @"PhSelectObjectWhenCreated";
NSString *const PhSplitPolygonLines = @"PhSplitPolygonLines";
NSString *const PhSplitNonPolygonLines = @"PhSplitNonPolygonLines";
NSString *const PhSnapToLines = @"PhSnapToLines";
NSString *const PhSnapToPoints = @"PhSnapToPoints";
NSString *const PhSnapObjectsToGrid = @"PhSnapObjectsToGrid";
NSString *const PhSnapToGridBool = @"PhSnapToGridBool";
NSString *const PhSnapToPointsLength = @"PhSnapToPointsLength";

NSString *const PhUseRightAngleSnap = @"PhUseRightAngleSnap";
NSString *const PhUseIsometricAngleSnap = @"PhUseIsometricAngleSnap";
NSString *const PhSnapFromPoints = @"PhSnapFromPoints";
NSString *const PhSnapFromLength = @"PhSnapFromLength";

// ********* Object Type Visability Settings *********
NSString *const PhEnableObjectItem = @"PhEnableObjectItem";
NSString *const PhEnableObjectPlayer = @"PhEnableObjectPlayer";
NSString *const PhEnableObjectEnemyMonster = @"PhEnableObjectEnemyMonster";
NSString *const PhEnableObjectSceanry = @"PhEnableObjectSceanry";
NSString *const PhEnableObjectSound = @"PhEnableObjectSound";
NSString *const PhEnableObjectGoal = @"PhEnableObjectGoal";

// ********* Polygon Color Visability Settings *********
NSString *const PhEnablePlatfromPolyColoring = @"PhEnablePlatfromPolyColoring";
NSString *const PhEnableConvexPolyColoring = @"PhEnableConvexPolyColoring";
NSString *const PhEnableZonePolyColoring = @"PhEnableZonePolyColoring";
NSString *const PhEnableTeleporterExitPolyColoring = @"PhEnableTeleporterExitPolyColoring";
NSString *const PhEnableHillPolyColoring = @"PhEnableHillPolyColoring";

// ********* Grid Settings *********
NSString *const PhGridFactor = @"PhGridFactor";
NSString *const PhEnableGridBool = @"PhEnableGridBool";

// ********* Current Phorge Information *********

const short oldVersionOfPfhorgeLevelData = 6;
const short currentVersionOfPfhorgeLevelData = 7;

NSString *const PhPrefVersion = @"PhPrefVersion";
NSString *const PhPhorgePrefVersion = @"PhPhorgePrefVersion";
NSString *const PhPhorgeColors = @"PhPhorgeColors";

// ********* PhPhorgeColors Strings *********
NSString *const PhPolygonRegularColor = @"PhPolygonRegularColor";
NSString *const PhPolygonSelectedColor = @"PhPolygonSelectedColor";
NSString *const PhPolygonPlatformColor = @"PhPolygonPlatformColor";
NSString *const PhPolygonNonConcaveColor = @"PhPolygonNonConcaveColor";
NSString *const PhPolygonTeleporterColor = @"PhPolygonTeleporterColor";
NSString *const PhPolygonZoneColor = @"PhPolygonZoneColor";
NSString *const PhPolygonHillColor = @"PhPolygonHillColor";

NSString *const PhLineRegularColor = @"PhLineRegularColor";
NSString *const PhLineSelectedColor = @"PhLineSelectedColor";
NSString *const PhLineConnectsPolysColor = @"PhLineConnectsPolysColor";

NSString *const PhPointRegularColor = @"PhPointRegularColor";
NSString *const PhPointSelectedColor = @"PhPointSelectedColor";

NSString *const PhObjectSelectedColor = @"PhObjectSelectedColor";
NSString *const PhObjectItemColor = @"PhObjectItemColor";
NSString *const PhObjectPlayerColor = @"PhObjectPlayerColor";
NSString *const PhObjectFriendlyMonsterColor = @"PhObjectFriendlyMonsterColor";
NSString *const PhObjectNeutralMonsterColor = @"PhObjectNeutralMonsterColor";
NSString *const PhObjectEnemyMonsterColor = @"PhObjectEnemyMonsterColor";
NSString *const PhObjectSceanryColor = @"PhObjectSceanryColor";
NSString *const PhObjectSoundColor = @"PhObjectSoundColor";
NSString *const PhObjectGoalColor = @"PhObjectGoalColor";

NSString *const PhObjectBLineSelectedColor = @"PhObjectBLineSelectedColor";
NSString *const PhObjectBLineItemColor = @"PhObjectBLineItemColor";
NSString *const PhObjectBLinePlayerColor = @"PhObjectBLinePlayerColor";
NSString *const PhObjectBLineFriendlyMonsterColor = @"PhObjectBLineFriendlyMonsterColor";
NSString *const PhObjectBLineNeutralMonsterColor = @"PhObjectBLineNeutralMonsterColor";
NSString *const PhObjectBLineEnemyMonsterColor = @"PhObjectBLineEnemyMonsterColor";
NSString *const PhObjectBLineSceanryColor = @"PhObjectBLineSceanryColor";
NSString *const PhObjectBLineSoundColor = @"PhObjectBLineSoundColor";
NSString *const PhObjectBLineGoalColor = @"PhObjectBLineGoalColor";

NSString *const PhBackgroundColor = @"PhBackgroundColor";
NSString *const PhWorldUnitGridColor = @"PhWorldUnitGridColor";
NSString *const PhSubWorldUnitGridColor = @"PhSubWorldUnitGridColor";
NSString *const PhCenterWorldUnitGridColor = @"PhCenterWorldUnitGridColor";

// * Terminal Keys *
NSString *const PhTerminalBoldAttributeName = @"PhBoldTerminalAttribute";
NSString *const PhTerminalColorAttributeName = @"PhColorTerminalAttribute";
NSString *const PhTerminalItalicAttributeName = @"PhItalicTerminalAttribute";

// *********************** End EXTERN Variables ***********************

@implementation NSObject (SKTPerformExtras)

- (void)performSelector:(SEL)sel withEachObjectInArray:(NSArray *)array {
    NSInteger i, c = [array count];
    
    if (c < 1)
        return;
    
    for (i=0; i<c; i++) {
        [[array objectAtIndex:i] performSelector:sel withObject:[array objectAtIndex:i]];
    }
}

- (void)performSelector:(SEL)sel withEachObjectInSet:(NSSet *)set {
    [self performSelector:sel withEachObjectInArray:[set allObjects]];
}

// *********************** Utilites ***********************

- (void)setEnabledOfMatrixCellsTo:(BOOL)v
{
    NSInteger j, c;
    NSArray *theCells;
    NSMatrix *m = (NSMatrix *) self;
    
    theCells = [m cells];
    c = [theCells count];
    
    for (j = 0; j < c; j++)
        [[theCells objectAtIndex:j] setEnabled:v];
}

@end

NSRect LERectFromPoints(NSPoint point1, NSPoint point2) {
    return NSMakeRect(((point1.x <= point2.x) ? point1.x : point2.x), ((point1.y <= point2.y) ? point1.y : point2.y), ((point1.x <= point2.x) ? point2.x - point1.x : point1.x - point2.x), ((point1.y <= point2.y) ? point2.y - point1.y : point1.y - point2.y));
}

NSPoint LEAddToPoint(NSPoint point1, float theSum) {
    point1.x += theSum;
    point1.y += theSum;
    return point1;
}

/*int LECompareLines(id line1, id line2, NSPoint thePoint) {
    //NSRect rect1 = [line1 drawingBounds];
    //NSRect rect2 = [line2 drawingBounds];
    int dis1 = LEDistanceOfLine(LERectFromPoints(thePoint, [line1 drawingBounds].origin)); //Use Orgin of drawing bounds?
    int dis2 = LEDistanceOfLine(LERectFromPoints(thePoint, [line2 drawingBounds].origin));
    
    if (dis1 > dis2)
        return NSOrderedDescending;
    else if (dis1 < dis2)
        return NSOrderedAscending;
    else
        return NSOrderedSame;
}*/

/*int LEDistanceOfLine(NSRect theBoundsOfLine) {
    return sqrt(pow(theBoundsOfLine.size.width, 2) + pow(theBoundsOfLine.size.height, 2));
}*/


// ********************** AppleScript Stuff **********************
#pragma mark -
#pragma mark ********* AppleScript Stuff *********

@implementation SendTarget

+ (id)sendTargetWithAppleScriptObject:(NDAppleScriptObject *)anObject
{
	SendTarget		* theInstance;

	if( (theInstance = [[[self alloc] init] autorelease]) )
	{
		theInstance->appleScriptObject = [anObject retain];
		theInstance->OK_Enough = 0;
	}
	return theInstance;
}

-(void)dealloc
{
	[appleScriptObject release];
	[super dealloc];
}

/*
 * sendAppleEvent:sendMode:sendPriority:timeOutInTicks:idleProc:filterProc:
 */
- (NSAppleEventDescriptor *)sendAppleEvent:(NSAppleEventDescriptor *)theAppleEventDescriptor sendMode:(AESendMode)aSendMode sendPriority:(AESendPriority)aSendPriority timeOutInTicks:(SInt32)aTimeOutInTicks idleProc:(AEIdleUPP)anIdleProc filterProc:(AEFilterUPP)aFilterProc
{	
	OK_Enough++;
	/*if( OK_Enough < 2 )
		printf("sending say event to %s...\n\n", [theAppleEventDescriptor isTargetCurrentProcess] ? "self" : "Finder" );
	else if( OK_Enough == 2 )
		printf("sending open event to %s...\t\tyou get the idea.\n\n", [theAppleEventDescriptor isTargetCurrentProcess] ? "self" : "Finder" );*/

	return [appleScriptObject sendAppleEvent:theAppleEventDescriptor sendMode:aSendMode sendPriority:aSendPriority timeOutInTicks:aTimeOutInTicks idleProc:anIdleProc filterProc:aFilterProc];
}

- (BOOL)appleScriptActive
{
	printf("* active\n");
	return [appleScriptObject appleScriptActive];
}

@end



/*
 * createAndExecuteScriptObject()
 */
void createAndExecuteScriptObject( NSString * aPath )
{
	NSString			* theScriptText;
	NDAppleScriptObject		* theScriptObject;
	
	NSLog(@"Excuting Script Function Begining...");
	
	if( [[aPath pathExtension] isEqualToString:@"applescript"] )
	{
		/*
		 * This shows creating a script object from a string
		 */		
		theScriptText = [NSString stringWithContentsOfFile:aPath usedEncoding:NULL error:NULL];
		theScriptObject = [NDAppleScriptObject appleScriptObjectWithString:theScriptText];
	}
	else
	{
		/*
		 * This shows creating a script object from a compiled AppleScript file,
		 */
		NSLog(@"Geting Script...");
		theScriptObject = [[NDAppleScriptObject alloc] initWithContentsOfFile:aPath];
	}
	
	if( theScriptObject )
	{
		///id			theResult;
		///NSArray		* theNamesList;
		SendTarget		* theSendTarget;
		
		/*
		 * set execution made flags
		 */
		[theScriptObject setExecutionModeFlags:kOSAModeCanInteract];
		
		theSendTarget = [SendTarget sendTargetWithAppleScriptObject:theScriptObject];
		/*
		 * set target object which implements the NDAppleScriptObjectSendEvent protocol,
		 * it simple prints a message and then passes all of the paramter back to NDAppleScriptObject
		 * which also implements the NDAppleScriptObjectSendEvent protocol.
		 */
		[theScriptObject setAppleEventSendTarget:theSendTarget];
		
		/*
		 * set target object which implements the NDAppleScriptObjectActive protocol,
		 * it simple prints a message and then calls NDAppleScriptObject
		 * which also implements the NDAppleScriptObjectActive protocol.
		 */
		[theScriptObject  setActivateTarget:theSendTarget];
		
		[theScriptObject setDefaultTargetAsCreator:(OSType)'PFrg'];
		//[theScriptObject setFinderAsDefaultTarget];
		NSLog(@"Excuting Script...");
		[theScriptObject execute];
		NSLog(@"Excuting Script DONE...");
		//[NDAppleScriptObject compileExecuteString:@"make new map at end of maps\n"];
		[NDAppleScriptObject compileExecuteString:@"say \"Done\"\n"];
		[NDAppleScriptObject compileExecuteString:@"display dialog \"Done\"\n"];
		if( [[aPath pathExtension] isEqualToString:@"scpt"] )
		{
			[theScriptObject writeToFile:aPath];
		}
	}
	else
	{
		printf("Could not create the AppleScript object... \n");
	}
	NSLog(@"Excuting Script END...");
}

