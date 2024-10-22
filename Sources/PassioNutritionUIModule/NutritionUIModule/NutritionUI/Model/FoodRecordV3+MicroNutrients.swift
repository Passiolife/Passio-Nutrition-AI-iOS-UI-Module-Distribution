//
//  FoodRecordV3+MicroNutrients.swift
//  BaseApp
//
//  Created by Mind on 29/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation

typealias MeasurementValue = (value: Double, unit: String)

// MARK: MicroNutrients
extension FoodRecordV3 {

    private func getMeasurement(for nutrient: [Measurement<UnitMass>?],
                                unit: String = UnitsTexts.g) -> MeasurementValue {
        return (value: nutrient.map { $0?.value ?? 0 }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                unit: nutrient.first??.unit.symbol ?? unit)
    }

    var totalSugar: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.sugars() })
    }

    var addedSugar: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.sugarsAdded() })
    }

    var saturatedFat: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.satFat() })
    }

    var transFat: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.transFat() })
    }

    var monounsaturatedFat: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.monounsaturatedFat() })
    }

    var polyunsaturatedFat: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.polyunsaturatedFat() })
    }

    var cholesterol: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.cholesterol() }, unit: UnitsTexts.mg)
    }

    var sodium: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.sodium() }, unit: UnitsTexts.mg)
    }

    var fibers: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.fibers() })
    }

    var vitaminD: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.vitaminD() }, unit: UnitsTexts.mcg)
    }

    var calcium: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.calcium() }, unit: UnitsTexts.mg)
    }

    var iron: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.iron() }, unit: UnitsTexts.mg)
    }

    var potassium: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.potassium() }, unit: UnitsTexts.mg)
    }

    var vitaminA: Double {
        ingredients.map { $0.nutrients.vitaminA() ?? 0 }.reduce(0.0, +).roundDigits(afterDecimal: 2)
    }
    
    var vitaminA_RAE: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.vitaminA_RAE() }, unit: UnitsTexts.mcg)
    }

    var vitaminC: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.vitaminC() }, unit: UnitsTexts.mg)
    }

    var alcohol: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.alcohol() })
    }

    var sugarAlcohol: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.sugarAlcohol() })
    }

    var vitaminB12: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.vitaminB12() }, unit: UnitsTexts.mcg)
    }

    var vitaminB6: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.vitaminB6() }, unit: UnitsTexts.mg)
    }

    var vitaminE: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.vitaminE() }, unit: UnitsTexts.mg)
    }

    var magnesium: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.magnesium() }, unit: UnitsTexts.mg)
    }

    var phosphorus: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.phosphorus() }, unit: UnitsTexts.mg)
    }

    var iodine: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.iodine() }, unit: UnitsTexts.mcg)
    }

    var selenium: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.selenium() }, unit: UnitsTexts.mcg)
    }

    var zinc: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.zinc() }, unit: UnitsTexts.mg)
    }

    var folicAcid: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.folicAcid() }, unit: UnitsTexts.mcg)
    }

    var chromium: MeasurementValue {
        getMeasurement(for: ingredients.map { $0.nutrients.chromium() }, unit: UnitsTexts.mcg)
    }
}

// MARK: - MicroNutirents Model
struct MicroNutirents {

    let name: String
    let value: Double
    let unit: String
    let recommendedValue: Double

    static func getMicroNutrientsFromFood(records: [FoodRecordV3]) -> [MicroNutirents] {

        return [
            MicroNutirents(name: "Saturated Fat",
                           value: records.map { $0.saturatedFat.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.saturatedFat.unit ?? UnitsTexts.g,
                           recommendedValue: 20),
            MicroNutirents(name: "Trans Fat",
                           value: records.map { $0.transFat.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.transFat.unit ?? UnitsTexts.g,
                           recommendedValue: 2.2),
            MicroNutirents(name: "Cholesterol",
                           value: records.map { $0.cholesterol.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.cholesterol.unit ?? UnitsTexts.mg,
                           recommendedValue: 300),
            MicroNutirents(name: "Sodium",
                           value: records.map { $0.sodium.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.sodium.unit ?? UnitsTexts.mg,
                           recommendedValue: 2300),
            MicroNutirents(name: "Dietary Fiber",
                           value: records.map { $0.fibers.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.fibers.unit ?? UnitsTexts.g,
                           recommendedValue: 28),
            MicroNutirents(name: "Total Sugar",
                           value: records.map { $0.totalSugar.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.totalSugar.unit ?? UnitsTexts.g,
                           recommendedValue: 50),
            MicroNutirents(name: "Added Sugar",
                           value: records.map { $0.addedSugar.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.addedSugar.unit ?? UnitsTexts.g,
                           recommendedValue: 50),
            MicroNutirents(name: "Vitamin D",
                           value: records.map { $0.vitaminD.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.vitaminD.unit ?? UnitsTexts.mcg,
                           recommendedValue: 20),
            MicroNutirents(name: "Calcium",
                           value: records.map { $0.calcium.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.calcium.unit ?? UnitsTexts.mg,
                           recommendedValue: 1000),
            MicroNutirents(name: "Iron",
                           value: records.map { $0.iron.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.iron.unit ?? UnitsTexts.mg,
                           recommendedValue: 18),
            MicroNutirents(name: "Potassium",
                           value: records.map { $0.potassium.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.potassium.unit ?? UnitsTexts.mg,
                           recommendedValue: 4700),
            MicroNutirents(name: "Polyunsaturated Fat",
                           value: records.map { $0.polyunsaturatedFat.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.polyunsaturatedFat.unit ?? UnitsTexts.g,
                           recommendedValue: 22),
            MicroNutirents(name: "Monounsaturated Fat",
                           value: records.map { $0.monounsaturatedFat.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.monounsaturatedFat.unit ?? UnitsTexts.g,
                           recommendedValue: 44),
            MicroNutirents(name: "Magnesium",
                           value: records.map { $0.magnesium.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.magnesium.unit ?? UnitsTexts.mg,
                           recommendedValue: 420),
            MicroNutirents(name: "Iodine",
                           value: records.map { $0.iodine.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.iodine.unit ?? UnitsTexts.mcg,
                           recommendedValue: 150),
            MicroNutirents(name: "Vitamin B6",
                           value: records.map { $0.vitaminB6.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.vitaminB6.unit ?? UnitsTexts.mg,
                           recommendedValue: 1.7),
            MicroNutirents(name: "Vitamin B12",
                           value: records.map { $0.vitaminB12.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.vitaminB12.unit ?? UnitsTexts.mcg,
                           recommendedValue: 2.4),
            MicroNutirents(name: "Vitamin E",
                           value: records.map { $0.vitaminE.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.vitaminE.unit ?? UnitsTexts.mg,
                           recommendedValue: 15),
            MicroNutirents(name: "Vitamin A",
                           value: records.map { $0.vitaminA }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: UnitsTexts.iu,
                           recommendedValue: 3000),
            MicroNutirents(name: "Vitamin A, RAE",
                           value: records.map { $0.vitaminA_RAE.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.vitaminA_RAE.unit ?? UnitsTexts.mcg,
                           recommendedValue: 900),
            MicroNutirents(name: "Vitamin C",
                           value: records.map { $0.vitaminC.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.vitaminC.unit ?? UnitsTexts.mg,
                           recommendedValue: 90),
            MicroNutirents(name: "Zinc",
                           value: records.map { $0.zinc.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.zinc.unit ?? UnitsTexts.mg,
                           recommendedValue: 10),
            MicroNutirents(name: "Selenium",
                           value: records.map { $0.selenium.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.selenium.unit ?? UnitsTexts.mcg,
                           recommendedValue: 55),
            MicroNutirents(name: "Folic Acid",
                           value: records.map { $0.folicAcid.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.folicAcid.unit ?? UnitsTexts.mcg,
                           recommendedValue: 400),
            MicroNutirents(name: "Chromium",
                           value: records.map { $0.chromium.value }.reduce(0.0, +).roundDigits(afterDecimal: 2),
                           unit: records.first?.chromium.unit ?? UnitsTexts.mcg,
                           recommendedValue: 35)
        ]
    }

    static func getMicroNutrientsFromIngredient(record: FoodRecordIngredient) -> [MicroNutirents] {

        return [
            MicroNutirents(name: "Saturated Fat",
                           value: record.saturatedFat.value,
                           unit: record.saturatedFat.unit,
                           recommendedValue: 20),
            MicroNutirents(name: "Trans Fat",
                           value: record.transFat.value,
                           unit: record.transFat.unit,
                           recommendedValue: 2.2),
            MicroNutirents(name: "Cholesterol",
                           value: record.cholesterol.value,
                           unit: record.cholesterol.unit,
                           recommendedValue: 300),
            MicroNutirents(name: "Sodium",
                           value: record.sodium.value,
                           unit: record.sodium.unit,
                           recommendedValue: 2300),
            MicroNutirents(name: "Dietary Fiber",
                           value: record.fibers.value,
                           unit: record.fibers.unit,
                           recommendedValue: 28),
            MicroNutirents(name: "Total Sugar",
                           value: record.totalSugar.value,
                           unit: record.totalSugar.unit,
                           recommendedValue: 50),
            MicroNutirents(name: "Added Sugar",
                           value: record.addedSugar.value,
                           unit: record.addedSugar.unit,
                           recommendedValue: 50),
            MicroNutirents(name: "Vitamin D",
                           value: record.vitaminD.value,
                           unit: record.vitaminD.unit,
                           recommendedValue: 20),
            MicroNutirents(name: "Calcium",
                           value: record.calcium.value,
                           unit: record.calcium.unit,
                           recommendedValue: 1000),
            MicroNutirents(name: "Iron",
                           value: record.iron.value,
                           unit: record.iron.unit,
                           recommendedValue: 18),
            MicroNutirents(name: "Potassium",
                           value: record.potassium.value,
                           unit: record.potassium.unit,
                           recommendedValue: 4700),
            MicroNutirents(name: "Polyunsaturated Fat",
                           value: record.polyunsaturatedFat.value,
                           unit: record.polyunsaturatedFat.unit,
                           recommendedValue: 22),
            MicroNutirents(name: "Monounsaturated Fat",
                           value: record.monounsaturatedFat.value,
                           unit: record.monounsaturatedFat.unit,
                           recommendedValue: 44),
            MicroNutirents(name: "Magnesium",
                           value: record.magnesium.value,
                           unit: record.magnesium.unit,
                           recommendedValue: 420),
            MicroNutirents(name: "Iodine",
                           value: record.iodine.value,
                           unit: record.iodine.unit,
                           recommendedValue: 150),
            MicroNutirents(name: "Vitamin B6",
                           value: record.vitaminB6.value,
                           unit: record.vitaminB6.unit,
                           recommendedValue: 1.7),
            MicroNutirents(name: "Vitamin B12",
                           value: record.vitaminB12.value,
                           unit: record.vitaminB12.unit,
                           recommendedValue: 2.4),
            MicroNutirents(name: "Vitamin E",
                           value: record.vitaminE.value,
                           unit: record.vitaminE.unit,
                           recommendedValue: 15),
            MicroNutirents(name: "Vitamin A",
                           value: record.vitaminA,
                           unit: UnitsTexts.iu,
                           recommendedValue: 3000),
            MicroNutirents(name: "Vitamin A, RAE",
                           value: record.vitaminA_RAE.value,
                           unit: record.vitaminA_RAE.unit,
                           recommendedValue: 900),
            MicroNutirents(name: "Vitamin C",
                           value: record.vitaminC.value,
                           unit: record.vitaminC.unit,
                           recommendedValue: 90),
            MicroNutirents(name: "Zinc",
                           value: record.zinc.value,
                           unit: record.zinc.unit,
                           recommendedValue: 10),
            MicroNutirents(name: "Selenium",
                           value: record.selenium.value,
                           unit: record.selenium.unit,
                           recommendedValue: 55),
            MicroNutirents(name: "Folic Acid",
                           value: record.folicAcid.value,
                           unit: record.folicAcid.unit,
                           recommendedValue: 400),
            MicroNutirents(name: "Chromium",
                           value: record.chromium.value,
                           unit: record.chromium.unit,
                           recommendedValue: 35)
        ]
    }
}
