//
//  FoodRecordV3+MicroNutrients.swift
//  BaseApp
//
//  Created by Mind on 29/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation

// MARK: MicroNutrients
extension FoodRecordV3 {

    var totalSugar: Double {
        ingredients.map {$0.nutrients.sugars()?.value ?? 0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var saturatedFat: Double {
        ingredients.map {$0.nutrients.satFat()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var transFat: Double {
        ingredients.map {$0.nutrients.transFat()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var monounsaturatedFat: Double {
        ingredients.map {$0.nutrients.monounsaturatedFat()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var polyunsaturatedFat: Double {
        ingredients.map {$0.nutrients.polyunsaturatedFat()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var cholesterol: Double {
        ingredients.map {$0.nutrients.cholesterol()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var sodium: Double {
        ingredients.map {$0.nutrients.sodium()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var fibers: Double {
        ingredients.map {$0.nutrients.fibers()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var vitaminD: Double {
        ingredients.map {$0.nutrients.vitaminD()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var calcium: Double {
        ingredients.map {$0.nutrients.calcium()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var iron: Double {
        ingredients.map {$0.nutrients.iron()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var potassium: Double {
        ingredients.map {$0.nutrients.potassium()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var vitaminA: Double {
        ingredients.map {$0.nutrients.vitaminA() ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var vitaminC: Double {
        ingredients.map {$0.nutrients.vitaminC()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var alcohol: Double {
        ingredients.map {$0.nutrients.alcohol()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var sugarAlcohol: Double {
        ingredients.map {$0.nutrients.sugarAlcohol()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var vitaminB12: Double {
        ingredients.map {$0.nutrients.vitaminB12()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var vitaminB6: Double {
        ingredients.map {$0.nutrients.vitaminB6()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var vitaminE: Double {
        ingredients.map {$0.nutrients.vitaminE()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var magnesium: Double {
        ingredients.map {$0.nutrients.magnesium()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var phosphorus: Double {
        ingredients.map {$0.nutrients.phosphorus()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var iodine: Double {
        ingredients.map {$0.nutrients.iodine()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var selenium: Double {
        ingredients.map {$0.nutrients.selenium()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var zinc: Double {
        ingredients.map {$0.nutrients.zinc()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var folicAcid: Double {
        ingredients.map {$0.nutrients.folicAcid()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var chromium: Double {
        ingredients.map {$0.nutrients.chromium()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }

    var addedSugar: Double {
        ingredients.map {$0.nutrients.sugarsAdded()?.value ?? 0.0}.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }
}

// MARK: - MicroNutirents Model
struct MicroNutirents {

    let name: String
    let value: Double
    let unit: String
    let recommendedValue: Double

    static func getMicroNutrientsFromFood(records: [FoodRecordV3]) -> [MicroNutirents] {

        let fiber = records.map { $0.fibers }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let sugar = records.map { $0.totalSugar }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let addedSugar = records.map { $0.addedSugar }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let saturatedFat = records.map { $0.saturatedFat }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let transFat = records.map { $0.transFat }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let polyunsatFat = records.map { $0.polyunsaturatedFat }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let monounsatFat = records.map { $0.monounsaturatedFat }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let cholesterol = records.map { $0.cholesterol }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let sodium = records.map { $0.sodium }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let potassium = records.map { $0.potassium }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let iron = records.map { $0.iron }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let magnesium = records.map { $0.magnesium }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let iodine = records.map { $0.iodine }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let vitaminA = records.map { $0.vitaminA }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let vitaminB6 = records.map { $0.vitaminB6 }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let vitaminB12 = records.map { $0.vitaminB12 }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let vitaminC = records.map { $0.vitaminC }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let vitaminD = records.map { $0.vitaminD }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let vitaminE = records.map { $0.vitaminE }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let calcium = records.map { $0.calcium }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let selenium = records.map { $0.selenium }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let zinc = records.map { $0.zinc }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let folicAcid = records.map { $0.folicAcid }.reduce(0.0, +).roundDigits(afterDecimal: 2)
        let chromium = records.map { $0.chromium }.reduce(0.0, +).roundDigits(afterDecimal: 2)

        return [
            MicroNutirents(name: "Saturated Fat", value: saturatedFat, unit: Localized.gramUnit, recommendedValue: 20),
            MicroNutirents(name: "Trans Fat", value: transFat, unit: Localized.gramUnit, recommendedValue: 2.2),
            MicroNutirents(name: "Cholesterol", value: cholesterol, unit: Localized.mgUnit, recommendedValue: 300),
            MicroNutirents(name: "Sodium", value: sodium, unit: Localized.mgUnit, recommendedValue: 2300),
            MicroNutirents(name: "Dietary Fiber", value: fiber, unit: Localized.gramUnit, recommendedValue: 28),
            MicroNutirents(name: "Total Sugar", value: sugar, unit: Localized.gramUnit, recommendedValue: 50),
            MicroNutirents(name: "Added Sugar", value: addedSugar, unit: Localized.gramUnit, recommendedValue: 50),
            MicroNutirents(name: "Vitamin D", value: vitaminD, unit: Localized.mcgUnit, recommendedValue: 20),
            MicroNutirents(name: "Calcium", value: calcium, unit: Localized.mgUnit, recommendedValue: 1000),
            MicroNutirents(name: "Iron", value: iron, unit: Localized.mgUnit, recommendedValue: 18),
            MicroNutirents(name: "Potassium", value: potassium, unit: Localized.mgUnit, recommendedValue: 4700),
            MicroNutirents(name: "Polyunsaturated Fat", value: polyunsatFat, unit: Localized.gramUnit, recommendedValue: 22),
            MicroNutirents(name: "Monounsaturated Fat", value: monounsatFat, unit: Localized.gramUnit, recommendedValue: 44),
            MicroNutirents(name: "Magnesium", value: magnesium, unit: Localized.mgUnit, recommendedValue: 420),
            MicroNutirents(name: "Iodine", value: iodine, unit: Localized.mcgUnit, recommendedValue: 150),
            MicroNutirents(name: "Vitamin B6", value: vitaminB6, unit: Localized.mgUnit, recommendedValue: 1.7),
            MicroNutirents(name: "Vitamin B12", value: vitaminB12, unit: Localized.mcgUnit, recommendedValue: 2.4),
            MicroNutirents(name: "Vitamin E", value: vitaminE, unit: Localized.mgUnit, recommendedValue: 15),
            MicroNutirents(name: "Vitamin A", value: vitaminA, unit: "IU", recommendedValue: 3000),
            MicroNutirents(name: "Vitamin C", value: vitaminC, unit: Localized.mgUnit, recommendedValue: 90),
            MicroNutirents(name: "Zinc", value: zinc, unit: Localized.mgUnit, recommendedValue: 10),
            MicroNutirents(name: "Selenium", value: selenium, unit: Localized.mcgUnit, recommendedValue: 55),
            MicroNutirents(name: "Folic Acid", value: folicAcid, unit: Localized.mcgUnit, recommendedValue: 400),
            MicroNutirents(name: "Chromium", value: chromium, unit: Localized.mcgUnit, recommendedValue: 35)
        ]
    }
}
