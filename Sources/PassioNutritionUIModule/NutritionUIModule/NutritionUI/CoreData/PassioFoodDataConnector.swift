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
                    print("Something went wrong while fetching data within date range.")
                }
            }
        }
        
        if dayLogs.count == 0 {
            completion([])
        }
    }
    
    public func fetchDayLogRecursive(fromDate: Date, toDate: Date, currentLogs: [DayLog], completion: @escaping ([DayLog]) -> Void) {
        
    }
    
    
    public func updateUserProfile(userProfile: UserProfileModel) {}
    
    public func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void) {}
    
    public func updateRecord(foodRecord: FoodRecordV3) {
        
        FoodRecordOperations.shared.insertFoodRecord(foodRecord: foodRecord) { (resultStatus, resultError) in
            if resultError == nil {
                print("Record saved Successfully")
            }
            else {
                if let error = resultError {
                    print("Failed to save record: \(error)")
                }
            }
        }
    }
    
    public func deleteRecord(foodRecord: FoodRecordV3) {
        FoodRecordOperations.shared.deleteFoodRecords(whereClause: foodRecord.uuid) { bResult, error in
            if error != nil {
                print("Error while delete the record: \(error)")
            }
            else {
                print("Record is deleted successfully")
            }
        }
    }
    
    public func fetchDayRecords(date: Date, completion: @escaping ([FoodRecordV3]) -> Void) {
        FoodRecordOperations.shared.fetchFoodRecords(whereClause: date) { foodRecords, error in
            if error != nil {
                print("Error while fetch the records.. \(error)")
                completion([])
            }
            else {
                completion(foodRecords)
            }
        }
    }
    
    public func fetchMealLogsJson(daysBack: Int) -> String {
        return ""
    }
    
    public func updateUserFood(record: FoodRecordV3) {}
    
    public func deleteUserFood(record: FoodRecordV3) {}
    
    public func fetchUserFoods(barcode: String, completion: @escaping ([FoodRecordV3]) -> Void) {}
    
    public func fetchUserFoods(refCode: String, completion: @escaping ([FoodRecordV3]) -> Void) {}
    
    public func fetchAllUserFoods(completion: @escaping ([FoodRecordV3]) -> Void) {}
    
    public func deleteAllUserFood() {}
    
    public func updateUserFoodImage(with id: String, image: UIImage) {}
    
    public func deleteUserFoodImage(with id: String) {}
    
    public func fetchUserFoodImage(with id: String, completion: @escaping (UIImage?) -> Void) {}
    
    public func updateFavorite(foodRecord: FoodRecordV3) {}
    
    public func deleteFavorite(foodRecord: FoodRecordV3) {}
    
    public func fetchFavorites(completion: @escaping ([FoodRecordV3]) -> Void) {}
    
    public func updateRecipe(record: FoodRecordV3) {}
    
    public func deleteRecipe(record: FoodRecordV3) {}
    
    public func fetchRecipes(completion: @escaping ([FoodRecordV3]) -> Void) {
        
    }
    
    public var passioKeyForSDK: String {
        ""
    }
    
    public var offsetFoodEditor: CGFloat {
        0
    }
    
    
}
