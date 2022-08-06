import SIMDEndianBytes

public struct Gimli {
    private var state: [UInt8]
    
    public init() {
        state = .init(repeating: 0, count: 48)
    }
    
    public mutating func permute() {
        var (a, b, c) = self.unpack()
        
        @inline(__always)
        func applySPBox() {
            let x = a.rotated(left: 24)
            let y = b.rotated(left:  9)
            let z = c
            
            c = x ^ (z &<< 1) ^ ((y & z) &<< 2)
            b = y ^  x        ^ ((x | z) &<< 1)
            a = z ^  y        ^ ((x & y) &<< 3)
        }
        
        var roundConstant: UInt32 = 0x9e377918
        
        for _ in 0..<6 {
            applySPBox()
            a.smallSwap()
            a.x ^= roundConstant
            
            applySPBox()
            
            applySPBox()
            a.bigSwap()
            
            applySPBox()
            
            roundConstant &-= 4
        }
        
        self.pack(a, b, c)
    }
    
    @inline(__always)
    private func unpack() -> (SIMD4<UInt32>, SIMD4<UInt32>, SIMD4<UInt32>) {
        let a: SIMD4<UInt32> = .init(littleEndianBytes: state[00..<16])
        let b: SIMD4<UInt32> = .init(littleEndianBytes: state[16..<32])
        let c: SIMD4<UInt32> = .init(littleEndianBytes: state[32..<48])
        return (a, b, c)
    }
    
    @inline(__always)
    private mutating func pack(_ a: SIMD4<UInt32>, _ b: SIMD4<UInt32>, _ c: SIMD4<UInt32>) {
        state.removeAll(keepingCapacity: true)
        state.append(contentsOf: a.littleEndianBytes())
        state.append(contentsOf: b.littleEndianBytes())
        state.append(contentsOf: c.littleEndianBytes())
    }
}

fileprivate extension SIMD4 where Scalar == UInt32 {
    @inline(__always)
    func rotated(left count: UInt32) -> Self {
        (self &<< count) | (self &>> (32 - count))
    }
    
    @inline(__always)
    mutating func smallSwap() {
        self = self[SIMD4(1, 0, 3, 2)]
    }
    
    @inline(__always)
    mutating func bigSwap() {
        self = self[SIMD4(2, 3, 0, 1)]
    }
}

extension Gimli: MutableCollection & RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Int
    
    public typealias SubSequence = ArraySlice<UInt8>
    
    @inline(__always)
    public var count: Int {
        48
    }
    
    @inline(__always)
    public var startIndex: Self.Index {
        0
    }
    
    @inline(__always)
    public var endIndex: Self.Index {
        48
    }
    
    @inline(__always)
    public subscript(position: Self.Index) -> Self.Element {
        get {
            state[position]
        }
        _modify {
            yield &state[position]
        }
    }
    
    @inline(__always)
    public subscript(bounds: Range<Self.Index>) -> Self.SubSequence {
        get {
            state[bounds]
        }
        _modify {
            yield &state[bounds]
        }
    }
    
    @inline(__always)
    public var first: Self.Element {
        get {
            state[startIndex]
        }
        _modify {
            yield &state[startIndex]
        }
    }
    
    @inline(__always)
    public var last: Self.Element {
        get {
            state[endIndex - 1]
        }
        _modify {
            yield &state[endIndex - 1]
        }
    }
    
    @inline(__always)
    public func withContiguousStorageIfAvailable<R>(
        _ body: (UnsafeBufferPointer<Self.Element>) throws -> R
    ) rethrows -> R? {
        try state.withContiguousStorageIfAvailable(body)
    }
    
    @inline(__always)
    public mutating func withContiguousMutableStorageIfAvailable<R>(
        _ body: (inout UnsafeMutableBufferPointer<Self.Element>) throws -> R
    ) rethrows -> R? {
        try state.withContiguousMutableStorageIfAvailable(body)
    }
}
