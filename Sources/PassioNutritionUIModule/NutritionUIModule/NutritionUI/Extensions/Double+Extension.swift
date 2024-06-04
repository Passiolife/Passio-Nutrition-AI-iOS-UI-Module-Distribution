//
//  Double+Extension.swift
//  Passio App Module
//
//  Created by zvika on 1/29/19.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import Foundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

extension Optional where Wrapped == Double {

    func roundDigits(afterDecimal: Int) -> Double? {
        guard let wself = self else {return nil}
        let multiplier = pow(10, Double(afterDecimal))
        return (wself * multiplier).rounded()/multiplier
    }
}
extension Double {

    func roundDigits(afterDecimal: Int) -> Double {
        let multiplier = pow(10, Double(afterDecimal))
        return (self * multiplier).rounded()/multiplier
    }

    var formattedDecimalValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        let number = NSNumber(value: self)
        let formattedValue = formatter.string(from: number)!
        return "\(formattedValue)"
    }
}

extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }

    func normalize(toMultipleOf multiple: Int) -> Double {
        guard multiple > 0 else {
            fatalError("Multiple should be greater than 0")
        }
        
        let roundedValue = (self / Double(multiple)).rounded() * Double(multiple)
        return roundedValue > self ? roundedValue : roundedValue + Double(multiple)
    }
    
    func normalize(_min: Double, _max: Double) -> Double {
        // Ensure min is less than max
        guard _min < _max else {
            fatalError("Minimum value must be less than maximum value")
        }
        let normalizedValue = (self - _min) / (_max - _min)
        return normalizedValue
    }
}

extension CGFloat{
    func normalize(toMultipleOf multiple: Int) -> CGFloat {
        guard multiple > 0 else {
            fatalError("Multiple should be greater than 0")
        }
        
        let roundedValue = (self / CGFloat(multiple)).rounded() * CGFloat(multiple)
        return roundedValue > self ? roundedValue : roundedValue + CGFloat(multiple)
    }
}
