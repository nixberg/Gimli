public struct Gimli {
    private var a: SIMD4<UInt32> = .zero
    private var b: SIMD4<UInt32> = .zero
    private var c: SIMD4<UInt32> = .zero
    
    public init() {}
    
    public mutating func permute() {
        a = SIMD4(littleEndian: a)
        b = SIMD4(littleEndian: b)
        c = SIMD4(littleEndian: c)
        
        for roundConstant: UInt32 in stride(from: 0x9e37_7918, to: 0x9e37_7900, by: -4) {
            self.applySPBox()
            a = a[1, 0, 3, 2]
            a[0] ^= roundConstant
            
            self.applySPBox()
            
            self.applySPBox()
            a = a[2, 3, 0, 1]
            
            self.applySPBox()
        }
        
        a = a.littleEndian
        b = b.littleEndian
        c = c.littleEndian
    }
    
    @inline(__always)
    private mutating func applySPBox() {
        let x = a.rotated(left: 24)
        let y = b.rotated(left:  9)
        let z = c
        
        c = x ^ (z &<< 1) ^ ((y & z) &<< 2)
        b = y ^  x        ^ ((x | z) &<< 1)
        a = z ^  y        ^ ((x & y) &<< 3)
    }
}

private extension SIMD4<UInt32> {
    @inline(__always)
    init(littleEndian value: Self) {
        self.init(
            Scalar(littleEndian: value.x),
            Scalar(littleEndian: value.y),
            Scalar(littleEndian: value.z),
            Scalar(littleEndian: value.w)
        )
    }
    
    @inline(__always)
    func rotated(left count: Scalar) -> Self {
        (self &<< count) | (self &>> (32 - count))
    }
    
    @inline(__always)
    subscript(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar) -> Self {
        self[Self(v0, v1, v2, v3)]
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
}
