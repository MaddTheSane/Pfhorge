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
#define SCREEN_DEPTH 32                                 // We want 16 bits per pixel

using namespace std;


extern int VideoFlags;                                  // The Pixel Format flags
//extern SDL_Surface * MainWindow;                        // Our Drawable portion of the window

// This Controls our MainLoop
//void MainLoop(void);

// This toggles between the Full Screen mode and the windowed mode
//void ToggleFullScreen(void);

// This allows us to configure our window for OpenGL and backbuffered
//void SetupPixelFormat(void);

// This is our own function that makes creating a window modular and easy
//void CreateMyWindow(const char *strWindowName, int width, int height, int VideoFlags);

// This inits our screen translations and projections
void SizeOpenGLScreen(int width, int height);

// This sets up OpenGL
void InitializeGL(int width, int height);

// This initializes the whole program
//void Init();

// This handles the keypress events generated when the user presses a key
//void HandleKeyPressEvent(SDL_keysym * keysym);

// This handles the keyrelease events generated when the user releases a key
//void HandleKeyReleaseEvent(SDL_keysym * keysym);

// This draws everything to the screen
//void RenderScene();

// This shuts down SDL and quits program
//void Quit(int ret_val);

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
