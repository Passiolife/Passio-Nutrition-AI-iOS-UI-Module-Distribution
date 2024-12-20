//
//  File.swift
//  
//
//  Created by Pratik on 10/10/24.
//

import Foundation
import UIKit

class JSONPassioConnector {
    static let shared = JSONPassioConnector()
    var cacheFavorites: [FoodRecordV3]?
    private let fileManager = FileManager.default
}

extension JSONPassioConnector: PassioConnector {
    
    // MARK: User profile

    func updateUserProfile(userProfile: UserProfileModel) {
        if let urlForUserProfileModel {
            _ = fileManager.updateRecordLocally(url: urlForUserProfileModel, record: userProfile)
        }
    }
    
    func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void) {
        completion(locallyGetUserProfileModel())
    }
    
    // MARK: Records

    func updateRecord(foodRecord: FoodRecordV3) {
        if let url = urlForSaving(record: foodRecord) {
            _ = fileManager.updateRecordLocally(url: url, record: foodRecord)
        }
    }
    
    func deleteRecord(foodRecord: FoodRecordV3) {
        if let url = urlForSaving(record: foodRecord) {
            fileManager.deleteRecordLocally(url: url)
        }
    }
    
    func fetchDayRecords(date: Date, completion: @escaping ([FoodRecordV3]) -> Void) {
        if let urlForDate = urlForSavingFiles(date: date) {
            completion(fileManager.getRecords(for: urlForDate))
        } else {
            completion([])
        }
    }
    
    // MARK: User foods
    
    func updateUserFood(record: FoodRecordV3) {
        if let url = urlForSaving(userFoods: record) {
            _ = fileManager.updateRecordLocally(url: url, record: record)
        }
    }
    
    func deleteUserFood(record: FoodRecordV3) {
        if let url = urlForSaving(userFoods: record) {
            fileManager.deleteRecordLocally(url: url)
        }
    }
    
    func fetchUserFoods(barcode: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        if let url = urlForUserFoodsDirectory {
            completion(fileManager.getRecords(for: url).filter { $0.barcode == barcode })
        } else {
            completion([])
        }
    }
    
    func fetchUserFoods(refCode: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        if let url = urlForUserFoodsDirectory {
            completion(fileManager.getRecords(for: url).filter { $0.refCode == refCode })
        } else {
            completion([])
        }
    }
    
    func fetchAllUserFoods(completion: @escaping ([FoodRecordV3]) -> Void) {
        if let url = urlForUserFoodsDirectory {
            completion(fileManager.getRecords(for: url))
        } else {
            completion([])
        }
    }
    
    // Newlt added
    func fetchAllUserFoodsMatching(name: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        fetchAllUserFoods(completion: { records in
            completion(records.filter { $0.name.lowercased() == name.lowercased() })
        })
    }
    
    // MARK: User food image

    func updateUserFoodImage(with id: String, image: UIImage) {
        if let url = urlForSaving(imageId: id) {
            _ = locallyUpdateUserFood(image: image, url: url)
        }
    }
    
    func deleteUserFoodImage(with id: String) {
        if let url = urlForSaving(imageId: id) {
            fileManager.deleteRecordLocally(url: url)
        }
    }
    
    func fetchUserFoodImage(with id: String, completion: @escaping (UIImage?) -> Void) {
        if let url = urlForUserFoodImagesDirectory {
            completion(getUserFoodImageFor(id: id, url: url))
        } else {
            completion(nil)
        }
    }
    
    // MARK: Favorites

    func updateFavorite(foodRecord: FoodRecordV3) {
        if let url = urlForSaving(favorite: foodRecord) {
            _ = fileManager.updateRecordLocally(url: url, record: foodRecord)
        }
        cacheFavorites = cacheFavorites?.filter { $0.uuid != foodRecord.uuid }
        cacheFavorites?.append(foodRecord)
    }
    
    func deleteFavorite(foodRecord: FoodRecordV3) {
        if let url = urlForSaving(favorite: foodRecord) {
            fileManager.deleteRecordLocally(url: url)
        }
        cacheFavorites = cacheFavorites?.filter { $0.uuid != foodRecord.uuid }
    }
    
    func fetchFavorites(completion: @escaping ([FoodRecordV3]) -> Void) {
        if let favorites = cacheFavorites {
            completion(favorites)
        } else {
            self.fetchFavoritesFromFile { (favorites) in
                self.cacheFavorites = favorites
                completion(favorites)
            }
        }
    }
    
    // MARK: Recipes

    func updateRecipe(record: FoodRecordV3) {
        if let url = urlForSaving(recipe: record) {
            _ = fileManager.updateRecordLocally(url: url, record: record)
        }
    }
    
    func deleteRecipe(record: FoodRecordV3) {
        if let url = urlForSaving(recipe: record) {
            fileManager.deleteRecordLocally(url: url)
        }
    }
    
    func fetchRecipes(completion: @escaping ([FoodRecordV3]) -> Void) {
        if let url = urlForRecipesDirectory {
            completion(fileManager.getRecords(for: url))
        } else {
            completion([])
        }
    }
    
    // MARK: Newly Added

    func fetchDayLogFor(fromDate: Date,
                        toDate: Date,
                        completion: @escaping ([DayLog]) -> Void) {
        var dayLogs = [DayLog]()
        for time in stride(from: fromDate.timeIntervalSince1970,
                           through: toDate.timeIntervalSince1970,
                           by: 86400) {
            let currentDate = Date(timeIntervalSince1970: time)
            fetchDayRecords(date: currentDate) { (foodRecords) in
                let daylog = DayLog(date: currentDate, records: foodRecords)
                dayLogs.append(daylog)
                if time > toDate.timeIntervalSince1970 - 86400 { // last element
                    completion(dayLogs)
                }
            }
        }
    }
    
    // Weight Tracking
    func updateWeightRecord(weightRecord: WeightTracking, completion: @escaping (Bool) -> Void) {}
    func fetchWeightRecords(startDate: Date, endDate: Date, completion: @escaping ([WeightTracking]) -> Void) {}
    func fetchLatestWeightRecord(completion: @escaping (WeightTracking?) -> Void) {}
    func deleteWeightRecord(weightRecord: WeightTracking, completion: @escaping (Bool) -> Void) {}
    
    // Water Tracking
    func updateWaterRecord(waterRecord: WaterTracking, completion: @escaping ((Bool) -> Void)) {}
    func fetchWaterRecords(startDate: Date, endDate: Date, completion: @escaping ([WaterTracking]) -> Void) {}
    func deleteWaterRecord(waterRecord: WaterTracking, completion: @escaping (Bool) -> Void) {}
}

// MARK: Helper

extension JSONPassioConnector {
    
    private var urlForFavoritesDirectory: URL? {
        fileManager.createDirectory(with: "passiofavorites")
    }
    
    private var urlForUserFoodsDirectory: URL? {
        fileManager.createDirectory(with: "passioUserFoods")
    }
    
    private var urlForUserFoodImagesDirectory: URL? {
        fileManager.createDirectory(with: "passioUserFoodImages")
    }
    
    private var urlForRecipesDirectory: URL? {
        fileManager.createDirectory(with: "passioRecipes")
    }
    
    private var urlForUserProfileModel: URL? {
        guard let appSupportDir = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil, create: true
        ) else {
            return nil
        }
        let dirURL = appSupportDir.appendingPathComponent("userProfile") // appendingPathComponent("userProfileModel.json")
        do {
            try fileManager.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("can't create directory at \(dirURL)")
        }
        return dirURL.appendingPathComponent("userProfileModel.json")
    }
    
    private func locallyGetUserProfileModel() -> UserProfileModel {
        let userProfile = UserProfileModel()
        guard let dirURL = urlForUserProfileModel else { return userProfile }
        do {
            let decoder = JSONDecoder()
            if let data = try? Data(contentsOf: dirURL),
               let profile = try? decoder.decode(UserProfileModel.self, from: data) {
                return profile
            }
        }
        return userProfile
    }
    
    private func locallyUpdateUserFood(image: UIImage, url: URL) -> Bool {
        do {
            let encodedImageData = image.pngData()
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(atPath: url.path)
            }
            do {
                try encodedImageData?.write(to: url)
                return true
            } catch {
                return false
            }
        } catch {
            return false
        }
    }
    
    private func getUserFoodImageFor(id: String, url: URL) -> UIImage? {
        guard let dirURL = urlForUserFoodImagesDirectory else { return nil }
        do {
            let imagePath = dirURL.appendingPathComponent("\(id).png", isDirectory: false)
            if let imageData = try? Data(contentsOf: imagePath),
               let foodImage = UIImage(data: imageData) {
                return foodImage
            }
        }
        return nil
    }
    
    private func urlForSaving(record: FoodRecordV3) -> URL? {
        let date = record.createdAt
        guard let urlForFile = urlForSavingFiles(date: date) else {
            return nil
        }
        let finalURL = urlForFile.appendingPathComponent(record.uuid.replacingOccurrences(of: "-", with: "") + ".json")
        return finalURL
    }
    
    private func urlForSavingFiles(date: Date) -> URL? {
        guard let appSupportDir = try? fileManager.url(for: .applicationSupportDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let directory = dateFormatter.string(from: date)
        let dirURL = appSupportDir.appendingPathComponent("date" + directory, isDirectory: true)
        do {
            try fileManager.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("can't create directory at \(dirURL)")
        }
        return dirURL
    }
    
    private func urlForSavingTrackingFiles(date: Date) -> URL? {
        guard let appSupportDir = try? fileManager.url(for: .applicationSupportDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let directory = dateFormatter.string(from: date)
        let dirURL = appSupportDir.appendingPathComponent("weightTrackingDate" + directory, isDirectory: true)
        do {
            try fileManager.createDirectory(atPath: dirURL.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("can't create directory at \(dirURL)")
        }
        return dirURL
    }
    
    private func urlForSaving(userFoods: FoodRecordV3) -> URL? {
        createFile(for: urlForUserFoodsDirectory, at: userFoods.uuid)
    }
    
    private func urlForSaving(imageId: String) -> URL? {
        createFile(for: urlForUserFoodImagesDirectory, at: "\(imageId)" + ".png", useJSON: false)
    }
    
    private func urlForSaving(favorite: FoodRecordV3) -> URL? {
        createFile(for: urlForFavoritesDirectory, at: favorite.uuid)
    }
    
    private func urlForSaving(recipe: FoodRecordV3) -> URL? {
        createFile(for: urlForRecipesDirectory, at: recipe.uuid)
    }
    
    private func createFile(for url: URL?, at path: String, useJSON: Bool = true) -> URL? {
        guard let dirURL = url else { return nil }
        let path = useJSON ? path.replacingOccurrences(of: "-", with: "") + ".json" : path
        let finalURL = dirURL.appendingPathComponent(path)
        return finalURL
    }
    
    func fetchFavoritesFromFile(completion: @escaping ([FoodRecordV3]) -> Void) {
        if let url = urlForFavoritesDirectory {
            completion(fileManager.getRecords(for: url))
        } else {
            completion([])
        }
    }
    
    private func urlForWeightTrackingeModel(weightTracking: WeightTracking) -> URL? {
        let date = weightTracking.dateTime
        
        guard let urlForFile = urlForSavingTrackingFiles(date: date) else {
            return nil
        }
        let finalURL = urlForFile.appendingPathComponent(weightTracking.id.replacingOccurrences(of: "-", with: "") + ".json")
        return finalURL
    }
}
