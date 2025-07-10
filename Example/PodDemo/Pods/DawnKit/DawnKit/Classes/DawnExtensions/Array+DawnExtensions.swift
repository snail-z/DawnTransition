//
//  Array+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import Foundation

public extension Array {
    
    /// 获取数组中一个随机下标
    var randomIndex: Int { Int.random(in: 0..<count) }
    
    /// 获取指定索引对应的元素，索引不存在则返回nil
    func element(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
    
    /// 获取指定索引对应的元素，索引不存在则返回默认值
    func element(safe index: Int, default element: Element) -> Element {
        guard index >= 0, index < count else { return element }
        return self[index]
    }
    
    /// 检查数组内是否包含指定元素的类型
    func containsType<T>(of element: T) -> Bool {
        let elementType = type(of: element)
        return contains { type(of: $0) == elementType}
    }
    
    /// 获取数组中指定某范围内的元素 (返回某范围内元素的数组)
    func subarray(at range: NSRange) -> [Element]? {
        guard range.location >= 0, range.location < count else {
            return nil
        }
        guard range.length > 0, NSMaxRange(range) <= count else {
            return nil
        }
        var elements = [Element]()
        for obj in self[range.location..<NSMaxRange(range)] {
            elements.append(obj)
        }
        return elements
    }
    
    /// 获取数组中前n个元素 (返回包含原数组内前n个元素的数组)
    func firstElements(_ length: NSInteger) -> [Element] {
        var elements = [Element]()
        let end = Swift.max(0, Swift.min(self.count, length))
        for obj in self[0..<end] {
            elements.append(obj)
        }
        return elements
    }
    
    /// 获取数组中后n个元素 (返回包含原数组内后n个元素的数组)
    func lastElements(_ length: NSInteger) -> [Element] {
        let begin = count - Swift.max(0, Swift.min(count, length))
        var elements = [Element]()
        for obj in self[begin..<count] {
            elements.append(obj)
        }
        return elements
    }

    /// 根据闭包返回的某个条件，查找数组内的最大最小值
    func maximin<T: Comparable>(_ block: (_ sender: Element) -> T) -> (max: T, min: T)? {
        guard !isEmpty else { return nil }
        var minValue = block(self[0]), maxValue = block(self[0])
        let lastIndex = count - 1
        for index in stride(from: 0, to: lastIndex, by: 2) {
            let one = block(self[index]), two = block(self[index + 1])
            let maxTemp = Swift.max(one, two)
            let minTemp = Swift.min(one, two)
            if maxTemp > maxValue { maxValue = maxTemp }
            if minTemp < minValue { minValue = minTemp }
        }
        guard count.isOdd else { return (maxValue, minValue) }
        let lastValue = block(self[lastIndex])
        if lastValue > maxValue { maxValue = lastValue }
        if lastValue < minValue { minValue = lastValue }
        return (maxValue, minValue)
    }
}

public extension Array {

    /// 将数组内元素按指定条件进行分组，并执行映射操作
    func catalogues<T>(_ condition: (_ element: Element) -> String?,
                       map: ((aKey: String, elements: [Element])) -> T) -> [T] {
        var temps = [T]()
        catalogued { condition($0) } forEach: { tuple in
            temps.append(map(tuple))
        }
        return temps
    }
    
    /// 将数组内元素按指定条件进行分组，forEach => 返回每个分组数据
    private func catalogued(_ condition: (_ element: Element) -> String?,
                            forEach: ((aKey: String, elements: [Element])) -> Void?) {
        guard !self.isEmpty else { return }
        var generator = self
        return catalogued(generator: &generator, condition) { results in
            forEach((results.first!.key, results.first!.value))
        }
    }

    private func catalogued(generator: inout [Element],
                            _ closure1: (_ sender: Element) -> String?,
                            _ closure2: ([String: [Element]]) -> Void?) {
        guard generator.count > 0 else { return }
        var temps = [Element]()
        let letter = closure1(generator.first!)
        while generator.count > 0 {
            guard let value = closure1(generator.first!), value == letter else { break }
            temps.append(generator.first!)
            generator.removeFirst()
        }
        closure2([letter ?? "-": temps])
        return catalogued(generator: &generator, closure1, closure2)
    }
}

public extension Collection {
    
    /// 返回指定索引对应的元素，若索引越界则返回nil
    subscript (safe index: Index?) -> Iterator.Element? {
        guard let idx = index else { return nil }
        return indices.contains(idx) ? self[idx] : nil
    }
}
