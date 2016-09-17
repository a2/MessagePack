struct DispatchDataGenerator: IteratorProtocol {
    let data: DispatchData
    var i: Int = 0

    var region: DispatchData?
    var offset: Int!

    init(data: DispatchData) {
        self.data = data
    }

    mutating func next() -> Byte? {
        if i >= data.count {
            return nil
        }

        if let offset = offset, let size = region?.count, i >= offset + size {
            region = nil
        }

        if region == nil {
            let (subregion, subregionOffset) = data.region(location: i)
            region = subregion
            offset = subregionOffset
        }

        let ret = region![i - offset]
        i += 1
        return ret
    }
}

struct NSDataGenerator: IteratorProtocol {
    let data: NSData
    var i: Int = 0

    var buffer: UnsafePointer<Byte>!
    var range: Range<Int>!

    init(data: NSData) {
        self.data = data
    }

    mutating func next() -> Byte? {
        if i >= data.length {
            return nil
        }

        if let range = range, range ~= i {
            buffer = nil
        }

        if buffer == nil {
            data.enumerateBytes { (bytes, byteRange, stop) in
                if let range = byteRange.toRange(), range ~= self.i {
                    self.buffer = bytes.assumingMemoryBound(to: UInt8.self)
                    self.range = range
                    stop.pointee = true
                }
            }
        }

        let ret = buffer[i - range.lowerBound]
        i += 1
        return ret
    }
}
