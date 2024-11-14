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
    
    var startOfGivenDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfGivenDay: Date {
        // Get the start of the next day, and subtract 1 second to get the last second of the current day
        let startOfNextDay = Calendar.current.date(byAdding: .day, value: 1, to: self)!
        return startOfNextDay.addingTimeInterval(-1)
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

    func startAndEndOfWeek(calendar: Calendar = .current, daysUpTo: Int = 6) -> (start: Date, end: Date)? {
        // Get the start of the week
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                                            from: self)) else {
            return nil
        }
        // Get the end of the week
        guard let endOfWeek = calendar.date(byAdding: DateComponents(day: daysUpTo), to: startOfWeek) else {
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
    
    func startAndEndOfMonthForTracking(calendar: Calendar = .current) -> (start: Date, end: Date)? {
        // Get the start of the month
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)) else {
            return nil
        }
        
        // Get the range of days in the current month
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        
        // Ensure the range is valid (it should never be nil)
        guard let dayRange = range, let lastDayOfMonth = dayRange.last else {
            return nil
        }
        
        // Get the end of the month by adding (lastDayOfMonth - 1) days to the start of the month
        guard let endOfMonth = calendar.date(byAdding: .day, value: lastDayOfMonth, to: startOfMonth) else {
            return nil
        }
        
        return (startOfMonth, endOfMonth)
    }
    
    func getTimeIntervalInSeconds(fromTime: Date) -> String {
        return "\(self.timeIntervalSince(fromTime).roundDigits(afterDecimal: 3)) Seconds"
    }
    
    //Merge two dates to make single Date
    static func combineTwoDate(dateToFetch: Date, timeToFetch: Date) -> Date? {
        // Create a calendar instance
        let calendar = Calendar.current
        
        // Extract the date components (year, month, day) from the first date
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: dateToFetch)
        
        // Extract the time components (hour, minute, second) from the second date
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeToFetch)
        
        // Merge the components: use date's year, month, day and time's hour, minute, second
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = timeComponents.second
        
        // Combine the components into a new Date object
        return calendar.date(from: mergedComponents)
    }
    
    var isDateLessThanTodayIgnoringTime: Bool {
        
        let calendar = Calendar.current
        
        // Get today's date with the time set to midnight
        let today = calendar.startOfDay(for: Date())
        
        // Extract only the year, month, and day components of the given date and today's date
        let givenDateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        // Create a new date from the components (ignoring the time part)
        guard let normalizedGivenDate = calendar.date(from: givenDateComponents),
              let normalizedToday = calendar.date(from: todayComponents) else {
            return false
        }
        
        // Compare the two dates
        return normalizedGivenDate < normalizedToday
    }
    
    static func isTodayDateWithFutureTime(date: Date, time: Date) -> Bool {
        let calendar = Calendar.current
        
        // Get today's date at midnight (no time part, just year, month, day)
        let today = calendar.startOfDay(for: Date())
        
        // Compare the selected date with today's date
        let isSameDay = calendar.isDate(date, inSameDayAs: today)
        
        // If it's the same day, check if the time is in the future
        if isSameDay {
            // Get the current time today (with today's date and the current time)
            let currentTimeToday = calendar.date(bySettingHour: calendar.component(.hour, from: Date()),
                                                 minute: calendar.component(.minute, from: Date()),
                                                 second: 0, of: today)!
            
            // Compare if the selected time is in the future compared to current time
            return time > currentTimeToday
        }
        
        // Return false if the date is not today
        return false
    }

}
