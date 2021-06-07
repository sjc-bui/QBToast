# QBToast

[![Version](https://img.shields.io/cocoapods/v/QBToast.svg?style=flat)](https://cocoapods.org/pods/QBToast)
[![License](https://img.shields.io/cocoapods/l/QBToast.svg?style=flat)](https://cocoapods.org/pods/QBToast)
[![Platform](https://img.shields.io/cocoapods/p/QBToast.svg?style=flat)](https://cocoapods.org/pods/QBToast)

Simple way to show Toast message in iOS app with a single line of code.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- Swift 5.0
- iOS 12.0 or later

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
QBToast(message: "Your message", position: .top, state: .success).showToast()
```

Toast message with specific duration.
```swift
QBToast(message: "Your message", duration: 3.0).showToast()
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
                        fadeDuration: 3.0)

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
QBToastManager.shared.tapToDismissEnabled = false
```

Toggle queueing behavior.
```swift
QBToastManager.shared.inQueueEnabled = false
```


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
