//
//  File.swift
//  
//
//  Created by Pratik on 10/10/24.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public protocol PassioConnector: AnyObject {
    
    // UserProfile
    func updateUserProfile(userProfile: UserProfileModel)
    func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void)
    
    // Records
    func updateRecord(foodRecord: FoodRecordV3)
    func deleteRecord(foodRecord: FoodRecordV3)
    func fetchDayRecords(date: Date, completion: @escaping ([FoodRecordV3]) -> Void)
    func fetchMealLogsJson(daysBack: Int) -> String
    
    // User Foods
    func updateUserFood(record: FoodRecordV3)
    func deleteUserFood(record: FoodRecordV3)
    func fetchUserFoods(barcode: String, completion: @escaping ([FoodRecordV3]) -> Void)
    func fetchUserFoods(refCode: String, completion: @escaping ([FoodRecordV3]) -> Void)
    func fetchAllUserFoods(completion: @escaping ([FoodRecordV3]) -> Void)
    func fetchAllUserFoodsMatching(name: String, completion: @escaping ([FoodRecordV3]) -> Void) // Newly added
    func deleteAllUserFood()
    
    // User Food Image
    func updateUserFoodImage(with id: String, image: UIImage)
    func deleteUserFoodImage(with id: String)
    func fetchUserFoodImage(with id: String, completion: @escaping (UIImage?) -> Void)
    
    // Favorites
    func updateFavorite(foodRecord: FoodRecordV3)
    func deleteFavorite(foodRecord: FoodRecordV3)
    func fetchFavorites(completion: @escaping ([FoodRecordV3]) -> Void)
    
    // Recipes
    func updateRecipe(record: FoodRecordV3)
    func deleteRecipe(record: FoodRecordV3)
    func fetchRecipes(completion: @escaping ([FoodRecordV3]) -> Void)
    
    // Day logs - Newly added
    func fetchDayLogFor(fromDate: Date, toDate: Date, completion: @escaping ([DayLog]) -> Void)
    func fetchDayLogRecursive(fromDate: Date, toDate: Date, currentLogs: [DayLog], completion: @escaping ([DayLog]) -> Void)
    
    // WeightTracking Records
    func updateWeightRecord(weightRecord: WeightTracking, completion: @escaping (Bool) -> Void)
    func fetchWeightRecords(startDate: Date, endDate: Date, completion: @escaping ([WeightTracking]) -> Void)
    func fetchLatestWeightRecord(completion: @escaping (WeightTracking?) -> Void)
    func deleteWeightRecord(weightRecord: WeightTracking, completion: @escaping (Bool) -> Void) 
}


