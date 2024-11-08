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
    func insertOrUpdateWeightTracking(weightTracking: WeightTracking, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the UserProfileModel entity
            let fetchRequest: NSFetchRequest<TblWeightTracking> = TblWeightTracking.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", weightTracking.id)
            
            var dbWeightTracking: TblWeightTracking?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    dbWeightTracking = firstRecord
                    passioLog(message: "Existing User Profile Record found to update")
                }
                else {
                    dbWeightTracking = TblWeightTracking(context: mainContext)
                    passioLog(message: "New User Profile Record is created for storage")
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
                
                dbWeightTracking.id = weightTracking.id
                dbWeightTracking.weight = weightTracking.weight
                dbWeightTracking.date = weightTracking.date
                dbWeightTracking.time = weightTracking.time
                dbWeightTracking.createdAt = weightTracking.createdAt
                
                mainContext.saveChanges()
                
                completion(true, nil)
            }
            catch let error {
                
                passioLog(message: "Error while saving UserProfile data :: \(error)")
                
                mainContext.saveChanges()
                completion(false, error)
            }
        }
    }

    //MARK: - Fetch all Weight Tracking records with given date formate
    func fetchWeightTracking(whereClause date: Date, completion: @escaping (([WeightTracking], Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                // Create a calendar to get the start of the day
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let fetchRequest: NSFetchRequest<TblWeightTracking> = TblWeightTracking.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "createdAt >= %@ AND createdAt < %@", NSDate(timeIntervalSince1970: startOfDay.timeIntervalSince1970), NSDate(timeIntervalSince1970: endOfDay.timeIntervalSince1970))
                
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
    
}
