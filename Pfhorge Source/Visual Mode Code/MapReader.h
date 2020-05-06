// Here are my map I/O objects
//
// Copyright (c) 1998 by Loren Petrich
// This code is intended to be freely available

#pragma once

#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>
#include <Foundation/Foundation.h>

//#include <Types.h>
//#include <Files.h>
//#include <MacMemory.h>
#include "SmartPtr.h"
#include "SimpleVec.h"
#include "MiscUtils.h"
#include "HeaderFormats.h"
#import "LESide.h"
#include "MapDataFormats.h"
//#include "ProgressBar.h"


typedef unsigned char byte;


// Extracted for convenience
//class MapFileCatalog {
//public:
//	// Which version?
//	enum {
//		Version_1,		// Marathon 1
//		Version_2_oo		// Marathon 2/Infinity
//	};
//};


#ifdef ALL_OBSOLETE

struct ChunkLink {
	WadDataType Type;
	long Length;
	long Offset;
	
	SmartPtr<ChunkLink> Next;
	
	ChunkLink() {Type = 0; Length = 0;}
	// Deleting this object will be recursive; this should not eat up too much stack space
};


struct LevelCatalog {
	int Offset;
	SmartPtr<ChunkLink> RootChunk;
	
	// static_data Info;
};


class MapFileCatalog {

	// File reference number
	FSIORefNum RefNum;

	// Map header
	wad_header Header;
	
	// Map Version (either Marathon 1 or Marathon 2/oo):
	MarathonAssetVersion Version;

	// Block of level catalogs
	simple_vector<LevelCatalog> LevelList;

	// Readin OK?
	bool OK;
	
	// Current-level index
	int LevelIndex;

	// Current chunk for doing listing
	ChunkLink *CurrOutputChunk;
        
        NSData *theMapFileData;
	
	// Progress bar:
	///ProgressBar PB;
public:

	enum ErrorType {
		Error_None,
		Error_Alloc,
		Error_ChunkMissing
	};

	// Error reporting
	OSErr MacError; // MacOS error code
	enum ErrorType OtherError; // Other error
	bool ReadOK() {return OK;}
	
	MarathonAssetVersion GetVersion() {return Version;}
	
	// Return the header:
	wad_header GetHeader() {return Header;}
	
	// How many levels?
	int LevelCount() {return Header.wad_count;}
	
	// Set and get the current level index (0 to LevelCount()-1);
	// "Set" returns whether the entered value did not
	// have to be forced to within the range
	bool SetLevelIndex(int _LevelIndex);
	int GetLevelIndex() {return LevelIndex;}

	// These are for listing the chunk types and sizes
	// This resets
	void ResetChunkListing();
	// Advances to the next chunk; returns whether or not it could be done
	bool AdvanceToNextChunk();
	// Find the chunk with this type; returns "false" if it could not be found
	bool FindChunk(OSType Type);
	
	// Does the current chunk really exist?
	bool CurrChunkExists() {return (CurrOutputChunk != 0);}
	
	// Gets current chunk features; will crash if the chunk doesn't exist
	// What type
	OSType GetCurrChunkType() {return CurrOutputChunk->Type;}
	// What length
	long GetCurrChunkLength() {return CurrOutputChunk->Length;}
	// Load contents into array pointed at (must already be allocated)
	bool LoadCurrChunk(byte *ChkPtr);
	// Return an array containing the loaded contents of the current chunk;
	// the caller is responsible for disposing of it
	byte *GetCurrChunk();
	
	// Support KL's API here
	byte *GetChunk(OSType Type, int &Length);
	
	// Find the map-info struct for the current level
	// static_data GetLevelInfo() {return LevelList[LevelIndex].Info;}
	
	// Create with a file to be opened and a progress-bar dialog-box resource ID.
	// Make the latter zero to omit the progress bar.
	MapFileCatalog(NSData *theMapRawData);
	~MapFileCatalog();
	
	// The name of the map in Pascal-string form
	Str31 MapName;
};


// This function reads a chunk into a vector
// Returns whether or not the chunk was found
template <class T> bool
	GetChunkIntoVector(MapFileCatalog &Cat, OSType Type, simple_vector<T> &Vec) {

	if (Cat.FindChunk(Type)) {
		Vec.reallocate(Cat.GetCurrChunkLength()/sizeof(T));
		Cat.LoadCurrChunk((byte *)&Vec[0]);
		return true;
	} else {
		Vec.reallocate(0);
		return false;
	}
}

#endif

