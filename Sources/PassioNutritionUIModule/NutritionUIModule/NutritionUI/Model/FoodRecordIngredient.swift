//
//  FoodRecordIngredient.swift
//  NutritionAISDK
//
//  Created by Nikunj Prajapati on 16/01/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public struct FoodRecordIngredient: Codable, Equatable {

    public var passioID: PassioID = ""
    public var name: String = ""
    public var iconId: String = ""
    public var refCode: String = ""
    public var selectedUnit: String = ""
    public var selectedQuantity: Double = 0.0
    public var servingSizes: [PassioServingSize]
    public var servingUnits: [PassioServingUnit]
    public var nutrients: PassioNutrients
    public var openFoodLicense: String? = ""
    public var details: String = ""
    public var entityType: PassioIDEntityType
    public var computedWeight: Measurement<UnitMass> {
        guard let weight2QuantityRatio = (servingUnits.filter {$0.unitName == selectedUnit}).first?.weight.value else {
            return Measurement<UnitMass>(value: 0, unit: .grams)
        }
        return Measurement<UnitMass>(value: weight2QuantityRatio * selectedQuantity, unit: .grams)
    }

    public var isOpenFood: Bool {
        (openFoodLicense ?? "" == "") ? false : true
    }

    public var totalCalories: Double {
        nutrients.calories()?.value ?? 0
    }

    public var totalCarbs: Double {
        nutrients.carbs()?.value ?? 0
    }

    public var totalProteins: Double {
        nutrients.protein()?.value ?? 0
    }

    public var totalFat: Double {
        nutrients.fat()?.value ?? 0
    }
    
    public var totalFiber: Double {
        nutrients.fibers()?.value ?? 0
    }

    public var nutritionSummary: NutritionSummary {
        (calories: totalCalories, carbs: totalCarbs, protein: totalProteins, fat: totalFat)
    }

    init(foodRecord: FoodRecordV3, entityType: PassioIDEntityType = .item) {

        passioID = foodRecord.passioID
        name = foodRecord.name
        details = foodRecord.details
        iconId = foodRecord.iconId
        refCode = foodRecord.refCode

        self.entityType = entityType

        selectedUnit = foodRecord.selectedUnit
        selectedQuantity = foodRecord.selectedQuantity
        servingSizes = foodRecord.servingSizes
        servingUnits = foodRecord.servingUnits

        nutrients = foodRecord.getNutrients()

        openFoodLicense = foodRecord.openFoodLicense
    }

    init(ingredient: PassioIngredient, entityType: PassioIDEntityType = .item) {

        passioID = ingredient.id
        name = ingredient.name
        iconId = ingredient.iconId
        refCode = ingredient.refCode ?? ""

        self.entityType = entityType

        servingSizes = ingredient.amount.servingSizes
        servingUnits = ingredient.amount.servingUnits
        selectedUnit = ingredient.amount.selectedUnit
        selectedQuantity = ingredient.amount.selectedQuantity

        nutrients = ingredient.referenceNutrients

        openFoodLicense = ingredient.metadata.foodOrigins?.first(where: { $0.source == "openfood" })?.licenseCopy
    }

    mutating public func setFoodIngredientServing(unit: String, quantity: Double) -> Bool {

        guard (servingUnits.filter { $0.unitName == unit }).first?.weight != nil else {
            return false
        }
        selectedUnit = unit
        selectedQuantity = quantity != 0 ? quantity : 0.0001
        let newNutrients = self.nutrients
        let newWeight = self.computedWeight 
        nutrients = PassioNutrients(referenceNutrients: newNutrients,
                                             weight: newWeight)
        return true
    }

    mutating public func setServingUnitKeepWeight(unitName: String) -> Bool {
        guard  let weight2Quantity = (servingUnits.filter { $0.unitName == unitName }).first?.weight  else {
            return false
        }
        selectedQuantity = computedWeight.value / weight2Quantity.value
        selectedUnit = unitName
        return true
    }

    mutating func setSelectedUnit(unit: String) -> Bool {

        var unit = if unit == "Gram" {
            unit.lowercased()
        } else {
            unit
        }

        if selectedUnit == unit {
            return true
        }
        if servingUnits.first(where: { $0.unitName == unit }) == nil {
            return false
        }
        selectedUnit = unit
        selectedQuantity = unit == "gram" ? 100 : 1
        return true
    }
}
