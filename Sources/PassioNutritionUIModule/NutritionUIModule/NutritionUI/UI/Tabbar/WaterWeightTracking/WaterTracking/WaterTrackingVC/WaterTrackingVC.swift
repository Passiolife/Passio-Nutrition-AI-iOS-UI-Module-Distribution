//
//  WaterTrackingVC.swift
//  
//
//  Created by Mindinventory on 13/11/24.
//

import UIKit

class WaterTrackingVC: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var nextDateButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var waterBarChart: MacroProgressBarChartView!

    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var waterTrackTableView: UITableView!
    @IBOutlet weak var waterTrackTableViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var waterTrackTableViewTopConst: NSLayoutConstraint!
    @IBOutlet weak var waterTrackTableViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var waterTrackerListContainer: UIView!
    @IBOutlet weak var dividerView: UIView!
    private let connector = PassioInternalConnector.shared
    private var selectedDate: Date = Date() {
        didSet {
            configureDateUI()
            getWaterTrackingRecords()
        }
    }
    private var currentScope: Scope = .week
    private var arrWaterTracking: [WaterTracking] = []
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
        waterBarChart.dropShadow(radius: 16,
                                  offset: CGSize(width: 0, height: 2),
                                  color: .black.withAlphaComponent(0.10),
                                  shadowRadius: 8,
                                  shadowOpacity: 1)
        waterTrackerListContainer.dropShadow(radius: 16,
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
        waterBarChart.layer.shadowPath = UIBezierPath(roundedRect: waterBarChart.shadowView.bounds,
                                            cornerRadius: 16).cgPath
    }

    func setupUI() {
        selectedDate = Date()
        segmentControl.defaultConfiguration(font: UIFont.inter(type: .regular, size: 14), color: .gray700)
        segmentControl.selectedConfiguration(font: UIFont.inter(type: .regular, size: 14), color: .white)
        waterBarChart.title = "Water Tracking"
        segmentControl.selectedSegmentTintColor = .indigo600
        arrowIcon.transform = CGAffineTransform(rotationAngle: .pi)
        configureNavBar()
        
        self.waterTrackerListContainer.isHidden = true
        
        self.configTableView()
    }
    
    private func configureNavBar() {
        
        self.title = "Water Tracking"
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
        let vc = NutritionUICoordinator.getAddWaterTrackingViewController()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configTableView() {
        self.waterTrackTableView.delegate = self
        self.waterTrackTableView.dataSource = self
        self.waterTrackTableView.separatorStyle = .none
        self.waterTrackTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.waterTrackTableView.register(nibName: TrackingRecordCell.className)
        self.waterTrackTableView.reloadData()
    }
}

//MARK: - Date management
extension WaterTrackingVC {

    @IBAction func onNextPrevButtonPressed(_ sender: UIButton) {
        let setDate: (Calendar.Component, Int) = currentScope == .week ? (.day, -7) : (.month, -1)
        let dateValue = sender.tag == 1 ? setDate.1 : abs(setDate.1)
        let date = Calendar.current.date(byAdding: setDate.0, value: dateValue, to: selectedDate)!
        self.selectedDate = date
    }

    @IBAction func onChangeScope(_ sender: UISegmentedControl) {
        self.currentScope = sender.selectedSegmentIndex == 0 ? .week : .month
        self.configureDateUI()
        self.getWaterTrackingRecords()
    }

    @IBAction func aarowTogglePressed(_ sender: UIButton) {
        if arrowIcon.tag == 0 {
            arrowIcon.tag = 1
            arrowIcon.transform = CGAffineTransform(rotationAngle: 0)
            UIView.animate(withDuration: 0.6) {
                self.waterTrackTableViewHeightConst.constant = 0
                self.waterTrackTableViewTopConst.constant = 0
                self.waterTrackTableViewBottomConst.constant = 0
                self.dividerView.isHidden = true
                self.view.layoutIfNeeded()
            }
            
        }
        else {
            arrowIcon.tag = 0
            arrowIcon.transform = CGAffineTransform(rotationAngle: .pi)
            UIView.animate(withDuration: 0.6) {
                self.dividerView.isHidden = false
                self.waterTrackTableViewHeightConst.constant = CGFloat(55 * self.arrWaterTracking.count)
                self.waterTrackTableViewTopConst.constant = 16
                self.waterTrackTableViewBottomConst.constant = 16
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
    
    private func getWaterTrackingRecords() {

        let (fromDate, toDate) = currentScope == .week
        ? selectedDate.startAndEndOfWeek()! : selectedDate.startAndEndOfMonth()!
        
        connector.fetchWaterRecords(startDate: fromDate, endDate: toDate) { [weak self] (waterTrackingRecords) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.arrWaterTracking = waterTrackingRecords
                self.waterTrackTableViewHeightConst.constant = CGFloat(55 * self.arrWaterTracking.count)
                if self.arrWaterTracking.count == 0 {
                    self.arrowIcon.tag = 1
                    self.arrowIcon.transform = CGAffineTransform(rotationAngle: 0)
                    self.waterTrackTableViewHeightConst.constant = 0
                    self.waterTrackTableViewTopConst.constant = 0
                    self.waterTrackTableViewBottomConst.constant = 0
                    self.dividerView.isHidden = true
                }
                else {
                    self.arrowIcon.tag = 0
                    self.arrowIcon.transform = CGAffineTransform(rotationAngle: .pi)
                    self.dividerView.isHidden = false
                    self.waterTrackTableViewTopConst.constant = 16
                    self.waterTrackTableViewBottomConst.constant = 16
                }
                
                self.waterTrackTableView.reloadData()
                if self.arrWaterTracking.count == 0 {
                    self.waterTrackerListContainer.isHidden = true
                }
                else {
                    self.waterTrackerListContainer.isHidden = false
                }
                self.setupCharts(from: self.arrWaterTracking)
            }
        }
    }

    private func setupCharts(from waterTrackingRecords: [WaterTracking]) {

        let data = waterTrackingRecords.map { waterTracking in
            let trackingWater = waterTracking.water
            let _trackrecord = ChartDataSource(value: CGFloat(trackingWater.roundDigits(afterDecimal: 1)), color: .green500)
            return _trackrecord
        }

        let dates = waterTrackingRecords.map({$0.dateTime})
        
        let max = (data.max(by: { ($0.value ?? 0) < ($1.value ?? 0) })?.value ?? 2000)
            .normalize(toMultipleOf: 200)
        waterBarChart.setupChart(datasource: data, maximum: max, dates: dates)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension WaterTrackingVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWaterTracking.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueCell(cellClass: TrackingRecordCell.self, forIndexPath: indexPath)
        
        cell.setLayout(waterTracking: arrWaterTracking[indexPath.item], userProfile: userProfile)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let waterRecord = self.arrWaterTracking[indexPath.row]
        let vc = NutritionUICoordinator.getAddWaterTrackingViewController()
        vc.delegate = self
        vc.isEditMode = true
        vc.waterRecord = waterRecord
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let editItem = UIContextualAction(style: .normal,
                                          title: ButtonTexts.edit) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let waterRecord = self.arrWaterTracking[indexPath.row]
            let vc = NutritionUICoordinator.getAddWaterTrackingViewController()
            vc.delegate = self
            vc.isEditMode = true
            vc.waterRecord = waterRecord
            self.navigationController?.pushViewController(vc, animated: true)
            completionHandler(true)
        }
        editItem.backgroundColor = .indigo600
        let deleteItem = UIContextualAction(style: .destructive,
                                            title: ButtonTexts.delete) { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            self.connector.deleteWaterRecord(waterRecord: self.arrWaterTracking[indexPath.row]) { bResult in
                if bResult {
                    self.getWaterTrackingRecords()
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

// MARK: - AddNewWaterTrackingDelegate
extension WaterTrackingVC: AddNewWaterTrackingDelegate {
    func refreshRecords() {
        getWaterTrackingRecords()
    }
}
