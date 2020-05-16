// This implements my map I/O object methods

#ifdef ALL_OBSOLETE

#include "MapReader.h"
//#include <MacMemory.h>
#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>
#include <Foundation/Foundation.h>

#define CHECKMACERR {if (MacError != noErr) {OK = false; ///PB.Hide(); return;}}

#define READ_OBJECT(Type,Obj) {\
	long Count = sizeof(Type); \
	MacError = FSRead(RefNum,&Count,(void *)&Obj); \
	CHECKMACERR \
	}


MapFileCatalog::MapFileCatalog(NSData *theMapRawData)///: ///PB(///PB_ID)
{
        
	//TODO: byteswap!
	// Start the progress bar:
	//////PB.SetTitle("\pReading Map File Info...");
	///PB.BkgdColor.red = 0;
	///PB.BkgdColor.green = 0;
	///PB.BkgdColor.blue = 0xffff;
	///PB.BarColor.red = 0xffff;
	///PB.BarColor.green = 0xffff;
	///PB.BarColor.blue = 0;
	///PB.Show();
	
	// The name of the map
	//BlockMove(Spec->name,MapName,32);
	
	// Set to blank state:
	OK = true;
	MacError = noErr;
	OtherError = Error_None;
	CurrOutputChunk = 0;
	LevelIndex = 0;
	
	// Open the map file
        theMapFileData = [theMapRawData copy]; //[[NSFileManager defaultManager] contentsAtPath:path];
        
        if (theMapFileData == nil)
        {
            NSLog(@"theMapFileData was nil");
            return;
        }
        
	/*MacError = FSpOpenDF(Spec, fsRdPerm, &RefNum);
	CHECKMACERR;*/

	// Read the map-file header
	//READ_OBJECT(wad_header, Header);
        
	[theMapFileData getBytes:(void *)(&Header)
            range:NSMakeRange(0, sizeof(wad_header))];
                            
	// Set up for loading the directory info
	LevelList.reallocate(LevelCount());
	
	long DirBase = Header.directory_offset;
	long DirStep = Header.directory_entry_base_size + Header.application_specific_directory_data_size;
	
	// Use file-size test; assuming there's nothing after the catalog in M1
	long FileSize = [theMapFileData length];
	///MacError = GetEOF(RefNum,&FileSize);
	///CHECKMACERR;
	
	if (FileSize > DirBase + LevelCount()*sizeof(directory_entry_1)) {
		Version = Version_2_oo;
	} else {
		Version = Version_1;
		DirStep = sizeof(directory_entry_1);
	}
	
	// Get progress-bar values to between 0 and 1 with this value:
	///double PB_Step = 1.0/(LevelCount()+1);
	///double PB_State = PB_Step;
	
	// Load the directory info
	// Be careful of which version to use
	int l;
	///PB.Update(///PB_State);
	///PB_State += ///PB_Step;
	///switch(Version) {
	if (Version_2_oo == Version)
        {
		for (l=0; l<LevelCount(); l++)
                {
			//MacError = SetFPos(RefNum, fsFromStart,	DirBase + l*DirStep);
			//CHECKMACERR;
			
			directory_entry Dir;
			//READ_OBJECT(directory_entry,Dir);
                        
                        [theMapFileData getBytes:(void *)(&Dir)
                            range:NSMakeRange(DirBase + l*DirStep, sizeof(directory_entry))];
			
			LevelList[l].Offset = Dir.offset_to_start;
		}
	}
	else if (Version_1 == Version)
        {// changed from Version_2_oo == Version, I think this may have been a bug in the orginal Map Viewer...
		for (l=0; l<LevelCount(); l++)
                {
			//MacError = SetFPos(RefNum, fsFromStart,	DirBase + l*DirStep);
			//CHECKMACERR;
			
			directory_entry_1 Dir;
			//READ_OBJECT(directory_entry_1,Dir);
                        
                        [theMapFileData getBytes:(void *)(&Dir)
                            range:NSMakeRange(DirBase + l*DirStep, sizeof(directory_entry_1))];
                            
			LevelList[l].Offset = Dir.offset_to_start;
		}
        }
	///}
	
	// Load the level chunk references
	for (l=0; l<LevelCount(); l++) {
		///PB.Update(PB_State);
		///PB_State += PB_Step;

		///LevelCatalog *CurrLevel = LevelList + l;
		///MacError = SetFPos(RefNum, fsFromStart,	CurrLevel->Offset);
		///CHECKMACERR;
                
                LevelCatalog *CurrLevel = LevelList + l;
                int cur_offset = CurrLevel->Offset;
                
		ChunkLink *CurrChunk = 0;
		while(true) {
			// Read in the current chunk
			WadDataType Tag;
			long Length;
			long NextOffset;
			
			switch(Version) {
                            case Version_2_oo:
                            {
                                    entry_header ChunkHdr;
                                    
                                    ///READ_OBJECT(entry_header, ChunkHdr);
                                    
                                    [theMapFileData getBytes:(void *)(&ChunkHdr)
                                        range:NSMakeRange(cur_offset, sizeof(entry_header))];
                                    cur_offset += sizeof(entry_header);
                                    
                                    Tag = ChunkHdr.tag;
                                    Length = ChunkHdr.length;
                                    NextOffset = ChunkHdr.next_offset;
                            }
                            break;
                            case Version_1:
                            {
                                    entry_header_1 ChunkHdr;
                                    
                                    ///READ_OBJECT(entry_header_1, ChunkHdr);
                                    
                                    [theMapFileData getBytes:(void *)(&ChunkHdr)
                                        range:NSMakeRange(cur_offset, sizeof(entry_header_1))];
                                    cur_offset += sizeof(entry_header_1);
                                    
                                    Tag = ChunkHdr.tag;
                                    Length = ChunkHdr.length;
                                    NextOffset = ChunkHdr.next_offset;
                            }
                            break;
			}
			
			// Absolute offset of chunk data
			long Offset = cur_offset;
			///MacError = GetFPos(RefNum,&Offset);
			///CHECKMACERR;
			
			// New chunk link
			ChunkLink *NewChunk = new ChunkLink;
			
			NewChunk->Type = Tag;
			NewChunk->Length = Length;
			NewChunk->Offset = Offset;

			// Put it into place
			if (CurrChunk != 0)
				CurrChunk->Next = NewChunk;
			else
				CurrLevel->RootChunk = NewChunk;
			CurrChunk = NewChunk;
			
			// The last chunk?
			if (NextOffset == 0) break;

			// Advance to next chunk
                        cur_offset += Length;
			
                        ///MacError = SetFPos(RefNum, fsFromMark, Length);
			///CHECKMACERR;
		}
	}
	
	// Load the map-info chunks
	for (l=0; l<LevelCount(); l++) {
		LevelIndex = l;
		if (!FindChunk(MapInfoTag)) {
			OtherError = Error_ChunkMissing;
			continue;
		}
		LoadCurrChunk((byte *)&LevelList[LevelIndex].Info);
	}
	///PB.Hide();
}



MapFileCatalog::~MapFileCatalog() {
        
        [theMapFileData release];
        theMapFileData = nil;
        
	// All done with the file
	FSClose(RefNum);
}


bool MapFileCatalog::SetLevelIndex(int _LevelIndex) {
	bool SetOK;

	// Force to within range;
	// C's call-by-value won't affect original value of this variable
	if (_LevelIndex < 0) {
		SetOK = false;
		_LevelIndex = 0;
	} else if (_LevelIndex >= LevelCount()) {
		SetOK = false;
		_LevelIndex = LevelCount()-1;
	} else {
		SetOK = true;
		LevelIndex = _LevelIndex;
	}
	
	return SetOK;
}


void MapFileCatalog::ResetChunkListing() {
	CurrOutputChunk = LevelList[LevelIndex].RootChunk;
}


bool MapFileCatalog::AdvanceToNextChunk() {
	CurrOutputChunk = CurrOutputChunk->Next;
	return CurrChunkExists();
}


bool MapFileCatalog::FindChunk(OSType Type) {
	ResetChunkListing();
	
	do {
		if (GetCurrChunkType() == Type) return true;
	} while (AdvanceToNextChunk());
	
	return false;
}


bool MapFileCatalog::LoadCurrChunk(byte *ChkPtr) {
	///MacError = SetFPos(RefNum, fsFromStart, CurrOutputChunk->Offset);
	///if (MacError != noErr) return false;
        
	long Count = GetCurrChunkLength();
	///MacError = FSRead(RefNum,&Count,(void *)ChkPtr);
        
        if (![theMapFileData
            isKindOfClass:[NSData class]])
            NSLog(@"[theMapFileData class] != [NSData class]");
        
        [theMapFileData getBytes:(void *)ChkPtr
            range:NSMakeRange(CurrOutputChunk->Offset, Count)];
            
	if (MacError != noErr) return false;

	return true;
}


byte *MapFileCatalog::GetCurrChunk() {

	byte *Chunk = new byte[GetCurrChunkLength()];
	if (Chunk == 0) {
		OtherError = Error_Alloc;
		return 0;
	}
	
	if (!LoadCurrChunk(Chunk)) return 0;

	return Chunk;
}


	
// Support KL's API here
byte *MapFileCatalog::GetChunk(OSType Type, int &Length) {

	Length = 0;
	if (!FindChunk(Type)) return 0;
	
	Length = GetCurrChunkLength();
	return GetCurrChunk();
}

#endif
