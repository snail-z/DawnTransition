//
//  Dictionary+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

import Foundation

public extension Dictionary {
    
    /// 检查字典中是否存在对应的Key
    func hasKey(_ key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    /// 获取字典中的一个随机元素
    func randomValue() -> Value? {
        return Array(values).randomElement()
    }
}
