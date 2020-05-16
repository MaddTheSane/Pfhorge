// Here are the more bulky methods of the texture-manager classes:

#include "string.h"
#include "TextureManager.h"
#include "IndexHeapSort.h"


// Ought to be some small number to keep the number of resets down
const float PriorityQuantum = 1.0/1048576;


// Reset a set's textures to "unloaded"
// and the textures to the lowest priority
void TextureManager::Reset(int its) {
	for (int itl=0; itl<TileList[its].get_len(); itl++) {
		TileList[its][itl].WasLoaded = false;
		TileList[its][itl].SetPriority(0.0);
	}
	
	CurrentPriority = 0.0;
}

// Find a texture set's average color:
void TextureManager::FindAverage(int its) {
	for (int itl=0; itl<TileList[its].get_len(); itl++) {
		TextureTile &Tile = TileList[its][itl];
		
		float RedSum = 0, GreenSum = 0, BlueSum = 0, AlphaSum = 0;
		for (int ip=0; ip<MaraNumWTPixels; ip++) {
			GLuint PackedColor = ColorTableList[its][Tile.Pixels[ip]];
			// Unpack the color:
			float Red = ((PackedColor >> 24) & 0x000000ff)/255.;
			float Green = ((PackedColor >> 16) & 0x000000ff)/255.;
			float Blue = ((PackedColor >> 8) & 0x000000ff)/255.;
			float Alpha = (PackedColor & 0x000000ff)/255.;
			RedSum += Red*Alpha;
			GreenSum += Green*Alpha;
			BlueSum += Blue*Alpha;
			AlphaSum += Alpha;
		}
		if (AlphaSum > 0) {
			Tile.AvgColor[0] = RedSum/AlphaSum;
			Tile.AvgColor[1] = GreenSum/AlphaSum;
			Tile.AvgColor[2] = BlueSum/AlphaSum;
		} else {
			Tile.AvgColor[0] = Tile.AvgColor[1] = Tile.AvgColor[2] = 0;
		}
		Tile.AvgColor[3] = AlphaSum/MaraNumWTPixels;
	}
}


// Get the current average color
// Returns whether out of range
GLfloat *TextureManager::GetAvgColor(int its, int itl) {
	
	// Check the texture ID's	
	if (its < 0) return 0;
	if (its >= NumWallTxtrSets) return 0;
	
	if (itl < 0) return 0;
	if (itl >= TileList[its].get_len()) return 0;
	
	return TileList[its][itl].AvgColor;
}


// Use the current wall texture; load if necessary
// Returns whether out of range
bool TextureManager::Use(int its, int itl) {
	
	// Check the texture ID's	
	if (its < 0) return false;
	if (its >= NumWallTxtrSets) return false;
	
	if (itl < 0) return false;
	if (itl >= TileList[its].get_len()) return false;
	
	// Make a reference to the appropriate tile
	TextureTile &Tile = TileList[its][itl];
	
	// Find its priority;
	// this scheme is inspired by the Least Recently Used (LRU)
	// algorithm of virtual-memory page replacement,
	// which is to page out the least recently used pages.
	CurrentPriority += PriorityQuantum;
	if (CurrentPriority > 1.0) ResetPriorities();
	
	// Now set the texture itself
	Tile.SetPriority(CurrentPriority);
	Tile.Use();
		
	if (!Tile.WasLoaded) {
		
		// Expand the colors with the color table
		for (int ip=0; ip<MaraNumWTPixels; ip++) {
			Intmd[ip] = ColorTableList[its][Tile.Pixels[ip]];
		}
		
		// Load the image
		/*
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB5_A1,
			MaraWallTxtrSize, MaraWallTxtrSize, 0,
				GL_RGBA, GL_UNSIGNED_BYTE, Intmd.begin());
		*/

		gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGB5_A1,
			MaraWallTxtrSize, MaraWallTxtrSize,
				GL_RGBA, GL_UNSIGNED_BYTE, Intmd.begin());
		
		// What kind of texture mapping to do
		// GL_MODULATE means that the textures
		// will be multiplied by the current OpenGL color,
		// for doing lighting
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
				
		// Tile the textures
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		

                // Anisotropic filtering (good for looking along walls):
#if defined(GL_TEXTURE_MAX_ANISOTROPY_EXT)
                GLfloat MaxAniso;
                glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &MaxAniso);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, MaxAniso);
#endif
		
		Tile.WasLoaded = true;
	}
	
	// Set render modes for each distance; redo each time since it could change:
	// Up close
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, CloseupRenderMode);	
	// Far away
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, DistantRenderMode);
	
	return true;
}

struct TileDesc {
	short Set, Tile;
	GLclampf Priority;
};


class TileDescIndxSort: public IndexHeapSort {
	TileDesc *TDList;
	
	int Compare(int i1, int i2) {
		return (TDList[i1].Priority <= TDList[i2].Priority);
	}
	
	public:
	TileDescIndxSort(int _n, TileDesc *_TDList):
		IndexHeapSort(_n), TDList(_TDList) {}
};


void TextureManager::ResetPriorities() {
	
	// Load up the texture-tile priority list:
	// May want to cache it, but that's a later improvement
	
	int TotNum = 0;
	int its, itl;
	for (its=0; its<NumWallTxtrSets; its++)
		TotNum += TileList[its].get_len();
	
	simple_vector<TileDesc> TDList(TotNum);

	int CurrIndx = 0;
	for (its=0; its<NumWallTxtrSets; its++) {
		for (itl=0; itl<TileList[its].get_len(); itl++) {
			TileDesc &TD = TDList[CurrIndx];
			TD.Set = its;
			TD.Tile = itl;
			TD.Priority = TileList[its][itl].GetPriority();
			CurrIndx++;
		}
	}
	
	// Sort!
	TileDescIndxSort Sorter(TDList.get_len(),TDList.begin());
	Sorter.Sort();
	
	// Reset the priorities
	for (int i=0; i<TotNum; i++) {
		TileDesc &TD = TDList[i];
		TileList[TD.Set][TD.Tile].SetPriority(PriorityQuantum*Sorter.Index(i));
	}
	
	// Finally!
	CurrentPriority = PriorityQuantum*(TotNum - 1);
}
