//
//  Date+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import Foundation
import CoreVideo

/// https://github.com/melvitax/DateHelper
public extension Date {
    
    /// 日期信息枚举
    enum ComponentType {
        case second, minute, hour, day, weekday, weekdayOrdinal, weekOfYear, month, quarter, year
    }
    
    /// 提取Date组件并获取对应的年月日时分秒等
    func component(_ type: ComponentType) -> Int {
        let components = dateComponents()
        switch type {
        case .second:
            return components.second!
        case .minute:
            return components.minute!
        case .hour:
            return components.hour!
        case .day:
            return components.day!
        case .weekday:
            return components.weekday!
        case .weekdayOrdinal:
            return components.weekdayOrdinal!
        case .weekOfYear:
            return components.weekOfYear!
        case .month:
            return components.month!
        case .quarter:
            return (component(.month) / 3 + 1)
        case .year:
            return components.year!
        }
    }
    
    /// 计算两日期相隔时间
    func since(_ date:Date, in component: ComponentType) -> Int64 {
        switch component {
        case .second:
            return Int64(timeIntervalSince(date))
        case .minute:
            let interval = timeIntervalSince(date)
            return Int64(interval / Date.seconds(of: .minute))
        case .hour:
            let interval = timeIntervalSince(date)
            return Int64(interval / Date.seconds(of: .hour))
        case .day:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .day, in: .era, for: self)
            let start = calendar.ordinality(of: .day, in: .era, for: date)
            return Int64(end! - start!)
        case .weekday:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .weekday, in: .era, for: self)
            let start = calendar.ordinality(of: .weekday, in: .era, for: date)
            return Int64(end! - start!)
        case .weekdayOrdinal:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .weekdayOrdinal, in: .era, for: self)
            let start = calendar.ordinality(of: .weekdayOrdinal, in: .era, for: date)
            return Int64(end! - start!)
        case .weekOfYear:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .weekOfYear, in: .era, for: self)
            let start = calendar.ordinality(of: .weekOfYear, in: .era, for: date)
            return Int64(end! - start!)
        case .month:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .month, in: .era, for: self)
            let start = calendar.ordinality(of: .month, in: .era, for: date)
            return Int64(end! - start!)
        case .quarter:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .quarter, in: .era, for: self)
            let start = calendar.ordinality(of: .quarter, in: .era, for: date)
            return Int64(end! - start!)
        case .year:
            let calendar = Calendar.current
            let end = calendar.ordinality(of: .year, in: .era, for: self)
            let start = calendar.ordinality(of: .year, in: .era, for: date)
            return Int64(end! - start!)
        }
    }
    
    /// 返回调整后的日期
    func adjust(_ component: ComponentType, offset: Int) -> Date {
        var dateComponent = DateComponents()
        switch component {
        case .second:
            dateComponent.second = offset
        case .minute:
            dateComponent.minute = offset
        case .hour:
            dateComponent.hour = offset
        case .day:
            dateComponent.day = offset
        case .weekday:
            dateComponent.weekday = offset
        case .weekdayOrdinal:
            dateComponent.weekdayOrdinal = offset
        case .weekOfYear:
            dateComponent.weekOfYear = offset
        case .month:
            dateComponent.month = offset
        case .quarter:
            dateComponent.quarter = offset
        case .year:
            dateComponent.year = offset
        }
        return Calendar.current.date(byAdding: dateComponent, to: self)!
    }
    
    /// 日期比较的类型枚举
    enum DateComparisonType {
        /// 是否为今天
        case isToday
        /// 是否为明天
        case isTomorrow
        /// 是否为昨天
        case isYesterday
        /// 是否与指定日期为同一天
        case isSameDay(Date)
        
        /// 是否为当前周
        case isThisWeek
        /// 是否为下一周
        case isNextWeek
        /// 是否为上一周
        case isLastWeek
        /// 是否与指定日期为同一周
        case isSameWeek(Date)
        
        /// 是否为当前月
        case isThisMonth
        /// 是否为下个月
        case isNextMonth
        /// 是否为上个月
        case isLastMonth
        /// 是否与指定日期为同一月
        case isSameMonth(Date)
        
        /// 是否为今年
        case isThisYear
        /// 是否为明年
        case isNextYear
        /// 是否为去年
        case isLastYear
        /// 是否与指定日期为同一年
        case isSameYear(Date)
        
        /// 是否为未来时间
        case isFuture
        /// 是否为过去时间
        case isPast
        /// 是否早于指定日期
        case isEarlier(than: Date)
        /// 是否晚于指定日期
        case isLater(than:Date)
        /// 是否为工作日
        case isWeekday
        /// 是否为周末
        case isWeekend
        
        /// 是否为闰月
        case isLeapMonth
        /// 是否为闰年
        case isLeapYear
    }
    
    /// 比较日期的某部分是否相等
    func compare(_ comparison: DateComparisonType) -> Bool {
        switch comparison {
        case .isToday:
            return compare(.isSameDay(Date()))
        case .isTomorrow:
            let adjusted = Date().adjust(.day, offset:1)
            return compare(.isSameDay(adjusted))
        case .isYesterday:
            let adjusted = Date().adjust(.day, offset: -1)
            return compare(.isSameDay(adjusted))
        case .isSameDay(let date):
            return component(.year) == date.component(.year)
            && component(.month) == date.component(.month)
            && component(.day) == date.component(.day)
        case .isThisWeek:
            return self.compare(.isSameWeek(Date()))
        case .isNextWeek:
            let adjusted = Date().adjust(.weekOfYear, offset:1)
            return compare(.isSameWeek(adjusted))
        case .isLastWeek:
            let adjusted = Date().adjust(.weekOfYear, offset:-1)
            return compare(.isSameWeek(adjusted))
        case .isSameWeek(let date):
            guard component(.weekOfYear) != date.component(.weekOfYear) else {
                return false
            }
            if component(.weekOfYear) != date.component(.weekOfYear) {
                return false
            }
            return abs(timeIntervalSince(date)) < Date.seconds(of: .week) // 确保时间间隔小于 1 周
            case .isThisMonth:
                return self.compare(.isSameMonth(Date()))
            case .isNextMonth:
                let adjusted = Date().adjust(.month, offset:1)
                return compare(.isSameMonth(adjusted))
            case .isLastMonth:
                let adjusted = Date().adjust(.month, offset:-1)
                return compare(.isSameMonth(adjusted))
            case .isSameMonth(let date):
                return component(.year) == date.component(.year) && component(.month) == date.component(.month)
            case .isThisYear:
                return self.compare(.isSameYear(Date()))
            case .isNextYear:
                let adjusted = Date().adjust(.year, offset:1)
                return compare(.isSameYear(adjusted))
            case .isLastYear:
                let adjusted = Date().adjust(.year, offset:-1)
                return compare(.isSameYear(adjusted))
            case .isSameYear(let date):
                return component(.year) == date.component(.year)
            case .isFuture:
                return compare(.isLater(than: Date()))
            case .isPast:
                return compare(.isEarlier(than: Date()))
            case .isEarlier(let date):
                return (self as NSDate).earlierDate(date) == self
            case .isLater(let date):
                return (self as NSDate).laterDate(date) == self
        case .isWeekday:
            return !compare(.isWeekend)
        case .isWeekend:
            let range = Calendar.current.maximumRange(of: Calendar.Component.weekday)!
            return (component(.weekday) == range.lowerBound || component(.weekday) == range.upperBound - range.lowerBound)
        case .isLeapMonth:
            return Calendar.current.dateComponents([.quarter], from: self).isLeapMonth ?? false
        case .isLeapYear:
            let year = component(.year)
            return (year % 400 == 0) || ((year % 100 != 0) && (year % 4 == 0))
        }
    }
    
    /// 日期已过去多久的枚举
    enum TimePassed {
        case year(Int), month(Int), day(Int), hour(Int), minute(Int), second(Int), now
    }
    
    /// 返回date距离当前日期已过去多久
    func timePassed() -> TimePassed {
        guard !compare(.isFuture) else { return .now }
        let flags: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let components = Calendar.autoupdatingCurrent.dateComponents(flags, from: self, to: Date())
        if components.year! >= 1 {
            return .year(components.year!)
        } else if components.month! >= 1 {
            return .month(components.month!)
        } else if components.day! >= 1 {
            return .day(components.day!)
        } else if components.hour! >= 1 {
            return .hour(components.hour!)
        } else if components.minute! >= 1 {
            return .minute(components.minute!)
        } else if components.second! >= 1 {
            return .second(components.second!)
        } else {
            return .now
        }
    }
    
    /// 将date转为字符串描述(对比当前日期)，如刚刚，1分钟前等等...
    func describeTimePassed() -> String {
        let passesd = timePassed()
        switch passesd {
        case .year(let year): return "\(year)年前"
        case .month(let month): return "\(month)个月前"
        case .day(let day): return "\(day)天前"
        case .hour(let hour): return "\(hour)小时前"
        case .minute(let minute): return "\(minute)分钟前"
        case .second(_), .now: return "刚刚"
        }
    }
    
    /// 基于当前时间将date转为字符串描述，今天，昨天，以前形式
    func describeTimePassedShort() -> String {
        if compare(.isToday) {
            return "今天 \(toString(format: "HH:mm"))"
        } else if compare(.isYesterday) {
            return "昨天 \(toString(format: "HH:mm"))"
        } else {
            return compare(.isThisYear) ? toString(format: "MM-dd HH:mm") : toString(format: "yyyy-MM-dd HH:mm")
        }
    }
    
    /// 基于当前时间将date转为字符串描述，英文形式
    func describeTimePassedEnglish() -> String {
        let passesd = timePassed()
        var str: String
        switch passesd {
        case .year(let year):
            year == 1 ? (str = "year") : (str = "years")
            return "\(year) \(str) ago"
        case .month(let month):
            month == 1 ? (str = "month") : (str = "months")
            return "\(month) \(str) ago"
        case .day(let day):
            day == 1 ? (str = "day") : (str = "days")
            return "\(day) \(str) ago"
        case .hour(let hour):
            hour == 1 ? (str = "hour") : (str = "hours")
            return "\(hour) \(str) ago"
        case .minute(let minute):
            minute == 1 ? (str = "minute") : (str = "minutes")
            return "\(minute) \(str) ago"
        case .second(let second):
            second == 1 ? (str = "second") : (str = "seconds")
            return "\(second) \(str) ago"
        case .now:
            return "Just now"
        }
    }
    
    /// 工作日描述形式枚举
    enum WeekdayDesc {
        case chinese, chineseShort, english
    }
    
    /// 将Date转为工作日形式
    func describeWeekday(_ desc: WeekdayDesc) -> String {
        let tuple: (chinese: String, chineseShort: String, english: String)
        switch component(.weekday) {
        case 1: tuple = ("星期日", "周日", "Sunday")
        case 2: tuple = ("星期一", "周一", "Monday")
        case 3: tuple = ("星期二", "周二", "Tuesday")
        case 4: tuple = ("星期三", "周三", "Wednesday")
        case 5: tuple = ("星期四", "周四", "Thursday")
        case 6: tuple = ("星期五", "周五", "Friday")
        case 7: tuple = ("星期六", "周六", "Saturday")
        default: tuple = ("", "", "")
        }
        switch desc {
        case .chinese: return tuple.chinese
        case .chineseShort: return tuple.chineseShort
        case .english: return tuple.english
        }
    }
    
    /// 返回日期中该月份的天数
    func numberOfDaysInMonth() -> Int {
        let range = Calendar.current.range(of: Calendar.Component.day, in: Calendar.Component.month, for: self)!
        return range.upperBound - range.lowerBound
    }
    
    /// 返回日期中该月份最后一天的日期
    func lastDayInMonth() -> Date? {
        var start: Date = Date(), interval: TimeInterval = 0
        let calculated = Calendar.current.dateInterval(of: .month, start: &start, interval: &interval, for: self)
        guard calculated else { return nil }
        return start.addingTimeInterval(interval - 1)
    }
    
    /// 返回日期中该周第一天的日期
    func firstDayInWeek() -> Date? {
        var start: Date = Date(), interval: TimeInterval = 0
        let calculated = Calendar.current.dateInterval(of: .weekdayOrdinal, start: &start, interval: &interval, for: self)
        return calculated ? start : nil
    }
    
    /// 指定componentFlags的日期组件信息
    func dateComponents(_ timeZone: TimeZone = NSTimeZone.local, locale: Locale = Locale.current) -> DateComponents {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        calendar.locale = locale
        return calendar.dateComponents(componentFlags(), from: self)
    }
}

public extension Date {
    
    /// 将String转为Date
    ///
    ///     timeZone：时区
    ///     TimeZone(identifier:"Asia/Shanghai")
    ///     TimeZone(identifier:"Asia/Hong_Kong")
    static func make(string: String, format: String, timeZone: TimeZone = .current, locale: Locale = .current, isLenient: Bool = true) -> Date? {
        guard !string.isEmpty else {
            return nil
        }
        let formatter = Date.cachedDateFormatters.cachedFormatter(format, timeZone: timeZone, locale: locale, isLenient: isLenient)
        guard let date = formatter.date(from: string) else {
            return nil
        }
        return Date(timeInterval: 0, since: date)
    }
    
    /// 将date转为String (默认日期格式yyyy-MM-dd HH:mm:ss)
    func toString(format: String = .dateFormat(.yMdHms), timeZone: TimeZone = .current, locale: Locale = .current) -> String {
        let formatter = Date.cachedDateFormatters.cachedFormatter(format, timeZone: timeZone, locale: locale)
        return formatter.string(from: self)
    }
    
    /// 将date转为String (返回系统日期格式 e.g Jul 4, 2022 at 5:00 PM)
    func toString(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, timeZone: TimeZone = NSTimeZone.local, locale: Locale = Locale.current, doesRelativeDateFormatting: Bool = false) -> String {
        let formatter = Date.cachedDateFormatters.cachedFormatter(dateStyle, timeStyle: timeStyle, doesRelativeDateFormatting: doesRelativeDateFormatting, timeZone: timeZone, locale: locale)
        return formatter.string(from: self)
    }

    /// 将时间戳timestamp转为date
    static func make(timestamp: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: timestamp)
    }
    
    /// 将date转为时间戳timestamp
    func toTimestamp() -> TimeInterval {
        return timeIntervalSince1970
    }
}

public extension Date {
    
    enum SecondsType { case year, week, day, hour, minute }
    
    /// 年周日时分秒转成多少秒表示
    static func seconds(of type: SecondsType) -> Double {
        switch type {
        case .minute: return 60
        case .hour: return 3600
        case .day: return 86400
        case .week: return 604800
        case .year: return 31556926
        }
    }
}
 
public extension Date {
    
    /// 获取所有农历年份名称
    static var chineseYearNames: [String] {
        return ["甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉", "甲戌",   "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛己", "壬午", "癸未", "甲申", "乙酉", "丙戌",  "丁亥", "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳", "甲午", "乙未", "丙申", "丁酉", "戊戌",  "己亥", "庚子", "辛丑", "壬寅", "癸丑", "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌",  "辛亥", "壬子", "癸丑", "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"]
    }
    
    /// 获取所有农历月份名称
    static var chineseMonthNames: [String] {
        return ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
    }
    
    /// 获取所有农历平日名称
    static var chineseDayNames: [String] {
        return ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    }
    
    /// 将date转为农历年月日名称 2020-02-18 => 庚子年正月廿五
    func lunarCalendarNameYmd() -> String? {
        let calendar = Calendar(identifier: .chinese)
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        guard comps.year != nil else { return nil }
        let year = Date.chineseYearNames[comps.year! - 1]
        guard comps.month != nil else { return nil }
        let month = Date.chineseMonthNames[comps.month! - 1]
        guard comps.day != nil else { return nil }
        let day = Date.chineseDayNames[comps.day! - 1]
        return year + "年" + month + day
    }
    
    /// 将date转为农历月日名称
    func lunarCalendarNameMd() -> String? {
        let calendar = Calendar(identifier: .chinese)
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        guard comps.month != nil else { return nil }
        let month = Date.chineseMonthNames[comps.month! - 1]
        guard comps.day != nil else { return nil }
        let day = Date.chineseDayNames[comps.day! - 1]
        return month + day
    }
}

public extension String {
    
    /**
    * 对Date格式化的扩展，将Date转化为指定格式的String
    * 月(M)、日(d)、12小时(h)、24小时(H)、分(m)、秒(s)、周(E)、季度(q) 可以用 1-2 个占位符
    * 年(y)可以用 1-4 个占位符，毫秒(S)只能用 1 个占位符(是 1-3 位的数字)
    * eg:
    * ("yyyy-MM-dd hh:mm:ss.S") ==> 2020-07-02 08:09:04.423
    * ("yyyy-MM-dd E HH:mm:ss") ==> 2020-03-10 二 20:09:04
    * ("yyyy-MM-dd EE hh:mm:ss") ==> 2020-03-10 周二 08:09:04
    * ("yyyy-MM-dd EEE hh:mm:ss") ==> 2020-03-10 星期二 08:09:04
    * ("yyyy-M-d h:m:s.S") ==> 2020-7-2 8:9:4.18
    */
    enum FormatType { case yMdHms, yMdHm, yMd, Hms }

    /// 对Date格式化的扩展，将Date转化为指定格式的String
    static func dateFormat(_ type: FormatType) -> String {
        switch type {
        case .yMdHms: return "yyyy-MM-dd HH:mm:ss"
        case .yMdHm: return "yyyy-MM-dd HH:mm"
        case .yMd: return "yyyy-MM-dd"
        case .Hms: return "HH:mm:ss"
        }
    }
}

fileprivate extension Date {
    
    // - fileprivate -
    func componentFlags() -> Set<Calendar.Component> {
        return [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.weekOfYear, Calendar.Component.hour, Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday, Calendar.Component.weekdayOrdinal, Calendar.Component.weekOfYear]
    }
    
    static var cachedDateFormatters = ConcurrentFormatterCache()
    
    class ConcurrentFormatterCache {
        private static let cachedDateFormattersQueue = DispatchQueue(
            label: "pk-date-formatter-queue",
            attributes: .concurrent
        )
        
        private static let cachedNumberFormatterQueue = DispatchQueue(
            label: "pk-number-formatter-queue",
            attributes: .concurrent
        )
        
        private static var cachedDateFormatters = [String: DateFormatter]()
        private static var cachedNumberFormatter = NumberFormatter()
        
        private func register(hashKey: String, formatter: DateFormatter) -> Void {
            ConcurrentFormatterCache.cachedDateFormattersQueue.async(flags: .barrier) {
                ConcurrentFormatterCache.cachedDateFormatters.updateValue(formatter, forKey: hashKey)
            }
        }
        
        private func retrieve(hashKey: String) -> DateFormatter? {
            let dateFormatter = ConcurrentFormatterCache.cachedDateFormattersQueue.sync { () -> DateFormatter? in
                guard let result = ConcurrentFormatterCache.cachedDateFormatters[hashKey] else { return nil }
                return result.copy() as? DateFormatter
            }
            
            return dateFormatter
        }
        
        private func retrieve() -> NumberFormatter {
            let numberFormatter = ConcurrentFormatterCache.cachedNumberFormatterQueue.sync { () -> NumberFormatter in
                // Should always be NumberFormatter
                return ConcurrentFormatterCache.cachedNumberFormatter.copy() as! NumberFormatter
            }
            
            return numberFormatter
        }
        
        func cachedFormatter(_ format: String = "EEE MMM dd HH:mm:ss  yyyy",
                             timeZone: Foundation.TimeZone = Foundation.TimeZone.current,
                             locale: Locale = Locale.current, isLenient: Bool = true) -> DateFormatter {
            let hashKey = "\(format.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
                
            if Date.cachedDateFormatters.retrieve(hashKey: hashKey) == nil {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                formatter.timeZone = timeZone
                formatter.locale = locale
                formatter.isLenient = isLenient
                Date.cachedDateFormatters.register(hashKey: hashKey, formatter: formatter)
            }
            return Date.cachedDateFormatters.retrieve(hashKey: hashKey)!
        }
        
        /// Generates a cached formatter based on the provided date style, time style and relative date.
        /// Formatters are cached in a singleton array using hashkeys.
        func cachedFormatter(_ dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style, doesRelativeDateFormatting: Bool, timeZone: Foundation.TimeZone = Foundation.NSTimeZone.local, locale: Locale = Locale.current, isLenient: Bool = true) -> DateFormatter {
            let hashKey = "\(dateStyle.hashValue)\(timeStyle.hashValue)\(doesRelativeDateFormatting.hashValue)\(timeZone.hashValue)\(locale.hashValue)"
            if Date.cachedDateFormatters.retrieve(hashKey: hashKey) == nil {
                let formatter = DateFormatter()
                formatter.dateStyle = dateStyle
                formatter.timeStyle = timeStyle
                formatter.doesRelativeDateFormatting = doesRelativeDateFormatting
                formatter.timeZone = timeZone
                formatter.locale = locale
                formatter.isLenient = isLenient
                Date.cachedDateFormatters.register(hashKey: hashKey, formatter: formatter)
            }
            return Date.cachedDateFormatters.retrieve(hashKey: hashKey)!
        }
        
        func cachedNumberFormatter() -> NumberFormatter {
            return Date.cachedDateFormatters.retrieve()
        }
    }
}
