//
//  FoodRecipeRecordOperations.swift
//
//
//  Created by Mindinventory on 16/10/24.
//

import Foundation
import UIKit
import CoreData

internal class FoodRecipeRecordOperations {
    
    private init() {}
    
    private static var foodRecipeRecordOperations: FoodRecipeRecordOperations = {
        let foodRecipeRecordOperations = FoodRecipeRecordOperations()
        return foodRecipeRecordOperations
    }()
    
    static var shared: FoodRecipeRecordOperations = {
        return foodRecipeRecordOperations
    }()
 
    private func getMainContext() -> NSManagedObjectContext {
        CoreDataManager.shared.mainManagedObjectContext
    }
    
    fileprivate let jsonConnector: PassioConnector = JSONPassioConnector.shared
    
    //MARK: - Insert Food Recipe Record
    func insertFoodRecipeRecord(foodRecord: FoodRecordV3, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            var dbFoodRecordV3: TblFoodRecipeRecord?
            
            do {
                
                dbFoodRecordV3 = TblFoodRecipeRecord(context: mainContext)
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
                dbFoodRecordV3.refCode = foodRecord.refCode
                
                var strServingSizes = ""
                foodRecord.servingSizes.compactMap({$0}).forEach({ strServingSizes.append($0.toJsonString() ?? "") })
                dbFoodRecordV3.servingSizes = strServingSizes
                
                var strServingUnits = ""
                foodRecord.servingUnits.compactMap({$0}).forEach({ strServingUnits.append($0.toJsonString() ?? "") })
                dbFoodRecordV3.servingUnits = strServingUnits
                
                dbFoodRecordV3.uuid = foodRecord.uuid
                
                var foodIngredients: [TblFoodRecipeRecordIngredient] = []
                
                foodRecord.ingredients.forEach { foodRecordIngredient in
                    let tblFoodRecipeRecordIngredient = TblFoodRecipeRecordIngredient(context: mainContext)
                    
                    tblFoodRecipeRecordIngredient.details = foodRecordIngredient.details
                    tblFoodRecipeRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                    tblFoodRecipeRecordIngredient.iconId = foodRecordIngredient.iconId
                    tblFoodRecipeRecordIngredient.name = foodRecordIngredient.name
                    tblFoodRecipeRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                    tblFoodRecipeRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                    tblFoodRecipeRecordIngredient.passioID = foodRecordIngredient.passioID
                    tblFoodRecipeRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                    tblFoodRecipeRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                    tblFoodRecipeRecordIngredient.refCode = foodRecordIngredient.refCode
                    tblFoodRecipeRecordIngredient.barcode = foodRecordIngredient.barcode
                    
                    var strIngredientServingSizes = ""
                    foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                    tblFoodRecipeRecordIngredient.servingSizes = strIngredientServingSizes
                    
                    var strIngredientServingUnits = ""
                    foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                    tblFoodRecipeRecordIngredient.servingUnits = strIngredientServingUnits
                    
                    foodIngredients.append(tblFoodRecipeRecordIngredient)
                }
                
                dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                print("Failed to fetch match delete and save as new recored: \(error)")
                completion(false, error)
            }
        }
    }
    
    //MARK: - Insert OR Update Food Recipe Record
    func insertOrUpdateFoodRecipeRecord(foodRecord: FoodRecordV3, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the Person entity
            let fetchRequest: NSFetchRequest<TblFoodRecipeRecord> = TblFoodRecipeRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", foodRecord.uuid)
            
            var dbFoodRecordV3: TblFoodRecipeRecord?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    dbFoodRecordV3 = firstRecord
                    print("Existing Record found to update")
                }
                else {
                    dbFoodRecordV3 = TblFoodRecipeRecord(context: mainContext)
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
                dbFoodRecordV3.refCode = foodRecord.refCode
                
                var strServingSizes = ""
                foodRecord.servingSizes.compactMap({$0}).forEach({ strServingSizes.append($0.toJsonString() ?? "") })
                dbFoodRecordV3.servingSizes = strServingSizes
                
                var strServingUnits = ""
                foodRecord.servingUnits.compactMap({$0}).forEach({ strServingUnits.append($0.toJsonString() ?? "") })
                dbFoodRecordV3.servingUnits = strServingUnits
                
                dbFoodRecordV3.uuid = foodRecord.uuid
                
                var foodIngredients: [TblFoodRecipeRecordIngredient] = []
                
                foodRecord.ingredients.forEach { foodRecordIngredient in
                    let tblFoodRecipeRecordIngredient = TblFoodRecipeRecordIngredient(context: mainContext)
                    
                    tblFoodRecipeRecordIngredient.details = foodRecordIngredient.details
                    tblFoodRecipeRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                    tblFoodRecipeRecordIngredient.iconId = foodRecordIngredient.iconId
                    tblFoodRecipeRecordIngredient.name = foodRecordIngredient.name
                    tblFoodRecipeRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                    tblFoodRecipeRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                    tblFoodRecipeRecordIngredient.passioID = foodRecordIngredient.passioID
                    tblFoodRecipeRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                    tblFoodRecipeRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                    tblFoodRecipeRecordIngredient.refCode = foodRecordIngredient.refCode
                    tblFoodRecipeRecordIngredient.barcode = foodRecordIngredient.barcode
                    
                    var strIngredientServingSizes = ""
                    foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                    tblFoodRecipeRecordIngredient.servingSizes = strIngredientServingSizes
                    
                    var strIngredientServingUnits = ""
                    foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                    tblFoodRecipeRecordIngredient.servingUnits = strIngredientServingUnits
                    
                    foodIngredients.append(tblFoodRecipeRecordIngredient)
                }
                
                dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                print("Failed to fetch match and save as new recored: \(error)")
                completion(false, error)
            }
            
            
        }
    }
    
    //MARK: - Update Food Recipe records
    func updateFoodRecipeRecord(foodRecord: FoodRecordV3, whereClause udid: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the Person entity
            let fetchRequest: NSFetchRequest<TblFoodRecipeRecord> = TblFoodRecipeRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", udid)
            var dbFoodRecordV3: TblFoodRecipeRecord?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
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
                    dbFoodRecordV3.refCode = foodRecord.refCode
                    
                    var strServingSizes = ""
                    foodRecord.servingSizes.compactMap({$0}).forEach({ strServingSizes.append($0.toJsonString() ?? "") })
                    dbFoodRecordV3.servingSizes = strServingSizes
                    
                    var strServingUnits = ""
                    foodRecord.servingUnits.compactMap({$0}).forEach({ strServingUnits.append($0.toJsonString() ?? "") })
                    dbFoodRecordV3.servingUnits = strServingUnits
                    
                    dbFoodRecordV3.uuid = foodRecord.uuid
                    
                    var foodIngredients: [TblFoodRecipeRecordIngredient] = []
                    
                    foodRecord.ingredients.forEach { foodRecordIngredient in
                        
                        let tblFoodRecipeRecordIngredient = TblFoodRecipeRecordIngredient(context: mainContext)
                        
                        tblFoodRecipeRecordIngredient.details = foodRecordIngredient.details
                        tblFoodRecipeRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                        tblFoodRecipeRecordIngredient.iconId = foodRecordIngredient.iconId
                        tblFoodRecipeRecordIngredient.name = foodRecordIngredient.name
                        tblFoodRecipeRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                        tblFoodRecipeRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                        tblFoodRecipeRecordIngredient.passioID = foodRecordIngredient.passioID
                        tblFoodRecipeRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                        tblFoodRecipeRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                        tblFoodRecipeRecordIngredient.refCode = foodRecordIngredient.refCode
                        tblFoodRecipeRecordIngredient.barcode = foodRecordIngredient.barcode
                        
                        var strIngredientServingSizes = ""
                        foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                        tblFoodRecipeRecordIngredient.servingSizes = strIngredientServingSizes
                        
                        var strIngredientServingUnits = ""
                        foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                        tblFoodRecipeRecordIngredient.servingUnits = strIngredientServingUnits
                        
                        foodIngredients.append(tblFoodRecipeRecordIngredient)
                    }
                    
                    dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                    
                    mainContext.saveChanges()
                    
                    completion(true, nil)
                }
            } catch let error {
                print("Failed to fetch record to update: \(error)")
                completion(false, error)
            }
            
        }
    }
    
    //MARK: - Fetch All Food Recipe records
    func fetchFoodRecipeRecords(completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let request: NSFetchRequest<TblFoodRecipeRecord> = TblFoodRecipeRecord.fetchRequest()
                let foodRecordResult = try mainContext.fetch(request)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblFoodRecipeRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblFoodRecipeRecord)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                print("Failed to fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch All Food Recipe Records That Matches With Given Name
    func fetchFoodRecipeRecords(whereClause name: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblFoodRecipeRecord> = TblFoodRecipeRecord.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                
                let foodRecordResult = try mainContext.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblFoodRecipeRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblFoodRecipeRecord)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                print("Failed to fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch All Food Recipe Records That Matches With Given Barcode
    func fetchFoodRecipeRecords(whereClauseBarcode barcode: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblFoodRecipeRecord> = TblFoodRecipeRecord.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcode)
                
                let foodRecordResult = try mainContext.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblFoodRecipeRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblFoodRecipeRecord)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                print("Failed to fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch All Food Recipe Records That Matches With Given RefCode
    func fetchFoodRecipeRecords(whereClauseRefCode refCode: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblFoodRecipeRecord> = TblFoodRecipeRecord.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "refCode == %@", refCode)
                
                let foodRecordResult = try mainContext.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblFoodRecipeRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblFoodRecipeRecord)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                print("Failed to fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Delete Food Recipe with where clause of RefCode
    func deleteFoodRecipeRecords(whereClauseRefCode refCode: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let deleteRequest: NSFetchRequest<TblFoodRecipeRecord> = TblFoodRecipeRecord.fetchRequest()
                deleteRequest.predicate = NSPredicate(format: "refCode == %@", refCode)
                
                let foodRecordResult = try mainContext.fetch(deleteRequest)
                
                // Delete the event
                foodRecordResult.forEach { recordToDelete in
                    mainContext.delete(recordToDelete)
                }
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                print("Failed to fetch record to delete: \(error)")
                completion(false, error)
            }
            
            
        }
        
    }
    
    //MARK: - Delete Food Recipe Records
    func deleteAllFoodRecipeRecords(completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let deleteRequest: NSFetchRequest<TblFoodRecipeRecord> = TblFoodRecipeRecord.fetchRequest()
                
                let foodRecordResult = try mainContext.fetch(deleteRequest)
                
                // Delete the event
                foodRecordResult.forEach { recordToDelete in
                    mainContext.delete(recordToDelete)
                }
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                print("Failed to fetch record to delete: \(error)")
                completion(false, error)
            }
        }
        
    }
    
}
