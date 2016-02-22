# Installation

## [Swift Package Manager](https://swift.org/package-manager)

`Package.swift`:

```swift
import PackageDescription

let package = Package(
    name: "YourPackage",
    dependencies: [
        .Package(url: "https://github.com/a2/MessagePack.swift.git", majorVersion: 1),
    ]
)
```

## [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

`Podfile`:

```ruby
use_frameworks!

target 'Your Target' do
  pod 'MessagePack.swift', '~> 1.2.0'
end
```

## [Carthage](https://github.com/Carthage/Carthage)

Add the following line to your `Cartfile`:

```ogdl
github "a2/MessagePack.swift" ~> 1.2.0
```
