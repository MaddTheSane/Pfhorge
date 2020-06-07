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

private func IntPow<X>(_ base: X, _ exponent: X) -> X where X: FixedWidthInteger  {
	var output: X = 1;
	for _ in 0 ..< exponent {
		output *= base;
	}
	return output;
}

private func square<X>(_ number: X) -> X where X: Numeric {
	return number * number
}
/*
inline double Square( double number )
{ return number*number; }

inline int IntSquare( int number )
{ return number*number; }

*/

private var DefaultXPelsPerMeter: UInt32 {
	return 3780
}

private var DefaultYPelsPerMeter: UInt32 {
	return 3780
}

private func bmpWrite(_ toWrite: UInt8, _ data: inout Data) {
	data.append(contentsOf: [toWrite])
}

private func bmpWrite(_ toWrite: Int8, _ data: inout Data) {
	data.append(contentsOf: [UInt8(bitPattern: toWrite)])
}

private func bmpWrite(_ toWrite: UInt16, _ data: inout Data) {
	let arr = [toWrite.littleEndian]
	arr.withUnsafeBytes { (rbp) -> Void in
		data.append(Data(rbp))
	}
}

private func bmpWrite(_ toWrite: Int16, _ data: inout Data) {
	let arr = [toWrite.littleEndian]
	arr.withUnsafeBytes { (rbp) -> Void in
		data.append(Data(rbp))
	}
}

private func bmpWrite(_ toWrite: UInt32, _ data: inout Data) {
	let arr = [toWrite.littleEndian]
	arr.withUnsafeBytes { (rbp) -> Void in
		data.append(Data(rbp))
	}
}

private func bmpWrite(_ toWrite: Int32, _ data: inout Data) {
	let arr = [toWrite.littleEndian]
	arr.withUnsafeBytes { (rbp) -> Void in
		data.append(Data(rbp))
	}
}


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
	
	private struct BMFH: CustomDebugStringConvertible {
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
	
	private struct BMIH: CustomDebugStringConvertible {
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
	
	private(set) var bitDepth: Int32 = 24
	private(set) var width: Int32 = 1
	private(set) var height: Int32 = 1
	
	var XPelsPerMeter: Int32 = 3780
	var YPelsPerMeter: Int32 = 3780

	var metaData1 = Data()
	var metaData2 = Data()
	var pixels: [[RGBApixel]]
	var colors: [RGBApixel] = []

	init() {
		pixels = [[RGBApixel()]]
	}
	
	var numberOfColors: Int {
		if bitDepth == 32 {
			return IntPow(2, 24)
		} else {
			return Int(IntPow(2, bitDepth))
		}
	}
	
	func setSize(width NewWidth: Int32, height NewHeight: Int32) -> Bool {
		if NewWidth <= 0 || NewHeight <= 0  {
			return false;
		}

		width = NewWidth;
		height = NewHeight;
		pixels = [[RGBApixel]](repeating: [RGBApixel](), count: Int(width))
		
		for i in 0 ..< Int(width) {
			pixels[i] = [RGBApixel](repeating: RGBApixel(blue: 255, green: 255, red: 255, alpha: 0), count: Int(height))
		}
		
		return true;
	}
	
	func createStandardColorTable() -> Bool {
		if bitDepth != 1 && bitDepth != 4 && bitDepth != 8 {
			return false
		}
		
		switch bitDepth {
		case 1:
			for i in 0 ..< 2 {
				colors[i].red = UInt8(i*255)
				colors[i].green = UInt8(i*255)
				colors[i].blue = UInt8(i*255)
				colors[i].alpha = 0;
			}
			return true
			
		case 4:
			var i = 0;
			
			// simplify the code for the first 8 colors
			for ell in 0 ..< 2 {
				for k in 0 ..< 2 {
					for j in 0 ..< 2 {
						colors[i].red = UInt8(j*128)
						colors[i].green = UInt8(k*128)
						colors[i].blue = UInt8(ell*128)
						i += 1
					}
				}
			}
			
			// simplify the code for the last 8 colors
			for ell in 0 ..< 2 {
				for k in 0 ..< 2 {
					for j in 0 ..< 2 {
						colors[i].red = UInt8(clamping: j*255);
						colors[i].green = UInt8(clamping: k*255);
						colors[i].blue = UInt8(clamping: ell*255);
						i += 1
					}
				}
			}
			
			// overwrite the duplicate color
			i = 8
			colors[i].red = 192
			colors[i].green = 192
			colors[i].blue = 192
			
			for i in 0 ..< 16 {
				colors[i].alpha = 0
			}
			return true
			
		case 8 :
			var i = 0
			
			// do an easy loop, which works for all but colors
			// 0 to 9 and 246 to 255
			for ell in 0 ..< 4 {
				for k in 0 ..< 8  {
					for j in 0 ..< 8  {
						colors[i].red = UInt8(j*32);
						colors[i].green = UInt8(k*32);
						colors[i].blue = UInt8(ell*64);
						colors[i].alpha = 0;
						i += 1
					}
				}
			}
			
			// now redo the first 8 colors
			i = 0
			for ell in 0 ..< 2 {
				for k in 0 ..< 2  {
					for j in 0 ..< 2  {
						colors[i].red = UInt8(j*128);
						colors[i].green = UInt8(k*128);
						colors[i].blue = UInt8(ell*128);
						colors[i].alpha = 0;
						i += 1
					}
				}
			}
			
			// overwrite colors 7, 8, 9
			i = 7
			colors[i].red = 192
			colors[i].green = 192
			colors[i].blue = 192
			i += 1 // 8
			colors[i].red = 192
			colors[i].green = 220
			colors[i].blue = 192
			i += 1 // 9
			colors[i].red = 166
			colors[i].green = 202
			colors[i].blue = 240
			
			// overwrite colors 246 to 255
			i = 246
			colors[i].red = 255;
			colors[i].green = 251;
			colors[i].blue = 240;
			i += 1 // 247
			colors[i].red = 160;
			colors[i].green = 160;
			colors[i].blue = 164;
			i += 1 // 248
			colors[i].red = 128;
			colors[i].green = 128;
			colors[i].blue = 128;
			i += 1 // 249
			colors[i].red = 255;
			colors[i].green = 0;
			colors[i].blue = 0;
			i += 1 // 250
			colors[i].red = 0
			colors[i].green = 255
			colors[i].blue = 0
			i += 1 // 251
			colors[i].red = 255
			colors[i].green = 255
			colors[i].blue = 0
			i += 1 // 252
			colors[i].red = 0;
			colors[i].green = 0;
			colors[i].blue = 255;
			i += 1 // 253
			colors[i].red = 255;
			colors[i].green = 0;
			colors[i].blue = 255;
			i += 1 // 254
			colors[i].red = 0;
			colors[i].green = 255;
			colors[i].blue = 255;
			i += 1 // 255
			colors[i].red = 255;
			colors[i].green = 255;
			colors[i].blue = 255;
			
			return true;
			
		default:
			break;
		}
		
		return false
	}
	
	func setBitDepth(_ NewDepth: Int32 ) -> Bool {
		if NewDepth != 1 && NewDepth != 4 &&
			NewDepth != 8 && NewDepth != 16 &&
			NewDepth != 24 && NewDepth != 32  {
			return false;
		}
	 
		bitDepth = NewDepth
		
		let NumberOfColors = IntPow(2, bitDepth)
		if bitDepth == 1 || bitDepth == 4 || bitDepth == 8 {
			colors = [RGBApixel](repeating: EasyBMP.RGBApixel(), count: Int(NumberOfColors))
			
		} else{
			colors.removeAll()
		
		}
		if bitDepth == 1 || bitDepth == 4 || bitDepth == 8 {
			let success = createStandardColorTable()
			assert(success, "createStandardColorTable() failed")
		}
		
		return true
	}

	func generateData() -> Data {
		var fp = Data()
		
		// some preliminaries
		
		let dBytesPerPixel = Double(bitDepth) / 8.0;
		var dBytesPerRow = dBytesPerPixel * Double(width);
		dBytesPerRow = ceil(dBytesPerRow);
		 
		var BytePaddingPerRow = 4 - Int(dBytesPerRow) % 4;
		if BytePaddingPerRow == 4 {
			BytePaddingPerRow = 0
		}
		
		var dActualBytesPerRow = dBytesPerRow + Double(BytePaddingPerRow);
		
		var dTotalPixelBytes = Double(height) * dActualBytesPerRow;
		
		var dPaletteSize: Double = 0;

		if bitDepth == 1 || bitDepth == 4 || bitDepth == 8 {
			dPaletteSize = Double(IntPow(2,bitDepth))*4.0;
		}

		// leave some room for 16-bit masks
		if bitDepth == 16 {
			dPaletteSize = 3*4
		}
		
		var dTotalFileSize = 14 + 40 + dPaletteSize + dTotalPixelBytes;

		// write the file header
		
		var bmfh = BMFH()
		bmfh.bfSize = UInt32(dTotalFileSize);
		bmfh.bfReserved1 = 0;
		bmfh.bfReserved2 = 0;
		bmfh.bfOffBits = UInt32((14+40+dPaletteSize));
		
		bmpWrite(bmfh.bfType, &fp)
		bmpWrite(bmfh.bfSize, &fp)
		bmpWrite(bmfh.bfReserved1, &fp)
		bmpWrite(bmfh.bfReserved2, &fp)
		bmpWrite(bmfh.bfOffBits, &fp)
		
		// write the info header
		
		var bmih = BMIH()
		bmih.biSize = 40;
		bmih.biWidth = UInt32(width);
		bmih.biHeight = UInt32(height);
		bmih.biPlanes = 1;
		bmih.biBitCount = UInt16(bitDepth);
		bmih.biCompression = 0;
		bmih.biSizeImage =  UInt32(dTotalPixelBytes)
		if XPelsPerMeter != 0 {
			bmih.biXPelsPerMeter = UInt32(XPelsPerMeter)
		} else {
			bmih.biXPelsPerMeter = DefaultXPelsPerMeter
		}
		if YPelsPerMeter != 0 {
			bmih.biYPelsPerMeter = UInt32(YPelsPerMeter)
		} else {
			bmih.biYPelsPerMeter = DefaultYPelsPerMeter
		}

		bmih.biClrUsed = 0;
		bmih.biClrImportant = 0;

		// indicates that we'll be using bit fields for 16-bit files
		if bitDepth == 16 {
			bmih.biCompression = 3;
		}
		
		bmpWrite(bmih.biSize, &fp)
		bmpWrite(bmih.biWidth, &fp)
		bmpWrite(bmih.biHeight, &fp)
		bmpWrite(bmih.biPlanes, &fp)
		bmpWrite(bmih.biBitCount, &fp)
		bmpWrite(bmih.biCompression, &fp)
		bmpWrite(bmih.biSizeImage, &fp)
		bmpWrite(bmih.biXPelsPerMeter, &fp)
		bmpWrite(bmih.biYPelsPerMeter, &fp)
		bmpWrite(bmih.biClrUsed, &fp)
		bmpWrite(bmih.biClrImportant, &fp)
		
		
		if bitDepth == 1 || bitDepth == 4 || bitDepth == 8  {
			let NumberOfColors = IntPow(2, bitDepth);
			
			// if there is no palette, create one
			if colors.count == 0 {
				colors = [RGBApixel](repeating: EasyBMP.RGBApixel(), count: Int(NumberOfColors))
				_=createStandardColorTable()
			}
			
			for n in 0 ..< Int(NumberOfColors){
				bmpWrite(colors[n].blue, &fp)
				bmpWrite(colors[n].green, &fp)
				bmpWrite(colors[n].red, &fp)
				bmpWrite(colors[n].alpha, &fp)
			}
		}

		// write the pixels
		if bitDepth != 16 {
			closestColorMap.removeAll()
			
			var BufferSize =  Int( (width*bitDepth)/8 );
			while 8*BufferSize < width*bitDepth  {
				BufferSize += 1
			}
			while BufferSize % 4 != 0 {
				BufferSize += 1
			}
			
			var buffer = Data(capacity: BufferSize)
			
			var j = height - 1
			while j > -1 {
				
				j -= 1
			}

		} else {
			
		}
		
		return fp
	}
	
	private var closestColorMap = [RGBApixel: UInt8]()
	
	private func findClosestColor(to input: RGBApixel) -> UInt8 {
		if let num = closestColorMap[input] {
			return num
		}
		
		var bestI: UInt8 = 0
		var bestMatch = 999999
		
		for (i, attempt) in colors.enumerated() {
			let tempMatch: Int = square(Int(attempt.red) - Int(input.red)) +
			square(Int(attempt.green) - Int(input.green)) +
			square(Int(attempt.blue) - Int(input.blue))
			if tempMatch < bestMatch {
				bestI = UInt8(i)
				bestMatch = tempMatch
			}
			if bestMatch < 1 {
				break
			}
		}
		
		closestColorMap[input] = bestI
		return bestI
	}
	
	func makeColorIterator() -> IndexingIterator<Array<RGBApixel>>? {
		if bitDepth != 1 && bitDepth != 4 && bitDepth != 8 {
			return nil
		}
		
		if colors.count == 0 {
			return nil
		}

		return colors.makeIterator()
	}
}
