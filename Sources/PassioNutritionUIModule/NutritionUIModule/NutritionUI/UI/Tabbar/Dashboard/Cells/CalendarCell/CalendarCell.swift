//
//  CalendarCell.swift
//  BaseApp
//
//  Created by Dharam on 15/09/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import UIKit
import FSCalendar

protocol CalendarCellLogsDelegate: AnyObject {
    func getDayLogs(startDate: Date, endDate: Date)
}

final class CalendarCell: UITableViewCell {

    @IBOutlet weak var adherenceIconImageView: UIImageView!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextDateView: UIView!
    @IBOutlet weak var nextDateButton: UIButton!
    @IBOutlet weak var calendarActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var disclosureButton: UIButton!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatString.yyyy_MM_dd
        return formatter
    }()
    var loggedRecordsDates: [String] = [] {
        didSet {
            calendarView.reloadData()
        }
    }
    var selectedDate: Date? = nil {
        didSet {
            calendarView.select(nil, scrollToDate: false)
        }
    }

    weak var delegate: CalendarCellLogsDelegate?
    var didSelectDate: ((Date)->())? = nil
    var didTapDisclosure: (()->())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()

        adherenceIconImageView.tintColor = .primaryColor
        calendarView.scope = .week
        shadowView.dropShadow(radius: 8,
                              offset: CGSize(width: 0, height: 1),
                              color: .black.withAlphaComponent(0.06),
                              shadowRadius: 2,
                              shadowOpacity: 1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds,
                                                   cornerRadius: 8).cgPath
    }
    
    @IBAction func disclosureButtonTapped(_ sender: Any) {
        self.didTapDisclosure?()
    }
}

// MARK: - Helper methods
extension CalendarCell {

    func configure(currentDate: Date?, calendarScope: FSCalendarScope) {

        let (startdate, enddate) = getCurrentDates()
        getDayLogsFrom(fromDate: startdate, toDate: enddate)
        customizeCalenderView(currentDate: currentDate, scope: calendarScope)
        delegate?.getDayLogs(startDate: startdate, endDate: enddate)
        self.calendarView.select(currentDate)
        configureDateUI()
        if calendarScope == .week {
            self.titleLabel.text = "Weekly Adherence"
        } else {
            self.titleLabel.text = "Monthly Adherence"
        }
    }

    func configureDateUI() {

        let (startDate, endDate) = getCurrentDates()
        nextDateView.alpha = Date() > startDate.startOfToday && Date() < endDate ? 0.5 : 1
        disclosureButton.transform = CGAffineTransform(rotationAngle: calendarView.scope == .month ? .pi/2 : 0)
        
        if calendarView.scope == .month {
            let dateFormatterr = DateFormatter()
            dateFormatterr.dateFormat = DateFormatString.MMMM_yyyy
            let month = dateFormatterr.string(from: calendarView.currentPage)
            dateLabel.text = month
        } else {
            let (startDate, endDate) = getCurrentDates()
            let dateFormatterr = DateFormatter()
            dateFormatterr.dateFormat = DateFormatString.M_d_yyyy2
            if Date() > startDate.startOfToday && Date() < endDate {
                dateLabel.text = "This week"
            } else {
                dateLabel.text = "\(dateFormatterr.string(from: startDate)) - \(dateFormatterr.string(from: endDate))"
            }
        }
    }

    private func getDayLogsFrom(fromDate: Date, toDate: Date) {
        PassioInternalConnector.shared.fetchDayLogFor(fromDate: fromDate,
                                                      toDate: toDate) { [weak self] (dayLogs) in
            guard let self = self else { return }
            self.calendarActivityIndicator.startAnimating()
            DispatchQueue.main.async {
                let logs = dayLogs.filter { !$0.records.isEmpty }
                let dates = logs.map { $0.date }
                self.loggedRecordsDates = dates.map { self.dateFormatter.string(from: $0) }
                self.calendarActivityIndicator.stopAnimating()
            }
        }
    }

    private func customizeCalenderView(currentDate: Date?, scope: FSCalendarScope) {
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.scope = scope
        calendarView.scrollEnabled = false
        calendarView.pagingEnabled = false
        calendarView.calendarHeaderView.isHidden = true
        calendarView.headerHeight = 6.0
        calendarView.appearance.caseOptions = [.headerUsesUpperCase]
        calendarView.appearance.headerTitleFont      = UIFont.systemFont(ofSize: 30, weight: .semibold)
        calendarView.appearance.headerDateFormat     = DateFormatString.MMMM_yyyy
        calendarView.appearance.weekdayFont          = .inter(type: .medium, size: 14)
        calendarView.appearance.weekdayTextColor     = .gray700
        calendarView.appearance.titleFont            = .inter(type: .semiBold, size: 12)
        calendarView.appearance.selectionColor       =  .primaryColor
        calendarView.appearance.titleSelectionColor  = .white
        calendarView.appearance.titleDefaultColor  = .gray700
        calendarView.collectionViewLayout.sectionInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        calendarView.delegate?.calendarCurrentPageDidChange?(calendarView)
    }

    private func getCurrentDates() -> (startDate: Date, endDate: Date) {
        let startDate: Date
        let endDate: Date
        if calendarView.scope == .week {
            startDate = calendarView.currentPage
            endDate = calendarView.gregorian.date(byAdding: .day, value: 6, to: startDate) ?? Date()
        } else { // .month
            let indexPath = calendarView.calculator.indexPath(for: calendarView.currentPage, scope: .month)
            startDate = calendarView.calculator.monthHead(forSection: (indexPath?.section)!)!
            endDate = calendarView.gregorian.date(byAdding: .day, value: 41, to: startDate) ?? Date()
        }
        return (startDate, endDate)
    }

    @IBAction func onNextPrevButtonPressed(_ sender: UIButton) {
        let setDate: (component: Calendar.Component, value: Int) = calendarView.scope == .week ? (.day, -7) : (.month, -1)
        let dateValue = sender.tag == 1 ? setDate.value : abs(setDate.value)
        let date = Calendar.current.date(byAdding: setDate.component,
                                         value: dateValue,
                                         to: calendarView.currentPage)!
        calendarView.setCurrentPage(date, animated: true)
    }
}

// MARK: - FSCalender Datasource and delegate
extension CalendarCell: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    func calendar(_ calendar: FSCalendar, 
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        self.didSelectDate?(date)
    }
    
    func calendar(_ calendar: FSCalendar,
                  boundingRectWillChange bounds: CGRect,
                  animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        layoutIfNeeded()
    }

    func calendar(_ calendar: FSCalendar,
                  shouldSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) -> Bool {
        true
    }

    func calendar(_ calendar: FSCalendar,
                  willDisplay cell: FSCalendarCell,
                  for date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        cell.frame.size = CGSize(width: 54, height: 35)
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  fillDefaultColorFor date: Date) -> UIColor? {
        if let sd = selectedDate, sd.isSameDayAs(date) {
            return .primaryColor
        }
        if loggedRecordsDates.contains(dateFormatter.string(from: date)) {
            return .green100
        }
        if date < Date() {
            return .red100
        }
        return .indigo50
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  borderDefaultColorFor date: Date) -> UIColor? {
        return date.isToday ? .primaryColor : .clear
    }

    func calendar(_ calendar: FSCalendar,
                  appearance: FSCalendarAppearance,
                  titleDefaultColorFor date: Date) -> UIColor? {
        if let sd = selectedDate, sd.isSameDayAs(date) {
            return .white
        }
        if loggedRecordsDates.contains(dateFormatter.string(from: date)) {
            return .green800
        }
        if date < Date() {
            return .red800
        }
        return .gray400
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let (startdate, enddate) = getCurrentDates()
        getDayLogsFrom(fromDate: startdate, toDate: enddate)
        configureDateUI()
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        Date()
    }
}
