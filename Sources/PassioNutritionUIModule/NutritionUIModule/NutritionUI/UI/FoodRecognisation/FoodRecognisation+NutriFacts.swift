//
//  FoodRecognisation+NutriFacts.swift
//  BaseApp
//
//  Created by Mind on 14/03/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

struct NutriFactCellData {
    var name: String
    var value: Double?
    var text: String
    var stringValue: String
}

extension NutritionFactsDataSet {

    var calories: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleCalories,
                                 value: nfc.calories,
                                 text: nfc.caloriesText,
                                 stringValue: (nfc.caloriesText) + " \(UnitsTexts.cal)")
    }

    var carbs: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleTotalCarbs,
                                 value: nfc.carbs,
                                 text: nfc.carbsText,
                                 stringValue: getNutritionValue(with: nfc.carbs, unit: "\(UnitsTexts.g)"))
    }

    var protein: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleProtein,
                                 value: nfc.protein,
                                 text: nfc.proteinText,
                                 stringValue: getNutritionValue(with: nfc.protein, unit: "\(UnitsTexts.g)"))
    }

    var fat: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleTotalFat,
                                 value: nfc.fat,
                                 text: nfc.fatText,
                                 stringValue: getNutritionValue(with: nfc.fat, unit: "\(UnitsTexts.g)"))
    }

    var saturatedFat: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleSaturatedFat,
                                 value: nfc.saturatedFat,
                                 text: nfc.saturatedFatText,
                                 stringValue: getNutritionValue(with: nfc.saturatedFat, unit: "\(UnitsTexts.g)"))
    }

    var transFat: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleTransFat,
                                 value: nfc.transFat,
                                 text: nfc.transFatText,
                                 stringValue: getNutritionValue(with: nfc.transFat, unit: "\(UnitsTexts.g)"))
    }

    var cholesterol: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleCholesterol,
                                 value: nfc.cholesterol,
                                 text: nfc.cholesterolText,
                                 stringValue: getNutritionValue(with: nfc.cholesterol, unit: "\(UnitsTexts.mg)"))
    }

    var sodium: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleSodium,
                                 value: nfc.sodium,
                                 text: nfc.sodiumText,
                                 stringValue: getNutritionValue(with: nfc.sodium, unit: "\(UnitsTexts.mg)"))
    }

    var dietaryFiber: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleDietaryFiber,
                                 value: nfc.dietaryFiber,
                                 text: nfc.dietaryFiberText,
                                 stringValue: getNutritionValue(with: nfc.dietaryFiber, unit: "\(UnitsTexts.g)"))
    }

    var totalSugar: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleTotalSugars,
                                 value: nfc.sugars,
                                 text: nfc.sugarsText,
                                 stringValue: getNutritionValue(with: nfc.sugars, unit: "\(UnitsTexts.g)"))
    }

    var sugarAlcohol: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleSugarAlcohol,
                                 value: nfc.sugarAlcohol,
                                 text: nfc.sugarAlcoholText,
                                 stringValue: getNutritionValue(with: nfc.sugarAlcohol, unit: "\(UnitsTexts.g)"))
    }

    var totalSugars: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleTotalSugars,
                                 value: nfc.totalSugars,
                                 text: nfc.totalSugarsText,
                                 stringValue: getNutritionValue(with: nfc.totalSugars, unit: "\(UnitsTexts.g)"))
    }

    var addedSugar: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleAddedSugar,
                                 value: nfc.addedSugar,
                                 text: nfc.addedSugarText,
                                 stringValue: getNutritionValue(with: nfc.addedSugar, unit: "\(UnitsTexts.g)"))
    }

    var vitaminD: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleVitaminD,
                                 value: nfc.vitaminD,
                                 text: nfc.vitaminDText,
                                 stringValue: getNutritionValue(with: nfc.vitaminD, unit: "\(UnitsTexts.mcg)"))
    }

    var calcium: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleCalcium,
                                 value: nfc.calcium,
                                 text: nfc.calciumText,
                                 stringValue: getNutritionValue(with: nfc.calcium, unit: "\(UnitsTexts.mg)"))
    }

    var iron: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titleIron, 
                                 value: nfc.iron,
                                 text: nfc.ironText,
                                 stringValue: getNutritionValue(with: nfc.iron, unit: "\(UnitsTexts.mg)"))
    }

    var potassium: NutriFactCellData? {
        guard let nfc = nutritionFacts else { return nil }
        return NutriFactCellData(name: nfc.titlePotassium,
                                 value: nfc.potassium,
                                 text: nfc.potassiumText,
                                 stringValue: getNutritionValue(with: nfc.potassium, unit: "\(UnitsTexts.mg)"))
    }

    func getNutritionValue(with value: Double?, unit: String) -> String {
        (value?.roundDigits(afterDecimal: 4).clean ?? "-") + " \(unit)"
        //value?.clean ?? "-"
    }
}
