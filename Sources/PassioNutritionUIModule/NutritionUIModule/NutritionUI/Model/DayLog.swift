//
//  DayLog.swift
//  PassioNutritionData
//
//  Created by James Kelly on 29/08/2018.
//  Copyright © 2023 PassioLife Inc. All rights reserved.
//

import Foundation

#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public class DayLog {

    private(set) var date: Date
    private(set) var records: [FoodRecordV3] = [] {
        didSet {
            breakfastArray = getFoodRecordsByMeal(mealLabel: .breakfast)
            lunchArray = getFoodRecordsByMeal(mealLabel: .lunch)
            dinnerArray = getFoodRecordsByMeal(mealLabel: .dinner)
            snackArray = getFoodRecordsByMeal(mealLabel: .snack)
        }
    }
    
    
    public var breakfastArray: [FoodRecordV3] = []
    public var lunchArray: [FoodRecordV3] = []
    public var dinnerArray: [FoodRecordV3] = []
    public var snackArray: [FoodRecordV3] = []
    
    var hidenMeals: Set<MealLabel> = []

    public init(date: Date, records: [FoodRecordV3]) {
        self.date = date
        self.records = records
        
        breakfastArray = getFoodRecordsByMeal(mealLabel: .breakfast)
        lunchArray = getFoodRecordsByMeal(mealLabel: .lunch)
        dinnerArray = getFoodRecordsByMeal(mealLabel: .dinner)
        snackArray = getFoodRecordsByMeal(mealLabel: .snack)
    }
    func setNew(foodRecords: [FoodRecordV3]) {
        records = foodRecords
    }
    
    func displayShowHide(mealLabel: MealLabel) -> Bool {
        let recordsCount = records.filter {$0.mealLabel == mealLabel}.count
        return !(recordsCount == 0)
    }

    func numberOfRecordsByMeal(mealLabel: MealLabel) -> Int {
        switch mealLabel{
        case .breakfast:
            return breakfastArray.count
        case .lunch:
            return lunchArray.count
        case .dinner:
            return dinnerArray.count
        case .snack:
            return snackArray.count
        }
    }

    func getFoodRecordsByMeal(mealLabel: MealLabel) -> [FoodRecordV3] {
        guard !hidenMeals.contains(mealLabel) else {
            return []
        }
        let recordsforMeal = records.filter {$0.mealLabel == mealLabel}
        guard recordsforMeal.count > 1 else { return recordsforMeal }
        let sorted = recordsforMeal.sorted(by: { (firstItem: FoodRecordV3,
                                                  secondItem: FoodRecordV3) -> Bool in
            if firstItem.createdAt != secondItem.createdAt {
                return firstItem.createdAt > secondItem.createdAt
            } else {
                return firstItem.name > secondItem.name
            }
        })
        return sorted
    }
    
    static func generateDataRequest(dayLogs: [DayLog]) -> String {
        let meals = DayLogMeal.extractMeals(dayLogs: dayLogs)
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(meals)
            let json = String(data: data, encoding: .ascii)
            return json ?? ""
        } catch {
            return ""
        }
    }
    
    var displayedRecords: [FoodRecordV3] {
        records.filter { !hidenMeals.contains($0.mealLabel) }
    }

    var displayedCarbs: Double {
        displayedRecords.map {$0.totalCarbs}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    var displayedProtein: Double {
        displayedRecords.map {$0.totalProteins}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    var displayedFat: Double {
        displayedRecords.map {$0.totalFat}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    var displayedCalories: Double {
        displayedRecords.map {$0.totalCalories}.reduce(0.0, +).roundDigits(afterDecimal: 0)
    }
    
    var dailyCarbs: Double {
        records.map {$0.totalCarbs}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    var dailyProtein: Double {
        records.map {$0.totalProteins}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    var dailyFat: Double {
        records.map {$0.totalFat}.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    var dailyCalories: Double {
        records.map {$0.totalCalories}.reduce(0.0, +).roundDigits(afterDecimal: 0)
    }
}

internal struct DayLogMeal: Codable {
    let date: String
    let breakfast: [String]
    let lunch: [String]
    let dinner: [String]
    let snacks: [String]
    
    var containsData: Bool {
        !(breakfast.isEmpty && lunch.isEmpty && dinner.isEmpty && snacks.isEmpty)
    }
    
    static func extractMeals(dayLogs: [DayLog]) -> [DayLogMeal] {
        var meals = [DayLogMeal]()
        for dayLog in dayLogs {
            let breakfast = dayLog.breakfastArray.compactMap({ $0.name })
            let lunch = dayLog.lunchArray.compactMap({ $0.name })
            let dinner = dayLog.dinnerArray.compactMap({ $0.name })
            let snacks = dayLog.snackArray.compactMap({ $0.name })
            let meal = DayLogMeal(date: dayLog.date.dateString,
                                  breakfast: breakfast,
                                  lunch: lunch,
                                  dinner: dinner,
                                  snacks: snacks)
            if meal.containsData {
                meals.append(meal)
            }
        }
        return meals
    }
}
