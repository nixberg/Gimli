public struct State {
    private var a: Row = .zero
    private var b: Row = .zero
    private var c: Row = .zero
    
    public init() {}
    
    public mutating func permute() {
        for constant: UInt32 in stride(from: 0x9e37_7918, to: 0x9e37_7900, by: -4) {
            self.substituteAndPermute()
            a = a[1, 0, 3, 2]
            a[0] ^= constant
            
            self.substituteAndPermute()
            
            self.substituteAndPermute()
            a = a[2, 3, 0, 1]
            
            self.substituteAndPermute()
        }
    }
    
    @inline(__always)
    private mutating func substituteAndPermute() {
        let x = a.rotated(left: 24)
        let y = b.rotated(left: 09)
        let z = c
        c = x ^ z &<< 1 ^ (y & z) &<< 2
        b = y ^ x       ^ (x | z) &<< 1
        a = z ^ y       ^ (x & y) &<< 3
    }
}

private typealias Row = SIMD4<UInt32>

extension Row {
    @inline(__always)
    fileprivate func rotated(left count: Scalar) -> Self {
        self &<< count | self &>> (32 - count)
    }
    
    @inline(__always)
    fileprivate subscript(_ v0: Scalar, _ v1: Scalar, _ v2: Scalar, _ v3: Scalar) -> Self {
        self[Self(v0, v1, v2, v3)]
    }
}

#if _endian(big)
#error("Big-endian platforms are currently not supported")
#endif
