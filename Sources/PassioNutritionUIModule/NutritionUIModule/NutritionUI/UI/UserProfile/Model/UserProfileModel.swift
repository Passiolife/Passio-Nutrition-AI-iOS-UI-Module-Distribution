//
//  UserProfile.swift
//  Passio App Module
//
//  Created by zvika on 2/26/19.
//  Copyright © 2022 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

enum Conversion: Double {
    case lbsToKg = 2.205
    case kgToLbs = 0.45359237
    case inchToMeter = 39.3701
    case inchToFeet = 12.00
}

public class UserManager {

    static var shared: UserManager = UserManager()
    private init() { }

    var user: UserProfileModel?

    func configure() {
        PassioInternalConnector.shared.fetchUserProfile { profile in
            self.user = profile
        }
    }
}

public struct UserProfileModel: Codable, Equatable {

    var firstName: String?
    var lastName: String?
    var birthday: Date?
    var age: Int?
    var weight: Double?  // Kg
    var goalWeight: Double?
    var goalWeightTimeLine: String?
    var height: Double? // M
    var gender: GenderSelection?
    var units: UnitSelection = UnitSelection.imperial
    var heightUnits: UnitSelection = UnitSelection.imperial
    var caloriesTarget = 2100
    var carbsPercent = 50
    var proteinPercent = 25
    var fatPercent = 25
    var recommendedCalories: Int = 2100
    var reminderSettings: ReminderSettings?
    var activityLevel: ActivityLevel?
    var mealPlan: PassioMealPlan?
    var goalWater: Double?
    var waterUnit: WaterUnit? = .oz

    public init() {}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try? container.decode(String.self, forKey: .firstName)
        self.lastName = try? container.decode(String.self, forKey: .lastName)
        self.birthday = try? container.decode(Date.self, forKey: .birthday)
        self.age = try? container.decode(Int.self, forKey: .age)
        self.weight = try? container.decode(Double.self, forKey: .weight)
        self.goalWeight = try? container.decode(Double.self, forKey: .goalWeight)
        self.goalWeightTimeLine = try? container.decode(String.self, forKey: .goalWeightTimeLine)
        self.goalWater = try? container.decode(Double.self, forKey: .goalWater)
        self.height = try? container.decode(Double.self, forKey: .height)
        self.gender = try? container.decode(GenderSelection.self, forKey: .gender)
        self.units = (try? container.decode(UnitSelection.self, forKey: .units)) ?? .imperial
        self.heightUnits = (try? container.decode(UnitSelection.self, forKey: .heightUnits)) ?? .imperial
        self.caloriesTarget = (try? container.decode(Int.self, forKey: .caloriesTarget)) ?? 2100
        self.carbsPercent = (try? container.decode(Int.self, forKey: .carbsPercent)) ?? 50
        self.proteinPercent = (try? container.decode(Int.self, forKey: .proteinPercent)) ?? 25
        self.fatPercent = (try? container.decode(Int.self, forKey: .fatPercent)) ?? 25
        self.recommendedCalories = (try? container.decode(Int.self, forKey: .recommendedCalories)) ?? 2100
        self.reminderSettings = try? container.decode(ReminderSettings.self, forKey: .reminderSettings)
        self.activityLevel = try? container.decode(ActivityLevel.self, forKey: .activityLevel)
        self.mealPlan = try? container.decode(PassioMealPlan.self, forKey: .mealPlan)
        self.waterUnit = try? container.decode(WaterUnit.self, forKey: .waterUnit)
    }

    var isComleted: Bool {
        if weight != nil,
           height != nil,
           age != nil,
           gender != nil,
           activityLevel != nil,
           goalWeightTimeLine != nil {
            return true
        } else {
            return false
        }
    }

    var recommendedCarbsGrams: Int {
        recommendedCalories*carbsPercent/100/4
    }
    var recommendedProteinGrams: Int {
        recommendedCalories*proteinPercent/100/4
    }
    var recommendedFatGrams: Int {
        recommendedCalories*fatPercent/100/9
    }

    var carbsGrams: Int {
        caloriesTarget*carbsPercent/100/4
    }
    var proteinGrams: Int {
        caloriesTarget*proteinPercent/100/4
    }
    var fatGrams: Int {
        caloriesTarget*fatPercent/100/9
    }

    var bmi: Double? {
        guard let weight = weight,
              let height = height,
              height > 0,
              weight > 0 else { return nil }
        // K/M^2 metric.  or  w/h^2 * 703
        //  return (0.45 * Double(w) / sqrt(Double(h)*0.025)).roundDigits(afterDecimal: 1)
        return (weight/pow(height, 2)).roundDigits(afterDecimal: 1)
    }

    var ageDesription: String? {
        guard let age = age else { return nil }
        return String(age)
    }

//    var weightTitle: String {
//        Localized.weight + " (" + weightUnits + ")"
//    }
//
//    var goalWeightTitle: String {
//        Localized.goalWeight + " (" + weightUnits + ")"
//    }
//
//    var weightUnits: String {
//        switch units {
//        case .imperial:
//            return Localized.lbsUnit
//        case .metric:
//            return Localized.kgUnit
//        }
//    }

    var weightDespription: String? {
        guard let weight = weight else { return nil}
        switch units {
        case .imperial:
            return (weight * Conversion.lbsToKg.rawValue).roundDigits(afterDecimal: 1).clean + " lbs"
        case .metric:
            return weight.roundDigits(afterDecimal: 1).clean + " kg"
        }
    }

    var goalWeightDespription: String? {
        guard let weight = goalWeight else { return nil}
        switch units {
        case .imperial:
            return (weight * Conversion.lbsToKg.rawValue).roundDigits(afterDecimal: 1).clean + " lbs"
        case .metric:
            return weight.roundDigits(afterDecimal: 1).clean + " kg"
        }
    }

    var heightDescription: String? {
        guard let height = height else { return nil }
        switch heightUnits {
        case .metric:
            return String(height.roundDigits(afterDecimal: 2)) + " m"
        case .imperial:
            let inches = Int(height * Conversion.inchToMeter.rawValue)
            let inch = inches%Int(Conversion.inchToFeet.rawValue)
            let feet = Int(inches/Int(Conversion.inchToFeet.rawValue))
            return ("\(feet)\' \(inch)\"")
        }
    }

    var goalWaterDescription: String? {
        guard let goalWater = goalWater else {return nil}
        return "\(goalWater.clean) \((waterUnit ?? .oz).rawValue)"
    }


    var bmiDescription: String {
        guard let bmi = bmi else { return "" }
        let cdc: String
        switch bmi {
        case 0...18.5:
            cdc = Localized.underWeight
        case 18.5...24.9:
            cdc = Localized.normal
        case 24.9...29.9:
            cdc = Localized.overweight
        default:
            cdc = Localized.obese
        }
        return cdc
    }

    // MARK: Picker helprs
    var heightArrayForPicker: [[String]] {
        switch heightUnits {
        case .metric:
            let arrayOne = Array(0...2).map { String($0) + " m" }
            let arrayTwo = Array(0...99).map { String($0) + " cm" }
            return [arrayOne, arrayTwo]
        case .imperial:
            let arrayOne = Array(0...8).map { String($0) + "'" }
            let arrayTwo = Array(0...11).map { String($0) + "\"" }
            return [arrayOne, arrayTwo]
        }
    }

    var heightInitialValueForPicker: [Int] {
        switch heightUnits {
        case .metric:
            if let height = height {
                return [Int(height), Int((height-Double(Int(height)))*100)]
            } else {
                return [1, 65]
            }
        case .imperial:
            if let height = height {
                let heightInInches = Int(height*Conversion.inchToMeter.rawValue)
                return [heightInInches/Int(Conversion.inchToFeet.rawValue),
                        heightInInches%Int(Conversion.inchToFeet.rawValue)]
            } else {
                return [5, 6]
            }
        }
    }

    mutating func setHeightInMetersFor(compOne: Int, compTwo: Int) {
        switch heightUnits {
        case .metric:
            height = Double(compOne) + Double(compTwo)/100.0
        case .imperial:
            height = Double(compOne*Int(Conversion.inchToFeet.rawValue) + compTwo)/Conversion.inchToMeter.rawValue
        }
    }

    mutating func setActivityLevel(compOne: Int) {
        activityLevel = ActivityLevel.allCases[compOne]
    }

    mutating func setMealPlan(mealPlan: PassioMealPlan) {
        self.mealPlan = mealPlan
        if let carbs = mealPlan.carbsTarget,
           let protien = mealPlan.proteinTarget,
           let fat = mealPlan.fatTarget{
            self.carbsPercent = carbs
            self.proteinPercent = protien
            self.fatPercent = fat
        }
        PassioInternalConnector.shared.updateUserProfile(userProfile: self)
    }

    public var getJSONDict: [String: Any]? {
        if let data = try? JSONEncoder().encode(self),
           let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return dic
        }
        return nil
    }
}

enum GenderSelection: String, Codable, CaseIterable {
    case male
    case female
}

public enum UnitSelection: String, Codable, CaseIterable {
    case imperial
    case metric

    var heightDisplay: String {
        switch self{
        case .imperial: "Feet, Inches"
        case .metric: "Meter"
        }
    }
    var weightDisplay: String {
        switch self{
        case .imperial: "lbs"
        case .metric: "kg"
        }
    }

    static var localDefault: UnitSelection {
        let locale = Locale.current
        if locale.usesMetricSystem {
            return .metric
        } else {
            return .imperial
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case notActive = "Not Active"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case active = "Active"
}

public struct ReminderSettings: Codable, Equatable {
    var breakfast: Bool?
    var lunch: Bool?
    var dinner: Bool?
}

public enum WaterUnit: String, Codable, CaseIterable {
    case oz, ml
    
    static func convertWaterMeasurement(value: Double,
                                        from: WaterUnit,
                                        to: WaterUnit) -> Double {

        let mlPerOunce = 29.5735  // 1 fluid ounce is approximately 29.5735 ml
        
        switch (from, to) {
        case (.oz, .ml):
            return value * mlPerOunce
        case (.ml, .oz):
            return value / mlPerOunce
        case (.oz, .oz):
            return value
        case (.ml, .ml):
            return value
        }
    }
}

var calorieDeficitArray: [String] {

    return [Localized.lose05,
            Localized.lose1,
            Localized.lose15,
            Localized.lose2,
            Localized.gain05,
            Localized.gain1,
            Localized.gain15,
            Localized.gain2,
            Localized.maintainWeight]
}

class MealPlanManager {

    static var shared: MealPlanManager = MealPlanManager()
    var mealPlans: [PassioMealPlan] = []

    private init() {}

    func getMealPlans() {
        PassioNutritionAI.shared.fetchMealPlans { [weak self] mealPlans in
            self?.mealPlans = mealPlans
        }
    }
}
