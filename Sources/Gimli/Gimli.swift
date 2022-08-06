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

extension Gimli: RandomAccessCollection {
    public typealias Element = UInt8
    
    public typealias Index = Array<UInt8>.Index
    
    @inline(__always)
    public var startIndex: Self.Index {
        0
    }
    
    @inline(__always)
    public var endIndex: Self.Index {
        48
    }
    
    @inline(__always)
    public func index(after i: Self.Index) -> Self.Index {
        state.index(after: i)
    }
    
    @inline(__always)
    public func index(before i: Self.Index) -> Self.Index {
        state.index(before: i)
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
    public var first: Self.Element {
        get {
            state[startIndex]
        }
        set {
            state[startIndex] = newValue
        }
    }
    
    @inline(__always)
    public var last: Self.Element {
        get {
            state[endIndex - 1]
        }
        set {
            state[endIndex - 1] = newValue
        }
    }
}
