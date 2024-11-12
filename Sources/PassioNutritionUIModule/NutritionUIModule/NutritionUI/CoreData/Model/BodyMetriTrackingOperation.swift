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
    
    //MARK: - Fetch User records
    func updateWeightRecord(weightRecord: WeightTracking, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the UserProfileModel entity
            let fetchRequest: NSFetchRequest<TblWeightTracking> = TblWeightTracking.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", weightRecord.id)
            
            var dbWeightTracking: TblWeightTracking?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    dbWeightTracking = firstRecord
                    passioLog(message: "Existing weight tracking Record found to update")
                }
                else {
                    dbWeightTracking = TblWeightTracking(context: mainContext)
                    passioLog(message: "New weight tracking Record is created for storage")
                }
                
                guard let dbWeightTracking = dbWeightTracking else {
                    
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
                
                dbWeightTracking.id = weightRecord.id
                dbWeightTracking.weight = weightRecord.weight
                dbWeightTracking.date = weightRecord.date
                dbWeightTracking.time = weightRecord.time
                dbWeightTracking.createdAt = weightRecord.createdAt
                
                mainContext.saveChanges()
                
                completion(true, nil)
            }
            catch let error {
                
                passioLog(message: "Error while saving weight tracking data :: \(error)")
                
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
                
                // Create a calendar to get the start of the day
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: startDate)
//                let endOfDay = calendar.date(byAdding: .day, value: 1, to: endDate)!
                
                let fetchRequest: NSFetchRequest<TblWeightTracking> = TblWeightTracking.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", NSDate(timeIntervalSince1970: startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: endDate.timeIntervalSince1970))
                
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)

                // Add the sort descriptor to the fetch request
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                let weightTrackingResults = try mainContext.fetch(fetchRequest)
                
                let arrWeightTracking: [WeightTracking] = weightTrackingResults.map { tblWeightTracking in
                    return WeightTracking(id: tblWeightTracking.id ?? UUID().uuidString, weight: tblWeightTracking.weight ?? 0, date: tblWeightTracking.date ?? Date(), time: tblWeightTracking.date ?? Date(), createdAt: tblWeightTracking.createdAt ?? Date())
                }
                
                mainContext.saveChanges()
                
                completion(arrWeightTracking, nil)
                
            } catch let error {
                mainContext.saveChanges()
                passioLog(message: "Failed to Weight Tracking fetch records: \(error)")
                completion([], error)
            }
        }
        
    }
    
    //MARK: - Fetch latest Weight Tracking record with given date formate
    func fetchLatestWeightRecord(completion: @escaping ((WeightTracking?, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
//                let startDate = Date()
//                // Create a calendar to get the start of the day
//                let calendar = Calendar.current
//                let startOfDay = calendar.startOfDay(for: startDate)
//                let endOfDay = calendar.date(byAdding: .day, value: 1, to: endDate)!
                
                let fetchRequest: NSFetchRequest<TblWeightTracking> = TblWeightTracking.fetchRequest()
                //fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", NSDate(timeIntervalSince1970: startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: startDate.timeIntervalSince1970))
                
                let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)

                // Add the sort descriptor to the fetch request
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                let weightTrackingResults = try mainContext.fetch(fetchRequest)
                
                let arrWeightTracking: [WeightTracking] = weightTrackingResults.map { tblWeightTracking in
                    return WeightTracking(id: tblWeightTracking.id ?? UUID().uuidString, weight: tblWeightTracking.weight ?? 0, date: tblWeightTracking.date ?? Date(), time: tblWeightTracking.date ?? Date(), createdAt: tblWeightTracking.createdAt ?? Date())
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
                passioLog(message: "Failed to Weight Tracking fetch records: \(error)")
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
                passioLog(message: "Failed to fetch Weight tracking record to delete: \(error)")
                completion(false, error)
            }
            
            
        }
        
    }
    
}
