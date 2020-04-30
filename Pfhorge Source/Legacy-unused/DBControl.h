// This object does dialog-box controls such as popup menus.

#pragma once

#include <Carbon/Carbon.h>

//#include <Dialogs.h>
#include "ActionAdapter.h"


class DBControl {

	ControlHandle Hdl;
	
public:
	// The control ID in the dialog box:
	short ID;
	
	// Which state:
	short State;
	
	// Which previous state (for reverting)
	short PrevState;
	
	// Which default state
	short DfltState;

	// Action to take:
	ActionAdapter *ClickedAction;
	
	// Update action:
	// call this anytime the state is reset
	void Update() {
		if (ClickedAction)
			ClickedAction->Do();
	}
	
	// Set the state to something
	void SetState(short NewState)
		{State = NewState; /*SetControlValue(ControlHandle(Hdl), State); Update();*/}
	
	// Get the state value
	void UpdateState() {/*State = GetControlValue(ControlHandle(Hdl));*/}
	
	// Default state
	void Default() {SetState(DfltState);}
	
	// Save state:
	void Save() {PrevState = State;}
	
	// Restore state:
	void Restore() {SetState(PrevState);}
	
	// Enabling and disabling
	void Enable() {/*HiliteControl(Hdl, 0);*/}
	void Disable() {/*HiliteControl(Hdl, 255);*/}
	
	// Was one of the buttons clicked?
	bool Clicked(short ItemHit) {
		if (ID == ItemHit) {
			UpdateState();
			Update();
			return true;
		} else return false;
	}
	
	// Set up; do after the dialog-box numbers have been set.
	void Setup(DialogPtr Dialog) {
		///short ItemType; // Might want to check for debugging purposes
		///Rect ItemRect; // Don't want to keep these
		
		////*GetDialogItem(Dialog, ID, &ItemType, (Handle *)&Hdl, &ItemRect);*/
	}
	
	DBControl() {ClickedAction = 0;}
};
