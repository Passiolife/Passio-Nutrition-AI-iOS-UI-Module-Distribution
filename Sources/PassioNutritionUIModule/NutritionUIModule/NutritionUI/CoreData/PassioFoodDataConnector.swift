//
//  PassioFoodDataConnector.swift

import Foundation
import UIKit
import CoreData
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public class PassioFoodDataConnector {
    
    // MARK: Shared Object
    public class var shared: PassioFoodDataConnector {
        if Static.instance == nil {
            Static.instance = PassioFoodDataConnector()
        }
        return Static.instance!
    }
    
    private init() {}
    
    private struct Static {
        fileprivate static var instance: PassioFoodDataConnector?
    }
}

extension PassioFoodDataConnector: PassioConnector {
    
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
    
    public func fetchDayLogRecursive(fromDate: Date, toDate: Date, currentLogs: [DayLog] = [], completion: @escaping ([DayLog]) -> Void) {
        
        guard fromDate <= toDate else {
            completion(currentLogs)
            return
        }
        
        fetchDayRecords(date: fromDate) { (foodRecords) in
            let daylog = DayLog(date: fromDate, records: foodRecords)
            var updatedLogs = currentLogs
            updatedLogs.append(daylog)
            
            // Recursive call with next day
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!
            self.fetchDayLogRecursive(fromDate: nextDate,
                                      toDate: toDate,
                                      currentLogs: updatedLogs,
                                      completion: completion)
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
    
    public func fetchMealLogsJson(daysBack: Int) -> String {
        
        let toDate = Date()
        let fromDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: toDate) ?? Date()

        var dayLogs = [DayLog]()
        fetchDayLogRecursive(fromDate: fromDate, toDate: toDate) { dayLog in
            dayLogs.append(contentsOf: dayLog)
        }
        let json = dayLogs.generateDataRequestJson()
        return json
        
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
    
    public func deleteAllUserFood() {
        CustomFoodRecordOperations.shared.deleteAllCustomFoodRecords { bResult, error in
            if error != nil {
                print("Failed to delete CustomFood record :: \(error)")
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

    public func insertOrReplaceWeightTrackingRecord(weightTracking: WeightTracking) {
        BodyMetriTrackingOperation.shared.insertOrUpdateWeightTracking(weightTracking: weightTracking) { (resultStatus, resultError) in
            if let error = resultError {
                print("Failed to save Weight tracking record: \(error)")
            }
        }
    }
    
    public func fetchWeightTrackingRecursive(fromDate: Date, toDate: Date, currentLogs: [WeightTracking], completion: @escaping ([WeightTracking]) -> Void) {
        guard fromDate <= toDate else {
            completion(currentLogs)
            return
        }
        
        fetchWeightTrackingRecord(date: fromDate) { (weightTrackingRecords) in
            var updatedLogs = currentLogs
            updatedLogs.append(contentsOf: weightTrackingRecords)
            
            // Recursive call with next day
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!
            self.fetchWeightTrackingRecursive(fromDate: nextDate,
                                      toDate: toDate,
                                      currentLogs: updatedLogs,
                                      completion: completion)
        }
    }
    
    public func fetchWeightTrackingRecord(date: Date, completion: @escaping ([WeightTracking]) -> Void) {
        BodyMetriTrackingOperation.shared.fetchWeightTracking(whereClause: date) { trackingRecords, error in
            if error != nil {
                print("Failed to fetch WeightTracking records :: \(error)")
                completion([])
            }
            else {
                completion(trackingRecords)
            }
        }
    }
    
    public func fetchWeightTrackingRecord(record: WeightTracking, completion: @escaping (WeightTracking?) -> Void) {
        BodyMetriTrackingOperation.shared.fetchFoodRecords(whereClause: record) { trackingRecord, error in
            if error != nil {
                print("Failed to fetch WeightTracking records :: \(error)")
                completion(nil)
            }
            else {
                completion(trackingRecord)
            }
        }
    }
    
    public func deleteWeightTrackingRecord(record: WeightTracking) {
        BodyMetriTrackingOperation.shared.deleteWeightTrackingRecords(whereClause: record) { bResult, error in
            if error != nil {
                print("Failed delete Weight Tracking record :: \(error)")
            }
        }
    }
}
