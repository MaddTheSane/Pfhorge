// Copyright 2001 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// http://www.omnigroup.com/DeveloperResources/OmniSourceLicense.html.

#import <AppKit/AppKit.h>
#import "InputHelpers.h"

#if 0
#import <drivers/event_status_driver.h>
#else
// TJW - The definition of NXMouseScaling is not present in the public headers right now.
//       Copied in from Darwin.   Also, event_status_driver.h imports two headers that
//       don't exist in public builds (one of which contains this typedef).

#define NX_MAXMOUSESCALINGS 20

typedef struct evsioMouseScaling        /* Match old struct names in kernel */
{
    int numScaleLevels;
    short scaleThresholds[NX_MAXMOUSESCALINGS];
    short scaleFactors[NX_MAXMOUSESCALINGS];
} NXMouseScaling;

typedef mach_port_t NXEventHandle;

extern NXEventHandle NXOpenEventStatus(void);
extern void NXCloseEventStatus(NXEventHandle handle);

extern void NXSetMouseScaling(NXEventHandle handle, NXMouseScaling *scaling);
extern void NXGetMouseScaling(NXEventHandle handle, NXMouseScaling *scaling);

extern double NXKeyRepeatInterval(NXEventHandle handle);
extern double NXKeyRepeatThreshold(NXEventHandle handle);
extern void NXSetKeyRepeatInterval(NXEventHandle handle, double seconds);
extern void NXSetKeyRepeatThreshold(NXEventHandle handle, double threshold);

#endif



static BOOL           mouseScalingEnabled = YES;
static NXMouseScaling originalMouseScaling;

void SetMouseScalingEnabled(BOOL enabled)
{
    NXEventHandle eventStatus;
    NXMouseScaling newScaling;

    if (mouseScalingEnabled == enabled)
        return;
        
    if (!(eventStatus = NXOpenEventStatus()))
        return;
    
    // Set or restore the scaling
    if (enabled) {
        NXSetMouseScaling(eventStatus, &originalMouseScaling);
    } else {
        // Save the old scaling value
        NXGetMouseScaling(eventStatus, &originalMouseScaling);

        // Setting a scaling curve with one factor of -1 turns off the OS scaling.  Setting it to 1 will NOT turn off the scaling.  This will make it linear, but the OS will still throw away bits of mouse movement precision
        newScaling.numScaleLevels = 1;
        newScaling.scaleThresholds[0] = 1;
        newScaling.scaleFactors[0] = -1;
        NXSetMouseScaling(eventStatus, &newScaling);
    }
		
    NXCloseEventStatus(eventStatus);
    mouseScalingEnabled = enabled;
}

static BOOL           keyboardRepeatEnabled = YES;
static double         originalKeyboardRepeatInterval;
static double         originalKeyboardRepeatThreshold;

void SetKeyboardRepeatEnabled(BOOL enabled)
{
    NXEventHandle eventStatus;
    
    if (keyboardRepeatEnabled == enabled)
        return;

    if (!(eventStatus = NXOpenEventStatus()))
        return;

    // Set or restore the configuration
    if (enabled) {
        NXSetKeyRepeatInterval(eventStatus, originalKeyboardRepeatInterval);
        NXSetKeyRepeatThreshold(eventStatus, originalKeyboardRepeatThreshold);
    } else {
        // Save the old configuration if we are about to disable repeats
        originalKeyboardRepeatInterval = NXKeyRepeatInterval(eventStatus);
        originalKeyboardRepeatThreshold = NXKeyRepeatThreshold(eventStatus);

        // No repeat events for 40 days and 40 nights
        NXSetKeyRepeatInterval(eventStatus, 3456000.0f);
        NXSetKeyRepeatThreshold(eventStatus, 3456000.0f);
    }

    NXCloseEventStatus(eventStatus);
    keyboardRepeatEnabled = enabled;
}
