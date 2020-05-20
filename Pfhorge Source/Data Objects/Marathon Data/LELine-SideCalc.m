//
//  LELineExtra1.m
//  Pfhorge
//
//  Created by Jagil on Thu Dec 19 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "LELine.h"
#import "LEMapPoint.h"
#import "LEPolygon.h"
#import "LEMapObject.h"
#import "LEExtras.h"
#import "LESide.h"
#import "LELevelData.h"
#import "LEMap.h"
#import "PhPlatform.h"








#define GET_SIDE_FLAG(b) (flags & (b))
#define SET_LINE_FLAG(b, v) ((v) ? (flags |= (b)) : (flags &= ~(b)))

@implementation LELine (SideCalculations)
// **************************  Side Rotines  *************************
#pragma mark -
#pragma mark Side Routines

-(void)autoTextureWithLine:(LELine *)theLine
{
    
}


-(void)caculateSides
{
    LEPolygon *clockPoly = clockwisePolygon;
    LEPolygon *counterclockPoly = conterclockwisePolygon;
    PhPlatform *cPlat = nil;
    PhPlatform *ccPlat = nil;
    int i = 0;
    BOOL alreadySetPlatformFlag = NO;
    BOOL cPlatform = NO;
    BOOL ccPlatform = NO;
    
    
    if (usePermanentSettings == YES && permanentNoSides == YES) {
        [theLELevelDataST removeSidesFromLine:self];
        return;
    }
    
    flags = 0;
    
    while (/*whatIAmTesting == 1*/ YES) {
        int theType;
        i++;
        
        if (i == 1) {
            if (clockPoly != nil)
                theType = [clockPoly type];
            else
                continue;
        } else if (i == 2) {
            if (counterclockPoly != nil)
                theType = [counterclockPoly type];
            else
                continue;
        } else
            break;
        
        switch (theType) {
            case _polygon_is_normal:
            case _polygon_is_item_impassable:
            case _polygon_is_monster_impassable:
            case _polygon_is_hill:
            case _polygon_is_base:
            case _polygon_is_light_on_trigger:
            case _polygon_is_platform_on_trigger:
            case _polygon_is_light_off_trigger:
            case _polygon_is_platform_off_trigger:
            case _polygon_is_teleporter:
            case _polygon_is_zone_border:
            case _polygon_is_goal:
            case _polygon_is_visible_monster_trigger:
            case _polygon_is_invisible_monster_trigger:
            case _polygon_is_dual_monster_trigger:
            case _polygon_is_item_trigger:
            case _polygon_must_be_explored:
            case _polygon_is_automatic_exit:
                break;
                
            case _polygon_is_platform: // Do Platfrom Side Calculations...
                
                // Only if the floor is moving, CHANGE THIS!!!
                //if (alreadySetPlatformFlag == NO)
                //   flags |= LELineVariableElevation;
                
                if (i == 1)
                {
                    cPlat = [clockPoly permutationObject];
                    cPlatform = YES;
                }
                else if (i == 2)
                {
                    ccPlat = [counterclockPoly permutationObject];
                    ccPlatform = YES;
                }
                
                alreadySetPlatformFlag = YES;
                break;
                
            default:
                break;
        } // END switch (theType)
    } // END while (YES)
    
    if (clockPoly == nil || counterclockPoly == nil) {
        // |---------------------
        // |  <-full c or cc
        // |---------------------
        if (clockPoly != nil) {
            if (clockwisePolygonSideObject == nil) {
                LESide *theNewSide = [theLELevelDataST addObjectWithDefaults:[LESide class]];
                int polyLineNumber1 = [clockPoly getLineNumberFor:self];
                
                NSParameterAssert(theNewSide != nil);
                //NSParameterAssert(polyLineNumber1 != -1);
                
                [theNewSide setPolygonObject:clockPoly];
                [theNewSide setLineObject:self];
                
                [self setClockwisePolygonSideObject:theNewSide];
                
                if (polyLineNumber1 != -1) {
                    [clockPoly setSidesObject:theNewSide toIndex:polyLineNumber1];
                } else {
                    NSLog(@"Poly %d does not have a link to me (Line %d)?", [clockPoly index], [self index]);
                }
            }
            
            [clockwisePolygonSideObject setType:LESideFull];
            
            flags |= LELineSolid;
            
            if (counterclockwisePolygonSideObject != nil)
                [theLELevelDataST deleteSide:counterclockwisePolygonSideObject];
            
            counterclockwisePolygonSideObject = nil;
        } else if (counterclockPoly != nil) {
            if (counterclockwisePolygonSideObject == nil) {
                LESide *theNewSide = [theLELevelDataST addObjectWithDefaults:[LESide class]];
                int polyLineNumber2 = [counterclockPoly getLineNumberFor:self];
                
                NSParameterAssert(theNewSide != nil);
                //NSParameterAssert(polyLineNumber2 != -1);
                
                [theNewSide setPolygonObject:counterclockPoly];
                [theNewSide setLineObject:self];
                
                [self setCounterclockwisePolygonSideObject:theNewSide];
                if (polyLineNumber2 != -1) {
                    [counterclockPoly setSidesObject:theNewSide toIndex:polyLineNumber2];
                } else {
                    NSLog(@"Poly %d does not have a link to me (Line %d)?", [counterclockPoly index], [self index]);
                }
            }
            
            [counterclockwisePolygonSideObject setType:LESideFull];
            
            flags |= LELineSolid;
            
            if (clockwisePolygonSideObject != nil)
                [theLELevelDataST deleteSide:clockwisePolygonSideObject];
            
            clockwisePolygonSideObject = nil;
        } else {
            if (counterclockwisePolygonSideObject != nil) {
                [theLELevelDataST deleteSide:counterclockwisePolygonSideObject];
            }
            if (clockwisePolygonSideObject != nil) {
                [theLELevelDataST deleteSide:clockwisePolygonSideObject];
            }
            
            clockwisePolygonSideObject = nil;
            counterclockwisePolygonSideObject = nil;
        }
    } // if (clockPoly == nil || counterclockPoly == nil)
    else { // NOT if (clockPoly == nil || counterclockPoly == nil)
        // *** Need To Check For Polygons And Adjust These!!! ***
        
        if (alreadySetPlatformFlag == YES) {
            //NSLog(@"Platform Line Setup For Line#: %d", [self index]);
            [self setupWithClockPlat:cPlat counterClockPlat:ccPlat];
        } else {
            [self setupAsNonPlatformLine];
        }
        
    } // END else After NOT if (clockPoly == nil || counterclockPoly == nil)
    
    
    //Make sure parmanent flags are followed...
    
    [self setFlags:flags];
} // END -(void)caculateSides

-(void)setupWithClockPlat:(PhPlatform *)cPlat counterClockPlat:(PhPlatform *)ccPlat
{
    int cF = [clockwisePolygon floorHeight];
    int cC = [clockwisePolygon ceilingHeight];
    int ccF = [conterclockwisePolygon floorHeight];
    int ccC = [conterclockwisePolygon ceilingHeight];
    
    int cPlatMax = [cPlat maximumHeight];
    int ccPlatMax = [ccPlat maximumHeight];
    
    int cPlatMin = [cPlat minimumHeight];
    int ccPlatMin = [ccPlat minimumHeight];
    
    if (cPlatMax == -1)
        cPlatMax = cC;
    if (cPlatMin == -1)
        cPlatMin = cF;
    if (ccPlatMin == -1)
        ccPlatMin = ccF;
    if (ccPlatMax == -1)
        ccPlatMax = ccC;
    
    
    //if
    
    PhPlatformStaticFlags ccPlatFlags = [ccPlat staticFlags];
    PhPlatformStaticFlags cPlatFlags = [cPlat staticFlags];
    
    BOOL cPlatFloor = ((cPlatFlags & (_platform_comes_from_floor)) ? (YES) : (NO));
    BOOL cPlatCeiling = ((cPlatFlags & (_platform_comes_from_ceiling)) ? (YES) : (NO));
    BOOL ccPlatFloor = ((ccPlatFlags & (_platform_comes_from_floor)) ? (YES) : (NO));
    BOOL ccPlatCeiling = ((ccPlatFlags & (_platform_comes_from_ceiling)) ? (YES) : (NO));
    
    int cCMax = 0, cCMin = 0, cFMax = 0, cFMin = 0;
    int ccCMax = 0, ccCMin = 0, ccFMax = 0, ccFMin = 0;
    
    
    
    // ••• ••• ••• Clock Wise Information ••• ••• •••
    
    
    
    if (cPlat != nil) {
        if (cPlatFloor && cPlatCeiling) {
            // c is both
            int half = (((cPlatMax - cPlatMin) / 2) + cPlatMin);
            cFMax = half;
            cFMin = cPlatMin;
            cCMin = half;
            cCMax = cPlatMax;
            //NSLog(@"Platform #%d - cPlatFloor && cPlatCeiling", [cPlat index]);
        } else if (cPlatFloor && !cPlatCeiling) {
            // c is floor
            cCMin = cC;
            cCMax = cC;
            cFMax = cPlatMax;
            cFMin = cPlatMin;
            //NSLog(@"Platform #%d - cPlatFloor && !cPlatCeiling", [cPlat index]);
        } else if (!cPlatFloor && cPlatCeiling) {
            // c is ceiling
            cFMax = cF;
            cFMin = cF;
            cCMax = cPlatMax;
            cCMin = cPlatMin;
            //NSLog(@"Platform #%d - !cPlatFloor && cPlatCeiling", [cPlat index]);
        } else if (!cPlatFloor && !cPlatCeiling) {
            // c is not floor or ceiling...
            // proably a major data error here...
            
            // inform user, set the platform for floor automaticaly (the default)...
            NSLog(@"Platform #%d Has Neither Floor Or Celining Flags Set... c", [cPlat index]);
            
            cCMax = cC;
            cCMin = cC;
            cFMax = cF;
            cFMin = cF;
        } else {
            // Very Major Logic Error...
            NSLog(@"Very Major Logic Error For Platform #%d, in caculatSides... c", [cPlat index]);
        }
    } else {
        cPlatFloor = NO;
        cPlatCeiling = NO;
        cPlatFlags = 0;
        
        cCMax = cC;
        cCMin = cC;
        cFMax = cF;
        cFMin = cF;
        
        //NSLog(@"Platform #%d - cPlat == nil", [cPlat index]);
    }
    
    
    
    // ••• ••• ••• Counter-Clock Wise Information ••• ••• •••
    
    
    
    if (ccPlat != nil) {
        if (ccPlatFloor && ccPlatCeiling) {
            // cc is both
            int half = (((ccPlatMax - ccPlatMin) / 2) + ccPlatMin);
            ccFMax = half;
            ccFMin = ccPlatMin;
            ccCMin = half;
            ccCMax = ccPlatMax;
            //NSLog(@"Platform #%d - ccPlatFloor && ccPlatCeiling", [ccPlat index]);
        } else if (ccPlatFloor && !ccPlatCeiling) {
            // cc is floor
            ccCMin = ccC;
            ccCMax = ccC;
            ccFMax = ccPlatMax;
            ccFMin = ccPlatMin;
            //NSLog(@"Platform #%d - ccPlatFloor && !ccPlatCeiling", [ccPlat index]);
        } else if (!ccPlatFloor && ccPlatCeiling) {
            // cc is ceiling
            ccFMax = ccF;
            ccFMin = ccF;
            ccCMax = ccPlatMax;
            ccCMin = ccPlatMin;
            // NSLog(@"Platform #%d - !ccPlatFloor && ccPlatCeiling", [ccPlat index]);
        } else if (!ccPlatFloor && !ccPlatCeiling) {
            // cc is not floor or ceiling...
            // proably a major data error here...
            
            // inform user, set the platform for floor automaticaly (the default)...
            //NSLog(@"Platform #%d Has Neither Floor Or Celining Flags Set... cc", [ccPlat index]);
            
            ccCMin = ccC;
            ccCMax = ccC;
            ccFMax = ccF;
            ccFMin = ccF;
        } else {
            // Very Major Logic Error...
            //NSLog(@"Very Major Logic Error For Platform #%d, in caculatSides... cc", [ccPlat index]);
        }
    } else {
        ccPlatFloor = NO;
        ccPlatCeiling = NO;
        ccPlatFlags = 0;
        
        ccCMin = ccC;
        ccCMax = ccC;
        ccFMax = ccF;
        ccFMin = ccF;
        
        //NSLog(@"Platform #%d - ccPlat == nil", [ccPlat index]);
    }
    
    // [self setupAsNonPlatformLine]; // For Right Now...
    
    
    
    // *** *** *** Taking a look at the platform ranges *** *** ***

    BOOL cHighSide = NO, ccHighSide = NO, cLowSide = NO, ccLowSide = NO;
    //BOOL variableFloor = NO; // Is the floor moving?
    //BOOL elevationFloor = NO; // is there a difrrence in highet of the floors?
   // BOOL seeThough = NO; // Is there any opertunity to 'see though' to the other side?
    
    
    NSMutableString *path = [[NSMutableString alloc] init];
    
    
    // ••• ••• ••• Ceiling Checks ••• ••• •••
    
    
    if (cCMax > ccCMax) {
        if (cCMin > ccCMin) {
            if (cCMin < ccCMax) {
                [path appendString:@"-1"];
                // If the platfroms are out of sync, could still have a high cc side
                ccHighSide = YES;
            }
            
            [path appendString:@"-2"];
            
            // at the very least there is a high c side
            cHighSide = YES;
        } else if (cCMin < ccCMin) {
            // For sure there are going to be two high sides...
            [path appendString:@"-3"];
            cHighSide = YES;
            ccHighSide = YES;
        } else { // (cCMin == ccCMin)
            if (cCMin < ccCMax) {
                [path appendString:@"-4a"];
                // If the platfroms are out of sync, could still have a high cc side
                ccHighSide = YES;
            }
            [path appendString:@"-4"];
            cHighSide = YES;
        }
    } else if (cCMax < ccCMax) {
        if (cCMin < ccCMin) {
            if (cCMax > ccCMin) {
                // If the platfroms are out of sync, could still have a high cc side
                cHighSide = YES;
                [path appendString:@"-5"];
            }
            [path appendString:@"-6"]; //-
            // at the very least there is a high c side
            ccHighSide = YES;
        } else if (cCMin > ccCMin) {
            // For sure there are going to be two high sides...
            [path appendString:@"-7"];
            ccHighSide = YES;
            cHighSide = YES;
        } else { // (cCMin == ccCMin)
            if (cCMax > ccCMin) {
                // If the platfroms are out of sync, could still have a high cc side
                cHighSide = YES;
                [path appendString:@"-8a"];
            }
            [path appendString:@"-8"];
            ccHighSide = YES;
        }
    } else { // if (cCMax == ccCMax)
        if (cCMin < ccCMax) {
            [path appendString:@"-9"];
            // at the very least there is a high c side
            ccHighSide = YES;
        }
        
        if (ccCMin < cCMax) {
            [path appendString:@"-10"];
            // For sure there are going to be two high sides...
            cHighSide = YES;
        }
        [path appendString:@"-11"];
    }
    
    
    
    // ••• ••• ••• Floor Checks ••• ••• •••
    
    
    
    if (cFMax > ccFMax) {
        if (cFMin > ccFMin) {
            if (cFMin < ccFMax) {
                // If the platfroms are out of sync, could still have a high cc side
                cLowSide = YES;
                [path appendString:@"-12"];
            }
            
            [path appendString:@"-13"];
            // at the very least there is a high c side
            ccLowSide = YES;
        } else if (cFMin < ccFMin) {
            // For sure there are going to be two high sides...
            [path appendString:@"-14"];
            ccLowSide = YES;
            cLowSide = YES;
        } else { // (cFMin == ccFMin)
            if (cFMin < ccFMax) {
                // If the platfroms are out of sync, could still have a high cc side
                cLowSide = YES;
                [path appendString:@"-15a"];
            }
            
            [path appendString:@"-15"];
            ccLowSide = YES;
        }
    } else if (cFMax < ccFMax) {
        if (cFMin < ccFMin) {
            if (cFMax > ccFMin) {
                [path appendString:@"-16"];
                // If the platfroms are out of sync, could still have a high cc side
                ccLowSide = YES;
            }
            
            [path appendString:@"-17"]; //-
            // at the very least there is a high c side
            cLowSide = YES;
        } else if (cFMin > ccFMin) {
            // For sure there are going to be two high sides...
            [path appendString:@"-18"];
            cLowSide = YES;
            ccLowSide = YES;
        } else { // (cFMin == ccFMin)
            if (cFMax > ccFMin) {
                [path appendString:@"-19a"];
                // If the platfroms are out of sync, could still have a high cc side
                ccLowSide = YES;
            }
            
            [path appendString:@"-19"];
            cLowSide = YES;
        }
    } else { // if (cFMax == ccFMax)
        if (cFMin < ccFMax) {
            [path appendString:@"-20"];
            // at the very least there is a high c side
            cLowSide = YES;
        }
        
        if (ccFMin < cFMax) {
            [path appendString:@"-21"];
            // For sure there are going to be two high sides...
            ccLowSide = YES;
        }
        [path appendString:@"-22"];
    }
    
    // •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
    //	At this point it is known where the sides are showing.
    //	It is time to setup the  c  and  cc  sides with the proper settings.
    //	
    //	
    //	
    // •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••
    
    
    //NSLog(@"Line# %d  P-Path: %@", [self index], path);
    
    if (cLowSide && cHighSide) {
        // c Side Split...
        [self setupSideFor:_clockwise asA:LESideSplit];
    } else if (cLowSide && !cHighSide) {
        // c Side Low...
        [self setupSideFor:_clockwise asA:LESideLow];
    } else if (!cLowSide && cHighSide) {
        // c Side High...
        [self setupSideFor:_clockwise asA:LESideHigh];
    }
    
    // ••• ••• ••• ••• ••• ••• ••• ••• •••
    
    
    if (ccLowSide && ccHighSide) {
        // cc Side Split...
        [self setupSideFor:_counter_clockwise asA:LESideSplit];
    } else if (ccLowSide && !ccHighSide) {
        // cc Side Low...
        [self setupSideFor:_counter_clockwise asA:LESideLow];
    } else if (!ccLowSide && ccHighSide) {
        // cc Side High...
        [self setupSideFor:_counter_clockwise asA:LESideHigh];
    }
    
    if (!cLowSide && !cHighSide) {
        [self removeSideFor:_clockwise];
    }
    
    if (!ccLowSide && !ccHighSide) {
        [self removeSideFor:_counter_clockwise];
    }
    
    if (ccLowSide || cLowSide) {
        flags |= LELineVariableElevation;
        flags |= LELineElevation;
    }
    
    /*if (ccLowSide || ccHighSide || cLowSide || cHighSide)
    {
        flags |= LELineTransparent;*/
    
    // ••• ••• ••• ••• ••• ••• ••• ••• •••
    
    flags |= LELineTransparent;
    
    // These should never be true, but just in case...
    
    /*if (!ccLowSide && !ccHighSide)
    {
        NSLog(@"WARNING: cc side in setupWithClockPlat is not low or high!!!");
        [self removeSideFor:_counter_clockwise];
        flags |= LELineSolid;
        flags &= ~LELineTransparent;
    }
    
    if (!cLowSide && !cHighSide)
    {
        NSLog(@"WARNING: c side in setupWithClockPlat is not low or high!!!");
        [self removeSideFor:_clockwise];
        flags |= LELineSolid;
        flags &= ~LELineTransparent;
    }*/
    
    
    [path release];
}

/*

-(void)sideTypesWithcCMax:(int)cCMax cCMin:(int)cCMin cFMax:(int)cFMax cFMin:(int)cFMin ccCMax:(int)ccCMax ccCMin:(int)ccCMin ccFMax:(int)ccFMax ccFMin:(int)ccFMin cIsPlat:(BOOL)
{
    BOOL cHighSide = NO, ccHighSide = NO, cLowSide = NO, ccLowSide = NO;
    BOOL variableFloor = NO; // Is the floor moving?
    BOOL elevationFloor = NO; // is there a difrrence in highet of the floors?
    BOOL seeThough = NO; // Is there any opertunity to 'see though' to the other side?
    
    if (cCMax > ccCMax)
    {
        if (cCMin > ccCMin)
        {
            if (cCMin < ccCMax)
            {
                // If the platfroms are out of sync, could still have a high cc side
                ccHighSide = YES;
            }
            
            // at the very least there is a high c side
            cHighSide = YES
        }
        else if (cCMin < ccCMin)
        {
            // For sure there are going to be two high sides...
            
            cHighSide = YES;
            ccHighSide = YES;
        }
        else // (cCMin == ccCMin)
        {
            
        }
    }
    
    
}

*/

-(void)setupAsNonPlatformLine
{
    int cF = [clockwisePolygon floorHeight];
    int cC = [clockwisePolygon ceilingHeight];
    int ccF = [conterclockwisePolygon floorHeight];
    int ccC = [conterclockwisePolygon ceilingHeight];
    
    if (cF == ccF)
    {
        if (ccC == cC)
        {   // -------------|------------
            //   cc empty->   <-empty c
            // -------------|------------
            // =========== or ===========
            // -------------|------------
            //    c empty->   <-empty cc
            // -------------|------------
            
            [self removeSideFor:_counter_clockwise];
            [self removeSideFor:_clockwise];
            flags |= LELineTransparent;
        }
        else if (cC > ccC)
        {	//
            //          |---------
            //          | <-high
            //----------|    c
            // cc none->
            //--------------------
            
            [self setupSideFor:_clockwise asA:LESideHigh];
            [self removeSideFor:_counter_clockwise];
            flags |= LELineTransparent;
        }
        else if (cC < ccC)
        {	//
            //          |---------
            //          | <-high
            //----------|    cc
            // c  none->
            //--------------------
            
            [self setupSideFor:_counter_clockwise asA:LESideHigh];
            [self removeSideFor:_clockwise];
            flags |= LELineTransparent;
        }
    } // END if (cF == ccF)
    else if (cC == ccC)
    {
        if (ccF == cF)
        {
            [self removeSideFor:_counter_clockwise];
            [self removeSideFor:_clockwise];
            flags |= LELineTransparent;
        }
        else if (cF > ccF)
        {	//
            //--------------------
            //  c none->
            //----------|   cc
            //          | <-low
            //          |---------
            
            [self setupSideFor:_counter_clockwise asA:LESideLow];
            [self removeSideFor:_clockwise];
            flags |= LELineTransparent;
            flags |= LELineElevation;
        }
        else if (cF < ccF)
        {	//
            //--------------------
            // cc none->
            //----------|    c
            //          | <-low
            //          |---------
            
            [self setupSideFor:_clockwise asA:LESideLow];
            [self removeSideFor:_counter_clockwise];
            
            flags |= LELineTransparent;
            flags |= LELineElevation;
        }
    } // END else if (cC == ccC)
    else /// if (cC != ccC && cF != ccF)
    {
        if (cF >= ccC || ccF >= cC)
        {	//-------------|
            //    cc full->|
            //-------------|
            //             |------------
            //             | <-full c
            //             |------------
            //========= or =============
            //-------------|
            //     c full->|
            //-------------|
            //             |------------
            //             | <-full cc
            //             |------------
            
            [self setupSideFor:_clockwise asA:LESideFull];
            [self setupSideFor:_counter_clockwise asA:LESideFull];
            flags |= LELineSolid;
        }
        else if (cC > ccC)
        {
            if (cF > ccF)
            {   //----------|
                // c  high->|---------
                //
                //----------|
                //          | <-low cc
                //          |---------
                [self setupSideFor:_clockwise asA:LESideHigh];
                [self setupSideFor:_counter_clockwise asA:LESideLow];
                flags |= LELineTransparent;
                flags |= LELineElevation;
            }
            else /// if (cF < ccF)
            {   //          |------------
                //          | <-split c
                //----------|
                // cc none->
                //----------|
                //          | <-split c
                //          |------------
                [self setupSideFor:_clockwise asA:LESideSplit];
                [self removeSideFor:_counter_clockwise];
                flags |= LELineTransparent;
                flags |= LELineElevation;
            }
        }
        else /// if (cC < ccC)
        {
            if (cF < ccF)
            {   //----------|
                // cc high->|---------
                //
                //----------|
                //          | <-low c
                //          |---------
                [self setupSideFor:_clockwise asA:LESideLow];
                [self setupSideFor:_counter_clockwise asA:LESideHigh];
                flags |= LELineTransparent;
                flags |= LELineElevation;
            }
            else /// if (cF > ccF)
            {   //          |------------
                //          | <-split cc
                //----------|
                // c  none->
                //----------|
                //          | <-split cc
                //          |------------
                [self setupSideFor:_counter_clockwise asA:LESideSplit];
                [self removeSideFor:_clockwise];
                flags |= LELineTransparent;
                flags |= LELineElevation;
            }
        } // END else /// if (cC < ccC)
    } // END else /// if (cC != ccC && cF != ccF)
    
}

- (LESide *)setupSideFor:(LESideDirection)sideDirection asA:(LESideType)sideType
{
  // _clockwise
    //  _counter_clockwise

 /*   
enum // side types (largely redundant; most of this could bve guessed for examining adjacent polygons)
{
	LESideFull,	// primary texture is mapped floor-to-ceiling
	LESideHigh, // primary texture is mapped on a panel coming down from the ceiling (implies 2 adjacent polygons)
	LESideLow, // primary texture is mapped on a panel coming up from the floor (implies 2 adjacent polygons)
	LESideComposite, //primary texture is mapped floor-to-ceiling, secondary texture is mapped into it (i.e., control panel)
	LESideSplit // primary texture is mapped onto a panel coming down from the ceiling, secondary texture is mapped on a panel coming up from the floor
};*/

    if (sideDirection == _clockwise) {
        if (clockwisePolygonSideObject != nil) {
            [clockwisePolygonSideObject setType:sideType];
        } else {
            LESide *theNewSide = [theLELevelDataST addObjectWithDefaults:[LESide class]];
            
            ///NSLog(@"theNewSide index: %d", [theNewSide index]);
            
            NSParameterAssert(theNewSide != nil);
            // NSParameterAssert(polyLineNumber3 != -1); // Handled Bellow...
            
            [theNewSide setPolygonObject:clockwisePolygon];
            [theNewSide setLineObject:self];
            
            clockwisePolygonSideObject = theNewSide;
            [clockwisePolygonSideObject setType:sideType];
            
            //flags |= LELineSolid;
        }
        
        int polyLineNumber = [clockwisePolygon getLineNumberFor:self];
        if (polyLineNumber != -1) {
            [clockwisePolygon setSidesObject:clockwisePolygonSideObject toIndex:polyLineNumber];
        } else {
            NSLog(@"Poly %d does not have a link to me (Line %d)?", [clockwisePolygon index], [self index]);
        }
        
        /*
        if ([clockwisePolygonSideObject flags] & LESideIsControlPanel)
        { // This side is a control panel... Attempt to keep it...
            [clockwisePolygonSideObject setType:LESideComposite];
        }
        */
        return clockwisePolygonSideObject;
    } else if (sideDirection == _counter_clockwise) {
        if (counterclockwisePolygonSideObject != nil) {
            [counterclockwisePolygonSideObject setType:sideType];
        } else {
            LESide *theNewSide = [theLELevelDataST addObjectWithDefaults:[LESide class]];
            
            ///NSLog(@"theNewSide index: %d", [theNewSide index]);
            
            NSParameterAssert(theNewSide != nil);
            // NSParameterAssert(polyLineNumber3 != -1); // Handled Bellow...
            
            [theNewSide setPolygonObject:conterclockwisePolygon];
            [theNewSide setLineObject:self];
            
            counterclockwisePolygonSideObject = theNewSide;
            [counterclockwisePolygonSideObject setType:sideType];
            
            //flags |= LELineSolid;
        }
        
        int polyLineNumber = [conterclockwisePolygon getLineNumberFor:self];
        if (polyLineNumber != -1) {
            [conterclockwisePolygon setSidesObject:counterclockwisePolygonSideObject toIndex:polyLineNumber]; // *** NOTE: ??? ??? ??? Check This Out!!! ***
        } else {
            NSLog(@"Poly %d does not have a link to me (Line %d)?", [conterclockwisePolygon index], [self index]);
        }
        
        /*
        if ([counterclockwisePolygonSideObject flags] & LESideIsControlPanel)
        { // This side is a control panel... Attempt to keep it...
            [counterclockwisePolygonSideObject setType:LESideComposite];
        }
        */
        
        return clockwisePolygonSideObject;
    } else {
        return nil;
    }
    

    /*
    if ([clockwisePolygonSideObject flags] & LESideIsControlPanel)
    { // This side is a control panel... Attempt to keep it...
        [clockwisePolygonSideObject setType:LESideComposite];
    }*/
    
    return nil;  
}

-(LESide *)setupSideFor:(LESideDirection)sideToReturn
{
    // _clockwise
    //  _counter_clockwise
    
    if (sideToReturn == _clockwise) {
        if (clockwisePolygonSideObject != nil) {
            return clockwisePolygonSideObject;
        } else {
            LESide *theNewSide = [theLELevelDataST addObjectWithDefaults:[LESide class]];
            int polyLineNumber3 = [clockwisePolygon getLineNumberFor:self];
            
            ///NSLog(@"theNewSide index: %d", [theNewSide index]);
            
            NSParameterAssert(theNewSide != nil);
            // NSParameterAssert(polyLineNumber3 != -1); // Handled Bellow...
            
            [theNewSide setPolygonObject:clockwisePolygon];
            [theNewSide setLineObject:self];
            
            clockwisePolygonSideObject = theNewSide;
            
            if (polyLineNumber3 != -1)
                [clockwisePolygon setSidesObject:theNewSide toIndex:polyLineNumber3];
            else
                NSLog(@"Poly %d does not have a link to me (Line %d)?", [clockwisePolygon index], [self index]);
            
            //flags |= LELineSolid;
            
            return theNewSide;
        }
    } else if (sideToReturn == _counter_clockwise) {
        if (counterclockwisePolygonSideObject != nil) {
            return counterclockwisePolygonSideObject;
        } else {
            LESide *theNewSide = [theLELevelDataST addObjectWithDefaults:[LESide class]];
            int polyLineNumber4 = [conterclockwisePolygon getLineNumberFor:self];
            
            ///NSLog(@"theNewSide index: %d", [theNewSide index]);
            
            NSParameterAssert(theNewSide != nil);
            //NSParameterAssert(polyLineNumber4 != -1); // Handled Bellow...
            
            [theNewSide setPolygonObject:conterclockwisePolygon];
            [theNewSide setLineObject:self];
            
            counterclockwisePolygonSideObject = theNewSide;
            
            if (polyLineNumber4 != -1) {
                [conterclockwisePolygon setSidesObject:theNewSide toIndex:polyLineNumber4];
            } else {
                NSLog(@"Poly %d does not have a link to me (Line %d)?", [conterclockwisePolygon index], [self index]);
            }
            
            //flags |= LELineSolid;
            
            return theNewSide;
        }
    }
    
    return nil;
}

-(void)removeSideFor:(LESideDirection)sideDirectionToRemove
{
    if (sideDirectionToRemove == _clockwise)
    {
        if (clockwisePolygonSideObject != nil)
            [theLELevelDataST deleteSide:clockwisePolygonSideObject];
        
        clockwisePolygonSideObject = nil;
    }
    else if (sideDirectionToRemove == _counter_clockwise)
    {
        if (counterclockwisePolygonSideObject != nil)
            [theLELevelDataST deleteSide:counterclockwisePolygonSideObject];
        
        counterclockwisePolygonSideObject = nil;
    }
}


@end
