//
//  TerminalSection.h
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
#import <AppKit/AppKit.h>

typedef struct term_section {	/*	section descriptor */
	short flags;		/*	no idea.  always 0 in Bungie's levels */
//	short type; 		/* _information_text, _checkpoint_text, _briefing_text, _movie, _sound_bite, _soundtrack */
	short type;		/*	section type, see below */
	short permutation;	/*	meaning varies with type */
	short text_offset;	/*	offset to the first character in the text */
	short text_length;	/*	number of characters in the text */
	short lines;		/*	number of lines in the text. absent in the preview */
} term_section;

enum {
        _no_section_type = -1,
					/*	section types */
	_logon_section = 0,		/*	show picture #id centered with text under it */
	_unfinished_section,		/*	start here if the level is unfinished
                                                    (or if there is no "finished" section) */
	_success_section,		/*	start here if the level is finished */
	_failure_section,
	_information_section,
	_delimiter_section,		/*	stop here */
	_new_level_teleport_section, 	/*	go to level #id (256 means game finished) */
	_map_teleport_section, 		/*	teleport to polygon #id */
	_checkpoint_section, 		/*	show a map view centered on goal object #id
                                                    on the left and text on the right
                                                    (was in the preview but not in the demo
                                                    or full versions) */
	_sound_section, 		// permutation is the sound id to play
	_movie_section, 		// permutation is the movie id to play
	_track_section, 		// permutation is the track to play
	_pict_section, 			/*	show picture #id on the left and text on the right */
	_logoff_section, /* = 13		show picture #id centered with text under it
                                                    (just like signon) */ 
	_camera_section, 		//  permutation is the object index
	_static_section, 		// permutation is the duration of static.
	_tag_section, 			// permutation is the tag to activate

	NUMBER_OF_SECTION_TYPES
};

enum // flags to indicate text styles for paragraphs
{
	_plain_text      = 0x00,
	_bold_text       = 0x01,
	_italic_text     = 0x02,
	_underline_text  = 0x04
};

enum { /* terminal grouping/section flags */
	_draw_object_on_right= 0x01,  // for drawing checkpoints, picts, movies.
	_center_object= 0x02
};

enum {
    ///SIZEOF_wad_header		= 128,
    ///SIZEOF_old_directory_entry	= 8,
    ///SIZEOF_directory_entry		= 10,
    ///SIZEOF_old_entry_header		= 12,
    ///SIZEOF_entry_header		= 16,
    ///SIZEOF_directory_data		= 74,
    ///SIZEOF_static_data		= 88,
    SIZEOF_terminal_groupings	= 12,
    SIZEOF_text_face_data	= 6
};


typedef struct term_style {		/*	text style descriptor */
	short 		offset;		/*	offset into the text where this style starts */
	unsigned short 	face;		/*	bold, italic, etc. in standard QD notation */
	short 		color;		/*	0=green, 1=white, 2=red, 3=dim green,
                                                    4=cyan, 5=yellow, 6=dim red, 7=blue.
                                                    for exact info, see the last eight colours
                                                    of clut #130 in the Marathon 2 application */
} term_style;

#import "PhAbstractName.h"

@interface TerminalSection : PhAbstractName <NSCoding>
{
    NSMutableAttributedString *theText;
    short flags;	/*	section flags, see above */
    short type;		/*	section type, see above */
    short permutation;	/*	meaning varies with type */
    short text_offset;	/*	offset to the first character in the text */
    short text_length;	/*	number of characters in the text */
    short lines;	/*	number of lines in the text. Absent in the preview (demo?) */
    
    id	 permutationObject;
    
    NSFont *regularFont;
    NSFont *boldFont;
    NSFont *italicFont;
    NSFont *condensedFont;
    NSFont *expandedFont;
    NSFont *underlinedFont;
}

-(id)initWithData:(NSData *)sectionData
        withFonts:(NSData *)fontData
         withText:(NSData *)textData
        withLevel:(LELevelData *)levelDataObj;

-(NSMutableParagraphStyle *)setNameAndReturnStyleFromType;

-(short)type;
-(void)setType:(short)value;

-(short)permutation;
-(void)setPermutation:(short)value;

-(id)permutationObject;
-(void)setPermutationObject:(id)value;

-(NSMutableAttributedString *)text;
-(NSMutableAttributedString *)textPointer;
-(void)setText:(NSMutableAttributedString *)value;

-(void)appendMarathonToText:(NSMutableData *)theTextData toFonts:(NSMutableData *)theFontData toGroups:(NSMutableData *)theGroupData;
                                     
@end



