// Here are the controls for the motion and the portals

#pragma once

#include "TextFieldObject.h"


class MotPort {

public:
	
	// Motion-speed control
	enum {
		Speed_Eighth,
		Speed_Fourth,
		Speed_Half,
		Speed_One,
		NUM_MOTION_SPEEDS
	};
	
	int SpeedPopup;
	
	float GetMotionSpeed() {
		const float MotionSpeedList[NUM_MOTION_SPEEDS] = {
			 128,
			 256,
			 512,
			1024
		};
		
		// One-based to zero-based indexing
		return MotionSpeedList[SpeedPopup];
	}
	
	// Walk through walls into the void
	bool WalkThruWallsCB;
	
	// Position (X, Y, Z):
	Float_TFO PositionTF[3];
	// Previous one (to revert to if desired)
	float PrevPos[3];
	
	// Visibility-mode control: choice of
	// All polygons
	// Those visible by portal-rendering calculation
	// Only those polygons of the viewpoint's current room
	enum {
		VisMode_All,
		VisMode_Portal,
		VisMode_One,
		NUM_VISIBILITY_MODES
	};
	
	int VisModePopup;
	
	// Clip the rendering to the portals when doing portal rendering
	bool ClipToPortalCB;
	
	// Jump from the void
	bool JumpFromVoidCB;
	
	// Do depth sorting when in portal-rendering mode
	bool DepthSortCB;
	
	// Do Z-buffering
	bool ZBufferCB;
	
	// Render in reverseorder
	bool ReverseOrderCB;
	
	// Perform the dialog-box action
	// Returns whether or not exited with OK (something got changed)
	bool Do();
	
	// Set up the dialog box
	void Init();
	
	// Various extra routines
	void Defaults();
	void Save();
	void Restore();
};
