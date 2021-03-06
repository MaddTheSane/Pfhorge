// Marathon-shapes-file data formats
// interpreted by Loren Petrich

#pragma once
#include <CoreFoundation/CoreFoundation.h>


#pragma pack(push, 2)


// Shapes collections:
// All the various stuff displayed
enum {
	Collection_Interface,
	Collection_WeaponsInHand,
	Collection_Juggernaut,
	Collection_Tick,
	Collection_ExplosionEffects,
	Collection_Hunter,
	Collection_Marine,
	Collection_Items,
	Collection_Trooper,
	Collection_PfhorFighter,
	Collection_SphtKr,
	Collection_Flickta,
	Collection_Bob,
	Collection_VacBob,
	Collection_Enforcer,
	Collection_Drone,
	Collection_Spht,
	Collection_Walls_1,
	Collection_Walls_2,
	Collection_Walls_3,
	Collection_Walls_4,
	Collection_Walls_5,
	Collection_Scenery_1,
	Collection_Scenery_2,
	Collection_Scenery_3,
	Collection_Scenery_4,
	Collection_Scenery_5,
	Collection_Landscape_1,
	Collection_Landscape_2,
	Collection_Landscape_3,
	Collection_Landscape_4,
	Collection_Cyborg,
	NUMBER_OF_SHAPES_COLLECTIONS
};

// Shapes subcollections:
// Standard is the one present for more collections;
// if there is more than one present, then
// standard = 8-bit-display version
// custom = 16-bit-display version
enum {
	Subcollection_Standard,
	Subcollection_Custom,
	NUMBER_OF_SHAPES_SUBCOLLECTIONS
};

//! Directory base and step
const int ShapesDirectory_Base = 4;
const int ShapesDirectory_Step = 32;


//! Shapes subdirectory entry:
//! It contains the offset and size of a shapes chunk.
//! If the offset is -1, that means that
//! there is no corresponding shapes chunk.
struct ShapesSubdirEntry {
	int Offset;
	int Size;
	
	//! Convenient C++ methods
	bool Exists() {return ((Offset >= 0) && (Size > 0));}
	ShapesSubdirEntry() {Offset = -1; Size = 0;}
};


//! Shapes directory entry
//! There are two possible subdirectory entries.
struct ShapesDirEntry {
	ShapesSubdirEntry SubdirList[NUMBER_OF_SHAPES_SUBCOLLECTIONS];
	// Appears to be nothing significant after these
};


// Much of this description has been copied
// from marathon-specs.txt (M1 shapes header),
// with modifications noted as appropriate.


//! This is to get around "fixed" being in namespace "std"
typedef int _fixed;

// End of a lot of LP stuff


/*! shapes classes */
typedef CF_ENUM(short, shapes_header_class)
{
   //! not used
   _shapeUnused,
   //! usually 128x128 pixels, but not always
   _shapeTexture, /* RAW */
   //! all monsters, guns, objects...
   _shapeSprite, /* RLE */
   //! everything that doesn't go in the window
   _shapeInterface, /* RAW */
   //! ???
   _shapeScenery /* RLE */
};


/*
	LP: At the beginning of each shapes chunk is this header object
	This struct is copied from marathon-specs.txt (M1 shapes header)
	the "_address" and the "_table" values are relative to the start
	of the shapes chunk.
*/
struct shapes_header /* 544 bytes */
{
   //! always equals 3
   short type; 
// C++ reserved word
//   short class;
   //! see above
   shapes_header_class shape_class;
   
   unsigned short flags; 

   //! number of color entries in each palette
   short color_count;
   //! number of palettes (different palettes are used for different
   //! "variations" of monsters)
   short palette_count;
   //! offset to first palette
   int first_palette_address;

   //! number of high-level shapes
   short high_level_shapes_count;
   //! offset to table of addresses of high-level shape
   //! records
   int high_level_shapes_table;

   //! number of low-level shapes
   short low_level_shapes_count;
   //! offset to table of addresses of low-level shape records
   int low_level_shapes_table;

   //! number of images
   short image_count;
   //! offset to table of addresses of images
   int image_table;

   short scale_factor;
   //! size of entire resource
   int size;

   short unused[253];
};

/*
LP: The size includes the header, and is also the size of a M2/Moo shapes chunk

LP: None of the "unused" stuff is used in M2/Moo

Also, high-level shapes are sequences
and low-level shapes are frames
*/

/*
	LP:
	There are palette_count of palettes,
	each of which has color_count color values,
	which are color_entry structs.
	They are stored as one contiguous group.
*/

struct color_entry /* 8 bytes */
{
   short entry_number; /*!< ranges from 0 to color_count - 1 */
   unsigned short red;
   unsigned short green;
   unsigned short blue;
};


/*
	LP: Sequence objects:
	
	High-level shape types and flags were not specified in marathon-specs.txt
	
	These objects are preceded by an offset list,
	a list of long integers that specifies the offset of each object from
	the beginning of the shapes chunk.
*/

struct high_level_shape /* 88 bytes */
{
   //! see above
   short type;
   //! see above
   unsigned short flags;

   //! length of name string (i.e. this is a Pascal string)
   char name_length;
   //! ASCII string
   char name[33];

   //! number of angles at which this animation can be viewed. This should
   //! only be 1, 2, 5, or 8.
   short view_count;
   //! number of frames of animation
   short frames_per_view;
   //! speed of animation
   short ticks_per_frame;

   //! frame at which "something happens"?
   short key_frame;

   short transfer_mode;
   //! absolutely no idea...
   short transfer_mode_period; /* in ticks */

   //! 'snd ' resource to play at start of animation
   short first_frame_sound;
   //! 'snd ' resource to play at key frame
   short key_frame_sound;
   //! 'snd ' resource to play at end of animation
   short last_frame_sound;

   short scale_factor;

   short unused[15];

   //frame information
};

/*

After this comes the frame information, which is a series of 2-byte words, each
corresponding to a low-level shape. There will be view_count * frames_per_view
entries, followed by 2 bytes of zero signifying to end of the animation. Note
that if view_count equals 5, then it's really 8 * frames_per_view entries.

LP: Each shapes object is followed by its list of frame indices.
The number of them is (number of views) * (number of frames per view) + 1,
with the last one always being zero. The frames are grouped by view, and have no
zero values separating these groups. View 0's frames, view 1's frames, ...,
0.

Here is the dictionary from the file's view_count value to its true value:

1	1
3	4
4	4
5	8
8	8
9	5
10	1 (not animated)
*/


/*

	LP: Frame objects:

	These objects are preceded by an offset list,
	a list of long integers that specifies the offset of each object from
	the beginning of the shapes chunk.

*/

/*! low-level shape flags */
typedef CF_ENUM(unsigned short, low_level_shape_flags)
{
   //! indicates that the sprite is to be drawn from right to left
   //! rather than left to right
   _lowShapeXMirror =    0x8000,
   //! similar to _lowShapeXMirror, but affects drawing vertically
   //! rather than horizontally. It doesn't seem to be implemented
   _lowShapeYMirror =    0x4000,
   
   _lowShapeKeyObscure = 0x2000
};

struct low_level_shape /* 36 bytes */
{
   low_level_shape_flags flags;

   //! minimum light value that can be assigned to this
   //! image. Used for "bright" sprites, such as explosions, that are never supposed to
   //! be dark.
   _fixed minimum_light_intensity;
   //! indicates which image is used to draw this low-level shape
   short image_index;
   //! center of shape? Who knows..
   short x_origin, y_origin;
   //! no idea..
   short x_key, y_key;
   //! defines the bounding rectangle?
   short left, right, top, bottom;
   //! no idea..
   short world_x_origin, world_y_origin;

   short unused[4];
};

/*

	LP: Image objects:

	In M2/Moo, these objects are preceded by an offset list,
	a list of long integers that specifies the offset of each object from
	the beginning of the shapes chunk.

*/

struct image_header /* 26 bytes */
{
   //! width of image
   short width;
   //! height of image
   short height;
   
   short unknown[11]; /* ??? */
};

/*

	Next comes the scan start addresses. These are run-time calculated, so there is
no need to provide valid information here. However, the right amount of space
must be reserved for this block. The size of the block will be width * 4, plus 4
bytes at the end (unknown?).

   And finally comes the actual image data. In RAW format, this is just a block
of bytes, where each byte corresponds to one pixel. The pixels are stored top to
bottom, then right to left. The color of a pixel can be determined by using the
pixel value as an index into the palette.
   RLE format is a little different. It starts with a 2-byte command word. If
this word is greater than zero, it signifies the start of a vertical run of
pixels. The pixel data follows immediately, and the number of pixels is equal to
the command word. If the command word is negative, it signifies the start of a
vertical "skip" in which no pixels are drawn (a hole). The length of the skip
will be equal to negative the value of the command word. If the command word is
zero, it signifies the start of the next vertical column, which will start one
pixel to the right of the start of the first column. The command words are
repeated until the entire sprite is drawn.

	LP: The scan-start address block must be computed using:
	
	_shapeTexture -- width
	_shapeSprite -- width
	_shapeInterface -- height
	
	The actual size is 4*(<this> + 1)
	
	The encoding used is either RAW (simply dump the pixel values)
	or RLE (run-length encoding)
	
	_shapeTexture -- RAW
	_shapeSprite -- RLE
	_shapeInterface -- RAW
	
	Resulting image:
	
	_shapeTexture -- (top to bottom), left to right
		Walls: flip using top-left to bottom-right line as the axis
			(rotate 90d clockwise, then flip horizontal, for example)
		Landscapes: flip vertically
	_shapeSprite -- (top to bottom), left to right
	 	Arrangement is like the walls
	_shapeInterface -- (left to right), top to bottom
		Normal scan order
	
	Marathon 2/oo RLE is different from Marathon 1 RLE.
	Each column is specified in the following manner:
	There are two shorts at the beginning, the first one being the row
	where the first pixel starts, and the second one being the row just below
	the last pixel. These two shorts are followed by those pixels.
	Anything outside of those pixels has the transparent color (index 0).
	
	Also, there's some nonzero values in "image_header" after "width" and "height".
*/


#pragma pack(pop)
