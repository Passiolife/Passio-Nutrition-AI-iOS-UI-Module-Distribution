//
//  MacroProgressViewController.swift
//  BaseApp
//
//  Created by Mind on 29/02/24.
//  Copyright © 2024 Passio Inc. All rights reserved.
//

import UIKit

class MacroProgressViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var nextDateButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var caloryBarChart: MacroProgressBarChartView!
    @IBOutlet weak var macroBarChart: MacroProgressBarChartView!

    private var selectedDate: Date = Date() {
        didSet {
            configureDateUI()
            getDayLogsFrom()
        }
    }
    private var currentScope: Scope = .week

    enum Scope {
        case month,week
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedDate = Date()
        self.setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let segmentPath = UIBezierPath(roundedRect: segmentControl.bounds, cornerRadius: 8)
        segmentControl.dropShadow(radius: 8,
                                  offset: CGSize(width: 0, height: 1),
                                  color: .black.withAlphaComponent(0.06),
                                  shadowRadius: 2,
                                  shadowOpacity: 1,
                                  useShadowPath: true,
                                  shadowPath: segmentPath.cgPath)

        let caloriePath = UIBezierPath(roundedRect: caloryBarChart.shadowView.bounds, cornerRadius: 16)
        caloryBarChart.dropShadow(radius: 16,
                                  offset: CGSize(width: 0, height: 2),
                                  color: .black.withAlphaComponent(0.10),
                                  shadowRadius: 8,
                                  shadowOpacity: 1,
                                  useShadowPath: true,
                                  shadowPath: caloriePath.cgPath)

        let macroPath = UIBezierPath(roundedRect: macroBarChart.shadowView.bounds, cornerRadius: 16)
        macroBarChart.dropShadow(radius: 16,
                                  offset: CGSize(width: 0, height: 2),
                                  color: .black.withAlphaComponent(0.10),
                                  shadowRadius: 8,
                                  shadowOpacity: 1,
                                  useShadowPath: true,
                                  shadowPath: macroPath.cgPath)
    }

    func setupUI() {
        segmentControl.defaultConfiguration(font: UIFont.inter(type: .regular, size: 14), color: .gray700)
        segmentControl.selectedConfiguration(font: UIFont.inter(type: .regular, size: 14), color: .white)
        caloryBarChart.title = "Calories"
        macroBarChart.title = "Macros"
    }
}

//MARK: - Date management
extension MacroProgressViewController {

    @IBAction func onNextPrevButtonPressed(_ sender: UIButton) {
        let setDate: (Calendar.Component, Int) = currentScope == .week ? (.day, -7) : (.month, -1)
        let dateValue = sender.tag == 1 ? setDate.1 : abs(setDate.1)
        let date = Calendar.current.date(byAdding: setDate.0, value: dateValue, to: selectedDate)!
        self.selectedDate = date
    }

    func configureDateUI() {

        let (startDate, endDate) = currentScope == .week ? selectedDate.startAndEndOfWeek()! : selectedDate.startAndEndOfMonth()!
        nextDateButton.isEnabled = !(Date() > startDate.startOfToday && Date() < endDate)
        nextDateButton.alpha = Date() > startDate.startOfToday && Date() < endDate ? 0.5 : 1

        if currentScope == .month {
            let dateFormatterr = DateFormatter()
            dateFormatterr.dateFormat = DateFormatString.MMMM_yyyy
            let month = dateFormatterr.string(from: selectedDate)
            dateLabel.text = month
        } else {
            let dateFormatterr = DateFormatter()
            dateFormatterr.dateFormat = DateFormatString.M_d_yyyy2
            if Date() > startDate.startOfToday && Date() < endDate {
                dateLabel.text = "This week"
            } else {
                dateLabel.text = "\(dateFormatterr.string(from: startDate)) - \(dateFormatterr.string(from: endDate))"
            }
        }
    }

    @IBAction func onChangeScope(_ sender: UISegmentedControl) {
        self.currentScope = sender.selectedSegmentIndex == 0 ? .week : .month
        self.configureDateUI()
        self.getDayLogsFrom()
    }

    private func getDayLogsFrom() {

        let (fromDate, toDate) = currentScope == .week ? selectedDate.startAndEndOfWeek()! : selectedDate.startAndEndOfMonth()!

        PassioInternalConnector.shared.fetchDayLogRecursive(fromDate: fromDate, toDate: toDate) { [weak self] (dayLogs) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.setupCharts(from: dayLogs)
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
        caloryBarChart.setupChart(datasource: data.map({ $0.0 }), maximum: max, dates: dates)
        macroBarChart.setupChart(datasource: data.map({ $0.1 }), maximum: max, dates: dates)
    }
}
