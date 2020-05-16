// Here are the rendering and visibility methods of MapManager

#include "MapManager.h"
#include "Vector3D.h"


//! Set current OpenGL color to swatch contents
inline void SetOGLColor(RGBColor& Swatch) {glColor3usv((GLushort *)&Swatch);}


//! This object contains a screen pattern to use with glPolygonStipple() for implementing semitransparency
class ScreenPatternObject
{
    unsigned long Pattern[32];

public:
    unsigned long *Get() {return Pattern;}
    
    ScreenPatternObject();
};
static ScreenPatternObject ScreenPattern;


ScreenPatternObject::ScreenPatternObject()
{
    // Set up the screen pattern:
    for (int k=0; k<32; k++)
    {
        // Clever test for even/odd; the hex values make 1 0 / 0 1
        Pattern[k] = (k & 1) ? 0x5a5a5a5a : 0xa5a5a5a5;
    }
}


// Is point inside the view context's polygon or its neighbors?
// Returns which one, or NONE if none
short MapManager::IsInsideVCPN(float x, float y, float z) {

	// Sanity check
	if (VC.MemberOf == NONE) return NONE;

	PolygonInfo &PInfo = PInfoList[VC.MemberOf];
	if (PInfo.IsInside(x,y,z)) return VC.MemberOf;
	
	for (int iw=0; iw<PInfo.WInfoList.get_len(); iw++) {
		short Ngbr = PInfo.WInfoList[iw].Neighbor;
		if (Ngbr == NONE) continue;
		if (PInfoList[Ngbr].IsInside(x,y,z)) return Ngbr;
	}
	
	return NONE;
}


short MapManager::IsInsideVCPN(simd::float3 pos)
{
	// Sanity check
	if (VC.MemberOf == NONE) return NONE;

	PolygonInfo &PInfo = PInfoList[VC.MemberOf];
	if (PInfo.IsInside(pos)) return VC.MemberOf;
	
	for (int iw=0; iw<PInfo.WInfoList.get_len(); iw++) {
		short Ngbr = PInfo.WInfoList[iw].Neighbor;
		if (Ngbr == NONE) continue;
		if (PInfoList[Ngbr].IsInside(pos)) return Ngbr;
	}
	
	return NONE;
}

void MapManager::FindOtherPolygon(int Dir) {

	// Sanity check
	if (VC.MemberOf == NONE) return;

	if (Dir > 0) {
		for (int ip=VC.MemberOf+1; ip<PInfoList.get_len(); ip++) {
			if (PInfoList[ip].IsInside(VC.pos)) {
				VC.MemberOf = ip;
				return;
			}
		}
		for (int ip = 0; ip<VC.MemberOf; ip++) {
			if (PInfoList[ip].IsInside(VC.pos)) {
				VC.MemberOf = ip;
				return;
			}
		}
	} else if (Dir < 0) {
		for (int ip=VC.MemberOf-1; ip>=0; ip--) {
			if (PInfoList[ip].IsInside(VC.pos)) {
				VC.MemberOf = ip;
				return;
			}
		}
		for (long ip=PInfoList.get_len()-1; ip>VC.MemberOf; ip--) {
			if (PInfoList[ip].IsInside(VC.pos)) {
				VC.MemberOf = ip;
				return;
			}
		}
	}
}


// Number of binary-search iterations for advancing
const int NumBinaryIters = 6;


// Set position to starting point if requested
void MapManager::UpdateViewCtxtDoVis() {
	//UpdatePosition = true;
	// Sanity check
	if (VC.MemberOf == NONE && !UpdatePosition) return;
	
	if (UpdatePosition) {
		// This is for setting a position to a start-point position
		VC.pos = simd_float(StartPoint.loc);
		VC.Save();
		VC.MemberOf = StartPoint.Polygon;
		VC.YawAngle = StartPoint.Angle;
		VC.PitchAngle = 0;
		VC.SetView();
		UpdatePosition = false;
	} else if (PInfoList[VC.MemberOf].IsInside(VC.posPrev)) {
		// Does new position land inside of itself or neighboring polygon?
		short Ngbr = IsInsideVCPN(VC.pos);
		if (Ngbr != NONE)
			VC.MemberOf = Ngbr;
		else {
			// Find the farthest one can go without walking through a wall
			// The loops here are deliberately finite.
			for (int it=0; it<NumBinaryIters; it++) {
				// Find the farthest point that can be jumped into
				simd::float3 val1 = VC.pos;
				for(int ita=0; ita<NumBinaryIters; ita++) {
					// Move that point to the previous point
					val1 = (VC.posPrev + val1)/2;
					// Check it
					Ngbr = IsInsideVCPN(val1);
					if (Ngbr != NONE) break;
				}
				// Just in case...
				if (Ngbr == NONE) break;
				
				// Move previous point to that point
				VC.posPrev = val1;
				VC.MemberOf = Ngbr;
				// Check on target point
				 Ngbr = IsInsideVCPN(VC.pos);
				 if (Ngbr != NONE) {
				 	VC.MemberOf = Ngbr;
				 	break;
				 }
			}
			
			if (!MP.WalkThruWallsCB) {
				// Cannot walk through walls
				// Move back to previous position
				// if had been unable to walk through the wall
				if (Ngbr == NONE) {
					VC.pos = VC.posPrev;
				}
			} // Don't change final position if one can walk through walls
		}
	} else if (MP.JumpFromVoidCB) {
		// This is if the viewpoint is jumping from the void
		// into whatever polygon is at its location
		for (int ip=0; ip<PInfoList.get_len(); ip++) {
			if (PInfoList[ip].IsInside(VC.pos)) {
				VC.MemberOf = ip;
				break;
			}
		}
	} // From the void, don't jump
	
	// Find the visibility
	// Go from one-based to zero-based indexing
	switch(MP.VisModePopup) {
	// Render all of them;
	case MotPort::VisMode_All:
	default:
		for (int ip=0; ip<VisList.get_len(); ip++)
			VisList[ip] = ip;
		break;
	
	// Do portal-rendering visibility
	case MotPort::VisMode_Portal:
		DoPortals();
		if (MP.DepthSortCB) DoDepthSort();
		break;
		
	// Render only the current one
	case MotPort::VisMode_One:
		VisList.fill(NONE);
		VisList[0] = VC.MemberOf;
		break;
	}
}


void MapManager::DoPortals() {
	// When this routine is done, the outgoing portals will be usable
	// Initially, nothing is visible
	VisList.fill(NONE);
	
	// Sanity check
	if (VC.MemberOf == NONE) return;
	
	// Initialization: nothing had been calculated
	for (int ip=0; ip<PInfoList.get_len(); ip++) {
		PolygonInfo &PInfo = PInfoList[ip];
		PInfo.PortalsCalculated = false;
	}
	
	// Set up the screen portal:
	PortalInfo ScreenPortal;
	simd::float3 PosVec;
	VC.FindPosition(0,0,PosVec);
	ScreenPortal.PVList[0].Vertex = PosVec;
	VC.FindPosition(VC.Width-1,0,PosVec);
	ScreenPortal.PVList[1].Vertex = PosVec;
	VC.FindPosition(VC.Width-1,VC.Height-1,PosVec);
	ScreenPortal.PVList[2].Vertex = PosVec;
	VC.FindPosition(0,VC.Height-1,PosVec);
	ScreenPortal.PVList[3].Vertex = PosVec;
	ScreenPortal.Update();
	
	// Set up the first visible polygon: the currently-resident one
	short CurrPolygon = VC.MemberOf;
	VisList[CurrPolygon] = CurrPolygon;
	PolygonInfo &StartPInfo = PInfoList[CurrPolygon];
	StartPInfo.PrevPolygon = NONE;
	StartPInfo.NextPlgnIndx = 0;
	
	// Now examine that polygon's neighbors
	const int qmax = 1000000;
	int q = qmax;
	while(--q > 0) {
		PolygonInfo &CurrPInfo = PInfoList[CurrPolygon];
		
		// Increment after reading, so that the next would-be portal
		// will be checked on the next go-around
		short NextPlgnIndx = CurrPInfo.NextPlgnIndx++;
		// printf("%d %d\n",CurrPolygon,NextPlgnIndx);
		if (NextPlgnIndx >= CurrPInfo.WInfoList.get_len()) {
			// Move backwards in the chain
			CurrPolygon = CurrPInfo.PrevPolygon;
			if (CurrPolygon == NONE) break;
			else continue;
		}
		
		// Calculate all the portals
		if (!CurrPInfo.PortalsCalculated) {
			for (int iw=0; iw<CurrPInfo.WInfoList.get_len(); iw++) {
				// Get a the wall reference and set to "invalid portal";
				// that will be overridden if necessary
				WallInfo &WInfo = CurrPInfo.WInfoList[iw];
				WInfo.PortalState = WallInfo::Portal_Invalid;
				
				// No neighbor: invalid portal
				if (WInfo.Neighbor == NONE) continue;
				
				// Test for the wall's normal being toward the viewpoint
				float WallViewProd = 
					(VC.pos.x - WInfo.StartPoint.x)*WInfo.InwardDir.x +
						(VC.pos.y - WInfo.StartPoint.y)*WInfo.InwardDir.y;
				
				if (WallViewProd <= 0) continue;
				
				// Construct the portal
				PortalInfo &Portal = WInfo.Portal;
				SurfaceInfo &PtlSurf = WInfo.TransparentInfo;
				for (int iv=0; iv<NumPortalVertices; iv++) {
					simd::short3 InpVert = PtlSurf.VInfoList[iv].Vert;
					simd::float3 &Vertex = Portal.PVList[iv].Vertex;
					Vertex = simd_float(InpVert) - VC.pos;
				}
				Portal.Update();
			
				// Skip over this position if the portal is not valid
				if (!Portal.IsValid()) continue;
				
				// The portal are now valid but invisible
				WInfo.PortalState = WallInfo::Portal_Invisible;
			}
			
			// No need to repeat
			CurrPInfo.PortalsCalculated = true;
		}
		
		// Examine the side's portal; if it is valid, then look at the polygon
		// on the other side
		WallInfo &WInfo = CurrPInfo.WInfoList[NextPlgnIndx];
		if (WInfo.PortalState != WallInfo::Portal_Invalid) {
			// Doesn't have to be checked for "NONE" because
			// that would make the portal invalid.
			short NextPolygon = WInfo.Neighbor;
			
			// Check on that portal's visibility by looking backward;
			// start by looking at previous polygon
			bool IsVisible = true;
			short LookBackPlgn = CurrPInfo.PrevPolygon;
			while(true) {
				// If the look-back polygon index is NONE,
				// then use the screen portal, otherwise use the appropriate
				// look-back-polygon portal
				PortalInfo *LookBackPortalPtr;
				short NextLookBackPlgn = NONE;
				bool ReachedBeginning = false;
				if (LookBackPlgn != NONE) {
					PolygonInfo &LookBackPInfo = PInfoList[LookBackPlgn];
					// NextPlgnIndx points to next one to look at;
					// move it back for the current index
					LookBackPortalPtr = &LookBackPInfo.WInfoList[LookBackPInfo.NextPlgnIndx-1].Portal;
					NextLookBackPlgn = LookBackPInfo.PrevPolygon;
				} else {
					ReachedBeginning = true;
					LookBackPortalPtr = &ScreenPortal;
				}
				
				if (!PortalOverlapCheck(WInfo.Portal,*LookBackPortalPtr)) {
					IsVisible = false;
					break;
				}
				if (ReachedBeginning) break;
				LookBackPlgn = NextLookBackPlgn;
			}
			if (!IsVisible) continue;
			// Visibility is "sticky"
			WInfo.PortalState = WallInfo::Portal_Visible;
			
			// Polygon to advance to
			PolygonInfo &NextPInfo = PInfoList[NextPolygon];
			
			// Set what its previous polygon is
			NextPInfo.PrevPolygon = CurrPolygon;
			VisList[NextPolygon] = NextPolygon;
			
			// For starting to go into it;
			// outside of above statement since the same polygon
			// could be entered via different paths
			NextPInfo.NextPlgnIndx = 0;
				
			// Go!
			CurrPolygon = NextPolygon;
		}
	}
	if (q <= 0) printf("Visibility checking problem: too many polygons examined\n");
}


void MapManager::DoDepthSort() {
	// Does depth sorting of the polygons
		
	// Create a temporary list and use it to compact the list of visible polygons
	int VisLen = VisList.get_len();	
	simple_vector<short> VisTempList(VisLen);
	VisTempList.fill(NONE);
	
	int NVisible = 0;
	for (int ip=0; ip<VisLen; ip++) {
		short VP = VisList[ip];
		if (VP != NONE)
			VisTempList[NVisible++] = VP;
	}
	VisList.swap_with(VisTempList);
	
	// No need to sort in this trivial case
	if (NVisible <= 0) return;
	
	// Now do the sorting of these compacted values
	
	// Use this temporary list as a reference; it is indexed by polygon ID,
	// and its value is the position in the sorted list
	VisTempList.fill(NONE);
	
	// Multipass sorting; the worst case is O(N^2)
	int NSorted = 0, PrevNSorted = 0;
	while(true) {
		// Be sure to start a pass at the first unsorted one
		int ip0 = NSorted;
		for (int ip=ip0; ip<NVisible; ip++) {
			// Check to see whether this polygon's visible portals all look into
			// sorted polygons
			short VP = VisList[ip];
			simple_vector<WallInfo> &WInfoList = PInfoList[VP].WInfoList;
			bool CanLookIntoUnsorted = false;
			for (int iv=0; iv<WInfoList.get_len(); iv++) {
				WallInfo &WInfo = WInfoList[iv];
				if (WInfo.PortalState == WallInfo::Portal_Visible) {
					if (VisTempList[WInfo.Neighbor] == NONE) {
						CanLookIntoUnsorted = true;
						break;
					}
				}
			}
			if (!CanLookIntoUnsorted) {
				// Add this one to the sorted list;
				// do this by interchange if necessary
				VisTempList[VP] = VP;
				if (ip != NSorted) {
					VisList[ip] = VisList[NSorted];
					VisList[NSorted] = VP;
				}
				NSorted++;
			}
		}
		// Do only as many passes as necessary; stop when everything is sorted
		if (NSorted == PrevNSorted) break;
		PrevNSorted = NSorted;
	}
	
	if (NSorted < NVisible) {
		// Ought to signal an error;
		// blank out remaining unsorted polygons
		for (int ip=NSorted; ip<NVisible; ip++)
			VisList[ip] = NONE;
	}
}


// Method for rendering a surface:
void MapManager::DoSurfaceRender(SurfaceInfo &SInfo) {
	
	GLfloat ColorBuffer[4];
	
	// When in textured mode, this will tell whether the texture has been suppressed
	// for the current polygon
	bool IfTextureSuppressed = false;
	
	switch(SInfo.TxtrType) {
	case SurfaceInfo::Wall:
		// Put in correct handling of invalid texture-frame indices
		if (IfTextured) {
			// Tell the texture object to use the current texture
			// The request will return whether or not the texture was in range
			bool IfExists;
			if (IfAveraged) {
				// Use the average color
				GLfloat *TileAvgColor = TMgr.GetAvgColor(SInfo.TxtrSet,SInfo.TxtrIndex);
				IfExists = (TileAvgColor != 0);
				if (IfExists)
                                        // Treat it as opaque;
                                        // semitransparency will be handled by stippling
					glColor3fv(TileAvgColor);
			} else {
				// Use the texture
				IfExists = TMgr.Use(SInfo.TxtrSet,SInfo.TxtrIndex);
				if (IfExists) {
					SInfo.UseTextures();
					// Change the backing color if lights are to be used
					if (VO.UseLights) {
						GLfloat CurrLight = LightList[SInfo.Light].CurrL;
						glColor3f(CurrLight,CurrLight,CurrLight);
					}
				}
			}
			// If the texture reference is invalid, then the color is the invalid color
			if (!IfExists) {
				IfTextureSuppressed = true;
				if (!IfAveraged) {
					glDisable(GL_TEXTURE_2D);
					glDisableClientState(GL_TEXTURE_COORD_ARRAY);
				}
				glGetFloatv(GL_CURRENT_COLOR,ColorBuffer);
				SetOGLColor(VO.InvldSwatch);
			}
		}
		break;
	
	case SurfaceInfo::Landscape:
		if (!VO.ShowLdscp) return;
		// New color only if doing filled
		if (SurfaceRenderMode != GL_LINE_LOOP) {
			glGetFloatv(GL_CURRENT_COLOR,ColorBuffer);
			SetOGLColor(VO.LdscpSwatch);
			if (IfTextured && !IfAveraged) {
				glDisable(GL_TEXTURE_2D);
				glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			}
		}
		break;
	
	case SurfaceInfo::Invalid:
		if (!VO.ShowInvld) return;
		// New color only if doing filled
		if (SurfaceRenderMode != GL_LINE_LOOP) {
			glGetFloatv(GL_CURRENT_COLOR,ColorBuffer);
			SetOGLColor(VO.InvldSwatch);
			if (IfTextured && !IfAveraged) {
				glDisable(GL_TEXTURE_2D);
				glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			}
		}
		break;
	
	default:
		return;	// Don't render if none of these
	}

	SInfo.Render(SurfaceRenderMode);
	
	// Do the wireframe in this special way when the Z-buffer is absent
	if ((!MP.ZBufferCB) && (SurfaceRenderMode != GL_LINE_LOOP) && (!IfTextured)) {
		GLfloat WireColorBuffer[4];
		glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
		glGetFloatv(GL_CURRENT_COLOR,WireColorBuffer);
		SetOGLColor(VO.WireSwatch);
		
		SInfo.Render(SurfaceRenderMode);
		
		glColor4fv(WireColorBuffer);
		glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
	}

	// Restore color and earlier state
	switch(SInfo.TxtrType) {
	case SurfaceInfo::Wall:
		if (IfTextureSuppressed) {
			if (!IfAveraged) {
				glEnable(GL_TEXTURE_2D);
				glEnableClientState(GL_TEXTURE_COORD_ARRAY);
			}
		 	glColor4fv(ColorBuffer);
		}
		break;
	
	case SurfaceInfo::Landscape:
	case SurfaceInfo::Invalid:
		if (SurfaceRenderMode != GL_LINE_LOOP) glColor4fv(ColorBuffer);
		if (IfTextured && !IfAveraged) {
			glEnable(GL_TEXTURE_2D);
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		}
		break;
	}
}


void MapManager::DoRender(int RenderMode, bool DoDoubleSided) {
	// This assumes that the matrix mode is GL_MODELVIEW
	//DoDoubleSided = true;
	// Decide whether or not to clip to the portals
	bool ClipToPortals = (MP.VisModePopup == MotPort::VisMode_Portal) &&
		MP.ClipToPortalCB;
	
	// Remember previous clip-plane state
	GLboolean ClipPlanesEnabled[NumPortalVertices];
	if (ClipToPortals) {
		for (int ipln=0; ipln<NumPortalVertices; ipln++) {
			ClipPlanesEnabled[ipln] = glIsEnabled(GL_CLIP_PLANE0 + ipln);
		}
	}
	
	bool IfColored;
	
	switch(RenderMode) {
	case Render_Wireframe:
		IfColored = false;
		IfAveraged = false;
		IfTextured = false;
		SurfaceRenderMode = GL_LINE_LOOP;
		// The only color used for the wireframes
		SetOGLColor(VO.WireSwatch);
		break;
		
	case Render_Colored:
		IfColored = true;
		IfAveraged = false;
		IfTextured = false;
		SurfaceRenderMode = GL_POLYGON;
		break;

	case Render_Averaged:
		IfColored = false;
		IfAveraged = true;
		IfTextured = true;
		SurfaceRenderMode = GL_POLYGON;
		break;
		
	case Render_Textured:
		IfColored = false;
		IfAveraged = false;
		IfTextured = true;
		SurfaceRenderMode = GL_POLYGON;
		// Color base for textured rendering
		glColor3f(1.0,1.0,1.0);
		break;
	
	default:
		return;	// Don't render if none of these
	}
	
	long VisLen = VisList.get_len();
	for (int ipi=0; ipi<VisLen; ipi++) {
		// Scan the VisList to find out what to render;
		// render in reverse order if desired
		long ipix = MP.ReverseOrderCB ? ((VisLen-1) - ipi) : ipi;
		short ip = VisList[ipix];
		if (ip < 0) continue;
		
		PolygonInfo &PInfo = PInfoList[ip];
		
		// Whether to clip to portals for this room;
		// don't clip for room that the viewpoint is a member of.
		// If so, then render as many times as there are portals.
		// Otherwise, render only once. 
		long npt = 1;
		bool InContainingRoom = (ip == VC.MemberOf);
		bool ClipToPortalHere = ClipToPortals && (!InContainingRoom);
		// Need to check every wall for portals if portal clipping is enabled
		if (ClipToPortalHere) npt = PInfo.WInfoList.get_len();
		if (ClipToPortals) {
			if (InContainingRoom) {
				// No clipping in containing room
				for (int ipln=0; ipln<NumPortalVertices; ipln++)
					glDisable(GL_CLIP_PLANE0 + ipln);
			} else {
				// Clipping on other rooms
				for (int ipln=0; ipln<NumPortalVertices; ipln++)
					glEnable(GL_CLIP_PLANE0 + ipln);
			}
		}
		
		for (int ipt=0; ipt<npt; ipt++) {
			if (ClipToPortalHere) {
				// Set up the clipping planes
				
				// Look into neighboring polygon at this wall
				WallInfo &WInfo = PInfo.WInfoList[ipt];
				short NgbrPolygon = WInfo.Neighbor;
				if (NgbrPolygon == NONE) continue;
				
				// Can one look back in?
				PolygonInfo &NgbrPInfo = PInfoList[NgbrPolygon];
				int inbk = NONE;
				for (int iv=0; iv<NgbrPInfo.WInfoList.get_len(); iv++) {
					if (NgbrPInfo.WInfoList[iv].Neighbor == ip) {
						inbk = iv;
						break;
					}
				}
				if (inbk == NONE) continue;
				
				// Get the inward portal
				WallInfo &NgbrWInfo = NgbrPInfo.WInfoList[inbk];
				
				// Omit if not visible
				if (NgbrWInfo.PortalState != WallInfo::Portal_Visible) continue;
				
				// Get the portal
				PortalInfo &Portal = NgbrWInfo.Portal;
				
				// Now make the clip planes
				GLdouble ClipPlane[4];	
				for (int ipln=0; ipln<NumPortalVertices; ipln++) {
					// Get the clipping plane's normal
					auto Plane = Portal.PVList[ipln].Plane;
					copy_3d(Plane,ClipPlane);
					scalmult_3d(1.0,ClipPlane,ClipPlane);
					// Clipping plane passes through viewpoint;
					// adjust with the third point
					ClipPlane[3] = - (ClipPlane[0]*VC.pos.x + ClipPlane[1]*VC.pos.y + ClipPlane[2]*VC.pos.z);
					glClipPlane(GL_CLIP_PLANE0 + ipln,ClipPlane);
				}
			}
			
			if (IfColored) SetOGLColor(VO.FloorSwatch);
			DoSurfaceRender(PInfo.FloorInfo);
			
			if (IfColored) SetOGLColor(VO.CeilSwatch);
			DoSurfaceRender(PInfo.CeilInfo);
			
			for (int iv=0; iv<PInfo.WInfoList.get_len(); iv++) {
				WallInfo &WInfo = PInfo.WInfoList[iv];
   				
				if (IfColored) SetOGLColor(VO.WallSwatch);
				if (WInfo.PrimaryPresent)
					DoSurfaceRender(WInfo.PrimaryInfo);
					
				if (WInfo.SecondaryPresent)
					DoSurfaceRender(WInfo.SecondaryInfo);
				
				// Transparent textures are double-sided...
				if (!DoDoubleSided) continue;
				
				// Make one-sided in case of two-sided rendering
				GLboolean IsOneSided = glIsEnabled(GL_CULL_FACE);
				if (!IsOneSided) glEnable(GL_CULL_FACE);
				if (WInfo.TransparentPresent && VO.ShowTrans) {
					if (IfColored) SetOGLColor(VO.TransSwatch);
                                        // Made semitransparent if flat-colored
                                        if (IfColored || IfAveraged) {
                                                glEnable(GL_POLYGON_STIPPLE);
                                                glPolygonStipple((const GLubyte *)ScreenPattern.Get());
                                        }
					DoSurfaceRender(WInfo.TransparentInfo);
                                        if (IfColored || IfAveraged) {
                                                glDisable(GL_POLYGON_STIPPLE);
                                        }
				}
				if (!IsOneSided) glDisable(GL_CULL_FACE);
			}
			
			// Liquids are double-sided...
			if (!DoDoubleSided) continue;
			
			// Do liquids?
			if (!VO.ShowLiquids) continue;
			
			short LiquidIndx = PInfo.Liquid;
			if (LiquidIndx == NONE) continue;
			
			// Check on the liquid's height
			world_distance LiquidHeight = LiquidList[LiquidIndx].CurrHeight;
			if (LiquidHeight <= PInfo.FloorHeight) continue;
			if (LiquidHeight >= PInfo.CeilingHeight) continue;
			PInfo.LiquidBelowInfo.SetHeight(LiquidHeight);
			PInfo.LiquidAboveInfo.SetHeight(LiquidHeight);
                        
                        // Semitransparency hack: stippling
                        if (VO.LiquidsTransparent) {
                            glEnable(GL_POLYGON_STIPPLE);
                            glPolygonStipple((const GLubyte *)ScreenPattern.Get());
                        }
		
			// Make one-sided in case of two-sided rendering
			GLboolean IsOneSided = glIsEnabled(GL_CULL_FACE);
			if (!IsOneSided) glEnable(GL_CULL_FACE);
			if (IfColored) SetOGLColor(VO.LiquidSwatch);
			DoSurfaceRender(PInfo.LiquidBelowInfo);
			DoSurfaceRender(PInfo.LiquidAboveInfo);
			if (!IsOneSided) glDisable(GL_CULL_FACE);
                        
                        // Done with that hack
                        if (VO.LiquidsTransparent) {
                            glDisable(GL_POLYGON_STIPPLE);
                        }
		}
	}
	
	// Restore previous clip-plane state
	if (ClipToPortals) {
		for (int ipln=0; ipln<NumPortalVertices; ipln++) {
			if (!ClipPlanesEnabled[ipln])
				glDisable(GL_CLIP_PLANE0 + ipln);
		}
	}
}
