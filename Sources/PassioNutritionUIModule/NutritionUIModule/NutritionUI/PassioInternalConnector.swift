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

public protocol PassioConnector: AnyObject {

    // UserProfile
    func updateUserProfile(userProfile: UserProfileModel)
    func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void)

    // Records
    func updateRecord(foodRecord: FoodRecordV3, isNew: Bool)
    func deleteRecord(foodRecord: FoodRecordV3)
    func fetchDayRecords(date: Date, completion: @escaping ([FoodRecordV3]) -> Void)
    func fetchMealLogsJson(daysBack: Int) -> String

    // User Foods
    func updateUserFood(record: FoodRecordV3, isNew: Bool)
    func deleteUserFood(record: FoodRecordV3)
    func fetchUserFoods(barcode: String, completion: @escaping ([FoodRecordV3]) -> Void)
    func fetchAllUserFoods(completion: @escaping ([FoodRecordV3]) -> Void)
    func deleteAllUserFood()

    // User Food Image
    func updateUserFoodImage(with id: String, image: UIImage)
    func deleteUserFoodImage(with id: String)
    func fetchUserFoodImage(with id: String, completion: @escaping (UIImage?) -> Void)

    // Favorites
    func updateFavorite(foodRecord: FoodRecordV3)
    func deleteFavorite(foodRecord: FoodRecordV3)
    func fetchFavorites(completion: @escaping ([FoodRecordV3]) -> Void)

    // Recipes
    func updateRecipe(record: FoodRecordV3)
    func deleteRecipe(record: FoodRecordV3)
    func fetchRecipes(completion: @escaping ([FoodRecordV3]) -> Void)

    // Photos
    var passioKeyForSDK: String { get }
    var offsetFoodEditor: CGFloat { get }
}

public class PassioInternalConnector {
    // MARK: Shared Object
    public class var shared: PassioInternalConnector {
        if Static.instance == nil {
            Static.instance = PassioInternalConnector()
        }
        return Static.instance!
    }
    private init() {}

    weak var passioExternalConnector: PassioConnector?

    var dateForLogging: Date?
    var mealLabel: MealLabel?
    var cacheFavorites: [FoodRecordV3]?
    var isInNavController = true

    public var passioKeyForSDK: String {
        passioExternalConnector?.passioKeyForSDK ?? "no key"
    }

    public var bundleForModule: Bundle {
        Bundle.module
    }

    public var offsetFoodEditor: CGFloat {
        passioExternalConnector?.offsetFoodEditor ?? 0
    }

    public func shutDown() {
        PassioNutritionAI.shared.shutDownPassioSDK()
        passioExternalConnector = nil
        Static.instance = nil
    }

    private struct Static {
        fileprivate static var instance: PassioInternalConnector?
    }

    public func startPassioAppModule(passioExternalConnector: PassioConnector,
                                     presentingViewController: UIViewController,
                                     withViewController: UIViewController,
                                     passioConfiguration: PassioConfiguration) {

        self.passioExternalConnector = passioExternalConnector
        if PassioNutritionAI.shared.status.mode == .isReadyForDetection {
            startModule(presentingViewController: presentingViewController,
                        viewController: withViewController)
        } else if PassioNutritionAI.shared.status.mode == .notReady {
            PassioNutritionAI.shared.configure(passioConfiguration: passioConfiguration) { (_) in
                DispatchQueue.main.async {
                    self.startModule(presentingViewController: presentingViewController,
                                     viewController: withViewController)
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

// MARK: - PassioConnector Delegate
extension PassioInternalConnector: PassioConnector {

    // MARK: UserProfile
    public func updateUserProfile(userProfile: UserProfileModel) {
        passioExternalConnector?.updateUserProfile(userProfile: userProfile)
    }

    public func fetchUserProfile(completion: @escaping (UserProfileModel?) -> Void) {
        guard let connector = passioExternalConnector else {
            completion(UserProfileModel())
            return
        }
        connector.fetchUserProfile { (userProfile) in
            completion(userProfile)
        }
    }

    // MARK: FoodRecordV3
    public func updateRecord(foodRecord: FoodRecordV3, isNew: Bool) {
        guard let connector = passioExternalConnector else { return }
        connector.updateRecord(foodRecord: foodRecord, isNew: isNew)
    }

    public func deleteRecord(foodRecord: FoodRecordV3) {
        guard let connector = passioExternalConnector else { return }
        connector.deleteRecord(foodRecord: foodRecord)
    }

    public func fetchDayRecords(date: Date, completion: @escaping ([FoodRecordV3]) -> Void) {
        guard let connector = passioExternalConnector else {
            completion([])
            return
        }
        connector.fetchDayRecords(date: date) { (foodRecords) in
            completion(foodRecords)
        }
    }
    
    public func fetchMealLogsJson(daysBack: Int) -> String {
        let toDate = Date()
        let fromDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: toDate) ?? Date()

        var dayLogs = [DayLog]()
        PassioInternalConnector.shared.fetchDayLogRecursive(fromDate: fromDate,
                                                            toDate: toDate) { dayLog in
            dayLogs.append(contentsOf: dayLog)
        }
        let json = dayLogs.generateDataRequestJson()
        return json
    }

    // MARK: UserFood
    public func updateUserFood(record: FoodRecordV3, isNew: Bool) {
        guard let connector = passioExternalConnector else { return }
        connector.updateUserFood(record: record, isNew: isNew)
    }

    public func deleteUserFood(record: FoodRecordV3) {
        guard let connector = passioExternalConnector else { return }
        connector.deleteUserFood(record: record)
    }

    public func deleteAllUserFood() {
        guard let connector = passioExternalConnector else { return }
        connector.deleteAllUserFood()
    }

    public func fetchUserFoods(barcode: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        guard let connector = passioExternalConnector else {
            completion([])
            return
        }
        connector.fetchUserFoods(barcode: barcode) { barcodeFood in
            completion(barcodeFood)
        }
    }

    public func fetchAllUserFoods(completion: @escaping ([FoodRecordV3]) -> Void) {
        guard let connector = passioExternalConnector else {
            completion([])
            return
        }
        connector.fetchAllUserFoods { userFoods in
            completion(userFoods)
        }
    }

    public func updateUserFoodImage(with id: String, image: UIImage) {
        guard let connector = passioExternalConnector else { return }
        connector.updateUserFoodImage(with: id, image: image)
    }

    public func deleteUserFoodImage(with id: String) {
        guard let connector = passioExternalConnector else { return }
        connector.deleteUserFoodImage(with: id)
    }

    public func fetchUserFoodImage(with id: String, completion: @escaping (UIImage?) -> Void) {
        guard let connector = passioExternalConnector else {
            completion(nil)
            return
        }
        connector.fetchUserFoodImage(with: id) { foodImage in
            completion(foodImage)
        }
    }

    // MARK: Favorite
    public func updateFavorite(foodRecord: FoodRecordV3) {
        guard let connector = passioExternalConnector else { return }
        connector.updateFavorite(foodRecord: foodRecord)
        cacheFavorites = cacheFavorites?.filter { $0.uuid != foodRecord.uuid }
        cacheFavorites?.append(foodRecord)
    }

    public func deleteFavorite(foodRecord: FoodRecordV3) {
        guard let connector = passioExternalConnector else { return }
        connector.deleteFavorite(foodRecord: foodRecord)
        cacheFavorites = cacheFavorites?.filter { $0.uuid != foodRecord.uuid }
    }

    public func fetchFavorites(completion: @escaping ([FoodRecordV3]) -> Void) {
        guard let connector = passioExternalConnector else {
            completion([])
            return
        }
        if let favorites = cacheFavorites {
            completion(favorites)
        } else {
            connector.fetchFavorites { (favorites) in
                self.cacheFavorites = favorites
                completion(favorites)
            }
        }
    }

    public func updateRecipe(record: FoodRecordV3) {
        guard let connector = passioExternalConnector else { return }
        connector.updateRecipe(record: record)
    }

    public func deleteRecipe(record: FoodRecordV3) {
        guard let connector = passioExternalConnector else { return }
        connector.deleteRecipe(record: record)
    }

    public func fetchRecipes(completion: @escaping ([FoodRecordV3]) -> Void) {
        guard let connector = passioExternalConnector else {
            completion([])
            return
        }
        connector.fetchRecipes { recipes in
            completion(recipes)
        }
    }
}

// MARK: - Helper
extension PassioInternalConnector {

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

    func fetchDayLogRecursive(fromDate: Date,
                              toDate: Date,
                              currentLogs: [DayLog] = [],
                              completion: @escaping ([DayLog]) -> Void) {

        guard fromDate <= toDate else {
            completion(currentLogs)
            return
        }

        fetchDayRecords(date: fromDate) { (foodRecords) in
            let daylog = DayLog(date: fromDate, records: foodRecords)
            var updatedLogs = currentLogs
            updatedLogs.append(daylog)

            // Recursive call with next day
            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!
            self.fetchDayLogRecursive(fromDate: nextDate,
                                      toDate: toDate,
                                      currentLogs: updatedLogs,
                                      completion: completion)
        }
    }

    func fetchAllUserFoodsName(completion: @escaping ([String]) -> Void) {
        fetchAllUserFoods(completion: { records in
            completion(records.map { $0.name })
        })
    }

    func fetchAllUserFoodsMatching(name: String, completion: @escaping ([FoodRecordV3]) -> Void) {
        fetchAllUserFoods(completion: { records in
            completion(records.filter { $0.name.lowercased() == name.lowercased() })
        })
    }
}
