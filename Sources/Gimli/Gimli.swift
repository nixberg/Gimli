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
        self.quadrupleRound(0x9e377918)
        self.quadrupleRound(0x9e377914)
        self.quadrupleRound(0x9e377910)
        self.quadrupleRound(0x9e37790c)
        self.quadrupleRound(0x9e377908)
        self.quadrupleRound(0x9e377904)
    }
    
    private mutating func quadrupleRound(_ constant: UInt32) {
        self.applySPBox()
        self.smallSwap()
        s.0.x ^= constant
        
        self.applySPBox()
        
        self.applySPBox()
        self.bigSwap()
        
        self.applySPBox()
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

fileprivate extension SIMD4 where Scalar == UInt32 {
    @inline(__always)
    func rotated(by n: UInt32) -> Self {
        (self &<< n) | (self &>> (32 &- n))
    }
}
