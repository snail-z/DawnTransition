# DawnTransition

[![Language](https://img.shields.io/badge/Language-%20Swift%20-orange.svg)](https://travis-ci.org/snail-z/DawnTransition)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](http://cocoapods.org/pods/DawnTransition)
![Platform](https://img.shields.io/badge/platforms-iOS%2013.0%20%20-F28D.svg)
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
[![Version](https://img.shields.io/cocoapods/v/DawnTransition.svg?style=flat)](https://cocoapods.org/pods/DawnTransition)



DawnTransition is a lightweight iOS transition framework for smooth, customizable animations and native-like interactive swipe-back gestures. It solves common gesture conflicts in custom transitions and is proven in real projects.

## Requirements

- iOS 13.0+
- Swift 5.0+

## Installation

DawnTransition is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DawnTransition'
```
Run pod install to integrate it into your project.

#### 📦 Swift Package Manager

DawnTransition also supports [Swift Package Manager](https://swift.org/package-manager):

#### In Xcode:
- File > Swift Packages > Add Package Dependency
- Add `https://github.com/snail-z/DawnTransition.git`
- Select "Up to Next Major" with "1.1.0"

#### Or manually in Package.swift:
```swift
// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/snail-z/DawnTransition.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "YOUR_TARGET_NAME",
            dependencies: ["DawnTransition"]
        )
    ]
)
```
Then run swift build to fetch and integrate the package.

## Usage

```swift
let pan = DawnPanGestureRecognizer(driver: self, type: .dismiss) { [weak self] in
    guard let `self` = self else { return }
    self.dismiss(animated: true)
}
pan.isRecognizeWhenEdges = false
pan.recognizeDirection = .leftToRight
view.dawn.addPanGestureRecognizer(pan)
```

## Author

haoz, haozhang0770@163.com

## License

DawnTransition is available under the MIT license. See the LICENSE file for more info.
