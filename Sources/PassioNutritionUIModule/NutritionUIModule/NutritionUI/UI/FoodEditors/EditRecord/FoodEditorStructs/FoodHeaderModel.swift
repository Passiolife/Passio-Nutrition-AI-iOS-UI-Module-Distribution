//
//  FoodHeaderModel.swift
//  BaseApp
//
//  Created by zvika on 5/3/20.
//  Copyright © 2023 Passio Inc. All rights reserved.
//

import Foundation

struct FoodHeaderModel {
    var labelName = ""
    var labelShortName = ""
    var labelServing = ""
    var calories = "0"
    var carbs = "0"
    var protein = "0"
    var fat = "0"
    let labelCal = "Calories".localized
    let labelCarbs = "Carbs".localized
    let labelProtein = "Protein".localized
    let lableFat = "Fat".localized

    init(foodRecord: FoodRecordV3) {
        labelName = foodRecord.name
        labelShortName = foodRecord.details
        let quantity = foodRecord.selectedQuantity
        let unitName = foodRecord.selectedUnit.capitalizingFirst()
        let weight = String(Int(foodRecord.computedWeight.value))
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
            String(quantity.roundDigits(afterDecimal: 2))
        let displayUnit = "g".localized
        let weightText = unitName == "g" ? "" : "(" + weight + " " + displayUnit + ") "
        labelServing = textAmount + " " + unitName + " " + weightText
        calories = String(Int(foodRecord.totalCalories))
        carbs = foodRecord.totalCarbs.roundDigits(afterDecimal: 1).clean
        protein = foodRecord.totalProteins.roundDigits(afterDecimal: 1).clean
        fat = foodRecord.totalFat.roundDigits(afterDecimal: 1).clean
    }
    
}

