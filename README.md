# QBToast

[![CI](https://github.com/sjc-bui/QBToast/actions/workflows/ci.yml/badge.svg)](https://github.com/sjc-bui/QBToast/actions/workflows/ci.yml)
[![Version](https://img.shields.io/cocoapods/v/QBToast.svg?style=flat)](https://cocoapods.org/pods/QBToast)
[![License](https://img.shields.io/cocoapods/l/QBToast.svg?style=flat)](https://cocoapods.org/pods/QBToast)
[![Platform](https://img.shields.io/cocoapods/p/QBToast.svg?style=flat)](https://cocoapods.org/pods/QBToast)

Simple way to display Toast message in iOS app with a single line of code.

<img src="https://github.com/sjc-bui/QBToast/blob/master/Example/QBToast/screen-record.gif" width="250">

Screenshots: [default](https://github.com/sjc-bui/QBToast/blob/master/Example/QBToast/default.png) -
[success](https://github.com/sjc-bui/QBToast/blob/master/Example/QBToast/success.png) -
[warning](https://github.com/sjc-bui/QBToast/blob/master/Example/QBToast/warning.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- Swift 5.0
- iOS 11.0 or later

## Getting started

### Basic

Show toast message.

```swift
QBToast(message: "This is sample toast message").showToast { isTapped in
            // do stuff here
            print(isTapped) // true or false
        }
```

Toast message with custom position and state.

```swift
// position (default: .bottom)
// state (default: .custom)
QBToast(message: "Your message", position: .top, state: .success).showToast()
```

Toast message with specific duration.
```swift
// duration (default: 3.0)
QBToast(message: "Your message", duration: 5.0).showToast()
```

### And more...

Create custom Toast message with completion closure.
```swift
let style = QBToastStyle(backgroundColor: .darkGray,
                        messageColor: .white,
                        messageFont: .boldSystemFont(ofSize: 15),
                        messageNumberOfLines: 1,
                        messageAlignment: .center,
                        cornerRadius: 12.0,
                        fadeDuration: 0.5)

QBToast(message: "Your message", style: style).showToast { isTapped in
            // do stuff here
            if isTapped {
                print("dismiss by tap")
            } else {
                print("time out")
            }
        }
```

Toggle `tapToDismissEnabled` functionality.
```swift
QBToastManager.shared.tapToDismissEnabled = false // default = true
```

Toggle queueing behavior.
```swift
QBToastManager.shared.inQueueEnabled = false // default = true
```

## Appearance
Predefined style are:
| Property | Type | Description | Default value |
| --- | --- | --- | --- |
| backgroundColor | `UIColor` | The background color of the Toast view. | `#323232`
| messageColor | `UIColor` | The message color. | `.white`
| messageFont | `UIFont` | The message font. | `.systemFont(ofSize: 14.0, weight: .medium)`
| messageNumberOfLines | `Int` | Number of lines. | `0`
| messageAlignment | `NSTextAlignment` | Message alignment. | `.left`
| maxWidthPercentage | `CGFloat` | The maximum width of Toast view relative to it's superview. | `0.8` (`80%`)
| maxHeightPercentage | `CGFloat` | The maximum height of Toast view relative to it's superview. | `0.8` (`80%`)
| toastPadding | `CGFloat` | The spacing from the horizontal and vertical edge of the Toast view to the content. | `16.0`
| cornerRadius | `CGFloat` | The corner radius of the Toast view. | `4.0`
| fadeDuration | `TimeInterval` | The fade in/out animation duration | `0.4`


## Installation

QBToast is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'QBToast'
```
and add `import QBToast` in your code.


## Manually

1. Add `QBToast.swift` to your project.
2. Have fun.


## Contributing

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **need help**, open an issue.
- If you **want to contribute**, submit a pull request.


## MIT License

QBToast is available under the MIT license. See the LICENSE file for more info.

Made with :heart: by [sjc-bui](https://github.com/sjc-bui).
