// This is an object for wall texture management:
// it contains the wall textures and associated info

#pragma once

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

#include "SimpleVec.h"

/*
	This includes all the texture set: M2/oo and M1
	M2/oo has 9 texture sets; 5 walls and 4 landscapes:
	M2/oo Walls:
		Water -- 17
		Lava -- 18
		Sewage -- 19
		Jjaro -- 20
		Pfhor -- 21
	M2/oo Landscapes:
		Day -- 27
		Night -- 28
		Moon -- 29
		Outer Space -- 30
	M1 has 6 texture sets:
		Marathon 1 -- 17
		Marathon 2 -- 18
		Marathon 3 -- 19
		Marathon Controls -- 8
		Pfhor -- 2
		Pfhor Controls -- 24
*/
const int NumWallTxtrSets = 15;

// Correct for both M1 and M2/oo
const int MaraWallTxtrSize = 128;
const int MaraNumWTPixels = MaraWallTxtrSize*MaraWallTxtrSize;
const int ColorTableSize = 256;


struct TextureTile {

	// Flag for whether texture was loaded
	bool WasLoaded;

	// OpenGL texture ID
	GLuint ID;
	
	// Average color value:
	GLfloat AvgColor[4];
	
	// Pixel data (color indices)
	GLubyte Pixels[MaraNumWTPixels];
	
	// Make current texture the rendering context
	void Use() {glBindTexture(GL_TEXTURE_2D,ID);}
	
	// Is the texture ID valid?
	// Good for debugging
	GLboolean IsValid() {return glIsTexture(ID);}
	
	// Texture priority:
	void SetPriority(GLclampf Priority) {glPrioritizeTextures(1,&ID,&Priority);}
	GLclampf GetPriority() {GLclampf Priority; Use();
		glGetTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_PRIORITY, &Priority);
		return Priority;
	}
	
	// Ctor and dtor create and destroy a texture ID
	TextureTile() {glGenTextures(1,&ID); WasLoaded = false; SetPriority(0.0);}
	~TextureTile() {glDeleteTextures(1,&ID);}
};


struct TextureManager {
	
	// Color table in RGBA form (what OpenGL likes)
	GLuint ColorTableList[NumWallTxtrSets][ColorTableSize];
	
	// Lists of texture tiles
	simple_vector<TextureTile> TileList[NumWallTxtrSets];
	
	// Intermediate buffer for loading a texture tile into OpenGL
	simple_vector<GLuint> Intmd;
	
	// Resets a set's wall textures to "unloaded"
	// In case it's necessary to reload
	void Reset(int its);
	void ResetAll() {for (int its=0; its<NumWallTxtrSets; its++) Reset(its);}
	
	// Use the specified wall texture; load if necessary
	// Returns whether it is in range
	// Args: tile set, which tile in set
	bool Use(int its, int itl);
	
	// Get pointer to the average color: returns 0 if out of range
	// Args: same as above
	GLfloat *GetAvgColor(int its, int itl);
	
	// Find the average colors for all the loaded texture sets
	void FindAverage(int its);
	void FindAllAverages() {for (int its=0; its<NumWallTxtrSets; its++) FindAverage(its);}
	
	// Current texture priority
	GLclampf CurrentPriority;
	
	// Reset all the priorities: they will be in the right order,
	// but as small as possible
	void ResetPriorities();
	
	// Closeup and distant render modes of surfaces
	GLint CloseupRenderMode;
	GLint DistantRenderMode;
		
	// Ctor
	TextureManager() : Intmd(MaraNumWTPixels), CurrentPriority(0),
		CloseupRenderMode(GL_LINEAR), DistantRenderMode(GL_LINEAR) {}
};

