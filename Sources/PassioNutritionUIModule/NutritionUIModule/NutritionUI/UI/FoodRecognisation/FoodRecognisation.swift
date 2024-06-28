//
//  FoodRecognisation.swift
//  BaseApp
//
//  Created by Mind on 23/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol FoodRecognitionDataSet: Equatable { }

class FoodRecognitionDataSetConnector {

    var id: String? { return nil }
    var foodItem: PassioFoodItem?
    var foodRecord: FoodRecordV3?

    func getFoodItem(completion: @escaping (PassioFoodItem?) -> Void) {
        if foodItem != nil {
            completion(foodItem)
            return
        }
        guard let _id = id else {
            completion(nil)
            return
        }
        PassioNutritionAI.shared.fetchFoodItemFor(productCode: _id) { [weak self] (passioFoodItem) in
            DispatchQueue.main.async {
                if let foodItem = passioFoodItem {
                    self?.foodItem = foodItem
                    completion(foodItem)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func getRecordV3(completion: @escaping (FoodRecordV3?) -> Void) {
        if let foodRecord {
            completion(foodRecord)
            return
        }
        getFoodItem { foodItem in
            DispatchQueue.main.async { [self] in
                guard let item = foodItem else {
                    completion(nil)
                    return
                }
                foodRecord = FoodRecordV3.init(foodItem: item)
                completion(foodRecord)
            }
        }
    }
}

class NutritionFactsDataSet: FoodRecognitionDataSet {

    var nutritionFacts: PassioNutritionFacts?
    var updatedNutritionFacts: PassioNutritionFacts?

    init(nutritionFacts: PassioNutritionFacts) {
        self.nutritionFacts = nutritionFacts
        self.updatedNutritionFacts = nutritionFacts
    }

    static func == (lhs: NutritionFactsDataSet, rhs: NutritionFactsDataSet) -> Bool {
        return (lhs.nutritionFacts?.calories == rhs.nutritionFacts?.calories) &&
        (lhs.nutritionFacts?.fat == rhs.nutritionFacts?.fat)
    }
}

class BarcodeDataSet: FoodRecognitionDataSetConnector, FoodRecognitionDataSet {

    override var id: String? { return candidate?.value }

    var candidate: BarcodeCandidate?

    init(candidate: BarcodeCandidate? = nil) {
        self.candidate = candidate
    }

    convenience init(candidate: BarcodeCandidate? = nil, foodRecord: FoodRecordV3) {
        self.init(candidate: candidate)
        self.foodRecord = foodRecord
    }

    static func == (lhs: BarcodeDataSet, rhs: BarcodeDataSet) -> Bool {
        return lhs.candidate?.value == rhs.candidate?.value
    }

    override func getFoodItem(completion: @escaping (PassioFoodItem?) -> Void) {

        fetchBarcodeFoodFromLocal { isUserFoodBarcode in

            if isUserFoodBarcode {
                completion(nil)
            } else {
                super.getFoodItem { foodItem in
                    if let foodItem {
                        completion(foodItem)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    func fetchBarcodeFoodFromLocal(completion: @escaping (Bool) -> Void) {
        guard let id else {
            completion(false)
            return
        }
        PassioInternalConnector.shared.fetchUserFoods(barcode: id) { [weak self] barcodeFood in
            guard let self, let barcodeFoodRecord = barcodeFood.first else {
                completion(false)
                return
            }
            foodRecord = barcodeFoodRecord
            completion(true)
        }
    }
}

class PackageFoodDataSet: FoodRecognitionDataSetConnector, FoodRecognitionDataSet {

    var candidate: PackagedFoodCandidate?
    override var id: String? {return candidate?.packagedFoodCode}

    init(candidate: PackagedFoodCandidate? = nil) {
        self.candidate = candidate
    }

    static func == (lhs: PackageFoodDataSet, rhs: PackageFoodDataSet) -> Bool {
        return lhs.candidate?.packagedFoodCode == rhs.candidate?.packagedFoodCode
    }
}

class VisualFoodDataSet: FoodRecognitionDataSetConnector, FoodRecognitionDataSet {
    var candidate: DetectedCandidate?
    var allAlternatives: [DetectedCandidate] = []

    override var id: String? {return candidate?.passioID}

    init(candidate: DetectedCandidate? = nil, topKResults: [DetectedCandidate] = [] ) {
        super.init()
        self.candidate = candidate
        self.allAlternatives = ((candidate?.alternatives ?? []) + topKResults).uniqued(on: {$0.passioID}).filter({$0.passioID != self.id})
        
//        if let mapping = PassioNutritionAI.shared.lookupPersonalizedAlternativeFor(passioID: candidate?.passioID ?? "NAN"){
//            if allAlternatives.contains(where: {mapping.nutritionalPassioID == $0.passioID}){
//                guard let toBeSwitchCandidate = allAlternatives.first(where: {mapping.nutritionalPassioID == $0.passioID}) else { return }
//                if candidate != nil {
//                    allAlternatives.insert(candidate!, at: 0)
//                }
//                self.candidate = toBeSwitchCandidate
//                allAlternatives.removeAll(where: {mapping.nutritionalPassioID == $0.passioID})
//            }
//        }
        
    }

    static func == (lhs: VisualFoodDataSet, rhs: VisualFoodDataSet) -> Bool {
        return lhs.candidate?.passioID == rhs.candidate?.passioID
    }

    override func getFoodItem(completion: @escaping (PassioFoodItem?) -> Void) {
        if foodItem != nil{
            completion(foodItem)
            return
        }
        guard let _id = id else {
            completion(nil)
            return
        }
        PassioNutritionAI.shared.fetchFoodItemFor(passioID: _id) { [weak self] (passioFoodItem) in

            DispatchQueue.main.async{
                if let foodItem = passioFoodItem {
                    self?.foodItem = foodItem
                    completion(foodItem)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
