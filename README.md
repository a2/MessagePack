# MessagePack.swift

> It's like JSON.
> but fast and small.

MessagePack is an efficient binary serialization format. It lets you exchange data among multiple languages like JSON. But it's faster and smaller. Small integers are encoded into a single byte, and typical short strings require only one extra byte in addition to the strings themselves.

For more information, go to MessagePack's website at [msgpack.org](http://msgpack.org).

## Usage

```swift
import MessagePack

let packedInt = pack(.UInt(42))
// -> [0x2a]

let unpackedInt = try! unpack([0x2a])
// -> MessagePack.Int(42)

let packedArray = pack([0, 1, 2, 3, 4])
// -> [0x95, 0x00, 0x01, 0x02, 0x03, 0x04]
```

## Installation

Installation is supported with CocoaPods, Carthage, Swift Package Manage, and with Git submodules. See INSTALL for details.

## Availability

MessagePack.swift is intended for use with Swift 2.2. Compatibility with past and future versions is not guaranteed.

## License

MessagePack.swift is released under the MIT license. See LICENSE for details.
