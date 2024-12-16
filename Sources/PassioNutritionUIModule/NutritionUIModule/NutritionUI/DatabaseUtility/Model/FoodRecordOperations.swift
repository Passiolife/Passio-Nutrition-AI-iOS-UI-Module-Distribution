//
//  FoodRecordOperations.swift
//
//
//  Created by Mindinventory on 16/10/24.
//

import Foundation
import CoreData

internal class FoodRecordOperations {
    
    private init() {}
    
    private static var foodRecordOperations: FoodRecordOperations = {
        let foodRecordOperations = FoodRecordOperations()
        return foodRecordOperations
    }()
    
    static var shared: FoodRecordOperations = {
        return foodRecordOperations
    }()
 
    private func getMainContext() -> NSManagedObjectContext {
        CoreDataManager.shared.mainManagedObjectContext
    }
    
    //save food record FoodRecordV3
    func insertFoodRecord(foodRecord: FoodRecordV3, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            var dbFoodRecordV3: TblFoodRecordV3?
            
            do {
                
                dbFoodRecordV3 = TblFoodRecordV3(context: mainContext)
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
                
                var foodIngredients: [TblFoodRecordIngredient] = []
                
                foodRecord.ingredients.forEach { foodRecordIngredient in
                    let tblFoodRecordIngredient = TblFoodRecordIngredient(context: mainContext)
                    
                    tblFoodRecordIngredient.details = foodRecordIngredient.details
                    tblFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                    tblFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                    tblFoodRecordIngredient.name = foodRecordIngredient.name
                    tblFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                    tblFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                    tblFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                    tblFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                    tblFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                    tblFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                    tblFoodRecordIngredient.barcode = foodRecordIngredient.barcode
                    
                    var strIngredientServingSizes = ""
                    foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                    tblFoodRecordIngredient.servingSizes = strIngredientServingSizes
                    
                    var strIngredientServingUnits = ""
                    foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                    tblFoodRecordIngredient.servingUnits = strIngredientServingUnits
                    
                    foodIngredients.append(tblFoodRecordIngredient)
                }
                
                dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print( "Failed to fetch match delete and save as new recored: \(error)")
                completion(false, error)
            }
        }
    }
    
    //MARK: - Insert OR Update food record
    func insertOrUpdateFoodRecord(foodRecord: FoodRecordV3, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the Person entity
            let fetchRequest: NSFetchRequest<TblFoodRecordV3> = TblFoodRecordV3.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", foodRecord.uuid)
            
            var dbFoodRecordV3: TblFoodRecordV3?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                if let firstRecord = results.first {
                    dbFoodRecordV3 = firstRecord
                    print( "Existing FoodLog Record found to update")
                }
                else {
                    dbFoodRecordV3 = TblFoodRecordV3(context: mainContext)
                    print( "New FoodLog Record is created for storage")
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
                    mainContext.saveChanges()
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
                
                var foodIngredients: [TblFoodRecordIngredient] = []
                
                foodRecord.ingredients.forEach { foodRecordIngredient in
                    let tblFoodRecordIngredient = TblFoodRecordIngredient(context: mainContext)
                    
                    tblFoodRecordIngredient.details = foodRecordIngredient.details
                    tblFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                    tblFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                    tblFoodRecordIngredient.name = foodRecordIngredient.name
                    tblFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                    tblFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                    tblFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                    tblFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                    tblFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                    tblFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                    tblFoodRecordIngredient.barcode = foodRecordIngredient.barcode
                    
                    var strIngredientServingSizes = ""
                    foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                    tblFoodRecordIngredient.servingSizes = strIngredientServingSizes
                    
                    var strIngredientServingUnits = ""
                    foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                    tblFoodRecordIngredient.servingUnits = strIngredientServingUnits
                    
                    foodIngredients.append(tblFoodRecordIngredient)
                }
                
                dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                
                mainContext.saveChanges()
                
                
                // print("Passio Logs >>> Insert/Update Log Record: \(endTime.getTimeIntervalInSeconds(fromTime: currentTime))")
                
                completion(true, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print( "Failed to fetch match and save as new FoodLog recored: \(error)")
                completion(false, error)
            }
            
            
        }
    }
    
    func insertOrUpdateMultipleFoodRecords(foodRecords: [FoodRecordV3], completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            var errorStatement: Error?
            
            for foodRecord in foodRecords {
                
                // Create a fetch request for the Person entity
                let fetchRequest: NSFetchRequest<TblFoodRecordV3> = TblFoodRecordV3.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", foodRecord.uuid)
                
                var dbFoodRecordV3: TblFoodRecordV3?
                
                do {
                    
                    // Fetch existing records
                    let results = try mainContext.fetch(fetchRequest)
                    if let firstRecord = results.first {
                        dbFoodRecordV3 = firstRecord
                        print( "Existing FoodLog Record found to update")
                    }
                    else {
                        dbFoodRecordV3 = TblFoodRecordV3(context: mainContext)
                        print( "New FoodLog Record is created for storage")
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
                    
                    var foodIngredients: [TblFoodRecordIngredient] = []
                    
                    foodRecord.ingredients.forEach { foodRecordIngredient in
                        let tblFoodRecordIngredient = TblFoodRecordIngredient(context: mainContext)
                        
                        tblFoodRecordIngredient.details = foodRecordIngredient.details
                        tblFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                        tblFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                        tblFoodRecordIngredient.name = foodRecordIngredient.name
                        tblFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                        tblFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                        tblFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                        tblFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                        tblFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                        tblFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                        tblFoodRecordIngredient.barcode = foodRecordIngredient.barcode
                        
                        var strIngredientServingSizes = ""
                        foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                        tblFoodRecordIngredient.servingSizes = strIngredientServingSizes
                        
                        var strIngredientServingUnits = ""
                        foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                        tblFoodRecordIngredient.servingUnits = strIngredientServingUnits
                        
                        foodIngredients.append(tblFoodRecordIngredient)
                    }
                    
                    dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                    
                } catch let error {
                    errorStatement = error
                    print( "Failed to fetch match and save as new FoodLog recored: \(error)")
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
    
    //MARK: - Update food records
    func updateFoodRecord(foodRecord: FoodRecordV3, whereClause udid: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the Person entity
            let fetchRequest: NSFetchRequest<TblFoodRecordV3> = TblFoodRecordV3.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", udid)
            var dbFoodRecordV3: TblFoodRecordV3?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    print( "Existing FoodLog Record found for storage and will update it")
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
                    
                    var foodIngredients: [TblFoodRecordIngredient] = []
                    
                    foodRecord.ingredients.forEach { foodRecordIngredient in
                        
                        let tblFoodRecordIngredient = TblFoodRecordIngredient(context: mainContext)
                        
                        tblFoodRecordIngredient.details = foodRecordIngredient.details
                        tblFoodRecordIngredient.entityType = foodRecordIngredient.entityType.rawValue
                        tblFoodRecordIngredient.iconId = foodRecordIngredient.iconId
                        tblFoodRecordIngredient.name = foodRecordIngredient.name
                        tblFoodRecordIngredient.nutrients = foodRecordIngredient.nutrients.toJsonString()
                        tblFoodRecordIngredient.openFoodLicense = foodRecordIngredient.openFoodLicense
                        tblFoodRecordIngredient.passioID = foodRecordIngredient.passioID
                        tblFoodRecordIngredient.selectedQuantity = foodRecordIngredient.selectedQuantity
                        tblFoodRecordIngredient.selectedUnit = foodRecordIngredient.selectedUnit
                        tblFoodRecordIngredient.refCode = foodRecordIngredient.refCode
                        tblFoodRecordIngredient.barcode = foodRecordIngredient.barcode
                        
                        var strIngredientServingSizes = ""
                        foodRecordIngredient.servingSizes.compactMap({$0}).forEach({ strIngredientServingSizes.append($0.toJsonString() ?? "") })
                        tblFoodRecordIngredient.servingSizes = strIngredientServingSizes
                        
                        var strIngredientServingUnits = ""
                        foodRecordIngredient.servingUnits.compactMap({$0}).forEach({ strIngredientServingUnits.append($0.toJsonString() ?? "") })
                        tblFoodRecordIngredient.servingUnits = strIngredientServingUnits
                        
                        foodIngredients.append(tblFoodRecordIngredient)
                    }
                    
                    dbFoodRecordV3.ingredients = NSSet(array: foodIngredients)
                    
                    mainContext.saveChanges()
                    
                    completion(true, nil)
                }
            } catch let error {
                mainContext.saveChanges()
                print( "Failed to fetch FoodLog record to update: \(error)")
                completion(false, error)
            }
            
        }
    }
    
    //MARK: - Fetch all food records
    func fetchFoodRecords(completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()

        mainContext.perform {
            
            do {
                
                let request: NSFetchRequest<TblFoodRecordV3> = TblFoodRecordV3.fetchRequest()
                let foodRecordResult = try mainContext.fetch(request)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { tblFoodRecordV3 in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: tblFoodRecordV3)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print( "Failed to FoodLog fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch all food records with given date formate
    func fetchFoodRecords(whereClause date: Date, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()

        mainContext.perform {
            
            do {
                
                // Create a calendar to get the start of the day
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let fetchRequest: NSFetchRequest<TblFoodRecordV3> = TblFoodRecordV3.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", NSDate(timeIntervalSince1970: startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: endOfDay.timeIntervalSince1970))
                
                let foodRecordResult = try mainContext.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { tblFoodRecordV3 in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: tblFoodRecordV3)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print( "Failed to FoodLog fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch all food records with given date range
    func fetchFoodRecords(whereClause fromDate: Date, endDate: Date, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblFoodRecordV3> = TblFoodRecordV3.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", NSDate(timeIntervalSince1970: fromDate.timeIntervalSince1970), NSDate(timeIntervalSince1970: endDate.timeIntervalSince1970))
                
                let foodRecordResult = try mainContext.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { tblFoodRecordV3 in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: tblFoodRecordV3)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print( "Failed to FoodLog fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch all food records that matches with given name
    func fetchFoodRecords(whereClause name: String, completion: @escaping (([FoodRecordV3], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblFoodRecordV3> = TblFoodRecordV3.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                
                let foodRecordResult = try mainContext.fetch(fetchRequest)
                
                let arrFoodRecordV3: [FoodRecordV3] = foodRecordResult.map { tblFoodRecordV3 in
                    var passioFoodRecordV3 = FoodRecordV3(foodRecordCore: tblFoodRecordV3)
                    return passioFoodRecordV3
                }
                
                mainContext.saveChanges()
                
                completion(arrFoodRecordV3, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print( "Failed to FoodLog fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Delete food record
    func deleteFoodRecords(whereClause udid: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let deleteRequest: NSFetchRequest<TblFoodRecordV3> = TblFoodRecordV3.fetchRequest()
                deleteRequest.predicate = NSPredicate(format: "uuid == %@", udid)
                
                let foodRecordResult = try mainContext.fetch(deleteRequest)
                
                // Delete the event
                foodRecordResult.forEach { recordToDelete in
                    mainContext.delete(recordToDelete)
                }
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print( "Failed to FoodLog fetch record to delete: \(error)")
                completion(false, error)
            }
            
            
        }
        
    }
    
}
