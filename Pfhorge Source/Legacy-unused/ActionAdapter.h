// This is a simple "action adapter" object for doing dialog-box callbacks;
// it is to be subclassed to do specific actions -- its subclasses can contain
// whatever data is necessary for that.

#pragma once

struct ActionAdapter {
	virtual void Do() = 0;
};
