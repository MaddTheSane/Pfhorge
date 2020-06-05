//
//  PhDataAdditions.swift
//  Pfhorge
//
//  Created by C.W. Betts on 6/4/20.
//

import Foundation

extension PhData {
    func getInt8() -> Int8 {
        return Int8(bitPattern: getUInt8())
    }
}
