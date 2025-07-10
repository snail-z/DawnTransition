//
//  String+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import CommonCrypto

#endif

#if os(OSX)

import AppKit
import CommonCrypto

#endif

public extension String {
    
    /// 将String转为Int
    func toInt() -> Int? {
        return Int(self)
    }
    
    /// 将String转为Double
    func toDouble() -> Double? {
        return Double(self)
    }
    
    /// 将String转CGFloat
    func toCGFloat() -> CGFloat? {
        guard let doubleValue = Double(self) else { return nil }
        return CGFloat(doubleValue)
    }
    
    /// 将String转NSString
    func toNSString() -> NSString {
        return self as NSString
    }
    
    /// 获取字符串尺寸
    func boundingSize(with size: CGSize,
                      font: NSUIFont!,
                      lineBreakMode: NSLineBreakMode? = nil) -> CGSize {
        var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font ?? NSUIFont.systemFont(ofSize: NSUIFont.systemFontSize) ]
        if lineBreakMode != nil {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = lineBreakMode!
            attributes.updateValue(paragraphStyle, forKey: NSAttributedString.Key.paragraphStyle)
        }
        let _size = toNSString().boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGSize(width: ceil(_size.width), height: ceil(_size.height))
    }
    
    /// 获取字符串宽度 (约束高度)
    func boundingWidth(with height: CGFloat,
                       font: NSUIFont!,
                       lineBreakMode: NSLineBreakMode? = nil) -> CGFloat {
        let size = CGSize(width: .greatestFiniteMagnitude, height: height)
        return boundingSize(with: size, font: font, lineBreakMode: lineBreakMode).width
    }
    
    /// 获取字符串高度 (约束宽度)
    func boundingHeight(with width: CGFloat,
                        font: NSUIFont!,
                        lineBreakMode: NSLineBreakMode? = nil) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        return boundingSize(with: size, font: font, lineBreakMode: lineBreakMode).height
    }
    
    /// 检查字符串是否为空或只包含空白和换行字符
    ///
    ///     let a = ""      返回true
    ///     let b = "   "   返回true
    ///     let c = " \n "  返回true
    var isBlank: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    /// 返回字符串中出现指定字符的第一个索引
    func index(of char: Character) -> Int? {
        for (index, c) in enumerated() where c == char {
            return index
        }
        return nil
    }
    
    /// 字符串查找子串返回NSRange
    func nsRange(of subString: String?) -> NSRange {
        guard let subValue = subString else { return NSRange(location: 0, length: 0) }
        guard let range = range(of: subValue) else {
            return NSRange(location: 0, length: 0)
        }
        return NSRange(range, in: self)
    }
    
    /// 字符串安全提取子串 (从某个位置起到某个位置结束)
    ///
    ///     "Hello World".substringSafe(from: 6, length: 5) -> "World"
    func substringSafe(from index: Int, length: Int) -> String? {
        guard length >= 0, index >= 0, index < count  else { return nil }
        guard index.advanced(by: length) <= count else {
            return self[safe: index..<count]
        }
        guard length > 0 else { return "" }
        return self[safe: index..<index.advanced(by: length)]
    }
    
    /// 字符串安全提取子串 (从起始处到某个位置结束)
    func substringSafe(to index: Int) -> String? {
        return substringSafe(from: 0, length: index)
    }
    
    /// 字符串安全提取子串 (从某个位置起直到末尾结束)
    func substringSafe(from index: Int) -> String? {
        return substringSafe(from: index, length: count)
    }
    
    /// 安全提取指定范围子串
    func substringSafe(range: NSRange) -> String? {
        return substringSafe(from: range.location, length: range.length)
    }
    
    /// 获取首字符
    var firstCharacter: String? {
        return substringSafe(to: 1)
    }
    
    /// 获取末尾字符
    var lastCharacter: String? {
        return substringSafe(from: count - 1)
    }
    
    /// 安全删除首字符并返回新字符串
    func deleteFirstCharacter() -> String? {
        return substringSafe(from: 1)
    }
    
    /// 安全删除末尾字符并返回新字符串
    func deleteLastCharacter() -> String? {
        return substringSafe(to: count - 1)
    }
}

public extension String {
    
    /// 检查是否包含某字符串且是否区分大小写
    func contains(_ string: String, caseSensitive: Bool) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }
    
    /// 检查字符串中是否包含Emoji
    func containsEmoji() -> Bool {
        for i in 0..<count {
            let c: unichar = (self as NSString).character(at: i)
            if (0xD800 <= c && c <= 0xDBFF) || (0xDC00 <= c && c <= 0xDFFF) {
                return true
            }
        }
        return false
    }
    
    /// 转为驼峰式字符串
    ///
    ///     "sOme vAriable naMe".pk.camelCased() -> "someVariableName"
    func camelCased() -> String {
        let source = lowercased()
        let first = source[..<source.index(after: source.startIndex)]
        if source.contains(" ") {
            let connected = source.capitalized.replacingOccurrences(of: " ", with: "")
            let camel = connected.replacingOccurrences(of: "\n", with: "")
            let rest = String(camel.dropFirst())
            return first + rest
        }
        let rest = String(source.dropFirst())
        return first + rest
    }
    
    /// 返回给定长度的随机字符串
    ///
    ///     String.pk.random(of: 18) -> "u7MMZYvGo9obcOcPj8"
    static func random(of length: Int) -> String {
        guard length > 0 else { return "" }
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 1...length {
            randomString.append(base.randomElement()!)
        }
        return randomString
    }
}

public extension String {
    
    /// 检查字符串是否是有效的URL
    var isValidURL: Bool {
        return URL(string: self) != nil
    }
    
    /// 检查字符串是否是有效的https URL
    var isValidHttpsURL: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme == "https"
    }
    
    /// 检查字符串是否是有效的文件URL
    var isValidFileURL: Bool {
        return URL(string: self)?.isFileURL ?? false
    }
    
    /// 检查字符串是否是有效的邮件格式
    var isValidEmail: Bool {
        // http://emailregex.com/
        let regex = "^(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$"
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    /// 检查字符串是否是手机号 (仅中国手机号所有号段)
    var isValidMobileNumber: Bool {
        let string = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard string.count == 11 else { return false }
        let regex = "^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$"
        return string.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    /// 检查字符串是否是身份证号
    var isValidIDCardNumber: Bool {
        let regex = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    /// 验证字符串是否为纯数字
    var isValidateAllDigits: Bool {
        let regex = "(^[0-9]*$)"
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    /// 验证字符串是否为纯汉字
    var isValidateChineseCharacters: Bool {
        let regex = "(^[\\u4e00-\\u9fa5]+$)"
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

public extension String {
    
    /// 获取指定范围内字符串
    subscript<R>(safe range: R) -> String? where R: RangeExpression, R.Bound == Int {
        let range = range.relative(to: Int.min..<Int.max)
        guard range.lowerBound >= 0,
            let lowerIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex),
            let upperIndex = index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex) else {
                return nil
        }
        return String(self[lowerIndex..<upperIndex])
    }
}

public extension String {
    
    /// Json解析类型
    enum JSONWritingType {
        case defalut, prettyPrinted, prettySortedKeys
    }
    
    /// 转Json字符串
    static func toJsonString(_ object: Any, type: JSONWritingType = .defalut) -> String {
        let options: JSONSerialization.WritingOptions
        switch type {
        case .defalut:
            options = JSONSerialization.WritingOptions()
        case .prettyPrinted:
            options = .prettyPrinted
        case .prettySortedKeys:
            if #available(iOS 11.0, *) {
                options = [.sortedKeys, .prettyPrinted]
            } else {
                options = .prettyPrinted
            }
        }
        return toJosnString(object, options: options)
    }
    
    /// 转Json字符串
    private static func toJosnString(_ object: Any, options: JSONSerialization.WritingOptions = []) -> String {
        guard JSONSerialization.isValidJSONObject(object) else { return "" }
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: options) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    /// 生成md5摘要
    static func md5(_ string: String) -> String {
        let data = Data(string.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
