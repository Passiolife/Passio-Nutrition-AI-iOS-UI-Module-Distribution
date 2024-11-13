//
//  TrackingModels.swift
//  PassioNutritionUIModule
//
//  Created by Tushar S on 07/11/24.
//

import Foundation

public struct WeightTracking: Codable, Equatable {
    public let id: String
    public let weight: Double
    public let dateTime: Date
    
    public init(id: String = UUID().uuidString, weight: Double, dateTime: Date) {
        self.id = id
        self.weight = weight
        self.dateTime = dateTime
    }
}
