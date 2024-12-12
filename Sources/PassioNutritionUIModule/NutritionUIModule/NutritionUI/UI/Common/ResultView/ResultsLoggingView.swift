//
//  ResultsLoggingView.swift
//  
//
//  Created by Nikunj Prajapati on 07/06/24.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

protocol ResultsLoggingDelegate: AnyObject {
    func onTryAgainTapped()
    func onLogSelectedTapped()
    func onAddIngredientsTapped(foodRecords: [FoodRecordV3])
    func onSearchManuallyTapped()
}

struct FoodLog {
    var isSelected: Bool
    var foodData: PassioSpeechRecognitionModel
}

class ResultsLoggingView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var searchManuallyStackView: UIStackView!
    @IBOutlet weak var tryAgainButton: UIButton!
    @IBOutlet weak var searchManuallyButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var clearView: UIView!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var resultsDescLabel: UILabel!
    @IBOutlet weak var foodResultsTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var logView: UIView!
    @IBOutlet weak var logSelectedButton: UIButton!
    @IBOutlet weak var logLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var resultViewFor: DetectedFoodResultType = .addLog {
        didSet {
            if resultViewFor == .addIngredient {
                logLabel.text = "Add Ingredient"
            }
        }
    }
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    var recognitionData: [PassioSpeechRecognitionModel]? {
        didSet {
            let uniqueData = recognitionData?.uniqued(on: { $0.advisorFoodInfo.recognisedName })
            foodLogs = uniqueData?.map {
                FoodLog(isSelected: true, foodData: $0)
            } ?? []
        }
    }
    var selectedIndexes: [Int] = []
    var showCancelButton: Bool = false {
        didSet {
            cancelButton.isHidden = !showCancelButton
            tryAgainButton.isHidden = showCancelButton
            searchManuallyStackView.isHidden = showCancelButton
        }
    }

    private var foodLogs: [FoodLog] = [] {
        didSet {
            updateResultUI()
        }
    }

    weak var resultLoggingDelegate: ResultsLoggingDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        foodResultsTableView.estimatedRowHeight = 80.0
        foodResultsTableView.rowHeight = UITableView.automaticDimension
        foodResultsTableView.register(nibName: "VoiceLoggingCell", bundle: .module)
        foodResultsTableView.dataSource = self
        foodResultsTableView.delegate = self
        foodResultsTableView.showsVerticalScrollIndicator = false
        contentView.roundMyCornerWith(radius: 16, upper: true, down: false)
        contentView.dropShadow(radius: 16,
                               offset: CGSize(width: 0, height: -2),
                               color: .black.withAlphaComponent(0.10),
                               shadowRadius: 6,
                               shadowOpacity: 1)

        resultsLabel.font = .inter(type: .bold, size: 18)
        resultsDescLabel.font = .inter(type: .regular, size: 14)
        logLabel.font = .inter(type: .medium, size: 16)
        
        let title = "Clear".toMutableAttributedString
        title.apply(attribute: [.foregroundColor: UIColor.primaryColor,
                                .underlineColor: UIColor.primaryColor,
                                .underlineStyle: NSUnderlineStyle.single.rawValue],
                    subString: "Clear")
        let str = "Not what you’re looking for? Search Manually".toMutableAttributedString
        str.apply(attribute: [.foregroundColor: UIColor.primaryColor,
                              .font: UIFont.inter(type: .bold, size: 14)], subString: "Search Manually")
        searchManuallyButton.setAttributedTitle(str, for: .normal)
        clearButton.setAttributedTitle(title, for: .normal)
        cancelButton.applyBorder(width: 2, color: .primaryColor)
        cancelButton.setTitleColor(.primaryColor, for: .normal)
        logView.backgroundColor = .primaryColor
        tryAgainButton.tintColor = .primaryColor
        tryAgainButton.setTitleColor(.primaryColor, for: .normal)
        tryAgainButton.applyBorder(width: 2, color: .primaryColor)
        
        updateLogUI(isLogging: false)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        foodResultsTableView.sizeToFit()
    }

    @IBAction func onClear(_ sender: UIButton) {
        foodLogs.indices.forEach { index in
            foodLogs[index].isSelected = false
        }
        foodResultsTableView.reloadWithAnimations(withDuration: 0.12)
    }

    @IBAction func onTryAgain(_ sender: UIButton) {
        resultLoggingDelegate?.onTryAgainTapped()
    }

    @IBAction func onSearchManually(_ sender: UIButton) {
        searchManually()
    }
    
    func searchManually() {
        resultLoggingDelegate?.onSearchManuallyTapped()
    }

    // If there is food to log, log the food, otherwise search manually
    @IBAction func onLogSelected(_ sender: UIButton) {
        if foodLogs.count > 0 {
            updateLogUI(isLogging: true)
            
            if resultViewFor == .addIngredient {
                
                getFoodRecordForAddingAnIngredients(foods: foodLogs.filter { $0.isSelected }) { [weak self] foodRecordIngredients in
                    self?.updateLogUI(isLogging: false)
                    self?.resultLoggingDelegate?.onAddIngredientsTapped(foodRecords: foodRecordIngredients)
                }
            }
            else {
                getFoodRecord(foods: foodLogs.filter { $0.isSelected }) { [weak self] in
                    self?.updateLogUI(isLogging: false)
                    self?.resultLoggingDelegate?.onLogSelectedTapped()
                }
            }
        } else {
            searchManually()
        }
    }
    
    func updateLogUI(isLogging: Bool) {
        if isLogging {
            self.isUserInteractionEnabled = false
            if resultViewFor == .addIngredient {
                logLabel.text = "Adding..."
            }
            else {
                logLabel.text = "Logging..."
            }
            activityIndicator.startAnimating()
        } else {
            self.isUserInteractionEnabled = true
            if resultViewFor == .addIngredient {
                logLabel.text = "Ingredients Selected"
            }
            else {
                logLabel.text = "Log Selected"
            }
            activityIndicator.stopAnimating()
        }
    }
    
    func updateResultUI() {
        
        if foodLogs.count > 0 {
            
            topConstraint.constant = 8
            clearView.isHidden = false
            resultsLabel.text = "Results"
            resultsDescLabel.text = "Select the foods you would like to log."
            
            // Table
            foodResultsTableView.reloadData()
            foodResultsTableView.isHidden = false
            tableViewHeightConstraint.constant = foodResultsTableView.contentSize.height >= 200 ? 200 : foodResultsTableView.contentSize.height
            
            searchManuallyStackView.isHidden = false

            // Log
            let isEnabled = foodLogs.filter { $0.isSelected }.count > 0
            logView.alpha = isEnabled ? 1 : 0.8
            logSelectedButton.isEnabled = isEnabled
            logLabel.text = "Log Selected"
        }
        else {
            topConstraint.constant = 20
            clearView.isHidden = true
            resultsLabel.text = "No Results Found"
            resultsDescLabel.text = "Sorry, we could not find any matches. Please try again or try searching manually."
            
            // Table
            foodResultsTableView.reloadData()
            foodResultsTableView.isHidden = true
            
            searchManuallyStackView.isHidden = true

            // Search manually
            logView.alpha = 1
            logSelectedButton.isEnabled = true
            logLabel.text = "Search Manually"
        }
    }

    private func getFoodRecord(foods: [FoodLog],
                               completion: @escaping () -> Void) {

        let dispatchGroup = DispatchGroup()

        foods.forEach { food in

            dispatchGroup.enter()

            DispatchQueue.global(qos: .userInteractive).async {

                let advisorFoodInfo = food.foodData.advisorFoodInfo

                if let foodDataInfo = advisorFoodInfo.foodDataInfo {

                    PassioNutritionAI.shared.fetchFoodItemFor(
                        foodDataInfo: foodDataInfo,
                        servingQuantity: foodDataInfo.nutritionPreview?.servingQuantity,
                        servingUnit: foodDataInfo.nutritionPreview?.servingUnit
                    ) { (foodItem) in

                        if let foodItem {
                            var foodRecord = FoodRecordV3(foodItem: foodItem)
                            foodRecord.mealLabel = MealLabel(mealTime: food.foodData.meal ?? PassioMealTime.currentMealTime())
                            NutritionUIModule.shared.updateRecord(foodRecord: foodRecord)
                            dispatchGroup.leave()
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }

    private func getFoodRecordForAddingAnIngredients(foods: [FoodLog],
                               completion: @escaping ([FoodRecordV3]) -> Void) {
        
        let selectedFoods = foods
        
        var foodRecordIngredients: [FoodRecordV3] = []
        
        let dispatchGroup = DispatchGroup()
        
        var iCounter = 0
        dispatchGroup.enter()
        
        selectedFoods.forEach { foodDataInfoItem in
            
            DispatchQueue.global(qos: .userInteractive).async {

                let advisorFoodInfo = foodDataInfoItem.foodData.advisorFoodInfo

                if let foodDataInfo = advisorFoodInfo.foodDataInfo {

                    PassioNutritionAI.shared.fetchFoodItemFor(
                        foodDataInfo: foodDataInfo,
                        servingQuantity: foodDataInfo.nutritionPreview?.servingQuantity,
                        servingUnit: foodDataInfo.nutritionPreview?.servingUnit
                    ) { (foodItem) in
                        
                        iCounter += 1
                        
                        if let foodItem {
                            var foodRecord = FoodRecordV3(foodItem: foodItem)
                            foodRecord.mealLabel = MealLabel(mealTime: foodDataInfoItem.foodData.meal ?? PassioMealTime.currentMealTime())
                            foodRecordIngredients.append(foodRecord)
                        }
                        
                        if iCounter == selectedFoods.count {
                            dispatchGroup.leave()
                        }
                    }
                }
                else {
                    if let foodItem = advisorFoodInfo.packagedFoodItem {
                        iCounter += 1
                        // As we need ingredients for Recipe creation only, that's why we keep entity type as `.recipe`
                        var foodRecord = FoodRecordV3(foodItem: foodItem, entityType: .recipe)
                        foodRecord.mealLabel = MealLabel(mealTime: foodDataInfoItem.foodData.meal ?? PassioMealTime.currentMealTime())
                        foodRecordIngredients.append(foodRecord)
                        
                        if iCounter == selectedFoods.count {
                            dispatchGroup.leave()
                        }
                    }
                    else {
                        iCounter += 1
                        if iCounter == selectedFoods.count {
                            dispatchGroup.leave()
                        }
                    }
                    
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            completion(foodRecordIngredients)
        }
    }
}

// MARK: - UITableViewDataSource
extension ResultsLoggingView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foodLogs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueCell(cellClass: VoiceLoggingCell.self, forIndexPath: indexPath)
        let foodLog = foodLogs[indexPath.row]
        cell.configureCell(with: foodLog)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        foodLogs[indexPath.row].isSelected = !foodLogs[indexPath.row].isSelected
        foodResultsTableView.reloadWithAnimations(withDuration: 0.12)
    }
}
