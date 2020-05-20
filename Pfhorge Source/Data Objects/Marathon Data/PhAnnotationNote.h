//
//  PhAnnotationNote.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Tue Jul 10 2001.
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
#import "PhAbstractName.h"

//#define ANNOTATION_TAG 'NOTE'
// I think these (both?) are not limitations of Alpha One, look into it!!!
#define MAXIMUM_ANNOTATIONS_PER_MAP	20
// Proably still a limitation, since the map format
// would have to be changed to change this!!!
#define MAXIMUM_ANNOTATION_TEXT_LENGTH	64

@class PhNoteGroup, LEPolygon;

@interface PhAnnotationNote : PhAbstractName <NSCoding>
{
	// From map_annotation structure, in LEMarathon2Structres.h...
        
	//! turns into color, font, size, style, etc...
	short	type;

	//! where to draw this (lower left)
	NSPoint	location;
	//! only displayed if this polygon is in the automap
	//short	polygon_index;
	LEPolygon *polygon_object;

	NSString	*text;
        
	NSRect bounds;
	NSSize size;
        
	PhNoteGroup *group;
}

-(id)initWithAdjPoint:(NSPoint)point;

@property (nonatomic) int x32;
@property (nonatomic) int y32;
- (void)set32X:(int)v API_DEPRECATED_WITH_REPLACEMENT("-setX32:", macos(10.0, 10.7));
- (void)set32Y:(int)v API_DEPRECATED_WITH_REPLACEMENT("-setY32:", macos(10.0, 10.7));

-(NSPoint)as32Point;

// **************************  Coding/Copy Protocal Methods  *************************
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

// *****************   Accsessors   *****************

-(void)setLocationX:(int)v;
-(void)setLocationY:(int)v;

-(void)setPolygon:(LEPolygon *)v API_DEPRECATED_WITH_REPLACEMENT("-setPolygonObject:", macos(10.0, 10.7));

@property (nonatomic, copy) NSString *text;

-(void)updateBounds;

-(NSRect) drawingBounds;

@property (nonatomic, retain) PhNoteGroup *group;
-(PhNoteGroup *)getGroup API_DEPRECATED_WITH_REPLACEMENT("-group", macos(10.0, 10.7));

@property short type;

@property (nonatomic) NSPoint location;
@property (readonly) NSPoint locationAdjusted;

@property (nonatomic) short polygonIndex;
@property (assign) LEPolygon *polygonObject;
- (LEPolygon *)polygon API_DEPRECATED_WITH_REPLACEMENT("-polygonObject", macos(10.0, 10.7));


- (void)setNoteType:(id)noteType;

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice;

@end
