//
//  BodyMetriTrackingOperation.swift
//  PassioNutritionUIModule
//
//  Created by Tushar S on 08/11/24.
//

import Foundation
import CoreData

public class BodyMetriTrackingOperation {
    
    private init() {}
    
    private static var bodyMetriTrackingOperation: BodyMetriTrackingOperation = {
        let bodyMetriTrackingOperation = BodyMetriTrackingOperation()
        return bodyMetriTrackingOperation
    }()
    
    static var shared: BodyMetriTrackingOperation = {
        return bodyMetriTrackingOperation
    }()
 
    private func getMainContext() -> NSManagedObjectContext {
        CoreDataManager.shared.mainManagedObjectContext
    }
    
    //MARK: - Weight Tracking
    //MARK: - Insert/Update records
    func updateWeightRecord(weightRecord: WeightTracking, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the TblWeightTracking entity
            let fetchRequest: NSFetchRequest<TblWeightTracking> = TblWeightTracking.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", weightRecord.id)
            
            var dbWeightTracking: TblWeightTracking?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    dbWeightTracking = firstRecord
                    print("Existing weight tracking Record found to update")
                }
                else {
                    dbWeightTracking = TblWeightTracking(context: mainContext)
                    print("New weight tracking Record is created for storage")
                }
                
                guard let dbWeightTracking = dbWeightTracking else {
                    
                    let errorDomain = "passio.watertracking.record.operation"
                    let errorCode = 7001
                    
                    // Create userInfo dictionary
                    let userInfo: [String: Any] = [
                        NSLocalizedDescriptionKey: "Failed to fetch object",
                        NSLocalizedRecoverySuggestionErrorKey: "WaterTracking recrod is not found or object is in appropriate"
                    ]
                    
                    // Create NSError
                    let error = NSError(domain: errorDomain, code: errorCode, userInfo: userInfo)
                    
                    completion(false, error as Error)
                    return
                }
                
                dbWeightTracking.id = weightRecord.id
                dbWeightTracking.weight = weightRecord.weight
                dbWeightTracking.dateTime = weightRecord.dateTime
                
                mainContext.saveChanges()
                
                completion(true, nil)
            }
            catch let error {
                
                print("Error while saving weight tracking data :: \(error)")
                
                mainContext.saveChanges()
                completion(false, error)
            }
        }
    }

    //MARK: - Fetch all Weight Tracking records with given date formate
    func fetchWeightTracking(whereClause startDate: Date, endDate: Date, completion: @escaping (([WeightTracking], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let startOfDay = startDate.startOfDay
                let endOfDay = endDate.endOfDay
                
                let fetchRequest: NSFetchRequest<TblWeightTracking> = TblWeightTracking.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@", startOfDay as NSDate, endOfDay as NSDate)
                
                let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)

                // Add the sort descriptor to the fetch request
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                let weightTrackingResults = try mainContext.fetch(fetchRequest)
                
                let arrWeightTracking: [WeightTracking] = weightTrackingResults.map { tblWeightTracking in
                    return WeightTracking(id: tblWeightTracking.id ?? UUID().uuidString, weight: tblWeightTracking.weight ?? 0, dateTime: tblWeightTracking.dateTime ?? Date())
                }
                
                mainContext.saveChanges()
                
                completion(arrWeightTracking, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print("Failed to Weight Tracking fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch latest Weight Tracking record with given date formate
    func fetchLatestWeightRecord(completion: @escaping ((WeightTracking?, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblWeightTracking> = TblWeightTracking.fetchRequest()
                
                let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)

                // Add the sort descriptor to the fetch request
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                let weightTrackingResults = try mainContext.fetch(fetchRequest)
                
                let arrWeightTracking: [WeightTracking] = weightTrackingResults.map { tblWeightTracking in
                    return WeightTracking(id: tblWeightTracking.id ?? UUID().uuidString, weight: tblWeightTracking.weight ?? 0, dateTime: tblWeightTracking.dateTime ?? Date())
                }
                
                mainContext.saveChanges()
                if let lastRecord = arrWeightTracking.last {
                    completion(lastRecord, nil)
                }
                else {
                    completion(nil, nil)
                }
                
            } catch let error {
                mainContext.saveChanges()
                print("Failed to Weight Tracking fetch records: \(error)")
                completion(nil, error)
            }
        }
    }
    
    //MARK: - Delete Weight tracking record
    func deleteWeightRecord(weightRecord record: WeightTracking, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let deleteRequest: NSFetchRequest<TblWeightTracking> = TblWeightTracking.fetchRequest()
                deleteRequest.predicate = NSPredicate(format: "id == %@", record.id)
                
                let foodRecordResult = try mainContext.fetch(deleteRequest)
                
                // Delete the event
                foodRecordResult.forEach { recordToDelete in
                    mainContext.delete(recordToDelete)
                }
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print("Failed to fetch Weight tracking record to delete: \(error)")
                completion(false, error)
            }
            
            
        }
        
    }
    
    
    //MARK: - Water Tracking
    //MARK: - Insert/Update records
    func updateWaterRecord(waterRecord: WaterTracking, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {

            // Create a fetch request for the TblWaterTracing entity
            let fetchRequest: NSFetchRequest<TblWaterTracking> = TblWaterTracking.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", waterRecord.id)
            
            var dbWaterTracking: TblWaterTracking?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    dbWaterTracking = firstRecord
                    print("Existing water tracking Record found to update")
                }
                else {
                    dbWaterTracking = TblWaterTracking(context: mainContext)
                    print("New water tracking Record is created for storage")
                }
                
                guard let dbWaterTracking = dbWaterTracking else {
                    
                    let errorDomain = "passio.watertracking.record.operation"
                    let errorCode = 7001
                    
                    // Create userInfo dictionary
                    let userInfo: [String: Any] = [
                        NSLocalizedDescriptionKey: "Failed to fetch object",
                        NSLocalizedRecoverySuggestionErrorKey: "water tracking recrod is not found or object is in appropriate"
                    ]
                    
                    // Create NSError
                    let error = NSError(domain: errorDomain, code: errorCode, userInfo: userInfo)
                    
                    completion(false, error as Error)
                    return
                }
                
                dbWaterTracking.id = waterRecord.id
                dbWaterTracking.water = waterRecord.water
                dbWaterTracking.dateTime = waterRecord.dateTime
                
                mainContext.saveChanges()
                
                completion(true, nil)
            }
            catch let error {
                
                print("Error while saving water tracking data :: \(error)")
                
                mainContext.saveChanges()
                completion(false, error)
            }
        }
    }
    
    //MARK: - Fetch all Water Tracking records with given date formate
    func fetchWaterTracking(whereClause startDate: Date, endDate: Date, completion: @escaping (([WaterTracking], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let startOfDay = startDate.startOfDay
                let endOfDay = endDate.endOfDay
                
                let fetchRequest: NSFetchRequest<TblWaterTracking> = TblWaterTracking.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "dateTime >= %@ AND dateTime <= %@", startOfDay as NSDate, endOfDay as NSDate)
                
                let sortDescriptor = NSSortDescriptor(key: "dateTime", ascending: true)

                // Add the sort descriptor to the fetch request
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                let waterTrackingResults = try mainContext.fetch(fetchRequest)
                
                let arrWaterTracking: [WaterTracking] = waterTrackingResults.map { tblWaterTracking in
                    return WaterTracking(id: tblWaterTracking.id ?? UUID().uuidString, water: tblWaterTracking.water ?? 0, dateTime: tblWaterTracking.dateTime ?? Date())
                }
                
                mainContext.saveChanges()
                
                completion(arrWaterTracking, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print("Failed to Water Tracking fetch records: \(error)")
                completion([], error)
            }
        }
    }
    
    //MARK: - Delete Water tracking record
    func deleteWaterRecord(waterRecord record: WaterTracking, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let deleteRequest: NSFetchRequest<TblWaterTracking> = TblWaterTracking.fetchRequest()
                deleteRequest.predicate = NSPredicate(format: "id == %@", record.id)
                
                let foodRecordResult = try mainContext.fetch(deleteRequest)
                
                // Delete the event
                foodRecordResult.forEach { recordToDelete in
                    mainContext.delete(recordToDelete)
                }
                
                mainContext.saveChanges()
                
                completion(true, nil)
                
            } catch let error {
                mainContext.saveChanges()
                print("Failed to fetch Water tracking record to delete: \(error)")
                completion(false, error)
            }
            
            
        }
        
    }
}
