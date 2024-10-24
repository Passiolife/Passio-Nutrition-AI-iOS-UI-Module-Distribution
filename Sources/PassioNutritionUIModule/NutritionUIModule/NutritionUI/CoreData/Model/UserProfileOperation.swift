//
//  UserProfileOperation.swift
//
//
//  Created by Mindinventory on 16/10/24.
//

import Foundation
import CoreData

public class UserProfileOperation {
    
    private init() {}
    
    private static var userProfileOperation: UserProfileOperation = {
        let userProfileOperation = UserProfileOperation()
        return userProfileOperation
    }()
    
    static var shared: UserProfileOperation = {
        return userProfileOperation
    }()
 
    private func getMainContext() -> NSManagedObjectContext {
        CoreDataManager.shared.mainManagedObjectContext
    }
    
    //MARK: - Fetch User records
    func insertOrUpdateUserProfile(userProfile: UserProfileModel, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            // Create a fetch request for the UserProfileModel entity
            let fetchRequest: NSFetchRequest<TblUserProfile> = TblUserProfile.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", userProfile.uuid)
            
            var dbUserProfile: TblUserProfile?
            
            do {
                
                // Fetch existing records
                let results = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = results.first {
                    dbUserProfile = firstRecord
                    passioLog(message: "Existing User Profile Record found to update")
                }
                else {
                    dbUserProfile = TblUserProfile(context: mainContext)
                    passioLog(message: "New User Profile Record is created for storage")
                }
                
                guard let dbUserProfile = dbUserProfile else {
                    
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
                
                dbUserProfile.activityLevel = userProfile.activityLevel?.rawValue
                dbUserProfile.age = userProfile.age.toInt16()
                dbUserProfile.birthday = userProfile.birthday
                dbUserProfile.caloriesTarget = userProfile.caloriesTarget.toInt16()
                dbUserProfile.carbsPercent = userProfile.carbsPercent.toInt16()
                dbUserProfile.fatPercent = userProfile.fatPercent.toInt16()
                dbUserProfile.firstName = userProfile.firstName
                dbUserProfile.gender = userProfile.gender?.rawValue
                dbUserProfile.goalWater = userProfile.goalWater ?? 0
                dbUserProfile.goalWeight = userProfile.goalWeight ?? 0
                dbUserProfile.goalWeightTimeLine = userProfile.goalWeightTimeLine
                dbUserProfile.height = userProfile.height ?? 0
                dbUserProfile.heightUnits = userProfile.heightUnits.rawValue
                dbUserProfile.lastName = userProfile.lastName
                dbUserProfile.mealPlan = userProfile.mealPlan?.toJsonString()
                dbUserProfile.proteinPercent = userProfile.proteinPercent.toInt16()
                dbUserProfile.recommendedCalories = userProfile.recommendedCalories.toInt16()
                dbUserProfile.reminderSettings = userProfile.reminderSettings?.toJsonString()
                dbUserProfile.units = userProfile.units.rawValue
                dbUserProfile.waterUnit = userProfile.waterUnit?.rawValue
                dbUserProfile.weight = userProfile.weight ?? 0
                
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
    
    //MARK: - Fetch User records
    func fetchUserProfile(completion: @escaping ((UserProfileModel?, Error?) -> Void)) {
        
        let mainContext = self.getMainContext()
        
        mainContext.perform {
            
            do {
                
                let fetchRequest: NSFetchRequest<TblUserProfile> = TblUserProfile.fetchRequest()
                fetchRequest.fetchLimit = 1
                
                let userProfileResult = try mainContext.fetch(fetchRequest)
                
                if let firstRecord = userProfileResult.first {
                    
                    let userProfileModel: UserProfileModel = UserProfileModel(coreModel: firstRecord)
                    
                    mainContext.saveChanges()
                    
                    completion(userProfileModel, nil)
                }
                else {
                    mainContext.saveChanges()
                    completion(nil, nil)
                }
                
                
                
            } catch let error {
                
                passioLog(message: "Failed to fetch User Profile records: \(error)")
                
                mainContext.saveChanges()
                completion(nil, error)
            }
        }
        
    }
    
}
