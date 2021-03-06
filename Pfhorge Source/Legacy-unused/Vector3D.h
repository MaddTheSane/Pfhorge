// Here are some 3D-vector utilities.
// These use templates because I wish them to work with both "float" and "double" values.
// Syntax: inputs, then outputs (might outputs, then inputs be better -- that's a common
// choice, even if sometimes counterintuitive).

#pragma once

#include "MiscUtils.h"
#include <simd/simd.h>


//! b = a
//! May change type
template<class T1, class T2> inline void copy_3d(const T1 *a, T2 *b) {
	for (int k=0; k<3; k++)
		b[k] = T2(a[k]);
}


//! b = a
//! May change type
template<class T1> inline void copy_3d(const T1 *a, simd::float3 &b) {
	for (int k=0; k<3; k++)
		b[k] = float(a[k]);
}


//! b = a
//! May change type
template<class T2> inline void copy_3d(const simd::float3 a, T2 *b) {
	for (int k=0; k<3; k++)
		b[k] = T2(a[k]);
}


//! Using conversion function
template<class T1, class T2, class Convert> inline void copy_3d(const T1 *a, T2 *b, Convert cvt) {
	for (int k=0; k<3; k++)
		b[k] = T2(cvt(a[k]));
}


//! Float-to-integer class: put to_int() in 3rd arg above
struct to_int {
	int operator()(float x) {return irint(x);}
	int operator()(double x) {return irint(x);}
};


//! c = a + b
template<class T> inline void add_3d(const T *a, const T *b, T *c) {
	for (int k=0; k<3; k++)
		c[k] = a[k] + b[k];
}

//! c = a - b
template<class T> inline void sub_3d(const T *a, const T *b, T *c) {
	for (int k=0; k<3; k++)
		c[k] = a[k] - b[k];
}

//! c = (a)*b
template<class T> inline void scalmult_3d(const T &a, const T *b, T *c) {
	for (int k=0; k<3; k++)
		c[k] = a*b[k];
}

//! Inner product: a⋅b
template<class T> inline T innerprod_3d(const T *a, const T *b) {
	T res = 0;
	for (int k=0; k<3; k++)
		res += a[k]*b[k];
	return res;
}

//! Absolute square: a^2
template<class T> inline T abssqr_3d(const T *a) {
	T res = 0;
	for (int k=0; k<3; k++)
		res += sqr(a[k]);
	return res;
}

//! Vector product c = a ✕ b
template<class T> inline void vecprod_3d(const T *a, const T *b, T *c) {
	// Must be written out
	c[0] = a[1]*b[2] - a[2]*b[1];
	c[1] = a[2]*b[0] - a[0]*b[2];
	c[2] = a[0]*b[1] - a[1]*b[0];
}

//! Determinant: a⋅(b ✕ c)
template<class T> inline T det_3d(const T *a, const T *b, const T *c) {
	T intmd[3];
	vecprod_3d(b,c,intmd);
	return innerprod_3d(a,intmd);
}
