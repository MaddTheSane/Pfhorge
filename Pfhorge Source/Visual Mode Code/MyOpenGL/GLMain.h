#ifndef _MAIN_H
#define _MAIN_H

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <OpenGL/gl.h>                                      // Header File For The OpenGL32 Library
#include <OpenGL/glu.h>                                     // Header File For The GLu32 Library

//#include "SDL.h"

#define SCREEN_WIDTH 800                                // We want our screen width 800 pixels
#define SCREEN_HEIGHT 600                               // We want our screen height 600 pixels
#define SCREEN_DEPTH 32                                 // We want 32 bits per pixel

using namespace std;


extern int VideoFlags;                                  //!< The Pixel Format flags

//! This function resizes the viewport for OpenGL.
void SizeOpenGLScreen(int width, int height);

//! This function handles all the initialization for openGL
void InitializeGL(int width, int height);

#endif  // _MAIN_H_

/////////////////////////////////////////////////////////////////////////////////
//
// * QUICK NOTES *
//
// The camera class was taken out of this file and put into camera.h
//
//
// Ben Humphrey (DigiBen)
// Game Programmer
// DigiBen@GameTutorials.com
// Co-Web Host of www.GameTutorials.com
//
//
