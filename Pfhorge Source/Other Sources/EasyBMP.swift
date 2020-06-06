//
//  EasyBMP.swift
//  Pfhorge
//
//  Created by C.W. Betts on 6/4/20.
//  Originally written by Paul Macklin and maintained by the EasyBMP Project.
//  Original copyright follows
/*************************************************
*                                                *
*  EasyBMP Cross-Platform Windows Bitmap Library *
*                                                *
*  Author: Paul Macklin                          *
*   email: macklin01@users.sourceforge.net       *
* support: http://easybmp.sourceforge.net        *
*                                                *
*   License: BSD (revised/modified)              *
* Copyright: 2005-6 by the EasyBMP Project       *
*                                                *
*************************************************/


import Cocoa

private func SafeFread(_ buffer: UnsafeMutableRawPointer, size: Int, number: Int, _ fp: UnsafeMutablePointer<FILE>) -> Bool
{
	if feof(fp) != 0 {
		return false
	}
	let ItemsRead = fread(buffer, size, number, fp)
	if ItemsRead < number {
		return false
	}
	return true;
}


class EasyBMP {
	struct RGBApixel: Comparable, Hashable {
		var blue: UInt8 = 0
		var green: UInt8 = 0
		var red: UInt8 = 0
		var alpha: UInt8 = 0
		
		static func <(lhs: RGBApixel, rhs: RGBApixel) -> Bool {
			if (lhs.blue != rhs.blue) {
				return lhs.blue < rhs.blue
			} else if (lhs.green != rhs.green) {
				return lhs.green < rhs.green
			} else if (lhs.red != rhs.red) {
				return lhs.red < rhs.red
			} else {
				return lhs.alpha < rhs.alpha
			}
		}
	}
	
	struct BMFH: CustomDebugStringConvertible {
		var bfType: UInt16 = 19778
		var bfSize: UInt32 = 0
		var bfReserved1: UInt16 = 0
		var bfReserved2: UInt16 = 0
		var bfOffBits: UInt32 = 0
		
		var debugDescription: String {
			return "bfType: \(bfType) bfSize: \(bfSize) bfReserved1: \(bfReserved1) bfReserved2: \(bfReserved2) bfOffBits: \(bfOffBits)"
		}
		
		mutating func switchEndianess() {
			bfType = bfType.byteSwapped
			bfSize = bfSize.byteSwapped
			bfReserved1 = bfReserved1.byteSwapped
			bfReserved2 = bfReserved2.byteSwapped
			bfOffBits = bfOffBits.byteSwapped
		}
	}
	
	struct BMIH: CustomDebugStringConvertible {
		var biSize: UInt32 = 0
		var biWidth: UInt32 = 0
		var biHeight: UInt32 = 0
		var biPlanes: UInt16 = 1
		var biBitCount: UInt16 = 0
		var biCompression: UInt32 = 0
		var biSizeImage: UInt32 = 0
		/// set to a default of 96 dpi
		var biXPelsPerMeter: UInt32 = 3780
		/// set to a default of 96 dpi
		var biYPelsPerMeter: UInt32 = 3780
		
		var biClrUsed: UInt32 = 0
		var biClrImportant: UInt32 = 0
		
		var debugDescription: String {
			return "biSize: \(biSize) biWidth: \(biWidth) biHeight: \(biHeight) biPlanes: \(biPlanes) biBitCount: \(biBitCount) biCompression: \(biCompression) biSizeImage: \(biSizeImage) biXPelsPerMeter: \(biXPelsPerMeter) biYPelsPerMeter: \(biYPelsPerMeter) biClrUsed: \(biClrUsed) biClrImportant:\(biClrImportant)"
		}
		
		mutating func switchEndianess() {
			biSize = biSize.byteSwapped
			biWidth = biWidth.byteSwapped
			biHeight = biHeight.byteSwapped
			biPlanes = biPlanes.byteSwapped
			biBitCount = biBitCount.byteSwapped
			biCompression = biCompression.byteSwapped
			biSizeImage = biSizeImage.byteSwapped
			biXPelsPerMeter = biXPelsPerMeter.byteSwapped
			biYPelsPerMeter = biYPelsPerMeter.byteSwapped
			biClrUsed = biClrUsed.byteSwapped
			biClrImportant = biClrImportant.byteSwapped
		}
	}
	
	private(set) var bitDepth = 24
	private(set) var width = 1
	private(set) var height = 1
	
	var XPelsPerMeter = 0;
	var YPelsPerMeter = 0;

	var metaData1 = Data()
	var metaData2 = Data()
	var pixels: [[RGBApixel]] = []
	var colors: [RGBApixel] = []

	init() {
		
	}
}
