public struct Gimli {
    var state: [UInt8]
    
    public init() {
        state = .init(repeating: 0, count: 48)
    }
    
    @inline(__always)
    public subscript(index: Int) -> UInt8 {
        get {
            state[index]
        }
        // TODO: modify
        set {
            state[index] = newValue
        }
    }
    
    @inline(__always)
    private func unpack() -> (SIMD4<UInt32>, SIMD4<UInt32>, SIMD4<UInt32>) {
        var state = self.state[...]
        let a = SIMD4(littleEndianBytes: state.prefix(16))
        state = state.dropFirst(16)
        let b = SIMD4(littleEndianBytes: state.prefix(16))
        state = state.dropFirst(16)
        let c = SIMD4(littleEndianBytes: state.prefix(16))
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
        
        func quadrupleRound(_ constant: UInt32) {
            applySPBox()
            a.smallSwap()
            a.x ^= constant
            
            applySPBox()
            
            applySPBox()
            a.bigSwap()
            
            applySPBox()
        }
        
        quadrupleRound(0x9e377918)
        quadrupleRound(0x9e377914)
        quadrupleRound(0x9e377910)
        quadrupleRound(0x9e37790c)
        quadrupleRound(0x9e377908)
        quadrupleRound(0x9e377904)
        
        self.pack(a, b, c)
    }
}

fileprivate extension SIMD4 where Scalar == UInt32 {
    @inline(__always)
    init(littleEndianBytes bytes: ArraySlice<UInt8>) {
        assert(bytes.count == Self.scalarCount * Scalar.bitWidth / 8)
        
        var bytes = bytes
        let x = UInt32(littleEndianBytes: bytes.prefix(4))
        bytes = bytes.dropFirst(4)
        let y = UInt32(littleEndianBytes: bytes.prefix(4))
        bytes = bytes.dropFirst(4)
        let z = UInt32(littleEndianBytes: bytes.prefix(4))
        bytes = bytes.dropFirst(4)
        let w = UInt32(littleEndianBytes: bytes.prefix(4))
        
        self = .init(x, y, z, w)
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
        assert(bytes.count == Self.bitWidth / 8)
        self = bytes
            .reversed()
            .reduce(0) { $0 << 8 | Self($1) }
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
