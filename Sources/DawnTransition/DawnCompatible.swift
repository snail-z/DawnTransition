//
//  DawnCompatible.swift
//  DawnTransition
//
//  Created by zhang on 2022/6/9.
//  Copyright (c) 2022 snail-z <haozhang0770@163.com> All rights reserved.
//

import Foundation

public protocol DawnCompatible {
    
    associatedtype CompatibleType
    var dawn: DawnExtension<CompatibleType> { get set }
}

public extension DawnCompatible {
    
    var dawn: DawnExtension<Self> {
        get { return DawnExtension(self) }
        // swiftlint:disable unused_setter_value
        set { }
    }
}

public class DawnExtension<Base> {
    
    public var base: Base
    init(_ base: Base) {
        self.base = base
    }
}
