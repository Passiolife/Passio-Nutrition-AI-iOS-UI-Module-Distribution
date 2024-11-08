//
//  WeightTrackingVC.swift
//  Passio-Nutrition-AI-iOS-UI-Module
//
//  Created by Tushar S on 07/11/24.
//

import UIKit

class WeightTrackingVC: UIViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var nextDateButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weightBarChart: MacroProgressBarChartView!

    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var weightTrackTableView: UITableView!
    @IBOutlet weak var weightTrackTableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var weightTrackerListContainer: UIView!
    
    private var selectedDate: Date = Date() {
        didSet {
            configureDateUI()
            getWeightTrackingRecords()
        }
    }
    private var currentScope: Scope = .week
    private var arrWeightTracking: [WeightTracking] = []
    
    enum Scope {
        case month,week
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        segmentControl.dropShadow(radius: 8,
                                  offset: CGSize(width: 0, height: 1),
                                  color: .black.withAlphaComponent(0.06),
                                  shadowRadius: 2,
                                  shadowOpacity: 1)
        weightBarChart.dropShadow(radius: 16,
                                  offset: CGSize(width: 0, height: 2),
                                  color: .black.withAlphaComponent(0.10),
                                  shadowRadius: 8,
                                  shadowOpacity: 1)
        weightTrackerListContainer.dropShadow(radius: 16,
                                              offset: CGSize(width: 0, height: 2),
                                              color: .black.withAlphaComponent(0.10),
                                              shadowRadius: 8,
                                              shadowOpacity: 1)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        segmentControl.layer.shadowPath = UIBezierPath(roundedRect: segmentControl.bounds,
                                            cornerRadius: 8).cgPath
        weightBarChart.layer.shadowPath = UIBezierPath(roundedRect: weightBarChart.shadowView.bounds,
                                            cornerRadius: 16).cgPath
    }

    func setupUI() {
        selectedDate = Date()
        segmentControl.defaultConfiguration(font: UIFont.inter(type: .regular, size: 14), color: .gray700)
        segmentControl.selectedConfiguration(font: UIFont.inter(type: .regular, size: 14), color: .white)
        weightBarChart.title = "Calories"
        segmentControl.selectedSegmentTintColor = .indigo600
        
        configureNavBar()
        
        self.weightTrackerListContainer.isHidden = true
        
        self.configTableView()
    }
    
    private func configureNavBar() {
        
        self.title = "Weight Tracking"
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.updateStatusBarColor(color: .statusBarColor)
        
        setupBackButton()
        
        let button = UIButton()
        button.setImage(UIImage.imageFromBundle(named: "addIcon"), for: .normal)
        button.addTarget(self, action: #selector(handleFilterButton(sender: )), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    // selector that's going to tigger on single tap on nav bar button
    @objc private func handleFilterButton(sender: UIButton) {
        let vc = NutritionUICoordinator.getAddWeightTrackingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configTableView() {
        self.weightTrackTableView.delegate = self
        self.weightTrackTableView.dataSource = self
        self.weightTrackTableView.separatorStyle = .none
        self.weightTrackTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.weightTrackTableView.register(nibName: WeightTrackingRecordCell.className)
        self.weightTrackTableView.reloadData()
    }
}

//MARK: - Date management
extension WeightTrackingVC {

    @IBAction func onNextPrevButtonPressed(_ sender: UIButton) {
        let setDate: (Calendar.Component, Int) = currentScope == .week ? (.day, -7) : (.month, -1)
        let dateValue = sender.tag == 1 ? setDate.1 : abs(setDate.1)
        let date = Calendar.current.date(byAdding: setDate.0, value: dateValue, to: selectedDate)!
        self.selectedDate = date
    }

    @IBAction func onChangeScope(_ sender: UISegmentedControl) {
        self.currentScope = sender.selectedSegmentIndex == 0 ? .week : .month
        self.configureDateUI()
        self.getWeightTrackingRecords()
    }

    private func configureDateUI() {

        let (startDate, endDate) = currentScope == .week
        ? selectedDate.startAndEndOfWeek()! : selectedDate.startAndEndOfMonth()!
        nextDateButton.isEnabled = !(Date() > startDate.startOfToday && Date() < endDate)
        nextDateButton.alpha = Date() > startDate.startOfToday && Date() < endDate ? 0.5 : 1

        if currentScope == .month {
            let dateFormatterr = DateFormatter()
            dateFormatterr.dateFormat = DateFormatString.MMMM_yyyy
            let month = dateFormatterr.string(from: selectedDate)
            dateLabel.text = month
            dateTitle.text = month
        } else {
            let dateFormatterr = DateFormatter()
            dateFormatterr.dateFormat = DateFormatString.M_d_yyyy2
            if Date() > startDate.startOfToday && Date() < endDate {
                dateLabel.text = "This week"
                dateTitle.text = "This week"
            } else {
                dateLabel.text = "\(dateFormatterr.string(from: startDate)) - \(dateFormatterr.string(from: endDate))"
                dateTitle.text = "\(dateFormatterr.string(from: startDate)) - \(dateFormatterr.string(from: endDate))"
            }
        }
    }
    
    private func getWeightTrackingRecords() {

        let (fromDate, toDate) = currentScope == .week
        ? selectedDate.startAndEndOfWeek()! : selectedDate.startAndEndOfMonth()!
        PassioInternalConnector.shared.fetchWeightTrackingRecursive(fromDate: fromDate, toDate: toDate) { [weak self] (weightTrackingRecords) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.arrWeightTracking = weightTrackingRecords
                self.weightTrackTableViewHeightConst.constant = CGFloat(55 * self.arrWeightTracking.count)
                self.weightTrackTableView.reloadData()
                if self.arrWeightTracking.count == 0 {
                    self.weightTrackerListContainer.isHidden = true
                }
                else {
                    self.weightTrackerListContainer.isHidden = false
                }
//                self.setupCharts(from: dayLogs)
            }
        }
    }

    private func setupCharts(from dayLogs: [DayLog]) {

        let data = dayLogs.map { daylog in
            let displayedRecords = daylog.displayedRecords
            let (calory, carbs, protein, fat) = getNutritionSummaryfor(foodRecords: displayedRecords)
            let _calory  = ChartDataSource(value: CGFloat(calory) == 0 ? nil : CGFloat(calory), color: .yellow500)
            let _protein = ChartDataSource(value: CGFloat(protein) * 4, color: .green500)
            let _fat     = ChartDataSource(value: CGFloat(fat) * 9, color: .purple500)
            let _carbs   = ChartDataSource(value: CGFloat(carbs) * 4, color: .lightBlue)
            return (_calory,CombineChartDataSource(dataSource: [_protein,_fat,_carbs]))
        }

        let dates = dayLogs.map({$0.date})

        let max = (data.map({$0.0}).max(by: { ($0.value ?? 0) < ($1.value ?? 0) })?.value ?? 2000)
            .normalize(toMultipleOf: 200)
        weightBarChart.setupChart(datasource: data.map({ $0.0 }), maximum: max, dates: dates)
    }
}

extension WeightTrackingVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWeightTracking.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueCell(cellClass: WeightTrackingRecordCell.self, forIndexPath: indexPath)
        
        cell.setLayout(weightTracking: arrWeightTracking[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let editItem = UIContextualAction(style: .normal,
                                          title: ButtonTexts.edit) { [weak self] (_, _, _) in
            tableView.reloadData()
        }
        editItem.backgroundColor = .indigo600
        let deleteItem = UIContextualAction(style: .destructive,
                                            title: ButtonTexts.delete) { [weak self] (_, _, _) in
            tableView.reloadData()
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])
        return swipeActions
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
}

