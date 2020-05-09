// Marathon-map data-structure formats

#pragma once

typedef unsigned short word;
typedef unsigned char byte;
typedef byte boolean;

/* ---------- fixed math */

//! This is to get around "fixed" being in namespace "std"
typedef int _fixed;

typedef short angle; /* 0-512 */
typedef short world_distance;


// Must get this down
const int NONE = -1;


//! This is a plain PNTS point
typedef struct world_point2d
{
   world_distance x, y;
} world_point2d;

typedef struct world_point3d
{
   world_distance x, y, z;
} world_point3d;


enum /* transfer modes (for sides and polygons) */
{
   tNormal,
   tFadeToBlack,
   tInvisible,
   tSubInvisible,
   tPulsate, /*!< polygons only */
   tWobble, /*!< polygons only */
   tFastWobble, /*!< polygons only */
   tStatic,
   tSubStatic,
   tLandscape,
   tSmear, /*!< flat shading */
   tFadeOutStatic,
   tPulsateStatic,
   tFoldIn,
   tFoldOut,
   tHorizSlide,
   tFastHorizSlide,
   tVertSlide,
   tFastVertSlide,
   tWander,
   tFastWander
};
