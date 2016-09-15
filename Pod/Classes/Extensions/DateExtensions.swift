//
//  DateExtensions.swift
//  StartAppsKit
//
//  Created by Gabriel Lanata on 11/16/14.
//  Credits to Erika Sadun (NSDate-Utilities)
//  Copyright (c) 2014 StartApps. All rights reserved.
//  Version: 1.0
//

import Foundation

private var _forcedNowDate: Date?
public extension Date {
    
    public static var forcedNow: Date? {
        set { _forcedNowDate = newValue }
        get { return _forcedNowDate }
    }
    
    public static func now() -> Date {
        return _forcedNowDate ?? Date()
    }
    
}

let TimeIntervalMinute: TimeInterval = 60
let TimeIntervalHour:   TimeInterval = 3600
let TimeIntervalDay:    TimeInterval = 86400
let TimeIntervalWeek:   TimeInterval = 604800
let TimeIntervalYear:   TimeInterval = 31556926

let DateComponents: NSCalendar.Unit = [
    .year, .month, .day, .weekOfYear, .weekday, .weekdayOrdinal, .hour, .minute, .second
]

public extension Date {
    
    /********************************************************************************************************/
    // MARK: String Date Methods
    /********************************************************************************************************/
    
    public init?(string: String, format: String, locale: String? = nil) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let locale = locale {
            formatter.locale = Locale(identifier: locale)
        }
        if let date = formatter.date(from: string) {
            self.init(timeInterval:0, since:date)
        } else {
            self.init(timeInterval:0, since:Date.now())
            return nil
        }
    }
    
    public func string(format format: String, locale: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format;
        if let locale = locale {
            formatter.locale = Locale(identifier: locale)
        }
        return formatter.string(from: self)
    }
    
    public func string(dateStyle: DateFormatter.Style? = nil, timeStyle: DateFormatter.Style? = nil, locale: String? = nil) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle ?= dateStyle;
        formatter.timeStyle ?= timeStyle;
        if let locale = locale {
            formatter.locale = Locale(identifier: locale)
        }
        return formatter.string(from: self)
    }
    
    public func shortDateString(locale: String? = nil) -> String {
        //return string(format: dateStyle: .ShortStyle, locale: locale)
        return string(format: (locale?.contains("es") ?? false ? "dd/MM/yyyy" : "MM/dd/yyyy"), locale: locale)
    }
    
    public func mediumDateString(locale: String? = nil) -> String {
        return string(format: "EEEE d MMM", locale: locale)
    }
    
    public func longDateString(locale: String? = nil) -> String {
        return string(format: (locale?.contains("es") ?? false ? "EEEE d 'de' MMMM" : "EEEE d MMMM"), locale: locale)
    }
    
    public func timeString(locale: String? = nil) -> String {
        return string(format: "h:mm a", locale: locale)
    }
    
    public func time24String(locale: String? = nil) -> String {
        return string(format: "H:mm", locale: locale)
    }
    
    public func timeAgoString(exact: Bool = false, locale: String? = nil) -> String {
        var timeAgoValue: Int!
        var timeAgoUnit:  String!
        let secondsAgo = TimeInterval(secondsBeforeNow()) 
        if (secondsAgo < TimeIntervalMinute) { // Smaller than a minute
            if !exact || secondsAgo < 1 { return (locale?.contains("es") ?? false ? "Ahora" : "Now") }
            timeAgoValue = Int(secondsAgo)
            timeAgoUnit  = (locale?.contains("es") ?? false ? "segundo" : "seconds")
        } else if (secondsAgo < TimeIntervalHour) { // Smaller than an hour
            timeAgoValue = Int(floor(secondsAgo/(TimeIntervalMinute)))
            timeAgoUnit  = (locale?.contains("es") ?? false ? "minuto" : "minute")
        } else if (secondsAgo < TimeIntervalDay) { // Smaller than a day
            timeAgoValue = Int(floor(secondsAgo/(TimeIntervalHour)))
            timeAgoUnit  = (locale?.contains("es") ?? false ? "hora" : "hour")
        } else { // Bigger than a day
            timeAgoValue = Int(floor(secondsAgo/(TimeIntervalDay)))
            timeAgoUnit  = (locale?.contains("es") ?? false ? "día" : "day")
        }
        let timeAgoPlural = (timeAgoValue == 1 ? "" : "s")
        if (locale?.contains("es") ?? false) {
            return "Hace \(timeAgoValue) \(timeAgoUnit)\(timeAgoPlural)"
        } else {
            return "\(timeAgoValue) \(timeAgoUnit)\(timeAgoPlural) ago"
        }
        
    }
    
    public func tinyTimeAgoString(_ locale: String? = nil) -> String {
        var timeAgoValue: Int!
        var timeAgoUnit:  String!
        let secondsAgo = TimeInterval(secondsBeforeNow())
        if (secondsAgo < TimeIntervalMinute) { // Smaller than a minute
            timeAgoValue = Int(secondsAgo)
            timeAgoUnit  = "s"
        } else if (secondsAgo < TimeIntervalHour) { // Smaller than an hour
            timeAgoValue = Int(floor(secondsAgo/(TimeIntervalMinute)))
            timeAgoUnit  = "m"
        } else if (secondsAgo < TimeIntervalDay) { // Smaller than a day
            timeAgoValue = Int(floor(secondsAgo/(TimeIntervalHour)))
            timeAgoUnit  = "h"
        } else { // Bigger than two days
            timeAgoValue = Int(floor(secondsAgo/(TimeIntervalDay)))
            timeAgoUnit  = "d"
        }
        return "\(timeAgoValue)\(timeAgoUnit)"
    }
    
    /********************************************************************************************************/
    // MARK: Comparing Date Methods
    /********************************************************************************************************/
    
    public func isSameDayAsDate(_ date: Date) -> Bool {
        let components1 = self.components()
        let components2 = date.components()
        return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day))
    }
    
    public func isToday() -> Bool {
        return isSameDayAsDate(Date.now())
    }
    
    public func isTomorrow() -> Bool {
        return isSameDayAsDate(Date.now().dateByAddingDays(1))
    }
    
    public func isYesterday() -> Bool {
        return isSameDayAsDate(Date.now().dateBySubtractingDays(1))
    }
    
    public func isSameWeekAsDate(_ date: Date) -> Bool {
        let components1 = self.components()
        let components2 = date.components()
        
        // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
        if (components1.weekOfYear != components2.weekOfYear) { return false }
        
        // Must have a time interval under 1 week. Thanks @aclark
        return (abs(self.timeIntervalSince(date)) < TimeIntervalWeek)
    }
    
    public func isThisWeek() -> Bool {
        return isSameWeekAsDate(Date.now())
    }
    
    public func isNextWeek() -> Bool {
        return isSameWeekAsDate(Date.now().dateByAddingDays(7))
    }
    
    public func isLastWeek() -> Bool {
        return isSameWeekAsDate(Date.now().dateBySubtractingDays(7))
    }
    
    public func isSameMonthAsDate(_ date: Date) -> Bool {
        let components1 = self.components()
        let components2 = date.components()
        return ((components1.month == components2.month) &&
            (components1.year == components2.year))
    }
    
    public func isThisMonth() -> Bool {
        return isSameMonthAsDate(Date.now())
    }
    
    public func isSameYearAsDate(_ date: Date) -> Bool {
        let components1 = self.components()
        let components2 = date.components()
        return (components1.year == components2.year)
    }
    
    public func isThisYear() -> Bool {
        return isSameYearAsDate(Date.now())
    }
    
    public func isEarlierThanDate(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedAscending)
    }
    
    public func isLaterThanDate(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }
    
    public func isBetweenDates(dateStart: Date, dateEnd: Date, including: Bool) -> Bool {
        if including && isSameDayAsDate(dateStart) { return true }
        if including && isSameDayAsDate(dateEnd)   { return true }
        return isLaterThanDate(dateStart) && isEarlierThanDate(dateEnd)
    }
    
    public func isBetweenDays(dateStart: Date, dateEnd: Date, including: Bool) -> Bool {
        if isSameDayAsDate(dateStart) { return including }
        if isSameDayAsDate(dateEnd)   { return including }
        return isLaterThanDate(dateStart) && isEarlierThanDate(dateEnd)
    }
    
    public func isInPast() -> Bool {
        return isEarlierThanDate(Date.now())
    }
    
    public func isInFuture() -> Bool {
        return isLaterThanDate(Date.now())
    }
    
    /********************************************************************************************************/
    // MARK: Adjusting Date Methods
    /********************************************************************************************************/
    
    public func dateByAddingDays(_ days: Int) -> Date {
        let timeInterval = self.timeIntervalSinceReferenceDate+TimeIntervalDay*Double(days)
        let newDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateBySubtractingDays(_ days: Int) -> Date {
        return dateByAddingDays(-days)
    }
    
    public func dateByAddingHours(_ hours: Int) -> Date {
        let timeInterval = self.timeIntervalSinceReferenceDate+TimeIntervalHour*Double(hours)
        let newDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateBySubtractingHours(_ hours: Int) -> Date {
        return dateByAddingHours(-hours)
    }
    
    public func dateByAddingMinutes(_ minutes: Int) -> Date {
        let timeInterval = self.timeIntervalSinceReferenceDate+TimeIntervalMinute*Double(minutes)
        let newDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateBySubtractingMinutes(_ minutes: Int) -> Date {
        return dateByAddingMinutes(-minutes)
    }
    
    public func dateByAddingSeconds(_ seconds: Int) -> Date {
        let timeInterval = self.timeIntervalSinceReferenceDate+Double(seconds)
        let newDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateBySubtractingSeconds(_ seconds: Int) -> Date {
        return dateByAddingSeconds(-seconds)
    }
    
    public func dateAtStartOfDay(locale: String? = nil) -> Date {
        var components = self.components(locale: locale)
        components.hour = 0
        components.minute = 0
        components.second = 0
        var calendar = Calendar.current
        if let locale = locale {
            calendar.locale = Locale(identifier: locale)
        }
        return calendar.date(from: components)!
    }
    
    public func dateAtStartOfWeek(locale: String? = nil) -> Date {
        return self.dateBySubtractingDays(self.weekday(locale: locale)).dateAtStartOfDay(locale: locale)
    }
    
    /********************************************************************************************************/
    // MARK: Decomposing Date Methods
    /********************************************************************************************************/
    
    fileprivate func components(locale: String? = nil) -> Foundation.DateComponents {
        var calendar = Calendar.current
        if let locale = locale {
            calendar.locale = Locale(identifier: locale)
        }
        return (calendar as NSCalendar).components(DateComponents, from: self)
    }
    
    public func nearestHour(locale: String? = nil) -> Int {
        let timeInterval = self.timeIntervalSinceReferenceDate+TimeIntervalMinute*30
        let newDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate.components(locale: locale).hour!
    }
    
    public func minute(locale: String? = nil) -> Int {
        return components(locale: locale).minute!
    }
    
    public func second(locale: String? = nil) -> Int {
        return components(locale: locale).second!
    }
    
    public func hour(locale: String? = nil) -> Int {
        return components(locale: locale).hour!
    }
    
    public func hour12(locale: String? = nil) -> Int {
        let hour24 = hour(locale: locale)
        return hour24 > 12 ? hour24-12 : hour24
    }
    
    public func day(locale: String? = nil) -> Int {
        return components(locale: locale).day!
    }
    
    public func week(locale: String? = nil) -> Int {
        return components(locale: locale).weekOfYear!
    }
    
    public func weekday(locale: String? = nil) -> Int {
        var weekDay = components(locale: locale).weekday!-2 //1 es domingo
        if weekDay < 0 { weekDay += 7 }
        return weekDay
    }
    
    public func nthWeekday(locale: String? = nil) -> Int { // e.g. 2nd Tuesday of the month is 2
        return components(locale: locale).weekdayOrdinal!
    }
    
    public func month(locale: String? = nil) -> Int {
        return components(locale: locale).month!
    }
    
    public func monthName(locale: String? = nil) -> String {
        return string(format: "MMMM", locale: locale)
    }
    
    public func year(locale: String? = nil) -> Int {
        return components(locale: locale).year!
    }
    
    public func dayOfWeek() -> DayOfWeek {
        // Force Peru for Monday = 0
        return DayOfWeek(rawValue: weekday(locale: "es_PE"))!
    }
    
    /********************************************************************************************************/
    // MARK: Retrieving Intervals Date Methods
    /********************************************************************************************************/
    
    public func secondsAfterNow() -> Int {  // In ## Seconds
        return secondsAfterDate(Date.now())
    }
    
    public func secondsBeforeNow() -> Int { // ## Seconds Ago
        return secondsBeforeDate(Date.now())
    }
    
    public func secondsAfterDate(_ date: Date) -> Int {
        let timeInterval = self.timeIntervalSince(date)
        return Int(timeInterval)
    }
    
    public func secondsBeforeDate(_ date: Date) -> Int {
        let timeInterval = date.timeIntervalSince(self)
        return Int(timeInterval)
    }
    
    public func minutesAfterDate(_ date: Date) -> Int {
        let timeInterval = self.timeIntervalSince(date)
        return Int(timeInterval/TimeIntervalMinute)
    }
    
    public func minutesBeforeDate(_ date: Date) -> Int {
        let timeInterval = date.timeIntervalSince(self)
        return Int(timeInterval/TimeIntervalMinute)
    }
    
    public func hoursAfterDate(_ date: Date) -> Int {
        let timeInterval = self.timeIntervalSince(date)
        return Int(timeInterval/TimeIntervalHour)
    }
    
    public func hoursBeforeDate(_ date: Date) -> Int {
        let timeInterval = date.timeIntervalSince(self)
        return Int(timeInterval/TimeIntervalHour)
    }
    
    public func daysAfterDate(_ date: Date) -> Int {
        let timeInterval = self.timeIntervalSince(date)
        return Int(timeInterval/TimeIntervalDay)
    }
    
    public func daysBeforeDate(_ date: Date) -> Int {
        let timeInterval = date.timeIntervalSince(self)
        return Int(timeInterval/TimeIntervalDay)
    }
    
}

public enum DayOfWeek: Int, Equatable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    
    public init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .monday
        case 1: self = .tuesday
        case 2: self = .wednesday
        case 3: self = .thursday
        case 4: self = .friday
        case 5: self = .saturday
        case 6: self = .sunday
        default: return nil
        }
    }
    
    public init?(string: String) {
        switch string.uppercased().trim() {
        case "LUNES":     self = .monday
        case "MARTES":    self = .tuesday
        case "MIERCOLES": self = .wednesday
        case "MIÉRCOLES": self = .wednesday
        case "JUEVES":    self = .thursday
        case "VIERNES":   self = .friday
        case "SABADO":    self = .saturday
        case "SÁBADO":    self = .saturday
        case "DOMINGO":   self = .sunday
        case "MONDAY":    self = .monday
        case "TUESDAY":   self = .tuesday
        case "WEDNESDAY": self = .wednesday
        case "THURSDAY":  self = .thursday
        case "FRIDAY":    self = .friday
        case "SATURDAY":  self = .saturday
        case "SUNDAY":    self = .sunday
        default:          return nil
        }
    }
    
    public var name: String {
        switch self {
        case .monday:    return "Lunes"
        case .tuesday:   return "Martes"
        case .wednesday: return "Miércoles"
        case .thursday:  return "Jueves"
        case .friday:    return "Viernes"
        case .saturday:  return "Sábado"
        case .sunday:    return "Domingo"
        }
    }
    
    // TODO: Should this be here?
    public var alternateRawValue: Int {
        var alternateRawValue = rawValue+2
        if alternateRawValue > 7 { alternateRawValue -= alternateRawValue }
        return alternateRawValue
    }
    
}
