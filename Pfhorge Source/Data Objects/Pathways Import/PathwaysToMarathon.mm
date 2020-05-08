//
// PathwaysToMarathon.h
// Pfhorge
//
// Converts a map from the format of
// Pathways into Darkness
// into Pfhorge's internal format
// for the Marathon series
//
// All the methods moved here from PathwaysExchange.mm
// to simplify the contents of the latter file
//
// Originally written by Loren Petrich

#import "PathwaysToMarathon.h"
#import "LEExtras.h"
#import "LEMapData.h"
#import "LELine.h"
#import "LESide.h"
#import "LEPolygon.h"
#import "LEMapPoint.h"
#import "PhPlatform.h"
#import "PhAnnotationNote.h"
#import "PhNoteGroup.h"


static NSString *MakeFromPascalString(byte *PasString)
{
    return CFBridgingRelease(CFStringCreateWithPascalString(kCFAllocatorDefault, PasString, kCFStringEncodingMacRoman));
}


NSString *GetLevelName(PID_Level& PL)
{
    return MakeFromPascalString(PL.Name);
}


// Addressing a sector
inline int SectorAddr(int x, int y)
{return (x + PID_Level::NUMBER_X_SECTORS*y);}

// Map positions
// "Which" refers to how many fourths away from the plain (x,y) point;
// a plain polygon has four points that are selections from pairs
// XPos(x,0) XPos(x,4)
// YPos(y,0) YPos(y,4)
// const int WORLD_ONE = 1024;
inline int XPos(int x, int which)
{return ((x - PID_Level::NUMBER_X_SECTORS/2)*WORLD_ONE + which*(WORLD_ONE/4));}
inline int YPos(int y, int which)
{return ((y - PID_Level::NUMBER_Y_SECTORS/2)*WORLD_ONE + which*(WORLD_ONE/4));}


// Which sector points, lines, and polygons are which

enum
{
    // Plain
    Pt_Corner,
    // For beveling, doors
    Pt_X_Near,
    Pt_X_Far,
    Pt_Y_Near,
    Pt_Y_Far,
    // Total
    NumPointDefs
};

struct PointDef {
    short wx, wy;	// Where in sector
};

static const PointDef PtDefs[NumPointDefs] = {
    // Plain
    {0,0},
    // For beveling, doors
    {1,0},
    {3,0},
    {0,1},
    {0,3}
};


enum {
    // Plain
    Ln_X,
    Ln_Y,
    // For beveling, doors
    Ln_X_Near,
    Ln_X_NearCenter,
    Ln_X_Center,
    Ln_X_FarCenter,
    Ln_X_Far,
    Ln_Y_Near,
    Ln_Y_NearCenter,
    Ln_Y_Center,
    Ln_Y_FarCenter,
    Ln_Y_Far,
    // For beveling
    Ln_XNear_YNear,
    Ln_XFar_YNear,
    Ln_XNear_YFar,
    Ln_XFar_YFar,
    // For doors
    Ln_X_NearDoor,
    Ln_X_FarDoor,
    Ln_Y_NearDoor,
    Ln_Y_FarDoor,
    // Total
    NumLineDefs
};

struct LnPtDef {
    short x, y;	// Which sector offset
    short w;	// Which sort of point or line (from appropriate enum)
};

struct LineDef {
    LnPtDef p0, p1; // The two endpoints
};

const LineDef LnDefs[NumLineDefs] = {
    // Plain
    {{0,0,Pt_Corner},{1,0,Pt_Corner}},
    {{0,0,Pt_Corner},{0,1,Pt_Corner}},
    // For beveling, doors
    {{0,0,Pt_Corner},{0,0,Pt_X_Near}},
    {{0,0,Pt_Corner},{0,0,Pt_X_Far}},
    {{0,0,Pt_X_Near},{0,0,Pt_X_Far}},
    {{0,0,Pt_X_Near},{1,0,Pt_Corner}},
    {{0,0,Pt_X_Far},{1,0,Pt_Corner}},
    {{0,0,Pt_Corner},{0,0,Pt_Y_Near}},
    {{0,0,Pt_Corner},{0,0,Pt_Y_Far}},
    {{0,0,Pt_Y_Near},{0,0,Pt_Y_Far}},
    {{0,0,Pt_Y_Near},{0,1,Pt_Corner}},
    {{0,0,Pt_Y_Far},{0,1,Pt_Corner}},
    // For beveling
    {{0,0,Pt_Y_Near},{0,0,Pt_X_Near}},
    {{0,0,Pt_X_Far},{1,0,Pt_Y_Near}},
    {{0,1,Pt_X_Near},{0,0,Pt_Y_Far}},
    {{1,0,Pt_Y_Far},{0,1,Pt_X_Far}},
    // For doors
    {{0,0,Pt_X_Near},{0,1,Pt_X_Near}},
    {{0,0,Pt_X_Far},{0,1,Pt_X_Far}},
    {{0,0,Pt_Y_Near},{1,0,Pt_Y_Near}},
    {{0,0,Pt_Y_Far},{1,0,Pt_Y_Far}}
};

enum {
    // Plain
    Pg_Plain,
    // For beveling
    Pg_XNear_YNear,
    Pg_XFar_YNear,
    Pg_XNear_YFar,
    Pg_XFar_YFar,
    // For doors -- door faces in direction (X, Y)
    Pg_XNear,
    Pg_XDoor,
    Pg_XFar,
    Pg_YNear,
    Pg_YDoor,
    Pg_YFar,
   // Total
    NumPolygonDefs
};

// All of them defined here are either quads or triangles
struct PolygonDef {
    int N;
    LnPtDef Pts[4], Lns[4];
};

const PolygonDef PgDefs[NumPolygonDefs] = {
    // Plain: will get special handling
    {0,{
    },{
    }},
    // For beveling
    {3,{
        {0,0,Pt_Corner},{0,0,Pt_X_Near},{0,0,Pt_Y_Near}
    },{
        {0,0,Ln_X_Near},{0,0,Ln_XNear_YNear},{0,0,Ln_Y_Near}
    }},
    {3,{
        {1,0,Pt_Corner},{1,0,Pt_Y_Near},{0,0,Pt_X_Far}
    },{
        {1,0,Ln_Y_Near},{0,0,Ln_XFar_YNear},{0,0,Ln_X_Far}
    }},
    {3,{
        {0,1,Pt_Corner},{0,0,Pt_Y_Far},{0,1,Pt_X_Near}
    },{
        {0,0,Ln_Y_Far},{0,0,Ln_XNear_YFar},{0,1,Ln_X_Near}
    }},
    {3,{
        {1,1,Pt_Corner},{0,1,Pt_X_Far},{1,0,Pt_Y_Far}
    },{
        {0,1,Ln_X_Far},{0,0,Ln_XFar_YFar},{1,0,Ln_Y_Far}
    }},
    // for doors
    {4,{
        {0,0,Pt_Corner},{0,0,Pt_X_Near},{0,1,Pt_X_Near},{0,1,Pt_Corner}
    },{
        {0,0,Ln_X_Near},{0,0,Ln_X_NearDoor},{0,1,Ln_X_Near},{0,0,Ln_Y}
    }},
    {4,{
        {0,0,Pt_X_Near},{0,0,Pt_X_Far},{0,1,Pt_X_Far},{0,1,Pt_X_Near}
    },{
        {0,0,Ln_X_Center},{0,0,Ln_X_FarDoor},{0,1,Ln_X_Center},{0,0,Ln_X_NearDoor}
    }},
    {4,{
        {0,0,Pt_X_Far},{1,0,Pt_Corner},{1,1,Pt_Corner},{0,1,Pt_X_Far}
    },{
        {0,0,Ln_X_Far},{1,0,Ln_Y},{0,1,Ln_X_Far},{0,0,Ln_X_FarDoor}
    }},
    {4,{
        {0,0,Pt_Corner},{1,0,Pt_Corner},{1,0,Pt_Y_Near},{0,0,Pt_Y_Near}
    },{
        {0,0,Ln_X},{1,0,Ln_Y_Near},{0,0,Ln_Y_NearDoor},{0,0,Ln_Y_Near}
    }},
    {4,{
        {0,0,Pt_Y_Near},{1,0,Pt_Y_Near},{1,0,Pt_Y_Far},{0,0,Pt_Y_Far}
    },{
        {0,0,Ln_Y_NearDoor},{1,0,Ln_Y_Center},{0,0,Ln_Y_FarDoor},{0,0,Ln_Y_Center}
    }},
    {4,{
        {0,0,Pt_Y_Far},{1,0,Pt_Y_Far},{1,1,Pt_Corner},{0,1,Pt_Corner}
    },{
        {0,0,Ln_Y_FarDoor},{1,0,Ln_Y_Far},{0,1,Ln_X},{0,0,Ln_Y_Far}
    }}
};


// For the polygons at the bevels of the void sectors
struct BevelDef
{
    short x, y;		// Neighbor offset
    short c, nc;	// Corner line of the sector and its neighbor
    short p;		// Type of bevel polygon to add
};

const int NumBevelDefs = 4;
const BevelDef BvDefs[NumBevelDefs] = {
    {-1, -1, PID_Sector::Corner_LowX_LowY,   PID_Sector::Corner_HighX_HighY, Pg_XFar_YFar},
    {-1,  1, PID_Sector::Corner_LowX_HighY,  PID_Sector::Corner_HighX_LowY,  Pg_XFar_YNear},
    { 1, -1, PID_Sector::Corner_HighX_LowY,  PID_Sector::Corner_LowX_HighY,  Pg_XNear_YFar},
    { 1,  1, PID_Sector::Corner_HighX_HighY, PID_Sector::Corner_LowX_LowY,   Pg_XNear_YNear}
};

// For the sides of each of the sectors that become plain polygons
struct SideDef {
    short x, y;		// Offset to get side from
    short dir;		// Traversal direction when loading edges
    short wall;		// Which one to look at
    short full, lomid, midhi, lo, mid, hi;	// All the possible side segments
    short crnr_lo_src, crnr_hi_src;		// Corners: low and high sources
    short crnr_lo_dst, crnr_hi_dst;		// Corners: low and high dests
};

// In clockwise order!
// Note, the full src is really which wall to look at rather than the wall type
const int NumSideDefs = 4;
const SideDef SdDefs[NumSideDefs] = {
    {0, 0,  1, PID_Sector::Wall_Y,
        Ln_X, Ln_X_NearCenter, Ln_X_FarCenter, Ln_X_Near, Ln_X_Center, Ln_X_Far,
        PID_Sector::Corner_LowX_LowY, PID_Sector::Corner_HighX_LowY,
        Ln_XNear_YNear, Ln_XFar_YNear},
    {1, 0,  1, PID_Sector::Wall_X,
        Ln_Y, Ln_Y_NearCenter, Ln_Y_FarCenter, Ln_Y_Near, Ln_Y_Center, Ln_Y_Far,
        PID_Sector::Corner_HighX_LowY, PID_Sector::Corner_HighX_HighY,
        Ln_XFar_YNear, Ln_XFar_YFar},
    {0, 1, -1, PID_Sector::Wall_Y,
        Ln_X, Ln_X_NearCenter, Ln_X_FarCenter, Ln_X_Near, Ln_X_Center, Ln_X_Far,
        PID_Sector::Corner_LowX_HighY, PID_Sector::Corner_HighX_HighY,
        Ln_XNear_YFar, Ln_XFar_YFar},
    {0, 0, -1, PID_Sector::Wall_X,
        Ln_Y, Ln_Y_NearCenter, Ln_Y_FarCenter, Ln_Y_Near, Ln_Y_Center, Ln_Y_Far,
        PID_Sector::Corner_LowX_LowY, PID_Sector::Corner_LowX_HighY,
        Ln_XNear_YNear, Ln_XNear_YFar}
};


// Are two point/line defs equal?
bool Equal(LnPtDef& D1, LnPtDef& D2)
{return (D1.x == D2.x && D1.y == D2.y && D1.w == D2.w);}

// Do two lines share a point?
bool SharedPoint(LineDef& L1, LineDef& L2, LnPtDef& P)
{
    if(Equal(L1.p0,L2.p0))
    {P = L1.p0; return true;}
    
    if(Equal(L1.p0,L2.p1))
    {P = L1.p0; return true;}
    
    if(Equal(L1.p1,L2.p0))
    {P = L1.p1; return true;}
    
    if(Equal(L1.p1,L2.p1))
    {P = L1.p1; return true;}
    
    return false;
}


// C++ wrapper for Obj-C stuff for each map sector:

class SectorObjects
{
    LEMapPoint *Points[NumPointDefs];
    LELine *Lines[NumLineDefs];
    LEPolygon *Polygons[NumPolygonDefs];
    
    int NumEdges;
    LnPtDef EdgeList[MAXIMUM_VERTICES_PER_POLYGON];
    
    NSMutableString *NTxt;

public:
    SectorObjects();
    ~SectorObjects();
    
    void MakePoint(int i) {if (!Points[i]) {Points[i] = [[LEMapPoint alloc] init];}}
    LEMapPoint *GetPoint(int i) {return Points[i];}
    void RemovePoint(int i) {if (Points[i]) {[Points[i] release]; Points[i] = nil;}}
    
    void MakeLine(int i) {if (!Lines[i]) {Lines[i] = [[LELine alloc] init];}}
    LELine *GetLine(int i) {return Lines[i];}
    void RemoveLine(int i) {if (Lines[i]) {[Lines[i] release]; Lines[i] = nil;}}
   
    void MakePolygon(int i) {if (!Polygons[i]) {Polygons[i] = [[LEPolygon alloc] init];}}
    LEPolygon *GetPolygon(int i) {return Polygons[i];}
    void RemovePolygon(int i) {if (Polygons[i]) {[Polygons[i] release]; Polygons[i] = nil;}}
    
    // This stuff is for the plain polygons only
    void ResetEdges() {NumEdges = 0;}
    bool AddEdge(LnPtDef& Edge);
    int GetNumEdges() {return NumEdges;}
    LnPtDef& GetEdge(int n) {return EdgeList[n];}
    
    NSMutableString *GetNoteText() {return NTxt;}
    void AppendNoteText(NSString *NewText);
};

SectorObjects::SectorObjects()
{
    for (int k=0; k<NumPointDefs; k++) Points[k] = nil;
    for (int k=0; k<NumLineDefs; k++) Lines[k] = nil;
    for (int k=0; k<NumPolygonDefs; k++) Polygons[k] = nil;
    ResetEdges();
    
    NTxt = [[NSMutableString alloc] init];
}

SectorObjects::~SectorObjects()
{
    for (int k=0; k<NumPointDefs; k++) [Points[k] release];
    for (int k=0; k<NumLineDefs; k++) [Lines[k] release];
    for (int k=0; k<NumPolygonDefs; k++) [Polygons[k] release];
    
    [NTxt release];
}

// Offsets and the line type; returns whether it could be added
bool SectorObjects::AddEdge(LnPtDef& Edge)
{
    if (NumEdges >= MAXIMUM_VERTICES_PER_POLYGON) return false;
    
    EdgeList[NumEdges++] = Edge;
    
    return true;
}

void SectorObjects::AppendNoteText(NSString *NewText)
{
    if (NewText)
    {
        // Add spacer in case of multiple additions
        if ([NTxt length] > 0)
            [NTxt appendString:@"_"];
        
        [NTxt appendString:NewText];
    }
}



// Point is at -x,-y corner of sector
// Edge lines are at -y side [x,y - x+1,y] (0) and -x side [x,y - x,y+1] (1) of sector
// Have added "guard region" in case of off-the-edge points and lines
typedef SectorObjects SectorArray[PID_Level::NUMBER_X_SECTORS+1][PID_Level::NUMBER_Y_SECTORS+1]; 


// Add a frame to indicate PID-map boundaries:
static void AddFrame(LELevelData *level)
{
    const int NumFramePoints = 4;
    const short FramePoints[NumFramePoints][2] = {
        {0,0},
        {PID_Level::NUMBER_X_SECTORS, 0},
        {PID_Level::NUMBER_X_SECTORS, PID_Level::NUMBER_Y_SECTORS},
        {0, PID_Level::NUMBER_Y_SECTORS},
    };
    
    LEMapPoint *Pts[NumFramePoints];
    LELine *Lns[NumFramePoints];
    
    for (int k=0; k<NumFramePoints; k++)
    {
        Pts[k] = [[LEMapPoint alloc] init];
        [Pts[k] setX:XPos(FramePoints[k][0],0) Y:YPos(FramePoints[k][1],0)];
        //[Pts[k] setY:YPos(FramePoints[k][1],0)];
        
        [level addPoint:Pts[k]];
        
        Lns[k] = [[LELine alloc] init];
        // Can't do anything more with the lines until we have all the points
    }
     
    for (int k=0; k<NumFramePoints; k++)
    {
        [Lns[k] setMapPoint1:Pts[k] mapPoint2:Pts[(k+1)%NumFramePoints]];
        //[Lns[k] setMapPoint2:Pts[(k+1)%NumFramePoints]];
        
        [level addLine:Lns[k]];
    }
   
    for (int k=0; k<NumFramePoints; k++)
    {
        [Pts[k] release];
        [Lns[k] release];
    }
}


// Adds the textured walls as lines
void AddTexturedWalls(PID_Sector& Sector, SectorObjects& SO)
{
    switch(Sector.WallList[PID_Sector::Wall_Y].Type)
    {
    case PID_Wall::Wall:
    case PID_Wall::Wall_FancyCorners:
        SO.MakeLine(Ln_X);
        break;
        
    case PID_Wall::Wall_ShortLow:
        SO.MakeLine(Ln_X_FarCenter);
        break;
        
    case PID_Wall::Wall_ShortHigh:
        SO.MakeLine(Ln_X_NearCenter);
        break;
        
    case PID_Wall::Wall_ShortBoth:
        SO.MakeLine(Ln_X_Center);
        break;
    }
    
    switch(Sector.WallList[PID_Sector::Wall_X].Type)
    {
    case PID_Wall::Wall:
    case PID_Wall::Wall_FancyCorners:
        SO.MakeLine(Ln_Y);
        break;
        
    case PID_Wall::Wall_ShortLow:
        SO.MakeLine(Ln_Y_FarCenter);
        break;
        
    case PID_Wall::Wall_ShortHigh:
        SO.MakeLine(Ln_Y_NearCenter);
        break;
        
    case PID_Wall::Wall_ShortBoth:
        SO.MakeLine(Ln_Y_Center);
        break;
    }          

    switch(Sector.WallList[PID_Sector::Corner_HighX_LowY].Type)
    {
    case PID_Wall::CutoffCorner:
        SO.MakeLine(Ln_XFar_YNear);
    }
    
    switch(Sector.WallList[PID_Sector::Corner_LowX_LowY].Type)
    {
    case PID_Wall::CutoffCorner:
        SO.MakeLine(Ln_XNear_YNear);
    }
    
    switch(Sector.WallList[PID_Sector::Corner_HighX_HighY].Type)
    {
    case PID_Wall::CutoffCorner:
        SO.MakeLine(Ln_XFar_YFar);
    }
    
    switch(Sector.WallList[PID_Sector::Corner_LowX_HighY].Type)
    {
    case PID_Wall::CutoffCorner:
        SO.MakeLine(Ln_XNear_YFar);
    }
}

static void AddTexturedWalls(PID_Level& PL, SectorArray SO)
{
    for (int x=0; x<PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<PID_Level::NUMBER_Y_SECTORS; y++)
            AddTexturedWalls(PL.SectorList[SectorAddr(x,y)], SO[x][y]);
}


// Adds the sector contents as polygons and line lists
static void AddSectorContents(PID_Level& PL, SectorArray SO)
{
    for (int x=0; x<PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<PID_Level::NUMBER_Y_SECTORS; y++)
        {
            PID_Sector& Sector = PL.SectorList[SectorAddr(x,y)];
            
            if (Sector.Type == PID_Sector::Door)
            {
                int Dir = PL.DoorList[Sector.TypeAddl].Direction;
                switch(Dir)
                {
                case PID_Door::X_Negative:
                case PID_Door::X_Positive:
                    SO[x][y].MakePolygon(Pg_YNear);
                    SO[x][y].MakePolygon(Pg_YDoor);
                    SO[x][y].MakePolygon(Pg_YFar);
                    break;
                    
                case PID_Door::Y_Negative:
                case PID_Door::Y_Positive:
                    SO[x][y].MakePolygon(Pg_XNear);
                    SO[x][y].MakePolygon(Pg_XDoor);
                    SO[x][y].MakePolygon(Pg_XFar);
                    break;
                }
            }
            else if (Sector.Type != PID_Sector::Void)
            {
                // Check all the sides
                for (int s=0; s<NumSideDefs; s++)
                {
                    const SideDef& S = SdDefs[s];
                    int nx = x + S.x;
                    int ny = y + S.y;
                    PID_Sector& NgbrSctr = PL.SectorList[SectorAddr(nx,ny)];
                    
                    // Textured-corner presence
                    bool cpres_lo = (Sector.WallList[S.crnr_lo_src].Type == PID_Wall::CutoffCorner);
                    bool cpres_hi = (Sector.WallList[S.crnr_hi_src].Type == PID_Wall::CutoffCorner);
                    
                    // Create a local stack of linedefs:
                    int NumLines = 0;
                    LnPtDef LineList[4];
                    
                    // Since the corners will trail the sides, reverse-direction means adding them first
                    if (S.dir < 0 && cpres_lo)
                    {
                        LnPtDef& L = LineList[NumLines++];
                        L.x = 0; L.y = 0; L.w = S.crnr_lo_dst;
                   }
                   
                    // Shorten the wall if there is a textured corner:
                    short WallType = NgbrSctr.WallList[S.wall].Type;
                    if (cpres_lo)
                    {
                        switch(WallType)
                        {
                        case PID_Wall::Wall_ShortBoth:
                        case PID_Wall::Wall_ShortLow:
                            break;	// OK
                        
                        case PID_Wall::Wall_ShortHigh:
                            WallType = PID_Wall::Wall_ShortBoth;
                            break;
                        
                        default:
                            WallType = PID_Wall::Wall_ShortLow;
                            break;
                        }
                    }
                    if (cpres_hi)
                    {
                        switch(WallType)
                        {
                        case PID_Wall::Wall_ShortBoth:
                        case PID_Wall::Wall_ShortHigh:
                            break;	// OK
                        
                        case PID_Wall::Wall_ShortLow:
                            WallType = PID_Wall::Wall_ShortBoth;
                            break;
                        
                        default:
                            WallType = PID_Wall::Wall_ShortHigh;
                            break;
                        }
                    }
                    
                    // Extend the sector edges if necessary - if there are no textured corners present
                    switch(WallType)
                    {
                    case PID_Wall::Wall_ShortBoth:
                        if (!cpres_lo)
                        {
                            LnPtDef& L = LineList[NumLines++];
                            L.x = S.x; L.y = S.y; L.w = S.lo;
                        }
                        {
                            LnPtDef& L = LineList[NumLines++];
                            L.x = S.x; L.y = S.y; L.w = S.mid;
                        }
                        if (!cpres_hi)
                        {
                            LnPtDef& L = LineList[NumLines++];
                            L.x = S.x; L.y = S.y; L.w = S.hi;
                        }
                        break;
                        
                    case PID_Wall::Wall_ShortHigh:
                        {
                            LnPtDef& L = LineList[NumLines++];
                            L.x = S.x; L.y = S.y; L.w = S.lomid;
                        }
                        if (!cpres_hi)
                        {
                            LnPtDef& L = LineList[NumLines++];
                            L.x = S.x; L.y = S.y; L.w = S.hi;
                        }
                        break;
                    
                    case PID_Wall::Wall_ShortLow:
                        if (!cpres_lo)
                        {
                            LnPtDef& L = LineList[NumLines++];
                            L.x = S.x; L.y = S.y; L.w = S.lo;
                        }
                        {
                            LnPtDef& L = LineList[NumLines++];
                            L.x = S.x; L.y = S.y; L.w = S.midhi;
                        }
                        break;
                    
                    default:
                        {
                            LnPtDef& L = LineList[NumLines++];
                            L.x = S.x; L.y = S.y; L.w = S.full;
                        }
                        break;
                    }
                    
                    // Corner trailing the side in the forward direction
                    if (S.dir >= 0 && cpres_hi)
                    {
                        LnPtDef& L = LineList[NumLines++];
                        L.x = 0; L.y = 0; L.w = S.crnr_hi_dst;
                    }
                    
                    // Load!
                    if (S.dir >= 0)
                    {
                        for (int n=0; n<NumLines; n++)
                            if (!SO[x][y].AddEdge(LineList[n]))
                                NSLog(@"*** Too many edges at sector %d,%d",x,y);
                    }
                    else
                    {
                        for (int n=NumLines-1; n>=0; n--)
                            if (!SO[x][y].AddEdge(LineList[n]))
                                NSLog(@"*** Too many edges at sector %d,%d",x,y);
                    }
                }
                
                // Add the central polygon!
                SO[x][y].MakePolygon(Pg_Plain);
                
                // Look for bevels in neighboring sectors; add bevel polygons as necessary
                for (int b=0; b<NumBevelDefs; b++)
                {
                    const BevelDef& B = BvDefs[b];
                    if (Sector.WallList[B.c].Type == PID_Wall::None)
                    {
                        int nx = x+B.x;
                        int ny = y+B.y;
                        PID_Sector& NgbrSctr = PL.SectorList[SectorAddr(nx,ny)];
                        if (NgbrSctr.Type == PID_Sector::Void)
                        {
                            if (NgbrSctr.WallList[B.nc].Type == PID_Wall::CutoffCorner)
                                SO[nx][ny].MakePolygon(B.p);
                        }
                    }
                }
            }
        }
}


// Adds the remaining geometry (points, lines, polygons)
static void AddGeometry(PID_Level& PL, SectorArray SO, LELevelData *level)
{
    // Create the lines from the polygons
    for (int x=0; x<=PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<PID_Level::NUMBER_Y_SECTORS; y++)
            for (int k=0; k<NumPolygonDefs; k++)
            {
                LEPolygon *Pg = SO[x][y].GetPolygon(k);
                if (Pg)
                {
                    if (k == Pg_Plain)
                    {
                        int NumEdges = SO[x][y].GetNumEdges();
                                                
                        for (int n=0; n<NumEdges; n++)
                        {
                            LnPtDef& L = SO[x][y].GetEdge(n);
                            SO[x+L.x][y+L.y].MakeLine(L.w);
                        }
                    }
                    else
                    {
                       const PolygonDef &D = PgDefs[k];
                       
                       for (int n=0; n<D.N; n++)
                       {
                            const LnPtDef& L = D.Lns[n];
                            SO[x+L.x][y+L.y].MakeLine(L.w);
                       }
                    }
                }
            }
   
    // Create the points from the lines
    for (int x=0; x<=PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<PID_Level::NUMBER_Y_SECTORS; y++)
            for (int k=0; k<NumLineDefs; k++)
            {
                LELine *Ln = SO[x][y].GetLine(k);
                if (Ln)
                {
                    const LineDef& L = LnDefs[k];
                    const LnPtDef& P0 = L.p0;
                    const LnPtDef& P1 = L.p1;
                    SO[x+P0.x][y+P0.y].MakePoint(P0.w);
                    SO[x+P1.x][y+P1.y].MakePoint(P1.w);
                }
            }
    
    // Set up the points
    for (int x=0; x<=PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<=PID_Level::NUMBER_Y_SECTORS; y++)
            for (int k=0; k<NumPointDefs; k++)
            {
                LEMapPoint *Pt = SO[x][y].GetPoint(k);
                if (Pt)
                {
                    const PointDef& P = PtDefs[k];
                    [Pt setX:XPos(x,P.wx) Y:YPos(y,P.wy)];
                    //[Pt setY:YPos(y,P.wy)];
                    
                    [level addPoint:Pt];
                }
            }
   
    // Set up the lines (needs the points)
    for (int x=0; x<=PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<=PID_Level::NUMBER_Y_SECTORS; y++)
            for (int k=0; k<NumLineDefs; k++)
            {
                LELine *Ln = SO[x][y].GetLine(k);
                if (Ln)
                {
                    const LineDef& L = LnDefs[k];
                    const LnPtDef& P0 = L.p0;
                    const LnPtDef& P1 = L.p1;
                    LEMapPoint *Pt0 = SO[x+P0.x][y+P0.y].GetPoint(P0.w);
                    LEMapPoint *Pt1 = SO[x+P1.x][y+P1.y].GetPoint(P1.w);
                    
                    [Ln setMapPoint1:Pt0 mapPoint2:Pt1];
                    //[Ln setMapPoint2:Pt1];
                    
                    [level addLine:Ln];
                }
            }
    
    // Set up the polygons (needs the points and lines)
    for (int x=0; x<=PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<=PID_Level::NUMBER_Y_SECTORS; y++)
            for (int k=0; k<NumPolygonDefs; k++)
            {
                LEPolygon *Pg = SO[x][y].GetPolygon(k);
                if (Pg)
                {
                    [level setUpArrayPointersFor:Pg];
                    
                    if (k == Pg_Plain)
                    {
                        int NumEdges = SO[x][y].GetNumEdges();
                        
                        [Pg setVertextCount:NumEdges];
                        
                        for (int n=0; n<NumEdges; n++)
                        {
                            int np = n > 0 ? n-1 : NumEdges-1;
                            
                            LnPtDef& D0 = SO[x][y].GetEdge(np);
                            LineDef L0 = LnDefs[D0.w];
                            L0.p0.x += D0.x;
                            L0.p0.y += D0.y;
                            L0.p1.x += D0.x;
                            L0.p1.y += D0.y;
                            
                            LnPtDef& D1 = SO[x][y].GetEdge(n);
                            LineDef L1 = LnDefs[D1.w];
                            L1.p0.x += D1.x;
                            L1.p0.y += D1.y;
                            L1.p1.x += D1.x;
                            L1.p1.y += D1.y;
                            
                            LnPtDef P;
                            if (!SharedPoint(L0,L1,P))
                                {NSLog(@"*** Broken Chain at %d,%d %d",x,y,n); continue;}
                            
                            LEMapPoint *Pt = SO[x+P.x][y+P.y].GetPoint(P.w);
                            [Pg setVertexWithObject:Pt i:n];
                         }
                        
                        for (int n=0; n<NumEdges; n++)
                        {
                            LnPtDef& L = SO[x][y].GetEdge(n);
                            LELine *Ln = SO[x+L.x][y+L.y].GetLine(L.w);
                            [Pg setLinesObject:Ln i:n];
                        }
                    }
                    else
                    {
                       const PolygonDef &D = PgDefs[k];
                       
                       [Pg setVertextCount:D.N];
                       
                       for (int n=0; n<D.N; n++)
                       {
                            const LnPtDef& P = D.Pts[n];
                            LEMapPoint *Pt = SO[x+P.x][y+P.y].GetPoint(P.w);
                            [Pg setVertexWithObject:Pt i:n];
                            
                            const LnPtDef& L = D.Lns[n];
                            LELine *Ln = SO[x+L.x][y+L.y].GetLine(L.w);
                            [Pg setLinesObject:Ln i:n];
                       }
                    }
                    
                    // Do this here because it's necessary for side setting
                    const short Ht_Floor = 0;
                    const short Ht_Ceiling = 1024;
                    [Pg setFloor_height:Ht_Floor];
                    [Pg setCeiling_height:Ht_Ceiling];
                    
                    [level addPolygon:Pg];
                    if (k == 0)
                        [level namePolygon:Pg to:[NSString stringWithFormat:@"PID %d %d",x,y,nil]];
                }
            }
}


// For adding all the doors -- they are Marathon-engine platforms

const PhPlatformStaticFlags PlainDoorFlags =
    _platform_uses_native_polygon_heights |
    _platform_comes_from_ceiling |
    _platform_is_player_controllable |
    _platform_is_door |
    // Below Three Added By JDO
    _platform_deactivates_at_each_level |
    _platform_activates_only_once |
    _platform_is_initially_extended;

const PhPlatformStaticFlags SecretDoorFlags =
    _platform_uses_native_polygon_heights |
    _platform_comes_from_ceiling |
    _platform_is_player_controllable |
    _platform_is_door |
    _platform_is_secret |
    // Below Three Added By JDO
    _platform_deactivates_at_each_level |
    _platform_activates_only_once |
    _platform_is_initially_extended;

// A single one of them
static void AddDoor(PhPlatformStaticFlags DoorFlags, LEPolygon *Pg, LELevelData *level)
{
    PhPlatform *Platform =[level addObjectWithDefaults:[PhPlatform class]];
    [Platform setStaticFlags:DoorFlags];
    [Pg setType:_polygon_is_platform];
    [Pg setPermutationObject:Platform];
}

// All of them
static void AddDoors(PID_Level& PL, SectorArray SO, LELevelData *level)
{
    for (int x=0; x<=PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<=PID_Level::NUMBER_Y_SECTORS; y++)
            for (int k=0; k<NumPolygonDefs; k++)
            {
                LEPolygon *Pg = SO[x][y].GetPolygon(k);
                if (Pg)
                {
                    if (k == Pg_XDoor || k == Pg_YDoor)
                    {
                        AddDoor(PlainDoorFlags,Pg,level);
                    }
                    else if (k == Pg_Plain)
                    {
                        PID_Sector& Sector = PL.SectorList[SectorAddr(x,y)];
                        
                        if (Sector.Type == PID_Sector::SecretDoor)
                        {
                            AddDoor(SecretDoorFlags,Pg,level);
                        }
                    }
                }
            }
}


// Calculates and adds all the side info; needs geometry and platforms
static void AddSides(SectorArray SO)
{
    // Polygon floor and ceiling textures
    for (int x=0; x<=PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<=PID_Level::NUMBER_Y_SECTORS; y++)
            for (int k=0; k<NumPolygonDefs; k++)
            {
                LEPolygon *Pg = SO[x][y].GetPolygon(k);
                if (Pg) [Pg calculateSidesForAllLines];
            }
}


// Conversion Parameters:

// Wall Textures

const int NumTextureSets = 3;
enum {
    Tx_Collection,
    Tx_Floor,
    Tx_Ceiling,
    Tx_Wall,
    Tx_FancyWall,
    Tx_BevelWall,
    Tx_DoorFloor,
    Tx_DoorCeiling,
    Tx_DoorWall,
    Tx_Door,
    Tx_Teleport,
    Tx_HOW_MANY
};

static unsigned short Txtrs[NumTextureSets][Tx_HOW_MANY];

// Lights

enum {
    Lt_Normal,
    Lt_Teleport,
    Lt_HOW_MANY
};

static unsigned short Lights[Lt_HOW_MANY];

// Texture Transfer Modes
// uses index of transfer types in PhDefs.h :
// _xfer_normal = 0
// _xfer_pulsate = 4
// etc.

enum {
    Xf_Normal,
    Xf_Teleport,
    Xf_HOW_MANY
};

static unsigned short Xfers[Xf_HOW_MANY];


// No error checking -- could not get NSAssert(Number, ...) etc. to compile

static unsigned short GetUnsignedShort(NSDictionary *Dict, NSString *NumMem)
{
    NSNumber *Number = (NSNumber *)[Dict objectForKey:NumMem];
    return [Number unsignedShortValue];
}


static void GetConversionParameters()
{
    NSBundle *AppBundle = [NSBundle mainBundle];
    
    NSDictionary *ConvParamsDict = (NSDictionary *)[AppBundle objectForInfoDictionaryKey:@"PfhPathwaysConvert"];
    
    NSArray *WallTxtrArray = (NSArray *)[ConvParamsDict objectForKey:@"WallTextures"];
    
    for (int i=0; i<NumTextureSets; i++)
    {
        NSDictionary *WallTxtrDict = (NSDictionary *)[WallTxtrArray objectAtIndex:i];
        
        Txtrs[i][Tx_Collection] = GetUnsignedShort(WallTxtrDict,@"Collection");
        
        Txtrs[i][Tx_Floor] = GetUnsignedShort(WallTxtrDict,@"Floor");
        Txtrs[i][Tx_Ceiling] = GetUnsignedShort(WallTxtrDict,@"Ceiling");
        Txtrs[i][Tx_Wall] = GetUnsignedShort(WallTxtrDict,@"Wall");
        
        Txtrs[i][Tx_FancyWall] = GetUnsignedShort(WallTxtrDict,@"FancyWall");
        Txtrs[i][Tx_BevelWall] = GetUnsignedShort(WallTxtrDict,@"BevelWall");
        
        Txtrs[i][Tx_DoorFloor] = GetUnsignedShort(WallTxtrDict,@"DoorFloor");
        Txtrs[i][Tx_DoorCeiling] = GetUnsignedShort(WallTxtrDict,@"DoorCeiling");
        Txtrs[i][Tx_DoorWall] = GetUnsignedShort(WallTxtrDict,@"DoorWall");
        Txtrs[i][Tx_Door] = GetUnsignedShort(WallTxtrDict,@"Door");
        
        Txtrs[i][Tx_Teleport] = GetUnsignedShort(WallTxtrDict,@"Teleport");
   }
   
   NSDictionary *LightsDict = (NSDictionary *)[ConvParamsDict objectForKey:@"Lights"];
   
   Lights[Lt_Normal] = GetUnsignedShort(LightsDict,@"Normal");
   Lights[Lt_Teleport] = GetUnsignedShort(LightsDict,@"Teleport");
   
   NSDictionary *XfersDict = (NSDictionary *)[ConvParamsDict objectForKey:@"Transfers"];
   
   Xfers[Xf_Normal] = GetUnsignedShort(XfersDict,@"Normal");
   Xfers[Xf_Teleport] = GetUnsignedShort(XfersDict,@"Teleport");
}

// The position is in PID units (top left is 0,0, and bottom right is (1,1) * 32*1024)
static void AddNote(LELevelData *level, SectorArray SO, short x, short y, NSString *Text, PhNoteGroup *NoteGroup)
{
    short xred = x >>  PID_WorldUnitBits;
    short yred = y >>  PID_WorldUnitBits;
    short xloc = x - WORLD_ONE*PID_Level::NUMBER_X_SECTORS/2;
    short yloc = y - WORLD_ONE*PID_Level::NUMBER_Y_SECTORS/2;
    LEPolygon *Pg = SO[xred][yred].GetPolygon(Pg_Plain);
    if (Pg && ([Text length] > 0))
    {
        PhAnnotationNote *Note = [level addObjectWithDefaults:[PhAnnotationNote class]];
        
        [Note setLocationX:xloc];
        [Note setLocationY:yloc];
        [Note setText:Text];
        [Note setPolygonObject:Pg];
        [NoteGroup addObject:Note];
    }
}


LELevelData *PathwaysToMarathon(PID_Level& PL, PID_LevelState& PLS)
{
    // Contains all the points, lines, and polygons at appropriate map positions
    SectorArray SO;
    
    NSLog(@"--- Number of Monsters and Pickups: %d %d",PLS.NumMonsters,PLS.NumAssigns);
    
    // Load the conversion parameters
    GetConversionParameters();
    
    // Get started with the level
    LELevelData *level = [[LELevelData alloc] initForNewPathwaysPIDLevel];
    
    // Create note types
    PhNoteGroup *NG_SectorAttribs = [level newNoteType:@"Sector Attributes"];
    [NG_SectorAttribs setColor:[NSColor lightGrayColor]];
    PhNoteGroup *NG_Pickups = [level newNoteType:@"Pickups"];
    [NG_Pickups setColor:[NSColor cyanColor]];
    PhNoteGroup *NG_Monsters = [level newNoteType:@"Monsters"];
    [NG_Monsters setColor:[NSColor magentaColor]];
    PhNoteGroup *NG_Scenery = [level newNoteType:@"Scenery"];
    [NG_Scenery setColor:[NSColor yellowColor]];
    
    // Assign environment code using which wall-texture type:
    // (plain->water, vine->lava, crystal->sewage)
    short Env = (PL.TextureList[0] & 0x0fff) - 64;
    if (Env < 0 || Env > NumTextureSets) Env = 0;	// Idiot-Proofing
    
    [level setLevelName:GetLevelName(PL)];
    [level setEnvironmentCode:Txtrs[Env][Tx_Collection]];
    [level setEnvironmentSinglePlayer:YES];
    [level setGameTypeSinglePlayer:YES];
    
    // To indicate where the boundaries of the PID level had been
    AddFrame(level);
    
    // Adds the textured walls as lines
    // AddTexturedWalls(PL,SO);
    
    // Adds the sector contents as polygons and line lists
    AddSectorContents(PL,SO);
    
    // Adds the remaining geometry (points, lines, polygons)
    AddGeometry(PL,SO,level);
    
    // Adds all the doors as platforms
    AddDoors(PL,SO,level);
    
    // Calculates and adds all the side info; needs geometry and platforms
    AddSides(SO);
    
    // Add textures and notes for polygons
    for (int x=0; x<=PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<=PID_Level::NUMBER_Y_SECTORS; y++)
            for (int k=0; k<NumPolygonDefs; k++)
            {
                LEPolygon *Pg = SO[x][y].GetPolygon(k);
                if (Pg)
                {
                    // Defaults: no note, plain floor and ceiling textures
                    NSString *NTxt = nil;
                    short WhichFloor = Tx_Floor;
                    short WhichFloorLight = Lt_Normal;
                    short WhichFloorXfer = Xf_Normal;
                    short WhichCeiling = Tx_Ceiling;
                    short WhichCeilingLight = Lt_Normal;
                    short WhichCeilingXfer = Xf_Normal;
                    
                    if (k == Pg_XDoor || k == Pg_YDoor)
                    {
                        WhichFloor = Tx_DoorFloor;
                        WhichCeiling = Tx_DoorCeiling;
                    }
                    else if (k == Pg_Plain)
                    {
                        PID_Sector& Sector = PL.SectorList[SectorAddr(x,y)];
                        
                        switch(Sector.Type)
                        {
                        case PID_Sector::ChangeLevel:
                            {
                                PID_LevelChange& LvCh = PL.LevelChangeList[Sector.TypeAddl];
                                if (LvCh.Level == PL.LevelNumber)
                                {
                                    [Pg setType:_polygon_is_teleporter];
                                    [Pg setPermutationObject:SO[LvCh.x][LvCh.y].GetPolygon(Pg_Plain)];
                                    WhichFloor = Tx_Teleport;
                                    WhichFloorLight = Lt_Teleport;
                                    WhichFloorXfer = Xf_Teleport;
                                    WhichCeiling = Tx_Teleport;
                                    WhichCeilingLight = Lt_Teleport;
                                    WhichCeilingXfer = Xf_Teleport;
                                }
                                else
                                    NTxt = [NSString stringWithFormat:@"Lv%hd,%hd,%hd",LvCh.Level,LvCh.x,LvCh.y,nil];
                            }
                            break;
                        
                        case PID_Sector::DoorTrigger:
                            NTxt = [NSString stringWithFormat:@"DT%hd",short(Sector.TypeAddl),nil];
                            break;
                        
                        case PID_Sector::SecretDoor:
                            NTxt = [NSString stringWithFormat:@"SD%hd",short(Sector.TypeAddl),nil];
                            break;
                        
                        case PID_Sector::Corpse:
                            NTxt = [NSString stringWithFormat:@"Cp%hd",short(Sector.TypeAddl),nil];
                            break;
                        
                        case PID_Sector::Pillar:
                            NTxt = [NSString stringWithFormat:@"Pr%hd",short(Sector.TypeAddl),nil];
                            break;
                        
                        case PID_Sector::OtherTrigger:
                            NTxt = [NSString stringWithFormat:@"OT",nil];
                            break;
                        
                        case PID_Sector::Save:
                            NTxt = [NSString stringWithFormat:@"Sv",nil];
                            break;
                        }
                    }
                    
                    short xext = XPos(x,2) + WORLD_ONE*PID_Level::NUMBER_X_SECTORS/2;
                    short yext = YPos(y,2) + WORLD_ONE*PID_Level::NUMBER_Y_SECTORS/2;
                    AddNote(level, SO, xext, yext, NTxt, NG_SectorAttribs);
                    
                    // Use level's texture collection
                    [Pg resetTextureCollectionOnly];
                    [Pg setFloorTextureOnly:Txtrs[Env][WhichFloor]];
                    [Pg setFloor_lightsource:Lights[WhichFloorLight]];
                    [Pg setFloor_transfer_mode:Xfers[WhichFloorXfer]];
                    [Pg setCeilingTextureOnly:Txtrs[Env][WhichCeiling]];
                    [Pg setCeiling_lightsource:Lights[WhichCeilingLight]];
                    [Pg setCeiling_transfer_mode:Xfers[WhichCeilingXfer]];
                }
            }
    
    // Add the pickups and monsters as notes
    
    bool WasCounted[PID_LevelState::MAXIMUM_NUMBER_OF_ITEMS];
    memset(WasCounted,0,PID_LevelState::MAXIMUM_NUMBER_OF_ITEMS*sizeof(bool));
    
    for (int n=0; n<PLS.NumAssigns; n++)
    {
        PID_PickupAssign& Assign = PLS.AssignList[n];
        PID_PlayerItem& Pickup = PLS.PickupList[Assign.PickupID];
        PID_ItemState& Item = PLS.Items[Assign.ItemID];
        WasCounted[Assign.ItemID] = true;
        short Coll = (Item.Texture >> 7) & 0xff;
        short Frame = (Item.Texture) & 0x7f;
        NSString *NTxt = [NSString stringWithFormat:@"P%d,%d,%d_%d,%d,%x",
            Pickup.Type,Pickup.Quantity,Pickup.ContainedItem,
            Coll,Frame,Item.Flags,nil];
        AddNote(level, SO, Item.Pos.x, Item.Pos.y, NTxt, NG_Pickups);
    }
    
    for (int n=0; n<PLS.NumMonsters; n++)
    {
        PID_MonsterState& Monster = PLS.MonsterList[n];
        PID_ItemState& Item = PLS.Items[Monster.ItemID];
        WasCounted[Monster.ItemID] = true;
        short Coll = (Item.Texture >> 7) & 0xff;
        short Frame = (Item.Texture) & 0x7f;
        NSString *NTxt = [NSString stringWithFormat:@"M%d_%d,%d,%x",
            Monster.Type,
            Coll,Frame,Item.Flags,nil];
        AddNote(level, SO, Item.Pos.x, Item.Pos.y, NTxt, NG_Monsters);
    }
    
    for (int n=0; n<PID_LevelState::MAXIMUM_NUMBER_OF_ITEMS; n++)
    {
        if (WasCounted[n]) continue;
        PID_ItemState& Item = PLS.Items[n];
        if (Item.Pos.x <= 0 || Item.Pos.y <= 0) continue;
        short Coll = (Item.Texture >> 7) & 0xff;
        short Frame = (Item.Texture) & 0x7f;
        NSString *NTxt = [NSString stringWithFormat:@"S%d,%d,%x",
            Coll,Frame,Item.Flags,nil];
        AddNote(level, SO, Item.Pos.x, Item.Pos.y, NTxt, NG_Scenery);
    }
    
    // Texture the sides; need to know which polygons are teleporters
    // in order to give their sides the teleporter textures
    for (int x=0; x<=PID_Level::NUMBER_X_SECTORS; x++)
        for (int y=0; y<=PID_Level::NUMBER_Y_SECTORS; y++)
            for (int k=0; k<NumLineDefs; k++)
            {
                LELine *Ln = SO[x][y].GetLine(k);
                if (Ln)
                {
                    for (int w=0; w<2; w++)
                    {
                        LESide *Sd = w > 0 ?
                            [Ln getClockwisePolygonSideObject] :
                            [Ln getCounterclockwisePolygonSideObject];
                        if (Sd)
                        {
                            // Use level's texture collection
                            [Sd resetTextureCollection];
                            
                            short Which = Tx_Wall;
                            short WhichLight = Lt_Normal;
                            short WhichXfer = Xf_Normal;
                            switch(k)
                            {
                            case Ln_X:
                                if (PL.SectorList[SectorAddr(x,y)].WallList[PID_Sector::Wall_Y].Type ==
                                    PID_Wall::Wall_FancyCorners)
                                        Which = Tx_FancyWall;
                                break;
                                
                            case Ln_Y:
                                break;
                                if (PL.SectorList[SectorAddr(x,y)].WallList[PID_Sector::Wall_X].Type ==
                                    PID_Wall::Wall_FancyCorners)
                                        Which = Tx_FancyWall;
                                 
                            case Ln_XNear_YNear:
                            case Ln_XFar_YNear:
                            case Ln_XNear_YFar:
                            case Ln_XFar_YFar:
                                Which = Tx_BevelWall;
                                break;
                                
                            case Ln_X_Center:
                                if (SO[x][y].GetPolygon(Pg_XDoor) || SO[x][y-1].GetPolygon(Pg_XDoor))
                                    Which = Tx_DoorWall;
                                break;
                                
                            case Ln_Y_Center:
                                if (SO[x][y].GetPolygon(Pg_YDoor) || SO[x-1][y].GetPolygon(Pg_YDoor))
                                    Which = Tx_DoorWall;
                                break;
                            
                            case Ln_X_NearDoor:
                            case Ln_X_FarDoor:
                            case Ln_Y_NearDoor:
                            case Ln_Y_FarDoor:
                                Which = Tx_Door;
                                break;
                            }
                            
                            LEPolygon *Pg = (LEPolygon *)[Sd getpolygon_object];
                            if (Pg)
                            {
                                if ([Pg getType] == _polygon_is_teleporter)
                                {
                                    Which = Tx_Teleport;
                                    WhichLight = Lt_Teleport;
                                    WhichXfer = Xf_Teleport;
                                }
                            }
                            
                            [Sd setPrimaryTexture:Txtrs[Env][Which]];
                            [Sd setPrimary_lightsource_index:Lights[WhichLight]];
                            [Sd setPrimary_transfer_mode:Xfers[WhichXfer]];
                       }                        
                    }
                }
            }

    // Add a player start position:
    LEMapObject *Player =[level addObjectWithDefaults:[LEMapObject class]];
    
    short x = PL.Start.x;
    short y = PL.Start.y;
    short xp = x >> PID_WorldUnitBits;
    short yp = y >> PID_WorldUnitBits;
    short xl = x - WORLD_ONE*PID_Level::NUMBER_X_SECTORS/2;
    short yl = y - WORLD_ONE*PID_Level::NUMBER_Y_SECTORS/2;
    [Player setX:xl];
    [Player setY:yl];
    [Player setZ:0];
    [Player setType:_saved_player];
    [Player setIndex:0];
    [Player setFacing:0];
    [Player setPolygonObject:SO[xp][yp].GetPolygon(Pg_Plain)];
    
    return level;
}
