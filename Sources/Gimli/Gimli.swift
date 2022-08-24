public struct Gimli {
    private var a: SIMD4<UInt32> = .zero
    private var b: SIMD4<UInt32> = .zero
    private var c: SIMD4<UInt32> = .zero
    
    public init() {}
    
    public mutating func permute() {
        a = SIMD4(littleEndian: a)
        b = SIMD4(littleEndian: b)
        c = SIMD4(littleEndian: c)
        
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
        
        a = a.littleEndian
        b = b.littleEndian
        c = c.littleEndian
    }
}

fileprivate extension SIMD4<UInt32> {
    @inline(__always)
    init(littleEndian value: Self) {
        self.init(
            UInt32(littleEndian: value.x),
            UInt32(littleEndian: value.y),
            UInt32(littleEndian: value.z),
            UInt32(littleEndian: value.w)
        )
    }
    
    @inline(__always)
    var littleEndian: Self {
        Self(
            x.littleEndian,
            y.littleEndian,
            z.littleEndian,
            w.littleEndian
        )
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
