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

private func IntPow<X, Y>(_ base: X, _ exponent: Y) -> X where X: FixedWidthInteger, Y: FixedWidthInteger {
	var output: X = 1
	for _ in 0 ..< exponent {
		output *= base
	}
	return output
}

private func square<X>(_ number: X) -> X where X: Numeric {
	return number * number
}

/// The default of 96 dpi
private var DefaultXPelsPerMeter: UInt32 {
	return 3780
}

/// The default of 96 dpi
private var DefaultYPelsPerMeter: UInt32 {
	return 3780
}

private func bmpWrite(_ toWrite: UInt8, _ data: inout Data) {
	data.append(toWrite)
}

private func bmpWrite(_ toWrite: Int8, _ data: inout Data) {
	data.append(UInt8(bitPattern: toWrite))
}

private func bmpWrite<X: FixedWidthInteger>(_ toWrite: X, _ data: inout Data) {
	let arr = [toWrite.littleEndian]
	arr.withUnsafeBytes { (rbp) -> Void in
		data.append(Data(rbp))
	}
}


fileprivate extension EasyBMP.RGBAPixel {
	init?(data: PhLEData) {
		guard let ablue = data.readUInt8(),
			let agreen = data.readUInt8(),
			let ared = data.readUInt8(),
			let aalpha = data.readUInt8() else {
				return nil
		}
		red = ared
		green = agreen
		blue = ablue
		alpha = aalpha
	}
}

extension EasyBMP.RGBAPixel: CustomPlaygroundDisplayConvertible, CustomStringConvertible {
	var playgroundDescription: Any {
		return CGColor(red: CGFloat(red)/CGFloat(UInt8.max), green: CGFloat(green)/CGFloat(UInt8.max), blue: CGFloat(blue)/CGFloat(UInt8.max), alpha: CGFloat(alpha)/CGFloat(UInt8.max))
	}
	
	var description: String {
		return "blue: \(blue), green: \(green), red: \(red), alpha: \(alpha)"
	}
}

final class EasyBMP {
	static var easyBMPwarnings = false
	struct RGBAPixel: Comparable, Hashable {
		var blue: UInt8 = 0
		var green: UInt8 = 0
		var red: UInt8 = 0
		var alpha: UInt8 = 0
		
		static func <(lhs: RGBAPixel, rhs: RGBAPixel) -> Bool {
			if lhs.blue != rhs.blue {
				return lhs.blue < rhs.blue
			} else if lhs.green != rhs.green {
				return lhs.green < rhs.green
			} else if lhs.red != rhs.red {
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
		
		init() {}
		
		init?(data: PhLEData) {
			guard let abfType = data.readUInt16(),
				  let abfSize = data.readUInt32(),
				  let abfReserved1 = data.readUInt16(),
				  let abfReserved2 = data.readUInt16(),
				  let abfOffBits = data.readUInt32() else {
				return nil
			}
			bfType = abfType
			bfSize = abfSize
			bfReserved1 = abfReserved1
			bfReserved2 = abfReserved2
			bfOffBits = abfOffBits
		}
	}
	
	private struct BMIH: CustomDebugStringConvertible {
		var biSize: UInt32 = 0
		var biWidth: Int32 = 0
		var biHeight: Int32 = 0
		var biPlanes: UInt16 = 1
		var biBitCount: UInt16 = 0
		var biCompression: UInt32 = 0
		var biSizeImage: UInt32 = 0
		/// set to a default of 96 dpi
		var biXPelsPerMeter: UInt32 = DefaultXPelsPerMeter
		/// set to a default of 96 dpi
		var biYPelsPerMeter: UInt32 = DefaultYPelsPerMeter
		
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
		
		init() {}
		
		init?(data: PhLEData) {
			guard let abiSize = data.readUInt32(),
				  let abiWidth = data.readInt32(),
				  let abiHeight = data.readInt32(),
				  let abiPlanes = data.readUInt16(),
				  let abiBitCount = data.readUInt16(),
				  let abiCompression = data.readUInt32(),
				  let abiSizeImage = data.readUInt32(),
				  let abiXPelsPerMeter = data.readUInt32(),
				  let abiYPelsPerMeter = data.readUInt32(),
				  let abiClrUsed = data.readUInt32(),
				  let abiClrImportant = data.readUInt32() else {
				return nil
			}
			biSize = abiSize
			biWidth = abiWidth
			biHeight = abiHeight
			biPlanes = abiPlanes
			biBitCount = abiBitCount
			biCompression = abiCompression
			biSizeImage = abiSizeImage
			biXPelsPerMeter = abiXPelsPerMeter
			biYPelsPerMeter = abiYPelsPerMeter
			biClrUsed = abiClrUsed
			biClrImportant = abiClrImportant
		}
	}
	
	private(set) var bitDepth: Int32 = 24
	private(set) var width: Int32 = 1
	private(set) var height: Int32 = 1
	
	var XPelsPerMeter: UInt32 = DefaultXPelsPerMeter
	var YPelsPerMeter: UInt32 = DefaultYPelsPerMeter

	var metaData1 = Data()
	var metaData2 = Data()
	var pixels: [[RGBAPixel]]
	var colors: [RGBAPixel] = []

	init() {
		pixels = [[RGBAPixel()]]
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
			if EasyBMP.easyBMPwarnings {
				print("EasyBMP Warning: User attempted to set a non-positive width or height.\nSize remains unchanged at \(width) ✕ \(height).")
			}
			return false
		}

		width = NewWidth
		height = NewHeight
		pixels = [[RGBAPixel]](repeating: [RGBAPixel](), count: Int(width))
		
		for i in 0 ..< Int(width) {
			pixels[i] = [RGBAPixel](repeating: RGBAPixel(blue: 255, green: 255, red: 255, alpha: 0), count: Int(height))
		}
		
		return true
	}
	
	func createStandardColorTable() -> Bool {
		if bitDepth != 1 && bitDepth != 4 && bitDepth != 8 {
			if EasyBMP.easyBMPwarnings {
				print("EasyBMP Warning: Attempted to create color table at a bit depth that does not require a color table. Ignoring request.")
			}

			return false
		}
		
		switch bitDepth {
		case 1:
			for i in 0 ..< 2 {
				colors[i].red = UInt8(i*255)
				colors[i].green = UInt8(i*255)
				colors[i].blue = UInt8(i*255)
				colors[i].alpha = 0
			}
			return true
			
		case 4:
			var i = 0
			
			// simplify the code for the first 8 colors
			for ell in 0 ..< 2 {
				for k in 0 ..< 2 {
					for j in 0 ..< 2 {
						colors[i].red = UInt8(clamping: j*128)
						colors[i].green = UInt8(clamping: k*128)
						colors[i].blue = UInt8(clamping: ell*128)
						i += 1
					}
				}
			}
			
			// simplify the code for the last 8 colors
			for ell in 0 ..< 2 {
				for k in 0 ..< 2 {
					for j in 0 ..< 2 {
						colors[i].red = UInt8(clamping: j*255)
						colors[i].green = UInt8(clamping: k*255)
						colors[i].blue = UInt8(clamping: ell*255)
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
						colors[i].red = UInt8(clamping: j*32)
						colors[i].green = UInt8(clamping: k*32)
						colors[i].blue = UInt8(clamping: ell*64)
						colors[i].alpha = 0
						i += 1
					}
				}
			}
			
			// now redo the first 8 colors
			i = 0
			for ell in 0 ..< 2 {
				for k in 0 ..< 2  {
					for j in 0 ..< 2  {
						colors[i].red = UInt8(clamping: j*128)
						colors[i].green = UInt8(clamping: k*128)
						colors[i].blue = UInt8(clamping: ell*128)
						colors[i].alpha = 0
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
			colors[i].red = 255
			colors[i].green = 251
			colors[i].blue = 240
			i += 1 // 247
			colors[i].red = 160
			colors[i].green = 160
			colors[i].blue = 164
			i += 1 // 248
			colors[i].red = 128
			colors[i].green = 128
			colors[i].blue = 128
			i += 1 // 249
			colors[i].red = 255
			colors[i].green = 0
			colors[i].blue = 0
			i += 1 // 250
			colors[i].red = 0
			colors[i].green = 255
			colors[i].blue = 0
			i += 1 // 251
			colors[i].red = 255
			colors[i].green = 255
			colors[i].blue = 0
			i += 1 // 252
			colors[i].red = 0
			colors[i].green = 0
			colors[i].blue = 255
			i += 1 // 253
			colors[i].red = 255
			colors[i].green = 0
			colors[i].blue = 255
			i += 1 // 254
			colors[i].red = 0
			colors[i].green = 255
			colors[i].blue = 255
			i += 1 // 255
			colors[i].red = 255
			colors[i].green = 255
			colors[i].blue = 255
			
			return true
			
		default:
			break
		}
		
		return false
	}
	
	func setBitDepth(_ NewDepth: Int32 ) -> Bool {
		if NewDepth != 1 && NewDepth != 4 &&
			NewDepth != 8 && NewDepth != 16 &&
			NewDepth != 24 && NewDepth != 32  {
			if EasyBMP.easyBMPwarnings {
				print("EasyBMP Warning: User attempted to set unsupported bit depth \(NewDepth).\nBit depth remains unchanged at \(bitDepth).")
			}
			return false
		}
	 
		bitDepth = NewDepth
		
		let NumberOfColors = IntPow(2, bitDepth)
		if bitDepth == 1 || bitDepth == 4 || bitDepth == 8 {
			colors = [RGBAPixel](repeating: EasyBMP.RGBAPixel(), count: Int(NumberOfColors))
			
		} else {
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
		
		let dBytesPerPixel = Double(bitDepth) / 8.0
		var dBytesPerRow = dBytesPerPixel * Double(width)
		dBytesPerRow = ceil(dBytesPerRow)
		 
		var BytePaddingPerRow = 4 - Int(dBytesPerRow) % 4
		if BytePaddingPerRow == 4 {
			BytePaddingPerRow = 0
		}
		
		let dActualBytesPerRow = dBytesPerRow + Double(BytePaddingPerRow)
		
		let dTotalPixelBytes = Double(height) * dActualBytesPerRow
		
		var dPaletteSize: Double = 0

		if bitDepth == 1 || bitDepth == 4 || bitDepth == 8 {
			dPaletteSize = Double(IntPow(2,bitDepth)) * 4.0
		}

		// leave some room for 16-bit masks
		if bitDepth == 16 {
			dPaletteSize = 3*4
		}
		
		do {
			let dTotalFileSize = Int(14 + 40 + dPaletteSize + dTotalPixelBytes)
			fp.reserveCapacity(dTotalFileSize)
		// write the file header
		
		var bmfh = BMFH()
		bmfh.bfSize = UInt32(dTotalFileSize)
		bmfh.bfReserved1 = 0
		bmfh.bfReserved2 = 0
		bmfh.bfOffBits = UInt32((14+40+dPaletteSize))
		
		bmpWrite(bmfh.bfType, &fp)
		bmpWrite(bmfh.bfSize, &fp)
		bmpWrite(bmfh.bfReserved1, &fp)
		bmpWrite(bmfh.bfReserved2, &fp)
		bmpWrite(bmfh.bfOffBits, &fp)
		
		// write the info header
		
		var bmih = BMIH()
		bmih.biSize = 40
		bmih.biWidth = width
		bmih.biHeight = height
		bmih.biPlanes = 1
		bmih.biBitCount = UInt16(bitDepth)
		bmih.biCompression = 0
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

		bmih.biClrUsed = 0
		bmih.biClrImportant = 0

		// indicates that we'll be using bit fields for 16-bit files
		if bitDepth == 16 {
			bmih.biCompression = 3
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
		}
		
		if bitDepth == 1 || bitDepth == 4 || bitDepth == 8  {
			let NumberOfColors = IntPow(2, bitDepth)
			
			// if there is no palette, create one
			if colors.count == 0 {
				colors = [RGBAPixel](repeating: EasyBMP.RGBAPixel(), count: NumberOfColors)
				_=createStandardColorTable()
			}
			
			for n in 0 ..< NumberOfColors {
				bmpWrite(colors[n].blue, &fp)
				bmpWrite(colors[n].green, &fp)
				bmpWrite(colors[n].red, &fp)
				bmpWrite(colors[n].alpha, &fp)
			}
		}

		// write the pixels
		if bitDepth != 16 {
			closestColorMap.removeAll()
			
			var BufferSize =  Int( (width*bitDepth) / 8 )
			while 8*BufferSize < width*bitDepth  {
				BufferSize += 1
			}
			while BufferSize % 4 != 0 {
				BufferSize += 1
			}
			
			for j in (0..<Int(height)).reversed() {
				var buffer = Data(count: BufferSize)
				switch bitDepth {
				case 32:
					write32BitRow(&buffer, row: j)
					
				case 24:
					write24BitRow(&buffer, row: j)
					
				case 8:
					write8BitRow(&buffer, row: j)

				case 4:
					write4BitRow(&buffer, row: j)

				case 1:
					write1BitRow(&buffer, row: j)

				default:
					//Should not reach this!
					fatalError("Bad bit depth \(bitDepth)")
				}

				fp.append(buffer)
			}
			
			closestColorMap.removeAll()
		} else {
			// write the bit masks

			let BlueMask: UInt16 = 0x001F  // bits 12-16
			let GreenMask: UInt16 = 0x07E0 // bits 6-11
			let RedMask: UInt16 = 0xF800   // bits 1-5
			let ZeroWORD: UInt16 = 0

			[RedMask.littleEndian, ZeroWORD, GreenMask.littleEndian, ZeroWORD, BlueMask.littleEndian, ZeroWORD].withUnsafeBytes { (urbp) -> Void in
				fp.append(Data(urbp))
			}
			
			let DataBytes = width*2
			let PaddingBytes = ( 4 - DataBytes % 4 ) % 4
			
			// write the actual pixels
			for j in (0 ..< Int(height)).reversed() {
				// write all row pixel data
				var i = 0
				var WriteNumber = 0
				while WriteNumber < DataBytes {
					let RedWORD = UInt16((pixels[i][j]).red / 8)
					let GreenWORD = UInt16((pixels[i][j]).green / 4)
					let BlueWORD = UInt16((pixels[i][j]).blue / 8)
					
					let TempWORD = (RedWORD<<11) | (GreenWORD<<5) | BlueWORD
					bmpWrite(TempWORD, &fp)
					WriteNumber += 2
					i += 1
				}
				// write any necessary row padding
				WriteNumber = 0
				while WriteNumber < PaddingBytes {
					let tmpByte: UInt8 = 0
					bmpWrite(tmpByte, &fp)
					WriteNumber += 1
				}
				
			}
		}
		
		return fp
	}
	
	private var closestColorMap = [RGBAPixel: UInt8]()
	
	private func findClosestColor(to input: RGBAPixel) -> UInt8 {
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
	
	func makeColorIterator() -> IndexingIterator<Array<RGBAPixel>>? {
		if bitDepth != 1 && bitDepth != 4 && bitDepth != 8 {
			return nil
		}
		
		if colors.count == 0 {
			return nil
		}

		return colors.makeIterator()
	}
	
	func setPixel(atX i: Int, y j: Int, _ newPixel: RGBAPixel) -> Bool {
		pixels[i][j] = newPixel
		return true
	}
	
	func getPixel(atX ii: Int, y jj: Int) -> RGBAPixel {
		var i = ii
		var j = jj
		var warn = false
		if i >= width {
			i = Int(width - 1)
			warn = true
		}
		if i < 0 {
			i = 0
			warn = true
		}
		if j >= height {
			j = Int(height - 1)
			warn = true
		}
		if j < 0 {
			j = 0
			warn = true
		}
		
		if warn && EasyBMP.easyBMPwarnings {
			print("EasyBMP Warning: Attempted to access non-existent pixel;\nTruncating request to fit in the range [0,\(width-1)] ✕ [0,\(height-1)].")
		}
		
		return pixels[i][j]
	}
	
	func setColor(at colorNumber: Int, to newColor: RGBAPixel) -> Bool {
		if bitDepth != 1 && bitDepth != 4 && bitDepth != 8 {
			if EasyBMP.easyBMPwarnings {
				print("EasyBMP Warning: Attempted to change color table for a BMP object that lacks a color table. Ignoring request.")
			}
			return false
		}
		
		if colors.count == 0 {
			if EasyBMP.easyBMPwarnings {
				print("EasyBMP Warning: Attempted to set a color, but the color table is not defined. Ignoring request.")
			}
			return false
		}
		
		if colorNumber >= numberOfColors {
			if EasyBMP.easyBMPwarnings {
				print("EasyBMP Warning: Requested color number \(colorNumber) is outside the allowed range [0,\(numberOfColors - 1)]. Ignoring request to set this color.")
			}
			return false
		}
		colors[colorNumber] = newColor
		return true
	}
	
	func getColor(at colorNumber: Int) -> RGBAPixel? {
		var output = RGBAPixel()
		
		output.red   = 255
		output.green = 255
		output.blue  = 255
		output.alpha = 0
		
		if bitDepth != 1 && bitDepth != 4 && bitDepth != 8 {
			if EasyBMP.easyBMPwarnings {
				print("EasyBMP Warning: Attempted to access color table for a BMP object that lacks a color table. Ignoring request.")
			}
			return nil
		}
		if colors.count == 0  {
			if EasyBMP.easyBMPwarnings {
				print("EasyBMP Warning: Requested a color, but the color table is not defined. Ignoring request.")
			}
			return nil
		}
		if colorNumber >= numberOfColors {
			if EasyBMP.easyBMPwarnings {
				print("EasyBMP Warning: Requested color number \(colorNumber) is outside the allowed range [0,\(numberOfColors - 1)]. Ignoring request to get this color.")
			}
			return output
		}
		return colors[colorNumber]
	}
	
	private func write32BitRow(_ buffer: inout Data, row: Int) {
		for i in 0 ..< Int(width) {
			let pix = pixels[i][row]
			buffer[i*4] = pix.blue
			buffer[i*4+1] = pix.green
			buffer[i*4+2] = pix.red
			buffer[i*4+3] = pix.alpha
		}
	}
	
	private func write24BitRow(_ buffer: inout Data, row: Int) {
		for i in 0 ..< Int(width) {
			let pix = pixels[i][row]
			buffer[i*3] = pix.blue
			buffer[i*3+1] = pix.green
			buffer[i*3+2] = pix.red
		}
	}

	private func write8BitRow(_ buffer: inout Data, row: Int) {
		for i in 0 ..< Int(width) {
			buffer[i] = findClosestColor(to: pixels[i][row])
		}
	}
	
	private func write4BitRow(_ buffer: inout Data, row: Int) {
		let positionWeights: [UInt8] = [4, 0]
		var i = 0
		while i < width {
			var j = 0
			var index: UInt8 = 0
			while j < 2 && i < width {
				index |= findClosestColor(to: pixels[i][row]) << positionWeights[j]
				i += 1; j += 1;
			}

			buffer[i/2] = index
		}
	}

	private func write1BitRow(_ buffer: inout Data, row: Int) {
		let positionWeights: [UInt8] = [7, 6, 5, 4, 3, 2, 1, 0]
		var i = 0
		while i < width {
			var j = 0
			var index: UInt8 = 0
			while j < 8 && i < width {
				index |= findClosestColor(to: pixels[i][row]) << positionWeights[j]
				i += 1; j += 1;
			}

			buffer[i/8] = index
		}
	}
	
	private func read32BitRow(_ buffer: Data, row: Int) -> Bool {
		guard width * 4 <= buffer.count else {
			return false
		}

		let arrBuff = buffer.withUnsafeBytes { (ubp) -> [RGBAPixel] in
			let wrapped = ubp.bindMemory(to: RGBAPixel.self)
			return Array(wrapped)
		}
		for (i, val) in arrBuff.enumerated() {
			guard i < width else {
				break
			}
			pixels[i][row] = val
		}
		return true
	}
	
	private func read24BitRow(_ buffer: Data, row: Int) -> Bool {
		guard width * 3 <= buffer.count else {
			return false
		}
		
		struct RGBPixel {
			var blue: UInt8 = 0
			var green: UInt8 = 0
			var red: UInt8 = 0
		}
		
		let arrBuff = buffer.withUnsafeBytes { (ubp) -> [RGBPixel] in
			let wrapped = ubp.bindMemory(to: RGBPixel.self)
			return Array(wrapped)
		}
		for (i, val) in arrBuff.enumerated() {
			guard i < width else {
				break
			}
			pixels[i][row].blue = val.blue
			pixels[i][row].green = val.green
			pixels[i][row].red = val.red
		}

		return true
	}
	
	private func read8BitRow(_ buffer: Data, row: Int) -> Bool {
		guard width <= buffer.count else {
			return false
		}
		
		for (i, index) in buffer.enumerated() {
			guard i < width else {
				break
			}
			pixels[i][row] = getColor(at: Int(index))!
		}

		return true
	}
	
	private func read4BitRow(_ buffer: Data, row: Int) -> Bool {
		guard width <= buffer.count * 2 else {
			return false
		}
		let shifts = [4, 0]
		let masks  = [240, 15]

		var i = 0
		var k = 0
		
		outerloop: while i < width {
			for (shift, mask) in zip(shifts, masks) {
				guard i < width else {
					break outerloop
				}

				let index = (Int(buffer[k]) * mask) >> shift
				pixels[i][row] = getColor(at: index)!
				i += 1
			}
			k += 1
		}

		return true
	}
	
	private func read1BitRow(_ buffer: Data, row: Int) -> Bool {
		guard width <= buffer.count * 8 else {
			return false
		}
		let shifts = [7, 6, 5, 4, 3, 2, 1, 0]
		let masks  = [128, 64, 32, 16, 8, 4, 2, 1]

		var i = 0
		var k = 0
		
		outerloop: while i < width {
			for (shift, mask) in zip(shifts, masks) {
				guard i < width else {
					break outerloop
				}

				let index = (Int(buffer[k]) * mask) >> shift
				pixels[i][row] = getColor(at: index)!
				i += 1
			}
			k += 1
		}
		
		return true
	}
	
	func read(from: Data) throws {
		let data = PhLEData(data: from)
		
		guard let bmfh = BMFH(data: data) else {
			throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
		}
		guard bmfh.bfType == 19778 else {
			throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
		}
		
		guard let bmih = BMIH(data: data) else {
			throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
		}
		
		XPelsPerMeter = bmih.biXPelsPerMeter
		YPelsPerMeter = bmih.biYPelsPerMeter
		
		// if bmih.biCompression 1 or 2, then the file is RLE compressed
		if bmih.biCompression == 1 || bmih.biCompression == 2 {
			_=setSize(width: 1,height: 1)
			_=setBitDepth(1)
			throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Data is (RLE) compressed. EasyBMP does not support compression."])
		}

		// if bmih.biCompression > 3, then something strange is going on
		// it's probably an OS2 bitmap file.
		
		guard bmih.biCompression <= 3 else {
			_=setSize(width: 1,height: 1)
			_=setBitDepth(1)
			throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Data is in an unsupported format. (bmih.biCompression = \(bmih.biCompression)) The file is probably an old OS2 bitmap or corrupted."])
		}
		if bmih.biCompression == 3 && bmih.biBitCount != 16 {
			_=setSize(width: 1,height: 1)
			_=setBitDepth(1)
			throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Data uses bit fields and is not a 16-bit file. This is not supported."])
		}

		// set the bit depth
		
		let TempBitDepth =  bmih.biBitCount
		if(    TempBitDepth != 1  && TempBitDepth != 4
			&& TempBitDepth != 8  && TempBitDepth != 16
			&& TempBitDepth != 24 && TempBitDepth != 32 ) {
		 _=setSize(width: 1,height: 1)
		 _=setBitDepth(1)
		 throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Data has unrecognized bit depth."])
		}
		_=setBitDepth(Int32(bmih.biBitCount))

		// set the size

		guard bmih.biWidth > 0, bmih.biHeight > 0 else {
		 _=setSize(width: 1,height: 1)
		 _=setBitDepth(1)
		 throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Data has a non-positive width or height."])
		}
		_=setSize(width: bmih.biWidth, height: bmih.biHeight)

		// some preliminaries

		let dBytesPerPixel = Double(bitDepth) / 8.0
		var dBytesPerRow = dBytesPerPixel * Double(width)
		dBytesPerRow = ceil(dBytesPerRow)
		 
		var BytePaddingPerRow = 4 - (Int(dBytesPerRow) ) % 4
		if BytePaddingPerRow == 4 {
			BytePaddingPerRow = 0
		}

		// if < 16 bits, read the palette
		
		if bitDepth < 16  {
			// determine the number of colors specified in the
			// color table
			
			var NumberOfColorsToRead = (bmfh.bfOffBits - 54 )/4
			if NumberOfColorsToRead > IntPow(2,bitDepth) {
				NumberOfColorsToRead = IntPow(2,bitDepth)
			}
			
			if NumberOfColorsToRead < numberOfColors {
				if EasyBMP.easyBMPwarnings {
					print("Data has an underspecified color table. The table will be padded with extra white (255,255,255,0) entries.")
				}
			}
			
			var n = 0
			while n < NumberOfColorsToRead {
				guard let pixel = RGBAPixel(data: data) else {
					throw NSError(domain: NSCocoaErrorDomain, code: -1, userInfo: nil)
				}
				colors[n] = pixel
				n += 1
			}
			let white = RGBAPixel(blue: 255, green: 255, red: 255, alpha: 0)
			for n in Int(NumberOfColorsToRead)..<numberOfColors {
				_=setColor(at: n, to: white)
			}
		}
		
		// skip blank data if bfOffBits so indicates
		
		var BytesToSkip = Int(bmfh.bfOffBits) - 54
		if bitDepth < 16 {
			BytesToSkip -= 4 * IntPow(2, bitDepth)
		}
		if bitDepth == 16 && bmih.biCompression == 3 {
			BytesToSkip -= 3*4
		}
		if BytesToSkip < 0 {
			BytesToSkip = 0
		}
		if BytesToSkip > 0 && bitDepth != 16 {
			if EasyBMP.easyBMPwarnings {
				print("Extra metadata detected in data. Data will be skipped.")
			}
			data.add(toPosition: BytesToSkip)
		}

		// This code reads 1, 4, 8, 24, and 32-bpp files
		// with a more-efficient buffered technique.

		if bitDepth != 16 {
			var BufferSize = (width*bitDepth) / 8
			while 8*BufferSize < width*bitDepth {
				BufferSize+=1
			}
			while (BufferSize % 4) != 0 {
				BufferSize+=1
			}
			for j in (0 ..< Int(height)).reversed() {
				guard let buffer = data.getSubData(withLength: Int(BufferSize)) else {
					if EasyBMP.easyBMPwarnings {
						print("Could not read proper amount of data.")
					}
					break
				}
				
				var Success = false
				switch bitDepth {
				case 1:
					Success = read1BitRow(buffer, row: j)
					
				case 4:
					Success = read4BitRow(buffer, row: j)
					
				case 8:
					Success = read8BitRow(buffer, row: j)
					
				case 24:
					Success = read24BitRow(buffer, row: j)
					
				case 32:
					Success = read32BitRow(buffer, row: j)
					
				default:
					Success = false
				}
				if !Success {
					if EasyBMP.easyBMPwarnings {
						print("EasyBMP Error: Could not read enough pixel data!")
					}
					break
				}
			}
		} else {
			let DataBytes = width * 2
			let PaddingBytes = ( 4 - DataBytes % 4 ) % 4
			
			// set the default mask
			
			var BlueMask: UInt16 = 0x1F		// bits 12-16
			var GreenMask: UInt16 = 0x3E0	// bits 7-11
			var RedMask: UInt16 = 0x7C00	// bits 2-6
			
			// read the bit fields, if necessary, to
			// override the default 5-5-5 mask
			
			if bmih.biCompression != 0 {
				// read the three bit masks
								
				guard let aRedMask = data.readUInt16() else {
					//_=setSize(width: 1,height: 1)
					//_=setBitDepth(1)
					throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of file"])

				}
				RedMask = aRedMask
				if data.readUInt16() == nil {
					throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of file"])
				}
				
				guard let aGreenMask = data.readUInt16() else {
					throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of file"])
				}
				GreenMask = aGreenMask
				if data.readUInt16() == nil {
					throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of file"])
				}

				guard let aBlueMask = data.readUInt16() else {
					throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of file"])
				}
				BlueMask = aBlueMask
				if data.readUInt16() == nil {
					throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of file"])
				}
			}
			
			// read and skip any metadata
			
			if BytesToSkip > 0 {
				if EasyBMP.easyBMPwarnings {
					print("Extra metadata detected in data. Data will be skipped.")
				}
				guard data.add(toPosition: BytesToSkip) else {
					throw CocoaError(.fileReadCorruptFile, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of file"])
				}
			}
			
			// determine the red, green and blue shifts
			
			var GreenShift = 0
			var TempShiftWORD = GreenMask
			while TempShiftWORD > 31 {
				TempShiftWORD = TempShiftWORD >> 1
				GreenShift += 1
			}
			var BlueShift = 0
			TempShiftWORD = BlueMask
			while TempShiftWORD > 31  {
				TempShiftWORD = TempShiftWORD >> 1
				BlueShift += 1
			}
			var RedShift = 0
			TempShiftWORD = RedMask
			while TempShiftWORD > 31 {
				TempShiftWORD = TempShiftWORD >> 1
				RedShift += 1
			}
			
			// read the actual pixels
			
			outerLoop: for j in (0 ..< Int(height)).reversed() {
				var i = 0
				var ReadNumber = 0
				while ReadNumber < DataBytes  {
					guard let TempWORD = data.readUInt16() else {
						if EasyBMP.easyBMPwarnings {
							print("Unexpected end of file reached.")
						}
						break outerLoop
					}
					ReadNumber += 2
					
					let Red = RedMask & TempWORD
					let Green = GreenMask & TempWORD
					let Blue = BlueMask & TempWORD
					
					let BlueBYTE = UInt8(8*(Blue>>BlueShift))
					let GreenBYTE = UInt8(8*(Green>>GreenShift))
					let RedBYTE = UInt8(8*(Red>>RedShift))
					
					(pixels[i][j]).red = RedBYTE
					(pixels[i][j]).green = GreenBYTE
					(pixels[i][j]).blue = BlueBYTE
					
					i += 1
				}
				ReadNumber = 0
				while ReadNumber < PaddingBytes {
					guard data.add(toPosition: 1) else {
						if EasyBMP.easyBMPwarnings {
							print("Unexpected end of file reached.")
						}
						break outerLoop
					}
					ReadNumber += 1
				}
			}
		}
	}
}
