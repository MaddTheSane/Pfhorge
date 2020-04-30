// Here is the work of the KeyControls object:

#include <Carbon/Carbon.h>
#include "KeyControls.h"


#warning re-write!

const short KeyDialogID = 700;
const short KeyStringsID = 700;

const short EmptyAlertID = 710;
const short RedundantAlertID = 720;


enum {
	OK_ID = 1,
	Cancel_ID,
	Revert_ID,
	Defaults_ID
};

KeyControls::~KeyControls() {
//	if (DPtr != 0)
//		DisposeDialog(DPtr);
}

void KeyControls::Init() {
    /*
	// Create the dialog box
	DPtr = GetNewDialog(KeyDialogID, nil, WindowPtr(-1));

	// Set up the dialog-box fields:
	for (int k=0; k<NUM_KEY_CONTROLS; k++) {
		// Grab from resource
		Str255 StringBuffer;
		GetIndString(StringBuffer,KeyStringsID,k+1);
		ControlList[k].KCChar_Dflt =
			toupper(int((StringBuffer[0] > 0) ? StringBuffer[1] : ' '));
		
		// Generate ID numbers automatically
		ControlList[k].ID = 6 + 2*k;
		ControlList[k].Setup(DPtr);
		ControlList[k].Default();
	}
    */
}


void KeyControls::Defaults() {

	for (int k=0; k<NUM_KEY_CONTROLS; k++)
		ControlList[k].Default();

}


void KeyControls::Save() {

	for (int k=0; k<NUM_KEY_CONTROLS; k++)
		ControlList[k].Save();

}


void KeyControls::Restore() {

	for (int k=0; k<NUM_KEY_CONTROLS; k++)
		ControlList[k].Restore();

}


void KeyControls::Do() {

	Save();
	//ShowWindow(DPtr);
	//SelectWindow(DPtr);

	bool QuitFlag = true; /// <--- false
	while(!QuitFlag) {
		short ItemHit=0;
//		ModalDialog(nil,&ItemHit);
		
		switch(ItemHit) {
		case OK_ID:
			QuitFlag = Check();
			break;
			
		case Cancel_ID:
			Restore();
			QuitFlag = true;
			break;
			
		case Revert_ID:
			Restore();
			break;
			
		case Defaults_ID:
			Defaults();
			break;
		}
	}
	
	//HideWindow(DPtr);
}


bool KeyControls::Check() {

	for (int k=0; k<NUM_KEY_CONTROLS; k++)
		if (!ControlList[k].Grab()) {
			///StopAlert(EmptyAlertID,nil);
			return false;
		}
	
	for (int k1=0; k1<NUM_KEY_CONTROLS; k1++)
		for (int k2=0; k2<NUM_KEY_CONTROLS; k2++) {
			if (k2 == k1) continue;
			if (ControlList[k2].KCChar == ControlList[k1].KCChar) {
				///StopAlert(RedundantAlertID,nil);
				return false;
			}
		}
        return true;
}
