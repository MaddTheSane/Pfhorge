//
//  PhTypesStructresEnums.h
//  Pfhorge
//
//  Created by Joshua D. Orr on Sun Jun 10 2001.
//  Copyright (c) 2001 Joshua D. Orr. All rights reserved.
//  
//  E-Mail:   dragons@xmission.com
//  
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//  or you can read it by running the program and selecting Phorge->About Phorge

#include <stdint.h>

typedef unsigned short word;

typedef unsigned char byte;
typedef byte boolean;

typedef short angle; // 0-512
typedef short world_distance;

typedef uint32_t WadDataType;
typedef short shape_descriptor;

typedef int32_t fixed;

#define TICKS_PER_SECOND 60
#define WORLD_ONE 1024


typedef int16_t int16;
typedef int32_t int32;
//typedef uint32_t uint32;
typedef uint16_t uint16;
