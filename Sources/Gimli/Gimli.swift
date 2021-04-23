import Algorithms
import Foundation

public struct Gimli {
    private var state: [UInt8]
    
    public init() {
        state = .init(repeating: 0, count: 48)
    }
    
    @inline(__always)
    private func unpack() -> (SIMD4<UInt32>, SIMD4<UInt32>, SIMD4<UInt32>) {
        let a = SIMD4(littleEndianBytes: state[00..<16])
        let b = SIMD4(littleEndianBytes: state[16..<32])
        let c = SIMD4(littleEndianBytes: state[32..<48])
        return (a, b, c)
    }
    
    @inline(__always)
    private mutating func pack(_ a: SIMD4<UInt32>, _ b: SIMD4<UInt32>, _ c: SIMD4<UInt32>) {
        state.removeAll(keepingCapacity: true)
        state.append(littleEndianBytesOf: a)
        state.append(littleEndianBytesOf: b)
        state.append(littleEndianBytesOf: c)
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
}

fileprivate extension SIMD4 where Scalar == UInt32 {
    @inline(__always)
    init(littleEndianBytes bytes: ArraySlice<UInt8>) {
        assert(bytes.count * 8 == Self.scalarCount * Scalar.bitWidth)
        var result = Self()
        for (i, chunk) in zip(result.indices, bytes.chunks(ofCount: 4)) {
            result[i] = UInt32(littleEndianBytes: chunk)
        }
        self = result
    }
    
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

fileprivate extension UInt32 {
    @inline(__always)
    init(littleEndianBytes bytes: ArraySlice<UInt8>) {
        assert(bytes.count * 8 == Self.bitWidth)
        self = bytes.reversed().reduce(0, { $0 << 8 | Self($1) })
    }
}

fileprivate extension Array where Element == UInt8 {
    @inline(__always)
    mutating func append(littleEndianBytesOf x: SIMD4<UInt32>) {
        for i in x.indices {
            for count in stride(from: 0, to: 32, by: 8) {
                self.append(UInt8(truncatingIfNeeded: x[i] >> count))
            }
        }
    }
}

extension Gimli: RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Array<UInt8>.Index
    
    public typealias Indices = Array<UInt8>.Indices
    
    public typealias SubSequence = Array<UInt8>.SubSequence
    
    @inline(__always)
    public var startIndex: Int {
        0
    }
    
    @inline(__always)
    public var endIndex: Int {
        48
    }
    
    @inline(__always)
    public var indices: Self.Indices {
        (0..<48)
    }
    
    @inline(__always)
    public func formIndex(after i: inout Self.Index) {
        state.formIndex(after: &i)
    }
    
    @inline(__always)
    public func formIndex(before i: inout Self.Index) {
        state.formIndex(before: &i)
    }
    
    @inline(__always)
    public subscript(index: Self.Index) -> Self.Element {
        get {
            state[index]
        }
        set {
            state[index] = newValue
        }
    }
    
    @inline(__always)
    public subscript(bounds: Self.Indices) -> Self.SubSequence {
        get {
            state[bounds]        }
        set {
            state[bounds] = newValue
        }
    }
}

extension Gimli {
    @inline(__always)
    public var first: Self.Element {
        get {
            state[0]
        }
        set {
            state[0] = newValue
        }
    }
    
    @inline(__always)
    public var last: Self.Element {
        get {
            state[47]
        }
        set {
            state[47] = newValue
        }
    }
}
