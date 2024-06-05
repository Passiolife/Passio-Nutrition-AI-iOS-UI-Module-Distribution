//
//  QuickAddService.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 04/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

struct SuggestedFoods {

    let name: String
    let iconId: String
    var foodRecord: FoodRecordV3?
    var searchResult: PassioFoodDataInfo?

    init(foodRecord: FoodRecordV3) {
        name = foodRecord.name
        iconId = foodRecord.iconId
        self.foodRecord = foodRecord
    }

    init(searchResult: PassioFoodDataInfo) {
        name = searchResult.foodName
        iconId = searchResult.iconID
        self.searchResult = searchResult
    }

    func getFoodRecords(completion: @escaping (FoodRecordV3?) -> Void) {
        if var foodRecord {
            foodRecord.createdAt = Date()
            completion(foodRecord)
        } else {
            guard let searchResult else {
                completion(nil)
                return
            }
            PassioNutritionAI.shared.fetchFoodItemFor(foodItem: searchResult) { (foodItem) in
                guard let foodItem else {
                    completion(nil)
                    return
                }
                completion(FoodRecordV3(foodItem: foodItem))
            }
        }
    }
}
