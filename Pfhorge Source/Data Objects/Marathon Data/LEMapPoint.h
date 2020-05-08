//
//  LEMapPoint.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sat Jun 16 2001.
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

@class LELine;

@interface LEMapPoint : LEMapStuffParent <NSCoding, NSCopying>
{
    short x, y, y32, x32; //Cordenates Of The Point
    //BOOL cleanUp; //No Longer In The Map, and should be deleted at the next opportinuity...
    NSMutableSet<LELine*> *lines; //Index of lines that this point is apart of
}


// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

-(id)initX32:(short)theX32 Y32:(short)theY32;
-(id)initX:(short)theX Y:(short)theY;

// Faster to use  setX:setY:  as a single message to
// setting both, because there are a few things that need to be recaculated
// and if you use  setX:  then a seperate  setY:  method, it will caculate it twice...
-(void)setX:(short)theX Y:(short)theY;
-(void)setX:(short)theX;
-(void)setY:(short)theY;
-(void)setX32:(short)theX;
-(void)setY32:(short)theY;
-(void)set32X:(short)theX;
-(void)set32Y:(short)theY;

-(NSPoint)asPoint;
-(NSPoint)as32Point;
-(NSRect)as32Rect;
-(NSSet *)getLinesAttachedToMe;
-(NSArray *)linesAttachedToMeAsArray;
//-(void)scanForLineChanges;
-(void)lineConnectedToMe:(LELine *)obj;
-(void)lineDisconnectedFromMe:(LELine *)obj;

-(void)tellLinesAttachedToMeToRecalc;

-(short)xgl;
-(short)ygl;
-(short)x32;
-(short)y32;
-(short)x;
-(short)y;
-(short)getX;
-(short)getY;

-(void)scanAndUpdateLines;

// These are methods that we probably wouldn't bother with if we weren't scriptable.
- (NSScriptObjectSpecifier *)objectSpecifier;


// High School Geometry Functions

-(LEMapPoint *)nearestMapPointInRange:(int)maxDist;
-(LEMapPoint *)nearestGridPointInRange:(int)maxDist;

-(short)distanceToPoint:(LEMapPoint *)target;
-(short)distanceToNSPoint:(NSPoint)target;

@end
