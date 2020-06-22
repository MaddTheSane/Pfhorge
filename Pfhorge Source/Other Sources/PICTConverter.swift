//
//  PICTConverter.swift
//  Pfhorge
//
//  Created by C.W. Betts on 6/4/20.
//  Code taken from Atque (credited to Gregory Smith) and adapted to Swift.
//  Original license follows.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as
//  published by the Free Software Foundation; either version 2 of the
//  License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  General Public License for more details.
//
//  This license is contained in the file "COPYING", which is included
//  with this source code; it is available online at
//  http://www.gnu.org/licenses/gpl.html
//

import Cocoa


private func PICTWrite<X: FixedWidthInteger>(_ toWrite: X, _ data: inout Data) {
	let arr = [toWrite.bigEndian]
	arr.withUnsafeBytes { (rbp) -> Void in
		data.append(Data(rbp))
	}
}

private func PICTWrite<X: RawRepresentable>(_ toWrite: X, _ data: inout Data)  where X.RawValue: FixedWidthInteger {
	let arr = [toWrite.rawValue.bigEndian]
	arr.withUnsafeBytes { (rbp) -> Void in
		data.append(Data(rbp))
	}
}

private func PICTWrite<X: Collection>(_ toWrite: X, _ data: inout Data)  where X.Element: FixedWidthInteger {
	let arr = toWrite.map({$0.bigEndian})
	arr.withUnsafeBytes { (rbp) -> Void in
		data.append(Data(rbp))
	}
}

private func PICTWrite(_ toWrite: UInt8, _ data: inout Data) {
	data.append(toWrite)
}

private func PICTWrite(_ toWrite: Int8, _ data: inout Data) {
	data.append(UInt8(bitPattern: toWrite))
}

class PICT {
	struct Rect {
		var top: Int16
		var left: Int16
		var bottom: Int16
		var right: Int16
		
		var height: Int16 {
			return bottom - top
		}
		var width: Int16 {
			return right - left
		}
		
		init() {
			top = 0
			left = 0
			bottom = 0
			right = 0
		}
		
		init(width: Int16, height: Int16) {
			top = 0
			left = 0
			bottom = height
			right = width
		}
		
		init?(data: PhData) {
			guard let aTop = data.readInt16(),
				let aLeft = data.readInt16(),
				let aBottom = data.readInt16(),
				let aRight = data.readInt16() else {
					return nil
			}
			top = aTop
			left = aLeft
			bottom = aBottom
			right = aRight
		}
		
		func save(to data: inout Data) {
			let dat = [top.bigEndian, left.bigEndian, bottom.bigEndian, right.bigEndian]
			let dat2 = dat.withUnsafeBytes { (buf) -> Data in
				return Data(buf)
			}
			data.append(contentsOf: dat2)
		}
	}

	
	enum OpCode: UInt16 {
		case noOp = 0
		case clippingRegion = 0x0001
		case bkPat = 0x0002
		case txFont = 0x0003
		case txFace = 0x0004
		case txMode = 0x0005
		case spExtra = 0x0006
		case pnSize = 0x0007
		case pnMode = 0x0008
		case pnPat = 0x0009
		case fillPat = 0x000a
		case ovSize = 0x000b
		case origin = 0x000c
		case txSize = 0x000d
		case fgColor = 0x000e
		case bgColor = 0x000f
		case txRatio = 0x0010
		case versionOp = 0x0011
		case bkPixPat = 0x0012
		case PnPixPat = 0x0013
		case fillPixPat = 0x0014
		case pnLocHFrac = 0x0015
		case chExtra = 0x0016
		
		/* 0x17 to 0x19 are reserved for Apple */
		
		case RGBFgCol = 0x001a
		case RGBBkCol = 0x001b
		case hiliteMode = 0x001c
		case hiliteColor = 0x001d
		case defHilite = 0x001e
		case opColor = 0x001f
		case line = 0x0020
		case lineFrom = 0x0021
		case shortLine = 0x0022
		case shortLineFrom = 0x0023
		
		/* 0x24 to 0x27 are reserved for Apple */
		
		case longText = 0x0028
		case dhText = 0x0029
		case dvText = 0x002a
		case DHDVText = 0x002b
		case fontName = 0x002c
		case lineJustify = 0x002d
		case glyphState = 0x002e
		
		/* 0x2f is reserved for Apple */
		
		case frameRect = 0x0030
		case paintRect = 0x0031
		case eraseRect = 0x0032
		case invertRect = 0x0033
		case fillRect = 0x0034
		
		/* 0x35 to 0x37 are reserved for Apple */
		
		case frameSameRect = 0x0038
		case paintSameRect = 0x0039
		case eraseSameRect = 0x003a
		case invertSameRect = 0x003b
		case fillSameRect = 0x003c
		
		/* 0x3D to 0x3F are reserved for Apple */
		
		case frameRRect = 0x0040
		case paintRRect = 0x0041
		case eraseRRect = 0x0042
		case invertRRect = 0x0043
		case fillRRect = 0x0044
		
		/* 0x45 to 0x47 are reserved for Apple */
		
		case frameSameRRect = 0x0048
		case paintSameRRect = 0x0049
		case eraseSameRRect = 0x004A
		case invertSameRRect = 0x004B
		case fillSameRRect = 0x004C
		
		/* 0x4d to 0x4f are reserved for Apple */
		
		case frameOval = 0x0050
		case paintOval = 0x0051
		case eraseOval = 0x0052
		case invertOval = 0x0053
		case fillOval = 0x0054
		
		/* 0x55 to 0x57 are reserved for Apple */
		
		case frameSameOval = 0x0058
		case paintSameOval = 0x0059
		case eraseSameOval = 0x005A
		case invertSameOval = 0x005B
		case fillSameOval = 0x005C
		
		/* 0x5d to 0x5f are reserved for Apple */
		
		case frameArc = 0x0060
		case paintArc = 0x0061
		case eraseArc = 0x0062
		case invertArc = 0x0063
		case fillArc = 0x0064
		
		/* 0x65 to 0x67 are reserved for Apple */
		
		case frameSameArc = 0x0068
		case paintSameArc = 0x0069
		case eraseSameArc = 0x006A
		case invertSameArc = 0x006B
		case fillSameArc = 0x006C
		
		/* 0x6d to 0x6f are reserved for Apple */
		
		case framePoly = 0x0070
		case paintPoly = 0x0071
		case erasePoly = 0x0072
		case invertPoly = 0x0073
		case fillPoly = 0x0074
		
		/* 0x75 to 0x77 are reserved for Apple */
		
		case frameSamePoly = 0x0078
		case paintSamePoly = 0x0079
		case eraseSamePoly = 0x007A
		case invertSamePoly = 0x007B
		case fillSamePoly = 0x007C
		
		/* 0x7d to 0x7f are reserved for Apple */
		
		case frameRgn = 0x0080
		case paintRgn = 0x0081
		case eraseRgn = 0x0082
		case invertRgn = 0x0083
		case fillRgn = 0x0084
		
		/* 0x85 to 0x87 are reserved for Apple */
		
		case frameSameRgn = 0x0088
		case paintSameRgn = 0x0089
		case eraseSameRgn = 0x008A
		case invertSameRgn = 0x008B
		case fillSameRgn = 0x008C
		
		/* 0x8d to 0x8f are reserved for Apple */
		
		case bitsRect = 0x0090
		case bitsRgn = 0x0091
		
		/* 0x92 to 0x97 are reserved for Apple */
		
		case packBitsRect = 0x0098
		case packBitsRgn = 0x0099
		case directBitsRect = 0x009A
		case directBitsRgn = 0x009B
		
		/* 0x9c to 0x9f are reserved for Apple */
		
		case shortComment = 0x00A0
		case longComment = 0x00A1
		
		/* 0xa2 to 0xfe are reserved for Apple */
		case opEndPic = 0x00ff
		
		
		/* 0x100 to 0x200 are reserved for Apple */
		
		case version = 0x02ff
		case headerOp = 0x0c00
		/// Compressed QuickTime image (we only handle JPEG compression)
		case compressedQuickTime = 0x8200
		
		case uncompressedQuickTime = 0x8201
		
		@available(*,deprecated, renamed: "packBitsRect")
		static var packedCopyBits: OpCode {
			return OpCode(rawValue: 0x0098)!
		}
		@available(*,deprecated, renamed: "packBitsRgn")
		static var packedCopyBitsClipping: OpCode {
			return OpCode(rawValue: 0x0099)!
		}
		@available(*,deprecated, renamed: "directBitsRect")
		static var directCopyBits: OpCode {
			return OpCode(rawValue: 0x009a)!
		}
		@available(*,deprecated, renamed: "directBitsRgn")
		static var directCopyBitsClipping: OpCode {
			return OpCode(rawValue: 0x009b)!
		}
		@available(*,deprecated, renamed: "compressedQuickTime")
		static var qtCompressed: OpCode {
			return OpCode(rawValue: 0x8200)!
		}
	}
	
	struct HeaderOp {
		var headerOp: Int16 = 0x0c00
		var headerVersion: UInt16
		var reserved1: Int16
		var hRes: Int32
		var vRes: Int32
		var srcRect: Rect
		var reserved2: Int32
		
		init() {
			headerOp = 0x0c00
			headerVersion = 0xfffe
			reserved1 = 0
			hRes = 72 << 16
			vRes = 72 << 16
			srcRect = Rect()
			reserved2 = 0
		}
		
		init?(data: PhData) {
			guard let aheaderVersion = data.readUInt16(),
				let areserved1 = data.readInt16(),
				let ahRes = data.readInt32(),
				let avRes = data.readInt32(),
				let asrcRect = Rect(data: data),
				let areserved2 = data.readInt32() else {
					return nil
			}
			headerVersion = aheaderVersion
			reserved1 = areserved1
			hRes = ahRes
			vRes = avRes
			srcRect = asrcRect
			reserved2 = areserved2
		}
		
		func save(to data: inout Data) {
			var tmpData = Data(capacity: 26)
			let dat1 = [headerOp.bigEndian, Int16(bitPattern: headerVersion).bigEndian, reserved1.bigEndian]
			dat1.withUnsafeBytes { (buf) -> Void in
				tmpData.append(Data(buf))
			}
			let dat2 = [hRes.bigEndian, vRes.bigEndian]
			dat2.withUnsafeBytes { (buf) -> Void in
				tmpData.append(Data(buf))
			}
			srcRect.save(to: &tmpData)
			let dat3 = [reserved2.bigEndian]
			dat3.withUnsafeBytes { (buf) -> Void in
				tmpData.append(Data(buf))
			}
			
			data.append(tmpData)
		}
	}
	
	struct PixMap {
		var rowBytes: Int16
		var bounds: Rect
		var version: Int16
		var packType: Int16
		var packSize: UInt32
		var hRes: UInt32
		var vRes: UInt32
		var pixelType: Int16
		var pixelSize: Int16
		var cmpCount: Int16
		var cmpSize: Int16
		var planeBytes: UInt32
		var table: UInt32
		var reserved: UInt32
		
		init?(data: PhData) {
			guard let arowBytes = data.readInt16(),
				let abounds = Rect(data: data),
				let aversion = data.readInt16(),
				let apackType = data.readInt16(),
				let apackSize = data.readUInt32(),
				let ahRes = data.readUInt32(),
				let avRes = data.readUInt32(),
				let apixelType = data.readInt16(),
				let apixelSize = data.readInt16(),
				let acmpCount = data.readInt16(),
				let acmpSize = data.readInt16(),
				let aplaneBytes = data.readUInt32(),
				let atable = data.readUInt32(),
				let areserved = data.readUInt32() else {
					return nil
			}
			rowBytes = arowBytes
			bounds = abounds
			version = aversion
			packType = apackType
			packSize = apackSize
			hRes = ahRes
			vRes = avRes
			pixelType = apixelType
			pixelSize = apixelSize
			cmpCount = acmpCount
			cmpSize = acmpSize
			planeBytes = aplaneBytes
			table = atable
			reserved = areserved
		}
		
		func save(to data: inout Data) {
			var tmpData = Data(capacity: MemoryLayout<PixMap>.size)
			let dat1 = [rowBytes.bigEndian]
			dat1.withUnsafeBytes { (buf) -> Void in
				tmpData.append(Data(buf))
			}
			bounds.save(to: &tmpData)
			let dat2 = [version.bigEndian, packType.bigEndian]
			dat2.withUnsafeBytes { (buf) -> Void in
				tmpData.append(Data(buf))
			}
			let dat3 = [packSize.bigEndian, hRes.bigEndian, vRes.bigEndian]
			dat3.withUnsafeBytes { (buf) -> Void in
				tmpData.append(Data(buf))
			}
			let dat4 = [pixelType.bigEndian, pixelSize.bigEndian, cmpCount.bigEndian, cmpSize.bigEndian]
			dat4.withUnsafeBytes { (buf) -> Void in
				tmpData.append(Data(buf))
			}
			let dat5 = [planeBytes.bigEndian, table.bigEndian, reserved.bigEndian]
			dat5.withUnsafeBytes { (buf) -> Void in
				tmpData.append(Data(buf))
			}
			data.append(tmpData)
		}
		
		init(depth: Int16, rowBytes rowBytes_: Int16) {
			rowBytes = rowBytes_ | Int16(bitPattern: 0x8000)
			version = 0
			packType = 0
			packSize = 0
			hRes = 72 << 16
			vRes = 72 << 16
			pixelSize = depth
			planeBytes = 0
			table = 0
			reserved = 0
			
			if depth == 8 {
				pixelType = 0
				cmpSize = 8
				cmpCount = 1
			} else if depth == 16 {
				pixelType = 0x10
				cmpSize = 5
				cmpCount = 3
			} else {
				pixelType = 0x10
				cmpSize = 8
				cmpCount = 3
			}
			bounds = Rect()
		}
	}
	
	private var jpegData = Data()
	private var bitmap = EasyBMP()

	private func loadCopyBits(_ stream: PhData, packed: Bool, clipped: Bool) -> Bool {
		if (!packed) {
			stream.add(toPosition: 4) // pmBaseAddr
		}

		guard var rowBytes = stream.readUInt16() else {
			return false
		}
		let isPixmap = (rowBytes & 0x8000) == 0x8000
		rowBytes &= 0x3fff
		guard let rect = Rect(data: stream) else {
			return false
		}
		
		let width = rect.width
		let height = rect.height
		var pack_type: UInt16
		var pixel_size: UInt16
		if isPixmap {
			guard stream.add(toPosition: 2) else { // pmVersion
				return false
			}
			guard let tmpVal = stream.readUInt16() else {
				return false
			}
			pack_type = tmpVal
			guard stream.add(toPosition: 14) else { // packSize/hRes/vRes/pixelType
				return false
			}
			guard let tmpVal2 = stream.readUInt16() else {
				return false
			}
			pixel_size = tmpVal2
			guard stream.add(toPosition: 16) else {// cmpCount/cmpSize/planeBytes/pmTable/pmReserved
				return false
			}
		} else {
			pack_type = 0
			pixel_size = 1
		}
		
		_=bitmap.setSize(width: Int32(width), height: Int32(height))
		if (pixel_size <= 8) {
			_=bitmap.setBitDepth(8)
		} else {
			_=bitmap.setBitDepth(Int32(pixel_size))
		}

		// read the color table
		if isPixmap && packed {
			stream.add(toPosition: 4) // ctSeed
			guard let flags = stream.readUInt16(),
				var num_colors = stream.readUInt16() else {
					return false
			}
			num_colors += 1
			for i in 0 ..< num_colors {
				guard var index: UInt16 = stream.readUInt16(),
				let red: UInt16 = stream.readUInt16(),
				let green: UInt16 = stream.readUInt16(),
					let blue: UInt16 = stream.readUInt16() else {
						return false
				}

				if (flags & 0x8000) != 0 {
					index = i
				} else {
					index &= 0xff
				}

				let pixel = EasyBMP.RGBAPixel(blue: UInt8(blue >> 8), green: UInt8(green >> 8), red: UInt8(red >> 8), alpha: 0xff)
				_=bitmap.setColor(at: Int(index), to: pixel)
			}
			
			// src/dst/transfer mode
			stream.add(toPosition: 18)
			
			// clipping region
			if clipped {
				guard let size = stream.readUInt16() else {
					return false
				}
				stream.add(toPosition: Int(size - 2))
			}
			// the picture itself
			if pixel_size <= 8 {
				for y in 0 ..< Int(height) {
					var scanLine = [UInt8]()
					if rowBytes < 8 {
						scanLine.reserveCapacity(Int(rowBytes))
						for _ in 0 ..< rowBytes {
							guard let line = stream.readUInt8() else {
								return false
							}
							scanLine.append(line)
						}
					} else {
						guard let slTmp = unpackRow8(stream, rowBytes: Int(rowBytes)) else {
							return false
						}
						scanLine = slTmp
					}
					
					if (pixel_size == 8) {
						for x in 0 ..< Int(width) {
							_=bitmap.setPixel(atX: x, y: y, bitmap.getColor(at: Int(scanLine[x]))!)
						}
					} else {
						let pixels = expandPixels(from: scanLine, depth: Int(pixel_size))
						
						for x in 0 ..< Int(width) {
							_=bitmap.setPixel(atX: x, y: y, bitmap.getColor(at: Int(pixels[x]))!)
						}
					}

				}
			} else if (pixel_size == 16) {
				for y in 0 ..< Int(height) {
					var scan_line = [UInt16]()
					if rowBytes < 8 || pack_type == 1 {
						for _ in 0 ..< Int(width) {
							guard let line = stream.readUInt16() else {
								return false
							}
							scan_line.append(line)
						}
					} else if (pack_type == 0 || pack_type == 3) {
						guard let tmpSl = unpackRow16(stream, rowBytes: Int(rowBytes)) else {
							return false
						}
						scan_line = tmpSl
					}

					for x in 0 ..< Int(width) {
						var pixel = EasyBMP.RGBAPixel()
						pixel.red = UInt8((scan_line[x] >> 10) & 0x1f)
						pixel.green = UInt8((scan_line[x] >> 5) & 0x1f)
						pixel.blue = UInt8(scan_line[x] & 0x1f)
						pixel.red = (pixel.red * 255 + 16) / 31
						pixel.green = (pixel.green * 255 + 16) / 31
						pixel.blue = (pixel.blue * 255 + 16) / 31
						pixel.alpha = 0xff
						
						_=bitmap.setPixel(atX: x, y: y, pixel)
					}
				}
			} else if (pixel_size == 32) {
				for y in 0 ..< Int(height) {
					var scan_line = [UInt8]()
					if rowBytes < 8 || pack_type == 1 {
						scan_line = Array(repeating: 0, count: Int(width) * 3)// .reserveCapacity(Int(width) * 3);
						for x in 0 ..< Int(width) {
							guard let pixel = stream.readUInt32() else {
								return false
							}
							scan_line[x] = UInt8(pixel >> 16)
							scan_line[x + Int(width)] = UInt8((pixel >> 8) & 0xff)
							scan_line[x + Int(width) * 2] = UInt8(pixel & 0xFF)
						}
					} else if pack_type == 0 || pack_type == 4 {
						guard let tmpSL = unpackRow8(stream, rowBytes: Int(rowBytes)) else {
							return false
						}
						scan_line = tmpSL
					}

					for x in 0 ..< Int(width) {
						var pixel = EasyBMP.RGBAPixel()
						pixel.red = scan_line[x]
						pixel.green = scan_line[x + Int(width)]
						pixel.blue = scan_line[x + Int(width) * 2]
						pixel.alpha = 0xff
						_=bitmap.setPixel(atX: x, y: y, pixel)
					}
				}
			}
		}
		
		if (stream.currentPosition & 1) != 0 {
			stream.add(toPosition: 1)
		}
		return true
	}
	
	func load(from: URL) throws {
		let preData = try Data(contentsOf: from)

		try load(from: preData)
	}
	
	func load(from preData: Data) throws {
		let data = PhData(data: preData)
		jpegData.removeAll()
		
		guard let /*size*/ _ = data.readUInt16(),
			let rect = Rect(data: data) else {
				throw CocoaError(.fileReadCorruptFile)
		}
		
		var done = false
		while done == false {
			guard let preOpcode = data.readUInt16() else {
				throw CocoaError(.fileReadCorruptFile)
			}
			if let opcode = PICT.OpCode(rawValue: preOpcode) {
				switch opcode {
				case .opEndPic:
					done = true
					
				case .noOp, .versionOp, .hiliteMode, .defHilite, .frameSameRect, .paintSameRect, .eraseSameRect, .invertSameRect, .fillSameRect, .version:
					break
					
				case .clippingRegion:
					guard var size = data.readUInt16() else {
						throw PICTConversionError.unexpectedEndOfStream
					}
					if ((size & 1) != 0) {
						size += 1
					}
					data.add(toPosition: Int(size - 2))
					
				case .txFont, .txFace, .txMode, .pnMode, .txSize, .pnLocHFrac, .chExtra, .shortLineFrom, .shortComment:
					data.add(toPosition: 2)
					
				case .spExtra, .pnSize, .ovSize, .origin, .fgColor, .bgColor, .lineFrom:
					data.add(toPosition: 4)
					
				case .RGBFgCol, .RGBBkCol, .hiliteColor, .opColor, .shortLine:
					data.add(toPosition: 6)
					
				case .bkPat, .pnPat, .fillPat, .txRatio, .line, .frameRect, .paintRect, .eraseRect, .invertRect, .fillRect:
					data.add(toPosition: 8)
					
				case .headerOp:
					guard let /*headerOp*/ _ = PICT.HeaderOp(data: data) else {
						throw PICTConversionError.unexpectedEndOfStream
					}
					
				case .longComment:
					data.add(toPosition: 2)
					guard var size = data.readInt16() else {
						throw PICTConversionError.unexpectedEndOfStream
					}
					if (size & 1) != 0 {
						size += 1
					}
					guard data.add(toPosition: Int(size)) else {
						throw PICTConversionError.unexpectedEndOfStream
					}
					
				case .packBitsRect, .packBitsRgn, .directBitsRect, .directBitsRgn:
					let packed = (opcode == .packBitsRect || opcode == .packBitsRgn)
					let clipped = (opcode == .packBitsRgn || opcode == .directBitsRgn)
					guard loadCopyBits(data, packed: packed, clipped: clipped) else {
						throw PICTConversionError.unexpectedEndOfStream
					}
					if jpegData.count != 0 {
						_=bitmap.setSize(width: 1, height: 1)
					} else if (bitmap.width != rect.width && bitmap.width == 614) {
						throw PICTConversionError.usesCinemascopeHack
					}
					
				case .compressedQuickTime:
					if jpegData.count != 0 {
						throw PICTConversionError.containsBandedJPEG
					}
					try loadJPEG(data, to: &jpegData)
					
				default:
					if preOpcode >= 0x0300 && preOpcode < 0x8000 {
						data.add(toPosition: Int(preOpcode >> 8) * 2)
					} else if preOpcode >= 0x8000 && preOpcode < 0x8100 {
						break
					} else {
						throw PICTConversionError.unimplementedOpCode(preOpcode)
					}
				}
			} else {
				if preOpcode >= 0x0300 && preOpcode < 0x8000 {
					data.add(toPosition: Int(preOpcode >> 8) * 2)
				} else if preOpcode >= 0x8000 && preOpcode < 0x8100 {
					//break
				} else {
					throw PICTConversionError.unimplementedOpCode(preOpcode)
				}
			}
		}
	}
	
	func load(from preData: Data, clut: Data) throws {
		let stream = PhData(data: preData)
		guard let rect = Rect(data: stream) else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		let height = rect.height
		let width = rect.width
		guard let depth = stream.readInt16() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		
		switch depth {
		case 8:
			_=bitmap.setBitDepth(Int32(depth))
			_=bitmap.setSize(width: Int32(width), height: Int32(height))

			guard clut.count == 6 + 256 * 6 else {
				throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
			}
			let clut_stream = PhData(data: clut)
			for i in 0 ..< 256 {
				let red = clut_stream.readInt16()!
				let green = clut_stream.readInt16()!
				let blue = clut_stream.readInt16()!
				
				let color = EasyBMP.RGBAPixel(blue: UInt8(blue >> 8), green: UInt8(green >> 8), red: UInt8(red >> 8), alpha: 0xff)
				_=bitmap.setColor(at: i, to: color)
			}
			
			for y in 0 ..< Int(height) {
				for x in 0 ..< Int(width) {
					guard let pixel = stream.readUInt8() else {
						throw PICTConversionError.unexpectedEndOfStream
					}
					_=bitmap.setPixel(atX: x, y: y, bitmap.getColor(at: Int(pixel))!)
				}
			}
			
		case 16:
			_=bitmap.setBitDepth(Int32(depth))
			_=bitmap.setSize(width: Int32(width), height: Int32(height))

			for y in 0 ..< Int(height) {
				for x in 0 ..< Int(width) {
					guard let color = stream.readUInt16() else {
						throw PICTConversionError.unexpectedEndOfStream
					}
					var pixel = EasyBMP.RGBAPixel()
					pixel.red = UInt8((color >> 10) & 0x1f)
					pixel.green = UInt8((color >> 5) & 0x1f)
					pixel.blue = UInt8(color & 0x1f)
					pixel.red = UInt8((UInt16(pixel.red) * 255 + 16) / 31)
					pixel.green = UInt8((UInt16(pixel.green) * 255 + 16) / 31)
					pixel.blue = UInt8((UInt16(pixel.blue) * 255 + 16) / 31)
					pixel.alpha = 0xff
					_=bitmap.setPixel(atX: x, y: y, pixel)
				}
			}

		default:
			throw NSError(domain: NSCocoaErrorDomain, code: NSFileReadCorruptFileError, userInfo: nil)
		}
	}
	
	private func loadJPEG(_ data: PhData, to: inout Data) throws {
		guard var opcodeSize = data.readUInt32() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		if (opcodeSize & 1) != 0 {
			opcodeSize += 1
		}
		
		let opcodeStart = data.currentPosition
		guard data.add(toPosition: 26) else {// version/matrix (hom. part)
			throw PICTConversionError.unexpectedEndOfStream
		}
		guard let offsetX = data.readInt16() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		guard data.add(toPosition: 2) else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		guard let offsetY = data.readInt16() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		guard data.add(toPosition: 2) else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		guard data.add(toPosition: 4) else {// rest of matrix
			throw PICTConversionError.unexpectedEndOfStream
		}
		guard offsetX == 0, offsetY == 0 else {
			throw PICTConversionError.containsBandedJPEG
		}
		
		guard let matteSize = data.readUInt32() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		guard data.add(toPosition: 22) else { // matte rect/srcRect/accuracy
			throw PICTConversionError.unexpectedEndOfStream
		}
		
		guard let maskSize = data.readUInt32() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		
		if matteSize != 0 {
			guard let matte_id_size = data.readUInt32() else {
				throw PICTConversionError.unexpectedEndOfStream
			}
			data.add(toPosition: Int(matte_id_size - 4))
		}
		
		data.add(toPosition: Int(matteSize))
		data.add(toPosition: Int(maskSize))
		
		guard let _/*idSize*/ = data.readUInt32(),
			let codecType = data.readUInt32(),
			codecType == PhJPEGCodecID else {
				throw PICTConversionError.unsupportedQuickTimeCodec
		}
		
		guard data.add(toPosition: 36) else { // resvd1/resvd2/dataRefIndex/version/revisionLevel/vendor/temporalQuality/spatialQuality/width/height/hRes/vRes
			throw PICTConversionError.unexpectedEndOfStream
		}
		guard let dataSize = data.readUInt32() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		guard data.add(toPosition: 38) else {// frameCount/name/depth/clutID
			throw PICTConversionError.unexpectedEndOfStream
		}
		
		guard let subDat = data.getSubData(withLength: Int(dataSize)) else {
			data.add(toPosition: opcodeStart + Int(opcodeSize) - data.currentPosition)
			throw PICTConversionError.unexpectedEndOfStream
		}
		to = subDat
		
		data.add(toPosition: opcodeStart + Int(opcodeSize) - data.currentPosition)
	}

	static func convertPICT(from: URL, to format: PhPictConversion.BinaryFormat = .best) throws -> (format: PhPictConversion.BinaryFormat, data: Data) {
		let preData = try Data(contentsOf: from)
		return try convertPICT(from: preData, to: format)
	}
	
	static func convertPICT(from: Data, to format: PhPictConversion.BinaryFormat = .best) throws -> (format: PhPictConversion.BinaryFormat, data: Data) {
		let aPict = PICT()
		try aPict.load(from: from)
		if aPict.jpegData.count != 0 && (format == .best || format == .JPEG) {
			return (.JPEG, aPict.jpegData)
		}
		if (aPict.bitmap.bitDepth <= 8 && format == .best) || format == .bitmap {
			return (.bitmap, aPict.bitmap.generateData())
		}
		if (aPict.bitmap.bitDepth > 8 && format == .best) || format == .PNG {
			//Hackity-hack!
			let dat = aPict.bitmap.generateData()
			guard let bmpImgRep = NSBitmapImageRep(data: dat),
				let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
					// brute force!
					guard let bir = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(aPict.bitmap.width), pixelsHigh: Int(aPict.bitmap.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bitmapFormat: NSBitmapImageRep.Format.alphaFirst, bytesPerRow: Int(aPict.bitmap.width)*4, bitsPerPixel: 32) else {
						throw PICTConversionError.conversionFailed
					}
					for i in 0 ..< Int(aPict.bitmap.width) {
						autoreleasepool {
							for j in 0 ..< Int(aPict.bitmap.height) {
								let pixCol = aPict.bitmap.getPixel(atX: i, y: j)
								let col = NSColor(calibratedRed: CGFloat(pixCol.red) / CGFloat(UInt8.max), green: CGFloat(pixCol.green) / CGFloat(UInt8.max), blue: CGFloat(pixCol.blue) / CGFloat(UInt8.max), alpha: 1)
								bir.setColor(col, atX: i, y: j)
							}
						}
					}
					guard let dat = bir.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
						throw PICTConversionError.conversionFailed
					}
					return (.PNG, dat)
			}
			return (.PNG, pngDat)
		}
		switch format {
		case .bitmap:
			if aPict.jpegData.count != 0 {
				if let bmpImgRep = NSBitmapImageRep(data: aPict.jpegData),
					let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.bmp, properties: [:]) {
					return (.bitmap, pngDat)
				}
			}
			return (.bitmap, aPict.bitmap.generateData())

		case .JPEG:
			if aPict.jpegData.count != 0 {
				return (.JPEG, aPict.jpegData)
			}
			
			if let bmpImgRep = NSBitmapImageRep(data: aPict.bitmap.generateData()),
				let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:]) {
				return (.JPEG, pngDat)
			}

			throw PICTConversionError.conversionFailed

		case .PNG:
			if aPict.jpegData.count != 0 {
				if let bmpImgRep = NSBitmapImageRep(data: aPict.jpegData),
					let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) {
					return (.PNG, pngDat)
				}
			}

			guard let bmpImgRep = NSBitmapImageRep(data: aPict.bitmap.generateData()),
				let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
					throw PICTConversionError.conversionFailed
			}
			return (.PNG, pngDat)

			
		default:
			throw NSError(domain: NSOSStatusErrorDomain, code: paramErr)
		}
	}
	
	static func convertRawPICT(from: Data, clut: Data, to format: PhPictConversion.BinaryFormat = .best) throws -> (format: PhPictConversion.BinaryFormat, data: Data) {
		let aPict = PICT()
		try aPict.load(from: from, clut: clut)
		if aPict.jpegData.count != 0 && (format == .best || format == .JPEG) {
			return (.JPEG, aPict.jpegData)
		}
		if (aPict.bitmap.bitDepth <= 8 && format == .best) || format == .bitmap {
			return (.bitmap, aPict.bitmap.generateData())
		}
		if (aPict.bitmap.bitDepth > 8 && format == .best) || format == .PNG {
			//Hackity-hack!
			let dat = aPict.bitmap.generateData()
			guard let bmpImgRep = NSBitmapImageRep(data: dat),
				let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
					// brute force!
					guard let bir = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(aPict.bitmap.width), pixelsHigh: Int(aPict.bitmap.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bitmapFormat: NSBitmapImageRep.Format.alphaFirst, bytesPerRow: Int(aPict.bitmap.width)*4, bitsPerPixel: 32) else {
						throw PICTConversionError.conversionFailed
					}
					for i in 0 ..< Int(aPict.bitmap.width) {
						autoreleasepool {
							for j in 0 ..< Int(aPict.bitmap.height) {
								let pixCol = aPict.bitmap.getPixel(atX: i, y: j)
								let col = NSColor(calibratedRed: CGFloat(pixCol.red) / CGFloat(UInt8.max), green: CGFloat(pixCol.green) / CGFloat(UInt8.max), blue: CGFloat(pixCol.blue) / CGFloat(UInt8.max), alpha: 1)
								bir.setColor(col, atX: i, y: j)
							}
						}
					}
					guard let dat = bir.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
						throw PICTConversionError.conversionFailed
					}
					return (.PNG, dat)
			}
			return (.PNG, pngDat)
		}
		switch format {
		case .bitmap:
			if aPict.jpegData.count != 0 {
				if let bmpImgRep = NSBitmapImageRep(data: aPict.jpegData),
					let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.bmp, properties: [:]) {
					return (.bitmap, pngDat)
				}
			}
			return (.bitmap, aPict.bitmap.generateData())

		case .JPEG:
			if aPict.jpegData.count != 0 {
				return (.JPEG, aPict.jpegData)
			}
			
			if let bmpImgRep = NSBitmapImageRep(data: aPict.bitmap.generateData()),
				let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:]) {
				return (.JPEG, pngDat)
			}

			throw PICTConversionError.conversionFailed

		case .PNG:
			if aPict.jpegData.count != 0 {
				if let bmpImgRep = NSBitmapImageRep(data: aPict.jpegData),
					let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) {
					return (.PNG, pngDat)
				}
			}

			guard let bmpImgRep = NSBitmapImageRep(data: aPict.bitmap.generateData()),
				let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
					throw PICTConversionError.conversionFailed
			}
			return (.PNG, pngDat)

			
		default:
			throw NSError(domain: NSOSStatusErrorDomain, code: paramErr)
		}
	}

	enum PICTConversionError: Error, RawRepresentable {
		init?(rawValue: Int) {
			switch rawValue {
			case 1:
				self = .unimplementedOpCode(0)
				
			case 2:
				self = .containsBandedJPEG
				
			case 3:
				self = .usesCinemascopeHack
				
			case 4:
				self = .unsupportedQuickTimeCodec
				
			case 5:
				self = .unexpectedEndOfStream
				
			case 6:
				self = .conversionFailed
								
			default:
				let op = rawValue >> 8
				guard (rawValue & 0xf) == 1,
					let op2 = UInt16(exactly: op) else {
						return nil
				}
				self = .unimplementedOpCode(op2)
			}
		}
		
		typealias RawValue = Int
		
		var rawValue: Int {
			switch self {
			case .unimplementedOpCode(let oc):
				return Int(oc) << 8 | 1
				
			case .containsBandedJPEG:
				return 2
				
			case .usesCinemascopeHack:
				return 3
				
			case .unsupportedQuickTimeCodec:
				return 4
				
			case .unexpectedEndOfStream:
				return 5
				
			case .conversionFailed:
				return 6
			}
		}
		
		var localizedDescription: String {
			switch self {
			case .unimplementedOpCode(let oc):
				return String(format: "Unimplemented OpCode %02d", oc)
				
			case .containsBandedJPEG:
				return "Contains Banded JPEG"
				
			case .usesCinemascopeHack:
				return "Uses CinemaScope Hack"
				
			case .unsupportedQuickTimeCodec:
				return "Contains Unknown or Unsupported Codec"
				
			case .unexpectedEndOfStream:
				return "Unexpected End of File"
				
			case .conversionFailed:
				return "Converting to anonther bitmap format failed"
			}
		}
		
		case unimplementedOpCode(_ opCode: UInt16)
		case containsBandedJPEG
		case usesCinemascopeHack
		case unsupportedQuickTimeCodec
		case unexpectedEndOfStream
		case conversionFailed
	}
	
	private func saveJPEG() -> Data? {
		var result = Data()
		
		guard let (width, height) = parseJPEGDimensions(jpegData) else {
			return nil
		}
		
		// size(2), rect(8), versionOp(2), version(2), headerOp(26), clip(12)
		var output_length = 10 + 2 + 2 + 26 + 12

		// PICT opcode
		output_length += 76
		
		// image description
		output_length += 86

		output_length += jpegData.count

		// end opcode
		output_length += 2

		if (output_length & 1) != 0 {
			output_length += 1
		}
		
		result.reserveCapacity(output_length)

		
		let size: Int16 = 0
		let clipRect = Rect(width: width, height: height)
		PICTWrite(size, &result)
		clipRect.save(to: &result)

		
		let versionOp = OpCode.versionOp
		let version: Int16 = 0x02ff
		PICTWrite(versionOp, &result)
		PICTWrite(version, &result)

		var headerOp = HeaderOp()
		headerOp.srcRect = clipRect
		headerOp.save(to: &result)

		let clip = OpCode.clippingRegion
		let clipSize: Int16 = 10
		PICTWrite(clip, &result)
		PICTWrite(clipSize, &result)
		clipRect.save(to: &result)

		let opcode = OpCode.compressedQuickTime
		let opcode_size: UInt32 = UInt32(154 + jpegData.count)
		PICTWrite(opcode, &result)
		PICTWrite(opcode_size, &result)

		result.append(contentsOf: [0, 0]) // version
		var matrix = [Int16](repeating: 0, count: 18)
		matrix[0] = 1
		matrix[8] = 1
		matrix[16] = 0x4000

		PICTWrite(matrix, &result)
		
		
		result.append(contentsOf: Array(repeating: 0, count: 4)) // matte size
		result.append(contentsOf: Array(repeating: 0, count: 8)) // matte rect
		
		let transfer_mode = OpCode.frameRRect
		PICTWrite(transfer_mode, &result)
		clipRect.save(to: &result)
		let accuracy: uint32 = 768
		PICTWrite(accuracy, &result)
		result.append(contentsOf: Array(repeating: 0, count: 4)) // mask size
		
		let id_size: UInt32 = 86
		let codec_type = PhJPEGCodecID
		PICTWrite(id_size, &result)
		PICTWrite(codec_type, &result)
		result.append(contentsOf: Array(repeating: 0, count: 8)) // rsrvd1, rsrvd2, dataRefIndex
		result.append(contentsOf: Array(repeating: 0, count: 4)) // revision, revisionLevel
		result.append(contentsOf: Array(repeating: 0, count: 4)) // vendor
		result.append(contentsOf: Array(repeating: 0, count: 4)) // temporalQuality
		let res: UInt32 = 72 << 16
		PICTWrite(accuracy, &result) // spatialQuality
		PICTWrite(width, &result)
		PICTWrite(height, &result)
		PICTWrite(res, &result) // hRes
		PICTWrite(res, &result) // vRes

		let data_size: UInt32 = UInt32(jpegData.count)
		let frame_count: UInt16 = 1
		PICTWrite(data_size, &result)
		PICTWrite(frame_count, &result)
		result.append(contentsOf: Array(repeating: 0, count: 32)) // name
		let depth: Int16 = 32
		let clut_id: Int16 = -1
		PICTWrite(depth, &result)
		PICTWrite(clut_id, &result)

		result.append(jpegData)

		if (result.count & 1) == 1 {
			result.append(0)
		}

		PICTWrite(OpCode.opEndPic, &result)


		return result
	}
	
	/// saves a PICT
	func save(toData: ()) throws -> Data {
		if bitmap.height != 1 || bitmap.width != 1 {
			return try saveBMP()
		} else if jpegData.count != 0 {
			guard let jpeg = saveJPEG() else {
				throw NSError(domain: NSCocoaErrorDomain, code: NSFileWriteUnknownError, userInfo: nil)
			}
			return jpeg
		}
		
		//last attempt
		return try saveBMP()
	}
	
	func save(to: URL) throws {
		let dat = try save(toData: ())
		try dat.write(to: to)
	}
	
	private func saveBMP() throws -> Data {
		var result = Data()
		var depth = bitmap.bitDepth
		let width = bitmap.width
		let height = bitmap.height
		if depth < 8 {
			depth = 8
		} else if depth == 24 {
			depth = 32
		}

		// size(2), rect(8), versionOp(2), version(2), headerOp(26), clip(12)
		var output_length = 10 + 2 + 2 + 26 + 12

		var row_bytes: Int32
		if depth == 8 {
			row_bytes = width
			// opcode(2), pixmap(46), colorTable(8+256*8), srcRect/dstRect/mode(18)
			output_length += 2 + 26 + 8 + 256 * 8 + 18
		} else {
			row_bytes = width * (depth == 16 ? 2 : 4)
			// opcode(2), pmBaseAddr(4), pixmap(46), srcRect/dstRect/mode(18)
			output_length += 2 + 4 + 26 + 18
		}
		
		// data is variable--allocate twice what we need
		output_length += Int(height * row_bytes * 2)
		result.reserveCapacity(output_length)

		let size: Int16 = 0
		let clipRect = Rect(width: Int16(width), height: Int16(height))
		PICTWrite(size, &result)
		clipRect.save(to: &result)

		let versionOp = OpCode.versionOp
		let version: Int16 = 0x02ff
		
		PICTWrite(versionOp, &result)
		PICTWrite(version, &result)

		var headerOp = HeaderOp()
		headerOp.srcRect = clipRect
		headerOp.save(to: &result)
		let clip = OpCode.clippingRegion
		let clipSize: Int16 = 10
		PICTWrite(clip, &result)
		PICTWrite(clipSize, &result)

		clipRect.save(to: &result)

		var pixMap = PixMap(depth: Int16(depth), rowBytes: Int16(row_bytes))
		pixMap.bounds = clipRect
		pixMap.save(to: &result)

		// color table
		if depth == 8 {
			let seed: Int32 = 0
			let flags: Int16 = 0
			let size: Int16 = 255
			PICTWrite(seed, &result)
			PICTWrite(flags, &result)
			PICTWrite(size, &result)


			for index in 0 ..< Int16(256) {
				let pixel = bitmap.getColor(at: Int(index))!
				let red = UInt16(pixel.red) << 8
				let green = UInt16(pixel.green) << 8
				let blue = UInt16(pixel.blue) << 8
				PICTWrite(index, &result)
				PICTWrite(red, &result)
				PICTWrite(green, &result)
				PICTWrite(blue, &result)
			}
		}
		
		// source
		clipRect.save(to: &result)
		// destination
		clipRect.save(to: &result)

		let transfer_mode: Int16 = 0
		PICTWrite(transfer_mode, &result)

		var color_map = [EasyBMP.RGBAPixel: UInt8]() // for faster saving of 8-bit images
		if depth == 8 {
			for i in (0...UInt8(255)).reversed() {
				color_map[bitmap.getColor(at: Int(i))!] = i
			}
		}
		
		for y in 0 ..< Int(height) {
			var scan_line: Data
			if depth == 8 {
				var pixels = [UInt8]()
				
				for x in 0 ..< Int(width) {
					let aPix = color_map[bitmap.getPixel(atX: x, y: y)] ?? 0
					pixels.append(aPix)
				}
				scan_line = packRow(pixels)
			} else if depth == 16 {
				var pixels = [UInt16]()
				pixels.reserveCapacity(Int(width))
				for x in 0 ..< Int(width) {
					let red: UInt16 = UInt16(bitmap.getPixel(atX: x, y: y).red >> 3)
					let green: UInt16 = UInt16(bitmap.getPixel(atX: x, y: y).green >> 3)
					let blue: UInt16 = UInt16(bitmap.getPixel(atX: x, y: y).blue >> 3)
					pixels.append((red << 10) | (green << 5) | blue)
				}

				scan_line = packRow(pixels)
			} else {
				var pixels = [UInt8](repeating: 0, count: Int(width) * 3)
				for x in 0 ..< Int(width) {
					let thePix = bitmap.getPixel(atX: x, y: y)
					pixels[x] = thePix.red
					pixels[x + Int(width)] = thePix.green
					pixels[x + Int(width * 2)] = thePix.blue
				}

				scan_line = packRow(pixels)
			}
			
			if row_bytes > 250 {
				PICTWrite(UInt16(scan_line.count), &result)
			} else {
				PICTWrite(UInt8(scan_line.count), &result)
			}
			result.append(scan_line)
		}
		
		if (result.count & 1) != 0 {
			result.append(0)
		}

		PICTWrite(OpCode.opEndPic, &result)

		return result
	}
	
	func importData(from: URL) throws {
		let resVal = try from.resourceValues(forKeys: [.typeIdentifierKey])
		switch resVal.typeIdentifier! {
		case (kUTTypeBMP as NSString as String):
			let dataB = try Data(contentsOf: from)
			try bitmap.read(from: dataB)
			
		case (kUTTypePNG as NSString as String):
			let dataB = try Data(contentsOf: from)
			guard let bir = NSBitmapImageRep(data: dataB) else {
				throw CocoaError.error(.fileReadCorruptFile, url: from)
			}
			guard let dataC = bir.representation(using: .bmp, properties: [.fallbackBackgroundColor: NSColor(calibratedWhite: 1, alpha: 1)]) else {
				throw CocoaError.error(.fileReadCorruptFile, url: from)
			}
			try bitmap.read(from: dataC)

		case (kUTTypeJPEG as NSString as String):
			jpegData = try Data(contentsOf: from)
			
		case (kUTTypePICT as NSString as String):
			let dataB = try Data(contentsOf: from)
			guard dataB.count >= 528 else {
				throw CocoaError.error(.fileReadCorruptFile, url: from)
			}
			try load(from: dataB.advanced(by: 512))


		default:
			throw CocoaError.error(.fileReadCorruptFile, url: from)
		}
	}
}

/// Obj-C bridging header for converting to/from PICT formats.
@objc class PhPictConversion: NSObject {
	@objc(PhPictConversionBinaryFormat) enum BinaryFormat: Int {
		/// `.bitmap` if 8-bit, `.JPEG` if JPEG data is encoded, otherwise `.PNG`.
		case best = -1
		
		case bitmap = 0
		
		case JPEG = 1
		
		case PNG = 2
	}

	@objc(convertPICTfromURL:returnedFormat:error:) class func convertPICT(from: URL, returnedFormat: UnsafeMutablePointer<BinaryFormat>) throws -> Data {
		let retVal = try PICT.convertPICT(from: from, to: .best)
		returnedFormat.pointee = retVal.format
		return retVal.data
	}
	
	@objc(convertPICTfromData:returnedFormat:error:) class func convertPICT(from: Data, returnedFormat: UnsafeMutablePointer<BinaryFormat>) throws -> Data {
		let retVal = try PICT.convertPICT(from: from, to: .best)
		returnedFormat.pointee = retVal.format
		return retVal.data
	}
	
	@objc(convertRawPICTfromData:clutData:returnedFormat:error:) class func convertRawPICT(from: Data, clut: Data, returnedFormat: UnsafeMutablePointer<BinaryFormat>) throws -> Data {
		let retVal = try PICT.convertRawPICT(from: from, clut: clut, to: .best)
		returnedFormat.pointee = retVal.format
		return retVal.data
	}
	
	@objc(convertPICTfromURL:toFormat:error:) class func convertPICT(from: URL, to: BinaryFormat) throws -> Data {
		let retVal = try PICT.convertPICT(from: from, to: to)
		guard to == retVal.format else {
			fatalError()
		}
		return retVal.data
	}
	
	@objc(convertPICTfromData:toFormat:error:) class func convertPICT(from: Data, to: BinaryFormat) throws -> Data {
		let retVal = try PICT.convertPICT(from: from, to: to)
		guard to == retVal.format else {
			fatalError()
		}
		return retVal.data
	}

	@objc(convertFileAtURLToPICT:error:) class func convertFileToPICT(at loc: URL) throws -> Data {
		let pict = PICT()
		try pict.importData(from: loc)
		return try pict.save(toData: ())
	}
	
	private override init() {
		
	}
}

private func unpackRow8(_ stream: PhData, rowBytes: Int) -> [UInt8]? {
	var result = [UInt8]()
	
	var row_length: Int
	if rowBytes > 250 {
		guard let preLength = stream.readUInt16() else {
			return nil
		}
		row_length = Int(preLength)
	} else {
		guard let preLength = stream.readUInt8() else {
			return nil
		}
		row_length = Int(preLength)
	}
	result.reserveCapacity(row_length)

	let end = stream.currentPosition + row_length
	while stream.currentPosition < end {
		guard let c = stream.readInt8() else {
			return nil
		}
		
		if c < 0 {
			let size = -Int(c) + 1
			guard let data = stream.readUInt8() else {
				return nil
			}
			for _ in 0 ..< size {
				result.append(data)
			}
		} else if c != -128 {
			let size = Int(c) + 1
			for _ in 0..<size {
				guard let data = stream.readUInt8() else {
					return nil
				}
				result.append(data)
			}
		}

	}
	return result
}

private func unpackRow16(_ stream: PhData, rowBytes: Int) -> [UInt16]? {
	var result = [UInt16]()
	
	var row_length: Int
	if rowBytes > 250 {
		guard let preLength = stream.readUInt16() else {
			return nil
		}
		row_length = Int(preLength)
	} else {
		guard let preLength = stream.readUInt8() else {
			return nil
		}
		row_length = Int(preLength)
	}
	result.reserveCapacity(row_length)

	let end = stream.currentPosition + row_length
	while stream.currentPosition < end {
		guard let c = stream.readInt8() else {
			return nil
		}
		
		if c < 0 {
			let size = -Int(c) + 1
			guard let data = stream.readUInt16() else {
				return nil
			}
			for _ in 0 ..< size {
				result.append(data)
			}
		} else if c != -128 {
			let size = Int(c) + 1
			for _ in 0..<size {
				guard let data = stream.readUInt16() else {
					return nil
				}
				result.append(data)
			}
		}

	}
	return result
}

private func expandPixels(from scanLines: [UInt8], depth: Int) -> [UInt8] {
	var result = [UInt8]()
	if depth == 1 {
		let bitset = CFBitVectorCreate(kCFAllocatorDefault, scanLines, 8*scanLines.count)!
		result.reserveCapacity(CFBitVectorGetCount(bitset))
		for i in 0 ..< CFBitVectorGetCount(bitset) {
			let val = CFBitVectorGetBitAtIndex(bitset, i)
			result.append(UInt8(val))
		}
		return result
	}
	for it in scanLines {
		if depth == 4 {
			result.append((it) >> 4)
			result.append((it) & 0xf)
		} else if depth == 2 {
			result.append((it) >> 6)
			result.append(((it) >> 4) & 0x3)
			result.append(((it) >> 2) & 0x3)
			result.append((it) & 0x3)
		}
	}

	return result
}

private func packRow<X:FixedWidthInteger>(_ scanLine: [X]) -> Data {
	var result = Data(capacity: scanLine.count * 2 * MemoryLayout<X>.size)
	
	var run = scanLine.startIndex
	var start = scanLine.startIndex
	var end = scanLine.index(after: scanLine.startIndex)

	while end != scanLine.endIndex {
		if scanLine[end] != scanLine[scanLine.index(before: end)] {
			run = end
		}
		
		scanLine.formIndex(after: &end)
		if end.distance(to: run) == 3 {
			if run > start {
				let block_length: UInt8 = UInt8(run - start - 1)
				PICTWrite(block_length, &result)
				while start < run {
					PICTWrite(scanLine[start], &result)

					scanLine.formIndex(after: &start)
				}
			}
			while end != scanLine.endIndex && scanLine[end] == scanLine[end - 1] && end - run < 128 {
				scanLine.formIndex(after: &end)
			}
			let run_length: UInt8 = UInt8(1 - (end - run))
			PICTWrite(run_length, &result)
			PICTWrite(scanLine[run], &result)
			run = end
			start = end
		} else if end - start == 128 {
			let block_length: UInt8 = UInt8(end - start - 1)
			PICTWrite(block_length, &result)
			while start < end {
				PICTWrite(scanLine[start], &result)
				scanLine.formIndex(after: &start)
			}
			run = end
		}
	}
	
	if end > start {
		let block_length: UInt8 = UInt8(end - start - 1)
		PICTWrite(block_length, &result)
		while start < end {
			PICTWrite(scanLine[start], &result)
			scanLine.formIndex(after: &start)
		}
	}

	
	return result
}

private func parseJPEGDimensions(_ preData: Data) -> (width: Int16, height: Int16)? {
	let stream = PhData(data: preData)
	guard let magic = stream.readUInt16(), magic == 0xffd8 else {
		return nil
	}
	
	while stream.currentPosition < stream.length {
		// eat until we find 0xff
		var c: UInt8
		repeat {
			guard let cc = stream.readUInt8() else {
				return nil
			}
			c = cc
		} while c != 0xff
		
		
		// eat 0xffs until we find marker code
		repeat {
			guard let cc = stream.readUInt8() else {
				return nil
			}
			c = cc
		} while c == 0xff

		switch c {
		case 0xd9, // end of image
		0xda: // start of scan
			return nil
			
			
		case 0xc0, 0xc1, 0xc2, 0xc3, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcd, 0xce, 0xcf:
			// start of frame
			guard let /*length*/_ = stream.readUInt16(), let /*precision*/_ = stream.readUInt8(), let height = stream.readInt16(), let width = stream.readInt16() else {
				return nil
			}
			
			return (width, height)
			
		default:
			guard let length = stream.readUInt16() else {
				return nil
			}
			if length < 2 {
				return nil
			} else {
				stream.add(toPosition: Int(length - 2))
			}
			break
		}
	}
	
	return nil
}
