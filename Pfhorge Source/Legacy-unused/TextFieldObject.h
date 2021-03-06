// This is a generic text-field handler

#pragma once

#include <Carbon/Carbon.h>

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
//#include <Dialogs.h>
#include "MiscUtils.h"
#include "SimpleVec.h"


class TextFieldObject {
	
	ControlHandle Hdl;
	
protected:
	
	// Both of these operations return whether
	// the operation could be performed successfully
	// One can check for format errors here.
	
	// Value -> Text buffer
	virtual bool SetValueIntoText(Str255 TextBuffer) = 0;
	
	// Text buffer -> value
	virtual bool GetValueFromText(ConstStr255Param TextBuffer) = 0;

public:
	
	void Setup(DialogPtr Dialog, short ID) {
		/*short ItemType; // Might want to check for debugging purposes
		Rect ItemRect; // Don't want to keep these
		
		GetDialogItem(Dialog, ID, &ItemType,
			(Handle *)&Hdl, &ItemRect);*/
	}
	
	// Updates text-field contents
	bool SetValue() {
		/*Str255 TextBuffer;
		if (!SetValueIntoText(TextBuffer)) return false;
		SetDialogItemText(Handle(Hdl),TextBuffer);
		return true;*/
                return true;
	}
	
	// Gets text-field contents; won't update
	bool GetValue() {
		/*Str255 TextBuffer;
		GetDialogItemText(Handle(Hdl),TextBuffer);
		return GetValueFromText(TextBuffer);*/
                return true;
	}
};


// Various kinds:


// This is for Pascal strings: call Pas2C or C2Pas to do appropriate conversions
template<int Len> class String_TFO: public TextFieldObject {
public:

	unsigned char val[Len+1];

private:
	
	// Value -> Text buffer
	bool SetValueIntoText(Str255 TextBuffer) {
		memcpy(TextBuffer,val,min(int(val[0]),Len)+1);
		return true;
	}
	
	// Text buffer -> value
	bool GetValueFromText(ConstStr255Param TextBuffer) {
		memcpy(val,TextBuffer,min(int(val[0]),Len)+1);
		return true;
	}
};


// This is for integers:
class Int_TFO: public TextFieldObject {
public:

	long val;

private:
	
	// Value -> Text buffer
	bool SetValueIntoText(Str255 TextBuffer) {
		sprintf((char *)TextBuffer,"%ld",val);
		C2Pas(TextBuffer,TextBuffer);
		return true;
	}
	
	// Text buffer -> value
	bool GetValueFromText(ConstStr255Param TextBuffer) {
		Str255 LocalTextBuffer;
		Pas2C((unsigned char *)TextBuffer,LocalTextBuffer);
		val = atoi((char *)LocalTextBuffer);
		return true;
	}
};


// This is for double-precision floats:
class Float_TFO: public TextFieldObject {
public:

	double val;

private:
	
	// Value -> Text buffer
	bool SetValueIntoText(Str255 TextBuffer) {
		///sprintf((char *)TextBuffer,"%lf",val);
		///C2Pas(TextBuffer,TextBuffer);
		return true;
	}
	
	// Text buffer -> value
	bool GetValueFromText(ConstStr255Param TextBuffer) {
		Str255 LocalTextBuffer;
		Pas2C((unsigned char *)TextBuffer,LocalTextBuffer);
		val = atof((char *)LocalTextBuffer);
		return true;
	}
};
