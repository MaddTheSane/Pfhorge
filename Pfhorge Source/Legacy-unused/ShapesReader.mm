// This implements my shapes I/O object methods

#include <Carbon/Carbon.h>
#include <Foundation/Foundation.h>


//#include <MacMemory.h>
//#include <Resources.h>
#include "ShapesReader.h"

#define CHECKMACERR {/*if (MacError != noErr) {OK = false; return;}*/}
#define CHECKMACERR_RC {/*if (MacError != noErr) {OK = false; return false;}*/}

#define READ_OBJECT(Type,Obj) {\
	long Count = sizeof(Type); \
	MacError = FSRead(RefNum,&Count,(void *)&Obj); \
	CHECKMACERR \
	}


ShapesFileCatalog::ShapesFileCatalog(NSString *path, MarathonAssetVersion _Version) {
	
	Version = _Version;
	
	// The name of the map
	//BlockMove(Spec->name,ShapesName,32);
	
	// Set to blank state:
	OK = true;
	MacError = noErr;
	OtherError = Error_None;
	NSLog (@"Getting Shapes Dir's...");
	// Open the map file
	switch(Version) {
	case Version_2_oo:
		theShapesFileData = [[[NSFileManager defaultManager] contentsAtPath:path] retain];
		
		for (int s=0; s<NUMBER_OF_SHAPES_COLLECTIONS; s++) {
			//MacError = SetFPos(RefNum, fsFromStart,	ShapesDirectory_Base + s*ShapesDirectory_Step);
			//CHECKMACERR;
                        //NSLog (@"Getting Shape Collection Dir %d", s);
			[theShapesFileData getBytes:(void *)(&DirList[s])
                            range:NSMakeRange(ShapesDirectory_Base + s*ShapesDirectory_Step, sizeof(ShapesDirEntry))];
                        
			//READ_OBJECT(ShapesDirEntry,DirList[s]);
		}
	break;
	
	/*case Version_1:
		RefNum = FSpOpenResFile(Spec, fsRdPerm);
		MacError = ResError();
		CHECKMACERR;
	break;*/
	}
        NSLog (@"Done Getting Shapes Dir's");
}


ShapesFileCatalog::~ShapesFileCatalog() {
        
        if (theShapesFileData != nil)
            [theShapesFileData release];
        
	// All done with the file
	switch(Version) {
	case Version_1:
		CloseResFile(RefNum);
		break;
		
	case Version_2_oo:
		FSCloseFork(RefNum);
		break;
	}
}


bool ShapesFileCatalog::Exists(int CollIndx, int SubcollIndx) {
	
	switch(Version) {
	case Version_2_oo:
	{
		if (CollIndx < 0) return false;
		if (CollIndx >= NUMBER_OF_SHAPES_COLLECTIONS) return false;
		if (SubcollIndx < 0) return false;
		if (SubcollIndx >= NUMBER_OF_SHAPES_SUBCOLLECTIONS) return false;
		return DirList[CollIndx].SubdirList[SubcollIndx].Exists();
	}
	break;
	
	/*case Version_1:
	{
		short PrevRefNum = CurResFile();
		UseResFile(RefNum);
		
		// Switch off resource loading, since checking the resource's presence
		// is all that is desired here
		SetResLoad(false);
		Handle ShapesHandle = GetResource('.256',128+CollIndx);
		SetResLoad(true);
		if (ShapesHandle != 0) {
			ReleaseResource(ShapesHandle);
			UseResFile(PrevRefNum);
			return true;
		} else {
			UseResFile(PrevRefNum);
			return false;
		}
	}*/
	}
        return false;
}


// Slurps in a shapes chunk without parsing it
bool ShapesFileCatalog::SlurpShapes(int CollIndx, int SubcollIndx, simple_vector<byte> &ShapesChunk) {

	// Clear it out 
	ShapesChunk.reallocate(0);
	
	// Extra insurance :-)
	// This tells how much memory is left
	///long MemTotal, MemContig;

	switch(Version) {
	case Version_2_oo:
	{
		if (CollIndx < 0) return false;
		if (CollIndx >= NUMBER_OF_SHAPES_COLLECTIONS) return false;
		if (SubcollIndx < 0) return false;
		if (SubcollIndx >= NUMBER_OF_SHAPES_SUBCOLLECTIONS) return false;
		if (!DirList[CollIndx].SubdirList[SubcollIndx].Exists()) return false;
		
		long Offset = DirList[CollIndx].SubdirList[SubcollIndx].Offset;
		long Size = DirList[CollIndx].SubdirList[SubcollIndx].Size;
		
		// That insurance...
		/*PurgeSpace(&MemTotal,&MemContig);
		if (MemContig < Size) {
			return false;
		}*/
		
		ShapesChunk.reallocate(Size);
		
                // bytes
                
		/*MacError = SetFPos(RefNum, fsFromStart,	Offset);
		CHECKMACERR_RC;
		MacError = FSRead(RefNum, &Size, ShapesChunk.begin());
		CHECKMACERR_RC;*/
                
                [theShapesFileData getBytes:ShapesChunk.begin() range:NSMakeRange(Offset, Size)];
                
		return true;
	}
	break;
	/*case Version_1:
	{
		short PrevRefNum = CurResFile();
		UseResFile(RefNum);
		
		Handle ShapesHandle = GetResource('.256',128+CollIndx);
		if (ShapesHandle == 0) {
			UseResFile(PrevRefNum);
			return false;
		}
		
		HLock(ShapesHandle);
		int len = GetHandleSize(ShapesHandle);
		
		// That insurance...
		PurgeSpace(&MemTotal,&MemContig);
		if (MemContig < len) {
			ReleaseResource(ShapesHandle);
			UseResFile(PrevRefNum);
			return false;
		}
		
		ShapesChunk.reallocate(len);
		BlockMove(*ShapesHandle,ShapesChunk.begin(),len);
		HUnlock(ShapesHandle);
		
		ReleaseResource(ShapesHandle);
		UseResFile(PrevRefNum);
		return true;
	}*/
	}
	return false;
}


ShapeObject *ShapesFileCatalog::GetShapes(int CollIndx, int SubcollIndx) {
	
	simple_vector<byte> ShapesChunk;
	if (!SlurpShapes(CollIndx,SubcollIndx,ShapesChunk)) return 0;
	
	return ParseShapes(ShapesChunk.get_len(),ShapesChunk.begin(),Version);
}


// These copy routines return a pointer to the next byte in the input object
// after the copying had completed; it is 0 if the copying had gone off the edge

template<class T> byte *CopySingle(byte *DataPtr, byte *EndSentry, T &Object) {
	int nbytes = sizeof(T);
        
	byte *NextDataPtr = DataPtr + nbytes;
	if (NextDataPtr > EndSentry) return 0;
        
        memmove(&Object,DataPtr,nbytes);
        
	return NextDataPtr;
}

template<class T> byte *CopyMulti(byte *DataPtr, byte *EndSentry, int NObjects, T *ObjPtr) {
	int nbytes = NObjects*sizeof(T);
        
	byte *NextDataPtr = DataPtr + nbytes;
	if (nbytes <= 0) return NextDataPtr;
        
        if (NextDataPtr > EndSentry) return 0;
        memmove(ObjPtr,DataPtr,nbytes);
        
	return NextDataPtr;
}


ShapeObject *ShapesFileCatalog::ParseShapes(int ShapesChunkLen, byte *ShapesChunk, int _Version) {
	
	byte *EndSentry = ShapesChunk + ShapesChunkLen;
	
	ShapeObject *Shapes = new ShapeObject;
	
	// Read in the header
	byte *DataPtr = ShapesChunk;
	
	if (!(DataPtr = CopySingle(DataPtr,EndSentry,Shapes->Header))) {
		delete Shapes; return 0;
	}
	
	// Read in the color tables
	if (Shapes->Header.palette_count < 0) {delete Shapes; return 0;}
	if (Shapes->Header.color_count < 0) {delete Shapes; return 0;}
	
	int NumColors = Shapes->Header.palette_count * Shapes->Header.color_count;
	Shapes->ColorList.reallocate(NumColors);
	
	DataPtr = ShapesChunk + Shapes->Header.first_palette_address;
	if (DataPtr < ShapesChunk) {delete Shapes; return 0;}
	
	if (!(DataPtr = CopyMulti(DataPtr,EndSentry,NumColors,Shapes->ColorList.begin()))) {
		delete Shapes; return 0;
	}
	
	// Read in the sequence offsets
	int NumSeqs = Shapes->Header.high_level_shapes_count;
	if (NumSeqs < 0) {delete Shapes; return 0;}
	
	Shapes->SequenceOffsetList.reallocate(NumSeqs);
	
	DataPtr = ShapesChunk + Shapes->Header.high_level_shapes_table;
	if (DataPtr < ShapesChunk) {delete Shapes; return 0;}
	
	if (!(DataPtr = CopyMulti(DataPtr,EndSentry,NumSeqs,Shapes->SequenceOffsetList.begin()))) {
		delete Shapes; return 0;
	}
	
	// Read in the sequences (high-level shapes)
	Shapes->SequenceList.reallocate(NumSeqs);
	
	for (int isq=0; isq<NumSeqs; isq++) {
		// Sequence header first:
		DataPtr = ShapesChunk + Shapes->SequenceOffsetList[isq];
		if (DataPtr < ShapesChunk) {delete Shapes; return 0;}
	
		SequenceObject &Seq = Shapes->SequenceList[isq];
		if (!(DataPtr = CopySingle(DataPtr,EndSentry,Seq.Header))) {
			delete Shapes; return 0;
		}
		
		// What's the true number of views?
		int &NumViews = Seq.NumViews;
		switch(Seq.Header.view_count) {
		case 1:
			NumViews = 1;
			break;
		
		case 3:
		case 4:
			NumViews = 4;
			break;
		
		case 5:
		case 8:
			NumViews = 8;
			break;
		
		case 9:
			NumViews = 5;
			break;
		
		case 10:
			NumViews = 1;
			break;
			
		// Just in case...
		default:
			NumViews = 0;
			break;
		}
		
		// Now read the frame indices:
		if (Seq.Header.frames_per_view < 0) {delete Shapes; return 0;}
		int NumFrames = NumViews*Seq.Header.frames_per_view + 1;
		
		Seq.FrameList.reallocate(NumFrames);
		// Current location already set
		
		if (!(DataPtr = CopyMulti(DataPtr,EndSentry,NumFrames,Seq.FrameList.begin()))) {
			delete Shapes; return 0;
		}
	}
	
	// Read in the frame offsets
	int NumFrames = Shapes->Header.low_level_shapes_count;
	if (NumFrames < 0) {delete Shapes; return 0;}
	
	Shapes->FrameOffsetList.reallocate(NumFrames);
	
	DataPtr = ShapesChunk + Shapes->Header.low_level_shapes_table;
	if (DataPtr < ShapesChunk) {delete Shapes; return 0;}
	
	if (!(DataPtr = CopyMulti(DataPtr,EndSentry,NumFrames,Shapes->FrameOffsetList.begin()))) {
		delete Shapes; return 0;
	}
		
	// Read in the frames (low-level shapes)
	Shapes->FrameList.reallocate(NumFrames);
	
	for (int ifr=0; ifr<NumFrames; ifr++) {
		// This is all of the frame:
		DataPtr = ShapesChunk + Shapes->FrameOffsetList[ifr];
		if (DataPtr < ShapesChunk) {delete Shapes; return 0;}
		
		if (!(DataPtr = CopySingle(DataPtr,EndSentry,Shapes->FrameList[ifr]))) {
			delete Shapes; return 0;
		}
	}
	
	// Read in the image offsets
	int NumImages = Shapes->Header.image_count;
	if (NumImages < 0) {delete Shapes; return 0;}
	
	Shapes->ImageOffsetList.reallocate(NumImages);
	
	DataPtr = ShapesChunk + Shapes->Header.image_table;
	if (DataPtr < ShapesChunk) {delete Shapes; return 0;}
	
	if (!(DataPtr = CopyMulti(DataPtr,EndSentry,NumImages,Shapes->ImageOffsetList.begin()))) {
		delete Shapes; return 0;
	}
	
	// Read in the images
	Shapes->ImageList.reallocate(NumImages);
	
	int ShapeClass = Shapes->Header.shape_class;
		
	for (int iim=0; iim<NumImages; iim++) {
		// Image header first:
		DataPtr = ShapesChunk + Shapes->ImageOffsetList[iim];
		if (DataPtr < ShapesChunk) {delete Shapes; return 0;}
		
		ImageObject &Img = Shapes->ImageList[iim];
		if (!(DataPtr = CopySingle(DataPtr,EndSentry,Img.Header))) {
			delete Shapes; return 0;
		}
		
		// The scan starts:
		// Different from what the M1 docs say (height instead of width)
		int NumScanStarts = 0; // Default -- none
		switch(ShapeClass) {
		case _shapeTexture:
		case _shapeSprite:
			NumScanStarts = Img.Header.width + 1;
			break;
		
		case _shapeInterface:
			NumScanStarts = Img.Header.height + 1;
			break;		
		}
		Img.ScanStartList.reallocate(NumScanStarts);
		
		if (!(DataPtr = CopyMulti(DataPtr,EndSentry,NumScanStarts,Img.ScanStartList.begin()))) {
			delete Shapes; return 0;
		}
		
		// Extra insurance :-)
		// This tells how much memory is left
                
		///long MemTotal, MemContig;
		///PurgeSpace(&MemTotal,&MemContig);
		
		// The image proper:
		// First allocate it
		int NumPixels = int(Img.Header.width)*int(Img.Header.height);
		///if (NumPixels > MemContig) {delete Shapes; return 0;}
		Img.Pixels.reallocate(NumPixels);
		
		// Now read it
		switch(ShapeClass) {
		case _shapeSprite:
			// First, fill with the transparent color
			Img.Pixels.fill(0);
			// Undo the run-length encoding;
			// the M2/Moo method differs significantly from the M1 method
			switch(_Version) {
			case Version_2_oo:
				// Loop over columns
				for (int icol=0; icol < Img.Header.width; icol++) {
					// Read the pixel-column boundaries
					short Pos0, Pos1;
					if (!(DataPtr = CopySingle(DataPtr,EndSentry,Pos0))) {
						delete Shapes; return 0;
					}
					if (!(DataPtr = CopySingle(DataPtr,EndSentry,Pos1))) {
						delete Shapes; return 0;
					}
					// Read the actual pixels
					byte *PixelStart = Img.Pixels + icol*Img.Header.height + Pos0;
					if (!(DataPtr = CopyMulti(DataPtr,EndSentry, Pos1 - Pos0, PixelStart))) {
						delete Shapes; return 0;
					}
				}
				break;
			case Version_1:
				// Loop over columns
				for (int icol=0; icol < Img.Header.width; icol++) {
					byte *PixelStart = Img.Pixels + icol*Img.Header.height;
					while(true) {
						// Read the opcode
						short Opcode;
						if (!(DataPtr = CopySingle(DataPtr,EndSentry,Opcode))) {
							delete Shapes; return 0;
						}
						if (Opcode > 0) {
							// Read in some pixels
							if (!(DataPtr = CopyMulti(DataPtr,EndSentry, Opcode, PixelStart))) {
								delete Shapes; return 0;
							}
							PixelStart += Opcode;
						} else if (Opcode < 0) {
							// Skip over some pixels
							PixelStart -= Opcode;
						} else {
							// End of column
							break;
						}
					}
				}
				break;
			}
			break;
			
		case _shapeTexture:
		case _shapeInterface:
			// Do a massive slurp
			if (!(DataPtr = CopyMulti(DataPtr,EndSentry,NumPixels,Img.Pixels.begin()))) {
				delete Shapes; return 0;
			}
			break;
		}
	}
	return Shapes;
}
