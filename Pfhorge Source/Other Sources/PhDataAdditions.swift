//
//  PhDataAdditions.swift
//  Pfhorge
//
//  Created by C.W. Betts on 6/4/20.
//

import Foundation

public extension PhData {
	func readInt8() -> Int8? {
		var toRet: UInt8 = 0
		guard __getByte(&toRet) else {
			return nil
		}
		return Int8(bitPattern: toRet)
	}

	func readUInt8() -> UInt8? {
		var toRet: UInt8 = 0
		guard __getByte(&toRet) else {
			return nil
		}
		return toRet
	}
	
	func readInt16() -> Int16? {
		var toRet: Int16 = 0
		guard __getShort(&toRet) else {
			return nil
		}
		return toRet
	}

	func readUInt16() -> UInt16? {
		var toRet: UInt16 = 0
		guard __getUnsignedShort(&toRet) else {
			return nil
		}
		return toRet
	}

	func readInt32() -> Int32? {
		var toRet: Int32 = 0
		guard __getInt(&toRet) else {
			return nil
		}
		return toRet
	}

	func readUInt32() -> UInt32? {
		var toRet: UInt32 = 0
		guard __getUnsignedInt(&toRet) else {
			return nil
		}
		return toRet
	}

	func readInt64() -> Int64? {
		var toRet: Int64 = 0
		guard __getLong(&toRet) else {
			return nil
		}
		return toRet
	}

	func readUInt64() -> UInt64? {
		var toRet: UInt64 = 0
		guard __getUnsignedLong(&toRet) else {
			return nil
		}
		return toRet
	}
	
	func getObjectFromIndex<X: LEMapStuffParent>(_ theIndex: [X], objTypesArr: UnsafeMutablePointer<Int16>) -> X? {
		return __getObjectFromIndex(theIndex, objTypesArr: objTypesArr) as? X
	}

	func getObjectFromIndex<X: LEMapStuffParent>(usingLast theIndex: [X]) -> X? {
		return __getObjectFromIndex(usingLast: theIndex) as? X
	}
}
