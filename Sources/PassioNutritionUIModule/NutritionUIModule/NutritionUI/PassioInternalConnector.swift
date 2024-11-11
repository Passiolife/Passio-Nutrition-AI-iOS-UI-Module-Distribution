//
//  PassioInternalConnector.swift
//  BaseApp
//
//  Created by zvika on 1/23/20.
//  Copyright © 2023 Passio Inc. All rights reserved.//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

public class PassioInternalConnector 
{
    // MARK: Shared Object
    public class var shared: PassioInternalConnector {
        if Static.instance == nil {
            Static.instance = PassioInternalConnector()
        }
        return Static.instance!
    }
    private init() {}

    var connector: PassioConnector = PassioFoodDataConnector.shared

    var dateForLogging: Date?
    var mealLabel: MealLabel?
    var cacheFavorites: [FoodRecordV3]?
    var isInNavController = true

    public var bundleForModule: Bundle {
        Bundle.module
    }

    public func shutDown() {
        PassioNutritionAI.shared.shutDownPassioSDK()
        Static.instance = nil
    }

    private struct Static {
        fileprivate static var instance: PassioInternalConnector?
    }

    public func startPassioAppModule(connector: PassioConnector,
                                     presentingViewController: UIViewController,
                                     withViewController: UIViewController,
                                     passioConfiguration: PassioConfiguration) {
        self.connector = connector
        UIModuleEntryPoint(presentingViewController: presentingViewController,
                           withViewController: withViewController,
                           passioConfiguration: passioConfiguration)
    }
    
    public func startPassioAppModule(presentingViewController: UIViewController,
                                     withViewController: UIViewController,
                                     passioConfiguration: PassioConfiguration) {
        UIModuleEntryPoint(presentingViewController: presentingViewController,
                           withViewController: withViewController,
                           passioConfiguration: passioConfiguration)
    }
    
    private func UIModuleEntryPoint(presentingViewController: UIViewController,
                                    withViewController: UIViewController,
                                    passioConfiguration: PassioConfiguration) {

        DataMigrationUtil.shared.migrateAllJsonContentToDB { resultStatus in
            
            if PassioNutritionAI.shared.status.mode == .isReadyForDetection {
                self.startModule(presentingViewController: presentingViewController, viewController: withViewController)
            }
            else if PassioNutritionAI.shared.status.mode == .notReady {
                PassioNutritionAI.shared.configure(passioConfiguration: passioConfiguration) { (_) in
                    DispatchQueue.main.async {
                        self.startModule(presentingViewController: presentingViewController,
                                         viewController: withViewController)
                    }
                }
            }
        }
    }

    private func startModule(dismisswithAnimation: Bool = false,
                             presentingViewController: UIViewController,
                             viewController: UIViewController) {

        if let navController = presentingViewController.navigationController {
            navController.pushViewController(viewController, animated: false)
        } else {
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            presentingViewController.present(viewController, animated: false)
        }
        self.isInNavController = true
    }

    deinit {
        print("deinit PassioInternalConnector")
    }
}

extension PassioInternalConnector {

    // MARK: User profile
    
    public func updateUserProfile(userProfile: UserProfileModel) {
        connector.updateUserProfile(userProfile: userProfile)
    }

    public func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void) {
        connector.fetchUserProfile { (userProfile) in
            completion(userProfile)
        }
    }

    // MARK: Records
    
    public func updateRecord(foodRecord: FoodRecordV3) {
        connector.updateRecord(foodRecord: foodRecord)
    }

    public func deleteRecord(foodRecord: FoodRecordV3) {
        connector.deleteRecord(foodRecord: foodRecord)
    }

    public func fetchDayRecords(date: Date, completion: @escaping ([FoodRecordV3]) -> Void) {
        connector.fetchDayRecords(date: date) { (foodRecords) in
            completion(foodRecords)
        }
    }
    
    public func fetchMealLogsJson(daysBack: Int) -> String {
        return connector.fetchMealLogsJson(daysBack: daysBack)
    }

    // MARK: User foods
    
    public func updateUserFood(record: FoodRecordV3) {
        connector.updateUserFood(record: record)
    }

    public func deleteUserFood(record: FoodRecordV3) {
        connector.deleteUserFood(record: record)
    }

    public func deleteAllUserFood() {
        connector.deleteAllUserFood()
    }

    public func fetchUserFoods(barcode: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        connector.fetchUserFoods(barcode: barcode) { barcodeFood in
            completion(barcodeFood)
        }
    }

    public func fetchUserFoods(refCode: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        connector.fetchUserFoods(refCode: refCode) { userFood in
            completion(userFood)
        }
    }

    public func fetchAllUserFoods(completion: @escaping ([FoodRecordV3]) -> Void) {
        connector.fetchAllUserFoods { userFoods in
            completion(userFoods)
        }
    }
    
    public func fetchAllUserFoodsMatching(name: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        connector.fetchAllUserFoodsMatching(name: name) { userFoods in
            completion(userFoods)
        }
    }
    
    // MARK: User food image

    public func updateUserFoodImage(with id: String, image: UIImage) {
        connector.updateUserFoodImage(with: id, image: image)
    }

    public func deleteUserFoodImage(with id: String) {
        connector.deleteUserFoodImage(with: id)
    }

    public func fetchUserFoodImage(with id: String, completion: @escaping (UIImage?) -> Void) {
        connector.fetchUserFoodImage(with: id) { foodImage in
            completion(foodImage)
        }
    }

    // MARK: Favorites

    public func updateFavorite(foodRecord: FoodRecordV3) {
        connector.updateFavorite(foodRecord: foodRecord)
    }

    public func deleteFavorite(foodRecord: FoodRecordV3) {
        connector.deleteFavorite(foodRecord: foodRecord)
    }

    public func fetchFavorites(completion: @escaping ([FoodRecordV3]) -> Void) {
        connector.fetchFavorites { favorites in
            completion(favorites)
        }
    }

    // MARK: Recipes

    public func updateRecipe(record: FoodRecordV3) {
        connector.updateRecipe(record: record)
    }

    public func deleteRecipe(record: FoodRecordV3) {
        connector.deleteRecipe(record: record)
    }

    public func fetchRecipes(completion: @escaping ([FoodRecordV3]) -> Void) {
        connector.fetchRecipes { recipes in
            completion(recipes)
        }
    }
    
    // MARK: Day logs - Newly added

    public func fetchDayLogFor(fromDate: Date, toDate: Date, completion: @escaping ([DayLog]) -> Void) {
        connector.fetchDayLogFor(fromDate: fromDate, toDate: toDate) { logs in
            completion(logs)
        }
    }
    
    public func fetchDayLogRecursive(fromDate: Date, toDate: Date, completion: @escaping ([DayLog]) -> Void) {
        connector.fetchDayLogRecursive(fromDate: fromDate, toDate: toDate, currentLogs: []) { logs in
            completion(logs)
        }
    }
    
    // MARK: Weight Tracking - Newly added
    public func insertOrReplaceWeightTrackingRecord(weightTracking: WeightTracking) {
        connector.insertOrReplaceWeightTrackingRecord(weightTracking: weightTracking)
    }
    
    public func fetchWeightTrackingRecord(date: Date, completion: @escaping ([WeightTracking]) -> Void) {
        connector.fetchWeightTrackingRecord(date: date, completion: completion)
    }
    
    public func fetchWeightTrackingRecursive(fromDate: Date, toDate: Date, completion: @escaping ([WeightTracking]) -> Void) {
        connector.fetchWeightTrackingRecursive(fromDate: fromDate, toDate: toDate, currentLogs: [], completion: completion)
    }
    
    public func deleteWeightTrackingRecord(record: WeightTracking) {
        connector.deleteWeightTrackingRecord(record: record)
    }
}

