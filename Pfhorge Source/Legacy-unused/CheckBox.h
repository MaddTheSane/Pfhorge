// This object does dialog-box checkboxes

#pragma once

#include <Carbon/Carbon.h>

//#include <Dialogs.h>
#include "ActionAdapter.h"


class CheckBox {

	ControlHandle Hdl;
	
public:
	// The checkbox ID in the dialog box:
	short ID;
	
	// Which state (0 or 1)
	short Checked;
	
	// Which previous state (for reverting)
	short PrevChecked;
	
	// Which default state
	short DfltChecked;

	// Action to take:
	ActionAdapter *ClickedAction;
	
	// Update to new state
	void Update() {
		/*if (Checked)
			SetControlValue(Hdl,1);
		else
			SetControlValue(Hdl,0);
		if (ClickedAction)
			ClickedAction->Do();*/
	}
	
	// Default state
	void Default() {Checked = DfltChecked; Update();}
	
	// Save state:
	void Save() {PrevChecked = Checked;}
	
	// Restore state:
	void Restore() {Checked = PrevChecked; Update();}
	
	// Enabling and disabling
	void Enable() {/*HiliteControl(Hdl, 0);*/}
	void Disable() {/*HiliteControl(Hdl, 255);*/}
	
	// Was one of the buttons clicked?
	bool Clicked(short ItemHit) {
		if (ID == ItemHit) {
			if (Checked) Checked = 0; else Checked = 1;
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
	
	CheckBox() {ClickedAction = 0;}
};
