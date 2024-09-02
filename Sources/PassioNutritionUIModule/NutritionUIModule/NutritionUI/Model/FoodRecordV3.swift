//
//  FoodRecordV3.swift
//  NutritionAISDK
//
//  Created by Nikunj Prajapati on 16/01/24.`
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

func getNutritionSummaryfor(foodRecords: [FoodRecordV3]) -> NutritionSummary {
    var nutritionSum: NutritionSummary = (0, 0, 0, 0)
    foodRecords.forEach {
        nutritionSum.calories += $0.nutritionSummary.calories
        nutritionSum.carbs += $0.nutritionSummary.carbs
        nutritionSum.protein += $0.nutritionSummary.protein
        nutritionSum.fat += $0.nutritionSummary.fat
    }
    return nutritionSum
}

public typealias NutritionSummary = (calories: Double, carbs: Double, protein: Double, fat: Double)

public struct FoodRecordV3: Codable, Equatable {

    public var radioSelected: Bool?
    public var passioID: PassioID = ""
    public var id: String = ""
    public var name: String = ""
    public var details: String = ""
    public var iconId: String = ""
    public var uuid: String
    public var createdAt: Date
    public var mealLabel: MealLabel = .snack
    public var barcode: String = ""
    public var refCode: String = ""

    public var ingredients: [FoodRecordIngredient] = []

    public var servingSizes: [PassioServingSize]
    public var servingUnits: [PassioServingUnit]

    private(set) public var selectedUnit: String
    private(set) public var selectedQuantity: Double

    private var nutrients: PassioNutrients!
    public var scannedUnitName = "scanned amount"
    public var entityType: PassioIDEntityType
    public var openFoodLicense: String? = ""
    public let confidence: Double?

    public var isOpenFood: Bool {
        self.ingredients.first(where: { $0.isOpenFood }) != nil
    }

    public var totalCalories: Double {
        ingredients.map { $0.totalCalories }.reduce(0.0, +).roundDigits(afterDecimal: 0)
    }

    public var totalCarbs: Double {
        ingredients.map { $0.totalCarbs }.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    public var totalProteins: Double {
        ingredients.map { $0.totalProteins }.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    public var totalFat: Double {
        ingredients.map { $0.totalFat }.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    public var totalFiber: Double {
        ingredients.map { $0.totalFiber }.reduce(0.0, +).roundDigits(afterDecimal: 1)
    }

    public var nutritionSummary: NutritionSummary {
        (calories: totalCalories, carbs: totalCarbs, protein: totalProteins, fat: totalFat)
    }

    public var computedWeight: Measurement<UnitMass> {
        guard let weight2UnitRatio = (servingUnits.filter {
            $0.unitName == selectedUnit
        }).first?.weight.value else {
            return Measurement<UnitMass>(value: 0, unit: .grams)
        }
        return Measurement<UnitMass>(value: weight2UnitRatio * selectedQuantity, unit: .grams)
    }

    // MARK: init
    public init(foodItem: PassioFoodItem,
                barcode: String = "",
                scannedWeight: Double? = nil,
                entityType: PassioIDEntityType? = nil,
                confidence: Double? = nil) {

        id = foodItem.id
        passioID = foodItem.scannedId
        refCode = foodItem.refCode ?? ""
        name = foodItem.name
        details = foodItem.details
        iconId = foodItem.iconId
        self.barcode = barcode == "" ? foodItem.ingredients.first?.metadata.barcode ?? "" : ""

        let now = Date()
        createdAt = now
        mealLabel = MealLabel.mealLabelBy(time: now)
        uuid = UUID().uuidString

        servingSizes = foodItem.amount.servingSizes
        servingUnits = foodItem.amount.servingUnits
        selectedUnit = foodItem.amount.selectedUnit
        selectedQuantity = foodItem.amount.selectedQuantity

        openFoodLicense = foodItem.licenseCopy

        ingredients = foodItem.ingredients.map { FoodRecordIngredient(ingredient: $0) }

        self.confidence = confidence
        self.entityType = entityType ?? (ingredients.count > 1 ? .recipe : .item)

        calculateQuantityForIngredients()

        if let scannedWeight = scannedWeight {
            addScannedAmount(scannedWeight: scannedWeight)
        } else {
            _ = setFoodRecordServing(unit: selectedUnit, quantity: selectedQuantity)
        }
    }

    public init(ingredient: PassioIngredient,
                barcode: String = "",
                scannedWeight: Double? = nil,
                entityType: PassioIDEntityType? = nil,
                confidence: Double? = nil) {

        passioID = ingredient.id
        name = ingredient.name
        iconId = ingredient.iconId
        refCode = ingredient.refCode ?? ""
        self.barcode = barcode == "" ? ingredient.metadata.barcode ?? "" : ""

        let now = Date()
        createdAt = now
        mealLabel = MealLabel.mealLabelBy(time: now)
        uuid = UUID().uuidString

        servingSizes = ingredient.amount.servingSizes
        servingUnits = ingredient.amount.servingUnits
        selectedUnit = ingredient.amount.selectedUnit
        selectedQuantity = ingredient.amount.selectedQuantity

        nutrients = ingredient.referenceNutrients
        openFoodLicense = ingredient.metadata.foodOrigins?.first(where: {
            $0.source == "openfood"
        })?.licenseCopy

        self.entityType = entityType ?? (ingredients.count > 1 ? .recipe : .item)
        self.confidence = confidence

        if let scannedWeight = scannedWeight {
            addScannedAmount(scannedWeight: scannedWeight)
        } else {
            _ = setFoodRecordServing(unit: selectedUnit, quantity: selectedQuantity)
        }
    }

    public init(foodRecordIngredient: FoodRecordIngredient) {

        passioID = foodRecordIngredient.passioID
        name = foodRecordIngredient.name
        iconId = foodRecordIngredient.iconId
        refCode = foodRecordIngredient.refCode
        self.barcode = foodRecordIngredient.barcode ?? ""

        let now = Date()
        createdAt = now
        mealLabel = MealLabel.mealLabelBy(time: now)
        uuid = UUID().uuidString

        entityType = foodRecordIngredient.entityType
        confidence = nil

        servingSizes = foodRecordIngredient.servingSizes
        servingUnits = foodRecordIngredient.servingUnits
        selectedUnit = foodRecordIngredient.selectedUnit
        selectedQuantity = foodRecordIngredient.selectedQuantity

        nutrients = foodRecordIngredient.nutrients
        openFoodLicense = foodRecordIngredient.openFoodLicense

        _ = setFoodRecordServing(unit: selectedUnit, quantity: selectedQuantity)
    }

    // MARK: Helper for Ingredients
    mutating func addIngredient(record: FoodRecordV3? = nil,
                                ingredient: FoodRecordIngredient? = nil,
                                index: Int = 0) {

        if ingredients.count == 1 { // this is when a food Item become a recipe
            var ingredientsAtZero = ingredients[0]
            ingredientsAtZero.details = details
            ingredients[0] = ingredientsAtZero
        }

        if let ingredient {
            ingredients.append(ingredient)
        } else if let record {
            ingredients.append(contentsOf: record.ingredients)
        }

        updateServingSizeAndUnitsForRecipe()

        if ingredients.count > 1 {
            entityType = .recipe
        }
    }

    mutating func removeIngredient(atIndex: Int) {
        guard atIndex < ingredients.count else { return }
        ingredients.remove(at: atIndex)
        updateServingSizeAndUnitsForRecipe()
    }

    @discardableResult
    mutating func replaceIngredient(updatedIngredient: FoodRecordIngredient, atIndex: Int) -> Bool {

        guard atIndex < ingredients.count else { return false }
        ingredients[atIndex] = updatedIngredient
        updateServingSizeAndUnitsForRecipe()
        return true
    }

    mutating func updateServingSizeAndUnitsForRecipe() {
        let totalWeight = ingredients.map { $0.computedWeight.value }.reduce(0, +)
        servingUnits = [
            PassioServingUnit(unitName: UnitsTexts.cGrams, weight: Measurement<UnitMass>(value: 1, unit: .grams)),
            PassioServingUnit(unitName: PassioFoodAmount.SERVING_UNIT_NAME,
                              weight: Measurement<UnitMass>(value: totalWeight != 0 ? totalWeight : 1,
                                                            unit: .grams))
        ]
        _ = setSelectedUnitKeepWeight(unitName: PassioFoodAmount.SERVING_UNIT_NAME)
        servingSizes = [PassioServingSize(quantity: selectedQuantity, unitName: selectedUnit)]
    }

    mutating func calculateQuantityForIngredients() {

        let totalWeight = ingredients.map { $0.computedWeight.value }.reduce(0, +)
        let ratioMultiply = computedWeight.value/totalWeight

        var newIngredient = [FoodRecordIngredient]()

        ingredients.forEach {
            var tempFood = $0
            _ = tempFood.setFoodIngredientServing(unit: tempFood.selectedUnit,
                                                  quantity: tempFood.selectedQuantity * ratioMultiply)
            newIngredient.append(tempFood)
        }

        ingredients = newIngredient
    }

    // MARK: Helper for qty, unit, servingsize & servingUnit
    private mutating func calculateQuantity() {
        let totalWeight = ingredients.map { $0.computedWeight.value }.reduce(0, +)
        if let servingSizeUnit = servingUnits.filter({ $0.unitName == selectedUnit }).first {
            selectedQuantity = totalWeight/servingSizeUnit.weight.value
        }
    }

    mutating func setSelectedQuantity(quantity: Double) {
        if selectedQuantity == quantity {
            return
        }
        selectedQuantity = (quantity != 0.0) ? quantity : 1
        calculateQuantityForIngredients()
    }

    mutating func setSelectedUnit(unit: String) -> Bool {

        let cGramsUnit = UnitsTexts.cGrams
        let gramsUnit = UnitsTexts.grams
        let gramUnit = UnitsTexts.gram

        let unit = if unit == UnitsTexts.cGrams ||
        unit == gramUnit ||
        unit == gramsUnit {
            cGramsUnit
        } else {
            unit
        }

        if selectedUnit == unit {
            return true
        }
        if let index = servingUnits.firstIndex(where: {
            $0.unitName == cGramsUnit ||
            $0.unitName == gramUnit ||
            $0.unitName == gramsUnit
        }) {
            servingUnits[index] = PassioServingUnit(unitName: cGramsUnit,
                                                    weight: servingUnits[index].weight)
        }
        if servingUnits.first(where: { $0.unitName == unit }) == nil {
            return false
        }
        selectedUnit = unit
        selectedQuantity = unit == cGramsUnit ? 100 : 1
        calculateQuantityForIngredients()
        return true
    }

    mutating func setSelectedUnitKeepWeight(unitName: String) -> Bool {

        if selectedUnit == unitName {
            return true
        }
        guard let servingWeight = servingUnits.first(where: { $0.unitName == unitName })?.weight else {
            return false
        }
        selectedUnit = unitName
        selectedQuantity = ingredients.count == 0 ? 1 : ingredientWeight().value / servingWeight.value
        return true
    }

    mutating public func setFoodRecordServing(unit: String, quantity: Double) -> Bool {

        guard (servingUnits.filter { $0.unitName == unit }).first?.weight != nil else {
            return false
        }
        selectedUnit = unit
        selectedQuantity = quantity != 0 ? quantity : 1
        calculateQuantityForIngredients()
        return true
    }

    mutating public func addScannedAmount(scannedWeight: Double) {

        guard scannedWeight > 1, scannedWeight < 50000 else { return }
        let scannedServingUnit = PassioServingUnit(unitName: scannedUnitName,
                                                   weight: Measurement<UnitMass>(value: scannedWeight,
                                                                                 unit: .grams))
        let scannedServingSize = PassioServingSize(quantity: 1, unitName: scannedUnitName)
        servingUnits.insert(scannedServingUnit, at: 0)
        servingSizes.insert(scannedServingSize, at: 0)
        _ = setFoodRecordServing(unit: scannedUnitName, quantity: 1)
    }

    func ingredientWeight() -> Measurement<UnitMass> {
        return ingredients.map {
            $0.computedWeight
        }.reduce(Measurement<UnitMass>(value: 0.0, unit: .grams)) { $0 + $1 }
    }

    // MARK: Get PassioNutrients
    public func getNutrients() -> PassioNutrients {
        let currentWeight = ingredientWeight()
        let ingredientNutrients = ingredients.map { (ingredient) in
            (ingredient.nutrients, ingredient.computedWeight.value / currentWeight.value)
        }
        return PassioNutrients(ingredientsData: ingredientNutrients, weight: currentWeight)
    }

    var getNutritionFacts: PassioNutritionFacts {

        let nutritionFacts = PassioNutritionFacts()

        nutritionFacts.servingSizeQuantity = selectedQuantity
        nutritionFacts.servingSizeUnitName = selectedUnit
        nutritionFacts.servingSizeGram = computedWeight.value
        nutritionFacts.calories = totalCalories
        nutritionFacts.carbs = totalCarbs
        nutritionFacts.protein = totalProteins
        nutritionFacts.fat = totalFat

        let nutrients = getNutrients()
        nutritionFacts.saturatedFat = nutrients.satFat()?.value
        nutritionFacts.transFat = nutrients.transFat()?.value
        nutritionFacts.cholesterol = nutrients.cholesterol()?.value
        nutritionFacts.sodium = nutrients.sodium()?.value
        nutritionFacts.dietaryFiber = nutrients.fibers()?.value
        nutritionFacts.totalSugars = nutrients.sugars()?.value
        nutritionFacts.addedSugar = nutrients.sugarsAdded()?.value
        nutritionFacts.vitaminD = nutrients.vitaminD()?.value
        nutritionFacts.calcium = nutrients.calcium()?.value
        nutritionFacts.iron = nutrients.iron()?.value
        nutritionFacts.potassium = nutrients.potassium()?.value

        return nutritionFacts
    }
}

// MARK: - Helper
extension FoodRecordV3 {

    var getServingInfo: String {

        let quantity = selectedQuantity
        let title = selectedUnit.capitalizingFirst()
        let weight = String(Int(computedWeight.value))
        let textAmount = quantity == Double(Int(quantity)) ? String(Int(quantity)) :
        String(quantity.roundDigits(afterDecimal: 1))
        let weightText = title == UnitsTexts.g ? "" : "(" + weight + " " + UnitsTexts.g + ") "
        return textAmount + " " + title + " " + weightText
    }

    var getCalories: String {
        var calStr = "0"
        let cal = totalCalories
        if 0 < cal, cal < 1e6 {
            calStr = String(cal.roundDigits(afterDecimal: 2))
        }
        return calStr + " " + UnitsTexts.cal
    }

    var getCarbs: String {
        "\(totalCarbs.roundDigits(afterDecimal: 2))"
    }

    var getProtein: String {
        "\(totalProteins.roundDigits(afterDecimal: 2))"
    }

    var getFat: String {
        "\(totalFat.roundDigits(afterDecimal: 2))"
    }

    var getNutritionSummary: (cal: String,
                              carbs: String,
                              pro: String,
                              fat: String) {
        (cal: getCalories, carbs: getCarbs, pro: getProtein, fat: getFat)
    }

    public var getJSONDict: [String: Any] {
        if let data = getJSONData,
           let dic = try? JSONSerialization.jsonObject(with: data, options: []),
           let finlaDic = dic as? [String: Any] {
            return finlaDic
        } else {
            return [:]
        }
    }

    var getJSONData: Data? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return jsonData
        } else {
            return nil
        }
    }
}
