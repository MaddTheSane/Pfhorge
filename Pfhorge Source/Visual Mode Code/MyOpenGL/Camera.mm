//***********************************************************************//
//                                                                       //
//      - "Talk to me like I'm a 3 year old!" Programming Lessons -      //
//                                                                       //
//      $Author:        DigiBen     DigiBen@GameTutorials.com            //
//                                                                       //
//      $Program:       TimeBasedMovement                                //
//                                                                       //
//      $Description:   Demonstrates camera movement in regards to time  //
//                                                                       //
//      $Date:          4/30/02                                          //
//                                                                       //
//***********************************************************************//


#include "GLMain.h"
#include "Camera.h"
#include <sys/times.h>
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#import <Foundation/Foundation.h>
#import "LEExtras.h"
#include <cmath>
#include <ApplicationServices/ApplicationServices.h>
#import <Cocoa/Cocoa.h>
/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *

// We increased the speed a bit from the Camera Strafing Tutorial
// This is how fast our camera moves
#define kSpeed  15.0f                                   

// Create a global float that stores the elapsed time between the current
// and last frame.  For your engine, this would move likely go into a 
// CTime or CTimer class, along with the CalculateFrameRate() function.
static float g_FrameInterval = 0.0f;

/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *

//extern bool upPressed , downPressed, leftPressed , rightPressed;

using namespace simd;

///////////////////////////////// CALCULATE FRAME RATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This function calculates the frame rate and time intervals between frames
/////
///////////////////////////////// CALCULATE FRAME RATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

static void CalculateFrameRate()
{
    static float framesPerSecond    = 0.0f;     // This will store our fps
    static float lastTime           = 0.0f;     // This will hold the time from the last frame
    static char strFrameRate[50] = {0};         // We will store the string here for the window title


/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *

    static float frameTime = 0.0f;              // This stores the last frame's time
	
	struct tms tmpTimes;
	
    float currentTime = TickCount() * 0.016f;                

    // Here we store the elapsed time between the current and last frame,
    // then keep the current frame in our static variable for the next frame.
    g_FrameInterval = currentTime - frameTime;
    frameTime = currentTime;

/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *


    // Increase the frame counter
    ++framesPerSecond;

    // Now we want to subtract the current time by the last time that was stored
    // to see if the time elapsed has been over a second, which means we found our FPS.
    if( currentTime - lastTime > 1.0f )
    {
        // Here we set the lastTime to the currentTime
        lastTime = currentTime;
        
        // Copy the frames per second into a string to display in the window title bar
        //sprintf(strFrameRate, "Current Frames Per Second: %d", int(framesPerSecond));
		printf("Current Frames Per Second: %d\n", int(framesPerSecond));
		
        // Set the window title bar to our string
        //SDL_WM_SetCaption(strFrameRate,"GameTutorials");

        // Reset the frames per second
        framesPerSecond = 0;
    }
}


///////////////////////////////// CCAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This is the class constructor
/////
///////////////////////////////// CCAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

CCamera::CCamera()
{
    m_vPosition = simd_make_float3(0.0, 0.0, 0.0);      // Init a vVector to 0 0 0 for our position
    m_vView = simd_make_float3(0.0, 1.0, 0.5);          // Init a starting view vVector (looking up and out the screen)
    m_vUpVector   = simd_make_float3(0.0, 0.0, 1.0);    // Init a standard up vVector (Rarely ever changes)
}


///////////////////////////////// POSITION CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This function sets the camera's position and view and up vVector.
/////
///////////////////////////////// POSITION CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void CCamera::PositionCamera(float positionX, float positionY, float positionZ,
                             float viewX,     float viewY,     float viewZ,
                             float upVectorX, float upVectorY, float upVectorZ)
{
    auto vPosition  = simd_make_float3(positionX, positionY, positionZ);
    auto vView      = simd_make_float3(viewX, viewY, viewZ);
    auto vUpVector  = simd_make_float3(upVectorX, upVectorY, upVectorZ);

	PositionCamera(vPosition, vView, vUpVector);
}


///////////////////////////////// SET VIEW BY MOUSE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This allows us to look around using the mouse, like in most first person games.
/////
///////////////////////////////// SET VIEW BY MOUSE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/*
void CCamera::SetViewByMouse()
{
    int mouseX,mouseY;                              // The mouse X and Y coordinates
    int middleX = SCREEN_WIDTH  >> 1;               // This is a binary shift to get half the width
    int middleY = SCREEN_HEIGHT >> 1;               // This is a binary shift to get half the height
    float angleY = 0.0f;                            // This is the direction for looking up or down
    float angleZ = 0.0f;                            // This will be the value we need to rotate around the Y axis (Left and Right)
    static float currentRotX = 0.0f;
    
    // Get the mouse's current X,Y position
    SDL_GetMouseState(&mouseX,&mouseY); 

    // If our cursor is still in the middle, we never moved... so don't update the screen
    if( (mouseX == middleX) && (mouseY == middleY) ) return;

    // Set the mouse position to the middle of our window
    SDL_WarpMouse(middleX, middleY);                            

    // Get the direction the mouse moved in, but bring the number down to a reasonable amount
    angleY = (float)( (middleX - mouseX) ) / 1000.0f;       
    angleZ = (float)( (middleY - mouseY) ) / 1000.0f;       

    // Here we keep track of the current rotation (for up and down) so that
    // we can restrict the camera from doing a full 360 loop.
    currentRotX -= angleZ;  

    // If the current rotation (in radians) is greater than 1.0, we want to cap it.
    if(currentRotX > 1.0f)
        currentRotX = 1.0f;
    // Check if the rotation is below -1.0, if so we want to make sure it doesn't continue
    else if(currentRotX < -1.0f)
        currentRotX = -1.0f;
    // Otherwise, we can rotate the view around our position
    else
    {
        // To find the axis we need to rotate around for up and down
        // movements, we need to get a perpendicular vector from the
        // camera's view vector and up vector.  This will be the axis.
        CVector3 vAxis = Cross(m_vView - m_vPosition, m_vUpVector);
        vAxis = Normalize(vAxis);

        // Rotate around our perpendicular axis and along the y-axis
        RotateView(angleZ, vAxis.x, vAxis.y, vAxis.z);
        RotateView(angleY, 0, 1, 0);
    }
}
*/

///////////////////////////////// ROTATE VIEW \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This rotates the view around the position using an axis-angle rotation
/////
///////////////////////////////// ROTATE VIEW \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void CCamera::RotateView(float angle, float x, float y, float z)
{
    simd::float3 vNewView;

    // Get the view vector (The direction we are facing)
    simd::float3 vView = m_vView - m_vPosition;

    // Calculate the sine and cosine of the angle once
    float cosTheta = (float)std::cos(angle);
    float sinTheta = (float)std::sin(angle);

    // Find the new x position for the new rotated point
    vNewView.x  = (cosTheta + (1 - cosTheta) * x * x)       * vView.x;
    vNewView.x += ((1 - cosTheta) * x * y - z * sinTheta)   * vView.y;
    vNewView.x += ((1 - cosTheta) * x * z + y * sinTheta)   * vView.z;

    // Find the new y position for the new rotated point
    vNewView.y  = ((1 - cosTheta) * x * y + z * sinTheta)   * vView.x;
    vNewView.y += (cosTheta + (1 - cosTheta) * y * y)       * vView.y;
    vNewView.y += ((1 - cosTheta) * y * z - x * sinTheta)   * vView.z;

    // Find the new z position for the new rotated point
    vNewView.z  = ((1 - cosTheta) * x * z - y * sinTheta)   * vView.x;
    vNewView.z += ((1 - cosTheta) * y * z + x * sinTheta)   * vView.y;
    vNewView.z += (cosTheta + (1 - cosTheta) * z * z)       * vView.z;

    // Now we just add the newly rotated vector to our position to set
    // our new rotated view of our camera.
    m_vView = m_vPosition + vNewView;
}


///////////////////////////////// STRAFE CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This strafes the camera left and right depending on the speed (-/+)
/////
///////////////////////////////// STRAFE CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void CCamera::StrafeCamera(float speed)
{   
    // Add the strafe vector to our position
    m_vPosition.xz += m_vStrafe.xz * speed;

    // Add the strafe vector to our view
    m_vView.xz += m_vStrafe.xz * speed;
}


///////////////////////////////// MOVE CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This will move the camera forward or backward depending on the speed
/////
///////////////////////////////// MOVE CAMERA \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void CCamera::MoveCamera(float speed)
{
    // Get the current view vector (the direction we are looking)
    float3 vVector = m_vView - m_vPosition;
    vVector = normalize(vVector);

    m_vPosition.xz += vVector.xz * speed;     // Add our acceleration to our position's X/Z
    m_vView.xz += vVector.xz * speed;         // Add our acceleration to our view's X/Z
}


//////////////////////////// CHECK FOR MOVEMENT \\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This function handles the input faster than in the WinProc()
/////
//////////////////////////// CHECK FOR MOVEMENT \\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void CCamera::CheckForMovement(bool upPressed, bool downPressed, bool leftPressed, bool rightPressed)
{

/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *
    
    // Once we have the frame interval, we just need to find the current speed.
    // This is done by multiplying our speed by the elapsed time between frames.
    // We can then pass that speed into our camera movement functions.
    float speed = kSpeed * g_FrameInterval;

/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *


    // Check if we hit the Up arrow or the 'w' key
    if(upPressed) {             

        // Move our camera forward by a positive SPEED
        MoveCamera(speed);              
    }

    // Check if we hit the Down arrow or the 's' key
    if(downPressed) {           

        // Move our camera backward by a negative SPEED
        MoveCamera(-speed);             
    }

    // Check if we hit the Left arrow or the 'a' key
    if(leftPressed) {           

        // Strafe the camera left
        StrafeCamera(-speed);
    }

    // Check if we hit the Right arrow or the 'd' key
    if(rightPressed) {          

        // Strafe the camera right
        StrafeCamera(speed);
    }   
}


///////////////////////////////// UPDATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This updates the camera's view and strafe vector
/////
///////////////////////////////// UPDATE \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void CCamera::Update(bool upPressed, bool downPressed, bool leftPressed, bool rightPressed) 
{
    // Initialize a variable for the cross product result
    simd::float3 vCross = cross(m_vView - m_vPosition, m_vUpVector);

    // Normalize the strafe vector
    m_vStrafe = normalize(vCross);

    // Move the camera's view by the mouse
    //SetViewByMouse();

    // This checks to see if the keyboard was pressed
    CheckForMovement(upPressed, downPressed, leftPressed, rightPressed);

    
/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *

    // We stick this function in our camera source file so that we can move
    // time base movement and camera functionality together between tutorials
    // relatively easyly. 
    
    // We calculate our frame rate and set our frame interval for time based movement
    CalculateFrameRate();

/////// * /////////// * /////////// * NEW * /////// * /////////// * /////////// *
}


// Adapted from GLKit's GLKMatrix4MakeLookAt
static inline float4x4 matrix4MakeLookAt(float3 eye, float3 center, float3 up)
{
    float3 n = normalize(eye - center);
    float3 u = normalize(cross(up, n));
    float3 v = cross(n, u);
    float4x4 m(simd_make_float4(u.x, v.x, n.x, 0.0f),
               simd_make_float4(u.y, v.y, n.y, 0.0f),
               simd_make_float4(u.z, v.z, n.z, 0.0f),
               simd_make_float4(dot(-u, eye),
                                dot(-v, eye),
                                dot(-n, eye),
                                1.0f));
    return m;
}


///////////////////////////////// LOOK \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*
/////
/////   This updates the camera according to the 
/////
///////////////////////////////// LOOK \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\*

void CCamera::Look()
{
	//TODO: test this code!
	float4x4 lookMatrix = matrix4MakeLookAt(m_vPosition, m_vView, m_vUpVector);
	::glMultMatrixf((GLfloat*)&lookMatrix);
//	glTranslatef(-m_vPosition.x, -m_vPosition.y, -m_vPosition.z);
    // Give openGL our camera position, then camera view, then camera up vector
//    gluLookAt(m_vPosition.x, m_vPosition.y, m_vPosition.z,
//              m_vView.x,     m_vView.y,     m_vView.z,  
//              m_vUpVector.x, m_vUpVector.y, m_vUpVector.z);
}


/////////////////////////////////////////////////////////////////////////////////
//
// * QUICK NOTES * 
//
// In this tutorial we added time base movement to our camera class.
// This way the camera will travel at the same speed, no matter what computer.
// We calculate the frame rate in Update(), which should be called each frame.
//
//
// Ben Humphrey (DigiBen)
// Game Programmer
// DigiBen@GameTutorials.com
// Co-Web Host of www.GameTutorials.com
//
//
