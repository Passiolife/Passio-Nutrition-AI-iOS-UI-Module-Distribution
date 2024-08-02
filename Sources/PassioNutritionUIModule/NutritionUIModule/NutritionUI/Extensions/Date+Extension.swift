//
//  Date+Extension.swift
//  BaseApp
//
//  Created by Nikunj Prajapati on 22/02/22.
//  Copyright © 2022 Passio Inc. All rights reserved.
//

import Foundation

extension Date {
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: self)
    }
    
    func dateFormatWithSuffix() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d'\(self.daySuffix())'"
        return dateFormatter.string(from: self)
    }

    func daySuffix() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self)
        let dayOfMonth = components.day
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }

    func get(_ components: Calendar.Component...,
             calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func getDayCountFromDate(date: Date, timeFroTrial: Double) -> Int {
        print("getDayCountFromDate = \(-date.timeIntervalSinceNow) -timeFroTrial = \(timeFroTrial)")
        guard -date.timeIntervalSinceNow < timeFroTrial  else {
            return 0
        }
        return Calendar.current.dateComponents([.day],
                                               from: date,
                                               to: self).day ?? 0
    }

    func convertDate(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.timeZone = TimeZone.autoupdatingCurrent
        let dateString = formatter.string(from: self)
        return dateString
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self) ?? Date()
    }

    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self) ?? Date()
    }

    var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }

    func isSameDayAs(_ date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    static func getDate(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? Date()
    }

    func startOfWeek(using calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents([.weekday, .year, .month, .weekOfYear],
                                                 from: self)
        components.weekday = calendar.firstWeekday
        return calendar.date(from: components) ?? self
    }

    func startAndEndOfWeek(calendar: Calendar = .current) -> (start: Date, end: Date)? {
        // Get the start of the week
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                                            from: self)) else {
            return nil
        }
        // Get the end of the week
        guard let endOfWeek = calendar.date(byAdding: DateComponents(day: 6), to: startOfWeek) else {
            return nil
        }
        return (startOfWeek, endOfWeek)
    }

    func startAndEndOfMonth(calendar: Calendar = .current) -> (start: Date, end: Date)? {
        // Get the start of the month
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month],
                                                                             from: self)) else {
            return nil
        }
        // Get the end of the month
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                             to: startOfMonth) else {
            return nil
        }
        return (startOfMonth, endOfMonth)
    }
}
