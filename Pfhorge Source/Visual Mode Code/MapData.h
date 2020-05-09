// This is the map data, in a separate file from MapManager.h
// This is done so that it can be included into other files
// Be sure to watch out for terminology collisions, such as
// surface polygons for rendering and Marathon map polygons;
// the latter ought to be called rooms or sectors.

#pragma once

#include <OpenGL/gl.h>
#include "LESide.h"
#include "MapDataFormats.h"
#include <simd/simd.h>
#include "SimpleVec.h"


struct VertexInfo {
	//! Vertex position
	simd::short3 Vert;
	//! Vertex texture coordinates
	simd::float2 TxtrCoord;
};


//! This struct contains the surface info:
struct SurfaceInfo {
	// Texture types:
	// Only the "wall" has an index value
	enum {
		Invalid,
		Landscape,
		Wall
	};

	//! Texture type, set, index, and transfer mode
	short TxtrType, TxtrSet, TxtrIndex, TxtrXfr;
	
	//! Light index
	short Light;
	
	//! List of vertex-info structs
	simple_vector<VertexInfo> VInfoList;
	
	//! Set how many vertices
	void SetNVerts(int NVerts) {VInfoList.reallocate(NVerts);}
	
	//! Vertical height
	void SetHeight(world_distance Height) {
		for (int iv=0; iv<VInfoList.get_len(); iv++) VInfoList[iv].Vert[2] = Height;
	}
	
	void UseTextures() {
		glTexCoordPointer(2,GL_FLOAT,sizeof(VertexInfo),&VInfoList[0].TxtrCoord);
	}
	
	void Render(GLint Mode) {
		glVertexPointer(3,GL_SHORT,sizeof(VertexInfo),&VInfoList[0].Vert);
		glDrawArrays(Mode,0,(GLsizei)VInfoList.get_len());
	}
	
	// Default: invalid
	SurfaceInfo(): TxtrType(Invalid), TxtrSet(0), TxtrIndex(0), TxtrXfr(0) {}
};


//! Here is the portal data
//! First, here's the stuff for each vertex:
//! vertex + plane connecting vertex with next one
struct PVInfo {
	simd::float3 Vertex;
	simd::float3 Plane;
};

//! I'll hardcode the number of portal vertices
//! since the Marathon engine's portals always have 4 vertices
const int NumPortalVertices = 4;

//! Now the portal data proper:
struct PortalInfo {
	PVInfo PVList[NumPortalVertices];
	//! Is a valid portal (points away from the viewpoint)
	bool IsValid();
	
	//! Updates everything else from the vertices
	void Update();
};

//! Returns true if overlapped, false otherwise
extern bool PortalOverlapCheck(PortalInfo &P1, PortalInfo &P2);


//! This struct contains the wall info
struct WallInfo {
	//! Whether the primary, secondary, and transparent blocks are present:
	bool PrimaryPresent, SecondaryPresent, TransparentPresent;
        
	//! Does this wall have overlaid textures?
	bool IsOverlaid;
	
	//! Is this wall a full-length side?
	bool IsFullLength;

	//! The primary, secondary, and transparent info blocks:
	SurfaceInfo PrimaryInfo, SecondaryInfo, TransparentInfo;

	//! These are all 4-sided,
	//! and initially absent
	WallInfo() {
		PrimaryInfo.SetNVerts(4); SecondaryInfo.SetNVerts(4); TransparentInfo.SetNVerts(4);
		PrimaryPresent = false; SecondaryPresent = false; TransparentPresent = false;
		Neighbor = NONE;
	}
	
	//! Per-point info, for doing collision
	world_point2d StartPoint, InwardDir;
	
	//! Neighboring polygon index; -1 is NONE
	short Neighbor;
	
	//! Portal to neighboring polygon
	PortalInfo Portal;
	
	//! Portal state:
	enum portal_state : short {
		Portal_Invalid,
		Portal_Invisible,
		Portal_Visible
	};
	portal_state PortalState;
	
	//! The visible neighbor (Neighbor or NONE):
	short VisibleNeighbor() {return (PortalState == Portal_Visible) ? Neighbor : NONE;}
};


//! This struct contains the parsed polygon info
struct PolygonInfo {

	//! The floor and ceiling heights
	world_distance FloorHeight, CeilingHeight;
	
	//! These are floor and ceiling info blocks
	SurfaceInfo FloorInfo, CeilInfo;
	
	//! Bounding box:
	world_distance XMin, XMax, YMin, YMax;
	
	//! This is the liquid index
	short Liquid;
	
	//! These are the liquid info blocks (from above and below)
	SurfaceInfo LiquidBelowInfo, LiquidAboveInfo;
	
	//! These are the wall info blocks
	simple_vector<WallInfo> WInfoList;
	
	//! Set the number of sides of this polygon:
	void SetNSides(int NSides) {
		FloorInfo.SetNVerts(NSides);
		CeilInfo.SetNVerts(NSides);
		LiquidAboveInfo.SetNVerts(NSides);
		LiquidBelowInfo.SetNVerts(NSides);
		WInfoList.reallocate(NSides);
	}
	
	//! This finds minimum and maximum values
	void FindMinMax();
	
	//! Test for being inside
	bool IsInside(float x, float y, float z);
	
	//! Here is some stuff on that portal
	//! The map polygon that looks into this current polygon
	//! If at the start of the portal tree, put in NONE
	short PrevPolygon;
		
	//! The index to the index of map polygon that the view checking has currently exited into
	short NextPlgnIndx;
	
	//! Were the outgoing portals calculated?
	bool PortalsCalculated;
			
	PolygonInfo():  Liquid(NONE) {}
};
