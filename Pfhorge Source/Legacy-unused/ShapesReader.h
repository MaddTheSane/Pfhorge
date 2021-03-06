// Here are my shapes I/O objects
//
// This code is intended to be freely available

#pragma once

#include <Carbon/Carbon.h>
#include <Foundation/Foundation.h>

//#include <Types.h>
//#include <Files.h>
#include "SmartPtr.h"
#include "SimpleVec.h"
#include "MiscUtils.h"
#include "ShapesDataFormats.h"
#include "MarathonVersions.h"


typedef unsigned char byte;


//! Sequence object:
struct SequenceObject {
	//! Sequence header
	high_level_shape Header;
	
	//! True number of views in this sequence
	int NumViews;
	
	//! List of this sequence's frames (actually, frame indices)
	simple_vector<short> FrameList;
	
	//! Convenient C++ method:
	SequenceObject() {NumViews = 0;}
};


// No need for special frame objects


//! Image object:
struct ImageObject {
	//! Image header
	image_header Header;

	//! Scan-start addresses
	simple_vector<int> ScanStartList;
	
	//! Image data: this is color-index values
	simple_vector<byte> Pixels;
};


//! Shape object: contains all the contents of a shapes subcollection
struct ShapeObject {
	
	//! Shape header
	shapes_header Header;
	
	//! List of color values for the color tables
	simple_vector<color_entry> ColorList;
	
	//! List of sequence offsets
	simple_vector<int> SequenceOffsetList;
	
	//! List of sequences (high-level shapes)
	simple_vector<SequenceObject> SequenceList;
	
	//! List of frame offsets
	simple_vector<int> FrameOffsetList;
	
	//! List of frames (low-level shapes)
	simple_vector<low_level_shape> FrameList;
	
	//! List of image offsets
	simple_vector<int> ImageOffsetList;
	
	//! List of images
	simple_vector<ImageObject> ImageList;
};


class ShapesFileCatalog {
	//! File reference number
	FSIORefNum RefNum;

	//! Readin OK?
	bool OK;

	ShapesDirEntry DirList[NUMBER_OF_SHAPES_COLLECTIONS];
	
	MarathonAssetVersion Version;
        
	NSData *theShapesFileData;
	
public:

	enum ErrorType {
		Error_None,
		Error_Alloc
	};
	
	
	MarathonAssetVersion GetVersion() {return Version;}

	// Error reporting
	OSErr MacError; // MacOS error code
	enum ErrorType OtherError; // Other error
	bool ReadOK() {return OK;}
	
	//! Does a shapes subcollection exist?
	//! Args are collection and subcollection index.
	bool Exists(int CollIndx, int SubcollIndx);
	
	//! Slurp in a shapes chunk and put into an array;
	//! return whether or not doing so was successful.
	//! The additional argument is a place to put that shape.
	bool SlurpShapes(int CollIndx, int SubcollIndx, simple_vector<byte> &ShapesChunk);
	
	//! Parse the shape
	static ShapeObject *ParseShapes(int ShapesChunkLen, byte *ShapesChunk, int _Version);
	
	//! Get a shape subcollection: returns a pointer to it
	//! Returns 0 if the operation failed;
	//! but with "no error" if the shape did not exist
	ShapeObject *GetShapes(int CollIndx, int SubcollIndx);

	//! Create with a file to be opened
	ShapesFileCatalog(NSString *path, MarathonAssetVersion _Version);
	~ShapesFileCatalog();
	
	//! The name of the shapes file in Pascal-string form
	Str31 ShapesName;
};

