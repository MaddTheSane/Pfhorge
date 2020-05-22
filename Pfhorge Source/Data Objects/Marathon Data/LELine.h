//
//  LELine.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 17 2001.
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
#import "LEMapStuffParent.h"
#import "LESide.h"
#import "LEExtras.h"

typedef NS_ENUM(int, LELinePermanentSettings) {
    LELinePermanentUse,
    LELinePermanentSolid,
    LELinePermanentTransparent,
    LELinePermanentLandscape,
    LELinePermanentNoSides
};

typedef NS_OPTIONS(unsigned short, LELineFlags) {
	LELineSolid = 0x4000,
	LELineTransparent = 0x2000,
	LELineLandscape = 0x1000,
	LELineElevation = 0x800,
	LELineVariableElevation = 0x400,
	LELineVariableHasTransparentSide = 0x200
};

@class LEMapPoint, LEPolygon, LESide, PhPlatform, NSBezierPath;

@interface LELine : LEMapStuffParent <NSCoding>
{
    short p1, p2;
    LEMapPoint *mapPoint1, *mapPoint2;
    LELineFlags flags; /*!< no permutation field */
    short _Length;
    short _Angle;
    short _Azimuth;
    
    //! Mabye make these pointers to the polygons themselves???
    short highestAdjacentFloor, lowestAdjacentCeiling;
    
    //short clockwisePolygonSideIndex, counterclockwisePolygonSideIndex;
    /*! the side definition facing the clockwise polygon which references this side,
        and the side definition facing the counterclockwise polygon (can be NONE (-1)) */
    LESide *clockwisePolygonSideObject, *counterclockwisePolygonSideObject;
    
    /*! a line can be owned by a clockwise polygon, a counterclockwise polygon,
        or both (but never two of the same) (can be NONE) */
    short clockwisePolygonIndex, conterclockwisePolygonIndex;
    LEPolygon *clockwisePolygon, *conterclockwisePolygon;
    
    BOOL permanentSolidLine;
    BOOL permanentLandscapeLine;
    BOOL permanentTransparentLine;
    
    BOOL usePermanentSettings;
    
    BOOL permanentNoSides;
}



// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

// ************************** Flag Accssors *************************

- (BOOL)getFlagSS:(short)v;
- (void)setFlag:(unsigned short)theFlag to:(BOOL)v;

- (BOOL)getPermanentSetting:(LELinePermanentSettings)settingToSet;
- (void)setPermanentSetting:(LELinePermanentSettings)settingToSet to:(BOOL)value;

// ************************** Utilites *************************
- (NSBezierPath *)clockwiseShadowPath;

// ************************** Accsessors *************************

@property (nonatomic) short pointIndex1;
@property (nonatomic) short pointIndex2;
- (short)p1 API_DEPRECATED_WITH_REPLACEMENT("-pointIndex1", macos(10.0, 10.7));
- (short)p2 API_DEPRECATED_WITH_REPLACEMENT("-pointIndex2", macos(10.0, 10.7));
@property (nonatomic, assign) LEMapPoint *mapPoint1;
@property (nonatomic, assign) LEMapPoint *mapPoint2;

@property (nonatomic) LELineFlags flags;

@property short length;

//! 0-512 Marathon units from p1 to p2
@property short angle;
//! From p2 to p1 ((getAngle+256)%512)
@property (readonly) short flippedAngle;
//! Degrees clockwise from vertical from p1 to p2
@property short azimuth;
//! From p2 to p1 ((getAzimuth+180)%360)
@property (readonly) short flippedAzimuth;

@property short highestAdjacentFloor;
@property short lowestAdjacentCeiling;

@property (nonatomic) short clockwisePolygonSideIndex;
@property (nonatomic) short counterclockwisePolygonSideIndex;

@property (assign) id clockwisePolygonSideObject;
@property (assign) id counterclockwisePolygonSideObject;

@property (nonatomic) short clockwisePolygonOwner;
@property (nonatomic) short conterclockwisePolygonOwner;
@property (nonatomic) short clockwisePolygonIndex;
@property (nonatomic) short conterclockwisePolygonIndex;

@property (assign) LEPolygon *clockwisePolygonObject;
@property (assign) LEPolygon *conterclockwisePolygonObject;

- (void)setP1:(short)s API_DEPRECATED_WITH_REPLACEMENT("-setPointIndex1:", macos(10.0, 10.7));
- (void)setP2:(short)s API_DEPRECATED_WITH_REPLACEMENT("-setPointIndex2:", macos(10.0, 10.7));
- (void)setMapPoint1:(LEMapPoint *)s1 mapPoint2:(LEMapPoint *)s2;

- (LEPolygon *)getPolyFromMe;
- (BOOL)isThereAClockWiseLineAlpha:(LEMapPoint *)alphaPoint beta:(LEMapPoint *)betaPoint theLine:(LELine *)currentLine;

//! Recalculate length, azimuth, angle
//! Should be called whenever one of these changes
//! Called by \c LEMapPoint to the lines it is part of, when it moves
-(void)recalc;

@end

@interface LELine (SideCalculations)
// **************************  Side Rotines  *************************
- (void)caculateSides;
- (void)setupWithClockPlat:(PhPlatform *)cPlat counterClockPlat:(PhPlatform *)ccPlat;
- (void)setupAsNonPlatformLine;
- (LESide *)setupSideFor:(LESideDirection)sideDirection asA:(LESideType)sideType;
- (LESide *)setupSideFor:(LESideDirection)sideToReturn;
- (void)removeSideFor:(LESideDirection)sideDirectionToRemove;
@end
