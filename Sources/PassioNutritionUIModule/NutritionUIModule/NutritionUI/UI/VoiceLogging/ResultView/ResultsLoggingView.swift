//
//  ResultsLoggingView.swift
//  
//
//  Created by Nikunj Prajapati on 07/06/24.
//

import UIKit

protocol ResultsLoggingDelegate: AnyObject {
    func onTryAgainTapped()
    func onLogSelectedTapped(foods: [PassioFoodDataInfo])
    func onSearchManuallyTapped()
}

class ResultsLoggingView: UIView {

    @IBOutlet weak var searchManuallyButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var loggingView: UIView!
    @IBOutlet weak var foodResultsTableView: UITableView!

    var recognitionData: [PassioSpeechRecognitionModel]? {
        didSet {
            foodLogs = recognitionData?.map {
                FoodLog(isSelected: false, foodData: $0.advisorFoodInfo.foodDataInfo)
            } ?? []
        }
    }
    var selectedIndexes: [Int] = []

    struct FoodLog {
        var isSelected: Bool
        let foodData: PassioFoodDataInfo
    }

    private var foodLogs: [FoodLog] = []

    weak var resultLoggingDelegate: ResultsLoggingDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        foodResultsTableView.register(nibName: "VoiceLoggingCell", bundle: .module)
        foodResultsTableView.dataSource = self
        foodResultsTableView.delegate = self
        loggingView.roundMyCornerWith(radius: 16, upper: true, down: false)
        loggingView.dropShadow(radius: 16,
                               offset: CGSize(width: 0, height: -2),
                               color: .black.withAlphaComponent(0.10),
                               shadowRadius: 6,
                               shadowOpacity: 1)

        searchManuallyButton.titleLabel?.font = .inter(type: .bold, size: 14)
        resultsLabel.font = .inter(type: .bold, size: 20)
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
        let selectedFoods = foodLogs.filter { $0.isSelected }
        resultLoggingDelegate?.onLogSelectedTapped(foods: selectedFoods.map { $0.foodData })
    }
}

// MARK: - UITableViewDataSource
extension ResultsLoggingView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        foodLogs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueCell(cellClass: VoiceLoggingCell.self, forIndexPath: indexPath)
        let food = foodLogs[indexPath.row]
        cell.configureUI(foodInfo: food.foodData, isSelected: food.isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        foodLogs[indexPath.row].isSelected = !foodLogs[indexPath.row].isSelected
        foodResultsTableView.reloadWithAnimations(withDuration: 0.12)
    }
}
