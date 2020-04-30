// Shapes file decoding utilities
// 2001 Tito Dal Canton, for the AlephOne project
#include <stdio.h>
#include <errno.h>
#include "shapes-structs.h"
#include "bitmap-decode.h"

collection_header	coll_hdrs[MAX_COLLECTIONS];
byte				*colls[MAX_COLLECTIONS];
FILE				*shapes;
int					bit_depth = 8;

// load headers of a shapes file
int LoadShapes(FILE *f, int depth)
{
	int	i;

	if (f == NULL)
		return 1;
	shapes = f;
	bit_depth = depth;

	// load 32 collection_headers
	for (i = 0; i < MAX_COLLECTIONS; i++) {
		byte	b[SIZEOF_collection_header];
		byte	*bp = b;

		// read the data block
		if (fread(b, SIZEOF_collection_header, 1, f) != 1)
			return EIO;
		// unpack the 68k-aligned data
		coll_hdrs[i].status = GET_SHORT(bp);
		coll_hdrs[i].flags = GET_WORD(bp);
		coll_hdrs[i].offset = GET_LONG(bp);
		coll_hdrs[i].length = GET_LONG(bp);
		coll_hdrs[i].offset16 = GET_LONG(bp);
		coll_hdrs[i].length16 = GET_LONG(bp);
		colls[i] = NULL;	// mark this collection as unloaded
	}
	return 0;
}

// load a collection from file and store it internally
int LoadCollection(int coll, FILE *f)
{
	long	offs, len;
	int		version, type;
	byte	*p;

	// get the offset/length in file of this collection
	if (bit_depth == 8 || coll_hdrs[coll].offset16 == -1 || coll_hdrs[coll].length16 == -1) {
		offs = coll_hdrs[coll].offset;
		len = coll_hdrs[coll].length;
	} else {
		offs = coll_hdrs[coll].offset16;
		len = coll_hdrs[coll].length16;
	}
	if (offs <= 0 || len <= 0)	// this collection doesn't exist
		return EINVAL;
	// allocate space for the data and load it from file
	colls[coll] = (byte *)malloc(len);
	if (colls[coll] == NULL)
		return errno;
	fseek(f, offs, SEEK_SET);
	if (fread(colls[coll], len, 1, f) != 1)
		return EIO;
	p = colls[coll];
	version = GET_SHORT(p);
	type = GET_SHORT(p);
	if (version < 0 || type < 0)	// just in case the first fields are messed up...
		return EIO;
	return 0;
}

void UnloadCollection(int coll)
{
	if (CollIsLoaded(coll))
		free(colls[coll]);
}

int CollIsLoaded(int coll)
{
	return (colls[coll] != NULL);
}

// decode the cluts for the given collection
int DecodeShapesClut(int coll, int clutID, int *outColorNum, rgb_color_value **outColors)
{
	byte	*p;
	int		i, colorsPerClut = 0, clutCount, version, type;
	long	clutOffset = 0;
	int		err = 0;
	word	flags;

	if (!CollIsLoaded(coll)) {
		if (err = LoadCollection(coll, shapes))
			return err;
	}
	// calculate a pointer to the RGB data for this clut
	p = colls[coll];
	version = GET_SHORT(p);
	type = GET_SHORT(p);
	flags = GET_WORD(p);
	colorsPerClut = GET_SHORT(p);
	clutCount = GET_SHORT(p);
	if (clutID >= clutCount)
		return EINVAL;
	clutOffset = GET_LONG(p);
	
	*outColorNum = colorsPerClut;
	*outColors = (rgb_color_value *)malloc(sizeof(rgb_color_value) * colorsPerClut);
	if (outColors == NULL)
		return errno;
	p = colls[coll] + clutOffset + (SIZEOF_rgb_color_value * colorsPerClut * clutID);
	for (i = 0; i < colorsPerClut; i++) {
		GET_BYTE(p);
		(*outColors)[i].value = GET_BYTE(p);
		(*outColors)[i].red = GET_WORD(p);
		(*outColors)[i].green = GET_WORD(p);
		(*outColors)[i].blue = GET_WORD(p);
	}
	return 0;
}

// get a plain bitmap from a Marathon-encoded bitmap
int DecodeShapesBitmap(int coll, int bitmapID, int *outW, int *outH, short *outFlags, unsigned char **outPixData)
{
	byte	*bd, *outPixBase, *p;
	long	bitmapOffsetTableOffset, *bitmapOffsetTable;
	int		bitmapCount, width, height, flags;
	int		err = 0;
	short	bytes_per_row;
	
	// calculate the pointer to the wanted bitmap_definition
	if (!CollIsLoaded(coll)) {
		if (err = LoadCollection(coll, shapes))
			return err;
	}
	p = colls[coll] + 26;
	bitmapCount = GET_SHORT(p);
	if (bitmapID >= bitmapCount)
		return EINVAL;
	bitmapOffsetTableOffset = GET_LONG(p);
	bitmapOffsetTable = (long *)(colls[coll] + bitmapOffsetTableOffset);
	p = (byte *)(bitmapOffsetTable + bitmapID);
	bd = colls[coll] + GET_LONG(p);
	
	// parse the bitmap_definition struct
	p = bd;
	width = GET_SHORT(p);
	height = GET_SHORT(p);
	bytes_per_row = GET_SHORT(p);
	flags = GET_SHORT(p);
	if (width < 0 || height < 0)	// idiot-proofing
		return EIO;
	
	// fill out data
	*outW = width;	*outH = height;	*outFlags = flags;
	outPixBase = (byte *)malloc(width * height);
	*outPixData = outPixBase;
	if (outPixBase == NULL)
		return errno;
	
	// parse/decode pixel data
	p = bd + SIZEOF_bitmap_definition;
	if (flags & _COLUMN_ORDER_BIT)			// skip scanline pointers
		p += width * SIZEOF_original_ptr;
	else
		p += height * SIZEOF_original_ptr;
	if (bytes_per_row != NONE) {			// this is an uncompressed bitmap, we can copy pixel by pixel
		int		x, y;
		byte	*dest = outPixBase;
		
		if (flags & _COLUMN_ORDER_BIT) {	// column-order pixels, rotate by 90
			for (y = 0; y < height; y++) {
				for (x = 0; x < width; x++)
					*dest++ = *(p + x * bytes_per_row + y);
			}
		} else {							// normal, plain, wonderful bitmap: just copy pixel by pixel
			for (y = 0; y < height; y++) {
				for (x = 0; x < width; x++)
					*dest++ = *(p + x);
				p += bytes_per_row;
			}
		}
	} else {
		// this is an RLE bitmap: for each column, read 2 shorts (p0 and p1),
		// leave p0 pixels blank, copy p1-p0 pixels and repeat for the next column. Huh...
		int		x;
		
		for (x = 0; x < width; x++) {
			int		p0, p1;
			byte	*dest;

			p0 = GET_SHORT(p);				// y coord of first non-transparent pixel
			p1 = GET_SHORT(p);				// y coord of the last non-transparent pixel
			dest = outPixBase + x + p0 * width;
			while (p0 != p1) {				// copy p1 - p0 pixels 
				*dest = *p;
				p0++;
				p++;
				dest += width;
			}
		}
	}	
	return 0;
}

short GetBEShort(unsigned char **p)
{
	short	v;

	v = (**p) << 8;	(*p)++;
	v |= (**p);		(*p)++;
	return v;
}

word GetBEWord(unsigned char **p)
{
	word	v;

	v = (**p) << 8;	(*p)++;
	v |= (**p);		(*p)++;
	return v;
}

long GetBELong(unsigned char **p)
{
	long	v;

	v = (**p) << 24;	(*p)++;
	v |= (**p) << 16;	(*p)++;
	v |= (**p) << 8;	(*p)++;
	v |= (**p);			(*p)++;
	return v;
}

int GetNumberOfBitmapsInCollection(int coll, int *theBitmapCount)
{
	byte		*p;
	int		bitmapCount;
	int		err = 0;
	
	// calculate the pointer to the wanted bitmap_definition
	if (!CollIsLoaded(coll)) {
		if (err = LoadCollection(coll, shapes))
			return err;
	}
	p = colls[coll] + 26;
	bitmapCount = GET_SHORT(p);
        
        (*theBitmapCount) = bitmapCount;
        
        return 0;
}



