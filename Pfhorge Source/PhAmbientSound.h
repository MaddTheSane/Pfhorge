//
//  PhAmbientSound.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jul 08 2001.
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

//#define AMBIENT_SOUND_TAG 'ambi'

// Check out if Alpha has this limitation!!!
#define MAXIMUM_AMBIENT_SOUND_IMAGES_PER_MAP 64

@interface PhAmbientSound : PhAbstractName <NSCoding>
{
        // Came from ambient_sound_image_data structure in LEMarathon2Structres.h... :)
        
        // non-directional ambient component
        
        // As far as I know, there are no
        // flags for ambient sounds!
	unsigned short flags;

	short sound_index;
	short volume;

	short unused[5];
}

// **************************  Coding/Copy Protocal Methods  *************************
- (void) encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

// *****************   Set Accsessors   *****************

-(void)setFlags:(unsigned short)v;

-(void)setSound_index:(short)v;
-(void)setVolume:(short)v;

// *****************   Get Accsessors   *****************

-(unsigned short)getFlags;

-(short)getSound_index;
-(short)getVolume;

// ************************** Inzlizations And Class Methods *************************

//+(void)setEverythingLoadedST:(BOOL)theChoice;

@end
