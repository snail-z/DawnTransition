//
//  FileManager+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2022/10/22.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension FileManager {
    
    /// 返回沙盒路径
    var documentsDirectoryPath: String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    /// 返回沙盒目录缓存路径
    var cachesDirectoryPath: String? {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}

#endif
