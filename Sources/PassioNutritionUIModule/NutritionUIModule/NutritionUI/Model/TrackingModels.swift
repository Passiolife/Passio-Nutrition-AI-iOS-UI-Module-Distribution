//
//  TrackingModels.swift
//  PassioNutritionUIModule
//
//  Created by Tushar S on 07/11/24.
//

import Foundation

public struct WeightTracking: Codable, Equatable {
    public let uuid: String
    public let weight: Double
    public let createdAt: Date
    
    public init(uuid: String = UUID().uuidString, weight: Double, createdAt: Date) {
        self.uuid = uuid
        self.weight = weight
        self.createdAt = createdAt
    }
}
