// Here is the work of the map-manager object:

#include <string.h>
#include <math.h>
#include "ShapesReader.h"
#include "MapManager.h"
#import "LEMapPoint.h"
#import "LELine.h"
#import "LESide.h"
#import "PhLight.h"
#import "PhMedia.h"
#import "PhPlatform.h"
#import "LEExtras.h"

#include <Foundation/Foundation.h>

// Multiplier for world coordinates -> texture coordinates 
const GLfloat TxtrNorm = 1.0/GLfloat(WORLD_ONE);


// Field of View
const double PI = 4*atan(1.0);
const GLfloat TunnelFOV = tan((PI/180)*0.5*36);
const GLfloat NormalFOV = tan((PI/180)*0.5*80);
const GLfloat ExtraFOV = tan((PI/180)*0.5*130);

// Near Distances
const GLfloat Dist_1_32 = 1024/32;
const GLfloat Dist_1_16 = 1024/16;
const GLfloat Dist_1_8 = 1024/8;
const GLfloat Dist_1_4 = 1024/4;
const GLfloat Dist_1_2 = 1024/2;

// Far Distances
const GLfloat Dist_64 = 64*1024;
const GLfloat Dist_128 = 128*1024;
const GLfloat Dist_256 = 256*1024;
const GLfloat Dist_512 = 512*1024;
const GLfloat Dist_1024 = 1024*1024;


static void SetTexture(int Version, SurfaceInfo &SInfo, shape_descriptor &Desc) {

    unsigned char DescSet = (Desc >> 8) & 0x00ff;
    unsigned char DescFrame = Desc & 0x00ff;

	switch(Version) {
	// Marathon 2/oo
	case MarathonAssetVersion::Version_2_oo:
	{
		if ((DescSet >= 17) && (DescSet <= 21) && (DescFrame != (NONE & 0x00ff))) {
			SInfo.TxtrType = SurfaceInfo::Wall;
			SInfo.TxtrSet = DescSet - 17; // Indices 0 to 4
			SInfo.TxtrIndex = DescFrame;
		} else if ((DescSet >= 27) && (DescSet <= 30) && (DescFrame != (NONE & 0x00ff))) {
			SInfo.TxtrType = SurfaceInfo::Landscape;
			SInfo.TxtrSet = (DescSet - 27) + 5; // Indices 5 to 8
			SInfo.TxtrIndex = DescFrame;
		} else {
			SInfo.TxtrType = SurfaceInfo::Invalid;
			SInfo.TxtrSet = 0;
			SInfo.TxtrIndex = 0;
		}
	}
	break;
	// Marathon 1
	case MarathonAssetVersion::Version_1:
	{
		if ((DescSet >= 17) && (DescSet <= 19) && (DescFrame != (NONE & 0x00ff))) {
			SInfo.TxtrType = SurfaceInfo::Wall;
			SInfo.TxtrSet = (DescSet - 17) + 9; // Indices 9 to 11
			SInfo.TxtrIndex = DescFrame;
		} else if ((DescSet == 8) && (DescFrame != (NONE & 0x00ff))) {
			SInfo.TxtrType = SurfaceInfo::Wall;
			SInfo.TxtrSet = 12;
			SInfo.TxtrIndex = DescFrame;
		} else if ((DescSet == 2) && (DescFrame != (NONE & 0x00ff))) {
			SInfo.TxtrType = SurfaceInfo::Wall;
			SInfo.TxtrSet = 13;
			SInfo.TxtrIndex = DescFrame;
		} else if ((DescSet == 24) && (DescFrame != (NONE & 0x00ff))) {
			SInfo.TxtrType = SurfaceInfo::Wall;
			SInfo.TxtrSet = 14;
			SInfo.TxtrIndex = DescFrame;
		} else {
			SInfo.TxtrType = SurfaceInfo::Invalid;
			SInfo.TxtrSet = 0;
			SInfo.TxtrIndex = 0;
		}
		// Test for being a landscape here
		if (SInfo.TxtrType == SurfaceInfo::Wall) {
			if (SInfo.TxtrXfr == tLandscape)
				SInfo.TxtrType = SurfaceInfo::Landscape;
		}
	}
	break;
	}
}


// Set the wall vertex and texture-coordinate values
// (Point0, Height0) is intended to be the upper lefthand corner
// Texture coordinates are vertical, then horizontal
static void SetWallVerts(SurfaceInfo &SInfo,
	world_point2d &Point0, world_point2d &Point1,
		world_distance LineLength, world_distance Height0, world_distance Height1) {

	double SideLen = double(LineLength);
	if (SideLen <= 0) {
		double dx = double(Point1.x) - double(Point0.x);
		double dy = double(Point1.y) - double(Point0.y);
		SideLen = hypot(dx,dy);
	}
	
	GLfloat tx_dx = TxtrNorm*GLfloat(SideLen);
	GLfloat tx_dy = TxtrNorm*(GLfloat(Height0) - GLfloat(Height1));

	SInfo.VInfoList[0].Vert[0] = Point0.x;
	SInfo.VInfoList[0].Vert[1] = Point0.y;
	SInfo.VInfoList[0].Vert[2] = Height0;
	SInfo.VInfoList[0].TxtrCoord[0] = 0;
	SInfo.VInfoList[0].TxtrCoord[1] = 0;
	
	SInfo.VInfoList[1].Vert[0] = Point1.x;
	SInfo.VInfoList[1].Vert[1] = Point1.y;
	SInfo.VInfoList[1].Vert[2] = Height0;
	SInfo.VInfoList[1].TxtrCoord[0] = 0;
	SInfo.VInfoList[1].TxtrCoord[1] = tx_dx;
	
	SInfo.VInfoList[2].Vert[0] = Point1.x;
	SInfo.VInfoList[2].Vert[1] = Point1.y;
	SInfo.VInfoList[2].Vert[2] = Height1;
	SInfo.VInfoList[2].TxtrCoord[0] = tx_dy;
	SInfo.VInfoList[2].TxtrCoord[1] = tx_dx;
	
	SInfo.VInfoList[3].Vert[0] = Point0.x;
	SInfo.VInfoList[3].Vert[1] = Point0.y;
	SInfo.VInfoList[3].Vert[2] = Height1;
	SInfo.VInfoList[3].TxtrCoord[0] = tx_dy;
	SInfo.VInfoList[3].TxtrCoord[1] = 0;
}


// Do texture offset:
static void DoTxtrOffset(SurfaceInfo &SInfo, short xoff, short yoff) {

	GLfloat tx_dx = TxtrNorm*GLfloat(xoff);
	GLfloat tx_dy = TxtrNorm*GLfloat(yoff);

	for (int iv=0; iv<SInfo.VInfoList.get_len(); iv++) {
		SInfo.VInfoList[iv].TxtrCoord[0] += tx_dx;
		SInfo.VInfoList[iv].TxtrCoord[1] += tx_dy;
	}
};


// Set the wall textures and texture-coordinate offsets:
static void SetWallTxtr(int Version, SurfaceInfo &SInfo, side_texture_definition &Def) {
	
	SetTexture(Version, SInfo, Def.texture);
	// Vertical, then horizontal
	DoTxtrOffset(SInfo, Def.y0, Def.x0);
}


void MapManager::UpdateViewOptions() {
	
	// Vertical-look mode
	// One-based to zero-based indexing
	int VertLookMode = VO.SelectVerticalLook;
	if (VC.VertLookMode != VertLookMode) {
		VC.VertLookMode = VertLookMode;
		VC.PitchAngle = 0;
		VC.SetView();
	}
	
	// Field of View
	GLfloat FOV = NormalFOV;
	switch(VO.SelectFieldOfView) {
		case ViewOptions::FOV_TunnelVision:
			FOV = TunnelFOV;
			break;
			
		case ViewOptions::FOV_Normal:
			FOV = NormalFOV;
			break;
			
		case ViewOptions::FOV_Extravision:
			FOV = ExtraFOV;
			break;
	}
        
	// Near distance
	// One-based to zero-based indexing
	GLfloat NearDist = Dist_1_32;
	/*switch(VO.PopupList[ViewOptions::SelectNearDistance].State - 1) {
	case ViewOptions::NearDist_1_32:
		NearDist = Dist_1_32;
		break;
		
	case ViewOptions::NearDist_1_16:
		NearDist = Dist_1_16;
		break;
		
	case ViewOptions::NearDist_1_8:
		NearDist = Dist_1_8;
		break;
		
	case ViewOptions::NearDist_1_4:
		NearDist = Dist_1_4;
		break;
		
	case ViewOptions::NearDist_1_2:
		NearDist = Dist_1_2;
		break;
	}*/
        
	NearDist = Dist_1_32;
        
	// Far distance
	// One-based to zero-based indexing
	GLfloat FarDist = Dist_256;
	/*switch(VO.PopupList[ViewOptions::SelectNearDistance].State - 1) {
	case ViewOptions::FarDist_64:
		FarDist = Dist_64;
		break;
		
	case ViewOptions::FarDist_128:
		FarDist = Dist_128;
		break;
		
	case ViewOptions::FarDist_256:
		FarDist = Dist_256;
		break;
		
	case ViewOptions::FarDist_512:
		FarDist = Dist_512;
		break;
		
	case ViewOptions::FarDist_1024:
		FarDist = Dist_1024;
		break;
	}*/
	
	if (VC.FOV_Size != FOV || VC.Near != NearDist || VC.Far != FarDist) {
		VC.FOV_Size = FOV;
		VC.Near = NearDist;
		VC.Far = FarDist;
		VC.SetView();
	}
	
	// Render modes:
	CloseupRenderMode() = VO.GetCloseupRenderMode();
	DistantRenderMode() = VO.GetDistantRenderMode();
	
	// Reload if necessary
	ReloadLevel();
	
	// Recalculate these
	RecalcLightsLiquids();
}


// Player's eye position (standard physics): 0.6 * total height (JRH)
const short PlayerEye = 614;


// Misc. setup and cleanup

MapManager::MapManager() {
    // Originally empty
    theLevel = nil;

	UpdatePosition = false;
	
	AreM2WallsPresent = false;
	AreM1WallsPresent = false;
	
	LiquidTextureSet.reallocate(NUMBER_OF_MEDIA_TYPES);
	LiquidTile.reallocate(NUMBER_OF_MEDIA_TYPES);
	
	// Which texture tiles for each liquid;
	// these are hardcoded in the Marathon engine,
	// as can be found out with Bo Lindbergh's "Fux!"
	LiquidTextureSet[_media_water] = 17;
	LiquidTile[_media_water] = 19;
	
	LiquidTextureSet[_media_lava] = 18;
	LiquidTile[_media_lava] = 12;
	
	LiquidTextureSet[_media_goo] = 21;
	LiquidTile[_media_goo] = 5;
	
	LiquidTextureSet[_media_sewage] = 19;
	LiquidTile[_media_sewage] = 13;
	
	LiquidTextureSet[_media_jjaro] = 20;
	LiquidTile[_media_jjaro] = 13;
}


void MapManager::InitDialog() {
	
	// Initialize these objects
	NSLog(@"VO.Init();");
	VO.Init();
	NSLog(@"MP.Init();");
	MP.Init();
	NSLog(@"UpdateViewOptions();");
	// Distribute view-options parameters:
	UpdateViewOptions();
	NSLog(@"InitDialog() DONE returning...");
}



bool MapManager::DoDialog(LELevelData *theLevelData, NSString *thePathToShapesFile) {
    // Insert in
    theLevel = theLevelData;
	
	if (theLevelData == nil)
	{
		NSLog(@"theLevelData was nil, can't go into visual mode...");
		return false;
	}
	
	Version = MarathonAssetVersion::Version_2_oo;
	
	DoShapesSelect(Version, thePathToShapesFile);
	
	ReloadLevel();
	
	return true;
}


// Select a shapes file:
void MapManager::DoShapesSelect(MarathonAssetVersion _Version, NSString *thePathToShapesFile) {
	NSLog(@"DoShapesSelect");
	
	if (thePathToShapesFile == nil)
		return;
	
	// Try to read in the shapes catalog:
	// For now, this object's scope will be limited to this function
        
	ShapesFileCatalog ShpCat(thePathToShapesFile,_Version);
        
	if (!ShpCat.ReadOK()) return;
        
	int NumTxtrSets = 0;
	int *TxtrSource = 0;
	int TxtrMgrRef = 0;
	
	int M2TxtrSource[] = {17,18,19,20,21};
	int M1TxtrSource[] = {17,18,19,8,2,24};
	
	switch(_Version) {
		case MarathonAssetVersion::Version_2_oo:
			NumTxtrSets = 5;
			TxtrSource = M2TxtrSource;
			TxtrMgrRef = 0;
			break;
		case MarathonAssetVersion::Version_1:
			NumTxtrSets = 6;
			TxtrSource = M1TxtrSource;
			TxtrMgrRef = 9;
			break;
	}
	
	for (int its=0; its<NumTxtrSets; its++) {
		// Get the appropriate shapes chunk
		ShapeObject *S = ShpCat.GetShapes(TxtrSource[its], Subcollection_Standard);
		
		//// PB.Update((2*its+1)/double(2*NumTxtrSets));
		
		int itmdex = TxtrMgrRef + its;
		if (S == 0) {
			TMgr.TileList[itmdex].reallocate(0);
			continue;
		}
		
		// Initially, all the colors are transparent
		memset(TMgr.ColorTableList[itmdex],0,4*ColorTableSize);
		
		// Fill in that table.
		// The first color is the transparent one; skip
		for (int ic=1; ic<S->Header.color_count; ic++) {
			color_entry &C = S->ColorList[ic];
			GLushort r = C.red >> 8;
			GLushort g = C.green >> 8;
			GLushort b = C.blue >> 8;
			TMgr.ColorTableList[itmdex][ic] = (r << 24) | (g << 16) | (b << 8) | 0x000000ff;
			// That last one means that this color is opaque
		}
		
		// Now load the tiles:
		// Be sure to reference them by frame ID instead of by bitmap ID
		// This avoids out-of-order bugs
		int NumTiles = S->FrameList.get_len();
		TMgr.TileList[itmdex].reallocate(NumTiles);
		for (int itl=0; itl<NumTiles; itl++) {
			ImageObject &Img = S->ImageList[S->FrameList[itl].image_index];
			TextureTile &Tile = TMgr.TileList[itmdex][itl]; 
			memset(Tile.Pixels, 0, MaraNumWTPixels*sizeof(GLubyte));
			
			int width = min(int(Img.Header.width),MaraWallTxtrSize);
			int height = min(int(Img.Header.height),MaraWallTxtrSize);
			// Don't change the pixel order
			for (int iw=0; iw<width; iw++)
				for (int ih=0; ih<height; ih++)
					Tile.Pixels[iw*MaraWallTxtrSize + ih] =
						Img.Pixels[Img.Header.height*iw + ih];
		}
		TMgr.Reset(itmdex);
		TMgr.FindAverage(itmdex);
		
		// Clean up
		delete S;
		
		////PB.Update((2*its+2)/double(2*NumTxtrSets));
	}
	switch(_Version) {
	case MarathonAssetVersion::Version_2_oo:
		AreM2WallsPresent = true;
		break;
	case MarathonAssetVersion::Version_1:
		AreM1WallsPresent = true;
		break;
	}
}


// Go to a start location
void MapManager::DoGoto() {
	
	if (!theLevel) return;
	
	NSMutableArray *theMapObjects = [theLevel theMapObjects];
	
	// Reads directly off a popup menu whose first entry (index 0)
	// means start at the center (behavior when no player start points are found)
	NSInteger StartIndx = [preferences integerForKey:VMStartPosition] - 1;
	bool StartPointFound = false;
	if ((theMapObjects) && StartIndx >= 0)
	{
		for (LEMapObject *theMapObject in theMapObjects)
		{
			if ([theMapObject getType] == _saved_player)
			{
				// Use StartIndx itself to count down to the start point to be used
				if (StartIndx == 0)
				{
					StartPoint.Angle = (360/float(512))*[theMapObject getFacing];
					StartPoint.Polygon = [theMapObject getPolygonIndex];
					StartPoint.loc.x = [theMapObject getX];
					StartPoint.loc.y = [theMapObject getY];
					StartPoint.loc.z = [theMapObject getZ] + PlayerEye;
					LEPolygon *thePolygon = (LEPolygon *)[theMapObject getPolygonObject];
					if (([theMapObject getFlags] & _map_object_hanging_from_ceiling) != 0)
						StartPoint.loc.z += [thePolygon getCeiling_height];
					else
						StartPoint.loc.z += [thePolygon getFloor_height];
					StartPointFound = true;
				}
				StartIndx--;
			}
			if (StartPointFound) break;
		}
		//[en release];
	}
	
	// In the center if necessary
	if (!StartPointFound)
	{
		StartPoint.Angle = 0;
		StartPoint.Polygon = NONE;
		StartPoint.loc.x = 0;
		StartPoint.loc.y = 0;
		StartPoint.loc.z = 0;
	}
	
	UpdatePosition = true;
}


// Return from the file dialog box:
void MapManager::ReloadLevel() {
        
	// In all these cases, remember the current state of the controls
	// so as not to reload unless necessary
	
	// Check on whether the map or the level has changed; reload if so
	bool DoReload = (theLevel != nil);
	
	// If nothing has changed then don't reload
	if (!DoReload) return;
	
	// Also the side-parsing state:
        
	// Get the appropriate map data:
        
	// Get the points
	NSMutableArray *thePoints = [theLevel getThePoints];
	
	if (thePoints)
	{
		PointList.reallocate([thePoints count]);
		world_point2d *PointPtr = &PointList[0];
		
		NSEnumerator *en = [thePoints objectEnumerator];
		LEMapPoint *thePoint;
		while (thePoint = [en nextObject])
		{
			PointPtr->x = [thePoint getX];
			PointPtr->y = [thePoint getY];
			PointPtr++;
		}
	}
	else
		return;	// No points: don't bother to continue
	
	// Get the lines
	NSMutableArray *theLines = [theLevel getTheLines];
	
	// No lines: don't bother to continue
	if (!theLines) return;
	
	// Get the sides
	NSMutableArray *theSides = [theLevel sides];
	
	// Get the polygons; calculate their heights with the platform data
	NSMutableArray *thePolygons = [theLevel getThePolys];
	
	// No polygons: don't bother to continue
	if (!thePolygons) return;
        
	NSInteger NPolygons = [thePolygons count];
	
	// Will get platform heights, if used
	FloorHeights.reallocate(NPolygons);
	CeilingHeights.reallocate(NPolygons);
	
	for (int np=0; np<NPolygons; np++)
	{
		LEPolygon *thePolygon = [thePolygons objectAtIndex:np];
		FloorHeights[np] = [thePolygon getFloor_height];
		CeilingHeights[np] = [thePolygon getCeiling_height];
	}
			
	// Get the platforms
	NSMutableArray *thePlatforms = [theLevel getPlatforms];
	
	if (thePlatforms)
	{
		// Find out how much the platforms are to be extended
		float PlatExtend = 0;
		switch(VO.SelectPlatformState - 1)
		{
		case ViewOptions::Platform_Contracted:
			PlatExtend = 0;
			break;
			
		case ViewOptions::Platform_1_4:
			PlatExtend = 0.25;
			break;
			
		case ViewOptions::Platform_1_2:
			PlatExtend = 0.5;
			break;
			
		case ViewOptions::Platform_3_4:
			PlatExtend = 0.75;
			break;
			
		case ViewOptions::Platform_Extended:
			PlatExtend = 1;
			break;
			
		}
		
		// Find all the adjacent heights
		MinNgbrFloorHeights.reallocate(NPolygons);
		MaxNgbrFloorHeights.reallocate(NPolygons);
		MinNgbrCeilingHeights.reallocate(NPolygons);
		MaxNgbrCeilingHeights.reallocate(NPolygons);
		
		for (int np=0; np<NPolygons; np++)
		{
			LEPolygon *thePolygon = [thePolygons objectAtIndex:np];
			int NumNeigbors = [thePolygon getTheVertexCount];
			world_distance MinNgbrFloorHeight = [thePolygon getFloor_height];
			world_distance MaxNgbrFloorHeight = [thePolygon getFloor_height];
			world_distance MinNgbrCeilingHeight = [thePolygon getCeiling_height];
			world_distance MaxNgbrCeilingHeight = [thePolygon getCeiling_height];
			for (int i=0; i<NumNeigbors; i++)
			{
				LEPolygon *theNeighbor = [thePolygon getAdjacent_polygon_objects:i];
				if (theNeighbor != nil)
				{
					world_distance FloorHeight = [theNeighbor getFloor_height];
					MinNgbrFloorHeight = min(MinNgbrFloorHeight,FloorHeight);
					MaxNgbrFloorHeight = max(MaxNgbrFloorHeight,FloorHeight);
					world_distance CeilingHeight = [theNeighbor getCeiling_height];
					MinNgbrCeilingHeight = min(MinNgbrCeilingHeight,CeilingHeight);
					MaxNgbrCeilingHeight = max(MaxNgbrCeilingHeight,CeilingHeight);
				}
			}
			MinNgbrFloorHeights[np] = MinNgbrFloorHeight;
			MaxNgbrFloorHeights[np] = MaxNgbrFloorHeight;
			MinNgbrCeilingHeights[np] = MinNgbrCeilingHeight;
			MaxNgbrCeilingHeights[np] = MaxNgbrCeilingHeight;
		}
		
		for (int np=0; np<NPolygons; np++)
		{
			LEPolygon *thePolygon = [thePolygons objectAtIndex:np];
			if ([thePolygon getType] == _polygon_is_platform)
			{
				PhPlatform *thePlatform = [thePlatforms objectAtIndex:[thePolygon getPermutation]];
				
				// Adjust the heights to the platform ranges
				short FloorHeight = FloorHeights[np];
				short CeilingHeight = CeilingHeights[np];
				short MinNgbrFloorHeight = MinNgbrFloorHeights[np];
				short MaxNgbrFloorHeight = MaxNgbrFloorHeights[np];
				short MinNgbrCeilingHeight = MinNgbrCeilingHeights[np];
				short MaxNgbrCeilingHeight = MaxNgbrCeilingHeights[np];
				short PlatMinHeight = [thePlatform minimumHeight];
				short PlatMaxHeight = [thePlatform maximumHeight];
				unsigned long PlatFlags = [thePlatform staticFlags];
				
				bool FromFloorToCeiling = (PlatFlags & _platform_extends_floor_to_ceiling) != 0;
				if (FromFloorToCeiling)
				{
					if (CeilingHeight > MaxNgbrFloorHeight)
						MaxNgbrFloorHeight = CeilingHeight;
					if (FloorHeight < MinNgbrCeilingHeight)
						MinNgbrCeilingHeight = FloorHeight;
				}
				
				bool FromFloor = (PlatFlags & _platform_comes_from_floor) != 0;
				bool FromCeiling = (PlatFlags & _platform_comes_from_ceiling) != 0;
				
				short PlatMinFloor = FloorHeight;
				short PlatMaxFloor = FloorHeight;
				short PlatMinCeiling = CeilingHeight;
				short PlatMaxCeiling = CeilingHeight;
				
				const int NONE = -1;
				if (FromFloor)
				{
					if (FromCeiling)
					{
						/* split platforms always meet in the center */
						PlatMinFloor = (PlatMinHeight == NONE) ? MinNgbrFloorHeight : PlatMinHeight;
						PlatMaxCeiling = (PlatMaxHeight == NONE) ? MaxNgbrCeilingHeight : PlatMaxHeight;
						PlatMaxFloor = PlatMinCeiling = (PlatMinFloor + PlatMaxCeiling)/2;
					}
					else
					{
						if (PlatFlags & _platform_uses_native_polygon_heights)
						{
							if (FloorHeight < MinNgbrFloorHeight || FromFloorToCeiling)
								MinNgbrFloorHeight = FloorHeight;
							else
								MaxNgbrFloorHeight = FloorHeight;
						}
						
						PlatMinFloor = (PlatMinHeight == NONE) ? MinNgbrFloorHeight : PlatMinHeight;
						PlatMaxFloor = (PlatMaxHeight == NONE) ? MaxNgbrFloorHeight : PlatMaxHeight;
						PlatMinCeiling = PlatMaxCeiling = CeilingHeight;
					}
				}
				else
				{
					if (FromCeiling)
					{
						if (PlatFlags & _platform_uses_native_polygon_heights)
						{
							if (CeilingHeight > MinNgbrCeilingHeight || FromFloorToCeiling)
								MaxNgbrCeilingHeight = CeilingHeight;
							else
								MinNgbrCeilingHeight = CeilingHeight;
						}
						
						PlatMinCeiling = (PlatMinHeight == NONE) ? MinNgbrCeilingHeight : PlatMinHeight;
						PlatMaxCeiling = (PlatMaxHeight == NONE) ? MaxNgbrCeilingHeight : PlatMaxHeight;
						PlatMinFloor = PlatMaxFloor = FloorHeight;
					}
					// A platform that comes from neither is no platform at all
				}
				
				// Adjust the floor and ceiling heights!
				FloorHeights[np] = PlatMinFloor + short(PlatExtend*(PlatMaxFloor - PlatMinFloor));
				CeilingHeights[np] = PlatMaxCeiling + short(PlatExtend*(PlatMinCeiling - PlatMaxCeiling));
			}
		}
	}
	
	// Maximum light value:
	const GLfloat MaxLightValue = GLfloat(1 << 16);
	
	// Get the lights
	NSMutableArray *theLights = [theLevel getLights];

	NSInteger NLights = [theLights count];
	LightList.reallocate(NLights);
	
	// Translate
	for (int il=0; il<NLights; il++) {
		PhLight *theLight = [theLights objectAtIndex:il];
		LightInfo &Light = LightList[il];
		
		GLfloat OnInten1 = [theLight intensityForState:_light_primary_active]/MaxLightValue;
		GLfloat OnInten2 = [theLight intensityForState:_light_secondary_active]/MaxLightValue;
		GLfloat OffInten1 = [theLight intensityForState:_light_primary_inactive]/MaxLightValue;
		GLfloat OffInten2 = [theLight intensityForState:_light_secondary_inactive]/MaxLightValue;
		GLfloat InitInten =
		([theLight flags] & (1 << PhLightStaticFlagIsInitiallyActive)) ? OnInten1 : OffInten1;
		
		// Average values -- weighted
		
		GLfloat OnIntenAvg1 =
		([theLight functionForState:_light_primary_active] == _constant_lighting_function) ?
		OnInten1 : (OnInten1 + OnInten2)/2;
		
		GLfloat OnIntenAvg2 =
		([theLight functionForState:_light_secondary_active] == _constant_lighting_function) ?
		OnInten2 : (OnInten1 + OnInten2)/2;
		
		GLfloat OnP1 = GLfloat([theLight periodForState:_light_primary_active]);
		GLfloat OnP2 = GLfloat([theLight periodForState:_light_secondary_active]);
		GLfloat OnPTot = OnP1 + OnP2;
		GLfloat OnIntenAvg =
		(OnPTot > 0) ? (OnIntenAvg1*OnP1 + OnIntenAvg2*OnP2)/OnPTot : (OnInten1 + OnInten2)/2;
		
		GLfloat OffIntenAvg1 =
		([theLight functionForState:_light_primary_inactive] == _constant_lighting_function) ?
		OffInten1 : (OffInten1 + OffInten2)/2;
		
		GLfloat OffIntenAvg2 =
		([theLight functionForState:_light_secondary_inactive] == _constant_lighting_function) ?
		OffInten2 : (OffInten1 + OffInten2)/2;
		
		GLfloat OffP1 = GLfloat([theLight periodForState:_light_primary_inactive]);
		GLfloat OffP2 = GLfloat([theLight periodForState:_light_secondary_inactive]);
		GLfloat OffPTot = OffP1 + OffP2;
		GLfloat OffIntenAvg =
		(OffPTot > 0) ? (OffIntenAvg1*OffP1 + OffIntenAvg2*OffP2)/OffPTot : (OffInten1 + OffInten2)/2;
		
		Light.L[ViewOptions::Light_Initial] = InitInten;
		Light.L[ViewOptions::Light_Off_1] = OffInten1;
		Light.L[ViewOptions::Light_Off_Avg] = OffIntenAvg;
		Light.L[ViewOptions::Light_Off_2] = OffInten2;
		Light.L[ViewOptions::Light_On_1] = OnInten1;
		Light.L[ViewOptions::Light_On_Avg] = OnIntenAvg;
		Light.L[ViewOptions::Light_On_2] = OnInten2;
	}
		
	// Get the liquids
	NSMutableArray *theLiquids = [theLevel getMedia];
        
	NSInteger NLiquids = [theLiquids count];
	LiquidList.reallocate(NLiquids);
	
	// Translate
	for (int iq=0; iq<NLiquids; iq++) {
		PhMedia *theLiquid = [theLiquids objectAtIndex:iq];
		LiquidInfo &Liquid = LiquidList[iq];
		
		Liquid.Type = [theLiquid type];
		Liquid.ControlLight = [theLiquid lightIndex];
		Liquid.Low = [theLiquid low];
		Liquid.High = [theLiquid high];
		
		Liquid.TransferMode = tNormal;
		Liquid.Texture = (((unsigned short)LiquidTextureSet[Liquid.Type]) << 8) +
		(LiquidTile[Liquid.Type] & 0x00ff);
	}
	
	// Parse the map and create the surfaces in OpenGL-ready form
	PInfoList.reallocate(NPolygons);
	VisList.reallocate(NPolygons);
	VisList.fill(NONE);		// Idiot-proof value
	for (int np=0; np<NPolygons; np++) {
		LEPolygon *thePolygon = [thePolygons objectAtIndex:np];
		PolygonInfo &PInfo = PInfoList[np];
		
		int NSides = [thePolygon getTheVertexCount];
		PInfo.SetNSides(NSides);
		
		short PFloor = PInfo.FloorHeight = FloorHeights[np];
		short PCeiling = PInfo.CeilingHeight = CeilingHeights[np];
		PInfo.FloorInfo.SetHeight(PFloor);
		PInfo.CeilInfo.SetHeight(PCeiling);
		
		// Set the floor and ceiling textures, transfer modes, and lights
		PInfo.FloorInfo.TxtrXfr = [thePolygon getFloor_transfer_mode];
		PInfo.CeilInfo.TxtrXfr = [thePolygon getCeiling_transfer_mode];
		PInfo.FloorInfo.Light = [thePolygon getFloor_lightsource_index];
		PInfo.CeilInfo.Light = [thePolygon getCeiling_lightsource_index];
		
		// These must come after setting the transfer mode
		shape_descriptor ShD;
		ShD = [thePolygon getFloor_texture];
		SetTexture(Version, PInfo.FloorInfo, ShD);
		ShD = [thePolygon getCeiling_texture];
		SetTexture(Version, PInfo.CeilInfo, ShD);
		
		// Liquids only in Marathon 2/oo
		PInfo.Liquid =  [thePolygon getMedia_index];
		
		// Set up liquid surfaces
		if (PInfo.Liquid != NONE) {
			LiquidInfo &Liquid = LiquidList[PInfo.Liquid];
			PInfo.LiquidBelowInfo.TxtrXfr = PInfo.LiquidAboveInfo.TxtrXfr =
			Liquid.TransferMode;
			PInfo.LiquidBelowInfo.Light = PInfo.LiquidAboveInfo.Light =
			[thePolygon getMedia_lightsource_index];
			
			// These must come after setting the transfer mode
			SetTexture(Version, PInfo.LiquidBelowInfo, Liquid.Texture);
			SetTexture(Version, PInfo.LiquidAboveInfo, Liquid.Texture);
		}
		
		for (int iv=0; iv<NSides; iv++) {
			// Floor and ceiling first:
			// Reverse the ceiling point order to get it facing the right way
			// (clockwise inward)
			
			world_point2d &Point = PointList[[thePolygon getVertexIndexes:iv]];
			
			VertexInfo &FloorVInfo = PInfo.FloorInfo.VInfoList[iv];
			VertexInfo &CeilVInfo = PInfo.CeilInfo.VInfoList[(NSides-1)-iv];
			VertexInfo &LBelowVInfo = PInfo.LiquidBelowInfo.VInfoList[iv];
			VertexInfo &LAboveVInfo = PInfo.LiquidAboveInfo.VInfoList[(NSides-1)-iv];
			
			FloorVInfo.Vert[0] = CeilVInfo.Vert[0] =
			LBelowVInfo.Vert[0] = LAboveVInfo.Vert[0] = Point.x;
			FloorVInfo.TxtrCoord[0] = CeilVInfo.TxtrCoord[0] =
			LBelowVInfo.TxtrCoord[0] = LAboveVInfo.TxtrCoord[0] = TxtrNorm*Point.x;
			
			FloorVInfo.Vert[1] = CeilVInfo.Vert[1] =
			LBelowVInfo.Vert[1] = LAboveVInfo.Vert[1] = Point.y;
			FloorVInfo.TxtrCoord[1] = CeilVInfo.TxtrCoord[1] =
			LBelowVInfo.TxtrCoord[1] = LAboveVInfo.TxtrCoord[1] = TxtrNorm*Point.y;
			
			// The walls:
			LELine *theLine = [theLines objectAtIndex:[thePolygon getLineIndexes:iv]];
			// jra 8-1-03
			// Must be converted from "32" units to "1024" units
			world_distance LineLength = ([theLine getLength]) * 16;
			WallInfo &WInfo = PInfo.WInfoList[iv];
			// Points, neighboring polygon, and side index
			int PIndx0 = 0, PIndx1 = 0, NIndx = NONE, SIndx = NONE;
			if (np == [theLine getClockwisePolygonIndex]) {
				PIndx0 = [theLine pointIndex1];
				PIndx1 = [theLine pointIndex2];
				NIndx = [theLine getConterclockwisePolygonIndex];
				SIndx = [theLine getClockwisePolygonSideIndex];
			} else if (np == [theLine getConterclockwisePolygonIndex]) {
				PIndx0 = [theLine pointIndex2];
				PIndx1 = [theLine pointIndex1];
				NIndx = [theLine getClockwisePolygonIndex];
				SIndx = [theLine getCounterclockwisePolygonSideIndex];
			}
			WInfo.Neighbor = NIndx;
			
			// The two 2D points:
			world_point2d &Point0 = PointList[PIndx0];
			world_point2d &Point1 = PointList[PIndx1];
			
			// Get the position and normal of the wall, for use in collision detection
			WInfo.StartPoint = Point0;
			WInfo.InwardDir.x = - (Point1.y - Point0.y);
			WInfo.InwardDir.y = (Point1.x - Point0.x);
			
			// Simply use standard parsing of sides
			WInfo.IsFullLength = false;
			if (NIndx == NONE) {
				// Full-length side:
				WInfo.PrimaryPresent = true;
				SetWallVerts(WInfo.PrimaryInfo,Point0,Point1,LineLength,
							 PCeiling,PFloor);
				WInfo.SecondaryPresent = true;
				SetWallVerts(WInfo.SecondaryInfo,Point0,Point1,LineLength,
							 PCeiling,PFloor);
				WInfo.TransparentPresent = true;
				SetWallVerts(WInfo.TransparentInfo,Point0,Point1,LineLength,
							 PCeiling,PFloor);
				WInfo.IsFullLength = true;
				
			} else {
				short NFloor = FloorHeights[NIndx];
				short NCeiling = CeilingHeights[NIndx];
				
				if (NFloor >= PCeiling) {
					// Full-length side:
					WInfo.PrimaryPresent = true;
					SetWallVerts(WInfo.PrimaryInfo,Point0,Point1,LineLength,
								 PCeiling,PFloor);
					WInfo.SecondaryPresent = true;
					SetWallVerts(WInfo.SecondaryInfo,Point0,Point1,LineLength,
								 PCeiling,PFloor);
					WInfo.TransparentPresent = true;
					SetWallVerts(WInfo.TransparentInfo,Point0,Point1,LineLength,
								 PCeiling,PFloor);
					WInfo.IsFullLength = true;
					
				} else if (NFloor > PFloor) {
					if (NCeiling >= PCeiling) {
						// Lower side:
						WInfo.TransparentPresent = true;
						SetWallVerts(WInfo.TransparentInfo,Point0,Point1,LineLength,
									 PCeiling,NFloor);
						WInfo.PrimaryPresent = true;
						SetWallVerts(WInfo.PrimaryInfo,Point0,Point1,LineLength,
									 NFloor,PFloor);
						
					} else {
						// Upper and lower sides:
						WInfo.PrimaryPresent = true;
						SetWallVerts(WInfo.PrimaryInfo,Point0,Point1,LineLength,
									 PCeiling,NCeiling);
						WInfo.TransparentPresent = true;
						SetWallVerts(WInfo.TransparentInfo,Point0,Point1,LineLength,
									 NCeiling,NFloor);
						WInfo.SecondaryPresent = true;
						SetWallVerts(WInfo.SecondaryInfo,Point0,Point1,LineLength,
									 NFloor,PFloor);
						
					}
				} else {
					if (NCeiling >= PCeiling) {
						// All clear:
						WInfo.TransparentPresent = true;
						SetWallVerts(WInfo.TransparentInfo,Point0,Point1,LineLength,
									 PCeiling,PFloor);
						
					} else if (NCeiling > PFloor) {
						// Upper side:
						WInfo.PrimaryPresent = true;
						SetWallVerts(WInfo.PrimaryInfo,Point0,Point1,LineLength,
									 PCeiling,NCeiling);
						WInfo.TransparentPresent = true;
						SetWallVerts(WInfo.TransparentInfo,Point0,Point1,LineLength,
									 NCeiling,PFloor);
						
					} else {
						// Full-length side:
						WInfo.PrimaryPresent = true;
						SetWallVerts(WInfo.PrimaryInfo,Point0,Point1,LineLength,
									 PCeiling,PFloor);
						WInfo.SecondaryPresent = true;
						SetWallVerts(WInfo.SecondaryInfo,Point0,Point1,LineLength,
									 PCeiling,PFloor);
						WInfo.TransparentPresent = true;
						SetWallVerts(WInfo.TransparentInfo,Point0,Point1,LineLength,
									 PCeiling,PFloor);
						WInfo.IsFullLength = true;
						
					}
				}
			}
			
			// Now set up the transfer modes and textures
			if (SIndx == NONE) {
				// The primary and secondary sides will keep their default states: being invalid
				WInfo.TransparentPresent = false;
			} else {
				LESide *theSide = [theSides objectAtIndex:SIndx];
				
				// The wall lights:
				WInfo.PrimaryInfo.Light = [theSide getPrimary_lightsource_index];
				WInfo.SecondaryInfo.Light = [theSide getSecondary_lightsource_index];
				WInfo.TransparentInfo.Light = [theSide getTransparent_lightsource_index];
				
				if (WInfo.IsFullLength) {
					side_texture_definition Txtr = [theSide getSecondary_texture];
					if (((Txtr.texture) & 0x00ff) == (NONE & 0x00ff))
						WInfo.SecondaryPresent = false;
				}
				
				side_texture_definition Txtr = [theSide getTransparent_texture];
				if (((Txtr.texture) & 0x00ff) == (NONE & 0x00ff))
					WInfo.TransparentPresent = false;
				
				if (WInfo.PrimaryPresent) {
					WInfo.PrimaryInfo.TxtrXfr = [theSide getPrimary_transfer_mode];
					Txtr = [theSide getPrimary_texture];
					SetWallTxtr(Version, WInfo.PrimaryInfo, Txtr);
				}
				
				if (WInfo.SecondaryPresent) {
					WInfo.SecondaryInfo.TxtrXfr = [theSide getSecondary_transfer_mode];
					Txtr = [theSide getSecondary_texture];
					SetWallTxtr(Version, WInfo.SecondaryInfo, Txtr);
				}
				
				if (WInfo.TransparentPresent) {
					WInfo.TransparentInfo.TxtrXfr = [theSide getTransparent_transfer_mode];
					Txtr = [theSide getTransparent_texture];
					SetWallTxtr(Version, WInfo.TransparentInfo, Txtr);
				}
			}
		}
		
		// Find the horizontal bounding box
		PInfo.FindMinMax();
		
		// Doing the offsets requires that the base values of the vertices be set
		NSPoint Origin;
		Origin = [thePolygon getFloor_origin];
		DoTxtrOffset(PInfo.FloorInfo, (short int)Origin.x, (short int)Origin.y);
		Origin = [thePolygon getCeiling_origin];
		DoTxtrOffset(PInfo.CeilInfo, (short int)Origin.x, (short int)Origin.y);
		
		// Likewise for trimming away unused liquid surfaces
		if (PInfo.Liquid == NONE) {
			PInfo.LiquidAboveInfo.SetNVerts(0);
			PInfo.LiquidBelowInfo.SetNVerts(0);
		}
	}
	
	// Reset the lights and liquids
	RecalcLightsLiquids();
	
	// Go to the current start position
	DoGoto();
}


void MapManager::RecalcLightsLiquids() {

	int LightSetting = VO.SelectLightType;
	
	for (int il=0; il<LightList.get_len(); il++) {
		LightInfo &Light = LightList[il];
		Light.CurrL = Light.L[LightSetting];
	}
	
	for (int iq=0; iq<LiquidList.get_len(); iq++) {
		LiquidInfo &Liquid = LiquidList[iq];
		GLfloat CurrHeight = Liquid.Low +
			(Liquid.High - Liquid.Low)*LightList[Liquid.ControlLight].CurrL;
		
		Liquid.CurrHeight = (CurrHeight >= 0) ? short(CurrHeight + 0.5) : short(CurrHeight - 0.5);
	}
}


// Do motion/portal dialog box; needs moving the position values
bool MapManager::DoMotPort() {
	
	// Get position from view context
	// and put it into motion/portals dialog
	MP.PositionTF[0].val = VC.x/float(WORLD_ONE);
	MP.PositionTF[1].val = VC.y/float(WORLD_ONE);
	MP.PositionTF[2].val = VC.z/float(WORLD_ONE);
	for (int ic=0; ic<3; ic++)
		MP.PositionTF[ic].SetValue();
	
	if (MP.Do()) {
		// Get position from motion/portals dialog
		// and put it into view context
		for (int ic=0; ic<3; ic++)
			MP.PositionTF[ic].GetValue();
		VC.x = MP.PositionTF[0].val*float(WORLD_ONE);
		VC.y = MP.PositionTF[1].val*float(WORLD_ONE);
		VC.z = MP.PositionTF[2].val*float(WORLD_ONE);
		VC.SetView();
	}
	return false;
}
