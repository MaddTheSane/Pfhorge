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

/*! section types */
typedef NS_ENUM(short, PhTerminalSectionType) {
    PhTerminalSectionTypeNone = -1,

    /*! show picture #id centered with text under it */
    PhTerminalSectionTypeLogOn = 0,
    /*! start here if the level is unfinished
    (or if there is no "finished" section) */
    PhTerminalSectionTypeUnfinished,
    /*! start here if the level is finished */
    PhTerminalSectionTypeSuccess,
    PhTerminalSectionTypeFailure,
    PhTerminalSectionTypeInformation,
    /*! stop here */
    PhTerminalSectionTypeDelimiter,
    /*! go to level #id (256 means game finished) */
    PhTerminalSectionTypeLevelTeleport,
    /*! teleport to polygon #id */
    PhTerminalSectionTypeInMapTeleport,
    /*! show a map view centered on goal object #id
    on the left and text on the right
    (was in the preview but not in the demo
    or full versions) */
    PhTerminalSectionTypeCheckpoint,
    //! permutation is the sound id to play
    PhTerminalSectionTypeSound,
    //! permutation is the movie id to play
    PhTerminalSectionTypeMovie,
    //! permutation is the track to play
    PhTerminalSectionTypeTrack,
    /*! show picture #id on the left and text on the right */
    PhTerminalSectionTypePict,
    /*! show picture #id centered with text under it
    (just like signon) */
    PhTerminalSectionTypeLogOff,
    //! permutation is the object index
    PhTerminalSectionTypeCamera,
    //! permutation is the duration of static.
    PhTerminalSectionTypeStatic,
    //! permutation is the tag to activate
    PhTerminalSectionTypeTag,

    //NUMBER_OF_SECTION_TYPES
};

//! flags to indicate text styles for paragraphs
typedef NS_OPTIONS(unsigned short, PhTerminalSectionFace)
{
    PhTerminalSectionPlain      = 0x00,
    PhTerminalSectionBold       = 0x01,
    PhTerminalSectionItalic     = 0x02,
    PhTerminalSectionUnderline  = 0x04
};

/*! terminal grouping/section flags */
typedef NS_OPTIONS(unsigned short, TerminalSectionFlags) {
    //! for drawing checkpoints, picts, movies.
    _draw_object_on_right= 0x01,
	
    _center_object= 0x02
};

/*! section descriptor */
typedef struct term_section {
    /*!no idea.  always 0 in Bungie's levels */
	short flags;
//	short type; 		/* _information_text, _checkpoint_text, _briefing_text, _movie, _sound_bite, _soundtrack */
    /*! section type, see above */
	PhTerminalSectionType type;
    /*! meaning varies with type */
	short permutation;
    /*! offset to the first character in the text */
	short text_offset;
    /*! number of characters in the text */
	short text_length;
    /*! number of lines in the text. absent in the preview */
	short lines;
} term_section;


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

/*! text style descriptor */
typedef struct term_style {
    /*! offset into the text where this style starts */
	short 		offset;
    /*! bold, italic, etc. in standard QD notation */
	PhTerminalSectionFace 	face;
    /*! 0=green, 1=white, 2=red, 3=dim green,
    4=cyan, 5=yellow, 6=dim red, 7=blue.
    for exact info, see the last eight colours
    of clut #130 in the Marathon 2 application */
	short 		color;
} term_style;

#import "PhAbstractName.h"

@interface TerminalSection : PhAbstractName <NSCoding>
{
    NSMutableAttributedString *theText;
    TerminalSectionFlags flags;	/*!<	section flags, see above */
    PhTerminalSectionType type;
    short permutation;
    short text_offset;	/*!<	offset to the first character in the text */
    short text_length;	/*!<	number of characters in the text */
    short lines;	/*!<	number of lines in the text. Absent in the preview (demo?) */
    
    __weak __kindof LEMapStuffParent	*permutationObject;
    
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
/*! section type, see above */
@property (nonatomic) PhTerminalSectionType type;

/*! meaning varies with type */
@property short permutation;

@property (weak) id permutationObject;

-(NSMutableAttributedString *)text;
-(NSMutableAttributedString *)textPointer;
-(void)setText:(NSAttributedString *)value;

-(void)appendMarathonToText:(NSMutableData *)theTextData toFonts:(NSMutableData *)theFontData toGroups:(NSMutableData *)theGroupData;
                                     
@end



