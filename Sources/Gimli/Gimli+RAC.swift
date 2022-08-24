extension Gimli: MutableCollection & RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Int
    
    @inline(__always)
    public var startIndex: Index {
        0
    }
    
    @inline(__always)
    public var endIndex: Index {
        48
    }
    
    @inline(__always)
    public subscript(position: Index) -> Element {
        get {
            self.withContiguousStorage {
                $0[position]
            }
        }
        set {
            self.withContiguousMutableStorage {
                $0[position] = newValue
            }
        }
    }
    
    @inline(__always)
    public var first: Self.Element {
        get {
            self[startIndex]
        }
        set {
            self[startIndex] = newValue
        }
    }
    
    @inline(__always)
    public var last: Self.Element {
        get {
            self[endIndex - 1]
        }
        set {
            self[endIndex - 1] = newValue
        }
    }
    
    @inline(__always)
    public func withContiguousStorageIfAvailable<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R? {
        try self.withContiguousStorage(body)
    }
    
    @inline(__always)
    public mutating func withContiguousMutableStorageIfAvailable<R>(
        _ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R? {
        try self.withContiguousMutableStorage(body)
    }
}

extension Gimli {
    @inline(__always)
    public func withContiguousStorage<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        try withUnsafePointer(to: self) {
            try $0.withMemoryRebound(to: Element.self, capacity: count) {
                try body(UnsafeBufferPointer(start: $0, count: count))
            }
        }
    }
    
    @inline(__always)
    public mutating func withContiguousMutableStorage<R>(
        _ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        let count = count
        return try withUnsafeMutablePointer(to: &self) {
            try $0.withMemoryRebound(to: Element.self, capacity: count) {
                var buffer = UnsafeMutableBufferPointer(start: $0, count: count)
                return try body(&buffer)
            }
        }
    }
}
