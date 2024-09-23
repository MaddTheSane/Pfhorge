//
//  SNDConverter.swift
//  Pfhorge
//
//  Created by C.W. Betts on 12/31/22.
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

import Foundation
import AudioToolbox

@objcMembers
final class SNDConverter: NSObject {
	var sixteenBits = false
	var stereo = false
	var signed8Bit = false
	var bytesPerFrame = 0
	var rate: UInt32 = 0
	var data = Data()
	
	convenience init(data: Data) throws(Errors) {
		self.init()
		try load(from: data)
	}
	
	@objc(SNDConverterErrors)
	enum Errors: Int, Error {
		case unexpectedEOF
		case badFormat
		case noSamples
		case unsupportedCompression
	}
    
	@objc(loadFromData:error:)
	func load(from dat: Data) throws(Errors) {
		let stream = PhData(data: dat)
		guard let format = stream.readUInt16() else {
			throw Errors.unexpectedEOF
		}
		guard format == 1 || format == 2 else {
			throw Errors.badFormat
		}
		
		if format == 1 {
			guard let num_data_formats = stream.readUInt16(),
					stream.add(toPosition: Int(num_data_formats) * 6) else {
				throw Errors.unexpectedEOF
			}
		} else if format == 2 {
			guard stream.add(toPosition: 2) else {
				throw Errors.unexpectedEOF
			}
		}

		guard let num_commands = stream.readUInt16() else {
			throw Errors.unexpectedEOF
		}
		for _ in 0 ..< num_commands {
			guard let cmd = stream.readUInt16(),
				  let param1 = stream.readUInt16(),
				  let param2 = stream.readUInt32() else {
				throw Errors.unexpectedEOF
			}

			if cmd == 0x8051 {
				let presample = dat[Data.Index(param2) ..< dat.endIndex]
				let sample = PhData(data: presample)
				if dat[Int(param2) + 20] == 0x00 {
					try unpackStandardSystem7Header(sample)
				} else if dat[Int(param2) + 20] == 0xff || dat[Int(param2) + 20] == 0xfe {
					try unpackExtendedSystem7Header(sample)
				}
			}
		}

		throw Errors.noSamples
	}
	
	func saveToData() -> Data {
		let length = 10 + 10 + data.count + 64
		var result = Data()
		result.reserveCapacity(length)
		
		// resource header
		let format: Int16 = 1
		let data_formats: Int16 = 1
		let data_type: Int16 = 5
		let initialization_options: UInt32 = (stereo ? 0x00c0 : 0x0080)
		PICTWrite(format, &result)
		PICTWrite(data_formats, &result)
		PICTWrite(data_type, &result)
		PICTWrite(initialization_options, &result)

		// command
		let num_commands: Int16 = 1
		let command: UInt16 = 0x8051
		let param1: UInt16 = 0
		let param2: UInt32 = 20

		PICTWrite(num_commands, &result)
		PICTWrite(command, &result)
		PICTWrite(param1, &result)
		PICTWrite(param2, &result)

		// extended sound header
		let ptr: UInt32 = 0
		let num_channels: Int32 = (stereo ? 2 : 1)
		let loop_start: UInt32 = 0
		let loop_end: UInt32 = 0
		let header_type: UInt8 = 0xff
		let baseFrequency: UInt8 = 0
		let num_frames = Int32(data.count / bytesPerFrame)
		let sample_size: Int16 = (sixteenBits ? 16 : 8)
		PICTWrite(ptr, &result)
		PICTWrite(num_channels, &result)
		PICTWrite(loop_start, &result)
		PICTWrite(loop_end, &result)
		PICTWrite(header_type, &result)
		PICTWrite(baseFrequency, &result)
		PICTWrite(num_frames, &result)
		result.append(Data(count: 22))
		PICTWrite(sample_size, &result)

		result.append(data)
		return result
	}
	
	private func unpackStandardSystem7Header(_ stream: PhData) throws(Errors) {
		bytesPerFrame = 1
		signed8Bit = false
		sixteenBits = false
		stereo = false
		// sample pointer
		guard stream.add(toPosition: 4) else {
			throw Errors.unexpectedEOF
		}
		
		guard let length = stream.readInt32() else {
			throw Errors.unexpectedEOF
		}
		guard let rate_ = stream.readUInt32() else {
			throw Errors.unexpectedEOF
		}
		rate = rate_
		
		// loop_start, loop_end
		guard stream.add(toPosition: 8) else {
			throw Errors.unexpectedEOF
		}
		
		guard stream.add(toPosition: 2) else {
			throw Errors.unexpectedEOF
		}

		guard let preDat = stream.getSubData(withLength: Int(length)) else {
			throw Errors.unexpectedEOF
		}
		
		data = preDat
	}
	
	private func unpackExtendedSystem7Header(_ stream: PhData) throws(Errors) {
		signed8Bit = false;
		// sample pointer
		guard stream.add(toPosition: 4) else {
			throw Errors.unexpectedEOF
		}
		guard let num_channels = stream.readInt32() else {
			throw Errors.unexpectedEOF
		}
		stereo = (num_channels == 2);
		guard let rate_ = stream.readUInt32() else {
			throw Errors.unexpectedEOF
		}
		rate = rate_
		// loop_start, loop_end;
		guard stream.add(toPosition: 8) else {
			throw Errors.unexpectedEOF
		}

		guard let header_type = stream.readUInt8() else {
			throw Errors.unexpectedEOF
		}
		// baseFrequency
		guard stream.add(toPosition: 1) else {
			throw Errors.unexpectedEOF
		}

		guard let num_frames = stream.readInt32() else {
			throw Errors.unexpectedEOF
		}

		if header_type == 0xfe {
			// AIFF rate
			guard stream.add(toPosition: 10) else {
				throw Errors.unexpectedEOF
			}
			// marker chunk
			guard stream.add(toPosition: 4) else {
				throw Errors.unexpectedEOF
			}
			guard let format = stream.readUInt32() else {
				throw Errors.unexpectedEOF
			}
			// future use, ptr, ptr
			guard stream.add(toPosition: 4*3) else {
				throw Errors.unexpectedEOF
			}
			guard let comp_id = stream.readInt16() else {
				throw Errors.unexpectedEOF

			}
			if (format != PhTwosEncoderID || comp_id != -1) {
				throw Errors.unsupportedCompression
			}
			signed8Bit = true
			guard stream.add(toPosition: 4) else {
				throw Errors.unexpectedEOF
			}
		} else {
			guard stream.add(toPosition: 22) else {
				throw Errors.unexpectedEOF
			}
		}

		guard let sample_size = stream.readInt16() else {
			throw Errors.unexpectedEOF
		}

		if header_type != 0xfe {
			guard stream.add(toPosition: 14) else {
				throw Errors.unexpectedEOF
			}
		}

		sixteenBits = (sample_size == 16)
		bytesPerFrame = (sixteenBits ? 2 : 1) * (stereo ? 2 : 1)
		guard let tmpDat = stream.getSubData(withLength: Int(num_frames) * bytesPerFrame) else {
			throw Errors.unexpectedEOF
		}
		data = tmpDat
	}

	@objc(importFromURL:error:)
	func importFrom(_ url: URL) throws {
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr)
	}
	
	@objc(exportToURL:error:)
	func export(to url: URL) throws {
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr)
	}
}
