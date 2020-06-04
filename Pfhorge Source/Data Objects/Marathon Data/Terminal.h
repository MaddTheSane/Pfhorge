//
//  Terminal.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Mar 10 2002.
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
#import "PhAbstractName.h"

/*! terminal flags */
typedef NS_ENUM(unsigned short, PhTerminalFlags) {
    /*! if this is on, the text is xored with
    hex 0000FEED (repeated indefinitely) */
    term_disguised = 0x0001
};

/*!
 *	The data for a single terminal consists of
 *		a header,
 *		some number of section descriptors,
 *		some number of text style descriptors,
 *		the text itself, possibly disguised.
 *
 *	A 'term' chunk in an M2 level consists of
 *	the data for all the terminals appended.
 */
typedef struct term_head {
    /*! the size (header included) of this terminal */
	short size;
    /*! flags, see above */
	PhTerminalFlags flags;
    /*! the number of text lines to show at once (I think).
    always 22 in Bungie's levels.absent in the preview */
	short line_count;
    /*! the number of text sections */
	short section_count;
    /*! the number of text style changes */
	short style_count;
} term_head;

@class TerminalSection;

@interface Terminal : PhAbstractName <NSSecureCoding>
{
    NSMutableArray<TerminalSection*> *theSections;
    PhTerminalFlags flags;
    short lineCount;
    BOOL textEncoded;
}

-(id)initWithTerminalData:(NSData *)data terminalNumber:(int)theTerminalNumber withLevel:(LELevelData *)levelDataObj;

@property (retain) NSMutableArray<TerminalSection*> *theSections;
-(BOOL)doYouHaveThisSection:(TerminalSection *)theSec;
@property PhTerminalFlags flags;
@property short lineCount;

-(NSData *)getTerminalAsMarathonData;

@end


