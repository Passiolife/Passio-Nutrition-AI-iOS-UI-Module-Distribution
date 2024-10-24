//
//  DataMigrationUtil.swift
//
//
//  Created by Mindinventory on 23/10/24.
//

import Foundation

internal class DataMigrationUtil {
    
    private init() {}
    
    private static var dataMigrationUtil: DataMigrationUtil = {
        let dataMigrationUtil = DataMigrationUtil()
        return dataMigrationUtil
    }()
    
    static var shared: DataMigrationUtil = {
        return dataMigrationUtil
    }()
    
    
    fileprivate func performLogMigration(completion: @escaping ((Bool, Error?) -> Void)) {
        
        do {
            
            var fileURLs: [URL] = []
            let fileManager = FileManager.default
            
            // Get the Application Support directory
            if let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                // Get the contents of the Application Support directory
                let contents = try fileManager.contentsOfDirectory(at: appSupportDirectory, includingPropertiesForKeys: nil)
                
                // Filter the contents for directories starting with "date"
                for url in contents {
                    if url.lastPathComponent.hasPrefix("date") && url.hasDirectoryPath {
                        // If it is a directory, fetch its contents
                         let filesInDateDirectory = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                        
                        // Filter for JSON files
                        let jsonFiles = filesInDateDirectory.filter { $0.pathExtension == "json" }
                        
                        // If there are JSON files, add the directory URL to the fileURLs array
                        if !jsonFiles.isEmpty {
                            fileURLs.append(url)
                        }
                    }
                }
                
                var arrFoodRecords: [FoodRecordV3] = []
                fileURLs.forEach { url in
                    let recrod: [FoodRecordV3] = fileManager.getRecords(for: url)
                    if !recrod.isEmpty {
                        print("Testing: \(recrod.map({$0.name}))")
                        arrFoodRecords.append(contentsOf: recrod.flatMap({$0}))
                    }
                }
                
                if arrFoodRecords.count > 0 {
                    print("arrFoodRecords Food Logs :: \(arrFoodRecords.count)")
                    // Insert/Upate All Food Logs Records
                    FoodRecordOperations.shared.insertOrUpdateMultipleFoodRecords(foodRecords: arrFoodRecords.reversed()) { resultState, error in

                        if error != nil {
                            print("insertOrUpdateMultipleFoodRecords ERROR:: \(error)")
                            completion(false, error)
                        }
                        else {
                            print("Alll FoodRecord Log Records are \(resultState ? "Successfully" : "Failed to") perform Inserted/Updated Migration Operation")
                            completion(resultState, nil)
                        }
                    }
                }
                else {
                    completion(true, nil)
                }
            }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
            completion(false, error)
        }

    }
    
    fileprivate func performFavouriteFoodMigration(completion: @escaping ((Bool, Error?) -> Void)) {
        
        let arrFavouriteFoodRecords: [FoodRecordV3] = fetchJSONFiles(from: "passiofavorites")
        
        if arrFavouriteFoodRecords.count > 0 {
            // Insert/Upate All Favourite Food Records
            FavouriteFoodRecordOperations.shared.insertOrUpdateFavouriteFoodMultipleRecords(foodRecords: arrFavouriteFoodRecords.reversed()) { resultState, error in
                
                if error != nil {
                    print("insertOrUpdateMultipleFoodRecords ERROR:: \(error)")
                    completion(false, error)
                }
                else {
                    print("All Favourite Food Records are \(resultState ? "Successfully" : "Failed to") perform Inserted/Updated Migration Operation")
                    completion(resultState, nil)
                }
            }
        }
        else {
            completion(true, nil)
        }
    }
    
    
    fileprivate func performCustomFoodMigration(completion: @escaping ((Bool, Error?) -> Void)) {
        
        let arrCustomFoodRecords: [FoodRecordV3] = fetchJSONFiles(from: "passioUserFoods")
        
        if arrCustomFoodRecords.count > 0 {
            // Insert/Upate All Custom Food Records
            CustomFoodRecordOperations.shared.insertOrUpdateCustomFoodMultipleRecords(foodRecords: arrCustomFoodRecords.reversed()) { resultState, error in

                if error != nil {
                    print("insertOrUpdateMultipleFoodRecords ERROR:: \(error)")
                    completion(false, error)
                }
                else {
                    print("All Custom Food Records are \(resultState ? "Successfully" : "Failed to") perform Inserted/Updated Migration Operation")
                    completion(resultState, nil)
                }
            }
        }
        else {
            completion(true, nil)
        }
    }
    
    fileprivate func performCustomFoodRecipeMigration(completion: @escaping ((Bool, Error?) -> Void)) {
        
        let arrRecipesFoodRecords: [FoodRecordV3] = fetchJSONFiles(from: "passioRecipes")
        
        if arrRecipesFoodRecords.count > 0 {
            // Insert/Upate All Custom Food Records
            FoodRecipeRecordOperations.shared.insertOrUpdateFoodRecipeRecords(foodRecords: arrRecipesFoodRecords.reversed()) { resultState, error in

                if error != nil {
                    print("insertOrUpdateMultipleFoodRecords ERROR:: \(error)")
                    completion(false, error)
                }
                else {
                    print("All Recipe Food Records are \(resultState ? "Successfully" : "Failed to") perform Inserted/Updated Migration Operation")
                    completion(resultState, nil)
                }
            }
        }
        else {
            completion(true, nil)
        }
    }
    
    fileprivate func performUserProfileMigration(completion: @escaping ((Bool, Error?) -> Void)) {
        
        let arrUserProfileRecords: [UserProfileModel] = fetchJSONFiles(from: "userProfile")
        
        if arrUserProfileRecords.count > 0,
           let firstUserRecord = arrUserProfileRecords.first {
            // Insert/Upate All Custom Food Records
            UserProfileOperation.shared.insertOrUpdateUserProfile(userProfile: firstUserRecord) { resultState, error in

                if error != nil {
                    print("insertOrUpdateUserProfile ERROR:: \(error)")
                    completion(false, error)
                }
                else {
                    print("UserProfile Record is \(resultState ? "Successfully" : "Failed to") perform Inserted Migration Operation")
                    completion(resultState, nil)
                }
            }
        }
        else {
            completion(true, nil)
        }
    }
    
    
    func migrateAllJsonContentToDB(completion: @escaping ((Bool) -> Void)) {
        
        let mingrationStatus = (UserDefaults.standard.value(forKey: "migrate") as? Bool) ?? false
        
        if mingrationStatus == false {
         
            let migrationDispatchGroup = DispatchGroup()
            
            //👉 1️⃣ Food Log Records Migration
            var foodLogRecordMigration: Bool = false
            
            migrationDispatchGroup.enter()
            performLogMigration { status, error in
                
                foodLogRecordMigration = status
                
                if error != nil {
                    print("FoodRecordV3 migration Error:: \(error)")
                }
                migrationDispatchGroup.leave()
            }
            
            //👉 2️⃣ Favourite Food Records Migration
            var foodFavouriteFoodRecordMigration: Bool = false
            
            migrationDispatchGroup.enter()
            performFavouriteFoodMigration { status, error in
                
                foodFavouriteFoodRecordMigration = status
                
                if error != nil {
                    print("Favourite Food Records migration Error:: \(error)")
                }
                migrationDispatchGroup.leave()
            }
            
            //👉 3️⃣ User Custom Food Records Migration
            var foodCustomFoodRecordMigration: Bool = false
            
            migrationDispatchGroup.enter()
            performCustomFoodMigration { status, error in
                
                foodCustomFoodRecordMigration = status
                
                if error != nil {
                    print("Custom Food Records migration Error:: \(error)")
                }
                migrationDispatchGroup.leave()
            }
            
            
            //👉 4️⃣ User Food Recipe Records Migration
            var foodCustomRecipeFoodRecordMigration: Bool = false
            
            migrationDispatchGroup.enter()
            performCustomFoodRecipeMigration { status, error in
                
                foodCustomRecipeFoodRecordMigration = status
                
                if error != nil {
                    print("Custom Food Records migration Error:: \(error)")
                }
                migrationDispatchGroup.leave()
            }
            
            //👉 5️⃣ User Record Migration
            var userModuleRecordMigration: Bool = false
            
            migrationDispatchGroup.enter()
            performUserProfileMigration { status, error in
                
                userModuleRecordMigration = status
                
                if error != nil {
                    print("Custom Food Records migration Error:: \(error)")
                }
                migrationDispatchGroup.leave()
            }
            
            // =============== FINAL RESULT  ===============
            let dispatchWorkItem: DispatchWorkItem = DispatchWorkItem {
                print("****** ****** ****** ****** ******")
                print("****** All Migration Status ******")
                print("****** ****** ****** ****** ******")
                
                print("FoodRecordV3 migration Status :: \(foodLogRecordMigration ? "✅" : "❎")")
                print("Favorite Food migration Status :: \(foodFavouriteFoodRecordMigration ? "✅" : "❎")")
                print("Custom Food migration Status :: \(foodCustomFoodRecordMigration ? "✅" : "❎")")
                print("User Food Recipe migration Status :: \(foodCustomRecipeFoodRecordMigration ? "✅" : "❎")")
                print("User Record migration Status :: \(userModuleRecordMigration ? "✅" : "❎")")
                
                if foodLogRecordMigration && foodFavouriteFoodRecordMigration && foodCustomFoodRecordMigration && foodCustomRecipeFoodRecordMigration && userModuleRecordMigration {
                    UserDefaults.standard.set(true, forKey: "migrate")
                    UserDefaults.standard.synchronize()
                    completion(true)
                }
                else {
                    UserDefaults.standard.set(false, forKey: "migrate")
                    UserDefaults.standard.synchronize()
                    completion(false)
                }
            }
            
            migrationDispatchGroup.notify(queue: .main, work: dispatchWorkItem)
            
        }
        else {
            completion(true)
        }
        
    }
    
}

extension DataMigrationUtil {
    
    fileprivate func fetchJSONFiles<T: Codable>(from directoryName: String) -> [T] {
        
        // Get the application support directory
        let fileManager = FileManager.default
        guard let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            print("Could not find application support directory")
            return []
        }
        
        // Construct the full path for the specified directory
        let directoryURL = appSupportDirectory.appendingPathComponent(directoryName)

        do {
            var fileURLs: [URL] = []
            
            // Fetch the contents of the directory
            let contents = try fileManager.contentsOfDirectory(at: appSupportDirectory, includingPropertiesForKeys: nil)
            
            if let url = contents.filter({$0.lastPathComponent.caseInsensitiveCompare(directoryName) == .orderedSame}).first {
                // Filter the contents for directories starting with "matched directory"
                if url.hasDirectoryPath {
                    // If it is a directory, fetch its contents
                     let filesInDateDirectory = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                    
                    // Filter for JSON files
                    let jsonFiles = filesInDateDirectory.filter { $0.pathExtension == "json" }
                    
                    // If there are JSON files, add the directory URL to the fileURLs array
                    if !jsonFiles.isEmpty {
                        fileURLs.append(url)
                    }
                }
            }
            
            var arrFoodRecords: [T] = []
            
            print("Other Food Records(Custom Foods, Food Recipe, Favourite Foods, User Profile) fileURLs:: \(fileURLs.count)")
            
            fileURLs.forEach { url in
                let recrod: [T] = fileManager.getRecords(for: directoryURL)
                if !recrod.isEmpty {
                    arrFoodRecords.append(contentsOf: recrod.flatMap({$0}))
                }
            }
            
            return arrFoodRecords
            
        } catch {
            print("Error fetching Other Food Records(Custom Foods, Food Recipe, Favourite Foods) files: \(error.localizedDescription)")
            return []
        }
    }
}
