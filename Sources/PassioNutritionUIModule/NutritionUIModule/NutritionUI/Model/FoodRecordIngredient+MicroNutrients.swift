//
//  File.swift
//  
//
//  Created by Nikunj Prajapati on 04/09/24.
//

import Foundation

// MARK: MicroNutrients
extension FoodRecordIngredient {

    private func getMeasurement(for nutrient: Measurement<UnitMass>?,
                                unit: String = UnitsTexts.g) -> MeasurementValue {
        return (value: (nutrient?.value ?? 0).roundDigits(afterDecimal: 2),
                unit: nutrient?.unit.symbol ?? unit)
    }

    var totalSugar: MeasurementValue {
        getMeasurement(for: nutrients.sugars())
    }

    var addedSugar: MeasurementValue {
        getMeasurement(for: nutrients.sugarsAdded())
    }

    var saturatedFat: MeasurementValue {
        getMeasurement(for: nutrients.satFat())
    }

    var transFat: MeasurementValue {
        getMeasurement(for: nutrients.transFat())
    }

    var monounsaturatedFat: MeasurementValue {
        getMeasurement(for: nutrients.monounsaturatedFat())
    }

    var polyunsaturatedFat: MeasurementValue {
        getMeasurement(for: nutrients.polyunsaturatedFat())
    }

    var cholesterol: MeasurementValue {
        getMeasurement(for: nutrients.cholesterol(), unit: UnitsTexts.mg)
    }

    var sodium: MeasurementValue {
        getMeasurement(for: nutrients.sodium(), unit: UnitsTexts.mg)
    }

    var fibers: MeasurementValue {
        getMeasurement(for: nutrients.fibers())
    }

    var vitaminD: MeasurementValue {
        getMeasurement(for: nutrients.vitaminD(), unit: UnitsTexts.mcg)
    }

    var calcium: MeasurementValue {
        getMeasurement(for: nutrients.calcium(), unit: UnitsTexts.mg)
    }

    var iron: MeasurementValue {
        getMeasurement(for: nutrients.iron(), unit: UnitsTexts.mg)
    }

    var potassium: MeasurementValue {
        getMeasurement(for: nutrients.potassium(), unit: UnitsTexts.mg)
    }

    var vitaminA: Double {
        (nutrients.vitaminA() ?? 0).roundDigits(afterDecimal: 2)
    }
    
    var vitaminA_RAE: MeasurementValue {
        getMeasurement(for: nutrients.vitaminA_REA(), unit: UnitsTexts.mcg)
    }

    var vitaminC: MeasurementValue {
        getMeasurement(for: nutrients.vitaminC(), unit: UnitsTexts.mg)
    }

    var alcohol: MeasurementValue {
        getMeasurement(for: nutrients.alcohol())
    }

    var sugarAlcohol: MeasurementValue {
        getMeasurement(for: nutrients.sugarAlcohol())
    }

    var vitaminB12: MeasurementValue {
        getMeasurement(for: nutrients.vitaminB12(), unit: UnitsTexts.mcg)
    }

    var vitaminB6: MeasurementValue {
        getMeasurement(for: nutrients.vitaminB6(), unit: UnitsTexts.mg)
    }

    var vitaminE: MeasurementValue {
        getMeasurement(for: nutrients.vitaminE(), unit: UnitsTexts.mg)
    }

    var magnesium: MeasurementValue {
        getMeasurement(for: nutrients.magnesium(), unit: UnitsTexts.mg)
    }

    var phosphorus: MeasurementValue {
        getMeasurement(for: nutrients.phosphorus(), unit: UnitsTexts.mg)
    }

    var iodine: MeasurementValue {
        getMeasurement(for: nutrients.iodine(), unit: UnitsTexts.mcg)
    }

    var selenium: MeasurementValue {
        getMeasurement(for: nutrients.selenium(), unit: UnitsTexts.mcg)
    }

    var zinc: MeasurementValue {
        getMeasurement(for: nutrients.zinc(), unit: UnitsTexts.mg)
    }

    var folicAcid: MeasurementValue {
        getMeasurement(for: nutrients.folicAcid(), unit: UnitsTexts.mcg)
    }

    var chromium: MeasurementValue {
        getMeasurement(for: nutrients.chromium(), unit: UnitsTexts.mcg)
    }

    var getAllNutrients: [MicroNutirents] {
        [MicroNutirents]()
    }
}
