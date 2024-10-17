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
    
    
    func updateUserProfile(userProfile: UserProfileModel, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let context = self.getMainContext()
        
        context.perform {
            
            let dbUserProfile = TblUserProfile(context: context)
            
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
            dbUserProfile.heightUnits = userProfile.heightUnits.toJsonString()
            dbUserProfile.lastName = userProfile.lastName
            dbUserProfile.mealPlan = userProfile.mealPlan?.toJsonString()
            dbUserProfile.proteinPercent = userProfile.proteinPercent.toInt16()
            dbUserProfile.recommendedCalories = userProfile.recommendedCalories.toInt16()
            dbUserProfile.reminderSettings = userProfile.reminderSettings?.toJsonString()
            dbUserProfile.units = userProfile.units.rawValue
            dbUserProfile.waterUnit = userProfile.waterUnit?.rawValue
            dbUserProfile.weight = userProfile.weight ?? 0
            
            context.saveChanges()
            
            completion(true, nil)
        }
    }
    
}
