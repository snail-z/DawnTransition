//
//  DawnExtensions.swift
//
//  Created by zhang on 2020/2/26.
//  Copyright © 2020 snail-z. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit

public typealias NSUIEdgeInsets = UIEdgeInsets
public typealias NSUIApplication = UIApplication
public typealias NSUIBezierPath = UIBezierPath
public typealias NSUIGestureRecognizer = UIGestureRecognizer
public typealias NSUIControl = UIControl
public typealias NSUIFont = UIFont
public typealias NSUIColor = UIColor

#endif

#if os(OSX)

import Cocoa

public typealias NSUIEdgeInsets = NSEdgeInsets
public typealias NSUIApplication = NSApplication
public typealias NSUIBezierPath = NSBezierPath
public typealias NSUIGestureRecognizer = NSGestureRecognizer
public typealias NSUIControl = NSControl
public typealias NSUIFont = NSFont
public typealias NSUIColor = NSColor

#endif
