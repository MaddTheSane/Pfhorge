// This dialog box does view options:

#pragma once

#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>

#include <OpenGL/gl.h>

class ViewOptions {

public:
    
	// Were once color-swatch indices
	RGBColor
            BkgdSwatch,		// Background
            FloorSwatch,	// Floor
            CeilSwatch,		// Ceiling
            WallSwatch,		// Wall
            LiquidSwatch,	// Liquid
            TransSwatch,	// Transparent
            LdscpSwatch,	// Landscape
            InvldSwatch,	// Invalid
            WireSwatch;		// Wireframe
	
	// Have zero-based indexing
	enum {
		Render_Wireframe,
		Render_Colored,
		Render_Averaged,
		Render_Textured,
		NUM_RENDER_MODES
	};
	enum {
		Platform_Contracted,
		Platform_1_4,
		Platform_1_2,
		Platform_3_4,
		Platform_Extended,
		NUM_PLATFORM_STATES
	};
	enum {
		SideBoth,
		SideInward,
		SideOutward,
		SideShow5D,
		NUM_SIDE_VISIBILITIES
	};
	enum {
		VertLookMarathon,
		VertLookThirdGen,
		NUM_VERT_LOOK_MODES
	};
	enum {
		FOV_TunnelVision,
		FOV_Normal,
		FOV_Extravision,
		NUM_FOV_VALUES
	};
	enum {
		CloseupRndr_Nearest,
		CloseupRndr_Linear,
		NUM_CLOSEUP_VALUES
	};
	enum {
		DistantRndr_Nearest,
		DistantRndr_Linear,
		DistantRndr_Nearest_Mipmap_Nearest,
		DistantRndr_Linear_Mipmap_Nearest,
		DistantRndr_Nearest_Mipmap_Linear,
		DistantRndr_Linear_Mipmap_Linear,
		NUM_DISTANT_VALUES
	};
	enum {
		Light_Initial,
		Light_Off_1,
		Light_Off_Avg,
		Light_Off_2,
		Light_On_1,
		Light_On_Avg,
		Light_On_2,
		NUM_LIGHT_VALUES
	};
	enum {
		NearDist_1_32,
		NearDist_1_16,
		NearDist_1_8,
		NearDist_1_4,
		NearDist_1_2,
		NUM_NEAR_DISTANCES
	};
	enum {
		FarDist_64,
		FarDist_128,
		FarDist_256,
		FarDist_512,
		FarDist_1024,
		NUM_FAR_DISTANCES
	};
	enum {
		Fog_None,
		Fog_64,
		Fog_16,
		Fog_4,
		Fog_1,
		NUM_FOG_TYPES
	};
	
	//! Were once popup-menu indices
	int
		SelectRenderMode,
		SelectPlatformState,
		SelectVisibleSides,
		SelectVerticalLook,
		SelectFieldOfView,
		SelectCloseupRender,
		SelectDistantRender,
		SelectLightType,
		SelectNearDistance,
		SelectFarDistance;
	
	//! Were once checkbox indices
	bool
		ShowTrans,		// Transparent
		ShowLdscp,		// Landscape
		ShowInvld,		// Invalid
		ShowObjects,
		UseLights,
		LiquidsTransparent,
		ShowLiquids,
		OffsetWires,
		UseFog;
	
	float FogDepth;
	
	//! Set up the dialog box
	void Init();
	
	//! Set OpenGL stuff that can be set immediately
	void SetImmediate();
	
	//! Get OpenGL render-mode constants
	GLint GetCloseupRenderMode();
	GLint GetDistantRenderMode();
};
