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

enum {
    _use_parmanent_settings,
    _parmanent_solid,
    _parmanent_transparent,
    _parmanent_landscape,
    _parmanent_no_sides
};

typedef NS_OPTIONS(unsigned short, LELineFlags) {
	SOLID_LINE_BIT = 0x4000,
	TRANSPARENT_LINE_BIT = 0x2000,
	LANDSCAPE_LINE_BIT = 0x1000,
	ELEVATION_LINE_BIT = 0x800,
	VARIABLE_ELEVATION_LINE_BIT = 0x400,
	LINE_HAS_TRANSPARENT_SIDE_BIT = 0x200
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
    
    /*! the side definition facing the clockwise polygon which references this side,
        and the side definition facing the counterclockwise polygon (can be NONE (-1)) */
    short clockwisePolygonSideIndex, counterclockwisePolygonSideIndex;
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
    
    //short 6 unused shorts... :)
}



// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

// ************************** Flag Accssors *************************

- (BOOL)getFlagSS:(short)v;
- (void)setFlag:(unsigned short)theFlag to:(BOOL)v;

- (BOOL)getPermanentSetting:(int)settingToSet;
- (void)setPermanentSetting:(int)settingToSet to:(BOOL)value;

// ************************** Utilites *************************
- (NSBezierPath *)clockwiseShadowPath;

// ************************** Get Accsessors *************************

- (short)pointIndex1;
- (short)pointIndex2;
- (short)getP1;
- (short)getP2;
- (LEMapPoint *)getMapPoint1;
- (LEMapPoint *)getMapPoint2;

- (LELineFlags)getFlags;

- (short)getLength;

- (short)getAngle;		//!< 0-512 Marathon units from p1 to p2
- (short)getFlippedAngle;	//!< From p2 to p1 ((getAngle+256)%512)
- (short)getAzimuth;		//!< Degrees clockwise from vertical from p1 to p2
- (short)getFlippedAzimuth;	//!< From p2 to p1 ((getAzimuth+180)%360)

- (short)getHighestAdjacentFloor;
- (short)getLowestAdjacentCeiling;

- (short)getClockwisePolygonSideIndex;
- (short)getCounterclockwisePolygonSideIndex;

- (id)getClockwisePolygonSideObject;
- (id)getCounterclockwisePolygonSideObject;

- (short)getClockwisePolygonOwner;
- (short)getConterclockwisePolygonOwner;
- (short)getClockwisePolygonIndex;
- (short)getConterclockwisePolygonIndex;

- (LEPolygon *)getClockwisePolygonObject;
- (LEPolygon *)getConterclockwisePolygonObject;

// ************************** Set Accsessors *************************

- (void)setPointIndex1:(short)s;
- (void)setPointIndex2:(short)s;
- (void)setP1:(short)s;
- (void)setP2:(short)s;
- (void)setMapPoint1:(LEMapPoint *)s;
- (void)setMapPoint2:(LEMapPoint *)s;
- (void)setMapPoint1:(LEMapPoint *)s1 mapPoint2:(LEMapPoint *)s2;
- (void)setFlags:(LELineFlags)us;
- (void)setLength:(short)s;
- (void)setAngle:(short)s;		//!< 0-512 Marathon units from p1 to p2
- (void)setAzimuth:(short)s;		//!< Degrees clockwise from vertical, p1 to p2
- (void)setHighestAdjacentFloor:(short)s;
- (void)setLowestAdjacentCeiling:(short)s;

- (void)setClockwisePolygonSideIndex:(short)s;
- (void)setCounterclockwisePolygonSideIndex:(short)s;

- (void)setClockwisePolygonSideObject:(id)s; //
- (void)setCounterclockwisePolygonSideObject:(id)s; //

- (void)setClockwisePolygonOwner:(short)s;
- (void)setConterclockwisePolygonOwner:(short)s;
- (void)setClockwisePolygonIndex:(short)s;
- (void)setConterclockwisePolygonIndex:(short)s;

- (void)setClockwisePolygonObject:(LEPolygon *)s;
- (void)setConterclockwisePolygonObject:(LEPolygon *)s;

- (LEPolygon *)getPolyFromMe;
- (BOOL)isThereAClockWiseLineAlpha:(LEMapPoint *)alphaPoint beta:(LEMapPoint *)betaPoint theLine:(LELine *)currentLine;

-(void)recalc;

@end

@interface LELine (SideCalculations)
// **************************  Side Rotines  *************************
- (void)caculateSides;
- (void)setupWithClockPlat:(PhPlatform *)cPlat counterClockPlat:(PhPlatform *)ccPlat;
- (void)setupAsNonPlatformLine;
- (LESide *)setupSideFor:(int)sideDirection asA:(int)sideType;
- (LESide *)setupSideFor:(int)sideToReturn;
- (void)removeSideFor:(int)sideDirectionToRemove;
@end
