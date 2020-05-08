// This is some of the extra methods of the MapData objects

#include "MiscUtils.h"
#include "MapData.h"
#include "Vector3D.h"

using namespace simd;

void PortalInfo::Update() {

	for (int iv=0; iv<NumPortalVertices; iv++) {
		auto V1 = PVList[iv].Vertex;
		auto V2 = PVList[(iv+1)%NumPortalVertices].Vertex;
		PVList[iv].Plane = cross(V1, V2);
	}
}

bool PortalInfo::IsValid() {

	simd::float3 vertsum = simd_make_float3(0, 0, 0), plnsum = simd_make_float3(0, 0, 0);
	
	for (int iv=0; iv<NumPortalVertices; iv++) {
		vertsum += PVList[iv].Vertex;
		plnsum += PVList[iv].Plane;
	}
	
	return (dot(vertsum,plnsum) > 0);
}


bool PortalOverlapCheck(PortalInfo &P1, PortalInfo &P2) {
		
	// Find which side of the planes the vertices are on
	bool Pln1Vert2[NumPortalVertices][NumPortalVertices];
	bool Pln2Vert1[NumPortalVertices][NumPortalVertices];
	
	// While finding those tables, check to see if a plane has all the other portal's
	// vertices on the wrong side of it
	for (int ip=0; ip<NumPortalVertices; ip++) {
		bool p1v2 = false;
		bool p2v1 = false;
		for (int iv=0; iv<NumPortalVertices; iv++) {
			bool p1v2ind = Pln1Vert2[ip][iv] =
				dot(P1.PVList[ip].Plane,P2.PVList[iv].Vertex) >= 0;
			bool p2v1ind = Pln2Vert1[ip][iv] =
				dot(P2.PVList[ip].Plane,P1.PVList[iv].Vertex) >= 0;
			p1v2 |= p1v2ind;
			p2v1 |= p2v1ind;
		}
		if (!p1v2) return false;
		if (!p2v1) return false;
	}
	
	// Now check on whether one is contained within the other
	// Do a vertex-by-vertex check
	for (int iv=0; iv<NumPortalVertices; iv++) {
		bool v1p2 = true;
		bool v2p1 = true;
		for (int ip=0; ip<NumPortalVertices; ip++) {
			v1p2 &= Pln2Vert1[ip][iv];
			v2p1 &= Pln1Vert2[ip][iv];
		}
		if (v1p2) return true;
		if (v2p1) return true;
	}
	
	// Now check for intersections of segments
	for (int is1=0; is1<NumPortalVertices; is1++) {
		int nis1 = (is1 + 1) % NumPortalVertices;
		for (int is2=0; is2<NumPortalVertices; is2++) {
			int nis2 = (is1 + 1) % NumPortalVertices;
			
			if ((Pln1Vert2[is1][is2] ^ Pln1Vert2[is1][nis2]) &&
				(Pln2Vert1[is2][is1] ^ Pln2Vert1[is2][nis1]))
				return true;
		}
	}
	
	return false;
}


// This finds minimum and maximum values
void PolygonInfo::FindMinMax() {

	XMin = XMax = WInfoList[0].StartPoint.x;
	YMin = YMin = WInfoList[0].StartPoint.y;

	for (int iw=0; iw<WInfoList.get_len(); iw++) {
		const WallInfo &WInfo = WInfoList[iw];
		world_distance x = WInfo.StartPoint.x;
		world_distance y = WInfo.StartPoint.y;
		XMin = std::min(XMin,x);
		XMax = std::max(XMax,x);
		YMin = std::min(YMin,y);
		YMax = std::max(YMax,y);
	}
}

// Test for being inside
bool PolygonInfo::IsInside(float x, float y, float z) {

	if (x < XMin) return false;
	if (x > XMax) return false;
	if (y < YMin) return false;
	if (y > YMax) return false;
	if (z < FloorHeight) return false;
	if (z > CeilingHeight) return false;

	for (int iw=0; iw<WInfoList.get_len(); iw++) {
		const WallInfo &WInfo = WInfoList[iw];
		const world_point2d &SP = WInfo.StartPoint;
		const world_point2d &ID = WInfo.InwardDir;
		if (((x-SP.x)*ID.x + (y-SP.y)*ID.y) < 0) return false;
	}
	return true;
}
