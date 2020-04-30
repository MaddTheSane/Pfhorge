// This is for specifying the keyboard controls:

#pragma once

#include "TextFieldObject.h"


// This object contains each key-control character
// and the associated dialog-box info.
// It is designed to store keys as uppercase.
struct KeyControlChar: String_TFO<1> {

	// The text-field ID in the dialog box:
	short ID;
	
	// Which value
	unsigned char KCChar;
	
	// Which previous state (for reverting)
	unsigned char KCChar_Prev;
	
	// Which default state
	unsigned char KCChar_Dflt;
	
	void Update() {
		///unsigned char Buffer[2];
		///val[0] = 1;
		val[1] = KCChar;
		SetValue();
	}

	// Default state
	void Default() {KCChar = KCChar_Dflt; Update();}
	
	// Save state:
	void Save() {KCChar_Prev = KCChar;}
	
	// Restore state:
	void Restore() {KCChar = KCChar_Prev; Update();}
	
	// Set up:
	void Setup(DialogPtr Dialog) {String_TFO<1>::Setup(Dialog,ID);}
	
	// Get the value;
	// reject zero-length characters,
	// and cut off any extra ones.
	bool Grab() {
		GetValue();
		if (val[0] < 1) return false;
		KCChar = toupper(int(val[1]));
		Update();
		return true;
	}
};


class KeyControls {

	DialogPtr DPtr;

public:
	enum {
		MoveForward,
		MoveBackward,
		
		TurnLeftward,
		TurnRightward,
		
		MoveLeftward,
		MoveRightward,
		
		MoveUpward,
		MoveDownward,
		
		LookUpward,
		LookCenter,
		LookDownward,
		
		NUM_KEY_CONTROLS
	};
	
	KeyControlChar ControlList[NUM_KEY_CONTROLS];
	
	// Perform the dialog-box action
	void Do();
	
	// Set up the dialog box
	void Init();
	
	// Various extra routines
	void Defaults();
	void Save();
	void Restore();
	bool Check();
	
	KeyControls() {DPtr = 0;}
	virtual ~KeyControls();
};
