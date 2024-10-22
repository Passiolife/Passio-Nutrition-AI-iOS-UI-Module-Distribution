//
//  DayLogRecord.swift
//
//
//  Created by Davido Hyer on 8/1/24.
//

import Foundation

internal struct DayLogRecord: Codable {
    let date: String
    let breakfast: [String]
    let lunch: [String]
    let dinner: [String]
    let snacks: [String]
    
    var containsData: Bool {
        !(breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty && snacks.isEmpty)
    }
}
