//
//  DashboardViewController.swift
//  Nutritaion-ai
//
//  Created by Mind on 12/02/24.
//

import UIKit
import FSCalendar

internal enum TrackingTypes {
    case waterTracking
    case weightTracking
}

protocol DashboardDelegate {
    func redirectToTrackingScreen(trackingType: TrackingTypes)
}

class DashboardViewController: UIViewController {

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var nextDateButton: UIButton!

    private lazy var calendarScope: FSCalendarScope = .week
    private let connector = PassioInternalConnector.shared
    private let cells: [CellType] = [.nutrition, .calender, .weightWater]
    private var dateSelector: DateSelectorViewController?
    private var dayLog: DayLog?
    private var selectedDate: Date = Date() {
        didSet {
            setTitle()
            getRecords(for: selectedDate)
            softReloadCalenderCell()
            nextDateButton.isEnabled = selectedDate.isToday ? false : true
        }
    }

    private enum CellType: Int {
        case nutrition, calender, weightWater
    }
    private var weightTrackingRecord: WeightTracking?
    
    var delegate: DashboardDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedDate = Date()
        dateView.backgroundColor = .navigationColor
        dateButton.titleLabel?.font = .inter(type: .semiBold, size: 14)
        dateButton.setTitleColor(.gray900, for: .normal)
        registerCell()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getWeightTrackingLastRecord()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        setTitle()
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        getRecords(for: selectedDate)
        tableView.reloadData()
    }

    func registerCell() {
        tableView.register(nibName: DailyNutritionCell.className)
        tableView.register(nibName: CalendarCell.className)
        tableView.register(nibName: WaterWeightCardCell.className)
    }

    @IBAction func onNextPrevButtonPressed(_ sender: UIButton) {
        let nextDate = Calendar.current.date(byAdding: .day,
                                             value: sender.tag == 1 ? 1 : -1,
                                             to: selectedDate)!
        selectedDate = nextDate
    }

    func setTitle() {
        if selectedDate.isToday {
            dateButton.setTitle("Today", for: .normal)
        } else {
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
            let newTitle = dateFormatterPrint.string(for: selectedDate)
            dateButton.setTitle(newTitle, for: .normal)
        }
    }

    func getRecords(for date: Date?) {
        guard let date = date else { return }
        connector.fetchDayRecords(date: date) { (foodRecords) in
            self.dayLog = DayLog(date: date, records: foodRecords)
            self.softReloadNutritionCell()
        }
    }
    
    func navigateToDiary(date: Date) {
        guard let vc = self.tabBarController as? HomeTabBarController else { return }
        vc.selectedIndex = 1
        if let diaryNavVC = vc.viewControllers?[1] as? UINavigationController,
           let diaryVC = diaryNavVC.viewControllers.first as? DiaryViewController {
            diaryVC.selectedDate = date
        }
    }
    
    private func getWeightTrackingLastRecord() {
        PassioInternalConnector.shared.fetchWeightTrackingRecord(date: Date()) { weightTrackingRecord in
            if let lastRecordOfDesOrder = weightTrackingRecord.last {
                self.weightTrackingRecord = lastRecordOfDesOrder
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {

    func softReloadNutritionCell() {
        tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .none)
    }

    func softReloadCalenderCell() {
        guard let cell = tableView.visibleCells.first(where: { $0 is CalendarCell}) as? CalendarCell else {
            return
        }
        cell.selectedDate = selectedDate
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch cells[indexPath.row] {

        case .nutrition:
            let cell = tableView.dequeueCell(cellClass: DailyNutritionCell.self, forIndexPath: indexPath)
            let displayedRecords = dayLog?.displayedRecords ?? []
            let userProfile = UserManager.shared.user ?? UserProfileModel()
            let (calories, carbs, protein, fat) = getNutritionSummaryfor(foodRecords: displayedRecords)
            let nuData = NutritionDataModal(
                calory: (consumed: Int(calories), target: userProfile.caloriesTarget),
                carb: (consumed: Int(carbs), target: userProfile.carbsTargetGrams),
                protein: (consumed: Int(protein), target: userProfile.proteinTargetGrams),
                fat: (consumed: Int(fat), target: userProfile.fatTargetGrams))
            cell.nutritionData = nuData
            return cell

        case .calender:
            let cell = tableView.dequeueCell(cellClass: CalendarCell.self, forIndexPath: indexPath)
            cell.configure(currentDate: self.selectedDate, calendarScope: calendarScope)
            cell.configureDateUI()
            cell.didSelectDate = { [weak self] date in
                guard let self = self else { return }
                self.navigateToDiary(date: date)
            }
            cell.didTapDisclosure = { [weak self] in
                guard let self = self else { return }
                calendarScope = calendarScope == .month ? FSCalendarScope.week : FSCalendarScope.month
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            return cell
        case .weightWater:
            let cell = tableView.dequeueCell(cellClass: WaterWeightCardCell.self, forIndexPath: indexPath)
            cell.configureUI(lastWeightRecord: weightTrackingRecord)
            cell.addWaterButtonAction = {
                self.delegate?.redirectToTrackingScreen(trackingType: .weightTracking)
            }
            
            cell.addWeightButtonAction = { [weak self] in
                guard let self = self else { return }
                self.delegate?.redirectToTrackingScreen(trackingType: .weightTracking)
            }
            cell.selectionStyle = .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cells[indexPath.row] {
        case .calender:
            print("Calendar cell")
            break
        default:
            break
        }
    }
}

// MARK: - DateSelection
extension DashboardViewController: DateSelectorUIViewDelegate {

    @IBAction func showDateSelector(_ sender: Any) {
        dateSelector = DateSelectorViewController()
        dateSelector?.delegate = self
        dateSelector?.modalPresentationStyle = .overFullScreen
        present(dateSelector!, animated: false)
    }

    func removeDateSelector(remove: Bool) {
        dateSelector?.dismiss(animated: false)
    }

    func dateFromPicker(date: Date) {
        selectedDate = date
    }
}
