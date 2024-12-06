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

final class QuickAddService {

    func getQuickAdds(mealTime: PassioMealTime,
                      completion: @escaping ([SuggestedFoods]) -> Void) {

        // Fetch Foodrecords for last 30 days
        let toDate = Date()
        guard let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: toDate) else {
            completion([])
            return
        }
        let maxSuggestedCount = 30

        NutritionUIModule.shared.fetchDayLogFor(fromDate: fromDate, 
                                                toDate: toDate) { [weak self] dayLogs in
            guard let self = self else { return }

            // Filter food records by mealTime
            let filterFoodRecords = dayLogs.flatMap { $0.records }.filter { $0.mealLabel.mealTime == mealTime }

            // Today's records, lowering their names for consistency
            let todayRecords = filterFoodRecords.filter { $0.createdAt.isToday }.map { $0.name.lowercased() }

            // Filter out today's records from the finalFoodRecords
            let finalFoodRecords = filterFoodRecords.filter { !todayRecords.contains($0.name.lowercased()) }

            guard !finalFoodRecords.isEmpty else {
                // Fetch suggestions from SDK if no records found
                self.fetchSDKSuggestions(mealTime: mealTime,
                                         todayRecords: todayRecords,
                                         userSuggestedFoods: [],
                                         completion: completion)
                return
            }

            // Convert food record names to lowercase and count occurrences
            let lowerCasedFoodRecords = finalFoodRecords.map { record in
                var recordCopy = record
                recordCopy.name = record.name.lowercased()
                return recordCopy
            }

            let foodNamesCount = lowerCasedFoodRecords.reduce(into: [String: Int]()) { counts, record in
                counts[record.name, default: 0] += 1
            }

            // Sort and remove duplicates, keeping the most frequent items first
            let sortedFoodRecords = lowerCasedFoodRecords
                .uniqued(on: \.name)
                .sorted { foodNamesCount[$0.name] ?? 0 > foodNamesCount[$1.name] ?? 0 }

            let userSuggestedFoods = sortedFoodRecords.map { SuggestedFoods(foodRecord: $0) }

            // Show the top 30 suggestions, if available
            let finalSuggestedFoods = Array(userSuggestedFoods.prefix(maxSuggestedCount))

            if finalSuggestedFoods.count < maxSuggestedCount {
                // Fetch additional suggestions from SDK if user suggestions are fewer than 30
                self.fetchSDKSuggestions(mealTime: mealTime, todayRecords: todayRecords, userSuggestedFoods: finalSuggestedFoods, completion: completion)
            } else {
                completion(finalSuggestedFoods)
            }
        }
    }

    private func fetchSDKSuggestions(
        mealTime: PassioMealTime,
        todayRecords: [String],
        userSuggestedFoods: [SuggestedFoods],
        completion: @escaping ([SuggestedFoods]) -> Void
    ) {
        // Fetch SDK suggestions and add them into userSuggestedFoods
        PassioNutritionAI.shared.fetchSuggestions(mealTime: mealTime) { sdkSuggestionsResult in
            // If no SDK suggestions, return userSuggestedFoods immediately
            guard !sdkSuggestionsResult.isEmpty else {
                completion(userSuggestedFoods)
                return
            }

            // Map SDK results to SuggestedFoods
            let sdkSuggestedFoods = sdkSuggestionsResult.map { SuggestedFoods(searchResult: $0) }

            // Combine SDK suggestions with user suggestions and ensure uniqueness by food name
            let combinedSuggestedFoods = (userSuggestedFoods + sdkSuggestedFoods)
                .uniqued(on: \.name)
                .filter { !todayRecords.contains($0.name.lowercased()) } // Exclude today's records

            // Limit the results to 30 suggestions
            let finalSuggestions = Array(combinedSuggestedFoods.prefix(30))

            // Pass the final suggestions to the completion handler
            completion(finalSuggestions)
        }
    }
}
