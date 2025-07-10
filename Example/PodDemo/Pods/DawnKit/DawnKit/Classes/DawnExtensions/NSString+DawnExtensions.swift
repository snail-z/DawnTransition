//
//  NSString+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

#endif

#if os(OSX)

import AppKit

#endif

public extension NSString {
    
    /// 返回字符串中的Unicode代码点数
    var codePointCount: Int {
        var count: Int = 0
        for code in (self as String).unicodeScalars {
            let length = NSString(string: String(code)).length
            count += length
        }
        return count
    }
    
    /// 将字符编码位置转为对应的字节数范围
    func rangeOfCodePoint(start: Int, end: Int) -> NSRange {
        return NSRange(location: start, length: end - start)
    }
    
    /// 将字符编码范围转为对应的字节数范围
    /// Unicode编码：
    /// 😄 => \ud83d\ude04
    /// 👩🏿 => \ud83d\udc69\ud83c\udfff
    /// 👨‍👩‍👧‍👦 => \ud83d\udc68\u200d\ud83d\udc69\u200d\ud83d\udc67\u200d\ud83d\udc66
    func rangeOfCodePoint(for range: NSRange) -> NSRange {
        guard range.location > 0, range.length > 0,
              NSMaxRange(range) < length else {
            return range
        }
        
        var index = 0
        var nsRange = NSRange(location: 0, length: 0)
        for code in (self as String).unicodeScalars {
            let length = NSString(string: String(code)).length
            if index < range.location {
                nsRange.location += length
            } else {
                guard index < NSMaxRange(range) else { break }
                nsRange.length += length
            }
            index += 1
        }
        return nsRange
    }

    /// 将字符串范围转为对应的字节数范围
    func rangeOfComposedCharacterSequences(for range: NSRange) -> NSRange {
        guard NSMaxRange(range) < length else {
            return range
        }

        /// 包含emoji的实际起始位置
        var index = 0
        var byteLocation = 0
        enumerateSubstrings(in: NSRange(location: 0, length: length), options: .byComposedCharacterSequences) { (substring, _, _, stop) -> () in
            if index < range.location {
                byteLocation += NSString(string: substring ?? "").length
            } else {
                stop.pointee = true
            }
            index += 1
        }
        
        let byteLength = bytesLengthOfComposedCharacterSequencesForRange(NSMakeRange(byteLocation, range.length))
        return NSMakeRange(byteLocation, byteLength);
    }
    
    private func bytesLengthOfComposedCharacterSequencesForRange(_ range: NSRange) -> Int {
        /// 包含emoji的实际字节长度
        var index = 0
        var byteLength = 0
        enumerateSubstrings(in: NSMakeRange(range.location, length - range.location), options: .byComposedCharacterSequences) { (substring, _, _, stop) -> () in
            if index < range.length {
                byteLength += NSString(string: substring ?? "").length
            } else {
                stop.pointee = true
            }
            index += 1
        }
        return byteLength
    }
}
