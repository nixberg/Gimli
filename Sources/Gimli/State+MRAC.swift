extension State: MutableCollection & RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Int
    
    @inline(__always)
    public var startIndex: Index {
        0
    }
    
    @inline(__always)
    public var endIndex: Index {
        MemoryLayout<Self>.size
    }
    
    @inline(__always)
    public subscript(position: Index) -> Element {
        get {
            precondition(indices.contains(position), "Index out of range")
            return self.withUnsafeBufferPointer {
                $0[position]
            }
        }
        set {
            precondition(indices.contains(position), "Index out of range")
            self.withUnsafeMutableBufferPointer {
                $0[position] = newValue
            }
        }
    }
    
    @inline(__always)
    public var first: Element {
        get {
            self[startIndex]
        }
        set {
            self[startIndex] = newValue
        }
    }
    
    @inline(__always)
    public var last: Element {
        get {
            self[self.index(before: endIndex)]
        }
        set {
            self[self.index(before: endIndex)] = newValue
        }
    }
    
    @inline(__always)
    public func withContiguousStorageIfAvailable<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R? {
        try self.withUnsafeBufferPointer(body)
    }
    
    @inline(__always)
    public mutating func withContiguousMutableStorageIfAvailable<R>(
        _ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R? {
        try self.withUnsafeMutableBufferPointer { bufferPointer in
            var inoutBufferPointer = bufferPointer
            defer {
                precondition(
                    inoutBufferPointer == bufferPointer,
                    "\(Self.self) \(#function): replacing the buffer is not allowed"
                )
            }
            return try body(&inoutBufferPointer)
        }
    }
}

extension State {
    @inline(__always)
    public func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        try self.withUnsafeBytes {
            try $0.withMemoryRebound(to: UInt8.self, body)
        }
    }
    
    @inline(__always)
    public mutating func withUnsafeMutableBufferPointer<R>(
        _ body: (UnsafeMutableBufferPointer<Element>) throws -> R
    ) rethrows -> R {
        try self.withUnsafeMutableBytes {
            try $0.withMemoryRebound(to: UInt8.self, body)
        }
    }
    
    @inline(__always)
    public func withUnsafeBytes<R>(
        _ body: (UnsafeRawBufferPointer) throws -> R
    ) rethrows -> R {
        try Swift.withUnsafeBytes(of: self, body)
    }
    
    @inline(__always)
    public mutating func withUnsafeMutableBytes<R>(
        _ body: (UnsafeMutableRawBufferPointer) throws -> R
    ) rethrows -> R {
        try Swift.withUnsafeMutableBytes(of: &self, body)
    }
}

extension UnsafeMutableBufferPointer {
    @inline(__always)
    fileprivate static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.baseAddress == rhs.baseAddress && lhs.count == rhs.count
    }
}
