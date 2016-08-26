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

let TimeIntervalMinute: NSTimeInterval = 60
let TimeIntervalHour:   NSTimeInterval = 3600
let TimeIntervalDay:    NSTimeInterval = 86400
let TimeIntervalWeek:   NSTimeInterval = 604800
let TimeIntervalYear:   NSTimeInterval = 31556926

let DateComponents: NSCalendarUnit = [
    .Year, .Month, .Day, .WeekOfYear, .Weekday, .WeekdayOrdinal, .Hour, .Minute, .Second
]

public extension NSDate {
    
    /********************************************************************************************************/
    // MARK: String Date Methods
    /********************************************************************************************************/
    
    convenience init?(string: String, format: String, locale: String? = nil) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        if let locale = locale {
            formatter.locale = NSLocale(localeIdentifier: locale)
        }
        if let date = formatter.dateFromString(string) {
            self.init(timeInterval:0, sinceDate:date)
        } else {
            self.init(timeInterval:0, sinceDate:NSDate())
            return nil
        }
    }
    
    public func stringWithFormat(format: String, locale: String? = nil) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format;
        if let locale = locale {
            formatter.locale = NSLocale(localeIdentifier: locale)
        }
        return formatter.stringFromDate(self)
    }
    
    public func stringWithFormat(dateStyle dateStyle: NSDateFormatterStyle? = nil, timeStyle: NSDateFormatterStyle? = nil, locale: String? = nil) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle ?= dateStyle;
        formatter.timeStyle ?= timeStyle;
        if let locale = locale {
            formatter.locale = NSLocale(localeIdentifier: locale)
        }
        return formatter.stringFromDate(self)
    }
    
    public func shortDateString(locale locale: String? = nil) -> String {
        //return stringWithFormat(dateStyle: .ShortStyle, locale: locale)
        return stringWithFormat((locale?.containsString("es") ?? false ? "dd/MM/yyyy" : "MM/dd/yyyy"), locale: locale)
    }
    
    public func mediumDateString(locale locale: String? = nil) -> String {
        return stringWithFormat("EEEE d MMM", locale: locale)
    }
    
    public func longDateString(locale locale: String? = nil) -> String {
        return stringWithFormat((locale?.containsString("es") ?? false ? "EEEE d 'de' MMMM" : "EEEE d MMMM"), locale: locale)
    }
    
    public func timeString(locale locale: String? = nil) -> String {
        return stringWithFormat("h:mm a", locale: locale)
    }
    
    public func time24String(locale locale: String? = nil) -> String {
        return stringWithFormat("H:mm", locale: locale)
    }
    
    public func timeAgoString(exact: Bool = false, locale: String? = nil) -> String {
        var timeAgoValue: Int!
        var timeAgoUnit:  String!
        let secondsAgo = NSTimeInterval(secondsBeforeNow()) 
        if (secondsAgo < TimeIntervalMinute) { // Smaller than a minute
            if !exact || secondsAgo < 1 { return (locale?.containsString("es") ?? false ? "Ahora" : "Now") }
            timeAgoValue = Int(secondsAgo)
            timeAgoUnit  = (locale?.containsString("es") ?? false ? "segundo" : "seconds")
        } else if (secondsAgo < TimeIntervalHour) { // Smaller than an hour
            timeAgoValue = Int(floor(secondsAgo/(TimeIntervalMinute)))
            timeAgoUnit  = (locale?.containsString("es") ?? false ? "minuto" : "minute")
        } else if (secondsAgo < TimeIntervalDay) { // Smaller than a day
            timeAgoValue = Int(floor(secondsAgo/(TimeIntervalHour)))
            timeAgoUnit  = (locale?.containsString("es") ?? false ? "hora" : "hour")
        } else { // Bigger than a day
            timeAgoValue = Int(floor(secondsAgo/(TimeIntervalDay)))
            timeAgoUnit  = (locale?.containsString("es") ?? false ? "día" : "day")
        }
        let timeAgoPlural = (timeAgoValue == 1 ? "" : "s")
        if (locale?.containsString("es") ?? false) {
            return "Hace \(timeAgoValue) \(timeAgoUnit)\(timeAgoPlural)"
        } else {
            return "\(timeAgoValue) \(timeAgoUnit)\(timeAgoPlural) ago"
        }
        
    }
    
    public func tinyTimeAgoString(locale: String? = nil) -> String {
        var timeAgoValue: Int!
        var timeAgoUnit:  String!
        let secondsAgo = NSTimeInterval(secondsBeforeNow())
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
    
    public func isSameDayAsDate(date: NSDate) -> Bool {
        let components1 = self.components()
        let components2 = date.components()
        return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day))
    }
    
    public func isToday() -> Bool {
        return isSameDayAsDate(NSDate())
    }
    
    public func isTomorrow() -> Bool {
        return isSameDayAsDate(NSDate().dateByAddingDays(1))
    }
    
    public func isYesterday() -> Bool {
        return isSameDayAsDate(NSDate().dateBySubtractingDays(1))
    }
    
    public func isSameWeekAsDate(date: NSDate) -> Bool {
        let components1 = self.components()
        let components2 = date.components()
        
        // Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
        if (components1.weekOfYear != components2.weekOfYear) { return false }
        
        // Must have a time interval under 1 week. Thanks @aclark
        return (abs(self.timeIntervalSinceDate(date)) < TimeIntervalWeek)
    }
    
    public func isThisWeek() -> Bool {
        return isSameWeekAsDate(NSDate())
    }
    
    public func isNextWeek() -> Bool {
        return isSameWeekAsDate(NSDate().dateByAddingDays(7))
    }
    
    public func isLastWeek() -> Bool {
        return isSameWeekAsDate(NSDate().dateBySubtractingDays(7))
    }
    
    public func isSameMonthAsDate(date: NSDate) -> Bool {
        let components1 = self.components()
        let components2 = date.components()
        return ((components1.month == components2.month) &&
            (components1.year == components2.year))
    }
    
    public func isThisMonth() -> Bool {
        return isSameMonthAsDate(NSDate())
    }
    
    public func isSameYearAsDate(date: NSDate) -> Bool {
        let components1 = self.components()
        let components2 = date.components()
        return (components1.year == components2.year)
    }
    
    public func isThisYear() -> Bool {
        return isSameYearAsDate(NSDate())
    }
    
    public func isEarlierThanDate(date: NSDate) -> Bool {
        return (self.compare(date) == .OrderedAscending)
    }
    
    public func isLaterThanDate(date: NSDate) -> Bool {
        return (self.compare(date) == .OrderedDescending)
    }
    
    public func isBetweenDates(dateStart dateStart: NSDate, dateEnd: NSDate, including: Bool) -> Bool {
        if including && isEqualToDate(dateStart) { return true }
        if including && isEqualToDate(dateEnd)   { return true }
        return isLaterThanDate(dateStart) && isEarlierThanDate(dateEnd)
    }
    
    public func isBetweenDays(dateStart dateStart: NSDate, dateEnd: NSDate, including: Bool) -> Bool {
        if isSameDayAsDate(dateStart) { return including }
        if isSameDayAsDate(dateEnd)   { return including }
        return isLaterThanDate(dateStart) && isEarlierThanDate(dateEnd)
    }
    
    public func isInPast() -> Bool {
        return isEarlierThanDate(NSDate())
    }
    
    public func isInFuture() -> Bool {
        return isLaterThanDate(NSDate())
    }
    
    /********************************************************************************************************/
    // MARK: Adjusting Date Methods
    /********************************************************************************************************/
    
    public func dateByAddingDays(days: Int) -> NSDate {
        let timeInterval = self.timeIntervalSinceReferenceDate+TimeIntervalDay*Double(days)
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateBySubtractingDays(days: Int) -> NSDate {
        return dateByAddingDays(-days)
    }
    
    public func dateByAddingHours(hours: Int) -> NSDate {
        let timeInterval = self.timeIntervalSinceReferenceDate+TimeIntervalHour*Double(hours)
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateBySubtractingHours(hours: Int) -> NSDate {
        return dateByAddingHours(-hours)
    }
    
    public func dateByAddingMinutes(minutes: Int) -> NSDate {
        let timeInterval = self.timeIntervalSinceReferenceDate+TimeIntervalMinute*Double(minutes)
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateBySubtractingMinutes(minutes: Int) -> NSDate {
        return dateByAddingMinutes(-minutes)
    }
    
    public func dateByAddingSeconds(seconds: Int) -> NSDate {
        let timeInterval = self.timeIntervalSinceReferenceDate+Double(seconds)
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    public func dateBySubtractingSeconds(seconds: Int) -> NSDate {
        return dateByAddingSeconds(-seconds)
    }
    
    public func dateAtStartOfDay(locale locale: String? = nil) -> NSDate {
        let components = self.components(locale: locale)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let calendar = NSCalendar.currentCalendar()
        if let locale = locale {
            calendar.locale = NSLocale(localeIdentifier: locale)
        }
        return calendar.dateFromComponents(components)!
    }
    
    public func dateAtStartOfWeek(locale locale: String? = nil) -> NSDate {
        return self.dateBySubtractingDays(self.weekday(locale: locale)).dateAtStartOfDay(locale: locale)
    }
    
    /********************************************************************************************************/
    // MARK: Decomposing Date Methods
    /********************************************************************************************************/
    
    private func components(locale locale: String? = nil) -> NSDateComponents {
        let calendar = NSCalendar.currentCalendar()
        if let locale = locale {
            calendar.locale = NSLocale(localeIdentifier: locale)
        }
        return calendar.components(DateComponents, fromDate: self)
    }
    
    public func nearestHour(locale locale: String? = nil) -> Int {
        let timeInterval = self.timeIntervalSinceReferenceDate+TimeIntervalMinute*30
        let newDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
        return newDate.components(locale: locale).hour
    }
    
    public func minute(locale locale: String? = nil) -> Int {
        return components(locale: locale).minute
    }
    
    public func second(locale locale: String? = nil) -> Int {
        return components(locale: locale).second
    }
    
    public func hour(locale locale: String? = nil) -> Int {
        return components(locale: locale).hour
    }
    
    public func hour12(locale locale: String? = nil) -> Int {
        let hour24 = hour(locale: locale)
        return hour24 > 12 ? hour24-12 : hour24
    }
    
    public func day(locale locale: String? = nil) -> Int {
        return components(locale: locale).day
    }
    
    public func week(locale locale: String? = nil) -> Int {
        return components(locale: locale).weekOfYear
    }
    
    public func weekday(locale locale: String? = nil) -> Int {
        var weekDay = components(locale: locale).weekday-2 //1 es domingo
        if weekDay < 0 { weekDay += 7 }
        return weekDay
    }
    
    public func nthWeekday(locale locale: String? = nil) -> Int { // e.g. 2nd Tuesday of the month is 2
        return components(locale: locale).weekdayOrdinal
    }
    
    public func month(locale locale: String? = nil) -> Int {
        return components(locale: locale).month
    }
    
    public func monthName(locale locale: String? = nil) -> String {
        return stringWithFormat("MMMM", locale: locale)
    }
    
    public func year(locale locale: String? = nil) -> Int {
        return components(locale: locale).year
    }
    
    public func dayOfWeek() -> DayOfWeek {
        // Force Peru for Monday = 0
        return DayOfWeek(rawValue: weekday(locale: "es_PE"))!
    }
    
    /********************************************************************************************************/
    // MARK: Retrieving Intervals Date Methods
    /********************************************************************************************************/
    
    public func secondsAfterNow() -> Int {  // In ## Seconds
        return secondsAfterDate(NSDate())
    }
    
    public func secondsBeforeNow() -> Int { // ## Seconds Ago
        return secondsBeforeDate(NSDate())
    }
    
    public func secondsAfterDate(date: NSDate) -> Int {
        let timeInterval = self.timeIntervalSinceDate(date)
        return Int(timeInterval)
    }
    
    public func secondsBeforeDate(date: NSDate) -> Int {
        let timeInterval = date.timeIntervalSinceDate(self)
        return Int(timeInterval)
    }
    
    public func minutesAfterDate(date: NSDate) -> Int {
        let timeInterval = self.timeIntervalSinceDate(date)
        return Int(timeInterval/TimeIntervalMinute)
    }
    
    public func minutesBeforeDate(date: NSDate) -> Int {
        let timeInterval = date.timeIntervalSinceDate(self)
        return Int(timeInterval/TimeIntervalMinute)
    }
    
    public func hoursAfterDate(date: NSDate) -> Int {
        let timeInterval = self.timeIntervalSinceDate(date)
        return Int(timeInterval/TimeIntervalHour)
    }
    
    public func hoursBeforeDate(date: NSDate) -> Int {
        let timeInterval = date.timeIntervalSinceDate(self)
        return Int(timeInterval/TimeIntervalHour)
    }
    
    public func daysAfterDate(date: NSDate) -> Int {
        let timeInterval = self.timeIntervalSinceDate(date)
        return Int(timeInterval/TimeIntervalDay)
    }
    
    public func daysBeforeDate(date: NSDate) -> Int {
        let timeInterval = date.timeIntervalSinceDate(self)
        return Int(timeInterval/TimeIntervalDay)
    }
    
}

public enum DayOfWeek: Int, Equatable {
    case Monday = 0, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    
    public init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .Monday
        case 1: self = .Tuesday
        case 2: self = .Wednesday
        case 3: self = .Thursday
        case 4: self = .Friday
        case 5: self = .Saturday
        case 6: self = .Sunday
        default: return nil
        }
    }
    
    public init?(string: String) {
        switch string.uppercaseString.trim() {
        case "LUNES":     self = .Monday
        case "MARTES":    self = .Tuesday
        case "MIERCOLES": self = .Wednesday
        case "MIÉRCOLES": self = .Wednesday
        case "JUEVES":    self = .Thursday
        case "VIERNES":   self = .Friday
        case "SABADO":    self = .Saturday
        case "SÁBADO":    self = .Saturday
        case "DOMINGO":   self = .Sunday
        case "MONDAY":    self = .Monday
        case "TUESDAY":   self = .Tuesday
        case "WEDNESDAY": self = .Wednesday
        case "THURSDAY":  self = .Thursday
        case "FRIDAY":    self = .Friday
        case "SATURDAY":  self = .Saturday
        case "SUNDAY":    self = .Sunday
        default:          return nil
        }
    }
    
    public var name: String {
        switch self {
        case .Monday:    return "Lunes"
        case .Tuesday:   return "Martes"
        case .Wednesday: return "Miércoles"
        case .Thursday:  return "Jueves"
        case .Friday:    return "Viernes"
        case .Saturday:  return "Sábado"
        case .Sunday:    return "Domingo"
        }
    }
    
    // TODO: Should this be here?
    public var alternateRawValue: Int {
        var alternateRawValue = rawValue+2
        if alternateRawValue > 7 { alternateRawValue -= alternateRawValue }
        return alternateRawValue
    }
    
}
