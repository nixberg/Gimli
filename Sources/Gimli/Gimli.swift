public struct Gimli {
    var s: (SIMD4<UInt32>, SIMD4<UInt32>, SIMD4<UInt32>)
    
    public init() {
        s = (.zero, .zero, .zero)
    }
    
    public subscript(index: Int) -> UInt8 {
        get {
            precondition(0 <= index && index < 48)
            return withUnsafePointer(to: s) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 48) {
                    $0[index]
                }
            }
        }
        set {
            precondition(0 <= index && index < 48)
            withUnsafeMutablePointer(to: &s) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 48) {
                    $0[index] = newValue
                }
            }
        }
    }
    
    public mutating func permute() {
        [0x9e377918 as UInt32, 0x9e377914, 0x9e377910, 0x9e37790c, 0x9e377908, 0x9e377904].forEach {
            self.applySPBox()
            self.smallSwap()
            s.0.x ^= $0
            
            self.applySPBox()
            
            self.applySPBox()
            self.bigSwap()
            
            self.applySPBox()
        }
    }
    
    @inline(__always)
    private mutating func applySPBox() {
        let x = s.0.rotated(by: 24)
        let y = s.1.rotated(by:  9)
        let z = s.2
        
        s.2 = x ^ (z &<< 1) ^ ((y & z) &<< 2)
        s.1 = y ^  x        ^ ((x | z) &<< 1)
        s.0 = z ^  y        ^ ((x & y) &<< 3)
    }
    
    @inline(__always)
    private mutating func smallSwap() {
        s.0 = s.0[SIMD4(1, 0, 3, 2)]
    }
    
    @inline(__always)
    private mutating func bigSwap() {
        s.0 = s.0[SIMD4(2, 3, 0, 1)]
    }
}

extension SIMD4 where Scalar == UInt32 {
    @inline(__always)
    func rotated(by n: UInt32) -> Self {
        (self &<< n) | (self &>> (32 &- n))
    }
}

extension Gimli: Equatable {
    public static func == (lhs: Gimli, rhs: Gimli) -> Bool {
        lhs.s.0 == rhs.s.0 && lhs.s.1 == rhs.s.1 && lhs.s.2 == rhs.s.2
    }
}
