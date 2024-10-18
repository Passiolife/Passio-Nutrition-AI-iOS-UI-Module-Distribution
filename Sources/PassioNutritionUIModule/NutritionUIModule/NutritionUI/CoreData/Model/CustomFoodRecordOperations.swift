//
//  CustomCustomFoodRecordOperations.swift
//
//
//  Created by Mindinventory on 16/10/24.
//

import Foundation
import UIKit
import CoreData

internal class CustomFoodRecordOperations {
    
    private init() {}
    
    private static var CustomFoodRecordOperations: CustomFoodRecordOperations = {
        let CustomFoodRecordOperations = CustomFoodRecordOperations()
        return CustomFoodRecordOperations
    }()
    
    static var shared: CustomFoodRecordOperations = {
        return CustomFoodRecordOperations
    }()
 
    private func getMainContext() -> NSManagedObjectContext {
        CoreDataManager.shared.mainManagedObjectContext
    }
    
    fileprivate let jsonConnector: PassioConnector = JSONPassioConnector.shared
    
    //MARK: - Insert Custom food record
    func insertFoodRecord(foodRecord: FoodRecordV3, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            var dbFoodRecordV3: TblCustomFoodRecord?
            
            do {
                
                dbFoodRecordV3 = TblCustomFoodRecord(context: context)
                guard let dbFoodRecordV3 = dbFoodRecordV3 else { return }
                
                dbFoodRecordV3.barcode = foodRecord.barcode
                dbFoodRecordV3.confidence = foodRecord.confidence ?? 0
                dbFoodRecordV3.createdAt = foodRecord.createdAt
                dbFoodRecordV3.details = foodRecord.details
                dbFoodRecordV3.entityType = foodRecord.entityType.rawValue
                dbFoodRecordV3.iconId = foodRecord.iconId
                dbFoodRecordV3.id = foodRecord.id
                dbFoodRecordV3.mealLabel = foodRecord.mealLabel.rawValue
                dbFoodRecordV3.name = foodRecord.name
                dbFoodRecordV3.nutrients = foodRecord.getNutrients().toJsonString()
                dbFoodRecordV3.openFoodLicense = foodRecord.openFoodLicense
                dbFoodRecordV3.passioID = foodRecord.passioID
                dbFoodRecordV3.radioSelected = foodRecord.radioSelected ?? false
                dbFoodRecordV3.scannedUnitName = foodRecord.scannedUnitName
                dbFoodRecordV3.selectedQuantity = foodRecord.selectedQuantity
                dbFoodRecordV3.selectedUnit = foodRecord.selectedUnit
                
                var strServingSizes = ""
                foodRecord.servingSizes.compactMap({$0}).forEach({ strServingSizes.append($0.toJsonString() ?? "") })
                dbFoodRecordV3.servingSizes = strServingSizes
                
                var strServingUnits = ""
                foodRecord.servingUnits.compactMap({$0}).forEach({ strServingUnits.append($0.toJsonString() ?? "") })
                dbFoodRecordV3.servingUnits = strServingUnits
                
                dbFoodRecordV3.uuid = foodRecord.uuid
                
                var foodIngredients: [TblCustomFoodRecordIngredient] = []
                
                foodRecord.ingredients.forEach { foodRecordIngredient in
                    let tblCustomFoodRecordIngredient = TblCustomFoodRecordIngredient(context: context)
                    
                    tblCustomFoodRecordIngredient.details = foodRecordIngredient.details
                    tblCustomFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                    tblCustomFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                    tblCustomFoodRecordIngredient.name = foodRecordIngredient.name
                    tblCustomFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                    tblCustomFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                    tblCustomFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                    tblCustomFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                    tblCustomFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                    tblCustomFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                    
                    var strIngredientServingSizes = ""
                    foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                    tblCustomFoodRecordIngredient.servingSizes = strIngredientServingSizes
                    
                    var strIngredientServingUnits = ""
                    foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                    tblCustomFoodRecordIngredient.servingUnits = strIngredientServingUnits
                    
                    foodIngredients.append(tblCustomFoodRecordIngredient)
                }
                
                dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                
                context.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                print("Failed to fetch match delete and save as new recored: \(error)")
                completion(false, error)
            }
        }
    }
    
    //MARK: - Insert OR Update Custom food record
    func insertOrUpdateFoodRecord(foodRecord: FoodRecordV3, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            // Create a fetch request for the Person entity
            let fetchRequest: NSFetchRequest<TblCustomFoodRecord> = TblCustomFoodRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", foodRecord.uuid)
            
            var dbFoodRecordV3: TblCustomFoodRecord?
            
            do {
                
                // Fetch existing records
                let results = try context.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    dbFoodRecordV3 = firstRecord
                    print("Existing Record found to update")
                }
                else {
                    dbFoodRecordV3 = TblCustomFoodRecord(context: context)
                    print("New Record is created for storage")
                }
                
                guard let dbFoodRecordV3 = dbFoodRecordV3 else {
                    
                    let errorDomain = "passio.food.record.operation"
                    let errorCode = 7001

                    // Create userInfo dictionary
                    let userInfo: [String: Any] = [
                        NSLocalizedDescriptionKey: "Failed to fetch object",
                        NSLocalizedRecoverySuggestionErrorKey: "Food recrod is not found or object is in appropriate"
                    ]

                    // Create NSError
                    let error = NSError(domain: errorDomain, code: errorCode, userInfo: userInfo)
                    
                    completion(false, error as Error)
                    return
                }
                
                dbFoodRecordV3.barcode = foodRecord.barcode
                dbFoodRecordV3.confidence = foodRecord.confidence ?? 0
                dbFoodRecordV3.createdAt = foodRecord.createdAt
                dbFoodRecordV3.details = foodRecord.details
                dbFoodRecordV3.entityType = foodRecord.entityType.rawValue
                dbFoodRecordV3.iconId = foodRecord.iconId
                dbFoodRecordV3.id = foodRecord.id
                dbFoodRecordV3.mealLabel = foodRecord.mealLabel.rawValue
                dbFoodRecordV3.name = foodRecord.name
                dbFoodRecordV3.nutrients = foodRecord.getNutrients().toJsonString()
                dbFoodRecordV3.openFoodLicense = foodRecord.openFoodLicense
                dbFoodRecordV3.passioID = foodRecord.passioID
                dbFoodRecordV3.radioSelected = foodRecord.radioSelected ?? false
                dbFoodRecordV3.scannedUnitName = foodRecord.scannedUnitName
                dbFoodRecordV3.selectedQuantity = foodRecord.selectedQuantity
                dbFoodRecordV3.selectedUnit = foodRecord.selectedUnit
                
                var strServingSizes = ""
                foodRecord.servingSizes.compactMap({$0}).forEach({ strServingSizes.append($0.toJsonString() ?? "") })
                dbFoodRecordV3.servingSizes = strServingSizes
                
                var strServingUnits = ""
                foodRecord.servingUnits.compactMap({$0}).forEach({ strServingUnits.append($0.toJsonString() ?? "") })
                dbFoodRecordV3.servingUnits = strServingUnits
                
                dbFoodRecordV3.uuid = foodRecord.uuid
                
                var foodIngredients: [TblCustomFoodRecordIngredient] = []
                
                foodRecord.ingredients.forEach { foodRecordIngredient in
                    let tblCustomFoodRecordIngredient = TblCustomFoodRecordIngredient(context: context)
                    
                    tblCustomFoodRecordIngredient.details = foodRecordIngredient.details
                    tblCustomFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                    tblCustomFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                    tblCustomFoodRecordIngredient.name = foodRecordIngredient.name
                    tblCustomFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                    tblCustomFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                    tblCustomFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                    tblCustomFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                    tblCustomFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                    tblCustomFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                    
                    var strIngredientServingSizes = ""
                    foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                    tblCustomFoodRecordIngredient.servingSizes = strIngredientServingSizes
                    
                    var strIngredientServingUnits = ""
                    foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                    tblCustomFoodRecordIngredient.servingUnits = strIngredientServingUnits
                    
                    foodIngredients.append(tblCustomFoodRecordIngredient)
                }
                
                dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                
                context.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                print("Failed to fetch match and save as new recored: \(error)")
                completion(false, error)
            }
            
            
        }
    }
    
    //MARK: - Update Custom food records
    func updateCustomFoodRecord(foodRecord: FoodRecordV3, whereClause udid: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            // Create a fetch request for the Person entity
            let fetchRequest: NSFetchRequest<TblCustomFoodRecord> = TblCustomFoodRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", udid)
            var dbFoodRecordV3: TblCustomFoodRecord?
            
            do {
                
                // Fetch existing records
                let results = try context.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    print("Existing Record found for storage and will update it")
                    dbFoodRecordV3 = firstRecord
                    
                    guard let dbFoodRecordV3 = dbFoodRecordV3 else { return }
                    
                    dbFoodRecordV3.barcode = foodRecord.barcode
                    dbFoodRecordV3.confidence = foodRecord.confidence ?? 0
                    dbFoodRecordV3.createdAt = foodRecord.createdAt
                    dbFoodRecordV3.details = foodRecord.details
                    dbFoodRecordV3.entityType = foodRecord.entityType.rawValue
                    dbFoodRecordV3.iconId = foodRecord.iconId
                    dbFoodRecordV3.id = foodRecord.id
                    dbFoodRecordV3.mealLabel = foodRecord.mealLabel.rawValue
                    dbFoodRecordV3.name = foodRecord.name
                    dbFoodRecordV3.nutrients = foodRecord.getNutrients().toJsonString()
                    dbFoodRecordV3.openFoodLicense = foodRecord.openFoodLicense
                    dbFoodRecordV3.passioID = foodRecord.passioID
                    dbFoodRecordV3.radioSelected = foodRecord.radioSelected ?? false
                    dbFoodRecordV3.scannedUnitName = foodRecord.scannedUnitName
                    dbFoodRecordV3.selectedQuantity = foodRecord.selectedQuantity
                    dbFoodRecordV3.selectedUnit = foodRecord.selectedUnit
                    
                    var strServingSizes = ""
                    foodRecord.servingSizes.compactMap({$0}).forEach({ strServingSizes.append($0.toJsonString() ?? "") })
                    dbFoodRecordV3.servingSizes = strServingSizes
                    
                    var strServingUnits = ""
                    foodRecord.servingUnits.compactMap({$0}).forEach({ strServingUnits.append($0.toJsonString() ?? "") })
                    dbFoodRecordV3.servingUnits = strServingUnits
                    
                    dbFoodRecordV3.uuid = foodRecord.uuid
                    
                    var foodIngredients: [TblCustomFoodRecordIngredient] = []
                    
                    foodRecord.ingredients.forEach { foodRecordIngredient in
                        
                        let tblCustomFoodRecordIngredient = TblCustomFoodRecordIngredient(context: context)
                        
                        tblCustomFoodRecordIngredient.details = foodRecordIngredient.details
                        tblCustomFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                        tblCustomFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                        tblCustomFoodRecordIngredient.name = foodRecordIngredient.name
                        tblCustomFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                        tblCustomFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                        tblCustomFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                        tblCustomFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                        tblCustomFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                        tblCustomFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                        
                        var strIngredientServingSizes = ""
                        foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                        tblCustomFoodRecordIngredient.servingSizes = strIngredientServingSizes
                        
                        var strIngredientServingUnits = ""
                        foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                        tblCustomFoodRecordIngredient.servingUnits = strIngredientServingUnits
                        
                        foodIngredients.append(tblCustomFoodRecordIngredient)
                    }
                    
                    dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                    
                    context.saveChanges()
                    
                    completion(true, nil)
                }
            } catch let error {
                print("Failed to fetch record to update: \(error)")
                completion(false, error)
            }
            
        }
    }
    
    //MARK: - Fetch all Custom food records
    func fetchCustomFoodRecords(completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            do {
                
                let request: NSFetchRequest<TblCustomFoodRecord> = TblCustomFoodRecord.fetchRequest()
                let foodRecordResult = try context.fetch(request)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblCustomFoodRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblCustomFoodRecord)
                    return passioFoodRecordV3
                }
                
                context.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                print("Failed to fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch all Custom food records that matches with given name
    func fetchCustomFoodRecords(whereClause name: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblCustomFoodRecord> = TblCustomFoodRecord.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                
                let foodRecordResult = try context.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblCustomFoodRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblCustomFoodRecord)
                    return passioFoodRecordV3
                }
                
                context.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                print("Failed to fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch all Custom food records that matches with given barcode
    func fetchCustomFoodRecords(whereClauseBarcode barcode: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblCustomFoodRecord> = TblCustomFoodRecord.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcode)
                
                let foodRecordResult = try context.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblCustomFoodRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblCustomFoodRecord)
                    return passioFoodRecordV3
                }
                
                context.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                print("Failed to fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch all Custom food records that matches with given refCode
    func fetchCustomFoodRecords(whereClauseRefCode refCode: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblCustomFoodRecord> = TblCustomFoodRecord.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "refCode == %@", refCode)
                
                let foodRecordResult = try context.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblCustomFoodRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblCustomFoodRecord)
                    return passioFoodRecordV3
                }
                
                context.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                print("Failed to fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Delete food record with where clause of UDID
    func deleteCustomFoodRecords(whereClauseUDID udid: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            do {
                
                let deleteRequest: NSFetchRequest<TblCustomFoodRecord> = TblCustomFoodRecord.fetchRequest()
                deleteRequest.predicate = NSPredicate(format: "uuid == %@", udid)
                
                let foodRecordResult = try context.fetch(deleteRequest)
                
                // Delete the event
                foodRecordResult.forEach { recordToDelete in
                    context.delete(recordToDelete)
                }
                
                context.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                print("Failed to fetch record to delete: \(error)")
                completion(false, error)
            }
            
            
        }
        
    }
    
    //MARK: - Delete Custom food record
    func deleteAllCustomFoodRecords(completion: @escaping ((Bool, Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            do {
                
                let deleteRequest: NSFetchRequest<TblCustomFoodRecord> = TblCustomFoodRecord.fetchRequest()
                
                let foodRecordResult = try context.fetch(deleteRequest)
                
                // Delete the event
                foodRecordResult.forEach { recordToDelete in
                    context.delete(recordToDelete)
                }
                
                context.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                print("Failed to fetch record to delete: \(error)")
                completion(false, error)
            }
            
            
        }
        
    }
    
    //MARK: - CUSTOM FOOD IMAGE
    //MARK: - Store User Created Custom Food Image
    func saveUserCreatedCustomFoodImage(id: String, image: UIImage) {
        jsonConnector.updateUserFoodImage(with: id, image: image)
    }
    
    //MARK: - Fetch User Created Custom Food Image
    func fetchUserCreatedCustomFoodImage(id: String, completion: @escaping ((UIImage?) -> Void)) {
        jsonConnector.fetchUserFoodImage(with: id, completion: completion)
    }
    
    //MARK: - Delete User Created Custom Food Image
    func deleteUserCreatedCustomFoodImage(id: String) {
        jsonConnector.deleteUserFoodImage(with: id)
    }
    
}
