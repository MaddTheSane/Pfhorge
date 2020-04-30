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
NSString *PhLevelDeallocatingNotification = @"PhLevelDeallocatingNotification";
NSString *PhUserDidChangePrefs = @"PhUserDidChangePref";
NSString *PhUserDidChangeNames = @"PhUserDidChangeName";
NSString *LELevelChangedNotification = @"LELevelChangedNotification";
NSString *LESelectionChangedNotification = @"LESelectionChangedNotification";
NSString *LEToolChangedNotification = @"LEToolChangedNotification";
NSString *PhLevelStatusBarUpdate = @"PhLevelStatusBarUpdate";

// ********* Visual Settings *********
NSString *VMKeySpeed = @"VMKeySpeed";
NSString *VMMouseSpeed = @"VMMouseSpeed";
NSString *VMInvertMouse = @"VMInvertMouse";

NSString *VMUpKey = @"VMUpKey";
NSString *VMDownKey = @"VMDownKey";
NSString *VMLeftKey = @"VMLeftKey";
NSString *VMRightKey = @"VMRightKey";
NSString *VMForwardKey = @"VMForwardKey";
NSString *VMBackwardKey = @"VMBackwardKey";
NSString *VMSlideLeftKey = @"VMSlideLeftKey";
NSString *VMSlideRightKey = @"VMSlideRightKey";

NSString *VMCeilingColor = @"VMCeilingColor";
NSString *VMFloorColor = @"VMFloorColor";
NSString *VMWallColor = @"VMWallColor";
NSString *VMLiquidColor = @"VMLiquidColor";
NSString *VMTransparentColor = @"VMTransparentColor";
NSString *VMLandscapeColor = @"VMLandscapeColor";
NSString *VMInvalidSurfaceColor = @"VMInvalidSurfaceColor";
NSString *VMWireFrameLineColor = @"VMWireFrameLineColor";
NSString *VMBackGroundColor = @"VMBackGroundColor";


NSString *VMShapesPath = @"VMShapesPath";
NSString *VMRenderMode = @"VMRenderMode";
NSString *VMStartPosition = @"VMStartPosition";

NSString *VMShowLiquids = @"VMShowLiquids";
NSString *VMShowTransparent = @"VMShowTransparent";
NSString *VMShowLandscapes = @"VMShowLandscapes";
NSString *VMShowInvalid = @"VMShowInvalid";
NSString *VMShowObjects = @"VMShowObjects";

NSString *VMLiquidsTransparent = @"VMLiquidsTransparent";
NSString *VMUseFog = @"VMUseFog";
NSString *VMFogDepth = @"VMFogDepth";

NSString *VMSmoothRendering = @"VMSmoothRendering";

NSString *VMUseLighting = @"VMUseLighting";
NSString *VMWhatLighting = @"VMWhatLighting";

NSString *VMPlatformState = @"VMPlatformState";
NSString *VMVisibleSide = @"VMVisibleSide";
NSString *VMVerticalLook = @"VMVerticalLook";
NSString *VMFieldOfView = @"VMFieldOfView";
NSString *VMVisibilityMode = @"VMVisibilityMode";

// ********* Default Layer Settings *********
NSString *PhDefaultLayers = @"PhDefaultLayers";
NSString *PhDefaultLayer_Name = @"Name";
NSString *PhDefaultLayer_FloorMin = @"Floor Min";
NSString *PhDefaultLayer_FloorMax = @"Floor Max";
NSString *PhDefaultLayer_CeilingMin = @"Ceiling Min";
NSString *PhDefaultLayer_CeilingMax = @"Ceiling Max";

// ********* General Settings *********
NSString *PhEnableAntialiasing = @"PhEnableAntialiasing";
NSString *PhEnableObjectOutling = @"PhEnableObjectOutling";
NSString *PhDrawOnlyLayerPoints = @"PhDrawOnlyLayerPoints";
NSString *PhSelectObjectWhenCreated = @"PhSelectObjectWhenCreated";
NSString *PhSplitPolygonLines = @"PhSplitPolygonLines";
NSString *PhSplitNonPolygonLines = @"PhSplitNonPolygonLines";
NSString *PhSnapToLines = @"PhSnapToLines";
NSString *PhSnapToPoints = @"PhSnapToPoints";
NSString *PhSnapObjectsToGrid = @"PhSnapObjectsToGrid";
NSString *PhSnapToGridBool = @"PhSnapToGridBool";
NSString *PhSnapToPointsLength = @"PhSnapToPointsLength";

NSString *PhUseRightAngleSnap = @"PhUseRightAngleSnap";
NSString *PhUseIsometricAngleSnap = @"PhUseIsometricAngleSnap";
NSString *PhSnapFromPoints = @"PhSnapFromPoints";
NSString *PhSnapFromLength = @"PhSnapFromLength";

// ********* Object Type Visability Settings *********
NSString *PhEnableObjectItem = @"PhEnableObjectItem";
NSString *PhEnableObjectPlayer = @"PhEnableObjectPlayer";
NSString *PhEnableObjectEnemyMonster = @"PhEnableObjectEnemyMonster";
NSString *PhEnableObjectSceanry = @"PhEnableObjectSceanry";
NSString *PhEnableObjectSound = @"PhEnableObjectSound";
NSString *PhEnableObjectGoal = @"PhEnableObjectGoal";

// ********* Polygon Color Visability Settings *********
NSString *PhEnablePlatfromPolyColoring = @"PhEnablePlatfromPolyColoring";
NSString *PhEnableConvexPolyColoring = @"PhEnableConvexPolyColoring";
NSString *PhEnableZonePolyColoring = @"PhEnableZonePolyColoring";
NSString *PhEnableTeleporterExitPolyColoring = @"PhEnableTeleporterExitPolyColoring";
NSString *PhEnableHillPolyColoring = @"PhEnableHillPolyColoring";

// ********* Grid Settings *********
NSString *PhGridFactor = @"PhGridFactor";
NSString *PhEnableGridBool = @"PhEnableGridBool";

// ********* Current Phorge Information *********

int currentVersionOfPfhorgeLevelData = 6;

NSString *currentPhorgeVersion = @"0.3.0 alpha";

NSString *PhPrefVersion = @"PhPrefVersion";
NSString *PhPhorgePrefVersion = @"PhPhorgePrefVersion";
NSString *PhPhorgeColors = @"PhPhorgeColors";

// ********* PhPhorgeColors Strings *********
NSString *PhPolygonRegularColor = @"PhPolygonRegularColor";
NSString *PhPolygonSelectedColor = @"PhPolygonSelectedColor";
NSString *PhPolygonPlatformColor = @"PhPolygonPlatformColor";
NSString *PhPolygonNonConcaveColor = @"PhPolygonNonConcaveColor";
NSString *PhPolygonTeleporterColor = @"PhPolygonTeleporterColor";
NSString *PhPolygonZoneColor = @"PhPolygonZoneColor";
NSString *PhPolygonHillColor = @"PhPolygonHillColor";

NSString *PhLineRegularColor = @"PhLineRegularColor";
NSString *PhLineSelectedColor = @"PhLineSelectedColor";
NSString *PhLineConnectsPolysColor = @"PhLineConnectsPolysColor";

NSString *PhPointRegularColor = @"PhPointRegularColor";
NSString *PhPointSelectedColor = @"PhPointSelectedColor";

NSString *PhObjectSelectedColor = @"PhObjectSelectedColor";
NSString *PhObjectItemColor = @"PhObjectItemColor";
NSString *PhObjectPlayerColor = @"PhObjectPlayerColor";
NSString *PhObjectFriendlyMonsterColor = @"PhObjectFriendlyMonsterColor";
NSString *PhObjectNeutralMonsterColor = @"PhObjectNeutralMonsterColor";
NSString *PhObjectEnemyMonsterColor = @"PhObjectEnemyMonsterColor";
NSString *PhObjectSceanryColor = @"PhObjectSceanryColor";
NSString *PhObjectSoundColor = @"PhObjectSoundColor";
NSString *PhObjectGoalColor = @"PhObjectGoalColor";

NSString *PhObjectBLineSelectedColor = @"PhObjectBLineSelectedColor";
NSString *PhObjectBLineItemColor = @"PhObjectBLineItemColor";
NSString *PhObjectBLinePlayerColor = @"PhObjectBLinePlayerColor";
NSString *PhObjectBLineFriendlyMonsterColor = @"PhObjectBLineFriendlyMonsterColor";
NSString *PhObjectBLineNeutralMonsterColor = @"PhObjectBLineNeutralMonsterColor";
NSString *PhObjectBLineEnemyMonsterColor = @"PhObjectBLineEnemyMonsterColor";
NSString *PhObjectBLineSceanryColor = @"PhObjectBLineSceanryColor";
NSString *PhObjectBLineSoundColor = @"PhObjectBLineSoundColor";
NSString *PhObjectBLineGoalColor = @"PhObjectBLineGoalColor";

NSString *PhBackgroundColor = @"PhBackgroundColor";
NSString *PhWorldUnitGridColor = @"PhWorldUnitGridColor";
NSString *PhSubWorldUnitGridColor = @"PhSubWorldUnitGridColor";
NSString *PhCenterWorldUnitGridColor = @"PhCenterWorldUnitGridColor";

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


// ********************** Apple Script Stuff **********************
#pragma mark -
#pragma mark ********* Apple Script Stuff *********

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
		 * This shows creating a script object from a compiled apple script file,
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

