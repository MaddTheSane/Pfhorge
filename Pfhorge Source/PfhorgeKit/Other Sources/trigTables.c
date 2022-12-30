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

// Functions to quickly access prebuilt trigonometric tables

#include "trigTables.h"
 
// Functions appear below data tables.

/**************** The Data ****************/
#pragma mark -
#pragma mark **************** The Data ****************


/** Sine, integer degrees 0-360 **/
static const double SINETABLE[361] =
{
    0.000000, 0.017452, 0.034899, 0.052336, 0.069756, 0.087156, 0.104528, 0.121869, 0.139173, 0.156434, 0.173648, 0.190809, 0.207912, 0.224951, 0.241922, 0.258819, 0.275637, 0.292372, 0.309017, 0.325568, 0.342020, 0.358368, 0.374607, 0.390731, 0.406737, 0.422618, 0.438371, 0.453990, 0.469472, 0.484810, 0.500000, 0.515038, 0.529919, 0.544639, 0.559193, 0.573576, 0.587785, 0.601815, 0.615661, 0.629320, 0.642788, 0.656059, 0.669131, 0.681998, 0.694658, 0.707107, 0.719340, 0.731354, 0.743145, 0.754710, 0.766044, 0.777146, 0.788011, 0.798636, 0.809017, 0.819152, 0.829038, 0.838671, 0.848048, 0.857167, 0.866025, 0.874620, 0.882948, 0.891007, 0.898794, 0.906308, 0.913545, 0.920505, 0.927184, 0.933580, 0.939693, 0.945519, 0.951057, 0.956305, 0.961262, 0.965926, 0.970296, 0.974370, 0.978148, 0.981627, 0.984808, 0.987688, 0.990268, 0.992546, 0.994522, 0.996195, 0.997564, 0.998630, 0.999391, 0.999848, 1.000000, 0.999848, 0.999391, 0.998630, 0.997564, 0.996195, 0.994522, 0.992546, 0.990268, 0.987688, 0.984808, 0.981627, 0.978148, 0.974370, 0.970296, 0.965926, 0.961262, 0.956305, 0.951057, 0.945519, 0.939693, 0.933580, 0.927184, 0.920505, 0.913545, 0.906308, 0.898794, 0.891007, 0.882948, 0.874620, 0.866025, 0.857167, 0.848048, 0.838671, 0.829038, 0.819152, 0.809017, 0.798636, 0.788011, 0.777146, 0.766044, 0.754710, 0.743145, 0.731354, 0.719340, 0.707107, 0.694658, 0.681998, 0.669131, 0.656059, 0.642788, 0.629320, 0.615661, 0.601815, 0.587785, 0.573576, 0.559193, 0.544639, 0.529919, 0.515038, 0.500000, 0.484810, 0.469472, 0.453990, 0.438371, 0.422618, 0.406737, 0.390731, 0.374607, 0.358368, 0.342020, 0.325568, 0.309017, 0.292372, 0.275637, 0.258819, 0.241922, 0.224951, 0.207912, 0.190809, 0.173648, 0.156434, 0.139173, 0.121869, 0.104528, 0.087156, 0.069756, 0.052336, 0.034899, 0.017452, -0.000000, -0.017452, -0.034899, -0.052336, -0.069756, -0.087156, -0.104528, -0.121869, -0.139173, -0.156434, -0.173648, -0.190809, -0.207912, -0.224951, -0.241922, -0.258819, -0.275637, -0.292372, -0.309017, -0.325568, -0.342020, -0.358368, -0.374607, -0.390731, -0.406737, -0.422618, -0.438371, -0.453991, -0.469472, -0.484810, -0.500000, -0.515038, -0.529919, -0.544639, -0.559193, -0.573576, -0.587785, -0.601815, -0.615661, -0.629320, -0.642788, -0.656059, -0.669131, -0.681998, -0.694658, -0.707107, -0.719340, -0.731354, -0.743145, -0.754710, -0.766044, -0.777146, -0.788011, -0.798636, -0.809017, -0.819152, -0.829038, -0.838671, -0.848048, -0.857167, -0.866025, -0.874620, -0.882948, -0.891007, -0.898794, -0.906308, -0.913545, -0.920505, -0.927184, -0.933580, -0.939693, -0.945519, -0.951057, -0.956305, -0.961262, -0.965926, -0.970296, -0.974370, -0.978148, -0.981627, -0.984808, -0.987688, -0.990268, -0.992546, -0.994522, -0.996195, -0.997564, -0.998630, -0.999391, -0.999848, -1.000000, -0.999848, -0.999391, -0.998630, -0.997564, -0.996195, -0.994522, -0.992546, -0.990268, -0.987688, -0.984808, -0.981627, -0.978148, -0.974370, -0.970296, -0.965926, -0.961262, -0.956305, -0.951057, -0.945519, -0.939693, -0.933580, -0.927184, -0.920505, -0.913545, -0.906308, -0.898794, -0.891007, -0.882948, -0.874620, -0.866025, -0.857167, -0.848048, -0.838671, -0.829038, -0.819152, -0.809017, -0.798636, -0.788011, -0.777146, -0.766044, -0.754710, -0.743145, -0.731354, -0.719340, -0.707107, -0.694658, -0.681998, -0.669131, -0.656059, -0.642788, -0.629320, -0.615661, -0.601815, -0.587785, -0.573576, -0.559193, -0.544639, -0.529919, -0.515038, -0.500000, -0.484810, -0.469472, -0.453990, -0.438371, -0.422618, -0.406737, -0.390731, -0.374607, -0.358368, -0.342020, -0.325568, -0.309017, -0.292372, -0.275637, -0.258819, -0.241922, -0.224951, -0.207912, -0.190809, -0.173648, -0.156434, -0.139173, -0.121869, -0.104528, -0.087156, -0.069756, -0.052336, -0.034899, -0.017452, 0.000000
};

/** Cosine, integer degrees 0-360 **/
static const double COSTABLE[361] =
{
    1.000000, 0.999848, 0.999391, 0.998630, 0.997564, 0.996195, 0.994522, 0.992546, 0.990268, 0.987688, 0.984808, 0.981627, 0.978148, 0.974370, 0.970296, 0.965926, 0.961262, 0.956305, 0.951057, 0.945519, 0.939693, 0.933580, 0.927184, 0.920505, 0.913545, 0.906308, 0.898794, 0.891007, 0.882948, 0.874620, 0.866025, 0.857167, 0.848048, 0.838671, 0.829038, 0.819152, 0.809017, 0.798636, 0.788011, 0.777146, 0.766044, 0.754710, 0.743145, 0.731354, 0.719340, 0.707107, 0.694658, 0.681998, 0.669131, 0.656059, 0.642788, 0.629320, 0.615661, 0.601815, 0.587785, 0.573576, 0.559193, 0.544639, 0.529919, 0.515038, 0.500000, 0.484810, 0.469472, 0.453990, 0.438371, 0.422618, 0.406737, 0.390731, 0.374607, 0.358368, 0.342020, 0.325568, 0.309017, 0.292372, 0.275637, 0.258819, 0.241922, 0.224951, 0.207912, 0.190809, 0.173648, 0.156434, 0.139173, 0.121869, 0.104528, 0.087156, 0.069756, 0.052336, 0.034899, 0.017452, -0.000000, -0.017452, -0.034899, -0.052336, -0.069756, -0.087156, -0.104528, -0.121869, -0.139173, -0.156434, -0.173648, -0.190809, -0.207912, -0.224951, -0.241922, -0.258819, -0.275637, -0.292372, -0.309017, -0.325568, -0.342020, -0.358368, -0.374607, -0.390731, -0.406737, -0.422618, -0.438371, -0.453990, -0.469472, -0.484810, -0.500000, -0.515038, -0.529919, -0.544639, -0.559193, -0.573576, -0.587785, -0.601815, -0.615661, -0.629320, -0.642788, -0.656059, -0.669131, -0.681998, -0.694658, -0.707107, -0.719340, -0.731354, -0.743145, -0.754710, -0.766044, -0.777146, -0.788011, -0.798636, -0.809017, -0.819152, -0.829038, -0.838671, -0.848048, -0.857167, -0.866025, -0.874620, -0.882948, -0.891007, -0.898794, -0.906308, -0.913545, -0.920505, -0.927184, -0.933580, -0.939693, -0.945519, -0.951057, -0.956305, -0.961262, -0.965926, -0.970296, -0.974370, -0.978148, -0.981627, -0.984808, -0.987688, -0.990268, -0.992546, -0.994522, -0.996195, -0.997564, -0.998630, -0.999391, -0.999848, -1.000000, -0.999848, -0.999391, -0.998630, -0.997564, -0.996195, -0.994522, -0.992546, -0.990268, -0.987688, -0.984808, -0.981627, -0.978148, -0.974370, -0.970296, -0.965926, -0.961262, -0.956305, -0.951057, -0.945519, -0.939693, -0.933580, -0.927184, -0.920505, -0.913545, -0.906308, -0.898794, -0.891007, -0.882948, -0.874620, -0.866025, -0.857167, -0.848048, -0.838671, -0.829038, -0.819152, -0.809017, -0.798636, -0.788011, -0.777146, -0.766044, -0.754710, -0.743145, -0.731354, -0.719340, -0.707107, -0.694658, -0.681998, -0.669131, -0.656059, -0.642788, -0.629320, -0.615661, -0.601815, -0.587785, -0.573576, -0.559193, -0.544639, -0.529919, -0.515038, -0.500000, -0.484810, -0.469472, -0.453990, -0.438371, -0.422618, -0.406737, -0.390731, -0.374607, -0.358368, -0.342020, -0.325568, -0.309017, -0.292372, -0.275637, -0.258819, -0.241922, -0.224951, -0.207912, -0.190809, -0.173648, -0.156434, -0.139173, -0.121869, -0.104528, -0.087156, -0.069756, -0.052336, -0.034899, -0.017452, 0.000000, 0.017452, 0.034899, 0.052336, 0.069756, 0.087156, 0.104528, 0.121869, 0.139173, 0.156434, 0.173648, 0.190809, 0.207912, 0.224951, 0.241922, 0.258819, 0.275637, 0.292372, 0.309017, 0.325568, 0.342020, 0.358368, 0.374607, 0.390731, 0.406737, 0.422618, 0.438371, 0.453991, 0.469472, 0.484810, 0.500000, 0.515038, 0.529919, 0.544639, 0.559193, 0.573576, 0.587785, 0.601815, 0.615661, 0.629320, 0.642788, 0.656059, 0.669131, 0.681998, 0.694658, 0.707107, 0.719340, 0.731354, 0.743145, 0.754710, 0.766044, 0.777146, 0.788011, 0.798636, 0.809017, 0.819152, 0.829038, 0.838671, 0.848048, 0.857167, 0.866025, 0.874620, 0.882948, 0.891007, 0.898794, 0.906308, 0.913545, 0.920505, 0.927184, 0.933580, 0.939693, 0.945519, 0.951057, 0.956305, 0.961262, 0.965926, 0.970296, 0.974370, 0.978148, 0.981627, 0.984808, 0.987688, 0.990268, 0.992546, 0.994522, 0.996195, 0.997564, 0.998630, 0.999391, 0.999848, 1.000000
};

/** Tangent, integer degrees 0-360 **/
static const double TANTABLE[361] =
{
    0.000000, 0.017455, 0.034921, 0.052408, 0.069927, 0.087489, 0.105104, 0.122785, 0.140541, 0.158384, 0.176327, 0.194380, 0.212557, 0.230868, 0.249328, 0.267949, 0.286745, 0.305731, 0.324920, 0.344328, 0.363970, 0.383864, 0.404026, 0.424475, 0.445229, 0.466308, 0.487733, 0.509525, 0.531709, 0.554309, 0.577350, 0.600861, 0.624869, 0.649408, 0.674509, 0.700208, 0.726543, 0.753554, 0.781286, 0.809784, 0.839100, 0.869287, 0.900404, 0.932515, 0.965689, 1.000000, 1.035530, 1.072369, 1.110613, 1.150368, 1.191754, 1.234897, 1.279942, 1.327045, 1.376382, 1.428148, 1.482561, 1.539865, 1.600335, 1.664279, 1.732051, 1.804048, 1.880726, 1.962611, 2.050304, 2.144507, 2.246037, 2.355852, 2.475087, 2.605089, 2.747477, 2.904211, 3.077684, 3.270853, 3.487414, 3.732051, 4.010781, 4.331476, 4.704630, 5.144554, 5.671282, 6.313752, 7.115370, 8.144346, 9.514364, 11.430052, 14.300666, 19.081137, 28.636253, 57.289962, -4875588902.821542, -57.289961, -28.636253, -19.081137, -14.300666, -11.430052, -9.514364, -8.144346, -7.115370, -6.313752, -5.671282, -5.144554, -4.704630, -4.331476, -4.010781, -3.732051, -3.487414, -3.270853, -3.077684, -2.904211, -2.747477, -2.605089, -2.475087, -2.355852, -2.246037, -2.144507, -2.050304, -1.962611, -1.880726, -1.804048, -1.732051, -1.664279, -1.600335, -1.539865, -1.482561, -1.428148, -1.376382, -1.327045, -1.279942, -1.234897, -1.191754, -1.150368, -1.110613, -1.072369, -1.035530, -1.000000, -0.965689, -0.932515, -0.900404, -0.869287, -0.839100, -0.809784, -0.781286, -0.753554, -0.726543, -0.700208, -0.674509, -0.649408, -0.624869, -0.600861, -0.577350, -0.554309, -0.531709, -0.509525, -0.487733, -0.466308, -0.445229, -0.424475, -0.404026, -0.383864, -0.363970, -0.344328, -0.324920, -0.305731, -0.286745, -0.267949, -0.249328, -0.230868, -0.212557, -0.194380, -0.176327, -0.158384, -0.140541, -0.122785, -0.105104, -0.087489, -0.069927, -0.052408, -0.034921, -0.017455, 0.000000, 0.017455, 0.034921, 0.052408, 0.069927, 0.087489, 0.105104, 0.122785, 0.140541, 0.158384, 0.176327, 0.194380, 0.212557, 0.230868, 0.249328, 0.267949, 0.286745, 0.305731, 0.324920, 0.344328, 0.363970, 0.383864, 0.404026, 0.424475, 0.445229, 0.466308, 0.487733, 0.509525, 0.531709, 0.554309, 0.577350, 0.600861, 0.624869, 0.649408, 0.674509, 0.700208, 0.726543, 0.753554, 0.781286, 0.809784, 0.839100, 0.869287, 0.900404, 0.932515, 0.965689, 1.000000, 1.035530, 1.072369, 1.110613, 1.150368, 1.191754, 1.234897, 1.279942, 1.327045, 1.376382, 1.428148, 1.482561, 1.539865, 1.600335, 1.664279, 1.732051, 1.804048, 1.880726, 1.962611, 2.050304, 2.144507, 2.246037, 2.355852, 2.475087, 2.605089, 2.747477, 2.904211, 3.077684, 3.270853, 3.487414, 3.732051, 4.010781, 4.331476, 4.704630, 5.144554, 5.671282, 6.313752, 7.115370, 8.144346, 9.514365, 11.430052, 14.300666, 19.081137, 28.636254, 57.289964, -1625196300.940514, -57.289960, -28.636253, -19.081136, -14.300666, -11.430052, -9.514364, -8.144346, -7.115370, -6.313751, -5.671282, -5.144554, -4.704630, -4.331476, -4.010781, -3.732051, -3.487414, -3.270853, -3.077684, -2.904211, -2.747477, -2.605089, -2.475087, -2.355852, -2.246037, -2.144507, -2.050304, -1.962611, -1.880726, -1.804048, -1.732051, -1.664279, -1.600335, -1.539865, -1.482561, -1.428148, -1.376382, -1.327045, -1.279942, -1.234897, -1.191754, -1.150368, -1.110613, -1.072369, -1.035530, -1.000000, -0.965689, -0.932515, -0.900404, -0.869287, -0.839100, -0.809784, -0.781286, -0.753554, -0.726543, -0.700208, -0.674509, -0.649408, -0.624869, -0.600861, -0.577350, -0.554309, -0.531709, -0.509525, -0.487733, -0.466308, -0.445229, -0.424475, -0.404026, -0.383864, -0.363970, -0.344328, -0.324920, -0.305731, -0.286745, -0.267949, -0.249328, -0.230868, -0.212557, -0.194380, -0.176327, -0.158384, -0.140541, -0.122785, -0.105104, -0.087489, -0.069927, -0.052408, -0.034921, -0.017455, 0.000000
};


/**************** The Functions ****************/
#pragma mark -
#pragma mark **************** The Functions ****************

double PhSin(int a)
{
    return SINETABLE[ (a % 360) ];
}

double PhCos(int a)
{
    return COSTABLE[ (a % 360) ];
}

double PhTan(int a)
{
    return TANTABLE[ (a % 360) ];
}