//
//  FavouriteFoodRecordOperations.swift
//
//
//  Created by Mindinventory on 16/10/24.
//

import Foundation
import UIKit
import CoreData

internal class FavouriteFoodRecordOperations {
    
    private init() {}
    
    private static var favouriteFoodRecordOperations: FavouriteFoodRecordOperations = {
        let favouriteFoodRecordOperations = FavouriteFoodRecordOperations()
        return favouriteFoodRecordOperations
    }()
    
    static var shared: FavouriteFoodRecordOperations = {
        return favouriteFoodRecordOperations
    }()
 
    private func getMainContext() -> NSManagedObjectContext {
        CoreDataManager.shared.mainManagedObjectContext
    }
    
    fileprivate let jsonConnector: PassioConnector = JSONPassioConnector.shared
    
    //MARK: - Insert Favourite food record
    func insertFavouriteFoodRecord(foodRecord: FoodRecordV3, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            var dbFoodRecordV3: TblFavouriteFoodRecord?
            
            do {
                
                dbFoodRecordV3 = TblFavouriteFoodRecord(context: mainContext)
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
                
                var foodIngredients: [TblFavouriteFoodRecordIngredient] = []
                
                foodRecord.ingredients.forEach { foodRecordIngredient in
                    let tblFavouriteFoodRecordIngredient = TblFavouriteFoodRecordIngredient(context: mainContext)
                    
                    tblFavouriteFoodRecordIngredient.details = foodRecordIngredient.details
                    tblFavouriteFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                    tblFavouriteFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                    tblFavouriteFoodRecordIngredient.name = foodRecordIngredient.name
                    tblFavouriteFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                    tblFavouriteFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                    tblFavouriteFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                    tblFavouriteFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                    tblFavouriteFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                    tblFavouriteFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                    tblFavouriteFoodRecordIngredient.barcode = foodRecordIngredient.barcode
                    
                    var strIngredientServingSizes = ""
                    foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                    tblFavouriteFoodRecordIngredient.servingSizes = strIngredientServingSizes
                    
                    var strIngredientServingUnits = ""
                    foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                    tblFavouriteFoodRecordIngredient.servingUnits = strIngredientServingUnits
                    
                    foodIngredients.append(tblFavouriteFoodRecordIngredient)
                }
                
                dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                
                print( "Failed to fetch match delete and save as new Favourite recored: \(error)")
                
                mainContext.saveChanges()
                completion(false, error)
            }
        }
    }
    
    //MARK: - Insert OR Update Favourite food record
    func insertOrUpdateFavouriteFoodRecord(foodRecord: FoodRecordV3, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the Person entity
            let fetchRequest: NSFetchRequest<TblFavouriteFoodRecord> = TblFavouriteFoodRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", foodRecord.uuid)
            
            var dbFoodRecordV3: TblFavouriteFoodRecord?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    dbFoodRecordV3 = firstRecord
                    print( "Existing Favourite Record found to update")
                }
                else {
                    dbFoodRecordV3 = TblFavouriteFoodRecord(context: mainContext)
                    print( "New Favourite Record is created for storage")
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
                
                var foodIngredients: [TblFavouriteFoodRecordIngredient] = []
                
                foodRecord.ingredients.forEach { foodRecordIngredient in
                    let tblFavouriteFoodRecordIngredient = TblFavouriteFoodRecordIngredient(context: mainContext)
                    
                    tblFavouriteFoodRecordIngredient.details = foodRecordIngredient.details
                    tblFavouriteFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                    tblFavouriteFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                    tblFavouriteFoodRecordIngredient.name = foodRecordIngredient.name
                    tblFavouriteFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                    tblFavouriteFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                    tblFavouriteFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                    tblFavouriteFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                    tblFavouriteFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                    tblFavouriteFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                    tblFavouriteFoodRecordIngredient.barcode = foodRecordIngredient.barcode
                    
                    var strIngredientServingSizes = ""
                    foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                    tblFavouriteFoodRecordIngredient.servingSizes = strIngredientServingSizes
                    
                    var strIngredientServingUnits = ""
                    foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                    tblFavouriteFoodRecordIngredient.servingUnits = strIngredientServingUnits
                    
                    foodIngredients.append(tblFavouriteFoodRecordIngredient)
                }
                
                dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                
                print( "Failed to fetch match and save as new Favourite recored: \(error)")
                
                mainContext.saveChanges()
                completion(false, error)
            }
        }
    }
    
    func insertOrUpdateFavouriteFoodMultipleRecords(foodRecords: [FoodRecordV3], completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            var errorStatement: Error?
            
            for foodRecord in foodRecords {
                
                do {
                    
                    // Create a fetch request for the Person entity
                    let fetchRequest: NSFetchRequest<TblFavouriteFoodRecord> = TblFavouriteFoodRecord.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "uuid == %@", foodRecord.uuid)
                    
                    var dbFoodRecordV3: TblFavouriteFoodRecord?
                    
                    // Fetch existing records
                    let results = try mainContext.fetch(fetchRequest)
                    
                    if let firstRecord = results.first {
                        dbFoodRecordV3 = firstRecord
                        print( "Existing Favourite Record found to update")
                    }
                    else {
                        dbFoodRecordV3 = TblFavouriteFoodRecord(context: mainContext)
                        print( "New Favourite Record is created for storage")
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
                    
                    var foodIngredients: [TblFavouriteFoodRecordIngredient] = []
                    
                    foodRecord.ingredients.forEach { foodRecordIngredient in
                        let tblFavouriteFoodRecordIngredient = TblFavouriteFoodRecordIngredient(context: mainContext)
                        
                        tblFavouriteFoodRecordIngredient.details = foodRecordIngredient.details
                        tblFavouriteFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                        tblFavouriteFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                        tblFavouriteFoodRecordIngredient.name = foodRecordIngredient.name
                        tblFavouriteFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                        tblFavouriteFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                        tblFavouriteFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                        tblFavouriteFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                        tblFavouriteFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                        tblFavouriteFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                        tblFavouriteFoodRecordIngredient.barcode = foodRecordIngredient.barcode
                        
                        var strIngredientServingSizes = ""
                        foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                        tblFavouriteFoodRecordIngredient.servingSizes = strIngredientServingSizes
                        
                        var strIngredientServingUnits = ""
                        foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                        tblFavouriteFoodRecordIngredient.servingUnits = strIngredientServingUnits
                        
                        foodIngredients.append(tblFavouriteFoodRecordIngredient)
                    }
                    
                    dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                    
                    
                } catch let error {
                    errorStatement = error
                    print( "Failed to fetch match and save as new Favourite recored: \(error)")
                    completion(false, error)
                }
                
            }
            
            mainContext.saveChanges()
            
            if errorStatement != nil {
                completion(false, errorStatement)
            }
            else {
                completion(true, nil)
            }
        }
    }
    
    //MARK: - Update Favourite food records
    func updateFavouriteFoodRecord(foodRecord: FoodRecordV3, whereClause udid: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the Person entity
            let fetchRequest: NSFetchRequest<TblFavouriteFoodRecord> = TblFavouriteFoodRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", udid)
            var dbFoodRecordV3: TblFavouriteFoodRecord?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    print( "Existing Favourite Record found for storage and will update it")
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
                    
                    var foodIngredients: [TblFavouriteFoodRecordIngredient] = []
                    
                    foodRecord.ingredients.forEach { foodRecordIngredient in
                        
                        let tblFavouriteFoodRecordIngredient = TblFavouriteFoodRecordIngredient(context: mainContext)
                        
                        tblFavouriteFoodRecordIngredient.details = foodRecordIngredient.details
                        tblFavouriteFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                        tblFavouriteFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                        tblFavouriteFoodRecordIngredient.name = foodRecordIngredient.name
                        tblFavouriteFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                        tblFavouriteFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                        tblFavouriteFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                        tblFavouriteFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                        tblFavouriteFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                        tblFavouriteFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                        tblFavouriteFoodRecordIngredient.barcode = foodRecordIngredient.barcode
                        
                        var strIngredientServingSizes = ""
                        foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                        tblFavouriteFoodRecordIngredient.servingSizes = strIngredientServingSizes
                        
                        var strIngredientServingUnits = ""
                        foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                        tblFavouriteFoodRecordIngredient.servingUnits = strIngredientServingUnits
                        
                        foodIngredients.append(tblFavouriteFoodRecordIngredient)
                    }
                    
                    dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                    
                    mainContext.saveChanges()
                    
                    completion(true, nil)
                }
            } catch let error {
                print( "Failed to fetch Favourite record to update: \(error)")
                
                mainContext.saveChanges()
                completion(false, error)
            }
            
        }
    }
    
    //MARK: - Fetch all Favourite food records
    func fetchFavouriteFoodRecords(completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let request: NSFetchRequest<TblFavouriteFoodRecord> = TblFavouriteFoodRecord.fetchRequest()
                let foodRecordResult = try mainContext.fetch(request)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { tblFavouriteFoodRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: tblFavouriteFoodRecord)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                
                print( "Failed to fetch Favourite records: \(error)")
                
                mainContext.saveChanges()
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch all Favourite food records that matches with given name
    func fetchFavouriteFoodRecords(whereClause name: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblFavouriteFoodRecord> = TblFavouriteFoodRecord.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                
                let foodRecordResult = try mainContext.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblFavouriteFoodRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblFavouriteFoodRecord)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                
                print( "Failed to fetch Favourite records: \(error)")
                
                mainContext.saveChanges()
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch all Favourite food records that matches with given barcode
    func fetchFavouriteFoodRecords(whereClauseBarcode barcode: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblFavouriteFoodRecord> = TblFavouriteFoodRecord.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcode)
                
                let foodRecordResult = try mainContext.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblFavouriteFoodRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblFavouriteFoodRecord)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                
                print( "Failed to fetch Favourite records: \(error)")
                
                mainContext.saveChanges()
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch all Favourite food records that matches with given refCode
    func fetchFavouriteFoodRecords(whereClauseRefCode refCode: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblFavouriteFoodRecord> = TblFavouriteFoodRecord.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "refCode == %@", refCode)
                
                let foodRecordResult = try mainContext.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { TblFavouriteFoodRecord in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: TblFavouriteFoodRecord)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                
                print( "Failed to fetch Favourite records: \(error)")
                
                mainContext.saveChanges()
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Delete food record with where clause of refCode
    func deleteFavouriteFoodRecords(whereClauseRefCode refCode: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let deleteRequest: NSFetchRequest<TblFavouriteFoodRecord> = TblFavouriteFoodRecord.fetchRequest()
                deleteRequest.predicate = NSPredicate(format: "refCode == %@", refCode)
                
                let foodRecordResult = try mainContext.fetch(deleteRequest)
                
                // Delete the event
                foodRecordResult.forEach { recordToDelete in
                    mainContext.delete(recordToDelete)
                }
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                
                print( "Failed to fetch Favourite record to delete: \(error)")
                
                mainContext.saveChanges()
                completion(false, error)
            }
            
            
        }
        
    }
    
    //MARK: - Delete Favourite food record
    func deleteAllFavouriteFoodRecords(completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let deleteRequest: NSFetchRequest<TblFavouriteFoodRecord> = TblFavouriteFoodRecord.fetchRequest()
                
                let foodRecordResult = try mainContext.fetch(deleteRequest)
                
                // Delete the event
                foodRecordResult.forEach { recordToDelete in
                    mainContext.delete(recordToDelete)
                }
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                
                print( "Failed to fetch record to delete: \(error)")
                
                mainContext.saveChanges()
                completion(false, error)
            }
            
            
        }
        
    }
    
    //MARK: - Favourite Food Image
    //MARK: - Store User Created Favourite Food Image
    func saveUserCreatedFavouriteFoodImage(id: String, image: UIImage) {
        jsonConnector.updateUserFoodImage(with: id, image: image)
    }
    
    //MARK: - Fetch User Created Favourite Food Image
    func fetchUserCreatedFavouriteFoodImage(id: String, completion: @escaping ((UIImage?) -> Void)) {
        jsonConnector.fetchUserFoodImage(with: id, completion: completion)
    }
    
    //MARK: - Delete User Created Favourite Food Image
    func deleteUserCreatedFavouriteFoodImage(id: String) {
        jsonConnector.deleteUserFoodImage(with: id)
    }
    
}
