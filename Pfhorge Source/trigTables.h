//
//  trigTables.h
//  Pfhorge
//
//  Created by Joe Auricchio on Sun Jul 27 2003.
//  Copyright (c) 2003 Joe Auricchio. All rights reserved.
//
//  E-Mail:   Joe Auricchio <avarame@ml1.net>
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

/*
 * These are functions to rapidly access precompiled trig tables (sin, tan, etc).
 * I'll gladly trade off a few K of memory for the hideous compute time of the
 * (accurate but slow) built-in sin() function.
 * I'll also trade off a few K of binary size for waiting for 1080 trig computations
 * during program launch.
 */ 

/** Sine, integer degrees 0-360 **/
double PhSin(int a);

/** Cosine, integer degrees 0-360 **/
double PhCos(int a);

/** Tangent, integer degrees 0-360 **/
double PhTan(int a);