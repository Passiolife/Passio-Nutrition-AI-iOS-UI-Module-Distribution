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
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var foodResultsTableView: UITableView!
    @IBOutlet weak var logSelectedButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
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
            let isEnabled = foodLogs.filter { $0.isSelected }.count > 0
            logSelectedButton.isEnabled = isEnabled
            logSelectedButton.alpha = isEnabled ? 1 : 0.8
            foodResultsTableView.reloadData()
            tableViewHeightConstraint.constant = foodResultsTableView.contentSize.height >= 200 ? 200 : foodResultsTableView.contentSize.height
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
        contentView.roundMyCornerWith(radius: 16, upper: true, down: false)
        contentView.dropShadow(radius: 16,
                               offset: CGSize(width: 0, height: -2),
                               color: .black.withAlphaComponent(0.10),
                               shadowRadius: 6,
                               shadowOpacity: 1)

        resultsLabel.font = .inter(type: .bold, size: 20)
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
        logSelectedButton.backgroundColor = .primaryColor
        tryAgainButton.tintColor = .primaryColor
        tryAgainButton.setTitleColor(.primaryColor, for: .normal)
        tryAgainButton.applyBorder(width: 2, color: .primaryColor)
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
        resultLoggingDelegate?.onSearchManuallyTapped()
    }

    @IBAction func onLogSelected(_ sender: UIButton) {
        getFoodRecord(foods: foodLogs.filter { $0.isSelected }) { [weak self] in
            self?.resultLoggingDelegate?.onLogSelectedTapped()
        }
    }

    private func getFoodRecord(foods: [FoodLog],
                               completion: @escaping () -> Void) {

        let dispatchGroup = DispatchGroup()

        foods.forEach { food in

            dispatchGroup.enter()

            DispatchQueue.global(qos: .userInteractive).async {

                let advisorFoodInfo = food.foodData.advisorFoodInfo

                PassioNutritionAI.shared.fetchFoodItemFor(foodItem: advisorFoodInfo.foodDataInfo,
                                                          weightGrams: advisorFoodInfo.weightGrams) { (foodItem) in

                    if let foodItem {
                        var foodRecord = FoodRecordV3(foodItem: foodItem)
                        foodRecord.mealLabel = MealLabel(mealTime: food.foodData.meal ?? PassioMealTime.currentMealTime())
                        PassioInternalConnector.shared.updateRecord(foodRecord: foodRecord, isNew: true)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion()
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
        cell.configureUI(with: foodLog)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        foodLogs[indexPath.row].isSelected = !foodLogs[indexPath.row].isSelected
        foodResultsTableView.reloadWithAnimations(withDuration: 0.12)
    }
}
