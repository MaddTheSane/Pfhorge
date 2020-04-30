#include <stdio.h>
#include <errno.h>
#include "shapes-structs.h"
#include "bitmap-decode.h"

#import "LEExtras.h"


#include <AppKit/AppKit.h>
#include <Foundation/Foundation.h>

#include "extractbitmap.h"

rgb_color_value		*ctable;
int			color_count = 0;
unsigned char		*pixels = NULL;


NSBitmapImageRep * getRawImageBits(int theCollection, int theColorTable, int theBitmap/*, unsigned char *pixelsOut*/);
NSData * save_bitmap_to_bmp(int width, int height, rgb_color_value *ct, unsigned char *pixels);
void write_word(unsigned short w, NSMutableData *theData);
void write_dword(unsigned long w, NSMutableData *theData);
void write_c(unsigned char w, NSMutableData *theData);

NSArray * getAllTexturesOf(int theCollection, int theColorTable, char *theShapesPath)
{
    NSMutableArray *theTextures;
    int i = 0;
    int theBitmapCount = 0;
    
    int		err = 0;
    FILE	*f/*, *bmp*/;
    
    /// fprintf(stderr, "Attempting to open  %s\n", theShapesPath);
    
    // open the shapes file...
    f = fopen(theShapesPath, "rb");
    if (f == NULL)
    {
        // No need for an error message to the user
        // who ever called me should send the error
        // because there is no need for futher elaboration on what
        // the error is...
            fprintf(stderr, "* Can't open %s: %s\n", theShapesPath, strerror(errno));
            return nil;
    }
    
    // read the collection headers...
    /// fprintf(stderr, "Reading collection headers... ");
    if (LoadShapes(f, 8))
    {
        SEND_ERROR_MSG_TITLE(@"Could not read collection headers in shapes file...",
                             @"Error Reading Shapes");
            fprintf(stderr, "error.\n");
            return nil;
    }
    
    /// fprintf(stderr, "done.\n");
    
    // load the color table...
    /// fprintf(stderr, "Loading color table %d... ", theColorTable);
    if (err = DecodeShapesClut(theCollection, theColorTable, &color_count, &ctable))
    {
        SEND_ERROR_MSG_TITLE(@"Could not read color tables in shapes file...",
                             @"Error Reading Shapes");
            fprintf(stderr, "error: %s.\n", strerror(err));
            return nil;
    }
    /// fprintf(stderr, "done, %d colors.\n", color_count);
    
    // get number of bitmaps in the collection...
    /// fprintf(stderr, "Getting number of bitmaps... ");
    if (err = GetNumberOfBitmapsInCollection(theCollection, &theBitmapCount))
    {
        SEND_ERROR_MSG_TITLE(@"Could not read bitmap info in shapes file...",
                             @"Error Reading Shapes");
            fprintf(stderr, "error: %s.\n", strerror(err));
            return nil;
    }
    /// fprintf(stderr, "done, %d bitmaps.\n", theBitmapCount);
    
    theTextures = [[NSMutableArray alloc] initWithCapacity:30];
    
    for (i = 0; i < theBitmapCount; i++)
    {
        NSImage *theImage = [[NSImage alloc] initWithSize:NSMakeSize(32.0, 32.0)];
        [theImage setScalesWhenResized:YES];
        [theImage addRepresentation:getRawImageBits(theCollection, theColorTable, i)];
        [theTextures addObject:theImage];
        [theImage setSize:NSMakeSize(32, 32)];
        [theImage release];
    }
    
    // free everything
    UnloadCollection(theCollection);
    fclose(f);
    free(ctable);
        
    return [theTextures autorelease];
}

NSBitmapImageRep * getRawImageBits(int theCollection, int theColorTable, int theBitmap/*, unsigned char *pixelsOut*/)
{
	///int argc = 5;
        int		/*i,*/ coll = 0, clut = 0, bitmap = 0;
	int		bwidth = 0, bheight = 0;
        short		bflags = 0;
	int		err = 0;
        
        NSBitmapImageRep *theImage = nil;
        
	///char	bmp_name[255] = "shape.bmp";
	

	/*if (argc < 5) {
		printf("Usage: %s <collection> <color table> <bitmap> <shapes file path> [<bmp path>]\n", argv[0]);
		return 0;
	}*/
        
	coll = theCollection;
	clut = theColorTable;
	bitmap = theBitmap;

	// load the bitmap
	/// fprintf(stderr, "Parsing bitmap %d... ", bitmap);
	if (DecodeShapesBitmap(coll, bitmap, &bwidth, &bheight, &bflags, &pixels)) {
		fprintf(stderr, "error: %s\n", strerror(err));
		return nil;
	}
	/// fprintf(stderr, "done, %d x %d, flags = 0x%.4x --- ", bwidth, bheight, bflags);
        
        
	/// fprintf(stderr, "Formating to bitmap...");
	//bmp = fopen(bmp_name, "wb");
        
        theImage = [[NSBitmapImageRep alloc] initWithData:save_bitmap_to_bmp(bwidth, bheight, ctable, pixels)];
        
        /// fprintf(stderr, "done!\n");
        
	free(pixels);
        
	return theImage;
}

NSData * save_bitmap_to_bmp(int width, int height, rgb_color_value *ct, unsigned char *pixels)
{
        NSMutableData *f = [[NSMutableData alloc] initWithCapacity:((width * height) * 3)];
        
	unsigned long	file_size = 0;
	long			x, y;
	
	write_c('B', f);	write_c('M', f);	// identificazione BMP
	write_dword(0, f);				// file size
	write_word(0, f);				// riservati
	write_word(0, f);
	write_dword(14+0x28, f);		// offset immagine
	// ----
	write_dword(0x28, f);			// dimensioni header secondario
	write_dword(width, f);			// larghezza
	write_dword(height, f);			// altezza
	write_word(1, f);				// piani
	write_word(24, f);				// bit depth (convertiamo tutto in 24)
	write_dword(0, f);				// nessuna compressione
	write_dword(0, f);				// dimensione immagine in byte, 0 se non e' compressa
	write_dword(72*39.37, f);		// risoluzione (pixel per metro)
	write_dword(72*39.37, f);
	write_dword(0, f);				// numero di colori (0 perche' e' a 24 bit)
	write_dword(0, f);				// colori importanti
	// scrivi i pixel
	for (y = 0; y < height; y++) {
		unsigned long	aligned;
		
		for (x = 0; x < width; x++) {
			unsigned char	r, g, b;
			unsigned long	ptr = x + (height-y-1) * width;
			unsigned char	color = *(pixels + ptr);

			r = ct[color].red;
			g = ct[color].green;
			b = ct[color].blue;
			write_c(b, f);	write_c(g, f);	write_c(r, f);
		}
		// la lunghezza delle righe deve essere allineata al prossimo multiplo di 4
		aligned = width & 3;
		while (aligned--)
			write_c(0, f);
	}
	// scrivi la dimensione del file
	
        file_size = [f length];
        [f replaceBytesInRange:NSMakeRange(2, 4) withBytes:&file_size];
        
        return [f autorelease];
}

void write_word(unsigned short w, NSMutableData *theData)
{
	write_c(w & 0x00ff, theData);
	write_c(w >> 8, theData);
        //[theData appendBytes:&w length:2];
}

void write_dword(unsigned long w, NSMutableData *theData)
{
	write_c(w & 0xff, theData);
	write_c((w >> 8) & 0xff, theData);
	write_c((w >> 16) & 0xff, theData);
	write_c((w >> 24) & 0xff, theData);
        //[theData appendBytes:&w length:4];
}

void write_c(unsigned char w, NSMutableData *theData)
{
    [theData appendBytes:&w length:1];
}


