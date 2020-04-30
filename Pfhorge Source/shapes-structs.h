#define SHAPES_STRUCTS

#include <stdint.h>

typedef unsigned char	byte;
typedef unsigned short	word;
typedef int32_t		fixed;
typedef unsigned char	pixel8;
#define NONE	-1
#define MAX_COLLECTIONS	32

#define GET_BYTE(ptr)		(*(byte *)ptr++)
#define GET_WORD(ptr)		GetBEShort(&ptr)
#define GET_SHORT(ptr)		GetBEWord(&ptr)
#define GET_LONG(ptr)		GetBELong(&ptr)

#define PUT_BYTE(n, ptr)	*((byte *)ptr)++ = (n)
#define PUT_WORD(n, ptr)	*((word *)ptr)++ = (n)
#define PUT_SHORT(n, ptr)	*((short *)ptr)++ = (n)
#define PUT_LONG(n, ptr)	*((int *)ptr)++ = (n)
#define PUT_PTR(n, ptr)		*((byte **)ptr)++ = (n)

#define MAX_FRAME_INDEXES_PER_SEQ			100
#define SIZEOF_collection_header			32
#define SIZEOF_collection_definition		544
#define SIZEOF_high_level_shape_definition	90
#define SIZEOF_low_level_shape_definition	36
#define SIZEOF_rgb_color_value				8
#define SIZEOF_bitmap_definition			30
#define SIZEOF_original_ptr					4	// m2 uses 32-bit pointers

/* ---------- collection definition structure */
/* 2 added pixels_to_world to collection_definition structure */
/* 3 added size to collection_definition structure */
#define COLLECTION_VERSION 3

/* at the beginning of the clut, used by the extractor for various opaque reasons */
#define NUMBER_OF_PRIVATE_COLORS 3

enum {						/* collection types */
	_unused_collection = 0,	/* raw */
	_wall_collection,		/* textures, landscapes: raw, column order */
	_object_collection,		/* monsters, weapons, items: rle */
	_interface_collection,	/* interface parts: raw, row order */
	_scenery_collection		/* scenery: rle */
};

struct collection_definition {
	short	version;
	short	type;					/* used for get_shape_descriptors() */
	word	flags;					/* [unused.16] */
	short	color_count,
			clut_count;
	long	color_table_offset;		/* an array of clut_count arrays of color_count ColorSpec structures */
	short	high_level_shape_count;
	long	high_level_shape_offset_table_offset;
	short	low_level_shape_count;
	long	low_level_shape_offset_table_offset;
	short	bitmap_count;
	long	bitmap_offset_table_offset;
	short	pixels_to_world;		/* used to shift pixel values into world coordinates */
	long	size;					/* used to assert offsets */
//	short	unused[253];
};
typedef struct collection_definition collection_definition;

/* ---------- high level shape definition */
#define HIGH_LEVEL_SHAPE_NAME_LENGTH 32

struct high_level_shape_definition {
	short	type;					/* ==0 */
	word	flags;					/* [unused.16] */
	char	name[HIGH_LEVEL_SHAPE_NAME_LENGTH + 2];
	short	number_of_views;
	short	frames_per_view,
			ticks_per_frame;
	short	key_frame;
	short	transfer_mode;
	short	transfer_mode_period;	/* in ticks */
	short	first_frame_sound,
			key_frame_sound,
			last_frame_sound;
	short	pixels_to_world;
	short	loop_frame;
	short	unused[14];
	short	low_level_shape_indexes[1];
};
typedef struct high_level_shape_definition	high_level_shape_definition;

/* --------- low-level shape definition */
#define _X_MIRRORED_BIT 0x8000
#define _Y_MIRRORED_BIT 0x4000
#define _KEYPOINT_OBSCURED_BIT 0x2000

struct low_level_shape_definition {
	word	flags;						/* [x-mirror.1] [y-mirror.1] [keypoint_obscured.1] [unused.13] */
	fixed	minimum_light_intensity;	/* in [0,FIXED_ONE] */
	short	bitmap_index;
	short	origin_x, origin_y;			/* (x,y) in pixel coordinates of origin */
	short	key_x, key_y;				/* (x,y) in pixel coordinates of key point */
	short	world_left, world_right, world_top, world_bottom;
	short	world_x0, world_y0;
//	short	unused[4];
};
typedef struct low_level_shape_definition low_level_shape_definition;


enum {
	SELF_LUMINESCENT_COLOR_FLAG= 0x80	// what is this??? Unshadable color?
};

struct rgb_color_value {
	byte	flags;
	byte	value;
	word	red, green, blue;
};
typedef struct rgb_color_value	rgb_color_value;


enum {	/* bitmap flags */
	_COLUMN_ORDER_BIT= 0x8000,
	_TRANSPARENT_BIT= 0x4000
};

struct bitmap_definition {
	short	width, height;		/* in pixels */
	short	bytes_per_row;		/* if == NONE this is a transparent RLE shape */
	short	flags;				/* [column_order.1] [unused.15] */
	short	bit_depth;			/* should always be ==8 */
	short	unused[8];
	pixel8	*row_addresses[1];
};
typedef struct bitmap_definition	bitmap_definition;


struct collection_header {		// 32 bytes
	short	status;
	word	flags;
	
	// used only in the file
	long	offset, length;		// for 8 bit screen
	long	offset16, length16;	// for 16/32 bit and OpenGL
	
	// stuff used in the past for holding pointers to coll data, unused in file
//	short	unused[6];
};
typedef struct collection_header collection_header;


typedef short shape_descriptor;	/* [clut.3] [collection.5] [shape.8] */

enum {	/* animation types */
	_animated1= 1,
	_animated2to8= 2, /* ?? */
	_animated3to4= 3,
	_animated4= 4,
	_animated5to8= 5,
	_animated8= 8,
	_animated3to5= 9,
	_unanimated= 10,
	_animated5= 11
};

short GetBEShort(unsigned char **p);
word GetBEWord(unsigned char **p);
int GetBELong(unsigned char **p);
