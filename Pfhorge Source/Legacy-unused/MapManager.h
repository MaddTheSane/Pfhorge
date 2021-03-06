// This is the Marathon map-stuff manager for my Map Viewer

#pragma once
#import <Foundation/Foundation.h>
#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>

#include <GLUT/glut.h>

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

#include "TextureManager.h"
#include "MapData.h"
#include "MapReader.h"
#include "ViewOptions.h"
#include "MotPort.h"
#include "ViewContext.h"
#include "LELevelData.h"
#include "MarathonVersions.h"


//! Details of starting points
struct StartPointInfo {
	float Angle;
	short Polygon;
	world_point3d loc;
};


//! Details of lights and liquids
struct LightInfo {
	GLfloat L[ViewOptions::NUM_LIGHT_VALUES];	//!< List of precalculated light values
	GLfloat CurrL;								//!< Current light value
};

//! Details of lights and liquids
struct LiquidInfo {
	short Type;					//!< Liquid's type
	short ControlLight;			//!< The liquid's control light
	world_distance Low, High;	//!< The vertical extent of variation
	
	short TransferMode;			//!< Transfer mode
	shape_descriptor Texture;	//!< Liquid's texture
	
	world_distance CurrHeight;	//!< Current liquid height
};


class MapManager {

    //! Pointer to the current map-level data
    LELevelData *theLevel;
	
	//! Dialog-item-handler methods:
	void DoShapesSelect(MarathonAssetVersion _Version, NSString *thePathToShapesFile);
	void DoGoto();
        
	//! Used in reloading a level -- defined here to avoid repeated reallocations
	simple_vector<world_point2d> PointList;
	//! For each polygon:
	simple_vector<world_distance> FloorHeights, CeilingHeights;
	simple_vector<world_distance> MinNgbrFloorHeights, MaxNgbrFloorHeights, MinNgbrCeilingHeights, MaxNgbrCeilingHeights;

	//! Lights and Liquids
	simple_vector<LightInfo> LightList;
	simple_vector<LiquidInfo> LiquidList;
	
	//! Parsed map surfaces
	simple_vector<PolygonInfo> PInfoList;
	
	//! Visibility list: list of rooms (map polygons) in order to be rendered
	simple_vector<short> VisList;
	
	//! Method for rendering a surface:
	void DoSurfaceRender(SurfaceInfo &SInfo);

	// Data needed:
	bool IfTextured; //!< Whether textured rendering is to be done; this includes averaging
	bool IfAveraged; //!< Whether averaged-texture rendering is to be done
	GLint SurfaceRenderMode;
	
	//! Wall textures:
	TextureManager TMgr;
	
	//! Whether these wall-texture sets are present
	bool AreM2WallsPresent, AreM1WallsPresent;
	
	//! Liquid-texture data
	simple_vector<short> LiquidTextureSet, LiquidTile;
		
	//! Which version of the Marathon series?
	MarathonAssetVersion Version;
	
public:

	//! Which version of the Marathon series?
	MarathonAssetVersion GetVersion();

	//! Initialize the main dialog box
	void InitDialog();

	//! Display the map manager's dialog box.
	//! Response is whether to continue (false = quit)
	bool DoDialog(LELevelData *theLevelData, NSString *thePathToShapesFile);
	
	//! Starting point
	StartPointInfo StartPoint;
	
	//! Whether to update the current position
	bool UpdatePosition;
	
	//! View context:
	ViewContext VC;
	
	//! View options:
	ViewOptions VO;
	
	//! Motion/portal options:
	MotPort MP;
	
	//! Motion/portal dialog wrapper;
	//! this needs to be a separate function because it contains
	//! position-value moving
	bool DoMotPort();
	
	//! Update room (polygon) membership in the view context,
	//! and do the visibility
	void UpdateViewCtxtDoVis();
		
	// Render modes:
	enum {
		Render_Wireframe,
		Render_Colored,
		Render_Averaged,
		Render_Textured
	};
	
	//! Render all of the surfaces:
	//! Takes the render mode (may depart from that in the ViewOptions object
	//! and whether or not to render double-sided surfaces
	//! (want to skip that when doing the other side in show-5D-space mode)
	void DoRender(int RenderMode, bool DoDoubleSided = true);
	
	//! Reset the textures
	void ResetTextures() {TMgr.ResetAll();}
	
	//! Set render modes
	GLint &CloseupRenderMode() {return TMgr.CloseupRenderMode;}
	GLint &DistantRenderMode() {return TMgr.DistantRenderMode;}
	
	//! Reload level
	void ReloadLevel();
	
	//! Recalculate lights and liquids
	void RecalcLightsLiquids();
	
	//! Update view-options stuff if parameters had been changed from outside
	void UpdateViewOptions();
	
	//! Is point inside the view context's polygon or its neighbors?
	//! Returns which one, or NONE if none
	short IsInsideVCPN(float x, float y, float z);
	
	//! Is point inside the view context's polygon or its neighbors?
	//! Returns which one, or NONE if none
	short IsInsideVCPN(simd::float3 pos);

	//! Find other polygon at current location;
	//! argument is which direction to look (+ is forward, - is backward, 0 is do nothing)
	//! Search will wrap around the list if necessary
	void FindOtherPolygon(int Dir);
	
	//! Work out portal visibility
	void DoPortals();
	
	//! Do depth sorting
	void DoDepthSort();
	
	MapManager();
};
