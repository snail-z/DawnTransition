//
//  Bundle+DawnExtensions.swift
//  DawnExtensions
//
//  Created by zhang on 2022/10/22.
//

#if os(iOS) || os(tvOS)

import UIKit

public extension Bundle {
    
    /// 读取Bundle内图片
    func image(named: String) -> UIImage? {
        let name = "\(named)@\(Int(max(2, UIScreen.main.scale)))x"
        let image: UIImage?
        if #available(iOS 13.0, *) {
            image = UIImage(named: name, in: self, with: nil)
        } else {
            image = UIImage(named: name, in: self, compatibleWith: nil)
        }
        return image
    }
    
    /// 读取Bundle内文件
    func contentsOfFile(named: String?, ofType type: String? = nil) -> Any? {
        guard let _ = named else { return nil }
        guard let path = path(forResource: named, ofType: type ?? "json") else { return nil }
        guard let data = NSData(contentsOfFile: path) else { return nil }
        return try? JSONSerialization.jsonObject(with: data as Data) as? [String: Any]
    }
}

#endif
