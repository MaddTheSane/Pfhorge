// This does the work of the Motion/Portals dialog box

#include "MotPort.h"
#include "MiscUtils.h"
#include "SimpleVec.h"


void MotPort::Init() {
	
	// Set up the control fields:
	SpeedPopup = Speed_One;
	WalkThruWallsCB = true;
	VisModePopup = VisMode_All;
	ClipToPortalCB = true;
	JumpFromVoidCB = true;
	DepthSortCB = true;
	ZBufferCB = true;
	ReverseOrderCB = false;
}

bool MotPort::Do() {
	
	// What to do when finishing
	return true;
}
