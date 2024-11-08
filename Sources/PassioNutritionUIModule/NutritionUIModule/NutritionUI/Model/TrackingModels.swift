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
    public let date: Date
    public let time: Date
    public let createdAt: Date
    
    public init(id: String = UUID().uuidString, weight: Double, date: Date, time: Date, createdAt: Date) {
        self.id = id
        self.weight = weight
        self.date = date
        self.time = time
        self.createdAt = createdAt
    }
}
