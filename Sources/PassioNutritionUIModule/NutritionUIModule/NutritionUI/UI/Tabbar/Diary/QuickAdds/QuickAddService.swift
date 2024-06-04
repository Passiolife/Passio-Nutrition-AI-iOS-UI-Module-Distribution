//
//  QuickAddService.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 04/04/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import Foundation
import PassioNutritionAISDK

final class QuickAddService {

    func getQuickAdds(mealTime: PassioMealTime, completion: @escaping ([SuggestedFoods]) -> Void)  {

        // Fetch Foodrecords for last 30 days
        let toDate = Date()
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: toDate) ?? Date()
        let maxSuggestedCount = 30

        PassioInternalConnector.shared.fetchDayLogRecursive(fromDate: fromDate,
                                                            toDate: toDate) { [weak self] (dayLogs) in

            let filterFoodRecords = dayLogs.map { $0.records }.flatMap { $0 }.filter { $0.mealLabel.mealTime == mealTime }
            let todayRecords = filterFoodRecords.filter { $0.createdAt.isToday }.map { $0.name.lowercased() }
            let finalFoodRecords = filterFoodRecords.filter { !todayRecords.contains($0.name.lowercased()) }

            guard let self = self,
                  finalFoodRecords.count > 0 else {
                self?.fetchSDKSuggestions(mealTime: mealTime,
                                          todayRecords: todayRecords,
                                          userSuggestedFoods: [SuggestedFoods](),
                                          completion: { (sdkSuggestedFoods) in
                    completion(sdkSuggestedFoods)
                })
                return
            }

            let lowerCasedFoodRecords = finalFoodRecords.map { foodRecord in
                var record = foodRecord
                record.name = foodRecord.name.lowercased()
                return record
            }

            // Dictionary to hold occurrences of properties
            let foodNamesCount: [String: Int] = lowerCasedFoodRecords.reduce(into: [:]) { counts, foodRecord in
                counts[foodRecord.name, default: 0] += 1
            }

            // Sort the items based on the occurrence of the foodrecord's name and also remove duplicated foodrecord
            let sortedFoodRecords = lowerCasedFoodRecords.uniqued(on: \.name).sorted { foodRecord1, foodRecord2 in
                return (foodNamesCount[foodRecord1.name] ?? 0) > (foodNamesCount[foodRecord2.name] ?? 0)
            }

            // Convert sortedFoodRecords to SuggestedFoods
            let userSuggestedFoods = sortedFoodRecords.map { SuggestedFoods(foodRecord: $0) }

            // Show only first 30
            if userSuggestedFoods.count > maxSuggestedCount {
                // Show first 30 userSuggestedFoods
                let maxuserSuggestedFoods = userSuggestedFoods.count > maxSuggestedCount
                ? Array(userSuggestedFoods.prefix(maxSuggestedCount)) : userSuggestedFoods
                completion(maxuserSuggestedFoods)

            } else {
                self.fetchSDKSuggestions(mealTime: mealTime,
                                         todayRecords: todayRecords,
                                    userSuggestedFoods: userSuggestedFoods,
                                    completion: { (sdkSuggestedFoods) in
                    completion(sdkSuggestedFoods)
                })
            }
        }
    }

    private func fetchSDKSuggestions(mealTime: PassioMealTime,
                                     todayRecords: [String],
                                     userSuggestedFoods: [SuggestedFoods],
                                     completion: @escaping ([SuggestedFoods]) -> Void) {
        // Fetch SDK suggestions and add them into userSuggestedFoods
        PassioNutritionAI.shared.fetchSuggestions(mealTime: mealTime) { sdkSuggestionsResult in

            guard sdkSuggestionsResult.count > 0 else {
                completion(userSuggestedFoods)
                return
            }
            let sdkSuggestedFoods = sdkSuggestionsResult.map { SuggestedFoods(searchResult: $0) }
            let finalSdkSuggestedFoods = Array((userSuggestedFoods + sdkSuggestedFoods).uniqued(on: \.name).prefix(30))
            let finalFoodRecords = finalSdkSuggestedFoods.filter { !todayRecords.contains($0.name.lowercased()) }
            completion(finalFoodRecords)
        }
    }
}
