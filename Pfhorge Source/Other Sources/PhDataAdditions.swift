//
//  PhDataAdditions.swift
//  Pfhorge
//
//  Created by C.W. Betts on 6/4/20.
//

import Foundation

extension PhData {
	func readInt8() -> Int8? {
		var toRet: UInt8 = 0
		let good = __getByte(&toRet)
		if good {
			return Int8(bitPattern: toRet)
		} else {
			return nil
		}
	}

	func readUInt8() -> UInt8? {
		var toRet: UInt8 = 0
		let good = __getByte(&toRet)
		if good {
			return toRet
		} else {
			return nil
		}
	}
	
	func readInt16() -> Int16? {
		var toRet: Int16 = 0
		let good = __getShort(&toRet)
		if good {
			return toRet
		} else {
			return nil
		}
	}

	func readUInt16() -> UInt16? {
		var toRet: UInt16 = 0
		let good = __getUnsignedShort(&toRet)
		if good {
			return toRet
		} else {
			return nil
		}
	}

	func readInt32() -> Int32? {
		var toRet: Int32 = 0
		let good = __getInt(&toRet)
		if good {
			return toRet
		} else {
			return nil
		}
	}

	func readUInt32() -> UInt32? {
		var toRet: UInt32 = 0
		let good = __getUnsignedInt(&toRet)
		if good {
			return toRet
		} else {
			return nil
		}
	}

	func readInt64() -> Int64? {
		var toRet: Int64 = 0
		let good = __getLong(&toRet)
		if good {
			return toRet
		} else {
			return nil
		}
	}

	func readUInt64() -> UInt64? {
		var toRet: UInt64 = 0
		let good = __getUnsignedLong(&toRet)
		if good {
			return toRet
		} else {
			return nil
		}
	}
}
