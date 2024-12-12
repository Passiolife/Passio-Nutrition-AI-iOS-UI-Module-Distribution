//
//  CoreDataPassioConnector.swift

import Foundation
import UIKit
import CoreData
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public class CoreDataPassioConnector {
    
    // MARK: Shared Object
    public class var shared: CoreDataPassioConnector {
        if Static.instance == nil {
            Static.instance = CoreDataPassioConnector()
        }
        return Static.instance!
    }
    
    private init() {}
    
    private struct Static {
        fileprivate static var instance: CoreDataPassioConnector?
    }
}

extension CoreDataPassioConnector: PassioConnector {
    
    public func fetchAllUserFoodsMatching(name: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        FoodRecordOperations.shared.fetchFoodRecords(whereClause: name) { foodRecords, error in
            if error == nil {
                completion(foodRecords)
            }
            else {
                print("Failed to fetch FoodLog records data with given Name: [\(name)].")
            }
        }
    }
    
    public func fetchDayLogFor(fromDate: Date, toDate: Date, completion: @escaping ([DayLog]) -> Void) {
        var dayLogs: [DayLog] = []
        
        for time in stride(from: fromDate.timeIntervalSince1970,
                           through: toDate.timeIntervalSince1970,
                           by: 86400) {
            let currentDate = Date(timeIntervalSince1970: time)
            
            FoodRecordOperations.shared.fetchFoodRecords(whereClause: currentDate) { foodRecords, error in
                if error == nil {
                    let daylog = DayLog(date: currentDate, records: foodRecords)
                    dayLogs.append(daylog)
                    if time > toDate.timeIntervalSince1970 - 86400 { // last element
                        completion(dayLogs)
                    }
                }
                else {
                    print("Failed to fetch FoodLog records data within date range.")
                }
            }
        }
        
        if dayLogs.count == 0 {
            completion([])
        }
    }
    
    //MARK: - User Profile Section
    public func updateUserProfile(userProfile: UserProfileModel) {
        UserProfileOperation.shared.insertOrUpdateUserProfile(userProfile: userProfile) { (resultStatus, resultError) in
            if let error = resultError {
                print("Failed to save User Profile record: \(error)")
            }
        }
    }
    
    public func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void) {
        UserProfileOperation.shared.fetchUserProfile { userProfileModel, error in
            if error != nil {
                print("Failed delete FoodLog record :: \(error)")
            }
            completion(userProfileModel)
        }
    }
    
    
    //MARK: - Foods for Logs Section
    public func updateRecord(foodRecord: FoodRecordV3) {
        
        FoodRecordOperations.shared.insertOrUpdateFoodRecord(foodRecord: foodRecord) { (resultStatus, resultError) in
            if let error = resultError {
                print("Failed to save FoodLog record: \(error)")
            }
        }
    }
    
    public func deleteRecord(foodRecord: FoodRecordV3) {
        FoodRecordOperations.shared.deleteFoodRecords(whereClause: foodRecord.uuid) { bResult, error in
            if error != nil {
                print("Failed delete FoodLog record :: \(error)")
            }
        }
    }
    
    public func fetchDayRecords(date: Date, completion: @escaping ([FoodRecordV3]) -> Void) {
        FoodRecordOperations.shared.fetchFoodRecords(whereClause: date) { foodRecords, error in
            if error != nil {
                print("Failed to fetch FoodLog records :: \(error)")
                completion([])
            }
            else {
                completion(foodRecords)
            }
        }
    }
    
    //MARK: - Userfood Section
    public func updateUserFood(record: FoodRecordV3) {
        CustomFoodRecordOperations.shared.insertOrUpdateFoodRecord(foodRecord: record) { (resultStatus, resultError) in
            if let error = resultError {
                print("Failed to save CustomFood record :: \(error)")
            }
        }
    }
    
    public func deleteUserFood(record: FoodRecordV3) {
        CustomFoodRecordOperations.shared.deleteCustomFoodRecords(whereClauseUUID: record.uuid) { bResult, error in
            if error != nil {
                print("Failed to delete CustomFood record :: \(error)")
            }
        }
    }
    
    public func fetchUserFoods(barcode: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        CustomFoodRecordOperations.shared.fetchCustomFoodRecords(whereClauseBarcode: barcode) { foodRecords, error in
            if error != nil {
                print("Failed to fetch CustomFood records :: \(error)")
                completion([])
            }
            else {
                completion(foodRecords)
            }
        }
    }
    
    public func fetchUserFoods(refCode: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        CustomFoodRecordOperations.shared.fetchCustomFoodRecords(whereClauseRefCode: refCode) { foodRecords, error in
            if error != nil {
                print("Failed to fetch CustomFood records :: \(error)")
                completion([])
            }
            else {
                completion(foodRecords)
            }
        }
    }
    
    public func fetchAllUserFoods(completion: @escaping ([FoodRecordV3]) -> Void) {
        CustomFoodRecordOperations.shared.fetchCustomFoodRecords { foodRecords, error in
            if error != nil {
                print("failed to fetch CustomFood records :: \(error)")
                completion([])
            }
            else {
                completion(foodRecords)
            }
        }
    }
    
    public func updateUserFoodImage(with id: String, image: UIImage) {
        CustomFoodRecordOperations.shared.saveUserCreatedCustomFoodImage(id: id, image: image)
    }
    
    public func deleteUserFoodImage(with id: String) {
        CustomFoodRecordOperations.shared.deleteUserCreatedCustomFoodImage(id: id)
    }
    
    public func fetchUserFoodImage(with id: String, completion: @escaping (UIImage?) -> Void) {
        CustomFoodRecordOperations.shared.fetchUserCreatedCustomFoodImage(id: id, completion: completion)
    }
    
    //MARK: - Favourite Food Section
    public func updateFavorite(foodRecord: FoodRecordV3) {
        FavouriteFoodRecordOperations.shared.insertOrUpdateFavouriteFoodRecord(foodRecord: foodRecord) { (resultStatus, resultError) in
            if let error = resultError {
                print("Failed to save Favorite record :: \(error)")
            }
        }
    }
    
    public func deleteFavorite(foodRecord: FoodRecordV3) {
        FavouriteFoodRecordOperations.shared.deleteFavouriteFoodRecords(whereClauseRefCode: foodRecord.refCode) { bResult, error in
            if error != nil {
                print("Failed to delete CustomFood record :: \(error)")
            }
        }
    }
    
    public func fetchFavorites(completion: @escaping ([FoodRecordV3]) -> Void) {
        FavouriteFoodRecordOperations.shared.fetchFavouriteFoodRecords { foodRecords, error in
            if error != nil {
                print("failed to fetch CustomFood records :: \(error)")
                completion([])
            }
            else {
                completion(foodRecords)
            }
        }
    }
    
    //MARK: - Recipe Section
    public func updateRecipe(record: FoodRecordV3) {
        FoodRecipeRecordOperations.shared.insertOrUpdateFoodRecipeRecord(foodRecord: record) { (resultStatus, resultError) in
            if let error = resultError {
                print("Failed to save Favorite record :: \(error)")
            }
        }
    }
    
    public func deleteRecipe(record: FoodRecordV3) {
        FoodRecipeRecordOperations.shared.deleteFoodRecipeRecords(whereClauseRefCode: record.refCode) { bResult, error in
            if error != nil {
                print("Failed to delete CustomFood record :: \(error)")
            }
        }
    }
    
    public func fetchRecipes(completion: @escaping ([FoodRecordV3]) -> Void) {
        FoodRecipeRecordOperations.shared.fetchFoodRecipeRecords { foodRecords, error in
            if error != nil {
                print("failed to fetch CustomFood records :: \(error)")
                completion([])
            }
            else {
                completion(foodRecords)
            }
        }
    }

    // MARK: Weight Tracking
    public func updateWeightRecord(weightRecord: WeightTracking, completion: @escaping (Bool) -> Void) {
        BodyMetriTrackingOperation.shared.updateWeightRecord(weightRecord: weightRecord) { (resultStatus, resultError) in
            if let error = resultError {
                print("Failed to save Weight tracking record: \(error)")
            }
            completion(resultStatus)
        }
    }
    
    public func fetchWeightRecords(startDate: Date, endDate: Date, completion: @escaping ([WeightTracking]) -> Void) {
        BodyMetriTrackingOperation.shared.fetchWeightTracking(whereClause: startDate, endDate: endDate) { weightTrackingRecords, error in
            if error == nil {
                completion(weightTrackingRecords)
            }
            else {
                completion([])
            }
        }
    }
    
    public func fetchLatestWeightRecord(completion: @escaping (WeightTracking?) -> Void) {
        BodyMetriTrackingOperation.shared.fetchLatestWeightRecord { trackingRecord, error in
            if error != nil {
               print("Failed to fetch WeightTracking records :: \(error)")
            }
            else {
                if let trackingRecord = trackingRecord {
                    completion(trackingRecord)
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
    public func deleteWeightRecord(weightRecord: WeightTracking, completion: @escaping (Bool) -> Void) {
        BodyMetriTrackingOperation.shared.deleteWeightRecord(weightRecord: weightRecord) { bResult, error in
            if error != nil {
                print("Failed delete Weight Tracking record :: \(error)")
            }
            completion(bResult)
        }
    }
    
    // MARK: Water Tracking
    
    public func updateWaterRecord(waterRecord: WaterTracking, completion: @escaping ((Bool) -> Void)) {
        BodyMetriTrackingOperation.shared.updateWaterRecord(waterRecord: waterRecord) { (resultStatus, resultError) in
            if let error = resultError {
                print("Failed to save water tracking record: \(error)")
            }
            completion(resultStatus)
        }
    }
    
    public func fetchWaterRecords(startDate: Date, endDate: Date, completion: @escaping ([WaterTracking]) -> Void) {
        BodyMetriTrackingOperation.shared.fetchWaterTracking(whereClause: startDate, endDate: endDate) { waterTrackingRecords, error in
            if error == nil {
                completion(waterTrackingRecords)
            }
            else {
                completion([])
            }
        }
    }
    
    public func deleteWaterRecord(waterRecord: WaterTracking, completion: @escaping (Bool) -> Void) {
        BodyMetriTrackingOperation.shared.deleteWaterRecord(waterRecord: waterRecord) { bResult, error in
            if error != nil {
                print("Failed delete Water Tracking record :: \(error)")
            }
            completion(bResult)
        }
    }
}
