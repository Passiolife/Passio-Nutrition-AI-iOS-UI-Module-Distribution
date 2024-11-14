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
    @IBOutlet weak var weightTrackTableViewTopConst: NSLayoutConstraint!
    @IBOutlet weak var weightTrackTableViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var weightTrackerListContainer: UIView!
    @IBOutlet weak var dividerView: UIView!
    private let connector = PassioInternalConnector.shared
    private var selectedDate: Date = Date() {
        didSet {
            configureDateUI()
            getWeightTrackingRecords()
        }
    }
    private var currentScope: Scope = .week
    private var arrWeightTracking: [WeightTracking] = []
    private var userProfile: UserProfileModel!
    enum Scope {
        case month,week
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfile = UserManager.shared.user ?? UserProfileModel()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        weightBarChart.title = "Weight Tracking"
        weightBarChart.showAllLabels = true
        segmentControl.selectedSegmentTintColor = .indigo600
        arrowIcon.transform = CGAffineTransform(rotationAngle: .pi)
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
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configTableView() {
        self.weightTrackTableView.delegate = self
        self.weightTrackTableView.dataSource = self
        self.weightTrackTableView.separatorStyle = .none
        self.weightTrackTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.weightTrackTableView.register(nibName: TrackingRecordCell.className)
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

    @IBAction func aarowTogglePressed(_ sender: UIButton) {
        if arrowIcon.tag == 0 {
            arrowIcon.tag = 1
            arrowIcon.transform = CGAffineTransform(rotationAngle: 0)
            UIView.animate(withDuration: 0.6) {
                self.weightTrackTableViewHeightConst.constant = 0
                self.weightTrackTableViewTopConst.constant = 0
                self.weightTrackTableViewBottomConst.constant = 0
                self.dividerView.isHidden = true
                self.view.layoutIfNeeded()
            }
            
        }
        else {
            arrowIcon.tag = 0
            arrowIcon.transform = CGAffineTransform(rotationAngle: .pi)
            UIView.animate(withDuration: 0.6) {
                self.dividerView.isHidden = false
                self.weightTrackTableViewHeightConst.constant = CGFloat(55 * self.arrWeightTracking.count)
                self.weightTrackTableViewTopConst.constant = 16
                self.weightTrackTableViewBottomConst.constant = 16
                self.view.layoutIfNeeded()
            }
        }
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
        
        connector.fetchWeightRecords(startDate: fromDate, endDate: toDate) { [weak self] (weightTrackingRecords) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.arrWeightTracking = weightTrackingRecords
                self.weightTrackTableViewHeightConst.constant = CGFloat(55 * self.arrWeightTracking.count)
                if self.arrWeightTracking.count == 0 {
                    self.arrowIcon.tag = 1
                    self.arrowIcon.transform = CGAffineTransform(rotationAngle: 0)
                    self.weightTrackTableViewHeightConst.constant = 0
                    self.weightTrackTableViewTopConst.constant = 0
                    self.weightTrackTableViewBottomConst.constant = 0
                    self.dividerView.isHidden = true
                }
                else {
                    self.arrowIcon.tag = 0
                    self.arrowIcon.transform = CGAffineTransform(rotationAngle: .pi)
                    self.dividerView.isHidden = false
                    self.weightTrackTableViewTopConst.constant = 16
                    self.weightTrackTableViewBottomConst.constant = 16
                }
                
                self.weightTrackTableView.reloadData()
                if self.arrWeightTracking.count == 0 {
                    self.weightTrackerListContainer.isHidden = true
                }
                else {
                    self.weightTrackerListContainer.isHidden = false
                }
                let arrMergedValue = self.getHighestWeightOfSameDateWise(weightRecords: self.arrWeightTracking)
                self.setupCharts(from: arrMergedValue)
            }
        }
    }
    
    private func getHighestWeightOfSameDateWise(weightRecords records: [WeightTracking]) -> [WeightTracking] {
        var result: [Date: Double] = [:]
        
        // Get the current calendar
        let calendar = Calendar.current
        
        // Group records by date (ignoring time)
        for record in records {
            // Get the start of the day for the record date (ignores the time)
            let dateWithoutTime = calendar.startOfDay(for: record.dateTime)
            
            // Check if the date is already in the result
            if let existingMax = result[dateWithoutTime] {
                // If we already have a value for this date, take the higher of the two
                result[dateWithoutTime] = max(existingMax, record.weight)
            } else {
                // If it's the first time we encounter this date, store the value
                result[dateWithoutTime] = record.weight
            }
        }
        
        let sortedRecords = result.keys.sorted().map({(date: $0, value: result[$0]!)})
        
        return sortedRecords.map({WeightTracking(weight: $0.value, dateTime: $0.date)})
    }

    private func setupCharts(from weightTrackingRecords: [WeightTracking]) {

        let data = weightTrackingRecords.map { weightTracking in
            let trackingWeight = userProfile.units == .imperial ? Double(weightTracking.weight * Conversion.lbsToKg.rawValue) : weightTracking.weight
            let _trackrecord = ChartDataSource(value: CGFloat(trackingWeight.roundDigits(afterDecimal: 1)), color: .green500)
            return _trackrecord
        }

        let dates = weightTrackingRecords.map({$0.dateTime})
        
        let max = (data.max(by: { ($0.value ?? 0) < ($1.value ?? 0) })?.value ?? 2000)
            .normalize(toMultipleOf: 200)
        
        if currentScope == .week {
            weightBarChart.currentScope = .week
        }
        else {
            weightBarChart.currentScope = .month
        }
        
        if let goalWeight = userProfile.goalWeight {
            weightBarChart.setupLineChart(datasource: data, baseLine: goalWeight, maximum: max, dates: dates)
        }
        else {
            weightBarChart.setupLineChart(datasource: data, maximum: max, dates: dates)
        }
        
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension WeightTrackingVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWeightTracking.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueCell(cellClass: TrackingRecordCell.self, forIndexPath: indexPath)
        
        cell.setLayout(weightTracking: arrWeightTracking[indexPath.item], userProfile: userProfile)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let weightRecord = self.arrWeightTracking[indexPath.row]
        let vc = NutritionUICoordinator.getAddWeightTrackingViewController()
        vc.delegate = self
        vc.isEditMode = true
        vc.weightRecord = weightRecord
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let editItem = UIContextualAction(style: .normal,
                                          title: ButtonTexts.edit) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let weightRecord = self.arrWeightTracking[indexPath.row]
            let vc = NutritionUICoordinator.getAddWeightTrackingViewController()
            vc.delegate = self
            vc.isEditMode = true
            vc.weightRecord = weightRecord
            self.navigationController?.pushViewController(vc, animated: true)
            completionHandler(true)
        }
        editItem.backgroundColor = .indigo600
        let deleteItem = UIContextualAction(style: .destructive,
                                            title: ButtonTexts.delete) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.connector.deleteWeightRecord(weightRecord: self.arrWeightTracking[indexPath.row]) { bResult in
                if bResult {
                    self.getWeightTrackingRecords()
                    completionHandler(true)
                }
                else {
                    completionHandler(false)
                }
            }
            
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])
        return swipeActions
    }

    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
}

// MARK: - AddNewWeightTrackingDelegate
extension WeightTrackingVC: AddNewWeightTrackingDelegate {
    func refreshRecords() {
        getWeightTrackingRecords()
    }
}
