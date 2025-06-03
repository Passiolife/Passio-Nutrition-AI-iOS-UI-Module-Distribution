//
//  File.swift
//  PassioNutritionUIModule
//
//  Created by Pratik on 27/05/25.
//

import Foundation

enum InputType: Int {
    
    case foodName = 1
    case barcode = 2
    case calories = 3
    case carbs = 4
    case protein = 5
    case fat = 6
    case servingSize = 7
    case servingUnit = 8
    case weight = 9
    case other = 100
    
    public init(value: Int) {
        self = InputType(rawValue: value) ?? .other
    }
}
