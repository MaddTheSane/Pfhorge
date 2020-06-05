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
		
		init(data: PhData) {
			top = data.getInt16()
			left = data.getInt16()
			bottom = data.getInt16()
			right = data.getInt16()
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
		
		init(data: PhData) {
			headerOp = data.getInt16()
			headerVersion = data.getUInt16()
			reserved1 = data.getInt16()
			hRes = data.getInt32()
			vRes = data.getInt32()
			srcRect = Rect(data: data)
			reserved2 = data.getInt32()
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
		
		init(data: PhData) {
			rowBytes = data.getInt16()
			bounds = Rect(data: data)
			version = data.getInt16()
			packType = data.getInt16()
			packSize = data.getUInt32()
			hRes = data.getUInt32()
			vRes = data.getUInt32()
			pixelType = data.getInt16()
			pixelSize = data.getInt16()
			cmpCount = data.getInt16()
			cmpSize = data.getInt16()
			planeBytes = data.getUInt32()
			table = data.getUInt32()
			reserved = data.getUInt32()
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

	private func loadCopyBits(_ stream: PhData, packed: Bool, clipped: Bool) {
		
	}
	
	func load(from: URL) throws {
		let preData = try Data(contentsOf: from)
		let data = PhData(data: preData)!
		jpegData.removeAll()
		
		let size = data.getInt16()
		let rect = Rect(data: data)
		
		var done = false
		while done == false {
			let preOpcode = data.getUInt16()
			if let opcode = PICT.OpCode(rawValue: preOpcode) {
				switch opcode {
				case .opEndPic:
					done = true
					
				case .noOp, .versionOp, .hiliteMode, .defHilite, .frameSameRect, .paintSameRect, .eraseSameRect, .invertSameRect, .fillSameRect, .version:
					break;
					
				case .clippingRegion:
					var size = UInt16(bitPattern: data.getInt16())
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
					var size = data.getInt16()
					if (size & 1) != 0 {
						size += 1
					}
					data.addP(Int(size))
					
				case .packBitsRect, .packBitsRgn, .directBitsRect, .directBitsRgn:
					let packed = (opcode == .packBitsRect || opcode == .packBitsRgn)
					let clipped = (opcode == .packBitsRgn || opcode == .directBitsRgn)
					loadCopyBits(data, packed: packed, clipped: clipped)
					if jpegData.count != 0 {
						//bitmap_.SetSize(1, 1)
					}/*else if (bitmap_.TellWidth() != rect.width && bitmap_.TellWidth() == 614) {
					throw ParseError("PICT appears to use Cinemascope hack");
					} */
					
				case .compressedQuickTime:
					if jpegData.count != 0 {
						throw PICTConversionError.containsBandedJPEG;
					}
					try loadJPEG(data, to: &jpegData)
					
				default:
					if (preOpcode >= 0x0300 && preOpcode < 0x8000) {
						data.addP(Int(preOpcode >> 8) * 2)
					} else if (preOpcode >= 0x8000 && preOpcode < 0x8100) {
						break
					} else {
						throw PICTConversionError.unimplementedOpCode(preOpcode)
					}
				}
			} else {
				if (preOpcode >= 0x0300 && preOpcode < 0x8000) {
					data.addP(Int(preOpcode >> 8) * 2)
				} else if (preOpcode >= 0x8000 && preOpcode < 0x8100) {
					//break;
				} else {
					throw PICTConversionError.unimplementedOpCode(preOpcode)
				}
			}
		}
	}
	
	private func loadJPEG(_ data: PhData, to: inout Data) throws {
		var opcodeSize = data.getUInt32()
		if (opcodeSize & 1) != 0 {
			opcodeSize += 1
		}
		
		let opcodeStart = data.currentPosition
		data.addP(26); // version/matrix (hom. part)
		let offsetX = data.getInt16()
		data.addP(2)
		let offsetY = data.getInt16()
		data.addP(2)
		data.addP(4) // rest of matrix
		guard offsetX == 0, offsetY == 0 else {
			throw PICTConversionError.containsBandedJPEG
		}
		
		let matteSize = data.getUInt32()
		data.addP(22); // matte rect/srcRect/accuracy
		
		let maskSize = data.getUInt32()
		
		if matteSize != 0 {
			let matte_id_size = data.getUInt32()
			data.addP(Int(matte_id_size - 4));
		}
		
		data.addP(Int(matteSize));
		data.addP(Int(maskSize));
		
		let idSize = data.getUInt32()
		let codecType = data.getUInt32()
		guard codecType == PhJPEGCodecID else {
			throw PICTConversionError.unsupportedQuickTimeCodec
		}
		
		data.addP(36); // resvd1/resvd2/dataRefIndex/version/revisionLevel/vendor/temporalQuality/spatialQuality/width/height/hRes/vRes
		let dataSize = data.getUInt32()
		data.addP(38); // frameCount/name/depth/clutID
		
		to = data.getSubData(withLength: Int(dataSize))
		
		data.addP(opcodeStart + Int(opcodeSize) - data.currentPosition)
	}

	static func convertPICT(from: URL, to format: BinaryFormat = .best) throws -> (format: BinaryFormat, data: Data) {
		let aPict = PICT()
		try aPict.load(from: from)
		
		throw NSError(domain: NSCocoaErrorDomain, code: -1)
	}
	
	enum PICTConversionError: Error {
		case unimplementedOpCode(_ opCode: UInt16)
		case containsBandedJPEG
		case usesCinemascopeHack
		case unsupportedQuickTimeCodec
	}
	
	@objc(PhPictConversionBinaryFormat) enum BinaryFormat: Int {
		/// `.bitmap` if 8-bit, `.JPEG` if JPEG data is encoded, otherwise `.PNG`.
		case best = -1
		
		case bitmap = 0
		
		case JPEG = 1
		
		case PNG = 2
	}
}

@objc class PhPictConversion: NSObject {
	@objc(convertPICTfromURL:returnedFormat:error:) class func convertPICT(from: URL, returnedFormat: UnsafeMutablePointer<PICT.BinaryFormat>) throws -> Data {
		let retVal = try PICT.convertPICT(from: from, to: .best)
		returnedFormat.pointee = retVal.format
		return retVal.data
	}
}

