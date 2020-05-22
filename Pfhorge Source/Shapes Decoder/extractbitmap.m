#include <stdio.h>
#include <errno.h>
#include "shapes-structs.h"
#include "bitmap-decode.h"

#import "LEExtras.h"


#import <Cocoa/Cocoa.h>

#import "extractbitmap.h"

static rgb_color_value	*ctable;
static int				color_count = 0;
static unsigned char	*pixels = NULL;
NSErrorDomain const LEShapesImportErrorDomain = @"pfhorge.shapesErrors";

static NSBitmapImageRep * getRawImageBits(int theCollection, int theColorTable, int theBitmap, NSError *__autoreleasing*error);
static NSData * save_bitmap_to_bmp(int width, int height, rgb_color_value *ct, unsigned char *pixels);
static void write_word(unsigned short w, NSMutableData *theData);
static void write_dword(unsigned int w, NSMutableData *theData);
static void write_c(unsigned char w, NSMutableData *theData);


NSArray * getAllTexturesOfWithError(int theCollection, int theColorTable, NSURL *theShapesPath, NSError *_Nullable __autoreleasing* _Nullable outError)
{
	NSMutableArray *theTextures;
	int i = 0;
	int theBitmapCount = 0;
	
	int        err = 0;
	FILE    *f/*, *bmp*/;
	if (!theShapesPath) {
		if (outError) {
			*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:paramErr userInfo:nil];
		}
		return nil;
	}
	if (!theShapesPath.isFileURL) {
		if (outError) {
			*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnsupportedSchemeError userInfo:@{NSURLErrorKey: theShapesPath}];
		}
		return nil;
	}
	
	/// fprintf(stderr, "Attempting to open  %s\n", theShapesPath);
	
	// open the shapes file...
	f = fopen(theShapesPath.fileSystemRepresentation, "rb");
	if (f == NULL) {
		// No need for an error message to the user
		// who ever called me should send the error
		// because there is no need for futher elaboration on what
		// the error is...
		if (outError) {
			*outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:@{NSURLErrorKey: theShapesPath, NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can't open %@: %s\n", theShapesPath.path, strerror(errno)]}];
		}
		return nil;
	}
	
	// read the collection headers...
	/// fprintf(stderr, "Reading collection headers... ");
	if (LoadShapes(f, 8)) {
		if (outError) {
			*outError = [NSError errorWithDomain:LEShapesImportErrorDomain code:LEShapesImportCouldNotReadCollectionHeader userInfo:@{NSURLErrorKey: theShapesPath, NSLocalizedFailureReasonErrorKey: @"Could not read collection headers in shapes file", NSLocalizedDescriptionKey: @"Error Reading Shapes", NSUnderlyingErrorKey: [NSError errorWithDomain:NSPOSIXErrorDomain code:EIO userInfo:nil]}];
		}
		
		fclose(f);
		return nil;
	}
	
	/// fprintf(stderr, "done.\n");
	
	// load the color table...
	/// fprintf(stderr, "Loading color table %d... ", theColorTable);
	if ((err = DecodeShapesClut(theCollection, theColorTable, &color_count, &ctable))) {
		if (outError) {
			*outError = [NSError errorWithDomain:LEShapesImportErrorDomain code:LEShapesImportCouldNotReadColorTable userInfo:@{NSURLErrorKey: theShapesPath, NSLocalizedFailureReasonErrorKey: @"Could not read color tables in shapes file", NSLocalizedDescriptionKey: @"Error Reading Shapes", NSUnderlyingErrorKey: [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:@{NSLocalizedDescriptionKey: @(strerror(err))}]}];
		}
		
		fclose(f);
		return nil;
	}
	/// fprintf(stderr, "done, %d colors.\n", color_count);
	
	// get number of bitmaps in the collection...
	if ((err = GetNumberOfBitmapsInCollection(theCollection, &theBitmapCount))) {
		if (outError) {
			*outError = [NSError errorWithDomain:LEShapesImportErrorDomain code:LEShapesImportCouldNotReadBitmapInfo userInfo:@{NSURLErrorKey: theShapesPath, NSLocalizedFailureReasonErrorKey: @"Could not read bitmap info in shapes file", NSLocalizedDescriptionKey: @"Error Reading Shapes", NSUnderlyingErrorKey: [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:@{NSLocalizedDescriptionKey: @(strerror(err))}]}];
		}
		
		fclose(f);
		free(ctable);
		return nil;
	}
	
	theTextures = [[NSMutableArray alloc] initWithCapacity:MAX(30, theBitmapCount)];
	
	@autoreleasepool {
	for (i = 0; i < theBitmapCount; i++) {
		NSImage *theImage = [[NSImage alloc] initWithSize:NSMakeSize(32.0, 32.0)];
		//[theImage setScalesWhenResized:YES];
		NSError *tmpErr;
		NSBitmapImageRep *rep = getRawImageBits(theCollection, theColorTable, i, &tmpErr);
		if (!rep) {
			if (outError) {
				*outError = [NSError errorWithDomain:LEShapesImportErrorDomain code:LEShapesImportReturnedNilImageRep userInfo:@{NSURLErrorKey: theShapesPath, NSLocalizedFailureReasonErrorKey: @"Could not create image for bitmap (possible end-of-file?)", NSLocalizedDescriptionKey: @"Error Reading Shapes", NSUnderlyingErrorKey: [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:@{NSUnderlyingErrorKey: tmpErr}]}];
			}
			
			UnloadCollection(theCollection);
			fclose(f);
			free(ctable);
		}
		[theImage addRepresentation:rep];
		[theTextures addObject:theImage];
		[theImage setSize:NSMakeSize(32, 32)];
	}
	}
	
	// free everything
	UnloadCollection(theCollection);
	fclose(f);
	free(ctable);
	
	return [theTextures copy];
}

NSBitmapImageRep * getRawImageBits(int theCollection, int theColorTable, int theBitmap, NSError **error)
{
	///int argc = 5;
	int		/*i,*/ coll = 0, clut = 0, bitmap = 0;
	int		bwidth = 0, bheight = 0;
	bitmap_definition_flags	bflags = 0;
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
	if ((err = DecodeShapesBitmap(coll, bitmap, &bwidth, &bheight, &bflags, &pixels))) {
		if (error) {
			*error = [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:@{NSLocalizedDescriptionKey: @(strerror(err))}];
		} else {
			fprintf(stderr, "error: %s\n", strerror(err));
		}
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
	NSMutableData *f = [[NSMutableData alloc] initWithCapacity:((width * height) * 3) + 58];
        
	unsigned int	file_size = 0;
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
	
	file_size = CFSwapInt32HostToLittle((int)[f length]);
	[f replaceBytesInRange:NSMakeRange(2, 4) withBytes:&file_size];
	
	return [f copy];
}

void write_word(unsigned short w, NSMutableData *theData)
{
	w = CFSwapInt16HostToLittle(w);
	[theData appendBytes:&w length:2];
}

void write_dword(unsigned int w, NSMutableData *theData)
{
	w = CFSwapInt32HostToLittle(w);
	[theData appendBytes:&w length:4];
}

void write_c(unsigned char w, NSMutableData *theData)
{
	[theData appendBytes:&w length:1];
}
