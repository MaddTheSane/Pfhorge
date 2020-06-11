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
			guard let aTop = data.readInt16(), let aLeft = data.readInt16(), let aBottom = data.readInt16(), let aRight = data.readInt16() else {
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
		var headerOp: Int16
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
			guard let aheaderOp = data.readInt16(), let aheaderVersion = data.readUInt16(),
			let areserved1 = data.readInt16(),
			let ahRes = data.readInt32(),
			let avRes = data.readInt32(),
			let asrcRect = Rect(data: data),
				let areserved2 = data.readInt32() else {
					return nil
			}
			headerOp = aheaderOp
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
			var tmpData = Data()
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
	}
	
	var jpegData = Data()
	var bitmap = EasyBMP()

	private func loadCopyBits(_ stream: PhData, packed: Bool, clipped: Bool) -> Bool {
		if (!packed) {
			stream.addP(4); // pmBaseAddr
		}

		guard var rowBytes = stream.readUInt16() else {
			return false
		}
		let isPixmap = (rowBytes & 0x8000) == 0x8000
		rowBytes &= 0x3fff;
		guard let rect = Rect(data: stream) else {
			return false
		}
		
		let width = rect.width
		let height = rect.height
		var pack_type: UInt16
		var pixel_size: UInt16
		if isPixmap {
			stream.addP(2); // pmVersion
			guard let tmpVal = stream.readUInt16() else {
				return false
			}
			pack_type = tmpVal
			stream.addP(14); // packSize/hRes/vRes/pixelType
			guard let tmpVal2 = stream.readUInt16() else {
				return false
			}
			pixel_size = tmpVal2
			stream.addP(16); // cmpCount/cmpSize/planeBytes/pmTable/pmReserved
		} else {
			pack_type = 0;
			pixel_size = 1;
		}
		
		_=bitmap.setSize(width: Int32(width), height: Int32(height))
		if (pixel_size <= 8) {
			_=bitmap.setBitDepth(8);
		} else {
			_=bitmap.setBitDepth(Int32(pixel_size));
		}

		// read the color table
		if (isPixmap && packed) {
			stream.addP(4); // ctSeed
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
					index = i;
				} else {
					index &= 0xff;
				}

				let pixel = EasyBMP.RGBAPixel(blue: UInt8(blue >> 8), green: UInt8(green >> 8), red: UInt8(red >> 8), alpha: 0xff)
				_=bitmap.setColor(at: Int(index), to: pixel)
			}
			
			// src/dst/transfer mode
			stream.addP(18)
			
			// clipping region
			if clipped {
				guard let size = stream.readUInt16() else {
					return false
				}
				stream.addP(Int(size - 2));
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
							_=bitmap.setPixel(atX: x, y: y, bitmap.getColor(at: Int(scanLine[x]))!);
						}
					} else {
						let pixels = expandPixels(from: scanLine, depth: Int(pixel_size))
						
						for x in 0 ..< Int(width) {
							_=bitmap.setPixel(atX: x, y: y, bitmap.getColor(at: Int(pixels[x]))!);
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
						pixel.red = UInt8((scan_line[x] >> 10) & 0x1f);
						pixel.green = UInt8((scan_line[x] >> 5) & 0x1f)
						pixel.blue = UInt8(scan_line[x] & 0x1f)
						pixel.red = (pixel.red * 255 + 16) / 31;
						pixel.green = (pixel.green * 255 + 16) / 31;
						pixel.blue = (pixel.blue * 255 + 16) / 31;
						pixel.alpha = 0xff;
						
						_=bitmap.setPixel(atX: x, y: y, pixel);
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
							scan_line[x] = UInt8(pixel >> 16);
							scan_line[x + Int(width)] = UInt8((pixel >> 8) & 0xff);
							scan_line[x + Int(width) * 2] = UInt8(pixel & 0xFF);
						}
					} else if pack_type == 0 || pack_type == 4 {
						guard let tmpSL = unpackRow8(stream, rowBytes: Int(rowBytes)) else {
							return false
						}
						scan_line = tmpSL
					}

					for x in 0 ..< Int(width) {
						var pixel = EasyBMP.RGBAPixel()
						pixel.red = scan_line[x];
						pixel.green = scan_line[x + Int(width)];
						pixel.blue = scan_line[x + Int(width) * 2];
						pixel.alpha = 0xff;
						_=bitmap.setPixel(atX: x, y: y, pixel);
					}
				}
			}
		}
		
		if (stream.currentPosition & 1) != 0 {
			stream.addP(1)
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
		
		guard let size = data.readInt16(),
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
					break;
					
				case .clippingRegion:
					guard var size = data.readUInt16() else {
						throw PICTConversionError.unexpectedEndOfStream
					}
					if ((size & 1) != 0) {
						size += 1
					}
					data.addP(Int(size - 2))
					
				case .txFont, .txFace, .txMode, .pnMode, .txSize, .pnLocHFrac, .chExtra, .shortLineFrom, .shortComment:
					data.addP(2)
					
				case .spExtra, .pnSize, .ovSize, .origin, .fgColor, .bgColor, .lineFrom:
					data.addP(4)
					
				case .RGBFgCol, .RGBBkCol, .hiliteColor, .opColor, .shortLine:
					data.addP(6)
					
				case .bkPat, .pnPat, .fillPat, .txRatio, .line, .frameRect, .paintRect, .eraseRect, .invertRect, .fillRect:
					data.addP(8)
					
				case .headerOp:
					let headerOp = PICT.HeaderOp(data: data)
					
				case .longComment:
					data.addP(2)
					guard var size = data.readInt16() else {
						throw PICTConversionError.unexpectedEndOfStream
					}
					if (size & 1) != 0 {
						size += 1
					}
					data.addP(Int(size))
					
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
						throw PICTConversionError.containsBandedJPEG;
					}
					try loadJPEG(data, to: &jpegData)
					
				default:
					if preOpcode >= 0x0300 && preOpcode < 0x8000 {
						data.addP(Int(preOpcode >> 8) * 2)
					} else if preOpcode >= 0x8000 && preOpcode < 0x8100 {
						break
					} else {
						throw PICTConversionError.unimplementedOpCode(preOpcode)
					}
				}
			} else {
				if preOpcode >= 0x0300 && preOpcode < 0x8000 {
					data.addP(Int(preOpcode >> 8) * 2)
				} else if preOpcode >= 0x8000 && preOpcode < 0x8100 {
					//break;
				} else {
					throw PICTConversionError.unimplementedOpCode(preOpcode)
				}
			}
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
		data.addP(26); // version/matrix (hom. part)
		guard let offsetX = data.readInt16() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		data.addP(2)
		guard let offsetY = data.readInt16() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		data.addP(2)
		data.addP(4) // rest of matrix
		guard offsetX == 0, offsetY == 0 else {
			throw PICTConversionError.containsBandedJPEG
		}
		
		guard let matteSize = data.readUInt32() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		data.addP(22); // matte rect/srcRect/accuracy
		
		guard let maskSize = data.readUInt32() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		
		if matteSize != 0 {
			guard let matte_id_size = data.readUInt32() else {
				throw PICTConversionError.unexpectedEndOfStream
			}
			data.addP(Int(matte_id_size - 4));
		}
		
		data.addP(Int(matteSize));
		data.addP(Int(maskSize));
		
		let idSize = data.readUInt32()
		let codecType = data.readUInt32()
		guard codecType == PhJPEGCodecID else {
			throw PICTConversionError.unsupportedQuickTimeCodec
		}
		
		data.addP(36); // resvd1/resvd2/dataRefIndex/version/revisionLevel/vendor/temporalQuality/spatialQuality/width/height/hRes/vRes
		guard let dataSize = data.readUInt32() else {
			throw PICTConversionError.unexpectedEndOfStream
		}
		data.addP(38); // frameCount/name/depth/clutID
		
		guard let subDat = data.getSubData(withLength: Int(dataSize)) else {
			data.addP(opcodeStart + Int(opcodeSize) - data.currentPosition)
			throw PICTConversionError.unexpectedEndOfStream
		}
		to = subDat
		
		data.addP(opcodeStart + Int(opcodeSize) - data.currentPosition)
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
						throw NSError(domain: NSCocoaErrorDomain, code: -1)
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
						throw NSError(domain: NSCocoaErrorDomain, code: -1)

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

			throw NSError(domain: NSCocoaErrorDomain, code: -1)

		case .PNG:
			if aPict.jpegData.count != 0 {
				if let bmpImgRep = NSBitmapImageRep(data: aPict.jpegData),
					let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) {
					return (.PNG, pngDat)
				}
			}

			guard let bmpImgRep = NSBitmapImageRep(data: aPict.bitmap.generateData()),
				let pngDat = bmpImgRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
				throw NSError(domain: NSCocoaErrorDomain, code: -1)
			}
			return (.PNG, pngDat)

			
		default:
			throw NSError(domain: NSCocoaErrorDomain, code: -1)
		}
	}
	
	enum PICTConversionError: Error {
		case unimplementedOpCode(_ opCode: UInt16)
		case containsBandedJPEG
		case usesCinemascopeHack
		case unsupportedQuickTimeCodec
		case unexpectedEndOfStream
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
		
		if (c < 0) {
			let size = -Int(c) + 1;
			guard let data = stream.readUInt8() else {
				return nil
			}
			for _ in 0 ..< size {
				result.append(data);
			}
		} else if (c != -128) {
			let size = Int(c) + 1;
			for _ in 0..<size {
				guard let data = stream.readUInt8() else {
					return nil
				}
				result.append(data);
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
		
		if (c < 0) {
			let size = -Int(c) + 1;
			guard let data = stream.readUInt16() else {
				return nil
			}
			for _ in 0 ..< size {
				result.append(data);
			}
		} else if (c != -128) {
			let size = Int(c) + 1;
			for _ in 0..<size {
				guard let data = stream.readUInt16() else {
					return nil
				}
				result.append(data);
			}
		}

	}
	return result
}

private func expandPixels(from scanLines: [UInt8], depth: Int) -> [UInt8] {
	var result = [UInt8]()
	for it in scanLines {
		if (depth == 4) {
			result.append((it) >> 4)
			result.append((it) & 0xf)
		} else if (depth == 2) {
			result.append((it) >> 6)
			result.append(((it) >> 4) & 0x3)
			result.append(((it) >> 2) & 0x3)
			result.append((it) & 0x3)
		} else if (depth == 1) {
			var tmpIt = it
			let bitset = CFBitVectorCreate(kCFAllocatorDefault, &tmpIt, 8)!
			for i in 0 ..< 8 {
				let val = CFBitVectorGetBitAtIndex(bitset, i)
				result.append(UInt8(val))
			}
		}
	}

	return result;
}

