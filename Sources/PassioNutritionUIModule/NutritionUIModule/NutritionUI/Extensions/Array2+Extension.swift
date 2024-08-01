//
//  Array+Extension.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 04/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

extension Array where Element: Hashable {

    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }

    func unique<T: Hashable>(map: ((Element) -> (T))) -> [Element] {
        var set = Set<T>()
        var arrayOrdered = [Element]()
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        return arrayOrdered
    }
}

extension Array where Element == UITextField {

    var isValidTextFields: Bool {
        allSatisfy { $0.text != "" && $0.text != nil }
    }
}

public extension Array where Element == DayLog {
    func generateDataRequestJson() -> String {
        var meals = [DayLogRecord]()
        for dayLog in self {
            let breakfast = dayLog.breakfastArray.compactMap({ $0.name })
            let lunch = dayLog.lunchArray.compactMap({ $0.name })
            let dinner = dayLog.dinnerArray.compactMap({ $0.name })
            let snacks = dayLog.snackArray.compactMap({ $0.name })
            let meal = DayLogRecord(date: dayLog.date.dateString,
                                    breakfast: breakfast,
                                    lunch: lunch,
                                    dinner: dinner,
                                    snacks: snacks)
            if meal.containsData {
                meals.append(meal)
            }
        }
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(meals)
            let json = String(data: data, encoding: .ascii)
            return json ?? ""
        } catch {
            return ""
        }
    }
}

// MARK: Safe use of Collection's Index while avoiding “Fatal error: Index out of range”.
extension Collection where Indices.Iterator.Element == Index {

    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}
