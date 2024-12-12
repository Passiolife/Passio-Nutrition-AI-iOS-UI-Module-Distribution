//
//  Int+Extension.swift
//
//
//  Created by Mindinventory on 16/10/24.
//

import Foundation

extension Optional where Wrapped == Int {
    public func toInt16() -> Int16 {
        // Unwrap the optional and check if the value is within the Int16 range
        guard let value = self,
                value >= Int(Int16.min),
                value <= Int(Int16.max) else {
            print("Value \(self ?? nil) is out of Int16 range or is nil.")
            return Int16(0)
        }
        
        return Int16(value)
    }
}

extension Int {
    public func toInt16() -> Int16 {
        // Check if the value is within the Int16 range
        guard self >= Int(Int16.min), self <= Int(Int16.max) else {
            print("Value \(self) is out of Int16 range.")
            return Int16(0)
        }
        
        return Int16(self)
    }
}
