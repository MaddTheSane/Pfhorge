#include "GLMain.h"
#include <simd/simd.h>

#ifndef _CAMERA_H
#define _CAMERA_H

// This was created to allow you to use this camera code in your projects
// without having to cut and paste code.  This file and camera.cpp should be
// added to your project.

//! This is our camera class
class CCamera {

public:

    //! Our camera constructor
    CCamera();  

    //! These are our data access functions for our camera's private data
    simd::float3 Position() {   return m_vPosition;     }
    //! These are our data access functions for our camera's private data
    simd::float3 View()     {   return m_vView;         }
    //! These are our data access functions for our camera's private data
    simd::float3 UpVector() {   return m_vUpVector;     }
    //! These are our data access functions for our camera's private data
    simd::float3 Strafe()   {   return m_vStrafe;       }
    
    //! This changes the position, view, and up vector of the camera.
    //! This is primarily used for initialization
    void PositionCamera(float positionX, float positionY, float positionZ,
                        float viewX,     float viewY,     float viewZ,
                        float upVectorX, float upVectorY, float upVectorZ);

    //! This changes the position, view, and up vector of the camera.
    //! This is primarily used for initialization
    inline void PositionCamera(simd::float3 position,
							   simd::float3 view,
							   simd::float3 upVector) {
		m_vPosition = position;                    // Assign the position
		m_vView     = view;                        // Assign the view
		m_vUpVector = upVector;                    // Assign the up vector
	}

    //! This rotates the camera's view around the position depending on the values passed in.
    void RotateView(float angle, float X, float Y, float Z);

    //! This moves the camera's view by the mouse movements (First person view)
    void SetViewByMouse(); 

    //! This rotates the camera around a point (I.E. your character).
    //void RotateAroundPoint(simd::float3 vCenter, float X, float Y, float Z);

    //! This strafes the camera left or right depending on the speed (+/-)
    void StrafeCamera(float speed);

    //! This will move the camera forward or backward depending on the speed
    void MoveCamera(float speed);

    //! This checks for keyboard movement
    void CheckForMovement(bool upPressed, bool downPressed, bool leftPressed, bool rightPressed);

    //! This updates the camera's view and other data (Should be called each frame)
    void Update(bool upPressed, bool downPressed, bool leftPressed, bool rightPressed);

    //! This uses gluLookAt() to tell OpenGL where to look
    void Look();

private:

    //! The camera's position
    simd::float3 m_vPosition;

    //! The camera's view
    simd::float3 m_vView;

    //! The camera's up vector
    simd::float3 m_vUpVector;
    
    //! The camera's strafe vector
    simd::float3 m_vStrafe;
};

#endif


/////////////////////////////////////////////////////////////////////////////////
//
// * QUICK NOTES * 
//
// Nothing was added to this file since the Camera5 tutorial on strafing.
//
// 
// Ben Humphrey (DigiBen)
// Game Programmer
// DigiBen@GameTutorials.com
// Co-Web Host of www.GameTutorials.com
//
//
