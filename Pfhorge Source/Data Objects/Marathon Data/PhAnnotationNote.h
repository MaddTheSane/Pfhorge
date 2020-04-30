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
        
	short	type;	// turns into color, font, size, style, etc...

	NSPoint	location;	// where to draw this (lower left)
	short	polygon_index;	// only displayed if this polygon is in the automap
        id	polygon_object;

	NSString	*text;
        
        NSRect bounds;
        NSSize size;
        
        PhNoteGroup *group;
}

-(id)initWithAdjPoint:(NSPoint)point;

- (void)setX32:(int)v;
- (void)setY32:(int)v;
- (void)set32X:(int)v;
- (void)set32Y:(int)v;

-(NSPoint)as32Point;

// **************************  Coding/Copy Protocal Methods  *************************
- (void) encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

// *****************   Set Accsessors   *****************

-(void)setGroup:(PhNoteGroup *)grp;

-(void)setType:(short)v;

-(void)setLocation:(NSPoint)v;

-(void)setLocationX:(int)v;
-(void)setLocationY:(int)v;

-(void)setPolygon_index:(short)v;
-(void)setPolygon_object:(LEPolygon *)v;
-(void)setPolygon:(LEPolygon *)v;

-(void)setText:(NSString *)v;

-(void)updateBounds;

// *****************   Get Accsessors   *****************

-(NSRect) drawingBounds;

-(PhNoteGroup *)group;
-(PhNoteGroup *)getGroup;

-(short)getType;

-(NSPoint)getLocation;
-(NSPoint)getLocationAdjusted;

-(short)getPolygon_index;
-(LEPolygon *)getPolygon_object;
- (LEPolygon *)polygon;

-(NSString *)getText;

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice;

@end
