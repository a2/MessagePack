import Data
import Darwin

extension Data {
    var count: Int {
        return startIndex.distanceTo(endIndex)
    }
}

func == <T>(lhs: Data<T>, rhs: Data<T>) -> Bool {
    if lhs.count != rhs.count {
        return false
    }

    return lhs.withUnsafeBufferPointer { l in
        rhs.withUnsafeBufferPointer { r in
            memcmp(l.baseAddress, r.baseAddress, l.count) == 0
        }
    }
}
